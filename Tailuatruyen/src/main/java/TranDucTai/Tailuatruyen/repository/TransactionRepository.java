package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.StatusEnum;
import TranDucTai.Tailuatruyen.entity.Transaction;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    // Tìm các giao dịch theo trạng thái (để tìm các mã PENDING)
    List<Transaction> findByStatus(StatusEnum status);

    // Khoá dòng Transaction khi xác nhận thanh toán, tránh 2 webhook gọi cùng lúc cộng Bạc 2 lần cho 1 giao dịch
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT t FROM Transaction t WHERE t.id = :id")
    Optional<Transaction> findByIdForUpdate(Long id);
}