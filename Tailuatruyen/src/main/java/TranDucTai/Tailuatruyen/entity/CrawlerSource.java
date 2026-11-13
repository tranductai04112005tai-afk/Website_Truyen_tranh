package TranDucTai.Tailuatruyen.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "crawler_sources")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CrawlerSource {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    @NotBlank(message = "Tên nguồn không được để trống")
    private String name; // Tên gợi nhớ, VD: "TruyenFull - Xuyên Đến Thập Niên 70"

    // Link trang chi tiết của truyện cần crawl (không phải link trang chủ)
    @Column(nullable = false, length = 1000)
    @NotBlank(message = "URL nguồn không được để trống")
    private String baseUrl;

    @Column(nullable = false)
    @NotBlank(message = "Cron expression không được để trống")
    private String cronExpression; // Lưu để hiển thị/tham khảo lịch chạy dự kiến

    // Bật/tắt nguồn mà không cần xoá cấu hình đã lưu
    @Builder.Default
    @Column(nullable = false)
    private Boolean active = true;

    // Giới hạn số chương tối đa crawl cho nguồn này (an toàn, tránh treo server)
    @Builder.Default
    @Column(nullable = false)
    @NotNull(message = "maxChapters không được để trống")
    @Min(value = 1, message = "maxChapters phải lớn hơn 0")
    private Integer maxChapters = 20;

    // ---- CSS selector riêng cho từng website (mỗi trang có cấu trúc HTML khác nhau) ----
    // Mặc định set sẵn theo cấu trúc của TruyenFull, nguồn khác có thể ghi đè khi tạo mới
    @Builder.Default
    private String titleSelector = "h1";

    @Builder.Default
    private String authorSelector = "a[itemprop='author']";

    @Builder.Default
    private String descriptionSelector = "div.desc-text";

    @Builder.Default
    private String chapterListSelector = ".list-chapter ul li a";

    @Builder.Default
    private String chapterContentSelector = "div.chapter-c";

    private LocalDateTime lastCrawledAt;
}
