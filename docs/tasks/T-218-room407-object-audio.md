# T-218 — Âm thanh phòng 407 khớp đồ mới: quạt trần, đèn tuýp, vòi sen, gương
- Lane: F (Âm thanh) | Trạng thái: **done (D-111), chờ chủ dự án nghe** | Agent: Claude Code web, Sonnet 5.5 (D-108)
- Phụ thuộc: D-103…D-106, D-109, **D-110** trên `main`. Quyết định giao: D-110 (chủ dự án: "ok tôi đồng ý, bạn thực hiện đi").
- Nhánh: `lane-f/T-218-room407-object-audio` từ `origin/main` mới nhất. Làm theo `docs/handoff/web.md` mục 1.
- Không đụng T-212 (chuông báo cháy vẫn chờ marker G1). Task này độc lập.

## Bối cảnh
G3 (D-103…D-106, D-109) đã thay phòng 407 trong bản chơi bằng đồ mới (Tripo/Blender): quạt trần mới, đèn tuýp sáng hơn và có bóng, vòi sen mới, hai gương phản chiếu thật, bảng sen tắm dời sang tường tây. **Âm thanh vẫn đặt theo phòng PS1 cũ.** Toạ độ dưới đây là toạ độ cục bộ của `Room407` (lấy từ source trên `main`, cần kiểm lại):

| Âm | Nguồn hiện tại | Vật mới (G3) |
|---|---|---|
| Quạt trần | `FanAmbience` trong `game/scenes/levels/floor4/room_407.tscn`, (2; 2,4; −2,5), `ambience/ceiling_fan.ogg`, bus Ambience, −12 dB, unit_size 4, max_distance 22 | `CeilingFan` (2; 3,0; −2,5), `ceiling_fan_split.glb` (`game/data/room407/placements.json`). Cánh quay trong `chapter1_main.gd`/`main.gd` qua node tên `fan_rotor` |
| Đèn tuýp | `Room407MainLight/LightHum` (`scripts/audio/light_hum.gd`), −10 dB, unit_size 2, max_distance 6; tiếng chập `sfx/fluorescent_flicker.ogg` | D-104: đèn sáng hơn (`flicker_energy` 2,6, tầm 9 m, có bóng) qua `flicker_light.gd`; chương 1 chập chờn qua `chapter1_director.gd::_set_flicker` |
| Vòi sen | `ShowerAudio` (`scripts/audio/shower_audio.gd`) do `chapter2_director.gd` gắn dưới `Anchors/ShowerStall` (6,18; 1,2; −6,32): nước, hơi nước, tiếng đẩy cửa, cue | `Shower` (6,18; 0,8; −6,69), quay 180°; bảng sen + nút ở tường tây (5,387; 1,45; −6,0) theo D-109 |
| Gương | cue `mirror_shiver` phát từ `ShowerAudio` (chương 2) | `MirrorSmall` (5,383; 1,12; −5,0) trên tường tây nhà tắm, `FullMirror` (6,6; 0; −3,78) |

