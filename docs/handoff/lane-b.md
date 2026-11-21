# Prompt bàn giao — Lane B (Môi trường và 3D)

> **07/11/2026, D-141:** lane B chuyển sang **một tài khoản Claude chạy Claude Code trên máy này**, workspace `D:\GAME_WORK\lane-b2` (dùng lại thư mục của agent GPT trước). Agent GPT từng làm lane B chuyển sang lane E (âm thanh). Đọc [bàn giao](BAN_GIAO_LANE_B_E_2026-11-07.md). Prompt T-229 của agent trước xem lịch sử git của file này.

## 0. Cài đặt cho chủ dự án (làm một lần)
1. **Đóng mọi cửa sổ Codex đang mở ở `D:\GAME_WORK\lane-b2`.** Thư mục này từ nay của Claude lane B.
2. Mở cửa sổ Claude lane B bằng file `D:\GAME_WORK\mo_claude_lane_b.cmd` (nháy đúp). File này:
   - đặt `CLAUDE_CONFIG_DIR=D:\ClaudeConfig\lane-b (11/11/2026 chuyển từ C:\Users\ADMIN\.claude-lane-b, chép nguyên thư mục nên giữ đăng nhập và các cuộc trò chuyện)`, để tài khoản Claude thứ hai có chỗ đăng nhập riêng, **không đè đăng nhập của integrator**;
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

## 1c. Giao T-239 (09/11/2026, D-153): 4 lỗi tay Trần Trung (ĐÃ XONG, merge 10/11; không dán lại)
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

## 1d. Giao T-240 (D-155): khảo sát mọi động tác Trần Trung (ĐÃ BỎ, D-158 ngày 11/11; không dán)
Chủ dự án: chờ integrator báo T-241 đã merge vào main, rồi dán vào cửa sổ lane B (cùng phiên hoặc phiên mới):
```text
Việc mới cho lane B: T-240 — khảo sát mọi động tác của Trần Trung ở chương 1, CHỈ khảo sát và đề xuất, không sửa game. Đọc docs/tasks/T-240-protagonist-motion-survey.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
kiểm T-241 đã có trên origin/main (git log --oneline origin/main | grep T-241), nếu chưa thì dừng và báo.
git switch -c lane-b/T-240-protagonist-motion-survey origin/main, git lfs pull.
Đọc AGENTS.md mục 3–5, card T-240, Handoff của T-239 và T-241 (cách đo, cách chụp) và game/tests/player/test_protagonist_chapter1.gd.
Lấy danh sách đồ dùng tay bằng code ở mọi mốc truyện; chấm Tự nhiên / Hơi gượng / Sai, độ nặng, ảnh, đề xuất sửa (code, Blender, vị trí đồ, Tripo) và công.
Không sửa code, scene, asset game; cảnh chụp tạm trong game/_probe_tmp/ rồi xóa. Không chạy bot, không đo FPS, không tiêu credit Tripo.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt), chụp chia nhiều lượt nhỏ.
Commit báo cáo và ảnh ("T-240: ..."), git push -u origin lane-b/T-240-protagonist-motion-survey. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: số mục đã khảo sát, số Hơi gượng / Sai, 5 lỗi nên sửa trước, câu hỏi cho chủ dự án, nhánh, commit.
```

