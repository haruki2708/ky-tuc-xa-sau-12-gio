# Đồ hoạ thật đợt 4 — T-261 (D-166, D-176): sân vận động, khán đài, dải nối vườn → sân

Card: `docs/tasks/T-261-realistic-graphics-wave4-stadium.md` (đọc ở commit `7b8431f`). Dựng bằng script Blender, texture vẽ
bằng code (numpy + Pillow). Không Tripo, không extension Blender, không ảnh AI.

## Lượt 1 (15/11/2026): khảo sát, góc mẫu, phương án — chờ chủ dự án chọn
`stadium.tscn`, `campus.tscn`, `props.tscn` **chưa sửa**: `capture_wave4.gd` gắn góc mẫu vào cảnh chương 3 thật lúc chạy,
ẩn hình PS1 tương ứng (`visible = false`, hoặc thu cỡ bản MultiMesh của `Stand_*` về 0), rồi chụp.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave4/make_wave4_textures.py     # 12 texture (khoảng 20 giây)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave4/build_stadium_pilot.py   # [-- field goal stand seats pole_steel pole_concrete fence_b40 fence_bars pillars]
python -B art_source/graphics_upgrade/realistic_map/wave4/make_wave4_materials.py    # .tres, shader, .import (nén VRAM)
godot --headless --path game --import   # lần đầu chạy hai lần
python -B art_source/graphics_upgrade/realistic_map/wave4/list_a16_box.py            # a16_box_nodes.json
pwsh tools/test.ps1 -Filter t261
```
Ảnh: chép `capture_wave4.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script đó (không commit), rồi theo Lượt Godot
`godot --path game res://_probe_tmp/capture_wave4.tscn -- --configs=before,a,b,c` (83 ảnh, khoảng 3 phút), sau đó
`python -B art_source/graphics_upgrade/realistic_map/wave4/make_wave4_sheets.py`.

- `stadium_layout.py`: số đo của sân lấy từ `stadium.tscn` trên main (va chạm, dữ liệu MultiMesh `Stand_*`, đỉnh dải
  `RunningSurface`/`Lane*`), dùng chung cho texture, Blender và bảng ảnh; hộp A16 của đợt này.
- `make_wave4_textures.py`: đường chạy cao su đỏ (R1) và xỉ than (R2), cỏ nhân tạo (C2), tôn mái, lưới B40, lưới khung
  thành, mặt nạ sân (`mask_field.png`: đất trọc, ướt, cỏ úa, cỏ nhân tạo mòn) và mặt nạ khán đài (`mask_stand.png`).
  Cỏ thật (C1) và đất dùng lại texture cỏ, đất của đợt 3.
- `build_stadium_pilot.py`: `field.glb` (đường chạy 7 làn, bó vỉa, sân trong, nền quanh đường chạy, vạch đích và vạch xuất
  phát), `goal.glb`, `stand.glb` (cả khán đài chính 80 m: bậc, lối lên chia nửa bậc, tường trước, đầu hồi, lan can sau,
  bản sàn nghiêng, dầm xiên, cột, mái tôn trên vì kèo thép, nền gầm khán đài, ống sắt chỗ B03), `stand_seats.glb` (S2),
  `pole_steel.glb`/`pole_concrete.glb` (L1/L2, 6 đèn), `fence_b40.glb`/`fence_bars.glb` (H1/H2: rào phía tây và tây bắc,
  cánh cổng), `gate_pillars.glb` (trụ cổng tây và tây bắc).
- `make_wave4_materials.py`: vật liệu `W4*`, shader `track.gdshader` (vạch làn vẽ theo UV, khử răng cưa, mòn theo nhiễu),
  `pitch.gdshader` (cỏ thật/nhân tạo, vạch sân đủ bộ, mòn), `card.gdshader` (lưới lặp có alpha cắt); `.import` của mọi
  texture mới viết trước khi Godot nhập: `compress/mode=2`, normal thêm `compress/normal_map=1`, mipmap bật.
