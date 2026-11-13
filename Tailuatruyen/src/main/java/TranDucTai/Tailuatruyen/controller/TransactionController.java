package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.TopupRequest;
import TranDucTai.Tailuatruyen.entity.Transaction;
import TranDucTai.Tailuatruyen.security.CurrentUser;
import TranDucTai.Tailuatruyen.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {

    @Autowired private PaymentService paymentService;
    @Autowired private CurrentUser currentUser;

    // 1. FrontEnd gọi để lấy mã QR Nạp Bạc
    @PostMapping("/topup")
    public ResponseEntity<?> createTopup(@Valid @RequestBody TopupRequest request) {
        Long userId = currentUser.requireId();

        Transaction transaction = paymentService.createTopupRequest(userId, request.amount());

        Map<String, Object> response = new HashMap<>();
        response.put("transactionId", transaction.getId());
        response.put("qrCodeUrl", transaction.getQrCode());
        response.put("expiredAt", transaction.getExpiredAt());
        return ResponseEntity.ok(response);
    }

    // 2. Webhook từ cổng thanh toán (hoặc nút "Tôi đã thanh toán" khi demo/mô phỏng) báo giao dịch thành công
    @PostMapping("/{id}/confirm")
    public ResponseEntity<?> confirmPayment(@PathVariable Long id) {
        paymentService.confirmPaymentSuccess(id, currentUser.requireId());
        return ResponseEntity.ok(Map.of("message", "Thanh toán thành công! Hệ thống đã cộng Bạc vào tài khoản."));
    }

    // 3. Frontend poll trạng thái/đếm ngược mã QR
    @GetMapping("/{id}/status")
    public ResponseEntity<?> getStatus(@PathVariable Long id) {
        Transaction transaction = paymentService.getForUser(id, currentUser.requireId());
        return ResponseEntity.ok(Map.of(
                "status", transaction.getStatus(),
                "expiredAt", transaction.getExpiredAt() == null ? "" : transaction.getExpiredAt()
        ));
    }
}
