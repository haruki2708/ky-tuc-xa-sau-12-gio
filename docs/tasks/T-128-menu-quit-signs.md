# T-128 — Nút Thoát qua `App.quit()` và chữ trên biển tầng 4
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-128-menu-quit-signs`
- Phụ thuộc: T-116 (done), T-112 (done). Đọc mục **Review** trong `docs/tasks/T-112-floor4-greybox.md`.

## Mục tiêu
1. Nút "Thoát game" trong menu tạm dừng thoát sạch, không để lại lỗi âm thanh khi tắt game.
2. Có sẵn câu chữ song ngữ cho các biển trên tầng 4.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## Yêu cầu
1. **Nút Thoát game** (`pause_menu.gd`):
   - Gọi `App.quit()` nếu autoload `/root/App` tồn tại (`game/scripts/core/app.gd`, integrator đã thêm). Không có thì dùng `get_tree().quit()` như cũ (để scene thử F6 vẫn chạy).
   - Lý do: `App.quit()` dừng cây scene, tắt mọi nguồn âm, chờ 0,25 giây rồi mới thoát. Thoát ngay lập tức sẽ làm Godot báo `ERROR: resources still in use at exit`.
2. **Key dịch cho biển tầng 4** (theo `docs/design/LAYOUT.md`), đủ `vi` và `en`:
   - `SIGN_ROOM_401` … `SIGN_ROOM_408`: "Phòng 401" / "Room 401"…
   - `SIGN_GATE_LOCKED`: "Khóa cổng 23:00" / "Gate locked at 23:00"
   - `SIGN_WASHROOM`: "Nhà vệ sinh" / "Washroom"
   - `SIGN_DUTY_DESK`: "Bàn trực tầng 4" / "Floor 4 duty desk"
   - Lane B sẽ dùng các key này để in chữ lên biển (task sau). Task này chỉ thêm key.
3. **Test `game/tests/ui/`:**
   - Bấm Thoát game khi có `App`: `App.quit()` được gọi. Thay `App` bằng một node giả trong test để runner không bị thoát thật.
   - Không có `App`: vẫn dùng đường cũ (kiểm bằng cách thay hàm thoát, không thoát thật).
   - Các key mới có đủ `vi` và `en` (test CSV hiện có đã kiểm, chỉ cần chắc test PASS).

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
