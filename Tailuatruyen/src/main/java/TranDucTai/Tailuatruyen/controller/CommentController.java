package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.CommentRequest;
import TranDucTai.Tailuatruyen.dto.CommentResponse;
import TranDucTai.Tailuatruyen.entity.Comment;
import TranDucTai.Tailuatruyen.security.CurrentUser;
import TranDucTai.Tailuatruyen.service.CommentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/comments")
public class CommentController {

    @Autowired private CommentService commentService;
    @Autowired private CurrentUser currentUser;

    // Public: xem bình luận không cần đăng nhập (đã khai permitAll trong SecurityConfig)
    @GetMapping
    public ResponseEntity<Page<CommentResponse>> list(@RequestParam Long storyId,
                                                        @RequestParam(defaultValue = "0") int page,
                                                        @RequestParam(defaultValue = "20") int size) {
        Page<Comment> comments = commentService.listByStory(storyId,
                PageRequest.of(normalizePage(page), normalizeSize(size)));
        return ResponseEntity.ok(comments.map(CommentResponse::from));
    }

    private int normalizePage(int page) {
        return Math.max(page, 0);
    }

    private int normalizeSize(int size) {
        return Math.min(Math.max(size, 1), 100);
    }

    // Cần đăng nhập để bình luận
    @PostMapping
    public ResponseEntity<CommentResponse> create(@RequestParam Long storyId, @Valid @RequestBody CommentRequest request) {
        Long userId = currentUser.requireId();
        Comment comment = commentService.create(userId, storyId, request.content());
        return ResponseEntity.ok(CommentResponse.from(comment));
    }

    // Chủ bình luận hoặc ADMIN mới được xoá (kiểm tra trong Service)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        Long userId = currentUser.requireId();
        String role = currentUser.getRoleOrNull();
        commentService.delete(userId, role, id);
        return ResponseEntity.ok(Map.of("message", "Đã xoá bình luận."));
    }
}
