# Đồ hoạ thật đợt 5 — T-262 (D-166, D-176): cổng trường, chốt bảo vệ, tường rào nam, sân cổng, dải A16 đoạn cổng

Card: `docs/tasks/T-262-realistic-graphics-wave5-gate.md` (đọc ở commit `1b63065`). Dựng bằng script Blender, texture vẽ
bằng code (numpy + Pillow). Không Tripo, không extension Blender, không ảnh AI.

## Lượt 2 (15/11/2026, D-180): cả cổng, tường rào nam, dải A16 đoạn cổng
Chủ dự án chọn phương án a có chữ: G1 cổng sắt hai cánh sơn xanh, P1 trụ trát quét vôi + SA biển tôn xanh trên vòm thép,
chữ "TRƯỜNG ĐẠI HỌC" (tên trường bong), K1 chốt xây quét vôi vàng (đồ bên trong gộp atlas), W1 tường trát quét vôi +
song sắt dọc **cả `Fence/S`**, C2 block con sâu cho sân cổng và lối sang nhà ăn, thay 5 ô tô PS1 và đồ rơi. HARU cho phép
rút hình `Road/Avenue` còn x 0…180, cắt hình tường ở lỗ cổng (dải ngoài cổng chỉ để nhìn) và trả đầu 3 xác bị ẩn nhầm.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_textures.py   # 11 texture lượt 2
# Gắn vào scene: chạy một lần trên bản main của ba file (xem đầu patch_gate.py); bước data trước khi dựng đồ rải:
python -B art_source/graphics_upgrade/realistic_map/wave5/patch_gate.py data
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave5/build_gate.py   # [-- court ... wall strip strip_props]
python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_materials.py
godot --headless --path game --import   # lần đầu chạy hai lần
python -B art_source/graphics_upgrade/realistic_map/wave5/patch_gate.py gate campus props
pwsh tools/test.ps1 -Filter t262
```
- `patch_gate.py`: `data` ghi `w5_ps1_props.json` (dữ liệu main của 24 chunk `props.tscn` đợt này đụng); `gate` ẩn 43 node hình
  PS1 của `gate.tscn` và thêm node `Real` (`gate_real.gd`); `campus` ẩn `Fence/S/Mesh` (giữ va chạm), rút BoxMesh của
  `Road/Avenue/Mesh` còn 180 m (mesh dời 20 m sang tây, node `Road/Avenue` không đổi), thêm `WallSouth` và `StripGate`;
  `props` thu cỡ về 0 đúng 180 bản trong hộp (5 ô tô 70 bản, 2 rào chắn 12, 6 cọc 12, 38 tờ giấy, ba lô 6, giày 10, dép 4,
  điện thoại 14, đống gạch 14) và trả ma trận main cho 3 đầu xác (`P_paper_box_p1_p0` bản 0, `P_paper_box_p2_p2` bản 1,
  `P_paper_box_p2_p4` bản 1).
- **`gate.tscn` → `Real`:** `Court` (block con sâu, cao độ −9,90), `Outside` (vỉa hè, bó vỉa, lòng đường nhựa ngoài cổng,
  z ≤ −60,15), `Cracks` (vết nứt đúng chỗ `RoadCrack*` và quanh chân trụ tây), `Pillars`, `Gate`, `Sign`, `Booth`, `Interior`.
- **`campus.tscn` → `WallSouth`:** W1 từ x −80 tới 420 trừ lỗ cổng, mỗi 30 m một khối `Solid_NN`, `BarsNear_NN` (song sắt
  thật), `BarsFar_NN` (thẻ song sắt phẳng có alpha, shader thẻ của đợt 4). `gate_real.gd`: song thật vẽ tới 45 m, thẻ từ 45 m,
  chuyển dần 5 m; đồ trong chốt vẽ trong 30 m; đồ rải tắt ở 125 m (giấy 80 m) như PS1; mặt phẳng không đổ bóng.
- **`campus.tscn` → `StripGate`** (hộp x 180…262, z −60…13): `Ground` (cỏ mòn `W5StripGround`; lối lát block con sâu
  x 217…223 từ mép bắc sân lên z 13 và rẽ tây tới x 186 ở z 7…13; 37 m cuối đại lộ x 180…217 giữ cao độ −9,87 của đường
  PS1; bó vỉa, viền bê tông), `Props` (5 ô tô sedan cũ đúng chỗ, đúng góc, màu theo PS1, trong khối va chạm 4,4 × 1,5 ×
  1,9 m; 2 rào chắn, 6 cọc (2 cọc đổ như PS1); ba lô, giày, dép, điện thoại theo bảng màu đợt 4; 38 tờ giấy; đống gạch vỡ).
- Lỗi đầu xác: `wave3/build_garden.py` và `wave4/build_stadium.py` bỏ tờ giấy đặt đúng chỗ đầu xác (giữ nguyên lượt rút số
  ngẫu nhiên nên mọi tờ khác không đổi: so đỉnh glb cũ/mới chỉ mất đúng 1 và 2 tờ); dựng lại `wave3/strip_props.glb`,
  `wave4/strip_stadium_props.glb`.
- Phương án không chọn đã gỡ khỏi `game/` (P2, G2, SB và chữ nổi, K2, W2, biển không chữ; texture gạch, composite, mặt nạ
  băng biển; `barrier.glb`, `cone.glb` gộp vào `strip_gate_props.glb`). Muốn dựng lại: `build_gate_pilot.py` và
  `make_wave5_textures.py brick panel signs board_masks`, vật liệu ở lịch sử git (commit `18d2530`).

### Số liệu lượt 2
| Phần | Tam giác | Vật liệu |
|---|---|---|
| Sân cổng, vết nứt, dải ngoài cổng | 8 + 18 + 48 | `W5CourtPavers`, `W5GroundCrack`, `W5CourtAsphalt`, `W1Concrete`, `W4Paint` |
| Hai trụ (P1) | 330 | `W5Plaster`, `W1Concrete`, `W1Crack` |
| Cổng G1 | 2.292 | `W5GateGreen`, `W1Iron`, `W1Steel` |
| Vòm và biển SA | 2.252 | `W5GateGreen`, `W1Iron`, `W5SignText`, `W1Steel` |
| Chốt K1 | 648 | 7 (`W5BoothYellow`, `W5Plaster`, `W1Concrete`, `W1Alu`, `W2Glass`, `W1Iron`, `W5DoorPaint`) |
| Đồ trong chốt | 528 | 1 (`W5BoothAtlas`) |
| **Lớp `Real` của cổng** | **6.124** | |
| Tường nam cả 500 m (17 khối) | 6.408 khối đặc + 29.224 song thật (chỉ vẽ trong 45 m) + 318 thẻ song | `W5Plaster`, `W5GateGreen`, `W5BarsCard` |
| Dải A16: cỏ, lối lát, đại lộ, bó vỉa | 592 | `W5StripGround`, `W5CourtPavers`, `W1Concrete` |
| Dải A16: 5 ô tô | 5.880 | 11 (4 màu sơn, kính, đèn, đèn hậu, cao su, thép, đen, biển số) |
| Dải A16: rào chắn, cọc; đồ rơi; giấy; gạch vỡ, thép | 1.340; 1.616; 76; 924 + 84 | `W5BarrierStripes`, `W4PoleSteel`, `W5ConeOrange`, `W5Reflect`, `W1Rubber`; `W4Palette`; `W3Litter`; `W3Brick`, `W1Concrete`, `W1Rebar` |
Cả đợt: 52.586 tam giác trong 11 glb (phần lớn là song sắt gần, chỉ vẽ các khối trong 45 m). PS1 cổng 804 tam giác,
6 vật liệu (vẫn còn, đã ẩn).

Số lần vẽ và primitive (chương 3, cùng camera, trước → sau): từ `Start_gate` 351 / 12,5 k → 336 / 30,2 k; cuối đường vào
382 / 14,5 k → 380 / 34,3 k; biển, đèn pin 448 / 13,3 k → 432 / 33,7 k; rào chắn, đèn pin 479 / 14,8 k → 466 / 37,4 k; chốt
35 / 1,6 k → 61 / 16,2 k (đèn pin 43 → 85: chốt 7 vật liệu, đèn pin đổ bóng); qua cửa sổ 17 → 28; nhìn qua cổng 332 → 309;
từ cổng nhìn về nhà ăn 2.001 / 104 k → 2.019 / 113 k; cuối đại lộ 428 → 424; ô tô 241 / 9,4 k → 251 / 29,9 k; tường sau nhà B
18 / 1,1 k → 25 / 6,4 k; tường phía đông 25 → 34. Góc rộng nhìn cả khu (tường phía chốt, lối sang nhà ăn, góc đông bắc
sân, tường nhìn xa): số lần vẽ gần như cũ (4.442 → 4.427, 6.011 → 6.027, 4.258 → 4.247, 3.518 → 3.515), primitive thêm
6…22 nghìn trên khoảng 1,5 triệu. Bộ nhớ hình chương 3: 1.278…1.279 MB → 1.288…1.290 MB (khoảng +10 MB). Không đo FPS.
Ảnh: `../previews/wave5/before_*`, `after_*` (17 góc, có hàng bảo vệ), `overview.jpg`; chép `capture_t262.gd` vào
`game/_probe_tmp/` và chạy `-- --tag=before` (trên bản main) / `--tag=after`, rồi `make_wave5_sheets.py --overview`.

## Lượt 1 (15/11/2026): khảo sát, góc mẫu, phương án — chờ chủ dự án chọn
`gate.tscn`, `campus.tscn`, `props.tscn` **chưa sửa**: `capture_wave5.gd` gắn góc mẫu vào cảnh chương 3 thật lúc chạy, ẩn
hình PS1 tương ứng (`visible = false`; bản MultiMesh của hai thanh chắn và hai hàng cọc thu cỡ về 0; `Fence/S/Mesh` thay
bằng hai khối PS1 ở hai bên đoạn tường mẫu x 186…262), rồi chụp. 12 bảo vệ do director đặt trong `_ready` đứng đúng chỗ.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_textures.py   # 16 texture + sign_layout.json (khoảng 35 giây)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave5/build_gate_pilot.py   # [-- court pillars_plaster gate_swing ...]
python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_materials.py  # .tres, .import của glb và texture (nén VRAM)
godot --headless --path game --import   # lần đầu chạy hai lần
python -B art_source/graphics_upgrade/realistic_map/wave5/list_a16_box.py          # a16_box_nodes.json
pwsh tools/test.ps1 -Filter t262
```
Ảnh: chép `capture_wave5.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script đó (không commit), rồi theo Lượt Godot
`godot --path game res://_probe_tmp/capture_wave5.tscn -- --configs=before,a,b,c,d` (67 ảnh, khoảng 4 phút), sau đó
`python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_sheets.py` (5 bảng `options_*.jpg`). Đi thử tuyến:
chép `walk_route.gd` tương tự, `godot --headless --path game res://_probe_tmp/walk_route.tscn`.

