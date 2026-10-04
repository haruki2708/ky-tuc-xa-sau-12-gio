# T-156 — Sổ quy tắc, bảng số người sống sót, màn chết, panel khóa số
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-156-rulebook-survivors`
- Phụ thuộc: T-155 (làm ngay sau). Đọc `docs/design/STORY.md` v2 §3, §5, §8.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Theo thiết kế, lời giải nằm ở **câu chữ** của quy tắc, nên người chơi phải tra lại được nguyên văn mọi quy tắc. Loa đọc số người sống sót sau mỗi vòng; chết thì có màn chết rõ ràng. Vòng 1 có một câu đố tủ khóa số.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (không sửa)
- `RuleSystem.mark_read(rule_id, source, text_key)`, `read_entries()`, `set_suspected()`, `set_evidence()`, `evidence_for()`; signal `rule_entry_added`, `rule_evidence_changed`. Quy tắc mỗi vòng được integrator nạp như các dòng luật, nguồn `speaker`.
- `EventBus.survivor_count_changed(count)`, `player_caught(entity_id)`, `player_failed(rule_id)`, `segment_changed`.
- `EventBus.puzzle_opened(id)`, `puzzle_closed(id)`, `puzzle_solved(id)`; `PuzzleData` (`kind = &"combination"`, `solution`, `title_key`, `hint_document`, `check()`).

## Yêu cầu
1. **Sổ quy tắc** (dựa trên `notebook.gd` hiện có; đổi tiêu đề và cách nhóm):
   - Nhóm theo vòng: "Tổng tắc", "Vòng 1", "Vòng 2"… Nhóm của mỗi dòng lấy từ tiền tố `text_key` hoặc từ `source`; đề xuất cách trong Handoff nếu cần integrator thêm trường.
   - Hiện **nguyên văn** từng dòng, chữ to. Quy tắc đã hết hiệu lực (vòng cũ) hiện mờ hơn, có nhãn "hết hiệu lực".
   - **Ghi chú của người chơi:** dùng "đánh dấu nghi ngờ" hiện có, đổi tên thành "đáng chú ý".
   - Mở bằng Tab như cũ.
2. **Bảng số người sống sót:**
   - Khi `survivor_count_changed(n)`: chữ lớn giữa màn hình "Số người sống sót: n", khoảng 4 giây, mờ dần, kiểu thông báo lạnh lùng.
   - Không chặn điều khiển.
3. **Màn chết:**
   - Khi `player_caught` hoặc `player_failed`: màn đen, chữ "Bạn đã chết" và lý do ngắn (integrator truyền key; đề xuất API `show_death(reason_key)`), rồi dòng "Số người sống sót: n−1".
   - Nút hoặc phím để chơi lại; integrator nối với tải checkpoint (dùng lại luồng màn thua hiện có nếu hợp).
4. **Panel khóa số** (`ui/puzzle/puzzle_panel.tscn`, chỉ cần `kind = &"combination"` cho chương 1):
   - Mở khi `puzzle_opened(id)`: dừng điều khiển như màn xem giấy, nhả chuột.
   - **Số vòng số lấy theo độ dài `solution`.** Bấm lên/xuống hoặc lăn chuột trên từng vòng.
   - Đủ số thì tự kiểm tra; sai thì rung nhẹ, có tiếng lạch cạch; đúng thì `puzzle_solved(id)` rồi tự đóng sau khoảng 0,8 giây.
   - Esc thì `puzzle_closed(id)`. Có `hint_document` thì có nút xem gợi ý; giấy chưa tồn tại thì ẩn nút.
   - Panel cầu dao để sang chương sau.
5. **Song ngữ:** đủ `vi` và `en`.
6. **Test:**
   - sổ quy tắc nhóm đúng vòng, hiện "hết hiệu lực";
   - bảng sống sót hiện rồi tắt;
   - màn chết hiện lý do;
   - panel khóa số đúng/sai, Esc;
   - không lỗi khi thiếu `hint_document`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp: sổ quy tắc, bảng sống sót, màn chết, panel khóa số (vi và en)
- [ ] Handoff: API, yêu cầu cho integrator

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Màn chết (**đã chốt sau khi ghép bot T-157**): luồng chương phát **`EventBus.player_failed(reason_key)`** cho mỗi lần chết, `reason_key` là key lý do. Màn chết **nghe signal này** để hiện; không cần hàm `show_death`. Node màn chết vào **group `death_screen`**: khi group có node, luồng chương không hiện thẻ đen tạm nữa và chờ 5 giây rồi tải lại checkpoint. Màn chết không tự tải lại. Báo cho integrator đường dẫn node để cập nhật `death_ui_path` trong `tools/ch1-profile.json`. Lý do chết là các key `DEATH_STAYED_IN_BED`, `DEATH_LEFT_ROOM`, `DEATH_NOT_IN_BED`, `DEATH_OWN_BED`, `DEATH_HEARD` (xem `docs/design/CH1_SCRIPT.md`).

## Handoff (agent điền)
