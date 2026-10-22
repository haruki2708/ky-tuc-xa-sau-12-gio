# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-22, Claude Code ở máy (Opus 5.5, integrator) — **D-129: vỏ phòng 407 T-222 vào bản chơi (chủ dự án duyệt ảnh); cửa ban công có bản lề và va chạm, mở sẵn; tay nắm Tripo nhận tay trong cảnh thử T-220, cửa ban công mở/đóng bằng tay ở đó.** **D-128: T-222 lượt 1 xong trong cảnh thử: vỏ phòng 407 cũ bẩn theo vị trí thật, khung và nẹp cửa, gạch chân tường, ban công dựng lại có cảnh bên ngoài, cửa nhà tắm, cửa ban công (mở sẵn), tay nắm và cửa phòng (lượt 2) Tripo. Ảnh so sánh `art_source/graphics_upgrade/room407_shell/previews/compare_*.jpg`; bản chơi chưa đổi.** **D-127: cửa ban công phòng 407 là cửa cánh nhôm kính có tay nắm gạt, mở sẵn lúc vào chương; chờ chủ dự án tạo cửa trên Tripo.** **D-126: card [T-222](tasks/T-222-room407-shell-upgrade.md) nâng vỏ phòng 407 (tường, trần, sàn, cửa và khung, ban công có cửa mới) cho hợp đồ Tripo; chủ dự án tạo 3 cánh cửa và tay nắm theo [`TRIPO_CUA_PHONG407.md`](handoff/TRIPO_CUA_PHONG407.md).** **D-125: sửa lỗi cửa nhà vệ sinh mở xong biến mất vào tường (có cả ở bản chơi): mở 82°, cụm bồn rửa và gương nhỏ lùi vào 22 cm.** **D-124: T-220 thêm camera nhìn theo tay, phải đứng gần mới dùng đồ bằng tay, tay trái cầm điện thoại, tay nắm cửa gạt hai mặt cho cửa 407 và nhà vệ sinh** (cảnh thử, video `build/graphics/protagonist/t220_demo.mp4`). Còn hỏi: ban công chưa có cửa. **D-123: T-220 bước 1, thân và tay người chơi chạy trên thân tạm CC0 trong cảnh thử `graphics_pilot/protagonist_pilot.tscn`** (thấy chân, bóng, gương; mở cửa, mở tủ, nhặt giấy mỗi thao tác 1 giây; cầm giấy theo góp ý của chủ dự án). Video `build/graphics/protagonist/t220_demo.mp4`, ảnh `art_source/graphics_upgrade/protagonist/previews/`. Bản chơi chưa đổi. **D-122: xác sống kiểu A (xác vừa chết); chủ dự án tạo vài mẫu gốc trên Tripo theo [`TRIPO_XAC_SONG.md`](handoff/TRIPO_XAC_SONG.md) (m1 Phúc trước), Claude làm hàng loạt 10 dạng ([T-221](tasks/T-221-zombie-tripo-variants.md)); T-220 chủ dự án + Claude, ngoại hình Trần Trung để sau.** **D-121: nhân vật chính thấy cả người, mỗi thao tác tay 1 giây hiện đủ động tác, giữ nguyên thời gian luật, nguồn chuyển động CC0 trước rồi quyết sau; card [T-220](tasks/T-220-protagonist-body-hands-pilot.md). Xác sống làm trước, chờ chọn ngoại hình.** Bản chơi mới `build/windows/KyTucXa.exe` 19/10 20:21 (có quản lý mới). **D-120: chủ dự án duyệt quản lý Tripo; quản lý mới vào bản chơi chương 1 và bóng trong gương chương 2** (mắt trắng đục, hỏi bằng tư thế chống nạnh, chuyển động tác mượt, tay trái với mở cửa). Chờ chơi thử. **D-119: quản lý Tripo đứng trong phòng 407 (cảnh xem thử)**: chủ dự án tạo thân, động tác, dao, chìa khóa, thẻ trên Tripo; Claude ghép clip, chỉnh tỉ lệ, gắn đồ, viết test. Ảnh `art_source/graphics_upgrade/manager/previews/`. **Tổng kết cuối ngày 16/10: viết lại ROADMAP và mục "Việc tiếp theo" để chủ dự án tiếp tục.** **D-118: quản lý (T-219) do chủ dự án tự làm, integrator hỗ trợ; không ghép phần lane C** (lượt sửa đã qua review, chủ dự án chọn bỏ). **T-219 đợt 1 (lane C) trả sửa** (lượt trước). **D-117: lane B hết hạn mức, T-219 chuyển sang lane C** (prompt [`lane-c.md`](handoff/lane-c.md) mục 5). **D-116: T-219 giao lane B** (mẫu C MPFB, bộ động tác, scene thân, cảnh so sánh, test). **D-115: G4 bắt đầu bằng quản lý: hai mẫu song song (A Tripo, C MPFB + đồ Tripo) để chủ dự án chọn bằng mắt; [T-219](tasks/T-219-manager-character-pilot.md), phiếu [`TRIPO_QUAN_LY.md`](handoff/TRIPO_QUAN_LY.md).** **D-114: đo FPS phòng 407 đủ đồ, 1080p đạt ≥60 ở mọi góc (thấp nhất ~98 FPS khi đèn trần nhấp nháy), [báo cáo](../tools/reports/D-114-room407-performance.md); bước tiếp: G4 nhân vật.** **D-113: sửa 3 lỗi chủ dự án báo từ bản chơi thử (Claude làm thay lane B): chữ trên lịch, thời khóa biểu, giấy note bị ngược; tường nhà tắm nhấp nháy (tường hành lang trùng mặt tường phòng); phòng 407 tắt đèn tối hẳn, phải dùng đèn pin.** Ảnh `art_source/graphics_upgrade/room407_furnished/previews/g3/compare_d113.jpg`. **D-112: ghép T-217 (lane D, Gemini): khung đọc hiện ảnh chụp như ảnh in, thẻ sinh viên như thẻ.** **D-111: ghép T-218 (lane F) + tiếng rè đèn chập chương 1.** **D-110: giao T-217 (lane D) và T-218 (lane F), thêm `DocumentData.look`.** **D-096: Tripo đợt 2 xong** (32 đồ + nệm/chiếu Blender), đặt đủ cả phòng 407 trong cảnh làm thử `game/scenes/levels/graphics_pilot/room407_furnished_pilot.tscn`; ảnh `art_source/graphics_upgrade/room407_furnished/previews/`; phiếu `docs/handoff/TRIPO_DOT2_PHONG407.md`. **D-097: chủ dự án duyệt, mọi thứ đạt.** **D-098: mùng (3 kiểu), dây phơi, poster dựng bằng Blender và đã đặt vào cảnh thử**; dây điện, giấy manh mối làm ở G3 trong code. **D-099: tách phần động** — tủ Việt (cánh mở bằng bản lề như `hinged.gd`) và quạt trần (dựng thẳng, node `fan_rotor` quay như bản chơi); cảnh thử phím F/O, ảnh `viet_locker_open_*`. **D-100: phòng còn trống → Tripo đợt 3 (30 món đồ sinh hoạt, mức bừa vừa) làm trước G3**, phiếu [`TRIPO_DOT3_PHONG407.md`](handoff/TRIPO_DOT3_PHONG407.md); **D-101: đợt 3 xong**, 30 món + chiếu, gạch nhà tắm, ống điện, lịch, rèm, 25 decal bẩn/ẩm đã đặt vào cảnh thử; ảnh `art_source/graphics_upgrade/room407_furnished/previews/summary_furnished.jpg`. **D-102: chủ dự án duyệt**; bộ lọc PS1 mặc định tắt. **D-103 (T-215): G3 bước 1 — phòng 407 đủ đồ đã vào bản chơi** (cả 4 chương dùng `floor4.tscn`), giữ nguyên luật/cốt truyện/độ khó; ảnh trong tầng 4 `art_source/graphics_upgrade/room407_furnished/previews/g3/summary_g3.jpg`. Chờ chủ dự án chơi thử. **D-104: ánh sáng phòng 407 như cảnh thử** (tắt đèn tối hẳn, đèn pin mạnh hơn; đèn trần khi sáng như đèn tuýp mẫu), chỉ trong phòng; ảnh `previews/g3/compare_d104.jpg`; chủ dự án duyệt. **D-105: gương nhà tắm và gương đứng phản chiếu thật** (chỉ khi đang nhìn vào gương); ảnh `previews/g3/compare_d105.jpg`. **D-106: giấy manh mối và dây điện làm lại** (giấy theo kiểu tài liệu, ảnh trong khung, dây tròn có đầu cắm); ảnh `previews/g3/compare_d106.jpg`. **D-107/D-108: lane D cũ nghỉ; lane D giao Gemini 3.8 Flash ([lane-d.md](handoff/lane-d.md) mục 0), lane F giao Claude Code web ([web.md](handoff/web.md))**; **3 lỗi nhà tắm (giẻ PS1 trong bồn, bảng sen tắm bị che, góc nhấp nháy) giao lane B, T-216** (prompt lane-b.md mục 6). **D-094: chủ dự án chấm giao diện T-214 đạt** (cải tiến sau khi cần). **D-095:** Tripo đợt 2 không giới hạn lượt; mùng, poster/giấy manh mối, dây, nệm và chăn bị rạch dựng bằng Blender chân thật. **Tripo đợt 2 (D-093):** đã soạn prompt 33 món còn lại của phòng 407 kèm cách sửa bằng AI Texturing/Magic Brush/Segmentation: [`docs/handoff/TRIPO_DOT2_PHONG407.md`](handoff/TRIPO_DOT2_PHONG407.md); chờ chủ dự án tạo, bắt đầu nhóm A (giường, nệm, gối, chăn, bàn, tủ, quạt trần). **D-091: ghép giao diện mới T-214** (lane D hết hạn mức, Claude làm thay commit/push; ảnh trước/sau `game/ui/theme/previews/index.html`). **D-092: ghép góc phòng 407 làm thử T-213** (B hết hạn mức, Claude làm tiếp: vật liệu CC0, chăn mô phỏng vải, 21 ảnh Forward+). **D-093: chủ dự án duyệt hướng phòng; mọi đồ trong phòng làm bằng Tripo** (integrator soạn prompt). **D-089: Tripo đợt 1 xong 7 đồ phòng 407** (ghế, tủ lạnh, nồi cơm, xô, khăn, dép, giày) theo quy trình AAA D-088 (Tripo chi tiết → bản nhẹ + normal nướng, `art_source/graphics_upgrade/tripo/bake_prop.py`); bản game ở `game/assets/models/graphics_pilot/room407_batch1/`, balo D-086 ở `graphics_pilot/`. **Bản chơi chưa đổi.** **D-090:** G3 hoãn; **lane B làm thử góc phòng 407** (T-213, prompt `docs/handoff/lane-b.md` mục 5): kiến trúc Blender + texture CC0 + ánh sáng, đặt sẵn đồ Tripo; sau đó Tripo đợt 2 và thay cả cụm. Hồ sơ: `docs/handoff/TRIPO_DOT1_PHONG407.md`, `TRIPO_PHIEU_BALO.md`.

