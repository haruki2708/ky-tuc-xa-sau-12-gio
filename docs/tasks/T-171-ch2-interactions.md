# T-171 — Chương 2: cầm giẻ, bịt miệng xác, buồng tắm, cảnh chết mới
- Lane: A (Gameplay) | Trạng thái: done | Agent:
- Nhánh: `lane-a/T-171-ch2-interactions`
- Phụ thuộc: T-161. **Đọc kỹ `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn: hết ngày 2026-10-07.**

## Mục tiêu
Cơ chế tương tác cho chương 2. Lane A chỉ làm **cơ chế**; luật thắng/thua và thứ tự diễn biến do core (T-170) điều khiển qua signal và API.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (core, không sửa)
- `EventBus.corpse_state_changed(bed, state)`, `chain_choice_blocked(blocked)`, `shower_choice_made(run_water)`, `shower_steam_changed(level)`.
- `EventBus.player_death_started(kind)` có thêm `corpse_lunge`, `scald`.

## Yêu cầu
1. **Cầm đồ một tay** (`carry_item.gd` + `.tscn`, kế thừa `Interactable`):
   - export `item_id` (`&"rag"`, `&"towel"`, `&"shirt"`), `prompt_key`;
   - E thì cầm, món đồ theo camera như dây mạng T-161; chỉ cầm **một món một lúc**, cầm món khác thì món cũ rơi về chỗ cũ;
   - signal `picked(item_id)`, `dropped(item_id)`; API `consume()` (core gọi khi đồ đã dùng để bịt miệng: món đồ biến mất khỏi tay).
2. **Bịt miệng xác** (`gag_spot.gd`, kế thừa `Interactable`):
   - export `bed` (1, 2, 4); gắn ở đầu xác, anchor của lane B;
   - chỉ hiện lời nhắc "Bịt miệng" khi đang cầm đồ; E thì phát signal `gag_requested(bed, item_id)`. **Core quyết định** có bịt được không và gọi `consume()`;
   - xác đã bịt thì tắt tương tác (`set_gagged(true)`).
3. **Cửa nhà vệ sinh kẹt** (`stuck_door.gd`): cần **đẩy vai 3 lần** (E). Mỗi lần: camera giật nhẹ, `noise_emitted(…, 6.0, &"door_bash")`, signal `bashed(count)`. Lần 3 thì gọi `set_bathroom_door_open(true)` của `Room407` (T-162) và phát `opened`. API `reset()`.
4. **Buồng tắm** (`shower_stall.gd`, Area3D): signal `player_inside_changed(inside)`, thuộc tính `player_inside`. Gắn vào vùng buồng tắm của lane B (`Anchors/ShowerStall`, T-172).
5. **Nút trên màn hình vòi sen**: hai vùng `ShowerYes`, `ShowerNo` (E) phát `EventBus.shower_choice_made(true/false)`; API `set_enabled(bool)` (core bật khi đang đếm ngược). **Lau màn hình**: giữ E 1 giây trên vùng `ShowerScreen`, phát signal `wiped()`. Bấm được cả khi đứng trong buồng tắm.
6. **Cảnh chết mới** (Player nghe `player_death_started`, khoảng 3 giây, phát `death_animation_finished` như T-161):
   - **`corpse_lunge`:** quay camera về xác gần nhất (group `ch2_corpse`), xác lao tới (lane B diễn), camera giật mạnh, ngã ngửa, máu bắn camera;
   - **`scald`:** khựng lại, camera rung co rút, nhìn xuống tay (không cần mô hình tay; rung và nghiêng), gục xuống sàn buồng tắm, hơi nước trùm (lớp hơi nước và bỏng là của lane D);
   - "Giảm hù dọa": không có máu, không lao sát mặt.
7. **Test:** cầm/đổi/thả đồ, bịt miệng chỉ khi đang cầm, cửa kẹt 3 lần, vùng buồng tắm, nút Có/Không chỉ khi được bật, lau giữ 1 giây, hai cảnh chết. Scene thử `ch2_interactions_test.tscn`.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Scene thử có đủ đồ để thử bằng tay
- [x] Handoff: tên scene, API, signal

## Handoff (agent điền)

### Đã làm

- Hoàn thành cơ chế T-171 trên nhánh `lane-a/T-171-ch2-interactions`, từ `origin/main` tại `c68888b`. Commit mã `3a89b5f` đã push trước khi ghi Handoff.
- Có đồ cầm một tay, vùng bịt miệng, cửa kẹt ba lần đẩy, vùng buồng tắm, hai lựa chọn vòi sen và lau màn hình. Thêm camera `corpse_lunge` / `scald`, giữ khóa điều khiển và phát `Player.death_animation_finished` một lần sau khoảng 3 giây; core vẫn quyết định luật và chuyển/reload scene.
- Thêm 13 test (8 tương tác, 5 cảnh chết), scene thử bằng primitive và 13 key dịch vi/en. Không thay đổi core, scene môi trường, UI hay luật chương 2.

### Scene, API và signal để tích hợp

Các scene dưới đây nằm tại `res://scenes/interaction/`; script tương ứng tại `res://scripts/interaction/`.

