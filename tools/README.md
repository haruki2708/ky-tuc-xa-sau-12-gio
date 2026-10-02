# Công cụ QA (chạy từ gốc repo bằng PowerShell 7)

Godot được tìm qua `godot-path.ps1`; có thể đặt biến môi trường `GODOT` tới bản console 4.7.2. Không cần plugin.

- `pwsh tools/test.ps1 [-Filter tools]`: import và chạy test headless; xem dòng `RESULT`.
- `pwsh tools/check.ps1`: import, parse từng `.gd` bằng `--check-only`, kiểm tra file nguồn lớn hơn 10 MB và bản dịch vi/en trống. Bỏ qua file được Git ignore (build/cache), tính cả file nguồn chưa track. Exit 0 khi không có lỗi.
- `pwsh tools/export.ps1 [-Debug]`: xuất Windows; mặc định release.
- `pwsh tools/package.ps1`: gọi export release, nén EXE có PCK nhúng và README song ngữ vào `build/dist/KyTucXa-<version>-<hash>-win64.zip`. Version lấy từ `application/config/version`; hash là HEAD. Nên commit trước khi tạo bản phát hành; workspace đang sửa vẫn được export. README lấy từ `tools/package_readme.txt`. Công cụ in dung lượng ZIP, tự giải nén vào thư mục riêng rồi chạy EXE 60 frame (timeout 60 giây). Chỉ in `RESULT: package PASS` khi exit 0 và log không có ERROR; lỗi trả exit 1 và `RESULT: package FAIL`. Stage và bản giải nén được dọn trong finally, log kiểm chứng giữ cạnh ZIP. Lệnh này mở tiến trình game với cửa sổ ẩn.
- `pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Frames 60 -Fps 30 -Resolution 1280x720 -Out build/captures/main -KeepEvery 10`: chạy Godot có cửa sổ, lưu PNG vào thư mục con riêng cho mỗi lần chạy; giữ frame thứ 10, 20… và luôn giữ ảnh cuối. Dòng cuối in đường dẫn ảnh cuối. WAV do Movie Maker tạo được giữ lại.

## Autoplay

Godot `--check-only --script` không khởi tạo tên singleton autoload. Nếu gặp lỗi `Identifier not found`, check chạy lại file đó trong scene probe với autoload của project; lỗi parse/compile thực vẫn khiến check thất bại.

Project đã có autoload `Autoplay` sau `GameInput`. Khi không có user arg, script không phát input. Chạy main scene trực tiếp:

```powershell
pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Autoplay res://tests/tools/autoplay_example.json -Frames 120 -Out build/captures/autoplay
```

Dùng `-Autoplay` với scene game bình thường (không dùng scene test để tránh hai bộ phát). Đường dẫn JSON có thể là `res://...` hoặc đường dẫn filesystem tính từ gốc repo. Capture báo lỗi nếu không thấy autoplay được nạp.

JSON là mảng event theo frame tăng dần (cho phép cùng frame), frame bắt đầu từ 0. Event chứa `press`/`release` với action đã đăng ký, hoặc `mouse_dx`/`mouse_dy` dạng số. Ví dụ ở `game/tests/tools/autoplay_example.json`. Chuột giả đi qua `Viewport.push_input`; action dùng `Input.action_press/release`. Script nhả các action còn giữ khi dừng và thoát ở frame cuối + 30. `-Frames` là giới hạn capture, có thể kết thúc sớm hơn autoplay; chọn đủ lớn. Frame tính theo `_process`, dùng fixed FPS khi capture để phát lại ổn định.

Smoke test duyệt đệ quy toàn bộ `res://scenes/*.tscn`, load, instance và cho chạy hai frame. Luôn kiểm tra thêm log Godot: test.ps1 chuyển runtime engine error hoặc thiếu dòng RESULT thành exit 1, giữ nguyên cách gọi cũ.
`capture.ps1` dùng snapshot riêng và override viewport để PNG đúng `-Resolution`; không sửa cấu hình project gốc. Mặc định snapshot được xóa trong finally kể cả khi capture lỗi; thêm `-KeepSnapshot` để giữ phục vụ chẩn đoán. PNG và WAV vẫn giữ. Output không được đặt trong `game/` để tránh sao chép đệ quy.

## Kiểm chứng T-124

- `pwsh tools/verify-capture.ps1`: năm lần liên tiếp trên main, kịch bản `autoplay_main.json` có đi/chạy/quay chuột; frame cuối 105 nên mong đợi 136 PNG mỗi lần. Dùng KeepEvery=1, Frames=200 và kiểm tra không còn thư mục snapshot. Chạy với cửa sổ thật; tránh thao tác chuột/phím trong lúc đo. Đây là phép kiểm tra số frame, không bảo đảm ảnh giống từng pixel khi có input thật.
- `pwsh tools/test.ps1 -Filter export_filters`: bảo vệ các mẫu loại trừ Windows Desktop. Giữ `scripts/debug/` vì project có autoload Autoplay; loại thư mục này đã được xác minh gây lỗi khởi động EXE. Các scene test/showcase và script import editor bị loại khỏi build. `project.godot` không bị sửa.
- ZIP dùng hash HEAD, nhưng chứa nội dung workspace hiện tại. Commit trước khi tạo bản phát hành. Log cạnh ZIP mô tả lần kiểm chứng gần nhất; artifact FAIL không được coi là bản đã xác minh.
### Lỗi shutdown đang theo dõi

Trên nền main `7552c07`, main có thể báo `ERROR: ... resources still in use at exit` khi thoát (tài nguyên Ogg trong log verbose). Capture/package vẫn trả FAIL dù engine exit 0; xem Handoff T-124 để tái hiện và theo dõi yêu cầu integrator/Lane E. Không coi một lần thoát sạch là bằng chứng lỗi không ổn định đã được sửa.

Để giữ dữ liệu chẩn đoán: `pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Frames 2 -KeepSnapshot -Out build/captures/debug`. Đã xác minh tùy chọn giữ snapshot và PNG ngay cả khi Godot báo lỗi shutdown; mặc định không có tùy chọn này thì snapshot được dọn trong finally.
