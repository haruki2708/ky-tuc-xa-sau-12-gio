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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Đã làm (2026-10-02, Lane D)
- Commit triển khai `100b50f` — `T-128: Route pause quit through App and add floor signs`; đã push lên `origin/lane-d/T-128-menu-quit-signs`, base `origin/main` tại `5d87982`.
- Nút Thoát tìm `/root/App` và gọi `quit()` khi có; nếu không có thì dùng `_quit_tree()` gọi `get_tree().quit()`. Hàm riêng cho đường cũ cho phép test thay hành vi thoát mà không tắt runner.
- Thêm đủ 11 key đúng câu chữ VI/EN trong card: `SIGN_ROOM_401`…`SIGN_ROOM_408`, `SIGN_GATE_LOCKED`, `SIGN_WASHROOM`, `SIGN_DUTY_DESK`. Không sửa key cũ, không gắn chữ vào scene tầng.
- Thêm hai test bấm nút Thoát: App giả nhận đúng một lần gọi khi game vẫn pause, không gọi đường thoát trực tiếp; khi thiếu App thì gọi đường cũ. Test giữ nguyên instance App thật, tạm đổi tên để thay lookup rồi khôi phục; kế thừa fixture sao lưu/khôi phục cấu hình và trạng thái game.

### Kiểm chứng và cách kiểm tra
- `pwsh tools/test.ps1 -Filter ui`: **`RESULT: 31 passed, 0 failed`**.
- `pwsh tools/test.ps1`: **`RESULT: 120 passed, 0 failed`**, exit code 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0.
- Log cục bộ trong `build/T-128/test.log` và `build/T-128/check.log` (không commit). Test CSV hiện có kiểm tra tất cả key đủ VI/EN, không rỗng và không trùng. Không có lỗi engine/script trong lượt cuối; các cảnh báo dữ liệu không hợp lệ thuộc test core sẵn có.
- `git diff --cached --check` sạch trước commit. Chỉ sửa `game/scripts/ui/pause_menu.gd`, thêm key CSV, test/UID trong `game/tests/ui/` và checklist/Handoff của card này.
- Có thể kiểm tra thủ công bằng F6 scene chơi hoặc game chính, Esc → Thoát game và xem log lúc đóng. **Chưa chạy phiên thoát game thật bằng thao tác thủ công trong task này**; đường gọi được kiểm tra bằng App giả và hàm thoát thay thế đúng yêu cầu card. Logic dừng âm/chờ 0,25 giây thuộc App sẵn có, không sửa ở T-128.

### Còn dở / yêu cầu thay đổi ngoài phạm vi
- Không còn mục checklist chưa đạt, không có yêu cầu thay đổi ngoài phạm vi mới. Lane B dùng các key đã thêm để in chữ lên biển ở task sau theo phân công trong card.
- Không phát sinh câu hỏi về luật chơi hoặc cốt truyện; không sửa file của Lane C, core, main hay scene tầng.

### Trở ngại
- Không còn bị chặn. Sandbox gặp lỗi khởi chạy Windows `1223` và chặn mạng/quyền ghi `user://`; các lệnh cần thiết đã chạy thành công qua cấp quyền ngoài sandbox, trong `D:\GAME_WORK\lane-d`.