**Bản đồ lộ trình tổng quan:** [`docs/ROADMAP.md`](ROADMAP.md) (từ demo tới phát hành, đang ở đâu).

**Giai đoạn (16/10):** đồ họa gần chân thực, **G3 xong** (phòng 407 đủ đồ trong bản chơi, D-103…D-114), **G4 nhân vật đang làm**: quản lý trước, chủ dự án tự làm cùng integrator (D-118). Lộ trình: [ROADMAP.md](ROADMAP.md).

**Giai đoạn (ghi chép 10–15/10):** Đồ họa gần chân thực, **Tripo AI thay Meshy (D-080)**. **G0 A/B/C/D/F + Claude web đã nhận**, T-207…T-212 còn làm tiếp G1/G2/G3. Các đầu ra mới là khảo sát/prototype/công cụ riêng, chưa thay đồ họa các chương. E nghỉ vô thời hạn, F tiếp nhận âm thanh theo D-078. **D-108: lane D = Gemini 3.8 Flash (Antigravity, luật cứng + integrator kiểm, lane-d.md mục 0); lane F = Claude Code web Sonnet 5.5 (web.md).** Kế hoạch: [GRAPHICS_UPGRADE_PLAN.md](design/GRAPHICS_UPGRADE_PLAN.md).

**Điều phối:** Astra tạm thay 10–11/10; Claude Code ở máy, **Opus 5.5**, nhận lại theo [hướng dẫn](handoff/OPUS_5_5_NHAN_LAI_DIEU_PHOI.md) và [nhật ký](handoff/NHAT_KY_ASTRA_2026-10-10_11.md). Chủ dự án là người dùng. **Astra làm thay Claude web ở T-207 (D-081)**; web tạm dừng, năm lane A/B/C/D/F tiếp tục. [Đầu mối và prompt G1](handoff/T207_G1_ASTRA_2026-10-11.md).

