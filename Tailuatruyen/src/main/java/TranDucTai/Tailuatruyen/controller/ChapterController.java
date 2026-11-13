package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.ChapterSummaryResponse;
import TranDucTai.Tailuatruyen.entity.Chapter;
import TranDucTai.Tailuatruyen.entity.StatusEnum;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.ChapterRepository;
import TranDucTai.Tailuatruyen.repository.StoryRepository;
import TranDucTai.Tailuatruyen.security.CurrentUser;
import TranDucTai.Tailuatruyen.service.ChapterService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/chapters")
public class ChapterController {

    @Autowired private ChapterService chapterService;
    @Autowired private ChapterRepository chapterRepository;
    @Autowired private StoryRepository storyRepository;
    @Autowired private CurrentUser currentUser;

    // Danh sách chương của 1 truyện (chỉ tiêu đề/số chương/isFree, KHÔNG trả nội dung để tránh lộ chương trả phí)
    @GetMapping
        public ResponseEntity<Page<ChapterSummaryResponse>> listByStory(@RequestParam Long storyId,
                                                       @RequestParam(defaultValue = "0") int page,
                                                       @RequestParam(defaultValue = "50") int size) {
        storyRepository.findById(storyId)
            .filter(story -> story.getStatus() == StatusEnum.ACTIVE)
            .orElseThrow(() -> AppException.notFound("Không tìm thấy truyện!"));
        Page<ChapterSummaryResponse> chapters = chapterRepository
                .findByStoryIdAndVisibleTrueOrderByChapterNumberAsc(storyId,
                        PageRequest.of(normalizePage(page), normalizeSize(size)))
            .map(ChapterSummaryResponse::from);
        return ResponseEntity.ok(chapters);
    }

    private int normalizePage(int page) {
        return Math.max(page, 0);
    }

    private int normalizeSize(int size) {
        return Math.min(Math.max(size, 1), 100);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChapterSummaryResponse> getMeta(@PathVariable Long id) {
        Chapter chapter = chapterRepository.findById(id)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy chương!"));
        if (chapter.getStory().getStatus() != StatusEnum.ACTIVE || !Boolean.TRUE.equals(chapter.getVisible())) {
            throw AppException.notFound("Không tìm thấy chương!");
        }
        return ResponseEntity.ok(ChapterSummaryResponse.from(chapter));
    }

    @GetMapping("/{id}/content")
    public ResponseEntity<?> readChapter(@PathVariable Long id) {
        // userId lấy từ SecurityContext (JwtAuthFilter đã set sẵn nếu có token hợp lệ), null nếu là khách
        Long userId = currentUser.getIdOrNull();
        String content = chapterService.getChapterContent(userId, id);
        return ResponseEntity.ok(Map.of("content", content));
    }
}
