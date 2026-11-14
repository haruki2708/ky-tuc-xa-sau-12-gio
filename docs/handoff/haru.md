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
**Cập nhật:** 14/11/2026 khoảng 03:30, integrator (Fable 5.2) nhận lại việc từ HARU: **T-256 đã merge vào main**, card T-258 cho lane B, bản chơi `e738e2e` đã build. Không có việc dở.

**Việc dở ngay lúc này (đọc trước):**
- **VIỆC GIAO CHO HARU (14/11, D-173, chủ dự án: "cho haru làm"): [T-260](../tasks/T-260-occlusion-culling.md) occlusion culling.** Đọc card. Tóm tắt:
  - Nhánh `integrator/T-260-occlusion-culling` từ main. Bật `rendering/occlusion_culling/use_occlusion_culling` trong `game/project.godot`; occluder hình khối (`BoxOccluder3D`, `QuadOccluder3D`…) đặt trong tường, sàn kín, để trong **cảnh riêng của core** `game/scenes/main/occlusion/`, gắn vào `chapter1.tscn`…`chapter4.tscn`. **Không sửa cảnh lane B** (lane B đang làm T-258 `building_b.tscn`, rồi T-259 vườn hoa).
  - Đọc tài liệu Godot 4.7 trước (bake occluder chỉ có trong editor; dự án chạy không cửa sổ).
  - Ảnh bật/tắt cùng camera và một lượt camera di chuyển qua cửa, góc cầu thang (không được có vật biến mất, nhấp nháy). Đo FPS trước/sau bằng `build/integrator/t255_fps.gd` (thêm tuỳ chọn bật/tắt), 1080p, chương 1 và 3, 2 vòng. Báo cáo `tools/reports/T-260-occlusion-culling.md`.
  - **Không merge khi chủ dự án chưa quyết** bật trong bản chơi. Đề xuất bật chỉ khi có lợi rõ và không lỗi hình.
  - Lane B chạy song song: chờ khoá Godot, nhường khi lane B cần, không tắt Godot của lane B. Integrator không chạy cùng lúc với HARU.
  - **Tiến độ HARU (từ 14/11 13:20, chủ dự án đồng ý), nhánh `integrator/T-260-occlusion-culling`:**
    - Bước 1 xong: đọc tài liệu Godot 4.7 (ghi trong Handoff card khi viết báo cáo). Điểm chính: bật bằng cài đặt dự án, bật/tắt lúc chạy bằng `get_tree().root.use_occlusion_culling`; vật chỉ bị bỏ khi hộp bao bị che hết; "Bake Occluders" là nút của editor; dời/ẩn occluder lúc chạy phải tính lại vài khung (nên occluder đứng yên, không gắn cánh cửa).
    - Bước 2 xong: khảo sát chương 1 và 3 thật (cảnh tạm `game/_probe_tmp/t260_survey.*`, bản lưu `art_source/graphics_upgrade/occlusion/survey.gd`; số liệu `build/haru/t260_survey_ch*.json`, không commit). Phòng 407 (~0,67 triệu tam giác) luôn được vẽ kể cả khi đứng ngoài; nội thất 401–406, 408 đã tự ẩn khi cửa đóng (`floor4_rooms.gd`).
    - Bước 3 xong (WIP commit): `project.godot` bật; `game/scenes/main/occlusion/occluders_floor4.tscn` (53 hộp: sàn, tường mặt phòng hai bên lỗ cửa, đầu cửa, vách giữa phòng, 407, nhà vệ sinh chung) gắn vào 4 chương; `occluders_campus.tscn` (106 hộp: sàn giữa tầng, vách, mặt trước tầng 1–3 nhà B, khối tầng 5–6, vỏ nhà A, giảng đường, nhà thể chất) gắn vào chương 3–4. Sinh bằng `art_source/graphics_upgrade/occlusion/make_occluders.py` (mỗi occluder nằm trong một hộp va chạm tường/sàn, dày 4 cm, hai đầu lùi 0,1 m). Chưa đặt: tường hậu, giếng thang, vách phòng quản lý (cửa sổ vẽ chồng qua).
    - Test mới `game/tests/core/test_t260_occlusion.gd` đạt 4/4 (13:42).
    - Bước 4 xong (14:32–14:50): ảnh tắt/bật cùng camera (`art_source/graphics_upgrade/occlusion/capture.gd`, thời gian gần như dừng `time_scale 0.0001`; `0` làm NaN ở khuôn viên và treo Godot): chương 1 13 góc, chương 3 15 góc, **giống hệt từng điểm ảnh** trừ mép cánh quạt. Tam giác vẽ giảm nhiều (vd chương 1 mở 7 cửa 2,08 → 0,75 triệu; dọc hành lang 497 → 247 nghìn; chương 3 tầng 2 1,98 → 1,15 triệu). 5 lượt camera đi (tắt rồi bật, 1.279 cặp khung lưu trong `build/haru/t260_walk/`): không vật nào hiện trễ; chỗ khác chỉ do quạt, cánh cửa 402 đang mở dở, hai khung camera xuyên vách nhà B tầng 1 (người chơi không vào được, capsule 0,3 m). Ảnh ghép `occlusion/previews/compare_ch1.jpg`, `compare_ch3.jpg` (`make_compare.py`).
    - Bước 5 xong (14:46–14:58, chủ dự án cho đo; máy trống, 5,9 GB RAM): 2 vòng, chương 1 và 3. Góc nặng nhanh hơn rõ (chương 3 sảnh 69 → 98, cả bảy cửa 62 → 75, 406 nhìn ra 82 → 118, ban công 72 → 100; góc chậm nhất chương 3 62 → 70); 3 góc nhẹ (> 95 FPS) chậm ~5%.
    - Full test **988/0** (15:05–15:35), check **0** (15:53). `game/_probe_tmp/` đã xoá. Báo cáo [`tools/reports/T-260-occlusion-culling.md`](../../tools/reports/T-260-occlusion-culling.md) (trên nhánh), Handoff card, STATUS xong.
    - **14/11 ~16:00: chủ dự án chọn bật (D-174); HARU merge vào main `275308d`** (cây `game/` trùng cây đã full test). Tiếp: build bản chơi. Dòng dưới là trạng thái lúc chờ quyết:
    - 14/11 15:55: T-260 xong trên nhánh, chưa merge, chờ chủ dự án quyết bật trong bản chơi (HARU đề xuất bật). Nếu bật: ghi D-174, merge nhánh `integrator/T-260-occlusion-culling` (cây `game/` đã full test trên nhánh, main chưa đổi lúc đó; nếu main đã có T-258 thì chạy lại full test sau merge), build. Card, STATUS, haru.md này đã chép sang main (commit tài liệu) cho integrator đọc.
  - Công cụ của integrator trong `build/integrator/`: `godot_steps_locked.ps1` (gọi bằng `&`), `run_tests_locked.ps1`, `package_locked.ps1`, `t255_fps.gd`, `t257_capture.gd` (mẫu cảnh chụp).
