package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.Story;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StoryRepository extends JpaRepository<Story, Long> {
    // Dùng để kiểm tra truyện đã tồn tại trong DB (theo link nguồn) trước khi crawl lại
    Optional<Story> findBySourceUrl(String sourceUrl);

    // Danh sách truyện cho trang chủ / trang danh sách (Giai đoạn 3), phân trang
    Page<Story> findByStatus(TranDucTai.Tailuatruyen.entity.StatusEnum status, Pageable pageable);

    // Toàn bộ truyện ACTIVE (không phân trang) - dùng để lọc tìm kiếm theo tên/tác giả không dấu ở tầng service
    java.util.List<Story> findByStatus(TranDucTai.Tailuatruyen.entity.StatusEnum status);

    // Tìm nhanh theo tên (không phân biệt hoa thường) cho ô tìm kiếm - giữ lại để tương thích ngược
    Page<Story> findByTitleContainingIgnoreCaseAndStatus(String title, TranDucTai.Tailuatruyen.entity.StatusEnum status, Pageable pageable);

    // Dùng cho admin: lấy hết truyện, kể cả đã ẩn, để quản trị không làm mất dữ liệu
    java.util.List<Story> findAllByOrderByIdAsc();
}
