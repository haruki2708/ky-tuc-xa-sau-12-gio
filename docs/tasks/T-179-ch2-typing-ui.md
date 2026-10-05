# T-179 — Chương 2: ô gõ từ nối, ô nhắn dự đoán, credits từ điển
- Lane: D (UI) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-179-ch2-typing-ui`
- Phụ thuộc: T-174. **Đọc D-049, D-050, D-051 trong `docs/DECISIONS.md`** và `docs/design/CH2_SCRIPT.md` (đã sửa).
- **Hạn đề xuất: hết ngày 2026-10-07.**

## Mục tiêu
Chủ dự án chơi thử chương 2 và quyết định:
- vòng 3 **bỏ 4 phương án**: người chơi **gõ từ bằng bàn phím**, dấu do **bộ gõ của máy** (Unikey, EVKey, bàn phím tiếng Việt của Windows) tạo, game không tự chuyển Telex;
- vòng 4 có **nhắn dự đoán**: Minh Nhật rồi Ngư gửi 3 nhiệt độ gần nhất, người chơi gõ câu trả lời trong điện thoại;
- từ điển lấy từ Wiktionary (CC BY-SA), **phải ghi công trong màn Credits**.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `strings.csv`

## Hợp đồng có sẵn (core, không sửa). Đọc chú thích trong `event_bus.gd`
- **Vòng 3:**
  - `chain_input_requested(seconds)`: lượt của Trung bắt đầu (sau `chain_turn_started(&"trung", …)`);
  - lane D phát `chain_word_typed(text)` khi người chơi gửi. Gửi **đúng chữ đã gõ**, không tự sửa; core chuẩn hóa và chấm;
  - `chain_input_closed(result)`: `&"accepted"`, `&"wrong"`, `&"timeout"`. Đóng ô nhập. Không hiện đúng hay sai (Insane); `wrong` và `timeout` đã có cảnh chết;
  - `chain_choice_blocked(blocked)`: giữ như cũ. Khi bị chặn vẫn cho gõ, nhưng hiện "Họ không nghe thấy bạn" và **không gửi**;
  - `chain_word_spoken(speaker, word_key)`: `word_key` có thể là key `WORD_CH2_*` **hoặc chính chữ** (ví dụ `"khuất bóng"`). `tr()` hiện được cả hai.
  - `chain_choice_requested` và `chain_choice_made`: **bỏ**, core không phát nữa. Xóa phần 4 phương án khỏi bảng.
- **Vòng 4:**
  - `prediction_requested(member, history, seconds)`: `member` là `&"minh_nhat"` hoặc `&"ngu"`, `history` là 3 nhiệt độ, `seconds` = 20;
  - lane D phát `prediction_sent(member, text)` khi gửi;
  - `prediction_result(member, correct)`: đóng ô, tin nhắn đã gửi ở lại trong lịch sử chat.
- **Mới, lane D phát:** `text_entry_changed(active)`: `true` khi một ô nhập nhận bàn phím, `false` khi trả lại. Lane A (T-177) dựa vào đây để nhân vật đứng yên khi gõ.

## Yêu cầu
1. **Bảng nối từ** (`ui/chain/chain_panel.tscn`):
   - giữ phần đầu: từ vừa nói, người nói, 3 từ gần nhất;
   - lượt của Trung: dòng hướng dẫn ngắn (ví dụ "Enter: gõ từ"), đồng hồ 15 giây, tích tắc 5 giây cuối như cũ;
   - **Enter mở ô gõ** (`LineEdit`): ô nhận bàn phím, phát `text_entry_changed(true)`. **Enter lần nữa gửi**: chữ rỗng thì không gửi. **Esc** đóng ô mà không gửi, không mở menu tạm dừng;
   - **bộ gõ của máy phải dùng được:** `LineEdit` để Godot bật IME; chữ có dấu hiện đúng; không lọc ký tự tiếng Việt;
   - ô đóng (`chain_input_closed`, hết giờ, chết, nạp checkpoint, hết vòng): phát `text_entry_changed(false)`;
   - không pause game; chuột vẫn nhìn được.
2. **Ô nhắn dự đoán** trong điện thoại (`phone_screen`):
   - khi có `prediction_requested`, điện thoại tự giơ lên (hoặc nhắc rõ phải giơ), mở ô nhập ở cuộc trò chuyện với người đó, đồng hồ 20 giây;
   - **không gợi ý** cách trả lời: không có nút "Có/Không", không ghi mẫu "3x";
   - Enter gửi: tin nhắn của Trung hiện trong chat; phát `prediction_sent`; quản lý `text_entry_changed` như mục 1.
3. **Credits** ở màn hình chính: thêm mục "Từ điển nối từ":
   - Wiktionary tiếng Việt và tiếng Anh, các tác giả Wiktionary;
   - trích bởi kaikki.org (wiktextract);
   - giấy phép CC BY-SA 4.0, đường dẫn giấy phép;
   - "đã chuyển thể: chỉ giữ từ hai tiếng".
   Nội dung đầy đủ ở `game/data/ch2/DICTIONARY_LICENSE.md`.
4. Tiếng Anh: từ nối vẫn là tiếng Việt; dòng hướng dẫn và nhãn thì dịch.
5. **Test và preview:**
   - mở và gửi bằng Enter, Esc hủy, chữ rỗng không gửi, bị chặn không gửi;
   - `text_entry_changed` bật và tắt đúng, kể cả khi hết giờ hoặc chết lúc đang gõ;
   - ô dự đoán gửi đúng `member`;
   - ảnh vi/en.
6. **Ghi vào Handoff:** đã thử gõ có dấu bằng bộ gõ nào chưa (Unikey/EVKey/Windows). Test headless không kiểm được IME; chưa thử thì ghi rõ "chưa thử".

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh preview vi/en
- [x] Handoff: scene, API, đường dẫn node (cho bot lane C)

## Handoff (agent điền)

### Đã làm — 2026-10-06

- Nhánh `lane-d/T-179-ch2-typing-ui`, tạo từ `origin/main` tại `e09451b`. Commit triển khai `971e491` đã push trước khi viết Handoff này. Chỉ thay đổi UI, test UI, thêm key CSV và card này; không sửa core, gameplay, dữ liệu hay luật chơi.
- Bảng nối từ bỏ bốn phương án và cả hai signal cũ. Giữ từ vừa nói, người nói, ba từ gần nhất, đồng hồ và tích tắc cuối lượt. Enter mở `LineEdit`, Enter gửi nguyên văn một lần; rỗng/toàn khoảng trắng không gửi và vẫn giữ focus. Esc hủy ô nhập, giữ lượt và nội dung nháp; Enter mở lại. Bị chặn vẫn gõ được, không gửi; đồng hồ vẫn chạy.
- `game_text_entry.gd` dùng LineEdit native, không chuyển Telex, không lọc dấu. Phát `text_entry_changed` theo focus; trả bàn phím khi gửi, hủy, hết giờ, core đóng lượt, chết, checkpoint, đổi chương hoặc node bị gỡ. Chặn phím UI pause/sổ tay/điện thoại chen vào lúc gõ. Không pause cây game hay đổi mouse mode; lane A nhận signal để đứng yên.
- Điện thoại tự giơ và chọn tab trò chuyện khi nhận dự đoán. Hiện tên người nhận, ba nhiệt độ do core gửi, đồng hồ 20 giây và ô gõ; không có đáp án mẫu/nút Có–Không. Enter gửi đúng `member` và nguyên văn chữ. Tin Trung được thêm vào lịch sử trước khi phát signal, vẫn còn sau result đúng/sai và JSON snapshot/restore. Text nhập được render literal, không dịch nhầm thành key hay diễn giải BBCode. Hai trường lịch sử tùy chọn `raw_text`, `recipient` giữ tương thích snapshot version 1 cũ.
- Khi Esc hủy ô dự đoán hoặc điện thoại bị hạ/che, trả bàn phím; yêu cầu vẫn chờ theo thời hạn, Enter mở lại. Khi hết giờ UI chỉ đóng ô, không tự gửi đáp án hay chấm kết quả.
- Thêm 8 key VI/EN, mục Credits Wiktionary tiếng Việt/Anh, tác giả, kaikki.org/wiktextract, CC BY-SA 4.0 và URL, mô tả chuyển thể. Từ nối dùng bản tiếng Việt cả khi UI là English; raw word ngoài kho vẫn hiển thị nguyên văn.

### Scene, API và node cho lane C

Các node Entry được dựng trong `_ready()`, chờ scene vào cây trước khi truy cập.

| Thành phần | Scene / đường dẫn tương đối từ root scene | API / signal |
|---|---|---|
| Nối từ | `res://ui/chain/chain_panel.tscn` → `Root/Card/Content/Entry` | `chain_input_requested(seconds)` mở lượt; Enter hoặc `open_entry()` mở ô; `is_choosing()` cho biết đang chờ gửi; `close_panel()` kết thúc vòng và xóa lịch sử |
| Nhãn nối từ | `Root/Card/Content/{Word,WordSpeaker,History,Status,Timer,Help}` | `chain_word_spoken` nhận key hoặc chữ; không còn `Options/Option1..4` |
| Dự đoán | `res://ui/phone/phone_screen.tscn` → `Root/Phone/Content/Prediction/Entry` | `prediction_requested(member, history, seconds)` tự mở; `phone.prediction.member`, `.remaining`, `.entry` cho QA; `open_entry()`, `cancel_entry()`, `close_request()` |
| Người nhận / lịch sử / đồng hồ | `Root/Phone/Content/Prediction/{Recipient,Countdown,Help}`; chat tại `Root/Phone/Content/Transcript` | `prediction_result` chỉ đóng yêu cầu khớp người nhận, không xóa tin đã gửi |
| Quyền nhập chữ | group `game_text_entry` | `text_entry_changed(true/false)` theo focus; group `chain_panel` vẫn giữ |