- `list_a16_box.py` → `a16_box_nodes.json`: node và bản MultiMesh A16 trong hộp đã chốt.
- `capture_wave4.gd`, `make_wave4_sheets.py`: ảnh và bảng phương án.

### Hợp đồng giữ nguyên (lượt 2 so dấu vân tay với main)
Va chạm: `TrackBounds`, `MainBleachers` (`Slab`, `FrontWall0…3`, `RearParapet`, `EndWest`, `EndEast`), `SecondaryBleachers`
(như trên, meta `surface = concrete`), `RoofColumn0…8`, `Fence0…11`, `GatePost*` (12), `Pole0…3`. `Floodlights` và
`Light0…3` (vị trí, năng lượng 12, màu, tầm 145 m, không bóng; mặc định ẩn). Trong `campus.tscn`: `Anchors/Start_stadium`,
`ZombieSpawns/Stadium/S01…S06`, `ZombieIdle/Stadium/I01…I06`, `BarSpawns/B02`, `B03`, `Clues/SirenSpot`, `Zones/Stadium`,
`Zones/Bleachers`, navigation. Hình mới chỉ nằm trong khối va chạm cũ hoặc cao trên đầu người (test
`test_t261_stadium_pilot`).

### Hộp A16 đợt này: x 50…110, z −11…176 (mặt đất, y −10,5…−6)
Đi thử tuyến bằng thân người chơi thật và navmesh (`_probe_tmp/route_probe.gd`, không commit):
- đồng đội: `P14_Wait_garden` (22; 26) → `P15` (48; 28) → `P16` (80; 28) → `P17` (80; 166) → cổng tây (115; 166), đi giữa
  `Road/WestBranch` (x 80) rồi `Road/StadiumWestAccess`;
- navmesh `Start_garden` → `Start_stadium` và xác sống vườn → sân: theo z 8…18 ra tới x 96, rồi dải đất trống x 96…108
  lên z 162 vào cổng tây; quay về cổng chính (`P24`, `P25`) đi lại `WestBranch`;
- bot (`tools/ch3-profile.json`): như đồng đội tới (80; 166), rồi vòng bắc (80; 226) → (149; 220) → cổng tây bắc.
Hộp phủ tuyến đồng đội và dải xác sống; mép nam z −11 là mép bắc của `Road/Avenue` (đường ra cổng, không đụng). Đoạn
bot vòng bắc ngoài sân (x 80…143, z 176…226) nằm ngoài hộp; nền gầm và sau khán đài (x 140…246, z 212,6…234: B02, B03)
là phần của khán đài (A13). Trong hộp: `Road/WestBranch/Mesh`, `Road/StadiumWestAccess/Mesh` (ẩn cả hai); nền mới phủ lên
8 ô `Ground/Tile_20|70_-10|40|90|140` (giữ va chạm); trong `props.tscn` chỉ 96 mẩu giấy rác trên đất (`P_paper_box_*`,
`D_paper_quad_*`) và hai đống gạch vỡ ở (87; 151) và (99; 173) (22 khối `P_concrete_box_p2_p3|p2_p4`, 6 ống
`P_iron_cylinder_p2_p3|p2_p4`). Ghế đá, thùng rác, xe đạp, ô tô, cọc, cột đèn, cây, mảnh xác, vệt kéo sẫm giữ nguyên.

