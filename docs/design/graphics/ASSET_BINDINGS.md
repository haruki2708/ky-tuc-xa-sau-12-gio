# Bảng ràng buộc visual–logic (T-207, G0 và tổng hợp G1)

> **D-081, 11/10:** Astra làm thay Claude web, tổng hợp Handoff A/B/C/D/F vào G1. Quy ước balo và các phần còn pending nằm trong [contract hiện hành](INTEGRATION_CONTRACT.md). Số đo G0 dưới đây giữ nguồn của web; bổ sung G1 dựa trên dữ liệu B và code tại `acbf771`, không phải lượt đo/render mới.

Người lập G0: Claude Code web theo D-077, 10/10/2026; G0 đã nhận/ghép D-079. Astra bổ sung G1 theo D-081. Bảng phân biệt hành vi hiện có với yêu cầu chưa triển khai; không dùng nó để tuyên bố model Tripo hoặc adapter mới đã đạt.

## 0. Cách đo và giới hạn

- Nguồn: `origin/main` tại `e3ed54a` (D-078). Số đo lấy bằng cách dựng thật bốn cảnh `res://scenes/main/chapter1…4.tscn` và các model liên quan bằng Godot 4.7.2 headless (không cần GPU), rồi in tọa độ thế giới, collider (hình, kích thước, layer/mask), marker, group, clip của `AnimationPlayer`, bounds và số tam giác của mesh. Script đo là tạm thời, đã xóa sau khi chạy, không commit.
- Hằng số, đường dẫn node và thời lượng chép từ mã nguồn tại dòng ghi kèm (số dòng theo `e3ed54a`; có thể trôi khi file đổi).
- **Không đo / không kiểm được trên máy này:** hình ảnh thật, FPS, âm thanh nghe được, cảm giác tương tác. Số tam giác ở đây là số lấy từ mesh sau import, chỉ để làm mốc "trước", không phải ngân sách.
- Tọa độ viết dưới dạng `(x, y, z)` mét, hệ **thế giới**. Trong cả bốn cảnh chương, `Floor4` và `Campus` đều đặt tại gốc `(0, 0, 0)` nên tọa độ cục bộ của chúng cũng là tọa độ thế giới. `Room407` nằm ở `(30, 0, 0)` so với `Floor4`, không xoay.

## 1. Quy ước chung đã đo

| Mục | Giá trị thật | Nguồn |
|---|---|---|
| Collision layer | 1 = world, 2 = player, 3 = interactable (giá trị bit 4) | AGENTS §5; `interactable.gd:LAYER_INTERACTABLE = 1 << 2` |
| Tia tương tác | `Head/Camera3D/InteractRay`, dài **2.0 m**, `collision_mask = 5` (world + interactable), bắt cả Area lẫn Body | `scenes/player/player.tscn:26-30` |
| Hệ quả | Mọi vật có collider layer 1 nằm giữa mắt và một `Interactable` **chặn tia**. Visual mới không được thêm collider layer 1 trước vùng tương tác | suy ra từ mask 5 |
| Hướng "trước" | −Z cục bộ (`Ch3Actor.face` dùng `atan2(-x, -z)`) | `ch3_actor.gd:68-72` |
| Gốc nhân vật | Chân ở `y = 0` của root; model campus `bounds_pos.y ≈ 0.013` | đo |
| Bus âm | Chuông dùng `SFX`; giọng dùng `Voice` | `chapter3_director.gd:784-788` |

## 2. Phòng 407 và hành lang (dùng chung bốn chương)

### 2.1 Cửa 407 — `Floor4/Door407`

| Thuộc tính | Giá trị |
|---|---|
| Script | `res://scenes/levels/floor4/door407.gd` (kế thừa `Interactable`) |
| Gốc/bản lề | `Door407` và `Pivot` cùng tại `(32.44, 0.01, 0.0)`; mở bằng `$Pivot.rotation.y = -π/2` |
| API core đang gọi | `set_open(open: bool, seconds: float = 0.0)`, thuộc tính `is_open`, `rattle(seconds)`, `stop_rattle()` (`chapter1_director.gd:1897-1910`, `manager.gd:136-176` dò số tham số của `set_open` bằng `get_method_list`) |
| Collider thế giới | `Pivot/Leaf/WorldCollision/Bounds`, Box `(0.88, 2.08, 0.10)` tại `(32.00, 1.05, -0.03)`, layer 1 (chương 1–2) |
| Collider tương tác | `InteractShape`, Box `(1.10, 2.20, 0.25)` tại `(32.00, 1.05, 0.00)`, layer 3 |
| Chốt cửa | `Pivot/DoorLatch407/CollisionShape3D`, Box `(0.18, 0.06, 0.06)` tại `(31.66, 1.06, -0.16)`, layer 3; core tìm bằng `find_child("DoorLatch407")` |
| Tờ luật | `Pivot/RulesPaper`; `Floor4.sync_door_anchor()` chép transform vào `Anchors/RulesPaper407` mỗi lần góc cửa đổi (`floor4.gd:9-14`) |
| Khe cửa | `$DoorGap.visible = not $Door407.is_open` |
| **Chương 3–4** | Campus đặt `Anchors/Ch4/Room407/Door` (script `scenes/levels/ch4/door407_proxy.gd`, vùng B). Proxy **đặt `collision_layer = 0` cho mọi `CollisionObject3D` dưới `Pivot/Leaf`** và thay bằng `Blocker` (layer 1 khi cửa đóng). Đo: `Leaf/WorldCollision/Bounds` layer **0** ở chương 3 và 4, layer **1** ở chương 1 và 2. Proxy cũng ẩn `Leaf` khi `damage_fraction ≥ 0.6` và nghe `EventBus.door_damage_changed(&"407", fraction)` |
| Owner | B (scene/model), core gọi API; A giữ `DoorLatch407` (tương tác) |

