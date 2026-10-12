# Fonts

- File: `be_vietnam_pro_regular.ttf` (Be Vietnam Pro Regular, unmodified).
- Authors: The Be Vietnam Pro Project Authors.
- Upstream: https://github.com/bettergui/BeVietnamPro
- Download: https://github.com/google/fonts/tree/main/ofl/bevietnampro
- License: SIL Open Font License 1.1 (OFL); full text in `OFL.txt`.
- Retrieved: 2026-10-02.
- SHA-256: `cd1ef6e9d7db28ad5cdb88a65ccbe693870e60d340b791f349d248342b4fe4c3`.

The task card explicitly permits OFL for fonts. No font was installed system-wide.

## T-214 — 12/10/2026

- `be_vietnam_pro_semibold.ttf`: Be Vietnam Pro SemiBold, giữ nguyên file nguồn; The Be Vietnam Pro Project Authors. [Nguồn Google Fonts](https://github.com/google/fonts/tree/main/ofl/bevietnampro), [file tải](https://raw.githubusercontent.com/google/fonts/main/ofl/bevietnampro/BeVietnamPro-SemiBold.ttf). SIL OFL 1.1, cùng giấy phép `OFL.txt` trong thư mục này. SHA-256 `bd8e27eb02720b9d91e59e4f10a90878643219f25ce6a8d9a4f06a8a88d3bb71`. Dùng cho logo, tiêu đề và nút; chữ thân giữ Regular.
- `ibm_plex_mono_regular.ttf`: IBM Plex Mono Regular, giữ nguyên file nguồn; IBM Corp., reserved font name “Plex”. [Nguồn Google Fonts](https://github.com/google/fonts/tree/main/ofl/ibmplexmono), [file tải](https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexmono/IBMPlexMono-Regular.ttf). SIL OFL 1.1, bản đầy đủ `ibm_plex_mono_OFL.txt`. SHA-256 `6a3412f058c7d8dfd9170c41e85ade48e5156ecb89356110ca57a0a27734af46`. Dùng cho giấy đánh máy và tiêu đề sổ; không thay lời.
- Font tải thẳng vào repo lane D, không cài hệ thống. Kiểm cả ba font bằng cmap ngoại tuyến và test Godot cho chữ hoa/thường `ă â đ ê ô ơ ư` cùng năm dấu: PASS trong lượt UI `119 passed, 0 failed` ngày 12/10/2026. Giấy viết tay dùng Be Vietnam Pro Regular với phép nghiêng `FontVariation` có sẵn, không thay file font. IBM Plex Mono thực dùng ở giấy đánh máy và tiêu đề sổ; số điện thoại giữ Be Vietnam Pro. Kết quả full test/check nằm trong Handoff T-214.
