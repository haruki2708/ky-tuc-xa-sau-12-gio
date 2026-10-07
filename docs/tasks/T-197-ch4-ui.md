# T-197 — Chương 4: tab "Đối chiếu", phiếu điều tra, tên bằng máu, mờ dần và nhắn cuối, thẻ bệnh viện, thẻ hết chương
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-197-ch4-ui`
- Phụ thuộc: T-111, T-156, T-179 (ô gõ chữ chương 2), T-194 (**hợp đồng chung**), `docs/design/CH4_DESIGN.md`, D-067.
- **Hạn đề xuất:** 2026-10-10.

## Việc
### 1. Tab "Đối chiếu" trong sổ quy tắc (thư viện)
- Sổ quy tắc (T-156) có thêm tab **Đối chiếu**, **chỉ hiện ở chương 4** (khi `GameState.get_flag(&"ch4_compare_enabled", false)`, core đặt ở thư viện). Phát `EventBus.ch4_compare_opened()` khi mở.
- Nội dung: **nguyên văn 5 vòng luật** (đọc từ `RuleSystem`/sổ, mỗi vòng một khối) và cạnh mỗi vòng **cách người chơi đã qua** (một dòng ngắn từ `GameState`; core cung cấp các key `UI_CH4_SOLVED_R2…R4`; vòng 1 và 5 không có dòng này). **Không chú thích gì thêm.**
- **Luật vòng 5 gồm 3 dòng** (`RULE_CH3_R5_1…3`, id `ch3_r5_1…3`). Người chơi **gạch chân một dòng** (chọn dòng rồi bấm nút "Gạch chân"): phát `EventBus.ch4_sentence_marked(rule_key)`. Core trả lời `ch4_compare_result(rule_key, matched)`: `matched` thì dòng đó **giữ gạch chân** và hiện ghi chú do người chơi "viết" (`UI_CH4_NOTE_REDUNDANT`, một dòng ngắn, ví dụ "Câu này thừa."); sai thì gạch chân tắt và hiện "Chưa khớp." (`UI_CH4_NOT_YET`), **không phạt, không gợi ý**.

### 2. Phiếu điều tra người sống sót
- Khi nhận `EventBus.bed_slat_flipped(bed)`: hiện **mảnh phiếu** của giường đó (3 mảnh khác nhau, chữ loang đứt đoạn, như mảnh biên bản chương 1 N5) trong tab/giấy đã có; mảnh được thêm vào "tài liệu đã nhặt".
- Nhận `survivor_form_assembled()`: **ghép 3 mảnh** thành **Phiếu điều tra người sống sót sau thảm họa động đất**: tiêu đề, các cột giới tính, tuổi, ngày sinh, phòng, tòa (đã điền khớp Trung, chữ loang), cột **"Họ và tên" để trống**. Chữ qua `UI_CH4_FORM_*` (D thêm key).

### 3. Viết tên bằng máu
- Trên phiếu có nút **"Cắn ngón tay"** (`UI_CH4_BITE`). Bấm thì hiện **ô gõ tên** (cùng khung với ô nối từ chương 2: bộ gõ của máy, không gợi ý; chữ đỏ sẫm như máu) và phát `EventBus.blood_name_requested(seconds)` (core đặt `seconds` theo thời gian cửa 407 còn lại). **Phát `text_entry_changed(true)`** khi nhận bàn phím, `false` khi trả (lane A đứng yên).
- Gửi tên: `EventBus.blood_name_typed(text)`. Core trả `blood_name_closed(result)`: `accepted` thì tên **hiện bằng máu** trên phiếu (hiệu ứng viết); `wrong` thì **không** xóa, cho gõ lại tới hết giờ (cửa vỡ); `timeout` đóng ô.
- Có **đồng hồ** theo dõi cửa (thanh nhỏ), không số.

### 4. Mờ dần và tin nhắn cuối
- Nhận `fade_message_requested(seconds)`: **cơ thể mờ dần** (lớp hiệu ứng: viền màn hình trắng/bạc dần, hình tay Trung trong suốt dần), điện thoại sáng, **ô nhắn vào nhóm chat** (cùng khung, 12 giây mặc định). Gửi: `fade_message_typed(text)`. Core trả `fade_message_closed(result)`: `sent` hoặc `timeout`.
- Màn hình trắng/đen kéo dài ngắn rồi chuyển cảnh (core điều khiển).

### 5. Thẻ tên bệnh viện và thẻ hết chương
- **`res://ui/ch4/bed_card.tscn`:** `Node3D` có `Label3D` (chữ thẻ giường bệnh: tên, tuổi, tình trạng "hôn mê" nếu cần); lane B gắn vào `Bed_*/Card`. Nhận `ch4_ending(kind)`: `all` thì thẻ `Bed_Nhat`, `Bed_Ngu` hiện tên (**Lý Minh Nhật**, **Khương Ngọc Ngư**); `alone` thì **ẩn** (giường trống). Thẻ `Bed_Trung` luôn hiện **Trần Trung**.
- **`res://ui/ch4/ch4_end_card.tscn`:** thẻ **"Hết chương 4"**, tiếp theo **tiêu đề cảm ơn** và credits (đã có từ chương 2: `credits`); nghe `EventBus.chapter_finished(4)`.
- **HUD điện thoại:** hiển thị số **lần đổ chuông còn lại** (biểu tượng nhỏ cạnh pin, từ `GameState` flag `ch4_phone_charges` và `phone_decoy_thrown`); chỉ chương 4.

