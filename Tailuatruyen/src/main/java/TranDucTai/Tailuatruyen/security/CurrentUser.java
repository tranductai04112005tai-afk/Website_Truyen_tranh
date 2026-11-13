package TranDucTai.Tailuatruyen.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * Helper đọc userId hiện tại từ SecurityContext (đã được JwtAuthFilter set sẵn),
 * để Controller không phải tự parse header Authorization / gọi JwtService thủ công nữa.
 */
@Component
public class CurrentUser {

    // Trả về null nếu request chưa đăng nhập (khách/guest) - KHÔNG ném lỗi ở đây,
    // vì có API cho phép cả khách lẫn thành viên (ví dụ đọc chương miễn phí).
    public Long getIdOrNull() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || !(auth.getPrincipal() instanceof Long)) {
            return null;
        }
        return (Long) auth.getPrincipal();
    }

    public Long requireId() {
        Long id = getIdOrNull();
        if (id == null) {
            throw TranDucTai.Tailuatruyen.exception.AppException.unauthorized("Bạn cần đăng nhập để thực hiện thao tác này!");
        }
        return id;
    }

    // Đọc role hiện tại (VD: "ADMIN") từ authority "ROLE_ADMIN" mà JwtAuthFilter đã gán vào SecurityContext
    public String getRoleOrNull() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return null;
        return auth.getAuthorities().stream()
                .map(a -> a.getAuthority().replaceFirst("^ROLE_", ""))
                .findFirst()
                .orElse(null);
    }
}
