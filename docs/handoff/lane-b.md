# Prompt bàn giao — Lane B (Môi trường và 3D)

> **31/10/2026, D-139:** lane B chuyển sang tài khoản GPT mới chạy Codex CLI trên máy này, workspace `D:\GAME_WORK\lane-b2`. Đọc [bàn giao](BAN_GIAO_LANE_ABC_2026-10-31.md). Các prompt cũ (T-208/T-209/T-210, T-216, T-219) xem lịch sử git của file này; không dùng nữa.

## 1. Prompt giao việc đầu tiên (dán nguyên khối)
```text
Bạn là agent Lane B (Môi trường và 3D) của game "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript).
Bạn là tài khoản mới nhận lane B từ hôm nay (D-139). Trả lời và viết tài liệu bằng tiếng Việt; code, comment, commit message bằng tiếng Anh.
Integrator là Claude Code ở máy (Opus 5.5): review và merge vào main. Chủ dự án quyết mọi việc thiết kế.

Workspace của bạn: D:\GAME_WORK\lane-b2. Chỉ làm trong thư mục này.
Không sửa D:\GAME_DEMO, không sửa workspace lane khác, kể cả workspace cũ D:\GAME_WORK\lane-b.

1. Nếu D:\GAME_WORK\lane-b2 chưa có:
   git clone https://github.com/haruki2708/ky-tuc-xa-sau-12-gio.git D:\GAME_WORK\lane-b2
   rồi trong thư mục đó: git lfs install --local và git lfs pull.
   Nếu đã có: kiểm git status, không ghi đè thay đổi đang có, git fetch origin.
2. Tạo nhánh lane-b/T-229-floor4-corridor-survey từ origin/main (đã có thì switch và pull --ff-only).
3. Đọc lần lượt: AGENTS.md, docs/handoff/BAN_GIAO_LANE_ABC_2026-10-31.md, docs/STATUS.md (phần đầu),
   docs/tasks/T-229-floor4-corridor-survey.md.
4. Làm task T-229: khảo sát hành lang tầng 4, chụp ảnh hiện trạng, viết kế hoạch và phiếu Tripo nháp; không sửa scene chơi.
   Chỉ sửa file trong mục "Được phép sửa" của card. Cần sửa ngoài phạm vi thì ghi "Yêu cầu thay đổi" trong Handoff, không tự sửa.
   Không chạy bot, không đo FPS, không tiêu credit Tripo.
   Việc thiết kế không rõ thì đưa phương án kèm đề xuất, không tự chọn.
5. Chạy Godot theo luật "Lượt Godot" trong AGENTS.md mục 4 (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt).
   Khi đang làm: pwsh tools/test.ps1 -Filter <tên test>. Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1.
   Không sửa âm thanh thì trước commit chạy git checkout -- game/default_bus_layout.tres.
6. Commit nhỏ "T-229: ...", push nhánh: git push -u origin lane-b/T-229-floor4-corridor-survey. Không push main, không mở PR.
7. Cập nhật Checklist và Handoff trong card: đã làm, còn dở, cách kiểm tra, dòng RESULT test và check,
   commit hash, yêu cầu thay đổi, phần chưa kiểm. Ghi trung thực. Không sửa STATUS hay DECISIONS.
8. Cuối phiên báo lại ngắn gọn bằng tiếng Việt cho chủ dự án: xong gì, nhánh, commit, có bị chặn không.
```

## 2. Prompt tiếp tục (phiên sau)
```text
Tiếp tục T-229 ở D:\GAME_WORK\lane-b2, nhánh lane-b/T-229-floor4-corridor-survey.
Kiểm git status, git fetch origin, rebase an toàn lên origin/main nếu main có thay đổi mới (không mất thay đổi cục bộ).
Đọc lại AGENTS.md và mục Handoff trong docs/tasks/T-229-floor4-corridor-survey.md để biết lần trước dừng ở đâu.
Làm tiếp phần còn dở, bàn giao theo bước 5–8 của prompt mục 1.
```

## 3. Prompt yêu cầu sửa (khi integrator trả lại)
```text
Integrator trả T-229. Ở D:\GAME_WORK\lane-b2: git fetch origin, đọc mục Review trong origin/main:docs/tasks/T-229-floor4-corridor-survey.md
(hoặc nội dung chủ dự án dán kèm). Rebase lane-b/T-229-floor4-corridor-survey lên origin/main, sửa đúng từng ý trong phạm vi được phép.
Chạy full test và check theo luật Lượt Godot, cập nhật Handoff, push nhánh, báo lại phần đã sửa và phần chưa kiểm.
```
