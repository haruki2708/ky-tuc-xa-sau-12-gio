# Credits — vỏ phòng 407 nâng cấp (T-222, D-126, D-127)

## Texture CC0 (Poly Haven)

| Bộ | Tác giả | Dùng cho | Ghi chú |
|---|---|---|---|
| [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall) | Dimitrios Savva | Lớp sơn bong (tường, trần, mặt ngoài) | Sơn đỏ của bản chụp đã sơn lại màu kem (`make_shell_textures.py` → `wall_peel_color.jpg`); normal và ARM giữ nguyên |
| [Distressed Painted Planks](https://polyhaven.com/a/distressed_painted_planks) | Rob Tuytel | Khung cửa, nẹp | Sơn lại xanh đậm (cửa phòng) và kem (cửa nhà tắm) |
| [Anti Skid Tiles](https://polyhaven.com/a/anti_skid_tiles) | Amal Kumar | Sàn nhà tắm | |
| [Floor Tiles 08](https://polyhaven.com/a/floor_tiles_08) | Rob Tuytel | Sàn ban công | |
| [Plastered Wall 02](https://polyhaven.com/a/plastered_wall_02) | Charlotte Baglioni | Mặt ngoài ban công, các dãy nhà bên ngoài | Nhuộm vàng; bản 1k `facade_color.jpg` cho nhà xa |

Đều **CC0-1.0** ([giấy phép](https://polyhaven.com/license)). URL, kích thước thật, SHA-256 từng map: [`texture_sources.json`](texture_sources.json). Vỏ cũ dùng lại Painted Plaster Wall và Interior Tiles của [`../room407_corner/CREDITS.md`](../room407_corner/CREDITS.md).

## Tự vẽ trong dự án (không ảnh AI)

`make_shell_textures.py`: noise, nhôm, đá ngưỡng, mạng nhện, trời đêm, cửa sổ sáng/tối. `make_shell_masks.py`: 4 bản đồ bẩn theo vị trí thật trong phòng. Hình học: `build_shell.py`, `build_outside.py` (Blender 5.2.2), Claude (Opus 5.5), 21–22/10/2026, CC0.

## Tripo (D-084)

`game/assets/models/graphics_pilot/room407_shell/doors/door_bathroom.glb`, `door_balcony.glb`, `door_lever.glb`:
- Tripo AI Studio, gói **Pro trả phí**, chủ dự án tạo ngày 22/10/2026 theo prompt chữ trong [`docs/handoff/TRIPO_CUA_PHONG407.md`](../../../docs/handoff/TRIPO_CUA_PHONG407.md) mục 2 (không ảnh đầu vào).
- Điều khoản lúc tạo: `../tripo/room407_backpack/evidence/tripo_terms_2026-10-12.pdf`, `tripo_commercial_2026-10-12.pdf`.
- File gốc ở `build/graphics/staging/doors/` (không vào git, mỗi file 63–67 MB), chỉ lưu hash: [`tripo_doors/SHA256SUMS.txt`](tripo_doors/SHA256SUMS.txt).
- Claude sửa: cắt khung, ép tay nắm in sẵn, lật mặt trước ra sau (cửa nhà tắm) bằng `prep_doors.py`; xoay và thu nhỏ tay nắm bằng `prep_lever.py`; giảm lưới, nướng normal bằng `../tripo/bake_prop.py`.
- `door_room.glb` lượt 1 không dùng (cửa hai cánh, mục 2b của phiếu); chờ lượt 2.

Khai báo nội dung AI (Steam): cánh cửa và tay nắm tạo bằng AI (Tripo AI).
