package TranDucTai.Tailuatruyen.dto;

import TranDucTai.Tailuatruyen.entity.Chapter;

public record ChapterSummaryResponse(
        Long id,
        Integer chapterNumber,
        String title,
        Boolean isFree,
        Long priceInSilver,
        Boolean visible
) {
    public static ChapterSummaryResponse from(Chapter chapter) {
        return new ChapterSummaryResponse(
                chapter.getId(),
                chapter.getChapterNumber(),
                chapter.getTitle(),
                chapter.getIsFree(),
                chapter.getPriceInSilver(),
                chapter.getVisible()
        );
    }
}
