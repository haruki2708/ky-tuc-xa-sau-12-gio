# T-182 — Chương 3: xác sống, thanh sắt, thể lực, đồng đội, bảo vệ, cảnh chết mới
- Lane: A (Gameplay) | Trạng thái: done | Agent:
- Nhánh: `lane-a/T-182-ch3-zombies`
- Phụ thuộc: T-134 (`pursuer.gd`), T-161, T-171, T-177. **Đọc kỹ `docs/design/CH3_DESIGN.md`** (D-052, D-054).
- **Hạn đề xuất: hết ngày 2026-10-08.** Lane B push greybox khuôn viên trong ngày 2026-10-07. Trước đó tự dựng cảnh thử nhỏ (sàn phẳng, một cầu thang, navmesh).

## Mục tiêu
Cơ chế chơi của chương 3:
- xác sống đông, chậm, nghe tiếng, vây ở chỗ hẹp;
- **thanh sắt** đập đầu làm xác tê liệt, cong dần rồi gãy;
- **thể lực** khi chạy;
- **Minh Nhật và Ngư** chạy theo đường dựng sẵn;
- **bảo vệ** ở cổng (Tổng tắc điều 4);
- hai cảnh chết mới.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`

## Hợp đồng có sẵn (core, không sửa). Đọc chú thích trong `event_bus.gd`, mục "Chapter 3"
- Signal mới: `zombie_woke(zombie)`, `zombie_stunned(zombie, seconds)`, `bar_picked(hits_left)`, `bar_swung(hit, hits_left)`, `bar_broken()`, `stamina_changed(value, exhausted)`, `companion_state_changed(member, state)`, `guard_warned(guard, warned)`.
- Signal có sẵn dùng lại:
  - `noise_emitted(position, radius, source)`: xác nghe tiếng;
  - `player_caught(entity_id)`: phát `&"zombie"` khi bị tóm, `&"guard"` khi đập trúng bảo vệ hoặc bước quá vùng cảnh báo; core giết và nạp checkpoint;
  - `player_death_started(kind)`: thêm kind `&"zombie_grab"`, `&"guard_shock"`.
- Anchor và tư thế mô hình: card T-183 của lane B (`Campus/Anchors/...`, `Paths/Nhat`, `Paths/Ngu`, `ZombieSpawns`, `ZombieIdle`, `BarSpawns`, `GuardLine`, `Zones/GuardRadius`).

## Yêu cầu
1. **Xác sống** `res://scenes/entity/zombie.tscn` (`class_name Zombie`; nên dùng lại cách di chuyển và tránh tường của `Pursuer`, nhưng dùng navmesh):
   - tốc độ khoảng **1,5 m/s** (`@export`), lên cầu thang chậm hơn khoảng 30%;
   - trạng thái `asleep` (đứng, ngồi, nằm im; thức khi người chơi trong 25 m **và** thấy hoặc nghe được), `hunting`, `stunned`;
   - nghe `noise_emitted` trong bán kính của tiếng: chạy 12 m, đi bộ 5 m, thở dốc khi cạn thể lực 8 m, đập sắt 10 m, bình cứu hỏa 25 m;
   - **tóm:** người chơi trong khoảng **1 m** trước mặt xác đang săn → phát `player_caught(&"zombie")` (chết ngay, D-052);
   - **tê liệt:** `stun(seconds)` → gục, không tóm, rồi đứng dậy;
   - **cửa:** không mở được cửa; đập cửa gỗ đã đóng khoảng 10 giây thì phá được (`door_bash_seconds`). Dùng cho cửa 407 và cửa 203;
   - API: `wake()`, `sleep_pose(pose)`, `stun(seconds)`, `is_stunned()`, `set_target(node)`, `set_body(scene)` (mô hình lane B).
2. **Quản lý đám xác** `scripts/entity/zombie_horde.gd` (`class_name ZombieHorde`), core gọi:
   - `spawn(zone: StringName, count: int)` tại `ZombieSpawns/<zone>`; `place_idle(zone)` tại `ZombieIdle/<zone>`;
   - **giới hạn khoảng 40 xác hoạt động** (`max_active`); xác xa hơn 60 m hoặc khuất thì cập nhật thưa (3–4 lần mỗi giây), không phát âm thanh;
   - `clear_zone(zone)`, `clear_all()`, `active_count()`.
