# Đợt 9 (T-266): phòng 407 ở chương 4 và phòng bệnh của đoạn kết

## Lượt 2 (20–21/11/2026, D-187): cả hai khu vào game
**Phòng 407 (chương 4, nhánh `Room407` của `ch4_anchors.tscn`).** Hình PS1 chỉ ẩn (`visible = false`), node giữ nguyên; hình mới
ở node con `Real`. Phần ngoài nhánh trùng main từng dòng (test so md5).
- **Vạt V2b** ba giường (`Slat<n>/Hinge/Real` = `slat_bed1/2/4.glb`): 9 tấm 14,5 cm, khe 1,6 cm, hai thanh dọc, rộng 0,72 m, bản lề
  cách mép tường 2 cm; mặt dưới mỗi giường một texture mực loang đúng mảnh phiếu UI (`W9SlatUnder1/2/4`). Góc lật riêng trong
  `slat_visual.gd` (`ANGLES`): giường 1 và 4 70°, giường 2 62° (đỉnh vạt dưới mặt dưới tầng trên 1,075 m). Vạt lật trễ 0,08 s,
  quay 0,42 s (xong ở 0,5 s), để đồ giường ra khỏi lòng giường trước khi tấm ván quét lên.
- **N2 (không va chạm)**: ba món Tripo của mỗi giường (`furnished_prop`; ba món của Phúc nằm dưới `Anchors/PhucMattress/Pivot`)
  bay theo `fall_keys()` trong 0,55 s, nằm ở `LANDING`, trả về chỗ cũ khi `set_flipped(false)` và khi thoát (`_exit_tree`).
  Sàn trước giường tầng A chỉ rộng 1,36 m (giường x 1,10 → chiếu x 2,49; ổ cắm nối dài x 1,13–1,55, z −2,40…−2,29; bàn học
  z −4,23): chỉ đủ một tấm nệm. Nên:

  | Giường | Nệm (gốc x; z, xoay) | Chăn | Gối |
  |---|---|---|---|
  | 1 Phúc (tầng trên A) | (2,025; −3,2), 2°: trước giường tầng A | trên nệm Phúc | trên nệm Phúc |
  | 2 Việt (tầng dưới A) | (3,55; −1,12), 92°: trước đầu chiếu, cách cung mở cửa 0,17 m | trên nệm Việt | sàn (4,78; −1,1) |
  | 4 Đạt (tầng trên B) | (6,43; −2,62), −2°: trước giường tầng B | trên nệm Đạt | trên nệm Đạt |

  Toạ độ phòng 407 gốc (`Floor4/Room407`); khe nhỏ nhất tới vật khác 2,8 cm, giữa đồ hai giường từ 4 cm.
  Đường bay: **tầng trên** dịch 3,5 cm về phía tường, nhấc lên (đáy 1,53 m, trên đầu cột 1,50), trượt ra tới khi giữa món đồ ở
  mép thành giường, chúc xuống 80° qua mép (treo trong 0,2 m ngoài thành giường), rơi đứng xuống sàn rồi đổ ra chỗ nằm; chăn,
  gối nằm trên nệm đi cao hơn đúng độ dày nệm. **Tầng dưới**: nệm nghiêng 18,8° (đầu chân lên) để lọt giữa hai cột cách nhau
  1,80 m (nệm dài 1,90 m), trượt ra dưới thanh tầng trên, rồi đi thấp (đáy tối đa 0,2 m) tới chỗ nằm.
  **Giới hạn ghi thật:** nệm Tripo rộng 0,80 m nằm sẵn dưới cả hai thanh chắn tầng trên (khe giữa hai thanh 0,70 m) và lấn
  5 cm vào cột ở hai đầu ngay lúc nằm yên. Không có đường nhấc cứng nào sạch hoàn toàn: khi nhấc, mép phía tường của nệm tầng
  trên đi qua thanh chắn phía tường (bị chính tấm nệm che, người chơi đứng phía phòng không thấy); nệm tầng dưới lướt qua
  8 mm mặt trong hai cột. Test kiểm thanh và cột phía phòng bằng hộp xoay (SAT) ở 201 mốc, và mọi chỗ mắt dùng tay phía phòng.
- **Cửa chớp thông gió và nắp trần H1 (C2)**: `room_407.tscn` (ở `scenes/levels/floor4/`) thêm node `Wave9Fixtures`
  (`vent.glb`, `hatch.glb`), `room407.gd` thêm `"Wave9Fixtures"` vào `KEEP_PS1` (đường (a) của D-187). Có ở cả bốn chương, chỉ là
  hình (không va chạm, không lời nhắc). Ở chương 3–4, `CeilingPanel`, `VentFrame`, `VentSlat0…5` của `ch4_anchors` ẩn.
  Nắp hở quạt trần hơn 10 cm cả khi mở.
