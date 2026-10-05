# T-185 — Chương 3: thanh thể lực, thanh sắt, lớp chết mới, thẻ hết chương
- Lane: D (UI) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-185-ch3-ui`
- Phụ thuộc: T-163, T-174, T-179. **Đọc `docs/design/CH3_DESIGN.md`** (D-052).
- **Hạn đề xuất: hết ngày 2026-10-08.**

## Mục tiêu
Giao diện ít và kín đáo, kiểu kinh dị (D-038: không giải thích luật): người chơi cảm nhận thể lực và độ cong của thanh sắt, không bị bảng chữ che.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `strings.csv`

## Hợp đồng có sẵn (core, không sửa). Đọc chú thích trong `event_bus.gd`, mục "Chapter 3"
- `stamina_changed(value, exhausted)`;
- `bar_picked(hits_left)`, `bar_swung(hit, hits_left)`, `bar_broken()`;
- `guard_warned(guard, warned)`;
- `player_death_started(kind)`: kind mới `&"zombie_grab"`, `&"guard_shock"`;
- `companion_state_changed(member, state)`;
- `chapter_finished(3)`.

## Yêu cầu
1. **Thể lực:**
   - không có thanh số cố định;
   - khi thể lực dưới khoảng 60% thì viền màn hình **tối và mờ dần**, nhịp thở hiện qua viền co giãn nhẹ;
   - cạn (`exhausted`) thì viền đậm và rung nhẹ;
   - về đầy thì biến mất;
   - "Giảm hù dọa" làm hiệu ứng nhẹ hơn.
2. **Thanh sắt:**
   - biểu tượng nhỏ góc dưới, chỉ hiện khi đang cầm;
   - hình thanh sắt **cong dần** theo `hits_left` (4–5 mức hình), không ghi số;
   - gãy thì biểu tượng vỡ rồi mất.
3. **Lớp chết:**
   - `zombie_grab`: máu kiểu `manager_kill`, thêm vết tay máu;
   - `guard_shock`: chớp trắng, nhiễu điện, rồi tối;
   - tôn trọng "Giảm hù dọa".
4. **Bảo vệ cảnh báo:** khi `guard_warned(_, true)`, màn hình **nhiễu điện nhẹ** ở mép (không có chữ).
5. **Thẻ hết chương 3:** "Hết chương 3" như chương 2 (key `UI_CH3_END`, core thêm qua script nếu cần; lane D thêm key UI của mình).
6. **Chọn chương:** màn tiêu đề cho chọn chương 3 khi đã mở khóa (`Progress.unlocked_chapter() >= 3`), cảnh báo nội dung như các chương khác.
7. **Màn chết:** hiện đúng lý do `DEATH_CH3_GRABBED`, `DEATH_CH3_GUARD` (core thêm chữ).
8. **Test và preview:** viền thể lực (đầy, thấp, cạn), biểu tượng thanh sắt (mới, cong, gãy), hai lớp chết, nhiễu cảnh báo bảo vệ; ảnh vi/en.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh preview vi/en
- [x] Handoff: scene, API, đường dẫn node

## Handoff (agent điền)

### Đã giao

- Commit triển khai UI: `bcd88ca` trên nhánh `lane-d/T-185-ch3-ui` (base `b9fcee5`).
- Scene chính: `res://ui/ch3/ch3_status.tscn` (CanvasLayer 8, `Root/Stamina`, `Root/GuardWarning`, `Root/BarIcon`), chỉ nên mount khi Chương 3 được khởi tạo. Scene chạy `process_mode = ALWAYS`, Control đều `mouse_filter = IGNORE` và không nhận input.
- Scene thẻ kết chương: `res://ui/ch3/ch3_end_card.tscn` (CanvasLayer 19, `Root/Shade`, `Root/Center/Lines/Title`, `Root/Center/Lines/Chapter`). `chapter_finished(3)` gọi `show_card()`; core phải dừng gameplay và mở khóa tiếp tục/chương 4. Có thể dùng scene này hoặc flow thẻ hiện có của core, không mount cả hai.
- Lớp chết hiện có được mở rộng tại `res://ui/death/blood_overlay.tscn`/`res://scripts/ui/blood_overlay.gd`: `zombie_grab` thêm tay máu, `guard_shock` chớp trắng/nhiễu rồi tối; "Giảm hù dọa" giảm hiệu ứng. Lý do chết vẫn do `DeathScreen` dịch từ key core cung cấp.
- API nhận từ EventBus: `stamina_changed(value, exhausted)`, `bar_picked(hits_left)`, `bar_swung(hit, hits_left)`, `bar_broken()`, `guard_warned(guard, warned)`, `player_death_started(kind)`, `chapter_finished(3)`. UI không tự suy diễn lượt đánh hay luật chơi; `hits_left` là giá trị authoritative từ core. `Root/BarIcon` có `max_hits = 8`, core set lại nếu tuning khác.
- Khi checkpoint tải xong, core/A cần phát lại trạng thái stamina/thanh sắt/cảnh báo sau khi mount UI; `reset_display()` cố ý xóa cache presentation.
- Script và shader: `res://scripts/ui/ch3_status.gd`, `iron_bar_icon.gd`, `ch3_end_card.gd`; `res://ui/ch3/stamina.gdshader`, `guard_warning.gdshader`; test `res://tests/ui/test_ch3_ui.gd`. Key mới: `UI_CH3_END` trong `res://localization/strings.csv`.
- Preview VI/EN và credits: `res://ui/ch3/previews/`, scene fixture `res://ui/ch3/ch3_ui_preview.tscn`, hướng dẫn/nguồn `res://ui/ch3/CREDITS.md`. Có đủ trạng thái stamina, thanh sắt, hai lớp chết, cảnh báo bảo vệ, thẻ kết chương và màn chọn chương. Fixture chọn chương dùng Progress tạm để minh họa mở khóa; không thay thế mapping chapter runtime.