## Việc cần làm
1. **Khảo sát:** bằng scene tạm headless (trong `game/_tmp`, xóa trước khi commit), đo vị trí thật trên thế giới của từng nguồn âm và của vật mới ở cả 4 chương (`scenes/main/chapter1…4.tscn`). Ghi bảng lệch (m) vào Handoff. Kiểm quạt có quay ở chương nào thì phải có tiếng ở chương đó và ngược lại; ghi lại chỗ không khớp.
2. **Chỉnh trong vùng F:**
   - Quạt và đèn: dời/chỉnh `FanAmbience`, `LightHum` cho nguồn nằm ở vật mới; đề xuất âm lượng/tầm nghe vừa căn phòng (chủ dự án thích âm nhỏ; mặc định **không tăng** âm lượng).
   - Đèn tuýp: kiểm tiếng rè tắt/bật cùng nhịp chập chờn của đèn mới (D-104 đổi năng lượng đèn). Không đổi nhịp đèn.
   - Vòi sen: cho tiếng nước phát từ đầu vòi sen mới thay vì giữa khoang tắm. Làm trong `shower_audio.gd` (ví dụ export độ lệch hoặc tự tìm vị trí vòi qua đường dẫn có sẵn, có fallback giữ nguyên vị trí cũ khi không tìm thấy). Không đổi API `set_water`, `set_steam`, `play_cue`, `play_door_push`.
   - Gương: `mirror_shiver` nên phát ở gương người chơi đang nhìn trong cảnh chương 2. Xem cảnh đó gọi từ đâu; nếu cần sửa ngoài vùng F thì ghi "Yêu cầu thay đổi".
   - Chỉ thêm âm mới khi thiếu thật, CC0/CC-BY hoặc tự tổng hợp, ghi nguồn; đo LUFS/peak như T-212.
3. **Cảnh nghe thử** `game/audio/graphics_upgrade/room407_audio_preview.tscn` (+ `.gd`):
   - dựng phòng 407 có người nghe ở giữa phòng và ở cửa nhà tắm;
   - phím bật/tắt từng nguồn: quạt, đèn, đèn chập, nước lạnh/ấm/sôi, hơi nước, `mirror_shiver`;
   - so trước/sau nếu có thể.
   Chủ dự án mở trên Windows để nghe. Hướng dẫn ghi vào `audio_source/graphics_upgrade/README.md`.
4. **Test** `game/tests/audio/test_room407_object_audio.gd`:
   - mỗi nguồn nằm trong khoảng hợp lý quanh vật mới;
   - nước vòi sen vẫn phát/dừng đúng theo `set_water`;
   - nguồn không phát ở gốc thế giới khi thiếu node;
   - không có nguồn trùng khi reload;
   - các test âm thanh cũ (`--filter=audio`) và test chương 2 vẫn đạt.

## Được phép sửa
- `game/scenes/levels/floor4/room_407.tscn`: **chỉ** thuộc tính (vị trí, âm lượng, unit_size, max_distance, stream) của hai node `FanAmbience` và `Room407MainLight/LightHum`.
- `game/scripts/audio/shower_audio.gd`, `game/scripts/audio/light_hum.gd`. `light_hum.gd` dùng ở hành lang, nhà vệ sinh, thư viện, bệnh viện, nên mọi thay đổi phải giữ nguyên hành vi mặc định ở các cảnh đó.
- File mới trong `game/audio/graphics_upgrade/`, `audio_source/graphics_upgrade/`, `game/tests/audio/`; `game/audio/CREDITS.md`, `game/audio/graphics_upgrade/CREDITS.md`.

## Không được
- Không sửa `chapter2_director.gd`, `chapter1_director.gd`, `room407.gd`, `flicker_light.gd`, `room407_anchors.tscn`, `placements.json`, `game/default_bus_layout.tres`, `strings.csv`, `project.godot`. Cần thì ghi "Yêu cầu thay đổi".
- Không đổi luật, thời gian, nhịp chập chờn, nội dung lời thoại, bán kính tiếng ồn AI (`noise_emitted`).
- Không đo FPS, không chạy bot.

## Bàn giao (theo `web.md` Bước 5–6)
- Kết quả test hai lượt (trước khi sửa và sau khi sửa) trên Linux.
- Bảng lệch vị trí trước/sau.
- Danh sách âm chủ dự án cần nghe (cảnh nghe thử + chương/cảnh thật: chương 1 phòng 407 khi đèn chập, chương 2 nhà tắm).
- Phần chưa kiểm được vì máy cloud không có loa/card đồ họa.
- Yêu cầu thay đổi ngoài vùng F.

## Handoff (agent điền)

### Claude Code web, lane F, D-108 — 15/10/2026 (UTC), nhánh `lane-f/T-218-room407-object-audio` từ `origin/main` `a167d6e` (D-110)

