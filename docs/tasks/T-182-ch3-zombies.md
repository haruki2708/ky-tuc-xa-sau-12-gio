# T-182 — Chương 3: xác sống, thanh sắt, thể lực, đồng đội, bảo vệ, cảnh chết mới
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
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

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Cảnh thử (scene test) cho xác, thanh sắt, đồng đội, bảo vệ
- [ ] Handoff: scene, API, signal, cách ghép, con số đã dùng

## Handoff (agent điền)
