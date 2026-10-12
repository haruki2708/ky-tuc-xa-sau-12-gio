# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-12, Claude Code ở máy (Opus 5.5, integrator) — **D-089: Tripo đợt 1 xong 7 đồ phòng 407** (ghế, tủ lạnh, nồi cơm, xô, khăn, dép, giày) theo quy trình AAA D-088 (Tripo chi tiết → bản nhẹ + normal nướng, `art_source/graphics_upgrade/tripo/bake_prop.py`); bản game ở `game/assets/models/graphics_pilot/room407_batch1/`, balo D-086 ở `graphics_pilot/`. **Bản chơi chưa đổi.** **D-090:** G3 hoãn; **lane B làm thử góc phòng 407** (T-213, prompt `docs/handoff/lane-b.md` mục 5): kiến trúc Blender + texture CC0 + ánh sáng, đặt sẵn đồ Tripo; sau đó Tripo đợt 2 và thay cả cụm. Hồ sơ: `docs/handoff/TRIPO_DOT1_PHONG407.md`, `TRIPO_PHIEU_BALO.md`.

**Bản đồ lộ trình tổng quan:** [`docs/ROADMAP.md`](ROADMAP.md) (từ demo tới phát hành, đang ở đâu).

**Giai đoạn:** Đồ họa gần chân thực, **Tripo AI thay Meshy (D-080)**. **G0 A/B/C/D/F + Claude web đã nhận**, T-207…T-212 còn làm tiếp G1/G2/G3. Các đầu ra mới là khảo sát/prototype/công cụ riêng, chưa thay đồ họa các chương. E nghỉ vô thời hạn, F tiếp nhận âm thanh theo D-078. Kế hoạch: [GRAPHICS_UPGRADE_PLAN.md](design/GRAPHICS_UPGRADE_PLAN.md).

**Điều phối:** Astra tạm thay 10–11/10; Claude Code ở máy, **Opus 5.5**, nhận lại theo [hướng dẫn](handoff/OPUS_5_5_NHAN_LAI_DIEU_PHOI.md) và [nhật ký](handoff/NHAT_KY_ASTRA_2026-10-10_11.md). Chủ dự án là người dùng. **Astra làm thay Claude web ở T-207 (D-081)**; web tạm dừng, năm lane A/B/C/D/F tiếp tục. [Đầu mối và prompt G1](handoff/T207_G1_ASTRA_2026-10-11.md).

