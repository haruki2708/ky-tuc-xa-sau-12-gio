# Đồ hoạ thật đợt 7 — T-264 (D-166): nhà nền, mặt ngoài nhà B, mặt đất, đường, cây, đèn, hàng rào còn lại

Card: `docs/tasks/T-264-realistic-graphics-wave7-shells-ground.md`. Ba lượt: lượt 1 khảo sát và góc mẫu, lượt 2 các nhà
(D-182), lượt 3 mặt đất. Dựng bằng script Blender, texture vẽ bằng code. Không Tripo, không extension Blender, không ảnh AI.

## Lượt 1 (16/11/2026): khảo sát, góc mẫu, phương án — chờ chủ dự án chọn
Chưa scene nào đổi: `capture_wave7.gd` gắn góc mẫu vào chương 3 thật lúc chạy, ẩn hình PS1 tương ứng (101 node và 18 bản
MultiMesh cây, đèn; va chạm giữ), rồi chụp.

```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave7/list_a16_rest.py          # a16_rest.json (hộp A16 còn lại, đồ rải, đầu xác)
python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_textures.py     # lá, vỏ cây, atlas phòng giả, mặt nạ, vạch sơn
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave7/build_wave7_pilot.py   # [-- bldga_wall ...]
python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_materials.py    # .tres W7*, .import glb và texture (nén VRAM)
godot --headless --path game --import   # lần đầu chạy hai lần
pwsh tools/test.ps1 -Filter t264
```
Khảo sát (`survey_wave7.gd` → `survey/*.tsv`), đi thử (`walk_wave7.gd`), ảnh (`capture_wave7.gd`): chép vào
`game/_probe_tmp/` cùng một scene gốc gắn script (không commit), chạy theo Lượt Godot (khảo sát, đi thử `--headless`); rồi
`python -B .../wave7/make_wave7_sheets.py` (bảng `options_*.jpg`, `wide_views.jpg`).

- `wave7_layout.py`: số đo từ main (ba nhà nền, nhà B, đoạn đại lộ mẫu, cây, đèn, ghế, xe máy, hàng rào tây), các vùng (dải đã
  làm, vùng thư viện của đợt 8, phần còn lại), hàng mặt nạ mặt nhà.
- `build_wave7_pilot.py`: 18 glb (xem docstring); mặt nhà dựng theo module lặp nên mỗi phương án là cả mặt nhà.
- `game/assets/models/.../wave7/materials/interior.gdshader`: phòng giả sau ô cửa (interior mapping): một tấm phẳng 0,3 m sau
  kính, shader dò tia trong một phòng sâu 3,2 m (lớp học, sảnh 6 m, nhà thể chất 12 m), mỗi ô một phòng khác (tối hơn, trống);
  không phát sáng, đèn pin rọi vào mới thấy rõ.

### Số tam giác (góc mẫu)
| glb | Tam giác | | glb | Tam giác |
|---|---|---|---|---|
| nhà A kiểu A2 (cả mặt nhà) | 13.998 | | đường nhựa / bê tông tấm (64 m) | 1.576 / 1.602 |
| nhà A kiểu A1 | 30.610 | | lề cỏ / lát block | 32 / 32 |
| nhà thể chất R1 / R2 | 2.536 / 1.638 | | cây bàng / phượng / xà cừ | 2.421 / 1.939 / 1.731 |
| nhà B (tầng 5–6 trước, mặt sau) | 23.228 | | 3 đèn thép / bê tông | 342 / 330 |
| ghế / xe máy | 72 / 272 | | hàng rào W1 / B40 (30 m) | 2.184 / 398 |
PS1 (PLAN): A17 684, A18 1.224, A19 288, A16 46.181 tam giác.