**Ràng buộc cho model cửa mới:** giữ tên node `Door407`, `Pivot`, `Pivot/Leaf` (có `CollisionObject3D` con để proxy gỡ layer), `Pivot/DoorLatch407`, `Pivot/RulesPaper`, `Pivot/HandlePivot` (rattle xoay `HandlePivot.rotation.z`), hướng mở −π/2 quanh Y, và kích thước lá cửa ≈ 0.88 × 2.08 m để khớp `Blocker`. Chủ đích: không mất vùng tương tác `(1.10, 2.20, 0.25)` và không để mesh mới che tia 2 m tới chốt cửa.

### 2.2 Giường tầng và bốn giường

| Giường | `Bunks/BunkN` (Marker3D, thế giới) | `Anchors/Bed_*` | Vùng tương tác (Area3D, layer 3) | Ghi chú |
|---|---|---|---|---|
| 1 Phúc (tầng trên, phía x = 30.65) | `(30.65, 1.20, -3.00)` | `Bed_Phuc` cùng tọa độ | Box `(1.15, 0.50, 1.90)` tại `(30.65, 1.50, -3.00)` | có `View` và `Exit` cục bộ |
| 2 Việt (tầng dưới, phía x = 30.65) | `(30.65, 0.43, -3.00)` | `Bed_Viet` | Box cùng cỡ tại `(30.65, 0.68, -3.00)` | |
| 3 Trung (tầng dưới, phía x = 37.35) | `(37.35, 0.43, -2.70)` | `Bed_Trung` | Box tại `(37.35, 0.68, -2.70)` | giường của người chơi |
| 4 Đạt (tầng trên, phía x = 37.35) | `(37.35, 1.20, -2.70)` | `Bed_Dat` | Box tại `(37.35, 1.50, -2.70)` | |

- `View` mỗi giường: `(0, 0.43, 0.64)` cục bộ, xoay X 15° (đã đọc ở giường 1–3). `Exit` cục bộ: giường 1 `(0.85, -1.17, 0.70)`, giường 2 `(0.85, -0.40, 0.70)`, giường 3 `(-0.85, -0.40, 0.70)`; giường 4 chưa đọc `Exit`.
- Khung giường: `BunkA` tại `Room407 + (0.65, 0, -3)`, `BunkB` tại `(7.35, 0, -2.7)`; khung `bunk_a_frame.tscn` bounds `0.90 × 1.70 × 2.00`, 108 tam giác, 9 mesh. Màn `Net_*`, `Sleeper_*` là con của `BunkA/BunkB`.
- Core còn hardcode vị trí đứng dậy `BED_EXIT` (`chapter1_director.gd`): giường 1–2 `(31.4, 0.05, -2.2)`, giường 3–4 `(32.6, 0.05, -2.2)`; điểm quản lý đứng nghe `MANAGER_SPOT (33.0, 0.05, -1.9)`. Đây là tọa độ thế giới, **không đổi** theo model.
- Khi `set_slashed(amount)` (B) hiển thị vết chém: `Details/TrungBedding/Section0…7`.
- **Ràng buộc:** model giường mới phải để mặt nệm ở đúng độ cao 0.43 m (tầng dưới) và 1.20 m (tầng trên) tại tâm giường, vì ba xác và `View` neo vào các số này.

### 2.3 API phòng 407 (`room407.gd`, B) core đang gọi

