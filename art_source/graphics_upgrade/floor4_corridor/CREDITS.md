# Nguồn bộ khảo sát T-229

- `previews/before_*.jpg`: ảnh chụp trực tiếp bằng Godot 4.7.2 Forward+ từ scene và asset của dự án tại nền Git `2773a3f608f33a2bda719a3dcfbf74900cfe07c0`. Công cụ chụp: `game/scenes/levels/floor4/corridor_capture.gd`, lane B (Codex), chụp ngày 02/11/2026. Không tạo ảnh bằng mô hình sinh ảnh, không hậu kỳ. Không gán giấy phép mới cho asset xuất hiện trong ảnh.
- Mesh PS1: hồ sơ nguồn ở [`../../CREDITS.md`](../../CREDITS.md), [`../../campus/CREDITS.md`](../../campus/CREDITS.md) và [`../../sealed408/CREDITS.md`](../../sealed408/CREDITS.md), áp dụng cho kit/props, Campus và dấu niêm phong tương ứng.
- Phòng/cánh cửa 407 có asset tạo bằng **Tripo AI** theo ngoại lệ D-084. Giữ nguyên tác giả/công cụ và hồ sơ tại `art_source/graphics_upgrade/room407_shell/` cùng `game/assets/models/graphics_pilot/`; không ghi Tripo là CC0.
- Texture CC0 dự định tái dùng, chưa sao chép/tải mới trong T-229: bảng nguồn/tác giả cụ thể ở `PLAN.md` mục 5, manifest gốc `../room407_shell/texture_sources.json`, `../room407_corner/texture_sources.json`; URL giấy phép https://polyhaven.com/license.
- `PLAN.md`, `TRIPO_NHAP.md`, script chụp và chạy: soạn với Codex cho task T-229. Không phát sinh model hay texture AI mới. Bộ ảnh chỉ làm bằng chứng khảo sát, không phải asset đưa vào bản chơi.

# Nguồn mẫu đoạn hành lang T-233 (D-142, phương án A)

Đoạn mẫu x 26…34 quanh cửa 406–407: `game/assets/models/graphics_pilot/floor4_corridor/segment_*.glb`, `game/assets/textures/graphics_pilot/floor4_corridor/mask_*.png`, cảnh `game/scenes/levels/floor4/corridor_g5_pilot.tscn`.

## Tự dựng (CC0)

- Hình học: `build_segment.py` (Blender 5.2.2, chạy bằng script), bố cục `segment_layout.py`. Bản đồ bẩn: `make_segment_masks.py` (numpy, vẽ bằng công thức theo vị trí thật trong hành lang). Claude (Opus 5.5), lane B, 07/11/2026. Không ảnh raster AI, không tác vụ Tripo mới, không tải texture mới.
- GLB chỉ chứa vật liệu giữ chỗ tên `Corr*`, không nhúng ảnh. `corridor_g5_pilot.gd` gán shader vỏ phòng 407 (`game/rendering/room407_shell.gdshader`) và các ảnh CC0 đã có trong game.

## Texture CC0 dùng lại (Poly Haven, CC0-1.0, [giấy phép](https://polyhaven.com/license))

| Dùng cho | Bộ, tác giả | File trong game (đã có, không sao chép) |
|---|---|---|
| Tường, trần | [Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall), Amal Kumar; bản tông kem của T-213 | `assets/models/graphics_pilot/room407_corner/architecture_painted_plaster_wall_*` |
| Lớp sơn bong | [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall), Dimitrios Savva; bản sơn lại kem của T-222 | `assets/textures/graphics_pilot/room407_shell/wall_peel_color.jpg`, `peeling_painted_wall_*` |
| Sàn, gạch chân tường | [Floor Tiles 08](https://polyhaven.com/a/floor_tiles_08), Rob Tuytel | `assets/textures/graphics_pilot/room407_shell/floor_tiles_08_*` |
| Khung, nẹp cửa | [Distressed Painted Planks](https://polyhaven.com/a/distressed_painted_planks), Rob Tuytel; bản sơn xanh của T-222 | `room407_shell/frame_green_color.jpg`, `assets/models/graphics_pilot/room407_shell/frames_distressed_painted_planks_*` |
| Lan can | [Green Metal Rust](https://polyhaven.com/a/green_metal_rust), Rob Tuytel | `assets/models/graphics_pilot/room407_corner/fixtures_green_metal_rust_*` |
| Ngưỡng đá, nhiễu | tự vẽ ở T-222 (`../room407_shell/make_shell_textures.py`) | `room407_shell/granite_*`, `noise.png` |

URL từng map, hash: `../room407_shell/texture_sources.json`, `../room407_corner/texture_sources.json`. PLAN mục 5 dự kiến Plastered Wall 04 cho tường; mẫu dùng Painted Plaster Wall như vỏ phòng 407 để hai bên cửa cùng một màu sơn.

## Tripo dùng lại (ngoại lệ D-084, không phải CC0)

Cánh cửa 406 dùng lại `game/assets/models/graphics_pilot/room407_shell/doors/door_room.glb` và tay gạt `door_lever.glb` (Tripo AI Studio, gói Pro trả phí, chủ dự án tạo 22/10/2026). Hồ sơ gói, ngày, prompt, điều khoản và hash: [`../room407_shell/CREDITS.md`](../room407_shell/CREDITS.md) mục Tripo. T-233 không tạo thêm tác vụ Tripo, không tiêu credit. Khai báo nội dung AI (Steam): cánh cửa và tay gạt tạo bằng AI (Tripo AI).

## Ảnh

`previews/after_*.jpg`, `before_13…19_*.jpg`: chụp trực tiếp bằng Godot 4.7.2 Forward+ (`corridor_capture.gd -- --g5`), không hậu kỳ. `compare_*.jpg`: ghép bằng `make_compare.py` (Pillow). Ảnh trước 01–04 là ảnh khảo sát T-229.
