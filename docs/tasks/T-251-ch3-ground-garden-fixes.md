# T-251 — Chương 3: tấm nền giả quanh nhà B, người chơi chồng lên Minh Nhật ở checkpoint vườn hoa, tán cây không va chạm
- Lane: A | Trạng thái: **merged 13/11/2026** (full test 944/0, check 0), chủ dự án chơi thử bản `04ddc7d` đạt 13/11 | Agent: tài khoản GPT lane A (`.codex-accountA`), Codex CLI, `D:\GAME_WORK\lane-a2`; integrator giao chạy ngầm (D-164).
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
- [x] Lỗi 1: tấm nền giả ẩn ở chương 3–4, ảnh trước/sau
- [x] Lỗi 2: checkpoint vườn hoa không chồng người
- [x] Lỗi 3: va chạm tán cây, không chặn tuyến
- [ ] Test mới, test cũ, full test, check
- [ ] Handoff

## Handoff
### 12/11/2026 — Lane A (Codex, chạy ngầm D-164)

- Đầu phiên workspace sạch; `git fetch origin`, tạo nhánh `lane-a/T-251-ch3-ground-garden-fixes` từ `origin/main`, `git lfs pull`. Commit của card đã đọc: **`ee05aa5`**. Đã chạy `--headless --import` thành công trước lần mở cảnh đầu tiên; mọi lượt Godot dùng khóa CreateNew, xóa khóa mình trong `finally`.
- **Lỗi 1:** chọn `chapter1_main.gd::_ready`, vì đây là chỗ ghép chương và biết có `Campus`; phòng 407 độc lập và chương 1–2 giữ nguyên. Ẩn cả `Furnished/outside`: kiểm tra `build_outside.py` và cây node thực tế thấy tất cả là cảnh nền không va chạm (nhà đối diện, sân, cây, đèn, quần áo trên nhà giả, trời cầu bán kính 140 m). Campus đã có môi trường ngoài trời; giữ nhóm giả sẽ còn nhà/cây xuyên đường và trời che khuôn viên. Giữ ban công, đồ phơi thật của phòng, đèn phòng và toàn bộ va chạm cũ. Ảnh sau: chân và **B04** hiện trên nền thật; nhìn từ cửa kính/ban công phòng 407 thấy khuôn viên thay nhà nền giả.
- **Lỗi 2:** chỉ khi Minh Nhật được tạo mới ở vườn, đặt lệch +X **1,2 m** so với `Start_garden`. Người chơi giữ `(22, -9.9, 8)`; Minh Nhật `(23.2, -9.9, 8)`. Khi `_arrive` phải đặt lại người chơi ở vườn, quay về +Z (hướng vào vườn/ghế Ngư). Đồng đội đã đi cùng từ nhà B không bị dời. Không sửa anchor, tuyến, thời gian, lời hay hành vi đi theo.
- **Lỗi 3:** `garden.tscn` thêm 12 `StaticBody3D/CollisionShape3D`, layer world, dùng chung một `ConvexPolygonShape3D` 16 đỉnh đúng tán nón cụt tám cạnh (bán kính đáy 1,1 m, đỉnh 0,175 m, cao 1,6 m). Tán bắt đầu ở 1,2 m so với mặt lát, thấp tới tầm người; khối bám toàn tán tới 2,8 m để không tạo mặt đứng vô hình giữa tán. Tất cả nằm gọn trong bồn 6 × 4 m đã có va chạm, không cần bỏ cây nào hoặc sửa navigation. Không sửa `foliage.gd`: cây đường lớn có đáy tán từ 2,1 m, không thuộc lỗi tán thấp vườn hoa.
- **Test mới:** `game/tests/levels/test_t251_ground_garden.gd`, 5 ca: visibility từng mesh nhóm outside ở đủ bốn chương; `run_from(garden)`; khôi phục save `ch3_garden` qua `start()` (đo 30 khung vật lý, không chồng người); ray ở ba độ cao/bốn phía trên cả 12 tán và quét capsule người chơi thật; capsule tại mọi anchor và lấy mẫu đường navigation giữa waypoint đồng đội trong vườn. Lần đầu 4/1 do test lấy đường trước khi navigation ngoài trời đồng bộ xong; sửa chờ chính điểm vào vườn được đồng bộ, chạy lại **`RESULT: 5 passed, 0 failed`** (`build/t251/test_test_t251_ground_garden.log`).
- **Ảnh:** đã tự xem 8 JPG trong `art_source/graphics_upgrade/realistic_map/previews/t251/`. Cặp `before/after_01_window`: cửa kính phòng 407; `02_road_b04`: chân và B04; `03_garden_spawn`: checkpoint; `04_crown`: đẩy capsule vào cùng tán cây, trước x≈6,96, sau x≈7,40. Kiểm tra kích thước phát hiện cửa sổ Windows giới hạn 1920 × 1057; chờ lượt full test/check xong để chụp lại bằng viewport cố định 1920 × 1080. Cảnh tạm `game/_probe_tmp/` đã xóa; bản sao tái hiện ở `build/t251/probe_backup/`, không commit.
- **Kiểm cuối:** đang chạy full `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`; log ở `build/t251/full_test.log`, `build/t251/full_check.log` (không commit). Chưa có kết quả cuối tại thời điểm ghi mục này.
- **Đối chiếu profile bot (chỉ đọc JSON):** ba tọa độ khai báo trực tiếp thuộc vườn hoa `(42, -9.9, 36)`, `(20, -9.9, 36)`, `(20, -9.9, 28)` đều ngoài tán; khoảng hở nhỏ nhất sau khi trừ bán kính tán 1,1 m và capsule 0,3 m là **3,07 m**. Các điểm dùng anchor đã được kiểm bằng test vật lý. Không chạy bot.
- **Chờ chủ dự án:** chơi thử và xem ảnh sau merge; không có quyết định thiết kế mới cần chọn. Không chạy bot, không đo FPS, chưa chơi bằng tay.
- **Yêu cầu thay đổi:** không có. **Blocked:** không.

## Review integrator (13/11/2026)
- Lane A (chạy ngầm, D-164) làm xong code, 5 test mới và ảnh trước/sau rồi **hết hạn mức lúc 23:46 khi đang chạy full test**. Integrator commit phần đã làm lên nhánh (`da533fa`), gỡ khoá Godot bị bỏ lại (không còn tiến trình Godot nào), review và merge.
- Đạt, đúng phạm vi: `chapter1_main.gd` ẩn `Floor4/Room407/Furnished/outside` khi có `Campus` (chương 3–4); `chapter3_director.gd` khi chạy từ checkpoint vườn hoa đặt Minh Nhật cách người chơi 1,2 m và cho người chơi quay mặt về vườn; `garden.tscn` thêm khối va chạm hình nón cho 12 tán cây thấp.
- Sau merge: full test 944/0, check 0. Ảnh: `art_source/graphics_upgrade/realistic_map/previews/t251/`.

## Chơi thử
- 13/11/2026: chủ dự án chơi bản `04ddc7d` (gồm T-244, T-246, T-249, T-251) và xác nhận: "ok tôi đã chơi thử rồi, ổn đấy".
