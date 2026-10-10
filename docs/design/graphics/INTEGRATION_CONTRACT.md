# Hợp đồng tích hợp đồ họa gần chân thực — core (T-207, G0)

Người lập: Claude Code web làm phần core theo D-077, 10/10/2026. **Bản đề xuất G0 cho integrator.** Chưa có hiệu lực chung cho tới khi G1 ghép vào `main`; các lane có thể đọc để làm G0 độc lập nhưng chưa nối API chung. Số liệu thật nằm ở [ASSET_BINDINGS.md](ASSET_BINDINGS.md). Kế hoạch gốc: [GRAPHICS_UPGRADE_PLAN.md](../GRAPHICS_UPGRADE_PLAN.md). Âm thanh: **lane F** tiếp nhận toàn bộ vai trò của E (D-078).

## 1. Nguyên tắc (không thương lượng)

1. **Root gameplay giữ nguyên.** Root của vật/nhân vật (vị trí thế giới, `CharacterBody3D`, collider, `Interactable`, marker neo) là của gameplay; visual chỉ là con thay được. Không dịch root, không đổi tọa độ thế giới đã chốt (D-069…D-075), không đổi số xác, thời lượng, bán kính tiếng, luật chết/checkpoint.
2. **Một nguồn sự kiện.** Sự kiện gameplay (`EventBus.noise_emitted`, `slashed`, `corpse_state_changed`, `door_opened`, `player_failed`, `door_damage_changed`, cờ `GameState`…) do **director/AI** phát. Animation, `AnimationPlayer`, marker và rig mới **chỉ trình diễn**, không phát hoặc gọi lại các sự kiện này. Tránh kích hoạt hai lần từ cả clip lẫn mã.
3. **Visual mới không chạm vào va chạm.** Mesh mới không được thêm collider layer 1 trước vùng tương tác (tia `InteractRay` dài 2.0 m, mask 5 gồm world và interactable), không dịch collider, không làm hẹp đường đi đã kiểm (khoảng thông D-058/D-062/D-075).
4. **Model cũ vẫn chạy.** Mọi điểm nối có đường lui về model hiện tại; thiếu model/marker mới thì dùng cái cũ và ghi cảnh báo, không dừng game.
5. **Không có hệ thống tổng quát khi chưa cần.** Chưa thêm registry/autoload/manifest-loader vào core. Core chỉ giữ hằng đường dẫn và `ResourceLoader.exists`, như hiện nay.
6. **Hình ảnh chưa là mặc định.** Chưa đổi main scene, mặc định hình ảnh hay luật chơi trước G3 được duyệt. Hình mới chỉ vào cảnh chương khi integrator ghép.

## 2. Chuẩn hóa visual (cho B, kiểm bởi C)

| Mục | Quy định |
|---|---|
| Đơn vị / trục | Mét; trước = **−Z**; lên = +Y. Model nhân vật có pivot ở **chân** (y = 0), tâm giữa hai bàn chân |
| Root visual | Một `Node3D` gốc, không có `CharacterBody3D`/`StaticBody3D`/`Area3D` layer 1 hoặc 3 bên trong. Collider thế giới (nếu cần) tách riêng và nhỏ gọn, không lấy từ mesh chi tiết |
| Không root motion | Clip không dịch root; di chuyển do gameplay. Hips/Chest được phép chuyển động tương đối bên trong |
| Tỉ lệ | Học sinh/zombie ≈ 1.72 m, guard ≈ 1.91 m, quản lý ≈ 1.92 m (xem ASSET_BINDINGS §4–5); lá cửa 0.88 × 2.08 m; mặt nệm 0.43 / 1.20 m. Sai khác lớn hơn ±5% phải ghi vào manifest và báo A |
| Vị trí đầu | `Head` (Node3D) có mặt ở đúng chỗ đầu thật; A dùng nó cho `head_position()`, B dùng cho `look_at_point`. Chênh lệch với fallback 1.55 m được chấp nhận khi ghi rõ |
| Vật tương tác thay hình | Bounds visual phủ khớp vùng `Interactable` hiện có (không nhỏ hơn quá 30%, không lớn hơn khiến che các vùng bên cạnh); điểm ngắm ở độ cao cũ |
| Đèn có bật/tắt | Giữ `OmniLight3D`/`SpotLight3D` có `visible` + `light_energy` (core đọc `Room407DeskLamp`); ánh sáng bake chỉ cho phần tĩnh |
| Vật liệu | `StandardMaterial3D`/`ORMMaterial3D` được thử trong cảnh pilot; chưa tắt shader PS1 trong cảnh chương |
| Tên node | Giữ các tên trong ASSET_BINDINGS §7.3; đổi tên phải đi kèm bản sửa chỗ hardcode và cập nhật bảng này |

