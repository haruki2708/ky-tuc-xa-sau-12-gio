# Đồ hoạ thật đợt 8 — T-265 (D-166): thư viện ba tầng (A20) và dải đất 6 m quanh thư viện

## Lượt 3 (20/11/2026, D-186): bịt các chỗ còn rơi được của ô cầu thang
Card mục 1 điểm 14. Bốn đoạn lan can có va chạm như lan can mép tây (cột thép dẹt 12 cm một cột, tay vịn gỗ, cao 1,1 m từ
sàn, sâu 8 cm, trên mép sàn): `WellRail_F3S` (tầng 3, mép nam x 78,86…84,89, z 198,92…199), `WellRail_F2SE` (tầng 2, đầu nam
khe đông x 84,05…84,89, z 198,92…199), `WellRail_F2NE`, `WellRail_F3NE` (tầng 2, 3, đầu bắc khe đông x 84,05…84,89,
z 209…209,08). Lối lên nhịp hai ở tầng 2 và đầu trên hai nhịp (x 79…84) để hở.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave8/plan_wave8.py final        # luật bố cục; in khoảng cách nav/link của từng lan can
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave8/build_wave8.py -- stairs
python -B art_source/graphics_upgrade/realistic_map/wave8/patch_wave8.py rails3      # trên cảnh lượt 2: thêm 4 khối WellRail_* dưới Real/Added
python -B art_source/graphics_upgrade/realistic_map/wave8/count_wave8.py
pwsh tools/test.ps1 -Filter t265
```
Ảnh: chép `capture_wave8_r2.gd` và `capture_wave8_r3.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn `capture_wave8_r3.gd`,
theo Lượt Godot `godot --path game --log-file <log> res://_probe_tmp/capture_wave8_r3.tscn` (6 ảnh `r3_*`), rồi
`python -B .../wave8/make_wave8_sheets.py round3` (`r3_well.jpg`).

## Lượt 2 (20/11/2026, D-185): cả thư viện
Lựa chọn ở card mục 1 (bộ c của lượt 1 cộng các điểm của integrator). Cảnh đã vá: `library.tscn` (667 hình PS1 ẩn; `Real`;
`Real/Added`; `BackDoor/Hinge/LeafReal`), `shells.tscn` (ẩn `LibraryBand0…2/Mesh`), `campus.tscn` (`StripLibrary`).
`props.tscn` không đổi (vùng không có mảnh xác; hai đống gạch và giấy vụn giữ nguyên).

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave8/plan_wave8.py final        # kiểm bố cục đồ thêm (mục 4), final_floor1..3.jpg
python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_textures.py curtain8
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave8/build_wave8.py   # [-- shell stairs shelves fill facade ...]
python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_materials.py    # rồi git checkout các .import của glb không đổi (chỉ đảo thứ tự)
godot --headless --path game --import   # hai lần
python -B art_source/graphics_upgrade/realistic_map/wave8/patch_wave8.py library shells campus   # trên cảnh của main, mỗi bước một lần
python -B art_source/graphics_upgrade/realistic_map/wave8/count_wave8.py             # survey/round2_counts.json
pwsh tools/test.ps1 -Filter t265
```
Ảnh: chép `capture_wave8_r2.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script, theo Lượt Godot
`godot --path game --log-file <log> res://_probe_tmp/capture_wave8_r2.tscn [-- --parts=ch4,ch3] [--views=...]` (88 ảnh,
khoảng 1 phút khi cảnh đã import), rồi `python -B .../wave8/make_wave8_sheets.py round2` (`r2_*.jpg`, `overview.jpg`).

- `wave8_layout.py`: `FINAL` (109 món thêm: kệ sát tường, kệ thấp dưới cửa sổ, dãy kệ hai mặt trong bốn khoang, đồ rời),
  `RAILS` (lan can mép tây ô cầu thang tầng 2, 3; lượt 3 thêm bốn đoạn), `SIGHTLINES`, `SCARE_POINTS`/`SCARE_SHELVES`, `ps1_solids`. Danh sách đầy
  đủ: `survey/final_layout.md`.
