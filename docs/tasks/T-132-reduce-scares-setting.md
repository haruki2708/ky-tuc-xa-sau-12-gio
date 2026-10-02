# T-132 — Tùy chọn "Giảm hù dọa"
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
