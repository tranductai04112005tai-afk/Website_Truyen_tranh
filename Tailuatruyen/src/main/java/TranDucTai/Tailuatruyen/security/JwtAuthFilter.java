package TranDucTai.Tailuatruyen.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import TranDucTai.Tailuatruyen.repository.UserRepository;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final Long userId;

        // Nếu không có token thì cho đi tiếp (tới các API public)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7); // Cắt bỏ chữ "Bearer "

        try {
            if (!jwtService.isTokenValid(jwt)) {
                filterChain.doFilter(request, response);
                return;
            }
            userId = jwtService.extractUserId(jwt);
            String role;

            if (userId != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                // Chặn ngay tài khoản đã bị Admin khoá (Giai đoạn 8), kể cả khi JWT còn hạn
                var user = userRepository.findById(userId).orElse(null);
                if (user == null || Boolean.TRUE.equals(user.getLocked()) || user.getRole() == null) {
                    filterChain.doFilter(request, response);
                    return;
                }
                // Quyền hiện tại trong DB là nguồn chính, tránh JWT cũ giữ quyền sau khi role bị đổi.
                role = user.getRole().name();

                // Gán quyền ROLE_xxx từ claim "role" trong JWT để @PreAuthorize / hasRole(...) hoạt động đúng
                List<GrantedAuthority> authorities = role != null
                        ? List.of(new SimpleGrantedAuthority("ROLE_" + role))
                        : List.of();

                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userId, null, authorities);
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        } catch (Exception e) {
            // Token hỏng/hết hạn -> bỏ qua, coi như request chưa đăng nhập (để các API public vẫn chạy được)
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }
}
