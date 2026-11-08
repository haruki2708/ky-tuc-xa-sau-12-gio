# T-236 — Chạy bot chương 2 và 3 sau lượt sửa T-232
- Lane: C (QA và Tools) | Trạng thái: todo | Agent: tài khoản GPT lane C (D-139)
- Nhánh: `lane-c/T-236-run-bots-ch2-ch3` từ `origin/main` mới nhất.
- Quyết định giao: **D-145** (08/11/2026, chủ dự án cho phép chạy bot chương 2–3). Tiếp nối [T-230](T-230-bot-smoke-review-ch2-4.md) (báo cáo `tools/reports/T-230-bot-review.md`) và [T-232](T-232-bot-fixes-ch2-3-menu-ch4.md) (sửa bot, chưa chạy thật).

## Mục tiêu
Biết thật bot chương 2 và 3 có chạy hết chương không, sau các sửa của T-232 (lau màn tắm ngắm node thật, chỗ đứng kiểm capsule, báo cháy tầng 1). Chỗ nào bot kẹt thì tìm nguyên nhân: lỗi của bot (sửa trong phạm vi C) hay lỗi của game (báo lại, không tự sửa).

## Việc cần làm
1. **Chạy từng ca một**, bằng `tools/playthrough.ps1`, theo thứ tự:
   1. chương 2 ca good;
   2. chương 3 ca good;
   3. nếu hai ca good đạt: các ca còn lại của chương 2 (chain, scald, leave, wrong_prediction…) rồi chương 3 (grabbed, guard…).
   **Ca đầu tiên lỗi thì dừng chạy tiếp**, phân tích log và ảnh/khung hình trước khi chạy ca khác.
2. **Mỗi ca là một lượt Godot** (luật Lượt Godot, `AGENTS.md` mục 4): lấy khóa bằng CreateNew, chạy, xóa khóa khi xong kể cả khi lỗi. Chạy bằng tiến trình pwsh riêng ghi log trong `build/t236/` để khỏi bị dừng khi máy thiếu RAM. Giữa hai ca, nhả khóa để lane khác (lane B đang làm T-235, integrator) có lượt.
3. **Lỗi của bot** (profile, tuyến, ngắm, thời gian chờ, kiểm mốc): sửa trong `tools/`, `game/scripts/debug/`, `game/tests/tools/`, kèm test không chạy bot nếu được. Chạy lại đúng ca đó.
4. **Lỗi của game** (kẹt va chạm, luật/đạo diễn chương sai, cửa không mở, chết vô lý): **không sửa**. Ghi vào "Yêu cầu thay đổi": chương, ca, bước, vị trí, log, ảnh, đề xuất người sửa (integrator, B, A).
5. **Báo cáo** `tools/reports/T-236-bot-run.md`: bảng từng ca (chương, ca, kết quả PASS/FAIL/chưa chạy, thời gian chạy thật, bước dừng nếu lỗi, nguyên nhân, đã sửa gì); so thời gian thật với ước lượng mục 7 của báo cáo T-230.