**Tóm tắt:** đo vị trí thật của mọi nguồn âm phòng 407 trong cả 4 chương, dời nguồn âm cho khớp đồ G3, thêm cảnh nghe thử và 10 test. Quạt và đèn tuýp vốn đã gần đúng (lệch ≤ 14 cm vì D-103…D-106 giữ nguyên toạ độ); chỗ lệch thật là **vòi sen (1,03 m)** và **mirror_shiver (1,48 m)**. Không thêm file âm, không đổi âm lượng, không đổi `light_hum.gd`. **Chưa ai nghe; máy cloud không có loa.**

#### Bảng lệch vị trí (toạ độ cục bộ `Room407`, mét; đo bằng scene tạm headless trong `game/_tmp`, đã xóa; chương 1–4 đều đo)

| Nguồn | Vật mới (đo trong cảnh) | Trước (khoảng cách tới vật) | Sau |
|---|---|---|---|
| Quạt trần `FanAmbience` | tâm cánh `fan_rotor` của `CeilingFan` mới (2; 2,54; −2,5) | (2; 2,40; −2,5): **0,143** | (2; 2,54; −2,5): **0,003** |
| Tiếng ù đèn `LightHum` | tâm hai ống `FluorescentTube` mới (2; 2,84; −1,20) | (2; 2,78; −1,20): **0,060** | (2; 2,84; −1,20): **0,000** |
| Nước vòi sen `ShowerAudio/Water` | đầu phát nước thấy được `Ch2Bathroom/Water` (6,18; 2,17; −6,65); mô hình `Shower` mới cao đến y 2,05, tâm xz (6,18; −6,69) | tâm khoang `ShowerStall` (6,18; 1,20; −6,32): **1,025** so với điểm nước rơi | (6,18; 2,17; −6,65): **0,000**; cách tâm mô hình theo xz 0,039 |
| `mirror_shiver` (cue chương 2 slot 12) | bóng quản lý `Ch2Bathroom/Reflection` trên gương nhỏ (5,52; 1,15; −5,0); kính `ReflectiveMirrorSmall` (5,40; 1,41; −5,0) | tâm khoang (6,18; 1,20; −6,32): **1,478** (kính: 1,546) | (5,52; 1,15; −5,0): **0,000** (kính: 0,283) |
| Tiếng đẩy cửa, `door_burst`, `Cue` | cửa nhà tắm `Extension/BathroomDoor` (5,35; 0; −4,0) | tâm khoang, cách cửa khoảng 2,4 m | **giữ nguyên** (xem "Ghi nhận") |
| Hơi nước `Steam`, tiếng bíp `shower_beep` | khoang tắm | tâm khoang | giữ nguyên |

Quạt có quay ở **cả 4 chương** (`chapter1_main.gd` gom `fan_rotor` của phòng mới, test xác nhận), và `FanAmbience` đang phát ở cả 4 chương, nên không có chỗ quạt quay mà thiếu tiếng hay ngược lại. `ShowerAudio` chỉ có ở chương 2 (do `chapter2_director.gd` dựng), đúng như trước. Đèn chính phòng 407 tắt lúc vào cảnh (`chapter1_main.gd`), nên tiếng ù chỉ có khi đèn sáng hoặc đang chập.

