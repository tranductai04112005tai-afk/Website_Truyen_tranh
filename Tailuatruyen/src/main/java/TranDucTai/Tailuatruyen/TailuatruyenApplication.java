package TranDucTai.Tailuatruyen;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling // Bắt buộc phải có dòng này để kích hoạt Cron Job
@EnableAsync // Cho phép CrawlerService chạy nền (@Async) khi được kích hoạt thủ công qua API
public class TailuatruyenApplication {
    public static void main(String[] args) {
        SpringApplication.run(TailuatruyenApplication.class, args);
    }
}