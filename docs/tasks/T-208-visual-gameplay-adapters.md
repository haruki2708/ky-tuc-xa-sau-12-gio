# T-208 — Adapter model, animation và tương tác giữ nguyên gameplay
- Lane: A | Trạng thái: **G0 đã review/ghép (D-079); G1 tiếp tục, toàn gói chưa done** | Agent: lane A
- Nhánh: `lane-a/T-208-visual-gameplay-adapters`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập, API chung sau G1 T-207; model mẫu T-209 cho G2/G3.
- Hạn đề xuất: gửi bản khảo sát/adapter mẫu trong phiên đầu; bàn giao nhân vật theo nhóm sau đó.

## Bối cảnh
`game/scripts/entity/ch3_actor.gd` đã có `set_body`, `play_pose`, `head_position`; `$Visual/Fallback` và node `Head` cần giữ hoạt động. `manager.gd` tìm `BladeTip`/AnimationPlayer. Các wrapper `campus/actor.gd`, `ch1_models/corpse_body.gd` thuộc B đang dựa vào khớp Node3D; model Meshy có skeleton cần đường nối khác. Game có giường, cửa, bịt miệng, vạt giường và thanh sắt; model đẹp không được che tia ngắm hoặc thay khoảng cách gameplay.

## Việc
1. **G0:** khảo sát consumer của visual trong vùng A: root/collider, pose, Head/BladeTip, điểm tay/miệng, timeline tấn công và death camera. Ghi bảng trong Handoff cho T-207/T-209. Dùng model hiện có để dựng thử adapter nhỏ; chưa cần Meshy.
2. **Sau G1:** triển khai giao diện adapter trong vùng A, chấp nhận visual cũ và visual rig mới; hỗ trợ thay thân nhiều lần, null/fallback, pause, reset scene/checkpoint. Movement/collision do root gameplay giữ, tránh root motion mới gây đi hai lần.
3. **G2:** phối hợp B kiểm một sinh viên trước: đứng/đi/nằm/ngồi/quay đầu; sau đó quản lý và xác. Các pose đặc thù bịt miệng, máu, thức dậy, chém/vồ phải được ánh xạ rõ; không âm thầm bỏ pose thiếu. B tự sửa wrapper/clip vùng B theo hợp đồng.
4. **G3/G4:** kiểm vật tương tác và toàn bộ nhân vật theo từng nhóm. Chỉnh offset hoặc attachment phục vụ model, giữ tầm ngắm, va chạm, tốc độ, AI, sát thương, cooldown và thời điểm luật. Thấy vấn đề do kích thước model thì báo B, không đổi bố cục để che lỗi.

## Được phép sửa
Vùng A trong AGENTS §3: `game/scenes/player/`, `interaction/`, `entity/`, `game/scripts/player/`, `interaction/`, `entity/`, `game/tests/player/`; chỉ các phần liên quan adapter/tương tác. Handoff/checklist card. Không sửa `game/scenes/levels/`, rendering, core, test levels, SETTINGS. Yêu cầu B/core ghi qua Handoff.

## Test và bằng chứng
- Test thay visual trên actor thật: root transform/collider không dịch ngoài chủ đích; `set_body` liên tiếp không nhân đôi model; Head theo đầu mới, fallback hợp lệ; pose/pause/reset đúng.
- Với nhân vật có rig: marker theo bone khi chuyển động; timing sự kiện không nhân đôi, animation không chiếm movement AI. Có fixture lỗi marker/pose để chứng minh kiểm tra bắt đúng lỗi.
- Kiểm `InteractRay` thật cho giường/cửa/đồ được thay; đi bộ đến vị trí tương tác. Chạy các test D-069…D-075 liên quan trên scene thật khi ghép dependency B.
- Chạy toàn bộ `pwsh tools/test.ps1` và `pwsh tools/check.ps1`; chưa có model mới thì ghi rõ giới hạn, không báo đã tương thích Meshy.