- `gate_layout.py`: số đo lấy từ main (`gate.tscn`, `Fence/S`, anchor, vùng, đồ rải của sân cổng), hộp A16 đợt này.
- `walk_route.gd`: navmesh và thân người chơi thật đi tuyến sân vận động → cổng → nhà ăn, đường nhìn tới 12 bảo vệ.
- `list_a16_box.py` → `a16_box_nodes.json`: node và bản MultiMesh A16 trong hộp, chia loại thay ở lượt 2 / giữ nguyên.
- `make_wave5_textures.py`: nhựa đường (C1), gạch (W2, P2), tấm composite (K2), biển tôn có chữ và không chữ (SA), mặt nạ
  băng biển (SB), sọc rào chắn, vết nứt sân, mặt nạ sân (`mask_court.png`, phủ cả hộp A16 cho lượt 2), mặt nạ tường/trụ/chốt
  (`mask_gate.png`); `sign_layout.json` (vị trí chữ để dựng chữ nổi khớp với texture).
- `build_gate_pilot.py`: 17 glb (xem docstring); mọi mảnh trong khối va chạm cũ hoặc cao trên đầu (test `test_t262_gate_pilot`).
- `make_wave5_materials.py`: vật liệu `W5*` (dùng lại bộ ghi của đợt 4); `.import` của mọi texture: `compress/mode=2`,
  normal thêm `compress/normal_map=1`.
