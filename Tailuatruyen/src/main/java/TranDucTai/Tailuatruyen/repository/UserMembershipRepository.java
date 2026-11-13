package TranDucTai.Tailuatruyen.repository;

import TranDucTai.Tailuatruyen.entity.UserMembership;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserMembershipRepository extends JpaRepository<UserMembership, Long> {
    // Trả về true nếu user có gói VIP ACTIVE và ngày hết hạn > hiện tại
    @Query("SELECT COUNT(um) > 0 FROM UserMembership um WHERE um.user.id = :userId AND um.status = 'ACTIVE' AND um.endDate > :now")
    boolean hasActiveVip(@Param("userId") Long userId, @Param("now") LocalDateTime now);

    // Ngày hết hạn xa nhất trong các gói ACTIVE còn hiệu lực - dùng để gia hạn nối tiếp thay vì đè lên
    @Query("SELECT MAX(um.endDate) FROM UserMembership um WHERE um.user.id = :userId AND um.status = 'ACTIVE' AND um.endDate > :now")
    Optional<LocalDateTime> findLatestActiveEndDate(@Param("userId") Long userId, @Param("now") LocalDateTime now);

    @Query("SELECT um FROM UserMembership um WHERE um.user.id = :userId AND um.status = 'ACTIVE' AND um.endDate > :now")
    List<UserMembership> findActiveMemberships(@Param("userId") Long userId, @Param("now") LocalDateTime now);
}