## Việc tiếp theo (cho phiên integrator kế tiếp)

> Viết lại 16/10/2026 sau D-118. Danh sách cũ (G1, Astra, D-082) đã xong hoặc nằm trong DECISIONS; xem lịch sử git của file này nếu cần.

1. **Bản chơi:** `build/windows/KyTucXa.exe` **19/10 20:21** (sau D-120, có quản lý Tripo ở chương 1 và gương chương 2). Phiếu chơi thử [`G3_PHONG407_QUICKTEST.md`](playtest/G3_PHONG407_QUICKTEST.md).
2. **G4 quản lý ([T-219](tasks/T-219-manager-character-pilot.md), D-118):** chủ dự án tự làm, integrator hỗ trợ, không giao lane.
   - **D-119 (19/10):** đã có thân, 7 động tác, dao, chìa khóa, thẻ trong cảnh xem thử `graphics_pilot/manager_preview.tscn`, quy trình dựng lại ở `art_source/graphics_upgrade/manager/README.md`.
   - **D-120 (19/10):** chủ dự án duyệt. Mắt tô trắng đục, `ask` = tư thế chống nạnh, chuyển động tác mượt, tay trái với mở cửa. **Chương 1 và gương chương 2 đã dùng quản lý mới**; chờ chủ dự án chơi thử. Bảo vệ khuôn viên vẫn thân cũ.
   - Chủ dự án tạo trên Tripo theo [`TRIPO_QUAN_LY.md`](handoff/TRIPO_QUAN_LY.md) và tải về `build/graphics/staging/manager/`.
   - Integrator (Claude làm thay B/A) làm tiếp:
     - chuẩn hóa: −Z, cao khoảng 1,70 m, gốc ở chân, texture ≤ 2048²;
     - map khung xương sang `SkeletonProfileHumanoid`;
     - gắn dao, `BladeTip`, làm scene thân theo hợp đồng `body_scene`;
     - chụp ảnh trong phòng 407.
   - Đọc mục "D-118" cuối card (bài học từ lượt lane C).
   - Nhánh `lane-c/T-219-manager-pilot` không ghép, chỉ để tra cứu.
   - Chủ dự án muốn tự học làm khung xương và động tác trong Blender. Integrator đã đề nghị soạn trang hướng dẫn cho người mới, chưa được nhận lời.
