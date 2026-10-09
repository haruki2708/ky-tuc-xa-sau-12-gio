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
**Claude Code web làm thay core (D-072).** Nhánh `core/T-204-ch2-tell-friends-loop` (dùng nhánh có sẵn, không tạo từ `main`).

**Đã làm**
- `chapter2_director.gd`: thêm `R3_TELL_LOOP_RUN := 2`, `R3_LOOP_PASS := 4`, `_tell_done` (reset trong `_reset_chain`, nên mỗi lượt chơi vòng 3 chỉ hỏi một lần) và `_tell_friends()`. `_chain` gọi nó ngay sau lượt gõ được chấp nhận làm `_loop_run` đạt 2: lúc đó chưa mở lượt gõ nào nên chuỗi và đồng hồ 15 giây dừng tới khi chọn xong. Thứ tự: chờ hàng đợi `_story` rảnh; nếu `_loop_known` false thì phát `n_loop`, `ngu_loop`; rồi `n_how`, `ngu_how`; `_choice(&"tell", 4, 10.0, -1)`. Câu 1 (chỉ số 0): `n_told`, `ngu_told`, chơi tiếp. Câu 2–4 hoặc hết giờ: `n_caught`, `chat_member_changed(minh_nhat|ngu, dead)` (kèm tiếng hét như chỗ khác), `_die(&"DEATH_CH2_LOST_FRIENDS")`, làm lại vòng 3 từ `ch2_r3`. Thêm `DEATH_CH2_LOST_FRIENDS: none` vào `CH2_DEATH_KINDS`.
- Vòng 3 kết thúc khi `_loop_run >= 4` (bỏ ngưỡng 8). Nếu lựa chọn đã phát `n_loop`/`ngu_loop` thì lượt 13 không phát lại hai câu đó.
- Bot: `ch2_bot.gd` trả lời lựa chọn `tell` bằng câu 1 qua op `choice`, `ch2_good` chỉ PASS khi đã nhắn đúng; `ch2_actions.gd` coi vòng lặp xong ở từ thứ 4 (`LOOP_PASS`). `ch2_policy.gd`, `tools/ch2-profile.json`, F9 (`ch2_menu.gd`/`qa_menu.gd`) không có chỗ nào nhắc "8 từ" nên không sửa.
- Test: file mới `game/tests/core/test_ch2_tell_friends.gd` (9 test, trên `chapter2.tscn`): hiện lựa chọn `tell` với 4 key và chuỗi dừng trong lúc chờ; câu 1 chơi tiếp và sang `r4` ở từ lặp thứ 4; câu 2, 3, 4 và hết giờ chết `DEATH_CH2_LOST_FRIENDS` và về `ch2_r3`; mới bịt 2 xác thì không hiện lựa chọn; từ lặp chỉ tính khi bịt đủ ba; hỏi một lần. Đã thử phá (tắt bước nhắn): 6/9 test FAIL như mong đợi. `test_chapter2.gd::test_gagged_corpses_and_the_loop_end_round_3_early` được sửa để chọn câu 1. `game/tests/tools/test_ch2_tools.gd` (loop 8 từ → 4 từ) sửa cho khớp bot; file này ngoài danh sách được phép sửa nhưng bắt buộc để không làm hỏng test, mời integrator xem lại.
- Tài liệu: `docs/playtest/CH2_WALKTHROUGH.md` (vượt nhanh và mục N5).

**Giơ điện thoại:** không cần giơ tay. `phone_screen.gd` (`_on_choice`) tự phát `phone_raised(true)` khi có `chat_choice_requested`, nên phím 1–4 dùng được ngay; test xác nhận có `phone_raised(true)`.

**Hai lượt test** (chạy trực tiếp bằng Godot Linux, userdata cô lập qua `XDG_DATA_HOME` + `QA_EXPECTED_USER_ROOT` vì `tools/test.ps1` lỗi trên Linux):
- Trước khi sửa (commit 13b5d68): **702 passed, 2 failed**: `test_audio.gd::test_all_ogg_load_and_decode_with_correct_loop_flags` (lỗi đã biết, chờ T-205) và `test_room407_fixes.gd::test_navigation_reaches_balcony_and_bathroom_without_crossing_solids` (môi trường Linux, thuộc điều hướng, không liên quan).
- Sau khi sửa: **712 passed, 1 failed**: chỉ còn `test_audio` (đã biết). Test nav ở trên PASS lần này, nên là test không ổn định chứ không phải do thay đổi này. Không FAIL mới. `tools/check.ps1` (pwsh Linux, `GODOT` đặt tay): **0 error**.

**Chưa kiểm chứng được** (không có card đồ họa/người chơi thật): cảm giác 10 giây chọn và hiển thị bảng chọn/điện thoại trên màn hình thật; giọng của 5 câu mới (chờ T-205, hiện phát bằng phụ đề và thời lượng ước lượng); bot `ch2_good` chạy đầy đủ (chưa chạy bot trên Linux, chỉ test đơn vị và test cảnh thật). Chưa test trên Windows.

**Câu hỏi / yêu cầu thay đổi ngoài phạm vi**
- `tools/README.md` (lane C), đoạn "Hành vi bot và menu", còn ghi "đủ vòng tám từ" và chưa nhắc bước chọn `tell`; mời lane C/integrator sửa.
- Chưa thêm case bot âm (chọn sai câu `tell`) vì ngoài yêu cầu; nếu cần thì lane C thêm vào `ch2_bot.gd`/profile.
- Thiết kế: nếu người chơi gõ một từ khác vòng lặp giữa chừng sau khi đã chọn đúng thì `_loop_run` về 0 và phải gõ lại 4 từ liên tiếp từ đầu (giữ nguyên luật cũ); không hỏi lại hai bạn. Nếu muốn khác thì chủ dự án quyết.


## Review (integrator)

### 2026-10-09 — Claude (integrator, Opus): **duyệt, đã merge**
- Đúng card: lựa chọn `tell` bật đúng một lần khi `_loop_run` đạt 2 (chỉ khi cả ba xác đã bị bịt), chuỗi dừng trong lúc chờ (chưa mở lượt gõ, đồng hồ 15 giây chưa chạy), câu 1 chơi tiếp, câu khác hoặc hết giờ thì hai bạn chết và về `ch2_r3`; qua vòng 3 ở từ lặp thứ 4; `n_loop` không phát lại nếu đã phát sớm. Điện thoại tự giơ khi có lựa chọn (`phone_screen._on_choice`), nên phím 1–4 dùng được ngay. 9 test trên cảnh thật, có thử phá (6/9 FAIL khi tắt bước nhắn).
- **Ngoài phạm vi, chấp nhận:** `game/tests/tools/test_ch2_tools.gd` (lane C) đổi vòng lặp 8 → 4 từ cho khớp bot; cần thiết để bộ test không hỏng.
- **Còn để ngỏ (lane C, khi chạy lại bot chương 2):** `tools/README.md` mục "Hành vi bot và menu" còn ghi "đủ vòng tám từ"; chưa có case bot chọn sai câu `tell`.
- Câu hỏi thiết kế của phiên web (gõ lệch vòng lặp giữa chừng thì đếm lại 4 từ, không hỏi lại hai bạn): giữ như vậy, đúng luật cũ.
