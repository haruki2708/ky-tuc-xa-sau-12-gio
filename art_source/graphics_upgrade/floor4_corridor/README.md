# Hành lang tầng 4 — đồ họa gần chân thực

- **T-229** (khảo sát, 02/11/2026): số đo, bảng hợp đồng gameplay, 12 ảnh hiện trạng, kế hoạch 4 lượt: [`PLAN.md`](PLAN.md); phiếu Tripo nháp [`TRIPO_NHAP.md`](TRIPO_NHAP.md).
- **T-233** (lượt 1, D-142): mẫu đoạn x 26…34 quanh cửa 406 và 407, phương án A cả 4 mục, phong cách vỏ phòng 407 ([`../room407_shell/README.md`](../room407_shell/README.md)). Ảnh lượt 1 giữ nguyên trong `previews/` (tên `before_*`, `after_*`, `compare_*`).
- **T-235** (lượt 2, D-144): chủ dự án duyệt mẫu, chọn lan can A1, thay biển số cùng cửa. Nhân ra **cả hành lang x 0…44**, cửa 401…408, tấm bịt cửa 408 cũ, biển số mới. Vẫn chỉ trong cảnh thử, chưa vào bản chơi. Ảnh lượt 2: `previews/round2/`.
- **T-237** (bản chơi, D-148): hành lang mới **vào cả bốn chương**. Chủ dự án chọn biển số A (nhôm) và cửa 408 cũ kiểu 1 (xây kín); bản chơi chỉ có hai lựa chọn này. Ảnh từ cảnh chương thật: `previews/round3_playable/` (chương 1 và 3).

## T-237: bản chơi
- Mã dựng nằm ở `game/scenes/levels/floor4/corridor_shell.gd` (`Floor4CorridorShell`). `floor4.gd` gọi `Floor4CorridorShell.build(self)` trong `_ready`, nên mọi scene dùng `floor4.tscn` đều có hành lang mới: bốn chương, `main.tscn`, cảnh thử, cảnh chụp. Mã giống hệt mã T-235 đã đo FPS (D-148), chỉ chuyển chỗ.
- Bản chơi dựng `shell`, `frames`, `lamps`, `railing`, `plates_alu`, hai tường đầu và 7 cánh Tripo. Cảnh thử `corridor_g5_pilot` dùng đúng hành lang đó, thêm `plates_enamel` và `seal_board` (ẩn) để còn so bằng phím N, M; phím G vẫn bật/tắt so với PS1.
- `floor4.gd` có `upgraded_corridor` (mặc định bật). Tắt trước khi Floor4 vào cây để có tầng PS1 nguyên bản: test so hợp đồng (`test_corridor_g5`), test đo hình PS1 (`test_sealed_408`), bộ ảnh khảo sát T-229.
- Chụp trong cảnh chương: `& $Godot --path game res://scenes/levels/floor4/corridor_capture.tscn -- --chapter=1` (hoặc `3`). Director không chạy (ánh sáng lúc mở chương), giao diện và người chơi ẩn, tắt tiếng. Bộ lọc PS1 tắt theo mặc định của game (D-102), nên ảnh không có hiệu ứng PS1 nếu người chơi không bật.

Script lượt 1 đã đổi tên và mở rộng: `segment_layout.py` → `corridor_layout.py`, `build_segment.py` → `build_corridor.py`, `make_segment_masks.py` → `make_corridor_masks.py`. Các file `segment_*.glb` (kể cả lan can A2 `segment_railing_classic.glb`) đã thay bằng `corridor_*.glb`; bản cũ còn trong lịch sử Git.

## T-235: cả hành lang