3. **Thanh sắt** (`res://scenes/interaction/iron_bar.tscn`, nhặt bằng E; vũ khí cầm tay gắn vào player):
   - chuột trái vung; tầm 1,5 m; **trúng khi nhắm vào đầu** (vùng đầu của xác); trúng thì `stun(5.0)`;
   - **8 lần trúng thì gãy** (`max_hits`); trượt không tính; mỗi cú vung tốn một ít thể lực;
   - phát `bar_picked`, `bar_swung`, `bar_broken`;
   - core có thể trao thanh sắt trực tiếp (Ngư đưa): `give_bar(hits)`;
   - **cảnh báo bảo vệ:** vung trúng bảo vệ → `player_caught(&"guard")`.
4. **Thể lực** (trong player, 0..1):
   - chạy nhanh tốn khoảng 1/12 mỗi giây (chạy liên tục khoảng 12 giây); đi bộ hồi chậm; đứng yên hồi nhanh;
   - cạn → **không chạy nhanh được** tới khi hồi 30%, **thở dốc** (phát `noise_emitted` bán kính 8 m mỗi 1,5 giây);
   - phát `stamina_changed`; chỉ bật ở chương 3 (`stamina_enabled`), chương 1–2 không đổi.
5. **Đồng đội** `res://scenes/entity/companion.tscn` (mô hình Minh Nhật, Ngư của lane B):
   - `follow_path(path_root: Node3D)`: chạy lần lượt qua `P01, P02…`; tới điểm có `_Wait_` thì **dừng chờ** tới khi người chơi trong 6 m, rồi chạy tiếp;
   - người chơi ở xa hơn 25 m quá 8 giây → `companion_state_changed(member, &"calling")` (core cho họ gọi điện);
   - **không bị tóm, không chết.** Xác lại gần thì họ né hoặc đập (hoạt cảnh đơn giản), không đánh giúp người chơi;
   - chạy hơi nhanh hơn xác, chậm hơn người chơi chạy nhanh; dùng navmesh;
   - phát `companion_state_changed`: `joined`, `running`, `waiting`, `calling`, `left`.
6. **Bảo vệ** `res://scenes/entity/guard.tscn` (mô hình lane B), đặt ở `GuardLine/G01…G12`:
   - đứng bất động; người chơi vào `GuardRadius` (3 m) → giơ dùi cui, phát `guard_warned(guard, true)`;
   - tiến thêm khoảng 1,5 m nữa, hoặc đập trúng → `player_caught(&"guard")`;
   - xác sống **tránh** vùng 3 m quanh bảo vệ;
   - API `turn_head_to(point)` (jumpscare 8, core gọi).
7. **Cảnh chết** (góc nhìn thứ nhất, như T-161):
   - `zombie_grab`: bị vồ, kéo ngã, mặt xác sát camera;
   - `guard_shock`: giật, ngã;
   - tôn trọng "Giảm hù dọa".
8. **Ray "aim" test** (bài học chương 1): người chơi đứng ở vị trí hợp lý thì nhắm và bấm E trúng được `FireKey`, `Extinguisher2F`, thanh sắt ở `BarSpawns`, cửa sổ phòng quản lý. Viết khi lane B đã có greybox; chưa có thì ghi "chưa test" vào Handoff.
9. **Test:**
   - xác thức, săn, tóm, tê liệt 5 giây, phá cửa;
   - giới hạn 40 xác, xác xa cập nhật thưa;
   - thanh sắt trúng đầu, trượt, gãy sau 8 lần;
   - thể lực cạn rồi hồi, thở dốc phát tiếng;
   - đồng đội chạy, chờ, gọi;
   - bảo vệ cảnh báo rồi giết;
   - chương 1–2 không bị ảnh hưởng (thể lực tắt).

10. **Nối với âm thanh lane E (T-186, đã merge):** đọc mục "Rig và API chính" trong `docs/tasks/T-186-ch3-audio.md` và `audio_source/ch3/README.md`.
    - Mỗi xác có một `ZombieAudio` con (core gắn). Lane A gọi:
      - `play_step()` theo bước thật;
      - `play_door_hit()` mỗi cú đập cửa;
      - `set_hunting(false)` khi xác ngủ, `set_hunting(true)` khi hồi tê liệt (nếu không phát lại `zombie_woke`);
      - `set_eligible(false)` khi xác khuất hoặc đang cập nhật thưa.
    - Bước chân người chơi: `FootstepPlayer.play_footstep(surface, intensity)` đã có thêm mặt `grass` và `concrete` (lane B gắn `surface` cho sàn).
    - Thở dốc khi cạn thể lực: `Ch3PlayerAudio` tự phát âm; lane A chỉ phát `noise_emitted` (8 m) cho xác nghe. Không để tiếng thở hụt hơi cũ của chương 1 (`breath`) phát chồng lên.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Cảnh thử (scene test) cho xác, thanh sắt, đồng đội, bảo vệ
