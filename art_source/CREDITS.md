# Nguồn asset T-102

Toàn bộ mesh và texture của kit được tạo mới cho dự án bằng script `kit/build_kit.py`. Không dùng ảnh tải ngoài, asset từ game khác, font hoặc plugin.

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép asset |
|---|---|---|---|
| `game/assets/models/kit/{wall_straight,wall_door,door,bunk_bed,locker,ceiling_fan,plastic_stool}.glb` | Lane B, Codex (OpenAI), Blender 5.2.2 LTS | [Script gốc](kit/build_kit.py) | CC0-1.0 |
| `game/assets/textures/kit/{plaster,green_paint,old_wood,iron,striped_mat,cloth,locker_paint,fan_paint,red_plastic}.png` | Lane B, Codex (OpenAI), texture thủ tục bằng Python, seed 102 | [Script gốc](kit/build_kit.py) | CC0-1.0 |
| `game/assets/models/kit/*.png` | Godot 4.7.2, bản sao ảnh nhúng của các texture trên khi import GLB | Cùng script gốc; không có nguồn bên ngoài | CC0-1.0 |
| `kit/previews/*.png` | Blender Cycles CPU; riêng `kit_showcase.png` do Godot Forward+ render | Các mô hình và texture trên | CC0-1.0 |

URL nguồn công cụ: https://www.blender.org/ và https://godotengine.org/.
URL giấy phép asset: https://creativecommons.org/publicdomain/zero/1.0/.

**Khai báo AI:** Codex (OpenAI) viết script sinh mô hình, texture và scene. Đây là nội dung tạo bằng mã có hỗ trợ AI; giữ khai báo này để integrator tổng hợp khi phát hành (bao gồm Steam). Không sử dụng mô hình sinh ảnh hoặc nguồn hình ảnh bên ngoài.

Giấy phép phần mềm Blender/Godot độc lập với giấy phép các asset được tạo ra.
