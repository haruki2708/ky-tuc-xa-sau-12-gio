# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-05 (tối)
**Giai đoạn:** Chương 2 "Trò chơi" **đã ghép đủ 5 lane** (T-171…T-175 merged), kịch bản tạm duyệt (D-048), **bản chơi thử đã export** (`build/windows/KyTucXa.exe`, 2026-10-05 22:13). **Chủ dự án đang chơi thử chương 2** theo `docs/playtest/CH2_WALKTHROUGH.md`. Chương 1 bản 2 tạm chốt (D-045, tag `v0.3-ch1`). Test 472/472, check 0 lỗi.

## Việc tiếp theo (cho phiên integrator kế tiếp)
1. **Làm theo góp ý chơi thử chương 2 (D-049):**
   - vòng 3 gõ từ bằng bàn phím: lane D đổi bảng nối từ thành ô nhập (LineEdit nhận bộ gõ của máy, 15 giây); core kiểm tra luật trên một **từ điển tiếng Việt lớn** (tìm nguồn có giấy phép thương mại, ghi vào CREDITS; từ không có trong kho của xác thì xác gục); bot và test cập nhật;
   - vòng 4 lời chat nhanh hơn;
   - vòng 4 nhắn dự đoán cho Minh Nhật và Ngư sau 3 lượt an toàn liên tiếp: thêm dãy nhiệt độ cho hai người, UI ô nhập trong điện thoại, đúng thì họ sống, sai thì họ bỏng (quyết định thua/thắng cần hỏi chủ dự án nếu chưa rõ);
   - đã sửa: cửa nhà vệ sinh bị giường B che (dời ô cửa, commit `af52dde`).
2. **Bot chương 2** (`pwsh tools/playthrough.ps1 -Chapter 2 -Scenario <case> -RequireComplete`, chạy từng case, thời gian thật 15–20 phút; máy hay hết RAM nên chỉ chạy khi chủ dự án đồng ý):
   - `ch2_good` lần 2 qua trọn vòng 3, dừng ở bước lau màn hình; đã sửa chỗ đứng `leave_shower` (commit `3780c37`), **chưa chạy lại** (lần 3 bị dừng vì hết RAM);
   - còn 5 case: `ch2_chain_timeout`, `ch2_chain_wrong`, `ch2_scald`, `ch2_leave_shower`, `ch2_lost_ngu`; đo FPS (`-Performance`, profile `performance` còn trống).
3. **Chưa kiểm tra:** menu F9 nhảy vòng 3/4 của chương 2; `CctvAudio.play_room_loss` chưa nối (chưa có rig `CctvAudio` trong chương).
4. **Lane B:** test `test_stuck_door_shakes_without_opening_then_cancels_on_open` chập chờn khi máy bận (bộ hẹn giờ 0,07 giây).
5. **Để sau (D-045):** chương 1 đoạn gõ tường (A giữ nguyên / B thêm tiếng gõ chờ / C gõ to hơn); chủ dự án nghe âm thanh lane E (chương 1 và 2).
6. **Sau khi chốt chương 2:** đề xuất T-180 (lane B) khung map chương 3 (nhà B 6 tầng, cầu thang, vườn hoa, sân vận động, cổng trường, nhà ăn); chủ dự án hoãn tới khi xong chương 2.
7. Máy chủ dự án: đã tạo `%APPDATA%/Godot/app_userdata/Ky Tuc Xa Sau 12 Gio/progress.json` = `{"unlocked": 2}` để chọn được chương 2.
**Repo:** https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio (private)

## Đã xong
- Godot 4.7.2 (self-contained) và export template Windows cài ở `D:\Tools\Godot`.
- Khung project `game/`:
  - autoload `GameInput` (input action) và `EventBus` (signal chung),
  - lớp `Interactable`,
  - scene `main.tscn` là hành lang greybox,
  - song ngữ CSV (vi/en).
