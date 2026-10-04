# T-161 — Chương 1 bản 2: tương tác cho 8 nhiệm vụ
- Lane: A (Gameplay) | Trạng thái: done | Agent:
- Nhánh: `lane-a/T-161-ch1v2-interactions`
- Phụ thuộc: T-151, T-152. **Đọc kỹ `docs/design/CH1_V2_MISSIONS.md`** (D-039, D-040).
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Các đồ vật và thao tác người chơi cần cho 8 nhiệm vụ mới của chương 1. Lane A chỉ làm **cơ chế tương tác**; luật thắng/thua và thứ tự diễn biến do integrator (T-160) điều khiển qua signal và API.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (core, không sửa)
`EventBus.wall_tapped(wall_id)`, `phone_call_lost/restored`, `noise_emitted`, `puzzle_opened/closed/solved`. `PuzzleData.max_attempts`, `lockout_seconds`.

## Yêu cầu
1. **Gõ tường** (`wall_knock.gd` + `.tscn`, kế thừa `Interactable`):
   - export `wall_id` (`&"wall_406"`, `&"wall_408"`);
   - mỗi lần E phát `EventBus.wall_tapped(wall_id)` và `noise_emitted(…, 3.0, &"knock")`;
   - không giới hạn tốc độ gõ, không tự giải mã (core giải mã theo thời gian giữa các lần gõ);
   - lời nhắc "Gõ tường" (key mới).
2. **Nín thở tối đa đặt được:** thêm export `max_breath_seconds` trên Player (mặc định 8). Core đặt 6 cho Insane. Thở hắt và thời gian nghỉ theo giá trị này.
3. **Chỗ lục đồ** (`search_spot.gd`, kế thừa `Interactable`):
   - export `spot_id`, `prompt_key`, `document_id` (giấy nhận được), `searched` (chỉ lục một lần);
   - E thì phát signal `searched(spot_id)` và mở giấy (`EventBus.document_opened(document_id)`) nếu có;
   - dùng cho: mở tủ Việt, lật nệm Phúc, lục sọt rác.
4. **Công tắc đèn bàn:** dùng lại `light_switch.gd` hoặc biến thể nhỏ, gắn vào đèn bàn (đèn do lane B cung cấp). Cờ `GameState.desk_lamp_on`.
5. **Ổ điện kéo dài và dây mạng** (`power_strip.gd`, `lan_cable.gd`):
   - ổ điện: 3 công tắc, mỗi cái là một vùng tương tác riêng; signal `switch_toggled(index, on)`; API `trip()` (core gọi khi chập: tắt cả 3) và `set_locked(seconds)` (không bật được trong thời gian chờ);
   - dây mạng: export `cable_id` (`&"blue"`, `&"gray"`); E khi ở gần thì "cầm" dây, E vào ổ mạng trên tường thì cắm (signal `plugged(cable_id)`); E vào dây đang cắm thì rút.
   - Mô hình do lane B làm (T-162); lane A làm vùng tương tác và trạng thái, gắn vào anchor của B.
6. **Tủ khóa số:** trạm câu đố hiện có giữ nguyên. Giới hạn số lần thử do panel của lane D (T-163) xử lý.
7. **Quản lý:** thêm chế độ nghe cử động. Export `hear_movement_while_present: bool`; khi bật, mọi `noise_emitted` có `source` là `move` hoặc `step` trong 4 m từ đầu, kể từ lúc quản lý vào phòng tới lúc rời phòng, đều làm phát `answered(true)` sớm (hoặc signal riêng `heard_movement`). Tiếng thở vẫn chỉ tính trong lúc nghe sau câu hỏi.
8. **Cảnh chết góc nhìn thứ nhất (D-042):** đọc mục "Cảnh chết" trong `CH1_V2_MISSIONS.md`.
   - Player nghe `EventBus.player_death_started(kind)` và diễn trong khoảng 3 giây: khóa điều khiển, camera chuyển động, hạt máu.
   - **`fall_back`:** khựng lại, máu phụt (GPUParticles kiểu PS1, hạt to, đỏ sẫm) từ phía dưới khung nhìn, ngã ngửa ra sau, camera chạm sàn nhìn lên trần, thở dốc chậm dần.
   - **`manager_kill`:** quay camera nhìn thẳng vào quản lý (`DormManager` trong scene; không có thì giữ hướng), giữ khoảng 0,8 giây cho cú lao và chém của quản lý (`kill_player()` đã có), máu bắn lên camera, ngã nghiêng sang bên.
   - **`bed_burst`:** đang nằm, máu trào lên trong khung nhìn, camera rung co giật, chậm dần.
   - Xong thì phát signal riêng `death_animation_finished` của Player.
   - **"Giảm hù dọa":** không có hạt máu bắn vào camera, chỉ ngã.
   - Tải lại checkpoint (scene mới) thì Player trở lại bình thường.
