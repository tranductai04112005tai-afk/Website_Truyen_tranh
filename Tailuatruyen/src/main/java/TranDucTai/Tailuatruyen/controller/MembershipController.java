package TranDucTai.Tailuatruyen.controller;

import TranDucTai.Tailuatruyen.dto.PurchaseMembershipRequest;
import TranDucTai.Tailuatruyen.entity.UserMembership;
import TranDucTai.Tailuatruyen.entity.VipPackage;
import TranDucTai.Tailuatruyen.repository.VipPackageRepository;
import TranDucTai.Tailuatruyen.security.CurrentUser;
import TranDucTai.Tailuatruyen.service.MembershipService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/memberships")
public class MembershipController {

    @Autowired private VipPackageRepository vipPackageRepository;
    @Autowired private MembershipService membershipService;
    @Autowired private CurrentUser currentUser;

    // Public - danh sách gói VIP để hiển thị trang mua gói
    @GetMapping("/packages")
    public ResponseEntity<List<VipPackage>> getPackages() {
        return ResponseEntity.ok(vipPackageRepository.findAll());
    }

    // Cần đăng nhập (SecurityConfig: mọi request không nằm trong danh sách permitAll đều yêu cầu authenticated)
    @PostMapping("/purchase")
    public ResponseEntity<?> purchase(@Valid @RequestBody PurchaseMembershipRequest request) {
        Long userId = currentUser.requireId();
        UserMembership membership = membershipService.purchase(userId, request.packageId());
        return ResponseEntity.ok(Map.of(
                "message", "Mua gói hội viên thành công!",
                "startDate", membership.getStartDate(),
                "endDate", membership.getEndDate()
        ));
    }

    // Trạng thái VIP hiện tại của user đang đăng nhập, để Frontend hiển thị badge VIP
    @GetMapping("/me")
    public ResponseEntity<?> myStatus() {
        Long userId = currentUser.requireId();
        boolean isVip = membershipService.hasActiveVip(userId);
        return ResponseEntity.ok(Map.of("isVip", isVip));
    }
}
