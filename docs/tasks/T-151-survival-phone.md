# T-151 — Sinh tồn: nằm trên giường, nín thở, tiếng động, cúi, điện thoại và đèn pin, trạm câu đố
- Lane: A (Gameplay) | Trạng thái: done | Agent:
- Nhánh: `lane-a/T-151-survival-phone`
- Phụ thuộc: T-150 phần 1 (đã có trên `main`). Đọc `docs/design/STORY.md` (v2) §5 và bảng số giường trong `docs/tasks/T-150-chapter1-core.md`.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-152 ngay.

## Mục tiêu
Chương 1 diễn ra gần như hoàn toàn trong phòng 407:
- mở đầu: người chơi nằm trên giường và phải ngồi dậy rời giường trong 60 giây;
- vòng 2: phải **nằm trên giường của bạn cùng phòng đã chết**, nín thở, không nhúc nhích khi quản lý đứng trong phòng.

Ngoài ra cần tiếng động cho thực thể nghe, điện thoại (nhóm chat là giao diện chính của chương), đèn pin và tủ khóa số.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`, thêm key vào `game/localization/strings.csv`.

## Hợp đồng có sẵn (không sửa)
- Phím: `crouch`, `phone`, `flashlight`, `hold_breath`.
- Signal: `noise_emitted`, `player_hidden`, `breath_held`, `phone_raised`, `flashlight_toggled`, `phone_battery_changed`, `puzzle_opened`, `puzzle_closed`, `puzzle_solved`.
- `PuzzleData.load_by_id(id)`.

## Yêu cầu
1. **Giường nằm được** (`bunk_spot.gd` + `.tscn`, kế thừa `Interactable`):
   - Export: `bed_number: int` (1–4), `view: NodePath` (vị trí camera khi nằm), `exit: NodePath` (chỗ đứng khi rời giường).
   - E thì nằm lên (giường tầng trên có động tác trèo ngắn); E lần nữa thì rời giường.
   - Khi nằm: không đi được; xoay đầu giới hạn khoảng ±70° ngang, −10…+40° dọc. Phát `player_hidden(true, &"bunk")`.
   - API: `GameState` cờ `player_bed` = số giường đang nằm (0 khi không nằm); hàm `Player.lie_on(spot)` để integrator đặt người chơi nằm sẵn lúc bắt đầu chương; signal `entered`, `exited`.
   - **"Nhúc nhích" khi đang nằm:** xoay đầu nhanh (vận tốc góc vượt ngưỡng) hoặc rời giường thì phát `noise_emitted(…, 2.0, &"move")`. Ngưỡng là export.
2. **Chỗ nấp chung** (`hide_spot.gd`): gầm giường, tủ sắt, buồng vệ sinh. Dùng cho chương 3–4.
   - Export `kind`, `view`, `exit`; API `is_occupied()`, `pull_out()`; phát `player_hidden`.
   - Làm cùng một khung với `bunk_spot`.
3. **Nín thở** (khi đang nằm hoặc đang nấp):
   - Giữ Space thì im lặng, tối đa 8 giây, phát `breath_held(true/false)`.
   - Hết 8 giây thì thở hắt bắt buộc, bán kính 4 m; nghỉ 4 giây mới nín lại được.
   - Không nín thở thì cứ khoảng 3 giây có một hơi thở, bán kính 1,5 m, `source = &"breath"`.
4. **Tiếng động khi đi:**
   - mỗi bước chân phát `noise_emitted(vị trí, bán kính, &"step")`: chạy 12 m, đi 5 m, cúi 1,5 m;
   - hàm `Player.make_noise(radius, source)`;
   - chốt cửa phát tiếng 3 m, công tắc 2 m.
5. **Cúi:** giữ C hoặc Ctrl; camera khoảng 1,0 m; 1,2 m/s; không chạy; chỉ đứng dậy khi trên đầu trống.
6. **Điện thoại cầm tay** (`phone_item.gd`, gắn vào Player):
   - Q giơ hoặc hạ, phát `phone_raised`; có mô hình đơn giản trong tay. Màn hình là việc của T-155.
   - F bật đèn pin (SpotLight3D theo camera, khoảng 12 m), phát `flashlight_toggled`.
   - **Pin:** export `battery`, `drain_per_second_flashlight` (mặc định 0,2 %/giây), `drain_per_second_call` (mặc định 0,05 %/giây khi đang trong cuộc gọi; integrator bật bằng `set_in_call(bool)`).
   - Hết pin thì đèn tắt; phát signal riêng `battery_empty`.
   - API: `set_battery()`, `charge(percent_per_second)` để integrator gọi khi cắm sạc.
   - Phát `phone_battery_changed` khi đổi số nguyên.
7. **Trạm câu đố** (`puzzle_station.gd`):
   - Export `puzzle_id`; E thì phát `puzzle_opened`.
   - Người chơi đứng yên cho tới khi có `puzzle_closed` hoặc `puzzle_solved`.
   - Đã giải thì `solved = true`, phát signal `solved`, không mở lại.
8. **Scene thử:** phòng có giường tầng (4 `bunk_spot`), một tủ có trạm câu đố, chỗ tối để thử đèn pin.
9. **Test `game/tests/player/`:**
   - nằm và rời giường; cờ `player_bed`;
   - nhúc nhích phát tiếng; nín thở 8 giây rồi thở hắt;
   - bán kính tiếng bước chân; cúi;
   - pin tụt và sạc; trạm câu đố.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Handoff: API, cách gắn vào phòng 407 (cho integrator), cách thử, phần chưa thử

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Đặt tên scene đúng: `res://scenes/interaction/bunk_spot.tscn` (property `bed_number`) và `res://scenes/interaction/puzzle_station.tscn` (property `puzzle_id`). Luồng chương tự tìm hai đường dẫn này.
- Điện thoại gắn vào Player với **tên node `PhoneItem`**; có `set_battery(percent)`, `set_in_call(on)`, `charge(percent_per_second)`.
- `Player.lie_on(spot)` phải đặt cờ `GameState.player_bed` ngay khi nằm xong.

