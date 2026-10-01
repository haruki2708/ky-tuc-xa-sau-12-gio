# T-104 — Font tiếng Việt, theme, HUD (tâm ngắm, gợi ý tương tác, phụ đề), đổi ngôn ngữ
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-104-ui-localization`
- Phụ thuộc: P0 (xong). HUD lắng nghe `EventBus`. Không phụ thuộc T-101.
- Loại: task thử tuần đầu

## Mục tiêu
Chữ tiếng Việt hiển thị đúng dấu. HUD phản ứng với tín hiệu từ `EventBus`. Đổi qua lại Việt/Anh khi đang chạy game.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## Yêu cầu
1. **Font:**
   - Dùng font giấy phép **OFL**, hỗ trợ đầy đủ tiếng Việt. Gợi ý: Be Vietnam Pro hoặc Noto Sans.
   - Có thể thêm một font phụ cho chữ viết tay hoặc chữ trên giấy tờ, nếu cũng là OFL và hỗ trợ tiếng Việt.
   - Đặt font vào `game/assets/fonts/`, kèm file giấy phép và `CREDITS.md`.
2. **Theme:** `game/ui/theme/main_theme.tres` gồm font, cỡ chữ, màu. Chữ phải dễ đọc trên nền tối.
3. **HUD: `game/ui/hud/hud.tscn` + `game/scripts/ui/hud.gd`:**
   - Tâm ngắm là một chấm nhỏ ở giữa màn hình. Khi có đồ vật đang được nhắm, tâm ngắm sáng lên.
   - Nghe `EventBus.interaction_focus_changed(prompt_key)`. Key không rỗng thì hiện `"[E] " + tr(prompt_key)` gần tâm ngắm; key rỗng thì ẩn.
   - Nghe `EventBus.subtitle_requested(text_key, duration)`. Hiện phụ đề ở cạnh dưới màn hình, nền mờ, tự ẩn sau `duration`. Nếu đang có câu phụ đề khác thì xếp hàng chờ.
   - Khi đổi ngôn ngữ, chữ đang hiển thị phải cập nhật ngay.
4. **Đổi ngôn ngữ: `game/scripts/ui/locale_settings.gd`:**
   - Hàm static `set_locale(code)` và `get_locale()`.
   - Lưu lựa chọn vào `user://settings.cfg`, mục `[ui] locale`. Mặc định là `vi`.
5. **Scene thử `game/ui/hud/hud_test.tscn`:**
   - Có nút giả lập focus, giả lập phụ đề, và đổi VI/EN.
   - Chủ dự án mở bằng F6 để xem trực tiếp.
6. **Key dịch:** thêm vào `strings.csv` các key cần dùng, ví dụ `UI_LANGUAGE`, `SUB_TEST_1`. Viết đủ cả `vi` và `en`, tiếng Việt có dấu đầy đủ.
7. **Test `game/tests/ui/`:**
   - Font có glyph cho `ạ ằ ẵ ữ ỹ đ Đ ơ ư`.
   - HUD hiện và ẩn gợi ý đúng theo signal.
   - Phụ đề tự ẩn sau thời gian quy định.
   - Đổi locale thì chữ của gợi ý đổi theo.
   - Mọi key trong CSV có đủ `vi` và `en`, không rỗng.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` PASS
- [ ] Ảnh chụp `hud_test.tscn` thấy rõ dấu tiếng Việt (ví dụ "Tương tác", "Kỷ luật", "Điểm danh")
- [ ] Không chạm file ngoài phạm vi; có `CREDITS.md` cho font
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
