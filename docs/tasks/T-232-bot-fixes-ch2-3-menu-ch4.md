# T-232 — Sửa bot chương 2–3 theo báo cáo T-230, thêm menu F9 chương 4
- Lane: C (QA và Tools) | Trạng thái: todo | Agent: tài khoản GPT lane C (D-139)
- Nhánh: `lane-c/T-232-bot-fixes-ch2-3-menu-ch4` từ `origin/main` mới nhất.
- Quyết định giao: **D-141** (chủ dự án duyệt 07/11). Tiếp nối báo cáo [T-230](T-230-bot-smoke-review-ch2-4.md) (`tools/reports/T-230-bot-review.md`, D-140).
- **Lượt này sửa và kiểm tĩnh. KHÔNG chạy bot** (`playthrough.ps1`, `*_bot.tscn`) và không đo FPS (`*_performance.tscn`). Chạy bot chương 2, 3 là lượt sau, khi chủ dự án cho phép.

## Bối cảnh
Báo cáo T-230 (integrator đã kiểm lại, đúng):
- **Chương 2, chắc chắn hỏng:** bước `wipe` ngắm (36.18, 1.45, −6.78), màn tắm đã dời tới x≈35.387 (D-109, `room407_anchors.tscn` `ShowerScreen` + offset phòng 30). Chặn mọi kịch bản đi tới vòng 4.
- **Chương 2:** chỗ đứng `bedroom` (33.5, 0.05, −2) chồng khối va chạm bàn gấp khoảng 7 cm (T-225). Các chỗ đứng khác chưa chồng nhưng chưa kiểm đường đi.
- **Chương 3:** profile không có bước dùng còi báo cháy tầng 1 (`Campus/Anchors/FireAlarm1F/Use_FireAlarm1F`) hay kiểm cờ `ch3_fire_alarm` (D-075). Chờ cố định 30 giây ở phòng 207 thay vì chờ tín hiệu.
- **Chương 4:** chưa có menu F9; `tools/qa-menu.ps1` chỉ nhận chương 1–3; `qa_menu.gd` chỉ nhận `Chapter1Director`. Director chương 4 đã có `run_from()` với 5 giai đoạn `split`, `library`, `return`, `room407`, `end4` (`chapter4_director.gd:12, 80`).

## Việc cần làm (theo ưu tiên)
1. **P1, lau màn tắm chương 2:** điểm ngắm lấy từ node `Wipe` thật (hoặc anchor `ShowerScreen`) lúc chạy, **không ghi cứng tọa độ mới**. Chọn chỗ đứng hợp lệ trước màn. Giữ nguyên luật lau (giữ nhìn đủ thời gian). Test chứng minh tia ngắm từ chỗ đứng chạm đúng node `Wipe` (chỉ dựng cảnh, không chạy bot).
2. **P1, chỗ đứng chương 2:** chọn chỗ đứng `bedroom` mới không chồng khối va chạm. Thêm test (hoặc mở rộng `profile_static_audit.gd`) kiểm **mọi chỗ đứng `goto`** của profile chương 2 và các waypoint chương 3 ra khỏi phòng 407: capsule người chơi (bán kính 0,3 m, cao 1,75 m) không chồng va chạm thế giới. Dùng truy vấn vật lý trên cảnh đã dựng hoặc tính từ khối va chạm; **không dời đồ, không sửa va chạm** để chiều bot.
3. **P1, báo cháy tầng 1 chương 3:** thêm bước dùng `Use_FireAlarm1F` vào tuyến chương 3 đúng chỗ trong cốt truyện (D-075), và mốc kiểm cờ `ch3_fire_alarm`. Đọc `chapter3_director.gd` (đoạn tạo báo cháy và kéo xác tầng 1) để đặt đúng thứ tự. Không đổi độ khó hay luật.
4. **P2:** thay chờ cố định 30 giây ở phòng 207 bằng chờ tín hiệu hoặc cờ có hạn, nếu director đã có tín hiệu phù hợp. Không có thì ghi "Yêu cầu thay đổi", giữ 30 giây.
5. **Menu F9 chương 4:** theo mẫu `ch3_menu.gd` và `ch3_menu_smoke`:
   - menu nhận `Chapter4Director`, nhảy 5 giai đoạn qua `run_from()`;
   - profile `tools/ch4-profile.json` chỉ chứa phần nhảy giai đoạn (`jumps`) và dữ liệu menu cần, **không có tuyến bot**;
   - `tools/qa-menu.ps1` nhận `-Chapter 4`, cảnh smoke `ch4_menu_smoke`;
   - test trong `game/tests/tools/` kiểm menu nhảy đủ 5 giai đoạn (theo mẫu `test_ch2_menu.gd`).
6. **Cập nhật** `tools/reports/T-230-bot-review.md` mục 7 (bảng ưu tiên): đánh dấu việc nào đã sửa, ở commit nào.

## Được phép sửa
- `tools/ch2-profile.json`, `tools/ch3-profile.json`, `tools/ch4-profile.json` (mới), `tools/qa-menu.ps1`, `tools/reports/T-230-bot-review.md`.
- `game/scripts/debug/` (bot, action, policy, menu chương 2–4, `profile_static_audit.gd`, cảnh smoke menu mới).
- `game/tests/tools/`, `game/tests/smoke/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- **Không chạy bot, launcher playthrough, cảnh performance, không đo FPS.** Chạy menu smoke (`pwsh tools/qa-menu.ps1 -Chapter <n> -Smoke`) được, theo luật Lượt Godot.
- Không sửa scene, script gameplay, core, level. Cần tín hiệu hay API mới thì ghi "Yêu cầu thay đổi".
- Không đổi luật, thời gian, độ khó để bot dễ qua.
- Không tiêu credit Tripo.

## Checklist hoàn thành
- [ ] Bước lau màn ngắm theo node thật, có test tia ngắm
- [ ] Mọi chỗ đứng chương 2 và đoạn ra khỏi phòng 407 chương 3 không chồng va chạm, có test
- [ ] Tuyến chương 3 có bước báo cháy tầng 1 và kiểm cờ
- [ ] Menu F9 chương 4 nhảy đủ 5 giai đoạn, có test; `qa-menu.ps1 -Chapter 4 -Smoke` đạt
- [ ] Báo cáo T-230 mục 7 cập nhật
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [ ] Handoff trung thực, có commit hash, ước lượng lại thời gian chạy bot từng chương

## Cách kiểm tra
- `pwsh tools/test.ps1 -Filter tools` khi đang làm; full test và check trước khi commit.
- Integrator đọc diff, chạy lại test lọc; chủ dự án quyết lượt chạy bot.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
