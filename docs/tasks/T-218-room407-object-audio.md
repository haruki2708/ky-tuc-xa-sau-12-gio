# T-218 — Âm thanh phòng 407 khớp đồ mới: quạt trần, đèn tuýp, vòi sen, gương
- Lane: F (Âm thanh) | Trạng thái: todo | Agent: Claude Code web, Sonnet 5.5 (D-108)
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

## Review (integrator)