`set_blood_stage(0..2)`, `set_slashed(0..1)`, `set_flicker(bool)`, `set_bathroom_door_open(bool)`, `set_stuck_shake(float)`, `set_water(on, temp)`, `set_steam(level)`, `flash_reflection()`, `set_desk_lamp(bool)`, `set_plugged(cable_id, bool) -> bool`, và `spark()` trên `PowerStrip`. Core luôn kiểm `has_method` trước khi gọi. Đèn `Room407MainLight`, `Room407DeskLamp` là `OmniLight3D` với `flicker_light.gd`; core đọc `visible` và `light_energy > 0.01` của đèn bàn để biết bật/tắt (`chapter1_director.gd:_desk_lamp_on`). **Thay đèn bằng ánh sáng bake sẽ làm sai luật bàn đèn (D-069)**; đèn có bật/tắt phải còn là node có hai thuộc tính trên.

### 2.4 Vùng (Zones) và Bounds — Area3D, layer 0, mask 2

`Zones/Bedroom`: Box `(7.8, 3.0, 4.0)` tại `(34.0, 1.5, -2.0)` + `Rear` `(5.2, 3.0, 3.0)` tại `(32.65, 1.5, -5.5)`; `Zones/Bathroom` `(2.65, 3.0, 3.0)` tại `(36.65, 1.5, -5.5)`; `Zones/Balcony` `(5.2, 3.0, 1.5)` tại `(32.6, 1.5, -7.75)`; `Bounds/Main` `(8.0, 3.2, 7.0)`, `Bounds/Balcony`. Luật chương 2 ("chỉ trả lời được trong phòng ngủ") và chương 1 (rời phòng) dựa vào các vùng này. **Không đổi tọa độ/kích cỡ khi thay phòng.**

### 2.5 Balo — mẫu đạo cụ tĩnh đầu tiên, bổ sung D-081

Nguồn B: `art_source/graphics_upgrade/asset_manifest.json` và `measured_assets.json`, ID `room407_backpack`. Trong `res://scenes/levels/floor4/floor4.tscn`: node `Room407/Details/Trung/Backpack`. `room407_details.tscn` đặt root local `(3.78,0.02,-4.52)`, yaw 90°, scale `(1,1,1)`; Room407 cộng x=30, thành vị trí trong floor4 `(33.78,0.02,-4.52)`.

Bounds **trước transform đặt root**: min `(-0.145,0.01,-0.1325)`, size `(0.29,0.45636,0.30274)` m. G0: 96 tam giác, 3 material; số này không là trần của mẫu mới. Trần prototype D-079: ≤3.000 tam giác, ≤2 material, texture ≤1024², file ≤10 MiB. Chuẩn hóa dưới visual, không recenter gameplay root hoặc tạo collider mới. Mặt trước/basis và artifact wrapper cụ thể B phải đưa vào brief; C đo trong cùng hệ root-local theo contract §2.

Mẫu này không cần rig/clip, preset mới hoặc điểm nối W1–W4. Brief B và schema/probe C chưa đủ bằng chứng nghiệm thu G1; không lấy số đo asset cũ làm kết quả Tripo.

## 3. Ba xác (Phúc, Việt, Đạt) — chương 1–4

| Thuộc tính | Giá trị đo |
|---|---|
| Vị trí gốc | `Room407/Anchors/Corpse1` `(30.65, 1.20, -3.00)`; `Corpse2` `(30.65, 0.43, -3.00)`; `Corpse4` `(37.35, 1.20, -2.70)`; mỗi cái có con `Body` tại cùng tọa độ |
| Scene | `res://scenes/levels/ch1_models/corpse_phuc.tscn` / `corpse_viet.tscn` / `corpse_dat.tscn`, script `corpse_body.gd` (vùng B) |
| Root khi nằm | bounds `0.55–0.63 × 0.32–0.34 × 1.72` (X,Y,Z) mét; 632–656 tam giác; 33–35 mesh |
| API | `set_pose(pose) -> bool` với `POSES = dead_a, dead_b, head_turn, eyes_open, sit_up`; `set_state(state) -> bool` với `STATES = sit_play, talk, gagged, mumble, fall, revive, lunge, slump`; `set_gagged(bool)`, `set_blood_visible(bool)`, `look_at_point(world_point)`; thuộc tính `seat_side` |
| Node bắt buộc (hardcode) | `Rig/Hips/Chest/Head`, `.../Head/Mouth`, `.../Head/Eyes`, `Rig/Hips/Chest/Blood`, `Rig/Hips/LeftLeg/Knee`, `.../RightLeg/Knee`, `Rig/Hips/Chest/LeftArm`, `RightArm`, `AnimationPlayer` |
| Clip | `RESET, dead_a, dead_b, eyes_open, head_turn, sit_up`, mỗi clip dài **0.01 s** và bị `advance(0)` + `pause()`; ngồi/nói/ú ớ/ngã/lao là **chuyển động viết bằng mã trong `_process`**, không phải clip |
| Thời gian trong mã | `fall` làm mượt trong 0.40 s, `slump` 0.65 s, `revive` 0.22 s, `lunge` 0.28 s (smoothstep theo `_time`); director chờ lần lượt `CORPSE_REVIVE_SECONDS = 10.0` (ngã đến dậy), `CORPSE_MUMBLE_SECONDS = 4.0`, `CORPSE_SPEAK_SECONDS = 2.6`, hồi sinh 0.6 s (`chapter2_director.gd:22-24, 291-299`) |
| Nhóm | `ch2_corpse` (đo: **6** node: 3 ở 407 và 3 ở `CctvSet/Room310/Corpse1/2/4`), `corpse_poser` (3, con `Body/UnseenPoser` của A) |
| Ghép với miệng | `Anchors/Gag1/2/4` (script `gag_anchor.gd`, B) bám `Rig/Hips/Chest/Head` của `Body` với offset `(0, 0.005, -0.14)` mỗi frame. Vị trí đo: `Gag1 (30.65, 1.485, -2.335)`, `Gag2 (30.65, 0.715, -2.335)`, `Gag4 (37.35, 1.485, -2.035)`. `GagSpot` (A) gắn vào đó và dùng cho tương tác |
| Chương dùng | 1 (nằm chết), 2 (`sit_play/talk/gagged/mumble/fall/revive/slump/lunge`, `bed` 1/2/4), 3 (`_roommates_rise` ẩn `Body`, dựng zombie `zombie_01/02/03` tại `anchor + (0, 0.05, 0.6)`, 4 s sau mới `wake`), 4 (tái dùng phòng) |
| Hiển thị phụ | `Room407.set_blood_stage` gọi `Corpse*/Body.set_blood_visible` khi `stage > 0` |
| Owner | B (scene/rig/wrapper), A (`UnseenPoser`, `GagSpot`), core (gọi state) |

