package TranDucTai.Tailuatruyen.dto;

public record AdminStatsResponse(
        long totalUsers,
        long totalStories,
        long totalChapters,
        long totalTransactions,
        long successfulTopupCount,
        long totalSilverToppedUp
) {
}