- Test runner headless chạy được: `tools/test.ps1`, 253/253 test PASS (sau T-101…T-105, T-110, T-112…T-114, T-116, T-118, T-121…T-126, T-133…T-136, T-137…T-141, T-115). Autoload `App` lo việc thoát sạch (`App.quit()`, `-- --quit-after-frames=N`). Có thêm `check.ps1`, `capture.ps1`, `package.ps1` và autoload `Autoplay` để phát lại input (xem `tools/README.md`).
- Export chạy được: `tools/export.ps1` ra `build/windows/KyTucXa.exe`. Đã chạy thử, mở được.
- Chụp khung hình bằng Movie Maker chạy được, integrator xem được ảnh.
- Blender 5.2.2 LTS portable ở `D:\Tools\Blender\5.2.2`; bộ 7 mô hình ký túc xá (T-102), preview ở `art_source/kit/previews/`.
- Lõi luật chơi (T-110): autoload `GameState`, `RuleSystem`, helper `Checkpoint`; bộ luật demo đã có (T-113, `game/data/rules/demo.tres`).
- Tài liệu: `AGENTS.md`, `docs/PLAN.md`, `docs/DECISIONS.md`, `docs/design/GDD.md`, task card cho tuần đầu.

## Đang làm / tiếp theo
| Task | Lane | Trạng thái |
|---|---|---|
| T-101 Điều khiển người chơi và tương tác | A | **done**, đã merge |
| T-102 Bộ module 3D bằng script Blender | B | **done**, đã merge; chủ dự án đã duyệt (D-012) |
| T-103 Công cụ capture, package, check | C | **done**, đã merge |
| T-104 Font, HUD, phụ đề, đổi ngôn ngữ | D | **done**, đã merge |
| T-105 Pipeline âm thanh và âm môi trường đầu tiên | E | **done**, đã merge; chủ dự án đã nghe: tạm ổn, riêng tiếng ù đèn tuýp quá nhỏ |
| T-114 Sửa tiếng ù, vùng âm, đèn tắt thì im tiếng | E | **done**, đã merge; chủ dự án đã duyệt tiếng ù (D-014) |
| T-121 Kit: ghế nhựa VN, mùng, collision | B | **done**, đã merge; chủ dự án đã duyệt (D-013) |
| T-122 Nhịp bước chân tự nhiên | A | **done**, đã merge; chủ dự án đã duyệt nhịp (D-018) |
| T-123 Âm dép lê mềm hơn | E (Claude làm thay) | **done**, đã merge; chủ dự án đã chốt độ to (D-015) |
| T-116 Menu tạm dừng và cài đặt | D | **done**, đã merge |
| T-112 Dựng greybox tầng 4 | B | **done**, đã merge; game chính chạy trên tầng 4 |
| T-118 Filter PS1, sửa import texture | B (Claude làm thay) | **done**, đã merge; game chính có filter PS1 |
| T-124 Dọn công cụ QA, lọc file build | C | **done**, đã merge; package PASS chuyển sang T-127 |
| T-127 Công cụ QA thoát qua `App.quit()` | C | **done**, đã merge; `package.ps1` PASS |
| T-128 Nút Thoát qua `App.quit()`, key biển tầng 4 | D | **done**, đã merge |
| T-125 Player theo menu tạm dừng và cài đặt | A | **done**, đã merge |
| T-126 Bus riêng cho bước chân | E | **done**, đã merge; menu có thanh trượt Bước chân |
| T-129 Đồ vật tương tác đoạn 1–2 | A | **done**, đã merge và gắn vào phòng 407 |
| T-130 Âm thanh đoạn 1–2 | E (Claude hoàn tất bước push) | **done**, đã merge và ghép vào game |
| T-111 Màn xem giấy và sổ tay | D | **done**, đã merge (Claude sửa 1 lỗi tích hợp) |
| T-117 Luật đầu tiên chạy trọn vòng | core | **review**: đoạn 1–2 chơi được trọn vòng; chờ chủ dự án chơi thử (T-120) |
| T-131 Âm hù dọa và truy đuổi | E | **done**, đã merge |
| T-132 Tùy chọn "Giảm hù dọa" | D | **done**, đã merge |
| T-134 Thực thể truy đuổi, phát hiện ánh nhìn | A | done (review 2026-10-03) |
| T-135 Bóng người, gương phản chiếu chậm | B | done (review 2026-10-03) |
| T-136 Đoạn 3–5 và cái kết | core | review: chờ chủ dự án chơi thử cả demo |
| **Chương 2 "Trò chơi" (duyệt 2026-10-05, chơi thử 2026-10-09)** | | |
| T-170 Kịch bản, kho từ nối, dãy nhiệt độ, luồng 2 vòng, ghép | core | **doing** |
| T-171 Cầm giẻ, bịt miệng xác, cửa kẹt, buồng tắm, nút vòi sen, cảnh chết `corpse_lunge` và `scald` | A | **done**, đã merge |
| T-172 Xác chơi nối từ, đồ bịt miệng, nhà vệ sinh có vòi sen, hơi nước, phòng camera 310 | B | **done**, đã merge |
| T-173 Bot chương 2, menu nhảy, đo FPS hơi nước | C | khung **đã merge**; bot chạy sau khi điền profile |
| T-174 Bảng nối từ, màn hình vòi sen, lớp hơi nước và bỏng | D | **done**, đã merge |
| T-175 Giọng xác, nước tắm, cảnh chết mới, nhạc chương 2 | E | **done**, đã merge |
| **Chương 1 bản 2 (2026-10-05, tạm chốt `v0.3-ch1`)** | | |
| T-160 Luồng 8 nhiệm vụ, Insane, cắt thời gian trống, ghép | core | **done** (tạm chốt D-045) |
| T-161 Tương tác: gõ tường, chỗ lục đồ, ổ điện, dây mạng, nín thở 6 giây, quản lý nghe cử động | A | **done**, đã merge |
| T-162 Phòng 407 to (chiếm chỗ 408, nhà vệ sinh, ban công) và đạo cụ nhiệm vụ | B | **done**, đã merge |
| T-165 Khu camera: 4 phòng sinh viên, camera hành lang, 4 mô hình sinh viên | B | **done** (Claude làm thay) |
| T-163 Mất kết nối, sơ đồ tòa nhà, tab camera an ninh, khóa số giới hạn lần thử | D | **done**, đã merge |
| T-164 Âm thanh nhiệm vụ mới, cảnh chết, camera | E | **done**, đã merge; chờ chủ dự án nghe |
| T-166 Menu thử nhanh (F9), bot 8 nhiệm vụ, đo FPS phòng mới và camera | C | công cụ **đã merge**; bot bản 2 **5/5 PASS** trên bản ghép; còn đo FPS sau T-165 |
| **Chương 1 bản 1 "Tổng tắc" (2026-10-04, `v0.2-ch1`)** | | |
| T-150 Hợp đồng chung, luồng chương, kịch bản, ghép | core | **done**: chờ chủ dự án chơi thử |
| T-151 Nằm giường, nín thở, tiếng động, cúi, điện thoại, đèn pin, trạm câu đố | A | **done**, đã merge |
| T-152 Quản lý, xác đổi tư thế khi không bị nhìn | A | **done**, đã merge |
| T-153 Phòng 407 chi tiết, máu me, giường bị chém | B | **done**, đã merge |
| T-154 Mô hình quản lý, xác ba bạn, đạo cụ | B | **done**, đã merge |
| T-155 Điện thoại và cuộc gọi nhóm, chọn chương, cảnh báo nội dung | D | **done**, đã merge |
| T-156 Sổ quy tắc, bảng sống sót, màn chết, panel khóa số | D | **done**, đã merge |
| T-157 Bot chương 1, FPS, lưu game | C | **done**, đã merge; bot 4/4 PASS trên chương 1 |
| T-158 Âm thanh chương 1 | E | **done**, đã merge; chờ chủ dự án nghe |
| T-159 Giọng loa, quản lý, thành viên cuộc gọi | E (**Claude làm thay**) | **done**; chờ chủ dự án nghe (giọng eSpeak) |
| **Đợt 3 (2026-10-03): hoàn thiện P3** | | |
| T-140 Đánh bóng chốt cửa, vùng chọn giấy, lộ trình thực thể | A | **done**, đã merge |
| T-138 Đạo cụ thật thay khối hộp | B (**Claude làm thay**) | **done**, đã merge; chờ chủ dự án xem trong game |
| T-115 Bot tự chơi cả demo | C | **done**, đã merge; `tools/playthrough.ps1 -Scenario all` 3/3 PASS |
| T-139 Màn hình chính, cảnh báo, credits | D | **done**, đã merge; game khởi động vào màn hình chính |
| T-133 Nhạc nền và drone | E | **done**, đã merge; chờ chủ dự án nghe |
| T-137 Giọng loa TTS offline | E | **done**, đã merge; chờ chủ dự án nghe |
| T-141 Ghép đợt 3: title làm main scene, MusicDirector, giọng loa, đạo cụ, truy đuổi 2 từ gương | core | **done** |
| T-110 Kiến trúc RuleSystem và GameState | core | **done**, đã merge (xem `docs/design/RULE_SYSTEM.md`) |
| T-113 Chốt bộ luật demo và sơ đồ tầng | Chủ dự án + Claude | **done** (D-020); dữ liệu `game/data/rules/demo.tres` |

