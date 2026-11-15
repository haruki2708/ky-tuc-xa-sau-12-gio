# Đồ hoạ thật đợt 5 — T-262 (D-166, D-176): cổng trường, chốt bảo vệ, tường rào nam, sân cổng, dải A16 đoạn cổng

Card: `docs/tasks/T-262-realistic-graphics-wave5-gate.md` (đọc ở commit `1b63065`). Dựng bằng script Blender, texture vẽ
bằng code (numpy + Pillow). Không Tripo, không extension Blender, không ảnh AI.

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
