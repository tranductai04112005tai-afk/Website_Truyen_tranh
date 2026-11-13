package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.entity.RoleEnum;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.entity.VipPackage;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import TranDucTai.Tailuatruyen.repository.VipPackageRepository;
import TranDucTai.Tailuatruyen.security.JwtService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.hamcrest.Matchers.greaterThan;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Giai đoạn 10: Integration Test - luồng đầy đủ Controller -> JwtAuthFilter -> Service -> Repository -> DB (H2)
 * cho tính năng mua gói VIP (Giai đoạn 5). Dùng JWT thật (sinh bằng JwtService) thay vì mock Security,
 * để test luôn cả bước xác thực JwtAuthFilter chứ không chỉ nghiệp vụ mua gói.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class MembershipControllerIT {

    @Autowired private MockMvc mockMvc;
    @Autowired private UserRepository userRepository;
    @Autowired private VipPackageRepository vipPackageRepository;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private JwtService jwtService;

    private User user;
    private VipPackage vipPackage;
    private String token;

    @BeforeEach
    void setUp() {
        user = userRepository.save(User.builder()
                .email("member-" + System.nanoTime() + "@test.com")
                .role(RoleEnum.MEMBER)
                .silverBalance(100000L)
                .locked(false)
                .build());

        vipPackage = vipPackageRepository.save(VipPackage.builder()
                .name("Gói Test 1 Tháng")
                .durationMonths(1)
                .priceInSilver(50000L)
                .build());

        // Sinh JWT thật cho user vừa tạo, đúng như luồng AuthController trả về sau khi đăng nhập Google
        token = jwtService.generateToken(user.getId(), user.getRole().name());
    }

    @Test
    void getPackages_isPublic_returnsSeededPackage() throws Exception {
        mockMvc.perform(get("/api/memberships/packages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()", greaterThan(0)));
    }

    @Test
    void purchase_withoutToken_shouldReturn401() throws Exception {
        Map<String, Object> body = Map.of("packageId", vipPackage.getId());

        mockMvc.perform(post("/api/memberships/purchase")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void purchase_shouldSucceed_andDeductSilverBalance() throws Exception {
        Map<String, Object> body = Map.of("packageId", vipPackage.getId());

        mockMvc.perform(post("/api/memberships/purchase")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Mua gói hội viên thành công!"));

        User reloaded = userRepository.findById(user.getId()).orElseThrow();
        org.assertj.core.api.Assertions.assertThat(reloaded.getSilverBalance()).isEqualTo(50000L);
    }

    @Test
    void purchase_shouldReturn402_whenNotEnoughSilver() throws Exception {
        user.setSilverBalance(1000L); // không đủ 50,000 giá gói
        userRepository.save(user);

        Map<String, Object> body = Map.of("packageId", vipPackage.getId());

        mockMvc.perform(post("/api/memberships/purchase")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isPaymentRequired());
    }

    @Test
    void purchase_shouldReturn400_whenPackageIdMissing() throws Exception {
        mockMvc.perform(post("/api/memberships/purchase")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content("{}"))
                .andExpect(status().isBadRequest());
    }
}