- **14/11: D-172, chủ dự án duyệt đồ hoạ thật đợt 1 (T-250, T-254) và đợt 2 (T-253).** Đợt 3 vườn hoa: card [T-259](../tasks/T-259-realistic-graphics-wave3-garden.md), prompt `lane-b.md` mục 1n (lượt 1 góc mẫu rồi dừng chờ chủ dự án chọn; lượt 2 cả vườn), giao sau T-258.
- **T-256 merged** (lane B `9153597`; cây `game/` sau merge trùng cây lane B đã chạy full test 984/0; integrator chạy lại check 0 lỗi, `test_t256` 9/9, 14/11 03:21). Review trong card.
- **Bản chơi mới nhất** (package PASS 14/11 03:23, commit `e738e2e`): `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-e738e2e-win64.zip` (497 MiB); có T-253, T-254, T-255, D-171, T-257, T-256. Đã báo chủ dự án; chưa ai chơi thử.
- **[T-258](../tasks/T-258-main-stairs-wall-over-washroom.md)** (lane B, todo): ở chương 3–4 tường PS1 của giếng cầu thang chính lấn 6 cm vào nhà vệ sinh tầng 4, che gương và máng rửa mới. Prompt `lane-b.md` mục 1m; chủ dự án dán khi lane B có hạn mức.
- **Chờ chủ dự án chơi thử** (T-253, T-254, T-255, D-171, T-257, T-256) và chọn: T-255 (nhà tắm góc sau, ban công cả bề ngang, chủ đề phòng, khoá cửa phòng chương 3–4, cánh cửa mở không va chạm); T-256 (màu gạch và góc cửa buồng, đồ trước mỗi phòng, tay gạt gọn); xem ảnh T-257 `vram_compress/previews/compare_closeup.jpg`.
- Chưa làm: occlusion culling (yêu cầu thay đổi T-253); bốn lỗi nhỏ STATUS mục 7; yêu cầu thay đổi 3 của T-255 (director bỏ qua mở phòng khi người chơi đang ở trong).
- **Tài khoản các lane (kiểm 14/11):** A `deptraihoang1627` (ChatGPT), C `hoanganhh1628`, E `bululachup`; B `deptraihoang1627` (Claude); HARU `hoangdeptrai1628` (Claude, đã tách khỏi lane B); integrator `tunank1103`. Máy lúc 02:50 chỉ trống 2,1–2,4 GB RAM (Chrome, Blender của lane B còn mở).