- `build_wave8.py`: 21 glb (xem docstring). Sách: mỗi cụm kệ một lưới gần (`Books_*`, một mặt gáy mỗi cuốn, bìa chỉ ở chỗ
  hở) và một lưới xa (`BooksFar_*`, một khối mỗi đợt). Rèm cửa sổ (`curtain()`) chung cho mặt trong và mặt ngoài.
- `game/scenes/levels/library/library_real.gd`: khoảng vẽ sách gần/xa (14 m), đồ của từng tầng chỉ vẽ khi camera ở tầng đó
  hoặc cách một tầng (ngoài nhà: tầng 1 trong 12 m), vỏ trong, cầu thang, chướng ngại trong 25 m quanh tường, song sắt 80 m,
  nắp rãnh 60 m, khung cửa sổ và bồn nước 150 m; đồ nhỏ không đổ bóng.
- Vật liệu mới: `W8ShelfBack` (lưng kệ tôn sơn phẳng), `W8Curtain*` (rèm sau kính tối nhìn từ ngoài, texture `curtain8.png`),
  `W8MapGlass` (kính bản đồ mờ, ít loá).
- Lượt 2 xoá các glb góc mẫu không chọn (`*_q2`, `facade_e1|e2`, `fill_m2|m3`, `books_*`, `shelf_*`, `table_*`, `map_drawn`,
  `mess`, `rule_book`) và `test_t265_pilot.gd`; `build_wave8_pilot.py` giữ làm nguồn của lượt 1.

Card: `docs/tasks/T-265-realistic-graphics-wave8-library.md`. Dựng bằng script Blender (bmesh, không extension), texture vẽ
bằng code (numpy + Pillow). Không Tripo, không ảnh AI. Toạ độ thế giới; `library.tscn` đặt gốc ở (45; −9,9; 195).

## Lượt 1 (19/11/2026): khảo sát, góc mẫu, phương án — chờ chủ dự án chọn
Không sửa cảnh nào (`library.tscn`, `shells.tscn`, `campus.tscn`, `props.tscn` như main). `capture_wave8.gd` gắn góc mẫu vào
cảnh chương 4 thật lúc chạy: ẩn 670 lưới PS1 của thư viện và `LibraryBand0…2` (`visible = false`; va chạm, node,
navigation giữ; mô hình thanh sắt giữ), treo glb dưới `Library/PilotWave8` (kệ, sách ở từng node `Shelf*`, bàn ở từng
`ReadingTable*`, cánh cửa sau mới dưới `BackDoor/Hinge` nên `set_open` vẫn quay nó), rồi chụp.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave8/list_wave8_zone.py          # zone8.json (vùng ngoài nhà, đếm đầu xác)
python -B art_source/graphics_upgrade/realistic_map/wave8/plan_wave8.py              # plan_floor1..3.jpg, options_fill_m*_floor1/3.jpg
python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_textures.py     # 11 texture
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave8/build_wave8_pilot.py   # [-- shell stairs counter ...]
python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_materials.py    # .tres W8*, .import glb và texture (nén VRAM)
godot --headless --path game --import   # lần đầu chạy hai lần; rồi git checkout -- game/default_bus_layout.tres
python -B art_source/graphics_upgrade/realistic_map/wave8/count_wave8.py             # survey/pilot_counts.json
pwsh tools/test.ps1 -Filter t265
```
Khảo sát: `survey_wave8.gd` (→ `survey/library_nodes.tsv`, `library_bands.tsv`, `zone8_nodes.tsv`, `plan_geometry.json`),
`walk_wave8.gd` (→ `survey/walk_wave8.txt`: thân người chơi thật của chương 4, navmesh, tầm nhìn). Chép vào `game/_probe_tmp/`
cùng một scene gốc gắn script (không commit), chạy `--headless`.
Ảnh: chép `capture_wave8.gd` như trên rồi theo Lượt Godot
`godot --path game res://_probe_tmp/capture_wave8.tscn -- [--configs=before,a,b,c] [--views=...] [--parts=main,plan,far,west]`
(126 ảnh, khoảng 45 phút; số lần vẽ ở `survey/capture_wave8.txt`), rồi `python -B .../wave8/make_wave8_sheets.py`.