9. **Test:**
   - gõ tường phát đúng signal;
   - `max_breath_seconds`;
   - chỗ lục chỉ lục một lần và mở giấy;
   - ổ điện `trip`/`set_locked`;
   - dây mạng cắm/rút đúng `cable_id`;
   - quản lý nghe cử động khi bật cờ, không nghe tiếng thở ngoài lúc nghe;
   - mỗi `kind` của cảnh chết khóa điều khiển, đưa camera về tư thế cuối đúng và phát `death_animation_finished`.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Handoff: API, tên scene/node để integrator gắn, cách thử

## Handoff (agent điền)

### Kết quả Lane A — 2026-10-05

- Nhánh tạo từ `origin/main` tại `c97874e`; commit code `0f44e82` đã push trước khi cập nhật Handoff. Chỉ thay đổi vùng được phép, thêm 11 key vi/en; không sửa core, level, audio, UI, STATUS hay project settings.
- Hoàn tất cơ chế gõ tường, lục một lần, đèn bàn, ba công tắc ổ điện, cầm/cắm/rút dây mạng, nín thở cấu hình được, manager nghe cử động và ba cảnh chết Player. Thêm scene thử và 16 test. Trạm câu đố giữ nguyên; giới hạn thử thuộc panel T-163.

### Scene/API để tích hợp

Tất cả scene tương tác dưới `res://scenes/interaction/`; node tương tác dùng layer 4, mask 0. `Placeholder` là mesh thử có thể ẩn khi gắn model/anchor T-162; giữ CollisionShape3D/vùng tương tác.

| Scene / node | Cấu hình và API |
|---|---|
| `wall_knock.tscn` / WallKnock | Export `wall_id`, mặc định `&"wall_406"`; mỗi E phát `EventBus.wall_tapped(wall_id)` và noise tại tường, radius 3, source knock. Không debounce/cooldown/giải mã. |
| `search_spot.tscn` / SearchSpot | Export `spot_id`, `document_id`, `prompt_key` kế thừa, `is_searched`. Signal `searched(spot_id)`, sau đó `document_opened(document_id)` nếu ID không rỗng. Latch trước signal để tránh lục lại do callback; disable sau lần đầu. |
| `desk_lamp_switch.tscn` / DeskLampSwitch | Dùng nguyên light_switch; gán `light` của đèn bàn trước ready. Cờ `desk_lamp_on` đồng bộ cả khi visibility của đèn thay đổi bên ngoài. |
| `power_strip.tscn` / PowerStrip | Ba vùng riêng `Switch1`, `Switch2`, `Switch3`. Signal `switch_toggled(index, on)` dùng index **0..2**, tương ứng nhãn 1..3. Trạng thái `switches` khởi đầu false; `toggle(index)`, `trip()`, `set_locked(seconds)`, `lock_remaining`. trip tắt cả ba trước khi báo các mục vừa tắt; gọi lại không phát thừa. |
| `lan_cable.tscn` / LanCable | Export `cable_id` blue/gray; enum `State.LOOSE/HELD/PLUGGED`, `state`, `holder`, `socket`; signal `plugged(cable_id)`, `unplugged(cable_id)`. Cầm dây theo camera, tạm bỏ layer tương tác để không chắn ray; cầm dây khác trả dây cũ về vị trí ban đầu. `drop()` trả connector về vị trí trước khi cầm. |
| `lan_socket.tscn` / LanSocket | E cắm dây đang cầm vào socket; E vào connector hoặc socket đang có dây thì rút thành dây đang cầm. Socket cũng phát `plugged/unplugged(cable_id)`; core chỉ nối một nguồn (socket hoặc cable) để tránh xử lý hai lần. Cả xanh/xám đều cắm được; core quyết định có mạng. |