**Lịch sử 13/11 tối – 14/11 (HARU làm T-257, đã xong):**
Bàn giao lúc 13/11 23:25: integrator sắp hết hạn mức, giao T-257 (nén bộ nhớ hình) cho HARU. Trước đó 22:55: T-255 đã merge vào main (full test 975/0, check 0), D-171, đo FPS, build bản chơi `9e5613f`.

**HARU làm T-257 (từ 13/11 23:20, chủ dự án đồng ý), cập nhật sau mỗi bước:**
- Bước 1–5 **xong**, commit WIP trên nhánh `integrator/T-257-vram-compress`:
  - `t257_apply.ps1`: đổi đúng 333 `.import` (109 normal map), không đổi file nào khác. Import có khoá (23:25): 18 giây, thoát 0, không lỗi; các `.import` giờ trỏ `*.s3tc.ctex`, `vram_texture: true`.
  - Chụp "sau" (23:28): **chương 1 đỉnh 3.505 → 1.143 MB (texture 3.359 → 998 MB); chương 3 đỉnh 3.664 → 1.249 MB (texture 3.502 → 1.087 MB).**
  - So ảnh: PSNR từng cặp 35–45 dB, độ sáng trung bình gần như không đổi; ba cặp khác nhiều nhất (`ch3_08`, `ch1_11`, `ch1_04`) chỉ khác ở quạt trần và quạt đứng đang quay. Cận cảnh 1:1 chăn, màn, sàn, tường, tủ, nhà tắm, bàn Phúc, bàn trực: không thấy vệt nén hay normal lạ. **Không texture nào phải trả về không nén.** Thanh sắt (`protagonist/iron_bar_*` normal, orm, đồ cầm tay chương 3) nằm trong 333, không có trong ảnh (thân người chơi bị ẩn khi chụp).
  - Ảnh ghép: `art_source/graphics_upgrade/vram_compress/previews/compare_ch1.jpg`, `compare_ch3.jpg`, `compare_closeup.jpg` (script `vram_compress/make_compare.py`).
  - HARU dùng bản chép `godot_steps_locked.ps1` ghi tên "HARU" vào file khoá (thư mục tạm của HARU, không sửa script của integrator).
- Bước 6 **xong**: full test **975/0** (khoá 13/11 23:34 → 14/11 00:03), check **0 lỗi** (00:20); log `build/integrator/t257full*.log`. Chủ dự án cho xếp hàng ngay khi lane B đang dùng khoá (test lọc T-256).
- Bước 7: báo cáo [`tools/reports/T-257-vram-compress.md`](../../tools/reports/T-257-vram-compress.md), Handoff card, STATUS xong; **merge vào main `fe62f3b`** (14/11 00:21), đã đẩy. Nhánh `integrator/T-257-vram-compress` giữ trên origin (`9215b06`).
- **Bản chơi đã build** (package PASS 14/11 00:23, commit `fe62f3b`, bản chép `package_locked.ps1` ghi tên HARU): `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-fe62f3b-win64.zip` (496 MiB). Có T-253, T-254, T-255, D-171 (như bản `9e5613f`) và T-257.
- **14/11 02:48: HARU dừng, trả việc cho integrator** (chủ dự án báo integrator có hạn mức lại). Không có việc dở: main `69f2488` sạch, đã đẩy; HARU không giữ khoá Godot, không có lượt chạy nền; `game/_probe_tmp/` đã xoá. Việc tiếp theo của integrator: chờ lane B xong T-256 rồi review, merge; chờ chủ dự án xem ảnh T-257 và chơi thử bản `fe62f3b`.
- **14/11 00:30:** integrator vẫn hết hạn mức; chủ dự án chọn để HARU **chờ lane B xong T-256** (nhánh đã có WIP `d635a8b`) rồi review, merge, full test + check, build. Không giao việc mới cho lane Codex.
- **T-257 xong.** Chờ chủ dự án: xem `art_source/graphics_upgrade/vram_compress/previews/compare_closeup.jpg` (và `compare_ch1.jpg`, `compare_ch3.jpg`), chơi thử bản `fe62f3b` (phòng 407, nhà B: đồ, tường, sàn có trông khác không; chương 3 có còn màn hình đen không).