## 3. Cách nối visual vào core

### 3.1 Điểm nối hiện có (không cần API mới)

| Đối tượng | Cách nối | Người gọi | Ghi chú |
|---|---|---|---|
| Quản lý | `DormManager.body_scene` (PackedScene) trước `add_child`; manager tự tìm `AnimationPlayer`, `BladeTip`, `LeftArm` | core (`_spawn_manager`), A (`manager.gd`) | Model mới phải có `BladeTip` (xem §4) |
| Học sinh/zombie/guard/đồng đội | `Ch3Actor.set_body(PackedScene)` | core (`_dress`, `_join`, guard) | `set_body` liên tiếp không nhân đôi model (A phải giữ) |
| Xác 407 | Scene `Corpse*/Body` do B, core chỉ gọi `set_state/set_pose` qua `_corpse_state` | core | Wrapper B giữ API `set_pose/set_state/set_gagged/set_blood_visible/look_at_point` |
| Cửa 407 | Core gọi `Door407.set_open(open, seconds)` / `rattle` / `stop_rattle` | core, manager | Proxy chương 3–4 (B) giữ layer: xem ASSET_BINDINGS §2.1 |
| Phòng 407 | `Room407` API `set_*` (ASSET_BINDINGS §2.3) | core | Core luôn `has_method` trước khi gọi |
| Nút báo cháy | core tạo marker `FireAlarm1F` + `Ch3Use` (chỉ chương 3) | core | Điểm nối dự kiến W1, §6 |
| Chuông | core tạo `AudioStreamPlayer3D` + mồi `noise_emitted` | core, F | Điểm nối dự kiến W2, §6 |

### 3.2 Điều **không** làm trước G1

Không thêm callback `set_visual_adapter`, signal mới trên `EventBus` hay autoload mới trong core. Nếu A đề xuất giao diện adapter dùng chung (T-208) thì core chỉ nối **sau khi** nó được ghép vào `main` và đã có test; core không đoán chữ ký.

## 4. Marker và API cần có (đề xuất tối thiểu cho pilot)

| Marker / API | Loại | Nơi | Cung cấp | Dùng | Khi thiếu |
|---|---|---|---|---|---|
| `Head` | Node3D | model nhân vật/xác/quản lý | B | A (`head_position`, `look_at_point`), core (xác nhìn người chơi) | A dùng `Visual/Fallback/Head` (nhân vật); xác không quay đầu |
| `BladeTip` | Node3D (bám tay cầm dao) | model quản lý | B | A (`manager.gd` `_sync_audio` kéo `Drag`), F | dùng `BladePivot/BladeTip` của fallback; cảnh báo |
| `LeftArm` | Node3D | model quản lý | B | A (cánh tay mở cửa) | fallback `Visual/Fallback/LeftArm` |
| `Rig/Hips/Chest/Head`, `Head/Mouth`, `Head/Eyes`, `Chest/Blood`, `Chest/LeftArm|RightArm`, `LeftLeg|RightLeg/Knee` | Node3D | model xác | B | `corpse_body.gd`, `gag_anchor.gd`, `UnseenPoser` (A) | model xác không đi qua wrapper này; cần adapter A giữ API trong §3.1 |
| Điểm miệng (gắn `GagN`) | Marker/Node3D theo đầu, offset `(0, 0.005, -0.14)` | xác | B | `gag_anchor.gd`, `GagSpot` (A) | `GagN` đứng yên ở vị trí scene; **phải có test bắt** |
| `FireBellMount` (mới, đề xuất) | Marker3D | `Campus/Anchors` | B (vị trí treo chuông) | core `_ring_bell`, F | core dùng `FIRE_BELL_AT + (0, 2.2, -1.8)` như hiện nay |
| `FireAlarm1F` hình (mới, đề xuất) | Node3D con của `Campus/Anchors/FireAlarm1F` hoặc scene B | `Campus` | B | core `_place_fire_alarm` | core vẫn dựng hộp đỏ tạm |
| Điểm dùng bình cứu hỏa | Marker3D `Extinguisher2F` (đã có, `(48.83, -5.50, 2.40)`) | `Campus/Anchors` | B | core `_use` | — |

