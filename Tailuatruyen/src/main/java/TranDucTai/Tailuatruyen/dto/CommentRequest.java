package TranDucTai.Tailuatruyen.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

// Giai đoạn 9: DTO + @Valid cho input, không nhận thẳng Entity từ client (tránh client tự set id/user/createdAt)
public record CommentRequest(
        @NotBlank(message = "Nội dung bình luận không được để trống")
        @Size(max = 2000, message = "Bình luận tối đa 2000 ký tự")
        String content
) {
}