**BÀN GIAO CHO HARU — [T-257](../tasks/T-257-vram-compress-room407-textures.md) nén VRAM texture phòng 407 và nhà B (chủ dự án chọn 13/11 tối)**
- **Trạng thái lúc dừng:** repo ở nhánh `integrator/T-257-vram-compress` (đã đẩy), **chưa đổi file `.import` nào**. Đã có: card, 20 ảnh "trước" (`art_source/graphics_upgrade/vram_compress/previews/before_ch1_*.jpg` 12 ảnh, `before_ch3_*.jpg` 8 ảnh), số đo trước: **chương 1 đỉnh 3.505 MB, chương 3 đỉnh 3.664 MB** (texture 3.359 và 3.502 MB). Khoá Godot đã trả, `game/_probe_tmp/` đã xoá. Main không đổi ngoài tài liệu.
- **Công cụ soạn sẵn trong `build/integrator/` (không commit):**
  - `t257_inventory.xml`: kiểm kê 393 texture không nén (đường dẫn, kích thước, loại).
  - `t257_apply.ps1`: đổi `.import` của **333 texture** màu, normal, độ nhám từ 1024 px trở lên (`compress/mode` 0 → 2; 109 normal map thêm `compress/normal_map` 0 → 1). Đã thử khô với `-WhatIf`: chọn 333, chưa ghi gì.
  - `t257_capture.gd`: cảnh chụp (chép vào `game/_probe_tmp/t257_capture.gd` cùng một `t257_capture.tscn` có root `Node3D` gắn script đó; chạy `--rendering-method forward_plus res://_probe_tmp/t257_capture.tscn -- --chapter=1 --tag=after`, rồi `--chapter=3`; in dòng `VRAM:`).
  - `godot_steps_locked.ps1 -Label <tên> -Steps @('tên|giây|tham số godot', …)`: lấy khoá, chạy lần lượt, trả khoá; gọi bằng `&` trong pwsh (không dùng `pwsh -File`, mảng bị dính).
- **Các bước còn lại:**
  1. `& build\integrator\t257_apply.ps1` (ghi thật).
  2. Có khoá: `godot_steps_locked.ps1 -Label t257import -Steps @('import|1200|--headless --import')` (nén 333 texture, có thể mất vài phút); `git status` phải chỉ thấy các `.import` đổi.
  3. Chụp "sau" chương 1 và 3 (cùng lệnh như ảnh "trước", `--tag=after`), ghi số `VRAM:`. Mong đợi giảm khoảng 2 GB trở lên.
  4. **Tự xem từng cặp ảnh trước/sau** (nhất là `01_bunk_a_bedding`, `08_blanket_close`, `07_floor_and_wall`, `12_wall_close`, `02_lockers`, `06_bathroom`): thấy vệt nén, bệt màu, normal lạ (bề mặt bóng sai, tối sai) ở texture nào thì trả texture đó về `compress/mode=0` (hoặc thử `compress/high_quality=true`) rồi import lại, ghi vào báo cáo. Nếu **mọi** normal trông sai: bỏ `compress/normal_map=1` (trả về 0) cho cả 109 file rồi import lại.
  5. Ghép ảnh so sánh cho chủ dự án (Python + PIL có sẵn; mẫu `art_source/graphics_upgrade/realistic_map/wave1/make_compare.py`), để trong `art_source/graphics_upgrade/vram_compress/previews/compare_*.jpg`.
  6. Xoá `game/_probe_tmp/`. Full test + check: `& build\integrator\run_tests_locked.ps1 -Label 'T-257 full' -Name t257full -Filters @('') -Check` (chạy nền, khoảng 50 phút; kỳ vọng 975/0, check 0).
  7. Viết `tools/reports/T-257-vram-compress.md` (số trước/sau, texture nào để nguyên), điền Handoff card, cập nhật STATUS, merge nhánh vào main, đẩy, build bản chơi (`package_locked.ps1 -Label 'package T-257' -Name package_t257`), báo chủ dự án xem ảnh so sánh và chơi thử.