| Scene / component | Hợp đồng |
|---|---|
| `carry_item.tscn` / `CarryItem` | Export `item_id: StringName` (`rag`, `towel`, `shirt`) và `prompt_key`. E cầm; đổi món tự `drop()` món cũ về transform lúc nhặt. `picked(item_id)`, `dropped(item_id)`; `CarryItem.held_by(player)` trả món đang cầm. `consume()` ẩn/tắt món đang cầm, bỏ holder, không phát `dropped`; gọi lặp không có tác dụng. Mất player thì món chưa dùng trở về chỗ cũ. |
| `gag_spot.tscn` / `GagSpot` | Export `bed` là 1/2/4. `gag_requested(bed, item_id)` chỉ phát khi có đồ và chưa bịt. Player dùng hook `can_interact(player)` để ẩn prompt khi tay trống. Core chấp nhận thì lấy món qua `held_by`, gọi `consume()` và `set_gagged(true)`; từ chối thì không cần đổi trạng thái. `set_gagged(false)` mở lại vùng. |
| `stuck_door.tscn` / `StuckDoor` | Gán export `room` tới Room407, hoặc đặt dưới ancestor có `set_bathroom_door_open(bool)`. Mỗi E: `bashed(count)`, noise tại cửa bán kính 6 nguồn `door_bash`, camera giật nhẹ 0,22 giây. Lần ba gọi mở cửa rồi phát `opened`, tắt tương tác. `reset()` trả count về 0, bật lại và đóng cửa. Thiếu controller thì không đếm/không giả báo mở cửa. |
| `shower_stall.tscn` / `ShowerStall` | Area mask player, không cản raycast. `player_inside: bool`, `player_inside_changed(inside)`, cập nhật cả khi player bị xóa. Shape mẫu rộng 1,4 m, cao 2,2 m; origin tại sàn. |
| `shower_choice.tscn` / `ShowerChoice` | Instance hai vùng tên `ShowerYes` / `ShowerNo`; export `run_water` lần lượt true/false, prompt lần lượt `PROMPT_CH2_SHOWER_YES` / `PROMPT_CH2_SHOWER_NO`. Mặc định tắt; core gọi `set_enabled(bool)` theo cửa sổ đếm ngược. E phát `EventBus.shower_choice_made(run_water)`. Core chịu trách nhiệm đóng cửa sổ sau lựa chọn. |
| `shower_screen.tscn` / `ShowerScreen` | E bắt đầu giữ khi raycast đang trỏ đúng vùng. Giữ liên tục 1 giây phát `wiped()` đúng một lần mỗi lượt giữ; `progress` là số giây đã giữ. Nhả E, mất focus, tắt `enabled` hoặc khóa điều khiển sẽ xóa tiến độ; cần nhấn E lại để bắt đầu lượt mới. Pause đóng băng tiến độ. Core xử lý hiệu ứng giảm hơi nước khi nhận `wiped`. |

`Player` nhận hai kind mới qua `EventBus.player_death_started`. `corpse_lunge` tìm node gần nhất trong group `ch2_corpse` cùng World3D, ngắm `GazeTarget` nếu có, nếu không tìm child `Head`, cuối cùng dùng origin xác. Quay về xác trong 0,7 giây đầu rồi giật/ngã và bắn máu. Không có/xóa xác giữa chừng vẫn hoàn tất an toàn. `scald` khựng/rung, nhìn xuống và gục xuống sàn, không tạo đợt bắn máu. Cả hai dùng camera sweep sẵn có để tránh xuyên world.

