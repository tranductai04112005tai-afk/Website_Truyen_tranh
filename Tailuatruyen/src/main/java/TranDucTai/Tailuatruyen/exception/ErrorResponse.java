package TranDucTai.Tailuatruyen.exception;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Cấu trúc lỗi thống nhất trả về cho Frontend (Giai đoạn 9).
 */
public record ErrorResponse(
        LocalDateTime timestamp,
        int status,
        String error,
        String message,
        List<String> details
) {
    public ErrorResponse(int status, String error, String message) {
        this(LocalDateTime.now(), status, error, message, null);
    }

    public ErrorResponse(int status, String error, String message, List<String> details) {
        this(LocalDateTime.now(), status, error, message, details);
    }
}
