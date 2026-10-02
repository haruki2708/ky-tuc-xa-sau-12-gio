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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] `pwsh tools/package.ps1` ra `RESULT: package PASS`
- [x] `pwsh tools/verify-capture.ps1` ra 5/5 PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Kết quả triển khai
- Hoàn tất trên nền `origin/main` tại `5d87982`, commit `7af33af`, đã push `origin/lane-c/T-127-qa-clean-quit` trước commit Handoff này. Không sửa file ngoài phạm vi; không sửa project.godot, core/App, export preset, test UI/player hoặc STATUS.
- Package truyền `-- --quit-after-frames=60`; giữ kiểm tra exit code, cả log/stdout/stderr có ERROR và timeout 60 giây.
- Capture truyền giới hạn frame qua user args cùng autoplay. Autoplay ưu tiên `/root/App.quit()`, fallback SceneTree.quit khi không có App. Ba test mới dùng spy kiểm chứng App, fallback và quit_on_finish=false, không thoát runner.
- README bản ZIP cập nhật tầng 4, cửa 407, menu Esc và các cài đặt đúng card; không tự thêm nội dung luật/cốt truyện.

### Số frame và thoát sạch
App chờ 0,25 giây để giải phóng audio, trong lúc này Movie Maker tiếp tục ghi. Lượt thăm dò ghi 143 ảnh thay vì 136, log sạch. Capture nay đọc mốc `AUTOPLAY: finished after N frames`, giữ min(Frames, N) ảnh kịch bản, bỏ đuôi ảnh chờ thoát trước khi lọc KeepEvery. Nếu không có mốc autoplay thì giữ Frames. Không bỏ qua ERROR và báo lỗi nếu số ảnh ít hơn yêu cầu. Log in cả số ảnh thô và số ảnh bỏ; WAV giữ nguyên, gồm phần chờ thoát.

`pwsh tools/verify-capture.ps1` chạy **5 lượt liên tiếp**, tất cả exit 0, không ERROR:

| Lượt | Ảnh thô Movie Maker | Ảnh chờ thoát bỏ đi | PNG còn lại | Còn snapshot |
|---|---:|---:|---:|---|
| 1 | 143 | 7 | 136 | Không |
| 2 | 143 | 7 | 136 | Không |
| 3 | 143 | 7 | 136 | Không |
| 4 | 143 | 7 | 136 | Không |
| 5 | 143 | 7 | 136 | Không |

- **`RESULT: autoplay capture 5/5 PASS (136 frames each, no snapshots)`**.
- Log/ảnh: `build/captures/T-127-eff7e9e90e7a4de1b261ac9b8b060465/run-1.log` … `run-5.log` và các thư mục run tương ứng.
- Capture không autoplay: `pwsh tools/capture.ps1 -Frames 12 -KeepEvery 5 -Out build/captures/T-127-no-autoplay` → **`RESULT: capture PASS (12 gameplay frames)`**; 19 ảnh thô, bỏ 7 ảnh chờ thoát, giữ index 4/9/11, không còn snapshot. Log `build/T-127-no-autoplay.log`.

### Test/check/package
- `pwsh tools/test.ps1`: **`RESULT: 122 passed, 0 failed`**, exit 0. Log cuối `build/T-127-tests-isolated.log`.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. Log `build/T-127-check.log`.
- `pwsh tools/package.ps1`: **`RESULT: package PASS`**, exit 0; đã tự giải nén và chạy EXE bằng `-- --quit-after-frames=60`, không ERROR. ZIP `build/dist/KyTucXa-0.0.1-7af33af-win64.zip`, **40.128.837 byte (38,27 MiB)**. Log `build/T-127-package.log` và các log cạnh ZIP. Snapshot capture, stage và bản giải nén kiểm chứng đã tự dọn.
- Artifact nằm trong build/ (Git ignore), không push ZIP/ảnh/log vào repo; các lệnh trên tái tạo được. Chưa chơi thử gameplay thủ công.

### Phát hiện bổ sung và xử lý trong phạm vi tools
- Lượt test ban đầu: 121/121 PASS. Một lượt sau có 3 test settings UI/player FAIL: file `user://settings.cfg` trống/mất key giữa kiểm tra (`build/T-127-tests-final.log`: 118 passed, 3 failed). Không giấu lượt lỗi hoặc sửa assertion của lane khác.
- Nghi xung đột dữ liệu dùng chung giữa các tiến trình/lane; chưa xác định tiến trình nào ghi đè. Đã xác minh đường dẫn user data qua probe rồi tách APPDATA riêng cho tiến trình Godot chạy test tại `build/test-userdata/<uuid>`. `tools/test.ps1` giữ nguyên cách gọi/Filter, khôi phục môi trường và dọn thư mục trong finally. Test mới kiểm tra OS.get_user_data_dir thực tế nằm trong root riêng. Lượt cuối toàn bộ 122 test PASS, thư mục dữ liệu đã dọn. Không sửa cấu hình project gốc hoặc file UI/player.
- Checkout ban đầu bị sandbox chặn credential Git LFS. Working tree trước đó sạch; đã lưu checkout dở vào stash `Recovery of interrupted T-127 LFS checkout`, chuyển nhánh lại với quyền cần thiết và tải asset thành công. Stash bảo toàn vẫn giữ, không liên quan nội dung commit.

### Còn dở / Yêu cầu thay đổi
- Không còn mục checklist chưa đạt, không còn blocker T-127.
- **Yêu cầu thay đổi ngoài phạm vi: không có.** App của integrator đã được dùng; không cần sửa core hay audio trong task này.
