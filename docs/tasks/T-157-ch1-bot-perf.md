# T-157 — Bot chơi chương 1, đo hiệu năng, kiểm tra lưu game
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-157-ch1-bot-perf`
- Phụ thuộc: T-115 (bot cũ). Phần cuối cần T-150 ghép xong. Đọc `docs/design/STORY.md` v2 §5 và `tools/README.md`.
- **Hạn:** phần công cụ hết ngày **2026-10-05**; chạy trên bản ghép **2026-10-07**.

## Mục tiêu
Chương 1 dài khoảng 50 phút, có nhiều cách chết. Mỗi lần ghép đều cần bot chơi trọn chương, kiểm tra các nhánh chết đều tải lại checkpoint đúng, và đo FPS.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Bot hiểu cơ chế mới** (`playthrough_bot.gd`, `Autoplay`):
   - nằm lên một giường theo số (`bunk_spot` của T-151), rời giường;
   - nín thở N giây; đứng yên không xoay camera;
   - giơ/hạ điện thoại; bắt máy (`phone_call_answered`);
   - chọn lựa chọn trong cuộc gọi (`chat_choice_made`);
   - giải câu đố (phát `puzzle_solved` hoặc nhập qua panel nếu đã có);
   - đi tới một điểm.
   - Cơ chế nào chưa merge thì bỏ qua hành động đó, ghi `SKIP` kèm lý do, không làm fail cả lượt.
2. **Kịch bản chương 1** (`tools/playthrough.ps1 -Chapter 1 -Scenario …`):
   - `ch1_good`: rời giường trong 60 giây, đi vệ sinh rồi về, không ra khỏi phòng sau Tổng tắc, bắt máy, lấy sạc, khi quản lý tới thì nằm giường của bạn và nín thở. Tới cuối chương: `Progress.unlocked_chapter() >= 2`.
   - `ch1_stay_in_bed`: không rời giường lúc mở đầu, nên chết; kiểm tra màn chết và tải lại.
   - `ch1_leave_room`: ra khỏi phòng ở vòng 1, nên chết; kiểm tra tải lại đầu vòng 1.
   - `ch1_own_bed`: nằm giường của mình khi quản lý tới, nên chết; kiểm tra tải lại checkpoint trước khi quản lý vào.
   - Dùng file `progress` và `checkpoint` tạm.
   - Ba kịch bản demo cũ: giữ chạy được tới khi integrator thay luồng chương. Khi bỏ thì ghi rõ trong Handoff.
3. **Đo hiệu năng:** các góc cố định trong phòng 407 (nhìn từng giường, nhìn cửa), hành lang tầng 4, nhà vệ sinh. FPS trung bình và p95 như T-112, ghi JSON.
4. **Kiểm tra lưu game:** tải lại giữa chương giữ `GameState.chapter`, pin điện thoại, lịch sử cuộc gọi (khi T-155 có `snapshot/restore`); chọn chương 2 khi chưa mở thì không vào được.
5. **Báo cáo** trong Handoff: thời gian trong game và thời gian thật của mỗi kịch bản; chỗ bot bị kẹt.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Công cụ chạy được trên `main` hiện tại (bỏ qua có lý do phần chưa có)
- [ ] Sau khi integrator ghép: 4 kịch bản PASS, số đo FPS
- [ ] Handoff: lệnh chạy, kết quả, chỗ kẹt

## Handoff (agent điền)
