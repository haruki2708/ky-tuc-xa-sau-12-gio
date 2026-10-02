# T-136 — Đoạn 3–5 và cái kết
- Lane: core (Claude) | Trạng thái: todo | Agent: Claude (integrator)
- Phụ thuộc: T-117 (đoạn 1–2), T-131, T-132 (done); **T-134 (A), T-135 (B)** cho truy đuổi và gương. Thiết kế: `docs/design/RULES.md` mục 5, 5b, 6.

## Mục tiêu
Demo chơi được từ đầu đến cuối, khoảng 15–20 phút:
- **đoạn 3 (00:30):** xuống bàn trực ký sổ, đọc bảng nội quy và sổ trực; tiếng dép sau lưng; **truy đuổi 1** nếu quay lại;
- **đoạn 4 (01:00):** điểm danh 5 tên; giấy viết tay; thua thật nếu trả lời tên Lâm;
- **đoạn 5 (01:30):** vòi nước và gương; **truy đuổi 2** nếu nhìn gương;
- **kết (01:40):** biến thể theo mức "lệch".

## Việc của integrator
1. **Dữ liệu:** `duty_log` (sổ trực: dòng 23:40 thay bản photo; trang 2009 có tên Lâm bị gạch) và các key `DOC_*`; hồ sơ phòng 407 (`room_record_407`, 4 tên); key phụ đề mới.
2. **Đặt giấy tờ** (đồ vật `readable` của T-129): bảng nội quy, giấy viết tay (xuất hiện từ đoạn 4), sổ trực, giấy trong nhà vệ sinh, hồ sơ phòng trong tủ của Trung.
3. **Luồng `StoryDirector` đoạn 3–5:** loa gọi ký sổ; tiếng dép sau lưng do `GazeDetector` phán định (`keep_walking` / `turn_around` / đứng yên quá lâu); điểm danh đọc 5 tên (phụ đề và tiếng loa, chưa có TTS), người chơi bấm E để trả lời "Có" trong lúc đang đọc một tên; vòi nước tự chảy, gương do `GazeDetector` phán định.
4. **Cú hù (D-024)**, bỏ phần hình ảnh và sting mạnh khi `reduce_scares` bật:
   - quay lại chào: bóng người cuối hành lang, `sting_hit`, rồi truy đuổi 1;
   - trả lời tên Lâm: tối màn hình, `whisper_co`, mùng giường trống phồng (`net_billow`), rồi tải lại checkpoint đầu đoạn 4;
   - nhìn gương: phản chiếu trễ, `stare()`, `sting_hit`, rồi truy đuổi 2.
5. **Truy đuổi:** đèn hành lang sau lưng tắt dần từng bóng; vùng an toàn là đoạn còn đèn hoặc phòng 407 đã chốt; bị bắt thì cộng "lệch" và tải lại checkpoint đầu đoạn.
6. **Mức "lệch" (RULES mục 6):** thay đổi môi trường ở mỗi mức 1–4; mức 5 thua thật và tải lại checkpoint.
7. **Kết:** loa điểm danh lần cuối; lệch 0–2 và 3–4 hai biến thể; màn "Còn tiếp", mời theo dõi game.
8. **Test core:** chạy nhanh từng đoạn, các nhánh đúng và sai, thua và tải lại checkpoint, cả hai biến thể kết.

## Handoff
