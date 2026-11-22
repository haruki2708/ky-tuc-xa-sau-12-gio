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

## Lượt 2 (22/11/2026): năm phòng, năm hành lang, đồ nhỏ 407, đồng bộ bốn chương (D-188)

### File

| File | Việc |
|---|---|
| `build_wave10.py` | Blender: `cctv_room.glb` (vỏ, W2, khung cửa, bảng số xanh, bóng đèn ngủ; bỏ W1), `cctv_hall.glb` (H1 trên vật liệu `CW*`, UV2 cho mask nhỏ; tường đầu hành lang kéo tới mép ngoài z 2,55). Bỏ `cctv_light_set.glb` (D1). |
| `build_wave10_net.py` | Mùng tầng trên vén (`cctv_net_upper_open.glb`): chạy chính `room407_furnished/build_nets.py`, chỉ đổi mái 1,0 m trên nệm (nạn nhân ngồi dậy không lòi đầu) và ô vải 5 cm (dưới 5.000 tam giác). |
| `make_wave10_textures.py` | Ba mask hành lang 512 × 256 / 256 × 128 (numpy), nén VRAM. |
| `make_wave10_materials.py` | `CWHall*` (scan đợt 2, mask nhỏ), `CWNetWeave`/`CWNetHem` (texture mùng 407), `A30Plastic`; `.import` của glb, texture. |
| `patch_cctv_set.py` | Gắn vào năm nhánh `Room*` của `cctv_set.tscn`: node `Real` (script `game/scenes/levels/cctv/cctv_room_real.gd`) và `Occluders` (9 hộp, mỗi hộp nằm trong một hộp va chạm tường PS1). |
| `build_wave10_a30.py`, `patch_a30.py` | A30: mesh OBJ mới trên đúng các node mesh cũ (giữ vật liệu của scene), và z của `Door407/Pivot/RulesPaper`. |
| `capture_wave10.gd` | Ảnh lượt 2 (`T267_PARTS`): `cctv` (chương 1 + 310), `cctv310`, `vram` (`T267_CHAPTER` 1 / 3), `a30`, `sync`. |
| `probe_occluder_toggle.gd` | Thử cách bật/tắt occluder (log `survey/r2_occ_probe.txt`). |
| `make_wave10_sheets.py` | Ảnh ghép; lượt 2 mặc định, `r1` cho ảnh lượt 1. |
| `survey/r2_*.txt`, `survey/feeds/r2_*.png` | Log và feed thô 320 × 240 (trước, sau, sau khi tắt occluder). |

Chạy lại (từ gốc repo; Godot theo file khoá, mỗi lúc một tiến trình):

```
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10.py
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10_net.py
blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10_a30.py
python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_textures.py
python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_materials.py
godot --headless --path game --import   (hai lần)
python -B art_source/graphics_upgrade/realistic_map/wave10/patch_cctv_set.py   (trên cctv_set.tscn của main)
python -B art_source/graphics_upgrade/realistic_map/wave10/patch_a30.py        (trên các scene A30 của main)
copy survey_wave10.gd, capture_wave10.gd vào game/_probe_tmp/ kèm một .tscn gốc Node3D gắn capture_wave10.gd
$env:T267_PARTS = "cctv" | "cctv310" | "vram" ($env:T267_CHAPTER = 1|3) | "a30" | "sync"
python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_sheets.py
```

### Cách gắn
- `Room<n>/Real` lúc chạy ẩn mọi `MeshInstance3D` PS1 của phòng (trừ người: `Victim`, `Corpse*`; quản lý đến sau), ghi lại trong
  `replaced`, rồi đặt vỏ, hành lang, lá cửa (mở vào trong, dọc mép đông) và đồ 407: hai khung giường Tripo, bốn tủ Tripo (áp
  tường như T-255), bàn, ghế, quạt, bốn nệm, gối, chăn gấp, mùng theo đúng trạng thái mùng PS1 (A: dưới đóng, trên vén; B: hai
  tầng đóng; 310 không có), đồ riêng: 102 áo trên móc ở đầu giường B, dép, poster tường đông; 306 khăn, xô, sổ, mì; 209 hàng
  sách, chậu đồ giặt; 106 đèn bàn 407 dưới đèn `DeskLamp`, sổ, sách, cốc bút.
- Không va chạm, không đèn, không `set_state`. Mọi hình của `Real` chỉ vẽ trong 40 m quanh camera (`visibility_range_end`):
  camera feed ở trong trường quay, người chơi luôn cách trên 60 m, nên góc nhìn người chơi không vẽ trường quay nữa.
- `Room<n>/Occluders`: 9 `OccluderInstance3D` hộp, mỗi hộp nằm trong bề dày một tường PS1 (cao 0–3 m, dày 0,16 m trong 0,2 m),
  không chạm phòng, hành lang, ô cửa; không có ở tường sau (sau nó không có gì), không ở phía lan can, không ở `Corridor`.

### Số đo (khi bật occlusion)

