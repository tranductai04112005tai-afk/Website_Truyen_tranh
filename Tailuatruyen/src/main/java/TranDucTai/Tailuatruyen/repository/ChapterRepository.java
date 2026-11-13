package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.Chapter;
import TranDucTai.Tailuatruyen.entity.Story;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChapterRepository extends JpaRepository<Chapter, Long> {
    // Kiểm tra chương đã tồn tại chưa để tránh crawl trùng khi chạy lại nhiều lần
    boolean existsByStoryAndChapterNumber(Story story, Integer chapterNumber);

    // Đếm số chương hiện có của 1 truyện để biết crawl tiếp từ chương nào
    long countByStory(Story story);

    // Danh sách chương của 1 truyện, phân trang, sắp theo số chương tăng dần (Giai đoạn 3)
    Page<Chapter> findByStoryIdOrderByChapterNumberAsc(Long storyId, Pageable pageable);

    Page<Chapter> findByStoryIdAndVisibleTrueOrderByChapterNumberAsc(Long storyId, Pageable pageable);

    // Lấy toàn bộ chương của 1 truyện (không phân trang) để tính lại isFree sau khi crawl (Giai đoạn 7)
    java.util.List<Chapter> findByStoryIdOrderByChapterNumberAsc(Long storyId);

    Optional<Chapter> findByStoryIdAndChapterNumber(Long storyId, Integer chapterNumber);
}
