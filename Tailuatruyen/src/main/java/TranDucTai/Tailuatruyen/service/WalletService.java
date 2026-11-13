package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.*;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.TransactionRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Giai đoạn 3/5/10: tách riêng logic trừ/cộng Bạc ra khỏi ChapterService/PaymentService/MembershipService.
 * - Dùng chung 1 chỗ để Unit Test (WalletService.debit()) như dàn ý yêu cầu.
 * - Dùng findByIdForUpdate (SELECT ... FOR UPDATE) để khoá dòng User trong lúc trừ tiền,
 *   tránh race condition khi 2 request cùng lúc mua chương / mua VIP làm số dư bị trừ sai (double-spend).
 */
@Service
public class WalletService {

    @Autowired private UserRepository userRepository;
    @Autowired private TransactionRepository transactionRepository;

    @Transactional
    public void debit(Long userId, Long amount, TypeEnum type) {
        if (amount == null || amount <= 0) {
            throw AppException.badRequest("Số Bạc không hợp lệ!");
        }

        // Khoá dòng User (pessimistic write lock) - request thứ 2 đến cùng lúc sẽ phải đợi request thứ 1 commit xong
        User user = userRepository.findByIdForUpdate(userId)
                .orElseThrow(() -> AppException.unauthorized("Tài khoản không hợp lệ!"));

        if (user.getSilverBalance() < amount) {
            throw AppException.paymentRequired("Số dư Bạc không đủ. Vui lòng nạp thêm!");
        }

        user.setSilverBalance(user.getSilverBalance() - amount);
        userRepository.save(user);

        Transaction transaction = Transaction.builder()
                .user(user)
                .type(type)
                .amount(amount)
                .status(StatusEnum.SUCCESS)
                .build();
        transactionRepository.save(transaction);
    }

    // Cộng Bạc + tự tạo một Transaction mới làm biên nhận (dùng cho các trường hợp cộng Bạc
    // không gắn với 1 Transaction PENDING có sẵn, ví dụ Admin cộng Bạc thủ công cho user)
    @Transactional
    public void credit(Long userId, Long amount, TypeEnum type) {
        creditBalanceOnly(userId, amount);

        Transaction transaction = Transaction.builder()
                .user(userRepository.getReferenceById(userId))
                .type(type)
                .amount(amount)
                .status(StatusEnum.SUCCESS)
                .build();
        transactionRepository.save(transaction);
    }

    // Chỉ cộng số dư, KHÔNG tạo Transaction mới - dùng khi đã có sẵn 1 Transaction (ví dụ topup PENDING -> SUCCESS)
    // để tránh ghi trùng 2 dòng lịch sử giao dịch cho cùng 1 lần nạp tiền.
    @Transactional
    public void creditBalanceOnly(Long userId, Long amount) {
        if (amount == null || amount <= 0) {
            throw AppException.badRequest("Số Bạc không hợp lệ!");
        }
        User user = userRepository.findByIdForUpdate(userId)
                .orElseThrow(() -> AppException.unauthorized("Tài khoản không hợp lệ!"));

        user.setSilverBalance(user.getSilverBalance() + amount);
        userRepository.save(user);
    }
}