#### Đã làm
1. `game/scenes/levels/floor4/room_407.tscn` (chỉ thuộc tính vị trí hai node, đúng phạm vi card): `FanAmbience` y 2,40 → 2,54; `LightHum` thêm `position = (0; 0,06; 0)`. `volume_db`, `unit_size`, `max_distance`, stream giữ nguyên.
2. `game/scripts/audio/shower_audio.gd`: nước phát tại `Ch2Bathroom/Water`; `mirror_shiver` phát tại `Ch2Bathroom/Reflection`, dự phòng `ReflectiveMirrorSmall`. Tìm node từ tổ tiên chứa `ShowerStall`; thiếu node thì về tâm khoang (vị trí cũ), không bao giờ về gốc thế giới (có test). Thêm `@export var follow_fixtures` (mặc định `true`; `false` đưa mọi nguồn về chỗ cũ, dùng cho so sánh). Đẩy cửa và `door_burst` giữ chỗ cũ. API `set_water`, `set_steam`, `play_cue`, `play_door_push` không đổi.
3. `game/scripts/audio/light_hum.gd` **không sửa.** Đã kiểm: tiếng ù theo năng lượng thật của đèn mỗi frame; `flicker_light.gd` (D-104) chỉ đổi biên độ xung (0,7 → 2,6) chứ không đổi nhịp 0,73 s nên tiếng ù tắt/bật khít xung của đèn mới. Test chạy đèn thật chập 1,7 giây, mỗi frame so `hum.playing` với trạng thái đèn: 0 lệch.
4. Cảnh nghe thử `game/audio/graphics_upgrade/room407_audio_preview.tscn` (+ `.gd`): phòng 407 đủ đồ, mở im lặng, người nghe ở giữa phòng (`C`) hoặc ở cửa nhà tắm (`B`); phím bật quạt (`F`), đèn (`L`), chập (`K`), nước lạnh/ấm/sôi (`1/2/3`), tắt nước (`0`), hơi nước (`S`), `mirror_shiver` (`M`), **đổi vị trí mới ↔ cũ (`T`)**, tắt hết (Space), nạp lại (`R`), thoát (Esc). Hướng dẫn và danh sách nghe: `audio_source/graphics_upgrade/README.md` (mục T-218).
5. Test `game/tests/audio/test_room407_object_audio.gd` (10 test): nguồn nằm trong 10 cm quanh tâm quạt/đèn và trong mô hình; âm lượng nền không tăng; ù đèn khít xung chập; nước từ chỗ nước rơi và vẫn bật/tắt theo `set_water`; `mirror_shiver` ở bóng gương, đẩy cửa giữ chỗ cũ; thiếu node → tâm khoang chứ không phải gốc thế giới; `follow_fixtures=false`; 3 lần nạp lại phòng chỉ còn một nguồn mỗi loại và `checkpoint_loaded` tắt hết; quạt quay và có tiếng ở chương 1–4; cảnh nghe thử im lặng khi mở và các phím chạy. Chạy thử bộ test mới với code cũ (`room_407.tscn` và `shower_audio.gd` của `origin/main`): 5/10 **FAIL** đúng chỗ (quạt lệch 0,143 > 10 cm, nước, gương, thiếu node, quạt ở 4 chương); các test còn lại pass vì không phụ thuộc vị trí (ù đèn chỉ lệch cũ 6 cm, âm lượng, nạp lại, cảnh nghe thử, `follow_fixtures`).
6. `game/audio/graphics_upgrade/CREDITS.md`: ghi T-218 không thêm asset âm thanh.

#### Đề xuất âm lượng/tầm nghe (chưa áp dụng, chờ nghe)
Mặc định **không tăng**. Vùng `AmbientZone` (7,8 × 3 × 6,9 m) phủ cả phòng và khoang tắm; quạt `unit_size 4`, `max_distance 22` luôn nghe được khắp phòng; ù đèn `max_distance 6`: từ vòi sen đèn cách khoảng 7 m nên **không nghe ù đèn ở khoang tắm** (thiết kế cũ, không đổi). Nếu chủ dự án thấy quạt quá hiện diện ở cuối phòng thì giảm `max_distance` quạt về khoảng 12 hoặc `volume_db` xuống 1–2 dB, chứ không cần dời nữa.

