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
- [ ] `pwsh tools/check.ps1` và `pwsh tools/test.ps1` PASS trên `main` hiện tại
- [ ] `capture.ps1 -Scene res://scenes/main/main.tscn` ra được ảnh
- [ ] `package.ps1` ra được file zip; giải nén ra chạy được
- [ ] Autoplay có test hoặc ví dụ chứng minh chạy được
- [ ] Mục Handoff đã điền, kèm "Yêu cầu thay đổi"

## Handoff (agent điền)