- **Khác tên trong card:** dùng `is_searched` cho biến export vì GDScript không cho biến và signal cùng tên `searched`. Signal vẫn đúng `searched(spot_id)`. Khi phục hồi checkpoint gán is_searched trước cho phép tương tác; nếu cần reset cùng instance thì đặt is_searched=false và enabled=true. Không tự thêm dữ liệu giấy/luật nhiệm vụ.
- PowerStrip chỉ chặn **bật** trong thời gian khóa, vẫn cho tắt. Khóa dừng theo pause; hết thời gian bật lại được. Core gọi `trip(); set_locked(20)` khi chập và tự xử lý ánh sáng/âm chập/router; scene thử dùng T để thử API này, không gán ý nghĩa nhiệm vụ cho công tắc 3.
- Gắn từng Switch vào anchor của model B được; nếu đổi parent thì gán export `strip` trước ready. Màu/đèn báo và chuyển động model thuộc B. Gắn connector LanCable vào đầu dây có thể di chuyển; không gắn cả sợi dây dài làm con của connector đi theo camera.
- Player export `max_breath_seconds = 8.0`; core đặt 6 cho Insane. Hết giới hạn thở hắt radius 4; nghỉ bằng nửa giới hạn (giữ tỉ lệ cũ 8/4, Insane 6/3). Giá trị runtime không hữu hạn về 8, quá nhỏ dùng 0,1. Không thay input action.
- Manager export `hear_movement_while_present = false`: core bật khi vào/mở cửa phòng và tắt khi rời phòng. Mỗi noise move/step cách đầu ≤4 m phát signal riêng `heard_movement()` ngay, kể cả đang đi/nói/chém; không tự giết. `answered(heard)` vẫn chỉ kết thúc câu hỏi như cũ, tiếng thở ngoài LISTENING bị bỏ qua. Pause và manager đã rời cây scene không nhận noise. Core giữ quyền dàn vị trí/thời điểm hiện diện.
- Player nghe `EventBus.player_death_started(kind)`, có child runtime `DeathAnimation` (script `player_death.gd`) và signal **`death_animation_finished()`** trên Player. fall_back/manager_kill/bed_burst dài 3 giây game time, pause được, signal kết thúc một lần; khóa điều khiển giữ tới khi thay scene. kind none/không hợp lệ bỏ qua, không khóa và không phát completion; core xử lý riêng.
- fall_back khựng rồi ngã ngửa, camera thấp sát sàn nhìn lên; manager_kill quay nhìn manager gần nhất trong group `dorm_manager` cùng world trong 0,8 s rồi ngã nghiêng (không có manager thì giữ hướng ban đầu); bed_burst rung giảm dần tại giường. Volume camera nhỏ tránh xuyên tường/sàn; bị tường chắn ngang vẫn rơi xuống.
- GPUParticles3D dùng hạt hộp đỏ sẫm, 15 FPS, không thêm texture/plugin. Giảm hù dọa bỏ máu, rung và khóa nhìn mặt quản lý; manager_kill chuyển nhìn lên trần trong 0,3 s và ngã ngay để tránh khuôn mặt sát camera; thay đổi setting trực tiếp ẩn/dừng hạt. Camera không bị head-bob setting hoặc đóng panel khác đặt lại khi đang chết. Scene Player mới trở về trạng thái bình thường. Âm thở/tiếng chết và lớp máu màn hình do E/D xử lý.

### Cách thử và kiểm chứng

