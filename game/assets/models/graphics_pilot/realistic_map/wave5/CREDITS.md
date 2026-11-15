# Nguồn asset — `realistic_map/wave5/` (T-262, cổng trường, chốt bảo vệ, tường rào nam, dải A16 đoạn cổng; D-166, D-176, D-180)

Mọi file dưới đây do `art_source/graphics_upgrade/realistic_map/wave5/build_gate.py` dựng (gọi các phần đã chọn của
`build_gate_pilot.py`; Blender 5.2.2, chỉ bmesh). Tác giả: dự án (Claude, lane B; T-262). Giấy phép: như dự án.

| File | Là gì |
|---|---|
| `court.glb` | Mặt sân cổng 60 × 40 m lát block con sâu (C2) và mép 4 cm |
| `outside.glb` | Vỉa hè, bó vỉa, lòng đường ngoài tường (chỉ nhìn qua cổng, không tới được) |
| `court_cracks.glb` | Vết nứt sân ở chỗ `RoadCrack212/222/233` PS1 và quanh chân trụ tây |
| `pillars_plaster.glb` | Hai trụ cổng trát quét vôi (P1); trụ tây nghiêng 7°, vết nứt mặt trước |
| `gate_swing.glb` | Cổng sắt hai cánh sơn xanh (G1) |
| `sign_arch.glb` | Vòm thép, biển tôn xanh "TRƯỜNG ĐẠI HỌC" rơi nửa, dây treo (SA; chữ đặt bằng Be Vietnam Pro SemiBold, OFL, đã có trong `game/assets/fonts/`) |
| `booth_masonry.glb`, `booth_interior.glb` | Chốt bảo vệ xây quét vôi vàng (K1); đồ bên trong trong một atlas |
| `wall_south.glb` | Tường rào nam (W1) dọc cả `Fence/S`: tường, trụ, song sắt gần, thẻ song sắt xa |
| `strip_gate.glb` | Dải A16 đoạn cổng: cỏ mòn, lối lát block con sâu, cuối đại lộ, bó vỉa, viền |
| `strip_gate_props.glb` | Năm ô tô sedan cũ, hai rào chắn, sáu cọc giao thông, ba lô, giày, dép, điện thoại, giấy, đống gạch vỡ |
| `materials/*.tres` | Vật liệu W5* (`make_wave5_materials.py`) |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

Texture riêng: `game/assets/textures/graphics_pilot/realistic_map/wave5/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã
có trong game (CC0 Poly Haven, nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md` và `room407_shell`):
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) và [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall)
(trụ, tường, chốt), [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (cổng, vòm, song tường, cửa chốt),
[Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (`W1Concrete`), [Wood Table Worn](https://polyhaven.com/a/wood_table_worn)
(mặt bàn trong atlas chốt); gạch block con sâu, cỏ, đất, giấy rác, gạch của đợt 3; bảng màu đồ rơi, thẻ lưới, thép mạ
kẽm, tôn của đợt 4; vật liệu chung của đợt 1, 2.
