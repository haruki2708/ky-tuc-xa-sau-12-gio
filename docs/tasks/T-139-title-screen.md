# T-139 — Màn hình chính, cảnh báo nội dung, credits
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-139-title-screen`
- Phụ thuộc: T-116, T-128, T-132 (done).

## Mục tiêu
Game đang vào thẳng màn chơi. Để đăng itch.io cần: màn cảnh báo nội dung, màn hình chính có "Tiếp tục", và màn credits.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## API của core (integrator đã thêm)
- `App.start_game(continue_saved: bool)`: vào game, từ đầu hoặc từ checkpoint gần nhất.
- `App.has_saved_game() -> bool`: có checkpoint để tiếp tục không.
- `App.return_to_title()`: về màn hình chính (`App.TITLE_SCENE`).
- `App.quit()`: thoát sạch.

## Yêu cầu
1. **`game/ui/title/title_screen.tscn`** (đúng đường dẫn `App.TITLE_SCENE`):
   - nền tối, ảnh hành lang tầng 4 ban đêm qua filter PS1 (chụp từ game bằng `tools/capture.ps1`, để trong `game/ui/title/`), có rung nhẹ hoặc chập chờn đèn;
   - tên game: "Ký túc xá sau 12 giờ" / "The Dorm After Midnight";
   - nút: **Tiếp tục** (chỉ hiện khi `App.has_saved_game()`), **Chơi mới**, **Cài đặt** (dùng lại bảng cài đặt của menu tạm dừng), **Credits**, **Thoát**;
   - "Chơi mới" khi đang có checkpoint thì hỏi xác nhận trước khi bỏ lượt chơi cũ;
   - chuột hiện, điều khiển được bằng bàn phím (mũi tên, Enter, Esc);
   - âm thanh: tiếng ù đèn rất nhỏ (dùng file có sẵn của lane E).
2. **Cảnh báo nội dung** trước màn hình chính, chỉ hiện ở lần chạy đầu:
   - nội dung: game kinh dị, có cảnh hù đột ngột và âm thanh lớn đột ngột; có thể bật "Giảm hù dọa" trong Cài đặt;
   - hai nút: "Tiếp tục" và "Bật Giảm hù dọa rồi tiếp tục";
   - lưu `[ui] content_warning_seen = true` (key mới, integrator đã thêm vào `docs/SETTINGS.md`).
3. **Credits:** liệt kê từ các `CREDITS.md` hiện có (kit, âm thanh, font, TTS khi có), có ghi chú nội dung tạo bằng AI; cuộn được.
4. **Menu tạm dừng:** thêm nút "Về màn hình chính" (xác nhận trước, vì sẽ mất tiến độ từ checkpoint) → `App.return_to_title()`.
5. **Song ngữ:** mọi chữ qua key `UI_*`, đủ vi và en; đổi ngôn ngữ ở màn hình chính có hiệu lực ngay.
6. **Test `game/tests/ui/`:** title load được; nút Tiếp tục ẩn hoặc hiện theo `has_saved_game`; cảnh báo chỉ hiện lần đầu và lưu key; nút "Bật Giảm hù dọa" ghi `reduce_scares = true`; menu tạm dừng có nút mới. Test không được gọi `change_scene` thật: tách hành động thành hàm có thể giả lập.
7. **Ảnh:** cảnh báo, màn hình chính (vi và en), credits.

## Ghi chú cho integrator
Sau khi merge, integrator đổi `run/main_scene` sang màn hình chính và cho màn "Còn tiếp…" quay về màn hình chính.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Có ảnh ở mục 7
- [x] Handoff: cách thử bằng tay, phần chưa thử

## Handoff (agent điền)

### Đã làm
- Lane D, ngày 2026-10-03; nhánh `lane-d/T-139-title-screen`, base `origin/main` tại `7dbce51`. Commit triển khai `1ffda8a` đã push cùng sáu PNG qua Git LFS.
- Thêm đúng scene `res://ui/title/title_screen.tscn`: ảnh hành lang tầng 4 qua filter PS1, nền tối với dao động sáng nhẹ; dùng lại tiếng ù đèn của Lane E ở −12 dB trên bus Ambience. Bật Giảm hù dọa thì dừng dao động nền. Không thêm font hoặc asset bên ngoài.
- Menu có Tiếp tục theo `App.has_saved_game()`, Chơi mới, Cài đặt dùng panel hiện có, Ghi công/Credits, Thoát. Chơi mới khi có checkpoint yêu cầu xác nhận; hành động gọi API `App.start_game(bool)`/`App.quit()`.
- Cảnh báo đầu tiên có hai lựa chọn, lưu `ui/content_warning_seen = true` trước khi vào menu; lựa chọn giảm hù dọa lưu thêm `accessibility/reduce_scares = true`. Lưu lỗi thì giữ cảnh báo và hiện thông báo. Schema mới mặc định `false`, sai kiểu về mặc định. Khôi phục mặc định giữ lại trạng thái đã đọc cảnh báo vì đây là xác nhận lần đầu, không phải tùy chọn chơi.
- Pause menu có Về màn hình chính và xác nhận mất tiến độ sau checkpoint, gọi `App.return_to_title()`. Esc trong xác nhận hủy thao tác và giữ game tạm dừng. Các hộp xác nhận đặt focus ban đầu ở Hủy.
- Mũi tên/Enter điều khiển menu; Esc quay lại từ Cài đặt/Credits/xác nhận, tại menu chính đặt focus vào Thoát. Credits cuộn bằng chuột hoặc mũi tên lên/xuống; Enter/Esc quay lại. 20 key mới VI/EN, đổi ngôn ngữ có hiệu lực ngay.
- Credits tổng hợp kit/tầng 4/bóng người/gương, âm thanh, font và khai báo AI từ `art_source/CREDITS.md`, `game/audio/CREDITS.md`, `game/assets/fonts/CREDITS.md`. Nguồn ảnh, font, hum và cách chụp được ghi ở `game/ui/title/CREDITS.md`.