### Phương án (ảnh ở `../previews/wave4/`)
| Mã | Là gì | Tam giác | Vật liệu |
|---|---|---|---|
| R1 | Đường chạy cao su đỏ bạc màu, nứt, vá; vạch sơn mòn khoảng 1/3 | 1.690 (cả sân: đường chạy, bó vỉa, sân trong, nền, vạch) | `W4TrackRubber` (+ `W4Apron`, `W4PitchGrass`, `W4Paint`) |
| R2 | Đường chạy xỉ than, vạch vôi mòn gần nửa | như R1 | `W4TrackCinder` |
| C1 | Cỏ thật úa loang lổ, trọc ở cầu môn, giữa sân, dọc biên | (trong 1.690) | `W4PitchGrass` (cỏ, đất đợt 3) |
| C2 | Cỏ nhân tạo cũ, sọc 5 m, lộ hạt cao su ở cầu môn | (trong 1.690) | `W4Turf` |
| — | Khung thành thép tròn sơn trắng, lưới rách | 292 mỗi khung | `W4Paint`, `W3LampPaint`, `W4Net` |
| S1 | Khán đài chính bậc bê tông trần, vết nước, rêu chân bậc; mái tôn kẽm rỉ trên vì kèo thép sơn xanh, thiếu 3 tấm | 5.122 | `W4StandConcrete`, `W1Concrete`, `W4SteelFrame`, `W4RoofSheet`, `W4Apron`, `W1Iron` |
| S2 | S1 thêm 2.160 ghế nhựa đúc (xanh bạc màu; đỏ để so) | + 69.120 | + `W4Seat` (`W4SeatRed`) |
| L1 | Cột đèn pha thép côn mạ kẽm 18 m, bậc leo, hộp điện, khung 6 đèn | 822 mỗi cột | `W4PoleSteel`, `W4FloodBody`, `W4FloodGlass`, `W1Concrete` |
| L2 | Cột bê tông ly tâm, cùng khung đèn | 730 mỗi cột | như L1 |
| H1 | Rào lưới B40 trên cột ống mạ kẽm 1,3 m, cánh cổng khung ống | 2.000 (120 m rào + 4 cánh) | `W4PoleSteel`, `W4Chainlink` |
| H2 | Rào song sắt sơn xanh 1,3 m, cánh cổng song sắt | 9.384 (như trên) | `W3LampPaint` |
| — | Trụ cổng gạch trát quét vôi (như viền bồn K1) | 56 mỗi trụ | `W4Pillar` |
PS1 cả sân: 8.340 tam giác, 38 vật liệu. Góc mẫu phương án a (R1 C1 S1 L1 H1, cả khán đài, 2 khung thành, 4 cột đèn):
12.908 tam giác; phương án b (R2 C2 S2 L2 H2): 89.044.

Số lần vẽ và bộ nhớ hình (chương 3, cùng camera, đèn pha tắt; bật không đổi số lần vẽ vì đèn không có bóng):
| Góc | PS1 | a | b |
|---|---|---|---|
| cổng tây, từ ngoài (`west_gate`) | 628 lần vẽ, 21,0 k prim | 606, 31,4 k | 606, 107,7 k |
| trong cổng tây (`gate_in`) | 139, 10,2 k | 126, 20,5 k | 126, 96,8 k |
| khán đài từ mép sân (`stand_front`) | 70, 7,1 k | 66, 14,6 k | 66, 91,1 k |
| hàng cao nhất nhìn xuống (`stand_top`) | 5.467, 1.458 k | 5.450, 1.467 k | 5.450, 1.544 k |
| gầm khán đài (`under_stand`) | 6.205, 1.489 k | 6.185, 1.498 k | 6.185, 1.575 k |
| bộ nhớ hình | 1.283 MB | 1.286 MB | 1.288 MB |
Hai góc trên khán đài nhìn thấy gần cả khu (khoảng 1,46 triệu prim có sẵn ở PS1). Không đo FPS (card mục 5).

### Ghi chú
- Ghế S2 không có va chạm, như dải ghế PS1: người chơi lên bậc sẽ đi xuyên ghế. Đổi va chạm không thuộc phạm vi.
- Rào H1/H2 cao đúng 1,3 m như khối va chạm cũ; cánh cổng mở gập sát rào phía ngoài 0,14 m nên không chắn lối.
- Đèn pha: 4 đèn giữ nguyên, ở xa 60 m chỉ sáng nhẹ; khác biệt chính là kính chao phát sáng khi `Floodlights` hiện.
- Hai vạch xuất phát PS1 (`StartLane5`, `StartLane6`) nằm ngoài đường chạy; bản mới đặt vạch giữa từng làn (ảnh chụp
  trước lần sửa này, vạch ở đoạn thẳng phía nam không có trong khung hình nào).
- Đồ rải trên sân (rào vượt, ghế, giấy, chai) nằm ở `props.tscn` (`Campus/Props`), không ở `Stand_*`.
