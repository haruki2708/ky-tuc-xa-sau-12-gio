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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: hàm/biến đã thêm, cách kiểm tra

## Handoff (agent điền)
