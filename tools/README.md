# Công cụ QA (chạy từ gốc repo bằng PowerShell 7)

Godot được tìm qua `godot-path.ps1`; có thể đặt biến môi trường `GODOT` tới bản console 4.7.2. Không cần plugin.

- `pwsh tools/test.ps1 [-Filter tools]`: import và chạy test headless; xem dòng `RESULT`.
- `pwsh tools/check.ps1`: import, parse từng `.gd` bằng `--check-only`, kiểm tra file nguồn lớn hơn 10 MB và bản dịch vi/en trống. Bỏ qua file được Git ignore (build/cache), tính cả file nguồn chưa track. Exit 0 khi không có lỗi.
- `pwsh tools/export.ps1 [-Debug]`: xuất Windows; mặc định release.
- `pwsh tools/package.ps1`: gọi export release, nén EXE có PCK nhúng và README song ngữ vào `build/dist/KyTucXa-<version>-<hash>-win64.zip`. Version lấy từ `application/config/version`; hash là HEAD. Nên commit trước khi tạo bản phát hành; workspace đang sửa vẫn được export. README lấy từ `tools/package_readme.txt`. Công cụ in dung lượng ZIP, tự giải nén vào thư mục riêng rồi chạy EXE 60 frame (timeout 60 giây). Chỉ in `RESULT: package PASS` khi exit 0 và log không có ERROR; lỗi trả exit 1 và `RESULT: package FAIL`. Stage và bản giải nén được dọn trong finally, log kiểm chứng giữ cạnh ZIP. Lệnh này mở tiến trình game với cửa sổ ẩn.
- `pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Frames 60 -Fps 30 -Resolution 1280x720 -Out build/captures/main -KeepEvery 10`: chạy Godot có cửa sổ, lưu PNG vào thư mục con riêng cho mỗi lần chạy; giữ frame thứ 10, 20… và luôn giữ ảnh cuối. Dòng cuối in đường dẫn ảnh cuối. WAV do Movie Maker tạo được giữ lại.

## Tự chơi cả demo

Chạy `pwsh tools/playthrough.ps1 -Scenario all` để kiểm tra hai luồng `correct` và `deviant`; chọn riêng bằng `-Scenario correct` hoặc `-Scenario deviant`. Bot instance main, tương tác qua API thật, dịch chuyển/quay người chơi và trả lời điểm danh bằng InputEventAction. Không tự ghi cờ story hoặc giải quyết luật. Đây là kiểm tra luồng truyện, không thay thế kiểm tra điều khiển và va chạm bằng tay.

Mặc định headless, `-TimeScale 0.05` chỉ tăng tốc StoryDirector; `-SegmentTimeout 45` giới hạn giây thực cho mỗi đoạn. `-Capture` chạy có cửa sổ và lưu PNG ở frame render kế tiếp của mỗi mốc. Log và ảnh nằm trong `build/playthrough/<uuid>/<scenario>/`; APPDATA riêng được dọn sau chạy. Launcher trả exit 1 khi bot thất bại, quá giờ, engine báo ERROR hoặc thiếu dòng PASS; dòng tổng là `RESULT: playthrough N passed, M failed`.

`correct` yêu cầu ending 1, độ lệch 0 và đủ sáu mốc seg1–seg5/end. `deviant` giữ đúng chuỗi hành động trong card T-115 và yêu cầu ending 2. Với dữ liệu luật hiện tại, để đèn (+1), mở cửa (+2), quay lại (+2) đã chạm ngưỡng thua 5 ở seg3: đây là FAIL được phát hiện, không bỏ qua hoặc ép ending. Xem Handoff T-115 để giải quyết xung đột yêu cầu trước khi dùng cả hai luồng làm cổng merge.

## Autoplay theo frame

Godot `--check-only --script` không khởi tạo tên singleton autoload. Nếu gặp lỗi `Identifier not found`, check chạy lại file đó trong scene probe với autoload của project; lỗi parse/compile thực vẫn khiến check thất bại.

Project đã có autoload `Autoplay` sau `GameInput`. Khi không có user arg, script không phát input. Chạy main scene trực tiếp:

```powershell
pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Autoplay res://tests/tools/autoplay_example.json -Frames 120 -Out build/captures/autoplay
```

Dùng `-Autoplay` với scene game bình thường (không dùng scene test để tránh hai bộ phát). Đường dẫn JSON có thể là `res://...` hoặc đường dẫn filesystem tính từ gốc repo. Capture báo lỗi nếu không thấy autoplay được nạp.

