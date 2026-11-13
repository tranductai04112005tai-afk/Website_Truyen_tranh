package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.StatusEnum;
import TranDucTai.Tailuatruyen.entity.Transaction;
import TranDucTai.Tailuatruyen.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class TransactionCronJob {

    @Autowired
    private TransactionRepository transactionRepository;

    // Chạy ngầm định kỳ mỗi 60 giây (60000 ms)
    @Scheduled(fixedRate = 60000)
    public void expireOldTransactions() {
        List<Transaction> pendingTransactions = transactionRepository.findByStatus(StatusEnum.PENDING);
        boolean hasUpdates = false;

        for (Transaction t : pendingTransactions) {
            // Nếu thời gian hiện tại đã vượt qua expiredAt
            if (t.getExpiredAt() != null && t.getExpiredAt().isBefore(LocalDateTime.now())) {
                t.setStatus(StatusEnum.EXPIRED);
                hasUpdates = true;
            }
        }
        
        if (hasUpdates) {
            transactionRepository.saveAll(pendingTransactions);
            System.out.println("CronJob: Đã tự động chuyển các mã QR quá hạn sang EXPIRED lúc: " + LocalDateTime.now());
        }
    }
}