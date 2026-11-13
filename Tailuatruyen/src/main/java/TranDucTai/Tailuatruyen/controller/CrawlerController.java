package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.entity.CrawlerLog;
import TranDucTai.Tailuatruyen.entity.CrawlerSource;
import TranDucTai.Tailuatruyen.repository.CrawlerLogRepository;
import TranDucTai.Tailuatruyen.repository.CrawlerSourceRepository;
import TranDucTai.Tailuatruyen.service.CrawlerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.List;
import java.util.Map;

// API quản trị nguồn crawl. TODO: khi bật SecurityConfig, giới hạn các endpoint này cho ADMIN.
@RestController
@RequestMapping("/api/crawler")
public class CrawlerController {

    @Autowired private CrawlerService crawlerService;
    @Autowired private CrawlerSourceRepository crawlerSourceRepository;
    @Autowired private CrawlerLogRepository crawlerLogRepository;

    // Danh sách các nguồn (web khác) đã cấu hình để crawl
    @GetMapping("/sources")
    public ResponseEntity<List<CrawlerSource>> getSources() {
        return ResponseEntity.ok(crawlerSourceRepository.findAll());
    }

    // Thêm 1 nguồn crawl mới - mỗi nguồn là 1 trang truyện trên 1 website,
    // có thể ghi đè selector nếu web đó có cấu trúc HTML khác TruyenFull
    @PostMapping("/sources")
    public ResponseEntity<?> addSource(@Valid @RequestBody CrawlerSource source) {
        if (source.getBaseUrl() == null || source.getBaseUrl().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Thiếu baseUrl (link truyện cần crawl)!"));
        }
        if (source.getName() == null || source.getName().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Thiếu tên nguồn (name)!"));
        }
        // Không cho client tự set id/lastCrawledAt để tránh ghi đè dữ liệu hệ thống
        source.setId(null);
        source.setLastCrawledAt(null);
        CrawlerSource saved = crawlerSourceRepository.save(source);
        return ResponseEntity.ok(saved);
    }

    // Bật/tắt 1 nguồn mà không cần xoá cấu hình
    @PatchMapping("/sources/{id}/toggle")
    public ResponseEntity<?> toggleSource(@PathVariable Long id) {
        return crawlerSourceRepository.findById(id)
                .map(source -> {
                    source.setActive(!source.getActive());
                    crawlerSourceRepository.save(source);
                    return ResponseEntity.ok(source);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // Chạy crawler thủ công cho TẤT CẢ nguồn đang bật - chạy nền, trả lời ngay không chờ crawl xong
    @PostMapping("/run")
    public ResponseEntity<?> runAll() {
        crawlerService.crawlAllActiveSources();
        return ResponseEntity.ok(Map.of("message", "Đã bắt đầu crawl toàn bộ nguồn đang bật ở chế độ nền."));
    }

    // Chạy crawler thủ công cho 1 nguồn cụ thể
    @PostMapping("/run/{sourceId}")
    public ResponseEntity<?> runOne(@PathVariable Long sourceId) {
        if (!crawlerSourceRepository.existsById(sourceId)) {
            return ResponseEntity.notFound().build();
        }
        crawlerService.crawlSourceById(sourceId);
        return ResponseEntity.ok(Map.of("message", "Đã bắt đầu crawl nguồn id = " + sourceId + " ở chế độ nền."));
    }

    // Xem lịch sử crawl gần nhất để debug khi bị lỗi (thay cho việc chỉ log ra console)
    @GetMapping("/logs")
    public ResponseEntity<List<CrawlerLog>> getLogs() {
        return ResponseEntity.ok(crawlerLogRepository.findTop50ByOrderByCrawledAtDesc());
    }
}
