# T-104 — Font tiếng Việt, theme, HUD (tâm ngắm, gợi ý tương tác, phụ đề), đổi ngôn ngữ
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` PASS
- [x] Ảnh chụp `hud_test.tscn` thấy rõ dấu tiếng Việt (ví dụ "Tương tác", "Kỷ luật", "Điểm danh")
- [x] Không chạm file ngoài phạm vi; có `CREDITS.md` cho font
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Đã làm (2026-10-02, Lane D)
- Commit triển khai: `2c69ac2` — `T-104: Add localized HUD, Vietnamese font and UI tests`; đã push lên `origin/lane-d/T-104-ui-localization`.
- Thêm Be Vietnam Pro Regular, giấy phép OFL 1.1 và nguồn trong `game/assets/fonts/CREDITS.md`. Font và ảnh chụp được lưu bằng Git LFS; kèm metadata `.import`/`.uid` do Godot tạo.
- Theme nền tối, chữ sáng; HUD có tâm ngắm sáng khi focus, gợi ý `[E]` qua key dịch, phụ đề nền mờ ở cạnh dưới và hàng đợi FIFO.
- `locale_settings.gd`: `set_locale(code)` trả về `Error`, `get_locale()` đọc lựa chọn đã lưu; chỉ nhận `vi`/`en`, mặc định `vi`. Lưu `[ui] locale` trong `user://settings.cfg`, giữ các mục cấu hình khác. HUD đọc và áp dụng lựa chọn khi vào cây scene; gợi ý và phụ đề đang hiện cập nhật theo thay đổi locale.
- Scene F6 có nút bật/tắt focus, phát hai phụ đề và đổi VI/EN. Nội dung mẫu chỉ kiểm tra chữ, không bổ sung luật chơi/cốt truyện.
- Thêm 11 test UI (tổng 16 test toàn dự án): glyph tiếng Việt, theme/font, signal focus, phụ đề hết hạn và FIFO, đổi ngôn ngữ khi đang hiện/chờ, yêu cầu phụ đề không hợp lệ, mặc định/lưu/khôi phục locale, bảo toàn cấu hình, CSV và các nút scene thử. Test sao lưu rồi khôi phục nguyên trạng file settings của người dùng.
- Quyết định kỹ thuật: bỏ yêu cầu phụ đề có key rỗng hoặc thời lượng không hữu hạn/không dương; dùng key `UI_INTERACTION_PROMPT` cho mẫu `[E] %s`; không cần autoload hay signal mới.

### Kiểm chứng và cách kiểm tra
- Đã chạy `pwsh tools/test.ps1` bằng Godot `4.7.2.stable.official.ed1daf0bf`: **`RESULT: 16 passed, 0 failed`**, exit code 0, lần cuối không có lỗi script/runtime.
- `git diff --cached --check` sạch trước commit triển khai; thay đổi chỉ trong các thư mục được phép và phần checklist/Handoff của card này. CSV chỉ thêm key.
- Đã chạy Movie Maker với Vulkan Forward+ và xem trực tiếp ảnh 1920×1080: `game/ui/hud/previews/hud_test_vi.png`. Thấy rõ dấu trong “Tương tác”, “Kỷ luật”, “Điểm danh”, các glyph mẫu, gợi ý và phụ đề.
- Mở `game/ui/hud/hud_test.tscn`, nhấn F6; bấm bật/tắt gợi ý, thử hàng đợi, rồi đổi VI/EN khi phụ đề đang hiện. Hai câu lần lượt tồn tại 2,5 giây; đổi ngôn ngữ không làm mất hàng đợi. Đóng/mở lại scene để kiểm tra ngôn ngữ đã lưu.
- Có thể tái tạo ảnh: tạo `D:\GAME_WORK\lane-d\build\ui-capture`, rồi chạy `& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://ui/hud/hud_test.tscn --write-movie D:/GAME_WORK/lane-d/build/ui-capture/frame.png --fixed-fps 30 --quit-after 2 --resolution 1280x720 --windowed -- --capture-ui`. Chế độ này ép VI/focus/phụ đề mẫu để chụp, không ghi đè lựa chọn ngôn ngữ đã lưu.
- Các nút đã được gọi bằng signal trong test tự động; chưa có phiên bấm chuột chơi thử thủ công của chủ dự án.

### Còn dở / checklist chưa đạt
- Không còn mục checklist chưa đạt trong phạm vi T-104. HUD sẵn sàng để integrator gắn vào scene chơi chính.

### Yêu cầu thay đổi ngoài phạm vi
- Integrator instance `res://ui/hud/hud.tscn` vào scene chơi chính trong `game/scenes/main/` khi tích hợp. Lane D không sửa scene này. Việc đọc locale đã nằm trong `_ready()` của HUD, không cần thêm autoload hoặc sửa `project.godot` cho task hiện tại.
- Không có câu hỏi mới về luật chơi hoặc cốt truyện.

### Trở ngại
- Không còn bị chặn. Sandbox Windows gặp lỗi đăng nhập `1326`; các lệnh cần thiết đã chạy thành công qua cơ chế cấp quyền ngoài sandbox, trong `D:\GAME_WORK\lane-d`.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`.** Sau merge (gồm T-101…T-103): `test.ps1` → `RESULT: 41 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi; `strings.csv` chỉ thêm key. Font OFL có đủ giấy phép và nguồn.
- Test rất kỹ: đủ bảng chữ cái tiếng Việt, hàng đợi phụ đề FIFO, bỏ yêu cầu không hợp lệ, đổi ngôn ngữ khi phụ đề đang hiện, sao lưu và khôi phục `settings.cfg` của người dùng.
- Ảnh `hud_test_vi.png`: dấu tiếng Việt rõ, phụ đề dễ đọc trên nền tối.
- Integrator đã xử lý yêu cầu thay đổi: instance `hud.tscn` vào `main.tscn`. Ngoài ra đặt `gui/theme/custom` = `main_theme.tres` để mọi UI trong game mặc định dùng Be Vietnam Pro.

**Việc cần làm kèm task sau của lane D (T-116), không chặn:**
1. Tâm ngắm 4 × 4 px gần như không thấy ở 1080p trên nền hành lang sáng. Tăng lên khoảng 6 px và thêm viền tối mảnh để thấy được trên cả nền sáng lẫn tối.
2. Áp dụng ngôn ngữ đã lưu đang nằm trong `hud.gd` `_ready()`. Khi có menu chính/menu tạm dừng, chuyển việc này về một chỗ chạy lúc khởi động game (ví dụ script cài đặt chung), để menu không có HUD vẫn đúng ngôn ngữ.
3. Gợi ý `[E]` đang cố định trong key dịch. Khi có menu đổi phím (nếu làm), lấy tên phím từ `InputMap`.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
