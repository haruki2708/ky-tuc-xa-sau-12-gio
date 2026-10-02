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
| D-012 | 2026-10-02 | Duyệt hướng hình ảnh bộ kit T-102. Sửa **ghế nhựa đỏ thành kiểu lùn Việt Nam** (chân loe, có lỗ cầm). **Thêm mùng** cho giường tầng, có bản đóng và bản mở, nhìn xuyên lờ mờ | Ghế phải nhận ra ngay là đồ Việt Nam; mùng gắn với cốt truyện (bạn cùng phòng nằm sau mùng). Giao ở T-121 |
| D-013 | 2026-10-02 | Duyệt bộ kit T-121: ghế nhựa đỏ lùn và **mùng giữ nguyên như hiện tại** (lưới alpha scissor, thấy rõ hình người bên trong) | Chủ dự án xem ảnh `kit_showcase.png` và chấp nhận; integrator từng đề xuất làm mắt lưới nhỏ, mờ hơn nhưng không áp dụng |
| D-014 | 2026-10-02 | Duyệt tiếng ù đèn tuýp mới (T-114). Bước chân phải **nhẹ, tự nhiên như người**: bước thưa hơn theo tốc độ, nhịp không đều tuyệt đối, âm dép mềm hơn và nhỏ hơn tiếng cửa | Chủ dự án nghe hành lang chính: tiếng bước "khá to, kiểu robot", kể cả sau khi integrator giảm 8 dB. Giao T-122 (lane A, nhịp) và T-123 (lane E, âm) |
| D-015 | 2026-10-02 | **Chốt độ to bước chân:** dép lê đi bộ **−38 LUFS**, chạy **−35 LUFS** (`TARGET_OVERRIDES` trong `audio_source/process.py`). Chất âm "lẹp xẹp" T-123 đã được duyệt | Chủ dự án nghe qua 4 lần (−26 → −30 → −34 → −38), lần cuối bằng tai nghe. Lane khác không tự đổi mức này; muốn đổi thì hỏi chủ dự án |
| D-016 | 2026-10-02 | Duyệt độ to bước chân −38/−35 LUFS (D-015) bằng tai nghe. **Giảm tiếng ù đèn tuýp xuống −32 LUFS** (trước −24), chất âm giữ nguyên | Chủ dự án: tiếng ù "to quá", muốn nhỏ đáng kể. Tiếng chập chờn `fluorescent_flicker` vẫn −18 LUFS, chưa đổi |
| D-017 | 2026-10-02 | **Giảm tiếng ù đèn tuýp xuống −44 LUFS** (thay D-016: −32). Tiếng ù chỉ là âm nền rất khẽ | Chủ dự án nghe −32 vẫn "khá to", muốn "nhỏ lại rất nhiều" |
| D-018 | 2026-10-02 | Duyệt nhịp bước T-122 (đi 1,1 m, chạy 1,4 m, jitter ±6%). **Giảm bước chân xuống −46 LUFS (đi), −43 LUFS (chạy)** (thay D-015: −38/−35) | Chủ dự án: nhịp đi ổn, nhưng tiếng bước "vẫn khá to", muốn nhỏ đáng kể |
