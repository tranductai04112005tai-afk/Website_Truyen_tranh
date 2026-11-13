-- Giai đoạn 1: seed dữ liệu ban đầu
-- Chạy sau khi Hibernate (ddl-auto=update) đã tạo xong bảng, nhờ spring.jpa.defer-datasource-initialization=true

-- Gói Hội viên VIP mặc định (chỉ insert nếu bảng đang trống, tránh insert trùng mỗi lần restart app)
INSERT INTO vip_packages (name, duration_months, price_in_silver)
SELECT * FROM (SELECT 'Gói 1 Tháng' AS name, 1 AS duration_months, 50000 AS price_in_silver) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM vip_packages WHERE name = 'Gói 1 Tháng');

INSERT INTO vip_packages (name, duration_months, price_in_silver)
SELECT * FROM (SELECT 'Gói 3 Tháng' AS name, 3 AS duration_months, 135000 AS price_in_silver) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM vip_packages WHERE name = 'Gói 3 Tháng');

INSERT INTO vip_packages (name, duration_months, price_in_silver)
SELECT * FROM (SELECT 'Gói 12 Tháng' AS name, 12 AS duration_months, 480000 AS price_in_silver) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM vip_packages WHERE name = 'Gói 12 Tháng');

-- Tài khoản Admin mặc định (đăng nhập qua Google, gán role ADMIN thủ công theo email)
-- Đổi lại email bên dưới thành email Google thật của bạn trước khi lần đầu chạy app,
-- để tài khoản Google đó tự động là ADMIN ngay khi đăng nhập lần đầu.
INSERT INTO users (email, display_name, role, silver_balance, locked, created_at)
SELECT * FROM (SELECT 'admin@tailuatruyen.local' AS email, 'Quản trị viên' AS display_name,
                      'ADMIN' AS role, 100000 AS silver_balance, FALSE AS locked, CURRENT_TIMESTAMP AS created_at) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@tailuatruyen.local');

UPDATE users
SET role = 'ADMIN', locked = FALSE, silver_balance = 100000
WHERE email = 'admin@tailuatruyen.local';

-- Dữ liệu demo cho đồ án local: truyện, chương, độc giả và bình luận mẫu.
-- source_url được dùng làm khóa seed để có thể khởi động lại nhiều lần mà không tạo trùng.
INSERT INTO users (email, display_name, role, silver_balance, locked, created_at)
SELECT * FROM (SELECT 'reader@tailuatruyen.local', 'Độc giả Demo', 'MEMBER', 150000, FALSE, CURRENT_TIMESTAMP) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'reader@tailuatruyen.local');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Kẻ Đánh Cắp Ánh Trăng', 'Tạ Vũ', 'Một kẻ trộm ký ức bước vào thành phố không có bình minh. Tiên hiệp và huyền huyễn.', 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=620&q=80', 'demo://ke-danh-cap-anh-trang', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://ke-danh-cap-anh-trang');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Sau Cơn Mưa Ở Thành Nam', 'Lam Nguyệt', 'Những lá thư cũ, một lời hẹn và mùa hè chưa từng kết thúc. Một câu chuyện đô thị nhẹ nhàng.', 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=620&q=80', 'demo://sau-con-mua-o-thanh-nam', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://sau-con-mua-o-thanh-nam');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Tinh Hà Rơi Trên Vai', 'Mộc Miên', 'Khi các vì sao rơi xuống, cô phải chọn giữa quê hương và tự do. Phiêu lưu giữa những vì tinh tú.', 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&w=620&q=80', 'demo://tinh-ha-roi-tren-vai', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://tinh-ha-roi-tren-vai');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Tiệm Sách Cuối Con Dốc', 'An Nhiên', 'Nơi mỗi cuốn sách đều giữ lại một người mà ta từng yêu. Ngôn tình và những ngày bình yên.', 'https://images.unsplash.com/photo-1526243741027-444d633d7365?auto=format&fit=crop&w=620&q=80', 'demo://tiem-sach-cuoi-con-doc', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://tiem-sach-cuoi-con-doc');

INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Thành phố không có bình minh', 'Đêm ấy, ánh trăng rơi xuống mái nhà như một mảnh ký ức bị đánh cắp.\nTạ Vũ mở cánh cửa cũ và bước vào con phố chưa từng xuất hiện trên bản đồ.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'demo://ke-danh-cap-anh-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chiếc chìa khóa bằng bạc', 'Trong căn phòng cuối hẻm, một chiếc chìa khóa biết gọi tên người đã mất.\nCậu phải chọn mở cánh cửa hay giữ lại ký ức của mình.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'demo://ke-danh-cap-anh-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Người giữ trăng', 'Người phụ nữ áo xanh nói rằng thành phố đã chờ cậu từ rất lâu.\nPhía sau lưng họ, những ngọn đèn lần lượt tắt.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'demo://ke-danh-cap-anh-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Bản đồ của những giấc mơ', 'Bản đồ mở ra giữa lòng bàn tay, dẫn lối qua những giấc mơ của người xa lạ.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'demo://ke-danh-cap-anh-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Bình minh đầu tiên', 'Khi tiếng chuông vang lên, thành phố lần đầu tiên nhìn thấy mặt trời.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'demo://ke-danh-cap-anh-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);

INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, n.chapter_number, n.title, n.content, n.is_free, n.price, TRUE FROM stories s JOIN (
    SELECT 1 chapter_number, 'Lá thư tháng sáu' title, 'Cơn mưa đầu mùa gõ lên cửa sổ. Lá thư cũ nằm im dưới chồng sách.' content, TRUE is_free, 0 price
    UNION ALL SELECT 2, 'Con đường quen', 'Thành Nam vẫn có con đường ấy, chỉ là người chờ đợi đã khác xưa.', TRUE, 0
    UNION ALL SELECT 3, 'Cuộc hẹn bên hiên', 'Hai người gặp lại nhau khi cơn mưa vừa tạnh. Câu hỏi năm nào vẫn chưa có lời đáp.', FALSE, 300
    UNION ALL SELECT 4, 'Mùa hè không kết thúc', 'Ký ức trở về qua mùi hoa giấy và tiếng ve sau vườn.', FALSE, 300
    UNION ALL SELECT 5, 'Ngày mai nhiều nắng', 'Lá thư cuối cùng không còn là lời tạm biệt.', FALSE, 300
) n WHERE s.source_url = 'demo://sau-con-mua-o-thanh-nam' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = n.chapter_number);

INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, n.chapter_number, n.title, n.content, n.is_free, n.price, TRUE FROM stories s JOIN (
    SELECT 1 chapter_number, 'Đêm sao rơi' title, 'Bầu trời nứt ra, để lộ một dòng sông ánh sáng bên trên mái nhà.' content, TRUE is_free, 0 price
    UNION ALL SELECT 2, 'Người du hành', 'Cô tỉnh dậy với một vì sao nhỏ nằm trong túi áo.', TRUE, 0
    UNION ALL SELECT 3, 'Cánh cửa phương Bắc', 'Cánh cửa chỉ mở khi người đi qua gọi đúng tên quê hương.', FALSE, 400
    UNION ALL SELECT 4, 'Lời hứa trên quỹ đạo', 'Giữa khoảng không vô tận, một lời hứa trở thành chiếc la bàn duy nhất.', FALSE, 400
    UNION ALL SELECT 5, 'Trở về mặt đất', 'Tinh hà rơi xuống vai cô, nhẹ như một lời chào.', FALSE, 400
) n WHERE s.source_url = 'demo://tinh-ha-roi-tren-vai' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = n.chapter_number);

INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, n.chapter_number, n.title, n.content, n.is_free, n.price, TRUE FROM stories s JOIN (
    SELECT 1 chapter_number, 'Cuốn sách phủ bụi' title, 'Cuối con dốc có một tiệm sách chỉ mở cửa vào những buổi chiều nhiều gió.' content, TRUE is_free, 0 price
    UNION ALL SELECT 2, 'Người khách đầu tiên', 'Cô gái chọn một cuốn sách không có tên tác giả.', TRUE, 0
    UNION ALL SELECT 3, 'Trang giấy trắng', 'Trang giấy trắng viết tiếp câu chuyện mà cô từng bỏ quên.', FALSE, 250
    UNION ALL SELECT 4, 'Mùi của tháng năm', 'Mỗi kệ sách cất giữ một mùi hương của quá khứ.', FALSE, 250
    UNION ALL SELECT 5, 'Cánh cửa cuối dốc', 'Có những cuộc gặp gỡ chỉ cần đọc đến trang cuối mới hiểu được.', FALSE, 250
) n WHERE s.source_url = 'demo://tiem-sach-cuoi-con-doc' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = n.chapter_number);

