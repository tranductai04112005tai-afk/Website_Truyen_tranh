package TranDucTai.Tailuatruyen.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "stories")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Story {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String author;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String coverImage;

    // length = 500 (không để 1000+) vì cột unique với charset utf8mb4 trên InnoDB
    // chỉ cho phép tối đa ~3072 byte cho index (500 ký tự x 4 byte/ký tự = 2000 byte, an toàn)
    @Column(unique = true, length = 500)
    private String sourceUrl;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    private StatusEnum status = StatusEnum.ACTIVE;

    @OneToMany(mappedBy = "story", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Chapter> chapters;
}