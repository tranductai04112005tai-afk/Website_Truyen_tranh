package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.RoleEnum;
import TranDucTai.Tailuatruyen.entity.TypeEnum;
import TranDucTai.Tailuatruyen.entity.User;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.TransactionRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Giai đoạn 10: Unit Test cho WalletService.debit() (mock Repository, không đụng DB thật).
 */
@ExtendWith(MockitoExtension.class)
class WalletServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private TransactionRepository transactionRepository;

    @InjectMocks private WalletService walletService;

    private User user;

    @BeforeEach
    void setUp() {
        user = User.builder()
                .id(1L)
                .email("test@example.com")
                .role(RoleEnum.MEMBER)
                .silverBalance(100L)
                .locked(false)
                .build();
    }

    @Test
    void debit_shouldReduceBalance_whenBalanceIsSufficient() {
        when(userRepository.findByIdForUpdate(1L)).thenReturn(Optional.of(user));

        walletService.debit(1L, 40L, TypeEnum.BUY_CHAPTER);

        assertThat(user.getSilverBalance()).isEqualTo(60L);
        verify(userRepository).save(user);
        verify(transactionRepository).save(any());
    }

    @Test
    void debit_shouldThrow402_whenBalanceIsInsufficient() {
        when(userRepository.findByIdForUpdate(1L)).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> walletService.debit(1L, 999L, TypeEnum.BUY_CHAPTER))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("không đủ");

        // Số dư không được thay đổi khi giao dịch thất bại
        assertThat(user.getSilverBalance()).isEqualTo(100L);
        verify(userRepository, never()).save(any());
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void debit_shouldThrow_whenAmountIsZeroOrNegative() {
        assertThatThrownBy(() -> walletService.debit(1L, 0L, TypeEnum.BUY_CHAPTER))
                .isInstanceOf(AppException.class);

        assertThatThrownBy(() -> walletService.debit(1L, -10L, TypeEnum.BUY_CHAPTER))
                .isInstanceOf(AppException.class);

        verifyNoInteractions(userRepository);
    }

    @Test
    void debit_shouldThrow401_whenUserDoesNotExist() {
        when(userRepository.findByIdForUpdate(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> walletService.debit(99L, 10L, TypeEnum.BUY_CHAPTER))
                .isInstanceOf(AppException.class);
    }

    @Test
    void credit_shouldIncreaseBalance() {
        when(userRepository.findByIdForUpdate(1L)).thenReturn(Optional.of(user));
        when(userRepository.getReferenceById(1L)).thenReturn(user);

        walletService.credit(1L, 50L, TypeEnum.TOPUP);

        assertThat(user.getSilverBalance()).isEqualTo(150L);
        verify(transactionRepository).save(any());
    }
}
