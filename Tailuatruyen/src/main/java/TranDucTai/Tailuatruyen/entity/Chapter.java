package TranDucTai.Tailuatruyen.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.*;

@Entity
@Table(name = "chapters", uniqueConstraints = {
    @UniqueConstraint(name = "uk_chapter_story_number", columnNames = {"story_id", "chapter_number"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Chapter {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "story_id", nullable = false)
    @JsonIgnore
    private Story story;

    @Column(nullable = false)
    private Integer chapterNumber;

    private String title;

    @Column(columnDefinition = "LONGTEXT")
    private String content;

    // Hai trường quyết định nghiệp vụ Freemium
    @Builder.Default
    @Column(nullable = false)
    private Boolean isFree = true; 

    @Builder.Default
    @Column(nullable = false)
    private Long priceInSilver = 0L;

    // Giai đoạn 8: Admin có thể ẩn 1 chương lỗi/vi phạm mà không cần xoá (giữ lại lịch sử mua/bình luận liên quan)
    @Builder.Default
    @Column(nullable = false)
    private Boolean visible = true;
}