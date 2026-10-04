# T-150 — Chương 1 "Đếm thừa": hợp đồng chung, luồng chương, dữ liệu, ghép
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: thiết kế `docs/design/STORY.md` (D-029…D-033)
- Hạn chương 1: chơi thử được ngày **2026-10-07**, muộn nhất 2026-10-08.

## Mục tiêu
Lõi cho chương 1 và các chương sau: hợp đồng chung giữa các lane, luồng chương, lưu tiến độ, dữ liệu của đêm 1 (nội quy, giấy tờ, tin nhắn, câu đố), rồi ghép việc của 5 lane thành một đêm chơi trọn khoảng 50 phút.

## Phần 1 — Hợp đồng chung (đã xong, `5f31722`)
- **Phím mới** (`game_input.gd`): `crouch` (C, Ctrl), `phone` (Q), `flashlight` (F), `hold_breath` (Space).
- **Signal mới** (`event_bus.gd`): `chapter_started`, `chapter_finished`, `noise_emitted`, `player_hidden`, `breath_held`, `phone_raised`, `flashlight_toggled`, `phone_battery_changed`, `phone_message_received`, `puzzle_opened`, `puzzle_closed`, `puzzle_solved`, `entity_state_changed`, `watcher_active`, `player_caught`, `rule_evidence_changed`. Ý nghĩa từng signal ghi ngay trong code.
- **`Progress`** (`scripts/core/progress.gd`, file `user://progress.json`): `unlocked_chapter()`, `unlock(n)`, `set_fact/get_fact` cho dữ kiện sống qua nhiều đêm (ví dụ `replaced_roommate`).
- **`GameState.chapter`**: lưu trong checkpoint. **`App.start_chapter(n)`**: chọn đêm ở màn hình chính.
- **`MessageData`** (`data/messages/<id>.tres`): tin nhắn điện thoại. **`PuzzleData`** (`data/puzzles/<id>.tres`): câu đố. Đã có `locker_combo_601` (mã 304) và `fuse_box_6` (5 cầu dao, đáp án `10010`).
- **`RuleSystem.set_evidence(rule_id, document_id, pinned)`, `evidence_for(rule_id)`**: gắn chứng cứ vào dòng nghi ngờ; lưu trong checkpoint.

## Phần 2 — Dữ liệu đêm 1 (integrator)
- Bộ luật `data/rules/ch1.tres` theo `STORY.md` §10: 6 điều thật, 3 dòng giả (điều 2 bỏ vế xưng tên, điều 4 tin nhắn "Phúc", điều 5 dấu "nhà 8"), cộng bản giả năm 2015 của điều 3.
- Giấy tờ mới: thông báo dấu giả tầng 5, giấy cũ 2015 tầng 6, lịch cũ `calendar_601`, sơ đồ cầu dao `fuse_diagram_6`, mẫu dấu trong sổ trực, ảnh phòng 407 năm 2009.
- Tin nhắn ban ngày và trong đêm (mẹ, nhóm lớp, Phúc, số lạ).
- Câu loa chương 1 (văn bản cho T-159).

## Phần 3 — Luồng chương và ghép
- Tách `story_director.gd` thành luồng theo chương; chương 1 dùng lại đoạn 1–5 của demo, chèn đoạn việc vặt tầng 5–6 và truy đuổi cầu thang.
- Main ghép tầng 4, cầu thang, tầng 5, 6 (T-153), đặt chỗ nấp, trạm câu đố, giấy tờ theo anchor của lane B.
- Phản ứng của thế giới: đèn chập chờn quanh Người đi dép, bị bắt thì màn hù rồi tải checkpoint, nấp trong mùng bị "đếm" thì cộng "lệch".
- Ghi `Progress.set_fact(&"replaced_roommate", …)` theo người được trả lời hộ (D-032); `Progress.unlock(2)` khi xong đêm.

## Checklist
- [x] Phần 1: hợp đồng chung, test PASS (258/258)
- [ ] Phần 2: dữ liệu đêm 1, `RuleSet.validate()` sạch
- [ ] Phần 3: ghép T-151…T-159, chơi trọn chương 1
- [ ] Bot T-157 chạy 3 kịch bản PASS
- [ ] Bản build cho chủ dự án chơi thử

## Handoff