### Số lần vẽ (chương 3, cùng camera, khối che bật; trước PS1 → góc mẫu)
| Góc | Trước | Sau |
|---|---|---|
| toàn cảnh từ hành lang tầng 4 nhà B | 281 | 238 |
| toàn cảnh giữa vườn | 333 | 318 |
| toàn cảnh từ khán đài | 4.598 | 4.643 |
| nhà A từ vườn / chân nhà / từ hành lang tầng 4 | 189 / 96 / 284 | 146 / 83 / 244 (A1: 147 / 84 / 245) |
| nhà thể chất góc / cửa | 76 / 23 | 71 / 24 (R2: 72 / 25) |
| nhà B tầng 5–6 / mặt sau | 4.186 / 3.718 | 3.782 / 3.778 |
| đại lộ / cây / đèn, ghế | 533 / 4.889 / 3.892 | 539 / 4.926 / 4.076 |
| hàng rào tây | 51 | 56 (B40: 57) |
Hai góc toàn cảnh gần nhà B giảm; khán đài tăng 45 (thấy đoạn đường mẫu với cây, đèn, nhà thể chất). Góc "đèn, ghế" dọc đại lộ
tăng 184: cây và đèn mẫu là node riêng, có đổ bóng; lượt 3 giữ cây theo cụm MultiMesh như nay, tắt bóng phần nhỏ. Bộ nhớ hình
chương 3: 1.307 MB (main, T-263) → 1.321–1.326 MB khi đã nạp mọi glb, texture góc mẫu. Không đo FPS (D-179).

### Khối che (occlusion culling) và độ sâu nội thất
Ba hộp che của core đặc từ 0,5 m sau mặt nhà. Ảnh bật/tắt: `options_occlusion.jpg`. Khối che chỉ bỏ vật khi cả hộp bao nằm
sau nó; phòng thật ở góc mẫu vẫn hiện vì lưới gộp có phần nằm trước mặt hộp, nhưng lượt 2 chia lưới theo phòng thì sẽ mất:
phải thu hộp vào theo độ sâu cần (Handoff card).

## Lượt 2 (16/11/2026): các nhà theo lựa chọn D-182
```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_materials.py    # bỏ W7WallGrey, W7RoadSlab (--options để có lại)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave7/build_wave7.py   # [-- bldga figure lecture gym b_outside bldga_light]
python -B art_source/graphics_upgrade/realistic_map/wave7/patch_wave7.py             # shells, building_b, backdrop (mỗi bước chỉ chạy một lần, từ main)
pwsh tools/test.ps1 -Filter t264
```
Ảnh: chép `capture_wave7_r2.gd` vào `game/_probe_tmp/` cùng scene gốc gắn script, chạy (Lượt Godot; thêm `-- --chapter=1` cho
chương 1), rồi `python -B .../wave7/make_wave7_sheets.py --round2` → `previews/wave7/r2_*.jpg` (tờ: `r2_building_a`,
`r2_lecture_gym`, `r2_building_b`, `r2_torch_occlusion`, `r2_wide_chapter1`). "Trước" là main dựng lại lúc chạy (hiện hình
PS1, ẩn lớp Real, bóng người thứ ba về x 31).

- `build_wave7.py`: sáu glb (docstring). Mọi mặt tiền nằm trong 0,45 m sau mặt nhà (khối che đặc từ 0,5 m); dưới 2 m không gì
  nhô quá 0,15 m khỏi va chạm (mái sảnh, lam, gân từ 2,4 m).
- `patch_wave7.py`: sửa chữ trong `.tscn`; ẩn 164 lưới PS1 của `shells.tscn` (trừ `LibraryBand*` của đợt 8) và 24 của nhà B
  (`UpperFloor5/6`, `UpperWindow*`); thêm `Real` (gắn `game/scenes/levels/campus/shells_real.gd`: kính, phòng giả, song sắt,
  khung, đồ nhỏ, bóng người không đổ bóng; song sắt, đồ nhỏ thôi vẽ ngoài 90 m), `Figure` dưới ba `WindowSilhouette`,
  `WindowSilhouette2` x 31 → 32; nhà A bản nhẹ trong `floor4/garden_backdrop.tscn`.
