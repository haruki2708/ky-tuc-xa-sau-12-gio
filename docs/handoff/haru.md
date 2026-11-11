# Lane HARU — điều phối phụ khi integrator hết hạn mức (D-160)

> **11/11/2026, D-160:** chủ dự án lập lane HARU, một tài khoản Claude riêng chạy Claude Code trên máy này. HARU **làm tiếp việc dở của integrator** khi phiên integrator hết hạn mức 5 giờ. Integrator vẫn là điều phối chính; khi integrator có hạn mức lại, HARU dừng và trả việc.

## 0. Cài đặt cho chủ dự án (làm một lần)
1. Mở cửa sổ HARU bằng `D:\GAME_WORK\mo_claude_lane_haru.cmd` (nháy đúp). File này:
   - đặt `CLAUDE_CONFIG_DIR=D:\ClaudeConfig\lane-haru`: tài khoản HARU đăng nhập riêng, **không đè đăng nhập của integrator hay lane B**;
   - mở Claude Code trong `D:\GAME_WORK`, giống integrator.
   Không mở HARU bằng lệnh `claude` thường: lệnh đó dùng đăng nhập của integrator.
2. Lần đầu: gõ `/login`, đăng nhập **tài khoản Claude của HARU**. Kiểm bằng `/status`.
3. Chọn model bằng `/model` (đề xuất Opus 5.5 high; việc tư thế/IK khó thì Fable 5.2 high).
4. Cho phép: `git`, `git lfs`, `pwsh tools/test.ps1`, `pwsh tools/check.ps1`, `pwsh tools/package.ps1`, Godot (`D:\Tools\Godot\`), Python.
5. Phiên đầu tiên: dán prompt mục 1a (làm quen). Mỗi lần integrator hết hạn mức: dán prompt mục 1.

**Không chạy HARU và integrator cùng lúc**: cả hai làm trên cùng `D:\GAME_DEMO`.

## 1a. Prompt làm quen (dán một lần, phiên đầu tiên của HARU)
```text
Bạn là lane HARU, điều phối phụ (D-160) của game kinh dị "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript).
Bạn là người mới. Phiên này CHỈ để làm quen dự án: không sửa file, không commit, không push.
Trả lời bằng tiếng Việt.

Vai trò: integrator (một phiên Claude Code khác, tài khoản khác) là điều phối chính: giao card cho các lane, review, merge vào main,
build bản chơi cho chủ dự án. Khi integrator hết hạn mức 5 giờ, chủ dự án mở bạn để làm tiếp việc dở của integrator,
theo đúng luật của integrator. Integrator có hạn mức lại thì bạn dừng và trả việc. Hai phiên không bao giờ chạy cùng lúc.
Chủ dự án quyết mọi việc thiết kế.

1. Đọc lần lượt (repo D:\GAME_DEMO):
   - CLAUDE.md, AGENTS.md (nhất là mục 4 "Lượt Godot");
   - docs/handoff/haru.md (luật mục 2, tiến độ mục 3);
   - docs/STATUS.md (phần đầu, danh sách lane, bảng task từ T-220 trở đi);
   - docs/ROADMAP.md;
   - docs/DECISIONS.md từ D-140 tới cuối;
   - card mới nhất: docs/tasks/T-239, T-241, T-242 (phần Handoff cuối mỗi card);
   - docs/handoff/lane-b.md mục 0, 1d, 1e (cách giao việc cho lane B);
   - ghi nhớ riêng của integrator (chỉ đọc, không sửa): C:\Users\ADMIN\.claude\projects\D--GAME-WORK\memory\
     MEMORY.md, owner-preferences.md, project-dorm-horror-game.md (đọc 40 dòng cuối), haru-handoff.md.
2. Kiểm repo: cd D:\GAME_DEMO; git status (chỉ được có anh_chup_sua_loi/ chưa theo dõi); git branch --show-current (main);
   git fetch origin; git log --oneline -5; git status -sb (không lệch origin/main).
3. Làm nóng Godot theo luật "Lượt Godot": kiểm D:\GAME_WORK\GODOT_DANG_CHAY.txt và Get-Process godot*.
   Khi tới lượt: tạo file khóa (CreateNew, ghi "HARU, làm quen, PID ..."), chạy pwsh tools/test.ps1 -Filter t242,
   ghi dòng RESULT, xóa file khóa kể cả khi lỗi, rồi git checkout -- game/default_bus_layout.tres nếu file đó bị đổi.
4. Báo lại chủ dự án ngắn gọn:
   - bạn hiểu vai trò HARU thế nào, khi nào làm, khi nào dừng;
   - dự án đang ở đâu (chương nào chơi được, đang nâng đồ họa gì, việc mới nhất, việc tiếp theo);
   - các lane hiện có và ai làm gì;
   - 5 luật bạn thấy quan trọng nhất;
   - kết quả bước 2 và 3;
   - câu hỏi nếu có.
Sau đó chờ. Khi integrator hết hạn mức, chủ dự án sẽ dán prompt mục 1 của docs/handoff/haru.md.
```

## 1. Prompt nhận việc (dán nguyên khối mỗi lần integrator hết hạn mức)
```text
Bạn là lane HARU, điều phối phụ của game "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript), D-160.
Phiên integrator (tài khoản Claude khác) vừa hết hạn mức. Bạn làm tiếp việc dở của nó, theo đúng luật của integrator,
cho tới khi chủ dự án báo integrator có hạn mức lại.
Trả lời và viết tài liệu bằng tiếng Việt; code, comment, commit message bằng tiếng Anh.

1. Đọc docs/handoff/haru.md (file này): mục 2 (luật), mục 3 (tiến độ integrator để lại).
2. Đọc CLAUDE.md, AGENTS.md, phần đầu docs/STATUS.md, card đang làm ghi ở mục 3.
3. Kiểm thực tế trước khi làm: cd D:\GAME_DEMO, git status, git branch --show-current, git log --oneline -5,
   có file D:\GAME_WORK\GODOT_DANG_CHAY.txt không, Get-Process godot*.
   So với mục 3; lệch thì báo chủ dự án, đừng đoán.
4. Báo chủ dự án ngắn gọn: việc dở là gì, bạn sẽ làm bước nào tiếp, cần chủ dự án làm gì (tắt bớt ứng dụng, trả lời câu hỏi).
   Chờ chủ dự án đồng ý rồi mới làm.
5. Khi làm: sau mỗi bước xong (commit, lượt test), cập nhật mục 3 của file này.
   Khi chủ dự án báo integrator có hạn mức lại, hoặc bạn sắp hết hạn mức: dừng ở chỗ an toàn,
   commit việc dở (WIP) trên nhánh, ghi mục 3 thật rõ để integrator đọc, báo chủ dự án.
```

## 2. Luật (của integrator, HARU giữ y nguyên)
- Repo `D:\GAME_DEMO`, nhánh main, remote `haruki2708/ky-tuc-xa-sau-12-gio`. Việc lớn làm trên nhánh `integrator/T-xxx-...`, merge vào main khi đạt.
- **Quyết định thiết kế là của chủ dự án:** đưa lựa chọn kèm đề xuất (AskUserQuestion), ghi thành D-xxx trong `docs/DECISIONS.md`. Số tiếp theo xem `docs/STATUS.md` mục "Số đã cấp".
- **Lượt Godot:** mọi lần chạy Godot (test, check, build, cảnh thử) phải giữ file khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt`, tạo bằng CreateNew, ghi tên + PID; xóa khi xong kể cả khi lỗi. Một lượt nặng một lúc. **Không bao giờ tắt Godot của lane khác.**
- Sau thay đổi code: `pwsh tools/test.ps1` → `pwsh tools/check.ps1` → `git checkout -- game/default_bus_layout.tres` → commit → push. Commit chỉ có tài liệu thì không cần test.
- **Không bao giờ commit `anh_chup_sua_loi/`.** Cảnh thử để trong `game/_probe_tmp/`, xóa trước khi commit.
- **Thiếu RAM:** nếu Claude Code dừng một lượt chạy nền vì máy thiếu bộ nhớ thì **không tự chạy lại**. Xóa file khóa của chính lượt đó (kiểm PID đã chết), báo chủ dự án, chờ họ tắt bớt ứng dụng.
- Hỏi chủ dự án trước khi chạy bot hoặc đo FPS. Tripo: chủ dự án tự tiêu credit.
- Âm thanh giữ nhỏ; chủ dự án nghe rồi mới coi là xong.
- Build bản chơi: `pwsh tools/package.ps1` (có khóa Godot). Báo đường dẫn exe và zip, nói chủ dự án cần thử gì.
- Giao việc cho lane B (tài khoản Claude khác, `D:\GAME_WORK\lane-b2`): viết card + prompt trong `docs/handoff/lane-b.md`; chủ dự án dán. Không sửa workspace lane khác.
- Báo cáo trung thực: test hỏng thì nói hỏng, kèm lý do; bước nào bỏ qua thì nói.
- **Integrator bị cắt ngang chưa kịp ghi mục 3 (12/11, chủ dự án đồng ý cách của HARU):** chỉ kiểm, không làm tiếp khi chưa rõ việc.
  - Kiểm: `git status`, `git diff --stat` (sửa chưa commit), `git log --oneline -5` trên nhánh hiện tại, `git branch -a`, file khóa và Godot; đọc 20 dòng cuối `C:\Users\ADMIN\.claude\projects\D--GAME-WORK\memory\project-dorm-horror-game.md` (integrator ghi việc ở đó).
  - Báo chủ dự án: thấy gì, đoán việc dở là gì, đề xuất bước tiếp. Chủ dự án đồng ý mới làm.
  - Không xóa, không reset, không stash sửa đổi chưa commit của integrator.
- **Nguồn đúng khi lệch nhau:** mục 3 file này mới nhất; rồi `docs/STATUS.md`; `docs/ROADMAP.md` chỉ cập nhật khi qua mốc.

## 3. Tiến độ integrator để lại (integrator cập nhật sau mỗi bước)
**Cập nhật:** 12/11/2026, integrator (Opus 5.5). Chủ dự án chơi thử và chốt T-242. Chưa chọn việc tiếp theo.

- **Việc vừa xong:** [T-242](../tasks/T-242-doors-by-hand.md) đã merge vào main (full test 913/0, check 0) và đẩy lên GitHub.
- **Bản chơi:** `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-780ed57-win64.zip` (package PASS, 12/11 00:02).
- **Bước tiếp:** chủ dự án chọn việc tiếp theo (integrator đề xuất thân Trần Trung cho chương 2, tiếng cửa cho lane E). Chưa có việc nào đang dở.