**Ràng buộc:** model xác mới **không thể** thay thẳng scene `corpse_*.tscn` nếu nó có `Skeleton3D`/`AnimationPlayer` khác tên: `corpse_body.gd`, `gag_anchor.gd` và `UnseenPoser` chạm trực tiếp vào các NodePath ở trên. Cần adapter giữ API `set_pose/set_state/set_gagged/set_blood_visible/look_at_point` và marker `Head` (hoặc nhận `Gag`/`Mouth` marker tương đương); xem hợp đồng §4.

## 4. Người quản lý

| Thuộc tính | Giá trị đo |
|---|---|
| Scene | `res://scenes/entity/manager.tscn` (`DormManager`, `CharacterBody3D`, vùng A) |
| Collider | Capsule r 0.30 h 2.00 tại `(0, 1, 0)`; `collision_layer = 0`, `collision_mask = 1`; `NavigationAgent3D` r 0.30 h 2.00 |
| Fallback | `Visual/Fallback`: thân Box, `LeftArm` tại `(-0.32, 1.5, 0)`, `BladePivot` tại `(0.45, 1.15, 0)`, `BladeTip` tại `(0, -1.15, 0)` cục bộ của `BladePivot`; 264 tam giác, 3 mesh |
| Model B | `res://scenes/levels/ch1_models/manager_body.tscn` (root `ManagerBody`, 776 tam giác, 44 mesh, bounds `0.664 × 1.917 × 0.340`, chân ở y = 0.013) |
| Core đặt model | `manager.set("body_scene", load(MANAGER_BODY))` rồi `add_child` (`chapter1_director.gd:1071-1072, 1741-1742`); manager tự dựng trong `_ready` |
| Manager tìm trong model | `find_children("AnimationPlayer")[0]`, `find_child("BladeTip")`, `find_child("LeftArm")` |
| `BladeTip` | Marker3D, local theo root `(0.25, 0.015, 0.0)` ở tư thế nghỉ, nằm dưới `Rig/Hips/Chest/RightArm/Elbow/Hand`; script `blade_tip.gd` bám theo `source` |
| Clip | `RESET 0.01 s`, `stand 2.40 s` (lặp), `walk 1.60 s` (lặp), `ask 2.00 s`, `slash 1.20 s`, `lunge 0.65 s`, `kill 0.90 s`. Manager gọi theo tên `stand`, `walk`, `slash`, `lunge`, `ask`, `kill` (`manager.gd`, `_play_animation`), bỏ qua clip không có; riêng `slash` được đặt `speed_scale = length / slash_interval` (0.45 s mỗi nhát) |
| Thời gian trong mã | `slash_count = 6`, `slash_interval = 0.45`, `lunge_seconds = 0.65`, `lunge_speed = 5.0`, `speed` 0.9 (trong phòng) / 1.3 (hành lang); `DOOR_OPEN_SECONDS = 1.5`, `DOOR_THRESHOLD_SECONDS = 1.0`, `HANDLE_RATTLE_SECONDS = 1.2`, `MANAGER_LISTEN_SECONDS = 2.5`, `HUNT_SECONDS = 15.0` |
| Sự kiện | tín hiệu `arrived`, `answered(heard)`, `slashed(target)`, `slash_finished`, `heard_movement`, `door_opened`; **`slashed` phát đúng một lần mỗi nhát từ bộ đếm thời gian trong `_tick_slash`, không từ clip**, và core đếm nó để tăng `_set_bed_slashed` |
| Âm thanh bám | Rig `manager_audio` (nhóm, `ManagerAudioFar` ở cảnh); `_sync_audio` đặt rig tại `global_position` và nút `Drag` tại `BladeTip` (model) hoặc `BladePivot/BladeTip` (fallback) |
| Quay mặt | `visual.global_rotation.y = atan2(-x, -z)` — gốc `Visual`, không phải root |
| Owner | A (manager.gd/scene, API), B (model), F (rig âm thanh), core (điều phối theo director) |

