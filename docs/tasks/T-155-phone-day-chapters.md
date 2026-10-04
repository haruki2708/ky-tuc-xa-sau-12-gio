# T-155 — Màn hình điện thoại, màn ban ngày, chọn đêm
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-155-phone-day-chapters`
- Phụ thuộc: T-150 phần 1 (đã có trên `main`). Đọc `docs/design/STORY.md` §8, §10 và D-027 trong `docs/DECISIONS.md`.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-156 ngay.

## Mục tiêu
Điện thoại của Trung là chỗ xem giờ (D-027), xem pin và đọc tin nhắn. Mỗi chương mở đầu bằng một màn ban ngày toàn tin nhắn. Màn hình chính có thêm mục chọn đêm.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/tests/ui/`, thêm key vào `game/localization/strings.csv`.

## Hợp đồng có sẵn (T-150, không sửa)
- Signal: `phone_raised(raised)`, `phone_battery_changed(percent)`, `phone_message_received(message_id)`, `flashlight_toggled(on)`, `player_hidden(hidden, kind)`, `breath_held(holding)`, `time_changed(minutes)`.
- `MessageData.load_by_id(id)`: `sender`, `sender_name_key`, `text_key`, `minutes`, `outgoing`, `clock_text()`.
- `GameState.clock_text()`, `GameState.chapter`; `Progress.unlocked_chapter()`; `App.start_chapter(n)`. Key tên đêm: `CH_1_TITLE` … `CH_4_TITLE`.

## Yêu cầu
1. **Màn hình điện thoại** (`ui/phone/phone_screen.tscn`, CanvasLayer):
   - **Hiện khi `phone_raised(true)`:** khung điện thoại ở góc dưới phải, chiếm khoảng 30% chiều cao, chữ to và rõ. Không áp filter PS1 lên chữ (như giấy tờ, D-005).
   - **Màn chính:** giờ trong game to ở giữa, ngày (lấy theo chương: đêm 1 là 30/4), % pin, biểu tượng đèn pin bật/tắt.
   - **Tin nhắn:** danh sách tin mới nhất bên dưới giờ; có hiển thị tin chưa đọc. Lăn chuột để cuộn qua các tin. Giơ điện thoại đủ 1 giây thì tính là đã đọc.
   - **Tin mới đến khi đang hạ điện thoại:** banner nhỏ "1 tin nhắn mới" ở góc màn hình, khoảng 3 giây, không che tâm ngắm.
   - **Không chặn di chuyển** và không nhả chuột: người chơi vẫn đi lại và nhìn được khi đang giơ điện thoại.
   - Ẩn khi mở sổ tay, xem giấy, mở menu tạm dừng hoặc mở panel câu đố.
   - Có API để vẽ lên texture `Screen` của mô hình điện thoại (T-154) qua SubViewport. Chưa có mô hình thì chỉ dùng overlay 2D.
   - Lịch sử tin nhắn đã nhận phải khôi phục được sau checkpoint. Đề xuất API `restore(message_ids: Array[StringName], read_ids: Array[StringName])` và `snapshot()`; integrator gọi khi lưu và khi tải.
2. **Lớp phủ khi nấp:**
   - Khi `player_hidden(true, …)`: viền tối quanh màn hình và gợi ý `PROMPT_HOLD_BREATH` (đã có).
   - Khi `breath_held(true)`: viền co lại một chút. Không có thanh đếm giây.
3. **Màn ban ngày** (`ui/day/day_screen.tscn`):
   - `show_day(chapter: int, message_ids: Array[StringName])`: nền đen, ngày và tên đêm (`CH_n_TITLE`), rồi các tin nhắn hiện lần lượt như trên điện thoại, mỗi tin cách nhau khoảng 1,2 giây.
   - Phím E, Space hoặc chuột: hiện hết tin ngay. Bấm thêm lần nữa thì phát signal `finished`.
   - Có nút bỏ qua.
4. **Chọn đêm** ở màn hình chính:
   - Thêm mục "Chọn đêm": danh sách 4 đêm, đêm chưa mở thì khóa và mờ (theo `Progress.unlocked_chapter()`).
   - Chọn một đêm thì gọi `App.start_chapter(n)`. Nếu đang có bản lưu thì hỏi xác nhận (dùng lại `confirm_panel`).
5. **Song ngữ:** mọi chữ qua key, đủ `vi` và `en`.
6. **Test `game/tests/ui/`:**
   - điện thoại hiện và ẩn theo signal;
   - giờ và pin cập nhật;
   - tin mới có banner;
   - snapshot/restore;
   - màn ban ngày phát `finished`;
   - chọn đêm khóa đúng theo Progress (dùng file progress tạm).

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp màn hình điện thoại, màn ban ngày, chọn đêm (vi và en)
- [ ] Handoff: API, cách integrator gắn vào main, phần chưa thử

## Handoff (agent điền)
