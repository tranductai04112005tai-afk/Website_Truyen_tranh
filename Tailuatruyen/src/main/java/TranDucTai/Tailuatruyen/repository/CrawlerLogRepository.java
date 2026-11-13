package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.CrawlerLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CrawlerLogRepository extends JpaRepository<CrawlerLog, Long> {
    // Lấy 50 log gần nhất để hiển thị màn hình quản trị / debug khi crawl lỗi
    List<CrawlerLog> findTop50ByOrderByCrawledAtDesc();
}