- [x] Handoff: scene, API, signal, cách ghép, con số đã dùng

## Handoff (agent điền)

### Bàn giao 2026-10-06 — Lane A

- Mã: `7ba1de3` — `T-182: add chapter three zombie combat and survival actors`, đã push lên `lane-a/T-182-ch3-zombies`. Nhánh xuất phát từ `origin/main` tại `b9fcee5`.
- Đã làm các cơ chế 1–7, test tự động và cảnh thử nhỏ theo card. Không sửa core, scene lane B, EventBus, project.godot, STATUS hoặc bản tích hợp.
- Nhân vật/thanh sắt hiện dùng khối hình thủ tục để thử cơ chế, chưa phải mô hình hoàn thiện của lane B. Không thêm asset bên ngoài hay plugin.

### Scene, API và cách ghép

| Thành phần | Đường dẫn / cách gọi |
|---|---|
| Xác | `res://scenes/entity/zombie.tscn`, `Zombie`: `wake()`, `sleep_pose(&"idle" / &"sit" / &"lie")`, `stun(seconds)`, `is_stunned()`, `set_target(player)`, `set_body(PackedScene)` |
| Đám xác | `res://scripts/entity/zombie_horde.gd`, `ZombieHorde`: gán `anchors = Campus/Anchors`, `target = player`, rồi `spawn(zone, count)`, `place_idle(zone)`, `clear_zone(zone)`, `clear_all()`, `active_count()` |
| Thanh sắt | `res://scenes/interaction/iron_bar.tscn`, đặt tại BarSpawns; E nhặt. `player.give_bar(hits)` trao trực tiếp, mặc định 8; vũ khí nằm tại `Head/Camera3D/IronBar` |
| Đồng đội | `res://scenes/entity/companion.tscn`, `Companion`: gán `player`, `member = &"minh_nhat" / &"ngu"`, `set_body(scene)`, rồi `follow_path(Campus/Anchors/Paths/Nhat hoặc Ngu)` |
| Bảo vệ | `res://scenes/entity/guard.tscn`, `CampusGuard`: gán `player`, đặt tại GuardLine/G01…G12, `set_body(scene)`, `turn_head_to(point)` |
| Cửa gỗ | `res://scripts/interaction/zombie_door.gd`, `ZombieDoor`: thêm một node cho mỗi cửa, gán `door` và `blocker` trước khi add_child. `door` cần `is_open` và `set_open(bool)`; `blocker` là collider world của cánh cửa |
| Cảnh thử | `res://scenes/entity/ch3_gameplay_test.tscn`; có sàn, 6 bậc thang thật, navmesh, player, thanh sắt, xác, hai đồng đội, bảo vệ và 40 anchor |

- `Ch3Actor` dùng NavigationAgent3D và collision world, bước lên tối đa 0,3 m, không teleport qua tường. Navmesh phải phủ đường qua cửa/cầu thang; collider cửa đóng chặn đường trong lúc đập. Đã test cả bước AI thường lẫn bước thưa 0,3 giây trên cầu thang thật.
- `set_body()` nhận Node3D, ưu tiên `set_pose(StringName)`, rồi `set_state(StringName)`, hoặc AnimationPlayer có animation cùng tên. Xác dùng `idle/walk/stunned/grab/sit/lie/wake`; bảo vệ dùng thêm `warn`. Mô hình nên có node `Head` theo đúng đầu để hitbox và camera bám theo; bảo vệ có thể cung cấp `turn_head_to(point)`.
- Collider thân dùng layer 1, HeadHitbox là Area3D layer 3 (bit 4), chỉ hitbox đầu được tính là đập trúng xác. Ray sắt kiểm tra world trước, không đánh xuyên tường.
- `place_idle(zone)` đọc metadata `pose` trên từng anchor (mặc định `idle`), gọi lại không tạo trùng. `spawn()` dùng anchor đang trống; phần còn lại chờ và thử lại mỗi 0,3 giây, tránh chồng nhiều thân lên 6 anchor. `clear_zone/all` hủy cả yêu cầu đang chờ. Giới hạn active tính cả xác đang stunned; khi đập đầu xác ngủ lúc đủ 40, nhường suất của xác hoạt động xa điểm bị đánh nhất bằng cách cho nó ngủ lại. Đây là cách giữ trần kỹ thuật đồng thời bảo đảm cú đập có tác dụng.
- `ZombieDoor` gắn metadata `zombie_door` lên blocker, tự đếm thời gian tiếp xúc nên nhiều xác không nhân tốc độ phá. Khi đủ thời gian: mở cửa, tắt tương tác nếu là Interactable, bỏ collision blocker và phát signal cục bộ `broken`. Chỉ gắn adapter cho cửa gỗ được phép phá, không gắn cửa kim loại/xích khóa.