## 1e. Giao T-241 (10/11/2026, D-156): lấy đồ tự nhiên (ĐÃ XONG, merge 10/11; không dán lại)
Chủ dự án: mở Claude lane B bằng `D:\GAME_WORK\mo_claude_lane_b.cmd` (hoặc dùng cửa sổ lane B đang mở), `/model` chọn **Opus 5.5**, effort đề xuất **max** như T-239, rồi dán:
```text
Việc mới cho lane B: T-241 — lấy đồ tự nhiên (chủ dự án chơi thử bản có T-239). Đọc docs/tasks/T-241-protagonist-natural-reach.md.
Nếu đang làm T-240 thì dừng: commit phần đã có vào nhánh T-240 ("T-240: WIP"), push, rồi làm T-241 (T-240 làm lại sau khi T-241 merge).
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
git switch -c lane-b/T-241-protagonist-natural-reach origin/main, git lfs pull.
Đọc AGENTS.md mục 3–5, card T-241 (mục 1 là điều chủ dự án đã chốt), Handoff của T-239, docs/tasks/T-227-protagonist-tripo-body-motions.md (mục cuối) và game/scripts/player/player_body.gd.
Chủ dự án khen cách cầm của T-239, chỉ chê cách thân với đồ: đồ trên bàn đứng yên gập hông nhẹ (≤ 45°, không khom, không rướn sâu, không nhón),
giấy dưới đất và thùng rác cúi gập gối hơi chùng (không ngồi xổm), thứ thấp khác cũng cúi gập. Giữ nguyên cách cầm T-239 và test T-239.
Card mục 2 là nguyên nhân integrator đọc ra từ code: tự đo để xác nhận trước khi sửa, ghi số đo trước/sau và bảng mọi đồ trong Handoff.
Tự chụp ảnh trước/sau trong chương 1 thật, tự xem lại từng tấm; nên có video ngắn (để trong build/, không commit).
Câu hỏi ở card mục 4 (1 giây có đủ cho cúi nhặt không, đồ phải dời xa hơn 10 cm) đưa chủ dự án kèm ảnh hoặc video và đề xuất, không tự quyết.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-241-protagonist-natural-reach.md).
Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi". Không chạy bot, không đo FPS, không tiêu credit Tripo.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt). Khi làm: pwsh tools/test.ps1 -Filter <tên test>.
Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1 (tiến trình pwsh riêng, log trong build/, mỗi lượt ~25 phút),
rồi git checkout -- game/default_bus_layout.tres. Không commit log, video, anh_chup_sua_loi/.
Commit nhỏ "T-241: ...", git push -u origin lane-b/T-241-protagonist-natural-reach. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh và video ở đâu, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1f. Giao T-247 (12/11/2026): khảo sát đưa thân Trần Trung vào chương 3 (chỉ khảo sát)
Chủ dự án tự dán (integrator không điều khiển lane B): mở Claude lane B bằng `D:\GAME_WORK\mo_claude_lane_b.cmd` (hoặc cửa sổ lane B đang mở), `/model` chọn **Opus 5.5**, effort đề xuất **high**, rồi dán:
```text
Việc mới cho lane B: T-247 — khảo sát đưa thân Trần Trung vào chương 3 (chỉ khảo sát và đề xuất, chưa sửa game). Đọc docs/tasks/T-247-protagonist-chapter3-survey.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
git switch -c lane-b/T-247-protagonist-chapter3-survey origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-247-protagonist-chapter3-survey.md).
Đọc AGENTS.md mục 3–5, card T-247 (mục "Cần đọc"), bảng chủ dự án chốt của chương 2 ở docs/tasks/T-243-protagonist-chapter2.md mục 1.
Chương 1–2 đã có thân và đã được chủ dự án duyệt: giữ nguyên mọi luật đã duyệt, chỉ đề xuất cho chương 3.
Lượt này KHÔNG sửa code, scene, test, chapter3.tscn: thử bật thân chỉ trong game/_probe_tmp/ (không commit, xoá khi xong).
Mỗi thao tác đưa 2–3 phương án kèm một đề xuất; thứ cần chủ dự án chọn thì đưa vào bảng quyết định đầu báo cáo, không tự quyết.
Tự chụp ảnh 1080p trong chương 3 thật vào art_source/graphics_upgrade/protagonist/previews/t247/, tự xem lại từng tấm; video (nếu có) để trong build/, không commit.
Không chạy bot, không đo FPS, không tiêu credit Tripo. Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt, tạo bằng CreateNew, xoá khi xong kể cả khi lỗi).
Commit chỉ có báo cáo, ảnh và card nên không cần full test/check. Không commit log, video, anh_chup_sua_loi/, game/_probe_tmp/.
Commit nhỏ "T-247: ...", git push -u origin lane-b/T-247-protagonist-chapter3-survey. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, báo cáo và ảnh ở đâu, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1g. Giao T-249 (12/11/2026, D-165): HARU làm thay lane B — thân Trần Trung chương 3, thanh sắt, ngoảnh lại, thở dốc
Lane B hết hạn mức nên **HARU làm thay** trong thư mục của lane B. Chủ dự án: nháy đúp `D:\GAME_WORK\mo_claude_haru_lam_lane_b.cmd` (đăng nhập HARU, thư mục `lane-b2`; không mở lane B cùng lúc), `/model` chọn **Fable 5.2**, effort **high**, rồi dán:
```text
Bạn là lane HARU, hôm nay làm thay lane B (lane B hết hạn mức) trong D:\GAME_WORK\lane-b2. Làm đúng như agent lane B: luật lane B trong AGENTS.md mục 3–5.
Integrator (phiên Claude Code khác, D:\GAME_DEMO) review và merge vào main. Không làm gì trong D:\GAME_DEMO. Trả lời tiếng Việt; code, comment, commit message tiếng Anh.
Việc: T-249 — thân Trần Trung vào chương 3, phần không phụ thuộc cảnh (thanh sắt trong tay phải, vung, nhặt, Ngư đưa; ngoảnh lại khi chạy; thở dốc). Đọc docs/tasks/T-249-protagonist-chapter3-bar.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
git switch -c lane-b/T-249-protagonist-chapter3-bar origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-249-protagonist-chapter3-bar.md).
Đọc card mục "Cần đọc", nhất là tools/reports/T-247-ch3-body-survey.md và docs/tasks/T-243-protagonist-chapter2.md. Luật chương 1–2 đã duyệt: giữ nguyên.
Phương án từng dòng đã chốt ở card mục 1: làm đúng như vậy; thấy phương án không ổn thì dừng dòng đó, đưa phương án kèm ảnh vào Handoff, không tự đổi.
Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi". Không chạy bot, không đo FPS, không tiêu credit Tripo.
Tự chụp ảnh trước/sau trong chương 3 thật vào art_source/graphics_upgrade/protagonist/previews/t249/, tự xem lại từng tấm; video để trong build/, không commit.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt, tạo bằng CreateNew, ghi "HARU (thay B), T-249, <giờ>", xoá khi xong kể cả khi lỗi; máy ít RAM: mỗi lúc một Godot).
Khi làm: pwsh tools/test.ps1 -Filter <tên test>. Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1 (log trong build/), rồi git checkout -- game/default_bus_layout.tres.
Không commit log, video, anh_chup_sua_loi/, game/_probe_tmp/. Commit nhỏ "T-249: ...", git push -u origin lane-b/T-249-protagonist-chapter3-bar. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1h. Giao T-250 (12/11/2026, D-166): đồ hoạ thật đợt 1 — bàn trực, cầu thang thoát hiểm và cửa, cầu thang chính nhà B
Chủ dự án: mở lane B bằng `D:\GAME_WORK\mo_claude_lane_b.cmd`, `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-250 — đồ hoạ thật đợt 1 (bàn trực tầng 4, cầu thang thoát hiểm và cửa, cầu thang chính nhà B). Đọc docs/tasks/T-250-realistic-graphics-wave1.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
git switch -c lane-b/T-250-realistic-graphics-wave1 origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-250-realistic-graphics-wave1.md).
Đọc AGENTS.md mục 3–5, card T-250 (mục 1 là điều chủ dự án đã chốt), art_source/graphics_upgrade/realistic_map/PLAN.md (mục 2–5, khu A01, A06, A07) và ảnh hiện trạng trong realistic_map/previews/survey/ (01, 02, 11–15).
Dựng bằng Blender, chân thực như đồ phòng 407 và hành lang tầng 4 (xem cách dựng trong art_source/graphics_upgrade/floor4_corridor/ và room407_furnished/); không dùng Tripo.
Làm bàn trực (A01) trước, chụp ảnh trước/sau, tự xem lại, rồi mới tới hai cầu thang và cửa. Giữ nguyên collider, navmesh, Ch3Use, tên node, luật chơi (PLAN mục 4).
Thứ cần chủ dự án chọn (kiểu đồ, màu, mức cũ) thì đưa ảnh kèm phương án và một đề xuất vào Handoff, không tự quyết.
Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi". Không chạy bot, không đo FPS, không tiêu credit Tripo.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt). Khi làm: pwsh tools/test.ps1 -Filter <tên test>. Trước commit: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres.
Không commit log, video, anh_chup_sua_loi/, game/_probe_tmp/. Commit nhỏ "T-250: ...", git push -u origin lane-b/T-250-realistic-graphics-wave1. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1i. Giao T-254 (13/11/2026): lan can mép chiếu nghỉ tầng 4 ở hai cầu thang nhà B (có va chạm)
Chủ dự án: mở lane B bằng `D:\GAME_WORK\mo_claude_lane_b.cmd`, `/model` chọn **Opus 5.5**, effort **high** (việc nhỏ), rồi dán:
```text
Việc mới cho lane B: T-254 — lan can mép chiếu nghỉ tầng 4 ở cả hai cầu thang nhà B, có va chạm (bạn đề xuất ở câu 4 của T-250, chủ dự án đồng ý). Đọc docs/tasks/T-254-floor4-landing-guard-rail.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
git switch -c lane-b/T-254-floor4-landing-guard-rail origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-254-floor4-landing-guard-rail.md).
Làm đúng card: hình lan can như lan can giếng thang của T-250, thêm hộp va chạm mỏng layer 1; không đổi va chạm nào khác. Ảnh trước/sau từ chiếu nghỉ tầng 4, tự xem lại.
Chỉ sửa file trong mục "Được phép sửa"; không chạy bot, không đo FPS, không tiêu credit Tripo.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt). Trước commit cuối: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres.
Commit nhỏ "T-254: ...", git push -u origin lane-b/T-254-floor4-landing-guard-rail. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, có bị chặn không.
```

