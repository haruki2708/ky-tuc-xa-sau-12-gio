# T-125 — Player làm theo menu tạm dừng và cài đặt
- Lane: A (Gameplay) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền; ghi rõ phần nào chưa thử bằng chuột/phím thật

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane A
- Đã bỏ toàn bộ xử lý action `pause` khỏi Player. `_ready()` vẫn yêu cầu bắt chuột; `EventBus.game_paused(true)` thả chuột và khóa mouse-look, `false` bắt lại và cho nhìn tiếp. Không thay `SceneTree.paused` từ Player; menu Lane D chịu trách nhiệm việc đó.
- Player đọc `user://settings.cfg` trực tiếp bằng `ConfigFile` lúc `_ready()`, nghe `settings_changed` và chỉ đọc lại đúng khóa `input/mouse_sensitivity` hoặc `video/head_bob` được thông báo. Không tạo/lưu/sửa file cài đặt.
- Kiểm tra đúng hợp đồng: sensitivity phải là float hữu hạn trong khoảng đóng 0,0005–0,006, sai thì về 0,002; head-bob phải là bool, sai thì về true. Thiếu file/mục hoặc không đọc được file cũng dùng mặc định. Giá trị hợp đồng ghi đè export khi khởi tạo, nên test gameplay đặt tùy chọn bob của fixture sau `_ready()`.
- Khi tắt bob bằng settings, camera về offset Y = 0 ngay trong callback, kể cả cây scene đang pause. Signal callback nhận thay đổi khi pause mà không cần đổi process mode của Player.
- Thêm 8 test settings/pause và `.uid`; cập nhật test mouse-look cũ sang signal. Bao phủ pause/resume lặp lại, Esc/action không tự toggle, đọc khi khởi tạo, cập nhật từng khóa khi pause, sensitivity thực sự đổi góc nhìn, tắt/bật bob, thiếu file/khóa, sai kiểu/ngoài khoảng/NaN/vô cực, hai biên hợp lệ, không ghi file và tự gỡ kết nối khi Player được free.
- Test mới sao lưu nguyên byte `user://settings.cfg` trước mỗi ca và khôi phục sau mỗi ca; nếu ban đầu không có file thì xóa file tạm. Khôi phục cả trạng thái pause và mouse mode.
- Commit code: `13f1d7e` — `T-125: Follow pause signals and reload validated player settings`; đã push lên `origin/lane-a/T-125-player-settings` trước khi ghi Handoff.

### Kết quả kiểm tra
- Nền đã kiểm tra: `origin/main` tại `7552c07` (đã có hợp đồng settings/EventBus và T-110; chưa có menu T-116 ở lần fetch kiểm tra).
- `pwsh tools/test.ps1 -Filter player_settings`: **`RESULT: 8 passed, 0 failed`**, exit code 0.
- `pwsh tools/test.ps1`: **`RESULT: 91 passed, 0 failed`**, exit code 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0.
- `git diff --cached --check`: sạch trước commit code. Thay đổi chỉ thuộc `game/scripts/player/`, `game/tests/player/` cùng checklist/Handoff card này.
- **Chưa thử bằng chuột/phím thật**: chưa mở editor/F6 và chưa kiểm tra luồng UI mở/đóng menu T-116. Test dùng signal và sự kiện input tổng hợp, kể cả lúc `SceneTree.paused = true`; headless xác minh trạng thái yêu cầu capture, không chứng minh OS bắt chuột thực tế.
- Cách kiểm tra tiếp sau khi tích hợp T-116: chạy game, Esc mở menu rồi đóng bằng Esc/nút tiếp tục nhiều lần; nhìn quanh sau mỗi lần đóng. Trong menu, đổi độ nhạy và tắt/bật bob; xác minh áp dụng ngay, thoát/chạy lại vẫn đọc giá trị đã lưu. Chạy riêng test bằng `pwsh tools/test.ps1 -Filter player_settings`.

### Yêu cầu thay đổi / chặn
- Không cần sửa thêm file ngoài phạm vi hoặc thêm signal/settings key. **Integrator merge T-116 trước T-125**, đúng thứ tự card; sau đó kiểm tra luồng menu thật. Khi chưa có menu, Esc không còn được Player xử lý theo yêu cầu task.
- Không còn blocker code/test/push hoặc phần code đang làm dở. Kiểm tra tích hợp menu và chuột/phím thật vẫn chờ T-116.
- GitHub bị chặn mạng trong sandbox, sau đó sandbox Windows báo lỗi tạo tiến trình 1326; đã dùng cơ chế cấp quyền ngoài sandbox cho các lệnh cần thiết. Không cài phần mềm, không thêm plugin, không làm việc trong bản tích hợp.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`** (sau T-116, đúng thứ tự). Sau merge: `test.ps1` → `RESULT: 110 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi. Bỏ hẳn xử lý Esc; bắt và thả chuột theo `game_paused`. Đọc độ nhạy và nhún đầu theo hợp đồng: sai kiểu, ngoài khoảng, NaN hay vô cực thì dùng mặc định, không kẹp. Không ghi file cài đặt.
- 8 test mới, kể cả đổi cài đặt khi cây scene đang dừng và tự gỡ kết nối signal khi Player bị xóa.
- Tích hợp với menu T-116 đã được kiểm bằng test core (Esc trong `main.tscn`).
- Handoff trung thực: chưa thử bằng chuột và phím thật. Chủ dự án kiểm khi chơi.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
