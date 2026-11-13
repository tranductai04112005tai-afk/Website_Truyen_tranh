package TranDucTai.Tailuatruyen.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "vip_packages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VipPackage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name; // Ví dụ: Gói 1 Tháng, 3 Tháng...

    @Column(nullable = false)
    private Integer durationMonths;

    @Column(nullable = false)
    private Long priceInSilver;
}
