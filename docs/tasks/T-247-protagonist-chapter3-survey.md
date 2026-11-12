# T-247 — Khảo sát đưa thân Trần Trung vào chương 3 (chỉ khảo sát và đề xuất, chưa làm)
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141), model và effort do chủ dự án đặt (đề xuất Opus 5.5 high)
- Nhánh: `lane-b/T-247-protagonist-chapter3-survey` từ `origin/main` mới nhất.
- Giao việc: 12/11/2026, chủ dự án chọn "Thân Trung chương 3: khảo sát trước" (thay vì làm luôn). Lane B do **chủ dự án tự dán prompt** (`lane-b.md` mục 1f), integrator không điều khiển lane B.
- Bối cảnh: thân Tripo của Trần Trung đã có ở chương 1 (D-151; tay T-239, lấy đồ T-241, cửa T-242, chủ dự án duyệt) và chương 2 (T-243, D-161/D-162; sửa sau chơi thử T-245, chủ dự án duyệt 12/11). Chương 3 và 4 chưa có thân (`protagonist_body` chỉ bật trong `chapter1.tscn`, `chapter2.tscn`).

## Mục tiêu
Một báo cáo kèm ảnh để chủ dự án **chốt cách Trần Trung làm từng việc ở chương 3** (giống bảng D-162 của chương 2), rồi integrator hoặc lane B mới làm ở card sau.
**Lượt này không sửa game:** không bật `protagonist_body` trong `chapter3.tscn` ở commit, không sửa code, scene, test.

## Cần đọc
- `docs/design/CH3_DESIGN.md`, `docs/design/CH3_SCRIPT.md` (chương 3 "Truy sát": nhà B tầng 4 xuống tầng 1, vườn hoa và thanh sắt, sân vận động, cổng trường, nhà ăn; đồng đội đi cùng; xác sống).
- `game/scripts/core/chapter3_director.gd` (`CH3_STAGES`, `_place_uses`, `_place_bars`, `_join`, `_spawn`), `game/scripts/core/ch3_use.gd`.
- Thân và tay: `game/scripts/player/protagonist.gd` (`Protagonist.attach`, `HINGED_DOORS`), `player_body.gd` (đầu file), `game/scenes/main/chapter1_main.gd` (`protagonist_body`, `_hinged_doors`; chương 1–3 dùng chung script).
- Chương 2 làm thế nào: `docs/tasks/T-243-protagonist-chapter2.md` (mục 1 là bảng chủ dự án chốt), `docs/tasks/T-245-ch2-playtest-fixes.md`.
- Chỗ đặt tay chương 3 đã có: `docs/tasks/T-231-ch2-4-hand-targets.md` (chương 3 có 28 đồ nhóm 1 dùng tay; bảng đề xuất cho `Ch3Use` nhóm 2, còn hai điểm chờ chốt: tay mở cửa cứu hỏa, nhật ký trên ghế thủ thư), `game/tests/player/test_ch2_4_hand_targets.gd`.
- Đo FPS chương 3 trước đây: `tools/reports/T-237-chapter-fps.md` (nhìn dọc hành lang ra khuôn viên có giật nhẹ, 1% thấp nhất 42–57 FPS).

## Phạm vi
**A. Thử bật thân ở chương 3 (chỉ trong cảnh tạm, không commit).** Trong `game/_probe_tmp/` (xoá khi xong), dựng `chapter3.tscn` với `protagonist_body = true` và `auto_start = false`, đi qua từng mốc `CH3_STAGES` (`b`, `garden`, `stadium`, `gate`, `end3`; dùng `run_from` hoặc menu F9 như bot). Ghi mọi thứ hỏng hoặc lạ: lỗi script, thân lệch, cửa phòng 407 (cửa nhà tắm, ban công, cửa phòng) gắn bằng tay có hợp chương 3 không, cầu thang chính và thoát hiểm, đổi khu (nhà B → vườn → sân → cổng → nhà ăn), cảnh chết, cảnh không cho điều khiển.