- **Lưu ý:** lane B đang làm T-256 và dùng khoá Godot từng lúc: chờ khoá, không tắt Godot của nó; import và full test là lượt dài, nếu lane B đang chờ khoá quá lâu thì nhường. Máy ít RAM: việc nền bị dừng vì thiếu RAM thì không tự chạy lại.
- Không nén ở lượt này (ghi trong card): texture dưới 1024 px, texture có chữ (lịch, thời khoá biểu, poster, mặt đồng hồ, sổ, bảng thông báo, nhãn), bầu trời đêm, mask shader nhà B, texture nhân vật, texture PS1 cũ (test yêu cầu không nén).

**Việc khác đang mở (đọc sau phần bàn giao):**
- **Đo FPS sau T-255: xong** (13/11 23:00, [báo cáo](../../tools/reports/T-255-rooms-fps.md)): 1080p trung bình ≥ 60 mọi góc ở chương 1 và 3; thấp nhất 62 FPS (chương 3, mở cả bảy cửa); chương 3 dùng 3.665 MB trên 4 GB bộ nhớ hình. Cảnh thử đã xoá; script lưu ở `build/integrator/t255_fps.gd`.
- **Bản chơi đã build** (package PASS 13/11 22:58, commit `9e5613f`): `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-9e5613f-win64.zip`; có T-253, T-254, T-255, D-171. Đã báo chủ dự án thử: mở cửa 401–406, 408 bằng tay ở chương 1, vào nhà tắm, ra ban công; gõ tường 406 ở chỗ mới (D-171); chương 3 xác vẫn phá cửa phòng tầng 4.
- Chờ chủ dự án chọn sau khi chơi thử T-255 (lane B làm theo đề xuất): nhà tắm góc sau; ban công cả bề ngang; chủ đề từng phòng; có khoá hẳn cửa phòng ở chương 3–4 không; cánh cửa mở không va chạm. Yêu cầu thay đổi 3 của T-255 (director bỏ qua mở phòng khi người chơi đang ở trong) chưa làm.
- **T-256** (tầng 4 phần còn lại, D-170): **chủ dự án đã dán prompt `lane-b.md` mục 1l, lane B đang làm từ 13/11 23:00** (nhánh `lane-b/T-256-floor4-washroom-corridor-props` từ main `8aad1c3`). Lane B sẽ dùng khoá Godot từng lúc: integrator không giữ Godot lâu, không tắt Godot của nó. Khi lane B báo xong: review, merge như thường. Integrator đã đo cửa thoát hiểm: tấm cánh hết chồng lan can, tay gạt mặt ngoài đâm vào tay vịn khoảng 2 cm (card phần C).
- Việc đề xuất khác chưa làm: phương án occlusion culling (yêu cầu thay đổi T-253, làm khi có số FPS); bốn lỗi nhỏ STATUS mục 7; nén VRAM các texture Tripo của 407 (lane B nêu: chương 3 dùng khoảng 3.660 MB trên 4 GB).

**Main:** merge T-255 (lane B `7f94e14`; integrator sửa 5 test của lane A: phân loại `RoomDoorHand`; **D-171** dời `WallKnock406` z −1,65 → −4,4 vì chỗ cũ không với tới được từ trong 407 từ khi có thân). Full test 975/0, check 0 (13/11 21:56–22:47). Trước đó: T-254 `14c574e`, T-253 `75550f1`, hộp báo cháy nút nhấn (D-169). **Bản chơi mới nhất: `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-9e5613f-win64.zip` (package PASS 13/11 22:58): thêm T-253, T-254, T-255, D-171; chưa chơi thử.** Bản trước `b1b1cb3` (13/11 11:08): T-244, T-246, T-249, T-250, T-251 và sửa ánh sáng bệnh viện. Chủ dự án đã chơi và duyệt bản `04ddc7d` (T-244, T-246, T-249, T-251).

**Đang chạy**
- **Lane B:** đang làm [T-256](../tasks/T-256-floor4-washroom-corridor-props.md) (từ 13/11 23:00). Còn yêu cầu thay đổi của T-253: bật occlusion culling (`project.godot`), làm khi có số đo FPS.

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

**Số tiếp theo:** D-174, T-261.
