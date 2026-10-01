# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-02
**Giai đoạn:** P0 xong → bắt đầu P1 (task thử tuần đầu).
**Repo:** https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio (private)

## Đã xong
- Godot 4.7.2 (self-contained) và export template Windows cài ở `D:\Tools\Godot`.
- Khung project `game/`:
  - autoload `GameInput` (input action) và `EventBus` (signal chung),
  - lớp `Interactable`,
  - scene `main.tscn` là hành lang greybox,
  - song ngữ CSV (vi/en).
- Test runner headless chạy được: `tools/test.ps1`, 5/5 test PASS.
- Export chạy được: `tools/export.ps1` ra `build/windows/KyTucXa.exe`. Đã chạy thử, mở được.
- Chụp khung hình bằng Movie Maker chạy được, integrator xem được ảnh.
- Tài liệu: `AGENTS.md`, `docs/PLAN.md`, `docs/DECISIONS.md`, `docs/design/GDD.md`, task card cho tuần đầu.

## Đang làm / tiếp theo
| Task | Lane | Trạng thái |
|---|---|---|
| T-101 Điều khiển người chơi và tương tác | A | todo (task thử) |
| T-102 Bộ module 3D bằng script Blender | B | todo (task thử) |
| T-103 Công cụ capture, package, check | C | todo (task thử) |
| T-104 Font, HUD, phụ đề, đổi ngôn ngữ | D | todo (task thử) |
| T-105 Pipeline âm thanh và âm môi trường đầu tiên | E | todo (task thử) |
| T-110 Kiến trúc RuleSystem và GameState | core | todo |
| T-113 Chốt bộ luật demo và sơ đồ tầng | Chủ dự án + Claude | todo |

## Đang vướng
- Không có.

## Ghi chú cho người chơi thử
- Bản hiện tại chỉ có hành lang xám, camera đứng yên. Chưa chơi được.
