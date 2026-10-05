# Từ điển nối từ chương 2: nguồn và giấy phép

- **File:** `dictionary.txt` (khoảng 31 nghìn từ hai tiếng), `corpse_syllables.txt`, `corpse_syllables.json` (danh sách tiếng).
- **Nguồn:** Wiktionary tiếng Việt (https://vi.wiktionary.org) và Wiktionary tiếng Anh (https://en.wiktionary.org), của các tác giả Wiktionary. Bản trích máy đọc được do kaikki.org (wiktextract) cung cấp:
  - https://kaikki.org/viwiktionary/Tiếng Việt/
  - https://kaikki.org/dictionary/Vietnamese/
  - Ngày tải và mã SHA-256: `docs/design/ch2/dictionary_report.json`.
- **Giấy phép:** Wiktionary phát hành theo CC BY-SA 3.0 (nội dung cũ) và CC BY-SA 4.0 (nội dung thêm từ giữa năm 2023). Danh sách từ chuyển thể ở đây phát hành theo **CC BY-SA 4.0**: https://creativecommons.org/licenses/by-sa/4.0/
- **Đã thay đổi:** chỉ giữ mục từ thường có đúng hai tiếng; bỏ tên riêng, ký tự, phụ tố; thêm dạng chuẩn hóa để so tiếng và cờ "xác biết"; thêm các từ của game (`docs/design/ch2/word_bank.py`).
- **Ngoại lệ D-051:** CC BY-SA nằm ngoài quy tắc CC0/CC-BY của dự án; chủ dự án cho phép riêng cho danh sách từ này. Phần ShareAlike áp dụng cho chính danh sách từ, không áp dụng cho mã nguồn hay tài nguyên khác của game.
- **Ghi công trong game:** mục Credits ở màn hình chính (lane D, T-179).
- **Tạo lại:** `py -3 docs/design/ch2/build_dictionary.py`.
- **Giọng đọc tiếng** (`game/audio/voice/vi/ch2_syllables_*.ogg`): tạo bằng eSpeak NG 1.52.0 (`audio_source/ch2_syllable_voices.py`), cùng cách với các giọng khác (xem `game/audio/CREDITS.md`).