**Ràng buộc:** model quản lý mới phải có `BladeTip` (Node3D), `LeftArm` (Node3D xoay X để mở cửa), `AnimationPlayer` với các clip `stand/walk/slash/lunge/ask/kill` (clip thiếu bị bỏ qua im lặng nhờ `has_animation`, nên cần test hợp đồng bắt thiếu). Nếu rig dùng `Skeleton3D` + `BoneAttachment3D`, `BladeTip` phải là con của attachment để `_sync_audio` vẫn đúng.

## 5. Đồng đội, học sinh, zombie, bảo vệ (chương 3–4)

| Thuộc tính | Giá trị đo |
|---|---|
| Lớp cơ sở | `Ch3Actor extends CharacterBody3D` (A): `set_body(PackedScene)`, `play_pose(StringName)`, `head_position()`, `face(point)` |
| Cấu trúc scene (companion/zombie/guard) | root `CharacterBody3D`; `CollisionShape3D` Capsule **r 0.25, h 1.70** tại `(0, 0.85, 0)`, layer 1, mask 1; `Visual/Fallback` (đầu tại `(0, 1.55, 0)`); `NavigationAgent3D`; zombie còn `HeadHitbox` Sphere r 0.31 tại `(0, 1.55, 0)` layer 3 |
| `set_body` | `queue_free` model cũ; model cũ còn trong cây tới deferred free. Thêm model hợp lệ mới dưới `Visual` rồi mới xóa cache `_played_pose` và gọi lại pose; nhánh null/root không hợp lệ trở về fallback trước bước này. A cần xử lý lifecycle/cache theo Review; G0 chưa sửa production |
| `play_pose` | chọn method theo thứ tự có `set_pose` → có `set_state` → clip, hiện không kiểm bool trả về và cache trước khi biết pose được nhận. Fallback xoay X π/2 khi `lie`/`stunned`. Các pose gồm `idle, walk, stunned, grab, sit, lie, wake`; guard còn yêu cầu `warn`, wrapper campus chưa hỗ trợ |
| `head_position` | `model.find_child("Head")` nếu có, nếu không thì `Visual/Fallback/Head` |
| Model hiện tại (B) | `res://assets/models/campus/%s.tscn` với `guard`, `nhat`, `ngu`, `zombie_01…10`, script `scenes/levels/campus/actor.gd`; cao 1.72 m (học sinh/zombie), 1.906 m (guard); 640–800 tam giác; `Head` tại `(0, 1.48, 0)` (guard `(0, 1.63, 0)`) cục bộ — **thấp hơn 7 cm so với fallback 1.55**, ảnh hưởng chỗ đặt `head_position` |
| Core gắn | `ZOMBIE_MODELS = 10`; `_dress`/`_make_zombie`/`_join` gọi `set_body(load(MODELS % name))` chỉ khi `ResourceLoader.exists` (`chapter3_director.gd:409-435, 554-558`) |
| Nhà đồng hành | `Companion` (member `minh_nhat`/`ngu`), tốc độ 2.6, khoảng cách theo sau 3.5 m, bên 1.2 m (`companion.gd`) |
| Owner | A (adapter/AI/va chạm), B (model/rig/wrapper `actor.gd`), core (chọn model theo vai), F (giọng/bước chân) |

**Ràng buộc:** `actor.gd` tự xóa `AnimationPlayer`/`BladeTip` của model, tự gắn tư thế bằng mã cho Rig `Hips/Chest/Head/LeftArm/...`. Một GLB có `Skeleton3D` **không** đi qua wrapper này; cần adapter A (T-208) tạo cầu nối riêng, và `head_position()` phải vẫn trả đúng đầu.

## 6. Bình cứu hỏa, nút báo cháy, chuông (tầng 1–2, chỉ chương 3)