## Việc tiếp theo (cho phiên integrator kế tiếp)
1. Đọc [Review D-082](handoff/REVIEW_G1_2026-10-11.md) và Review từng card. Đã nhận A `0bb6f9a`, B `21f2f9b`, D `2a3c56c`, F `89a9445`; C nhận probe `b86a77d`; **D-083 ghép schema/validator (`7af1075` + sửa R1–R4 `d91606e`)**. Không coi năm task đã done.
2. **C sửa R1–R4 → integrator review/ghép schema → B chuyển manifest.** Probe root-local đã sửa; validator G1 vẫn bỏ sót unit scale/dung sai, trần được duyệt, dependency thiếu và kiểu metadata. 42 fixture nhánh C đạt nhưng ca review bổ sung phát hiện thiếu kiểm. Main vẫn dùng validator G0; không bảo B chuyển dữ liệu trước khi schema được nhận. B bổ sung facing nguồn balo song song; rig/settings/chuông độc lập.
3. **T-207 do Astra làm thay web, sau đó Opus nhận:** contract D-081 có quy ước balo; G1 nghiệm thu còn mở. Nhận đề xuất A/D/F và phần sửa pilot B, chưa thêm SETTINGS, stream hoặc nối W1–W4. Chuông còn chờ nghe thật/pause/mount; preset chưa có backend/default.
4. **Tripo AI (D-080):** ưu tiên Studio thủ công → GLB → Blender → Godot. Studio/API tách ví; chưa xác nhận gói đã mua, nguồn/license và trần chi. Một mẫu đầu `room407_backpack`: ≤3.000 tam giác, ≤2 material, map ≤1024², ≤10 MiB/file. Chưa tạo/nhập asset Tripo; 1080p/60 FPS trên RTX 3050 Laptop vẫn là mục tiêu chưa đo.
5. **Kiểm D-082:** full test → check sau mọi thay đổi trước commit; kết quả/giờ/hash/log trong message (`git log -1 --format=full --grep="D-082:"`). Renderer pilot riêng đạt 3/3 trên Forward+/RTX 3050; T-202 integration 5/5. Lỗi nav từng chập chờn trên Linux chưa được chẩn đoán; không gọi Windows PASS là đã sửa.
6. **Build chơi thử:** `build/windows/KyTucXa.exe`, 2026-10-10 03:57:18, code `add6d5f` có D-075. D-082 nhận prototype/QA/tài liệu, chưa đổi nội dung cảnh chơi nên không export. Đã xem hai ảnh mount B; chưa duyệt chất lượng đồ họa cuối, nghe/chơi tay hoặc đo FPS.
7. **Chơi thử còn mở:** chương 1 D-071/chương 2 D-073 tạm chốt; đoạn nhắn tin D-072 chưa chơi lại. Chương 3 lần cuối bước 6/tầng 1; D-074/T-206/D-075 đã sửa, chờ chơi tiếp. Chương 4/giọng và âm chương 2–4 còn chờ chủ dự án kiểm. D-059 chưa bắt đầu.
8. **Lượt Windows:** chủ dự án xác nhận A/B/C/D/F xong, integrator nhận lượt kiểm D-082 rồi báo nhả sau khi kết thúc. Code/tài liệu/offline vẫn song song; các phiên không tự biết nhau nhả lượt. Import/check cũng dùng APPDATA riêng; không tự mở bot/FPS.
9. Số đã cấp **D-076…D-090, T-207…T-213**. Số tiếp theo **D-091, T-214**.

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
| **Đồ họa gần chân thực (D-076/D-077, 10/10/2026)** | | |
| [T-207 Hợp đồng và tích hợp core](tasks/T-207-graphics-core-contract.md) | core — **Astra làm thay web (D-081)** | **D-085 đóng G1 đạo cụ tĩnh (balo); W1–W4 chưa đóng** |
| [T-208 Adapter gameplay–visual](tasks/T-208-visual-gameplay-adapters.md) | A | **D-082 nhận đề xuất lifecycle/pose/marker; rig và implementation còn chờ** |
| [T-209 Art pipeline và phòng mẫu](tasks/T-209-realistic-art-pilot.md) | B | **D-085: manifest G1 + hướng mặt trước balo đã ghép (Claude làm thay commit). Còn: nhập mẫu Tripo G2** |
| [T-213 Làm thử góc phòng 407](tasks/T-213-room407-corner-pilot.md) | B | **todo — giao 12/10 (D-090)** |
| [T-210 Asset QA và công cụ tạo asset (Tripo)](tasks/T-210-graphics-asset-qa.md) | C | **D-083 ghép schema/validator; D-085 G1 balo đạt. Còn: asset_id hoa/thường (không chặn), QA mẫu Tripo G2** |
| [T-211 Cài đặt và khả năng đọc](tasks/T-211-graphics-settings-readability.md) | D | **D-082 nhận migration/readability; chưa mở key/control mới** |
| [T-212 Audio/marker và chuông báo cháy](tasks/T-212-graphics-audio-anchors.md) | F (tiếp nhận E, D-078) | **D-082 nhận attachment/W2 đề xuất; chưa nghe hoặc đổi core** |
| **Lịch sử triển khai trước đợt đồ họa** | | |
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
| T-201 Luật sống mới, quản lý bước vào và đi tới chỗ trốn, gõ tường theo nhịp | core (**Claude Code web làm thay**, D-069) | **done**, đã merge (integrator sửa săn trong nhà vệ sinh, 2 test; gõ lại theo D-070) |
| T-202 Vùng nằm giường dễ bấm, quản lý `hunt` và `open_door` | A | **done**, đã merge |
| T-203 Va chạm giường tầng, cửa 407 mở chậm, đường đi ban công và nhà vệ sinh, khe ổ điện | B | **done**, đã merge (thanh chắn tầng trên: **Claude làm thay**) |
| **Chương 2 sau chơi thử lại (D-072, giao 2026-10-09)** | | |
| T-204 Nhắn cho hai bạn cách qua vòng 3, qua màn ở từ lặp thứ 4 | core (**Claude Code web làm thay**, D-072) | **done**, đã merge |
| T-205 Giọng 5 câu gọi mới | E | **done**, đã merge; chờ nghe |
| **Chương 3 sau chơi thử lại (D-074, 2026-10-09)** | | |
| T-206 Tấm bịt cửa 408 cũ nhấp nháy cạnh phòng 407 | B | **done**, đã merge (đúng ở cả 4 chương) |
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
- G0 không bị chặn. G2 chờ tài khoản Tripo/ngân sách/license; Studio thủ công không cần key, API cần ví/key riêng; settings chung và budget mới chờ G1; hình ảnh/âm thanh chờ người dùng duyệt. Đây là điều kiện của mốc sau, không phải lý do dừng công việc chuẩn bị.

## Ghi chú cho người chơi thử
- Game chính chạy trên **tầng 4** (T-112): bắt đầu trước cửa phòng 407; E mở và đóng cửa 407; đi được khắp hành lang, phòng 407, nhà vệ sinh, bàn trực. WASD đi, Shift chạy, chuột nhìn, Esc mở menu. Có filter PS1 (chỉnh cường độ và độ sáng trong Cài đặt). Có HUD (tâm ngắm, gợi ý, phụ đề), font tiếng Việt, tiếng bước chân dép lê, tiếng ù đèn tuýp và côn trùng đêm. Đồ vật tương tác hiện chỉ có cửa 407; giấy tờ, công tắc, sổ trực chờ T-111 và T-117.
- Nghe thử vùng âm và tiếng ù mới: mở `res://audio/test/zones_test.tscn`, F6; đi giữa hai phòng, phím L bật/tắt đèn, F cho đèn chập chờn.
- Nghe thử âm thanh: mở `res://audio/test/audio_test.tscn`, F6; phím 0–7 để nghe riêng từng nguồn.
- Trong game: Esc mở menu tạm dừng (Tiếp tục, Cài đặt, Thoát). Cài đặt có âm lượng, độ nhạy chuột, nhún đầu, ngôn ngữ.
- Thử HUD và đổi ngôn ngữ: mở `res://ui/hud/hud_test.tscn`, F6.
- Thử tương tác: mở `res://scenes/player/player_test.tscn`, F6, nhìn hộp xanh bấm E để bật/tắt đèn.