### Kiểm chứng và ảnh
- `pwsh tools/test.ps1`: **RESULT: 226 passed, 0 failed**.
- `pwsh tools/check.ps1`: **RESULT: check 0 error(s)**.
- Thêm tám test title/pause: cảnh báo lần đầu và lưu trước signal, lựa chọn giảm hù dọa, lỗi ghi file, hiện/ẩn Tiếp tục, Chơi mới có/không checkpoint, hủy/xác nhận, bàn phím, đổi ngôn ngữ trực tiếp, cuộn credits và về title. Test dùng API giả lập/hàm có thể override, không gọi `change_scene` thật; fixture sao lưu/khôi phục cài đặt. Test headless cố định canvas title 1920×1080 vì cửa sổ headless mặc định vuông.
- Test/check cuối không có lỗi engine/parse; còn cảnh báo UID texture trong cache model cũ, Godot dùng đường dẫn thay thế. Không sửa hoặc commit file ngoài phạm vi.
- Ảnh nền tạo bằng `pwsh tools/capture.ps1 -Scene res://ui/title/background_test.tscn -Frames 5 -Resolution 1920x1080 -Out build/T-139/background`: **RESULT: capture PASS (5 gameplay frames)**. Dùng user data riêng để filter lấy mặc định 1.0; giữ ảnh nguyên từ Godot.
- Đã render và xem ảnh 1920×1080: [cảnh báo](../../game/ui/title/previews/warning.png), [title VI](../../game/ui/title/previews/vi.png), [title EN](../../game/ui/title/previews/en.png), [credits đầu](../../game/ui/title/previews/credits.png), [credits cuối và khai báo AI](../../game/ui/title/previews/credits_end.png).
- Scene `title_test.tscn` phục vụ ảnh: API giả lập báo có checkpoint nên ảnh có nút Tiếp tục, không tạo checkpoint thật. Chạy Godot với `--path game res://ui/title/title_test.tscn --write-movie <thư mục>/frame.png --fixed-fps 30 -- --title-capture=<màn> --quit-after-frames=5`; `<màn>` là `warning`, `vi`, `en`, `credits`, `credits_end`. Thao tác chọn màn/ngôn ngữ phục vụ chụp không lưu vào cài đặt.

### Cách thử bằng tay / phần chưa thử
1. Mở **`title_screen.tscn`** bằng F6 với user data thử riêng chưa có `content_warning_seen`; kiểm tra cả hai lựa chọn cảnh báo qua hai bộ dữ liệu thử. Mở lại phải vào menu trực tiếp, lựa chọn giảm hù dọa phải được giữ trong Cài đặt.
2. Kiểm tra mũi tên/Enter/Esc và chuột, đổi VI/EN trong Cài đặt rồi quay lại. Mở Credits, cuộn đến khai báo AI, Enter/Esc quay lại.
3. Không có checkpoint thì Tiếp tục ẩn; Chơi mới vào đầu game. Có checkpoint thì Tiếp tục gọi tiếp tục; Chơi mới phải hỏi, Hủy/Esc không bỏ lượt chơi.
4. Trong game: Esc → Về màn hình chính → Hủy/Esc giữ tạm dừng; Xác nhận về title. Thoát phải đi qua `App.quit()`.
- Đã kiểm tra input tự động và ảnh render. **Chưa chơi thử thủ công vòng title → gameplay → checkpoint thật → title; chưa nghe đánh giá độ nhỏ của hum trên thiết bị thực; chưa export/package nhánh này.** Scene ảnh dùng API giả lập, không dùng nó để kiểm tra chuyển scene thật.
- Không còn checklist chưa đạt hoặc blocker phía Lane D. Chưa có nguồn TTS T-137 trong base; chưa ghi công cho asset chưa tồn tại.

### Yêu cầu thay đổi ngoài phạm vi
- **Integrator / T-141:** đổi `project.godot` mục `run/main_scene` sang `res://ui/title/title_screen.tscn`; nối màn “Còn tiếp…” về `App.return_to_title()`. Lane D không sửa cấu hình project/core/main.
- Sau khi tích hợp T-133/T-137, bổ sung credits nhạc/TTS từ nguồn đã xác nhận của Lane E và kiểm tra vòng chuyển scene/checkpoint thật, âm thanh, bản export. Không cần signal/autoload/input action mới; API App và key trong hợp đồng cài đặt đã có.
