package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.DevLoginRequest;
import TranDucTai.Tailuatruyen.entity.RoleEnum;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import TranDucTai.Tailuatruyen.security.GoogleTokenVerifierService;
import TranDucTai.Tailuatruyen.security.JwtService;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired private GoogleTokenVerifierService googleVerifier;
    @Autowired private UserRepository userRepository;
    @Autowired private JwtService jwtService;
    @Autowired private TranDucTai.Tailuatruyen.service.MembershipService membershipService;

    @Value("${app.security.dev-login-enabled:false}")
    private boolean devLoginEnabled;

    @PostMapping("/google")
    public ResponseEntity<?> authenticateGoogle(@RequestBody Map<String, String> request) {
        String idToken = request.get("idToken");
        if (idToken == null || idToken.isBlank()) {
            throw AppException.unauthorized("Token Google không được để trống!");
        }

        // 1. Xác minh token với Google
        GoogleIdToken.Payload payload = googleVerifier.verifyToken(idToken);
        if (payload == null) {
            throw AppException.unauthorized("Token Google không hợp lệ hoặc đã hết hạn!");
        }

        String email = payload.getEmail();
        String googleId = payload.getSubject();
        String name = (String) payload.get("name");

        // 2. JIT Provisioning (Giai đoạn 2):
        //    - Tìm theo googleId trước (đây là khoá định danh chính, không đổi qua các lần login).
        //    - Nếu chưa từng đăng nhập Google nhưng email đã tồn tại (VD: tài khoản Admin được seed sẵn
        //      trong data.sql, chưa gắn googleId) -> gắn googleId vào tài khoản đó thay vì tạo trùng.
        //    - Nếu không có cả hai -> tạo mới User với role mặc định GUEST.
        User user = userRepository.findByGoogleId(googleId)
                .or(() -> userRepository.findByEmail(email))
                .orElseGet(() -> User.builder()
                        .role(RoleEnum.GUEST)
                        .silverBalance(0L)
                        .locked(false)
                        .build());

        if (Boolean.TRUE.equals(user.getLocked())) {
            throw AppException.forbidden("Tài khoản của bạn đã bị khoá. Vui lòng liên hệ quản trị viên!");
        }

        // Luôn đồng bộ lại thông tin mới nhất từ Google (đúng yêu cầu "nếu đã có -> cập nhật thông tin")
        user.setGoogleId(googleId);
        user.setEmail(email);
        if (name != null && !name.isBlank()) {
            user.setDisplayName(name);
        } else if (user.getDisplayName() == null || user.getDisplayName().isBlank()) {
            user.setDisplayName(email);
        }
        user = userRepository.save(user);
        membershipService.syncUserVipRole(user.getId());

        // 3. Sinh JWT nội bộ của hệ thống trả về cho ReactJS
        String jwt = jwtService.generateToken(user.getId(), user.getRole().name());

        // 4. Đóng gói dữ liệu trả về cho Frontend
        Map<String, Object> response = new HashMap<>();
        response.put("token", jwt);
        response.put("userId", user.getId());
        response.put("role", user.getRole().name());
        response.put("displayName", user.getDisplayName());
        response.put("silverBalance", user.getSilverBalance());

        return ResponseEntity.ok(response);
    }

    /**
     * CHỈ DÙNG ĐỂ TEST (Postman/local dev) - KHÔNG xác minh Google, tự cấp JWT theo email + role bất kỳ.
     * Bị tắt hoàn toàn (trả 404) khi app.security.dev-login-enabled=false.
     * BẮT BUỘC set false khi deploy production (xem application.yml).
     */
    @PostMapping("/dev-login")
    public ResponseEntity<?> devLogin(@Valid @RequestBody DevLoginRequest request) {
        if (!devLoginEnabled) {
            throw AppException.notFound("Không tìm thấy tài nguyên!");
        }

        User user = userRepository.findByEmail(request.email())
                .orElseGet(() -> User.builder()
                        .email(request.email())
                        .role(RoleEnum.MEMBER)
                        .silverBalance(0L)
                        .locked(false)
                        .build());

        if (request.displayName() != null && !request.displayName().isBlank()) {
            user.setDisplayName(request.displayName());
        } else if (user.getDisplayName() == null || user.getDisplayName().isBlank()) {
            user.setDisplayName(user.getEmail());
        }
        if (request.role() != null) {
            user.setRole(request.role());
        }
        if (request.silverBalance() != null) {
            user.setSilverBalance(request.silverBalance());
        }
        user = userRepository.save(user);
        membershipService.syncUserVipRole(user.getId());

        String jwt = jwtService.generateToken(user.getId(), user.getRole().name());

        Map<String, Object> response = new HashMap<>();
        response.put("token", jwt);
        response.put("userId", user.getId());
        response.put("role", user.getRole().name());
        response.put("displayName", user.getDisplayName());
        response.put("silverBalance", user.getSilverBalance());
        return ResponseEntity.ok(response);
    }
}
