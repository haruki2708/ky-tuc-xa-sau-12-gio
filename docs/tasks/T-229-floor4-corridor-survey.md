# T-229 — Hành lang tầng 4: khảo sát hiện trạng và kế hoạch nâng đồ họa (G5)
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: (chủ dự án điền tên tài khoản GPT mới)
- Nhánh: `lane-b/T-229-floor4-corridor-survey` từ `origin/main` mới nhất.
- Quyết định giao: **D-139** (việc thử đầu tiên của tài khoản lane B mới). Integrator chấm theo bảng trong `docs/tasks/README.md`.
- Lượt này **chỉ khảo sát, chụp ảnh và viết kế hoạch**. Không sửa scene chơi được.

## Bối cảnh
- Phòng 407 đã gần chân thực:
  - đồ vật Tripo (G3, D-103…D-114);
  - vỏ phòng làm bằng Blender (T-222, D-128, D-129);
  - ổ điện, quạt (T-226).
- Hành lang tầng 4 bên ngoài vẫn là hình **PS1**. Cả 4 chương đều đi qua tầng 4 (quản lý tuần tra, gõ cửa, đuổi theo ở chương 1; chương 2–4 cũng dùng), nên đây là cảnh tiếp theo của G5 (`docs/ROADMAP.md`).
- File chính (lane B): `game/scenes/levels/floor4/floor4.tscn`, `floor4.gd`, `corridor.tscn`, `duty_desk.tscn`, `washroom.tscn`, `door407.gd`.
- Bài học từ phòng 407:
  - `art_source/graphics_upgrade/room407_shell/README.md` (vỏ Blender, texture CC0, cửa Tripo);
  - `art_source/graphics_upgrade/room407_furnished/`;
  - phiếu Tripo mẫu `docs/handoff/TRIPO_DOT1_PHONG407.md`, `TRIPO_CUA_PHONG407.md`.
- Ngân sách: 1080p ≥ 60 FPS trên RTX 3050 Laptop. Phòng 407 hiện thấp nhất khoảng 86 FPS (D-132).

## Việc cần làm
1. **Hiện trạng:**
   - đo kích thước hành lang;
   - liệt kê cửa phòng, cầu thang, bàn trực, nhà vệ sinh chung, đèn, cửa sổ, đồ trang trí đang có;
   - ghi đồ nào là PS1, đồ nào đã nâng.
2. **Thứ gameplay phụ thuộc** (đọc `game/scripts/core/chapter*_director.gd`, `game/scripts/entity/`, `floor4.gd`; không sửa):
   - node và anchor được gọi theo tên;
   - đường tuần tra của quản lý, navmesh;
   - vùng kích hoạt, chỗ nấp, camera CCTV, cửa phòng khác (408 bị niêm phong);
   - va chạm phải giữ.

   Ghi thành bảng "không được đổi tên hoặc dời".
3. **Ảnh hiện trạng 1080p** (Forward+):
   - cảnh chụp mới `game/scenes/levels/floor4/corridor_capture.tscn` + `.gd`, theo mẫu `game/scenes/levels/room407/room407_g3_capture.gd`;
   - khoảng 8–12 góc: hai đầu hành lang, trước cửa 407, bàn trực, cầu thang, nhà vệ sinh chung, cửa 408;
   - ánh sáng ban đêm và đèn pin;
   - lưu `art_source/graphics_upgrade/floor4_corridor/previews/before_*.jpg`.
4. **Kế hoạch** `art_source/graphics_upgrade/floor4_corridor/PLAN.md`:
   - **phần dựng Blender:** tường, sàn gạch, trần, nẹp, đèn tuýp, cửa sổ. Dùng lại được gì từ vỏ phòng 407 và cánh cửa Tripo 407;
   - **phần cần Tripo:** danh sách món, số lượt ước tính;
   - **phần giữ PS1** hoặc làm sau;
   - texture CC0 dự định (nguồn, giấy phép);
   - rủi ro FPS (hành lang dài, nhiều cửa, đèn): instancing, che khuất, số đèn có bóng;
   - chia thành 2–4 lượt nhỏ, mỗi lượt có ảnh để chủ dự án duyệt.
5. **Phiếu Tripo nháp** `art_source/graphics_upgrade/floor4_corridor/TRIPO_NHAP.md`:
   - prompt từng món theo mẫu phiếu phòng 407: kích thước thật, chất liệu, độ cũ, negative prompt;
   - integrator chuyển thành phiếu chính thức sau khi chủ dự án duyệt kế hoạch.