- Nhà B: mặt sau tầng 4 là của `floor4_rooms.gd` (ban công, có ở chương 3–4) nên không phủ; cửa sổ phòng quản lý (x 2…5,3,
  lối `WindowExit`) để trống; vỏ hai tháp là lớp 4 mm ngoài hộp PS1 (mặt trong của hộp là tường cầu thang).

### Số tam giác (lượt 2)
| glb | Tam giác |
|---|---|
| nhà A (`bldga`) | 12.194 |
| bóng người (`figure`, ×3) | 302 |
| giảng đường (`lecture`) | 10.168 |
| nhà thể chất (`gym`) | 1.740 |
| nhà B mặt ngoài (`b_outside`) | 26.224 |
| nhà A bản nhẹ chương 1–2 (`bldga_light`) | 5.448 |

### Số lần vẽ (chương 3, cùng camera, khối che bật, cùng một lần chạy; main → lượt 2)
| Góc | Trước | Sau |
|---|---|---|
| toàn cảnh từ hành lang tầng 4 nhà B (x 37) | 1.698 | 1.730 |
| toàn cảnh giữa vườn | 333 | 316 |
| toàn cảnh từ khán đài | 4.473 | 4.522 |
| nhà A từ vườn / chân nhà / góc đông / từ hành lang tầng 4 | 189 / 96 / 181 / 1.636 | 141 / 80 / 98 / 1.668 |
| giảng đường cửa / góc | 98 / 111 | 37 / 37 |
| nhà thể chất góc / cửa | 76 / 23 | 49 / 24 |
| nhà B tầng 5–6 từ vườn / nhìn lên / ngang tầm | 3.582 / 2.865 / 3.240 | 3.666 / 2.950 / 3.338 |
| nhà B mặt sau / xa | 3.591 / 4.332 | 3.644 / 4.362 |
| chương 1 từ hành lang tầng 4 (x 37; ảnh đầu của lần chạy, chưa ổn định) | 777 | 460 |
Số đo giữa hai lần chạy lệch tới vài trăm ở các góc gần nhà B (thứ tự chụp, nạp dần); chỉ so trong cùng một lần. Bộ nhớ hình
chương 3: 1.313 MB → 1.318 MB. Không đo FPS (D-179). Bật/tắt khối che cho ảnh như nhau (`r2_torch_occlusion.jpg`).

## Lượt 3 (19/11/2026): mặt đất, đường, cây, đèn, hàng rào, đồ rải (D-182)
```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave7/patch_wave7.py data          # w7_ps1_props.json từ props.tscn của main
python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_textures.py mask_road mask_verge leaf_bang tree_far palette
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave7/build_wave7_rest.py   # [-- ground fences trees lamp props]
python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_materials.py
python -B art_source/graphics_upgrade/realistic_map/wave7/patch_wave7.py props campus  # một lần, trên bản main
python -B art_source/graphics_upgrade/floor4_rooms/make_room_materials.py             # F4Exterior (chỉ giữ file .tres)
pwsh tools/test.ps1 -Filter t264
```
Ảnh: chép `capture_wave7_r3.gd` và `props.tscn` của main (`props_main.tscn`) vào `game/_probe_tmp/`, chạy (thêm
`-- --chapter=4`), rồi `make_wave7_sheets.py --round3` → `r3_roads.jpg`, `r3_trees_props.jpg`, `r3_fences_forecourts.jpg`,
`r3_wide.jpg`, `r3_torch.jpg`, `overview.jpg`.

- `wave7_layout.py`: cao độ (lề −9,925; đường, sân lát −9,92; tile va chạm −9,94), ba đường, ba sân trước, `ground_cells()`
  chia khuôn viên thành ô một loại mặt (bỏ các dải đã làm, vùng đợt 8, các nhà, hộp nhà B), quy tắc loài cây và hướng cần đèn.
