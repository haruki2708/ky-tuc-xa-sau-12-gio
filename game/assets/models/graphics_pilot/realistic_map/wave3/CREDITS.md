# Nguồn asset — `realistic_map/wave3/` (T-259, vườn hoa trước nhà B; D-166, D-175)

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `tree_plumeria_a/b/c.glb`, `tree_lagerstroemia_a/b.glb` | Cây trong bồn: hoa sứ / hoa đại (3 biến thể), bằng lăng có hoa (2 biến thể); mỗi cây có bản gần (`Bark`, `Leaves`) và bản xa (`BarkFar`, `LeavesFar`) | `art_source/graphics_upgrade/realistic_map/wave3/build_garden.py` (dùng hàm của `build_garden_pilot.py`; Blender 5.2.2) | Dự án (Claude, lane B; T-259) | Như dự án |
| `garden_beds.glb` | 12 viền bồn gạch trát quét vôi (`Kerbs`), đất trong bồn (`Soil`) | như trên | như trên | Như dự án |
| `garden_planting.glb` | Viền chuỗi ngọc xén (`Hedges`), bụi trang đỏ, hoa, lá rụng (`Planting`) của 12 bồn | như trên | như trên | Như dự án |
| `paving_block.glb` | Sân lát gạch block con sâu 44 × 40 m | `build_garden_pilot.py` | như trên | Như dự án |
| `bench_ngu.glb`, `bench_back.glb` | Ghế đá mài của Ngư (không tựa), ghế đá mài có tựa (`Bench0…3`) | `build_garden_pilot.py`, `build_garden.py` | như trên | Như dự án |
| `garden_lamp.glb` | Cột đèn sân vườn cầu tròn | `build_garden_pilot.py` | như trên | Như dự án |
| `fallen_bunk.glb` | Giường tầng thép đổ nghiêng, ván giường, bốn thanh lan can rời | `build_garden.py` | như trên | Như dự án |
| `garden_backdrop.glb` | Bản nhẹ của vườn cho cảnh ngoài tầng 4 ở chương 1–2 | `build_garden.py` | như trên | Như dự án |
| `strip_b_garden.glb`, `strip_props.glb` | Dải nối nhà B → vườn: bãi cỏ mòn, viền sân, rãnh có tấm đan; giấy rác, gạch vỡ, ống sắt, bảng tin | `build_garden.py` | như trên | Như dự án |
| `materials/*.tres`, `materials/foliage.gdshader`, `materials/ground_blend.gdshader` | Vật liệu W3*, shader thẻ lá và shader nền cỏ (`make_wave3_materials.py`) | | như trên | Như dự án |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

Texture: `game/assets/textures/graphics_pilot/realistic_map/wave3/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã có
trong game (CC0 Poly Haven, nguồn ghi ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`):
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) (viền bồn),
[Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall) (bong vôi viền bồn),
[Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (cột đèn, khung bảng tin),
[Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (đế đèn, viền sân, rãnh, gạch vỡ: `W1Concrete`, `W3Brick`),
[Wood Table Worn](https://polyhaven.com/a/wood_table_worn) (ván giường, mặt bảng tin: `W1Wood`); đá mài tự vẽ của đợt 1
(ghế); sơn giường tầng `W2BunkPaint` của đợt 2.

Ảnh tham chiếu loài cây (Wikimedia Commons, CC0 / CC BY) chỉ dùng để so trong `art_source/.../previews/wave3/references.jpg`,
không đưa vào game; tác giả và đường dẫn ghi ở `art_source/graphics_upgrade/realistic_map/wave3/README.md`.