## Được phép sửa
- `art_source/graphics_upgrade/floor4_corridor/` (mới): `PLAN.md`, `TRIPO_NHAP.md`, `previews/`, script phụ nếu cần.
- `game/scenes/levels/floor4/corridor_capture.tscn`, `corridor_capture.gd` (mới, chỉ để chụp).
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `floor4.tscn`, `corridor.tscn`, `duty_desk.tscn`, `washroom.tscn`, `floor4.gd` hay bất cứ scene chơi được nào trong lượt này.
- Không tiêu credit Tripo, không tải asset chưa rõ giấy phép (chỉ CC0 hoặc CC-BY, AGENTS.md mục 5).
- Không đo FPS, không chạy bot.
- Không quyết thay chủ dự án về hình dáng (màu tường, kiểu cửa, đồ trang trí mang ý nghĩa truyện): đưa 2–3 phương án kèm đề xuất trong `PLAN.md`.

## Checklist hoàn thành
- [x] Bảng hiện trạng và bảng "không được đổi" trong `PLAN.md`
- [x] 8–12 ảnh `before_*.jpg` 1080p
- [x] `PLAN.md` có các lượt nhỏ, rủi ro FPS, phương án cho chủ dự án chọn
- [x] `TRIPO_NHAP.md`
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (theo luật lượt Godot trong `AGENTS.md`)
- [ ] Handoff trung thực, có commit hash

## Cách kiểm tra
- Chạy cảnh chụp: `<godot_console> --path game res://scenes/levels/floor4/corridor_capture.tscn` (không `--headless`, cần Forward+).
- Integrator xem ảnh và kế hoạch, rồi hỏi chủ dự án các phương án.

## Handoff (agent điền)
- Phiên 2026-11-01, lane B mới (Codex), workspace `D:\GAME_WORK\lane-b2`, nền `2773a3f608f33a2bda719a3dcfbf74900cfe07c0`.
- Đã làm: clone + LFS, nhánh đúng tên; khảo sát tĩnh, PLAN và TRIPO_NHAP; tạo cảnh chụp độc lập 12 góc 1080p và script chờ/giữ/trả khóa Godot. Không thay scene chơi.
- Bố trí 408: đã đối chiếu T-190 Handoff và generator; tấm bịt X=36 được giữ có chủ đích, cửa thật ở X=42. Không đề nghị dời lại.
- Kiểm tra ngắn: `pwsh tools/test.ps1 -Filter test_floor4` → `RESULT: 6 passed, 0 failed`, exit 0.
- 02/11/2026: đã chụp và xem đủ 12 ảnh 1920×1080 Forward+ trên RTX 3050 Laptop; `RESULT: corridor capture 12 images PASS`, exit 0; log không có lỗi engine. Đã chờ lane C trả khóa rồi mới chạy.
- Đã hoàn tất khảo sát, ảnh, kế hoạch, phiếu nháp và kiểm tra. Chờ integrator review và chủ dự án duyệt mỹ thuật để mở card triển khai; không có việc dựng scene chơi trong T-229.
- Cách kiểm tra: `art_source/graphics_upgrade/floor4_corridor/PLAN.md` mục 3; các stage `filter`, `capture`, `test`, `check` trong `run_stage.ps1` tự chờ khóa bằng CreateNew.
- Full test lượt 1: `RESULT: test FAIL (engine error or missing successful runner result)`; smoke khởi tạo cảnh chụp headless làm cảnh gọi thoát. Đã sửa cảnh chỉ chạy chụp khi là current_scene trực tiếp (deferred); chụp lại vẫn đủ 12 ảnh PASS. Check lượt 1 bị ngắt, chưa có RESULT; không tính đạt.
- Lượt xác nhận sau sửa: smoke `RESULT: 1 passed, 0 failed`, exit 0; full `pwsh tools/test.ps1` → `RESULT: 851 passed, 0 failed`, exit 0. `pwsh tools/check.ps1` → `RESULT: check 0 error(s)`, exit 0. Chuỗi `verify.ps1` kết thúc `RESULT: T229 verification PASS`. Commit: bổ sung ngay sau commit nội dung.
- Yêu cầu thay đổi: không cần sửa ngoài phạm vi T-229. Lượt triển khai sau cần integrator giao card cho CCTV/core nếu đồng bộ hình trên điện thoại; chủ dự án duyệt các phương án mỹ thuật trước dựng.
- Phần chưa kiểm: chơi tay bốn chương, bot, FPS/VRAM và credit/asset Tripo (không được giao thực hiện).
- Blocked: không. Khóa Godot đã được trả sau kiểm tra; file bus âm thanh được trả về trước commit. Không sửa STATUS/DECISIONS, không sửa scene chơi, không chạy bot/FPS hay tiêu credit Tripo.