## Checklist hoàn thành
- [x] G0: bảng ràng buộc và prototype adapter (model hiện có, 5 test; chưa nối production)
- [ ] G1: API thống nhất với web/B/F (F tiếp nhận E theo D-078)
- [ ] Pilot nhân vật/đạo cụ kiểm trong scene thật
- [ ] Không đổi hành vi AI/collision/timing và có fallback
- [x] Full test/check PASS, Handoff phân biệt mẫu thử và production (mốc G0; mốc sau phải kiểm lại)

## Handoff (agent điền)

### G0 — khảo sát và prototype riêng, 10/10/2026

- Nhánh `lane-a/T-208-visual-gameplay-adapters`, tạo từ `origin/main` tại `e3ed54a` (có D-077/D-078). Workspace ban đầu sạch; đã `git fetch origin`. Chỉ làm trong `D:\GAME_WORK\lane-a`.
- Prototype: `game/scripts/entity/visual_adapter_g0.gd`, `game/scenes/entity/visual_adapter_g0.tscn`; dùng nguyên `game/assets/models/campus/nhat.tscn` và wrapper B hiện có. Không sửa asset hoặc consumer production. Đây là thử nghiệm G0, **không phải API chung đã chốt, không chứng minh tương thích Skeleton3D/Meshy**.
- Test: `game/tests/player/test_visual_adapter_g0.gd`, gắn prototype qua `Ch3Actor.set_body()` trên `companion.tscn` thật. Kiểm root/collider/nav khi đổi pose, đầu theo transform model, lỗi marker/pose/collision, thay thân nhiều lần rồi null, pause và instance scene mới. Fixture tắt physics tick của companion để cô lập visual; không chạy bot chương 3–4.
- **G0 hoàn tất**, tài liệu này là đầu ra cho web T-207, B T-209 và F T-212; chưa chuyển trạng thái cả gói sang done. Chưa có `docs/design/graphics/INTEGRATION_CONTRACT.md` trên baseline; kiểm remote lúc 20:33 vẫn thấy main=`e3ed54a`, chưa đủ điều kiện G1.

### Bảng ràng buộc đọc từ baseline cho T-207/T-209/T-212

Các đường dẫn bên dưới tính từ `game/`; kích thước là mét, thời gian là giây. Số trong bảng là cấu hình/code hiện hành, chưa phải số đo render hoặc ngân sách asset mới.

