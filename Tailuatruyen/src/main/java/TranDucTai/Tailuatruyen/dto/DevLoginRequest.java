package TranDucTai.Tailuatruyen.dto;

import TranDucTai.Tailuatruyen.entity.RoleEnum;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

// Chỉ dùng cho môi trường dev/test (Postman), KHÔNG xác minh gì cả - xem AuthController.devLogin()
public record DevLoginRequest(
        @NotBlank @Email String email,
        String displayName,
        RoleEnum role,        // mặc định MEMBER nếu để trống
        Long silverBalance    // mặc định 100000 nếu để trống, giúp test nhanh luồng mua chương/VIP
) {
}
