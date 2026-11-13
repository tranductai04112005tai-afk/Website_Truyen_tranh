package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.User;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleId(String googleId);

    // Khoá ghi (pessimistic write lock) trên dòng User khi trừ/cộng Bạc,
    // tránh race condition khi 2 request cùng mua chương / nạp tiền một lúc (Giai đoạn 10)
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT u FROM User u WHERE u.id = :id")
    Optional<User> findByIdForUpdate(Long id);
}
