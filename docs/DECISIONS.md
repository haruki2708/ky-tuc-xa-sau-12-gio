# Nhật ký quyết định

Mỗi quyết định ghi: ngày, nội dung, lý do. Muốn đổi một quyết định thì thêm dòng mới, không xóa dòng cũ.

| # | Ngày | Quyết định | Lý do / ghi chú |
|---|---|---|---|
| D-001 | 2026-10-02 | Engine **Godot 4.7.2 + GDScript**, renderer Forward+ | Nhẹ (ổ C: gần đầy); scene và script là file văn bản nên AI sửa được; test và export chạy headless; GDScript gần Python; miễn phí |
| D-002 | 2026-10-02 | Cơ chế chính là **"Nội quy có bản bị sửa"**. Hồ sơ dùng để kiểm chứng, điểm danh là sự kiện mốc, "người thứ năm" là twist truyện | "Nhận diện bạn cùng phòng" bị loại: tốn kém và thể loại đã bão hòa |
| D-003 | 2026-10-02 | Hướng kinh dị: **tâm linh dân gian nhẹ, mơ hồ, có logic luật lệ**. Tránh chủ đề tự tử và bạo lực thật | Tạo khác biệt trên thị trường; nhạy cảm với bối cảnh ký túc xá có thật |
| D-004 | 2026-10-02 | Tiền đề: sinh viên năm nhất ở lại ký túc xá dịp nghỉ, tầng gần như trống, bạn cùng phòng ngủ sau mùng, điểm danh đọc 5 tên cho phòng 4 người | Giảm số NPC một cách hợp truyện |
| D-005 | 2026-10-02 | Đồ họa **phong cách PS1 rõ rệt**: texture thấp lọc nearest, low-poly, render độ phân giải thấp, dithering | Giấy tờ manh mối khi xem cận cảnh phải hiển thị **sắc nét** để dễ đọc. Cài đặt có tùy chọn giảm cường độ filter |
| D-006 | 2026-10-02 | Lồng tiếng bằng **giọng AI (TTS)** cho loa đọc nội quy và điểm danh | Phải chọn công cụ cho phép **dùng thương mại** và đọc tiếng Việt tự nhiên. Ghi tên công cụ vào CREDITS. **Khai báo AI khi lên Steam.** Bản tiếng Anh dùng giọng Việt kèm phụ đề |
| D-007 | 2026-10-02 | Dùng **5 agent GPT** làm task thử trong tuần đầu, sau đó xem xét giảm | Chấm theo `tasks/README.md` |
| D-008 | 2026-10-02 | **Claude tự merge sau khi review.** `main` luôn phải chạy được | |
| D-009 | 2026-10-02 | Repo GitHub **private**, Git LFS cho file nhị phân. Mỗi agent làm trong clone riêng ở `D:\GAME_WORK\lane-x` | Tránh việc agent chuyển nhánh làm đè lên nhau |
| D-010 | 2026-10-02 | Công cụ cài vào `D:\Tools\`. Godot ở chế độ self-contained (dữ liệu editor nằm ở `D:\Tools\Godot\editor_data`) | Ổ C: chỉ còn khoảng 6 GB |
| D-011 | 2026-10-02 | Input action đăng ký bằng code (`scripts/core/game_input.gd`). Test dùng runner tự viết (`tests/run_tests.tscn`), không dùng addon | Giữ `project.godot` gọn, không phụ thuộc plugin |
