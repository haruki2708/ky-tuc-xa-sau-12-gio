# Prompt bàn giao — Lane B (Môi trường và 3D)

> **07/11/2026, D-141:** lane B chuyển sang **một tài khoản Claude chạy Claude Code trên máy này**, workspace `D:\GAME_WORK\lane-b2` (dùng lại thư mục của agent GPT trước). Agent GPT từng làm lane B chuyển sang lane E (âm thanh). Đọc [bàn giao](BAN_GIAO_LANE_B_E_2026-11-07.md). Prompt T-229 của agent trước xem lịch sử git của file này.

## 0. Cài đặt cho chủ dự án (làm một lần)
1. **Đóng mọi cửa sổ Codex đang mở ở `D:\GAME_WORK\lane-b2`.** Thư mục này từ nay của Claude lane B.
2. Mở cửa sổ Claude lane B bằng file `D:\GAME_WORK\mo_claude_lane_b.cmd` (nháy đúp). File này:
   - đặt `CLAUDE_CONFIG_DIR=C:\Users\ADMIN\.claude-lane-b`, để tài khoản Claude thứ hai có chỗ đăng nhập riêng, **không đè đăng nhập của integrator**;
   - mở Claude Code trong `D:\GAME_WORK\lane-b2`.
   Không mở Claude lane B bằng lệnh `claude` thường: lệnh đó dùng đăng nhập của integrator.
