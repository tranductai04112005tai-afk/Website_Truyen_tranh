package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.CrawlerSource;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CrawlerSourceRepository extends JpaRepository<CrawlerSource, Long> {
    // Chỉ lấy các nguồn đang được bật (active = true) để chạy crawler
    List<CrawlerSource> findByActiveTrue();
}
