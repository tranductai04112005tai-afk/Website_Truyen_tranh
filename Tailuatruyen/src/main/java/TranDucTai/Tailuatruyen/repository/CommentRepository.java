package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    // Phân trang bình luận theo truyện, mới nhất lên đầu (Giai đoạn 6)
    Page<Comment> findByStoryIdOrderByCreatedAtDesc(Long storyId, Pageable pageable);
}
