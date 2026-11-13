# Nguồn asset — `game/assets/models/graphics_pilot/realistic_map/floor4_rest/`

T-256 (D-170): tầng 4 phần còn lại. Dựng bằng Blender 5.2.2 từ script trong `art_source/graphics_upgrade/realistic_map/floor4_rest/`. Tác giả: dự án (Claude, lane B; T-256). Giấy phép: như dự án.

| File | Là gì | Script |
|---|---|---|
| `washroom.glb` | Nhà vệ sinh chung: vỏ ốp gạch, ba buồng có bệ xổm, máng rửa ba vòi, ống nước, khung gương, bảng tin, máng đèn, ô thoáng, xô, gáo, chậu, cây lau, xà phòng, khăn, lớp ố gương | `build_washroom.py` |
| `corridor_props.glb`, `cloths.glb` | Dây phơi, quần áo phơi, xô, kệ giày, ghế nhựa, chậu, bao đàn, thùng carton, can nước, ô, chổi, dép, giày | `build_corridor_props.py` |
| `fire_door_handle_compact.glb` | Tay gạt cửa thoát hiểm theo bản đợt 1 (`wave1/build_fire_door.py`), cần gạt phía hành lang cổ ngắn | `build_fire_door_rest.py` |
| `exit_sign.glb` | Hộp đèn LỐI THOÁT trên cửa thoát hiểm (tắt) | `build_fire_door_rest.py` |
| `cctv_corridor.glb` | Trường quay CCTV hành lang 405–407 | `build_cctv_corridor.py` |
| `materials/*.tres` | Vật liệu Godot của các glb trên | `make_rest_materials.py` |

**Không dùng Tripo, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

### Texture dùng lại (đã có trong game), không chép bản nào
- Gạch men dài trắng của nhà tắm 407 (`room407_furnished/bath_tiles_long_white_tiles_*`), gạch chống trơn, gạch sàn `floor_tiles_08`, nhôm, sơn khung xanh của vỏ 407 (nguồn CC0 ở `art_source/graphics_upgrade/room407_shell/CREDITS.md` và `room407_furnished/CREDITS.md`).
- [Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) (bản nhuộm kem T-213) và [Green Metal Rust](https://polyhaven.com/a/green_metal_rust): CC0 Poly Haven, nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`. Ván sơn bong (`frames_distressed_painted_planks_*`) của khung cửa: CC0, nguồn ở `art_source/graphics_upgrade/room407_shell/CREDITS.md`.
- Vải: bản tô màu vải lanh của T-255 (`game/assets/textures/graphics_pilot/floor4_rooms/curtain_*.jpg`; vải lanh quét CC0 của T-222).
- Shader vỏ phòng 407 (`rendering/room407_shell.gdshader`), mặt gương HD (`rendering/mirror_surface_hd.gdshader`).