## 1j. Giao T-253 (13/11/2026, D-167): đồ hoạ thật đợt 2 — hành lang tầng 3→1, phòng 203, sảnh, phòng quản lý, bình cứu hoả, hộp báo cháy
**Dán sau khi integrator merge T-254** (mục 1i, merge 13/11), phiên mới (`/clear`). `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-253 — đồ hoạ thật đợt 2 (nhà B: hành lang tầng 3, 2, 1, phòng 203, sảnh, phòng quản lý và cửa sổ, bình cứu hoả tầng 2, hộp báo cháy tầng 1). Đọc docs/tasks/T-253-realistic-graphics-wave2.md.
Chủ dự án đã duyệt phong cách đợt 1 của bạn (D-167): dùng lại đúng bộ vật liệu, màu và chi tiết đó cho đợt 2.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin,
git switch -c lane-b/T-253-realistic-graphics-wave2 origin/main (T-254 đã merge vào main 13/11), git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-253-realistic-graphics-wave2.md).
Đọc card T-253, card T-250 (mục Handoff: cách bạn đã dựng đợt 1), art_source/graphics_upgrade/realistic_map/PLAN.md mục 2–4, 6 (A08–A11), ảnh hiện trạng realistic_map/previews/survey/16–25.
Dựng bằng Blender, không dùng Tripo. Giữ nguyên collider, navmesh, Ch3Use, tên node, luật (PLAN mục 4). Động tác Trần Trung (bình cứu hoả, báo cháy, cửa sổ) chưa làm, chỉ dựng hình để làm được sau.
Làm từng khu, chụp ảnh trước/sau trong chương 3 thật, tự xem lại từng tấm. Thứ cần chủ dự án chọn thì đưa ảnh kèm phương án và một đề xuất vào Handoff.
Chỉ sửa file trong mục "Được phép sửa"; ngoài phạm vi thì ghi "Yêu cầu thay đổi". Không chạy bot, không đo FPS, không tiêu credit Tripo.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt). Trước commit cuối: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres.
Không commit log, video, anh_chup_sua_loi/, game/_probe_tmp/. Commit nhỏ "T-253: ...", git push -u origin lane-b/T-253-realistic-graphics-wave2. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1k. Giao T-255 (13/11/2026, D-168): các phòng 401–406, 408 sâu như 407, nhà tắm, ban công, đồ đầy đủ, mở cửa đi vào được
Dán **sau khi lane B xong T-253** (mục 1j), hoặc trước nếu chủ dự án muốn đổi thứ tự. `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-255 — các phòng 401–406, 408 ở tầng 4: sâu như phòng 407, có nhà tắm và ban công, đồ đạc đầy đủ như 407 (mỗi phòng một khác), mở cửa bằng tay và đi vào khám được ở mọi chương. Đọc docs/tasks/T-255-floor4-rooms-like-407.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-255-floor4-rooms-like-407 origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-255-floor4-rooms-like-407.md).
Đọc card (mục 1 là điều chủ dự án đã chốt ở D-168, mục 2 hiện trạng). Làm bước 1 (khảo sát, đề xuất bố cục, ghi Handoff) trước khi dựng; thứ cần chủ dự án chọn thì đưa phương án kèm đề xuất, làm theo đề xuất và ghi "chờ chủ dự án chọn".
Chất lượng phải ngang phòng 407 (chủ dự án chê mẫu T-252 của lane C: phòng nhỏ, đồ thưa, cùng một bố cục, rèm nệm trông mới). Dựng bằng Blender, dùng lại đồ phòng 407 có sẵn; không dùng Tripo.
Không dời cửa, không đổi hành lang, cầu thang, đường đi quản lý và xác sống, luật chơi. Phần ngoài phạm vi lane B (script người chơi, director, Protagonist) ghi "Yêu cầu thay đổi".
Không chạy bot, không đo FPS, không tiêu credit Tripo. Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM, đóng Godot khi không dùng.
Trước commit cuối: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres. Commit nhỏ "T-255: ...", push nhánh sau mỗi phần xong. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1l. Giao T-256 (13/11/2026, D-170): tầng 4 phần còn lại — nhà vệ sinh chung, đồ ở hành lang, rà cửa thoát hiểm, trường quay CCTV hành lang
Dán **sau khi T-255 đã merge vào main** (integrator báo). `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-256 — tầng 4 phần còn lại: nhà vệ sinh chung, đồ ở hành lang, rà cửa thoát hiểm mở sát lan can, trường quay CCTV hành lang. Đọc docs/tasks/T-256-floor4-washroom-corridor-props.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-256-floor4-washroom-corridor-props origin/main, git lfs pull. origin/main phải đã có T-255 (các phòng 401–406, 408); chưa có thì dừng và báo.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-256-floor4-washroom-corridor-props.md).
Mục 1 của card là điều chủ dự án đã chốt (D-170): buồng vệ sinh có bên trong, cửa khép hờ, không tương tác; máng rửa dài ốp gạch men ba vòi; gương phản chiếu thật như gương phòng 407, mép ố; đồ hành lang thêm vừa phải, lối đi trống; dựng lại trường quay CCTV hành lang bằng bộ hành lang thật, giữ camera; cảnh ngoài chương 1–2 không làm.
Làm phần A (nhà vệ sinh chung) trước, dựng một góc mẫu, chụp cùng camera với ảnh previews/survey/03 và 04, tự xem rồi làm rộng; sau đó phần B, C, D. Chất lượng ngang phòng 407 và đợt 1, 2 đã duyệt; dựng bằng Blender, dùng lại đồ và texture đã có, không thêm texture 2K mới (chương 3 từng hết bộ nhớ hình), không dùng Tripo.
Không đổi va chạm, navmesh, anchor, ánh sáng, âm thanh, luật, director, script trong game/scripts; hình PS1 chỉ ẩn, không xoá. Phần ngoài phạm vi ghi "Yêu cầu thay đổi".
Không chạy bot, không đo FPS, không tiêu credit Tripo. Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Godot khi không dùng, chạy full test ở tiền cảnh.
Trước commit cuối: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres. Commit nhỏ "T-256: ...", push nhánh sau mỗi phần xong. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, câu hỏi cho chủ dự án, có bị chặn không.
```

## 1m. Giao T-258 (14/11/2026): tường giếng cầu thang chính lấn vào nhà vệ sinh tầng 4 ở chương 3–4
Dán **sau khi T-256 đã merge vào main** (integrator báo). `/model` chọn **Opus 5.5**, effort **xhigh**, rồi dán:
```text
Việc mới cho lane B: T-258 — chương 3–4: tường giếng cầu thang chính lấn 6 cm vào nhà vệ sinh tầng 4, che gương và máng rửa của T-256 (chính bạn phát hiện, yêu cầu thay đổi 1 của T-256). Đọc docs/tasks/T-258-main-stairs-wall-over-washroom.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-258-main-stairs-wall-over-washroom origin/main, git lfs pull. origin/main phải đã có T-256; chưa có thì dừng và báo.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-258-main-stairs-wall-over-washroom.md).
Sửa hình và va chạm của tường giếng thang chính chỉ ở độ cao tầng 4 để nó không vượt quá mặt ngoài tường tây nhà vệ sinh; kiểm cùng lỗi ở phía cầu thang thoát hiểm với phòng 408. Đây là đổi va chạm có chủ ý: cập nhật các test dấu vân tay của building_b.tscn chỉ ở đúng phần tường này và ghi rõ trong Handoff.
Không đổi nhà vệ sinh, hành lang, bậc thang, chiếu nghỉ, lan can, navmesh, director, luật. Không Tripo, không bot, không đo FPS.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng, chạy full test và check ở tiền cảnh.
Trước commit cuối: full pwsh tools/test.ps1 rồi pwsh tools/check.ps1, rồi git checkout -- game/default_bus_layout.tres. Commit nhỏ "T-258: ...", push nhánh. Không push main, không mở PR.
Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh ở đâu, dòng RESULT test và check, có bị chặn không.
```