3. **Nhân vật chính có thân và tay thật** (chủ dự án hỏi 16/10). Integrator đã đề xuất kế hoạch 5 bước:
   1. mẫu thử trong phòng 407: mở cửa 407, mở tủ Việt, nhặt giấy;
   2. bước chân thật;
   3. 8–10 loại thao tác tay, dùng IK và điểm cầm trên từng đồ vật;
   4. NPC đi không trượt, dùng tay mở cửa;
   5. hồi quy 4 chương.

   **D-121 (19/10) chủ dự án chốt:**
   - thấy cả người (chân, bóng, gương);
   - mỗi thao tác tay 1 giây, hiện đủ động tác; giữ nguyên thời gian luật;
   - nguồn chuyển động cách (c): CC0 + chỉnh tay ở mẫu thử, chơi thử rồi mới quyết trả phí quay video.

   Card [T-220](tasks/T-220-protagonist-body-hands-pilot.md) (bước 1, cảnh thử phòng 407). **D-123: cơ chế bước 1 xong trên thân tạm.** **D-124:** camera nhìn theo tay, phải đứng gần (b), tay trái cầm điện thoại, tay nắm cửa gạt. Ban công có cửa cánh tay gạt, mở sẵn (D-126, D-127); tay nắm làm trên Tripo theo phiếu T-222. Còn chờ chủ dự án: nhịp chân khi đi nhanh (card mục D-124). **D-122:** chủ dự án tạo Trần Trung trên Tripo, Claude làm phần còn lại (như T-219). Ngoại hình Trần Trung để sau; trong lúc chờ, Claude làm cơ chế (thân, IK, 3 thao tác) trên thân tạm CC0. Auto Rig của Tripo có xương ngón tay (đã thấy ở quản lý), nên không cần MPFB.
