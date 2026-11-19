# Đồ hoạ thật đợt 8 — T-265 (D-166): thư viện ba tầng (A20) và dải đất 6 m quanh thư viện

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
python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_textures.py     # 12 texture
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
(124 ảnh, khoảng 45 phút; số lần vẽ ở `survey/capture_wave8.txt`), rồi `python -B .../wave8/make_wave8_sheets.py`.

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