| Consumer / đường dẫn | Root, collider, marker hiện hành | Pose/timing phải giữ và điểm nối cần chốt |
|---|---|---|
| `scripts/entity/ch3_actor.gd`; `scenes/entity/{companion,zombie,guard}.tscn` | Root `CharacterBody3D`; capsule r=0.25, h=1.7, tâm y=0.85; layer/mask=1/1. `NavigationAgent3D` r=0.3, h=1.7, khoảng đạt path/target=0.2/0.15. Model con `Visual`; fallback `Visual/Fallback/Head` y=1.55. `face()` quay root theo -Z, `navigate_to()` sở hữu movement, bước lên tối đa mặc định 0.3. | `set_body(PackedScene)`, `play_pose(StringName)`, `head_position()` hiện hữu. Chọn `set_pose`, rồi `set_state`, rồi clip cùng tên; chưa kiểm bool thất bại. `head_position()` tìm đệ quy node tên `Head`, không gọi API trên model. Null/root không phải Node3D dùng fallback. Không đặt collider/nav hoặc root motion trong model. |
| `scripts/entity/zombie.gd`; `scenes/entity/zombie.tscn` | `HeadHitbox` là Area3D thuộc root, sphere r=0.31, layer/mask=4/0; logic cập nhật theo `head_position()` khi stun/tick/đổi pose. LOS cũng dùng đầu. | `idle/sit/lie/wake/walk/stunned/grab`; speed=1.5, wake distance=25, catch=1.0, bash cửa=10, sparse tick=0.3 mặc định. Đổi vị trí đầu có thể đổi cả ngắm/LOS, không chỉ hình ảnh. Clip không phát caught/stun/damage. |
| `scripts/entity/companion.gd`; `assets/models/campus/{nhat,ngu}.tscn` | Root trên; `campus/actor.gd` điều khiển `Model/Rig/Hips/Chest/Head`, hai nhánh `LeftArm/Elbow/Hand`, `RightArm/Elbow/Hand`. `nhat` dùng `cctv/student_kiet.tscn`; Hips y=0.85, Head tương đối Chest y=0.63, đầu đứng nghỉ khoảng y=1.48. | Wrapper có `idle/walk/stunned/grab/sit/lie/wake`. Đi dùng dao động 6.5 rad/s; wake blend 1.5. Companion speed=2.6/catch-up=3.8; animation không đổi tốc độ này. Wrapper B xóa AnimationPlayer của model con và thao tác khớp Node3D: không thể thay thẳng bằng GLB skeleton. |
| `scripts/entity/guard.gd`; `assets/models/campus/guard.tscn` | Root trên, thêm `Visual/Baton`; `turn_head_to()` gọi model nếu có, nếu không quay đầu fallback. | Cảnh báo 3.0, bắt 1.5. Consumer yêu cầu `warn`, **wrapper campus không có pose này**; wrapper cũng chưa có `turn_head_to()`. Cần B/web chốt ánh xạ có chủ đích, không tự đổi `warn` thành `idle/grab`. |
| `scripts/entity/manager.gd`; `scenes/entity/manager.tscn`; `scenes/levels/ch1_models/manager_body.tscn` | Root CharacterBody3D capsule r=0.3, h=2.0, tâm y=1; layer/mask=0/1, snap=0.2. Quay `Visual`, không quay root để nhìn mục tiêu. Tìm AnimationPlayer đầu tiên, `LeftArm`, `BladeTip`; model có tip dưới `Rig/Hips/Chest/RightArm/Elbow/Hand/BladeTip` (y=-0.855 so với Hand) và proxy ở root. Fallback `BladePivot`=(0.45,1.15,0), tip=(0,-1.15,0). | Clip `stand/walk/ask/slash/lunge/kill`; slash 6 lần, interval=0.45 (clamp tối thiểu 0.05), tính bằng `_tick_slash()`, `speed_scale=clip.length/seconds`. Lunge speed=5, duration=0.65, khoảng dừng=0.65; kill=0.65 hoặc 0.15 khi reduce scares. Mở cửa tween tay theo 20%/60%/20% thời lượng caller; stop dùng serial hủy lượt cũ. Không phát signal chém lần hai qua animation method track. |
| Manager/audio | `_sync_audio()` đặt rig âm ở gameplay root; chỉ `Drag` theo BladeTip. Nghe đo từ root+(0,1.6,0), mặc định 4 m; bước âm mỗi 0.7 m. | F xác nhận marker âm kéo dao theo clip và speech theo body hiện tại. Không tự chuyển điểm nghe sang bone hoặc thay khoảng nghe khi model cao hơn. |
| `scripts/entity/unseen_poser.gd`; `scripts/entity/entity_visibility.gd` | Visibility lấy root và tâm/8 góc AABB của từng mesh đang hiện, ray world mask=1. Đổi kích thước mesh có thể đổi lúc bị nhìn thấy. | `dead_a/dead_b/head_turn/eyes_open`; interval mặc định 4, chance=0.35, khoảng thấy=15. `UnseenPoser` seek AnimationPlayer đến cuối clip rồi pause hoặc bật child pose; **không gọi `set_pose()`**. Rig mới cần giữ snapshot đứng yên khi nhìn lại; A/B/web phải chốt đường adapter riêng. |
| `scripts/player/gaze_detector.gd` | Nhìn điểm `target.global_position` do caller gán; mặc định góc=35°, hold=0.5, LOS tắt. Khi bật LOS dùng world mask=1. | Thay marker/mesh không được tự đổi target gameplay hoặc ngưỡng nhìn. Reset khi camera/target đổi, chỉ phát `gazed` một lần mỗi lượt. |
| `scenes/levels/ch1_models/corpse_body.gd` (B); caller `scripts/core/chapter2_director.gd` (core) | `Rig/Hips/Chest/Head/Mouth`; Gag gắn dưới Head ở (0,0.005,-0.115), scale=(0.65,1.5,0.40). Hai tay dưới Chest; blood ở `Chest/Blood`. GagSpot/nguồn thoại thực tế core gắn vào room anchor `Gag1/2/4`, chưa tự bám bone. | Pose `dead_a/dead_b/head_turn/eyes_open/sit_up`; state `sit_play/talk/gagged/mumble/fall/revive/lunge/slump`; API độc lập `set_gagged`, `set_blood_visible`, `look_at_point`. Fall=0.40, slump=0.65, revive=0.22, lunge=0.28 là blend visual hiện hành. Gag giữ qua fall/revive/slump; không gộp state vào pose làm mất gag/máu. |
| `scripts/player/player_death.gd` | Corpse/zombie: ưu tiên `head_position()`, rồi `GazeTarget` trực tiếp, rồi Head đệ quy, cuối cùng root. Manager hiện ngắm root+(0,1.7,0). Camera sweep sphere r=0.1, world mask=1; điểm nằm cuối cao hơn sàn 0.15. | Tổng duration=3.0; nhìn corpse/zombie 0.7 đầu, manager 0.8 đầu; zombie kéo camera 0.3 rồi ngã. Reduce scares giữ nhánh riêng. Marker visual mới không được đổi verdict/checkpoint/timing camera. |
| `scripts/player/door_burst.gd` | Dựng bàn tay/3 zombie visual riêng từ `assets/models/campus/zombie_01.tscn`; gọi `grab/walk` trực tiếp. Root staging `top_level=true`, focus cao 1.25 so với chân player tại cửa; không gắn vào AI. | Tay ẩn sau 1.0; cửa bật mở lúc 0.5 (tắt Blocker deferred), đám xác tiến trong 0.5–2.2; mảnh gỗ hiện 0.5–1.5. Đây là consumer model riêng ngoài `Ch3Actor`, phải đưa vào bindings; giữ nhánh reduce scares. |
| `scripts/player/iron_bar_weapon.gd` | Viewmodel tự tạo dưới Camera3D tại (0.28,-0.3,-0.6); hai đoạn 0.35/0.5, khớp cong y=0.35. Ray đánh dài 1.5, mask=5, bật area; nhận zombie qua metadata của HeadHitbox. | Cooldown/swing=0.55, stamina=0.08, tối đa 8 hit trúng, stun=5.0; hit tính ngay trong `swing()`, không đợi animation chạm đích. Model mới không dời thời điểm hit sang animation event. |
| `scripts/entity/pursuer.gd`; `scenes/entity/pursuer.tscn` | Ngoại lệ root Node3D theo chân `Body` CharacterBody3D; capsule r=0.3/h=1.8, tâm y=0.9, layer/mask=0/1; visual ở `Body/Visual`. Âm Footsteps y=0.15, Breath y=1.5. | Chỉ gắn `body_scene` ở ready, không hợp đồng pose. Speed=2.9, catch=0.8, give-up=2.0; adapter không được làm root và Body cùng dịch. Giữ trong kiểm kê legacy, chưa đưa vào pilot. |
| `scenes/player/player.tscn`; `scripts/interaction/{hide_spot,bunk_spot}.gd`; `scenes/interaction/bunk_spot.tscn` | `Head/Camera3D/InteractRay`: dài 2, mask=5 (world + interactable). Bunk pick box=(1.15,0.5,1.9), layer/mask=4/0; tâm y=0.25, giường 1/4 y=0.3. View=(0,0.8,-0.6), Exit=(0,0.02,0.8); scene chủ có thể đặt lại anchor. Chương >1 đổi pick box=(0.8,0.5,0.2), tâm y=0.7. | Giường trên entry=0.5, dưới=0. `View/Exit` là camera/điểm ra gameplay, không là bone để kéo theo model. Cần ray và đi bộ thật kiểm giường/cửa 407 sau khi B giao pilot; không nới ray hoặc sửa layout che lỗi model. |
| `scripts/interaction/{carry_item,gag_spot,bed_slat,iron_bar}.gd`; `scenes/interaction/gag_spot.tscn` | CarryItem theo camera offset=(0.24,-0.22,-0.55); khi cầm layer=0, thả trả layer=4. GagSpot pick box=(0.26,0.18,0.15), layer/mask=4/0. BedSlat dùng `SlatPivot`; iron bar pickup xóa node sau khi giao vật. | GagSpot chỉ phát `gag_requested`, core chấp nhận/tiêu vật. BedSlat hold=5, tween xoay -0.48π trong 0.45 sau hoàn tất. IronBar max_hits=8 mặc định. Tay/miệng/mesh thay đổi phải giữ các vùng và trình tự tương tác này. |

