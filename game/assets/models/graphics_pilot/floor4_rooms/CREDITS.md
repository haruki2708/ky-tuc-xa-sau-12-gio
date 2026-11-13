# Nguồn asset — `game/assets/models/graphics_pilot/floor4_rooms/`

T-255 (D-168): vỏ các phòng 401–406, 408 sâu như phòng 407. Đồ đạc trong phòng là đồ có sẵn của phòng 407 (Tripo, Blender; nguồn ghi ở các thư mục `room407_*`), không chép bản nào vào đây.

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `room_401.glb` … `room_406.glb`, `room_408.glb` | Vỏ một phòng: `Interior` (tường, sàn, trần, len chân tường, nhà tắm ốp gạch, ô cửa lá sách, khung cửa xanh, đèn tuýp, công tắc, dây phơi) và `Exterior` (mặt sau nhà, ban công, lan can, vách ngăn, trần ban công, dây phơi) | `art_source/graphics_upgrade/floor4_rooms/build_rooms.py` (Blender 5.2.2) | Dự án (Claude, lane B; T-255) | Như dự án |
| `materials/F4*.tres` | Vật liệu Godot dùng chung cho các glb trên | `make_room_materials.py` | như trên | Như dự án |

**Không dùng Tripo, không tạo ảnh bằng AI** cho phần mới. AI (Claude) viết script dựng hình và vẽ texture bằng code. Lá cửa nhà tắm, cửa ban công và tay gạt là bản Tripo có sẵn của phòng 407 (`room407_shell/doors/`, hồ sơ D-084 ở đó).

### Texture dùng lại (đã có trong game, CC0 Poly Haven)
Vật liệu trỏ thẳng vào file sẵn có, không chép thêm:
- [Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) (bản nhuộm kem của T-213): tường, trần.
- [Interior Tiles](https://polyhaven.com/a/interior_tiles): sàn phòng, len chân tường. Nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`.
- Gạch ốp nhà tắm `bath_tiles_long_white_tiles_*` của phòng 407, gạch chống trơn, gạch ban công `floor_tiles_08`, vữa ngoài `plastered_wall_02`, nhôm, sơn khung xanh của vỏ 407 (`art_source/graphics_upgrade/room407_shell/CREDITS.md`).
- Lớp sơn bong (`Room407Furnish.PEEL`) như vỏ 407.
