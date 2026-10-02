# T-115 — Kịch bản tự chơi cả demo
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-115-full-playthrough`
- Phụ thuộc: T-103, T-124, T-127 (done), T-136 (done). Đọc `docs/design/RULES.md` mục 5 và `game/scripts/core/story_director.gd` để biết luồng chơi.

## Mục tiêu
Chủ dự án vừa gặp lỗi kẹt vòng lặp ở đoạn 4 khi chơi thử. Cần một **bot tự chơi hết đêm** để mỗi lần merge đều biết demo còn đi được từ đầu đến cuối, không kẹt và không có lỗi engine. (Card cũ "từ đầu đến luật số 1" được mở rộng thành cả demo.)

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Bot `game/scripts/debug/playthrough_bot.gd`** và scene đi kèm (trong `game/scripts/debug/` hoặc `game/tests/tools/`):
   - instance `res://scenes/main/main.tscn`, đặt `StoryDirector.auto_start = false`, `time_scale` nhỏ (mặc định 0,05), rồi gọi `start()`;
   - chơi bằng **API của game**, không dựng input frame-by-frame:
     - dịch chuyển người chơi tới anchor hoặc vị trí cần thiết;
     - quay camera bằng `rotation` của Player và `Head`;
     - gọi `interact(player)` trên đồ vật (công tắc, chốt cửa, cửa, giấy, điện thoại, vòi `TapTrigger`);
     - "bấm E" lúc điểm danh bằng cách gửi `InputEventAction` `interact` (xem `test_story_segments_3_5.gd`);
   - hai kịch bản:
     - **`correct`:** làm đúng mọi nội quy → kết biến thể 1 (`ending_variant = 1`), mức lệch 0;
     - **`deviant`:** để đèn, mở cửa, quay lại nhìn rồi chạy thoát vào vùng sáng, điểm danh đúng, nhìn gương rồi chạy về phòng và chốt cửa → kết biến thể 2;
   - in một dòng log cho mỗi mốc (`PLAYTHROUGH: seg3 start 00:30 deviation 2`), và dòng cuối `PLAYTHROUGH_RESULT: PASS|FAIL <lý do>`;
   - FAIL khi: quá thời gian từng đoạn, có `restart_requested` ngoài dự kiến, kết sai biến thể, hoặc log có `ERROR`/`SCRIPT ERROR`.
2. **`tools/playthrough.ps1`**: chạy bot headless cho một hoặc cả hai kịch bản (`-Scenario correct|deviant|all`), APPDATA riêng như `test.ps1`, trả exit code khác 0 khi FAIL; tùy chọn `-Capture` chụp ảnh ở mỗi mốc (chạy có cửa sổ).
3. **Ghi chú từ T-135:** chạy riêng `pwsh tools/test.ps1 -Filter smoke` từng báo 42 ObjectDB instances / 3 resources còn lại lúc thoát. Tìm nguyên nhân (thường là audio hoặc scene chưa giải phóng trước khi runner thoát) và sửa trong phạm vi lane C, hoặc ghi rõ thủ phạm vào "Yêu cầu thay đổi".
4. **Tài liệu:** thêm mục "Tự chơi cả demo" vào `tools/README.md`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` và `pwsh tools/playthrough.ps1 -Scenario all` PASS (dán dòng RESULT)
- [ ] Thời gian chạy mỗi kịch bản ghi trong Handoff
- [ ] Handoff: lỗi game tìm thấy trong lúc làm bot (nếu có) ghi thành "Yêu cầu thay đổi", không tự sửa code ngoài phạm vi

## Handoff (agent điền)