- `wave8_layout.py`: số đo lấy từ main (tường, cửa, cửa sổ, đèn, cầu thang, kệ, bàn, quầy, thanh sắt, bản đồ, chướng ngại,
  anchor), toạ độ mặt nạ UV2, cỡ lặp texture (`SIZES`), bố cục mức đầy M2/M3 (`FILL`).
- `build_wave8_pilot.py`: 27 glb (xem docstring). Mảnh "local" (kệ, sách, bàn, sổ quy tắc, cánh cửa sau) có gốc tại node
  chúng được treo vào.
- `make_wave8_materials.py`: vật liệu `W8*` (dùng lại sơn, gạch, tấm trần, đá mài, bê tông, gỗ, mặt đất của các đợt 1–7);
  `.import` mọi texture: `compress/mode=2`, normal thêm `compress/normal_map=1`.

### Cấu hình chụp
- **a**: F1 (ceramic kem, tường vàng nhạt, chân tường gạch), C2 (trần tấm 60 × 60), Q1 (quầy gỗ dán mặt kính), bản đồ in, kệ
  thép đầy, T1 (bàn gỗ dài), cửa sổ kính tối + song + rèm, E1 (vàng + lam bê tông, phòng giả), M1, gọn.
- **b**: F2 (đá mài, vôi trắng ngà, chân tường sơn xanh), C1 (bê tông trần, dầm, quạt), Q2 (quầy xây ốp gạch), bản đồ vẽ tay,
  kệ gỗ vơi, T2 (vách nỉ, đèn bàn), cửa chớp gỗ, E2 (đá rửa + biển THƯ VIỆN, kính tối), M1, bừa.
- **c** (đề xuất): a + M2 + tầng 3 là kho (sàn xi măng, kệ gỗ cũ, đợt đổ nghiêng) + bừa.
- M2, M3 thêm vào bộ a ở `options_fill_*`; ảnh nhìn từ trên `options_top_*` (trần, tầng trên, mái ẩn; thêm một đèn chiếu từ
  trên chỉ cho ảnh sơ đồ).

### Ghi chú
- Mặt quầy mới cao 0,868 m: đáy ống thanh sắt ở 0,8865 m (khe 1,85 cm ≤ 2 cm), đỉnh khối va chạm `Counter/Top` 0,84 m nằm
  dưới mặt mới 2,8 cm (≤ 3 cm). PS1 hiện để thanh sắt lơ lửng 4,65 cm trên mặt quầy.
- Cánh cửa sau mới dày 5 cm (PS1 10 cm): mở 90° thì mép bản lề nằm ở x 64,005…64,055, không cắm vào má cửa (x 64).
- Bản đồ: năm khối nhà đúng chỗ khối PS1, hai vòng đỏ vẽ đúng đường `FadedCircle0_*`/`1_*`; thêm giảng đường, nhà thi đấu,
  cổng trường cho khớp tài liệu `ch4_map`. Lượt 1 ẩn các vòng PS1 (hình mới có vòng trong ảnh).
- Độ sáng: ảnh đầu tiên với màu như nhà ăn sáng gấp đôi PS1 (xám trung bình 130–145 so với 64–83) vì ánh sáng môi trường 0,65 của
  cảnh; màu trong nhà của W8 hạ khoảng một phần ba (vẫn là các màu đã duyệt). Ánh sáng không đổi.
- Cửa sổ: tường vẫn đặc; kính và phòng giả nằm trong bề dày tường (mặt ngoài 0,11 m, mặt trong 0,11 m).
