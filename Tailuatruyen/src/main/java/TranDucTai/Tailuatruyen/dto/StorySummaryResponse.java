package TranDucTai.Tailuatruyen.dto;

import TranDucTai.Tailuatruyen.entity.Story;

// Danh sách truyện: không trả kèm List<Chapter> để tránh payload nặng / N+1 query
// chapters: số chương (tên field khớp với frontend đọc story.chapters)
// description: mô tả truyện, cần thiết cho trang chi tiết StoryView
public record StorySummaryResponse(
        Long id,
        String title,
        String author,
        String description,
        String coverImage,
        String status,
        long chapters
) {
    public static StorySummaryResponse from(Story s, long totalChapters) {
        return new StorySummaryResponse(
                s.getId(), s.getTitle(), s.getAuthor(), s.getDescription(),
                s.getCoverImage(), s.getStatus().name(), totalChapters
        );
    }
}