| Mục | Giá trị đo / hằng số | Nguồn |
|---|---|---|
| Neo bình cứu hỏa tầng 2 | `Campus/Anchors/Extinguisher2F` tại `(48.83, -5.50, 2.40)` | `campus.tscn:7461` |
| Visual bình | `BuildingB/FireExtinguisher` (MeshInstance3D, `CylinderMesh` Ø≈0.20 cao 0.55, y từ −6.075 đến −5.525) tại `(48.86, -5.80, 2.40)` và `BuildingB/ExtinguisherHandle/Mesh` (`BoxMesh` 0.17×0.055×0.07 tại y −5.5275) tại `(48.86, -5.50, 2.40)` | `building_b.tscn`, đo |
| Vùng dùng (core đặt) | `Use_Extinguisher2F` (`Ch3Use`): Box `(0.5, 0.8, 0.5)` tâm `(48.83, -5.50, 2.40)`, layer 3, `once = true` | `chapter3_director.gd:490` |
| Khi dùng | `_alarm_sounded = true`, cờ `ch3_alarm`, `noise_emitted(position, 25.0, &"extinguisher")`, `_pull_crowd_203` | dòng 490-497 |
| Neo nút báo cháy | **Không có trong scene**: core tạo `Marker3D "FireAlarm1F"` dưới `Campus/Anchors` tại `FIRE_ALARM_AT (0.9, -8.5, 0.12)` **chỉ khi `_chapter() == 3`**. Đo: chương 3 có `Anchors/FireAlarm1F`, chương 4 `MISSING` | `chapter3_director.gd:53, 743-767` |
| Hình nút (core tự dựng) | `BoxMesh` 0.22 × 0.28 × 0.06 m, albedo `(0.72, 0.06, 0.05)`, phát sáng `(0.35, 0.02, 0.02)`, con trực tiếp của marker. Đo tường: tia từ `z=1.5` về phía `−z` trúng `Facade0L` tại `z = 0.08`, mặt sau hộp ở `z = 0.09` | đo |
| Vùng dùng | `Use_FireAlarm1F` Box `(0.5, 0.6, 0.5)` tâm marker | dòng 764 |
| Mồi khi bấm | `_bell_rung` (chỉ một lần), cờ `ch3_fire_alarm`, `noise_emitted(FIRE_BELL_AT, 45.0, &"fire_alarm")`, `_pull_crowd(_crowd_1f, (41.4, -9.9, 2.0), false)` | `FIRE_BELL_AT (42.0, -9.9, 2.0)`, dòng 769-776 |
| Chuông (âm) | `_ring_bell(FIRE_BELL_AT + (0, 2.2, -1.8) = (42.0, -7.7, 0.2), 20.0)`: `AudioStreamPlayer3D "FireBell"`, bus `SFX`, `volume_db −4`, `unit_size 8`; vòng lặp `play(); await finished` trong 20 s thật | dòng 55, 778-796 |
| Stream | `res://audio/ch1v2/lock_alarm.ogg`: dài **1.50 s, `loop = false`** → phát lại ≈ 13 lần trong 20 s. **Một stream đặt `loop = true` làm `await bell.finished` không bao giờ trả** (chuông không dừng) | đo |
| Visual của chuông | **Không có** (chỉ nguồn âm tại `(42.0, -7.7, 0.2)`); vị trí treo chưa là marker trong scene | đo |
| Owner | B (bình, vị trí treo chuông), core (hình nút tạm, mồi), A (`Ch3Use` kế thừa `Interactable`), F (stream, T-212), D (prompt `PROMPT_CH3_FIRE_ALARM`) |

**Ràng buộc:** D-075 — chuông chỉ chương 3; số xác, thời lượng 20 s, bán kính 45 m và vị trí mồi không đổi. Hình nút mới phải để vùng dùng `0.5 × 0.6 × 0.5` vẫn ngắm được từ tầm 2 m và không dịch mặt trước nút ra quá tường (`z = 0.08`).

## 7. Nơi core đang tự dựng hình hoặc hardcode đường dẫn (kiểm kê)

### 7.1 Core tự tạo visual