JSON là mảng event theo frame tăng dần (cho phép cùng frame), frame bắt đầu từ 0. Event chứa `press`/`release` với action đã đăng ký, hoặc `mouse_dx`/`mouse_dy` dạng số. Ví dụ ở `game/tests/tools/autoplay_example.json`. Chuột giả đi qua `Viewport.push_input`; action dùng `Input.action_press/release`. Script nhả các action còn giữ khi dừng và yêu cầu thoát ở frame cuối + 30: gọi App.quit() nếu có App, fallback SceneTree.quit() nếu không có. `-Frames` là giới hạn capture, có thể kết thúc sớm hơn autoplay; chọn đủ lớn. Frame tính theo `_process`, dùng fixed FPS khi capture để phát lại ổn định.

Smoke test duyệt đệ quy toàn bộ `res://scenes/*.tscn`, load, instance và cho chạy hai frame. Luôn kiểm tra thêm log Godot: test.ps1 chuyển runtime engine error hoặc thiếu dòng RESULT thành exit 1, giữ nguyên cách gọi cũ.
`capture.ps1` dùng snapshot riêng và override viewport để PNG đúng `-Resolution`; không sửa cấu hình project gốc. Mặc định snapshot được xóa trong finally kể cả khi capture lỗi; thêm `-KeepSnapshot` để giữ phục vụ chẩn đoán. PNG và WAV vẫn giữ. Output không được đặt trong `game/` để tránh sao chép đệ quy.

## Kiểm chứng T-124 / T-127

- `pwsh tools/verify-capture.ps1`: năm lần liên tiếp trên main, kịch bản `autoplay_main.json` có đi/chạy/quay chuột; frame cuối 105 nên mong đợi 136 PNG mỗi lần. Dùng KeepEvery=1, Frames=200 và kiểm tra không còn thư mục snapshot. Chạy với cửa sổ thật; tránh thao tác chuột/phím trong lúc đo. Đây là phép kiểm tra số frame, không bảo đảm ảnh giống từng pixel khi có input thật.
- `pwsh tools/test.ps1 -Filter export_filters`: bảo vệ các mẫu loại trừ Windows Desktop. Giữ `scripts/debug/` vì project có autoload Autoplay; loại thư mục này đã được xác minh gây lỗi khởi động EXE. Các scene test/showcase và script import editor bị loại khỏi build. `project.godot` không bị sửa.
- ZIP dùng hash HEAD, nhưng chứa nội dung workspace hiện tại. Commit trước khi tạo bản phát hành. Log cạnh ZIP mô tả lần kiểm chứng gần nhất; artifact FAIL không được coi là bản đã xác minh.

### Thoát sạch và số frame (T-127)

Package chạy EXE bằng `-- --quit-after-frames=60`; capture truyền `--quit-after-frames=<Frames>` cùng nhóm user args với autoplay. Không dùng `--quit-after` của engine vì nó bỏ qua bước dừng âm thanh của App.

App dừng scene/âm thanh rồi chờ 0,25 giây trước khi thoát. Movie Maker vẫn ghi thêm ảnh trong lúc chờ. Capture đọc mốc `AUTOPLAY: finished after N frames`, giữ tối đa `min(Frames, N)` ảnh gameplay (hoặc Frames nếu không có mốc), bỏ đuôi ảnh chờ thoát rồi mới áp dụng KeepEvery. Ví dụ kịch bản kết thúc frame 105 vẫn giữ 136 ảnh với KeepEvery=1. Log luôn in cả số ảnh thô và số ảnh chờ thoát bị bỏ; WAV gốc vẫn gồm phần chờ thoát. Capture kết thúc sớm hơn số frame yêu cầu sẽ báo lỗi.

Không bỏ qua ERROR, exit code hoặc timeout của package. Để giữ snapshot chẩn đoán, thêm `-KeepSnapshot`; không có tùy chọn này thì snapshot được dọn trong finally cả khi lệnh lỗi. Lịch sử lỗi Ogg khi thoát ngay được ghi trong Handoff T-124; công cụ hiện dùng App của core để dừng sạch.
`test.ps1` giữ nguyên tham số nhưng đặt APPDATA riêng cho tiến trình Godot chạy test trong `build/test-userdata/<uuid>`, rồi khôi phục biến môi trường và dọn thư mục ở finally. Cách này tách `user://settings.cfg` giữa các lane/lần chạy; test launcher kiểm chứng đường dẫn thực tế. Không đổi project.godot hay test UI/player. Tham khảo [đường dẫn dữ liệu Godot](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html).
