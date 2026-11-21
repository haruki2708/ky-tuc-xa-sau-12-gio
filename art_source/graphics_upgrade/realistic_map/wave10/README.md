# Đợt 10 (T-267): năm phòng trường quay CCTV và đồ nhỏ phòng 407

Card: `docs/tasks/T-267-realistic-graphics-wave10-cctv-room407.md`. Quyết định nền: D-166 (Blender, không mẫu Tripo mới, giữ ánh sáng; CCTV giữ góc máy và độ rõ), D-167/D-172/D-177 (phong cách nhà B), D-179/D-184 (không đo FPS, không bot).

## Lượt 1 (21/11/2026): khảo sát, hình mẫu phòng 306, phương án

### File

| File | Việc |
|---|---|
| `survey_wave10.gd` | Khảo sát trong game thật. `list`: kiểm kê đồ nhỏ phòng 407 ở chương 1–4, số liệu và dấu vân tay va chạm năm phòng; `feeds`: ảnh feed 320 × 240 lấy thẳng từ `SubViewport` (×3, giữ điểm ảnh) và 1080p cùng camera, chương 1 `_cctv_scene()`, chương 2 `_cctv_310()`; `a30`: ảnh gần có đèn pin; `vram`: bộ nhớ hình đầu chương. |
| `build_wave10.py` | Blender 5.2.2: `cctv_room.glb` (vỏ phòng, tường sau W1/W2, khung cửa, bảng số, bóng đèn ngủ), `cctv_hall.glb` (hành lang tầng 1–3, lan can sắt, lan can xây, máng đèn, bóng tối ngoài trời), `cctv_light_set.glb` (D1: giường tầng thép, tủ thép). Toạ độ là toạ độ cục bộ của `Room<n>`: năm phòng cùng bố cục nên một bộ glb dùng cho cả năm. |
| `make_wave10_materials.py` | Ghi `.import` của glb: vật liệu giữ chỗ trỏ vào `.tres` có sẵn của đợt 1–2. Đợt 10 chưa có vật liệu, texture riêng. |
| `capture_wave10_pilot.gd` | Hình mẫu dựng lúc chạy trong chương 1 thật (không sửa scene): quản lý giữ yên, mỗi phương án là một lần bật/tắt hình trên cùng khung. `vram3`: bộ nhớ hình chương 3. |
| `make_wave10_sheets.py` | Ảnh ghép `previews/wave10/survey_*.jpg`, `pilot_306.jpg`, `options_*.jpg`; bản "như trên điện thoại" mô phỏng `ui/phone/cctv.gdshader`. |
| `survey/` | Log (`list.txt`, `feeds.txt`, `a30.txt`, `pilot_pilot.txt`, `pilot_vram3.txt`, `vram_ch3.txt`) và feed thô 320 × 240 (`feeds/*.png`). |

Chạy lại (từ gốc repo, một Godot mỗi lúc, theo file khoá):

```
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10.py
python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_materials.py
godot --headless --path game --import   (hai lần)
copy survey_wave10.gd, capture_wave10_pilot.gd vào game/_probe_tmp/ kèm một .tscn gốc Node3D gắn script
$env:T267_PARTS = "list" | "feeds" | "a30" | "vram" ($env:T267_CHAPTER = 1|3); pilot: "pilot" | "vram3"
python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_sheets.py
```

### Số đo

**Năm phòng (main):** cùng bố cục 4 × 5 m, cửa 0,9 × 2,2 m, hành lang 5,8 × 2,25 m; gốc `Room102/306/209/106/310` ở x 0, 6, 12, 18, 40; `CctvSet` ở y −60. Mỗi phòng 22 hình va chạm, dấu vân tay giống hệt nhau ở cả năm phòng.

| Phòng | Tam giác / vật liệu (cả người) | Feed phòng: lần vẽ / tam giác | Feed hành lang: lần vẽ / tam giác |
|---|---|---|---|
| 102 | 4.780 / 28 | 69 / 29.669 | 310 / 41.973 |
| 306 | 5.060 / 34 | 112 / 33.709 | 289 / 37.193 |
| 209 | 4.576 / 25 | 125 / 35.301 | 235 / 32.073 |
| 106 | 4.812 / 32 | 115 / 35.353 | 187 / 27.417 |
| 310 | 4.840 / 35 | 127 / 6.984 (sau `_cctv_310`) | 111 / 6.500 |

