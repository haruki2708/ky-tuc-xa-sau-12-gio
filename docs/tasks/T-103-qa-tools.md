# T-103 — Công cụ QA: chụp hình, đóng gói, kiểm tra lỗi script, phát lại input
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-103-qa-tools`
- Phụ thuộc: P0 (xong)
- Loại: task thử tuần đầu

## Mục tiêu
Cho mọi agent và integrator công cụ để **tự kiểm tra game mà không cần người chơi**: chụp khung hình, phát lại chuỗi phím, bắt lỗi parse script, và đóng gói bản build cho itch.io.

## Được phép sửa
`tools/` (trừ `tools/godot-path.ps1`; không đổi cách gọi `test.ps1` và `export.ps1` hiện có), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **`tools/capture.ps1`:**
   - Tham số: `-Scene res://...`, `-Frames 60`, `-Fps 30`, `-Resolution 1280x720`, `-Out build/captures/<tên>`, `-Autoplay <file json>` (tùy chọn), `-KeepEvery 10`.
   - Chạy Godot có cửa sổ với `--write-movie`, mỗi `KeepEvery` frame giữ lại một ảnh PNG, xóa phần còn lại.
   - In ra đường dẫn ảnh cuối cùng.
2. **Phát lại input (`game/scripts/debug/autoplay.gd`):**
   - Đọc file JSON được truyền qua user arg `--autoplay=res://...json`. Định dạng ví dụ:
     ```
     [{"frame":0,"press":"move_forward"},{"frame":60,"release":"move_forward"},{"frame":61,"mouse_dx":200},{"frame":90,"press":"interact"}, {"frame":91,"release":"interact"}]
     ```
   - Dùng `Input.action_press` / `Input.action_release` và tạo `InputEventMouseMotion` giả.
   - Thoát sau frame cuối cộng 30 frame.
   - Script này cần được nạp như autoload. **Không tự sửa `project.godot`.** Ghi "Yêu cầu thay đổi: thêm autoload `Autoplay`" vào Handoff, kèm đường dẫn.
   - Test được bằng cách gắn thủ công vào scene test.
3. **`tools/check.ps1`:**
   - Dùng `--check-only` để parse mọi file `.gd`, báo lỗi theo từng file.
   - Báo file lớn hơn 10 MB trong repo.
   - Báo key dịch trong `game/localization/strings.csv` thiếu cột `vi` hoặc `en`.
   - Có lỗi thì exit code khác 0.
4. **`tools/package.ps1`:**
   - Gọi export bản release.
   - Nén thành `build/dist/KyTucXa-<config/version>-<git short hash>-win64.zip`, kèm `README.txt` song ngữ (cách chạy, phím điều khiển).
5. **Smoke test `game/tests/smoke/test_smoke_scenes.gd`:** mọi file `.tscn` dưới `res://scenes/` đều load và instance được mà không có lỗi.
6. **`tools/README.md`:** hướng dẫn ngắn cho từng script.

## Checklist hoàn thành
- [x] `pwsh tools/check.ps1` và `pwsh tools/test.ps1` PASS trên `main` hiện tại
- [x] `capture.ps1 -Scene res://scenes/main/main.tscn` ra được ảnh
- [x] `package.ps1` ra được file zip; giải nén ra chạy được
- [x] Autoplay có test hoặc ví dụ chứng minh chạy được
- [x] Mục Handoff đã điền, kèm "Yêu cầu thay đổi"

## Handoff (agent điền)

### Kết quả (2026-10-02)
- Hoàn tất phần triển khai Lane C trong commit `681a2e2`, đã push `origin/lane-c/T-103-qa-tools`. Nhánh dựa trên `origin/main` tại `9e8fd6b`; test chạy trên nhánh task với nền main này, không sửa hoặc push main.
- Thêm `capture.ps1`, `check.ps1`, `package.ps1`, hướng dẫn `tools/README.md`, autoplay có kiểm tra JSON, scene/ví dụ autoplay và smoke test đệ quy các scene.
- `test.ps1` giữ nguyên giao diện lệnh; bổ sung exit 1 khi log có lỗi engine/script hoặc thiếu RESULT thành công, tránh smoke test báo xanh giả.
- Đã commit các `.uid` do Godot tạo. Không thêm plugin, không cài phần mềm, không truy cập bản tích hợp.

