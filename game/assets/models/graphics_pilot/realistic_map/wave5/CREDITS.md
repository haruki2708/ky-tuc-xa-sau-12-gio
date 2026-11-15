# Nguồn asset — `realistic_map/wave5/` (T-262, cổng trường, chốt bảo vệ, tường rào nam, sân cổng; D-166, D-176)

Lượt 1 (góc mẫu, chưa scene nào dùng): mọi file dưới đây do
`art_source/graphics_upgrade/realistic_map/wave5/build_gate_pilot.py` dựng (Blender 5.2.2, chỉ bmesh). Tác giả: dự án
(Claude, lane B; T-262). Giấy phép: như dự án.

| File | Là gì |
|---|---|
| `court.glb` | Mặt sân cổng 60 × 40 m và mép 4 cm: `Pavers` (C2 block con sâu), `Asphalt` (C1 nhựa đường) |
| `outside.glb` | Vỉa hè, bó vỉa, lòng đường ngoài tường (chỉ nhìn qua cổng, không tới được) |
| `court_cracks.glb` | Vết nứt sân ở chỗ `RoadCrack212/222/233` PS1 và quanh chân trụ tây |
| `pillars_plaster.glb`, `pillars_brick.glb` | Hai trụ cổng: P1 trát quét vôi, P2 ốp gạch; trụ tây nghiêng 7°, vết nứt mặt trước |
| `gate_swing.glb`, `gate_folding.glb` | Cánh cổng: G1 sắt hai cánh sơn xanh, G2 cổng xếp inox |
| `sign_arch.glb` | SA: vòm thép, biển tôn xanh rơi nửa, dây treo |
| `sign_band.glb`, `sign_letters.glb` | SB: băng biển trát vữa rơi nửa, giá đỡ; chữ nổi "TRƯỜNG ĐẠI HỌC" (font Be Vietnam Pro SemiBold, OFL, đã có trong `game/assets/fonts/`) |
| `booth_masonry.glb`, `booth_prefab.glb`, `booth_interior.glb` | Chốt bảo vệ K1 xây quét vôi vàng, K2 lắp ghép composite; đồ bên trong |
| `wall_plaster.glb`, `wall_brick.glb` | Tường rào nam đoạn x 186…262: W1 trát quét vôi + song sắt, W2 gạch trần |
| `barrier.glb`, `cone.glb` | Rào chắn sọc đỏ trắng di động, cọc giao thông |
| `materials/*.tres` | Vật liệu W5* (`make_wave5_materials.py`) |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

Texture riêng: `game/assets/textures/graphics_pilot/realistic_map/wave5/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã
có trong game (CC0 Poly Haven, nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md` và `room407_shell`):
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) và [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall)
(trụ, tường, chốt, băng biển), [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (cổng G1, vòm, song tường, cửa chốt),
nhôm của T-222 (inox G2), [Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (`W1Concrete`), gạch block con sâu của đợt 3,
vật liệu chung của đợt 1, 2, 4.
