package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.*;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class PaymentService {
    @Autowired private TransactionRepository transactionRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private WalletService walletService;

    // 1. Tạo yêu cầu nạp tiền và sinh QR Code
    @Transactional
    public Transaction createTopupRequest(Long userId, Long amount) {
        if (amount == null || amount <= 0) {
            throw AppException.badRequest("Mệnh giá nạp không hợp lệ!");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> AppException.unauthorized("Tài khoản không tồn tại"));

        Transaction transaction = Transaction.builder()
                .user(user)
                .type(TypeEnum.TOPUP)
                .amount(amount)
                .status(StatusEnum.PENDING)
                .expiredAt(LocalDateTime.now().plusMinutes(15)) // Đếm ngược 15 phút
                // Mô phỏng API sinh URL mã QR (thực tế sẽ gọi VNPay/MoMo)
                .qrCode("https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=Topup_" + amount + "_User_" + userId + "_" + UUID.randomUUID())
                .build();

        return transactionRepository.save(transaction);
    }

    // 2. Xác nhận thanh toán (webhook cổng thanh toán gọi về, hoặc Frontend poll rồi gọi endpoint này khi mô phỏng)
    @Transactional
    public void confirmPaymentSuccess(Long transactionId, Long requesterId) {
        // Khoá dòng Transaction (SELECT ... FOR UPDATE) để 2 lệnh gọi webhook trùng nhau
        // không thể cùng đi qua bước kiểm tra "đang PENDING" rồi cùng cộng Bạc 2 lần
        Transaction transaction = transactionRepository.findByIdForUpdate(transactionId)
                .orElseThrow(() -> AppException.notFound("Giao dịch không tồn tại"));

        if (!transaction.getUser().getId().equals(requesterId)) {
            throw AppException.forbidden("Bạn không có quyền xử lý giao dịch này!");
        }

        if (transaction.getStatus() != StatusEnum.PENDING) {
            throw AppException.conflict("Giao dịch này không còn ở trạng thái chờ thanh toán");
        }

        if (transaction.getExpiredAt().isBefore(LocalDateTime.now())) {
            transaction.setStatus(StatusEnum.EXPIRED);
            transactionRepository.save(transaction);
            throw AppException.conflict("Mã QR đã hết hạn!");
        }

        // Đánh dấu giao dịch gốc thành công (giữ lại làm biên nhận nạp tiền)
        transaction.setStatus(StatusEnum.SUCCESS);
        transactionRepository.save(transaction);

        // Cộng Bạc qua WalletService (có pessimistic lock, tránh cộng trùng nếu webhook gọi 2 lần cùng lúc).
        // Dùng creditBalanceOnly vì Transaction "topup" đã có sẵn ở trên rồi, không tạo thêm bản ghi trùng.
        walletService.creditBalanceOnly(transaction.getUser().getId(), transaction.getAmount());
    }

    @Transactional(readOnly = true)
    public Transaction getForUser(Long transactionId, Long requesterId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> AppException.notFound("Giao dịch không tồn tại"));
        if (!transaction.getUser().getId().equals(requesterId)) {
            throw AppException.forbidden("Bạn không có quyền xem giao dịch này!");
        }
        return transaction;
    }
}
