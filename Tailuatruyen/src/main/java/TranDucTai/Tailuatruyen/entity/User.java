package TranDucTai.Tailuatruyen.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "google_id", unique = true)
    @JsonIgnore
    private String googleId; // Dùng cho OAuth2 Google

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "display_name")
    private String displayName;

    @JsonIgnore
    private String passwordHash; // Dùng nếu đăng ký thủ công

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoleEnum role = RoleEnum.GUEST; // Mặc định là Khách

    @Builder.Default
    @Column(name = "silver_balance", nullable = false)
    private Long silverBalance = 0L;

    // Giai đoạn 8: Admin có thể khoá tài khoản vi phạm mà không cần xoá dữ liệu (lịch sử giao dịch, bình luận...)
    @Builder.Default
    @Column(nullable = false)
    private Boolean locked = false;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}