### Đề xuất để chốt G1, chưa áp dụng chung

1. Giữ gameplay root, `Visual`, fallback và collider/nav thuộc A; B cung cấp model thuần visual, chuẩn mét/-Z/pivot chân, offset chỉ nằm dưới Visual. Pilot `nhat` dùng đường Head tường minh `Body/Model/Rig/Hips/Chest/Head`; sau G1 B chịu trách nhiệm node marker/BoneAttachment3D bám bone. Cần phân biệt tay trái/phải bằng đường dẫn, không tìm chung tên `Hand`.
2. Web ghi mapping pose/state/clip/marker theo từng actor vào ASSET_BINDINGS; A nhận kết quả thất bại rõ ràng, không âm thầm nuốt pose thiếu. Không mặc định set_pose/set_state tương đương: corpse có cả hai và khác ngữ nghĩa. Chưa thêm EventBus/autoload/setting/registry mới.
3. Head phải cập nhật cùng frame animation và đọc được ở world space; HeadHitbox/LOS/death camera dùng nguồn đã thống nhất. BladeTip cần bám tay/dao; Mouth/Gag cần B/F/core chốt có giữ room anchor tương tác/âm hay chỉ thêm attachment visual. Không tự đổi điểm phát thoại hoặc pick volume.
4. Animation chỉ trình bày; timer/AI/root/collision, signal chém/bắt/chết do logic hiện hành sở hữu. B không thêm method track gọi gameplay hoặc root motion dịch root. G1 phải quy định pause/reset, quyền ghi transform đầu/tay và cách không tranh với procedural animation.
5. `Ch3Actor.set_body()` hiện `queue_free()` model cũ nên nhiều model có thể còn trong cây **đến hết frame**; test G0 chỉ chứng minh còn một model sau deferred free. `_played_pose` cache cũng chưa phản ánh lời từ chối pose. Đề nghị A xử lý lifecycle/acknowledgement sau G1, kèm test thay nhiều lần cùng frame; không tuyên bố đã sửa ở G0.

