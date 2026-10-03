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
- [x] Thời gian chạy mỗi kịch bản ghi trong Handoff
- [x] Handoff: lỗi game tìm thấy trong lúc làm bot (nếu có) ghi thành "Yêu cầu thay đổi", không tự sửa code ngoài phạm vi

## Handoff (agent điền)

### Lane C — 2026-10-03

- Nhánh tạo từ `origin/main` tại `7dbce51`; commit triển khai `4e55fbc` đã push lên `lane-c/T-115-full-playthrough`.
- Thêm bot/scene chơi qua API thật, launcher headless với APPDATA riêng, timeout từng đoạn và timeout tiến trình, kiểm tra restart/ending/ERROR, log mốc và chụp PNG. Thêm hướng dẫn vào `tools/README.md`. Không ghi ép cờ story hoặc đổi luật để làm xanh kết quả.
- Sửa cleanup smoke: dừng producer/audio trước queue_free và chờ mixer 0,3 giây. Probe verbose trước sửa chỉ ra ba tài nguyên Ogg ambience: `fluorescent_hum.ogg`, `ceiling_fan.ogg`, `night_insects_motorbike.ogg`. Smoke sau sửa không còn 42 ObjectDB / 3 resources hay ERROR khi thoát.

**Kiểm chứng thực tế** (Godot 4.7.2; exit code launcher):

| Lệnh | Kết quả | Exit |
|---|---|---|
| `pwsh tools/test.ps1` | `RESULT: 218 passed, 0 failed` | 0 |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)` | 0 |
| `pwsh tools/test.ps1 -Filter smoke` | `RESULT: 1 passed, 0 failed` | 0 |
| `pwsh tools/playthrough.ps1 -Scenario all` | `RESULT: playthrough 1 passed, 1 failed` | 1 |
| `pwsh tools/playthrough.ps1 -Scenario correct -Capture` | `RESULT: playthrough 1 passed, 0 failed` | 0 |

- Headless correct: bot 22,25 giây; tiến trình 23,51 giây; `PLAYTHROUGH_RESULT: PASS scenario=correct elapsed=22.25s ending=1 deviation=0`.
- Headless deviant: bot 8,29 giây; tiến trình 9,39 giây; `PLAYTHROUGH_RESULT: FAIL scenario=deviant elapsed=8.29s unexpected restart_requested: seg3_start deviation 5 (waiting for corridor chase)`.
- Capture correct: bot 22,36 giây; tiến trình 26,34 giây; đủ 14 PNG cho 14 mốc, ảnh cuối hiển thị “Còn tiếp…”. Chưa kiểm chứng phần deviant sau seg3 hoặc ảnh của các mốc đó vì luồng bị chặn.
- Log local (build được ignore): `build/T-115-tests-verified.log`, `build/T-115-check-verified.log`, `build/T-115-smoke-final.log`; headless trong `build/playthrough/cdb92366c89241509b39d6afe7cd2134/`, ảnh trong `build/playthrough/7b0db9e1340e4d4885ab243abc31e1c7/correct/captures/`. Các lần test/check trong sandbox lỗi quyền certificate/log không được tính PASS; bảng trên là lần chạy lại ngoài sandbox thành công.
- Checklist đầu tiên còn mở vì `-Scenario all` chưa PASS. Bot dùng teleport/API, không chứng minh điều khiển, va chạm hay trải nghiệm thời gian thực 15–20 phút.

**Yêu cầu thay đổi / câu hỏi thiết kế**:

1. **Blocked:** chuỗi deviant của card mâu thuẫn luật đang tích hợp. `game/data/rules/demo.tres`: để đèn +1, mở cửa +2, quay lại +2; tổng 5 chạm `GameState.MAX_DEVIATION` và core yêu cầu restart ở seg3 trước khi chạy thoát. Nếu tới gương còn +2 nữa. Chủ dự án/integrator cần quyết định sửa yêu cầu kịch bản (ví dụ chỉ quay lại + nhìn gương, tổng 4, cần được duyệt và kiểm chứng) hay đổi thiết kế penalty/ngưỡng trong core/data. Lane C chưa sửa card phần yêu cầu, core hoặc dữ liệu luật và chưa chọn thay chủ dự án.
2. Luồng thua deviant còn báo `WARNING: 25 ObjectDB instances were leaked at exit` và `ERROR: 1 resources still in use at exit` dù bot gọi `App.quit()`. Xem `deviant/stderr.log` ở thư mục headless trên; chưa xác định chính xác tài nguyên còn giữ. Đề nghị integrator kiểm tra lifecycle của nhánh loss/restart trong core và phối hợp lane sở hữu tài nguyên; launcher vẫn trả FAIL, không lọc bỏ ERROR.

Phần độc lập đã hoàn tất; dừng phần deviant tại điểm chặn thiết kế theo AGENTS.md mục 6. Cần quyết định thiết kế trước khi xác nhận hai luồng đều hoàn thành demo.