### 6. Test và chữ
`game/tests/ui/`: tab Đối chiếu chỉ ở chương 4, gạch chân phát đúng tín hiệu và nhận kết quả, mảnh phiếu theo `bed_slat_flipped`, ô tên và ô nhắn phát/nhận đúng tín hiệu và `text_entry_changed`, thẻ giường theo `ch4_ending`, mọi key chữ có `vi` và `en`.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key `UI_CH4_*`), `game/tests/ui/`, card này (Handoff).

## Checklist hoàn thành
- [x] Tab Đối chiếu, gạch chân dòng, kết quả đúng/sai, không phạt
- [x] Mảnh phiếu theo từng vạt; phiếu ghép đủ; ô họ tên trống
- [x] "Cắn ngón tay" → ô tên bằng máu, `text_entry_changed`, đồng hồ cửa
- [x] Hiệu ứng mờ dần, ô nhắn 12 giây
- [x] `bed_card.tscn`, `ch4_end_card.tscn`, HUD lần đổ chuông
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: tên scene/API, ảnh chụp

## Handoff (agent điền)

### Đã làm

- Commit triển khai: `9ddc309` (`T-197: add chapter four UI and localization`), nhánh `lane-d/T-197-ch4-ui`, base sau khi cập nhật `origin/main` là `3a782d4`.
- Sổ hiện có `res://ui/notebook/notebook.tscn`; `res://scripts/ui/notebook.gd` gắn view động `Chapter4` từ `res://scripts/ui/ch4_notebook.gd`. Tab `Đối chiếu` chỉ hiện khi `GameState.chapter == 4` và flag `ch4_compare_enabled` đúng. Mở tab phát `EventBus.ch4_compare_opened()`.
- `Chapter4/CompareScroll` hiển thị nguyên văn các RuleData vòng 1–5; vòng 5 cho chọn `ch3_r5_1`, `ch3_r5_2`, `ch3_r5_3` rồi nút `UI_CH4_UNDERLINE`. UI phát `ch4_sentence_marked(rule_key)`, chỉ giữ gạch chân khi core trả `ch4_compare_result(rule_key, true)`; kết quả sai chỉ hiện `UI_CH4_NOT_YET`, không phạt. Gạch chân đúng được lưu ở flag UI `ch4_ui_marked_rule`.
- `Chapter4/Forms` trong view sổ dùng `bed_slat_flipped(1|2|4)` để hiển thị ba mảnh riêng, `survivor_form_assembled()` để ghép phiếu. Flags UI `ch4_ui_scrap_1`, `_2`, `_4` lưu mảnh đã xem; core vẫn sở hữu `ch4_slats_found`/`ch4_form_ready`. Các node chính: `Collected`, `PaperScroll/Paper/Fields`, `Bite`, `BloodName/Entry`, `BloodName/Clock`.
- `res://scripts/ui/reading_overlay.gd` có `pause_gameplay` và `reader_player_path`. Khi Chương 4 mở sổ, scene tree tiếp tục chạy để cửa đếm thời gian, còn Player nhận `acquire_control_lock()`/`release_control_lock()`. Chương 1–3 giữ hành vi pause cũ. Death/checkpoint/chapter reset đóng reader và trả khóa.
- Ô nhập tên là `res://scripts/ui/ch4_timed_entry.gd`: native `LineEdit`/IME, phát `text_entry_changed(true/false)` qua `game_text_entry.gd`, gửi `blood_name_typed(text)` đúng một lần mỗi lượt. `wrong` giữ nguyên draft để gõ lại; `accepted` hiện chữ máu; `timeout` đóng. `door_damage_changed("407", fraction)` dùng fraction hư hại từ T-195, nên đồng hồ hiển thị phần còn lại trong 90 giây. Flag `ch4_ui_signature` chỉ lưu text đã core chấp nhận.
- Điện thoại dùng view `PhoneScreen/Content/Chapter4/Message` từ `res://scripts/ui/ch4_phone.gd`; `fade_message_requested(seconds)` mở native input và lớp `res://ui/ch4/fade_effect.tscn` (mép trắng/bạc + tay polygon nguyên bản), gửi `fade_message_typed(text)`, chỉ ghi transcript sau `fade_message_closed("sent")`. `Status/DecoyCharges` hiển thị biểu tượng chuông và số từ `ch4_phone_charges`/`phone_decoy_thrown`. `ch4_ending`, death và checkpoint dọn effect.
- Scene thẻ bệnh viện: `res://ui/ch4/bed_card.tscn`, script `res://scripts/ui/ch4_bed_card.gd`, node `Name`/`Details` (`Label3D`). Gắn dưới `Bed_Trung/Card`, `Bed_Nhat/Card`, `Bed_Ngu/Card`; tự suy ra tên giường hoặc set export `character`. `ch4_ending("all")` hiện hai thẻ bạn, `"alone"` ẩn hai thẻ; thẻ Trung luôn hiện.
- Scene kết: `res://ui/ch4/ch4_end_card.tscn`, script `res://scripts/ui/ch4_end_card.gd`, CanvasLayer 19. `chapter_finished(4)` hiện “Hết chương 4”, sau đó cảm ơn và credits hiện có. Core phải dừng gameplay và đặt `app_path` nếu `/root/App` khác mặc định; scene này chỉ nên instance một lần.
- Blood overlay hiện có nhận thêm `door_burst`; `ch3_status.gd` cho phép hiển thị status ở Chapter 4. Không thêm luật, lời thoại cốt truyện hoặc quyết định kết vào UI.