### Thông số và signal

- Xác: 1,5 m/s; cầu thang ×0,7; thấy/nghe để thức khi player trong 25 m; góc nhìn 120°, có ray kiểm tra vật cản; tóm trong 1 m phía trước và không xuyên tường. Cửa gỗ 10 giây tiếp xúc cộng dồn; stunned 5 giây từ thanh sắt.
- Đám xác: `max_active = 40`; xa hơn 60 m, ngoài khung nhìn hoặc bị che thì cập nhật mỗi 0,3 giây (~3,33 Hz). `audio_enabled` chỉ true khi hunting và không cập nhật thưa; AudioStreamPlayer3D con được tạm ngừng khi không đủ điều kiện. Lane E cần kiểm tra thuộc tính này nếu phát âm ở hệ thống ngoài actor.
- Sắt: tầm 1,5 m, mặc định 8 hit, trượt/đập thân không hao độ bền, cooldown 0,55 giây, mỗi cú vung tốn 0,08 thể lực. Hình sắt cong theo độ bền rồi ẩn khi gãy. Chuột trái có sắt không kích hoạt tương tác E; bị khóa khi typing/modal/pause/ẩn nấp/chết.
- Thể lực: mặc định `stamina_enabled = false`; core bật chỉ ở chương 3. Chạy tiêu 1/12 mỗi giây; đi hồi 0,05/s; đứng hồi 0,12/s. Cạn thì chỉ đi bộ đến khi hồi 0,3. Thở dốc phát tiếng bán kính 8 m mỗi 1,5 giây; vung sắt phát tiếng 10 m. Tiếng đi/chạy có sẵn giữ bán kính 5/12 m; xác cũng nghe noise bình cứu hỏa 25 m.
- Đồng đội: 2,6 m/s; thứ tự waypoint tự nhiên theo tên P01/P02…; `_Wait_` dừng đến khi player trong 6 m; xa hơn 25 m đủ 8 giây phát `calling` một lần cho đến khi player lại gần. Né bằng nghiêng thân khi xác tới gần; không stun xác và không nhận lệnh chết/tóm.
- Bảo vệ: cảnh báo 3 m, giết 1,5 m hoặc bị sắt đánh trúng; cảnh báo/tóm kiểm tra vật cản. Xác tránh vùng bảo vệ với khoảng đệm 0,35 m.
- Hai death kind mới dài 3 giây: `zombie_grab` kéo camera gần đầu rồi ngã liên tục; `guard_shock` rung ban đầu rồi ngã. Giảm hù dọa bỏ rung/giật/máu, zombie_grab quay nhìn lên sớm. Giữ tín hiệu `death_animation_finished` một lần; core vẫn sở hữu verdict/checkpoint.
- Dùng đúng EventBus đã có: `zombie_woke`, `zombie_stunned`, `bar_picked`, `bar_swung`, `bar_broken`, `stamina_changed`, `companion_state_changed`, `guard_warned`, `noise_emitted` (source `pant`/`bar_swing`), `player_caught(&"zombie" / &"guard")`. Không tự thêm signal hoặc input action. Prompt nhặt hiện dùng key sẵn có `PROMPT_INTERACT`.

### Kiểm tra đã chạy