**B. Mọi thao tác bằng tay của chương 3** (bảng, mỗi dòng một thứ):
- **Nhóm 1:** đồ đã có `HandTarget` (28 đồ, lấy danh sách bằng code như test T-231, không liệt kê tay).
- **Nhóm 2:** `Ch3Use` (chìa khoá cửa thoát hiểm, cửa cứu hoả, bình chữa cháy tầng 2, báo cháy tầng 1, …): chưa có chỗ đặt tay, dùng bảng đề xuất T-231 làm điểm xuất phát.
- **Thanh sắt** (Ngư đưa ở vườn hoa, 7 thanh): nhặt, cầm khi chạy, dùng (đánh, cạy, chặn cửa…: đọc code xem thanh sắt làm gì). Cầm tay nào, dáng cầm.
- Thứ khác lane B tìm thấy (đồ đồng đội đưa, cửa, chướng ngại).

Với mỗi thứ ghi: code hiện có làm gì (camera, treo đồ trước mắt, chỉ bấm E…); **2–3 phương án động tác, một phương án đề xuất**; luật đã duyệt của chương 1–2 dùng lại được không (đứng gập hông ≤ 40°, cúi 1,4 s, tay phải cầm đồ, nắm tay đang cầm vẫn làm việc khác, tự bước tránh cánh cửa); việc phải làm (code, Blender, dời đồ, cần động tác mới trên Tripo hay có sẵn trong Tripo/UAL2).

**C. Động tác thân riêng của chương 3** (chấm **Tự nhiên / Hơi gượng / Sai** trên thân chương 1–2 hiện có, đề xuất sửa):
- chạy dài, chạy nước rút khi bị đuổi, chạy du kích ở sân vận động, chạy cùng đồng đội;
- lên xuống cầu thang (chính, thoát hiểm), qua cửa khi đang chạy;
- nấp, khom, nhìn lại phía sau;
- bị xác sống tóm, cảnh chết mới (D-042), jumpscare: thân lúc đó ở đâu, có xuyên camera không;
- tay trái và điện thoại ở chương 3 (đèn pin, gọi điện nếu có).

**D. Rủi ro và việc cần chủ dự án cho phép** (chỉ ghi, không làm):
- FPS: chương 3 vốn nặng ở Campus/sân vận động; thân thêm chi phí. Ghi chỗ nghi nặng; **không đo FPS** (cần chủ dự án cho phép).
- Bot chương 3: **không chạy bot**; ghi profile bot nào có thể hỏng khi có thân.
- Thứ cần tạo trên Tripo (nếu có): ghi rõ, **không tiêu credit Tripo**.

## Sản phẩm
- Báo cáo `tools/reports/T-247-ch3-body-survey.md`, tiếng Việt, đầu báo cáo là **bảng quyết định cho chủ dự án** (thao tác | phương án | đề xuất), giống bảng mục 1 của T-243. Phần A, B, C, D như trên. Cuối báo cáo: đề xuất chia việc (card nào, thứ tự, ước lượng) và câu hỏi cho chủ dự án.
- Ảnh trong `art_source/graphics_upgrade/protagonist/previews/t247/` (1080p, JPG; góc mắt và góc ngoài thấy cả thân; mỗi thao tác 2–4 khung), tự xem lại từng tấm. Video nếu có để trong `build/`, không commit.

## Được phép sửa
- `tools/reports/T-247-ch3-body-survey.md` (mới), `art_source/graphics_upgrade/protagonist/previews/t247/` (mới), Checklist và Handoff của card này.
- `game/_probe_tmp/` chỉ để thử, **không commit**, xoá khi xong.

## Không được
- Sửa code, scene, test, `chapter3.tscn`; sửa STATUS, DECISIONS.
- Chạy bot, đo FPS, tiêu credit Tripo.
- Commit `anh_chup_sua_loi/`, log, video.
- Commit chỉ có báo cáo và ảnh nên **không cần full test/check**; vẫn theo luật Lượt Godot mỗi khi mở Godot (file khoá `D:\GAME_WORK\GODOT_DANG_CHAY.txt`).

