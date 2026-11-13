package TranDucTai.Tailuatruyen.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "crawler_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CrawlerLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_id", nullable = false)
    private CrawlerSource source;

    // Có thể null nếu lần chạy đó crawl lỗi, không insert được truyện nào
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "story_id")
    private Story story;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusEnum status;

    @Column(length = 1000)
    private String message;

    @Column(name = "crawled_at", updatable = false)
    private LocalDateTime crawledAt;

    @PrePersist
    protected void onCreate() {
        this.crawledAt = LocalDateTime.now();
    }
}