Marker mới chỉ tồn tại khi B/A đã bàn giao; tên là **đề xuất**, G1 chốt.

## 5. Fallback và kiểm tra bắt buộc

- Core: `ResourceLoader.exists(path)` + `has_method(...)` trước khi gọi API tùy chọn (đã là kiểu hiện nay); thiếu → hành vi cũ.
- Thiếu **marker bắt buộc** (bảng §4): không crash; ghi `push_warning` một lần; dùng fallback. Mỗi marker bắt buộc phải có **test hợp đồng** trên scene chương thật khiến test **FAIL** nếu marker bị bỏ hoặc đổi tên (card T-207 yêu cầu: "gỡ wiring hoặc bỏ marker bắt buộc phải khiến test hợp đồng thất bại").
- Không dùng mock thay cho scene thật; không ghi giá trị mong đợi chỉ để khớp con số tự đặt.
- Cảnh chương 1–4 đều phải được kiểm khi đổi bất cứ thứ gì thuộc phòng 407/hành lang (§7).

## 6. Điểm nối core dự kiến sau G1 (chưa viết, chờ dependency)

| Mã | Việc | Phụ thuộc | Giữ nguyên | Test dự kiến (scene thật) |
|---|---|---|---|---|
| W1 | `_place_fire_alarm`: nếu campus đã có hình nút của B tại `Anchors/FireAlarm1F`, dùng nó và bỏ hộp đỏ tạm; vẫn chỉ tạo ở chương 3, cùng `FIRE_ALARM_AT`, cùng `Ch3Use` `(0.5, 0.6, 0.5)` | G1 + T-209 model nút | tọa độ, vùng dùng, `_bell_rung` một lần, cờ `ch3_fire_alarm` | có/không model mới; chương 4 không có `FireAlarm1F`; bấm hai lần chỉ một mồi |
| W2 | `_ring_bell`: dùng `Anchors/FireBellMount` nếu có; **dừng bằng bộ đếm 20 s thay vì chỉ dựa `await finished`** để chạy được cả stream lặp lẫn không lặp | G1 + T-212 (F) + T-209 vị trí treo | `FIRE_BELL_SECONDS = 20.0`, `noise_emitted(FIRE_BELL_AT, 45.0, &"fire_alarm")`, bus `SFX`, chỉ chương 3 | stream không lặp 1.5 s và stream lặp đều dừng sau 20 s; không phát đôi |
| W3 | Xác, quản lý, nhân vật, cửa, phòng 407: **không đổi core** nếu B giữ API/đường dẫn ở §3.1; chỉ thêm test hợp đồng | G1 + T-208/T-209 | mọi điều ở ASSET_BINDINGS §3–5 | marker/NodePath bắt buộc còn đủ; `set_state` đủ 8 state; `Head` đúng; `BladeTip` có |
| W4 | Hằng `MODELS`/`MANAGER_BODY`: chỉ đổi đường dẫn khi có asset ghép | G2/G3 | `ResourceLoader.exists` giữ | model cũ còn dùng được khi file mới thiếu |

