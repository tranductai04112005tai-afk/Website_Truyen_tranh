package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.RoleEnum;
import TranDucTai.Tailuatruyen.entity.TypeEnum;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.TransactionRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Giai đoạn 10: Integration Test - luồng Service -> Repository -> DB thật (H2), CHẠY THẬT với 2 luồng
 * (thread) trừ Bạc đồng thời trên cùng 1 tài khoản, để kiểm tra pessimistic lock trong WalletService
 * có chống được race condition (double-spend) hay không.
 *
 * Kịch bản: User có 100 Bạc. 2 request cùng lúc mua 1 món giá 80 Bạc.
 * Kỳ vọng: CHỈ 1 request thành công, request còn lại phải nhận lỗi "không đủ Bạc" (402),
 * và số dư cuối cùng phải là 20 (KHÔNG được là âm, và KHÔNG được là 100 - 2*80 = -60).
 */
@SpringBootTest
@ActiveProfiles("test")
class WalletServiceRaceConditionIT {

    @Autowired private WalletService walletService;
    @Autowired private UserRepository userRepository;
    @Autowired private TransactionRepository transactionRepository;

    @Test
    void debit_concurrentRequests_shouldNotAllowDoubleSpend() throws InterruptedException {
        User user = userRepository.save(User.builder()
                .email("race-test-" + System.nanoTime() + "@test.com")
                .role(RoleEnum.MEMBER)
                .silverBalance(100L)
                .locked(false)
                .build());

        int threadCount = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        CountDownLatch readyLatch = new CountDownLatch(threadCount);
        CountDownLatch startLatch = new CountDownLatch(1);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger failureCount = new AtomicInteger(0);

        Runnable task = () -> {
            try {
                readyLatch.countDown();
                startLatch.await(); // đợi cả 2 luồng cùng sẵn sàng rồi mới bắn request cùng lúc
                walletService.debit(user.getId(), 80L, TypeEnum.BUY_CHAPTER);
                successCount.incrementAndGet();
            } catch (AppException e) {
                failureCount.incrementAndGet();
            } catch (InterruptedException ignored) {
            }
        };

        executor.submit(task);
        executor.submit(task);

        readyLatch.await(5, TimeUnit.SECONDS);
        startLatch.countDown(); // GO! cả 2 luồng cùng gọi debit() gần như đồng thời

        executor.shutdown();
        boolean finished = executor.awaitTermination(10, TimeUnit.SECONDS);
        assertThat(finished).as("2 luồng phải xử lý xong trong 10s (nếu treo -> có deadlock)").isTrue();

        // Chỉ đúng 1 trong 2 request được trừ tiền thành công
        assertThat(successCount.get()).isEqualTo(1);
        assertThat(failureCount.get()).isEqualTo(1);

        User reloaded = userRepository.findById(user.getId()).orElseThrow();
        assertThat(reloaded.getSilverBalance()).isEqualTo(20L); // 100 - 80, KHÔNG bị trừ 2 lần
    }
}
