# Nguồn asset — `realistic_map/wave3/` (T-259, vườn hoa trước nhà B)

Lượt 1 (14/11/2026): góc mẫu quanh ghế Ngư và các phương án để chủ dự án chọn. Lượt 2 sẽ ghi thêm vào
`../CREDITS.md` chung khi gắn vào game.

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `tree_plumeria.glb`, `tree_mantaly.glb`, `tree_lagerstroemia.glb` | Ba phương án cây thấp trong bồn: hoa sứ / hoa đại, bàng Đài Loan, bằng lăng; mỗi cây có bản gần (`Bark`, `Leaves`) và bản xa (`BarkFar`, `LeavesFar`) | `art_source/graphics_upgrade/realistic_map/wave3/build_garden_pilot.py` (Blender 5.2.2) | Dự án (Claude, lane B; T-259) | Như dự án |
| `beds_pilot.glb` | Viền bồn gạch trát và đất của `Bed1_1`, `Bed2_1` | như trên | như trên | Như dự án |
| `planting_a.glb`, `planting_b.glb` | Cây bụi, hoa trong bồn: F1 chuỗi ngọc + trang đỏ; F2 cẩm tú mai + dừa cạn + cỏ | như trên | như trên | Như dự án |
| `paving_block.glb`, `paving_red.glb` | Sân lát 44 × 40 m: gạch block con sâu; gạch đỏ lá dừa | như trên | như trên | Như dự án |
| `bench_ngu.glb` | Ghế đá mài của Ngư | như trên | như trên | Như dự án |
| `garden_lamp.glb` | Cột đèn sân vườn cầu tròn | như trên | như trên | Như dự án |
| `materials/*.tres`, `materials/foliage.gdshader` | Vật liệu W3* và shader thẻ lá (`make_wave3_materials.py`) | | như trên | Như dự án |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

Texture: `game/assets/textures/graphics_pilot/realistic_map/wave3/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã có
trong game (CC0 Poly Haven, nguồn ghi ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`):
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) (viền bồn),
[Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall) (bong sơn viền bồn),
[Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (cột đèn),
[Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (đế đèn, vật liệu `W1Concrete` của đợt 1); đá mài tự vẽ của đợt 1 (ghế).

Ảnh tham chiếu loài cây (Wikimedia Commons, CC0 / CC BY) chỉ dùng để so trong `art_source/.../previews/wave3/references.jpg`,
không đưa vào game; tác giả và đường dẫn ghi ở `art_source/graphics_upgrade/realistic_map/wave3/README.md`.
