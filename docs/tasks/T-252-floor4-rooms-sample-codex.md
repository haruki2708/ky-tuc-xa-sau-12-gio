# T-252 — Mẫu thử đồ hoạ thật bằng lane Codex: các phòng 401–406, 408 nhìn qua cửa (đợt 10, khu A03)
- Lane: C | Trạng thái: todo | Agent: tài khoản GPT lane C (`.codex-accountC`), Codex CLI, `D:\GAME_WORK\lane-c2`; integrator giao chạy ngầm (D-164).
- Nhánh: `lane-c/T-252-floor4-rooms-sample` từ `origin/main` mới nhất.
- Giao việc: 13/11/2026, chủ dự án đồng ý cho một lane Codex làm thử đồ hoạ (theo D-166). **Mục đích kép:** (1) các phòng khác ở tầng 4 nhìn qua cửa có nội thất thật thay PS1; (2) biết lane Codex dựng Blender có đạt chất lượng phòng 407 không, để các đợt sau chia cho nhiều lane. **Chỉ merge khi chủ dự án xem ảnh và đồng ý.**

## 1. Chủ dự án đã chốt (D-166)
- Đồ hoạ thật, **dựng bằng Blender**, chân thực **như đồ phòng 407** (không PS1, không Tripo). Cũ vừa phải như phòng 407 và hành lang tầng 4.
- Ánh sáng giữ như hiện nay.

## 2. Khu A03 (`art_source/graphics_upgrade/realistic_map/PLAN.md` mục 2–4)
- Scene và node: `game/scenes/levels/floor4/corridor.tscn` → `RoomInterior_*`, `Floor_*`, `BackWall_*`, `RoomPartition_*` (38,2 × 5,1 × 3,35 m; hiện 756 tam giác, 6 vật liệu). Ảnh hiện trạng: `realistic_map/previews/survey/05_floor4_rooms.jpg`, `06_floor4_408.jpg`.
- Làm: **một module phòng ký túc 4 × 5 m** (vách, sàn, trần, cửa sổ phía sau, hai giường tầng, bàn, tủ, vài đồ sinh hoạt; bản nhẹ của bộ đồ phòng 407), dùng cho 401–406; phòng **408 rộng hơn** (thật ở X = 38…44; dấu bịt cửa cũ ở X = 36) làm theo đúng kích thước của nó. Mỗi phòng xoay, đổi vài đồ cho khỏi giống hệt nhau.
- Người chơi chỉ **nhìn qua cửa** (đứng ngoài hành lang, 1–8 m): làm kỹ phần thấy được từ cửa, không làm thêm chỗ chơi, không cho vào phòng nếu bây giờ không vào được.
- Giữ: cửa G5 (T-237) và khung cửa, phòng 407, va chạm, lối đi, các node mà director và test đang tìm; cửa phòng nào mở ở chương nào giữ như cũ.
- Ngân sách (PLAN mục 6): A03 và A04 cộng lại ≤ 0,35 ms; phòng có cửa đóng thì ẩn nội thất; đồ nhỏ không cần chi tiết như đồ phòng 407 khi chỉ thấy từ xa.

## 3. Cách làm
1. Đọc cách đã dựng: hành lang tầng 4 (`art_source/graphics_upgrade/floor4_corridor/` `build_corridor.py`, `corridor_layout.py`, `README.md`: hành lang sinh bằng script) và đồ phòng 407 (`art_source/graphics_upgrade/room407_furnished/`, `room407_shell/`, `game/assets/models/graphics_pilot/room407_*`). Dùng lại vật liệu CC0 và mô hình phòng 407 (bản nhẹ hơn nếu cần), ghi nguồn.
2. Script Blender trong `art_source/graphics_upgrade/realistic_map/floor4_rooms/`, glb trong `game/assets/models/graphics_pilot/realistic_map/floor4_rooms/`. Blender: `D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P <script>`.
3. Thay phần hình PS1 (`RoomInterior_*`…) bằng module mới, giữ nguyên va chạm.
4. Ảnh trước/sau 1080p, chụp ở chương 1 thật và chương 3 thật, đứng ngoài hành lang nhìn vào từng cửa đang mở và nhìn dọc hành lang: `art_source/graphics_upgrade/realistic_map/previews/t252/`, kèm một ảnh ghép trước/sau cho chủ dự án. Tự xem lại từng tấm; ảnh nào tối quá thì chụp thêm có đèn pin.
5. Ghi số tam giác, vật liệu, dung lượng; **không đo FPS, không chạy bot**.

