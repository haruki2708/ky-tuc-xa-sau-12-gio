# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-02
**Giai đoạn:** P1. Xong 5 task thử tuần đầu (T-101…T-105). Lane E nhận T-114.
**Repo:** https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio (private)

## Đã xong
- Godot 4.7.2 (self-contained) và export template Windows cài ở `D:\Tools\Godot`.
- Khung project `game/`:
  - autoload `GameInput` (input action) và `EventBus` (signal chung),
  - lớp `Interactable`,
  - scene `main.tscn` là hành lang greybox,
  - song ngữ CSV (vi/en).
- Test runner headless chạy được: `tools/test.ps1`, 54/54 test PASS (sau T-101…T-105, T-121). Có thêm `check.ps1`, `capture.ps1`, `package.ps1` và autoload `Autoplay` để phát lại input (xem `tools/README.md`).
- Export chạy được: `tools/export.ps1` ra `build/windows/KyTucXa.exe`. Đã chạy thử, mở được.
- Chụp khung hình bằng Movie Maker chạy được, integrator xem được ảnh.
- Blender 5.2.2 LTS portable ở `D:\Tools\Blender\5.2.2`; bộ 7 mô hình ký túc xá (T-102), preview ở `art_source/kit/previews/`.
- Tài liệu: `AGENTS.md`, `docs/PLAN.md`, `docs/DECISIONS.md`, `docs/design/GDD.md`, task card cho tuần đầu.

## Đang làm / tiếp theo
| Task | Lane | Trạng thái |
|---|---|---|
| T-101 Điều khiển người chơi và tương tác | A | **done**, đã merge |
| T-102 Bộ module 3D bằng script Blender | B | **done**, đã merge; chủ dự án đã duyệt (D-012) |
| T-103 Công cụ capture, package, check | C | **done**, đã merge |
| T-104 Font, HUD, phụ đề, đổi ngôn ngữ | D | **done**, đã merge |
| T-105 Pipeline âm thanh và âm môi trường đầu tiên | E | **done**, đã merge; chủ dự án đã nghe: tạm ổn, riêng tiếng ù đèn tuýp quá nhỏ |
| T-114 Sửa tiếng ù, vùng âm, đèn tắt thì im tiếng | E | todo (giao ngay) |
| T-121 Kit: ghế nhựa VN, mùng, collision | B | **done**, đã merge; mùng chờ chủ dự án duyệt hình ảnh |
| T-110 Kiến trúc RuleSystem và GameState | core | todo |
| T-113 Chốt bộ luật demo và sơ đồ tầng | Chủ dự án + Claude | todo |

## Đang vướng
- Không có.

## Ghi chú cho người chơi thử
- Hành lang xám đi lại được: WASD đi, Shift chạy, chuột nhìn, Esc bắt/thả chuột. Có HUD (tâm ngắm, gợi ý, phụ đề), font tiếng Việt, tiếng bước chân dép lê, tiếng ù đèn tuýp và côn trùng đêm. Chưa có đồ vật để tương tác trong hành lang chính.
- Nghe thử âm thanh: mở `res://audio/test/audio_test.tscn`, F6; phím 0–7 để nghe riêng từng nguồn.
- Thử HUD và đổi ngôn ngữ: mở `res://ui/hud/hud_test.tscn`, F6.
- Thử tương tác: mở `res://scenes/player/player_test.tscn`, F6, nhìn hộp xanh bấm E để bật/tắt đèn.
