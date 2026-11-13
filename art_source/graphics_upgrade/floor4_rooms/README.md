# T-255: phòng 401–406, 408 sâu như phòng 407 (D-168)

Bảy phòng tầng 4 (trừ 407) sâu bằng 407, có nhà tắm ở góc sau và ban công cả bề ngang phòng, đồ đạc bày như 407 (dùng lại đồ Tripo và Blender của 407, không tạo đồ mới), mỗi phòng một nhóm sinh viên khác nhau. Cửa phòng mở bằng tay ở mọi chương.

## File
| File | Việc |
|---|---|
| `rooms_layout.py` | Số đo chung (Python thuần): độ sâu như 407, vị trí phòng, nhà tắm, cửa nhà tắm, cửa ban công, ô cửa thoáng, ô trống cho xác sống ra (chương 3), atlas mask. |
| `build_rooms.py` | Blender 5.2.2: vỏ mỗi phòng `game/assets/models/graphics_pilot/floor4_rooms/room_<n>.glb` gồm `Interior` (tường, sàn, trần, len chân tường, nhà tắm ốp gạch tới 1,8 m, ô cửa lá sách, khung cửa xanh như 407, đèn tuýp, công tắc, dây phơi) và `Exterior` (mặt sau nhà tới sàn tầng 5, sàn ban công, lan can, vách ngăn, trần ban công, dây phơi). Không có va chạm (Godot dựng). |
| `make_room_textures.py` | numpy + Pillow: `mask_rooms.png` (mask cũ hoá cho shader vỏ 407, vẽ theo mặt bằng từng phòng: vết tay quanh cửa, vết đầu vai cạnh giường, lối đi mòn, ẩm quanh nhà tắm; 405 bỏ trống cũ nhất) và vải tô lại màu từ chăn, gối, rèm, áo của 407 (`<loại>_<màu>.jpg`). Không tải ảnh, không dùng ảnh AI. |
| `make_room_materials.py` | Vật liệu Godot `F4*` (shader vỏ 407, ảnh quét CC0 sẵn có của 407) và file `.import` gán vật liệu cho glb. |
| `make_placements.py` | Bảng bày đồ `game/data/floor4_rooms/rooms.json` (bố cục và đồ từng phòng). Tự kiểm: không đồ cứng nào trong ô xác sống ra, không xuyên tường. |
| `capture_t255.gd` | Chụp ảnh 1080p trong cảnh chương thật (chép vào `game/_probe_tmp/`, xem đầu file). |
| `make_compare.py` | Ghép ảnh trước/sau: `previews/compare_ch1.jpg`, `compare_ch3.jpg`, `new_views_ch*.jpg`, `overview.jpg`. |
| `draw_plan.py` | Sơ đồ đề xuất `previews/plan_proposal.png` (bước 1). |

Chạy lại (từ gốc repo; Blender `D:\Tools\Blender\5.2.2\blender.exe`):
```
python -B art_source/graphics_upgrade/floor4_rooms/make_room_textures.py
blender -b --factory-startup -P art_source/graphics_upgrade/floor4_rooms/build_rooms.py
python -B art_source/graphics_upgrade/floor4_rooms/make_room_materials.py
python -B art_source/graphics_upgrade/floor4_rooms/make_placements.py
blender -b --factory-startup -P art_source/graphics_upgrade/room407_shell/build_outside.py   # phông chương 1-2
```
Sau đó mở Godot import hai lần (lần đầu có thể báo lỗi ảnh mới).

## Trong game
- `game/scenes/levels/floor4/floor4_rooms.gd` (`Floor4Rooms`): `floor4.gd` dựng nút `Rooms` ở mọi chương (`upgraded_rooms`, mặc định bật). Va chạm hộp cho tường, sàn (`surface = tile`), nhà tắm, ban công, đồ cứng (hộp lùi 5 cm như 407). Phòng PS1 cũ (`Floor_`, `BackWall_`, `Ceiling_`, `RoomInterior_`, `Room408BackWall`) bị ẩn và tắt va chạm, không xoá. Vách ngăn, cửa (`RoomDoor`, `Blocker`), hành lang giữ nguyên.
- Nội thất mỗi phòng (vỏ trong, đồ, cửa nhà tắm) chỉ vẽ khi cửa phòng mở/đang đóng dở hoặc camera ở trong phòng (cả ban công). Đồ trên ban công vẽ cùng nội thất, hoặc khi camera ở sau mặt nhà trong vòng 25 m. Mặt sau nhà, ban công, cửa ban công luôn vẽ.
- Cửa phòng: `room_door_hand.gd` (`RoomDoorHand`) cưỡi trên cánh, tay gạt Tripo nhận tay (`DoorHandles` của lane A). Cánh vẫn mở ra hành lang. Khi core gắn `ZombieDoor` (chương 3–4) cửa thuộc về chương: tắt tay; nếu đang mở bằng tay thì tự đóng lại khi không ai đứng ở ô cửa.
- Cửa nhà tắm, cửa ban công: `room_hinge.gd` + `HingedDoor` (lane A), lá cửa Tripo của 407 và tay gạt. Đóng khi bắt đầu chương. Cửa nhà tắm mở vào trong dọc vách; cửa ban công mở ra, áp vào mặt tường phía nhà tắm (như 407).
- Đồ Tripo dùng LOD tự động của Godot (`meshes/generate_lods=true` trong file `.import` có sẵn), đó là bản nhẹ cho đồ nhỏ ở xa.

## Nguồn
Toàn bộ là đồ, ảnh quét CC0, lá cửa Tripo có sẵn của phòng 407 (nguồn ghi ở `room407_*`/`CREDITS.md`). Mask và vải tô lại màu tạo bằng script ở đây. Không tiêu credit Tripo.
