# T-232 — Sửa bot chương 2–3 theo báo cáo T-230, thêm menu F9 chương 4
- Lane: C (QA và Tools) | Trạng thái: done (merge 08/11/2026) | Agent: tài khoản GPT lane C (D-139)
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
- [x] Bước lau màn ngắm theo node thật, có test tia ngắm
- [x] Mọi chỗ đứng chương 2 và đoạn ra khỏi phòng 407 chương 3 không chồng va chạm, có test
- [x] Tuyến chương 3 có bước báo cháy tầng 1 và kiểm cờ
- [x] Menu F9 chương 4 nhảy đủ 5 giai đoạn, có test; `qa-menu.ps1 -Chapter 4 -Smoke` đạt
- [x] Báo cáo T-230 mục 7 cập nhật
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [x] Handoff trung thực, có commit hash, ước lượng lại thời gian chạy bot từng chương

## Cách kiểm tra
- `pwsh tools/test.ps1 -Filter tools` khi đang làm; full test và check trước khi commit.
- Integrator đọc diff, chạy lại test lọc; chủ dự án quyết lượt chạy bot.

## Handoff (agent điền)
### Phiên 07–08/11/2026 — lane C

- Nền `origin/main`: `85598c6`; nhánh `lane-c/T-232-bot-fixes-ch2-3-menu-ch4`. Commit triển khai: `a1172c587a52bdf8b3f84afcb132d1055fdb409c` (`T-232: Fix chapter bot targets and add chapter four QA menu`).
- Đã sửa: `wipe` ngắm node Wipe runtime, giữ nguyên hold 1,1 giây. Capsule/ray fixture không chạy bot kiểm toàn bộ điểm goto ch2 và hai điểm ch3 ra 407. Ngoài bedroom chồng bàn gấp, truy vấn phát hiện pickup_rag chồng BathroomSide, gag_4 chồng BunkB, hai điểm ch3 ở y=0 chồng sàn; đã chỉnh các tọa độ profile, không dời đồ hay sửa va chạm. Điểm bedroom cũ được giữ làm ca hồi quy âm để chứng minh truy vấn bắt được lỗi.
- Đã thêm báo cháy tầng 1 sau Nhat/P05, trước P06; action gọi Use_FireAlarm1F thật, kiểm cờ `ch3_fire_alarm`; preflight yêu cầu binding và bot good yêu cầu mốc này. Test hợp đồng hiện có mở rộng kiểm action và endpoint navmesh. Không chạy tuyến bot.
- Đã thêm menu F9 ch4 với split/library/return/room407/end4, tạo scene mới, gọi director `run_from()`, phiên/save riêng; profile chỉ có dữ liệu menu. Launcher nhận chương 4 và smoke riêng. Test menu phát hiện audio rig còn chờ `add_child.call_deferred`; đã sửa menu chờ một frame sau gắn scene trước `run_from`, không sửa audio/core. Có test năm điểm nhảy, F9 pause/unpause, và phiên chưa cách ly chỉ yêu cầu mở child.
- Báo cáo T-230 chỉ cập nhật mục 7, giữ bằng chứng cũ ở các mục khác.

**Kiểm tra**

- Khi phát triển: test vị trí ban đầu FAIL đúng các chồng lấn trên, sau sửa `RESULT: 1 passed, 0 failed`; test menu ban đầu có engine error audio, sau sửa `RESULT: 2 passed, 0 failed` (exit 0). Log lần chạy hiện hành: `build/t232/positions.log`, `menu-test.log`.
- Test nhóm tools: `RESULT: 50 passed, 0 failed` (exit 0), log `build/t232/tools-test.log`. Smoke: `RESULT: qa-menu PASS chapter4 (five stage jumps, F9)` (exit 0), log `build/t232/menu-smoke.log`; artifacts `build/qa-menu/90caf4bfa05d4de0b55be362a0c23a58/`. Đã xem ảnh `ch4-menu.png`: đủ năm nút tiếng Việt, không cắt chữ. Phiên tiếp tục 08/11: `git fetch origin` xác nhận HEAD và origin/main cùng `85598c6`, không cần rebase; giữ nguyên mọi thay đổi chưa commit. Lệnh chờ từ phiên trước vẫn sống (PID 51564), đã lấy khóa lane C và bắt đầu full test lúc 00:31:15; xác nhận Godot lane-c2 đang chạy, không xóa khóa và không chạy trùng. Lượt full đầu kết thúc 00:54:09 với `RESULT: 858 passed, 2 failed` (exit 1): hai ca `test_reading.gd::test_modal_conflicts_invalid_document_and_removal_cleanup` và `test_notebook_empty_tab_and_escape`. Nguyên nhân fixture ch4 gọi `GameState.reset()` nhưng hàm này giữ số chương 4, làm sổ tay ở test sau không pause. Đã sửa fixture khôi phục `GameState.to_dict()` ban đầu bằng `from_dict()`; không sửa UI/core. Đã dừng riêng cây tiến trình check của lane C đang chạy để kiểm lại bản sửa; lượt check dừng giữa chừng không có RESULT, không tính PASS. Log cũ: `full-test-initial-fail.log`, `check-interrupted.log`, `gate-exits-initial.txt`. Test menu sau sửa: `RESULT: 2 passed, 0 failed` (exit 0, `menu-test-final.log`). Full chạy lại 00:56:52–01:19:48 ngày 08/11: `RESULT: 860 passed, 0 failed` (exit 0, `full-test.log`); hai ca sổ tay từng lỗi đều PASS. Lượt check sau full bị ngắt khi phiên đổi, dừng sau `test_gaze_detector.gd`, không có RESULT; log giữ tại `check-session-interrupted.log`. Lúc 01:35 xác nhận không còn Godot/check của C, thu hồi đúng khóa C bỏ dở theo yêu cầu chủ dự án; đã chạy lại riêng check lúc 01:35:27–01:49:37: `RESULT: check 0 error(s)` (exit 0, `build/t232/check.log`, `gate-exits.txt`). Không chạy lại full vì mã không đổi. Khóa Godot đã được xóa trong finally; đã chạy `git checkout -- game/default_bus_layout.tres` trước commit.
- Cách kiểm lại: `pwsh tools/test.ps1 -Filter tools`; `pwsh tools/qa-menu.ps1 -Chapter 4 -Smoke`; trước commit full `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`, theo lượt Godot. Log giữ ở `build/t232/`, không commit.
- Sự cố điều phối lượt: một lệnh lấy khóa thiếu Stop gặp khóa lane E nhưng finally vẫn xóa khóa. Không khởi chạy Godot C từ lệnh lỗi, không tắt tiến trình E. Đã khôi phục khóa ghi rõ lane E/PID 45096; sau đó tiến trình E kết thúc và file khóa không còn. Các lệnh tiếp theo dùng CreateNew với Stop, chỉ vào try chạy sau khi lấy khóa thành công và chỉ xóa nếu nội dung vẫn đúng khóa mình tạo. Các test lọc ngắn chạy khi E còn hoạt động theo ngoại lệ mục 4.

