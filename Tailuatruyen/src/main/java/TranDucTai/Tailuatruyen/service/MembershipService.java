package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.*;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.UserMembershipRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import TranDucTai.Tailuatruyen.repository.VipPackageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class MembershipService {
    @Autowired private UserMembershipRepository userMembershipRepository;
    @Autowired private VipPackageRepository vipPackageRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private WalletService walletService;

    public boolean hasActiveVip(Long userId) {
        if (userId == null) return false;
        return userMembershipRepository.hasActiveVip(userId, LocalDateTime.now());
    }

    @Transactional
    public void syncUserVipRole(Long userId) {
        if (userId == null) return;

        User user = userRepository.findById(userId).orElse(null);
        if (user == null) return;

        boolean hasVip = hasActiveVip(userId);

        if (user.getRole() == RoleEnum.ADMIN) {
            return;
        }

        if (hasVip) {
            if (user.getRole() != RoleEnum.VIP_MEMBER) {
                user.setRole(RoleEnum.VIP_MEMBER);
                userRepository.save(user);
            }
            return;
        }

        if (user.getRole() == RoleEnum.VIP_MEMBER || user.getRole() == RoleEnum.MEMBER) {
            user.setRole(RoleEnum.MEMBER);
            userRepository.save(user);
        }
    }

    // Giai đoạn 5: mua/gia hạn gói VIP. Bọc trong 1 @Transactional để trừ Bạc + tạo UserMembership
    // là all-or-nothing (nếu 1 bước lỗi thì rollback cả 2, không để user bị trừ Bạc mà không nhận được VIP).
    @Transactional
    public UserMembership purchase(Long userId, Long packageId) {
        VipPackage vipPackage = vipPackageRepository.findById(packageId)
                .orElseThrow(() -> AppException.notFound("Gói hội viên không tồn tại!"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> AppException.unauthorized("Tài khoản không hợp lệ!"));

        // Trừ Bạc (có pessimistic lock chống race condition khi mua 2 gói cùng lúc)
        walletService.debit(userId, vipPackage.getPriceInSilver(), TypeEnum.BUY_VIP);

        // Chỉ giữ 1 gói VIP active duy nhất tại một thời điểm.
        // Nếu đã có gói trước đó còn hiệu lực, tính từ ngày hết hạn gần nhất nhưng
        // tắt toàn bộ membership cũ để không khiến các gói khác cùng được sử dụng.
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startFrom = userMembershipRepository.hasActiveVip(userId, now)
                ? latestActiveEndDate(userId, now)
                : now;

        userMembershipRepository.findActiveMemberships(userId, now).forEach(activeMembership -> {
            activeMembership.setStatus(StatusEnum.INACTIVE);
            userMembershipRepository.save(activeMembership);
        });

        UserMembership membership = UserMembership.builder()
                .user(user)
                .vipPackage(vipPackage)
                .startDate(startFrom)
                .endDate(startFrom.plusMonths(vipPackage.getDurationMonths()))
                .status(StatusEnum.ACTIVE)
                .build();

        UserMembership savedMembership = userMembershipRepository.save(membership);
        syncUserVipRole(userId);
        return savedMembership;
    }

    private LocalDateTime latestActiveEndDate(Long userId, LocalDateTime now) {
        return userMembershipRepository.findLatestActiveEndDate(userId, now).orElse(now);
    }
}
