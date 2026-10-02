# Công cụ QA (chạy từ gốc repo bằng PowerShell 7)

Godot được tìm qua `godot-path.ps1`; có thể đặt biến môi trường `GODOT` tới bản console 4.7.2. Không cần plugin.

- `pwsh tools/test.ps1 [-Filter tools]`: import và chạy test headless; xem dòng `RESULT`.
- `pwsh tools/check.ps1`: import, parse từng `.gd` bằng `--check-only`, kiểm tra file nguồn lớn hơn 10 MB và bản dịch vi/en trống. Bỏ qua file được Git ignore (build/cache), tính cả file nguồn chưa track. Exit 0 khi không có lỗi.
- `pwsh tools/export.ps1 [-Debug]`: xuất Windows; mặc định release.
- `pwsh tools/package.ps1`: gọi export release, nén EXE có PCK nhúng và README song ngữ vào `build/dist/KyTucXa-<version>-<hash>-win64.zip`. Version lấy từ `application/config/version`; hash là HEAD. Nên commit trước khi tạo bản phát hành; workspace đang sửa vẫn được export. Thư mục stage giữ lại để kiểm tra.
- `pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Frames 60 -Fps 30 -Resolution 1280x720 -Out build/captures/main -KeepEvery 10`: chạy Godot có cửa sổ, lưu PNG vào thư mục con riêng cho mỗi lần chạy; giữ frame thứ 10, 20… và luôn giữ ảnh cuối. Dòng cuối in đường dẫn ảnh cuối. WAV do Movie Maker tạo được giữ lại.

## Autoplay

Godot `--check-only --script` không khởi tạo tên singleton autoload. Nếu gặp lỗi `Identifier not found`, check chạy lại file đó trong scene probe với autoload của project; lỗi parse/compile thực vẫn khiến check thất bại.

Integrator cần thêm autoload `Autoplay="*res://scripts/debug/autoplay.gd"` sau `GameInput`. Khi không có user arg, script không làm gì. Trước khi tích hợp autoload, chạy scene test có gắn script thủ công:

```powershell
pwsh tools/capture.ps1 -Scene res://tests/tools/autoplay_scene.tscn -Autoplay res://tests/tools/autoplay_example.json -Frames 120 -Out build/captures/autoplay
```

Sau khi thêm autoload, dùng `-Autoplay` với scene game bình thường (không dùng scene test để tránh hai bộ phát). Đường dẫn JSON có thể là `res://...` hoặc đường dẫn filesystem tính từ gốc repo. Capture báo lỗi nếu không thấy autoplay được nạp.

JSON là mảng event theo frame tăng dần (cho phép cùng frame), frame bắt đầu từ 0. Event chứa `press`/`release` với action đã đăng ký, hoặc `mouse_dx`/`mouse_dy` dạng số. Ví dụ ở `game/tests/tools/autoplay_example.json`. Chuột giả đi qua `Viewport.push_input`; action dùng `Input.action_press/release`. Script nhả các action còn giữ khi dừng và thoát ở frame cuối + 30. `-Frames` là giới hạn capture, có thể kết thúc sớm hơn autoplay; chọn đủ lớn. Frame tính theo `_process`, dùng fixed FPS khi capture để phát lại ổn định.

Smoke test duyệt đệ quy toàn bộ `res://scenes/*.tscn`, load, instance và cho chạy hai frame. Luôn kiểm tra thêm log Godot: test.ps1 chuyển runtime engine error hoặc thiếu dòng RESULT thành exit 1, giữ nguyên cách gọi cũ.
`capture.ps1` giữ snapshot project trong thư mục output và dùng override viewport trên snapshot để PNG đúng `-Resolution`; không sửa cấu hình project gốc. Snapshot gồm cache import nên có thể chiếm thêm dung lượng.
