# Đồ hoạ thật đợt 6 — T-263 (D-166): nhà ăn, bếp, kho (A15) và dải A16 quanh nhà ăn

Card: `docs/tasks/T-263-realistic-graphics-wave6-canteen.md`. Dựng bằng script Blender, texture vẽ bằng code
(numpy + Pillow). Không Tripo, không extension Blender, không ảnh AI.

## Bước 0 (15/11/2026): trả đầu 6 xác trong vườn
`patch_canteen.py heads` (chạy một lần trên `props.tscn` của main): hiện lại `Parts/P_paper_box_p0_p0` (T-259 ẩn cả node,
mất đầu 6 xác), thu về 0 bảy bản T-259 đã thay (khay cơm #0, 6 tờ bảng tin #4…9), giữ 6 đầu (#1…3, #10…12).
`../wave3/build_garden.py` không đặt tờ giấy lên đầu xác ở mọi chế độ; dựng lại `wave3/strip_props.glb`
(`blender -b --factory-startup -P .../wave3/build_garden.py -- props`): 54 mẩu giấy, chỉ mất đúng 6 tờ ở 6 chỗ đầu, các
lưới khác trùng từng đỉnh với bản cũ. Test: `test_t263_garden_heads.gd`; `test_t259` (`A16_ALL`/`A16_PARTLY`) và
`test_t261` (`PROPS_KEPT_MD5`, 2.117 dòng) sửa theo, có comment. Ảnh `../previews/wave6/heads_*`, `heads.jpg`.

## Lượt 1 (15/11/2026): khảo sát, góc mẫu, phương án — chờ chủ dự án chọn
`canteen.tscn`, `campus.tscn` chưa sửa (chỉ `props.tscn` ở bước 0): `capture_wave6.gd` gắn góc mẫu vào cảnh chương 3 thật
lúc chạy, ẩn hình PS1 tương ứng (838 node, `visible = false`; va chạm, node, meta giữ), treo màn sáng dưới
`Canteen/TV/Screen` (nên `campus.gd.set_canteen_tv` vẫn bật/tắt được), đặt 6 xác sống ở `ZombieIdle/Canteen` bằng
`place_idle` của đàn xác, rồi chụp.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave6/make_wave6_textures.py     # 15 texture (khoảng 30 giây)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave6/build_canteen_pilot.py   # [-- hall_shell windows ...]
python -B art_source/graphics_upgrade/realistic_map/wave6/make_wave6_materials.py    # .tres W6*, .import glb và texture (nén VRAM)
godot --headless --path game --import   # lần đầu chạy hai lần
python -B art_source/graphics_upgrade/realistic_map/wave6/list_a16_box.py            # a16_box_nodes.json
pwsh tools/test.ps1 -Filter t263
```
Ảnh: chép `capture_wave6.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script đó (không commit), rồi theo Lượt Godot
`godot --path game res://_probe_tmp/capture_wave6.tscn -- --configs=before,a,b,c,d` (khoảng 90 ảnh), sau đó
`python -B art_source/graphics_upgrade/realistic_map/wave6/make_wave6_sheets.py` (8 bảng `options_*.jpg` và `heads.jpg`).
Khảo sát: `survey_canteen.gd` (→ `survey/canteen_nodes.tsv`, `survey/campus_canteen.tsv`), `walk_canteen.gd` (navmesh,
thân người chơi thật), chép vào `_probe_tmp` như trên, chạy `--headless`.

- `canteen_layout.py`: số đo lấy từ main (cửa sổ, đèn, quạt, bàn, quầy, bếp, đồng hồ, chữ biển), toạ độ mặt nạ UV2,
  hộp A16, cỡ lặp texture (`SIZES`), ô bảng giá trong atlas.
- `make_wave6_textures.py`: gạch ceramic 40 × 40, tấm trần 60 × 60, mặt nạ sàn/trần/tường, bảng giá hai kiểu, biển,
  khẩu hiệu, màn TV, bảng màu đồ nhỏ (`palette.json`).
- `build_canteen_pilot.py`: 21 glb (xem docstring); mọi mảnh dưới tầm đầu nằm trong khối va chạm cũ hoặc đúng chỗ mesh PS1
  vốn không có va chạm (rào xếp hàng, thanh trượt khay, giá khay, máy quẹt thẻ, cột mái hiên); lanh tô cửa chính và lỗ bếp từ
  3,3 m, lối tây và cửa kho từ 2,4 m (test `test_t263_canteen_pilot`).
- `make_wave6_materials.py`: vật liệu `W6*`; `.import` của mọi texture: `compress/mode=2`, normal thêm `compress/normal_map=1`.
- `capture_wave6.gd`, `make_wave6_sheets.py`: ảnh và bảng phương án. `capture_t263.gd`: ảnh bước 0.

### Phương án (ảnh ở `../previews/wave6/`)
Cấu hình chụp: **a** = T1 F1 Q1 + bảng gỗ C2 K1 M1; **b** = T2 F2 Q2 + bảng in C1 K2 M2; **c** = a với M2 (đề xuất);
**d** = b với M1 (T2 ghế đứng).

| Mã | Là gì | Tam giác | Vật liệu |
|---|---|---|---|
| — | Vỏ sảnh (sàn, mặt trong tường, tường trước hai mặt, tường sau phía tây có 5 ô chia cơm, lanh tô, khung lối tây) | 2.138 | 10 |
| — | 10 cửa sổ nhôm kính lùa, song sắt, bậu | 5.721 | 4 (kính trong suốt) |
| F1 | Sàn ceramic 40 × 40 kem, tường vàng nhạt, ốp gạch men trắng 1,4 m | (trong vỏ) | `W6FloorCeramic`, `W6WallYellow`, `W6Wainscot` |
| F2 | Sàn đá mài, tường xanh nhạt, chân tường sơn dầu xanh 1,4 m | (trong vỏ) | `W6FloorTerrazzo`, `W6WallGreen`, `W6DadoGreen` |
| C2 | Trần tấm 60 × 60 ố vàng, 6 tấm rơi (thấy hốc tối), 2 tấm võng, 1 tấm dưới sàn | 516 | 3 |
| C1 | Mái tôn lộ, xà gồ mạ kẽm, kèo chữ I sơn xanh | 820 | 3 |
| — | 20 máng đèn tuýp (đúng chỗ PS1), 3 quạt trần đứng yên | 2.644 | 4 |
| T1 | 21 bàn inox liền 6 ghế đôn tròn (ghế đỏ/xanh như PS1) | 23.100 | 3 |
| T2 | 21 bàn mặt đá khung sắt sơn, 126 ghế nhựa rời đỏ/xanh | 24.360 | 4 |
| M1 | Khay inox 5 ngăn, bát sứ viền xanh, đũa, cơm thừa đúng chỗ PS1; 6 khay rơi, vệt đổ | 22.504 | 2 |
| M2 | M1 + bát đổ trên bàn, 34 chỗ khay/bát/đũa/mảnh bát rơi ở lối đi (với T2: một phần ba ghế đổ) | 27.034 | 2 |
| Q1 | Quầy inox, khay thức ăn lõm, kính chắn nghiêng, thanh trượt khay, thùng giữ cơm, giá khay, máy quẹt thẻ, rào xếp hàng | 3.996 | 4 |
| Q2 | Quầy xây ốp gạch men trắng, mặt inox (phần còn lại như Q1) | 3.876 | 6 |
| — | 5 bảng giá treo xích: gỗ sơn đen chữ trắng (`W6PriceWood`) hoặc bảng in (`W6PricePrint`) | 130 | 2 |
| — | TV phẳng cũ trên giá tường; màn sáng (dưới `TV/Screen`) | 106 + 2 | 4 + 1 |
| — | Phòng bếp: sàn chống trơn, tường ốp gạch 1,8 m, bàn sơ chế, chậu, xửng hấp, nồi cơm, kệ, móc muôi | 2.828 | 9 |
| K1 | Bếp gạch ốp men cháy khói, 2 chảo gang, 2 nồi nhôm lớn, ống gas; chụp hút inox chia hai nửa | 1.752 | 8 |
| K2 | Bếp inox công nghiệp, chảo, nồi inox; cùng chụp hút | 1.964 | 4 |
| — | Đồng hồ treo tường dừng 4:00 | 190 | 3 |
| — | Mặt tiền: trụ, chân tường, gờ, tường chắn mái, mái hiên, cột, bậc, biển, khẩu hiệu | 522 | 7 |

PS1 `canteen.tscn` (PLAN A15): 19.380 tam giác, 13 vật liệu, 932 MeshInstance3D. Góc mẫu cấu hình a: 66.149 tam giác
(bàn và khay bát 45.604; lượt 2 sẽ giảm ghế, bát theo khoảng cách), b: 72.335.

Số lần vẽ / primitive (chương 3, cùng camera; PS1 → a → b):
| Góc | PS1 | a | b |
|---|---|---|---|
| từ cửa chính nhìn sảnh (`door`) | 1.656 / 83 k | 1.295 / 143 k | 1.265 / 146 k |
| từ cửa nhìn thẳng vào bếp (`door_in`) | 1.572 / 48 k | 1.089 / 98 k | 1.089 / 102 k |
| từ quầy nhìn ra cửa (`counter_out`) | 1.122 / 53 k | 693 / 104 k | 695 / 110 k |
| quầy chia cơm | 1.100 / 79 k | 1.039 / 132 k | 1.042 / 135 k |
| giữa các bàn | 1.246 / 53 k | 724 / 101 k | 725 / 107 k |
| một bàn gần, đèn pin | 1.701 / 168 k | 1.609 / 248 k | 1.610 / 254 k |
| trần | 617 / 30 k | 254 / 81 k | 254 / 85 k |
| bếp, đèn pin | 843 / 34 k | 831 / 38 k | 828 / 38 k |
| mặt tiền | 1.976 / 60 k | 1.213 / 109 k | 1.213 / 112 k |
Số lần vẽ giảm ở mọi góc (PS1 mỗi bàn khoảng 30 lần vẽ; góc mẫu gộp 21 bàn thành 3–4 lưới, khay bát thành 2), primitive tăng
50–80 nghìn ở góc rộng. Góc nhìn về phía tây (TV, lối tây, bếp nhìn chéo) thấy cả khuôn viên phía sau tường (4.300–5.200
lần vẽ ở cả PS1 lẫn góc mẫu): đề nghị integrator cân nhắc occluder hộp cho vỏ nhà ăn (card mục 5). Bộ nhớ hình chương 3:
1.307 MB (PS1) → 1.309–1.310 MB khi đã nạp cả hai bộ phương án. Không đo FPS (D-179).

### Hộp A16 đợt này: x 166…218, z 13…60, trừ góc x 166…170, z 37…60 (đợt 8)
Sân trước từ mép dải T-262 (z 13) tới mặt tiền, hai bên hông, sân sau cửa kho tới z 60; không lấn hộp T-262 (z < 13) và
phần ngoài lối tây phía bắc z 37 (đường sang thư viện, đợt 8). Chi tiết: `a16_box_nodes.json` và Handoff của card.

### Ghi chú
- Ô chia cơm là hốc 0,2 m trong tường sau phía tây (tường dày 0,25 m, mặt ngoài giữ nguyên), cửa cuốn kéo xuống còn hở 30 cm.
- Cửa sổ trước là lỗ thật (va chạm tường vẫn liền): từ trong nhìn ra sân, từ sân nhìn vào sảnh sáng đèn.
- Chụp hút chia hai nửa để đồng hồ (giữa x 191,7…192,3, cao −7,68…−7,12) không bị che: hộp chụp hút PS1 che gần hết đồng hồ
  khi nhìn từ sảnh.
- Mặt trong tường tây, đông, sau phía đông và tường bếp dựng sát trước mặt PS1 (4 mm); hộp PS1 giữ mặt ngoài. Lượt 2 làm mặt
  ngoài các tường này.
- Đồ PS1 phía đông sảnh (bồn rửa tay, gương, chỗ trả khay, thùng thức ăn thừa), áp phích, kho, xe đạp trước cửa, máy lạnh
  tường tây chưa thay ở góc mẫu.