## Handoff (agent điền)

### Phiên 2026-10-04 — Lane A
- Nền `origin/main`: `37bdfa7`. Đã đọc STORY v2 §5 và số giường T-150. Commit code `3a95f4a` (`T-151: Add bunk survival, crouching, handheld phone and puzzle stations`) đã push lên `origin/lane-a/T-151-survival-phone` trước khi ghi Handoff.
- Thêm khung `HideSpot`, scene/script giường, chỗ nấp và trạm câu đố; thêm điện thoại cầm tay dưới camera Player; Player có nằm/nấp, nín thở, tiếng động, cúi và khóa điều khiển cục bộ. Có scene thử và 14 test mới, kèm UID. Chỉ sửa vùng được phép và thêm 7 key vi/en; không sửa core, UI, level, audio hoặc bản tích hợp.

### API và cách gắn cho integrator
| Thành phần | API / cách gắn |
|---|---|
| Giường | Instance `res://scenes/interaction/bunk_spot.tscn`; gán `bed_number` đúng bảng T-150: 1 Phúc trên A, 2 Việt dưới A, 3 Trung dưới B, 4 Đạt trên B. `view` và `exit` là NodePath tương đối tới Marker3D/Node3D. `view` là transform **camera**, hướng nhìn local −Z; `exit` là transform **chân người chơi**, đặt trên sàn trống. Chỉnh cả collider tương tác của từng giường để ray E chạm được. |
| Khởi đầu nằm sẵn | Sau ready, gọi `player.lie_on(spot)` (trả bool). Hoặc `spot.enter(player)` / E tương tác. Giường trên 1/4 có tween trèo mặc định `climb_seconds = 0.5`; giường dưới vào ngay. Trong lúc nằm collider thân bị tắt, velocity bằng 0, không đi được. Không tự chạy đồng hồ 60 giây hoặc xử lý chết. |
| Trạng thái nằm/nấp | `player.is_hidden()`, `spot.is_occupied()`. `GameState.player_bed` là **flag**: dùng `GameState.get_flag(&"player_bed", 0)`; vào giường đặt số 1–4, nấp thường/rời đặt 0. Mỗi Player mới khởi tạo cờ 0, core đặt lại tư thế bằng API sau khi load checkpoint. `EventBus.player_hidden(true/false, kind)`; giường dùng `&"bunk"` theo card v2. Spot phát `entered`, `exited` không tham số. |
| Rời/kéo ra | E khi đang nằm/nấp không cần nhìn lại collider; `spot.pull_out()` hoặc `player.leave_hide_spot()`. Khôi phục tại exit đã lưu lúc vào. Xóa spot cũng giải phóng Player; hủy tween đang trèo. Rời phát `noise_emitted(..., 2.0, &"move")`. `leave_hide_spot(false)` chỉ dùng dọn scene/di chuyển cưỡng chế cần im tiếng. |
| Nấp thường | Instance `res://scenes/interaction/hide_spot.tscn`, export `kind` (`&"bed"`, `&"locker"`, `&"stall"`…), `view`, `exit`; chung API chiếm chỗ/kéo ra với giường. Scene chỉ cung cấp vùng tương tác/anchor, mô hình level do lane B ghép. Đặt exit đủ trống; nếu trên đầu bị chắn thì Player rời trong tư thế cúi. |
| Đầu và nhúc nhích | Khi nằm/nấp, yaw đầu ±70°, pitch −10…+40°. `Player.restless_degrees_per_second = 180.0` là ngưỡng export; đo góc xoay thực đã clamp trong mỗi physics tick. Vượt ngưỡng phát tiếng 2 m, source `&"move"`, giới hạn nhắc lại mỗi 0,4 s để một cú rê chuột không phát hàng chục sự kiện. Không đổi hướng cả thân khi nằm. |
| Nín thở | Giữ `hold_breath` khi nằm/nấp: `holding_breath` và `EventBus.breath_held`. Tối đa 8 s rồi thở hắt radius 4, source `&"breath"`, nghỉ 4 s. Nếu vẫn giữ phím sau hồi phục thì tự nín lại. Khi không nín: mỗi 3 s phát breath radius 1,5. Rời chỗ ngừng giữ thở nhưng giữ thời gian hồi phục còn lại; pause dừng timer. Các sự kiện này là tín hiệu nghe của AI, chưa tự phát asset thở T-158. |
| Cúi và bước chân | Giữ `crouch` (C/Ctrl), mắt cao 1,0 m, capsule cao 1,15 m, tốc độ tối đa 1,2 m/s kể cả đang giữ Shift. Nhả phím chỉ đứng lên nếu capsule đứng cao 1,75 m không đụng world; không đổi shape của Player khác. Mỗi bước thực tế trên sàn phát `noise_emitted`: đi 5 m, chạy 12 m, cúi 1,5 m; giữ signal `footstep` và nhịp/bob cũ. |
| Tiếng động | `player.make_noise(radius, source)` phát tại chân Player. Chốt (cả thử chốt cửa đang mở) phát radius 3, source `&"latch"`; công tắc phát radius 2, source `&"switch"`, tại gốc đồ vật. Vật bị disabled không phát. |
| Điện thoại | Đã instance `res://scenes/player/phone_item.tscn` tại `Player/Head/Camera3D/PhoneItem`. `Q` giơ/hạ mô hình, `F` bật/tắt SpotLight3D khoảng 12 m theo camera. Có `set_raised(bool)`, `set_flashlight(bool)` cho UI/bot, phát `phone_raised`/`flashlight_toggled` khi trạng thái đổi. Q/F nhận unhandled input, không kích hoạt khi Player bị khóa bởi câu đố. Bot dùng API hoặc gửi InputEvent qua viewport; chỉ `Input.action_press()` không dispatch unhandled input cho hai phím này. |
| Pin/cuộc gọi/sạc | Export `battery` (mặc định 100), `drain_per_second_flashlight = 0.2`, `drain_per_second_call = 0.05`. `set_battery(percent)` clamp 0–100; `set_in_call(bool)` do core gọi, hai mức hao cộng nhau. `charge(percent_per_second)` đặt **tốc độ sạc liên tục**, `charge(0)` ngắt sạc, hao pin vẫn tính. Không tự ghi save/settings. Pause dừng hao/sạc. |
| Sự kiện pin | `phone_battery_changed(float)` báo phần trăm nguyên làm tròn lên (0 chỉ khi cạn), lúc ready và mỗi lần số này đổi; UI có thể đọc `battery` khi khởi tạo sau PhoneItem. Hết pin tắt đèn, local signal `battery_empty` phát một lần mỗi lần cạn; sạc lại không tự bật đèn. Core nối signal này để ngắt cuộc gọi theo luồng chương; component không tự chọn nội dung/kết nối nhóm chat. |
| Câu đố | Instance `res://scenes/interaction/puzzle_station.tscn`, gán `puzzle_id` có `PuzzleData.load_by_id()` hợp lệ. E khóa di chuyển/nhìn/shortcut điện thoại, thả chuột và phát `puzzle_opened(id)`. Chỉ `puzzle_closed(id)` hoặc `puzzle_solved(id)` khớp ID mới giải phóng. Xóa station cũng giải phóng; đóng dưới menu pause không giành lại chuột. |
| Đã giải | Dùng **`is_solved: bool`** và local **signal `solved`**. GDScript không cho khai báo biến và signal cùng tên `solved`; đây là điều chỉnh tên kỹ thuật so với câu chữ card, hành vi giữ nguyên. Khi nhận `puzzle_solved(id)`, đánh dấu true, disabled, không mở lại, phát signal một lần. Core/UI kiểm tra `station.is_solved`. |
| Khóa điều khiển | `player.acquire_control_lock(owner: Node)`, `release_control_lock(owner)`, `controls_locked()`. Không pause toàn bộ game; station tự quản lý lock. Core/UI khác dùng cùng API phải nhả đúng owner. Trạng thái pause của scene vẫn do menu/UI hiện có quản lý. |

