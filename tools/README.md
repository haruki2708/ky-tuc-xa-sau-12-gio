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
- Đáp án lấy từ D-039, D-069: 2109, công tắc 2, dây xanh, gõ lại nhịp của Khoa 3–1 (code `31`). Menu ghi rõ đây là đáp án **bản 2**, không phải xác nhận dữ liệu trên main cũ. Catalog vi/en dành riêng QA được đăng ký lúc chạy, trong phạm vi `scripts/debug/`.

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
- `wall_taps`: chuỗi số 1..5, mỗi số là một nhóm gõ, số lượng số chẵn, ví dụ `31` (nhịp 3–1 của D-069); cách nhau 0,18 giây trong nhóm, 1 giây giữa hai số trong cặp, 2,5 giây giữa các cặp, theo đồng hồ thực. Core (`Chapter1Director.tap_groups`, T-201) tách nhóm ở khoảng nghỉ từ 0,7 giây; đổi nhịp thì đối chiếu với hàm đó.
- Bot đóng giấy sau lục, kiểm tra cờ ghép đủ ba mảnh, mở Sơ đồ/Camera, tắt đèn/điện thoại, nằm giường Việt và nín 5,5 giây ở mốc nghe. Cần xác nhận lịch nhiệm vụ thật: sửa mạng/gõ tường không được khiến bot lỡ cửa 10 giây. Case sai công tắc đợi 20,5 giây trước sửa lại. Case chết kiểm tra lý do, UI và reload scene thật về đầu vòng 1/2.
- Chưa có binding không có nghĩa là đã chơi hết tám nhiệm vụ. `report.json` ghi status, checks, skipped, thời gian thật và phút game.

### Hiệu năng bản 2

`performance.views` cần bốn mục `door`, `bed`, `washroom`, `balcony`; mỗi mục `{ "eye":[x,y,z], "target":[x,y,z] }` do người ghép lấy từ **phòng mới**. `camera_view` cùng cấu trúc, dùng thêm adapter `actions.camera_tab` để mở tab thật sau `cctv_unlocked` và giơ máy. Không lấy tọa độ phòng cũ thay cho phòng mới.

Bài đo chỉ tính case Camera khi tìm thấy ít nhất năm SubViewport có Camera3D hiện hành, `UPDATE_ALWAYS`, thuộc các node group `cctv_feed`. Không tính viewport gương; không ép bật năm viewport để che lỗi tích hợp. Nếu cách bố trí viewport của core khác hợp đồng trên, cập nhật adapter kiểm kê trước khi đo.

JSON ghi phần cứng, renderer, 1280×720, VSync off, không giới hạn FPS, warmup 90 frame/góc, sample 240 frame/góc, mean FPS, p95 frame ms, max frame ms và `target_met` (mean ≥60). Camera đo cuối sau các góc tĩnh. Scene vẫn có physics/HUD/audio, story tắt để so sánh góc cố định; không phải benchmark đầy đủ luồng truyện. Chạy riêng, không đồng thời chạy Godot/test khác. Mục chưa ghép trả SKIP và không sinh FPS. `-RequireComplete` giúp CI không nhận nhầm SKIP thành hoàn thành.

## T-173 / T-180: chương 2 — gõ từ và nhắn dự đoán

```powershell
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario all
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario all -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Performance -RequireComplete
pwsh tools/qa-menu.ps1 -Chapter 2 -Stage r3
pwsh tools/qa-menu.ps1 -Chapter 2 -Smoke
```

**Không tự chạy bot cả chương:** theo T-180, integrator chỉ chạy các lệnh playthrough bên trên sau khi chủ dự án đồng ý (15–20 phút mỗi case, tốn RAM). Phiên T-180 chỉ chạy `pwsh tools/test.ps1` và `pwsh tools/check.ps1` headless.

Chương 2 tự chọn `tools/ch2-profile.json`, thời gian thật (`TimeScale=1`), watchdog toàn chương 60 phút. Các phép đợi reload dùng `-SegmentTimeout` (mặc định 120 giây). Không dùng `-V2` cùng `-Chapter 2`. Sáu case: good, chain_timeout, chain_wrong, scald, leave_shower, wrong_prediction (đều có tiền tố `ch2_`). Exit 0 = không có FAIL; `-RequireComplete` trả 2 nếu còn SKIP, 1 nếu FAIL. Menu smoke cũng trả 2 nếu scene/mốc chưa ghép. Mỗi lượt chạy dùng APPDATA riêng dưới build, không dùng checkpoint/progress thật.

### Profile và dữ liệu cần core cung cấp