INSERT INTO comments (user_id, story_id, content, created_at)
SELECT u.id, s.id, 'Truyện có không khí rất cuốn, mình thích phần mở đầu này.', CURRENT_TIMESTAMP
FROM users u CROSS JOIN stories s
WHERE u.email = 'reader@tailuatruyen.local' AND s.source_url = 'demo://ke-danh-cap-anh-trang'
    AND NOT EXISTS (SELECT 1 FROM comments c WHERE c.user_id = u.id AND c.story_id = s.id);

-- Thêm thêm 20 bộ truyện demo để thư viện phong phú hơn, nhưng vẫn an toàn khi ẩn/hiện vì không xóa dữ liệu gốc
INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Tử Thần Trong Bóng Tối', 'Hà Lệ', 'Một kẻ sống giữa cái chết và những lời nguyện không thành.', 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=620&q=80', 'demo://tu-than-trong-bong-toi', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://tu-than-trong-bong-toi');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Huyền Thoại Mắt Sáng', 'Ngọc Bích', 'Từ một ánh nhìn, cả thế giới lật ngược bởi định mệnh.', 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=620&q=80', 'demo://huyen-thoai-mat-sang', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://huyen-thoai-mat-sang');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Tầng Thứ Mười Hai', 'Dương Thảo', 'Một tầng nhà hung ám chứa bí mật của vũ trụ bị chôn giấu.', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=620&q=80', 'demo://tang-thu-10', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://tang-thu-10');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Cửu Vân Ký', 'Thái Minh', 'Một thiên sứ mất lời hứa, một thánh địa bỏ lại một câu chuyện.', 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=620&q=80', 'demo://cuu-van-ky', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://cuu-van-ky');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Đệ Nhất Tướng Quân', 'Trần Huyền', 'Anh hùng bước ra từ chiến trường hóa thành người giữ lời hứa.', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=620&q=80', 'demo://de-nhat-tuong-quan', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://de-nhat-tuong-quan');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Bến Đợi Trên Mưa', 'Mỹ Hạnh', 'Một người chờ đợi rất lâu, và một cuộc gặp gỡ đã sắp tới.', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=620&q=80', 'demo://ben-doi-tren-mua', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://ben-doi-tren-mua');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Mảnh Trăng Ở Hạ Giới', 'Tiểu Nhi', 'Một bông hồng nở trong đêm, báo hiệu một lời nguyền cũ', 'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?auto=format&fit=crop&w=620&q=80', 'demo://mang-trang-o-ha-gioi', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://mang-trang-o-ha-gioi');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Lời Hứa Đêm Giao Thừa', 'Vân Khánh', 'Những người ở lại ngồi chờ bên ngọn lửa năm cũ.', 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=620&q=80', 'demo://loi-hua-dem-giao-thua', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://loi-hua-dem-giao-thua');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Phòng Trọ Chín Tầng', 'Lê Quân', 'Một khu trọ lạ chứa đầy người sống bằng ký ức và nỗi nhớ.', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=620&q=80', 'demo://phong-tro-chin-tang', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://phong-tro-chin-tang');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Nữ Tướng Của Gió', 'Khả Nhi', 'Mỗi cơn gió mang theo một mệnh lệnh chưa ai từng nghe đủ.', 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=620&q=80', 'demo://nu-tuong-cua-gio', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://nu-tuong-cua-gio');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Mắt Biển Trắng', 'Tuệ An', 'Một người đánh cá tìm thấy chiếc mũi khoan bí mật dưới biển.', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=620&q=80', 'demo://mat-bien-trang', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://mat-bien-trang');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Đường Về Mộng Cũ', 'Lan Anh', 'Mỗi lần trở về quê, cô lại thấy một lời nhắn mới trên bức tường.', 'https://images.unsplash.com/photo-1517486800572-480a5e5e9b1f?auto=format&fit=crop&w=620&q=80', 'demo://duong-ve-mong-cu', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://duong-ve-mong-cu');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Tia Nắng Dưới Cầu', 'Đức Khang', 'Một người đàn ông bất ngờ được nhìn thấy bằng người khác.', 'https://images.unsplash.com/photo-1493246318656-5bfd4cf5b29b?auto=format&fit=crop&w=620&q=80', 'demo://tia-nang-duoi-cau', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://tia-nang-duoi-cau');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Vòng Tròn Đất Mới', 'Ninh Vy', 'Mỗi người đi qua vòng tròn đều đổi tên một lần trong đời.', 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=620&q=80', 'demo://vong-tron-dat-moi', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://vong-tron-dat-moi');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Đêm Gió Ngoài Biên', 'Mạnh Tường', 'Một bức tường sắt đặt giữa đất liền và biển cả.', 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=620&q=80', 'demo://dem-gio-ngoai-bien', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://dem-gio-ngoai-bien');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Chàng Trai Bên Khe Đời', 'Khiêm Duy', 'Mỗi ngày, anh bước ra và xoay ngược lại thời gian bằng một cử chỉ.', 'https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=620&q=80', 'demo://chang-trai-ben-khe-doi', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://chang-trai-ben-khe-doi');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Mùi Hương Nửa Đêm', 'Ánh Phương', 'Một ngôi nhà trống ngập hương hoa, nhưng không ai từng ở lại.', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=620&q=80', 'demo://mui-huong-nua-dem', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://mui-huong-nua-dem');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Con Đường Gạch Sứ', 'Hằng Thảo', 'Một con đường có thể dẫn người ta đến những kiếp sống cũ.', 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=620&q=80', 'demo://con-duong-gach-su', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://con-duong-gach-su');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Người Sống Trong Mưa', 'Trịnh Tâm', 'Cô gái phát hiện mình có thể nghe tiếng người chết trong mưa.', 'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=620&q=80', 'demo://nguoi-song-trong-mua', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://nguoi-song-trong-mua');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Sứ Mệnh Của Thám Tử', 'Tùng Sơn', 'Một vụ án không có xác chết, chỉ có chứng cứ lạc mất trong gió.', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=620&q=80', 'demo://su-menh-cua-tham-tu', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://su-menh-cua-tham-tu');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Bóng Dáng Trên Mái Nhà', 'Minh Châu', 'Một cô gái giữ bí mật cho cả thành phố và cho chính mình.', 'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?auto=format&fit=crop&w=620&q=80', 'demo://bong-dang-tren-mai-nha', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://bong-dang-tren-mai-nha');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Ký Ức Bên Bờ Sông', 'Thúy Kiều', 'Những người từng xa nhau tìm lại nhau bằng lời hứa cũ.', 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=620&q=80', 'demo://ky-uc-ben-bo-song', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://ky-uc-ben-bo-song');

