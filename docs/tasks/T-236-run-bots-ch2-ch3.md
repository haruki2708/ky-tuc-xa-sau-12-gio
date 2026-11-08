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
- [ ] Chương 2 ca good và chương 3 ca good đã chạy, có kết quả thật
- [ ] Các ca còn lại đã chạy, hoặc ghi rõ vì sao dừng
- [ ] Lỗi của bot đã sửa, có test; lỗi của game ghi trong "Yêu cầu thay đổi"
- [ ] Báo cáo `tools/reports/T-236-bot-run.md`
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt nếu có sửa code (luật Lượt Godot)
- [ ] Handoff trung thực, có commit hash

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
