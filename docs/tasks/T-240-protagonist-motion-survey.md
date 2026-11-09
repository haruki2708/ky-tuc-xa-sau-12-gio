# T-240 — Khảo sát mọi động tác của Trần Trung ở chương 1 (chỉ khảo sát, chưa sửa)
- Lane: B | Trạng thái: todo, **bắt đầu sau khi T-239 đã merge vào main** | Agent: tài khoản Claude lane B (D-141), Opus 5.5 (effort do chủ dự án đặt)
- Nhánh: `lane-b/T-240-protagonist-motion-survey` từ `origin/main` **sau khi** integrator merge [T-239](T-239-protagonist-hand-fixes.md).
- Quyết định giao: **D-155** (09/11/2026). Chủ dự án hỏi có nên cho lane B khảo sát tất cả các hành động (cầm nắm, lấy đồ dùng…) để tìm động tác thiếu tự nhiên và lỗi logic, chỉnh trong Blender. Integrator đề xuất làm sau T-239, chỉ khảo sát và đề xuất; chủ dự án: "có giao".
- Vì sao làm sau T-239: T-239 làm lại hệ ngón tay (tư thế theo kiểu cầm, ngón cái, cách chọn chỗ cầm cửa). Khảo sát trên bản đã sửa mới không trùng 4 lỗi đã biết.

## Mục tiêu
Một báo cáo kèm ảnh để chủ dự án xem rồi **chọn lỗi nào sửa**. Mỗi động tác của Trần Trung ở chương 1 được:
- chụp lại;
- chấm **Tự nhiên / Hơi gượng / Sai**;
- ghi rõ lỗi;
- đề xuất cách sửa và chỗ sửa: code, Blender, vị trí đồ, hay phải làm lại trên Tripo.

**Lượt này không sửa gì trong game.** Việc sửa là card sau, theo lựa chọn của chủ dự án.

## Phạm vi (chương 1 thật, `chapter1.tscn`; chỉ chương 1 có thân, D-151)
**A. Mọi thao tác bằng tay** (bắt buộc).
- **Lấy danh sách bằng code, không liệt kê tay:** mọi `Interactable` đang hiện, không phải `HideSpot`, có `hand_target()` (cùng vòng lặp với `test_every_hand_thing_can_be_reached_from_a_standing_spot` trong `game/tests/player/test_protagonist_chapter1.gd`).
- **Lấy ở nhiều mốc truyện:** có đồ chỉ hiện khi director đặt ra, ví dụ mẩu giấy của Khoa (`_place_khoa_note`). Nhảy mốc bằng `Chapter1Director.run_from(stage)` với các mốc trong `STAGES` (`prologue`, `r1`, `r2`, `r2_manager`, `end`), hoặc gọi thẳng hàm đặt đồ của director. Chương 1 không có menu F9 như chương 2–4. D-152 đếm được 23 đồ; ghi tổng thật của từng mốc.
- **Nhóm cần có:**
  - giấy, thẻ, ảnh, thời khóa biểu (lấy lên đọc rồi đặt lại);
  - cửa 407 (mở, đóng, trong và ngoài, sau T-239), chốt cửa;
  - công tắc, ổ điện, dây mạng, ổ mạng;
  - tủ, nan giường, chỗ lục đồ, gõ tường, bàn giải đố;
  - đồ ôm hoặc mang (`carry_item`) nếu chương 1 có.
- **Mỗi đồ khảo sát mọi cách với mà game cho phép:** đứng, nhón chân, rướn qua đồ, quỳ (D-152). Với mỗi cách, kiểm từ chỗ đứng gần nhất và một chỗ đứng xa nhất còn hiện lời nhắc.

**B. Tay trái và điện thoại** (bắt buộc): giơ lên đọc, cầm thấp bật đèn, cất. Cầm điện thoại **trong lúc** tay phải đang làm việc khác (lấy giấy, mở cửa): hai tay có va nhau không, điện thoại có xuyên thân không.

**C. Động tác thân liên quan** (bắt buộc, chấm như trên):
- đi, chạy, đi lùi, đi ngang, khom, đi khom;
- xoay tại chỗ (chân bước theo khi nhìn quay quá 50°);
- nhón chân, rướn, quỳ rồi tự đứng dậy;
- nằm giường lúc đầu chương và lúc đứng dậy;
- vào và ra chỗ nấp (thân có ẩn đúng không);
- nhìn xuống chân, hình trong gương;
- lúc chết: thân cất đi, tờ giấy về chỗ (D-151).

**D. Lỗi logic** (bắt buộc, ghi riêng một bảng). Ví dụ cần thử:
- tay xuyên đồ khác trên đường với (sổ, cốc, đèn bàn, thành giường, cánh tủ);
- với tới đồ nằm sau đồ khác;
- lời nhắc hiện mà tay không chạm được, hoặc ngược lại;
- đồ đặt lại lệch chỗ cũ sau khi đọc;
- dùng đồ khi đang khom, đang giơ điện thoại, đang đứng sát tường;
- thao tác tay khi quản lý vào phòng hoặc khi có sự kiện truyện;
- bấm dùng đồ liên tục;
- chết giữa lúc đang với;
- tay hoặc đồ đang cầm xuyên camera;
- thân lệch so với chỗ người chơi đứng.

## Cách làm
- **Chụp trong cảnh chương 1 thật,** 1080p, bằng cảnh tạm trong `game/_probe_tmp/` (không commit, xóa khi xong).
  - Mẫu chụp có ở cảnh thử `protagonist_pilot.gd`: `_capture`, `_show_third_person`.
  - Mẫu đứng đúng chỗ: `_stand_within_reach` trong `test_protagonist_chapter1.gd`.
