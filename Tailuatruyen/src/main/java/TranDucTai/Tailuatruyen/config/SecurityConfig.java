package TranDucTai.Tailuatruyen.config;

import TranDucTai.Tailuatruyen.security.JwtAuthFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.hierarchicalroles.RoleHierarchy;
import org.springframework.security.access.hierarchicalroles.RoleHierarchyImpl;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;
import java.util.Map;

/**
 * Giai đoạn 2: cấu hình SecurityFilterChain.
 * Trước đây JwtAuthFilter được viết ra nhưng KHÔNG được đăng ký vào chain nào cả,
 * nên toàn bộ hệ thống xác thực JWT thực chất chưa từng chạy. File này bật nó lên
 * và khai báo rule phân quyền cho từng nhóm endpoint.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity // bật @PreAuthorize trên Controller/Service
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    @Value("${app.cors.allowed-origins}")
    private List<String> allowedOrigins;

    public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    // ROLE_ADMIN > ROLE_VIP_MEMBER > ROLE_MEMBER > ROLE_GUEST (theo dàn ý Giai đoạn 2)
    @Bean
    public RoleHierarchy roleHierarchy() {
        return RoleHierarchyImpl.withDefaultRolePrefix()
                .role("ADMIN").implies("VIP_MEMBER")
                .role("VIP_MEMBER").implies("MEMBER")
                .role("MEMBER").implies("GUEST")
                .build();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // dùng JWT (stateless), không cần CSRF token
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Public: đăng nhập, đọc danh sách truyện/chương miễn phí, xem bình luận
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/stories/**", "/api/chapters/**", "/api/comments/**", "/api/memberships/packages").permitAll()
                        // Giao dịch / VIP / bình luận (ghi) / crawler / admin: cần đăng nhập, chi tiết quyền xử lý bằng @PreAuthorize trong Controller
                        .requestMatchers("/api/crawler/**", "/api/admin/**").hasRole("ADMIN")
                        .anyRequest().authenticated()
                )
                // Chưa đăng nhập -> 401 (thay vì mặc định 403 của Spring Security khi thiếu AuthenticationEntryPoint),
                // đúng với hợp đồng lỗi thống nhất ở Giai đoạn 9 (401/402/403/404...)
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(unauthorizedEntryPoint())
                        .accessDeniedHandler(accessDeniedHandler())
                )
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper().findAndRegisterModules();
    }

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    @Bean
    public AuthenticationEntryPoint unauthorizedEntryPoint() {
        return (request, response, authException) -> writeJsonError(response, HttpStatus.UNAUTHORIZED,
                "Bạn cần đăng nhập để thực hiện thao tác này!");
    }

    @Bean
    public AccessDeniedHandler accessDeniedHandler() {
        return (request, response, accessDeniedException) -> writeJsonError(response, HttpStatus.FORBIDDEN,
                "Bạn không có quyền thực hiện thao tác này!");
    }

    private void writeJsonError(jakarta.servlet.http.HttpServletResponse response, HttpStatus status, String message) throws java.io.IOException {
        response.setStatus(status.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write(objectMapper.writeValueAsString(Map.of(
                "status", status.value(),
                "error", status.getReasonPhrase(),
                "message", message
        )));
    }

    // Cho phép Frontend ReactJS (domain khác) gọi API kèm header Authorization
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(allowedOrigins);
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