| # | Vị trí | Nội dung | Ghi chú |
|---|---|---|---|
| 1 | `chapter3_director.gd:743-767` (`_place_fire_alarm`) | `Marker3D` + `MeshInstance3D(BoxMesh)` đỏ + `Ch3Use` | greybox; B/T-209 dự kiến thay |
| 2 | `chapter3_director.gd:778-796` (`_ring_bell`) | `AudioStreamPlayer3D` | không có hình |
| 3 | `chapter3_director.gd:468-511` (`_place_uses`, `_use`) | `Ch3Use` Box tại neo `FireKey` `(0.4, 0.3, 0.4)`, `FireDoor` `(1.4, 2.2, 1.4)` nâng 1.1, `Extinguisher2F`, `FireAlarm1F` | vùng tương tác, không hình |
| 4 | `chapter3_director.gd:666` | `Node3D "CrowdDecoy"` đặt `stand + (0, -3, 0)` | mồi dưới sàn, vô hình |
| 5 | `chapter3_director.gd:578-583, 815-821` | `Node3D`/`Marker3D` bản sao đường đi | không phải visual |
| 6 | `chapter1_director.gd:1745` | `Node3D "SilentRig"` cho quản lý trong phòng CCTV | thay rig âm thanh, không có hình |
| 7 | `chapter1_director.gd` (nhiều hàm `_place_*`) | Dựng scene vùng A lên neo B: `readable`, `bunk_spot`, `search_spot`, `wall_knock`, `power_strip`, `lan_cable`, `lan_socket`, `desk_lamp_switch`, `door_latch`, `puzzle_station` | model thuộc B ở neo, vùng tương tác thuộc A |
| 8 | `chapter2_director.gd:770-840` | `carry_item`, `gag_spot`, `stuck_door`, `shower_stall`, `shower_choice`, `shower_screen` + UI `shower_screen.tscn` trên neo B; đồ cầm có `Model` (B) và `Placeholder` (A): core ẩn/hiện hai node này theo `picked/dropped` | **Đổi tên/loại bỏ `Model`/`Placeholder` làm hỏng ẩn–hiện đồ cầm** |
| 9 | `chapter4_director.gd` | `bed_slat`, `fake_search_spot`, UI `bed_card` trên `Ch4/Room407/*` | |
| 10 | `story_director.gd:22-25` | `preload` `PURSUER`, `SILHOUETTE`, `SLIPPERS_PAIR`, `SHIRT_HANGING` | model B |

Không có `CSG`, `QuadMesh`, `Label3D`, `Decal`, `Sprite3D` hay particle do core tạo (đã grep `scripts/core/*.gd`). Chỉ có hình nút báo cháy là visual do core tự dựng bằng mã.

### 7.2 Đường dẫn model/scene hardcode trong core

`MANAGER_BODY` (`res://scenes/levels/ch1_models/manager_body.tscn`), `STUDENT_SCENES` (`cctv/student_hung|kiet|bao|dang.tscn`, `CCTV_SET_SCENE`), `MODELS = res://assets/models/campus/%s.tscn` (+ `ZOMBIE_MODELS = 10`, `guard`, `nhat`, `ngu`), `ZOMBIE_SCENE/COMPANION_SCENE/GUARD_SCENE` (`scenes/entity/*.tscn`), `BAR_SCENE`, `HOSPITAL_SCENE`, `READABLE_SCENE`, `BUNK_SCENE`, `PUZZLE_STATION_SCENE`, `MANAGER_SCENE`, `BED_SLAT_SCENE`, `FAKE_SEARCH_SCENE`, cùng `FIRE_BELL_STREAM`, voice `res://audio/voice/vi/%s.ogg`, sfx `res://audio/sfx/%s.ogg`. Phần lớn có `ResourceLoader.exists` trước khi `load` (model B, `MANAGER_SCENE`, `HOSPITAL_SCENE`, `CCTV_SET_SCENE`, `STUDENT_SCENES`, `MODELS`, `FIRE_BELL_STREAM`, `COMPANION_SCENE`…). Một số scene tương tác vùng A được `load` thẳng, thiếu file là lỗi: `BED_SLAT_SCENE`, `FAKE_SEARCH_SCENE`, `READABLE_SCENE`, `BAR_SCENE`, `ZOMBIE_SCENE`, `GUARD_SCENE` (grep `scripts/core/*.gd`, 10/10).

### 7.3 NodePath hardcode (chọn lọc, đủ để B/A không đổi tên)

`Room407`, `Door407`, `Room407/Anchors/{Bunks/BunkN, CorpseN/Body, GagN, RagSpot/Model, TowelSpot/Model, ShirtSpot/Model, DatLocker/Charger, PowerStrip, Router/Model, DeskLampSwitch, KhoaNoteSlot, LanBlueEnd, LanWallPort/LanSocket, ManagerApproach, ShowerScreen, ShowerYes, ShowerNo, ShowerStall/Collision, WallKnock406, TrungChargingCable}`, `Room407MainLight`, `Room407DeskLamp`, `Zones/{Bedroom,Bathroom,Balcony}`, `Extension/BathroomDoor` (+ `StuckDoor`), `Victim`, `VictimBed`, `Cam`, `Hall/Cam`, `Hall/Start`, `Anchors/{Extinguisher2F,FireKey,FireDoor,FireAlarm1F,Room203Door,NguBench,Start_garden,Paths/Nhat,Paths/Ngu,GuardLine,BarSpawns}` (campus), `Anchors/Ch4/Room407/{Door,Slat1|2|4,FakeLocker,FakeCeiling,FakeVent}`.

