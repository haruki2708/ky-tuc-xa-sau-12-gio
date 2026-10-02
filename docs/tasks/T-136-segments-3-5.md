# T-136 — Đoạn 3–5 và cái kết
- Lane: core (Claude) | Trạng thái: doing (phần 1 xong) | Agent: Claude (integrator)
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
**Phần 1 (2026-10-03, Claude):** chơi được từ đầu đến cuối, chưa có cú hù hình ảnh và truy đuổi.
- **Dữ liệu:** `duty_log.tres`, `room_record_407.tres`; key `DOC_DUTY_LOG_*`, `DOC_ROOM_RECORD_*`, `SPK_*` (loa ký sổ, điểm danh, khóa vòi, kết), `SUB_*` mới, `PROMPT_CLOSE_TAP`.
- **Đặt đồ (`main.gd` `_place_story_papers`):** bảng nội quy, giấy viết tay (ẩn đến đoạn 4), sổ trực nằm trên bàn, thông báo nhà vệ sinh, hồ sơ phòng trên tủ Trung; vòi nước là `StoryTrigger` (lõi, `scripts/core/story_trigger.gd`). Đã chụp ảnh kiểm tra hướng.
- **`StoryDirector`:** `run_from(segment)` chạy từ một đoạn bất kỳ; `stop_after` cho test. Đoạn 3: dép sau lưng, phán định tạm bằng góc camera (50°, 0,3 s), về phòng là `keep_walking`, đứng yên 8 s là `stop_and_wait`. Đoạn 4: loa đọc 5 tên, bấm E trong lúc đang đọc một tên là trả lời; trả lời cho bạn cùng phòng làm mùng phồng; trả lời tên Lâm thì thua. Đoạn 5: vòi chảy (tiếng nhỏ giọt tạm); nhìn gương 25° trong 1 s là `look_in_mirror`. Kết: lệch 0–2 "…và một người nữa", lệch 3–4 Lâm thay Trung, rồi màn "Còn tiếp".
- **Mức lệch:** 1 đèn 405 chập chờn; 2 tắt đèn 402–404; 3 đôi dép thứ 5 và áo trắng trên dây phơi; 4 quạt quay chậm; 5 thua.
- **Thua:** `player_failed` → tiếng `whisper_co` và `net_billow` → tối màn hình → `restart_requested` → `main.gd` nạp lại scene, `StoryDirector.resume_checkpoint` khôi phục checkpoint đầu đoạn và đặt người chơi.
- **Test:** `tests/core/test_story_segments_3_5.gd` (13 test); test đoạn 1–2 dùng `stop_after = &"seg2"`.

**Còn lại (phần 2, khi T-134/T-135 xong):** thay phán định góc camera bằng `GazeDetector`; bóng người + `sting_hit` + truy đuổi 1 (đoạn 3); `mirror.stare()` + truy đuổi 2 (đoạn 5); đèn tắt dần sau lưng khi truy đuổi, vùng an toàn, bị bắt thì cộng lệch và tải lại; tiếng nước chảy thật (T-133 hoặc lane E).
