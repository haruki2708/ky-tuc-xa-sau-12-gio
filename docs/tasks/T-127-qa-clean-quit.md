# T-127 — Công cụ QA thoát game qua `App.quit()`
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-127-qa-clean-quit`
- Phụ thuộc: T-124 (done). Đọc mục **Review** trong `docs/tasks/T-124-qa-followups.md`.

## Mục tiêu
Gỡ blocker của T-124. Lỗi `ERROR: resources still in use at exit` xảy ra khi game thoát ngay lúc âm thanh còn phát. Integrator đã thêm autoload `App` (`game/scripts/core/app.gd`): `App.quit()` dừng cây scene, tắt mọi nguồn âm, chờ 0,25 giây rồi mới thoát. Tham số `-- --quit-after-frames=N` làm việc tương tự sau N frame.

Đối chứng của integrator trên `main.tscn` (headless): cờ `--quit-after` của engine lỗi 4/5 lần; `--quit-after-frames` qua `App` lỗi 0/5. Bản build release chạy có cửa sổ 5/5 lần sạch.

Công cụ QA hiện vẫn dùng `--quit-after` của engine, nên đi vòng qua bước thoát sạch. Task này chuyển chúng sang `App`.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`; không đổi cách gọi `test.ps1` và `export.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **`package.ps1`:** chạy exe đã giải nén bằng `-- --quit-after-frames=60` thay cho `--quit-after 60`. Giữ nguyên mọi kiểm tra (exit code, `ERROR` trong log, timeout).
2. **`capture.ps1`:** Movie Maker ghi tới khi game thoát. Truyền `--quit-after-frames=<Frames>` vào phần user args (sau `--`, cùng chỗ với `--autoplay=...`) thay cho `--quit-after <Frames>`. Số ảnh phải giữ đúng như trước (ví dụ autoplay `main.tscn` vẫn ra 136 ảnh).
3. **`autoplay.gd`:** khi phát xong và `quit_on_finish` bật, gọi `App.quit()` nếu autoload `App` tồn tại, nếu không thì dùng `get_tree().quit()` như cũ.
4. **`package_readme.txt`:** cập nhật đúng hiện trạng (D-021):
   - Bản thử chạy trên tầng 4 ký túc xá: hành lang, phòng 407 (mở cửa bằng E), nhà vệ sinh, bàn trực.
   - **Esc mở menu tạm dừng** (Tiếp tục, Cài đặt, Thoát), không còn là "bắt/thả chuột".
   - Cài đặt có âm lượng, độ nhạy chuột, nhún đầu, ngôn ngữ.
   - Chưa có cốt truyện và luật chơi.
5. **Chạy lại các kiểm chứng của T-124:**
   - `pwsh tools/package.ps1` phải ra `RESULT: package PASS`. Ghi dung lượng zip.
   - `pwsh tools/verify-capture.ps1` phải ra 5/5 PASS, 136 ảnh mỗi lần, không còn bản sao project.
   - Nếu vẫn còn `ERROR` khi thoát thì **không che lỗi**: ghi log vào Handoff và báo Blocked như T-124.
6. **Test:** cập nhật hoặc thêm test cho `autoplay.gd` (gọi `App.quit()` khi có `App`; test không được làm thoát runner, ví dụ dùng `quit_on_finish = false` hoặc thay hàm thoát).

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `pwsh tools/package.ps1` ra `RESULT: package PASS`
- [ ] `pwsh tools/verify-capture.ps1` ra 5/5 PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