## 1n. Giao T-259 (14/11/2026, D-172): đồ hoạ thật đợt 3 — vườn hoa, dải nối từ nhà B, cảnh ngoài nhìn từ tầng 4 ở chương 1–2
Dán **sau khi T-258 xong** (hoặc trước nếu chủ dự án muốn). `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-259 — đồ hoạ thật đợt 3: vườn hoa trước nhà B (chương 3–4), dải nối từ nhà B, và bản nhẹ của vườn làm cảnh ngoài nhìn từ hành lang tầng 4 ở chương 1–2. Đọc docs/tasks/T-259-realistic-graphics-wave3-garden.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-259-realistic-graphics-wave3-garden origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-259-realistic-graphics-wave3-garden.md).
Phiên này CHỈ làm lượt 1 (card mục 2): khảo sát, bảng hợp đồng, danh sách node A16, góc mẫu quanh ghế Ngư với các phương án cây, hoa, sân, ghế, đèn kèm ảnh trong chương 3 thật. Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không Tripo (bỏ qua dòng Tripo của PLAN cho vườn), giữ mật độ, giữ ánh sáng. Giữ nguyên va chạm, anchor, vùng, đèn; tán lá dưới 2 m phải nằm trong khối CanopyCollision của T-251. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, luật, navmesh. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng.
Commit nhỏ "T-259: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, câu hỏi cho chủ dự án, có bị chặn không.
```
**Lượt 2** (sau khi chủ dự án chọn, integrator đã ghi vào card mục 1): dán
```text
Tiếp tục T-259 lượt 2: chủ dự án đã chọn (card mục 1, D-175: 8 hoa sứ + 4 bằng lăng có hoa, F1 cả 12 bồn, viền K1 vôi trắng, sân P1 xám, ghế đá mài không chữ, đèn cầu, DistantStreetLamp chỉ ẩn cột giữ đèn, làm lại bảng tin). Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-259-realistic-graphics-wave3-garden: git status, git fetch origin, git rebase origin/main (lấy card mục 1), git lfs pull. Làm cả vườn, dải nối nhà B → vườn, cảnh ngoài chương 1–2, ảnh trước/sau, test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Commit, push nhánh, cập nhật Handoff, báo ngắn như lượt 1 kèm dòng RESULT test và check.
```

## 1o. Giao T-261 (15/11/2026, D-176): đồ hoạ thật đợt 4 — sân vận động, khán đài, dải nối vườn → sân
`/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-261 — đồ hoạ thật đợt 4: sân vận động (đường chạy, sân cỏ, khung thành, hai khán đài có mái, hàng rào, cổng, cột đèn pha) ở chương 3–4, và dải nối từ vườn hoa tới cổng tây sân. Đọc docs/tasks/T-261-realistic-graphics-wave4-stadium.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-261-realistic-graphics-wave4-stadium origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-261-realistic-graphics-wave4-stadium.md).
Phiên này CHỈ làm lượt 1 (card mục 2): khảo sát, bảng hợp đồng, đi thử tuyến vườn → cổng tây và chốt hộp A16, góc mẫu quanh cổng tây và góc khán đài chính (gầm khán đài có thanh sắt B02/B03) với các phương án đường chạy, cỏ, khán đài, đèn pha, hàng rào, cổng; ảnh trong chương 3 thật, đèn pha tắt và bật. Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không Tripo, giữ ánh sáng (không thêm đèn; chao đèn pha mới sáng theo Floodlights). Giữ nguyên va chạm, anchor, vùng, navmesh, 4 đèn pha và cơ chế tắt/bật. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, luật, âm thanh. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS.
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng.
Commit nhỏ "T-261: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, câu hỏi cho chủ dự án, có bị chặn không.
```
**Lượt 2** (sau khi chủ dự án chọn, HARU/integrator đã ghi vào card mục 1): dán
```text
Tiếp tục T-261 lượt 2: chủ dự án đã chọn (card mục 1). Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-261-realistic-graphics-wave4-stadium: git status, git fetch origin, git rebase origin/main (lấy card mục 1), git lfs pull. Làm cả sân vận động, dải nối vườn → sân, ảnh trước/sau (đèn pha tắt và bật), test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Commit, push nhánh, cập nhật Handoff, báo ngắn như lượt 1 kèm dòng RESULT test và check.
```

## 1p. Giao T-262 (15/11/2026): đồ hoạ thật đợt 5 — cổng trường, chốt bảo vệ, đường tới cổng (ĐÃ XONG, merge 15/11; không dán lại)
`/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-262 — đồ hoạ thật đợt 5: cổng trường (trụ, cánh cổng, biển tên trường rơi nửa), chốt bảo vệ, thanh chắn, tường rào nam, sân cổng ở chương 3, và đoạn đường tới cổng. Đọc docs/tasks/T-262-realistic-graphics-wave5-gate.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-262-realistic-graphics-wave5-gate origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-262-realistic-graphics-wave5-gate.md).
Phiên này CHỈ làm lượt 1 (card mục 2): khảo sát, bảng hợp đồng, đi thử tuyến sân vận động → cổng → nhà ăn và chốt hộp A16, góc mẫu quanh cổng và chốt bảo vệ với các phương án cánh cổng, trụ và biển (có chữ hay không), chốt, tường rào (và phạm vi), sân cổng; ảnh trong chương 3 thật, có hàng 12 bảo vệ. Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không Tripo, giữ ánh sáng (không thêm đèn). Giữ nguyên va chạm, anchor, vùng, navmesh và đường nhìn tới hàng bảo vệ. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, luật, bảo vệ (lane A), âm thanh. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS (D-179).
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng.
Commit nhỏ "T-262: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, câu hỏi cho chủ dự án, có bị chặn không.
```
**Lượt 2** (sau khi chủ dự án chọn, HARU/integrator đã ghi vào card mục 1): dán
```text
Tiếp tục T-262 lượt 2: chủ dự án đã chọn (card mục 1). Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-262-realistic-graphics-wave5-gate: git status, git fetch origin, git rebase origin/main (lấy card mục 1), git lfs pull. Làm cả cổng, chốt bảo vệ, tường rào theo phạm vi đã chọn, dải A16 đoạn cổng, ảnh trước/sau (có hàng bảo vệ), test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Commit, push nhánh, cập nhật Handoff, báo ngắn như lượt 1 kèm dòng RESULT test và check.
```

