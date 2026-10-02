# T-139 — Màn hình chính, cảnh báo nội dung, credits
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-139-title-screen`
- Phụ thuộc: T-116, T-128, T-132 (done).

## Mục tiêu
Game đang vào thẳng màn chơi. Để đăng itch.io cần: màn cảnh báo nội dung, màn hình chính có "Tiếp tục", và màn credits.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## API của core (integrator đã thêm)
- `App.start_game(continue_saved: bool)`: vào game, từ đầu hoặc từ checkpoint gần nhất.
- `App.has_saved_game() -> bool`: có checkpoint để tiếp tục không.
- `App.return_to_title()`: về màn hình chính (`App.TITLE_SCENE`).
- `App.quit()`: thoát sạch.

## Yêu cầu
1. **`game/ui/title/title_screen.tscn`** (đúng đường dẫn `App.TITLE_SCENE`):
   - nền tối, ảnh hành lang tầng 4 ban đêm qua filter PS1 (chụp từ game bằng `tools/capture.ps1`, để trong `game/ui/title/`), có rung nhẹ hoặc chập chờn đèn;
   - tên game: "Ký túc xá sau 12 giờ" / "The Dorm After Midnight";
   - nút: **Tiếp tục** (chỉ hiện khi `App.has_saved_game()`), **Chơi mới**, **Cài đặt** (dùng lại bảng cài đặt của menu tạm dừng), **Credits**, **Thoát**;
   - "Chơi mới" khi đang có checkpoint thì hỏi xác nhận trước khi bỏ lượt chơi cũ;
   - chuột hiện, điều khiển được bằng bàn phím (mũi tên, Enter, Esc);
   - âm thanh: tiếng ù đèn rất nhỏ (dùng file có sẵn của lane E).
2. **Cảnh báo nội dung** trước màn hình chính, chỉ hiện ở lần chạy đầu:
   - nội dung: game kinh dị, có cảnh hù đột ngột và âm thanh lớn đột ngột; có thể bật "Giảm hù dọa" trong Cài đặt;
   - hai nút: "Tiếp tục" và "Bật Giảm hù dọa rồi tiếp tục";
   - lưu `[ui] content_warning_seen = true` (key mới, integrator đã thêm vào `docs/SETTINGS.md`).
3. **Credits:** liệt kê từ các `CREDITS.md` hiện có (kit, âm thanh, font, TTS khi có), có ghi chú nội dung tạo bằng AI; cuộn được.
4. **Menu tạm dừng:** thêm nút "Về màn hình chính" (xác nhận trước, vì sẽ mất tiến độ từ checkpoint) → `App.return_to_title()`.
5. **Song ngữ:** mọi chữ qua key `UI_*`, đủ vi và en; đổi ngôn ngữ ở màn hình chính có hiệu lực ngay.
6. **Test `game/tests/ui/`:** title load được; nút Tiếp tục ẩn hoặc hiện theo `has_saved_game`; cảnh báo chỉ hiện lần đầu và lưu key; nút "Bật Giảm hù dọa" ghi `reduce_scares = true`; menu tạm dừng có nút mới. Test không được gọi `change_scene` thật: tách hành động thành hàm có thể giả lập.
7. **Ảnh:** cảnh báo, màn hình chính (vi và en), credits.

## Ghi chú cho integrator
Sau khi merge, integrator đổi `run/main_scene` sang màn hình chính và cho màn "Còn tiếp…" quay về màn hình chính.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Có ảnh ở mục 7
- [ ] Handoff: cách thử bằng tay, phần chưa thử

## Handoff (agent điền)
