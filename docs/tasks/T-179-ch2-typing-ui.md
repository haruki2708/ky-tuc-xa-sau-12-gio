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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh preview vi/en
- [ ] Handoff: scene, API, đường dẫn node (cho bot lane C)

## Handoff (agent điền)