## 1q. Giao T-263 (15/11/2026): đồ hoạ thật đợt 6 — nhà ăn, bếp, kho (và trả đầu 6 xác trong vườn)
Gõ `/clear` (hoặc mở phiên mới), `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-263 — đồ hoạ thật đợt 6: nhà ăn (sảnh, 21 bàn, quầy chia cơm, TV, bếp, kho, tường tây lối tây) ở chương 3–4 và dải A16 quanh nhà ăn; trước đó trả đầu 6 xác trong vườn mà T-259 ẩn nhầm. Đọc docs/tasks/T-263-realistic-graphics-wave6-canteen.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-263-realistic-graphics-wave6-canteen origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-263-realistic-graphics-wave6-canteen.md).
Phiên này CHỈ làm lượt 1 (card mục 2): bước 0 trả đầu 6 xác vườn (cách sửa ở Handoff lượt 2 card T-262), khảo sát, bảng hợp đồng, đi thử tuyến cổng → nhà ăn → bếp → kho → cửa sau và lối tây chương 4, chốt hộp A16; góc mẫu sảnh, TV, bếp, mặt tiền với các phương án bàn ghế, sàn và tường, quầy, trần, bếp, mức bừa; ảnh trong chương 3 thật, TV bật và tắt. Xong thì chạy full pwsh tools/test.ps1, pwsh tools/check.ps1 (bước 0 có đổi scene), git checkout -- game/default_bus_layout.tres; commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không Tripo, giữ ánh sáng (không thêm đèn). Giữ nguyên va chạm, anchor, vùng, navmesh, TV bật/tắt, đồng hồ bếp dừng, lỗ cửa. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, luật, lane A, âm thanh. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS (D-179).
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng.
Commit nhỏ "T-263: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì (kể cả 6 đầu xác), nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, câu hỏi cho chủ dự án, dòng RESULT test và check, có bị chặn không.
```
**Lượt 2** (sau khi chủ dự án chọn, HARU/integrator đã ghi vào card mục 1): dán
```text
Tiếp tục T-263 lượt 2: chủ dự án đã chọn (card mục 1). Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-263-realistic-graphics-wave6-canteen: git status, git fetch origin, git rebase origin/main (lấy card mục 1), git lfs pull. Làm cả nhà ăn, bếp, kho, tường tây lối tây, dải A16 quanh nhà ăn, ảnh trước/sau (chương 3 và lối tây chương 4), test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Commit, push nhánh, cập nhật Handoff, báo ngắn như lượt 1 kèm dòng RESULT test và check.
```

## 1r. Giao T-264 (16/11/2026): đồ hoạ thật đợt 7 — nhà nền (nhà A, giảng đường, nhà thể chất), mặt ngoài nhà B, mặt đất, đường, cây, đèn đường, hàng rào còn lại
Gõ `/clear` (hoặc mở phiên mới), `/model` chọn **Opus 5.5**, effort **xhigh** (khó thì **max**), rồi dán:
```text
Việc mới cho lane B: T-264 — đồ hoạ thật đợt 7: nhà nền (nhà A đối diện nhà B, giảng đường, nhà thể chất) có nội thất nhìn qua cửa, mặt ngoài nhà B, và phần mặt đất, đường, cây, đèn đường, hàng rào còn lại của khuôn viên (chương 3–4). Đọc docs/tasks/T-264-realistic-graphics-wave7-shells-ground.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-264-realistic-graphics-wave7-shells-ground origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-264-realistic-graphics-wave7-shells-ground.md).
Card chia BA lượt. Phiên này CHỈ làm lượt 1 (card mục 2): khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp A16 còn lại, phân loại đồ rải (đếm đầu xác trước khi đụng), góc mẫu nhà A, một nhà nền nữa, mặt ngoài nhà B, một đoạn đường có cây, đèn, hàng rào, kèm các phương án ở bước 3 với ảnh trong chương 3 thật. Chụp góc mẫu cả khi bật và tắt occlusion culling, ghi độ sâu nội thất cần ở từng mặt nhà (khối che của core đang đặc bằng cả khối nhà, card mục 5). Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2, 3.
D-166: dựng bằng Blender, không Tripo, giữ ánh sáng (không thêm đèn), không mở lối vào nhà nền. Giữ nguyên va chạm, anchor, vùng, navmesh, ba bóng người cửa sổ nhà A. Thư viện, 6 m quanh thư viện, LibraryBand và lỗ cửa lối tây nhà ăn là đợt 8: không đụng. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, luật, game/scenes/main (kể cả khối che), project.godot, lane A, âm thanh. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS (D-179).
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng; lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.
Commit nhỏ "T-264: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, độ sâu nội thất, câu hỏi cho chủ dự án, dòng RESULT test, có bị chặn không.
```
**Lượt 2** (sau khi chủ dự án chọn, integrator đã ghi card mục 1 và đã thu khối che): dán
```text
Tiếp tục T-264 lượt 2: chủ dự án đã chọn (card mục 1). Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-264-realistic-graphics-wave7-shells-ground: git status, git fetch origin, git rebase origin/main (lấy card mục 1 và khối che đã sửa), git lfs pull. Làm lượt 2 (card mục 2, bước 5–7): nhà A, giảng đường, nhà thể chất, mặt ngoài nhà B, nội thất nhìn qua cửa, ba bóng người cửa sổ, bản nhẹ nhà A cho chương 1–2 nếu mục 1 có chọn; ảnh trước/sau, test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Commit, push nhánh, cập nhật Handoff, báo ngắn kèm dòng RESULT test và check, rồi DỪNG chờ integrator merge. Không làm lượt 3.
```
**Lượt 3** (sau khi integrator merge lượt 2): dán
```text
Tiếp tục T-264 lượt 3. Ở D:\GAME_WORK\lane-b2: git status, git fetch origin, git switch lane-b/T-264-realistic-graphics-wave7-shells-ground, git rebase origin/main (main đã có lượt 2), git lfs pull. Làm lượt 3 (card mục 2, bước 8–9; card mục 1 có thêm việc đổi màu mặt ngoài dãy ban công tầng 4 phía sau nhà B cho khớp mặt sau mới, được sửa floor4_rooms.gd chỉ phần màu đó): mặt đất, đường, vỉa, cây, đèn đường, ghế, xe máy đổ, hàng rào bắc/đông/tây, đồ rải trong hộp A16 đã chốt, khớp mép với các dải đã làm; mảnh xác, máu, vệt kéo không đụng, chỉ thu từng bản MultiMesh về 0. Ảnh trước/sau (cả toàn cảnh từ hành lang tầng 4 nhà B và từ khán đài), overview.jpg, số lần vẽ trước/sau ở ba góc toàn cảnh, test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Commit, push nhánh, cập nhật Handoff, README, CREDITS, báo ngắn kèm dòng RESULT test và check.
```