INSERT INTO stories (title, author, description, cover_image, source_url, status)
SELECT * FROM (SELECT 'Đêm Của Cửa Sổ Mở', 'Nam Phong', 'Một căn phòng chìm trong đêm và lời nhắn đến từ người xa.', 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=620&q=80', 'demo://dem-cua-so-mo', 'ACTIVE') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM stories WHERE source_url = 'demo://dem-cua-so-mo');

-- ===== Bổ sung mô tả đầy đủ + chương đầy đủ cho các truyện trước đây chỉ có bìa, chưa có nội dung =====
-- (nguyên nhân chính khiến 'chương miễn phí không đọc được' / 'VIP vẫn không đọc được truyện': các truyện này vốn KHÔNG có chương nào cả)

UPDATE stories SET description = 'Một sát thủ giấu mặt, một thành phố không ngủ, và lời thề chưa từng nói ra. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Hà Lệ chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://tu-than-trong-bong-toi';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Tử Thần Trong Bóng Tối bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một sát thủ giấu mặt, một thành phố không ngủ, và lời thề chưa từng nói ra xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'tu-than-trong-bong-toi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Tử nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'tu-than-trong-bong-toi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Tử: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tu-than-trong-bong-toi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Tử đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tu-than-trong-bong-toi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Tử buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tu-than-trong-bong-toi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Tử đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tu-than-trong-bong-toi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một đôi mắt có thể nhìn thấu vận mệnh, và cái giá phải trả cho từng lần nhìn thấu. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Ngọc Bích chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://huyen-thoai-mat-sang';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Huyền Thoại Mắt Sáng bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một đôi mắt có thể nhìn thấu vận mệnh, và cái giá phải trả cho từng lần nhìn thấu xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'huyen-thoai-mat-sang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Huyền nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'huyen-thoai-mat-sang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Huyền: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'huyen-thoai-mat-sang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Huyền đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'huyen-thoai-mat-sang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Huyền buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'huyen-thoai-mat-sang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Huyền đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'huyen-thoai-mat-sang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Toà chung cư cũ chỉ có mười một tầng trên giấy tờ, nhưng đêm nào thang máy cũng dừng ở tầng thứ mười hai. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Dương Thảo chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://tang-thu-10';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Tầng Thứ Mười Hai bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Toà chung cư cũ chỉ có mười một tầng trên giấy tờ, nhưng đêm nào thang máy cũng dừng ở tầng thứ mười hai xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'tang-thu-10' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Tầng nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'tang-thu-10' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Tầng: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'tang-thu-10' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Tầng đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'tang-thu-10' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Tầng buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'tang-thu-10' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Tầng đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'tang-thu-10' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Chín tầng mây, chín kiếp tu luyện, và một lời hẹn thiên sứ bỏ lại nơi trần thế. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Thái Minh chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://cuu-van-ky';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Cửu Vân Ký bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Chín tầng mây, chín kiếp tu luyện, và một lời hẹn thiên sứ bỏ lại nơi trần thế xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'cuu-van-ky' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Cửu nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'cuu-van-ky' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Cửu: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'cuu-van-ky' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Cửu đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'cuu-van-ky' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Cửu buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'cuu-van-ky' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Cửu đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'cuu-van-ky' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Người từng cầm quân trăm trận trở về triều đình, mang theo vết thương không thuốc nào chữa được. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Trần Huyền chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://de-nhat-tuong-quan';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Đệ Nhất Tướng Quân bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Người từng cầm quân trăm trận trở về triều đình, mang theo vết thương không thuốc nào chữa được xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'de-nhat-tuong-quan' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Đệ nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'de-nhat-tuong-quan' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Đệ: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'de-nhat-tuong-quan' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Đệ đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'de-nhat-tuong-quan' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Đệ buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'de-nhat-tuong-quan' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Đệ đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 500, TRUE FROM stories s WHERE s.source_url = 'de-nhat-tuong-quan' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một bến đò nhỏ, một chuyến tàu chưa từng cập bến, và người phụ nữ vẫn ra đứng đợi mỗi chiều mưa. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Mỹ Hạnh chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://ben-doi-tren-mua';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Bến Đợi Trên Mưa bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một bến đò nhỏ, một chuyến tàu chưa từng cập bến, và người phụ nữ vẫn ra đứng đợi mỗi chiều mưa xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'ben-doi-tren-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Bến nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'ben-doi-tren-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Bến: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ben-doi-tren-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Bến đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ben-doi-tren-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Bến buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ben-doi-tren-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Bến đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ben-doi-tren-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một tiên nữ đánh rơi một mảnh trăng xuống nhân gian, và nó rơi đúng vào tay một cô gái bán hoa. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Tiểu Nhi chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://mang-trang-o-ha-gioi';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Mảnh Trăng Ở Hạ Giới bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một tiên nữ đánh rơi một mảnh trăng xuống nhân gian, và nó rơi đúng vào tay một cô gái bán hoa xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'mang-trang-o-ha-gioi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Mảnh nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'mang-trang-o-ha-gioi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Mảnh: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'mang-trang-o-ha-gioi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Mảnh đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'mang-trang-o-ha-gioi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Mảnh buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'mang-trang-o-ha-gioi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Mảnh đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'mang-trang-o-ha-gioi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Mỗi năm giao thừa, họ hẹn gặp lại bên đống lửa cũ - cho đến năm chỉ còn một người đến. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Vân Khánh chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://loi-hua-dem-giao-thua';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Lời Hứa Đêm Giao Thừa bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Mỗi năm giao thừa, họ hẹn gặp lại bên đống lửa cũ - cho đến năm chỉ còn một người đến xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'loi-hua-dem-giao-thua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Lời nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'loi-hua-dem-giao-thua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Lời: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'loi-hua-dem-giao-thua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Lời đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'loi-hua-dem-giao-thua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Lời buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'loi-hua-dem-giao-thua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Lời đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'loi-hua-dem-giao-thua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một khu trọ rẻ tiền giữa lòng thành phố, nơi mỗi căn phòng giữ lại một phần đời người từng ở. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Lê Quân chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://phong-tro-chin-tang';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Phòng Trọ Chín Tầng bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một khu trọ rẻ tiền giữa lòng thành phố, nơi mỗi căn phòng giữ lại một phần đời người từng ở xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'phong-tro-chin-tang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Phòng nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'phong-tro-chin-tang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Phòng: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'phong-tro-chin-tang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Phòng đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'phong-tro-chin-tang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Phòng buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'phong-tro-chin-tang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Phòng đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'phong-tro-chin-tang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Cô gái sinh ra trên lưng ngựa, được gió đặt tên, và được giao một mệnh lệnh chưa ai hiểu hết. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Khả Nhi chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://nu-tuong-cua-gio';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Nữ Tướng Của Gió bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Cô gái sinh ra trên lưng ngựa, được gió đặt tên, và được giao một mệnh lệnh chưa ai hiểu hết xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'nu-tuong-cua-gio' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Nữ nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'nu-tuong-cua-gio' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Nữ: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 450, TRUE FROM stories s WHERE s.source_url = 'nu-tuong-cua-gio' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Nữ đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 450, TRUE FROM stories s WHERE s.source_url = 'nu-tuong-cua-gio' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Nữ buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 450, TRUE FROM stories s WHERE s.source_url = 'nu-tuong-cua-gio' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Nữ đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 450, TRUE FROM stories s WHERE s.source_url = 'nu-tuong-cua-gio' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một ngư dân già kéo lưới lên và thấy một sinh vật chưa từng có tên trong bất kỳ cuốn sách nào. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Tuệ An chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://mat-bien-trang';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Mắt Biển Trắng bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một ngư dân già kéo lưới lên và thấy một sinh vật chưa từng có tên trong bất kỳ cuốn sách nào xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'mat-bien-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Mắt nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'mat-bien-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Mắt: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mat-bien-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Mắt đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mat-bien-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Mắt buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mat-bien-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Mắt đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mat-bien-trang' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Mỗi lần cô về quê, bức tường đầu ngõ lại có thêm một dòng chữ mới - do một người cô chưa từng gặp viết. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Lan Anh chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://duong-ve-mong-cu';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Đường Về Mộng Cũ bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Mỗi lần cô về quê, bức tường đầu ngõ lại có thêm một dòng chữ mới - do một người cô chưa từng gặp viết xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'duong-ve-mong-cu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Đường nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'duong-ve-mong-cu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Đường: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'duong-ve-mong-cu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Đường đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'duong-ve-mong-cu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Đường buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'duong-ve-mong-cu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Đường đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'duong-ve-mong-cu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Người đàn ông sống dưới gầm cầu bỗng một ngày phát hiện mình có thể nhìn thấy điều người khác không thấy. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Đức Khang chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://tia-nang-duoi-cau';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Tia Nắng Dưới Cầu bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Người đàn ông sống dưới gầm cầu bỗng một ngày phát hiện mình có thể nhìn thấy điều người khác không thấy xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'tia-nang-duoi-cau' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Tia nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'tia-nang-duoi-cau' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Tia: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tia-nang-duoi-cau' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Tia đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tia-nang-duoi-cau' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Tia buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tia-nang-duoi-cau' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Tia đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'tia-nang-duoi-cau' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một vòng tròn đất bí ẩn xuất hiện sau cơn bão, ai bước qua cũng mang một cái tên khác khi trở ra. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Ninh Vy chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://vong-tron-dat-moi';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Vòng Tròn Đất Mới bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một vòng tròn đất bí ẩn xuất hiện sau cơn bão, ai bước qua cũng mang một cái tên khác khi trở ra xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'vong-tron-dat-moi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Vòng nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'vong-tron-dat-moi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Vòng: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'vong-tron-dat-moi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Vòng đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'vong-tron-dat-moi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Vòng buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'vong-tron-dat-moi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Vòng đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'vong-tron-dat-moi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Nơi biên giới có một hàng rào sắt cũ, và những đêm gió lớn, người ta nghe thấy tiếng gọi từ phía bên kia. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Mạnh Tường chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://dem-gio-ngoai-bien';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Đêm Gió Ngoài Biên bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Nơi biên giới có một hàng rào sắt cũ, và những đêm gió lớn, người ta nghe thấy tiếng gọi từ phía bên kia xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'dem-gio-ngoai-bien' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Đêm nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'dem-gio-ngoai-bien' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Đêm: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'dem-gio-ngoai-bien' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Đêm đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'dem-gio-ngoai-bien' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Đêm buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'dem-gio-ngoai-bien' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Đêm đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'dem-gio-ngoai-bien' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Mỗi sáng, anh thức dậy sớm hơn một giờ so với hôm trước - và không ai, kể cả anh, biết vì sao. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Khiêm Duy chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://chang-trai-ben-khe-doi';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Chàng Trai Bên Khe Đời bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Mỗi sáng, anh thức dậy sớm hơn một giờ so với hôm trước - và không ai, kể cả anh, biết vì sao xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'chang-trai-ben-khe-doi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Chàng nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'chang-trai-ben-khe-doi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Chàng: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'chang-trai-ben-khe-doi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Chàng đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'chang-trai-ben-khe-doi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Chàng buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'chang-trai-ben-khe-doi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Chàng đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'chang-trai-ben-khe-doi' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Ngôi nhà bỏ hoang cuối phố luôn thoảng mùi hoa sữa lúc nửa đêm, dù mùa hoa đã qua từ lâu. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Ánh Phương chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://mui-huong-nua-dem';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Mùi Hương Nửa Đêm bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Ngôi nhà bỏ hoang cuối phố luôn thoảng mùi hoa sữa lúc nửa đêm, dù mùa hoa đã qua từ lâu xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'mui-huong-nua-dem' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Mùi nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'mui-huong-nua-dem' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Mùi: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mui-huong-nua-dem' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Mùi đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mui-huong-nua-dem' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Mùi buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mui-huong-nua-dem' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Mùi đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'mui-huong-nua-dem' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Con đường lát gạch sứ cổ dẫn người đi qua nó về lại một buổi chiều họ tưởng đã quên. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Hằng Thảo chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://con-duong-gach-su';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Con Đường Gạch Sứ bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Con đường lát gạch sứ cổ dẫn người đi qua nó về lại một buổi chiều họ tưởng đã quên xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'con-duong-gach-su' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Con nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'con-duong-gach-su' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Con: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'con-duong-gach-su' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Con đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'con-duong-gach-su' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Con buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'con-duong-gach-su' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Con đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'con-duong-gach-su' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Cô phát hiện mình có thể nghe được tiếng người đã khuất, nhưng chỉ khi trời đổ mưa. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Trịnh Tâm chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://nguoi-song-trong-mua';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Người Sống Trong Mưa bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Cô phát hiện mình có thể nghe được tiếng người đã khuất, nhưng chỉ khi trời đổ mưa xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'nguoi-song-trong-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Người nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'nguoi-song-trong-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Người: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'nguoi-song-trong-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Người đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'nguoi-song-trong-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Người buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'nguoi-song-trong-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Người đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'nguoi-song-trong-mua' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Một vụ án không xác chết, không nhân chứng, chỉ có một chiếc khăn tay bỏ quên giữa cơn gió. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Tùng Sơn chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://su-menh-cua-tham-tu';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Sứ Mệnh Của Thám Tử bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Một vụ án không xác chết, không nhân chứng, chỉ có một chiếc khăn tay bỏ quên giữa cơn gió xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'su-menh-cua-tham-tu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Sứ nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'su-menh-cua-tham-tu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Sứ: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'su-menh-cua-tham-tu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Sứ đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'su-menh-cua-tham-tu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Sứ buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'su-menh-cua-tham-tu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Sứ đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 400, TRUE FROM stories s WHERE s.source_url = 'su-menh-cua-tham-tu' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Cô gái trên mái nhà mỗi đêm nhìn xuống thành phố và giữ một bí mật đủ lớn để thay đổi tất cả. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Minh Châu chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://bong-dang-tren-mai-nha';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Bóng Dáng Trên Mái Nhà bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Cô gái trên mái nhà mỗi đêm nhìn xuống thành phố và giữ một bí mật đủ lớn để thay đổi tất cả xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'bong-dang-tren-mai-nha' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Bóng nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'bong-dang-tren-mai-nha' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Bóng: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'bong-dang-tren-mai-nha' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Bóng đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'bong-dang-tren-mai-nha' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Bóng buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'bong-dang-tren-mai-nha' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Bóng đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'bong-dang-tren-mai-nha' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Hai người bạn thời thơ ấu xa nhau hai mươi năm, tìm lại nhau nhờ một lời hứa khắc trên phiến đá bờ sông. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Thúy Kiều chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://ky-uc-ben-bo-song';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Ký Ức Bên Bờ Sông bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Hai người bạn thời thơ ấu xa nhau hai mươi năm, tìm lại nhau nhờ một lời hứa khắc trên phiến đá bờ sông xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'ky-uc-ben-bo-song' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Ký nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'ky-uc-ben-bo-song' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Ký: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ky-uc-ben-bo-song' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Ký đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ky-uc-ben-bo-song' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Ký buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ky-uc-ben-bo-song' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Ký đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 300, TRUE FROM stories s WHERE s.source_url = 'ky-uc-ben-bo-song' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);

UPDATE stories SET description = 'Căn phòng luôn có một ô cửa sổ mở, dù chủ nhà chưa bao giờ nhớ đã mở nó. Đây là một trong những câu chuyện được bạn đọc yêu thích nhất trên Tà Lụa Truyện, do Nam Phong chấp bút, cập nhật đều đặn với văn phong nhẹ nhàng nhưng nhiều nút thắt bất ngờ. 40% chương đầu tiên hoàn toàn miễn phí, các chương sau mở khoá bằng Bạc hoặc gói Hội viên VIP.' WHERE source_url = 'demo://dem-cua-so-mo';
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 1, 'Chương 1: Khởi đầu', 'Câu chuyện của Đêm Của Cửa Sổ Mở bắt đầu vào một buổi chiều bình thường như bao buổi chiều khác, cho đến khi Căn phòng luôn có một ô cửa sổ mở, dù chủ nhà chưa bao giờ nhớ đã mở nó xuất hiện.
Không ai trong số họ biết rằng, từ khoảnh khắc đó, mọi thứ sẽ không còn như cũ nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'dem-cua-so-mo' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 1);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 2, 'Chương 2: Dấu hiệu đầu tiên', 'Những dấu hiệu nhỏ bắt đầu xuất hiện, lặng lẽ như thể ai đó đang cố nói điều gì đó mà lời nói không đủ diễn tả.
Đêm nhận ra mình không thể phớt lờ chúng thêm được nữa.', TRUE, 0, TRUE FROM stories s WHERE s.source_url = 'dem-cua-so-mo' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 2);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 3, 'Chương 3: Ngã rẽ', 'Một lựa chọn đặt ra trước mắt Đêm: tiếp tục con đường quen thuộc, hay bước vào vùng đất chưa ai từng kể lại.
Gió đêm ấy lạnh hơn thường lệ, như thể chính bầu trời cũng đang chờ câu trả lời.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'dem-cua-so-mo' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 3);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 4, 'Chương 4: Sự thật hé lộ', 'Từng mảnh ghép rời rạc dần khớp lại với nhau. Đêm đứng lặng trước sự thật mà bản thân chưa từng dám nghĩ tới.
Có những điều, một khi đã biết, sẽ không thể nào quên được nữa.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'dem-cua-so-mo' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 4);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 5, 'Chương 5: Cái giá phải trả', 'Không có con đường nào miễn phí. Để tiến thêm một bước, Đêm buộc phải đánh đổi một điều gì đó quý giá.
Câu hỏi chỉ còn là: liệu điều đó có đáng không.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'dem-cua-so-mo' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 5);
INSERT INTO chapters (story_id, chapter_number, title, content, is_free, price_in_silver, visible)
SELECT s.id, 6, 'Chương 6: Đối mặt', 'Cuối cùng, khoảnh khắc không thể trốn tránh cũng đến. Đêm đứng đối diện với chính nỗi sợ lớn nhất của mình.
Phía sau lưng không còn đường lui, phía trước chỉ còn một lựa chọn duy nhất.', FALSE, 350, TRUE FROM stories s WHERE s.source_url = 'dem-cua-so-mo' AND NOT EXISTS (SELECT 1 FROM chapters c WHERE c.story_id = s.id AND c.chapter_number = 6);
