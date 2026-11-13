package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.Comment;
import TranDucTai.Tailuatruyen.entity.Story;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.CommentRepository;
import TranDucTai.Tailuatruyen.repository.StoryRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CommentService {

    @Autowired private CommentRepository commentRepository;
    @Autowired private StoryRepository storyRepository;
    @Autowired private UserRepository userRepository;

    // Giai đoạn 6: phân trang bình luận theo truyện, mới nhất trước
    public Page<Comment> listByStory(Long storyId, Pageable pageable) {
        return commentRepository.findByStoryIdOrderByCreatedAtDesc(storyId, pageable);
    }

    @Transactional
    public Comment create(Long userId, Long storyId, String content) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> AppException.unauthorized("Tài khoản không hợp lệ!"));
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy truyện!"));

        Comment comment = Comment.builder()
                .user(user)
                .story(story)
                .content(content)
                .build();
        return commentRepository.save(comment);
    }

    @Transactional
    public void delete(Long userId, String role, Long commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy bình luận!"));

        // Chỉ chủ bình luận hoặc ADMIN mới được xoá
        boolean isOwner = comment.getUser().getId().equals(userId);
        boolean isAdmin = "ADMIN".equals(role);
        if (!isOwner && !isAdmin) {
            throw AppException.forbidden("Bạn không có quyền xoá bình luận này!");
        }
        commentRepository.delete(comment);
    }
}
