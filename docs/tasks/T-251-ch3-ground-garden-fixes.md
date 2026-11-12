# T-251 — Chương 3: tấm nền giả quanh nhà B, người chơi chồng lên Minh Nhật ở checkpoint vườn hoa, tán cây không va chạm
- Lane: A | Trạng thái: todo | Agent: tài khoản GPT lane A (`.codex-accountA`), Codex CLI, `D:\GAME_WORK\lane-a2`; integrator giao chạy ngầm (D-164).
- Nhánh: `lane-a/T-251-ch3-ground-garden-fixes` từ `origin/main` mới nhất.
- Quyết định giao: **D-166** (12/11/2026): chủ dự án chọn ẩn tấm nền giả ở chương 3–4 và giao lane Codex sửa hai lỗi cũ ở vườn hoa. Ba lỗi đều có từ trước, lane B tìm ra ở T-247 và T-249.

## 1. Ba lỗi
1. **Tấm nền giả quanh nhà B.** `Floor4/Room407/Furnished/outside/OutsideGround` (80 × 28 m) là cảnh nhìn ra cửa sổ phòng 407 ở chương 1–2. Nó nổi cao hơn mặt đất thật của khuôn viên 14 cm (−9,80 so với −9,94) và không có va chạm. Ở chương 3–4 (có `Campus`), trong vùng đó chân Trần Trung lún xuống và thanh sắt **B04** chìm dưới tấm nền, không thấy. Ảnh: `art_source/graphics_upgrade/protagonist/previews/t249/x_nen_gia_phong_407_chan_lun.jpg`; mô tả: `docs/tasks/T-249-protagonist-chapter3-bar.md` mục "Thấy thêm".
   - **Chủ dự án chọn: ẩn ở chương 3–4**, chương 1–2 giữ nguyên (cảnh nhìn qua cửa sổ). Xem trong `Furnished/outside` còn gì khác cũng thừa khi có Campus (trời, nhà nền giả…): ẩn cả nhóm nếu mọi thứ trong đó đều thừa ở chương 3–4, hoặc chỉ `OutsideGround` nếu có thứ còn cần; ghi lý do trong Handoff, kèm ảnh trước/sau từ cửa sổ phòng 407 và từ đường nội bộ cạnh nhà B ở chương 3.
2. **Checkpoint vườn hoa:** chơi lại từ checkpoint `garden` (hoặc `run_from(&"garden")`), người chơi và Minh Nhật cùng đặt ở `Start_garden`, người chơi đứng trên đầu Minh Nhật rồi rơi xuống (`tools/reports/T-247-ch3-body-survey.md` mục 2, ảnh `art_source/graphics_upgrade/protagonist/previews/t247/a3*`). Sửa để hai người đứng cạnh nhau, không chồng, đúng hướng đi tiếp; không đổi tuyến, thời gian hay lời thoại.
3. **Tán cây vườn hoa không có va chạm** (chỉ thân cây có): thân Trần Trung lẫn vào tán khi chạy sát (ảnh `t247/a4*`). Thêm va chạm cho phần tán **thấp tới tầm người** (từ sàn tới khoảng 2 m), vừa với hình tán; không lấn lối đi, không chặn tuyến đồng đội, xác sống, bot (`Campus/Anchors`, `Zones`, navigation). Nếu một cây nào thêm va chạm sẽ chặn tuyến thì không thêm cây đó, ghi lại.

## 2. Kiểm
- Test mới trong `game/tests/levels/` hoặc `game/tests/core/`: chương 3 và 4 không vẽ tấm nền giả (chương 1–2 vẫn vẽ); chạy từ `garden` thì người chơi và Minh Nhật cách nhau ≥ 0,6 m, không ai đứng trên ai; mọi tán cây vườn hoa thấp dưới 2 m có va chạm, không tán nào chạm các điểm tuyến đã có.
- Test cũ đạt: `test_chapter3`, `test_chapter4`, `test_ch3_*`, `test_t249_chapter3_bar`, `test_ch2_4_hand_targets`, `test_room407*`, `test_floor4*`. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit.
- Ảnh trước/sau 1080p vào `art_source/graphics_upgrade/realistic_map/previews/t251/`, tự xem lại.
- **Không chạy bot, không đo FPS.**

## 3. Được phép sửa
- Lỗi 1: `game/scenes/main/chapter1_main.gd` (chương 1–4 dùng chung; ẩn khi có `Campus`) hoặc `game/scenes/levels/room407/room407.gd`: chọn một chỗ, ghi lý do.
- Lỗi 2: `game/scripts/core/chapter3_director.gd` (chỗ đặt người chơi và đồng đội khi chạy từ checkpoint), hoặc anchor trong `game/scenes/levels/campus/`.
- Lỗi 3: `game/scenes/levels/campus/garden.tscn`, `game/scenes/levels/campus/foliage.gd`.
- Test mới, card này (Checklist, Handoff).

## 4. Không được
- Đổi luật, tuyến, thời gian, lời thoại, số xác sống; đổi chương 1–2.
- Sửa STATUS, DECISIONS; commit log, `anh_chup_sua_loi/`, `game/_probe_tmp/`.

## Checklist
- [ ] Lỗi 1: tấm nền giả ẩn ở chương 3–4, ảnh trước/sau
- [ ] Lỗi 2: checkpoint vườn hoa không chồng người
- [ ] Lỗi 3: va chạm tán cây, không chặn tuyến
- [ ] Test mới, test cũ, full test, check
- [ ] Handoff

## Handoff
(lane A điền)
