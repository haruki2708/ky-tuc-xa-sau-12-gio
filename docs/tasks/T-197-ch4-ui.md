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
- [ ] Tab Đối chiếu, gạch chân dòng, kết quả đúng/sai, không phạt
- [ ] Mảnh phiếu theo từng vạt; phiếu ghép đủ; ô họ tên trống
- [ ] "Cắn ngón tay" → ô tên bằng máu, `text_entry_changed`, đồng hồ cửa
- [ ] Hiệu ứng mờ dần, ô nhắn 12 giây
- [ ] `bed_card.tscn`, `ch4_end_card.tscn`, HUD lần đổ chuông
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: tên scene/API, ảnh chụp

## Handoff (agent điền)

## Review (integrator)
