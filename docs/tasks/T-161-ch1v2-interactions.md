# T-161 — Chương 1 bản 2: tương tác cho 8 nhiệm vụ
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: API, tên scene/node để integrator gắn, cách thử

## Handoff (agent điền)