Mỗi mục W đi kèm đường quay lại bằng `git revert` của đúng commit wiring; model/scene cũ được giữ trong repo cho tới khi G3 duyệt.

## 7. Phân vai và quyền sở hữu

| Bên | Sở hữu | Cung cấp cho core |
|---|---|---|
| **Core (Claude web, T-207)** | `docs/design/graphics/*`, các điểm nối trong `game/scripts/core/` & `game/scenes/main/` đã nêu, test `game/tests/core/` | hợp đồng này, bảng binding, wiring W1–W4 theo mốc |
| **A (T-208)** | `game/scripts/entity|player|interaction`, `scenes/entity|interaction`, `tests/player/` | adapter cho quản lý/đồng đội/zombie, `UnseenPoser`, `GagSpot`, `Ch3Use`-kiểu vùng tương tác; giao diện adapter ở G1 |
| **B (T-209)** | `art_source/`, `assets/models|textures`, `scenes/levels/`, `rendering/`, `tests/levels/` | model, scene phòng/hành lang, `corpse_body.gd`/`actor.gd`/proxy cửa, marker §4, manifest asset |
| **C (T-210)** | `tools/graphics/`, `scripts/debug/`, `tests/tools|smoke` | kiểm bounds/marker/tam giác/license; công cụ Meshy dry-run; không chạy FPS khi chưa được phép |
| **D (T-211)** | `game/ui/`, `scripts/ui/`, `assets/fonts/`, key trong `strings.csv`, `tests/ui/` | menu và lưu setting (xem §8); chữ trên biển/giấy/phone đọc được; credits hiển thị |
| **F (T-212)** | `audio_source/`, `game/audio/`, `scripts/audio/`, `default_bus_layout.tres`, `tests/audio/` — toàn bộ vùng âm thanh cũ của E (D-078) | stream chuông (đường dẫn, độ dài, có/không lặp), rig âm thanh bám `BladeTip`/`Head`, marker âm; phối hợp W2 |
| **Integrator** | `STATUS`, `DECISIONS`, `SETTINGS`, `project.godot`, review/merge | chốt G1; cập nhật `docs/SETTINGS.md` trước khi D/B dùng key mới |

Nếu hai lane cùng cần sửa một file (ví dụ `campus/actor.gd`), chỉ B sửa; A gửi yêu cầu qua Handoff.

## 8. Đề xuất settings cho integrator (chưa ghi `SETTINGS.md`, chưa đổi `project.godot`)

Chỉ là đề xuất để integrator cân nhắc ở G1. Theo quy tắc `docs/SETTINGS.md`: D ghi `user://settings.cfg` rồi phát `settings_changed`; lane khác chỉ đọc; thiếu/sai kiểu → mặc định. **Không thêm key vào file người dùng trước khi `SETTINGS.md` được cập nhật**, và không thêm nút không có tác dụng.

| Mục đề xuất | Kiểu | Mặc định | Khoảng | Ai ghi | Ai đọc/áp dụng | Điều kiện dùng |
|---|---|---|---|---|---|---|
| `[video] visual_style` | String | `"classic"` | `classic`, `realistic` | D | B (chọn shader/material, áp dụng ngay khi `settings_changed`); core chỉ **đọc** nếu cần chọn biến thể scene pilot | Chỉ khi B có hình pilot dùng được trong chương; mặc định giữ `classic` tới G3 duyệt (kế hoạch §9) |
| `[video] graphics_preset` | String | `"medium"` | `low`, `medium`, `high` | D | B (đặt bóng, SSAO, độ phân giải render…) | Chỉ khi có backend thật và số đo; giá trị chi tiết do pilot quyết, **chưa tuyên bố đạt FPS** |
| `[video] render_scale` | float | `1.0` | 0.5…1.0 | D | B (scaling 3D) | Chỉ khi B/C xác nhận có tác dụng trong Forward+ |
| `[video] brightness` (đã có) | float | `1.0` | 0.5…1.5 | D | B | Giữ nguyên; cần áp dụng cả khi `visual_style = realistic` |
| `[video] ps1_strength` (đã có) | float | `1.0` | 0…1 | D | B | Giữ nguyên; `realistic` có thể bỏ qua (D xác nhận UI) |

