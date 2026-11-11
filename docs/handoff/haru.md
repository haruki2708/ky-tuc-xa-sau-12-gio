# Lane HARU — điều phối phụ khi integrator hết hạn mức (D-160)

> **11/11/2026, D-160:** chủ dự án lập lane HARU, một tài khoản Claude riêng chạy Claude Code trên máy này. HARU **làm tiếp việc dở của integrator** khi phiên integrator hết hạn mức 5 giờ. Integrator vẫn là điều phối chính; khi integrator có hạn mức lại, HARU dừng và trả việc.

## 0. Cài đặt cho chủ dự án (làm một lần)
1. Mở cửa sổ HARU bằng `D:\GAME_WORK\mo_claude_lane_haru.cmd` (nháy đúp). File này:
   - đặt `CLAUDE_CONFIG_DIR=C:\Users\ADMIN\.claude-lane-haru`: tài khoản HARU đăng nhập riêng, **không đè đăng nhập của integrator hay lane B**;
   - mở Claude Code trong `D:\GAME_WORK`, giống integrator.
   Không mở HARU bằng lệnh `claude` thường: lệnh đó dùng đăng nhập của integrator.
2. Lần đầu: gõ `/login`, đăng nhập **tài khoản Claude của HARU**. Kiểm bằng `/status`.
3. Chọn model bằng `/model` (đề xuất Opus 5.5 high; việc tư thế/IK khó thì Fable 5.2 high).
4. Cho phép: `git`, `git lfs`, `pwsh tools/test.ps1`, `pwsh tools/check.ps1`, `pwsh tools/package.ps1`, Godot (`D:\Tools\Godot\`), Python.
5. Mỗi lần integrator hết hạn mức: dán prompt mục 1.

**Không chạy HARU và integrator cùng lúc**: cả hai làm trên cùng `D:\GAME_DEMO`.

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

## 3. Tiến độ integrator để lại (integrator cập nhật sau mỗi bước)
**Cập nhật:** 11/11/2026 23:30, integrator (Opus 5.5).

- **Việc đang làm:** [T-242](../tasks/T-242-doors-by-hand.md), cửa nhà tắm và cửa ban công mở/đóng bằng tay ở chương 1, Trung tự bước tránh cánh cửa (D-154, D-159).
- **Nhánh:** `integrator/T-242-doors-by-hand` (chưa đẩy lên GitHub, chưa merge). Commit: `3de713e` (code + test), `32bf33d` (sửa quản lý, ảnh). Phần bàn giao của card đã viết.
- **Đã kiểm:** test_t242_doors 8/8, test_chapter1_d069 22/22, T-241 7/7, T-239 6/6. Ảnh `art_source/graphics_upgrade/protagonist/previews/t242/` đã xem: ổn.
- **Đang chạy:** full test rồi check (log `D:\GAME_DEMO\build\integrator\t242full.log`, chi tiết `t242full_full.out.log`, `t242full_check.out.log`).
- **Bước tiếp:**
  1. Đọc `t242full.log`. Đạt (0 failed, check 0 lỗi) thì làm tiếp; hỏng thì đọc `*.out.log`, sửa, chạy lại phần hỏng.
  2. Commit tài liệu đang sửa dở (card T-242, file này) trên nhánh.
  3. `git switch main`, `git merge --no-ff integrator/T-242-doors-by-hand`, cập nhật `docs/STATUS.md` (dòng đầu, dòng T-242 thành "merged", không đổi số đã cấp), commit, `git push origin main`.
  4. Build bản chơi (`pwsh tools/package.ps1` có khóa). Báo chủ dự án thử: mở/đóng cửa nhà tắm và cửa ban công hai phía, đứng sát bản lề rồi bấm E (Trung tự bước tránh, có thể đi tới ~1 m), trốn ngoài ban công đóng cửa cho quản lý tới.
