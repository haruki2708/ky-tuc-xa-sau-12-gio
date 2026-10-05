# T-180 — Chương 2: bot gõ từ và nhắn dự đoán
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-180-ch2-bot-typing`
- Phụ thuộc: T-173. **Đọc D-049, D-050, D-051 trong `docs/DECISIONS.md`**, `docs/tasks/T-176-ch2-feedback-core.md` (Handoff). Bản thật cần T-177 (A), T-179 (D) đã ghép; phần bot làm được ngay trên `main`.
- **Hạn đề xuất:** khung hết ngày 2026-10-07; chạy trên bản ghép sau khi integrator ghép A, D, E.

## Mục tiêu
Vòng 3 bỏ 4 phương án: người chơi gõ từ; core chấm trên từ điển khoảng 31 nghìn từ. Vòng 4 bỏ đoạn chọn câu cứu Ngư: thay bằng nhắn dự đoán cho Minh Nhật và Ngư (một lần, sau 3 lượt tắm an toàn liên tiếp, muộn nhất 7:40). Bot và menu thử nhanh phải theo luật mới.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Hợp đồng có sẵn (core, không sửa). Đọc chú thích trong `event_bus.gd`
- **Vòng 3:**
  - `chain_input_requested(seconds)` → bot phát `chain_word_typed(text)` → core phát `chain_input_closed(result)`;
  - `chain_word_spoken(speaker, word_key)`: key `WORD_CH2_*` **hoặc chính chữ**;
  - **bỏ** `chain_choice_requested` và `chain_choice_made`.
- **Vòng 4:** `prediction_requested(member, history, seconds)` → bot phát `prediction_sent(member, text)` → core phát `prediction_result(member, correct)`.
- **Lớp core dùng được:**
  - `VietText.canon_word(text)`, `VietText.canon_syllable(s)`;
  - `Ch2Dictionary.shared()`: `has(canon)`, `spelling`, `by_first`, `corpse_by_first`;
  - director: `is_valid_word(text)`, `suggest_word()` (khi đã bịt đủ 3 xác thì đi về vòng lặp), `suggest_dead_end()` (từ làm xác bí), `Chapter2Director.is_right_prediction(text, next)`.
  - Nên để policy của bot tự tính từ `Ch2Dictionary`, chỉ dùng hàm của director để đối chiếu.
- **Dữ liệu:** `data/ch2/shower.json` mục `predict` (`minh_nhat`, `ngu`: `history`, `next`), `predict_streak`, `predict_latest_slot`, `predict_seconds`; bỏ `ngu_history`, `ngu_next`, `ngu_slot`. `word_bank.json` bỏ `traps` và `options`.
- **Lý do chết mới:** `DEATH_CH2_LOST_NHAT`.

## Yêu cầu
1. **Bot vòng 3:**
   - gõ từ hợp lệ trong 15 giây;
   - gài bẫy bằng từ làm xác bí ít nhất một lần;
   - bịt 3 xác rồi đi trọn vòng lặp 8 từ;
   - `ch2_chain_wrong` gõ một từ sai (sai dấu, ví dụ "vỡ nát" sau "sách vở");
   - `ch2_chain_timeout` không gõ.
2. **Bot vòng 4:**
   - tắm theo quy luật;
   - khi có `prediction_requested`, tính lượt tới từ `history` (quy luật trong `CH2_DESIGN.md` N9) và gõ "có"/"không" (thỉnh thoảng "3x");
   - kịch bản `ch2_lost_ngu` đổi thành **`ch2_wrong_prediction`**: nhắn sai cho Ngư, chờ `DEATH_CH2_LOST_NGU`, nạp lại `ch2_r4`.
3. Kịch bản `ch2_good` yêu cầu thêm: đã nhắn đúng cho cả hai người.
4. `tools/ch2-profile.json`: bỏ `ngu_choice_id`, `ngu_temperatures`, `ngu_yes_index`, `ngu_no_index`; lexicon cũ không còn đủ (từ điển lớn).
5. **Menu F9 (`ch2_menu`):** kiểm tra nhảy vòng 3 và vòng 4 vẫn chạy. Ghi kết quả vào Handoff; STATUS ghi là chưa kiểm tra.
6. **Test** (`game/tests/tools/`): policy gõ từ (hợp lệ, từ làm xác bí, vòng lặp), policy dự đoán (đúng và sai), kịch bản mới có trong danh sách.
7. **Không chạy bot thật cả chương** (rất tốn RAM, 15–20 phút mỗi kịch bản). Integrator chạy sau khi chủ dự án đồng ý. Chỉ chạy test headless.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: lệnh chạy từng kịch bản, kết quả F9

## Handoff (agent điền)