- Mở `res://scenes/interaction/ch1v2_interactions_test.tscn`, F6. E dùng props, T trip/khóa ổ điện 20 s, 1 fall_back, 2 manager_kill, 3 bed_burst, R tải lại; Esc menu có Giảm hù dọa. Scene có Player nín 6 s, BunkSpot, manager capsule, đèn và các props placeholder. Ba chỗ lục chưa gán document_id thật trong scene thử; việc mở giấy đã test bằng signal.
- Test mới: tương tác 9/9, cảnh chết 7/7; survival cũ 14/14, Player settings 8/8 và smoke scene 1/1 đạt ở các lượt lọc. Toàn bộ `pwsh tools/test.ps1`: **`RESULT: 371 passed, 0 failed`**, exit 0. `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0.
- Lượt toàn bộ trước báo 370 đạt/1 lỗi ở `test_freed_player_leaves_no_signal_connections`: component mới đăng ký thêm listener settings. Đã chuyển refresh reduce_scares qua listener sẵn có của Player, giữ nguyên test cũ; kết quả bản cuối ở dòng trên và log `build/T-161-test-final.log`.
- Đã render và xem các khung hình đầu/giữa/cuối của ba cảnh bằng Godot Movie Maker, mỗi cảnh 100 frame. Ảnh/log cục bộ trong `build/captures/T-161-deaths/`: fall_back, manager_kill, bed_burst_fixed. Lượt bed_burst đầu phát hiện callback noise tới manager đã tháo khỏi tree; đã sửa và thêm test hồi quy. Render lại: `RESULT: bed_burst capture PASS (100 frames; no engine errors)`.
- Chưa chơi bằng chuột/phím trực tiếp, chưa nghe bằng tai, chưa duyệt với model/anchor phòng T-162 và chưa chạy đủ 8 nhiệm vụ trong bản ghép T-160. Render manager dùng capsule dự phòng, không thay thế duyệt hình ảnh model cuối.
- Lệnh shell/Godot chạy ngoài sandbox sau lỗi khởi chạy helper 1223. Không cài công cụ mới; ảnh/log/userdata kiểm thử nằm trong workspace.

### Yêu cầu thay đổi ngoài phạm vi

1. **Core T-160:** instance props vào anchor B, gán spot/document/wall IDs, nối searched/switch_toggled/plugged/unplugged với nhiệm vụ và checkpoint. Đặt max_breath_seconds=6; bật/tắt hear_movement_while_present đúng cửa sổ hiện diện và nối heard_movement với kết quả luật. Giới hạn thử tủ do T-163, Lane A không sửa PuzzleStation.
2. **Core — thứ tự cảnh chết:** bản nền hiện gọi kill_player rồi player_caught mới _die/player_failed, chưa phát player_death_started. Khi ghép D-042 cần đánh dấu đang chết trước, phát player_death_started(manager_kill) đồng thời bắt đầu kill_player, chờ Player.death_animation_finished rồi mới player_failed/màn chết/reload. Không để player_caught từ cú chém gây khởi động lần hai hoặc phủ màn chết trước 3 giây. Player chỉ diễn camera, không gọi kill_player lần nữa. kind none không chờ signal Player.
3. **Lane B/E/D:** thay Placeholder/gắn anchor/model T-162, diễn tủ/nệm/tay nắm theo signal core; E nối tiếng gõ, chập, cầm/cắm/rút và âm chết/thở dốc với event thích hợp; D nối lớp máu/màn đen với player_death_started và tôn trọng reduce_scares. Không sửa các file lane này trong T-161.

Không có blocker còn lại trong phạm vi T-161. Hai mục checklist của card đã đạt; các yêu cầu ghép ở trên dành cho T-160/B/D/E, không phải phần đã được chơi thử trong chương thật.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge.** Đúng phạm vi; 16 test mới; ba cảnh chết đã render kiểm tra. Handoff rất chi tiết, ghi rõ chỗ khác card (công tắc 0..2, `is_searched`, signal `heard_movement` riêng).
- **Ghép:**
  - `power_strip.tscn` gắn dưới `Anchors/PowerStrip` của B, vùng `Switch1..3` đặt theo mô hình B, đồng bộ `set_switch`/`set_tripped`;
  - `lan_cable.tscn` ở `LanBlueEnd`/`LanGrayEnd`, `lan_socket.tscn` ở `LanWallPort` (chỉ nối signal của socket), hình dây do `Room407.set_plugged` của B;
  - `desk_lamp_switch.tscn` ở `DeskLampSwitch`, `light` là `Room407DeskLamp`;
  - `search_spot`, `wall_knock`, `max_breath_seconds = 6`, `heard_movement`, `death_animation_finished`.
- **Integrator sửa `manager.gd`:** thêm export `hear_radius` (mặc định 4 như card). Chương 1 Insane đặt 7,5 m, vì phòng 407 mới rộng 8 m làm giường dãy A ra ngoài tầm 4 m.
- Thứ tự cảnh chết theo đúng yêu cầu số 2: phát `player_death_started(manager_kill)` cùng lúc `kill_player()`, chờ `death_animation_finished` rồi mới `player_failed`.
