# Nguồn asset T-102 / T-121

Toàn bộ mesh và texture của kit được tạo mới cho dự án bằng script `kit/build_kit.py`. Không dùng ảnh tải ngoài, asset từ game khác, font hoặc plugin.

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép asset |
|---|---|---|---|
| `game/assets/models/kit/{wall_straight,wall_door,door,bunk_bed,locker,ceiling_fan,plastic_stool,mosquito_net_closed,mosquito_net_open}.glb` | Lane B, Codex (OpenAI), Blender 5.2.2 LTS | [Script gốc](kit/build_kit.py) | CC0-1.0 |
| `game/assets/textures/kit/{plaster,green_paint,old_wood,iron,striped_mat,cloth,locker_paint,fan_paint,red_plastic,net_weave}.png` | Lane B, Codex (OpenAI), texture thủ tục bằng Python, seed 102 | [Script gốc](kit/build_kit.py) | CC0-1.0 |
| `kit/previews/*.png` | Blender Cycles CPU; riêng `kit_showcase*.png` do Godot Forward+ render | Các mô hình và texture trên; capsule hình nộm là primitive Godot | CC0-1.0 |

T-121 làm lại ghế nhựa, thêm hai mùng và texture lưới alpha scissor. Các PNG trùng trong `game/assets/models/kit/` của T-102 đã bỏ; GLB tham chiếu texture gốc trong `textures/kit/`.

URL nguồn công cụ: https://www.blender.org/ và https://godotengine.org/.
URL giấy phép asset: https://creativecommons.org/publicdomain/zero/1.0/.

**Khai báo AI:** Codex (OpenAI) viết script sinh mô hình, texture và scene. Đây là nội dung tạo bằng mã có hỗ trợ AI; giữ khai báo này để integrator tổng hợp khi phát hành (bao gồm Steam). Không sử dụng mô hình sinh ảnh hoặc nguồn hình ảnh bên ngoài.

Giấy phép phần mềm Blender/Godot độc lập với giấy phép các asset được tạo ra.

## Greybox T-112

`game/scenes/levels/floor4/*.tscn` dùng lại các model/texture kit ở trên và primitive Godot (hộp, capsule), sinh bằng `art_source/floor4/build_floor4.py`. Tác giả: Lane B, Codex (OpenAI); nguồn nội bộ là script này và bố cục đã duyệt `docs/design/LAYOUT.md`; giấy phép hình khối/ảnh mới CC0-1.0. Ảnh `art_source/floor4/previews/*.png` do Godot Forward+ render. Không dùng ảnh/asset tải ngoài. Âm thanh chỉ tham chiếu tài nguyên của Lane E; nguồn của chúng giữ ở `game/audio/CREDITS.md`.
