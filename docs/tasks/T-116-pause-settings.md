# T-116 — Menu tạm dừng và cài đặt
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Có ảnh chụp menu tạm dừng và màn hình cài đặt (tiếng Việt)
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền, kèm "Yêu cầu thay đổi" (autoload `Settings`, gắn menu vào `main.tscn`)

## Handoff (agent điền)

### Đã làm (2026-10-02, Lane D)
- Commit triển khai `2483370` — `T-116: Add pause menu and shared persistent settings`; đã push lên `origin/lane-d/T-116-pause-settings`, tạo từ `origin/main` tại `7552c07`.
- Thêm `res://scripts/ui/settings.gd` (`extends Node`) theo đúng 11 mục trong `docs/SETTINGS.md`: đọc mặc định khi thiếu/sai kiểu/ngoài khoảng; kẹp số khi ghi; lưu trước, áp dụng ngôn ngữ và âm lượng, rồi emit `EventBus.settings_changed(section, key)`. `set_value()` và `reset_defaults()` trả về `Error`; lỗi lưu không phát signal hay áp dụng giá trị mới. Không thêm mục cấu hình mới.
- `Settings._ready()` áp dụng locale và các bus có sẵn. Ngưỡng −40 dB mute bus; tăng trở lại thì unmute. Theo dõi cả thêm/xóa và đổi tên bus. `reset_defaults()` lưu toàn bộ mặc định một lần trước khi thông báo từng mục; giữ nguyên dữ liệu ngoài các mục được cập nhật.
- `locale_settings.gd` giữ API cũ, gọi chung logic của Settings. HUD không còn áp dụng locale trong `_ready()`; tâm ngắm 6×6 px với viền tối 1 px (kích thước ngoài 8×8).
- Menu `res://ui/pause/pause_menu.tscn`: CanvasLayer 20 trên HUD, `PROCESS_MODE_ALWAYS`, Esc mở/đóng, nút Tiếp tục/Cài đặt/Thoát game. Cập nhật `SceneTree.paused` trước signal `game_paused`; thả chuột lúc mở và khôi phục chế độ chuột trước đó khi đóng. Bắt Esc ở `_input()` để không rơi tiếp xuống input gameplay.
- Màn hình cài đặt có các thanh âm lượng theo bus, độ nhạy chuột, nhún đầu, độ sáng, cường độ PS1, VI/EN, khôi phục mặc định và thông báo lỗi lưu. Thanh của bus thiếu được ẩn; thay đổi áp dụng/lưu ngay qua Settings. Chữ bổ sung đủ VI/EN, chỉ thêm key CSV.
- Scene thử độc lập `res://ui/pause/pause_test.tscn` dùng autoload nếu có, hoặc tạo Settings cục bộ khi chưa tích hợp. Scene HUD F6 cũ cũng có đường khởi động tương tự. Menu production mặc định tìm `/root/Settings`; khi thiếu thì nút Cài đặt bị vô hiệu hóa, không tự đăng ký autoload.

