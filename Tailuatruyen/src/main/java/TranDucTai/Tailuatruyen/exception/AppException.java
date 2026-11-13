package TranDucTai.Tailuatruyen.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception nghiệp vụ dùng chung cho toàn bộ Service.
 * Thay thế cho việc ném RuntimeException("401: ...") rồi parse chuỗi ở Controller (dễ vỡ, khó bảo trì).
 */
public class AppException extends RuntimeException {
    private final HttpStatus status;

    public AppException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }

    // ---- Factory method cho các lỗi hay dùng nhất, để Service gọi cho gọn ----
    public static AppException notFound(String message) {
        return new AppException(HttpStatus.NOT_FOUND, message);
    }

    public static AppException unauthorized(String message) {
        return new AppException(HttpStatus.UNAUTHORIZED, message);
    }

    public static AppException paymentRequired(String message) {
        return new AppException(HttpStatus.PAYMENT_REQUIRED, message);
    }

    public static AppException conflict(String message) {
        return new AppException(HttpStatus.CONFLICT, message);
    }

    public static AppException badRequest(String message) {
        return new AppException(HttpStatus.BAD_REQUEST, message);
    }

    public static AppException forbidden(String message) {
        return new AppException(HttpStatus.FORBIDDEN, message);
    }
}