### Kiểm tra và scene thử
- `pwsh tools/test.ps1 -Filter test_player_settings`: **`RESULT: 8 passed, 0 failed`**, exit 0.
- Lượt test sinh tồn ban đầu: **`RESULT: 13 passed, 0 failed`**; sau đó bổ sung test tiếng chốt/công tắc và kiểm tra cúi ngay từ chạy.
- `pwsh tools/test.ps1 -Filter player`: **`RESULT: 77 passed, 0 failed`**, exit 0 (gồm 14 test T-151 và hồi quy T-101…T-140).
- `pwsh tools/test.ps1`: **`RESULT: 272 passed, 0 failed`**, exit 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. `git diff --cached --check` sạch trước commit.
- `pwsh tools/capture.ps1 -Scene res://scenes/player/survival_test.tscn -Frames 2 -KeepEvery 1 -Out build/captures/T-151-survival`: **`RESULT: capture PASS (2 gameplay frames)`**. Đã xem `build/captures/T-151-survival/d441279275114a8c92d98d529e39480a/frame00000001.png`: có hai giường tầng đúng số, hai tủ, HUD hướng dẫn và phòng tối. Artifact build bị ignore, không commit ảnh.
- F6 `res://scenes/player/survival_test.tscn`: WASD/Shift đi/chạy, C/Ctrl cúi, nhìn vùng giường bấm E để nằm và E rời, Space nín thở, Q điện thoại, F đèn pin. Giường 1/4 trèo ngắn, 2/3 vào ngay. Góc phải có tủ nấp; tủ trái có khóa. HUD fixture hiển thị pin, trạng thái thở và tiếng mới nhất.
- Phím **chỉ trong fixture**: Y bật/tắt sạc 5%/s, U bật/tắt cuộc gọi, B đặt pin 1%, K phát solved cho khóa, X đóng khóa. Fixture dùng `locker_combo_601` có sẵn để thử hợp đồng; không phải câu đố/cốt truyện chương 1 và chưa có panel T-156. X/K dùng để kiểm tra mở khóa điều khiển sau E.
- **Chưa thử bằng tay:** chưa chơi bằng bàn phím/chuột thật, chưa nghe âm, chưa xem model điện thoại khi giơ trong ảnh capture, chưa duyệt cảm giác trèo/nín thở. Capture chỉ kiểm tra bố trí ban đầu. Chưa ghép vào phòng 407 chi tiết/T-150, chưa có UI T-155/T-156 hoặc AI quản lý T-152 để kiểm tra cảnh sống/chết trọn vòng. Các thao tác và timer/pin/collision đã được kiểm tra tự động, không thay cho duyệt cảm giác chơi.

