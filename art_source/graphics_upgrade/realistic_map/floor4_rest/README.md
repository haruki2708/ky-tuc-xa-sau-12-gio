# T-256: tầng 4 phần còn lại (D-170)

Nhà vệ sinh chung, đồ ở hành lang, tay gạt và biển thoát hiểm của cửa thoát hiểm, trường quay CCTV hành lang. Dựng bằng Blender theo chất lượng phòng 407 và đợt 1–2 (D-166, D-167), dùng lại texture có sẵn. Mới chỉ có mask bẩn 1K, lớp ố gương và mặt biển thoát hiểm, tất cả vẽ bằng code. Không Tripo, không ảnh AI.

## File
| File | Việc |
|---|---|
| `washroom_layout.py` | Số đo nhà vệ sinh (Python thuần): hợp đồng của `washroom.tscn` (hộp va chạm, vòi, gương, đèn, anchor), buồng, máng rửa, atlas mask. |
| `build_washroom.py` | Phần A: `washroom.glb` gồm Shell (tường ốp gạch men xanh nhạt tới 1,8 m, trên trát; sàn chống trơn dốc 1,2 cm về ga; trần), Stalls (ba buồng xây ốp gạch, bệ xổm, vòi thấp, cánh cửa sơn khép hờ vào trong), Trough (máng rửa dài ba vòi, ống cấp lộ, ống thoát), Fixtures (khung gương nhôm, bảng tin ở `WashroomNotice`, máng đèn, ô thoáng, móc), Props (xô, gáo, chậu, cây lau, xà phòng, ca, thùng rác, khăn), MirrorStain (mép tráng bạc bong, đốm nước). |
| `make_washroom_textures.py` | `mask_washroom.png` 1024² (bẩn cho shader vỏ 407), `mirror_stain.png` 1024×512, `exit_sign.png` 512×192 (chạy với `exit`). |
| `build_corridor_props.py` | Phần B: `corridor_props.glb` (dây phơi võng nhẹ móc trần, đồ nhỏ, đồ cứng `Solid_*`, ba xô cũ), `cloths.glb` (quần áo cho `HangingCloth_0…4`). |
| `build_fire_door_rest.py` | Phần C: `fire_door_handle_compact.glb` (tay gạt đợt 1, riêng cần gạt phía hành lang trên cổ ngắn), `exit_sign.glb` (hộp đèn LỐI THOÁT, tắt). |
| `build_cctv_corridor.py` | Phần D: `cctv_corridor.glb` cho trường quay CCTV hành lang. |
| `make_rest_materials.py` | Vật liệu Godot `WR*`, `CC*`, `CD*`, `CV*` và file `.import` gán vật liệu cho từng glb. |
| `capture_t256.gd` | Chụp ảnh trong chương thật (chép vào `game/_probe_tmp/`). `--old` cho hình như main. Có đọc VRAM. |
| `make_compare.py` | Ghép ảnh trước/sau: `previews/floor4_rest/compare_*.jpg`, `overview.jpg`. |

Chạy lại (từ gốc repo; Blender `D:\Tools\Blender\5.2.2\blender.exe`):
```
python -B art_source/graphics_upgrade/realistic_map/floor4_rest/make_washroom_textures.py
python -B art_source/graphics_upgrade/realistic_map/floor4_rest/make_washroom_textures.py exit
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_washroom.py
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_corridor_props.py
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_fire_door_rest.py
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_cctv_corridor.py
python -B art_source/graphics_upgrade/realistic_map/floor4_rest/make_rest_materials.py
```
Texture mới để nén VRAM trong file `.import` (`compress/mode=2`). Godot import hai lần.

## Trong game
- **Nhà vệ sinh:** `game/scenes/levels/floor4/washroom_real.gd` gắn ở gốc `washroom.tscn`.
  - Ẩn hình PS1 (không xoá), thêm `Real`.
  - Gương phản chiếu thật như 407: mặt HD, chỉ vẽ khi đang nhìn vào, đi theo người chơi cầm camera; có thân thì ẩn hình thế PS1. Kính thu từ 2,8 m còn 2,5 m để chừa bảng tin.
  - Ống đèn sáng theo `WashroomLight`.
  - Va chạm, đèn, âm thanh, anchor giữ nguyên.
- **Đồ hành lang:** node `RealProps` (`corridor_props.gd`) ở cuối `corridor.tscn`.
  - Quần áo thật gắn vào `HangingCloth_i` sau `_ready` của chúng: vẫn đung đưa, không bị tô màu.
  - Đồ cỡ xô trở lên có hộp va chạm, đặt sát tường giữa các cửa hoặc sát lan can, không nằm trong 1,2 m trước cửa.
  - Dép `Slippers_0…3` vẫn ẩn như trước: đã có dép Tripo ở `Anchors/Slippers407`.
- **Cửa thoát hiểm:** `building_b.tscn` cho `FireDoor/Leaf/Handle` dùng tay gạt bản gọn (node, vị trí như cũ) và thêm `FireDoor/ExitSign`.
- **CCTV:** `cctv_set.tscn` thêm `Corridor/RealSet`, ẩn mesh PS1 và hình ba cửa kit. Camera, đèn, va chạm như cũ.
