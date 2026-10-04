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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh chụp: sổ quy tắc, bảng sống sót, màn chết, panel khóa số (vi và en)
- [x] Handoff: API, yêu cầu cho integrator

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Màn chết (**đã chốt sau khi ghép bot T-157**): luồng chương phát **`EventBus.player_failed(reason_key)`** cho mỗi lần chết, `reason_key` là key lý do. Màn chết **nghe signal này** để hiện; không cần hàm `show_death`. Node màn chết vào **group `death_screen`**: khi group có node, luồng chương không hiện thẻ đen tạm nữa và chờ 5 giây rồi tải lại checkpoint. Màn chết không tự tải lại. Báo cho integrator đường dẫn node để cập nhật `death_ui_path` trong `tools/ch1-profile.json`. Lý do chết là các key `DEATH_STAYED_IN_BED`, `DEATH_LEFT_ROOM`, `DEATH_NOT_IN_BED`, `DEATH_OWN_BED`, `DEATH_HEARD` (xem `docs/design/CH1_SCRIPT.md`).

## Handoff (agent điền)

### Bàn giao Lane D — 2026-10-04

- Base `d000c8f` (`origin/main` lúc bắt đầu), nhánh `lane-d/T-156-rulebook-survivors`. Commit triển khai `628db92` đã push trước Handoff này. Chỉ sửa vùng UI/test UI và thêm 18 key VI/EN; không sửa dữ liệu luật, core, main, tools, âm thanh hay STATUS.
- Sổ đổi thành **Sổ quy tắc**, giữ nguyên `text_key` từng dòng; nhóm theo vòng, nhóm cũ mờ và có nhãn Hết hiệu lực. Nút Đáng chú ý dùng lại `set_suspected`, hiển thị chứng cứ đã ghim qua `evidence_for`; đổi ngôn ngữ cập nhật ngay. Dữ liệu cũ không có tiền tố vòng vẫn nhóm theo nguồn để giữ tương thích.
- Bảng sống sót hiện giữa màn hình 4 giây, mờ ở giây cuối, không pause/đổi chuột/chặn input. Màn chết đen, hiện lý do và số sống sót trừ một; tuân theo bổ sung của integrator: nghe `player_failed(reason_key)`, không tự tải lại và không có nút tạo thêm luồng reload.
- Panel khóa số tạo số vòng từ `solution.length()`, ban đầu để trống; bấm +/− hoặc lăn trên từng vòng. Khi mọi vòng đã có số, mỗi thay đổi tự kiểm tra. Sai có phản hồi/rung nhẹ/âm kim loại; Giảm hù dọa tắt rung. Đúng phát `puzzle_solved` một lần rồi đóng sau 0,8 giây. Esc/nút đóng phát `puzzle_closed`, kể cả đang xem gợi ý. Gợi ý đọc nguyên văn DocumentData trong vùng cuộn của panel; file thiếu thì ẩn nút. Không làm panel cầu dao.
- Sửa lỗi đọc giấy phát hiện khi chạy full test: bỏ qua lần nhả interact đã dùng để mở giấy; chỉ lần nhấn mới trong màn đọc mới cho phép đóng khi nhả. Shared reading overlay xóa input interact trước khi bỏ pause, tránh Player poll lại lần nhấn cũ. Có test hồi quy; không sửa test core để làm PASS.

### API và cách gắn vào chương

| Scene / node đề xuất dưới root chương | Hợp đồng |
|---|---|
| `res://ui/notebook/notebook.tscn` / `Notebook` (đã có) | Tab như cũ; đọc RuleSystem, cập nhật khi entry/evidence/suspicion/segment đổi. |
| `res://ui/survivors/survivor_notice.tscn` / `SurvivorNotice` | Nghe `survivor_count_changed(count)`; export `display_seconds = 4`. Thông báo mới thay thông báo đang hiện; pause giữ thời gian còn lại. |
| `res://ui/death/death_screen.tscn` / `DeathScreen` | Tự vào group `death_screen`; `is_open()` cho modal guard. Đọc `GameState.get_flag("survivors")`, chỉ hiển thị n−1, không sửa count của core. Lý do lạ/thiếu count có nhãn dự phòng, không tự bịa lý do. |
| `res://ui/puzzle/puzzle_panel.tscn` / `PuzzlePanel` | Nghe `puzzle_opened(id)` → `PuzzleData.load_by_id()`. API thử `open_puzzle(data) -> bool`, `is_open()`, `close_view()`. Export `solved_delay = 0.8`, `wrong_sound`. |

- Gắn một instance mỗi scene trên viewport chính, ngoài filter PS1. Layer: notice 14, notebook 15, puzzle 18, death 30.
- **QA `death_ui_path`: `DeathScreen/Root`**, tương đối với root scene chương. Cần trỏ vào Root vì đây là Control thật sự ẩn/hiện, không trỏ CanvasLayer luôn tồn tại.
- DeathScreen mặc định `player_path = ../Player`, `pause_menu_path = ../PauseMenu`; dùng API khóa điều khiển hiện có của Player. Trước khi hiện, nó đóng reader/puzzle/pause đang mở; không pause tree để timer 5 giây của Chapter1Director tiếp tục. `checkpoint_loaded`/`chapter_started` gọi `close_view()` và trả khóa; giải phóng scene cũng trả khóa. Sổ/menu không mở thêm khi màn chết đang hiện. Không nghe `player_caught` trực tiếp: core đổi sự kiện đó thành `player_failed` với lý do theo bổ sung đã chốt.
- Puzzle dùng quyền pause chung với màn giấy, nhả chuột và khôi phục khi đóng. Không chiếm pause của modal khác. Nếu ID/kind/solution không hợp lệ hoặc đang có modal khác, phát `puzzle_closed(id)` để station không giữ khóa Player. Khi đúng, station nhận solved trước; UI giữ pause 0,8 giây rồi phát closed.
- Âm sai dùng lại `res://audio/sfx/door_latch.ogg` của Lane E, đúng mức âm gốc, bus SFX; nguồn trong [CREDITS](../../game/ui/chapter_previews/CREDITS.md). Không thêm/sửa asset âm thanh.

