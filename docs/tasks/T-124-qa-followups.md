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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `pwsh tools/package.ps1` ra `RESULT: package PASS`; dung lượng zip ghi trong Handoff, so với trước khi lọc
- [x] `capture.ps1` không còn để lại bản sao project
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Kết quả phiên 2026-10-02
- Commit triển khai `cd3deab`, đã push `origin/lane-c/T-124-qa-followups`; nền `origin/main` là `7552c07`. Chỉ sửa các file được phép cùng checklist/Handoff card này.
- Capture dọn snapshot bằng finally, cả khi Godot báo lỗi; có `-KeepSnapshot`. Có chặn output trong game/ để tránh sao chép đệ quy và kiểm tra đường dẫn trước xóa. PNG/WAV giữ nguyên. Nhánh mặc định đã kiểm chứng thực tế; chưa chạy riêng nhánh `-KeepSnapshot`.
- README song ngữ chuyển sang `tools/package_readme.txt`, mô tả đúng hiện trạng đi lại/HUD/âm thanh, chưa có nội dung cốt truyện/luật. Phím lấy từ hiện trạng main (Esc bắt/thả chuột).
- Windows export loại toàn bộ mẫu bắt buộc trừ debug theo ngoại lệ của card. Test mới bảo vệ các mẫu loại trừ và autoload cần giữ.
- Package tự giải nén ZIP, chạy EXE 60 frame, kiểm tra exit code + log/stdout/stderr, timeout 60 giây, in byte/MiB và PASS/FAIL. Stage và bản giải nén tự dọn; log giữ cạnh ZIP. Không bỏ qua ERROR dù EXE exit 0.

### Kiểm chứng
- `pwsh tools/test.ps1`: **`RESULT: 84 passed, 0 failed`**, exit 0 (83 test có sẵn + 1 test export filters).
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**; log `build/T-124-check.log`.
- `pwsh tools/package.ps1`: **`RESULT: package FAIL`**. ZIP vẫn được tạo nhưng KHÔNG coi là bản phát hành đã xác minh.
- ZIP trước lọc/cập nhật README: `build/dist/T-124-before-filter.zip`, **40.108.631 byte**. ZIP sau: `build/dist/KyTucXa-0.0.1-7552c07-win64.zip`, **40.027.541 byte** (38,17 MiB), giảm **81.090 byte**, khoảng **0,202%**. Được tạo trước commit triển khai nên tên mang hash nền; nội dung là workspace T-124 đã sửa.
- Log package: `build/T-124-package-filtered.log` và các file `.verify.log`, `.stdout.log`, `.stderr.log` cạnh ZIP. EXE chạy/thoát với exit 0 nhưng stderr có `ERROR: 2 resources still in use at exit` và cảnh báo 11 ObjectDB instances.
- Khi thử loại cả `scripts/debug/*`, EXE báo không tìm thấy `res://scripts/debug/autoplay.gd` và không khởi tạo được autoload; package trả FAIL. Bằng chứng: `build/T-124-exclude-debug.log`. Vì vậy giữ debug, không sửa project.godot, đúng ngoại lệ card.

### Năm lần autoplay liên tiếp
Lệnh tái hiện: `pwsh tools/verify-capture.ps1`. Script chạy main.tscn với `autoplay_main.json` (đi/chạy/quay chuột; frame cuối 105), Frames=200, FPS=30, Resolution=1280x720, KeepEvery=1.

| Lượt | Số PNG | Còn snapshot | Exit capture |
|---|---:|---|---:|
| 1 | 136 | Không | 1 |
| 2 | 136 | Không | 1 |
| 3 | 136 | Không | 1 |
| 4 | 136 | Không | 1 |
| 5 | 136 | Không | 1 |

- Không tái hiện lệch frame: cả năm đúng 105 + 30 + 1. Không thay thuật toán đếm frame autoplay khi chưa có bằng chứng lỗi.
- Cả năm báo lỗi resource khi shutdown nên tổng kết trung thực **`RESULT: autoplay capture FAIL (inspect run logs)`**; không chỉ dựa số ảnh để kết luận PASS.
- Log/ảnh: `build/captures/T-124-ff88c43de5d241a4a5b5a992c7897cea/run-1.log` đến `run-5.log` và thư mục run tương ứng. Một lượt thăm dò trước chuỗi năm cũng có 136 ảnh và lỗi tương tự, không tính vào bảng.

### Blocked / yêu cầu thay đổi ngoài phạm vi
**Blocked: chưa đạt checklist package PASS vì lỗi giải phóng tài nguyên âm thanh khi thoát main, tái hiện không ổn định cả trước khi lọc.** Không sửa code âm thanh/core ngoài phạm vi Lane C; không che log hoặc lặp tới khi xanh để đánh dấu đạt.

**Yêu cầu thay đổi:** integrator/Lane E điều tra lifecycle/shutdown Ogg của main trong `game/scripts/audio/` và cấu hình scene do core sở hữu nếu cần. Chưa kết luận nguyên nhân gốc; đây là yêu cầu điều tra và sửa lỗi, không khẳng định file cụ thể có bug.

Bằng chứng đối chứng:
- EXE baseline lấy từ ZIP trước mọi thay đổi, giải nén ở `build/dist/T-124-baseline-probe`, chạy `--windowed --quit-after 60` với cùng cách thu log của package: exit 0 nhưng `ERROR: 1 resources still in use at exit`. Log: `build/T-124-baseline-controlled.stderr`.
- EXE sau lọc chạy cùng điều kiện trong lượt đối chứng kế tiếp lại không ERROR (`build/T-124-filtered-controlled.stderr`), trong khi lượt package trước đó có lỗi. Lượt baseline có `--verbose` cũng chưa tái hiện. Vì vậy lỗi shutdown không ổn định; chưa có bằng chứng nó do bộ lọc mới gây ra.
- Chạy main headless/autoplay với `--verbose` chỉ ra OggPacketSequence, AudioStreamOggVorbis và playback còn giữ tham chiếu, gồm clip dép và ambience: `build/T-124-autoplay-verbose.log`. Lượt headless này khác điều kiện Movie Maker, chỉ dùng hỗ trợ điều tra tài nguyên.
- Sau khi sửa bên sở hữu: chạy lại `pwsh tools/test.ps1`, `pwsh tools/check.ps1`, `pwsh tools/package.ps1`, `pwsh tools/verify-capture.ps1`; chỉ đánh dấu checklist package khi lần kiểm chứng thực tế sạch lỗi.
- Các log/ZIP/ảnh là artifact local trong build/ (Git ignore); lệnh và bằng chứng tóm tắt đã ghi ở đây để tái hiện. Chưa chơi thử gameplay thủ công.
- Checkout đầu phiên bị ngắt do sandbox chặn Git LFS; đã lưu trạng thái dở vào stash `Recovery of interrupted T-124 LFS checkout`, rồi checkout lại thành công. Stash bảo toàn này vẫn giữ; working tree trước checkout sạch. Không có blocker Git/mạng sau khi cấp quyền cần thiết.