**Yêu cầu thay đổi**

- Core/integrator: hiện `_watch_crowd_pull()` chỉ đổi biến riêng `_crowd_pull_active` về false; cờ `ch3_alarm` chỉ xác nhận đã gây tiếng động, không xác nhận đám đông đã rời cửa. Đề nghị cung cấp cờ hoặc signal công khai hoàn tất kéo đám đông 203 (reset khi bắt đầu kéo và khi reset chương), để C thay wait phòng 207 bằng chờ có timeout. T-232 giữ nguyên 30 giây theo card, không đọc biến riêng làm hợp đồng và không tự sửa core. Chưa có thay đổi thiết kế cần chủ dự án chọn.

**Còn dở / phần chưa kiểm**

- Chưa chạy bot/playthrough, chưa đo FPS, không dùng Tripo. Chưa chứng minh bot vượt toàn tuyến, sweep capsule giữa các điểm, phản ứng đám đông/cửa, ray/reach các action ngoài Wipe, trải nghiệm/chất lượng hình ảnh hoặc các kết chương 4. Smoke chỉ nhảy tới đầu năm stage và mở/đóng F9.
- ETA sau sửa (ước lượng, không phải số đo): ch2 good 12–25 phút, chain 1–5 phút/case, scald/leave 4–10 phút/case, wrong_prediction 8–18 phút, tổng sáu case 30–75 phút; ch3 good 12–30 phút, grabbed/guard 1–6 phút/case, tổng 15–45 phút. Bước báo cháy thêm vài giây dự trù, chưa đo; wait207 vẫn 30 giây. Ch4 chưa có bot nên không có ETA bot. Giữ trần bảo vệ cũ, không đồng nhất timeout với ETA.
- Blocked: chưa có; phần chuyển wait207 sang tín hiệu phụ thuộc yêu cầu core trên và được card cho phép hoãn. Các cổng kiểm tra đã đạt; phần triển khai đã commit `a1172c5`, sẵn sàng integrator review. Bàn giao riêng tại `docs/handoff/lane-c.md` theo yêu cầu chủ dự án phiên tiếp tục. Không còn việc triển khai dở trong phạm vi T-232; phần wait207 và những phần chưa kiểm nêu trên giữ nguyên giới hạn.

## Review (integrator, 08/11/2026)
- **Đạt, merge vào `main`** (merge `c68c27d`). Wipe ngắm node thật (`aim_path`), test capsule cho mọi điểm goto ch2 và hai điểm ra 407 ch3, báo cháy tầng 1 thành mốc bắt buộc của bot ch3, menu F9 chương 4 năm điểm nhảy kèm smoke. Không chạy bot, không sửa level/core.
- Sửa fixture menu ch4 khôi phục `GameState` bằng snapshot, sau khi full đầu lỗi 2 test sổ tay: tìm đúng nguyên nhân, không né test.
- **Bỏ khi merge:** mục 5 thêm vào `docs/handoff/lane-c.md` (`docs/` là của integrator; nội dung đã có trong card). Lần sau ghi bàn giao vào card, không sửa file handoff.
- Nhãn menu ch4 viết cứng trong script debug, cùng cách menu ch2/ch3 đã có; chấp nhận cho công cụ QA, không phải chữ của game.
- Yêu cầu core (cờ/signal công khai khi kéo đám đông 203 xong, để thay wait 30 giây phòng 207): ghi nhận, làm khi giao lượt bot tiếp theo.
- Integrator chạy lại sau merge A + C: full `RESULT: 863 passed, 0 failed`; check `RESULT: check 0 error(s)`.