### Yêu cầu thay đổi ngoài phạm vi

- **Web/core T-207:** tổng hợp bảng này vào contract/bindings, xác định đường nối corpse/UnseenPoser/death camera và quyền marker; integrator review/ghép G1 lên main trước khi A triển khai consumer chung. Không yêu cầu đổi luật/lời thoại/setting.
- **B T-209:** cung cấp pilot sinh viên với bảng pose/marker và quyền điều khiển khớp; làm rõ `warn`/quay đầu guard, các clip thiếu; B tự sửa wrapper `campus/actor.gd`/`corpse_body.gd` và asset. Không gắn skeleton trực tiếp vào wrapper đang giả định Rig Node3D.
- **F T-212:** xác nhận BladeTip/Drag và mouth/speech theo bảng, không chuyển tọa độ âm trong G0 của A.
- **Lượt Windows:** đã gửi yêu cầu điều phối, kiểm tra không có Godot trước khi bắt đầu full test lúc khoảng 19:51; chủ dự án xác nhận “Cấp lượt cho lane A khi prototype sẵn sàng” lúc khoảng 19:57. Test/check chạy tuần tự; kiểm tra lại không có Godot và báo trả lượt lúc 20:39 (UTC+07). Không chạy render/FPS/bot.

### Kiểm chứng và phần chưa đạt

