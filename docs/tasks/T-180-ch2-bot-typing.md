# T-180 — Chương 2: bot gõ từ và nhắn dự đoán
- Lane: C (QA và Tools) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Handoff: lệnh chạy từng kịch bản, kết quả F9

## Handoff (agent điền)

### Phiên 2026-10-06 — hoàn tất phạm vi T-180
- Base `origin/main`: `e09451b`; commit triển khai `c85dd77`, đã push `lane-c/T-180-ch2-bot-typing` trước khi ghi Handoff.
- Bot vòng 3 chuyển sang `chain_input_requested` → `chain_word_typed` → `chain_input_closed`. Không còn dùng hai signal chọn phương án cũ. Nhận cả key `WORD_CH2_*` lẫn chữ trực tiếp; policy tự chọn chữ bằng `Ch2Dictionary`, so dấu/lịch sử bằng `VietText`. Dùng `director.is_valid_word()` chỉ để đối chiếu, không lấy đáp án từ suggest của director.
- Tính đường về vòng lặp bằng chỉ mục ngược của từ điển, tránh quét đệ quy kho 31 nghìn từ. Gài từ xác không biết nối; chỉ ghi nhận bẫy khi core nhận chữ và xác chưa bịt ngã. Chỉ ghi nhận vòng tám từ qua chữ Trung thật sự được core phát ra, không coi gửi input là hoàn thành.
- Bot vòng 4 trả dự đoán từ ba nhiệt độ nhận qua signal; Minh Nhật nhận dạng khoảng hàng chục, Ngư nhận có/không. Good cần kết quả đúng được core xác nhận cho cả hai. Đổi case thành `ch2_wrong_prediction`, chỉ nhắn sai cho Ngư, kỳ vọng `DEATH_CH2_LOST_NGU` và reload `ch2_r4`. Đồng bộ các lý do chết còn lại sang tiền tố `DEATH_CH2_` thực tế.
- Bỏ lexicon nhỏ và bốn binding Ngư cũ khỏi profile; giữ các binding vật lý do integrator đã ghép. Menu dùng observer nhập chữ và có đáp án dự đoán từ lịch sử đang nhận. README/launcher cập nhật kịch bản và giới hạn chạy.

### Kiểm tra đã chạy
| Lệnh | Kết quả | Log cục bộ |
|---|---|---|
| `pwsh tools/test.ps1 -Filter ch2_` | `RESULT: 45 passed, 0 failed` (exit 0; trước khi bổ sung test đối chiếu core/bẫy cuối cùng) | `build/T-180-focused.log` |
| `pwsh tools/test.ps1` | `RESULT: 483 passed, 0 failed` (exit 0; bản triển khai cuối, gồm 9 test ch2_tools và 1 test ch2_menu) | `build/T-180-tests.log` |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)` (exit 0) | `build/T-180-check.log` |

- **F9: PASS trong test headless** `test_f9_opens_closes_and_jumps_to_real_rounds`: gọi handler với InputEventKey F9, kiểm tra mở/đóng và pause; nhảy r3 rồi r4 bằng scene chương 2 thật, scene mới/chapter/segment đúng, đáp án lấy từ observer mới. Userdata tách riêng bởi test runner. Không chạy `qa-menu.ps1 -Smoke` dùng renderer trong phiên này.
- Phạm vi bằng chứng F9 là handler và scene jump tự động; **chưa test bấm bàn phím thực tế, hình ảnh render hoặc bộ gõ Unikey/EVKey**. Không suy kết quả test headless thành trải nghiệm nhập chữ của bản ghép T-179.
- Test đầu phát hiện dùng nhầm dạng canon nội bộ như chữ; đã sửa, các lần PASS ở trên là sau sửa. Không có lỗi test còn tồn đọng.

### Lệnh từng kịch bản cho integrator — chưa chạy trong phiên này
Chỉ chạy sau khi ghép T-177/T-179/T-178 và chủ dự án đồng ý, theo mục 7 của card (15–20 phút mỗi case, tốn RAM):

```powershell
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_good -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_chain_timeout -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_chain_wrong -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_scald -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_leave_shower -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_wrong_prediction -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 2 -Performance -RequireComplete
```

- **Chưa chạy bot thật cả chương, chưa đo FPS**, không có report end-to-end mới. Các report T-173 cũ vẫn là bằng chứng lịch sử, không phải kết quả T-180. `performance` trong profile vẫn chưa có binding thật.

### Yêu cầu thay đổi ngoài phạm vi / chặn
- Không có yêu cầu sửa core/UI mới để hoàn thành T-180; không sửa file ngoài phạm vi hoặc STATUS. Integrator tiếp tục ghép A/D/E, bỏ hai signal cũ khỏi EventBus theo kế hoạch T-176 và kiểm thử bản ghép sau khi được chủ dự án đồng ý.
- **Không bị chặn trong phạm vi khung + test headless.** Xác nhận bot end-to-end, FPS và bộ gõ hệ điều hành vẫn là phần việc sau tích hợp, chưa đạt/chưa kiểm tra trong phiên này theo giới hạn card.
- Git fetch/checkout ban đầu bị sandbox chặn mạng/LFS; đã phục hồi và chuyển nhánh thành công. Trạng thái checkout dở được giữ an toàn trong stash cục bộ có nhãn `T-180 recovery: partial checkout after sandbox LFS failure`; không áp lại vào nhánh task. Repo sạch trước lần checkout lỗi, không có chỉnh sửa người dùng bị bỏ.

### Review (integrator, 2026-10-06)
- **Đạt, đã merge** (`c73ca3a`). Policy tự tính từ `Ch2Dictionary`, chỉ đối chiếu với `director.is_valid_word`; bẫy và vòng lặp chỉ ghi nhận khi core xác nhận; `ch2_wrong_prediction` thay `ch2_lost_ngu`; F9 có test headless.
- Bot phát signal trực tiếp, không đi qua ô gõ của lane D; đường ô gõ thật được test ghép `test_ch2_typing_flow.gd` của integrator phủ.
- **Chưa chạy bot thật** (6 kịch bản, 15–20 phút mỗi kịch bản): chờ chủ dự án đồng ý.
