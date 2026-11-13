package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import TranDucTai.Tailuatruyen.security.CurrentUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Endpoint thong tin nguoi dung dang dang nhap.
 * GET /api/users/me - frontend goi de dong bo so du sau giao dich ma khong can logout/login lai.
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired private UserRepository userRepository;
    @Autowired private CurrentUser currentUser;

    @GetMapping("/me")
    public ResponseEntity<?> me() {
        Long userId = currentUser.requireId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> AppException.unauthorized("Tai khoan khong hop le!"));

        return ResponseEntity.ok(Map.of(
                "userId", user.getId(),
                "email", user.getEmail() != null ? user.getEmail() : "",
                "displayName", user.getDisplayName() != null ? user.getDisplayName() : "",
                "role", user.getRole().name(),
                "silverBalance", user.getSilverBalance(),
                "locked", Boolean.TRUE.equals(user.getLocked())
        ));
    }

}