### Có gì
| Phần | Cách làm |
|---|---|
| Tường phía phòng (mặt hành lang z 0,1), x 0…44 | Như mẫu: sơn kem của phòng 407 nhuộm xám nhẹ, shader vỏ 407. Chia theo 10 gian (nhà vệ sinh, 401…406, 407 tây, 407 đông, 408), mỗi gian một mesh gồm cả sàn, trần, gạch chân tường. Mặt phía phòng phủ tới z −0,1 (trừ hai gian của phòng 407, vỏ phòng đã vẽ mặt trong) |
| Bản đồ bẩn | Một atlas cho cả hành lang mỗi nhóm: tường 4096×2048 (207 px/m), sàn 4096×2048 (191 px/m), trần 4096×1024 (126 px/m). Vẽ theo vị trí thật nên không vết nào lặp ở mọi cửa: vệt tay bên chốt mỗi cửa đậm nhạt khác nhau (407 đậm nhất, cửa 408 cũ gần như không còn); làn đi giữa hành lang lệch nhẹ; lối rẽ vào từng cửa, vào nhà vệ sinh, chỗ đứng trước bàn trực; ẩm chân tường và vệt ướt ở cửa nhà vệ sinh; bụi dồn hai đầu và mép ngoài; trần: bồ hóng trên mỗi máng đèn đậm nhạt khác nhau, dải ẩm mép ngoài, 3 vết dột, vài vết nứt |
| Cửa 401…406, 408 | Khung, nẹp 7 cm, ngưỡng đá, nẹp chặn và 3 bản lề như cửa 406 của mẫu. Cánh Tripo và 2 tay gạt của phòng 407 treo vào `LockedDoor_*/Hinge`: `RoomDoor.set_open()` mở ra hành lang như cánh PS1 (chương 3 mở cửa 408) |
| Cửa 407 | Giữ như mẫu (nửa phía hành lang của khung, nối với khung có sẵn của phòng) |
| Cửa 408 cũ ở x 36 | Giữ khung và nẹp cũ, ngưỡng đá; lòng cửa **xây kín trát lại**, lùi 2 cm, sơn mới hơn, nứt chân chim quanh mép (mặc định, đúng ghi chú T-190 "bịt mặt cửa cũ bằng tường"). Phương án 2: **ốp 5 tấm ván cũ bắt vít** trong khung cũ (phím M) |
| Cửa nhà vệ sinh chung | Má cửa và đầu cửa trát vữa, ngưỡng đá; không khung (bên trong nhà vệ sinh vẫn PS1, lượt 3–4) |
| Biển số 401…408 | Dựng trong Blender, đúng số và tâm (x, 2,42) của `RoomPlate_*`. Mặc định **A: nhôm** 30×12 cm, gờ dập quanh mép, số dập nổi sơn đen, 2 vít. Phương án **B: men xanh** 30×14 cm, viền và số in trắng (phím N). Chữ số tự vẽ bằng nét (không dùng file font) |
| Máng đèn | Máng 2 bóng tuýp của phòng 407 dưới cả 9 `CorridorLight_*` (8 phòng và bàn trực); đèn, nguồn sáng, `LightHum` giữ nguyên; bóng tuýp sáng/tắt/chập chờn theo đèn |
| Lan can A1 | Suốt 44 m: trụ vuông 50 mm cách 2 m (hai trụ đầu lùi vào 3 cm), tay vịn ống 50 mm, thanh dưới, song đứng cách 12,5 cm |
| Hai đầu | Floor4 riêng (chương 1–2): tường trát vữa và gạch chân tường gắn dưới `WestEnd`/`EastEnd`. Có Campus (chương 3–4): Campus ẩn hai nắp này nên tường mới ẩn theo, lối sang cầu thang để trống; mép sàn, trần, tường ở x 0/44 có mặt cắt khép kín |

Giữ PS1 trong lượt này: đồ phơi, dây phơi, dép, xô, bàn trực và đồ trên bàn, bảng tin, loa, nội thất các phòng, bên trong nhà vệ sinh chung, cầu thang Campus.

### Không đổi gameplay
- `floor4.tscn`, `corridor.tscn`, `washroom.tscn`, `duty_desk.tscn` và mọi scene chơi không sửa. Cảnh thử chỉ ẩn hình PS1 (mesh) của tường phía phòng, biển số, máng đèn, cánh cửa, sàn, trần, lan can, hai nắp đầu, tấm bịt `Sealed408`; không xóa, dời hay đổi tên node nào; không thêm va chạm.
- `game/tests/levels/test_corridor_g5.gd`: so toàn bộ node của Floor4 trước/sau khi dựng (vị trí, va chạm, đèn, navigation, âm thanh, số phòng), không đỉnh nào của hình mới lấn vào lối đi, capsule đi thông dọc Z=3 và Z=1 cả 44 m (trước bàn trực đi ở Z=1,1 vì bàn PS1 nhô tới z 0,745) và vào cửa 407, 7 cánh cửa mở/đóng theo `RoomDoor`, 9 máng đèn theo đèn, biển số đúng số và chỗ, tấm bịt, hai đầu ẩn theo nắp.

### Xem và dựng lại
```powershell
# Cảnh thử đi bộ được (Godot editor, F6): G bật/tắt hành lang mới (so với PS1), N đổi kiểu biển số, M đổi kiểu cửa 408 cũ
#   res://scenes/levels/floor4/corridor_g5_pilot.tscn
python -B art_source/graphics_upgrade/floor4_corridor/corridor_layout.py        # in số mảnh và mật độ atlas
python -B art_source/graphics_upgrade/floor4_corridor/make_corridor_masks.py    # 3 bản đồ bẩn (~2 phút)
& "D:\Tools\Blender\5.2.2\blender.exe" -b --factory-startup -P art_source/graphics_upgrade/floor4_corridor/build_corridor.py
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage g5test   # test của hành lang (chờ khóa Godot)
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage g5       # import lại rồi chụp ảnh 1080p vào previews/round2/
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage full     # full test rồi check trong một lượt Godot
python -B art_source/graphics_upgrade/floor4_corridor/make_compare.py           # ảnh ghép trước/sau, phương án, compare_overview.jpg
```
Log ở `build/floor4_corridor/` (không commit). Số tam giác, vật liệu, dung lượng: [`geometry_report.json`](geometry_report.json).

Nguồn và giấy phép: [`CREDITS.md`](CREDITS.md).
