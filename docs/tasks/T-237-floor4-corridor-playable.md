# T-237 — Hành lang tầng 4 mới vào bản chơi (bốn chương)
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141)
- Nhánh: `lane-b/T-237-floor4-corridor-playable` từ `origin/main` mới nhất.
- Quyết định giao: **D-148** (08/11/2026: chủ dự án duyệt T-235, chọn biển số A và cửa 408 cũ kiểu 1, cho phép đo FPS). Tiếp nối [T-235](T-235-floor4-corridor-full-shell.md) (cả hành lang trong cảnh thử `corridor_g5_pilot`) và [báo cáo FPS](../../tools/reports/D-148-corridor-fps.md): hành lang mới ≥ 60 FPS ở 1080p, chậm hơn PS1 khoảng 0,55 ms/khung.
- Lượt này đưa hành lang mới vào **bản chơi**: `floor4.tscn` dùng chung cho cả bốn chương, nên mọi chương đổi theo.

## Chủ dự án chọn (08/11/2026)
- Biển số **A** (nhôm, số dập sơn đen); cửa 408 cũ ở X=36 **kiểu 1** (xây kín, trát vữa); lan can **A1**. Bỏ mọi biến thể khác khỏi bản chơi (giữ trong cảnh thử nếu muốn).

## Việc cần làm
1. **Cách đưa vào (lane B đề xuất, integrator duyệt trong Handoff trước khi merge):** theo mẫu phòng 407: phần dựng hiện nằm trong `corridor_g5_pilot.gd` (`build`, `set_upgraded`, `set_plates`, `set_seal`) được tách thành một script production (ví dụ `game/scenes/levels/floor4/corridor_shell.gd`), `floor4.gd` gọi nó trong `_ready`; cảnh thử cũng gọi đúng mã đó và giữ phím G so PS1. Nếu cách khác tốt hơn, ghi lý do. **Không xóa node PS1**, chỉ ẩn mesh như cảnh thử (hợp đồng `PLAN.md` mục 2).
2. **Hợp đồng gameplay giữ nguyên:** mọi node, transform, va chạm, navigation trong `PLAN.md` mục 2. Phải còn đạt: `test_floor4`, `test_wide_corridors`, tuyến quản lý chương 1, cửa 408 chương 3 (`_wave_408`), proxy chương 4, `test_room407_*`, `test_corridor_g5`.
3. **Nối Campus (chương 3–4):** hai đầu hành lang khi có Campus (cầu thang chính ở X=0, cầu thang thoát hiểm ở X=44). T-235 mới chụp ảnh; lượt này phải **đi bộ thật** bằng capsule từ hành lang xuống cả hai cầu thang ở chế độ Campus (test mới trong `game/tests/levels/`), và cửa thoát hiểm chương 3 mở được.
4. **Số liệu:** ghi số tam giác, mesh, vật liệu của cảnh chơi (Floor4 một mình và Floor4 + Campus) trong Handoff.
5. **Ảnh trong cảnh chơi thật:** chụp 1080p bằng cảnh chương (không phải cảnh thử) ở chương 1 và chương 3: dọc hành lang, trước cửa 407, chỗ nối cầu thang. Dùng chế độ chụp của T-235 hoặc cảnh chụp mới.

