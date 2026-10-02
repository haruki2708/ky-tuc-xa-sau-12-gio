# T-125 — Player làm theo menu tạm dừng và cài đặt
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-125-player-settings`
- Phụ thuộc: T-122 (done). **Đọc `docs/SETTINGS.md` trước khi làm.** Làm song song với T-116 (lane D, menu). Integrator merge T-116 **trước** T-125.

## Mục tiêu
Từ khi có menu tạm dừng, Player không tự xử lý Esc nữa. Player bắt hoặc thả chuột theo `EventBus.game_paused`, và đọc độ nhạy chuột, nhún đầu từ file cài đặt.

Lý do: nếu cả Player lẫn menu cùng xử lý Esc, cờ bắt chuột của Player sẽ lệch với thực tế. Hậu quả là sau khi đóng menu, chuột không còn xoay được góc nhìn.

## Được phép sửa
`game/scenes/player/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`

## Yêu cầu
1. **Bỏ xử lý phím `pause` trong `player.gd`.**
2. **Nghe `EventBus.game_paused(paused)`:** `true` thì thả chuột và ngừng xoay góc nhìn; `false` thì bắt chuột lại. Khi vào game, Player vẫn bắt chuột như hiện tại.
3. **Đọc cài đặt** (theo `docs/SETTINGS.md`, đọc trực tiếp bằng `ConfigFile`):
   - `[input] mouse_sensitivity` cho `mouse_sensitivity`.
   - `[video] head_bob` cho `head_bob_enabled`.
   - Đọc lúc `_ready()`. Nghe `EventBus.settings_changed(section, key)`, đúng mục của mình thì đọc lại và áp dụng ngay.
   - Thiếu file, thiếu mục, sai kiểu hoặc ngoài khoảng thì dùng mặc định.
   - Player **không ghi** file cài đặt.
4. **Test `game/tests/player/`:**
   - `game_paused(true)` thì chuột được thả và chuyển động chuột không xoay góc nhìn; `game_paused(false)` thì xoay lại được.
   - Phím `pause` không còn làm Player đổi trạng thái chuột.
   - Ghi file cài đặt tạm với độ nhạy khác, emit `settings_changed("input", "mouse_sensitivity")`: Player dùng giá trị mới. Tương tự với `head_bob`.
   - Giá trị sai hoặc ngoài khoảng thì Player dùng mặc định.
   - Sao lưu và khôi phục `user://settings.cfg` của người dùng, như test T-104.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền; ghi rõ phần nào chưa thử bằng chuột/phím thật

## Handoff (agent điền)
