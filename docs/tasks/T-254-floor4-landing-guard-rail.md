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
- [ ] Hình lan can hai cầu thang
- [ ] Va chạm hai lan can
- [ ] Test, full test, check, ảnh
- [ ] Handoff

## Handoff
(lane B điền)