- `rest_props.py`: nhận từng vật ghép PS1 (`art_source/campus/scatter.py`) theo mảnh neo (thân ô tô, thân xe máy, yên xe đạp,
  mái che, ...) rồi các mảnh theo cỡ quanh neo; đồ rời (gạch vụn, thép, giấy, kính, dép, giày) theo chỗ nằm. 365/367 bản phần
  còn lại được thay; hai điện thoại (một ô kính đi cặp ô `D_iron`) giữ PS1. Không đụng `D_iron` (vệt nứt, vệt kéo), `D_red`
  (máu), mảnh màu da (đầu xác: phần còn lại không có).
- `build_wave7_rest.py`: `ground.glb`, `fences.glb`, ba `tree_*.glb` (thêm tán trung, thẻ xa), `lamp_steel.glb`, `rest_props.glb`
  (đồ rải theo ô 80 m, như chunk PS1 bị cắt ở 125 m).
- `game/scenes/levels/campus/rest_real.gd`: gắn trên `StripRest`; tắt bóng mặt phẳng và đồ nhỏ; cây, đèn thành MultiMesh treo
  theo đúng điểm của từng cụm `Trees_*`, `ExtraTrees_*`, `StreetLights_*` (hình PS1 ẩn): thân tới 90 m, tán gần 45 m, tán trung
  40…90 m, thẻ xa 85…125 m; đèn tới 125 m.
- `patch_wave7.py props campus`: 365 bản thu về 0 trong 61 chunk (28 chunk rỗng thì ẩn); ẩn lưới 37 ô đất bị phủ kín (ô có
  phần dải cũ, đợt 8 hay hộp nhà B giữ), ba đường PS1, `Fence/N|E|W`, ba ghế và ba xe máy đổ (va chạm giữ); thêm `StripRest`.
- Ban công tầng 4 phía sau: `F4Exterior` (401–406, 408) và `ShellExterior` của phòng 407 (`room407_furnish.gd`) lấy vữa sơn và
  màu của `W7WallPale`; mặt nạ, phòng, va chạm, đồ đạc giữ.

### Số tam giác (lượt 3)
| glb | Tam giác |
|---|---|
| mặt đất (`ground`: lề 2.942, đường 746, vỉa 9.984, lát 194, viền, vạch, ngoài rào) | 14.178 |
| hàng rào B40 (`fences`, 1.200 m) | 15.534 |
| bàng / phượng / xà cừ (thân + tán gần; tán trung; thẻ xa 4) | 2.781; 540 / 1.939; 392 / 1.731; 384 |
| đèn thép (`lamp_steel`) | 126 |
| đồ rải (`rest_props`, 10 ô) | 22.736 |

### Số lần vẽ (chương 3, cùng camera, khối che bật, cùng một lần chạy; main sau lượt 2 → lượt 3)
| Góc | Trước | Sau |
|---|---|---|
| toàn cảnh từ hành lang tầng 4 nhà B (x 37) | 1.933 | 1.924 |
| toàn cảnh giữa vườn | 316 | 292 |
| toàn cảnh từ khán đài | 4.502 | 4.463 |
| đại lộ / ghế, xe máy / phía tây | 533 / 3.859 / 545 | 526 / 3.851 / 510 |
| mái che xe / ki-ốt / cây sau nhà B | 35 / 143 / 440 | 48 / 137 / 434 |
| nhánh đông / đường vòng bắc / rào tây / rào bắc | 229 / 85 / 37 / 62 | 213 / 65 / 30 / 44 |
| sân trước giảng đường / nhà thể chất / ban công sau nhà B | 63 / 42 / 2.764 | 64 / 42 / 2.788 |
| chương 4: sân trước giảng đường / đường sang thư viện | 63 / 475 | 64 / 463 |
Ba góc toàn cảnh đều giảm (khán đài 4.502 → 4.463, dưới 4.598 của lượt 1). Bộ nhớ hình chương 3: 1.333 MB trước và sau.
Không đo FPS (D-179).