## 1s. Giao T-265 (viết 19/11/2026; dán SAU KHI T-264 lượt 3 merge): đồ hoạ thật đợt 8 — thư viện ba tầng và dải đất quanh thư viện (ĐÃ XONG, merge `9ae6e4f` 20/11; không dán lại)
Gõ `/clear` (hoặc mở phiên mới), `/model` chọn **Opus 5.5**, effort **xhigh** (model cao nhất của lane B, D-183; lượt sửa lại lần hai thì **max**), rồi dán:
```text
Việc mới cho lane B: T-265 — đồ hoạ thật đợt 8: thư viện ba tầng (vỏ ngoài, ba tầng trong, cầu thang, cửa sau, quầy, bản đồ, kệ sách, bàn đọc) và dải đất 6 m quanh thư viện (chương 3–4). Đọc docs/tasks/T-265-realistic-graphics-wave8-library.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-265-realistic-graphics-wave8-library origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-265-realistic-graphics-wave8-library.md).
Card chia HAI lượt. Phiên này CHỈ làm lượt 1 (card mục 2, bước 1–4): khảo sát, bảng hợp đồng, bản đồ lối đi ba tầng nhìn từ trên (vùng navigation, va chạm, anchor, chỗ sàn trống ngoài lối đi), đi thử bằng thân người chơi thật trong chương 4, kiểm jumpscare có hình hay chỉ có tiếng, liệt kê vùng ngoài nhà x 39…91, z 189…231 (đếm đầu xác trước khi đụng), hai ảnh lối tây nhà ăn; góc mẫu tầng 1 (quầy, thanh sắt, bản đồ, kệ), tầng 2 (bàn đọc, kệ, cửa sổ), cầu thang, cửa sau, cửa chính có chướng ngại, mặt ngoài; các phương án ở bước 3, nhất là mức đầy M1/M2/M3 có ảnh nhìn từ trên. Ảnh trong chương 4 thật, có và không đèn pin. Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không Tripo, giữ ánh sáng (6 đèn giữ nguyên, không thêm đèn). Giữ nguyên va chạm có sẵn, mọi vùng và link navigation, anchor chương 4, cửa sau (cánh treo dưới Hinge), cửa chính đóng, thanh sắt trên quầy, hai vòng đỏ trên bản đồ. Hình mới đặt dưới node Real, không đặt dưới các node Shelf*. Không bày sẵn kết quả của jumpscare. Lối tây nhà ăn đã xong ở T-263: không làm lại. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, luật, ch4_anchors.tscn, room_door.gd, game/scenes/main (kể cả khối che), project.godot, âm thanh. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS (D-179).
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng; lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.
Commit nhỏ "T-265: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, chỗ nào thêm đồ được mà không chạm lối đi, mặt tường nào đặc kín (cho khối che), câu hỏi cho chủ dự án, dòng RESULT test, có bị chặn không.
```
**Lượt 2** (sau khi chủ dự án chọn, integrator đã ghi card mục 1): dán
```text
Tiếp tục T-265 lượt 2: chủ dự án giao integrator chọn, đã ghi ở card mục 1 (D-185). Đọc kỹ mục 1: M2 có thêm dãy kệ hai mặt trong bốn khoang (đúng điều kiện M2 ở mục 4, navigation không đổi), ô cửa ngoài là kính tối có rèm (không phòng giả), thêm ô cửa ngoài ở mặt đông và tây, lan can có va chạm ở mép tây ô cầu thang tầng 2–3 (phần thêm dưới Real/Added, có test), vùng trống quanh các điểm jumpscare. Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-265-realistic-graphics-wave8-library: git status, git fetch origin, git rebase origin/main (lấy card mục 1), git lfs pull. Làm lượt 2 (card mục 2, bước 5–8): vỏ ngoài bốn mặt và mái, cửa chính, cửa sau, cửa sổ, ẩn LibraryBand; ba tầng trong (sàn, tường, trần, máng đèn, quầy, ghế thủ thư, bản đồ, 9 kệ và sách dùng atlas, 3 bàn đọc và ghế, chướng ngại, cầu thang, tay vịn), đồ thêm theo mức đầy đã chọn (đúng điều kiện card mục 4); dải đất trong hộp x 39…91, z 189…231 khớp mép đợt 7. Ảnh trước/sau trong chương 4 thật và 1–2 ảnh chương 3 từ xa, overview.jpg, số lần vẽ trước/sau ở các góc card mục 6, test, rồi full pwsh tools/test.ps1, pwsh tools/check.ps1, git checkout -- game/default_bus_layout.tres. Nếu quá lớn thì dừng sau vỏ ngoài + tầng 1 + cầu thang, chạy đủ test và check, báo để integrator merge rồi làm tiếp. Commit, push nhánh, cập nhật Handoff, README, CREDITS, báo ngắn kèm dòng RESULT test và check.
```
**Lượt 3** (sau review lượt 2, D-186; việc nhỏ): `/clear`, `/model` **Opus 5.5**, effort **high**, rồi dán
```text
Tiếp tục T-265 lượt 3: integrator đã review lượt 2 (đạt về hình và test, chưa merge) và giao thêm một việc nhỏ ở card mục 1 điểm 14 (D-186): bịt các chỗ còn rơi được của ô cầu thang. Ngoài mép nam tầng 3 lane B đã báo, còn khe đông x 84,05…84,89 (giữa tay vịn đông RailCollision*_39 và tường đông) ở tầng 2 và tầng 3, rơi được từ cả đầu nam lẫn đầu bắc. Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-265-realistic-graphics-wave8-library: git status, git fetch origin, git rebase origin/main (lấy card mục 1 và mục 2 "Lượt 3"), git lfs pull. Làm lượt 3 (card mục 2, bước 9–12): viết phép thử rơi trước và cho thấy chúng hỏng trên bản lượt 2; dựng các đoạn lan can có va chạm tên WellRail* dưới Real/Added (kiểu như lan can mép tây, hình trong glb stairs); thêm vào RAILS và tăng ADDED trong test_t265_library; lối vào và lối ra của hai nhịp để hở; mỗi đoạn cách navigation ≥ 0,31 m (hoặc theo ngoại lệ ghi ở điểm 14, ghi số). Chỉ chạy pwsh tools/test.ps1 -Filter t265 và -Filter t264, rồi git checkout -- game/default_bus_layout.tres. KHÔNG chạy full test và check: integrator chạy một lần khi merge. Ảnh r3_well.jpg (1–2 góc lan can mới). Commit, push nhánh, ghi Handoff "### Lượt 3", báo ngắn kèm dòng RESULT và toạ độ từng đoạn lan can, rồi dừng.
```

