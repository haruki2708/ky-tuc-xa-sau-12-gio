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
**Cập nhật:** 13/11/2026 khoảng 22:55, integrator (Fable 5.2): **T-255 đã merge vào main** (full test 975/0, check 0), D-171; tiếp theo đo FPS rồi build bản chơi.

**Việc dở ngay lúc này (đọc trước):**
- **Đo FPS sau T-255: xong** (13/11 23:00, [báo cáo](../../tools/reports/T-255-rooms-fps.md)): 1080p trung bình ≥ 60 mọi góc ở chương 1 và 3; thấp nhất 62 FPS (chương 3, mở cả bảy cửa); chương 3 dùng 3.665 MB trên 4 GB bộ nhớ hình. Cảnh thử đã xoá; script lưu ở `build/integrator/t255_fps.gd`.
- **Build bản chơi** (`build/integrator/package_locked.ps1 -Label 'package T-255' -Name package_t255`, chạy nền từ khoảng 23:10; log `build/integrator/package_t255.log`). Xong thì báo chủ dự án thử: mở cửa 401–406, 408 bằng tay ở chương 1, vào nhà tắm, ra ban công; gõ tường 406 ở chỗ mới (D-171); chương 3 xác vẫn phá cửa phòng tầng 4.
- Chờ chủ dự án chọn sau khi chơi thử T-255 (lane B làm theo đề xuất): nhà tắm góc sau; ban công cả bề ngang; chủ đề từng phòng; có khoá hẳn cửa phòng ở chương 3–4 không; cánh cửa mở không va chạm. Yêu cầu thay đổi 3 của T-255 (director bỏ qua mở phòng khi người chơi đang ở trong) chưa làm.
- **T-256** (tầng 4 phần còn lại, D-170): card và prompt `lane-b.md` mục 1l xong, **chủ dự án dán được ngay** (T-255 đã merge). Integrator đã đo cửa thoát hiểm: tấm cánh hết chồng lan can, tay gạt mặt ngoài đâm vào tay vịn khoảng 2 cm (card phần C).
- Việc đề xuất khác chưa làm: phương án occlusion culling (yêu cầu thay đổi T-253, làm khi có số FPS); bốn lỗi nhỏ STATUS mục 7; nén VRAM các texture Tripo của 407 (lane B nêu: chương 3 dùng khoảng 3.660 MB trên 4 GB).

**Main:** merge T-255 (lane B `7f94e14`; integrator sửa 5 test của lane A: phân loại `RoomDoorHand`; **D-171** dời `WallKnock406` z −1,65 → −4,4 vì chỗ cũ không với tới được từ trong 407 từ khi có thân). Full test 975/0, check 0 (13/11 21:56–22:47). Trước đó: T-254 `14c574e`, T-253 `75550f1`, hộp báo cháy nút nhấn (D-169). **Bản chơi chưa build lại sau T-254, T-253, T-255.** Bản chơi mới nhất: `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-b1b1cb3-win64.zip` (package PASS 13/11 11:08): có T-244, T-246, T-249, T-250, T-251 và sửa ánh sáng bệnh viện. Chủ dự án đã chơi và duyệt bản `04ddc7d` (T-244, T-246, T-249, T-251).

**Đang chạy**
- **Lane B:** rảnh sau T-255 (hết hạn mức tối 13/11); việc tiếp theo T-256, prompt `lane-b.md` mục 1l. Còn yêu cầu thay đổi của T-253: bật occlusion culling (`project.godot`), làm khi có số đo FPS.

**Lane khác**
- Lane A, C, E (Codex, integrator điều khiển bằng `D:\GAME_WORK\chay_lane.ps1`, [DIEU_KHIEN_LANE.md](DIEU_KHIEN_LANE.md)): rảnh, không có việc. Ba lane dùng ba tài khoản ChatGPT khác nhau (integrator đã kiểm 13/11). Lane C hết hạn mức tới 16:09 hôm 13/11.
- **D-168:** lane Codex dựng đồ hoạ chưa đạt mức phòng 407 (T-252 không merge), nên đồ hoạ giao lane B. Chủ dự án muốn lane B dùng **Opus 5.5 xhigh/max**, không Fable 5.2 (tốn hạn mức).
- Lane HARU: dự phòng.

**Chờ chủ dự án**
- Chơi thử bản 11:08: bàn trực tầng 4, cửa thoát hiểm và hai cầu thang nhà B (chương 3), bệnh viện chương 4 (chỉ chỉnh ánh sáng; đồ hoạ bệnh viện là đợt 9). Máy chủ dự án để độ sáng 1,45.
- Có muốn đưa đợt 9 (bệnh viện) lên sớm không (integrator vừa hỏi).
- Xoá bản sao đăng nhập cũ lane B `C:\Users\ADMIN\.claude-lane-b`: chờ chủ dự án đóng mọi cửa sổ lane B cũ và nói "đã đóng"; trước khi xoá chép ghi nhớ T-247 (`projects\D--GAME-WORK-lane-b2\memory\t247-ch3-survey.md` và dòng trong MEMORY.md) sang `D:\ClaudeConfig\lane-b`.

**Luật đã rút ra hôm nay**
- Máy ít RAM (lúc 11:06 chỉ trống 3,3 GB; Chrome và `rsEngineSvc` ăn nhiều). Việc nặng chạy tiền cảnh hoặc lần lượt; việc nền bị dừng vì thiếu RAM thì không tự chạy lại khi chưa hỏi.
- Lane Codex chờ khoá Godot vẫn tốn hạn mức: khi lane Codex đang chạy, integrator không giữ Godot lâu; prompt dặn lane dừng và báo nếu chờ khoá quá 10 phút.
- Lane hết hạn mức hay bị dừng giữa chừng: lưu (commit, push) phần đã làm lên nhánh của lane, gỡ khoá Godot nó bỏ lại (khi không còn tiến trình Godot nào).
- Script chạy test, khoá, đóng gói của integrator: `build/integrator/run_tests_locked.ps1`, `run_locked.ps1`, `package_locked.ps1` (thư mục `build/` không commit).

**Số tiếp theo:** D-171, T-257.
