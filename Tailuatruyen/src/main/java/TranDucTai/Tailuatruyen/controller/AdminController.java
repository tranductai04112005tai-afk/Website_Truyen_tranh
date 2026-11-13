package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.ChangeRoleRequest;
import TranDucTai.Tailuatruyen.dto.ChapterRequest;
import TranDucTai.Tailuatruyen.dto.StorySummaryResponse;
import TranDucTai.Tailuatruyen.dto.StoryRequest;
import TranDucTai.Tailuatruyen.entity.Chapter;
import TranDucTai.Tailuatruyen.entity.Story;
import TranDucTai.Tailuatruyen.entity.Transaction;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.repository.ChapterRepository;
import TranDucTai.Tailuatruyen.repository.TransactionRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import TranDucTai.Tailuatruyen.service.AdminService;
import TranDucTai.Tailuatruyen.service.ChapterService;
import TranDucTai.Tailuatruyen.service.StoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Giai đoạn 8: API quản trị. Toàn bộ /api/admin/** đã bị chặn ở SecurityConfig (chỉ ROLE_ADMIN),
 * @PreAuthorize thêm ở đây chỉ để phòng thủ theo chiều sâu (defense in depth) nếu SecurityConfig bị sửa nhầm sau này.
 */
@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired private UserRepository userRepository;
    @Autowired private TransactionRepository transactionRepository;
    @Autowired private ChapterRepository chapterRepository;
    @Autowired private AdminService adminService;
    @Autowired private StoryService storyService;
    @Autowired private ChapterService chapterService;

    // ---- Quản lý người dùng ----
    @GetMapping("/users")
    public ResponseEntity<Page<User>> listUsers(@RequestParam(defaultValue = "0") int page,
                                                 @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(userRepository.findAll(PageRequest.of(page, size)));
    }

    @PatchMapping("/users/{id}/lock")
    public ResponseEntity<User> toggleLock(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.toggleLock(id));
    }

    @PatchMapping("/users/{id}/role")
    public ResponseEntity<User> changeRole(@PathVariable Long id, @Valid @RequestBody ChangeRoleRequest request) {
        return ResponseEntity.ok(adminService.changeRole(id, request.role()));
    }

    // ---- Quản lý truyện & chương (CRUD, ẩn/hiện) ----
    // Trả về DTO thay vì entity thô để tránh serialize lazy chapters và circular reference
    @GetMapping("/stories")
    public ResponseEntity<List<StorySummaryResponse>> listStories() {
        List<Story> stories = storyService.listAll();
        List<StorySummaryResponse> body = stories.stream()
                .map(s -> StorySummaryResponse.from(s, storyService.countChapters(s.getId())))
                .toList();
        return ResponseEntity.ok(body);
    }

    @PostMapping("/stories")
    public ResponseEntity<Story> createStory(@Valid @RequestBody StoryRequest request) {
        return ResponseEntity.ok(storyService.create(request));
    }

    @PutMapping("/stories/{id}")
    public ResponseEntity<Story> updateStory(@PathVariable Long id, @Valid @RequestBody StoryRequest request) {
        return ResponseEntity.ok(storyService.update(id, request));
    }

    @DeleteMapping("/stories/{id}")
    public ResponseEntity<Void> deleteStory(@PathVariable Long id) {
        storyService.deleteHard(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/stories/{id}/toggle")
    public ResponseEntity<Story> toggleStory(@PathVariable Long id) {
        return ResponseEntity.ok(storyService.toggleVisibility(id));
    }

    @PatchMapping("/stories/{id}/restore")
    public ResponseEntity<Story> restoreStory(@PathVariable Long id) {
        return ResponseEntity.ok(storyService.restore(id));
    }

    @PatchMapping("/chapters/{id}/toggle")
    public ResponseEntity<Chapter> toggleChapter(@PathVariable Long id) {
        return ResponseEntity.ok(chapterService.toggleVisibility(id));
    }

    @PostMapping("/stories/{storyId}/chapters")
    public ResponseEntity<Chapter> createChapter(@PathVariable Long storyId, @Valid @RequestBody ChapterRequest request) {
        return ResponseEntity.ok(chapterService.createManual(storyId, request));
    }

    @PutMapping("/chapters/{id}")
    public ResponseEntity<Chapter> updateChapter(@PathVariable Long id, @Valid @RequestBody ChapterRequest request) {
        return ResponseEntity.ok(chapterService.updateManual(id, request));
    }

    // Endpoint dành riêng cho Admin: lấy TẤT CẢ chapter của 1 truyện (kể cả chapter bị ẩn visible=false)
    // Public endpoint /api/chapters chỉ trả chapter visible=true, admin cần thấy cả chapter bị ẩn để quản lý
    @GetMapping("/stories/{storyId}/chapters")
    public ResponseEntity<List<Chapter>> listChaptersAdmin(@PathVariable Long storyId) {
        List<Chapter> chapters = chapterRepository.findByStoryIdOrderByChapterNumberAsc(storyId);
        // Null-out story reference để tránh circular serialization (chapter->story->chapters->chapter)
        chapters.forEach(c -> c.setStory(null));
        return ResponseEntity.ok(chapters);
    }

    // ---- Xem/giám sát giao dịch, thống kê ----
    // Sort theo createdAt DESC để admin thấy giao dịch mới nhất trước
    @GetMapping("/transactions")
    public ResponseEntity<Page<Transaction>> listTransactions(@RequestParam(defaultValue = "0") int page,
                                                              @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(transactionRepository.findAll(
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"))
        ));
    }

    @GetMapping("/stats")
    public ResponseEntity<?> stats() {
        return ResponseEntity.ok(adminService.getStats());
    }
}
