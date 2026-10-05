# T-177 — Chương 2: đứng yên khi đang gõ chữ
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-177-ch2-typing`
- Phụ thuộc: T-171. **Đọc D-049, D-051 trong `docs/DECISIONS.md`.**
- **Hạn đề xuất: hết ngày 2026-10-07.**

## Mục tiêu
Từ D-049, vòng 3 người chơi **gõ từ bằng bàn phím** và vòng 4 **gõ tin nhắn dự đoán** trong điện thoại. Khi một ô nhập chữ của lane D đang nhận bàn phím, chữ gõ vào không được làm nhân vật đi (W, A, S, D), chạy (Shift), cúi, nín thở, bấm tương tác (E), giơ điện thoại hay mở camera.

## Được phép sửa
`game/scenes/player/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`

## Hợp đồng có sẵn (core, không sửa)
- `EventBus.text_entry_changed(active: bool)`: lane D phát `true` khi ô nhập nhận bàn phím, `false` khi trả lại. Đọc chú thích trong `game/scripts/core/event_bus.gd`.

## Yêu cầu
1. Khi `active == true`:
   - nhân vật đứng yên, không đọc input di chuyển, chạy, cúi, nín thở, tương tác, phím điện thoại;
   - **chuột vẫn nhìn được**;
   - đang di chuyển thì dừng êm, không trượt tiếp.
2. Khi `false`: điều khiển trở lại ngay. Phím đang được giữ lúc mở ô nhập không được "kẹt" sau khi đóng.
3. Không ảnh hưởng menu tạm dừng, màn đọc giấy, nằm giường, trốn.
4. Nhiều ô nhập (ví dụ đóng ô này mở ô kia liên tiếp) không làm lệch trạng thái: lấy giá trị cuối cùng.
5. Test: phát `text_entry_changed(true)`, mô phỏng giữ W và E → không di chuyển, không tương tác; phát `false` → di chuyển lại.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Handoff: hàm/biến đã thêm, cách kiểm tra

## Handoff (agent điền)

### Đã làm — 2026-10-06

- Phần Gameplay hoàn thành trên `lane-a/T-177-ch2-typing`, base `e09451b`. Commit mã `054d290` đã push trước khi ghi Handoff. Chỉ sửa 3 script trong phạm vi A và thêm bộ test cùng UID.
- `player.gd`: thêm `_text_entry_active`, `GAMEPLAY_ACTIONS`, `_on_text_entry_changed(active)` và API `keyboard_input_blocked()`. Giá trị cuối của signal quyết định trạng thái; phát lặp cùng giá trị không làm thay đổi input. API mới trả true khi đang gõ hoặc có khóa điều khiển hiện hữu; `controls_locked()` vẫn giữ hợp đồng cũ để chuột nhìn được khi gõ.
- Khi bắt đầu nhập: dừng velocity ngay, nhả nín thở; không đọc di chuyển/chạy/cúi/tương tác. Nhún đầu trở dần về 0. Khi nằm/trốn, giữ nguyên occupancy, vẫn nhìn bằng chuột và vẫn chạy bộ đếm thở tự nhiên; E không làm rời chỗ.
- Khi đổi trạng thái nhập ở cả hai chiều: nhả các action gameplay đang giữ. Sau khi đóng ô, nhấn lại phím là điều khiển được ngay; không phát lại phím đã gõ. Không tiêu thụ sự kiện ký tự, Enter hay Esc của UI. Kiểm tra E thêm `is_action_pressed` vì Godot còn giữ `is_action_just_pressed` trong frame đã gọi `action_release`; tránh tương tác/rời chỗ trốn ngay lúc đóng ô.
- `phone_item.gd`: phím Q/F hỏi `keyboard_input_blocked()` của Player; giữ fallback `controls_locked()` cho ancestor cũ. Các API `set_raised`/`set_flashlight` vẫn dùng được, để core/UI giơ điện thoại chứa ô dự đoán.
- `CarryItem.player_can_use()` thêm kiểm tra API mới; các tương tác chương 2 dùng helper này, đặc biệt lượt lau màn hình đang dở, không tiếp tục nhận E trong lúc gõ.

### Cách kiểm tra và kết quả

- `pwsh tools/test.ps1 -Filter player`: `RESULT: 132 passed, 0 failed` (exit 0).
- `pwsh tools/test.ps1`: `RESULT: 489 passed, 0 failed` (exit 0).
- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)` (exit 0).
- Log cục bộ: `build/T-177-player-final.log`, `build/T-177-test-final.log`, `build/T-177-check-final.log` (không commit build).
- Bộ mới `game/tests/player/test_text_entry.gd` có 8 test: giữ W/E và dừng trượt; khôi phục ngay sau khi đóng; phím giữ và tín hiệu liên tiếp; chuột cùng Q/F; nằm/trốn và thở; pause/khóa đọc giấy; hủy lau E; sự kiện chữ tới `LineEdit`; khóa chết và dọn kết nối khi thay Player.
- Để thử trên UI T-179 sau khi ghép: đang đi thì Enter mở ô, gõ W/A/S/D/E/Q/F/Space/Shift/Ctrl; nhân vật đứng yên, chuột vẫn nhìn. Enter gửi hoặc Esc hủy rồi nhấn W/E lại. Lặp khi nằm/trốn, mở/đóng nhiều ô, và pause/resume; kiểm tra Q không hạ điện thoại đang chứa ô dự đoán.
- Chưa chơi tay với UI T-179, chưa thử Unikey/EVKey/Windows IME. Test `LineEdit` ở đây chỉ kiểm tra sự kiện chữ không bị Player nuốt, không xác nhận bộ gõ hệ điều hành.

### Yêu cầu thay đổi ngoài phạm vi / phần còn thiếu

- **Lane D / T-179 cần chặn phím tắt UI điện thoại/camera khi `text_entry_changed(true)`.** Trên base hiện tại, `game/scripts/ui/phone_screen.gd::_input()` gọi `phone_tools.handle_input()` trước giai đoạn `_unhandled_input` của Player; `phone_tools.gd` dùng `[`/`]` đổi tab (có thể mở camera), `,`/`.` đổi camera và Enter đánh dấu bản đồ. `_blocked()` của UI hiện chỉ xét pause/giấy/puzzle, chưa xét ô nhập. Vì vậy phần A chặn Q/F và E gameplay chưa đủ để đáp ứng toàn bộ yêu cầu **không mở camera khi gõ** nếu điện thoại đang giơ.
- Đề nghị D tách chặn các shortcut cũ (gồm E nhận cuộc gọi/lựa chọn cũ nếu còn) khỏi luồng nhập chữ, trước khi gọi `tools_view.handle_input`. Giữ Enter gửi/Esc hủy của ô nhập. Không thêm trạng thái nhập vào `_blocked()` dùng chung cho visibility, vì sẽ ẩn luôn điện thoại chứa ô dự đoán.
- A không sửa hai file UI trên và không chặn sự kiện bàn phím toàn viewport, vì như vậy sẽ làm ô nhập mất chữ. Không cần thêm signal, input action hay plugin.

### Trạng thái bàn giao

- Hai mục checklist đã đạt; các hành vi trong phạm vi A đã qua test. **Blocked ở phần tích hợp phím camera UI ngoài phạm vi:** cần thay đổi của lane D nêu trên trước khi xác nhận toàn bộ yêu cầu T-177 trong bản ghép. Không có blocker còn lại trong code Gameplay A; không có câu hỏi luật chơi/cốt truyện mới.
