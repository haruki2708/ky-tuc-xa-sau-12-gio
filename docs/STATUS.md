# STATUS — cập nhật bởi integrator

**Cập nhật lần cuối:** 2026-10-02
**Giai đoạn:** P1. Xong 5 task thử tuần đầu (T-101…T-105). Cả 5 lane nhận task mới (T-112, T-116, T-124, T-125, T-126), dùng chung hợp đồng cài đặt `docs/SETTINGS.md`.
**Repo:** https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio (private)

## Đã xong
- Godot 4.7.2 (self-contained) và export template Windows cài ở `D:\Tools\Godot`.
- Khung project `game/`:
  - autoload `GameInput` (input action) và `EventBus` (signal chung),
  - lớp `Interactable`,
  - scene `main.tscn` là hành lang greybox,
  - song ngữ CSV (vi/en).
- Test runner headless chạy được: `tools/test.ps1`, 125/125 test PASS (sau T-101…T-105, T-110, T-112…T-114, T-116, T-118, T-121…T-126). Autoload `App` lo việc thoát sạch (`App.quit()`, `-- --quit-after-frames=N`). Có thêm `check.ps1`, `capture.ps1`, `package.ps1` và autoload `Autoplay` để phát lại input (xem `tools/README.md`).
- Export chạy được: `tools/export.ps1` ra `build/windows/KyTucXa.exe`. Đã chạy thử, mở được.
- Chụp khung hình bằng Movie Maker chạy được, integrator xem được ảnh.
- Blender 5.2.2 LTS portable ở `D:\Tools\Blender\5.2.2`; bộ 7 mô hình ký túc xá (T-102), preview ở `art_source/kit/previews/`.
- Lõi luật chơi (T-110): autoload `GameState`, `RuleSystem`, helper `Checkpoint`; bộ luật demo đã có (T-113, `game/data/rules/demo.tres`).
- Tài liệu: `AGENTS.md`, `docs/PLAN.md`, `docs/DECISIONS.md`, `docs/design/GDD.md`, task card cho tuần đầu.

## Đang làm / tiếp theo
| Task | Lane | Trạng thái |
|---|---|---|
| T-101 Điều khiển người chơi và tương tác | A | **done**, đã merge |
| T-102 Bộ module 3D bằng script Blender | B | **done**, đã merge; chủ dự án đã duyệt (D-012) |
| T-103 Công cụ capture, package, check | C | **done**, đã merge |
| T-104 Font, HUD, phụ đề, đổi ngôn ngữ | D | **done**, đã merge |
| T-105 Pipeline âm thanh và âm môi trường đầu tiên | E | **done**, đã merge; chủ dự án đã nghe: tạm ổn, riêng tiếng ù đèn tuýp quá nhỏ |
| T-114 Sửa tiếng ù, vùng âm, đèn tắt thì im tiếng | E | **done**, đã merge; chủ dự án đã duyệt tiếng ù (D-014) |
| T-121 Kit: ghế nhựa VN, mùng, collision | B | **done**, đã merge; chủ dự án đã duyệt (D-013) |
| T-122 Nhịp bước chân tự nhiên | A | **done**, đã merge; chủ dự án đã duyệt nhịp (D-018) |
| T-123 Âm dép lê mềm hơn | E (Claude làm thay) | **done**, đã merge; chủ dự án đã chốt độ to (D-015) |
| T-116 Menu tạm dừng và cài đặt | D | **done**, đã merge |
| T-112 Dựng greybox tầng 4 | B | **done**, đã merge; game chính chạy trên tầng 4 |
| T-118 Filter PS1, sửa import texture | B (Claude làm thay) | **done**, đã merge; game chính có filter PS1 |
| T-124 Dọn công cụ QA, lọc file build | C | **done**, đã merge; package PASS chuyển sang T-127 |
| T-127 Công cụ QA thoát qua `App.quit()` | C | todo (giao ngay) |
| T-128 Nút Thoát qua `App.quit()`, key biển tầng 4 | D | todo (giao ngay) |
| T-125 Player theo menu tạm dừng và cài đặt | A | **done**, đã merge |
| T-126 Bus riêng cho bước chân | E | **done**, đã merge; menu có thanh trượt Bước chân |
| T-110 Kiến trúc RuleSystem và GameState | core | **done**, đã merge (xem `docs/design/RULE_SYSTEM.md`) |
| T-113 Chốt bộ luật demo và sơ đồ tầng | Chủ dự án + Claude | **done** (D-020); dữ liệu `game/data/rules/demo.tres` |

## Đang vướng
- Không có. (Lỗi editor tự nén texture kit đã sửa ở T-118.)

## Ghi chú cho người chơi thử
- Game chính chạy trên **tầng 4** (T-112): bắt đầu trước cửa phòng 407; E mở và đóng cửa 407; đi được khắp hành lang, phòng 407, nhà vệ sinh, bàn trực. WASD đi, Shift chạy, chuột nhìn, Esc mở menu. Có filter PS1 (chỉnh cường độ và độ sáng trong Cài đặt). Có HUD (tâm ngắm, gợi ý, phụ đề), font tiếng Việt, tiếng bước chân dép lê, tiếng ù đèn tuýp và côn trùng đêm. Đồ vật tương tác hiện chỉ có cửa 407; giấy tờ, công tắc, sổ trực chờ T-111 và T-117.
- Nghe thử vùng âm và tiếng ù mới: mở `res://audio/test/zones_test.tscn`, F6; đi giữa hai phòng, phím L bật/tắt đèn, F cho đèn chập chờn.
- Nghe thử âm thanh: mở `res://audio/test/audio_test.tscn`, F6; phím 0–7 để nghe riêng từng nguồn.
- Trong game: Esc mở menu tạm dừng (Tiếp tục, Cài đặt, Thoát). Cài đặt có âm lượng, độ nhạy chuột, nhún đầu, ngôn ngữ.
- Thử HUD và đổi ngôn ngữ: mở `res://ui/hud/hud_test.tscn`, F6.
- Thử tương tác: mở `res://scenes/player/player_test.tscn`, F6, nhìn hộp xanh bấm E để bật/tắt đèn.
