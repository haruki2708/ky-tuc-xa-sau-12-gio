# Prompt bàn giao — Lane C (QA và Tools)

> **31/10/2026, D-139:** lane C là tài khoản GPT chạy Codex CLI trên máy này, workspace `D:\GAME_WORK\lane-c2`. Việc thử T-230 đạt (D-140). Bàn giao gốc: [BAN_GIAO_LANE_ABC_2026-10-31.md](BAN_GIAO_LANE_ABC_2026-10-31.md). Prompt cũ xem lịch sử git của file này.
>
> **07/11/2026, D-141:** lane B chuyển cho một tài khoản Claude, âm thanh là lane E (tài khoản GPT từng làm B). Lane C giữ nguyên. Việc hiện tại: **T-232 sửa bot chương 2–3, menu F9 chương 4**.

## 1. Prompt giao việc hiện tại: T-232 sửa bot chương 2–3, menu F9 chương 4 (dán nguyên khối, phiên mới)
```text
Việc mới cho lane C (QA và Tools): T-232 sửa bot chương 2–3, menu F9 chương 4 — đọc docs/tasks/T-232-bot-fixes-ch2-3-menu-ch4.md.
Bạn là agent lane C của game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Integrator là Claude Code ở máy (Opus 5.5) làm ở D:\GAME_DEMO. Chủ dự án quyết mọi việc thiết kế.
Trả lời và viết tài liệu bằng tiếng Việt; code, comment, commit message bằng tiếng Anh.
Từ 07/11 (D-141): lane B là một tài khoản Claude ở D:\GAME_WORK\lane-b2, lane E (âm thanh) ở D:\GAME_WORK\lane-e2. Không sửa thư mục của lane khác.

1. Ở D:\GAME_WORK\lane-c2: git status (giữ thay đổi đang có), git fetch origin, git switch main, git pull --ff-only, git lfs pull.
   Tạo nhánh lane-c/T-232-bot-fixes-ch2-3-menu-ch4 từ origin/main.
2. Đọc lại AGENTS.md (đã đổi theo D-141), mục Review của card việc trước docs/tasks/T-230-bot-smoke-review-ch2-4.md, rồi card docs/tasks/T-232-bot-fixes-ch2-3-menu-ch4.md.
3. Làm đúng card. Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi" trong Handoff, không tự sửa.
   Không chạy bot, không đo FPS, không tiêu credit Tripo. Thiết kế không rõ thì đưa phương án kèm đề xuất và hỏi chủ dự án.
4. Godot theo luật "Lượt Godot" (AGENTS.md mục 4, file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt).
   Khi đang làm: pwsh tools/test.ps1 -Filter <tên test>. Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1,
   rồi git checkout -- game/default_bus_layout.tres. Log để trong build/, không commit log.
5. Commit nhỏ "T-232: ...", git push -u origin lane-c/T-232-bot-fixes-ch2-3-menu-ch4. Không push main, không mở PR.
6. Cập nhật Checklist và Handoff trong card: đã làm, còn dở, cách kiểm tra, dòng RESULT test và check, commit hash,
   yêu cầu thay đổi, phần chưa kiểm. Ghi trung thực. Không sửa STATUS hay DECISIONS.
7. Cuối phiên báo lại ngắn gọn bằng tiếng Việt cho chủ dự án: xong gì, nhánh, commit, có bị chặn không.
```

## 2. Prompt tiếp tục (phiên sau)
```text
Tiếp tục T-232 ở D:\GAME_WORK\lane-c2, nhánh lane-c/T-232-bot-fixes-ch2-3-menu-ch4.
Kiểm git status, git fetch origin, rebase an toàn lên origin/main nếu main có thay đổi mới (không mất thay đổi cục bộ).
Đọc lại AGENTS.md và mục Handoff trong docs/tasks/T-232-bot-fixes-ch2-3-menu-ch4.md để biết lần trước dừng ở đâu.
Làm tiếp phần còn dở, bàn giao theo bước 4–7 của prompt mục 1.
```

## 3. Prompt yêu cầu sửa (khi integrator trả lại)
```text
Integrator trả T-232. Ở D:\GAME_WORK\lane-c2: git fetch origin, đọc mục Review trong origin/main:docs/tasks/T-232-bot-fixes-ch2-3-menu-ch4.md
(hoặc nội dung chủ dự án dán kèm). Rebase lane-c/T-232-bot-fixes-ch2-3-menu-ch4 lên origin/main, sửa đúng từng ý trong phạm vi được phép.
Chạy full test và check theo luật Lượt Godot, cập nhật Handoff, push nhánh, báo lại phần đã sửa và phần chưa kiểm.
```

## 4. Giao việc khác (integrator điền)
Dùng prompt mục 1, thay số việc, card, nhánh `lane-c/T-xxx-...` và card việc trước.
