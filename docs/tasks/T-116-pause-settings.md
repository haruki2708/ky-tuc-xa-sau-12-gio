# T-116 — Menu tạm dừng và cài đặt
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-116-pause-settings`
- Phụ thuộc: T-104, T-105 (done). **Đọc `docs/SETTINGS.md` trước khi làm**; đó là hợp đồng chung với lane A, B, E.
- Làm song song với T-118 (B), T-125 (A), T-126 (E). Integrator merge T-116 **trước** T-125.

## Mục tiêu
Người chơi bấm Esc để tạm dừng, chỉnh âm lượng từng loại âm (kể cả bước chân), độ nhạy chuột, bật/tắt nhún đầu, độ sáng, cường độ filter PS1, ngôn ngữ. Thay đổi có hiệu lực ngay và được lưu lại.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## Yêu cầu
1. **Script cài đặt chung `game/scripts/ui/settings.gd`** (`extends Node`, sẽ là autoload `Settings`):
   - `get_value(section, key)` trả về giá trị đã lưu hoặc mặc định theo bảng trong `docs/SETTINGS.md`, có kiểm tra kiểu và khoảng.
   - `set_value(section, key, value)` kẹp giá trị vào khoảng hợp lệ, lưu file, áp dụng phần thuộc lane D, rồi emit `EventBus.settings_changed(section, key)`.
   - `_ready()`: áp dụng ngôn ngữ và âm lượng các bus ngay lúc khởi động. Chuyển việc áp dụng ngôn ngữ ra khỏi `hud.gd` (xem Review T-104).
   - Giữ `locale_settings.gd` chạy được, hoặc cho nó gọi qua `settings.gd`. Test cũ của T-104 vẫn phải PASS.
   - Không tự sửa `project.godot`. Ghi "Yêu cầu thay đổi: thêm autoload `Settings`" vào Handoff, kèm đường dẫn và vị trí (sau `EventBus`).
2. **Menu tạm dừng `game/ui/pause/pause_menu.tscn`** (CanvasLayer, nằm trên HUD):
   - Phím `pause` (Esc) mở hoặc đóng menu. Khi mở: `get_tree().paused = true`, hiện chuột, emit `EventBus.game_paused(true)`. Khi đóng thì làm ngược lại.
   - Node menu dùng `process_mode = PROCESS_MODE_ALWAYS` để vẫn chạy khi game dừng.
   - Các nút: **Tiếp tục**, **Cài đặt**, **Thoát game**.
3. **Màn hình cài đặt** (mở từ menu tạm dừng):
   - **Âm thanh:** thanh trượt cho Master, Âm môi trường, Hiệu ứng, **Bước chân**, Giọng đọc, Nhạc. Bus nào chưa có trong `AudioServer` thì ẩn thanh trượt của bus đó (bus `Footsteps` do lane E thêm ở T-126).
   - **Điều khiển:** độ nhạy chuột.
   - **Hình ảnh:** bật/tắt nhún đầu, độ sáng, cường độ filter PS1.
   - **Ngôn ngữ:** Việt / Anh.
   - Mọi thay đổi gọi `Settings.set_value(...)`. Có nút **Khôi phục mặc định**.
   - Điều khiển được bằng chuột. Chữ lấy từ `strings.csv`, đủ `vi` và `en`.
4. **Sửa việc tồn từ Review T-104:**
   - Tâm ngắm khoảng 6 px, có viền tối mảnh để thấy được trên cả nền sáng lẫn tối.
5. **Test `game/tests/ui/`:**
   - `get_value` trả mặc định khi thiếu file hoặc giá trị sai kiểu, ngoài khoảng.
   - `set_value` lưu file, kẹp khoảng, emit `settings_changed` đúng section và key, và **giữ nguyên** các mục khác trong file.
   - Đổi `[audio] sfx_db` thì volume bus SFX đổi theo; ≤ −40 thì bus bị mute.
   - Esc mở menu: game dừng, `game_paused(true)` được emit. Esc lần nữa hoặc bấm Tiếp tục: game chạy lại, `game_paused(false)`.
   - Thanh trượt của bus không tồn tại bị ẩn.
   - Test sao lưu và khôi phục `user://settings.cfg` như T-104.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Có ảnh chụp menu tạm dừng và màn hình cài đặt (tiếng Việt)
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền, kèm "Yêu cầu thay đổi" (autoload `Settings`, gắn menu vào `main.tscn`)

## Handoff (agent điền)
