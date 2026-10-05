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

## T-166: chương 1 bản 2 và menu F9

- Trong chương 1 bản debug, F9 mở/đóng menu thử nhanh. Bản release ẩn menu trừ khi truyền `-- --qa-menu`.
- Chọn mốc ở phiên chơi thường sẽ mở một tiến trình Godot mới, dùng APPDATA riêng dưới `build/qa-menu/`. Phiên gốc tạm dừng khi menu mở. Không thay checkpoint/progress của phiên gốc. Các tùy chọn bất tử/x4 áp dụng cho phiên thử riêng; đóng phiên thử để trở lại game gốc.
- Trong phiên QA, mỗi lần nhảy tạo scene mới rồi gọi `Chapter1Director.run_from(stage)`, không chạy chồng coroutine của mốc trước. Menu giữ nguyên trạng thái pause có từ trước.
- Mốc chưa có trong profile hoặc `Chapter1Director.STAGES` bị vô hiệu hóa. Hiện có prologue/r1/r2/r2_manager. Mất mạng/gõ tường/giữ cửa/cứu Nhật cần T-160 thêm entry point rồi điền `jumps`.
- Bất tử dùng subclass debug `qa_director.gd` chặn `_die` và `_manager_kills`, ghi `QA_DEATH_SUPPRESSED` (mỗi lý do một lần mỗi scene). Không áp dụng vào scene chơi thường. Khi core đổi pipeline chết, cần kiểm tra lại hai hook này. Chặn chết không tự giải nhiệm vụ; một nhánh truyện có thể kết thúc sớm, dùng F9 nhảy lại để tiếp tục thử.
- Đáp án lấy từ D-039: 2109, công tắc 2, dây xanh, CO = 13 34. Menu ghi rõ đây là đáp án **bản 2**, không phải xác nhận dữ liệu trên main cũ. Catalog vi/en dành riêng QA được đăng ký lúc chạy, trong phạm vi `scripts/debug/`.

```powershell
pwsh tools/qa-menu.ps1 -Stage r1
pwsh tools/qa-menu.ps1 -Smoke
pwsh tools/playthrough.ps1 -V2 -Scenario all
pwsh tools/playthrough.ps1 -V2 -Scenario ch1v2_good -RequireComplete
pwsh tools/playthrough.ps1 -V2 -Performance -RequireComplete
```

`-V2` tự chọn chương 1 và `tools/ch1v2-profile.json`. Năm case: `ch1v2_good`, `ch1v2_wrong_switch`, `ch1v2_door_late`, `ch1v2_lamp_on`, `ch1v2_wrong_advice`. Thiếu binding/cơ chế => SKIP với lý do; `-RequireComplete` trả exit 2 nếu chỉ còn SKIP. FAIL thật trả exit 1. Bộ cũ vẫn dùng lệnh cũ; chương 1 bản đầu cần `-Chapter 1 -ChapterProfile tools/ch1-profile.json`.

Bot bản 2 mặc định chạy thời gian thật (`TimeScale=1`), timeout mỗi lần đợi 1800 giây, toàn phiên 4500 giây; launcher dừng sau 4515 giây. Có thể đặt `-SegmentTimeout 5..3600`. Không tăng tốc khi cần đo cửa 10 giây, cooldown ổ điện 20 giây, nhịp gõ hoặc nín thở 6 giây. Tua x4 trong menu chỉ dùng khám phá thủ công.

### Điền profile sau khi ghép

- `bindings`: ID segment/cờ và tọa độ thật. Giá trị `null` khiến kịch bản SKIP trước khi chạy; không lấy mốc thời gian suy ra thành ID. Cờ chờ phải là cờ trạng thái tồn tại tới khi bot đọc được, không phải xung một frame.
- `actions`: đường dẫn tương đối từ scene chương 1. `wall_taps` và `keypad` chỉ cần `{ "path": "..." }`: tường gọi `interact(Player)` và đếm `wall_tapped`; keypad mở trạm thật rồi bấm nút Up của panel, chờ `puzzle_solved`, không tự phát signal giải khóa.
- Các thao tác khác cần `path`, `method`, `args`, `verify`. `$player` trong args được thay bằng Player; `$on` bằng bool của command. `verify` dùng `flag` (GameState) hoặc `property` (trên target) và `equals`. Khi trạng thái đã đúng, không toggle lại. Không có phương thức thì SKIP; có phương thức nhưng trạng thái không đúng trong 3 giây thì FAIL.
- Ví dụ adapter cho ổ sạc hiện tại (xác nhận lại sau T-160):

```json
{"path":"Chapter1Director/ChargerSocket","method":"interact","args":["$player"],"verify":{"flag":"charging","equals":true}}
```