Thiết lập `accessibility/reduce_scares` dùng listener sẵn có của Player: cảnh xác bỏ khóa nhìn mặt, quay lên trần sớm, không giật/máu; cảnh nước nóng bỏ rung co rút. Hoạt ảnh xác ở lane B phải cùng tôn trọng thiết lập này (xem yêu cầu tích hợp bên dưới).

### Cách kiểm tra và kết quả

- Scene: `res://scenes/interaction/ch2_interactions_test.tscn`. Có 3 món, 3 vùng bịt tương ứng giường 1/2/4, cửa có collider, vùng tắm và đủ màn hình/nút. Đây là fixture API: bịt miệng luôn được chấp nhận để minh họa `consume`, không mô phỏng luật nối từ.
- WASD đi, E tương tác, giữ E lau; T bật/tắt cả hai nút; 1 xem xác lao, 2 xem nước nóng (đưa player vào vùng tắm), R nạp lại fixture, Esc mở cài đặt để thử giảm hù dọa. Có thể dùng user arg `--death-preview=corpse_lunge` hoặc `--death-preview=scald` khi chụp tự động.
- `pwsh tools/test.ps1 -Filter player`: `RESULT: 124 passed, 0 failed`.
- `pwsh tools/test.ps1`: `RESULT: 427 passed, 0 failed` (exit 0).
- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)` (exit 0).
- Đã chụp và xem khung hình overview, xác lao/bắn máu và nước nóng; mỗi lượt 95 frame, Godot exit 0, stderr rỗng. Nhãn 3D được ẩn khi preview chết để không che camera. Log/ảnh cục bộ tại `build/T-171-*`, không commit artifact build.
- Chưa chơi thử bằng tay toàn chương 2 với scene/luật tích hợp; các kết quả trên là test tự động và kiểm tra khung hình fixture. Checklist scene đánh dấu vì fixture đã có đủ đồ để người review thử.

### Yêu cầu thay đổi / nối ngoài phạm vi

- Core T-170 và lane B T-172: instance các vùng vào anchor RagSpot/TowelSpot/ShirtSpot, Gag1/Gag2/Gag4, ShowerStall và ba vùng màn hình. Gán Room407 cho cửa; thay/ẩn child `Placeholder` khi dùng model chính thức và chỉnh shape theo model. A không tự sửa scene môi trường.
- Core nối `gag_requested` tới luật chấp nhận/từ chối; nối `wiped` tới hơi nước; điều khiển `set_enabled` của Có/Không và dùng `player_inside` khi xét luật. Các component không tự đổi lượt hay tuyên bố thắng/thua.
- B/core diễn xác lao đồng bộ 0–0,7 giây đầu của `corpse_lunge`; khi bật giảm hù dọa phải bỏ hoạt ảnh lao sát mặt. Group `ch2_corpse` đặt trên root xác; có thể thêm `GazeTarget` tại đầu nếu rig mới không có child `Head`.
- Lane D nối lớp hơi nước/bỏng cho `scald`; lane E có thể dùng noise `door_bash` cho tiếng đẩy cửa. Không cần thêm signal EventBus, input action hay plugin cho phần A.

### Còn dở / bị chặn

- Không có mục checklist T-171 còn dở và không có blocker trong phạm vi Lane A. Các bước tích hợp trên thuộc core/B/D/E; chưa xác nhận trải nghiệm cuối trong toàn chương 2. Không có câu hỏi thiết kế mới.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge.** Đúng phạm vi; 13 test; API rõ. Ghép:
  - `carry_item` ở `RagSpot`, `TowelSpot`, `ShirtSpot` (ẩn model của B khi cầm);
  - `gag_spot` ở `Gag1/2/4` (core nhận qua `CarryItem.held_by`);
  - `stuck_door` dưới `Extension/BathroomDoor`;
  - `shower_stall` dùng box của B;
  - hai `shower_choice` ở `ShowerYes`/`ShowerNo`, core bật/tắt theo đếm ngược;
  - `shower_screen` (lau) ở `ShowerScreen`.
