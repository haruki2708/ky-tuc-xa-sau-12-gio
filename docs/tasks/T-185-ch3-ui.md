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
- [ ] Ảnh preview vi/en
- [ ] Handoff: scene, API, đường dẫn node

## Handoff (agent điền)