## 1t. Giao T-266 (viết 20/11/2026): đồ hoạ thật đợt 9 — phòng 407 ở chương 4 và phòng bệnh viện của đoạn kết
Gõ `/clear` (hoặc mở phiên mới), `/model` chọn **Opus 5.5**, effort **xhigh** (D-183; lượt sửa lại lần hai thì **max**), rồi dán:
```text
Việc mới cho lane B: T-266 — đồ hoạ thật đợt 9: phòng 407 ở chương 4 (ba vạt giường lật được, ba chỗ tìm giả, cửa 407 bị phá) và phòng bệnh viện của đoạn kết. Đọc docs/tasks/T-266-realistic-graphics-wave9-room407-hospital.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-266-realistic-graphics-wave9-room407-hospital origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-266-realistic-graphics-wave9-room407-hospital.md).
Card chia HAI lượt. Phiên này CHỈ làm lượt 1 (card mục 2, bước 1–4): khảo sát hai khu, bảng hợp đồng; ảnh phòng 407 trong chương 4 thật (director.run_from room407; từng giường 1, 2, 4 trước và sau khi lật; ba chỗ tìm giả; cửa ở mức hỏng 0, 30, 60, 80 %), thêm một ảnh phòng 407 ở chương 3 và chương 1 cùng góc; ảnh đúng khung Camera_Wake của bệnh viện ở cả hai kết, độ sáng 1,0 và 1,45, và sơ đồ phòng nhìn từ trên có hình nón nhìn. Hình mẫu: giường 2 với vạt mới trước/sau lật có chữ mặt dưới, ô thông gió, tấm trần, cửa ba mức hỏng; khung hình kết của bệnh viện dựng thô đủ để chọn. Các phương án ở bước 3, nhất là: nệm chăn gối đi đâu khi lật vạt (N1/N2), hai y tá chỉ có tiếng ngay giữa khung hình (Y1 rèm quây giường có bóng người, Y2 dời tiếng ra cửa; dựng ảnh mẫu cả hai), khung hình K1/K2, ô thông gió và tấm trần có ở cả bốn chương hay không (C1/C2). Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không Tripo, giữ ánh sáng (không thêm đèn; bệnh viện theo D-167, test_hospital_light phải đạt, ở độ sáng 1,45 không cháy trắng). Phòng 407 gốc và đồ Tripo trong phòng không làm lại; chỉ nhánh Room407 của ch4_anchors.tscn, slat_visual.gd, door407_proxy.gd (phần hình) và hospital_room.tscn/.gd. Các node khác trong ch4_anchors.tscn không đổi một dòng. Không thêm va chạm, không đổi marker, không bày sẵn lời giải. Hình PS1 chỉ ẩn. Mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, bed_slat, search_spot, UI, âm thanh, luật, room_door.gd, game/scenes/main, project.godot. Không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS (D-179, D-184).
Godot theo luật Lượt Godot (file khóa D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng. Chỉ chạy test lọc (card mục 7), rồi git checkout -- game/default_bus_layout.tres. KHÔNG chạy full test và check: integrator chạy khi merge. Lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.
Commit nhỏ "T-266: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, câu hỏi cho chủ dự án, dòng RESULT test lọc, có bị chặn không.
```
**Lượt 2** (D-187 đã ghi ở card mục 1): `/clear`, `/model` **Opus 5.5**, effort **xhigh**, rồi dán
```text
Tiếp tục T-266 lượt 2: chủ dự án và integrator đã chọn, ghi ở card mục 1 (D-187). Đọc kỹ mục 1 cùng các mục 3, 4, 7, 8, 9 vừa sửa theo D-187. Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-266-realistic-graphics-wave9-room407-hospital: git status, git fetch origin, git rebase origin/main (lấy card mục 1), git lfs pull. Làm lượt 2 (card mục 2, bước 5–7):
Phòng 407: vạt V2b cả ba giường, mỗi giường một góc lật (giường 2 khoảng 62°); chữ mực loang ba mảnh; N2 không va chạm (rơi ≤ 0,6 giây; giường 1 và 2 cùng một giường tầng: đồ hai giường nằm riêng, không chồng xuyên, lật theo thứ tự nào cũng vậy; camera ở chỗ dùng tay không nằm trong món nào); nắp trần H1 và chớp thông gió, có phản hồi khi tìm xong qua tín hiệu searched; C2: hai hình này vào phòng 407 gốc ở cả bốn chương theo một trong hai đường ở mục 1 điểm 5 (room407.gd._furnish() ẩn mọi mesh ngoài KEEP_PS1 và ngoài cây đồ thật), ẩn CeilingPanel, VentFrame, VentSlat* của ch4_anchors; sửa hình cửa 407 bị phá trong door407_proxy.gd (từ 60 % ẩn cả Pivot/RoomDoor và bốn hộp Damage/Hole, trả lại khi thoát; kiểm 80 % từ hành lang khi có bốn xác đứng ở cửa).
Phòng bệnh: Y1 rèm có bóng hai người đứng yên như người thường; K2 ngước 11°; vỏ phòng, giường như hình mẫu; Trung T1; Nhật, Ngư dưới chăn không lộ mặt; kết một mình ga phẳng, chăn gấp; thẻ tên (ngoại lệ UI, mục 1 điểm 11): chữ hai mặt, giấy chịu sáng, ở 1,45 không cháy trắng, kết thật đọc được tên Nhật và Ngư từ Camera_Wake.
Ảnh trước/sau trong chương 4 thật (phòng 407 từ cửa: chưa lật, lật cả ba theo hai thứ tự, cửa 0/30/60/80 % từ trong và từ hành lang có xác), phòng 407 chương 1 cùng góc (C2), khung kết ở hai kết, độ sáng 1,0 và 1,45; overview.jpg; số lần vẽ trước/sau theo card mục 5; test test_t266_* theo card mục 7 (thay test_t266_pilot). Chỉ chạy các test lọc ở card mục 7 (có cả chương 1–2 vì C2), rồi git checkout -- game/default_bus_layout.tres. KHÔNG chạy full test và check: integrator chạy khi merge. Lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.
Luật như lượt 1: dựng bằng Blender, không Tripo, không extension Blender, không ảnh AI, không bot, không đo FPS; Godot theo file khoá D:\GAME_WORK\GODOT_DANG_CHAY.txt, đóng Blender và Godot khi không dùng; không push main, không mở PR, không sửa STATUS hay DECISIONS.
Commit, push nhánh, cập nhật Checklist, Handoff "### Lượt 2", README, CREDITS; báo ngắn bằng tiếng Việt kèm dòng RESULT từng test lọc, rồi dừng.
```