- `scene`, `director`: scene chương 2 thật và node director có `auto_start`, `start()`. Các đường dẫn dự kiến từ T-170 có thể chưa tồn tại; bot kiểm tra trước khi load, trả SKIP có lý do.
- `bindings.round3_segment`, `round4_segment`, `death_ui_path`: ID/path thật. Không đoán theo tên task. Checkpoint kỳ vọng `ch2_r3`/`ch2_r4` và lý do chết lấy từ thiết kế đã duyệt.
- T-180 bỏ `lexicon` và bốn binding Ngư cũ. Bot đọc `Ch2Dictionary.shared()` và `VietText`; từ key `WORD_CH2_*` được tra text trong `word_bank.json`, còn chữ trực tiếp được giữ nguyên. Policy dùng chỉ mục từ điển, tính đường ngắn về vòng lặp và xác định từ xác không biết nối; không lấy đáp án từ `director.suggest_word()`.
- Dự đoán chỉ dùng `history` nhận qua `prediction_requested`; không đọc trước `predict.next`. Gửi `prediction_sent` một lần/người, rồi chờ `prediction_result`. Minh Nhật nhận dạng hàng chục (ví dụ `2x`), Ngư nhận `có`/`không`; case `ch2_wrong_prediction` chỉ đảo đáp án Ngư.
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

Bot nghe signal trước khi scene bắt đầu. `chain_input_requested` mở lượt gõ; bot phát `chain_word_typed`, chờ `chain_input_closed`. Không dùng hai signal chọn phương án đã bỏ. Nối từ kiểm tra hai tiếng, dấu và ba từ vừa nói; chữ dựng sẵn/tổ hợp, dấu kiểu cũ/mới dùng cùng chuẩn hóa với core. Gài từ làm xác bí ít nhất một lần và đợi core nhận từ rồi xác ngã trước khi lấy đồ/bịt xác. Sau ba xác đã bịt, chọn đường vào vòng học sinh…văn học; sau 2 từ lặp, core hỏi `tell` và bot chọn câu 1 (D-072); vòng 3 qua ở từ lặp thứ 4, chỉ tính khi nghe core phát chữ Trung đã nói. Timeout không gõ, wrong gõ từ cùng âm nhưng sai dấu; không có từ sai dấu thì tiếp tục hợp lệ. Bot đối chiếu tính hợp lệ với director nhưng tự chọn chữ từ từ điển.

Vòi sen: lượt đầu chưa có dữ liệu thì chọn Không; các lượt sau dùng `(hàng chục + hàng đơn vị) % 10 < 5` của nhiệt độ vừa hiện, không đọc trước dãy. Trước Có phải vào vùng buồng tắm thật; case leave_shower bước ra sau Có. Good chỉ PASS khi có ba xác bịt, đủ vòng tám từ, ≥25 phút nước, đã xác nhận gài bẫy và nhận `prediction_result(correct=true)` cho cả Minh Nhật lẫn Ngư, chapter_finished(2) và unlock chương 3, không có chết. Case chết kiểm tra lý do, kind, UI và scene reload thật về đầu vòng.

F9 trong scene chương 2 mở menu riêng (chỉ debug hoặc `--qa-menu`); các mốc thiếu bị khóa. Nhảy từ phiên thường mở tiến trình mới có userdata riêng. Bật đáp án chỉ hiển thị từ hợp lệ và dự đoán Có/Không từ dữ liệu đã quan sát; chưa có dữ liệu thì báo chưa có. Catalog vi/en nằm trong debug như T-166 để giữ phạm vi file; tên mốc bổ sung hiển thị ID do core cung cấp.

### FPS hơi nước

`performance.view` = eye/target XYZ trong nhà vệ sinh thật. `setup`, `hot_water`, `steam_0`, `steam_1` dùng cùng schema action/acknowledgement, gọi API fixture của cơ chế thật khi director auto_start=false. Đo hai trạng thái **nước nóng đang chảy** ở hơi nước 0 và 1, 1280×720, VSync off, không giới hạn FPS, 90 frame warmup + 240 frame mẫu/trạng thái. `hot_water` và `steam_*` phải có state acknowledgement, không chỉ signal; kiểm tra state mỗi frame lấy mẫu. State đổi trong lúc đo thì FAIL, không gán số đo nhầm trạng thái. JSON có mean FPS, p95/max frame ms, steam level, hot_water_running, ngưỡng mean ≥60 và thời gian. Không có scene/fixture thì SKIP, views rỗng. Đo riêng, không chạy đồng thời Godot/test khác; không lấy FPS phòng chương 1 để thay thế.

### Kiểm tra nhanh T-180 (headless)