### Chữ, preview và cách kiểm tra

- Thêm các key `UI_CH4_*` đủ `vi`/`en` vào `game/localization/strings.csv`; chưa thêm key `DEATH_CH4_*`, `UI_CH4_SOLVED_R2…R4` vì core sở hữu nội dung đó.
- 24 ảnh VI/EN nằm tại `res://ui/ch4/previews/` (compare, marked, scrap, form, name, signed, fade, hospital_all, hospital_alone, end, credits, door), kèm `.import`. Scene fixture `res://ui/ch4/ch4_ui_preview.tscn`; credits và lệnh capture ở `res://ui/ch4/CREDITS.md`. Hướng dẫn node/API chi tiết ở `res://ui/ch4/README.md`.
- `pwsh tools/test.ps1 -Filter ch4_ui`: `RESULT: 12 passed, 0 failed`.
- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.
- Full `pwsh tools/test.ps1` sau khi cập nhật `origin/main`: `RESULT: 612 passed, 1 failed`; lỗi duy nhất `test_ch3_tools.gd::test_preflight_never_claims_unbound_profile_is_complete` (T-193/Lane C). Chạy riêng `pwsh tools/test.ps1 -Filter ch3_tools`: `RESULT: 6 passed, 0 failed`.
- **Blocked:** checklist full test PASS chưa đạt do test T-193 chập chờn ngoài phạm vi Lane D. Không sửa tools/profile/test của Lane C để che lỗi.

### Yêu cầu thay đổi ngoài phạm vi

- Lane C ổn định `test_preflight_never_claims_unbound_profile_is_complete` và profile T-193 để full suite không phụ thuộc timing; sau đó chạy lại full test.
- Core/T-194 thêm các key và flag đã nêu trong hợp đồng: `UI_CH4_SOLVED_R2`, `UI_CH4_SOLVED_R3`, `UI_CH4_SOLVED_R4` (và giá trị GameState tương ứng), đồng thời cung cấp các giá trị đã duyệt cho `ch4_form_sex`, `ch4_form_age`, `ch4_form_dob`. Base hiện chưa có dữ liệu tuổi/ngày sinh/giới tính của Trung; UI để trống, không tự đoán.
- Core instance đúng các UI scene trong `chapter4.tscn`, nối `reader_player_path`, phát lại trạng thái sau checkpoint, cung cấp `DEATH_CH4_*`/`door_burst` và điều khiển dừng/chuyển cảnh.
- Lane A phát `door_damage_changed("407", fraction)` theo đúng quy ước fraction hư hại và hoàn tất `blood_name_*`/`fade_message_*` lifecycle; Lane B gắn `bed_card.tscn` vào ba anchor bệnh viện và kiểm tra layout trong hospital scene.
- Core cập nhật export preset loại fixture `ui/ch4/previews/*`, `ui/ch4/ch4_ui_preview*`, `scripts/ui/ch4_ui_preview.gd*` khỏi bản phát hành nếu không muốn ship preview.
- Chưa thực hiện gameplay integration, OS-level Vietnamese IME composition, controller feel, FPS/export và playtest bệnh viện; cần Lane C/integrator kiểm tra sau khi các lane Chương 4 ghép.

## Review (integrator)
