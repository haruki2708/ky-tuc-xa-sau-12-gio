# T-254 — Lan can mép chiếu nghỉ tầng 4 ở hai cầu thang nhà B (có va chạm)
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model Opus 5.5 high (việc nhỏ). Chủ dự án tự dán prompt (`lane-b.md` mục 1i).
- Nhánh: `lane-b/T-254-floor4-landing-guard-rail` từ `origin/main` mới nhất (đã có T-250).
- Giao việc: chủ dự án trả lời câu 4 của [T-250](T-250-realistic-graphics-wave1.md) (13/11/2026): **có làm** lan can mép chiếu nghỉ tầng 4; card riêng vì phải thêm va chạm (T-250 cấm đổi va chạm).

## 1. Lỗi (có từ trước, T-250 "Thấy thêm" 2)
Ở **cả hai cầu thang** nhà B (chính và thoát hiểm), mép chiếu nghỉ tầng 4 phía giếng thang (trên vế B) để hở: không lan can, không va chạm. Bước ra là rơi xuống tầng 3.

## 2. Việc (theo đề xuất của lane B trong Handoff T-250)
- Chỗ: mép chiếu nghỉ tầng 4 (y 0, z 0) phía giếng thang, trên vế B. Cầu thang chính x −2,28…−0,12 (cộng khe giếng tới −2,72); cầu thang thoát hiểm x 46,72…48,88 (từ 46,28). Đo lại trên cảnh trước khi dựng.
- **Hình:** lan can cùng kiểu lan can giếng thang của T-250 (song thép sơn xanh, tay vịn gỗ, trụ hai đầu), cao 0,95 m, nối với lan can vế A ở trụ đầu thang. Dựng trong `art_source/graphics_upgrade/realistic_map/wave1/build_stairs.py`.
- **Va chạm:** một `StaticBody3D` hộp mỏng (khoảng 0,05 m dày, cao 1,0 m) trên layer 1 đúng chỗ lan can, để người chơi, đồng đội, xác sống và bot không rơi xuống tầng 3. Không lấn lối đi vế A, vế B, chiếu nghỉ.

## 3. Kiểm
- Test trong `game/tests/levels/` (thêm vào `test_t250_realistic_wave1.gd` hoặc file mới): hai hộp va chạm mới đúng chỗ, đúng layer; dấu vân tay các va chạm khác của hai cầu thang không đổi (cập nhật md5 trong test T-250 cho đúng phần thêm); người chơi đi từ chiếu nghỉ tầng 4 ra phía giếng bị chặn.
- Test cũ đạt: `test_fire_stairs`, `test_campus` (đường dẫn, lối đi), `test_chapter3`, `test_ch3_*`, `test_t250_*`. Full test và check trước commit cuối.
- Ảnh trước/sau 1080p từ chiếu nghỉ tầng 4 của hai cầu thang: `art_source/graphics_upgrade/realistic_map/previews/t254/`.
- Không chạy bot, không đo FPS.

## 4. Được phép sửa
- `game/scenes/levels/campus/building_b.tscn` (hình và thân va chạm lan can), `art_source/graphics_upgrade/realistic_map/wave1/build_stairs.py` và glb sinh ra, test trong `game/tests/levels/`, card này.

## 5. Không được
- Đổi va chạm khác, navmesh, director, luật; Tripo; bot, FPS; sửa STATUS, DECISIONS.

## Checklist
- [x] Hình lan can hai cầu thang
- [x] Va chạm hai lan can
- [ ] Test, full test, check, ảnh (test mới, test T-250, ảnh: xong; full test, check: chưa chạy)
- [x] Handoff

## Handoff

### 13/11/2026 — lane B (Claude, Opus 5.5), WIP
Nhánh `lane-b/T-254-floor4-landing-guard-rail` từ `origin/main` `82631bd` (commit card đã đọc: `d1ab5ad`). Không dùng Tripo, không chạy bot, không đo FPS.

