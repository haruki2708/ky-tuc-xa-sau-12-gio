# Hệ thống luật (T-110)

Tài liệu cho các lane dùng lõi luật chơi, và cho buổi chốt bộ luật ở T-113. Code nằm trong `game/scripts/core/`, do integrator sở hữu.

## Ý tưởng
Mỗi **tình huống** (`situation`), ví dụ "có người gõ cửa", có thể được nhiều **dòng nội quy** (`RuleData`) chi phối:
- **một dòng thật** (`is_fake = false`),
- **các dòng bị sửa** (`is_fake = true`), in ở nguồn khác, bảo người chơi làm việc khác.

Người chơi chọn một **hành động** (`action`). `RuleSystem.resolve(situation, action)` phán định:

| Người chơi làm | Kết quả (`outcome`) | Hậu quả |
|---|---|---|
| Đúng như dòng thật | `correct` | Không có |
| Đúng như một dòng giả | `followed_fake` | `penalty` và `consequence` của **dòng giả đó** |
| Việc khác, trong khi có dòng thật | `broke_rule` | `penalty` và `consequence` của **dòng thật** |
| Không dòng nào chi phối | `unruled` | Không có |
| Chỉ có dòng giả và người chơi không làm theo | `correct` | Không có |

Khi sai:
- `GameState.add_deviation(penalty)`: mức "lệch" tăng, tối đa `GameState.MAX_DEVIATION` = 5.
- `EventBus.consequence_triggered(consequence, rule_id)`: các lane khác thực hiện thay đổi môi trường (tắt đèn một đoạn, đổi số phòng, thêm tên vào danh sách điểm danh…).
- Nếu dòng đó có `fatal = true`: `EventBus.player_failed(rule_id)`. Luồng game (T-117) tải lại checkpoint.

Cờ `is_fake` là **bí mật**. UI và sổ tay không bao giờ hiển thị nó.

## Dữ liệu một dòng (`RuleData`)
| Trường | Ví dụ | Ý nghĩa |
|---|---|---|
| `id` | `&"knock_paper"` | Duy nhất |
| `text_key` | `"RULE_KNOCK_PAPER"` | Key trong `strings.csv`, tiền tố `RULE_`, đủ `vi` và `en` |
| `is_fake` | `true` | Dòng bị sửa |
| `source` | `&"room_paper"` | Nơi in hoặc đọc: `speaker`, `hall_board`, `room_paper`, `duty_log`… |
| `situation` | `&"knock_at_door"` | Tình huống dòng này chi phối |
| `action` | `&"open_door"` | Việc dòng này bảo người chơi làm |
| `penalty` | `3` | Mức "lệch" cộng thêm khi dòng này gây ra sai lầm |
| `consequence` | `&"room_number_swap"` | Thay đổi môi trường; để trống nếu không có |
| `fatal` | `false` | Thua thật, phải tải lại checkpoint |

Bộ luật của một đêm là một `RuleSet` (`rules: Array[RuleData]`), lưu thành file `.tres` trong `game/data/rules/` (tạo ở T-113). `RuleSet.validate()` bắt các lỗi:
- trùng `id`,
- `text_key` sai tiền tố hoặc thiếu bản dịch,
- thiếu `situation` hoặc `action`,
- hai dòng thật cho cùng một tình huống,
- dòng giả có hành động trùng với dòng thật (dòng giả kiểu đó vô nghĩa).