3. Lần đầu: gõ `/login`, đăng nhập **tài khoản Claude mới**. Kiểm lại bằng `/status` (phải hiện tài khoản mới).
4. Chọn model bằng `/model`: Opus nếu gói cho phép (dựng Blender, đọc cảnh 3D cần suy luận nhiều), không thì Sonnet.
5. Khi Claude hỏi quyền chạy lệnh: cho phép `git`, `git lfs`, `pwsh tools/test.ps1`, `pwsh tools/check.ps1`, Godot (`D:\Tools\Godot\`), Blender (`D:\Tools\Blender\`), Python. Không cho phép lệnh xóa thư mục ngoài `lane-b2`.
6. Dán prompt mục 1.

## 1. Prompt nhận bàn giao (dán nguyên khối, phiên đầu)
```text
Bạn là agent Lane B (Môi trường và 3D) của game "Ký túc xá sau 12 giờ" (Godot 4.7.2, GDScript), tài khoản Claude mới nhận lane B từ hôm nay (D-141).
Bạn KHÔNG phải integrator. Integrator là một phiên Claude Code khác (Opus 5.5) làm ở D:\GAME_DEMO: review và merge vào main. Chủ dự án quyết mọi việc thiết kế.
Trả lời và viết tài liệu bằng tiếng Việt; code, comment, commit message bằng tiếng Anh.

Workspace của bạn: D:\GAME_WORK\lane-b2. Chỉ làm trong thư mục này. Không mở, không sửa D:\GAME_DEMO hay workspace lane khác.

Phiên này CHỈ nhận bàn giao, chưa có việc. Không sửa file, không commit.
1. Kiểm thư mục: git status (phải sạch), git remote -v (phải là haruki2708/ky-tuc-xa-sau-12-gio).
   git fetch origin, git switch main, git pull --ff-only, git lfs pull.
2. Đọc lần lượt: CLAUDE.md, AGENTS.md, docs/handoff/BAN_GIAO_LANE_B_E_2026-11-07.md, docs/handoff/lane-b.md,
   docs/STATUS.md (phần đầu và bảng task), docs/ROADMAP.md, docs/tasks/T-229-floor4-corridor-survey.md,
   art_source/graphics_upgrade/floor4_corridor/PLAN.md, art_source/graphics_upgrade/room407_shell/README.md.
3. Làm nóng Godot theo luật "Lượt Godot" (AGENTS.md mục 4, file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt):
   khi tới lượt, chạy pwsh tools/test.ps1 -Filter test_floor4. Ghi dòng RESULT. Xóa file khóa khi xong, kể cả khi lỗi.
   Sau đó: git checkout -- game/default_bus_layout.tres nếu file này bị đổi.
4. Báo lại cho chủ dự án bằng tiếng Việt, ngắn gọn:
   - bạn hiểu lane B làm gì, được sửa thư mục nào, luật nào quan trọng nhất;
   - dự án đang ở đâu với phần môi trường 3D (phòng 407 đã nâng, hành lang tầng 4 đang chờ chủ dự án chọn phương án);
   - kết quả bước 1 và 3;
   - câu hỏi nếu có.
Sau đó chờ integrator giao card.
```

## 1b. T-237 đã xong, không giao lại
T-237 (hành lang tầng 4 mới vào bản chơi) integrator đã làm thay lúc lane B hết hạn mức (09/11/2026, merge `f7efdc3`). Khi lane B có hạn mức lại, chỉ dán prompt này rồi chờ card mới:
```text
T-237 đã được integrator làm thay và merge vào main (f7efdc3), đừng làm lại, đừng dùng nhánh T-235 cũ.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch main, git pull --ff-only, git lfs pull.
Đọc docs/tasks/T-237-floor4-corridor-playable.md (Handoff và Review) để biết hành lang giờ dựng trong game/scenes/levels/floor4/corridor_shell.gd.
Báo lại: nhánh đang đứng, commit HEAD, thay đổi chưa commit nếu có. Sau đó chờ integrator giao card.
```

## 1c. Giao T-239 (09/11/2026, D-153): 4 lỗi tay Trần Trung
Chủ dự án: mở Claude lane B bằng `D:\GAME_WORK\mo_claude_lane_b.cmd`, `/model` chọn **Opus 5.5**, đặt effort **max** (`/effort max` hoặc trong `/model`), rồi dán:
```text
Việc mới cho lane B: T-239 — sửa 4 lỗi tay Trần Trung mà chủ dự án thấy khi chơi thử. Đọc docs/tasks/T-239-protagonist-hand-fixes.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có; nhánh T-235 cũ không dùng nữa), git fetch origin,
git switch -c lane-b/T-239-protagonist-hand-fixes origin/main, git lfs pull.
Đọc AGENTS.md mục 3–5, card T-239, docs/tasks/T-227-protagonist-tripo-body-motions.md (mục cuối) và game/scripts/player/player_body.gd.
Xem 4 ảnh lỗi trong art_source/graphics_upgrade/protagonist/previews/t239/before_*.png.
Chủ dự án muốn sửa dứt điểm. Card mục 2 là nguyên nhân integrator đọc ra từ code: tự đo để xác nhận trước khi sửa, ghi số đo trước/sau.
Sửa cho mọi đồ cùng loại, tự chụp ảnh trước/sau trong chương 1 thật và tự xem lại từng tấm.
Không sửa game/scripts/entity/hand_grip_modifier.gd (quản lý dùng chung); hệ ngón tay mới viết riêng trong game/scripts/player/.
Câu hỏi ở card mục 4 (đóng cửa 407 đang mở thì tay cầm vào đâu, đóng có nhấn tay nắm không, lấy giấy kiểu nào) đưa chủ dự án kèm ảnh dựng thử và đề xuất,
hỏi phần cửa trước khi làm cửa; vượt 1 giây hay phải sửa door407.gd thì dừng, hỏi trước.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-239-protagonist-hand-fixes.md).
Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi". Không chạy bot, không đo FPS, không tiêu credit Tripo.
Có chỗ phải chọn về cách cầm hay động tác mà card chưa nói thì đưa phương án kèm đề xuất cho chủ dự án.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt). Khi làm: pwsh tools/test.ps1 -Filter <tên test>.
Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1 (chạy bằng tiến trình pwsh riêng ghi log trong build/, mỗi lượt ~25 phút),
rồi git checkout -- game/default_bus_layout.tres. Không commit log, không commit anh_chup_sua_loi/.
Commit nhỏ "T-239: ...", git push -u origin lane-b/T-239-protagonist-hand-fixes. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, có bị chặn không.
```

## 2. Prompt giao việc (integrator điền T-xxx)
```text
Việc mới cho lane B: <T-xxx> — đọc docs/tasks/<file card>.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có), git fetch origin, tạo nhánh lane-b/<T-xxx-...> từ origin/main.
Đọc lại AGENTS.md mục 3–5 và card. Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi".
Không chạy bot, không đo FPS, không tiêu credit Tripo khi card không cho phép. Thiết kế không rõ thì đưa phương án kèm đề xuất.
Godot theo luật Lượt Godot. Khi làm: pwsh tools/test.ps1 -Filter <tên test>. Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1,
rồi git checkout -- game/default_bus_layout.tres. Log để trong build/, không commit log.
Commit nhỏ "<T-xxx>: ...", git push -u origin <nhánh>. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card (đã làm, còn dở, cách kiểm tra, dòng RESULT test và check, commit hash, yêu cầu thay đổi, phần chưa kiểm). Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, có bị chặn không.
```

## 3. Prompt tiếp tục (phiên sau)
```text
Tiếp tục <T-xxx> ở D:\GAME_WORK\lane-b2, nhánh lane-b/<T-xxx-...>.
Kiểm git status, git fetch origin, rebase an toàn lên origin/main nếu main có thay đổi mới (không mất thay đổi cục bộ).
Đọc lại AGENTS.md và mục Handoff trong card để biết lần trước dừng ở đâu. Làm tiếp, bàn giao như prompt mục 2.
```

## 4. Prompt yêu cầu sửa (khi integrator trả lại)
```text
Integrator trả <T-xxx>. Ở D:\GAME_WORK\lane-b2: git fetch origin, đọc mục Review trong origin/main:docs/tasks/<file card>.md
(hoặc nội dung chủ dự án dán kèm). Rebase nhánh lên origin/main, sửa đúng từng ý trong phạm vi được phép.
Chạy full test và check theo luật Lượt Godot, cập nhật Handoff, push nhánh, báo lại phần đã sửa và phần chưa kiểm.
```