**Đo trên cảnh trước khi dựng** (chương thật: `floor4.tscn` + `campus.tscn`):
- Chiếu nghỉ tầng 4 là hộp `Landing4`: x −5…0 (chính) và 44…49 (thoát hiểm), z 0…4, mặt trên y 0. Vế 4A có va chạm tới x0 + 2,28. Trụ đầu thang vế 4A (T-250) ở x0 + 2,255.
- Mép phía vế B: cầu thang chính giáp tường nhà vệ sinh tầng 4 (`Floor4/Washroom/WestWall`, mặt ở x −0,1, z −5…0). Cầu thang thoát hiểm giáp tường `Wall49.08` (mặt ở x 49).
- Không có polygon dẫn đường nào qua mép này, nên navmesh không đổi.

**Đã làm:**
- **Va chạm:** `building_b.tscn` có thêm `MainStairs/Landing4Rail` và `FireStairs/Landing4Rail`. Mỗi cái là một `StaticBody3D` layer 1, mask 0, một `BoxShape3D` dày 0,05 m, cao 1,0 m, đứng trên mép sàn (z 0…0,05, y 0…1).
  - Cầu thang chính: x −2,745…−0,1.
  - Cầu thang thoát hiểm: x 46,255…49,0.
  - Hộp không lấn vế 4A, vế 4B (z < 0) hay lối đi chiếu nghỉ (z > 0,05, như test T-250 định nghĩa).
  - Không đổi, không xoá va chạm nào khác.
- **Hình:** `build_stairs.py` có thêm `landing_rail()`: song thép vuông khoảng 12 cm một song, thanh thép dưới ở 0,12 m, tay vịn gỗ ở 0,95 m, nối trụ đầu thang vế 4A, kết thúc bằng trụ 1,02 m sát tường. Đứng trên đúng đường z 0,025 của lan can ngang giếng ở các tầng dưới.
  - Dựng lại `main_stairs.glb` (15.676 → 15.996 tam giác) và `fire_stairs.glb` (17.976 → 18.308).
  - Dựng lại khi chưa sửa thì `main_stairs.glb` trùng từng byte bản cũ; `fire_stairs.glb` chỉ khác thứ tự chỉ số tam giác ở hai lưới, đỉnh không đổi.

**Kiểm:**
- Test mới `game/tests/levels/test_t254_landing_rail.gd` (4 test, đạt):
  - hai hộp đúng chỗ, đúng layer; tia từ chiếu nghỉ về phía giếng chạm đúng lan can ở mọi điểm dọc mép;
  - hình lan can nằm trong hộp (±5 mm, đỉnh trụ nhô 2 cm như trụ T-250);
  - người chơi thật đẩy thẳng và chéo vào mép từ 4 vị trí mỗi cầu thang đều đứng lại trên tầng 4;
  - người chơi vẫn đi xuống vế 4A sát lan can tới chiếu nghỉ trung gian.
  - Thử tắt hai hộp thì test đẩy hỏng: người chơi rơi xuống vế 4B ở mọi điểm, nên test có tác dụng thật.
- `test_t250_realistic_wave1.gd`: dấu vân tay va chạm bỏ qua đúng hai body `Landing4Rail`. **md5 giữ nguyên bản main `c666d1ad…`** (36 dòng), tức mọi va chạm cũ của hai cầu thang, cửa, bàn trực không đổi. 5 test T-250 đạt.
- **Chưa chạy:** full test, check (chạy ngay sau commit này).

**Ảnh** `art_source/graphics_upgrade/realistic_map/previews/t254/`:
- Ảnh 1080p, chương 3, director giữ, đèn pin khảo sát như T-250: `before_*`/`after_*` cùng camera, 5 góc mỗi cầu thang (đứng trên chiếu nghỉ, sát mép, từ hành lang hoặc cửa thoát hiểm, từ vế 4A, từ vế 4B nhìn lên).
- Ghép: `compare_main.jpg`, `compare_fire.jpg`. Đã tự xem từng ảnh: lan can khớp kiểu T-250, nối trụ vế 4A, không hở, không chồng hình.
- Script chụp là bản sao của `capture_wave1.gd` để ở `game/_probe_tmp/` (không commit).

**Yêu cầu thay đổi ngoài phạm vi:** không có.