- **Phản hồi khi tìm xong** (`Room407/SearchFeedback`, `search_feedback.gd`): nắp (`HatchLeaf`, gốc ở bản lề) hé 28°, chớp
  (`VentGrille`, gốc ở vít góc trên phía bắc) treo lệch 26°, chân rời tường 3 cm (lượt 1 xoay ngược trọng lực). **Chỗ tìm giả
  (`empty_result = true`) không phát `searched`** (`search_spot.gd._on_completed`), nên script nghe cả `searched` lẫn
  `EventBus.interacted` (do `HoldInteractable._finish()` phát cho mọi lần giữ E xong) của `Search<spot>` dưới marker. Trả lại khi thoát.
- **Cửa bị phá** (`door407_proxy.gd`): ba lớp `Damage/*/Real` đặt đúng transform của `Door407/Pivot/RoomDoor` (cánh Tripo
  người chơi thấy); từ 60 % ẩn cả `RoomDoor` và `Pivot/Leaf`, các vết nứt quanh lỗ (`CracksInner`) nhường cho mép lỗ; trả lại khi
  thoát. Tay xác: tay áo hoodie xám rách thò vào phòng 9 cm, da tái lốm đốm có UV, tối hơn lượt 1; phía hành lang cánh tay vươn
  lên vai ở 1,3 m. Kiểm từ hành lang với bốn xác thật (tự đi tới cửa sau 17,5 s, dừng ở 0,75–1,26 m từ giữa cửa): xác che kín
  lỗ và tay, không thấy tay lơ lửng hay cánh hở.