Migration: file cũ không có `visual_style`/`graphics_preset` phải chạy như mặc định, không mất ngôn ngữ/âm lượng/input. Core hiện chỉ đọc `[accessibility] reduce_scares`; hợp đồng này **không** thêm key core ghi.

## 9. Đề xuất cho schema/asset ID (gửi C và B, theo góc nhìn core)

Không gắn core với manifest. Core chỉ cần mỗi asset có bản ghi cho phép kiểm tự động: `asset_id` ổn định, `scene_path`, `binding` (một trong: `door407`, `bunk`, `corpse`, `manager`, `actor`, `fire_alarm`, `fire_extinguisher`, `fire_bell_mount`, `prop`), `root_class`, các `required_markers`, `collider_policy` (`none`/`keep_gameplay`), kích thước thật (bounds, mét), số tam giác/material/texture đo được, license, công cụ AI, tình trạng duyệt. Schema chính thức do C đề xuất, B giữ dữ liệu, thống nhất ở G1.

## 10. Tình trạng đầu ra (cập nhật theo từng đợt)

| Đầu ra | Chủ | Trạng thái G0 (10/10) |
|---|---|---|
| Bảng binding thật | core | **Có**: `ASSET_BINDINGS.md` (số đo từ scene thật, headless) |
| Hợp đồng tích hợp | core | **Có**: tài liệu này; chờ review G1 |
| Giao diện adapter A | A (T-208) | Chờ Handoff của A; core chưa nối |
| Manifest/marker B | B (T-209) | Chờ Handoff của B |
| Schema/công cụ kiểm | C (T-210) | Chờ Handoff của C |
| Settings/UI | D (T-211) | Chờ Handoff của D và cập nhật `SETTINGS.md` của integrator |
| Stream chuông/marker âm | F (T-212) | Chờ Handoff của F |
| Wiring W1–W4 | core | **Chưa làm** (cần G1 + dependency ở §6) |
| Hình ảnh thật, FPS, nghe âm | máy có GPU/người dùng | **Chưa kiểm** (cloud không có GPU) |

## 11. Lệnh kiểm trên Windows cho integrator

Từ gốc repo, trên máy có Godot 4.7.2:

- `pwsh tools/test.ps1` và `pwsh tools/check.ps1` (toàn bộ).
- Lọc phần phòng 407/chương: `pwsh tools/test.ps1 -Filter test_chapter` (chương 1–4), `-Filter test_room407`, `-Filter test_ch3`, `-Filter test_ch4`.
- Khi có wiring W1/W2: `-Filter test_chapter3` cộng tay: bấm nút báo cháy hai lần chỉ một mồi; chương 4 không có nút; chuông dừng sau 20 s; nghe chuông bằng tai.
- Đi bộ thật tới cửa 407, giường, bình cứu hỏa, `FireAlarm1F`, đường 207→203, đường khuôn viên và thanh chắn chương 4; ngắm bằng `InteractRay` để chắc visual mới không chắn tia.

## 12. Điểm cần integrator quyết (không tự đoán)

1. Chọn `visual_style` hay chỉ `graphics_preset` cho pilot (§8), và ai quyết tên khóa.
2. Giao diện adapter chung do A đề xuất, hay giữ mỗi loại một cách nối như §3.1.
3. Tên marker mới `FireBellMount` và vị trí hình nút `FireAlarm1F` trong `Campus.tscn` (B) — chốt ở G1.
4. Có cho phép W2 đổi `_ring_bell` thành bộ đếm thời gian hay giữ stream không lặp 1.5 s (sửa nhỏ, không đổi hành vi nghe thấy).
5. Có gom nhóm `ch2_corpse` của phòng 310 CCTV vào hợp đồng hay giữ riêng (phát hiện ở ASSET_BINDINGS §8.2).