### Kiểm thử

- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.
- `pwsh tools/test.ps1 -Filter ch3_ui`: `RESULT: 8 passed, 0 failed`.
- Full `pwsh tools/test.ps1` đã chạy hai lần: `RESULT: 519 passed, 1 failed`; lỗi duy nhất là test có sẵn ngoài phạm vi `game/tests/levels/test_ch2_props.gd::test_stuck_door_shakes_without_opening_then_cancels_on_open`. Chạy riêng `-Filter ch2_props` cho `7 passed, 0 failed`, nên chưa khẳng định nguyên nhân production; test dùng timer 0.07 giây và STATUS đã ghi nhận flaky.
- **Blocked:** checklist toàn bộ test PASS chưa đạt vì blocker ngoài phạm vi Lane D. Không sửa test/cửa của Lane B để che lỗi.

### Yêu cầu thay đổi ngoài phạm vi

- Lane B/integrator ổn định test cửa kẹt nêu trên bằng tiến trình animation/điều kiện chờ xác định; chạy lại full suite sau khi sửa.
- Core thêm mapping `App.CHAPTER_SCENES[3]` tới scene Chương 3 (hiện chưa có scene production, chọn chương 3 còn fallback chương 1), mount `ch3_status` và blood/death overlay đúng lifecycle.
- Core cung cấp bản dịch VI/EN thật cho `DEATH_CH3_GRABBED` và `DEATH_CH3_GUARD`; UI đã route key generic nhưng không tự đặt lời thoại cốt truyện.
- Core cập nhật `export_presets.cfg` loại `ui/ch3/previews/*`, `ui/ch3/ch3_ui_preview*`, `scripts/ui/ch3_ui_preview.gd*` khỏi export nếu đây chỉ là fixture.
- Lane C/integrator kiểm tra full scene, FPS, camera và death flow sau khi tích hợp; chưa thực hiện gameplay/export tích hợp trong phạm vi UI.