#### Ghi nhận / yêu cầu thay đổi ngoài vùng F
1. **(B hoặc integrator)** Hạt nước `Ch2Bathroom/Water` bắt đầu ở y 2,17 nhưng mô hình `Shower` mới chỉ cao đến y 2,05, tức nước (và tiếng nước đi theo) khởi phát cao hơn đầu vòi mới khoảng 12 cm. Nếu hạ emitter xuống đầu vòi thật thì tiếng nước tự đi theo (F lấy vị trí từ emitter), không cần sửa gì ở F.
2. **(core, `chapter2_director.gd`)** Tiếng đẩy cửa (`play_door_push`) và `door_burst` phát ở giữa khoang tắm, cách cửa nhà tắm (5,35; 0; −4,0) khoảng 2,4 m. Chưa đổi vì card chỉ yêu cầu nước và gương; nếu muốn khớp cửa, đề nghị director đặt thêm một anchor (ví dụ `Anchors/BathroomDoorAudio`) hoặc cho F nhận đường dẫn `Extension/BathroomDoor`. F có thể làm ngay khi được cho phép.
3. **(core, `chapter1_director.gd`)** Chập chờn đèn chương 1 (`_set_flicker`) không gọi `LightHum.flicker()` nên không có tiếng rè `fluorescent_flicker.ogg` (chỉ ù tắt/bật theo xung ánh sáng). Hành lang 405/407 thì có. Chỉ ghi nhận, không phải lỗi của T-218.
4. Gương đứng `FullMirror` không có cue riêng: `flash_reflection` và `mirror_shiver` chỉ gắn với gương nhỏ trong nhà tắm.
5. Không cần câu hỏi về luật chơi hay cốt truyện.

#### Danh sách âm chủ dự án cần nghe (trên Windows, có loa)
Cảnh nghe thử: `& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/graphics_upgrade/room407_audio_preview.tscn --windowed --resolution 960x540` (xếp lượt Godot với integrator trước).
- Quạt (F) từ giữa phòng (C): nhỏ, đúng ở trên đầu/trần.
- Đèn (L, K): ù tắt/bật đúng nhịp đèn chập; không click lạ lúc bật lại. Theo đọc code, hum khởi động lại từ đầu clip mỗi lần đèn sáng lại (cơ chế cũ, chưa đổi); cần nghe để biết có click không.
- Nước (1/2/3) từ cửa nhà tắm (B) và giữa phòng (C), so mới/cũ bằng T: từ vòi sen mới, không to hơn, không chói.
- `mirror_shiver` (M, T): lệch về tường tây nhà tắm (gương), nghe khác với chỗ cũ.
- Cảnh thật: chương 1 phòng 407 khi đèn chập; chương 1–4 tiếng quạt trong phòng; chương 2 nhà tắm (nước lạnh/ấm/sôi, đẩy cửa, slot 12 bóng quản lý trong gương).

#### Chưa kiểm được trên máy cloud (không loa, không card đồ họa)
Chất âm, âm lượng và hướng nghe thật; so cảm nhận mới/cũ; hiển thị cảnh nghe thử (chỉ chạy headless; test gọi các hàm gắn với phím và xác nhận mở im lặng, chưa gõ phím thật, chưa xem ảnh); khớp hình-âm thanh trong cảnh render; FPS (không đo). Không chạy `pwsh tools/test.ps1`/`tools/check.ps1` (máy Linux không có PowerShell): thay bằng lệnh Godot trực tiếp theo `web.md`, test chạy với dữ liệu người dùng cô lập (`XDG_DATA_HOME` + `QA_EXPECTED_USER_ROOT` như `tools/test.ps1`); phần "check" thay bằng parse từng script mới qua `parse_probe` (PASS).

