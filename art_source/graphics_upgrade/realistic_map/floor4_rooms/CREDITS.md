# Nguồn T-252 — nội thất nhìn qua cửa tầng 4

Lane C (Codex), 13/11/2026. Hình học mới dựng bằng script Blender 5.2.2, CC0; AI hỗ trợ viết code. Không ảnh raster AI, không Tripo, không tải asset mới. Script dùng lại các hàm hình học CC0 của `room407_corner/build_corner.py` (lane B/Codex và Claude, T-213).

Các GLB `shell_4`, `shell_6`, `bunk`, `desk`, `locker`, `stool`, `curtains` trong `game/assets/models/graphics_pilot/realistic_map/floor4_rooms/` chỉ chứa hình học và vật liệu đặt tên. `room_visual.gd` gán các scan đã nhập của phòng 407, dùng chung tài nguyên giữa bảy phòng:

| Bộ / URL | Tác giả | Giấy phép | Dùng cho / tiền tố file trong `game/assets/models/graphics_pilot/room407_corner/` |
|---|---|---|---|
| [Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) | Amal Kumar | CC0-1.0 | Tường/trần; `architecture_painted_plaster_wall_*`, màu kem phái sinh đã có |
| [Interior Tiles](https://polyhaven.com/a/interior_tiles) | Charlotte Baglioni | CC0-1.0 | Sàn, chân tường, bậu; `floor_interior_tiles_*` |
| [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) | Rob Tuytel | CC0-1.0 | Giường, tủ, chân bàn, khung cửa sổ; `bunk_a_green_metal_rust_*` |
| [Wood Table Worn](https://polyhaven.com/a/wood_table_worn) | Dimitrios Savva, Rico Cilliers | CC0-1.0 | Bàn, ghế, ván giường; `study_desk_wood_table_worn_*` |
| [Rough Linen](https://polyhaven.com/a/rough_linen) | colormass, Rico Cilliers | CC0-1.0 | Nệm, rèm, trang sách; `bunk_a_rough_linen_square_*` |
| [Fabric Pattern 05](https://polyhaven.com/a/fabric_pattern_05) | Rob Tuytel | CC0-1.0 | Gối, bìa sách; `bunk_a_bedding_fabric_pattern_05_*` |
| [Polar Fleece](https://polyhaven.com/a/polar_fleece) | colormass, Rico Cilliers | CC0-1.0 | Chăn; `bunk_a_bedding_polar_fleece_square_*` |

Mỗi tiền tố dùng màu, normal OpenGL, ARM. Hồ sơ URL gốc, SHA-256 và giấy phép đã lưu tại [`../../room407_corner/texture_sources.json`](../../room407_corner/texture_sources.json) và [`../../room407_corner/CREDITS.md`](../../room407_corner/CREDITS.md). Màu tối cửa sổ/chân cao su là thông số vật liệu tự tạo. Ảnh chụp chương thật còn chứa những tài sản khác của dự án (kể cả cửa G5 Tripo); không tuyên bố toàn bộ ảnh là CC0.
