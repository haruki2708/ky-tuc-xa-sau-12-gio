# Đồ hoạ thật đợt 7 — T-264 (D-166): nhà nền, mặt ngoài nhà B, mặt đất, đường, cây, đèn, hàng rào còn lại

Card: `docs/tasks/T-264-realistic-graphics-wave7-shells-ground.md`. Ba lượt: lượt 1 khảo sát và góc mẫu (bản này), lượt 2
các nhà, lượt 3 mặt đất. Dựng bằng script Blender, texture vẽ bằng code. Không Tripo, không extension Blender, không ảnh AI.

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