- **Ảnh cho mỗi thao tác tay:**
  - góc mắt người chơi, ở các mốc: bắt đầu với, chạm, giữa lúc dùng, kết thúc;
  - một góc bên ngoài lúc chạm, để thấy cả cánh tay và thân.
- **Động tác thân:** chụp chuỗi ảnh hoặc quay video ngắn. Video để trong `build/`, không commit; báo cáo dẫn đường dẫn.
- **Đo khi có thể, không chỉ nhìn:**
  - tay xuyên đồ: điểm trên các đốt ngón hoặc cánh tay lọt vào va chạm hay hộp của đồ khác;
  - tay–đồ còn cách bao nhiêu lúc chạm;
  - chân trượt khi đi;
  - Cách đo dựa trên các phép đo của T-239.
- **Chấm từng mục:**
  - mức: Tự nhiên / Hơi gượng / Sai;
  - độ nặng: **cao** (người chơi thấy mỗi lần dùng đồ hoặc chặn chơi), **vừa** (thấy rõ nhưng ít gặp), **thấp** (phải tìm mới thấy).
- **Đề xuất sửa cho mỗi mục Hơi gượng hoặc Sai:**
  - sửa ở đâu: code IK/tư thế/nhịp, Blender (tư thế ngón, clip mới), vị trí đồ, hay Tripo (tốn credit, chủ dự án quyết);
  - ước lượng công: nhỏ (< 1 giờ), vừa, lớn;
  - mục nào cùng một nguyên nhân thì gom lại.
- **Câu hỏi thiết kế:** chỗ nào cần chủ dự án chọn kiểu động tác thì ghi thành câu hỏi kèm phương án và đề xuất, như mục 4 của T-239.

## Sản phẩm
- `art_source/graphics_upgrade/protagonist/T-240-survey/REPORT.md` (tiếng Việt), gồm:
  1. **Tóm tắt:** tổng số mục, số Tự nhiên / Hơi gượng / Sai, 5–10 lỗi nên sửa trước nhất kèm lý do.
  2. **Bảng A, B, C:** mỗi dòng gồm mục, cách với, mức, độ nặng, mô tả lỗi, ảnh, đề xuất sửa, công.
  3. **Bảng D (lỗi logic):** cách tái hiện từng bước.
  4. **Nhóm theo nguyên nhân chung**, với đề xuất card sửa (gom thành 1–3 card).
  5. **Câu hỏi cho chủ dự án.**
  6. **Phần chưa khảo sát được** và lý do.
- Ảnh: `art_source/graphics_upgrade/protagonist/previews/t240/` (jpg 1080p, chất lượng 85 cho nhẹ).
  - Tên file theo mục, ví dụ `a_ch1_dat_note_kneel_contact_view.jpg`.
  - Thêm một tấm tổng hợp nhiều ảnh nhỏ cho mỗi nhóm để chủ dự án xem nhanh.
- **Khuyến khích:** một trang `REPORT.html` mở bằng trình duyệt, có ảnh nhỏ bấm phóng to và lọc theo mức. Không bắt buộc.

## Được phép sửa
- `art_source/graphics_upgrade/protagonist/T-240-survey/`, `art_source/graphics_upgrade/protagonist/previews/t240/`.
- Card này: chỉ Checklist và Handoff.
- **Không** commit code game. Cảnh và script chụp để trong `game/_probe_tmp/`, xóa trước khi commit. Thấy cần một công cụ chụp dùng lâu dài thì ghi đề xuất trong Handoff.

## Không được
- Không sửa code, scene, asset game (kể cả lỗi rất nhỏ): ghi vào báo cáo.
- Không tiêu credit Tripo, không chạy bot, không đo FPS.
- Không sửa STATUS, DECISIONS. Không commit `anh_chup_sua_loi/`, log, video.

## Godot
- Luật Lượt Godot: khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt` (`CreateNew`), mỗi lần chỉ chạy một lượt Godot nặng, xóa khóa khi xong kể cả khi lỗi, không tắt Godot của lane khác.
- Chụp có cửa sổ dễ tốn RAM: chia nhiều lượt chụp, mỗi lượt một nhóm.
- Đã biết: lúc đọc mẩu giấy của Khoa, chụp có cửa sổ từng bị treo hai lần (D-152). Nếu còn, ghi cách tái hiện như một lỗi logic.
- Không sửa code nên **không cần full test và check**. Chỉ cần `git status` sạch phần game trước khi commit, và `git checkout -- game/default_bus_layout.tres` nếu file bị đổi.

## Checklist hoàn thành
- [ ] Danh sách đồ dùng tay lấy bằng code ở mọi mốc truyện, có tổng số
- [ ] Phần A: mọi đồ, mọi cách với, đã chấm và có ảnh
- [ ] Phần B: điện thoại ba trạng thái và lúc dùng cùng tay phải
- [ ] Phần C: động tác thân, đã chấm
- [ ] Phần D: bảng lỗi logic có cách tái hiện
- [ ] Nhóm theo nguyên nhân, đề xuất card sửa, câu hỏi cho chủ dự án
- [ ] REPORT.md và ảnh đã commit; `game/` không đổi
- [ ] Handoff: commit, chỗ chưa khảo sát

## Cách kiểm tra (integrator)
- Đọc báo cáo và xem ảnh, đối chiếu ngẫu nhiên vài mục trong game.
- Tóm tắt cho chủ dự án để chủ dự án chọn lỗi cần sửa, rồi viết card sửa.

## Handoff (agent điền)
