# T-204 — Chương 2: nhắn cho hai bạn cách qua vòng 3, qua màn ở từ lặp thứ 4 (core)
- Lane: core, **Claude Code trên web (Sonnet 5.5) làm thay** (D-072) | Trạng thái: review | Agent: Claude Code web (Sonnet 5.5), làm thay core (D-072)
- Nhánh: `core/T-204-ch2-tell-friends-loop`
- Phụ thuộc: D-072. **Lời thoại đã có sẵn trên nhánh này** (commit đầu của `core/T-204-ch2-tell-friends-loop`, integrator viết): `strings.csv`, `game/data/messages/`, sinh từ `docs/design/ch2/build_ch2_script.py`; xem `docs/design/CH2_SCRIPT.md` mục 06:40. Không tạo nhánh mới từ `main`: dùng nhánh có sẵn. Trên nhánh này `test_audio.gd::test_all_ogg_load_and_decode_with_correct_loop_flags` FAIL cho tới khi lane E thêm 5 giọng (T-205); đó là lỗi đã biết, ghi vào Handoff, không sửa test. Giọng các câu mới do lane E thu ở T-205, làm song song; core phát giọng theo tên key nên không phải chờ.
- **Hạn đề xuất:** 2026-10-10.

## Bối cảnh
- Vòng 3 nằm ở `game/scripts/core/chapter2_director.gd` (`_round_3`, `_chain`, `_trung_turn`, `_loop_run`, `_all_gagged`, `R3_BEATS`). Hiện nay: khi cả ba xác đã bị bịt, mỗi từ Trung gõ thuộc vòng lặp làm `_loop_run` tăng 1 (gõ từ khác thì về 0); `_loop_run` đạt **8** (một vòng đủ) thì vòng 3 kết thúc sớm và nhảy tới 7:00 (D-040).
- `Chapter1Director._choice(id, count, seconds, timeout_index)` dựng key `CHOICE_CH2_<ID>_<n>`, dùng như đoạn cứu Minh Nhật ở chương 1 (`_choice(&"tell", 4, TELL_SECONDS, -1)`).

## Việc
1. **Nhắn cho hai bạn:** lần đầu `_loop_run` đạt **2** (cả ba xác đã bị bịt, 2 từ liên tiếp của vòng lặp):
   - nếu Minh Nhật chưa đọc vòng lặp (`_loop_known` false, người chơi biết trước từ hướng dẫn) thì phát `n_loop`, `ngu_loop` trước;
   - phát `n_how`, `ngu_how`; rồi `_choice(&"tell", 4, 10.0, -1)`. **Đúng là câu 1** (chỉ số 0);
   - đúng: `n_told`, `ngu_told`, chơi tiếp;
   - sai hoặc hết giờ: `n_caught`, hai thành viên `minh_nhat`, `ngu` chết trong cuộc gọi (`chat_member_changed(..., &"dead")` như chỗ khác), rồi `_die(&"DEATH_CH2_LOST_FRIENDS")`, làm lại từ đầu vòng 3 (checkpoint hiện có). Thêm `&"DEATH_CH2_LOST_FRIENDS": &"none"` vào `CH2_DEATH_KINDS`.
   - Trong lúc chờ chọn, **chuỗi nối từ dừng**: lượt gõ của Trung chưa mở và đồng hồ 15 giây chưa chạy cho tới khi chọn xong. Xác đã bị bịt nên chỉ ú ớ.
   - Kiểm người chơi **chọn được thật**: giao diện chọn câu của điện thoại (lane D) chỉ nhận phím 1–4 khi điện thoại đang giơ. Nếu đang hạ thì giơ lên giúp, hoặc ghi trong Handoff cách người chơi biết phải giơ.
2. **Qua màn ở từ thứ 4:** `_loop_run` đạt **4** (và đã chọn đúng ở mục 1) thì vòng 3 kết thúc ngay, nhảy tới 7:00 như cũ (loa `R3_END`…). Bỏ ngưỡng 8.
3. **Bot và menu F9:** cập nhật bot chương 2 (`game/scripts/debug/ch2_policy.gd`, `ch2_actions.gd` hoặc `tools/ch2-profile.json`, chỗ nào đang xử lý vòng lặp) để chọn câu 1 và qua màn ở từ thứ 4; câu đáp án F9 (`qa_menu.gd` / `ch2_menu.gd`) nếu có nói "8 từ".
4. **Test (`game/tests/core/`), trên cảnh thật `chapter2.tscn`:**
   - bịt cả ba, gõ 2 từ lặp: hiện lựa chọn `tell` với 4 key `CHOICE_CH2_TELL_1…4`, chuỗi dừng trong lúc chờ;
   - chọn câu 1: chơi tiếp; gõ thêm 2 từ lặp (tổng 4): vòng 3 kết thúc, sang `ch2_r4`;
   - chọn câu 2, 3, 4 hoặc hết 10 giây: chết `DEATH_CH2_LOST_FRIENDS`, làm lại vòng 3;
   - chưa bịt đủ ba xác thì gõ từ lặp không bật lựa chọn và không qua màn;
   - lựa chọn chỉ xuất hiện một lần trong một lượt chơi vòng 3;
   - bộ test chương 2–4 hiện có vẫn PASS.
5. **Tài liệu:** `docs/playtest/CH2_WALKTHROUGH.md` (vượt nhanh vòng 3 và mục chi tiết): sau 2 từ lặp chọn câu 1, gõ thêm 2 từ là qua.

## Được phép sửa (ngoại lệ D-072 cho phiên web)
`game/scripts/core/`, `game/scenes/main/`, `game/tests/core/`, `game/scripts/debug/` (phần chương 2 và `qa_menu.gd`), `tools/ch2-profile.json`, `docs/playtest/CH2_WALKTHROUGH.md`, card này (Handoff). **Không** sửa `strings.csv`, `game/data/messages/` (lời do integrator viết), file của lane A, B, D, E. Cần gì ngoài phạm vi thì ghi "Yêu cầu thay đổi".

## Checklist hoàn thành
- [x] Lựa chọn nhắn sau 2 từ lặp, chuỗi dừng khi chờ, đúng/sai/hết giờ
- [x] Qua màn ở từ lặp thứ 4
- [x] Bot và F9 khớp (F9 không nhắc "8 từ" nên không phải sửa; xem ghi chú)
- [x] Test trên cảnh thật; chương 2–4 không hỏng
- [ ] Test hai lượt (trước và sau); `tools/check.ps1` PASS
- [x] Hướng dẫn `CH2_WALKTHROUGH.md` cập nhật

## Handoff (agent điền)

## Review (integrator)