## 8. Sai khác và điều đáng chú ý đã phát hiện (không tự sửa)

1. **Cửa 407 chương 3–4:** collider lá cửa bị `door407_proxy.gd` đưa về layer 0 và thay bằng `Blocker` của proxy. Model cửa mới phải tương thích với proxy hoặc proxy phải đổi cùng lúc (vùng B).
2. **Nhóm `ch2_corpse` có 6 phần tử**, trong đó 3 là xác phòng 310 của CCTV. Mã nào duyệt nhóm này theo nghĩa "ba xác phòng 407" sẽ sai nếu model đổi chỉ ở 407.
3. **`head_position()` sai lệch ~7 cm** giữa fallback (1.55 m) và model campus (1.48 m). Không phải lỗi, nhưng model mới cần chốt chiều cao đầu cho A.
4. **Chuông:** stream 1.5 s không lặp được phát lại trong vòng 20 s bằng `await finished`; đổi sang stream lặp mà không đổi `_ring_bell` sẽ làm chuông không dừng.
5. **Nút báo cháy chỉ tồn tại ở chương 3** vì core tạo bằng mã. D-079/D-081: B cung cấp scene visual riêng để core instance sau điều kiện chương; không đặt sẵn nút tương tác trong campus dùng chung chương 4.
6. **Corpse sống nhờ mã, không nhờ clip:** `corpse_body.gd` đặt `rig.position = (side × 1.25, 0.145, 0)` và xoay Rig bằng mã mỗi frame khi có state. Một model xác có animation sẵn sẽ phải tắt phần này, hoặc thay hẳn script.

## 9. Việc chưa đo (để lại cho Windows/GPU)

B đã có 13 mục đo G0 và 12 ảnh pilot tại `art_source/graphics_upgrade/`, không còn chờ kiểm kê ban đầu. Đây chưa là thống kê toàn phòng/hành lang sau nâng đồ họa, không là số tam giác mỗi frame/VRAM. Trần mẫu balo có trong contract; độ che tia của model mới, ảnh trong game, bộ nhớ và FPS vẫn chưa được nghiệm thu. FPS chưa được phép chạy.

## 10. Consumer bổ sung từ Handoff A/F — D-081

| Consumer | Căn cứ hiện có / ràng buộc | Phần cần G1 tiếp |
|---|---|---|
| Guard | `game/scripts/entity/guard.gd` yêu cầu `warn` và `turn_head_to`; B `campus/actor.gd` chưa cung cấp tương ứng | A/B chốt mapping có chủ đích; không đổi `warn` sang idle im lặng |
| `UnseenPoser` | Seek/pause AnimationPlayer hoặc chọn child pose; không gọi `set_pose` như Ch3Actor. Visibility còn phụ thuộc bounds mesh | A/B giữ snapshot và thời điểm nhìn thấy; chưa là adapter skeleton |
| `door_burst` | Consumer model zombie riêng ngoài Ch3Actor, gọi `grab/walk`; staging theo camera/cửa | A/B/core giữ timing mở cửa và reduce_scares khi đổi visual |
| Xác CCTV 310 | Cùng group `ch2_corpse`, thêm 3 xác ngoài 407 | Contract bao gồm cả 6 xác; không chỉ sửa 3 model trong phòng 407 |
| Gag / Voice | `gag_anchor.gd` của B bám Head mỗi frame, priority 10; GagSpot và CorpseVoice là con nên theo anchor | Giữ cùng nguồn Head/offset, chốt attachment và thứ tự cập nhật nếu đổi rig. Mô tả G0 A nói chưa bám bone không phủ định script bám Head hiện có |
| Âm quản lý | F xác nhận Speech/Step/Knock/Slash/Kill hiện ở root rig; chỉ Drag bám BladeTip qua A `_sync_audio` | Chưa có API âm bám miệng mới; F/A/B phải thống nhất trước khi chuyển |
| Âm zombie | Voice/Foley hiện local zero; `Ch3ZombieLink` và horde quản cadence/số nguồn | Không suy `head_position()` là API audio đã có hoặc chuyển clock sang animation |
| Death camera / HeadHitbox | Đọc Head qua các nhánh hiện có; Head thay đổi ảnh hưởng LOS, ngắm và camera | A/B bảo đảm marker cập nhật cùng frame; fallback/test riêng trước consumer mới |

Đây là tổng hợp code/Handoff, không có thay đổi runtime trong D-081. Các bảng node/clip của G0 tiếp tục là mốc hiện hành; contract nêu rõ phần đã chốt quy ước và phần còn chờ triển khai/kiểm.
