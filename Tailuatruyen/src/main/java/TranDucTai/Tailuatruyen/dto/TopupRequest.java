package TranDucTai.Tailuatruyen.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record TopupRequest(
        @NotNull(message = "Thiếu mệnh giá nạp")
        @Min(value = 10000, message = "Số Bạc nạp tối thiểu là 10,000")
        Long amount
) {
}