- Key adapter: `power_switch_1..3`, `cable_blue/gray`, `latch`, `search_viet_locker/phuc_mattress/trash`, `desk_lamp`, `camera_tab`, `map_tab`, `charge`. Dây mạng cần bind API thao tác cầm/cắm thật do T-161 cung cấp; nếu API gồm hai đối tượng, cập nhật adapter sau ghép. Không tự set cờ đã cắm. Switch 3 phải xác nhận cờ **đã chập**, không đòi công tắc còn bật sau `trip()`.
- `wall_taps`: chuỗi số 1..5, hai số/chữ, ví dụ `13 34`; cách nhau 0,18 giây trong nhóm, 1 giây giữa tọa độ, 2,5 giây giữa chữ, theo đồng hồ thực. Đổi nhịp chỉ sau khi đối chiếu bộ giải mã T-160.
- Bot đóng giấy sau lục, kiểm tra cờ ghép đủ ba mảnh, mở Sơ đồ/Camera, tắt đèn/điện thoại, nằm giường Việt và nín 5,5 giây ở mốc nghe. Cần xác nhận lịch nhiệm vụ thật: sửa mạng/gõ tường không được khiến bot lỡ cửa 10 giây. Case sai công tắc đợi 20,5 giây trước sửa lại. Case chết kiểm tra lý do, UI và reload scene thật về đầu vòng 1/2.
- Chưa có binding không có nghĩa là đã chơi hết tám nhiệm vụ. `report.json` ghi status, checks, skipped, thời gian thật và phút game.

### Hiệu năng bản 2

`performance.views` cần bốn mục `door`, `bed`, `washroom`, `balcony`; mỗi mục `{ "eye":[x,y,z], "target":[x,y,z] }` do người ghép lấy từ **phòng mới**. `camera_view` cùng cấu trúc, dùng thêm adapter `actions.camera_tab` để mở tab thật sau `cctv_unlocked` và giơ máy. Không lấy tọa độ phòng cũ thay cho phòng mới.

Bài đo chỉ tính case Camera khi tìm thấy ít nhất năm SubViewport có Camera3D hiện hành, `UPDATE_ALWAYS`, thuộc các node group `cctv_feed`. Không tính viewport gương; không ép bật năm viewport để che lỗi tích hợp. Nếu cách bố trí viewport của core khác hợp đồng trên, cập nhật adapter kiểm kê trước khi đo.

JSON ghi phần cứng, renderer, 1280×720, VSync off, không giới hạn FPS, warmup 90 frame/góc, sample 240 frame/góc, mean FPS, p95 frame ms, max frame ms và `target_met` (mean ≥60). Camera đo cuối sau các góc tĩnh. Scene vẫn có physics/HUD/audio, story tắt để so sánh góc cố định; không phải benchmark đầy đủ luồng truyện. Chạy riêng, không đồng thời chạy Godot/test khác. Mục chưa ghép trả SKIP và không sinh FPS. `-RequireComplete` giúp CI không nhận nhầm SKIP thành hoàn thành.

## T-173: chương 2 (khung trước khi ghép T-170…T-175)

```powershell
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario all
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario all -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Performance -RequireComplete
pwsh tools/qa-menu.ps1 -Chapter 2 -Stage r3
pwsh tools/qa-menu.ps1 -Chapter 2 -Smoke
```

Chương 2 tự chọn `tools/ch2-profile.json`, thời gian thật (`TimeScale=1`), watchdog toàn chương 60 phút. Các phép đợi reload dùng `-SegmentTimeout` (mặc định 120 giây). Không dùng `-V2` cùng `-Chapter 2`. Sáu case: good, chain_timeout, chain_wrong, scald, leave_shower, lost_ngu (đều có tiền tố `ch2_`). Exit 0 = không có FAIL; `-RequireComplete` trả 2 nếu còn SKIP, 1 nếu FAIL. Menu smoke cũng trả 2 nếu scene/mốc chưa ghép. Mỗi lượt chạy dùng APPDATA riêng dưới build, không dùng checkpoint/progress thật.

### Profile và dữ liệu cần core cung cấp

- `scene`, `director`: scene chương 2 thật và node director có `auto_start`, `start()`. Các đường dẫn dự kiến từ T-170 có thể chưa tồn tại; bot kiểm tra trước khi load, trả SKIP có lý do.
- `bindings.round3_segment`, `round4_segment`, `death_ui_path`: ID/path thật. Không đoán theo tên task. Checkpoint kỳ vọng `ch2_r3`/`ch2_r4` và lý do chết lấy từ thiết kế đã duyệt.
- `lexicon`: map từ key `WORD_CH2_*` sang `{ "text": "từ tiếng Việt", "valid": true, "dead_end": false }`. Phải bao gồm cả phương án bẫy (valid=false khi không phải từ hợp lệ). Text chuẩn hóa theo dữ liệu core, giữ nguyên dấu; không dùng bản dịch tiếng Anh của UI để nối từ. Cần kho đầy đủ để tìm đường 1–3 từ trung gian vào vòng tám từ. Không tự tạo kho từ trong tool.
- `ngu_choice_id`, `ngu_temperatures` (ba nhiệt độ đã nói trong cuộc gọi), `ngu_yes_index`, `ngu_no_index`: core điền theo dữ liệu lời thoại thật. Bot chỉ dùng chúng khi câu hỏi đó đang chờ. Case lost_ngu đảo đáp án dự đoán.
- `scald_temperature_flag`: cờ core công bố nhiệt độ thật tại lúc chết; case scald chọn Có ở lượt thứ tư (81°C trong dãy đã duyệt), nhưng chỉ PASS khi quan sát được đúng 81°C. Nếu nhiệt độ chưa được core công bố, SKIP binding; không suy 81 chỉ từ tên case.
- `jumps`: r3/r4 và tùy ý thêm mốc giữa vòng do core cung cấp. Menu chương 2 gọi `run_from(stage)` trên scene mới. `rule_set` là resource luật nếu API run_from cần tool load trước. Không dùng bất tử của Chapter1Director cho chương 2.

