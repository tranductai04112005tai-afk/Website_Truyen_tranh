package TranDucTai.Tailuatruyen.dto;

import TranDucTai.Tailuatruyen.entity.RoleEnum;
import jakarta.validation.constraints.NotNull;

public record ChangeRoleRequest(
        @NotNull(message = "Thiếu role mới")
        RoleEnum role
) {
}