## Lưu ý cho chủ dự án
- **Đóng editor Godot đang mở `D:\GAME_DEMO` trước khi integrator merge**, hoặc sau khi merge vào editor chọn *Project → Reload Current Project*. Editor mở sẵn giữ script cũ trong bộ nhớ và có thể import lại tài nguyên bằng script cũ (2026-10-02: kit mất shader PS1; test của kit đã bắt được lỗi).
- Editor có thể tự lưu lại một số file (`default_bus_layout.tres`, `.import`) khi mở. Đừng commit các thay đổi đó; integrator sẽ dọn.

## Đang vướng
- Không có gì chặn. Ảnh tham khảo đồ họa chủ dự án gửi sau.

## Ghi chú cho người chơi thử
- Game chính chạy trên **tầng 4** (T-112): bắt đầu trước cửa phòng 407; E mở và đóng cửa 407; đi được khắp hành lang, phòng 407, nhà vệ sinh, bàn trực. WASD đi, Shift chạy, chuột nhìn, Esc mở menu. Có filter PS1 (chỉnh cường độ và độ sáng trong Cài đặt). Có HUD (tâm ngắm, gợi ý, phụ đề), font tiếng Việt, tiếng bước chân dép lê, tiếng ù đèn tuýp và côn trùng đêm. Đồ vật tương tác hiện chỉ có cửa 407; giấy tờ, công tắc, sổ trực chờ T-111 và T-117.
- Nghe thử vùng âm và tiếng ù mới: mở `res://audio/test/zones_test.tscn`, F6; đi giữa hai phòng, phím L bật/tắt đèn, F cho đèn chập chờn.
- Nghe thử âm thanh: mở `res://audio/test/audio_test.tscn`, F6; phím 0–7 để nghe riêng từng nguồn.
- Trong game: Esc mở menu tạm dừng (Tiếp tục, Cài đặt, Thoát). Cài đặt có âm lượng, độ nhạy chuột, nhún đầu, ngôn ngữ.
- Thử HUD và đổi ngôn ngữ: mở `res://ui/hud/hud_test.tscn`, F6.
- Thử tương tác: mở `res://scenes/player/player_test.tscn`, F6, nhìn hộp xanh bấm E để bật/tắt đèn.