`pwsh tools/test.ps1 -Filter ch2_` bao gồm policy nhập chữ/dự đoán và test `test_ch2_menu.gd`: tạo scene thật, gọi handler F9 mở/đóng, nhảy r3 rồi r4, kiểm tra scene mới/chapter/segment/pause và đáp án. Đây là kiểm tra xử lý input/menu bằng headless; không xác nhận hình ảnh render, bàn phím vật lý hay Unikey/EVKey. Không chạy bot trọn chương, không đo FPS trong phiên T-180.

## T-184: chương 3 — khung QA và benchmark ngoài trời

```powershell
pwsh tools/test.ps1 -Filter ch3_
pwsh tools/playthrough.ps1 -Chapter 3 -Performance -RequireComplete
pwsh tools/qa-menu.ps1 -Chapter 3 -Stage b
pwsh tools/qa-menu.ps1 -Chapter 3 -Smoke
```

Benchmark ngắn được phép chạy; **không chạy bot cả chương khi chưa có bản ghép và yêu cầu của integrator**. Các lệnh bot sau chỉ dành cho bước đó:

```powershell
pwsh tools/playthrough.ps1 -Chapter 3 -Scenario ch3_good -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 3 -Scenario ch3_grabbed -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 3 -Scenario ch3_guard -RequireComplete
```

Profile mặc định `tools/ch3-profile.json`. Đường dẫn scene và ID b/garden/stadium/gate lấy từ card T-181…T-183; phần chưa công bố để `null`. Không dùng scene giả để thay kết quả đo trên Campus. Exit 2 với `-RequireComplete` nghĩa là còn SKIP; không phải PASS.

### Profile bot và menu

- `routes.b/garden/stadium/gate`: mảng waypoint theo đường thật của đồng đội, mỗi điểm `{ "anchor": "Campus/Anchors/...", "zone": "garden", "timeout": 180, "crouch": false }`. Có thể thêm `action` là tên thao tác trong `actions`. Phải có các waypoint và thao tác lấy chìa, mở cửa, gây tiếng động 203, thoát cửa sổ, gặp đồng đội, nhận sắt, sống qua sân và nhà ăn; integrator điền tuyến thật sau khi ghép. Không coi tên anchor là đã hoàn thành nhiệm vụ.
- `bindings.key_taken/noise_203/stadium_survived`: postcondition `{ "flag": "ID_core_cong_bo", "equals": true }`; `death_ui`: NodePath thật. `grab_stage`: một trong b/garden/stadium/gate, điểm checkpoint mà đứng yên có xác tới tóm; `guard_target`: waypoint nằm trong hàng bảo vệ cho case âm tính. Checkpoint suy từ ID đã công bố `ch3_<stage>`, death kind `zombie_grab`/`guard_shock`.
- `bindings.guard_paths`: NodePath của đủ các bảo vệ; bot good từ chối đường navmesh tiến vào khoảng 3,3 m (3 m cảnh báo + biên QA 0,3 m). `bar_head_path`: đường dẫn vùng đầu tương đối trong Zombie do lane A cung cấp, không tự đặt offset giả.
- `actions`: `{ "key": { "path": "NodePath", "method": "API", "args": ["$player"], "verify": {"flag": "ID", "equals": true} } }`. Args có thể rỗng hoặc dùng tham số cụ thể. Verify cũng có thể dùng `property` trên target. Gọi API thật rồi chờ trạng thái tối đa 3 giây; không tự ghi cờ nhiệm vụ. Với cờ có sẵn cần đảm bảo postcondition đủ phân biệt trạng thái trước/sau; thêm adapter signal nếu API chỉ xác nhận bằng signal khi ghép.
- `menu_actions`: cùng schema, bốn key `zombies_on`, `zombies_off`, `give_bar`, `refill`. Dùng API thật của core/horde/player; give_bar và refill là trợ giúp debug, không xuất hiện trong bot good. Menu khóa nút khi binding thiếu. Ngoài phiên QA tách userdata, thao tác mở phiên mới trước; chọn lại thao tác trong phiên mới.
- `jumps` và `rule_set`: menu tạo scene mới, tắt auto_start, gọi run_from(stage); không dùng bất tử chương 1. Menu và bot dùng APPDATA riêng dưới build.

T-193 điền profile theo scene/core trên main `61af631`. Waypoint có thể dùng `position: [x,y,z]` thay `anchor`; vẫn đi bằng navmesh và input, không teleport. `wait_seconds` chờ có giới hạn tại điểm nấp; `wait_for` + `wait_timeout` đợi postcondition thật (nhận sắt từ Ngư). Điểm `loop` chứa một tuyến con, `until` là postcondition và `timeout` là giới hạn; sân vận động chạy vòng tới cờ sống sót thay vì đứng yên hoặc tự đặt cờ. `verify.path` chọn node khác với node gọi API; `property` dùng dấu `:` để đọc thuộc tính lồng, ví dụ `Player` / `bar_weapon:hits_left`. Các tương tác thường có `max_distance` để từ chối gọi từ xa.

