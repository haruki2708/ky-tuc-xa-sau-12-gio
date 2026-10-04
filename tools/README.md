# Công cụ QA (chạy từ gốc repo bằng PowerShell 7)

Godot được tìm qua `godot-path.ps1`; có thể đặt biến môi trường `GODOT` tới bản console 4.7.2. Không cần plugin.

- `pwsh tools/test.ps1 [-Filter tools]`: import và chạy test headless; xem dòng `RESULT`.
- `pwsh tools/check.ps1`: import, parse từng `.gd` bằng `--check-only`, kiểm tra file nguồn lớn hơn 10 MB và bản dịch vi/en trống. Bỏ qua file được Git ignore (build/cache), tính cả file nguồn chưa track. Exit 0 khi không có lỗi.
- `pwsh tools/export.ps1 [-Debug]`: xuất Windows; mặc định release.
- `pwsh tools/package.ps1`: gọi export release, nén EXE có PCK nhúng và README song ngữ vào `build/dist/KyTucXa-<version>-<hash>-win64.zip`. Version lấy từ `application/config/version`; hash là HEAD. Nên commit trước khi tạo bản phát hành; workspace đang sửa vẫn được export. README lấy từ `tools/package_readme.txt`. Công cụ in dung lượng ZIP, tự giải nén vào thư mục riêng rồi chạy EXE 60 frame (timeout 60 giây). Chỉ in `RESULT: package PASS` khi exit 0 và log không có ERROR; lỗi trả exit 1 và `RESULT: package FAIL`. Stage và bản giải nén được dọn trong finally, log kiểm chứng giữ cạnh ZIP. Lệnh này mở tiến trình game với cửa sổ ẩn.
- `pwsh tools/capture.ps1 -Scene res://scenes/main/main.tscn -Frames 60 -Fps 30 -Resolution 1280x720 -Out build/captures/main -KeepEvery 10`: chạy Godot có cửa sổ, lưu PNG vào thư mục con riêng cho mỗi lần chạy; giữ frame thứ 10, 20… và luôn giữ ảnh cuối. Dòng cuối in đường dẫn ảnh cuối. WAV do Movie Maker tạo được giữ lại.

## Tự chơi cả demo

Chạy `pwsh tools/playthrough.ps1 -Scenario all` để kiểm tra ba luồng `correct`, `deviant`, `mirror`; chọn riêng bằng `-Scenario correct`, `-Scenario deviant` hoặc `-Scenario mirror`. Bot instance main, tương tác qua API thật, dịch chuyển/quay người chơi và trả lời điểm danh bằng InputEventAction. Không tự ghi cờ story hoặc giải quyết luật. Đây là kiểm tra luồng truyện, không thay thế kiểm tra điều khiển và va chạm bằng tay.

Mặc định headless, `-TimeScale 0.05` chỉ tăng tốc StoryDirector; `-SegmentTimeout 45` giới hạn giây thực cho mỗi đoạn. `-Capture` chạy có cửa sổ và lưu PNG ở frame render kế tiếp của mỗi mốc. Log và ảnh nằm trong `build/playthrough/<uuid>/<scenario>/`; APPDATA riêng được dọn sau chạy. Launcher trả exit 1 khi bot thất bại, quá giờ, engine báo ERROR hoặc thiếu dòng PASS; dòng tổng là `RESULT: playthrough N passed, M failed`.

Mọi luồng đều kiểm tra đủ sáu mốc seg1–seg5/end, đúng ending và chính xác độ lệch:

| Kịch bản | Hành động | Ending | Độ lệch |
|---|---|---|---|
| `correct` | Làm đúng mọi luật | 1 | 0 |
| `deviant` | Tắt đèn đúng, mở cửa (+2), quay lại (+2), thoát vào vùng sáng, điểm danh và khóa vòi đúng | 2 | 4 |
| `mirror` | Làm đúng các đoạn trước, nhìn gương (+2), ra hành lang rồi chạy về phòng 407 và chốt cửa | 1 | 2 |

Bot chạy khi pause để xử lý giấy và timeout; scene game được đặt `PAUSABLE` riêng để giữ hành vi pause như chạy main bình thường. Nếu main kế thừa `ALWAYS` từ bot, LightHum có thể bật âm thanh lại sau khi App đã dừng, gây rò rỉ tài nguyên lúc thoát. Test `pwsh tools/test.ps1 -Filter playthrough_pause` bảo vệ trường hợp này.

## Chương 1 và hiệu năng (T-157)

```powershell
pwsh tools/playthrough.ps1 -Chapter 1 -Scenario all
pwsh tools/playthrough.ps1 -Chapter 1 -Scenario ch1_good -ChapterProfile tools/ch1-profile.example.json
pwsh tools/playthrough.ps1 -Chapter 1 -Scenario all -ChapterProfile build/ch1-profile.json -RequireComplete
pwsh tools/playthrough.ps1 -Performance
```