- Lượt full test đầu (khoảng 19:51–20:11): **FAIL, exit 1**. Runner in `RESULT: 727 passed, 0 failed` nhưng launcher bắt đúng `SCRIPT ERROR`: fixture G0 đọc nhầm `NavigationAgent3D.global_transform` (node này không có transform). Không dùng dòng PASS của runner để báo đạt. Đã sửa fixture sang so node/cấu hình nav (radius, height, khoảng path/target, target_position, avoidance); không sửa gameplay/core. Log: `build/t208-g0/full-test-attempt1.log`.
- Kiểm riêng sau sửa: `pwsh tools/test.ps1 -Filter test_visual_adapter_g0` → **`RESULT: 5 passed, 0 failed`, exit 0**. Log: `build/t208-g0/focused-test.log`.
- Full test sau sửa (khoảng 20:12–20:32): `pwsh tools/test.ps1` → **`RESULT: 727 passed, 0 failed`, exit 0**; gồm 5 test G0. Không có SCRIPT ERROR/ERROR. Log: `build/t208-g0/full-test.log`.
- Full check (20:32–20:39): `pwsh tools/check.ps1` → **`RESULT: check 0 error(s)`, exit 0; 336 script parse PASS**. Log: `build/t208-g0/check.log`. Log nằm trong build cục bộ, không commit. `git diff --check` sạch. Không sửa code sau lượt full test đạt; chỉ hoàn thiện báo cáo kết quả/checklist.
- Số đo fixture sau mỗi `set_pose()` + một bước animation 0.25 s, tọa độ Head cục bộ theo actor (m): idle=(-0.002414,1.479995,0), walk=(0,1.504963,0), sit=(0,1.03,0), lie=(0,0.18,0.68), wake=(0,0.533052,0.762904), stunned=(0,1.148925,0.451934), grab=(0,1.469821,0.112789). Actor đặt world=(4,2,-3), yaw=0.7 rad; test so Head world thực và kiểm root/collider/cấu hình nav không đổi. Đây là mẫu khớp Node3D sẵn có, không phải rig mới.
- Chưa kiểm rig skeleton/bone attachment, visual mới, InteractRay/đi bộ với model mới, ảnh trước/sau, bốn chương sau tích hợp, checkpoint reload thực tế, timing marker trong clip mới, render/FPS, nghe/chơi tay. Test tạo actor mới không thay cho checkpoint round-trip.
- G1/G2/G3/G4 còn mở. G2 phụ thuộc pilot B và điều kiện kết nối/ngân sách/license Meshy khi dùng Meshy; không tiêu credit hoặc cài MCP/plugin. G0 không cần các quyền đó.
- **Blocked (phần sau G0):** chờ contract G1 được integrator ghép main và A rebase; chưa triển khai adapter production hoặc tự ánh xạ pose/setting mới. G0 không còn chặn. Yêu cầu ngoài phạm vi gửi web/B/F ở mục trên.
- Commit bàn giao G0: `T-208: survey visual bindings and add isolated G0 adapter` (commit chứa Handoff này), nhánh `lane-a/T-208-visual-gameplay-adapters`; push bằng `git push -u origin lane-a/T-208-visual-gameplay-adapters`. Hash/kết quả push ghi trong báo cáo phiên. Không sửa STATUS/DECISIONS/Review, không push main hoặc mở PR.

## Review (integrator)

### 11/10/2026 — Astra, D-079

- Nhận **G0** từ lane A, commit `e27fe28`; ghép cùng năm nhánh còn lại. **Chưa đánh dấu toàn bộ T-208 done.**
- Nhận khảo sát, adapter biệt lập và 5 test với model cũ. Chưa chứng minh Skeleton3D/checkpoint thật hoặc sửa lifecycle cùng frame. Làm rõ acknowledgement pose, warn/quay đầu guard, UnseenPoser/door_burst; GagSpot hiện bám anchor do gag_anchor.gd của B cập nhật theo Head, không được coi là điểm cố định.
- Phạm vi diff đạt; không nới test, không đổi gameplay/default. Không sửa code lane trong lượt review này.
- Full Windows test/check bản ghép và kiểm `--t202-integration` là điều kiện trước commit. Kết quả thực/thời điểm/log ở message commit `D-079`; không dùng số test lane riêng thay kết quả tích hợp.
- Đọc [báo cáo chung và yêu cầu G1](../handoff/REVIEW_G0_2026-10-11.md), làm phần Review của lane trên nhánh hiện có sau fetch/rebase; không tự dùng contract G0 như API production đã chốt. Chưa chạy Meshy trả phí hoặc FPS/bot.
