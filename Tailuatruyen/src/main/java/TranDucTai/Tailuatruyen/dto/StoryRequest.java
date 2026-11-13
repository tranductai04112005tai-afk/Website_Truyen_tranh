package TranDucTai.Tailuatruyen.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

// Dùng cho Admin tạo/sửa truyện thủ công (Giai đoạn 8) - không nhận thẳng Entity từ client
public record StoryRequest(
        @NotBlank(message = "Tên truyện không được để trống")
        @Size(max = 255)
        String title,

        String author,

        @Size(max = 5000)
        String description,

        String coverImage
) {
}