## Được phép sửa
- `game/scenes/levels/floor4/` (`floor4.tscn`, `floor4.gd`, `corridor_g5_pilot.*`, `corridor_capture.*`, script production mới), `art_source/graphics_upgrade/floor4_corridor/`, `game/assets/models/graphics_pilot/floor4_corridor/`, `game/rendering/` (chỉ thêm), `game/tests/levels/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `door407.gd`, phòng 407, Campus (`game/scenes/levels/campus/`), director, `game/scripts/core/`, shader 407 đang dùng; không đổi tên, dời, xóa node hợp đồng; không thêm va chạm.
- Không tiêu credit Tripo; asset chỉ CC0, CC-BY.
- **Không đo FPS** và **không chạy bot**: D-148 chỉ cho phép đo hành lang trong cảnh thử (đã xong); đo trong chương thật và chạy lại bot phải xin chủ dự án riêng, integrator làm.

## Ghi chú đã biết (không phải việc của lượt này)
- **CCTV** (`CCTVSet/Corridor`, hình hành lang trên điện thoại ở chương 1) vẫn PS1 và sẽ lệch với hành lang mới: tách việc riêng cho integrator (`PLAN.md` mục 7.4), không tự sửa; ghi ảnh chỗ lệch trong Handoff nếu thấy.
- Còn PS1: bên trong phòng 401–406 và 408, bàn trực, nhà vệ sinh chung, đồ phơi, cầu thang (lượt sau).
- Bot chương 2–3 đi qua hành lang này; sau khi merge integrator xin chủ dự án chạy lại ca good (lane C hiện hết hạn mức).

## Checklist hoàn thành
- [x] Hành lang mới có trong cả bốn chương, một mã dùng chung với cảnh thử
- [x] Mọi test hợp đồng ở mục 2 đạt, không đổi node/va chạm
- [x] Đi bộ capsule thật tới hai cầu thang ở chế độ Campus; cửa thoát hiểm mở được
- [x] Ảnh 1080p từ cảnh chương thật (chương 1 và 3)
- [x] Số tam giác, mesh, vật liệu trong Handoff
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot; chạy bằng tiến trình pwsh riêng ghi log)
- [x] Handoff trung thực, có commit hash, ghi rõ chỗ chưa kiểm

## Cách kiểm tra
- Integrator xem ảnh, chạy full test và check, xin chủ dự án đo FPS trong chương thật rồi mới build `KyTucXa.exe` cho chủ dự án chơi thử.

## Handoff (agent điền)
**Phiên 09/11/2026 — Claude làm thay lane B** (integrator, Opus 5.5; lane B hết hạn mức, chủ dự án giao). Nhánh `lane-b/T-237-floor4-corridor-playable`.

**Đã làm**
1. **Cách đưa vào** (theo mẫu phòng 407, `Room407Furnish`):
   - Tách phần dựng của `corridor_g5_pilot.gd` thành `game/scenes/levels/floor4/corridor_shell.gd` (`class_name Floor4CorridorShell`, hàm tĩnh). Mã chuyển nguyên, không tối ưu, để số FPS của D-148 vẫn đúng.
   - `floor4.gd` gọi `Floor4CorridorShell.build(self)` trong `_ready`, sau `_hang_furnished_door()`, cùng thứ tự cảnh thử đã đo.
   - Thêm `@export var upgraded_corridor := true` trong `floor4.gd`. Tắt trước khi vào cây để có tầng PS1 nguyên bản (test so hợp đồng, ảnh khảo sát T-229).
   - `build()` gặp `G5Corridor` có sẵn thì trả lại cái đó, không dựng lần hai.
2. **Chỉ lựa chọn của chủ dự án trong bản chơi (D-148):**
   - Bản chơi dựng `shell`, `frames`, `lamps`, `railing`, `plates_alu`, hai tường đầu, 7 cánh Tripo. Không có `plates_enamel`, `seal_board`; cửa 408 cũ xây kín nằm sẵn trong `shell`.
   - Cảnh thử `corridor_g5_pilot` dùng đúng hành lang của Floor4, rồi thêm hai biến thể (ẩn) bằng `add_variants()`. Phím G (so PS1), N, M vẫn chạy.
3. **Không xóa node PS1:** chỉ ẩn 149 mesh như cảnh thử; không đổi tên, dời, thêm node hợp đồng hay va chạm. `test_gameplay_nodes_are_untouched` nay so tầng PS1 thật (`upgraded_corridor` tắt) với tầng mặc định.
4. **Test mới** `game/tests/levels/test_floor4_corridor_playable.gd`:
   - Cả 4 scene chương dùng `floor4.tscn` với `upgraded_corridor` bật.
   - Floor4 + Campus, thân người chơi thật (capsule, trọng lực, `move_and_slide`, không dịch chuyển): đi từ x 30 dọc hành lang mới xuống **cầu thang chính** (4A, chiếu nghỉ, 4B) tới hành lang tầng 3.
   - **Cửa thoát hiểm** đóng thì chặn ở cuối hành lang; mở (`set_fire_door_open`) thì đi xuống tới chiếu nghỉ tầng 3.
   - Cả hai test kiểm hành lang mới đang hiện và hai tường đầu ẩn theo nắp.
   - Chương 3 mở cửa bằng chìa: `test_chapter3` sẵn có, nay chạy trên hành lang mới.
5. **Test sửa:**
   - `test_corridor_g5` (dựng hai lần không nhân đôi; bản chơi không có biến thể; cảnh thử không dựng lần hai).
   - `test_room407_playable_furnished` (kiểm mặt trùng tường phòng 407 thêm cả mesh của `G5Corridor`, lớp lỗi D-113).
   - `test_sealed_408` đo tấm bịt và biển số **PS1** nên chạy trên tầng PS1; biển số và cửa 408 mới đã có `test_corridor_g5` đo.
6. **Ảnh 1080p trong cảnh chương thật** `art_source/graphics_upgrade/floor4_corridor/previews/round3_playable/`:
   - 8 ảnh chương 1, 11 ảnh chương 3 (dọc hành lang, cửa 407, hai đầu, cầu thang chính, cầu thang thoát hiểm, cửa thoát hiểm mở), kèm `ch*_capture_report.json`.
   - Chế độ mới `corridor_capture.tscn -- --chapter=N`: director không chạy, giao diện và người chơi ẩn, tắt tiếng.
   - Bộ lọc PS1 tắt theo mặc định (D-102), nên ảnh là hình người chơi thấy khi chưa bật bộ lọc.

**Số liệu** (mesh đang hiện, đếm trong Godot; tam giác theo chỉ số):
| Cảnh | Tam giác | Mesh | Bề mặt | Vật liệu |
|---|---|---|---|---|
| Floor4 một mình, PS1 | 705 031 | 772 | 857 | 278 |
| Floor4 một mình, hành lang mới | 798 372 | 693 | 827 | 404 |
| Floor4 + Campus, PS1 | 756 637 | 3 893 | 4 010 | 354 |
| Floor4 + Campus, hành lang mới | 849 978 | 3 814 | 3 978 | 477 |
| Riêng nút `G5Corridor` | 41 854 | 47 | 127 | 127 |

- Floor4 tăng khoảng 93 000 tam giác. Riêng `G5Corridor` là 41 854; phần còn lại chủ yếu là 7 cánh cửa Tripo và tay gạt treo dưới `LockedDoor_*/Hinge`.
- Phần lớn 705 000 tam giác của Floor4 là đồ Tripo trong phòng 407.
- Mỗi bề mặt hành lang có một vật liệu riêng (127/127), như cảnh thử lúc đo FPS. Nếu cần, có thể dùng chung vật liệu theo loại ở lượt sau, nhưng phải đo lại FPS.

**Cách kiểm tra**
- `pwsh tools/test.ps1 -Filter corridor` (16 test), `-Filter levels/`.
- Full test và check: xem dòng kết quả cuối Handoff.
- Ảnh: `previews/round3_playable/`.

**Chỗ thấy, không thuộc lượt này (không sửa)**
- **Cánh cửa thoát hiểm Campus khi mở** (`BuildingB/FireDoor`, hộp 3,8 × 2,4 × 0,12 m) quay vào hành lang và nằm dọc z ≈ 3,84…3,96 từ x 40,2 tới 44. Nó chồng lên lan can (mới và PS1) và che lan can đoạn đó (ảnh `ch3_23_fire_door_open_torch.jpg`, `ch3_12_fire_stairs_torch.jpg`). Lỗi có từ trước (lan can PS1 cũng chồng), thuộc Campus.
- **CCTV** (`CCTVSet/Corridor`, điện thoại chương 1) vẫn PS1, chưa kiểm; integrator làm việc riêng (PLAN mục 7.4).
- Mỗi lần dựng Floor4 nay nạp thêm 6 GLB và tạo vật liệu, nên full test chậm hơn một chút.

**Chưa kiểm:** chưa đo FPS trong chương thật, chưa chạy bot (card không cho phép; integrator xin chủ dự án). Chưa chơi tay.

**Kết quả:**
- `-Filter corridor`: `RESULT: 16 passed, 0 failed` (`test_corridor_g5` 9, `test_floor4_corridor_playable` 3, `test_wide_corridors` 4).
- `-Filter levels/` lượt đầu: 171 đạt, 2 hỏng ở `test_sealed_408` (đo mesh PS1 đã bị ẩn); sửa như mục 5, full test bên dưới chạy lại cả hai.
- Chụp chương 1 và 3: cả hai thoát mã 0, 8 và 11 ảnh.
- Full test: `RESULT: 887 passed, 0 failed` (00:08–00:34).
- Check: `RESULT: check 0 error(s)` (00:34–00:58).
- Full test và check chạy liền nhau trong một tiến trình `pwsh` riêng, lấy khóa bằng CreateNew lúc 00:08:46 và trả khóa khi xong; log trong `build/integrator/` (không commit). Giữa chừng, Claude Code dừng vòng chờ đọc log vì máy thiếu RAM; tiến trình test không bị ảnh hưởng. Sau đó `git checkout -- game/default_bus_layout.tres`.
- Nền: nhánh tạo từ `main` `9a104a7`, lúc commit `origin/main` vẫn là `9a104a7`.

**Commit:**
- `f2021e6`: script dựng dùng chung, `floor4.gd`, cảnh thử, chế độ chụp chương, test.
- `914afc6`: ảnh từ cảnh chương 1 và 3, README.
- Commit card này ngay sau.

**Yêu cầu thay đổi:** không. **Blocked:** không.

## Review (integrator, 09/11/2026)
- **Đạt, merge vào `main`** (`f7efdc3`). Integrator tự làm thay lane B nên đây là tự rà, không có người rà thứ hai; chủ dự án nên chơi thử trước khi coi là xong hẳn.
- Đúng phạm vi card: không sửa `door407.gd`, phòng 407, Campus, director, `game/scripts/core/`, shader 407; không đổi tên, dời, xóa node hợp đồng, không thêm va chạm. Bản chơi chỉ có biển số nhôm và cửa 408 xây kín (D-148).
- Nhánh tách từ `9a104a7` và `main` không có commit mới, nên kết quả full test 887/0 và check 0 lỗi đúng cho `main` sau merge; không chạy lại.
- **Tiếp theo (cần chủ dự án cho phép):** đo FPS trong chương thật (chương 1 và 3), chạy lại bot chương 2–3, rồi build `KyTucXa.exe` cho chủ dự án chơi thử.
- **Việc tách riêng:** cánh cửa thoát hiểm Campus khi mở chồng lên lan can; CCTV hành lang trên điện thoại chương 1 vẫn PS1. Còn PS1 ở tầng 4: bên trong phòng 401–406 và 408, bàn trực, nhà vệ sinh chung, đồ phơi, cầu thang (lượt 3–4).