### Quy ước nhóm quy tắc

- `RULE_CH<n>_GENERAL_*` → Tổng tắc (thứ tự 0); `RULE_CH<n>_R1`…`R5` hoặc hậu tố `_...` → Vòng 1…5. Nếu key không khớp, source `general`, `r1`…`r5`, `round_1`…`round_5` cũng được nhận.
- Vòng hiện hành lấy từ số vòng lớn nhất **đã ghi vào `read_entries()`**; nhóm nhận diện có số nhỏ hơn được gắn Hết hiệu lực. Segment chỉ yêu cầu refresh, không suy diễn quy tắc chưa được đọc. UI không thay việc kiểm tra luật của core.
- Base hiện chỉ có `GENERAL_*` và `RULE_CH1_R2`, nên không tự tạo nhóm Vòng 1 rỗng hoặc chép lại câu luật. Cách này chưa cần thêm trường dữ liệu. Chứng cứ đã ghim được hiển thị; card không yêu cầu màn chọn/ghim chứng cứ mới nên không thêm luồng đó.

### Kiểm tra và ảnh

```text
pwsh tools/test.ps1
RESULT: 331 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)

pwsh tools/test.ps1 -Filter ui
RESULT: 70 passed, 0 failed

pwsh tools/test.ps1 -Filter test_core.gd
RESULT: 18 passed, 0 failed
```

- Full test đầu có `RESULT: 329 passed, 1 failed` ở `test_reading_the_door_paper_opens_and_closes_cleanly`; đã sửa xử lý input UI như trên. Full test cuối 331/331 (thêm một test hồi quy sau lần đầu). Log cục bộ ignored: `build/T-156/test.log`, `test-final.log`, `core-recheck.log`, `ui-final.log`, `check.log`.
- Đã render và xem tám ảnh 1920×1080, VI/EN, Git LFS, đủ `.import`: [sổ VI](../../game/ui/chapter_previews/rulebook_vi.png), [EN](../../game/ui/chapter_previews/rulebook_en.png); [sống sót VI](../../game/ui/chapter_previews/survivors_vi.png), [EN](../../game/ui/chapter_previews/survivors_en.png); [chết VI](../../game/ui/chapter_previews/death_vi.png), [EN](../../game/ui/chapter_previews/death_en.png); [khóa số VI](../../game/ui/chapter_previews/puzzle_vi.png), [EN](../../game/ui/chapter_previews/puzzle_en.png). Đã xem thêm ảnh hint có vùng cuộn trong `build/T-156/hint_vi/`.
- F6 `res://ui/chapter_panels_test.tscn`, hoặc truyền `-- --chapter-ui=rulebook_vi|rulebook_en|survivors_vi|survivors_en|death_vi|death_en|puzzle_vi|puzzle_en|hint_vi`. Fixture dùng dữ liệu đã duyệt trong repo, không chạy director hay ghi checkpoint.
- Test bao phủ nhóm/hết hiệu lực/nguyên văn/dấu chú ý/chứng cứ/dịch live; notice thay số, fade, hết thời gian và không chiếm điều khiển; death lý do/n−1/lặp signal/khóa Player/không pause/khôi phục checkpoint; khóa 3–4 vòng, sai/đúng/timeout đóng, lăn chuột, Esc, hint thiếu/có, từ chối modal khác và dọn khi node bị gỡ.

### Yêu cầu thay đổi ngoài phạm vi

1. **Integrator:** instance SurvivorNotice, DeathScreen và PuzzlePanel vào `game/scenes/main/chapter1.tscn`, giữ Notebook hiện có; dùng tên/path nêu trên. Core tiếp tục sở hữu reload sau 5 giây và count thật. Không thêm một luồng reload UI khác.
2. **Lane C/integrator:** cập nhật `tools/ch1-profile.json` → `bindings.death_ui_path = "DeathScreen/Root"` sau khi gắn scene, rồi chạy lại bot chương 1 với UI thật.
3. **Integrator:** loại `ui/chapter_previews/*`, `ui/chapter_panels_test*`, `scripts/ui/chapter_panels_test.gd*` khỏi export bản phát hành; không sửa `export_presets.cfg` trong nhánh Lane D.
4. **Câu hỏi dữ liệu cho integrator:** nếu cần nhóm Vòng 1 riêng thay vì các dòng Tổng tắc hiện có, cung cấp entry/key R1 hoặc source `round_1` đã duyệt. Nếu có quy tắc Tổng tắc phải giữ hiệu lực qua các vòng, cần metadata hiệu lực rõ ràng từ core; UI hiện áp dụng nguyên tắc quy tắc mới thay quy tắc cũ của card/STORY, không tự đặt ngoại lệ.

### Phần chưa thử / chặn

- Chưa chạy bot/chơi xuyên chương sau khi gắn ba scene mới vì main và profile nằm ngoài phạm vi. Chưa nghiệm thu bằng tai mức âm của tiếng khóa; đã kiểm tra đường phát clip qua test, dùng asset có sẵn. Chưa export/package bản phát hành.
- Không bị chặn phần Lane D. Cả ba mục checklist đạt; các yêu cầu tích hợp trên cần lane sở hữu thực hiện. Không đổi luật, câu chữ kịch bản hoặc cấu trúc dữ liệu ngoài phạm vi.