Bot nên mở bằng Enter, đưa Unicode vào LineEdit đang focus rồi Enter gửi để đi qua đường input thực. UI phát `chain_word_typed(text)` hoặc `prediction_sent(member, text)`; core duy nhất chuẩn hóa/chấm. UI không còn tham chiếu `chain_choice_requested` / `chain_choice_made`.

### Kiểm tra và bằng chứng

- Godot 4.7.2; `pwsh tools/test.ps1`: **`RESULT: 489 passed, 0 failed`**. `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**. Log local (ignored): `build/T-179/test.log`, `build/T-179/check.log`.
- Thêm 9 test trong `game/tests/ui/test_ch2_typing.gd`, 1 test Credits trong `test_title.gd`; thay test lựa chọn cũ bằng hành vi gõ. Có gửi bằng Enter thật qua viewport, rỗng/whitespace, Esc với hai thứ tự scene pause, chặn gửi, timeout/tick, vòng đời focus, Unicode, xung đột phím điện thoại, routing cả hai người nhận, lịch sử JSON và locale.
- Lượt test đầy đủ đầu tiên fail vì một dòng trống CSV (488 pass / 1 fail); đã bỏ dòng trống và chạy lại toàn bộ PASS như trên. Godot tự chuẩn hóa `default_bus_layout.tres` khi import; đã khôi phục file sinh ngoài phạm vi, không commit thay đổi âm thanh.
- 10 PNG VI/EN trong `game/ui/ch2_typing_previews/` kèm `.import`, Git LFS, mỗi file dưới 1,2 MB: `chain_player`, `chain_blocked`, `prediction_nhat`, `prediction_ngu`, `credits_end`. Đã xem ảnh đại diện cả hai ngôn ngữ, chữ và ô nhập không tràn; capture log không có ERROR. Nguồn, giấy phép và cách tạo lại ở `game/ui/ch2_typing_previews/CREDITS.md`.
- Preview dùng `res://ui/ch2_ui_preview.tscn -- --ch2-ui=<mode>_<vi|en>`; Credits dùng `res://ui/title/title_test.tscn -- --title-capture=credits_end` hoặc `credits_end_en`. Đây là fixture UI, không phải ảnh chơi trọn chương.