**Phòng bệnh (`hospital_room.tscn/.gd`).** Mọi lưới PS1 ẩn, node giữ; hình mới dưới `Real` (vỏ, tường chân giường, rèm),
`Bed_*/Real` (giường inox có khung kẹp thẻ), `Bed_*/Patient/Real` (Trung T1; Nhật, Ngư dưới chăn), `Bed_Nhat|Ngu/Empty` (chăn gấp
của kết một mình; `set_companions_visible` bật ngược với `Patient`), `IV_*/Real`. `Camera_Wake` ngước 11° (K2), vị trí và FOV
giữ. `Nurse1/2` giữ ở (∓0,72; 0; 1,9), sau rèm (z 1,5); hai bóng trên rèm đúng chỗ đó. Không thêm đèn.
**Thẻ tên** (ngoại lệ UI, `ui/ch4/bed_card.tscn`, `scripts/ui/ch4_bed_card.gd`): giấy chịu sáng (`Paper` không còn unshaded,
màu 0,70), thêm `NameBack`, `DetailsBack` (cùng chữ, quay về đầu giường, không ngược), các nhãn `double_sided = false`; API giữ.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_textures.py      # 11 texture (--pilot: thêm ba kiểu chữ của lượt 1)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave9/build_wave9.py   # [-- slats vent hatch cracks door hand shell footwall bed iv patients curtain]
python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_materials.py     # vật liệu W9*, .import (nén VRAM)
godot --headless --path game --import   # hai lần; rồi git checkout -- game/default_bus_layout.tres
# ảnh: chép capture_wave9.gd + capture_wave9_r2.gd vào game/_probe_tmp/, $env:T266_PARTS = "r407,crowd,ch1,ward", cửa sổ thường
python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_r2_sheets.py     # compare_*.jpg, overview.jpg
pwsh tools/test.ps1 -Filter t266
```

### Glb trong game (gốc ở node treo)
| File | Treo ở | Tam giác | Vật liệu |
|---|---|---|---|
| `slat_bed1/2/4.glb` | `Slat<n>/Hinge/Real` | 336 | W1WoodPale, W9SlatUnder<n>, W9RawWood, W1Steel |
| `vent.glb` (VentBack, VentGrille) | `Floor4/Room407/Wave9Fixtures/Vent` | 144 | W9Soot, W9VentPaint, W9Screen, W1Steel |
| `hatch.glb` (HatchFrame, HatchLeaf) | `.../Wave9Fixtures/Hatch` | 134 | W9Void, W9HatchPaint, W1Steel |
| `door_cracks.glb`, `door_broken.glb`, `zombie_hand.glb` | `Door/Damage/Cracks|Hole|Hand/Real` | 18; 2.356; 628 | W9Cracks; W9DoorRoom, W9RawWood; W9Skin, W9Hoodie |
| `ward_shell.glb`, `footwall.glb`, `curtain_y1.glb` | `HospitalRoom/Real` | 726; 8; 1.324 | như lượt 1 |
| `ward_bed.glb` (thêm `CardHolder`) | `Bed_*/Real` | 872 | W6Stainless, W9Laminate, W1Steel, W1Iron, W9Vinyl, W9Sheet |
| `patient_t1.glb` / `patient_side.glb` | `Bed_Trung|Nhat|Ngu/Patient/Real` | 2.266 / 2.168 | W9Blanket, W9Bandage, W9SkinPatient, W9IVBag / W9Hair |
| `bed_empty.glb` | `Bed_Nhat|Ngu/Empty` | 132 | W9Blanket |
| `iv.glb` | `IV_*/Real` | 352 | W6Stainless, W1Iron, W9IVBag |

Đếm như test T-196 (gồm cả lưới PS1 ẩn): mỗi `Slat` 362, `Door` 3.206 (ngưỡng nâng 500 → 3.600), `Bed_Trung` 3.270, `Bed_Nhat`,
`Bed_Ngu` 3.304 (ngưỡng nâng 1.500 → 4.000), cả phòng bệnh 13.424. Glb hình mẫu lượt 1 không dùng (V1, V2, V2b của giường 2,
`vent_open`, `hatch_h1*`, `hatch_h2`, `footwall_door`, `bed_rolled`, `patient_t2`) và ba texture chữ khác kiểu đã xoá khỏi game;
`build_wave9_pilot.py` và `make_wave9_textures.py --pilot` dựng lại được.

### Số đo (không đo FPS)
| Chỗ (cùng camera, cùng lượt chạy) | Trước (hình main) | Sau |
|---|---|---|
| Phòng 407 từ cửa, chưa lật, đèn pin | 3.729 / 3.728 lần vẽ | 3.761 / 3.763 (+33) |
| Phòng 407 từ cửa, lật cả ba, cửa 80 % | 3.720 / 3.718 | 3.776 / 3.776 (+57) |
| Phòng bệnh, `Camera_Wake`, kết thật / một mình | 27 / 21 (K1, main, lượt 1) | 42 / 34 (K2) |
| Bộ nhớ hình chương 4 | 1.301 MB (main, lượt 1) | 1.310 MB ở phòng 407, 1.313 MB ở phòng bệnh |

"Trước" của phòng 407 dựng lại hình main ngay trong lượt chụp (hiện PS1, ẩn `Real` và `Wave9Fixtures`, vạt 70°, đồ giường không
động, cánh Tripo không ẩn); đo hai lần liền nhau vì tổng số lần vẽ trôi theo thời gian trong một lượt chạy (bóng, nạp dần).
Ảnh: `../previews/wave9/before_*`, `after_*` (`capture_wave9_r2.gd`, log `survey/capture_r2.txt`), tờ `compare_407_room`,
`compare_407_bedding`, `compare_407_fall`, `compare_407_slats`, `compare_407_spots`, `compare_407_door`, `compare_407_corridor`,
`compare_ch1`, `compare_ward`, `compare_ward_detail`, và `overview.jpg`.

## Lượt 1 (20/11/2026): khảo sát, hình mẫu, phương án
Không sửa cảnh nào (`ch4_anchors.tscn`, `slat_visual.gd`, `door407_proxy.gd`, `hospital_room.tscn/.gd` như main).
`capture_wave9_pilot.gd` gắn glb đợt 9 vào cảnh chương 4 thật lúc chạy, ẩn hình PS1 chúng thay (`visible = false`), rồi chụp.
Ảnh ở `../previews/wave9/`: `survey_*` (main), `pilot_*` (hình mẫu), `options_*.jpg` (tờ phương án), `plan_hospital.jpg`,
`survey_sheet_407.jpg`, `survey_sheet_ward.jpg`.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_textures.py      # 14 texture (chữ vạt, nứt cửa, da, bóng y tá...)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave9/build_wave9_pilot.py   # [-- slats vent hatch cracks door hand shell footwall bed patients curtain]
python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_materials.py     # vật liệu W9*, .import glb và texture (nén VRAM)
godot --headless --path game --import   # hai lần; rồi git checkout -- game/default_bus_layout.tres
python -B art_source/graphics_upgrade/realistic_map/wave9/plan_wave9.py               # previews/wave9/plan_hospital.jpg
python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_sheets.py        # options_*.jpg, survey_sheet_*.jpg
pwsh tools/test.ps1 -Filter t266
```
Khảo sát: chép `survey_wave9.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script (không commit), chạy `--headless`
(→ `survey/survey_wave9.txt`, `room407_bed_props.tsv`, `hospital_nodes.tsv`, `plan_geometry.json`).
Ảnh: chép `capture_wave9.gd` (và `capture_wave9_pilot.gd`) vào `game/_probe_tmp/`, theo Lượt Godot chạy cửa sổ thường.
PowerShell bỏ mất `--` trước tham số người dùng khi gọi qua script: dùng biến môi trường `T266_PARTS` (`s407,ward,ch3,ch1`
hoặc `p407,pward`), `T266_SECTIONS` (`bed,spots,door`), `T266_SLATS` (`v1,v2,v2b`), `T266_VIEWS`. Số lần vẽ ở
`survey/capture_survey.txt`, `survey/capture_pilot.txt` (lượt chụp cuối).

### Glb (hình mẫu, gốc ở node sẽ treo vào)
| File | Treo ở | Tam giác | Vật liệu |
|---|---|---|---|
| `slat_v1_bed2.glb` | `Slat2/Hinge` | 12 | W1WoodPale, W9SlatUnder, W9RawWood |
| `slat_v2_bed2.glb`, `slat_v2b_bed2.glb` | `Slat2/Hinge` | 348 | + W1Steel (đinh) |
| `vent.glb`, `vent_open.glb` | `Room407` | 144 | W9Soot, WRVent, W9Screen, W1Steel |
| `hatch_h1.glb`, `hatch_h1_open.glb` | `Room407` | 134 | W9Void, W9HatchPaint, W1Steel |
| `hatch_h2.glb` | `Room407` | 62 | W9Void, W1Alu, W9Gypsum |
| `door_cracks.glb` (Outer, Inner) | `Damage/Cracks`, ở transform của `RoomDoor` | 18 | W9Cracks |
| `door_broken.glb` | `Damage/Hole`, như trên | 2.356 | W9DoorRoom, W9RawWood |
| `zombie_hand.glb` | `Damage/Hand`, như trên | 444 | W9Skin, CCClothGrey |
| `ward_shell.glb` | `HospitalRoom` | 726 | W9WardFloor/Wall/Dado/Ceiling, W8Skirting, W1Enamel, W2Tube, W9WindowDay, W9MonitorScreen, W9Cabinet… |
| `footwall.glb` / `footwall_door.glb` (Y2) | `HospitalRoom` | 8 / 144 | |
| `ward_bed.glb` | mỗi `Bed_*` | 616 | W6Stainless, W9Laminate, W9Vinyl, W9Sheet, W1Steel, W1Iron |
| `iv.glb` | mỗi `IV_*` | 352 | W6Stainless, W1Iron, W9IVBag |
| `patient_t1.glb` / `patient_t2.glb` | `Bed_Trung/Patient` | 2.030 / 1.872 | W9Blanket, W9Bandage, W9SkinPatient, W9IVBag |
| `patient_side.glb` | `Bed_Nhat/Patient`, `Bed_Ngu/Patient` | 2.168 | W9Blanket, W9Hair, W9SkinPatient |
| `bed_empty.glb` / `bed_rolled.glb` | `Bed_Nhat`, `Bed_Ngu` (kết một mình) | 132 / 164 | |
| `curtain_y1.glb` (Y1) | `HospitalRoom` | 1.324 | W1Alu, W9Curtain, W9CurtainNet, W9Shadow |

Ngưỡng card mục 5 (test `test_t266_pilot.gd` cộng sẵn phần PS1 vẫn đếm): `Slat2` với V2b 374 (< 1.500); `Door` 3.022 (< 4.000);
`Bed_Trung` 2.778, `Bed_Nhat`/`Bed_Ngu` 3.212 (< 8.000); cả phòng bệnh khoảng 13.300 (< 80.000).

### Ghi chú kỹ thuật
- Cánh vỡ: `door_room.glb` nhập vào bị tách rời từng đỉnh (7.157 cạnh hở) nên boolean không cắt được: hàn đỉnh trước
  (`remove_doubles` 0,4 mm), giảm lưới 0,3, boolean EXACT với lưỡi cắt răng cưa; kiểm 0 mặt còn trong lỗ.
- Lỗ đặt cao 0,97 m (không gian `Door407`), dưới tờ nội quy phía hành lang (`Pivot/RulesPaper` ở y 1,39) và cách tay nắm 6 cm.
- Giường 2: vạt PS1 0,86 m quay 70° chạm tầng trên (mặt dưới tầng trên ở y 1,075). Hình mẫu rộng 0,72 m, quay 62°
  (> 1 rad của test), đỉnh ở y 1,03; giường 1, 4 (tầng trên) giữ 70°.
- Vạt nằm trên sàn giát Tripo (đỉnh 0,385), dưới nệm 4,9 cm (0,38…0,429): trước khi lật không thấy chữ.
- Vật liệu phòng bệnh: tường, trần, sàn của thư viện bị làm tối cho ban đêm, nên phòng bệnh có bản riêng sáng hơn
  (`W9Ward*`, cùng texture đã duyệt). Ở độ sáng 1,45 chỉ thẻ tên (UI lane D, trắng) cháy trắng.