- `capture_wave5.gd`, `make_wave5_sheets.py`: ảnh và bảng phương án.

### Hộp A16 đợt này: x 180…262, z −60…13 (mặt đất, y −10,5…−6)
Sân cổng, 40 m cuối `Road/Avenue` (x 180…220) và khoảng đất từ sân lên tới mép nam hộp nhà ăn (z 13), nơi đồng đội, bot,
đàn xác cổng và người chơi đi qua sang nhà ăn; không lấn hộp nhà ăn (x 170…210, z 13…51). Chi tiết và danh sách node ở
Handoff của card và `a16_box_nodes.json`.

### Phương án (ảnh ở `../previews/wave5/`)
| Mã | Là gì | Tam giác | Vật liệu |
|---|---|---|---|
| C2 | Sân lát block con sâu xám (như dải nối D-178), vệt bánh xe, vũng nước, dầu | 8 (cả sân) | `W5CourtPavers` |
| C1 | Sân nhựa đường cũ, nứt chân chim, miếng vá | 8 | `W5CourtAsphalt` |
| — | Vỉa hè, bó vỉa, lòng đường ngoài cổng; vết nứt sân | 48; 18 | `W5CourtPavers`, `W5CourtAsphalt`, `W1Concrete`, `W4Paint`; `W5GroundCrack` |
| P1 | Hai trụ trát quét vôi trên chân bê tông, khung nổi mặt trước, trụ tây nghiêng 7° và nứt | 330 | `W5Plaster`, `W1Concrete`, `W1Crack` |
| P2 | Hai trụ ốp gạch đỏ, gờ và mũ quét vôi | 138 | `W5Brick`, `W5Plaster`, `W1Concrete`, `W1Crack` |
| G1 | Cổng sắt hai cánh sơn xanh, tấm tôn dưới, song đứng mũi giáo, bánh xe đỡ, khoá xích (3 m) | 2.292 | `W5GateGreen`, `W1Iron`, `W1Steel` |
| G2 | Cổng xếp inox hai nửa, ray dưới đất, cột khoá giữa (1,9 m) | 11.348 | `W5Stainless`, `W1Iron`, `W1Rubber` |
| SA | Vòm giàn thép trên hai trụ, biển tôn xanh treo, rơi nửa (đầu đông tựa lên cổng) | 2.252 | `W5GateGreen`, `W1Iron`, `W1Steel`, `W5SignText` hoặc `W5SignBlank` |
| SB | Băng biển trát vữa bắt giá trên mũ trụ, rơi nửa; chữ nổi đỏ | 72 + chữ 2.488 | `W5Band` hoặc `W5BandBlank`, `W1Iron`, `W5LetterRed` |
| K1 | Chốt xây trát quét vôi vàng, gờ trắng, mái bê tông, cửa sổ nhôm có song sắt, cửa sắt | 650 | 10 (`W5BoothYellow`, `W5PlasterInner`, `W5Plaster`, `W1Concrete`, `W1Alu`, `W2Glass`, `W1Iron`, `W5DoorPaint`, `W1Steel`, `W1Terrazzo`) |
| K2 | Chốt lắp ghép tấm composite trắng, khung thép xanh, mái tôn, thêm cửa sổ hông | 420 | 7 (`W5Panel`, `W5FrameBlue`, `W4RoofSheet`, `W1Alu`, `W2Glass`, `W1Steel`, `W1Terrazzo`) |
| — | Đồ trong chốt (chỉ vẽ trong 30 m): bàn, ghế nhựa, sổ trực, điện thoại, phích, cốc, quạt, màn hình, mũ, lịch, hộp khoá | 526 | 10 vật liệu chung đợt 1 |
| W1 | Tường trát quét vôi 1,8 m + song sắt tới 3 m, trụ mỗi 3 m (đoạn x 186…262) | 3.976 | `W5Plaster`, `W5GateGreen` |
| W2 | Tường gạch trần 2,7 m, trụ gạch, gờ bê tông (cùng đoạn) | 768 | `W5Brick`, `W1Concrete` |
| — | Rào chắn sọc đỏ trắng (2 cái), cọc giao thông (6 cái) | 244 mỗi rào, 186 mỗi cọc | `W5BarrierStripes`, `W4PoleSteel`, `W1Rubber`; `W5ConeOrange`, `W5Reflect` |

