package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.*;
import TranDucTai.Tailuatruyen.exception.AppException;
import TranDucTai.Tailuatruyen.repository.UserMembershipRepository;
import TranDucTai.Tailuatruyen.repository.UserRepository;
import TranDucTai.Tailuatruyen.repository.VipPackageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Giai đoạn 10: Unit Test cho MembershipService.hasActiveVip() + purchase() (mock Repository).
 */
@ExtendWith(MockitoExtension.class)
class MembershipServiceTest {

    @Mock private UserMembershipRepository userMembershipRepository;
    @Mock private VipPackageRepository vipPackageRepository;
    @Mock private UserRepository userRepository;
    @Mock private WalletService walletService;

    @InjectMocks private MembershipService membershipService;

    @Test
    void hasActiveVip_shouldReturnFalse_whenUserIdIsNull() {
        assertThat(membershipService.hasActiveVip(null)).isFalse();
        verifyNoInteractions(userMembershipRepository);
    }

    @Test
    void hasActiveVip_shouldReturnTrue_whenRepositoryConfirms() {
        when(userMembershipRepository.hasActiveVip(eq(1L), any())).thenReturn(true);
        assertThat(membershipService.hasActiveVip(1L)).isTrue();
    }

    @Test
    void hasActiveVip_shouldReturnFalse_whenNoActiveMembership() {
        when(userMembershipRepository.hasActiveVip(eq(1L), any())).thenReturn(false);
        assertThat(membershipService.hasActiveVip(1L)).isFalse();
    }

    @Test
    void purchase_shouldDebitAndCreateMembership_whenNoExistingVip() {
        User user = User.builder().id(1L).silverBalance(200000L).build();
        VipPackage vipPackage = VipPackage.builder().id(10L).name("Gói 1 Tháng").durationMonths(1).priceInSilver(50000L).build();

        when(vipPackageRepository.findById(10L)).thenReturn(Optional.of(vipPackage));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userMembershipRepository.hasActiveVip(eq(1L), any())).thenReturn(false);
        when(userMembershipRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        UserMembership result = membershipService.purchase(1L, 10L);

        assertThat(result.getVipPackage()).isEqualTo(vipPackage);
        assertThat(result.getStatus()).isEqualTo(StatusEnum.ACTIVE);
        verify(walletService).debit(1L, 50000L, TypeEnum.BUY_VIP);
    }

    @Test
    void purchase_shouldDeactivateOldActiveMemberships_beforeActivatingNewOne() {
        User user = User.builder().id(1L).silverBalance(200000L).build();
        VipPackage vipPackage = VipPackage.builder().id(10L).name("Gói 1 Tháng").durationMonths(1).priceInSilver(50000L).build();
        UserMembership oldMembership = UserMembership.builder().id(99L).user(user).vipPackage(vipPackage).startDate(LocalDateTime.now().minusDays(10)).endDate(LocalDateTime.now().plusDays(5)).status(StatusEnum.ACTIVE).build();

        when(vipPackageRepository.findById(10L)).thenReturn(Optional.of(vipPackage));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userMembershipRepository.hasActiveVip(eq(1L), any())).thenReturn(true);
        when(userMembershipRepository.findLatestActiveEndDate(eq(1L), any())).thenReturn(Optional.of(LocalDateTime.now().plusDays(5)));
        when(userMembershipRepository.findActiveMemberships(eq(1L), any())).thenReturn(java.util.List.of(oldMembership));
        when(userMembershipRepository.save(any(UserMembership.class))).thenAnswer(inv -> inv.getArgument(0));

        UserMembership result = membershipService.purchase(1L, 10L);

        assertThat(result.getStatus()).isEqualTo(StatusEnum.ACTIVE);
        assertThat(oldMembership.getStatus()).isEqualTo(StatusEnum.INACTIVE);
        verify(userMembershipRepository).save(oldMembership);
    }

    @Test
    void syncVipRole_shouldPromoteMemberToVip_whenActiveMembershipExists() {
        User user = User.builder().id(1L).role(RoleEnum.MEMBER).build();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userMembershipRepository.hasActiveVip(eq(1L), any())).thenReturn(true);

        membershipService.syncUserVipRole(1L);

        assertThat(user.getRole()).isEqualTo(RoleEnum.VIP_MEMBER);
        verify(userRepository).save(user);
    }

    @Test
    void purchase_shouldThrow_whenPackageNotFound() {
        when(vipPackageRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> membershipService.purchase(1L, 99L))
                .isInstanceOf(AppException.class);

        verifyNoInteractions(walletService);
    }
}