## Được phép
- Chạy bot chương 2 và 3 (chủ dự án cho phép, D-145). Không chạy bot chương 1, không đo FPS.
- Sửa: `tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/tools/`, `tools/reports/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa game: core, director, level, scene, gameplay, UI, âm thanh. Không nới luật, độ khó hay thời gian của game để bot qua.
- Không sửa `docs/` ngoài card này (lần trước C sửa `docs/handoff/lane-c.md`; integrator đã bỏ).
- Không commit log, khung hình, video (để trong `build/`).
- Không chạy hai ca cùng lúc, không giữ khóa Godot qua nhiều ca liền.

## Checklist hoàn thành
- [x] Chương 2 ca good và chương 3 ca good đã chạy, có kết quả thật
- [x] Các ca còn lại đã chạy, hoặc ghi rõ vì sao dừng
- [x] Lỗi của bot đã sửa, có test; lỗi của game ghi trong "Yêu cầu thay đổi"
- [x] Báo cáo `tools/reports/T-236-bot-run.md`
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt nếu có sửa code (luật Lượt Godot)
- [ ] Handoff trung thực, có commit hash

## Handoff (agent điền)
### Phiên 08/11/2026

- Nền `894d871`, nhánh `lane-c/T-236-run-bots-ch2-ch3`; workspace sạch khi bắt đầu, đã fetch/rebase an toàn sau lần phiên bị ngắt. Đã đọc Review T-232; không sửa docs ngoài card này.
- Đã chạy duy nhất `ch2_good` lượt 01 bằng pwsh riêng, TimeScale=1, RequireComplete, Capture, khóa CreateNew và trả khóa khi xong. FAIL 235,88 giây (bot), launcher 244,55 giây: không nhận `wiped` đầu vòng 4. Các ca khác chưa chạy theo quy tắc dừng ca đầu lỗi.
- Phân tích: bot lau khi vẫn ở bedroom trước lựa chọn tắm đầu tiên. Đã sửa lịch định vị tới `leave_shower` trước lần lau đầu, thêm test lịch thao tác không chạy chương; bổ sung action/segment/vị trí và ảnh khi physical action lỗi.
- Bằng chứng/chi tiết: `tools/reports/T-236-bot-run.md`; log/ảnh trong `build/t236/01-ch2-good/`, không commit.
- Test lọc `pwsh tools/test.ps1 -Filter test_ch2_shower_start`: `RESULT: 2 passed, 0 failed` (exit 0), log `build/t236/shower-start-test.log`. Lượt 02 ch2_good bắt đầu 15:10:53, log `build/t236/02-ch2-good/`, bản vá tương ứng `bot.patch`.
- Lượt 02 ch2_good FAIL 239,32 giây tại Wipe, vị trí thực đã đúng `(36.18, 0.00039, -5.2)`. Ảnh lỗi và mã player xác nhận hiệu ứng đẩy cửa xóa góc camera mà bot đặt. Đã sửa ngắm bằng yaw thân/pitch Head trong ch2_actions; fixture bật physics, kích hoạt rung cửa và lau thật đạt `RESULT: 1 passed, 0 failed` (exit 0), log `build/t236/wipe-physics-test.log`. Lượt 03 PASS: bot 590,31 giây, wrapper 606,40 giây, exit 0, `RESULT: playthrough 1 passed, 0 failed`; ảnh, log và phân tích đủ trong báo cáo.
- Ch3 good: lượt 04–05 FAIL do bot đọc nav cũ sau mở cửa; sửa chờ đường qua FireDoorLink. Lượt 06 FAIL khi sprint ra nấp; lượt 07 cúi qua cửa nhưng va Minh Nhật, bị xác phía sau bắt; sửa tuyến tránh qua z=3. Lượt 08 qua nhà B nhưng timeout garden vì điểm cuối P13 nằm ngay mép vùng và bot dừng trước mép. Đã sửa điểm vào `(20, -9.9, 26)`, test nav/clearance đạt 1/0 (`build/t236/ch3-stage-entry-nav.log`). Chi tiết mọi lượt trong báo cáo.
- Phiên tiếp tục: fetch/rebase an toàn lên `9578ec2` (main chỉ đổi docs D-147), giữ đủ thay đổi chưa commit; khóa lượt 08 đã tự nhả, không có Godot tồn dư. Lượt 09–10 đã vào garden nhưng bị xác bắt trước khi nhận thanh sắt; đã phân tích cả đường nav, sửa tuyến vòng phía đông và đi cúi sau lưng đàn idle, test profile đạt 1/0 (`ch3-garden-east.log`). Đang chạy lượt 11 ch3_good, log `build/t236/11-ch3-good/`, pwsh PID 49740. Chưa chạy ca âm vì ch3_good chưa đạt. Full test/check chưa chạy trên sửa đổi T-236. Commit: chưa có.
- Yêu cầu thay đổi: chưa có bằng chứng lỗi game; lỗi lần đầu thuộc bot.
- Blocked: chưa có; đang xác minh bản sửa bot.

### Phiên kết thúc 08/11/2026 — Claude làm thay (lane C hết hạn mức)

- Lane C hết hạn mức sau lượt 12, khi tuyến vào sân vận động phía nam đã sửa và test profile đạt 1/0. Integrator chạy lượt 13 bằng `build/t236/run_case.ps1` của lane C (khóa CreateNew, tự trả): bot 469,13 giây, FAIL trong vòng sống sót sân vận động (bị tóm khi đi tới P22, thanh sắt còn 7 lượt). Lượt này qua mọi mốc ch3 trước sân, gồm `sound_fire_alarm`.
- **Kết quả:** ch2 good **PASS** (lượt 03, 9:50); ch3 good **chưa đạt** sau 13 lượt (dừng ở vòng sống sót sân vận động, do chiến thuật bot). Ca âm ch2 (5) và ch3 (2) **chưa chạy**: integrator dừng để giao việc tiếp, xem Kết luận trong báo cáo.
- **Đề xuất việc sau cho lane C:** chiến thuật vòng sống sót sân vận động của bot; rồi các ca âm.
- **Yêu cầu thay đổi:** không có; chưa có bằng chứng lỗi game. Gợi ý cho chủ dự án về độ khó chương 3 ghi trong Kết luận báo cáo.
- **Kiểm tra:** test lọc của lane C ghi trong báo cáo (lịch thao tác 2/0, vị trí/lau 1/0, đánh 1/0, profile 1/0). Full test và check: integrator chạy một lần trên `main` sau khi merge nhánh này cùng việc của integrator, kết quả ghi trong mục Review.
- Commit: xem `git log` nhánh `lane-c/T-236-run-bots-ch2-ch3` (commit của Claude làm thay).