## Checklist
- [x] A: bật thân ở chương 3 trong cảnh tạm, đi qua 5 mốc, bảng thứ hỏng
- [x] B: bảng mọi thao tác bằng tay (nhóm 1 lấy bằng code, nhóm 2, thanh sắt, thứ khác), phương án và đề xuất
- [x] C: chấm động tác thân riêng chương 3
- [x] D: rủi ro, việc cần cho phép
- [x] Bảng quyết định đầu báo cáo, đề xuất chia việc, câu hỏi cho chủ dự án
- [x] Ảnh `previews/t247/` đã tự xem lại
- [x] Xoá `game/_probe_tmp/`; push nhánh; Handoff

## Handoff
(lane B điền)

### Kết quả (lane B, Opus 5.5, 12/11/2026)
Nhánh `lane-b/T-247-protagonist-chapter3-survey`, gốc `origin/main` `fc57369` (card đọc ở `fc57369`). Chỉ commit báo cáo, ảnh và card; không sửa code, scene, test, `chapter3.tscn`. Không cần full test/check (card).

**Sản phẩm:**
- Báo cáo [`tools/reports/T-247-ch3-body-survey.md`](../../tools/reports/T-247-ch3-body-survey.md): đầu báo cáo là bảng quyết định 13 dòng; sau đó phần A–D, đề xuất chia 4 card, câu hỏi cho chủ dự án.
- 34 ảnh 1080p chương 3 thật: `art_source/graphics_upgrade/protagonist/previews/t247/` (đã tự xem từng tấm).

**Cách làm:** cảnh tạm `game/_probe_tmp/t247_probe.*` (đã xoá; bản sao để tra lại ở `build/t247/probe_backup/`, không commit) nạp `chapter3.tscn` thật, bật `protagonist_body` trước khi vào cây, `auto_start = false`, chạy từng mốc bằng `run_from`. Người chơi đi bằng phím thật, đi cầu thang theo lưới dẫn đường như bot. Log ở `build/t247/*.log`.
- 15 lượt mở chương 3, mỗi lượt giữ khóa Lượt Godot riêng.
- Lượt chạy liền 14 cảnh đầu tiên bị Claude Code dừng vì máy thiếu RAM. Khóa của mình đã xoá tay (không còn Godot nào chạy). Chủ dự án cho phép chạy lại, mình chạy lần lượt từng cảnh.

**Phát hiện chính:**
- Bật thân ở chương 3 **không lỗi script** ở cả 5 mốc. Cửa 407, cửa nhà tắm, ban công, đồ phòng 407, điện thoại, cảnh chết chạy như chương 1–2.
- **Thanh sắt chưa nằm trong tay:** là hộp treo trước camera, tay thân trống; từ ngoài thấy thanh lơ lửng. Nhặt thanh: thanh biến mất lúc chạm, tay bật về ngay.
- **B05 (cổng), B06 (gần nhà ăn) thấp hơn tầm lòng bàn tay 4 cm khi cúi:** có thân thì không hiện lời nhắc.
- **4 `Ch3Use` chưa có chỗ đặt tay:** có thân vẫn bấm E là xong, không động tác.
- **Cầu thang:** mũi chân lún 4–25 cm, lơ lửng tới 38 cm. **Cửa sổ phòng quản lý:** chân lơ lửng 30–45 cm.
- **Quay ra sau lúc chạy:** clip chạy phát ngược.

**Lỗi có từ trước, ghi cho integrator (không thuộc thân, không sửa):**
- Ở checkpoint vườn hoa, người chơi và Minh Nhật cùng đặt ở `Start_garden`: người chơi đứng trên đầu Minh Nhật rồi rơi xuống.
- Tán cây vườn hoa không có va chạm.

**Câu hỏi cho chủ dự án:** báo cáo mục 7.
- Chọn phương án cho 13 dòng của bảng 1.
- Đồng ý không thêm lời nhắc ở cửa sổ phòng quản lý (D-055).
- Cho phép đo FPS và chạy bot `ch3` ở bước kiểm cuối.
- Ngư chìa thanh tận tay: làm khi có mô hình Ngư thật, hay giữ thanh hiện thẳng trong tay.

**Chưa thử:** chạy qua cửa lúc đang chạy, chạy cạnh đồng đội, jumpscare, đổi hướng gấp ở sân vận động (ghi "Chưa thử" trong báo cáo). Không chạy bot, không đo FPS, không tiêu credit Tripo.

**Yêu cầu thay đổi ngoài phạm vi:** không có.