### Yêu cầu thay đổi ngoài phạm vi / chặn
- **Core T-150 + lane B T-153:** đặt bốn BunkSpot vào anchor giường 407 đúng số, chỉnh view/exit/collider theo model; lúc khởi đầu gọi `lie_on(giường 3)`, quản lý timer 60 s và checkpoint. Luồng kiểm tra quản lý đọc flag `player_bed` và nghe signal sinh tồn. T-151 không tự quyết chết/thắng hoặc thời điểm quản lý xuất hiện.
- **Core T-150 + lane D T-155/T-156:** cấp PuzzleData cho tủ của Đạt, gán ID vào station, nối panel đóng/giải; ghép màn điện thoại, cuộc gọi, UI pin. Dùng `is_solved` (khác tên biến trong mô tả card vì xung đột tên với signal); gọi `set_in_call`, `charge`, xử lý `battery_empty`/mất kết nối và lưu/khôi phục pin theo checkpoint.
- **Lane E T-158 / core:** nối các sự kiện breath/move/step vào âm phù hợp và AI nghe. Không cần thêm signal, input action, setting hay plugin. T-151 không sửa các file thuộc lane khác.
- Không còn blocker code/test/push của T-151. Không có câu hỏi thiết kế chưa giải quyết. Sandbox gặp lỗi Windows 1326; lệnh cần thiết chạy qua cơ chế cấp quyền ngoài sandbox. Không cài công cụ và không làm việc trong `D:\GAME_DEMO`.

### Review (integrator, 2026-10-04)
- **Đạt, đã merge.** Đúng phạm vi, 14 test mới, Handoff rõ và trung thực. Đổi tên `solved` thành `is_solved` vì trùng tên với signal là hợp lý.
- Xung đột `strings.csv` với key chương 1 của core: giữ cả hai.
- Đã ghép vào chương 1: luồng chương dùng `bunk_spot.tscn` thật, `Player.lie_on()`, `leave_hide_spot()`, `PhoneItem`. Chụp khung hình: nằm trong mùng giường 3 đúng. Góc camera khi nằm hơi thấp; lane B chỉnh `View` theo mô hình ở T-153.