4. **Xác sống ([T-221](tasks/T-221-zombie-tripo-variants.md), D-121, D-122):** kiểu A xác vừa chết. Chủ dự án tạo mẫu gốc theo [`TRIPO_XAC_SONG.md`](handoff/TRIPO_XAC_SONG.md), **m1 (Phúc) trước** kèm đủ preset động tác, tải về `build/graphics/staging/zombie/`. Claude chạy thử cả quy trình trên m1 (đóng gói, mắt đỏ, 2–3 biến thể, ảnh), chủ dự án duyệt rồi mới làm m2–m4. Sau đó Claude làm 10 dạng `zombie_01`–`10`.
5. **Vỏ phòng 407 ([T-222](tasks/T-222-room407-shell-upgrade.md), D-126…D-128):**
   - **D-128 (22/10): lượt 1 xong trong cảnh thử**, ảnh `art_source/graphics_upgrade/room407_shell/previews/compare_*.jpg`, card mục "Lượt 1";
   - cửa Tripo: tay nắm, cửa ban công đạt; cửa nhà tắm Claude đã sửa; **cửa phòng lượt 2 đã vào cảnh thử** (22/10), tay nắm treo trên `HandlePivot` để cảnh rung tay nắm vẫn chạy;
   - **D-129 (22/10): chủ dự án duyệt, vỏ mới vào bản chơi.** Cửa ban công có bản lề và va chạm (`Extension/BalconyDoor`), mở sẵn 172°; mở/đóng bằng tay trong cảnh thử T-220;
   - chờ chủ dự án: cho người chơi tự đóng/mở cửa ban công trong bản chơi ngay hay để tới T-220 bước 5; đo FPS phòng 407 (hỏi trước).
6. **Chơi thử còn mở:**
   - chương 1 và gương chương 2 với quản lý mới (bản 19/10 20:21);
   - chương 2: nhà tắm mới D-109, đoạn nhắn tin D-072;
   - chương 3: từ tầng 1 (báo cháy, 4 xác sống);
   - chương 4: chưa chơi lần nào.
   - Ánh sáng, gương, giấy và 3 lỗi D-113 chủ dự án đã duyệt.
7. **Việc nhỏ cho lane rảnh** (chưa giao):
   - con dấu tiếng Anh xuống dòng "Dormitory / – Floor 4";
   - thẻ sinh viên hiện thừa "Cuộn để đọc tiếp";
   - chưa có `photo_family_en.png`;
   - đèn pin chói trắng khi sát vật dưới 1 m.
8. **Để sau:** hành lang tầng 4 (vẫn PS1), quyết định xác trong gương, GĐ4 ghép bản hoàn chỉnh (D-059).
9. **Lane:**
   - A, C, D (Gemini), F (Claude web): rảnh.
   - B: hết hạn mức.
   - Workspace `lane-b` còn phần T-216 cũ chưa commit (đã ghép D-109): khi giao việc mới cho B, bảo agent stash, không xóa.
10. **Quy trình:**
   - Sau mọi thay đổi: `pwsh tools/test.ps1` → `pwsh tools/check.ps1` → `git checkout -- game/default_bus_layout.tres` → commit, push main.
   - Hỏi chủ dự án trước khi chạy bot hoặc đo FPS.
   - Kiểm `Get-Process godot*,KyTucXa*` trước khi chạy Godot.
   - Máy từng thiếu RAM làm lượt test chạy nền bị dừng (16/10). Gặp lại thì báo chủ dự án, không tự chạy lại.
