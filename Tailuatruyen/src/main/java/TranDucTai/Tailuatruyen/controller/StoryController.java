package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.StorySummaryResponse;
import TranDucTai.Tailuatruyen.entity.Story;
import TranDucTai.Tailuatruyen.service.StoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stories")
public class StoryController {

    @Autowired private StoryService storyService;

    // Giai đoạn 3: GET /api/stories - danh sách truyện, phân trang, có thể tìm theo tên (?search=)
    @GetMapping
    public ResponseEntity<Page<StorySummaryResponse>> list(@RequestParam(required = false) String search,
                                                             @RequestParam(defaultValue = "0") int page,
                                                             @RequestParam(defaultValue = "20") int size) {
        Page<Story> stories = storyService.listActive(search, PageRequest.of(normalizePage(page), normalizeSize(size)));
        Page<StorySummaryResponse> body = stories.map(s -> StorySummaryResponse.from(s, storyService.countChapters(s.getId())));
        return ResponseEntity.ok(body);
    }

    private int normalizePage(int page) {
        return Math.max(page, 0);
    }

    private int normalizeSize(int size) {
        return Math.min(Math.max(size, 1), 100);
    }

    // GET /api/stories/{id} - chi tiết truyện (không kèm nội dung chương, dùng /api/chapters?storyId= để lấy danh sách chương)
    @GetMapping("/{id}")
    public ResponseEntity<StorySummaryResponse> getById(@PathVariable Long id) {
        Story story = storyService.getPublicById(id);
        long chapterCount = storyService.countChapters(id);
        return ResponseEntity.ok(StorySummaryResponse.from(story, chapterCount));
    }
}
