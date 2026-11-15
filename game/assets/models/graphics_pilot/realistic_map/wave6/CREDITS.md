# Nguồn asset — `realistic_map/wave6/` (T-263, nhà ăn, bếp, kho; lượt 1 góc mẫu; D-166)

Mọi file dưới đây do `art_source/graphics_upgrade/realistic_map/wave6/build_canteen_pilot.py` dựng (Blender 5.2.2, chỉ
bmesh). Tác giả: dự án (Claude, lane B; T-263). Giấy phép: như dự án. Lượt 1 chưa scene nào dùng; lượt 2 bỏ các phương án
không chọn.

| File | Là gì |
|---|---|
| `hall_shell.glb` | Sàn sảnh, mặt trong tường (sơn trên ốp chân tường 1,4 m), tường trước hai mặt có 10 lỗ cửa sổ, tường sau phía tây có 5 ô chia cơm (cửa cuốn kéo xuống), lanh tô, khung lối tây |
| `windows.glb` | 10 cửa sổ nhôm kính lùa, song sắt ngoài, bậu |
| `ceiling_panels.glb` / `ceiling_roof.glb` | C2 trần tấm 60 × 60 ố vàng / C1 mái tôn lộ xà gồ, kèo thép |
| `lights_fans.glb` | 20 máng đèn tuýp, 3 quạt trần |
| `tables_inox.glb` | T1: 21 bàn inox liền 6 ghế đôn |
| `tables_stone.glb`, `tables_stone_mess.glb` | T2: bàn mặt đá, ghế nhựa rời (đứng / một phần đổ) |
| `tableware.glb`, `tableware_mess.glb` | M1 / M2: khay inox, bát, đũa, đồ ăn thừa, khay rơi, vệt đổ |
| `counter_inox.glb`, `counter_tiled.glb` | Q1 quầy inox / Q2 quầy ốp gạch men; kính chắn, khay thức ăn, thanh trượt khay, thùng giữ cơm, giá khay, máy quẹt thẻ, rào xếp hàng |
| `price_boards.glb` | 5 bảng giá (chữ trong `price_wood.png` / `price_print.png`) |
| `tv.glb`, `tv_screen.glb` | TV phẳng cũ trên giá tường; màn hình sáng (treo dưới `TV/Screen`) |
| `kitchen_room.glb` | Sàn, tường, trần bếp; bàn sơ chế, chậu rửa, xửng hấp, nồi cơm, kệ, móc muôi |
| `kitchen_k1.glb` / `kitchen_k2.glb` | K1 bếp gạch ốp men, chảo gang, nồi nhôm / K2 bếp inox; chụp hút chia hai nửa |
| `clock.glb` | Đồng hồ treo tường dừng 4:00 |
| `facade.glb` | Mặt tiền: trụ, chân tường, gờ, tường chắn mái, mái hiên, cột, bậc, biển "NHÀ ĂN SINH VIÊN", bảng khẩu hiệu |
| `materials/*.tres` | Vật liệu W6* (`make_wave6_materials.py`) |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.
Chữ biển, khẩu hiệu, bảng giá đặt bằng Be Vietnam Pro SemiBold (OFL, có sẵn trong `game/assets/fonts/`), giữ đúng chữ PS1.

Texture riêng: `game/assets/textures/graphics_pilot/realistic_map/wave6/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã
có trong game (CC0 Poly Haven, nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md` và `room407_shell`):
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) và [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall)
(tường, chân tường sơn dầu, mặt tiền), [Long White Tiles](https://polyhaven.com/a/long_white_tiles) (ốp chân tường, quầy Q2,
bếp K1), gạch chống trơn của phòng 407 (sàn bếp), nhôm xước và đá granite tự vẽ ở T-222 (inox, nồi, mặt bàn T2), đá mài
tự vẽ của đợt 1 (F2); vật liệu chung của đợt 1, 2, 4, 5 (bê tông, sắt, nhôm, kính, đèn tuýp, tôn, thép, sơn xanh, đồng hồ).