### Thao tác vật lý

`actions` cần binding cho pickup_rag/towel/shirt, gag_1/2/4, bedroom, push_door_1/2/3, enter_shower, leave_shower, wipe. Mỗi binding là một bước hoặc `{ "steps": [...] }`. Mỗi bước:

```json
{
  "path": "duong/dan/node/thuc",
  "method": "interact",
  "args": ["$player"],
  "verify": {"signal": "picked", "property": "ten_thuoc_tinh_thuc", "equals": true}
}
```

Đây là **schema**, không phải node/API đã tồn tại. `verify` dùng signal trên target, hoặc `property` trên target / `flag` trong GameState và `equals`; nếu có cả signal và state thì phải xác nhận cả hai. Signal được nối trước thao tác và tháo sau đó; trạng thái khớp từ trước không thay thế một signal chưa phát. JSON number được so sánh an toàn với int/float của Godot.

- Bước có `position: [x,y,z]` đưa Player tới tọa độ thật rồi chờ acknowledgement (ví dụ `shower_stall.player_inside`). Không tự ghi cờ trong/ngoài buồng.
- Bước có `hold_action`, `seconds` (1…5, mặc định 1,05) giữ input thật; có thể thêm `aim: [x,y,z]` để camera nhìn vùng tương tác và đợi hai physics frame. Binding lau phải xác nhận `wiped`, không gọi thẳng UI.wipe() để bỏ qua một giây giữ E.
- Mỗi bước chờ tối đa 3 giây cho xác nhận, không có component/API thì SKIP. Có API nhưng không đạt trạng thái/signal thì FAIL. Cần kiểm tra lại adapter với API T-171 sau merge; đặc biệt vị trí lấy đồ/quay về phòng ngủ, điều kiện giữ E và cửa đẩy đúng ba lần.

### Hành vi bot và menu

Bot nghe signal trước khi scene bắt đầu. Nối từ kiểm tra đúng hai tiếng, dấu chính xác và ba từ vừa nói; ưu tiên từ cụt có metadata khi còn cần lấy đồ. Sau ba signal xác đã bịt, chọn đường vào vòng học sinh…văn học và ghi nhận đủ tám lựa chọn liên tiếp. Không trả lời khi chain_choice_blocked; quay lại phòng ngủ bằng adapter. Case timeout không phát lựa chọn -1 giả, kiểm tra đã chờ ít nhất 15 giây thực. Case wrong chỉ chọn phương án sai dấu; nếu chưa có thì tiếp tục chọn hợp lệ.

Vòi sen: lượt đầu chưa có dữ liệu thì chọn Không; các lượt sau dùng `(hàng chục + hàng đơn vị) % 10 < 5` của nhiệt độ vừa hiện, không đọc trước dãy. Trước Có phải vào vùng buồng tắm thật; case leave_shower bước ra sau Có. Good chỉ PASS khi có ba xác bịt, đủ vòng tám từ, ≥25 phút nước, đã trả lời Ngư, chapter_finished(2) và unlock chương 3, không có chết. Case chết kiểm tra lý do, kind, UI và scene reload thật về đầu vòng.

F9 trong scene chương 2 mở menu riêng (chỉ debug hoặc `--qa-menu`); các mốc thiếu bị khóa. Nhảy từ phiên thường mở tiến trình mới có userdata riêng. Bật đáp án chỉ hiển thị từ hợp lệ và dự đoán Có/Không từ dữ liệu đã quan sát; chưa có dữ liệu thì báo chưa có. Catalog vi/en nằm trong debug như T-166 để giữ phạm vi file; tên mốc bổ sung hiển thị ID do core cung cấp.

### FPS hơi nước

`performance.view` = eye/target XYZ trong nhà vệ sinh thật. `setup`, `hot_water`, `steam_0`, `steam_1` dùng cùng schema action/acknowledgement, gọi API fixture của cơ chế thật khi director auto_start=false. Đo hai trạng thái **nước nóng đang chảy** ở hơi nước 0 và 1, 1280×720, VSync off, không giới hạn FPS, 90 frame warmup + 240 frame mẫu/trạng thái. `hot_water` và `steam_*` phải có state acknowledgement, không chỉ signal; kiểm tra state mỗi frame lấy mẫu. State đổi trong lúc đo thì FAIL, không gán số đo nhầm trạng thái. JSON có mean FPS, p95/max frame ms, steam level, hot_water_running, ngưỡng mean ≥60 và thời gian. Không có scene/fixture thì SKIP, views rỗng. Đo riêng, không chạy đồng thời Godot/test khác; không lấy FPS phòng chương 1 để thay thế.