- Godot console 4.7.2, từ `D:\GAME_WORK\lane-a`:
  - `pwsh tools/test.ps1 -Filter player`: `RESULT: 151 passed, 0 failed`.
  - Bản mã cuối `pwsh tools/test.ps1`: **`RESULT: 530 passed, 0 failed`**, exit 0, không lỗi engine. Log local `build/T-182-full-final.log`.
  - `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. Log local `build/T-182-check.log`.
  - `git diff --cached --check`: sạch.
- Thêm 15 test CH3: thức/nghe/vật cản/tóm/stun, navmesh và cầu thang ở hai nhịp AI, phá cửa không nhân damage theo bầy, trần 40, queue spawn, xa/khuất không âm thanh, hitbox theo mô hình, sắt trúng/trượt/gãy, E/chuột/typing, thể lực và chương cũ, đồng đội, bảo vệ, load/pause scene. Thêm 4 test death thường/giảm hù dọa và kiểm tra không giật camera khi chuyển từ kéo sang ngã.
- Sửa test T-177 bị dao động theo gravity: sau khi đóng nhập chữ, chỉ so chuyển động X/Z và kiểm tra E không phát lại; vẫn kiểm tra khóa input khi gõ và điều khiển trở lại. Không đổi cơ chế typing.
- Đã chạy scene bằng Godot có render, chụp và xem khung hình; không coi đây là chơi tay toàn chương. Ảnh local (ignored, không commit): `build/T-182-preview/frame00000060.png`, `build/T-182-zombie-final/frame00000015.png`, `build/T-182-zombie-final/frame00000065.png`, `build/T-182-guard-preview/frame00000065.png`. Hai lượt chụp death không báo lỗi engine.
- Chạy scene thử: `D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game res://scenes/entity/ch3_gameplay_test.tscn`. E nhặt, chuột trái vung; 1 = zombie_grab, 2 = guard_shock, 3 = gọi bầy, 4 = trao sắt, R = tải lại. Có tham số sau `--`: `--death-preview=zombie_grab` hoặc `--death-preview=guard_shock` để chụp camera.

### Còn dở / chưa test

- **Ray aim trên khuôn viên: chưa test** FireKey, Extinguisher2F, thanh sắt tại BarSpawns, cửa sổ quản lý: `campus.tscn`/greybox T-183 chưa có trên base `b9fcee5`. Đã test E nhặt sắt bằng ray Player trong fixture; không thay thế kết quả aim ở map thật.
- **Chưa test** đi hết khuôn viên, FPS 40 xác trên map lớn, mô hình/tư thế thật lane B, âm thanh lane E, UI lane D và checkpoint chương 3 tích hợp. Các mục này cần các lane tương ứng ghép trước; chưa có kết quả chơi tay của chủ dự án.
- Không còn checklist ba mục chưa đạt. Phần cơ chế độc lập không bị chặn; kiểm thử aim/tích hợp đang chờ T-183 và core.

### Yêu cầu thay đổi ngoài phạm vi

1. **Core/T-181:** tạo/gán Horde với Campus/Anchors và player, bật `stamina_enabled` khi vào CH3, đặt pickup/đồng đội/bảo vệ từ anchor, gọi API theo tiến trình được thiết kế; nối `player_caught` sang death kind/checkpoint. Khi đổi checkpoint, clear/recreate actor và queue. Không dùng callback `_caught` của fixture trong bản tích hợp.
2. **Core + lane B/T-183:** gắn ZombieDoor cho cửa gỗ 407 và 203 với đúng blocker; cửa 407 sẵn có `is_open/set_open`. Bảo đảm navmesh/collision cầu thang liên thông, Head của mô hình phản ánh tư thế, bổ sung tư thế `warn` và `turn_head_to` cho bảo vệ nếu mô hình chưa có; cung cấp greybox để A/C thực hiện các aim test còn thiếu.
3. **Lane D/E:** ghép UI/sound theo signal và `audio_enabled` trên đây; hiện A chỉ phát signal, chưa xác nhận lớp UI/âm thanh CH3 đã ghép.

Không có câu hỏi mới về luật chơi/cốt truyện; không tự thêm tình tiết hay cơ chế ngoài card.

### Review (integrator, 2026-10-06)
- **Đạt, đã merge.** Xác (thức, nghe, tóm 1 m, tê liệt 5 giây, phá cửa gỗ không nhân theo bầy), quản lý 40 xác, thanh sắt (trúng đầu, cong, gãy sau 8 lần), thể lực (chỉ bật ở chương 3), đồng đội theo đường, bảo vệ, 2 cảnh chết; sửa test T-177 chập chờn (chỉ so X/Z).
- Nhánh tạo trước khi có khung map và âm thanh, nên phần sau chuyển cho integrator (T-181) khi ghép luồng: gắn `ZombieAudio` và gọi `play_step` / `play_door_hit` / `set_hunting` / `set_eligible`; dùng mô hình lane B qua `set_body`; ray "aim" test trên map thật (FireKey, Extinguisher2F, BarSpawns, cửa sổ phòng quản lý, cần cúi).
- Ghép thử headless với map lane B: 40 xác thức cùng lúc, khoảng 6,9 ms/frame logic.
