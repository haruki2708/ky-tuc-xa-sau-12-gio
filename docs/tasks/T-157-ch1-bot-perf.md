# T-157 — Bot chơi chương 1, đo hiệu năng nhiều tầng, kiểm tra lưu game
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-157-ch1-bot-perf`
- Phụ thuộc: T-115 (bot cũ). Phần cuối cần T-150 ghép xong. Đọc `docs/design/STORY.md` §10 và `tools/README.md`.
- **Hạn:** phần công cụ hết ngày **2026-10-05**; chạy bot trên bản ghép **2026-10-07**.

## Mục tiêu
Chương 1 dài khoảng 50 phút, nhiều tầng, có nấp và câu đố. Không thể chỉ chơi bằng tay để kiểm tra mỗi lần ghép. Cần bot chơi trọn chương, công cụ đo FPS nhiều tầng, và kiểm tra lưu game giữa các chương.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Bot hiểu cơ chế mới** (`playthrough_bot.gd`, `Autoplay`):
   - Hành động mới: giữ cúi, nấp vào một `hide_spot` theo tên, nín thở N giây, giơ/hạ điện thoại, bật/tắt đèn pin, giải câu đố (gửi `puzzle_solved(id)` như người chơi đã giải đúng; có chế độ nhập đáp án qua panel nếu panel T-156 đã có).
   - **Đi theo navmesh** giữa các tầng qua cầu thang (`NavigationServer3D.map_get_path`), không chỉ đi thẳng.
   - Chưa có cơ chế nào (chưa merge) thì bỏ qua hành động đó và ghi `SKIP` có lý do, không làm fail cả lượt.
2. **Kịch bản chương 1** (`tools/playthrough.ps1 -Chapter 1 -Scenario …`):
   - `ch1_good`: làm đúng mọi dòng thật, giải hai câu đố, không bị bắt, tới cảnh kết đêm 1. Kiểm tra `Progress.unlocked_chapter() >= 2` và `replaced_roommate = "phuc"`.
   - `ch1_answer_for`: trả lời hộ **Việt** lúc điểm danh. Kiểm tra `replaced_roommate = "viet"`.
   - `ch1_caught`: cố tình bật đèn cầu thang để bị Người đi dép đuổi, đứng yên cho bị bắt. Kiểm tra tải lại checkpoint, mức "lệch" cộng đúng, chơi tiếp tới hết đêm.
   - Bot dùng file `progress` và `checkpoint` tạm, không ghi đè bản lưu của người chơi.
   - Giữ 3 kịch bản demo cũ chạy được cho tới khi integrator thay luồng chương; khi thay, ghi rõ trong Handoff kịch bản nào bỏ.
3. **Đo hiệu năng** (`tools/perf.ps1` hoặc mở rộng công cụ có sẵn):
   - Đặt camera ở các góc cố định: hành lang tầng 4, 5, 6, cầu thang giữa tầng 5 và 6, sân phơi, phòng 407.
   - Đo FPS trung bình và p95 thời gian frame như cách của T-112. Ghi JSON.
   - Trước khi T-153 merge thì chạy trên `floor4`; sau đó chạy trên `building_playtest.tscn`.
4. **Kiểm tra lưu game:**
   - test hoặc smoke cho `Progress` cùng checkpoint;
   - tải lại giữa đêm 1 giữ nguyên `GameState.chapter`, pin điện thoại, tin nhắn đã nhận (khi T-155 có `snapshot/restore`);
   - chọn đêm 2 khi chưa mở thì không vào được.
5. **Báo cáo** trong Handoff: thời gian chơi của bot cho mỗi kịch bản (đo thời gian trong game và thời gian thật), các chỗ bot bị kẹt.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Công cụ chạy được trên `main` hiện tại (bỏ qua có lý do phần chưa có)
- [ ] Sau khi integrator ghép chương 1: 3 kịch bản PASS, số đo FPS
- [ ] Handoff: lệnh chạy, kết quả, chỗ kẹt

## Handoff (agent điền)