PS1 `gate.tscn`: 804 tam giác, 6 vật liệu. Góc mẫu phương án a (C2 P1 G1 SA K1 W1 + đồ trong chốt, rào chắn, cọc):
11.704 tam giác; phương án b (C1 P2 G2 SB có chữ K2 W2 …): 17.438.

Số lần vẽ và số primitive (chương 3, cùng camera; PS1 → a → b):
| Góc | PS1 | a | b |
|---|---|---|---|
| từ `Start_gate` nhìn cổng (`start`) | 351 lần vẽ, 12,5 k prim | 323, 22,9 k | 320, 28,6 k |
| cuối đường vào sân (`approach`) | 382, 14,5 k | 353, 24,9 k | 350, 30,6 k |
| biển rơi nửa, đèn pin (`sign_torch`) | 448, 13,3 k | 418, 27,0 k | 416, 39,7 k |
| sát trụ tây, đèn pin | 423, 12,2 k | 398, 29,6 k | 395, 41,4 k |
| chốt bảo vệ, đèn pin (`booth_torch`) | 43, 2,1 k | 78, 13,5 k | 72, 16,7 k |
| qua cửa sổ chốt | 17, 0,2 k | 37, 9,8 k | 34, 13,3 k |
| tường phía chốt, nhìn rộng (`wall_east`) | 4.439, 1.483 k | 4.406, 1.494 k | 4.403, 1.500 k |
| nhìn qua cổng ra ngoài | 332, 10,6 k | 306, 19,9 k | 303, 25,7 k |
Phần lớn góc ít lần vẽ hơn PS1 (21 song cổng, 9 vết sẹo biển, 21 nhánh vết nứt PS1 mỗi cái một lần vẽ). Chỉ góc nhìn chốt
tăng khoảng 20–35 lần vẽ (chốt và đồ bên trong mỗi thứ khoảng 10 vật liệu): lượt 2 gộp đồ trong chốt về một atlas. Bộ nhớ
hình chương 3 khi đã nạp cả hai bộ phương án: 1.291…1.294 MB. Không đo FPS (D-179).

### Ghi chú
- Chữ trên biển là chữ mẫu: "TRƯỜNG ĐẠI HỌC", phần tên trường đã bong chỉ còn vết keo (STORY: trường không tên). Chữ nằm
  trong texture/mô hình (như bảng giá nhà ăn), không qua `strings.csv`.
- Trụ tây nghiêng 7° như khối va chạm; chân trụ chôn 0,3 m để góc đông (khối va chạm hở 11 cm) chạm đất.
- Biển (SA, SB) và cánh cổng: phần thấp dưới 2,3 m nằm trong bề dày 0,18 m của khối va chạm `Gate/Gate`; đầu đông của biển
  thấp nhất khoảng 2,1 m, tựa trước cổng.
- Đồ trong chốt `visibility_range_end = 30 m`, không đổ bóng (đặt ở `capture_wave5.gd`; lượt 2 đặt trong scene).
- `barrier.glb` thu chân vào 3 cm (cho vừa khối va chạm 0,5 m) sau khi chụp ảnh; ảnh là bản chân rộng hơn 3 cm.