11. Số đã cấp **D-076…D-129, T-207…T-222**. Số tiếp theo **D-130, T-223**.

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
| [T-213 Làm thử góc phòng 407](tasks/T-213-room407-corner-pilot.md) | B | **D-092 đã ghép; D-093 chủ dự án duyệt hướng phòng**, đồ trong phòng chuyển sang Tripo; **D-096 Tripo đợt 2 xong**, cả phòng đủ đồ trong cảnh `room407_furnished_pilot.tscn` (phiếu `handoff/TRIPO_DOT2_PHONG407.md`) |
| [T-214 Giao diện đẹp + đặt lại riêng Hình ảnh + chữ 720p](tasks/T-214-video-reset-readability.md) | D | **D-091 đã ghép; D-094 chủ dự án chấm đạt** (Claude làm thay commit/push). Vòng 2 để sau khi cần |
| [T-215 G3: phòng 407 đủ đồ vào bản chơi](tasks/T-215-g3-room407-playable.md) | integrator (Claude làm thay B/A/D) | **D-103 bước 1 đã ghép**: phòng mới trong bản chơi, bộ lọc PS1 mặc định tắt. Còn: chủ dự án chơi thử 4 chương, gương phản chiếu, FPS (hỏi trước) |
| [T-216 Sửa 3 lỗi nhà tắm phòng 407](tasks/T-216-bathroom-fixes.md) | B | **done, D-109 đã ghép** (lane B hết hạn mức, Claude làm thay commit): giẻ mới trên giá khăn, bảng sen tắm + nút sang tường tây, nẹp gạch hết chồng. Chờ chủ dự án chơi tay chương 2. |
| [T-217 Khung đọc giấy hiện đúng ảnh chụp và thẻ](tasks/T-217-document-view-looks.md) | D (Gemini, D-108) | **done, D-112 đã ghép** sau 2 lần trả sửa: ảnh chụp hiện như ảnh in kèm mặt sau, thẻ sinh viên có ô ảnh và con dấu; ảnh `game/ui/document/previews/` (vi/en). Không xóa/đổi tên file ngoài 12 file tạm được duyệt |
| [T-218 Âm thanh phòng 407 khớp đồ mới](tasks/T-218-room407-object-audio.md) | F (Claude web, D-108) | **done, D-111 đã ghép**: nguồn âm theo đồ G3, cảnh nghe thử; integrator thêm tiếng rè đèn chập chương 1, tiếng cửa nhà tắm ở tay nắm. **Chờ chủ dự án nghe** |
| [T-220 G4 nhân vật chính có thân và tay thật, bước 1](tasks/T-220-protagonist-body-hands-pilot.md) | Chủ dự án + Claude (D-122) | **D-124: bước 1 xong trên thân tạm CC0** (cảnh thử `graphics_pilot/protagonist_pilot.tscn`, 14 test): camera nhìn theo tay, phải đứng gần, tay trái cầm điện thoại, tay nắm cửa gạt. Chờ chủ dự án: ban công, tay nắm Tripo; Trần Trung (Tripo) chưa có |
| [T-222 Nâng vỏ phòng 407 cho hợp đồ Tripo](tasks/T-222-room407-shell-upgrade.md) | Chủ dự án + Claude (D-126) | **mới**: chủ dự án tạo 3 cánh cửa và tay nắm trên Tripo (`TRIPO_CUA_PHONG407.md`); Claude làm khung cửa, tường, trần, sàn, nhà tắm, ban công có cửa. D-127: cửa ban công cánh tay gạt, mở sẵn. **D-128: lượt 1 xong trong cảnh thử**, cửa phòng Tripo lượt 2 đã gắn. **D-129: vào bản chơi**, cửa ban công có bản lề và va chạm. Chờ: chủ dự án chọn có cho người chơi tự đóng/mở cửa ban công không, đo FPS (hỏi trước) |
| [T-221 G4 xác sống Tripo, mẫu gốc và 10 dạng](tasks/T-221-zombie-tripo-variants.md) | Chủ dự án + Claude (D-122) | **mới**: kiểu A xác vừa chết; chờ chủ dự án tạo m1 (Phúc) theo `TRIPO_XAC_SONG.md` |
| [T-219 G4 mẫu thử quản lý, hai cách làm](tasks/T-219-manager-character-pilot.md) | Chủ dự án + Claude (D-118…D-120) | **D-120: chủ dự án duyệt; quản lý Tripo trong bản chơi chương 1 và gương chương 2** (mắt trắng đục, `ask` = chống nạnh, chuyển động tác mượt, tay trái mở cửa). Cảnh xem thử `graphics_pilot/manager_preview.tscn`, 14 ảnh `art_source/graphics_upgrade/manager/previews/`; 24.131 tam giác. Chờ chơi thử |
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