## 1u. Giao T-267 (viết 20/11/2026): đồ hoạ thật đợt 10 — năm phòng trường quay CCTV và đồ nhỏ phòng 407
**Dán được: T-266 đã merge 21/11** (`44843bfa`; phòng 407 đã có ô thông gió và nắp trần ở cả bốn chương). Gõ `/clear` (hoặc mở phiên mới), `/model` chọn **Opus 5.5**, effort **xhigh** (D-183; lượt sửa lại lần hai thì **max**), rồi dán:
```text
Việc mới cho lane B: T-267 — đồ hoạ thật đợt 10, đợt môi trường cuối: năm phòng trường quay CCTV (102, 306, 209, 106, 310, cả hành lang trước cửa mỗi phòng) và đồ nhỏ phòng 407. Đọc docs/tasks/T-267-realistic-graphics-wave10-cctv-room407.md.
Ở D:\GAME_WORK\lane-b2: git status (giữ thay đổi đang có, báo nếu có), git fetch origin, git switch -c lane-b/T-267-realistic-graphics-wave10-cctv-room407 origin/main, git lfs pull.
Đầu phiên ghi commit của card đã đọc (git log -1 --format=%h origin/main -- docs/tasks/T-267-realistic-graphics-wave10-cctv-room407.md).
Card chia HAI lượt. Phiên này CHỈ làm lượt 1 (card mục 2, bước 1–4): khảo sát, bảng hợp đồng; ảnh đúng khung feed 320 × 240 (phóng ×3) và ảnh 1080p cùng camera của năm phòng và năm hành lang lúc director dựng cảnh (chương 1: _cctv_scene như test_cctv; chương 2: _cctv_310); kiểm kê đồ nhỏ phòng 407 (A30) kèm ảnh gần có đèn pin, ghi rõ file nào sở hữu từng món; hình mẫu phòng 306 và hành lang của nó; phương án D1/D2 (đồ trong phòng), W1/W2 (tường sau), hành lang, dấu hiệu trên feed. Xong thì commit, push nhánh, ghi Handoff, báo và DỪNG để chủ dự án chọn. Không làm lượt 2.
D-166: dựng bằng Blender, không tạo mẫu Tripo mới (được dùng lại đồ Tripo có sẵn của 407), giữ ánh sáng (không thêm, không đổi đèn). Chỉ năm nhánh Room* của cctv_set.tscn; Corridor của trường quay, sinh viên, xác, quản lý không đổi. Va chạm trùng main, đồ mới không có va chạm; camera, marker, nạn nhân giữ nguyên. Hình PS1 chỉ ẩn. Trường quay được nạp ở cả bốn chương: dùng lại mesh, texture có sẵn trước; không texture mới 2K; mọi texture mới từ 512 px trở lên phải nén VRAM trong .import (compress/mode=2; normal thêm compress/normal_map=1).
Không đổi director, UI (cả tab Camera và kích thước feed), âm thanh, luật, lời thoại, game/scenes/main, project.godot. Không extension Blender, không ảnh AI, không bot, không đo FPS (D-179, D-184).
Godot theo luật Lượt Godot (file khoá D:\GAME_WORK\GODOT_DANG_CHAY.txt); máy ít RAM: đóng Blender và Godot khi không dùng. Chỉ chạy test lọc (card mục 7), rồi git checkout -- game/default_bus_layout.tres. KHÔNG chạy full test và check: integrator chạy khi merge. Lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.
Commit nhỏ "T-267: ...", push nhánh. Không push main, không mở PR. Cập nhật Checklist và Handoff trong card. Không sửa STATUS hay DECISIONS.
Cuối phiên báo ngắn bằng tiếng Việt: xong gì, nhánh, commit, ảnh phương án ở đâu, phương án đề xuất, câu hỏi cho chủ dự án, dòng RESULT test lọc, có bị chặn không.
```
**Lượt 2** (D-188 đã ghi ở card mục 1): `/clear`, `/model` **Opus 5.5**, effort **xhigh**, rồi dán
```text
Tiếp tục T-267 lượt 2: chủ dự án và integrator đã chọn, ghi ở card mục 1 (D-188). Đọc kỹ mục 1 cùng các mục 4, 5, 7, 8 vừa sửa theo D-188. Ở D:\GAME_WORK\lane-b2 trên nhánh lane-b/T-267-realistic-graphics-wave10-cctv-room407: git status, git fetch origin, git rebase origin/main (lấy card mục 1 và commit core 1324a2aa: feed chép far, bật occlusion culling), git lfs pull. Làm lượt 2 (card mục 2, bước 5–8):
Năm phòng: D2 (giường tầng, tủ Tripo và đồ 407 như T-255; đồ riêng từng phòng đúng chỗ), W2, mùng PS1 ẩn mesh và thay bằng mùng 407 cùng trạng thái đóng/mở (từ Cam vẫn thấy rõ nạn nhân, mùng 209 vẫn là dấu hiệu), cửa mở vào trong, bảng số xanh đậm sau Label3D; năm hành lang H1 với mask nhỏ ≤ 512 px nén VRAM. Thêm occluder hộp ở tường năm phòng và năm hành lang, chỉ trong năm nhánh Room* (không trong Corridor); chụp bật/tắt occluder ở mọi feed phòng và hành lang, phải giống nhau từng điểm ảnh (chạy 3 s rồi mới dừng thời gian, chụp liền nhau). Trần đo khi có occlusion: phòng ≤ 160.000 tam giác, mỗi glb đợt 10 < 5.000, feed phòng ≤ 150 lần vẽ, feed hành lang ≤ 250; bộ nhớ hình chương 1–2 thêm ≤ 25 MB, chương 3 ≤ 5 MB. Hình mới trong Room310 không có hàm set_state.
Đồ nhỏ 407 (A30): chỉ các file ở mục 1 điểm 8 (dat_notebook, guitar_songbook, khoa_outlet, trash_bin, hai mesh ShowerYes/Button và ShowerNo/Button trong room407_anchors, transform Door407/Pivot/RulesPaper trong floor4.tscn). Chỉ đổi node mesh và vật liệu; node khác trùng main (test vân tay từng scene); hình bao lệch ≤ vài cm (tay T-239/T-241/T-243 nhắm vào); không đặt hình ở đường dẫn khớp REPLACED_PS1. Test nào băm floor4 bị đổi vì RulesPaper thì cập nhật hằng kèm bằng chứng bỏ dòng đó ra thì trùng main.
Đồng bộ bốn chương (bước 7): chụp cùng góc ở chương 1–4, liệt kê chỗ khác không có lý do, không sửa ngoài phạm vi.
Ảnh before/after (feed 320 × 240 phóng ×3 và 1080p), a30_*, sync_ch1..4_*, overview.jpg; test test_t267_* theo mục 7. Trước khi chạy test: grep game/tests theo tên file mọi scene đã sửa và chạy cả những test đó. Mỗi bộ lọc chạy TRỰC TIẾP (không chạy nền), dưới 10 phút; lệnh nào quá 10 phút tự chuyển nền thì chạy ngay bộ lọc kế tiếp trực tiếp. Rồi git checkout -- game/default_bus_layout.tres. KHÔNG chạy full test và check: integrator chạy khi merge. Lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.
Luật như lượt 1: dựng bằng Blender, không tạo mẫu Tripo mới, không extension Blender, không ảnh AI, không bot, không đo FPS; Godot theo file khoá D:\GAME_WORK\GODOT_DANG_CHAY.txt, đóng Blender và Godot khi không dùng; không push main, không mở PR, không sửa STATUS hay DECISIONS.
Commit, push nhánh, cập nhật Checklist, Handoff "### Lượt 2", README, CREDITS; báo ngắn bằng tiếng Việt kèm dòng RESULT từng test lọc, rồi dừng.
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
