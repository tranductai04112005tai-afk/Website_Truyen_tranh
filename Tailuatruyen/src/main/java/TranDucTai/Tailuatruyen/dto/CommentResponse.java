package TranDucTai.Tailuatruyen.dto;

import TranDucTai.Tailuatruyen.entity.Comment;

import java.time.LocalDateTime;

public record CommentResponse(
        Long id,
        Long userId,
        String displayName,
        String content,
        LocalDateTime createdAt
) {
    public static CommentResponse from(Comment c) {
        return new CommentResponse(
                c.getId(),
                c.getUser().getId(),
                c.getUser().getDisplayName(),
                c.getContent(),
                c.getCreatedAt()
        );
    }
}
