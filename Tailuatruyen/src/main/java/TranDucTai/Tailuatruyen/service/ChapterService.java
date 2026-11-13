package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.*;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ChapterService {
    @Autowired private ChapterRepository chapterRepository;
    @Autowired private MembershipService membershipService;
    @Autowired private WalletService walletService;
    @Autowired private StoryRepository storyRepository;

    // Dùng @Transactional để đảm bảo nếu trừ tiền lỗi thì rollback lại toàn bộ
    @Transactional
    public String getChapterContent(Long userId, Long chapterId) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy chương!"));

        if (!Boolean.TRUE.equals(chapter.getVisible())
            || chapter.getStory().getStatus() != StatusEnum.ACTIVE) {
            throw AppException.notFound("Chương này đang tạm ẩn!");
        }

        // 1. Luồng 1: Nếu chương nằm trong 40% MIỄN PHÍ -> Cho đọc luôn
        if (Boolean.TRUE.equals(chapter.getIsFree())) {
            return chapter.getContent();
        }

        // 2. Từ đây trở xuống là chương TRẢ PHÍ (60%). Kiểm tra đăng nhập
        if (userId == null) {
            throw AppException.unauthorized("Bạn cần đăng nhập để đọc chương này!");
        }

        // 3. Luồng 2: Kiểm tra xem User có gói Hội viên VIP không?
        if (membershipService.hasActiveVip(userId)) {
            return chapter.getContent(); // VIP đọc miễn phí
        }

        // 4. Luồng 3: Nếu là Member thường -> Trừ Bạc (có khoá pessimistic lock chống race condition)
        walletService.debit(userId, chapter.getPriceInSilver(), TypeEnum.BUY_CHAPTER);

        return chapter.getContent();
    }

    // Giai đoạn 3: tự tính lại isFree cho toàn bộ chương của 1 truyện dựa trên tỉ lệ 40% đầu tiên.
    // Gọi lại mỗi khi crawler lưu chương mới (Giai đoạn 7), vì tổng số chương thay đổi làm mốc 40% dịch chuyển.
    @Transactional
    public void recalculateFreemium(Long storyId) {
        List<Chapter> chapters = chapterRepository.findByStoryIdOrderByChapterNumberAsc(storyId);
        int total = chapters.size();
        if (total == 0) return;

        int freeCount = (int) Math.ceil(total * 0.4);
        for (int i = 0; i < total; i++) {
            Chapter c = chapters.get(i);
            boolean shouldBeFree = i < freeCount;
            if (!shouldBeFree && (c.getPriceInSilver() == null || c.getPriceInSilver() == 0L)) {
                c.setPriceInSilver(50L); // giá mặc định chương trả phí, có thể cho Admin chỉnh sau
            }
            c.setIsFree(shouldBeFree);
        }
        chapterRepository.saveAll(chapters);
    }

    // Giai đoạn 8: Admin ẩn/hiện 1 chương (ví dụ chương crawl lỗi, nội dung vi phạm...)
    @Transactional
    public Chapter toggleVisibility(Long chapterId) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy chương!"));
        chapter.setVisible(!Boolean.TRUE.equals(chapter.getVisible()));
        return chapterRepository.save(chapter);
    }

    // Giai đoạn 8: Admin tạo chương thủ công (truyện không lấy từ crawler, hoặc cần chỉnh sửa gấp).
    // Tự tính lại isFree cho cả truyện sau khi thêm, đúng quy tắc Freemium 40/60 (Giai đoạn 3/7).
    @Transactional
    public Chapter createManual(Long storyId, TranDucTai.Tailuatruyen.dto.ChapterRequest request) {
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy truyện!"));

        if (chapterRepository.existsByStoryAndChapterNumber(story, request.chapterNumber())) {
            throw AppException.conflict("Truyện này đã có chương số " + request.chapterNumber() + " rồi!");
        }

        Chapter chapter = Chapter.builder()
                .story(story)
                .chapterNumber(request.chapterNumber())
                .title(request.title())
                .content(request.content())
                .isFree(true) // giá trị tạm, recalculateFreemium() bên dưới sẽ tính lại đúng
                .priceInSilver(0L)
                .visible(true)
                .build();
        chapter = chapterRepository.save(chapter);

        recalculateFreemium(storyId);
        return chapter;
    }

    @Transactional
    public Chapter updateManual(Long chapterId, TranDucTai.Tailuatruyen.dto.ChapterRequest request) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy chương!"));
        chapter.setChapterNumber(request.chapterNumber());
        chapter.setTitle(request.title());
        chapter.setContent(request.content());
        chapter = chapterRepository.save(chapter);

        recalculateFreemium(chapter.getStory().getId());
        return chapter;
    }
}
