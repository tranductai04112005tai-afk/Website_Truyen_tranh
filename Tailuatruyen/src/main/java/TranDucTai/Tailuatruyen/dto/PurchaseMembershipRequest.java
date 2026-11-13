package TranDucTai.Tailuatruyen.dto;

import jakarta.validation.constraints.NotNull;

public record PurchaseMembershipRequest(
        @NotNull(message = "Thiếu packageId")
        Long packageId
) {
}
