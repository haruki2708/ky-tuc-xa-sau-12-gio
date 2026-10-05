# T-176 — Chương 2 sau chơi thử: từ điển, gõ từ, nhắn dự đoán (core)
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude
- Phụ thuộc: T-170. Quyết định: D-049, D-050, D-051.

## Việc
- Từ điển nối từ lớn có giấy phép dùng thương mại; xác biết phần từ phổ biến; giọng xác ghép theo tiếng.
- Vòng 3: bỏ 4 phương án, người chơi gõ từ (bộ gõ của máy); core chuẩn hóa chữ và kiểm tra luật.
- Vòng 4: giọng chat nhanh hơn khoảng 25%, chat không chặn lượt tắm; nhắn dự đoán cho Minh Nhật và Ngư thay đoạn cứu Ngư lúc 7:40.
- Hợp đồng mới cho lane A, C, D, E (T-177…T-180); ghép; export.

## Handoff
### Phiên 2026-10-06 (Claude)
- **Từ điển** `docs/design/ch2/build_dictionary.py`:
  - nguồn: Wiktionary tiếng Việt và tiếng Anh (bản trích kaikki.org, CC BY-SA, ngoại lệ D-051) cộng kho từ game;
  - kết quả: 30 975 từ hai tiếng (`game/data/ch2/dictionary.txt`, cột: chữ, dạng chuẩn, cờ xác biết); xác biết 9 474 từ (có trong cả hai bản, sau từ đó còn ít nhất 5 cách nối);
  - nguồn, giấy phép, ngày tải, SHA-256: `game/data/ch2/DICTIONARY_LICENSE.md`, `docs/design/ch2/dictionary_report.json`; file tải về để ở `docs/design/ch2/.cache/` (không commit).
- **Chuẩn hóa chữ** `scripts/core/viet_text.gd` (`VietText`): Unicode dựng sẵn và tổ hợp, dấu kiểu cũ/mới (hoà = hòa), y/i sau phụ âm (kỹ = kĩ), hoa/thường, khoảng trắng thừa. Python và GDScript cùng luật, test so trên `tests/core/canon_samples.json`.
- **`Ch2Dictionary`** (`scripts/core/ch2_dictionary.gd`) nạp từ điển một lần; **`Ch2SyllableBank`** (`scripts/core/ch2_syllable_bank.gd`) trả các đoạn giọng của từng tiếng.
- **Giọng xác theo tiếng:** `audio_source/ch2_syllable_voices.py` tạo 2 403 tiếng, 4 file `game/audio/voice/vi/ch2_syllables_*.ogg` (khoảng 5 MB) và `game/data/ch2/corpse_syllables.json`.
- **Director** (`chapter2_director.gd`):
  - vòng 3: `chain_input_requested(seconds)` → `chain_word_typed(text)` → `chain_input_closed(&"accepted"|&"wrong"|&"timeout")`; `is_valid_word(text)`; xác chọn từ kho game (60%) hoặc từ điển; xác bí khi không biết từ nào nối tiếp; `suggest_word()`, `suggest_dead_end()` cho bot và test;
  - vòng 4: chat chạy theo hàng đợi, không chặn; nhắn dự đoán một lần khi lần đầu đủ 3 lượt tắm an toàn liên tiếp (dãy chuẩn: sau lượt 9), muộn nhất trước lượt 21 (7:40); `prediction_requested(member, history, seconds)` → `prediction_sent(member, text)` → `prediction_result(member, correct)`; sai hoặc hết 20 giây: `DEATH_CH2_LOST_NHAT` / `DEATH_CH2_LOST_NGU`; `is_right_prediction(text, next)` nhận "có/co", "không/khong/ko/k", "3x";
  - bỏ đoạn cứu Ngư (choice `ngu`) và các hàm phương án.
- **Kịch bản** (`build_ch2_script.py`): lời nhắn mới `N_ASK`, `N_OK`, `N_SCREAM`, `NGU_ASK`, `NGU_SAVED`, `NGU_SCREAM`; dữ liệu `shower.json` mục `predict` (Minh Nhật 38, 16, 75 → 23; Ngư 74, 15, 62 → 81); bỏ từ bẫy, `CHOICE_CH2_NGU_*`, `CHAT_CH2_NGU_HELP`. Giọng chat chương 2 tạo lại ở tốc độ ×1,25.
- **EventBus:** thêm `chain_input_requested`, `chain_word_typed`, `chain_input_closed`, `text_entry_changed`, `prediction_requested`, `prediction_sent`, `prediction_result`; `chain_choice_requested` và `chain_choice_made` để lại, ghi "Deprecated" cho tới khi lane D bỏ.
- **Export:** `include_filter` thêm `data/ch2/*.txt`.
- **Sửa test cũ:** `test_ch1v2` đo cửa nhà vệ sinh ở chỗ cũ (commit `af52dde` dời cửa nhưng không sửa test).
- **Test:** `test_chapter2.gd` 19 test, `test_ch2_syllables.gd` 2 test.
- **Còn lại:** ghép T-177…T-180 khi lane giao; chạy bot ch2 (hỏi chủ dự án trước); export.

### Phiên 2026-10-06 (tiếp, Claude): ghép T-177…T-180
- Merge D → A → E → C, không xung đột. Xóa `chain_choice_requested` và `chain_choice_made`; `Ch2Countdown` reset theo `chain_input_closed`; export loại `ui/ch2_typing_previews/*`.
- **Test ghép** `tests/core/test_ch2_typing_flow.gd`: gõ trong ô thật của bảng nối từ (dấu tổ hợp) và trong điện thoại; nhân vật khóa và mở bàn phím.
- **Lỗ hổng từ điển tìm thấy khi ghép:**
  - lượt đầu sau "sách vở" chỉ có đúng "vở kịch" trong Wiktionary: thêm `SUPPLEMENT` (từ dự án tự soạn, chỉ người chơi dùng): vở ghi, vở nháp, vở viết, vở tuồng, vở chèo, vở diễn, vở tập;
  - xác có thể nói từ kho để lại ít hơn 5 cách nối (ví dụ "điện thoại" → chỉ "thoại bản"): giờ xác chỉ nói từ kho cũng đạt ngưỡng 5 như từ điển (test `test_every_corpse_word_leaves_five_ways_on`).
- Chạy thử headless scene chương 2 thật 900 frame: không lỗi.
- Hướng dẫn chơi thử `docs/playtest/CH2_WALKTHROUGH.md` sửa theo gõ từ và nhắn dự đoán.
