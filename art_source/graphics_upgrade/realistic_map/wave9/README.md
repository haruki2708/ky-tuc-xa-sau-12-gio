# Đợt 9 (T-266): phòng 407 ở chương 4 và phòng bệnh của đoạn kết

## Lượt 1 (20/11/2026): khảo sát, hình mẫu, phương án — chờ chủ dự án chọn
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