#### Kết quả test (Linux, Godot 4.7.2, dữ liệu người dùng cô lập; lệnh trực tiếp thay `pwsh tools/test.ps1`)
- **Lượt 1, trước khi sửa, trên `origin/main` `a167d6e`:** `RESULT: 779 passed, 1 failed`. FAIL duy nhất: `test_wide_corridors.gd::test_floor4_standalone_navigation_reaches_both_ends_and_room407` (nav chập chờn trên Linux, STATUS đã ghi chưa chẩn đoán; lượt đó chạy song song với một lượt Godot khác nên CPU tải nặng; ở lượt chạy trước và lượt 2 test này pass). Không sửa. Lượt chạy đầu tiên (chưa cô lập dữ liệu người dùng, có chạy song song) cho 775 passed, 5 failed: `test_ch2_menu` và `test_ch3_tools` đòi `QA_EXPECTED_USER_ROOT` (chỉ có khi chạy qua `tools/test.ps1`), `test_manager` và hai test của `test_reading` nhiễm dữ liệu người dùng dùng chung; không dùng làm chuẩn so sánh.
- **Lượt 2, sau khi sửa (nhánh này, bản commit):** `RESULT: 790 passed, 0 failed` (780 test cũ + 10 test mới), không dòng `ERROR:` nào trong log. Không có FAIL mới so với lượt 1; nav test pass.
- `git diff --check` PASS. Parse từng script đổi/mới qua `tests/tools/parse_probe.tscn` (cách `tools/check.ps1` dùng): `shower_audio.gd`, `light_hum.gd`, `room407_audio_preview.gd`, `test_room407_object_audio.gd` đều PASS. **Không chạy được `tools/check.ps1` nguyên bản (không có `pwsh`).**
- `default_bus_layout.tres` do Godot tự ghi lúc import: đã `git checkout` trước khi commit, không nằm trong diff. Không FPS, không bot.

## Review (integrator)

### Integrator — 15/10/2026, D-111 (Claude Code ở máy, Opus 5.5)
**Đạt, đã ghép** (merge `19f295b` từ `0b8badb`). Đã kiểm: 10 file đều trong "Được phép sửa", không xóa/đổi tên; `room_407.tscn` chỉ đổi `position` của `FanAmbience` và `LightHum`, âm lượng giữ nguyên; `light_hum.gd` không đổi; `_find_anchor` tìm đúng `Ch2Bathroom/Water`, `Ch2Bathroom/Reflection`, `ReflectiveMirrorSmall`; thiếu node thì về tâm khoang tắm. 5/10 test mới FAIL với code cũ là bằng chứng tốt. Ba yêu cầu thay đổi đều đúng khi đối chiếu source; xử lý khi ghép:
1. **Tia nước chương 2** (`Ch2Bathroom/Water` y 2,17, cao hơn đỉnh vòi sen 2,05): `room407.gd::_fit_shower_water` đặt điểm bắt đầu 11 cm dưới đỉnh mô hình vòi sen (y ≈ 1,94); tiếng nước tự theo. Test thêm: điểm nước nằm dưới đỉnh vòi.
2. **Tiếng đẩy/phá cửa nhà tắm** (giữa khoang, cách cửa ~2,4 m): `shower_audio.gd` thêm `DOOR_ANCHORS` = `Extension/BathroomDoor/Pivot/Handle`; `play_door_push` và `door_burst` phát ở tay nắm cửa. Test lane F sửa theo (đổi tên thành `..._door_cues_from_the_door`). Claude làm thay F phần script nhỏ này.
3. **Tiếng rè khi đèn chập chương 1:** chủ dự án: "có chứ". `scripts/audio/flicker_buzz.gd` (mới) phát lại `sfx/fluorescent_flicker.ogg` với khoảng nghỉ ngẫu nhiên 0,25–1,4 s; `chapter1_director.gd::_set_flicker` tạo `FlickerBuzz` dưới `Room407MainLight`, cùng bus/âm lượng với tiếng ù (−10 dB), tắt khi hết chập. Test `test_chapter1.gd::test_door_flicker_crackles_under_the_tube`.

Cần chủ dự án nghe: cảnh nghe thử (lệnh ở Handoff), tiếng rè khi quản lý mở cửa chương 1, tiếng đẩy cửa nhà tắm chương 2.

