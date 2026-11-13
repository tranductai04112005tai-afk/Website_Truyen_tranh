package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.dto.AdminStatsResponse;
import TranDucTai.Tailuatruyen.entity.RoleEnum;
import TranDucTai.Tailuatruyen.entity.StatusEnum;
import TranDucTai.Tailuatruyen.entity.TypeEnum;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminService {

    @Autowired private UserRepository userRepository;
    @Autowired private StoryRepository storyRepository;
    @Autowired private ChapterRepository chapterRepository;
    @Autowired private TransactionRepository transactionRepository;

    // Giai đoạn 8: khoá/mở khoá tài khoản mà không xoá dữ liệu liên quan
    @Transactional
    public User toggleLock(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy người dùng!"));
        user.setLocked(!Boolean.TRUE.equals(user.getLocked()));
        return userRepository.save(user);
    }

    @Transactional
    public User changeRole(Long userId, RoleEnum newRole) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> AppException.notFound("Không tìm thấy người dùng!"));
        user.setRole(newRole);
        return userRepository.save(user);
    }

    // Thống kê nhanh cho Dashboard Admin
    public AdminStatsResponse getStats() {
        long totalUsers = userRepository.count();
        long totalStories = storyRepository.count();
        long totalChapters = chapterRepository.count();
        long totalTransactions = transactionRepository.count();

        var successfulTopups = transactionRepository.findByStatus(StatusEnum.SUCCESS).stream()
                .filter(t -> t.getType() == TypeEnum.TOPUP)
                .toList();
        long successfulTopupCount = successfulTopups.size();
        long totalSilverToppedUp = successfulTopups.stream().mapToLong(t -> t.getAmount() == null ? 0 : t.getAmount()).sum();

        return new AdminStatsResponse(totalUsers, totalStories, totalChapters, totalTransactions,
                successfulTopupCount, totalSilverToppedUp);
    }
}