`-Chapter 0` (mặc định) giữ ba kịch bản demo cũ. Chương 1 có `ch1_good`, `ch1_stay_in_bed`, `ch1_leave_room`, `ch1_own_bed`; template hành động nằm ở `game/scripts/debug/ch1_scenarios.json`. Chương 1 mặc định timeout mỗi đoạn/chờ là 120 giây thật, demo là 45; đổi bằng `-SegmentTimeout`. Nín thở/đứng yên dùng giây thật, không nhân TimeScale. Bot không tự đặt cờ sống sót hoặc mở khóa chương.

**Main ngày 2026-10-04 chưa có luồng T-150, cơ chế T-151 và UI T-155.** Bốn kịch bản hiện trả SKIP có lý do; đây không phải bốn lượt chơi PASS. Launcher đếm riêng PASS/FAIL/SKIP: mặc định SKIP không gây exit lỗi; `-RequireComplete` trả exit 2 khi còn SKIP, exit 1 khi có FAIL/ERROR. Chỉ dùng kết quả không có SKIP để xác nhận chương chơi được. APPDATA riêng chứa cả progress và checkpoint, dọn sau từng lượt; log và `report.json` giữ trong `build/playthrough/<uuid>/<scenario>/`.

Sau khi ghép, sao chép `ch1-profile.example.json` rồi điền **ID thật từ core** vào `bindings`, cùng scene/path nút chương 2 của T-155. Giá trị null là chưa có, không tự đoán. `opening_segment` là đoạn người chơi bắt đầu trên giường; `round1_segment` là lúc luật cấm rời phòng có hiệu lực; `manager_segment` là checkpoint chuẩn bị trước khi quản lý bước vào. `breath_seconds` phải khớp cửa sổ nín thở của luồng đã ghép (T-151 giới hạn 8 giây); `solution_choice`/`solution_index` là lựa chọn báo lời giải cho Nhật sau quản lý. Ba `*_checkpoint` và `*_failure_rule` phải trùng tín hiệu chết/tải lại thực tế; `death_ui_path` trỏ tới node có thuộc tính `visible` trong scene chương. Các tọa độ ở template theo tầng 4 hiện tại, cần đối chiếu lại khi T-153 ghép.

Nhánh chết phải quan sát đúng nguyên nhân, UI hiện và scene thực sự được thay rồi tải đúng checkpoint. Nhánh tốt phải nhận `chapter_finished(1)` và `Progress.unlocked_chapter() >= 2`. Probe hiện kiểm chứng round-trip `GameState.chapter` qua checkpoint tạm; việc giữ pin/lịch sử qua **reload scene** vẫn SKIP khi thiếu phone/snapshot/restore. Khi có các thành phần này, bước `save_reload` đặt pin 37% qua API thật, lưu checkpoint hiện hành, gọi `App.start_game(true)` và so chapter/pin/snapshot sau tải lại (dung sai pin 0,5% cho hao pin theo thời gian). Không tự nhét dữ liệu pin/chat vào checkpoint để che thiếu sót core. Màn chọn chương được kiểm tra nút chương 2 bị disabled trên progress mới; kiểm tra này chưa chạy khi chưa có binding UI.

Autoplay nhận thêm event độc lập `command`; các event phím/chuột cũ giữ nguyên. Ví dụ:

```json
[
  {"frame":0,"command":{"op":"bed","number":1}},
  {"frame":1,"command":{"op":"breath","seconds":3}},
  {"frame":2,"command":{"op":"leave_bed"}},
  {"frame":3,"command":{"op":"goto","position":[32,0.03,-2]}}
]
```

Các command khác: `still` + `seconds`; `phone` + `raised` true/false; `answer_call` (dùng cuộc gọi đến đã quan sát); `choice` + `id`/`index` (lựa chọn đang chờ); `puzzle` + `id` (station phải tồn tại). Timeline frame dừng trong lúc command chờ, rồi tiếp tục; command FAIL dừng playback, SKIP ghi lý do và tiếp tục. Signal đã khai báo nhưng chưa có component nhận không được xem là hành động thành công.

`-Performance` mở renderer thật, 1280×720, tắt VSync/giới hạn FPS, warm-up 90 frame và đo 240 frame mỗi góc. Có thể đổi `-WarmupFrames`/`-PerfFrames`. Bảy góc: bốn giường, cửa 407, hành lang, nhà vệ sinh. FPS trung bình = số frame / tổng thời gian thực; `p95_frame_ms` là phân vị 95 của thời gian frame (nearest rank), **đơn vị ms**, như T-112. JSON ghi CPU/GPU/renderer, cấu hình và tọa độ camera. Không đo headless/fixed-fps, không chụp ảnh trong khoảng lấy mẫu. Story tắt, Player physics/HUD/audio vẫn chạy; số đo trên main hiện tại chưa đại diện chương 1 đã ghép. Chạy riêng, không chạy test/Godot khác đồng thời để so sánh hiệu năng.

## Autoplay theo frame (demo)

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
