# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-07
**Giai đoạn:** Chương 1 (`v0.3-ch1`) và chương 2 (`v0.4-ch2`) tạm chốt. Chương 3 đã sửa theo góp ý chơi thử (D-061…D-066). **Chương 4 "Người sống sót" đã ghép đủ 4 lane** (T-194…T-198, D-067). **Bản chơi thử 2026-10-07 19:51** (`build/windows/KyTucXa.exe`) có đủ chương 1–4; máy chủ dự án đã mở khóa tới chương 4. **Kế hoạch tiếp: chủ dự án kiểm tra lại trọn chương 1 → 4.**

## Việc tiếp theo (cho phiên integrator kế tiếp)
1. **Chủ dự án chơi kiểm tra chương 1 → 4** bản 2026-10-08 00:31 (`docs/playtest/`: `CH1_QUICKTEST.md` (nhanh) hoặc `CH1_V2_PLAYTEST.md`, `CH2_WALKTHROUGH.md`, `CH3_QUICKTEST.md`, `CH4_QUICKTEST.md`). Mỗi lỗi: tái hiện bằng test hoặc cảnh thật, sửa, chạy cả bộ test, export lại. Góp ý thiết kế: đưa phương án kèm đề xuất, ghi D-xxx.
2. **Chương 4 (D-068):** lời `CH4_SCRIPT.md` **đã duyệt**; phiếu điều tra: Nam, 20 tuổi, sinh 11/03/2006 (`FORM_FIELDS` trong `chapter4_director.gd`).
3. **Giọng (T-200, đã merge 2026-10-08):** chương 4 có đủ 16 giọng theo lời đã duyệt; cuộc gọi chương 2–4 và loa chương 2–4 **nay mới có tiếng** (trước đó chỉ có phụ đề do bộ phát chỉ nhận chương 1). Chờ chủ dự án nghe.
4. **Chương 1 sau chơi thử lại (D-069, 2026-10-08):** lời đã sửa (câu cứu Minh Nhật, mẩu giấy của Khoa, sổ hợp âm không còn bảng mã). Giao song song: **T-202** lane A (vùng nằm giường, quản lý `hunt`, `open_door`), **T-203** lane B (va chạm giường tầng, cửa 407 mở chậm, đường đi tới ban công và nhà vệ sinh, khe ổ điện `KhoaNoteSlot`), **T-201** core do **Claude Code trên web** làm (luật sống, quản lý bước vào, gõ theo nhịp, test). Prompt: `docs/handoff/lane-a.md`, `lane-b.md`, `web.md` §1. Ghép theo thứ tự A, B rồi T-201; sau đó export.
4b. **Bot:** không chạy bot chương 3 và 4 (D-068); T-199 chưa viết card.
5. **Chưa ai nghe bằng tai:** âm thanh chương 3 và 4, giọng cuộc gọi và loa chương 2–4 (fixture `res://audio/test/ch4_audio_test.tscn`).
6. **Sau khi chốt chương 4:** giai đoạn "Ghép bản hoàn chỉnh" (D-059).
7. Máy chủ dự án: `%APPDATA%/Godot/app_userdata/Ky Tuc Xa Sau 12 Gio/progress.json` = `{"version": 1, "unlocked": 4}` (bản cũ ở `progress.json.bak`).
8. **Phân công model** (chủ dự án tự đổi bằng `/model`): Opus cho kịch bản, kiến trúc, review nhánh lane, gỡ lỗi khó; Sonnet cho ghép có card rõ, sửa nhỏ, thêm test. Tới đoạn đổi thì dừng và nhắc chủ dự án.

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
| **Chương 2 sau chơi thử lần 1 (D-049…D-051, 2026-10-06)** | | |
| T-176 Từ điển, gõ từ, nhắn dự đoán, chat nhanh, giọng xác theo tiếng | core | **done**: đã ghép 4 lane, export bản chơi thử |
| T-177 Đứng yên khi đang gõ chữ | A | **done**, đã merge |
| T-178 Xác đọc từ điển bằng giọng ghép theo tiếng | E | **done**, đã merge; chờ nghe |
| T-179 Ô gõ từ nối, ô nhắn dự đoán, credits từ điển | D | **done**, đã merge; chờ thử bộ gõ |
| T-180 Bot gõ từ và nhắn dự đoán, kiểm tra F9 | C | **done**, đã merge; bot thật chưa chạy |
| **Chương 3 "Truy sát" (D-052…D-054, giao 2026-10-06)** | | |
| T-181 Hợp đồng chung, kịch bản, luồng 4 khu, ghép | core | **review**: ghép xong, FPS đạt, đã export; chờ chơi thử. Còn: profile bot (`routes`, `bindings`), chạy bot khi được phép |
| T-182 Xác sống, thanh sắt, thể lực, đồng đội, bảo vệ, cảnh chết | A | **done**, đã merge |
| T-183 Khuôn viên: nhà B tầng 1–4, vườn hoa, sân vận động, cổng, nhà ăn (greybox trước) | B | **done**, đã merge; chờ chốt tên trường trên biển cổng |
| T-184 Bot, menu nhảy 4 khu, đo FPS ngoài trời | C | **done** phần khung, đã merge; FPS chưa đo |
| T-185 Thể lực, thanh sắt, lớp chết, thẻ hết chương | D | **done**, đã merge |
| T-186 Tiếng xác, thanh sắt, thở dốc, ngoài trời, nhạc | E | **done**, đã merge; chờ nghe |
| T-187 Hành lang nhà B rộng khoảng 4 m ở cả 4 tầng (D-058) | B | **done**, đã merge |
| T-188 Sửa khối sập chặn cầu thang thoát hiểm tầng 3 → 2 | E (làm thay lane B, D-060) | **done**, đã merge |
| T-189 Nhà ăn kiểu nhà ăn trường học Trung Quốc | B (**Claude làm thay**) | review: đã dựng, chờ chủ dự án xem |
| T-190 Cửa phòng mở được, xác đi ra từ trong phòng (tầng 4, 3, 2; D-061) | B | **done**, đã merge (207 core mở sẵn, D-062) |
| T-191 Xác ra từ phòng theo bước chân người chơi | core | **done** (Sonnet 5.5); chờ chủ dự án chơi thử nhà B |
| T-192 Khán đài sân vận động làm lại, rải đồ khuôn viên (D-064) | B (**Claude Code web làm thay**, D-066) | **done**, đã merge; FPS đo lại PASS (40 xác, trung bình ≥107) |
| T-193 Điền profile bot chương 3, menu F9 dùng được | C | **done**, đã merge (3 sửa nhỏ của integrator); bot cả chương chưa chạy |
| **Chương 4 "Người sống sót" (D-067, giao 2026-10-07)** | | |
| T-194 Hợp đồng chung, kịch bản, luồng 5 khu, ghép | core | **review**: đã ghép A, B, D, E và giọng T-200; lời và phiếu đã chốt (D-068); chờ chơi thử |
| T-195 Điện thoại mồi, lật vạt giường, độ bền cửa phá, cảnh chết `door_burst` | A | **done**, đã merge và nối |
| T-196 Thư viện 3 tầng, đường về, phòng 407 cuối, bệnh viện | B (lane B đã có lại token; phiên web dự phòng, D-066) | **done**, đã merge và nối |
| T-197 Tab Đối chiếu, phiếu điều tra, tên bằng máu, mờ dần, thẻ bệnh viện, thẻ hết chương | D | **done**, đã merge và nối |
| T-198 Chuông mồi, đập cửa, thư viện, bệnh viện, giọng y tá, nhạc kết | E | **done**, đã merge và nối vào luồng; giọng thoại chờ lời được duyệt, chưa ai nghe |
| T-199 Bot chương 4, menu F9 nhảy 5 khu | C | chưa viết card; chủ dự án không cần chạy bot chương 3, 4 (D-068) |
| T-200 Giọng chương 4 theo lời đã duyệt; cuộc gọi chương 2–4 có tiếng | E | **done**, đã merge (core thêm tín hiệu có sóng lại trước câu cuối); chờ nghe |
| **Chương 1 sau chơi thử lại (D-069, giao 2026-10-08)** | | |
| T-201 Luật sống mới, quản lý bước vào và đi tới chỗ trốn, gõ tường theo nhịp | core (**Claude Code web làm thay**, D-069) | **todo** |
| T-202 Vùng nằm giường dễ bấm, quản lý `hunt` và `open_door` | A | **todo** |
| T-203 Va chạm giường tầng, cửa 407 mở chậm, đường đi ban công và nhà vệ sinh, khe ổ điện | B | **todo** |
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
