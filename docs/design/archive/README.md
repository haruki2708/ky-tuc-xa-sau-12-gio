# Lưu trữ: phần chơi cũ (bản demo "người thứ năm")

Bản demo khoảng 18 phút, 5 đoạn, cốt truyện "Nội quy có bản bị sửa" và "người thứ năm", chơi thử ngày 2026-10-03. Thay bằng thiết kế v2 (`docs/design/STORY.md`) theo D-034.

- **Chơi lại bản cũ:** `build/archive/demo-v1/KyTucXa.exe` trên máy integrator (không có trong git).
- **Lấy lại mã nguồn bản cũ:** `git checkout demo-v1` (tag ở commit `37d0e62`), hoặc `git show demo-v1:<đường dẫn>` cho từng file.

| File | Nội dung |
|---|---|
| `STORY_v1.md` | Thiết kế v1 cho game 4 chương (người thứ năm, bác Tư, Vũ Đức Lâm), đã duyệt rồi bị thay ngay trong ngày 2026-10-04 |
| `RULES.md` | Bộ luật, cốt truyện và diễn biến 5 đoạn của demo (T-113, D-020) |
| `GDD.md` | GDD rút gọn của demo |
| `PLAN.md` | Kế hoạch tổng ban đầu (demo 15–20 phút cho itch.io) |

Vẫn còn dùng, không lưu trữ: `docs/design/LAYOUT.md` (sơ đồ tầng 4, phòng 407), `docs/design/RULE_SYSTEM.md` (hệ thống luật trong code), `docs/SETTINGS.md`.

**Code và dữ liệu chỉ thuộc truyện cũ** (luồng 5 đoạn trong `story_director.gd`, `data/rules/demo.tres`, giấy tờ cũ, câu chữ cũ, kịch bản bot cũ) vẫn nằm trong game cho tới khi chương 1 ghép xong, vì test và bot đang chạy trên chúng. Integrator xóa sau đó; tag `demo-v1` giữ lại mọi thứ.