### Kiểm chứng
- `pwsh tools/test.ps1`: **`RESULT: 101 passed, 0 failed`**, exit code 0; bao gồm 29 test UI. Các cảnh báo GameState/Checkpoint trong bộ core là từ test dữ liệu không hợp lệ, không có `SCRIPT ERROR`/`ERROR` trong lượt cuối.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0.
- Log cục bộ (không commit, thuộc `build/`): `build/T-116/test.log`, `build/T-116/check.log`.
- Test bao phủ hợp đồng mặc định/kiểu/khoảng, kẹp giá trị, lưu trước signal, bảo toàn mục khác, mute/unmute SFX, startup locale/audio, reset; Esc, key repeat, Tiếp tục, Quay lại, game timer dừng/chạy lại, ẩn bus thiếu và nhận bus được thêm/đổi tên. Test chuột đẩy `InputEventMouseMotion`/`InputEventMouseButton` qua viewport để mở Cài đặt, chỉnh âm lượng và tiếp tục khi đang pause.
- Test T-104 vẫn PASS; hai test startup locale đã chuyển bước khởi động sang Settings theo yêu cầu review. Fixture sao lưu/khôi phục nguyên byte `user://settings.cfg`, locale, audio layout và trạng thái pause/chuột.
- Đã chạy scene bằng Vulkan Forward+ và xem hai ảnh 1920×1080: [menu tạm dừng](../../game/ui/pause/previews/pause_vi.png), [cài đặt tiếng Việt](../../game/ui/pause/previews/settings_vi.png). Chữ không bị cắt, dấu tiếng Việt rõ. Ảnh nằm trong Git LFS, kèm `.import`; script mới kèm `.uid`.
- `git diff --cached --check` sạch; thay đổi triển khai chỉ trong `game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key `strings.csv`; tài liệu chỉ đổi checklist/Handoff của card này. Không sửa `project.godot`, main, player, audio bus hoặc metadata texture kit.

### Cách thử và giới hạn kiểm chứng
- Mở `game/ui/pause/pause_test.tscn`, F6, nhấn Esc. Thử Cài đặt, kéo các thanh, đổi ngôn ngữ, Khôi phục mặc định, Quay lại, Tiếp tục; đóng/mở lại để kiểm tra lưu lựa chọn. Nút Thoát game gọi `SceneTree.quit()`.
- Tái tạo ảnh bằng Movie Maker với scene trên, thư mục đích tuyệt đối đã tạo trước, `--fixed-fps 30 --quit-after 3 --resolution 1280x720 --windowed`, và đối số sau `--`: `--capture-pause` hoặc `--capture-settings`. Hai chế độ chỉ ép locale hiển thị thành VI, không ghi cấu hình để chụp.
- Bus `Footsteps` chưa có ở base `7552c07`, nên ảnh cài đặt hiện 5 thanh âm lượng; test đã xác nhận thanh thứ sáu hiện và áp dụng giá trị đã lưu khi bus có mặt.
- Các lựa chọn của lane A/B đã được kiểm tra việc lưu và signal; chưa xác nhận tác động thực tế lên player/filter vì T-125/T-118 chưa có trong base này. Chưa chơi thử thủ công bằng người; các thao tác được kiểm tra tự động qua input/signal và ảnh được xem trực tiếp. Chưa chạy nút Thoát game trong phiên chơi thủ công.

### Yêu cầu thay đổi ngoài phạm vi
1. **Thêm autoload `Settings`**, đường dẫn `res://scripts/ui/settings.gd`, **ngay sau `EventBus`** trong `[autoload]` của `game/project.godot`: `Settings="*res://scripts/ui/settings.gd"`. Cần thực hiện cùng lúc tích hợp T-116 vì HUD đã bỏ trách nhiệm áp dụng locale khởi động.
2. Instance `res://ui/pause/pause_menu.tscn` vào `game/scenes/main/main.tscn`; giữ `settings_path` mặc định `/root/Settings`.
3. Tích hợp tiếp T-125 để player đọc độ nhạy/nhún đầu, nghe `game_paused` và bỏ tự xử lý Esc; T-118 để filter áp dụng độ sáng/PS1; T-126 để thêm bus `Footsteps`. Không cần thêm signal hay sửa hợp đồng cài đặt.

### Còn dở / trở ngại
- Không còn mục checklist chưa đạt; không bị chặn trong phạm vi Lane D. Các thay đổi tích hợp nêu trên do integrator thực hiện.
- Sandbox không truy cập được GitHub/Git LFS và không ghi được `user://`; đã chạy các lệnh liên quan thành công qua cơ chế cấp quyền ngoài sandbox. Lần checkout LFS lỗi ban đầu để lại file dở dang; đã lưu stash phục hồi `Recovery snapshot after interrupted T-116 LFS checkout`, rồi checkout sạch. Stash này chỉ là snapshot phục hồi cục bộ, không thuộc commit T-116.
- Không phát sinh câu hỏi về luật chơi/cốt truyện, không thêm plugin hay cài phần mềm.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`** (trước T-125). Sau khi merge cả T-116 và T-125: `test.ps1` → `RESULT: 110 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi; `strings.csv` chỉ thêm key. Xung đột cuối file với key `RULE_*` của T-113 đã được integrator gộp (49 key, không trùng).
- `Settings` đúng hợp đồng `docs/SETTINGS.md`: kiểm tra kiểu và khoảng khi đọc, kẹp khi ghi, lưu trước rồi mới emit. Lỗi lưu thì không áp dụng. Theo dõi bus thêm, xóa, đổi tên.
- Menu tạm dừng bắt Esc ở `_input()`, dùng `PROCESS_MODE_ALWAYS`, trả lại chế độ chuột cũ khi đóng, và tự bỏ dừng nếu bị xóa khi đang mở.
- Integrator đã xử lý yêu cầu thay đổi: autoload `Settings` ngay sau `EventBus`; `PauseMenu` trong `main.tscn`; test core `test_main_scene_escape_pauses_and_resumes_player` (Esc dừng game, Player thả chuột; Esc lần nữa chạy lại, Player bắt chuột).
- Thanh "Bước chân" sẽ hiện khi T-126 (bus `Footsteps`) được merge.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