### Kiểm chứng và cách chạy lại
- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.
- `pwsh tools/test.ps1`: `RESULT: 9 passed, 0 failed` (5 test core, 1 smoke, 3 autoplay). Kiểm tra press/release, chuột giả qua input viewport, thời điểm kết thúc và JSON không hợp lệ.
- `pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn`: `RESULT: capture PASS (60 frames rendered)`. PNG 1280x720 đã mở xem, có hành lang greybox; KeepEvery=10 giữ đúng 6 ảnh (index 9,19,29,39,49,59).
- Ảnh cuối: `build/captures/main/63bf39579dcd4acfa18907fae92c7306/frame00000059.png`.
- `pwsh tools/capture.ps1 -Scene res://tests/tools/autoplay_scene.tscn -Autoplay res://tests/tools/autoplay_example.json -Frames 120 -Out build/captures/autoplay`: nạp 5 event, tự dừng frame 36 (37 ảnh trước lọc), đúng frame cuối 6 + 30. Đây là scene gắn script thủ công, chưa phải autoload trong main.
- `pwsh tools/package.ps1`: `RESULT: package PASS`; tạo `build/dist/KyTucXa-0.0.1-681a2e2-win64.zip`, gồm EXE với PCK nhúng và README song ngữ.
- Đã giải nén ZIP vào `build/dist/verify-681a2e2`, chạy EXE với working directory riêng, `--windowed --quit-after 60`: `RESULT: extracted release PASS (60 frames, exit 0)`. Log Vulkan/RTX 3050 không có ERROR. Chưa chơi thử gameplay (P0 chỉ có camera cố định).
- Artifact build/capture được Git ignore, có trên máy Lane C; tái tạo bằng các lệnh trên.

### Quyết định kỹ thuật và giới hạn
- `--check-only --script` của Godot không nhận singleton autoload như EventBus. Check vẫn chạy tùy chọn này với mọi `.gd`; nếu lỗi thiếu identifier thì load lại script trong scene probe có autoload. Lỗi parse/compile thực vẫn khiến exit khác 0.
- `--resolution` chỉ đổi cửa sổ; Movie Maker dùng viewport trong project. Capture tạo snapshot project/cache riêng dưới output rồi đặt viewport bằng override trên snapshot, không sửa `game/project.godot`. Snapshot được giữ lại, có thể chiếm thêm dung lượng.
- Chuột giả dùng `Viewport.push_input(event, true)` để nhận đúng số pixel viewport, không bị hệ số stretch thay đổi. Frame autoplay là process frame; dùng fixed FPS khi capture.
- Check kích thước áp dụng file nguồn tracked/untracked không bị Git ignore; không tính build/cache. Package dùng preset hiện tại có embedded PCK.
- Sandbox ban đầu chặn GitHub và Godot ghi log/settings tại D:\Tools\Godot. Các lệnh cần thiết đã chạy lại với quyền ngoài sandbox; hiện không còn blocker môi trường.

### Còn dở / checklist chưa đạt
- Không còn mục checklist chưa đạt trong phạm vi Lane C. Tích hợp autoload vào main chờ integrator theo yêu cầu dưới đây.
- Không có câu hỏi về luật chơi hoặc cốt truyện; chưa tự suy đoán thiết kế.

### Yêu cầu thay đổi ngoài phạm vi
- **Yêu cầu thay đổi: thêm autoload `Autoplay`** trong `game/project.godot`, đường dẫn `res://scripts/debug/autoplay.gd`, sau `GameInput` để các action đã được đăng ký. Dòng đề xuất: `Autoplay="*res://scripts/debug/autoplay.gd"`.
- Khi đã thêm autoload, chạy capture với scene game bình thường; không dùng `autoplay_scene.tscn` có script thủ công để tránh phát hai lần. Khi không có `--autoplay=...`, autoload không phát input.
- Không có yêu cầu thay đổi ngoài phạm vi khác.