Feed hành lang của 102 vẽ nhiều nhất vì nhìn dọc trục x thấy cả hành lang và phòng của 306, 209, 106 qua tường (feed không bật occlusion culling, camera feed không chép `far`). Feed phòng thấy phòng bên trái qua tường (102 không có phòng bên trái nên ít nhất).

**Bộ nhớ hình đầu chương (main):** chương 1: 1.150 MB, chương 3: 1.355 MB.

**Hình mẫu (phòng 306, cùng khung):**

| | Tam giác / vật liệu của phòng | Feed phòng | Feed hành lang |
|---|---|---|---|
| main | 4.464 / 29 | 111 lần vẽ, 33.697 tam giác | 289 / 37.193 |
| D1 (+ vỏ, hành lang H1) | 105.280 / 38 | 136 / 96.958 | 318 / 76.430 |
| D2 | 148.494 / 37 | 133 / 128.427 | — |
| W2 thay W1 (feed của 310) | +864 tam giác | +5 lần vẽ | — |

glb: `cctv_room` 2.386, `cctv_hall` 1.502, `cctv_light_set` 3.784 tam giác. Phần lớn tam giác của D1 là đồ Tripo của 407 dùng chung (gối 4.900, chăn 4.900–7.840, bàn, quạt 7.840, đồ của 306).

Bộ nhớ hình: chương 1 1.150 → 1.223 MB (+73 MB, cả D1 lẫn D2; D2 không thêm gì vì đồ 407 đã nạp). Chủ yếu là ba mask hành lang đợt 2 (4096 × 1536 và 4096 × 768, chưa nén, khoảng 60 MB), còn lại là terrazzo 2K, mask cầu thang, sơn xám. Chương 3 1.355 → 1.355 MB (+0 MB: nhà B đã nạp sẵn mọi texture này).

### Đồ nhỏ phòng 407 (A30)

Có ở cả bốn chương (trừ giấy Khoa chỉ có ở chương 1 sau tiếng gõ), tổng khoảng 616 tam giác hình khối:

| Món | Hình hiện nay | File sở hữu | Ghi chú |
|---|---|---|---|
| Sổ Đạt `Anchors/DatNote/Model` | 9 hộp, 108 tam giác | `scenes/levels/ch1_models/dat_notebook.tscn` (B) | Giấy đọc được `Ch1DatNote` (A) nằm trên |
| Sổ hợp âm `Anchors/GuitarSongbook` | sổ (cùng scene trên) + 10 hộp dây/phím, 228 | `scenes/levels/ch1v2/guitar_songbook.tscn` (B) | "chỗ dây đàn"; `Ch1TapChart` (A) nằm trên |
| Ổ điện Khoa `Anchors/KhoaOutlet` | 9 hộp, 108 | `scenes/levels/room407/khoa_outlet.tscn` (B) | |
| Nút tắm `Anchors/ShowerYes|No/Button` | 2 hộp trắng, không vật liệu, 24 | `scenes/levels/room407/room407_anchors.tscn` (B) | Chương 2 director gắn `shower_choice.tscn` (A) |
| Bộ sạc `Anchors/DatLocker/Charger` | 5 hộp, 60 | `scenes/levels/ch1_models/charger.tscn` (B) | Nằm trong tủ Đạt đóng: không thấy khi chơi |
| Giấy thùng rác `Anchors/TrashBin` | 3 lăng trụ + giấy xé, 42 | `ch1v2/trash_bin.tscn`, `ch1v2/torn_paper.tscn` (B) | |
| LED router `Anchors/Router/Model/LED` | 1 hộp, 12 | `scenes/levels/ch1_models/router.tscn` (B) | Router thật đã có; giữ LED |
| Giấy đọc được `Ch1*` (9 tờ) | quad 2 tam giác | `scenes/interaction/readable.tscn` (A), director (core) đặt | Giữ: giấy hai tam giác là hợp lý |
| Nội quy cửa `Door407/Pivot/RulesPaper` | hộp 12 | `scenes/levels/floor4/floor4.tscn` (B) | Từ trong phòng không thấy; phía hành lang lệch 4 cm khỏi cánh Tripo (đã ghi ở T-266) |
| Ổ cắm nối dài, phích, cổng LAN, cáp | đã là hình thật (T-226) | | Giữ |

Các món của lane B nằm dưới `Anchors` (trong `KEEP_PS1`), nên hình mới đặt trong chính scene của món đó không bị `_furnish()` ẩn; không cần đường của C2.
