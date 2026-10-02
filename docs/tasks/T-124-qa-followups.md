# T-124 — Dọn công cụ QA và lọc file khi xuất bản build
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-124-qa-followups`
- Phụ thuộc: T-103 (done). Đọc mục **Review** trong `docs/tasks/T-103-qa-tools.md` và `docs/tasks/T-121-kit-update.md`.
- **Riêng task này** lane C được sửa thêm `game/export_presets.cfg` (bình thường thuộc integrator).

## Mục tiêu
Dọn các việc tồn từ review T-103 và T-121, để bản build gửi người chơi thử gọn, đúng nội dung, và công cụ không làm đầy ổ đĩa.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`; không đổi cách gọi `test.ps1` và `export.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`, `game/export_presets.cfg`

## Yêu cầu
1. **`capture.ps1`:** mặc định xóa bản sao project sau khi chụp xong. Thêm `-KeepSnapshot` nếu muốn giữ. Ảnh chụp vẫn giữ như cũ.
2. **README trong bản đóng gói:**
   - Đưa nội dung ra file riêng `tools/package_readme.txt`, song ngữ, để dễ cập nhật.
   - Nội dung đúng hiện trạng: đi lại được, có HUD, âm thanh; chưa có cốt truyện và luật chơi. Phím: WASD, Shift, chuột, E hoặc chuột trái, Esc.
3. **Lọc file khi xuất bản build** (`export_presets.cfg`, preset Windows Desktop):
   - Loại khỏi bản phát hành: `tests/*`, `audio/test/*`, `ui/hud/hud_test*`, `ui/hud/previews/*`, `scenes/player/player_test*`, `scenes/levels/kit_showcase*`, `assets/models/kit/kit_import.gd`, `scripts/debug/*`.
   - Autoload `Autoplay` trỏ tới `scripts/debug/autoplay.gd`. Nếu loại `scripts/debug/*` làm game báo lỗi khi khởi động bản build, **không loại thư mục đó**; ghi lý do vào Handoff.
   - Script và scene của bản build vẫn phải chạy đủ: `package.ps1` khởi chạy exe đã giải nén khoảng 60 frame, không có `ERROR` trong log.
4. **`package.ps1`:**
   - Sau khi đóng gói, tự giải nén ra thư mục tạm, chạy thử như mục 3, rồi in `RESULT: package PASS` hoặc `FAIL`.
   - In dung lượng file zip.
5. **Theo dõi lệch khung hình autoplay (Review T-103):** chạy `capture.ps1` với autoplay trên `main.tscn` 5 lần liên tiếp và ghi số ảnh mỗi lần vào Handoff. Nếu có lần lệch, tìm nguyên nhân và sửa nếu nằm trong phạm vi lane C.
6. **Test** (`game/tests/tools/` hoặc script PowerShell kèm theo): kiểm tra `export_presets.cfg` có các mẫu loại trừ ở mục 3.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `pwsh tools/package.ps1` ra `RESULT: package PASS`; dung lượng zip ghi trong Handoff, so với trước khi lọc
- [ ] `capture.ps1` không còn để lại bản sao project
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