| | main | sau |
|---|---|---|
| Tam giác mỗi phòng (102 / 306 / 209 / 106 / 310) | PS1 4.576–5.060 (cả người) | `Real`, không tính người: 146.692 / 156.690 / 149.830 / 155.895 / 112.629 (trần 160.000) |
| glb đợt 10 | — | `cctv_room` 2.370, `cctv_hall` 1.502, `cctv_net_upper_open` 4.506 (trần 5.000) |
| Feed phòng 102 / 306 / 209 / 106 / 310: lần vẽ | 77 / 141 / 165 / 158 / 127 | 112 / 125 / 134 / 136 / 140 (trần 150); tắt occluder 112 / 193 / 226 / 229 / 140 |
| Feed hành lang 102 / 306 / 209 / 106 / 310 | 293 / 229 / 278 / 213 / 117 | 131 / 116 / 108 / 92 / 135 (trần 250); tắt occluder 407 / 313 / 351 / 254 / 135 |
| Feed hành lang tầng 4 (`cam_corridor`) | 167 | 59 (tắt occluder 182) |
| Bộ nhớ hình chương 1 | 1.150 MB | 1.166 MB (+16, trần 25) |
| Bộ nhớ hình chương 3 | 1.355 MB | 1.358 MB: 3 MB xuất hiện khi vẽ góc nhìn xuống, trước khi gắn đồ; gắn đồ thêm 0 (trần 5) |
| Góc người chơi nhìn thẳng xuống chỗ trường quay (11 m) | ch1 2.500, ch3 2.664 lần vẽ | ch1 2.445, ch3 2.047 |

Main ở đây là `53d4d0e` (feed đã chép `far`, bật occlusion culling, chưa có occluder). Tam giác của feed sau: 94k–131k.

**Bật/tắt occluder** (`survey/r2_cctv.txt`): chương chạy 3 s rồi thời gian gần như dừng; quản lý, nạn nhân (310:
cả ba xác và director) giữ yên; mỗi feed chụp liền nhau: occlusion bật, tắt, bật lại.
- 10/12 khung giống hệt từng điểm ảnh: feed tầng 4, hành lang 102, 209, 106, 310, phòng 102, 306, 209, 106, 310 (sau khi thua).
- Hành lang 306: 11 điểm ảnh lệch tối đa 2/255, thành một vệt dọc ở mép tường đầu hành lang (dưới ngưỡng 6/255 của T-260).
- Phòng 310 trước khi thua: mọi điểm ảnh dao động 1/255 giữa hai khung cùng trạng thái (bật/bật: 1.972 điểm), bật/tắt 1.014
  điểm cùng mức 1/255; số lần vẽ bật và tắt bằng nhau (142): ở góc này occluder không bỏ vật nào.
- **Bẫy Godot 4.7.2:** ẩn một `OccluderInstance3D` (hay gỡ khỏi cây) rồi hiện lại thì nó không che nữa cho tới khi một viewport bật
  lại `use_occlusion_culling` (`survey/r2_occ_probe.txt`). Vì vậy ảnh so sánh bật/tắt cờ của viewport; trong game occluder không
  bao giờ ẩn.

### Đồ nhỏ phòng 407 (A30)
Chỉ đổi node mesh (và vật liệu đặt lên chúng) trong các file ở card mục 1 điểm 8; dấu vân tay các node khác trùng main
(`test_t267_a30`). Giữ vật liệu của scene (shader bề mặt PS1, `ps1_strength` mặc định 0 nên không rung đỉnh), chữ, UV, key dịch.

| Món | Main | Sau | Hình bao lệch |
|---|---|---|---|
| Sổ Đạt, sổ hợp âm (`dat_notebook.tscn`) | 9 hộp, 108 | bìa bo góc, khối trang vát mép, 7 vòng lò xo qua lỗ: 448 | 2,8 mm |
| Ô hợp âm (`guitar_songbook.tscn`) | 10 hộp nổi 1 mm, 120 | 10 nét mực phẳng, 20 (cả sổ 468) | 2,8 mm |
| Ổ điện Khoa (`khoa_outlet.tscn`) | 9 hộp, 108 | khung bo cạnh, mặt ổ vát, hai khe bo tròn, vít mũ tròn: 454 | 0 |
| Giấy vo trong thùng rác (`trash_bin.tscn`, `Waste0–2`) | 3 lăng trụ, 24 | 3 nắm giấy vo, 240 | ≤ 1,2 cm |
| Nút tắm (`room407_anchors.tscn`, `ShowerYes/No/Button`) | 2 hộp trắng không vật liệu, 24 | đế và nút bấm nhựa, 2 × 552 | 6 mm (mỏng hơn) |
| Nội quy cửa 407 (`floor4.tscn`) | z −0,025: cách mặt cánh Tripo phía hành lang 4,35 cm | z −0,063: lưng tờ cách chỗ nhô nhất của cánh 1,2 mm | — |

Ngân sách tam giác của test cũ giữ nguyên (sổ, sổ hợp âm, ổ điện, thùng rác dưới 500). Không đặt hình ở đường dẫn khớp
`REPLACED_PS1`. Ảnh: `a30_compare.jpg` (trước là ảnh lượt 1 cùng góc), `a30_*_after.jpg`, `a30_rules_paper_*`.

### Đồng bộ bốn chương (`sync.jpg`, `sync_ch{1..4}_*.jpg`)
Bốn góc: 407 từ cửa, hành lang tầng 4 từ đầu cầu thang, nhà vệ sinh chung, phòng 403 (cửa 407 và 403 mở cho ảnh). Khác nhau
thấy được đều do truyện hoặc môi trường chương:
- chương 1–2 đèn bàn 407 bật, chương 3–4 tắt;
- chương 3–4 tầng 4 nằm trong nhà B giữa khuôn viên: ánh sáng môi trường sáng hơn, ngoài lan can là trời đêm xanh và các
  nhà; chương 1–2 ngoài lan can là nền đỏ thẫm.
Không thấy chỗ khác nào không có lý do. Không sửa gì ngoài phạm vi.