`test_ch3_profile.gd` dùng scene thật để kiểm schema, node, tương tác, bốn API debug và đường navmesh nối các waypoint. Đây là test hợp đồng, không chứng minh bot sống sót. Trên base trên, audit navmesh **FAIL** ở điểm nấp 207 `(35.75,-6.6,-4.5)` (endpoint dừng tại z=-2.5) và các waypoint ngoài trời (ví dụ Start_garden không nằm trên navmesh đang hoạt động). Giữ test báo lỗi để integrator/lane B xử lý; không đổi map hay tăng tolerance để bỏ qua. Xem Handoff T-193. `qa-menu -Chapter 3 -Smoke` kiểm bốn lần nhảy khu, cả bốn API debug ở mỗi khu và F9 đóng/mở. Không chạy bot cả chương hoặc đo lại FPS trong T-193.

Bot đi bằng InputMap của Player theo đường do NavigationServer3D trả về, kiểm tra endpoint đạt được; không teleport để qua nhiệm vụ. Khi có xác chắn ngay trước mặt, còn sắt/thể lực và chưa stunned: nhắm vùng đầu, kiểm tra ray đầu tiên trúng chính xác rồi phát chuột trái. Điện thoại được trả lời qua adapter chung khi di chuyển. Tốc độ mô phỏng giữ 1; watchdog bot 75 phút. Các tình huống chết phải có lý do đúng, vùng đúng, cảnh chết, màn chết và scene reload mới, không chỉ có một signal bắt người.

### Profile benchmark 0/20/40 xác

- Ghép `floor4_scene` và `campus_scene` cạnh nhau đúng tọa độ lane B; không bật director/story. Camera và một Node3D làm mục tiêu AI đi từ 407 qua nhà B, vườn hoa, sân vận động, cổng tới nhà ăn theo navmesh. Đây là benchmark renderer/AI, không mô phỏng người chơi và không đo toàn luồng truyện.
- `performance.route`: waypoint `{ "anchor": "Floor4/... hoặc Campus/Anchors/...", "zone": "b|garden|stadium|gate|canteen" }`. Phải bắt đầu tại 407 (zone b), kết thúc nhà ăn, đủ năm zone; thêm waypoint ở nơi cần quan sát/tụt FPS. Navmesh không tới endpoint thì FAIL. Camera đi hết từng đoạn trong `-PerfFrames` frame (mặc định 240); đây là đường khảo sát nén thời gian, không phải tốc độ đi bộ trong game.
- `performance.spawn_paths`: ít nhất 40 NodePath anchor khác nhau trong scene ghép; 20/40 dùng lần lượt 20/40 điểm đầu. Phải chọn và ghi rõ phân bố sau khi có greybox. Mỗi lần đo tạo lại thế giới và Zombie thật, gọi set_target()/wake(). Không dùng khối hộp thay mô hình xác.
- `performance.active_property/active_value`: property/trạng thái thực tế của Zombie đang hoạt động do lane A cung cấp. Kiểm tra tất cả xác mỗi frame lấy mẫu; nếu số đang hoạt động thay đổi, FAIL và không ghi đoạn đó như phép đo đúng số xác. Mức 0 không cần Zombie.
- 1280×720, VSync off, không khóa FPS, warmup mặc định 90 frame; JSON ghi GPU/CPU/Godot/renderer, mean FPS, min FPS = 1000 / frame tệ nhất, p95 frame ms, max frame ms, khu/anchor/số xác, tổng tuyến. Đạt khi mean ≥60 và min ≥30. Mỗi đoạn dưới ngưỡng phát `CH3_PERF_ALERT` ngay; launcher hiển thị trong lúc chạy. Chạy benchmark riêng, tránh Godot/editor khác để số đo có ý nghĩa. Watchdog benchmark 10 phút.

`test_ch3_tools.gd` kiểm tra policy và menu bằng **fixture test**, không dùng fixture cho report FPS hoặc kết luận chương 3 đã chạy. Nếu scene thật thiếu, menu smoke chỉ render nút vô hiệu hóa rồi báo SKIP. Ngày 2026-10-06 trên base b9fcee5 chưa có Campus/Zombie/Chapter3Director; báo cáo preflight ở `tools/reports/T-184-main-performance.json` không có số FPS.
