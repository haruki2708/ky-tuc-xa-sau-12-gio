# T-132 — Tùy chọn "Giảm hù dọa"
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done | Agent:
- Nhánh: `lane-d/T-132-reduce-scares`
- Phụ thuộc: T-116 (done). **Đọc `docs/SETTINGS.md`** (mục mới `[accessibility] reduce_scares`) và `docs/design/RULES.md` mục 5b (D-024).

## Mục tiêu
Người dễ hoảng vẫn chơi được: một công tắc trong Cài đặt làm giảm hù dọa. Lane D chỉ thêm mục cài đặt; integrator và lane A đọc mục này để đổi cách hù dọa.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`

## Yêu cầu
1. `settings.gd`: thêm `[accessibility] reduce_scares` (bool, mặc định `false`) vào `SCHEMA`, đúng hợp đồng `docs/SETTINGS.md`: đọc sai kiểu thì về mặc định; `set_value` lưu file rồi emit `settings_changed("accessibility", "reduce_scares")`.
2. Màn Cài đặt: thêm nhóm **"Trợ năng"** có công tắc **"Giảm hù dọa"**, kèm dòng giải thích nhỏ: "Bỏ hình ảnh và âm thanh giật mình đột ngột. Truy đuổi chậm hơn." (cả `vi` và `en`). "Khôi phục mặc định" đưa về `false`.
3. **Test `game/tests/ui/`:** mặc định `false`; bật công tắc thì lưu `true` và emit đúng section/key; sai kiểu thì đọc về `false`; nút khôi phục đưa về `false`. Sao lưu và khôi phục `user://settings.cfg` như các test trước.
4. Ảnh chụp màn Cài đặt có nhóm mới, tiếng Việt.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Đã làm
- Lane D, ngày 2026-10-02; nhánh `lane-d/T-132-reduce-scares`, tạo từ `origin/main` tại `aca2d8a`. Commit triển khai `27357ec` đã push.
- Thêm `[accessibility] reduce_scares` vào `Settings.SCHEMA`: boolean, mặc định `false`, sai kiểu trở về mặc định; tái sử dụng cơ chế lưu file trước khi emit `settings_changed("accessibility", "reduce_scares")`.
- Panel Cài đặt có nhóm Trợ năng, công tắc Giảm hù dọa và mô tả nhỏ, tự xuống dòng. Thêm ba key VI/EN; đổi ngôn ngữ trực tiếp, mở lại giữ giá trị đã lưu và Khôi phục mặc định đưa công tắc về `false`.
- Không thêm plugin, công cụ, asset bên ngoài hay thay đổi hành vi hù dọa/truy đuổi. Chỉ commit file thuộc phạm vi và checklist/Handoff này.

### Kiểm tra và ảnh
- `pwsh tools/test.ps1`: **RESULT: 170 passed, 0 failed**.
- `pwsh tools/check.ps1`: **RESULT: check 0 error(s)**.
- Thêm hai test UI: click công tắc khi tạm dừng, xác nhận boolean đã có trong file ngay lúc nhận signal đúng section/key; đọc bằng instance mới, mở lại menu, tắt/bật và khôi phục; kiểm tra nhãn/mô tả VI/EN. Mở rộng test hợp đồng mặc định, sai kiểu và từ chối ghi kiểu không hợp lệ cho key mới. Fixture hiện có sao lưu/khôi phục `user://settings.cfg` nguyên byte; launcher cô lập dữ liệu test trong `build/`.
- Lượt UI trong sandbox có `43 passed, 0 failed` nhưng launcher báo FAIL vì Godot không đọc được kho chứng chỉ Windows; đã chạy lại toàn bộ ngoài sandbox và đạt kết quả cuối ở trên. Test/check còn cảnh báo UID texture từ cache model cũ (dùng đường dẫn thay thế); không có lỗi engine/parse trong lượt cuối.
- Đã render và xem [ảnh Cài đặt tiếng Việt](../../game/ui/pause/previews/reduce_scares_vi.png) ở 1920×1080: nhóm mới, công tắc và toàn bộ mô tả hiển thị rõ. Ảnh cùng `.import` đã commit, PNG qua Git LFS.
- Tái tạo ảnh: chạy Godot với `--path game res://ui/pause/pause_test.tscn --windowed --write-movie <thư mục>/frame.png --fixed-fps 30 -- --capture-settings --quit-after-frames=5`.
- Kiểm tra bằng tay: mở scene `pause_test.tscn` bằng F6 → Esc → Cài đặt → Giảm hù dọa; bật rồi mở lại menu; đổi VI/EN; Khôi phục mặc định phải tắt công tắc. Đã kiểm tra bằng input tự động và ảnh render; chưa chơi thử hiệu ứng hù dọa/truy đuổi thực tế.

### Còn lại / Yêu cầu thay đổi
- Không còn checklist chưa đạt hoặc blocker phía Lane D. Lỗi checkout do sandbox chặn Git LFS đã xử lý; giữ stash `Recovery: interrupted LFS checkout before T-132` để có thể phục hồi, không đưa nội dung này vào nhánh task.
- **Core/A/E áp dụng theo D-024:** đọc `user://settings.cfg` bằng `ConfigFile` lúc khởi tạo và khi nhận `EventBus.settings_changed("accessibility", "reduce_scares")`; thiếu/sai kiểu dùng `false`. StoryDirector bỏ hình ảnh hù đột ngột và sting mạnh, thực thể truy đuổi chậm hơn, giảm tiếng thì thầm; hậu quả đoạn 1–2 giữ nguyên. Lane D chỉ cung cấp cài đặt, không tự sửa các file sở hữu bởi lane khác.
- Không cần thêm signal, autoload, input action hay sửa hợp đồng `docs/SETTINGS.md`; mục mới đã có trong hợp đồng. Không có câu hỏi mới về luật chơi/cốt truyện.

## Review (integrator, 2026-10-03)
**Kết quả: chấp nhận, đã merge vào `main`.** Sau merge: `test.ps1` → `RESULT: 173 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi, đúng hợp đồng `docs/SETTINGS.md`. Nhóm "Trợ năng" và công tắc "Giảm hù dọa" có mô tả song ngữ; test bấm công tắc thật khi đang tạm dừng.
- Integrator nối vào `StoryDirector` (đọc lúc khởi động và khi `settings_changed`), có test `test_director_follows_reduce_scares_setting`. Hiệu ứng thật của tùy chọn sẽ thấy ở đợt 2 (cú hù, truy đuổi).

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