## 4. Kiểm
- Test mới `game/tests/levels/test_t252_floor4_rooms.gd`: mỗi phòng 401–406, 408 có nội thất mới hiện ở đúng chỗ, PS1 cũ không còn vẽ; va chạm, cửa, các node cũ còn nguyên; tổng tam giác trong ngân sách đã ghi.
- Test cũ đạt (`test_floor4*`, `test_room407*`, `test_chapter1`…`test_chapter4`, `test_graphics_bindings`). Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## 5. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/floor4_rooms/`, `.../previews/t252/`, `game/assets/models/graphics_pilot/realistic_map/floor4_rooms/`, `game/assets/textures/` (vật liệu CC0 mới), `game/scenes/levels/floor4/corridor.tscn` (chỉ phần hình A03) và script dựng hành lang trong `art_source/graphics_upgrade/floor4_corridor/` nếu hành lang phải sinh lại, test mới trong `game/tests/levels/`, card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 6. Không được
- Đụng `duty_desk.tscn`, `building_b.tscn` (lane B đang làm T-250), phòng 407, cửa G5, director, luật.
- Tripo, credit Tripo; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Module phòng 4 × 5 m và phòng 408, Blender, vật liệu CC0
- [ ] Thay PS1 trong `corridor.tscn`, va chạm giữ nguyên
- [ ] Ảnh trước/sau chương 1 và 3, ảnh ghép
- [ ] Test mới, test cũ, full test, check
- [ ] Handoff (số tam giác, vật liệu, chỗ chưa ưng)

## Handoff
- Tiếp tục 13/11/2026 từ WIP `0fa724e` do integrator lưu. Workspace sạch lúc nhận lại; đã fetch/pull và rebase an toàn lên `origin/main=369a6c8` (WIP sau rebase `5105e60`). Commit card đã đọc: `a64361d`. T-250 chưa nằm trong `origin/main` ở thời điểm fetch; integrator đang giữ lượt Godot để kiểm bản merge.
- Đã dựng 7 GLB bằng Blender, giảm đồ lặp xuống 65% lưới gốc: 12.432 tam giác/phòng, tổng 87.024 cho bảy phòng; 8 vật liệu dùng chung, 699.520 byte GLB (không nhúng lại texture). Rèm cũng ẩn khi đóng cửa; bảy vỏ phòng còn 8.064 tam giác khi tất cả cửa đóng. Tái dùng 7 scan CC0 của phòng 407; nguồn đầy đủ ở `art_source/graphics_upgrade/realistic_map/floor4_rooms/CREDITS.md`.
- Đã gắn module vào riêng A03 của `corridor.tscn`, ẩn hình PS1, giữ node/collider/cửa. Script hình ảnh chỉ đọc trạng thái/góc cửa, ẩn đồ khi đóng; giữ vỏ phòng để không thủng mặt nhà.
- **Đang làm:** import đầu phiên, ảnh trước/sau chương 1 và 3, tự xem ảnh, test và check. Chưa có RESULT kiểm tra; không coi bản WIP là đã đạt. Runner đang chờ khóa của integrator, kiểm lại mỗi 30 giây và không xóa khóa người khác.
- Lựa chọn mỹ thuật: giường sắt xanh, bàn gỗ, tủ thép, chăn/gối/rèm cùng họ vật liệu 407; mức cũ vừa phải, **chờ chủ dự án chọn**. Chưa đo/nghiệm thu ngân sách A03–04 ≤0,35 ms; không đo FPS, không bot.
- Ảnh dự kiến: `art_source/graphics_upgrade/realistic_map/previews/t252/`. Hai góc hành lang giữ cửa đóng đầu chương; góc nội thất mở bằng API cửa để kiểm hình, sẽ ghi rõ `inspection` (director không chạy, không giả là lượt chơi).
- Yêu cầu thay đổi ngoài phạm vi: chưa có.
