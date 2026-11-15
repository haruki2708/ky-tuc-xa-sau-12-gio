# Nguồn asset — `realistic_map/wave6/` (T-263, nhà ăn, bếp, kho, dải A16 quanh nhà ăn; D-166, D-181)

Mọi file dưới đây do `art_source/graphics_upgrade/realistic_map/wave6/build_canteen_pilot.py` (lượt 1, các phương án chủ dự
án chọn ở D-181) và `build_canteen.py` (lượt 2) dựng (Blender 5.2.2, chỉ bmesh). Tác giả: dự án (Claude, lane B; T-263).
Giấy phép: như dự án. Lượt 2 đã bỏ glb và vật liệu của các phương án không chọn (C1, T2, M1, Q2, K2, F2, bảng in).

| File | Là gì |
|---|---|
| `hall_shell.glb` | Sàn sảnh (F1 ceramic), mặt trong tường (sơn vàng nhạt trên ốp gạch men 1,4 m), tường trước hai mặt có 10 lỗ cửa sổ, tường sau phía tây có 5 ô chia cơm (cửa cuốn kéo xuống), lanh tô, khung lối tây |
| `windows.glb` | 10 cửa sổ nhôm kính lùa, song sắt ngoài, bậu |
| `ceiling_panels.glb` | C2: trần tấm 60 × 60 ố vàng, vài tấm rơi, vài tấm võng |
| `lights_fans.glb` | 20 máng đèn tuýp, 3 quạt trần |
| `tables_inox.glb` | T1: 21 bàn inox liền 6 ghế đôn |
| `tableware_mess.glb` | M2: khay inox, bát, đũa, đồ ăn thừa; bát đổ, khay, đũa, mảnh bát rơi ở lối đi |
| `counter_inox.glb` | Q1: quầy inox, kính chắn, khay thức ăn, thanh trượt khay, thùng giữ cơm, giá khay, máy quẹt thẻ, rào xếp hàng |
| `price_boards.glb` | 5 bảng giá gỗ sơn đen chữ trắng (chữ trong `price_wood.png`) |
| `tv.glb`, `tv_screen.glb` | TV phẳng cũ trên giá tường; màn hình sáng (treo dưới `TV/Screen`, ảnh bản tin không chữ) |
| `kitchen_room.glb` | Sàn, tường, trần bếp; bàn sơ chế, chậu rửa, xửng hấp, nồi cơm, kệ, móc muôi |
| `kitchen_k1.glb` | K1: bếp gạch ốp men, chảo gang, nồi nhôm; chụp hút chia hai nửa |
| `clock.glb` | Đồng hồ treo tường dừng 4:00 |
| `facade.glb` | Mặt tiền: trụ, chân tường, gờ, tường chắn mái, mái hiên, cột, bậc, biển "NHÀ ĂN SINH VIÊN", bảng khẩu hiệu |
| `hall_east.glb` | Lượt 2: máng rửa tay ốp gạch, 4 chậu men, vòi, gương; kệ trả khay inox và khay; biển "TRẢ KHAY"; 2 thùng thức ăn thừa; 4 tranh cổ động không chữ; 3 máy lạnh treo tường; ngưỡng cửa |
| `store.glb` | Lượt 2: sàn, tường, trần kho; khung cửa sau, cửa cuốn cuộn lên; 2 kệ thép góc, thùng carton, can dầu, bao gạo (cả bao gạo trong bếp) |
| `outside.glb` | Lượt 2: mặt ngoài tường tây, đông, sau; chân tường, gờ, trụ; mái (mặt, viền, tường chắn mái, máng xối), bồn nước inox; ống khói; ống thoát nước mưa; cục nóng máy lạnh; bình gas và lồng sắt; thùng rác; quạt hút bếp; hộp điện; cánh cửa thép lối tây mở áp tường |
| `bikes.glb` | Lượt 2: 6 xe đạp đỗ trước cửa (màu khung như PS1, 2 xe nghiêng chân chống) |
| `strip_canteen.glb` | Lượt 2: dải A16 quanh nhà ăn: gạch lát sân trước, hè bê tông và rãnh có nắp dọc tường, sân bê tông sau bếp và kho, bãi cỏ mòn, viền bê tông |
| `strip_canteen_props.glb` | Lượt 2: 18 đồ rải thay chỗ PS1: giấy (thẻ giấy của đợt 3), dép, ba lô (bảng màu đợt 4), khay |
| `materials/*.tres` | Vật liệu W6* (`make_wave6_materials.py`) |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.
Chữ biển, khẩu hiệu, bảng giá, "TRẢ KHAY" đặt bằng Be Vietnam Pro SemiBold (OFL, có sẵn trong `game/assets/fonts/`), giữ đúng
chữ PS1.

Texture riêng: `game/assets/textures/graphics_pilot/realistic_map/wave6/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã
có trong game (CC0 Poly Haven, nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md` và `room407_shell`):
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) và [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall)
(tường, mặt tiền, mặt ngoài), [Long White Tiles](https://polyhaven.com/a/long_white_tiles) (ốp chân tường, bếp K1, máng
rửa tay), Plastered Wall 04 của phòng 407 (bê tông sân sau, hè), gạch chống trơn của phòng 407 (sàn bếp, sàn kho), nhôm
xước tự vẽ ở T-222 (inox, nồi); cỏ, đất, gạch "con sâu", thẻ giấy và rãnh tối của đợt 3; bảng màu đồ rải của đợt 4; vật
liệu chung của đợt 1, 2, 4, 5 (bê tông, sắt, nhôm, kính, đèn tuýp, thép mạ kẽm, đồng hồ, sơn cửa thép).