### Chưa thử / còn cần xác nhận

- **Unikey: chưa thử. EVKey: chưa thử. Bàn phím tiếng Việt Windows/IME: chưa thử.** Chỉ kiểm Unicode bằng input tổng hợp và render chữ có dấu; headless không chứng minh bộ gõ hệ điều hành hoạt động. Cần chủ dự án thử thực tế sau ghép, gồm đang tổ hợp dấu rồi Enter/Esc.
- Chưa chơi tay trọn chương 2, chưa chạy bot 15–20 phút, chưa export bản Windows và chưa xác nhận di chuyển khi gõ trên bản ghép T-177. Không ghi các mục đó là đã PASS.
- Không còn checklist của card chưa đạt. Không có câu hỏi thiết kế mới, không bị chặn trong phạm vi lane D.

### Yêu cầu thay đổi ngoài phạm vi

1. **Core / lane A / lane C:** ghép T-177 để khóa di chuyển/tương tác theo `text_entry_changed`, cập nhật bot T-180 sang hai Entry ở trên. Sau khi tất cả consumer cũ được chuyển, core xóa `chain_choice_requested` và `chain_choice_made` khỏi EventBus như kế hoạch STATUS; lane D đã bỏ phụ thuộc nhưng không tự sửa EventBus.
2. **Core (`game/export_presets.cfg`):** thêm `ui/ch2_typing_previews/*` vào `exclude_filter` để 10 ảnh bằng chứng không vào bản phát hành. Bộ lọc hiện có đã loại fixture `ch2_ui_preview` và `title_test`, nhưng chưa có thư mục ảnh mới này.
