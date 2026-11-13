package TranDucTai.Tailuatruyen.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

// Admin tạo/sửa chương thủ công (Giai đoạn 8 - CRUD, không chỉ ẩn/hiện), hoặc dùng để seed dữ liệu test
public record ChapterRequest(
        @NotNull @Min(1) Integer chapterNumber,
        @NotBlank String title,
        @NotBlank String content
) {
}
