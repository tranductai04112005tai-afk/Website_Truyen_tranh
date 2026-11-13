package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.*;
import TranDucTai.Tailuatruyen.repository.ChapterRepository;
import TranDucTai.Tailuatruyen.repository.CrawlerLogRepository;
import TranDucTai.Tailuatruyen.repository.CrawlerSourceRepository;
import TranDucTai.Tailuatruyen.repository.StoryRepository;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Safelist;
import org.jsoup.select.Elements;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class CrawlerService {

    @Autowired private StoryRepository storyRepository;
    @Autowired private ChapterRepository chapterRepository;
    @Autowired private CrawlerSourceRepository crawlerSourceRepository;
    @Autowired private CrawlerLogRepository crawlerLogRepository;
    @Autowired private ChapterService chapterService;

    private static final long DELAY_BETWEEN_REQUESTS_MS = 1000; // chống bị chặn IP
    private static final String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
    private static final int TIMEOUT_MS = 10000;

    // Chạy tự động mỗi 12 tiếng - quét toàn bộ nguồn đang bật (active = true) trong DB
    @Scheduled(fixedRate = 43200000)
    public void runScheduledCrawl() {
        System.out.println("=== Bắt đầu tiến trình Crawler tự động ===");
        crawlAllActiveSources();
    }

    // Quét toàn bộ nguồn đang active. Chạy nền (@Async) để không block request khi gọi thủ công từ Controller.
    @Async
    public void crawlAllActiveSources() {
        List<CrawlerSource> sources = crawlerSourceRepository.findByActiveTrue();
        if (sources.isEmpty()) {
            System.out.println("Crawler: Không có nguồn nào đang bật (active = true).");
            return;
        }
        for (CrawlerSource source : sources) {
            // Lỗi ở 1 nguồn không được làm dừng các nguồn còn lại
            try {
                crawlOneSource(source);
            } catch (Exception e) {
                System.out.println("Crawler: Lỗi không mong muốn với nguồn [" + source.getName() + "] - " + e.getMessage());
                saveLog(source, null, StatusEnum.FAILED, e.getMessage());
            }
        }
    }

    // Quét 1 nguồn cụ thể theo id - dùng cho nút "Crawl ngay" trên trang quản trị
    @Async
    public void crawlSourceById(Long sourceId) {
        crawlerSourceRepository.findById(sourceId).ifPresentOrElse(
                this::crawlOneSource,
                () -> System.out.println("Crawler: Không tìm thấy nguồn với id = " + sourceId)
        );
    }

    // ---- Logic crawl 1 nguồn: tách phần gọi mạng (chậm, dễ lỗi) ra khỏi transaction ghi DB ----
    private void crawlOneSource(CrawlerSource source) {
        System.out.println("Crawler: Đang xử lý nguồn [" + source.getName() + "] - " + source.getBaseUrl());
        try {
            Document storyDoc = Jsoup.connect(source.getBaseUrl())
                    .userAgent(USER_AGENT)
                    .timeout(TIMEOUT_MS)
                    .get();

            String title = storyDoc.select(source.getTitleSelector()).text();
            String author = storyDoc.select(source.getAuthorSelector()).text();
            String description = storyDoc.select(source.getDescriptionSelector()).text();

            Story story = getOrCreateStory(source.getBaseUrl(), title, author, description);

            Elements chapterLinks = storyDoc.select(source.getChapterListSelector());
            if (chapterLinks.isEmpty()) {
                updateLastCrawled(source);
                saveLog(source, story, StatusEnum.NO_NEW_DATA,
                        "Không tìm thấy chương nào - kiểm tra lại chapterListSelector cho nguồn này.");
                return;
            }

            int alreadyCrawled = (int) chapterRepository.countByStory(story);
            int totalToCrawl = Math.min(chapterLinks.size(), source.getMaxChapters());

            if (alreadyCrawled >= totalToCrawl) {
                updateLastCrawled(source);
                saveLog(source, story, StatusEnum.NO_NEW_DATA,
                        "Truyện đã crawl đủ số chương giới hạn (" + totalToCrawl + ").");
                return;
            }

            int newChaptersSaved = 0;

            for (int i = alreadyCrawled; i < totalToCrawl; i++) {
                int chapterNumber = i + 1;

                if (chapterRepository.existsByStoryAndChapterNumber(story, chapterNumber)) {
                    continue; // đã có rồi, tránh cào trùng
                }

                String chapterUrl = chapterLinks.get(i).attr("abs:href");
                if (chapterUrl == null || chapterUrl.isBlank()) {
                    continue;
                }

                try {
                    Document chapterDoc = Jsoup.connect(chapterUrl)
                            .userAgent(USER_AGENT)
                            .timeout(TIMEOUT_MS)
                            .get();

                    String chapterTitle = chapterDoc.select("a.chapter-title").text();
                    String rawContent = chapterDoc.select(source.getChapterContentSelector()).html();
                    // Làm sạch HTML trước khi lưu để tránh XSS khi hiển thị nội dung chương lên Frontend
                    String chapterContent = Jsoup.clean(rawContent, Safelist.basic());

                    if (chapterContent.isBlank()) {
                        System.out.println("Crawler: Chương " + chapterNumber
                                + " rỗng, bỏ qua (kiểm tra lại chapterContentSelector).");
                        continue;
                    }

                    // Lưu tạm isFree=true/giá=0, giá trị thật sẽ được tính lại ngay bên dưới bởi
                    // recalculateFreemium() dựa trên TỔNG số chương hiện có của cả truyện (đúng yêu cầu Giai đoạn 7),
                    // thay vì chỉ dựa trên totalToCrawl của riêng lượt crawl này.
                    // Ghi từng chương ngay khi cào được (transaction ngắn, riêng biệt)
                    // -> nếu chương sau lỗi thì các chương trước đã lưu vẫn được giữ nguyên
                    saveChapter(story, chapterNumber, chapterTitle, chapterContent, true, 0L);
                    newChaptersSaved++;

                } catch (Exception chapterEx) {
                    System.out.println("Crawler: Lỗi khi crawl chương " + chapterNumber + " - " + chapterEx.getMessage());
                }

                sleepQuietly(DELAY_BETWEEN_REQUESTS_MS);
            }

            updateLastCrawled(source);

            if (newChaptersSaved > 0) {
                // Giai đoạn 7: sau khi lưu chương mới -> tính lại isFree cho TOÀN BỘ chương của truyện,
                // vì tổng số chương thay đổi làm mốc 40% dịch chuyển.
                chapterService.recalculateFreemium(story.getId());
                saveLog(source, story, StatusEnum.SUCCESS, "Crawl thành công " + newChaptersSaved + " chương mới.");
                System.out.println("Crawler: [" + source.getName() + "] đã cào " + newChaptersSaved + " chương mới.");
            } else {
                saveLog(source, story, StatusEnum.NO_NEW_DATA, "Không có chương mới nào được thêm.");
            }

        } catch (Exception e) {
            System.out.println("Crawler: Lỗi nguồn [" + source.getName() + "] - " + e.getMessage());
            saveLog(source, null, StatusEnum.FAILED, e.getMessage());
        }
    }

    // ---- Các thao tác ghi DB tách thành transaction ngắn, độc lập với việc gọi mạng ----

    @Transactional
    public Story getOrCreateStory(String sourceUrl, String title, String author, String description) {
        Optional<Story> existingStory = storyRepository.findBySourceUrl(sourceUrl);
        if (existingStory.isPresent()) {
            return existingStory.get();
        }
        Story story = Story.builder()
                .title(title == null || title.isBlank() ? "Truyện chưa có tên" : title)
                .author(author == null || author.isBlank() ? "Đang cập nhật" : author)
                .description(description)
                .sourceUrl(sourceUrl)
                .status(StatusEnum.ACTIVE)
                .chapters(new ArrayList<>())
                .build();
        return storyRepository.save(story);
    }

    @Transactional
    public void saveChapter(Story story, int chapterNumber, String chapterTitle, String chapterContent,
                             boolean isFree, Long price) {
        Chapter chapter = Chapter.builder()
                .story(story)
                .chapterNumber(chapterNumber)
                .title(chapterTitle == null || chapterTitle.isBlank() ? "Chương " + chapterNumber : chapterTitle)
                .content(chapterContent)
                .isFree(isFree)
                .priceInSilver(price)
                .build();
        chapterRepository.save(chapter);
    }

    @Transactional
    public void updateLastCrawled(CrawlerSource source) {
        source.setLastCrawledAt(LocalDateTime.now());
        crawlerSourceRepository.save(source);
    }

    @Transactional
    public void saveLog(CrawlerSource source, Story story, StatusEnum status, String message) {
        // Cắt bớt message để không vượt quá giới hạn cột DB (length = 1000)
        String safeMessage = message;
        if (safeMessage != null && safeMessage.length() > 1000) {
            safeMessage = safeMessage.substring(0, 1000);
        }
        CrawlerLog log = CrawlerLog.builder()
                .source(source)
                .story(story)
                .status(status)
                .message(safeMessage)
                .build();
        crawlerLogRepository.save(log);
    }

    private void sleepQuietly(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        }
    }
}
