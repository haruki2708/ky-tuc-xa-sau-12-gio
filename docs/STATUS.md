# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-02
**Giai đoạn:** P1, task thử tuần đầu. Đang review lần lượt từng lane.
**Repo:** https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio (private)

## Đã xong
- Godot 4.7.2 (self-contained) và export template Windows cài ở `D:\Tools\Godot`.
- Khung project `game/`:
  - autoload `GameInput` (input action) và `EventBus` (signal chung),
  - lớp `Interactable`,
  - scene `main.tscn` là hành lang greybox,
  - song ngữ CSV (vi/en).
- Test runner headless chạy được: `tools/test.ps1`, 30/30 test PASS (sau T-101, T-102, T-103). Có thêm `check.ps1`, `capture.ps1`, `package.ps1` và autoload `Autoplay` để phát lại input (xem `tools/README.md`).
- Export chạy được: `tools/export.ps1` ra `build/windows/KyTucXa.exe`. Đã chạy thử, mở được.
- Chụp khung hình bằng Movie Maker chạy được, integrator xem được ảnh.
- Blender 5.2.2 LTS portable ở `D:\Tools\Blender\5.2.2`; bộ 7 mô hình ký túc xá (T-102), preview ở `art_source/kit/previews/`.
- Tài liệu: `AGENTS.md`, `docs/PLAN.md`, `docs/DECISIONS.md`, `docs/design/GDD.md`, task card cho tuần đầu.

## Đang làm / tiếp theo
| Task | Lane | Trạng thái |
|---|---|---|
| T-101 Điều khiển người chơi và tương tác | A | **done**, đã merge |
| T-102 Bộ module 3D bằng script Blender | B | **done**, đã merge; chờ chủ dự án duyệt hình ảnh |
| T-103 Công cụ capture, package, check | C | **done**, đã merge |
| T-104 Font, HUD, phụ đề, đổi ngôn ngữ | D | review (agent đã push, chờ integrator) |
| T-105 Pipeline âm thanh và âm môi trường đầu tiên | E | review (agent đã push, chờ integrator) |
| T-110 Kiến trúc RuleSystem và GameState | core | todo |
| T-113 Chốt bộ luật demo và sơ đồ tầng | Chủ dự án + Claude | todo |

## Đang vướng
- Không có.

## Ghi chú cho người chơi thử
- Hành lang xám đi lại được: WASD đi, Shift chạy, chuột nhìn, Esc bắt/thả chuột. Chưa có đồ vật để tương tác trong hành lang chính.
- Thử tương tác: mở `res://scenes/player/player_test.tscn`, F6, nhìn hộp xanh bấm E để bật/tắt đèn.