## Dùng từ các lane
| Việc | Gọi |
|---|---|
| Nạp bộ luật (luồng game, T-117) | `RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))`; danh sách lỗi trả về phải rỗng |
| Người chơi thấy một dòng ở một nguồn | `RuleSystem.mark_read(rule_id, source, text_key)`; `source` mặc định là nguồn của dòng, `text_key` mặc định là chữ của dòng. Loa đọc điều 3 bị rè: `mark_read(&"slippers_genuine", &"speaker", "RULE_3_GARBLED")` |
| Sổ tay (T-111) | `RuleSystem.read_entries()`: mỗi phần tử `{rule_id, source, text_key}` theo thứ tự thấy. Cùng dòng, cùng nguồn chỉ một mục; thấy lại với chữ khác thì cập nhật chữ. Nghe `EventBus.rule_entry_added` để vẽ lại |
| Giấy tờ (T-129, T-111) | `DocumentData.load_by_id(id)`; `mark_rules_read()` ghi mọi dòng của tờ vào sổ tay với nguồn của tờ. Mở hoặc đóng: `EventBus.document_opened(id)`, `document_closed(id)` |
| Đánh dấu nghi ngờ | `RuleSystem.set_suspected(id, bool)`, `is_suspected(id)` |
| Đồ vật hoặc sự kiện cần phán định | `RuleSystem.resolve(situation, action)` trả `{outcome, rule_id, consequence, fatal}` |
| Giờ trong game | `GameState.set_time(phút)`, `advance_minutes(n)`, `clock_text()` ("00:30"). Mặc định giờ chỉ chạy theo cốt truyện; `minutes_per_second > 0` để chạy theo thời gian thực |
| Đoạn chơi | `GameState.set_segment(&"roll_call")` |
| Cờ cốt truyện | `GameState.set_flag(&"door_locked", true)`; chỉ nhận bool, int, float, String |
| Lưu và tải | `Checkpoint.save(&"before_roll_call")`, `Checkpoint.restore()` |

Mọi thay đổi đều được báo qua `EventBus`: `time_changed`, `segment_changed`, `deviation_changed`, `flag_changed`, `rule_read`, `rule_suspicion_changed`, `rule_resolved`, `consequence_triggered`, `player_failed`, `checkpoint_saved`, `checkpoint_loaded`. Lane nào cần thì nghe signal tương ứng, không gọi chéo vào code của lane khác.

## Giấy tờ (`DocumentData`)
File `game/data/documents/<id>.tres`:

| Trường | Ý nghĩa |
|---|---|
| `id` | Trùng tên file |
| `title_key` | Key tiêu đề, có thể để trống (giấy viết tay) |
| `style` | `stamped` (đánh máy, dấu đỏ), `photocopy`, `handwritten`, `notice` (giấy dán tường), `log` (sổ trực) |
| `source` | Nguồn ghi vào sổ tay |
| `rule_ids` | Các dòng luật theo thứ tự in, đánh số 1..n |
| `text_keys` | Đoạn văn thường sau các dòng luật (sổ trực, chữ ký…) |

Đã có: `room_paper_407` (photo sau cửa, có điều 3 giả), `hall_board` (bảng có dấu, 5 điều thật), `hall_board_note` (giấy viết tay, điều 4 giả), `washroom_notice` (6 điều, có điều 6 giả). Sổ trực (`duty_log`) làm ở đoạn 3.

Điều 4 thật có 3 dòng dữ liệu cùng chữ (tên mình, tên bạn cùng phòng, tên lạ). Giấy tờ chỉ in dòng `rollcall_self_genuine`.

## Checkpoint
- File `user://checkpoint.json`, có trường `version`. Lưu giờ, đoạn chơi, mức "lệch", cờ, các dòng đã đọc, đã nghi ngờ, và kết quả từng tình huống.
- **Không lưu vị trí người chơi.** `checkpoint_id` là tên điểm hồi sinh; scene nghe `checkpoint_loaded(id)` và đặt người chơi vào marker cùng tên.
- Bộ luật không nằm trong file lưu. Khi tải, nạp `RuleSet` trước rồi mới `Checkpoint.restore()`.

## Cần chốt ở T-113
Để điền dữ liệu, mỗi luật của demo cần:
1. tình huống,
2. câu chữ dòng thật và dòng giả (vi và en),
3. dòng nào in ở đâu,
4. hành động đúng và hành động sai,
5. mức "lệch",
6. hậu quả nhìn thấy được,
7. có phải luật gây thua thật không.

Cũng cần chốt ý nghĩa của từng mức "lệch" (0–5): ở mỗi mức, ký túc xá thay đổi thế nào.
