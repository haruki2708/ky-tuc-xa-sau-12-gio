# T-173 — Chương 2: bot, menu nhảy tới đoạn, đo hiệu năng hơi nước
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-173-ch2-qa`
- Phụ thuộc: T-166. **Đọc `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn:** phần khung hết ngày 2026-10-07; chạy trên bản ghép ngày 2026-10-08.

## Mục tiêu
Kiểm thử chương 2 tự động như chương 1 bản 2 (T-166).

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Bot chương 2** (`-Chapter 2`, profile `tools/ch2-profile.json`, integrator điền ID thật khi ghép). Thao tác mới:
   - trả lời nối từ: chọn phương án theo luật (tiếng đầu khớp đúng dấu, không lặp trong 3 lượt), chọn từ cụt để gài bẫy, chọn theo vòng lặp;
   - cầm đồ, bịt miệng xác, đẩy cửa, đứng trong / ra khỏi buồng tắm, lau màn hình, chọn Có/Không theo quy luật nhiệt độ.
2. **Kịch bản:**
   - `ch2_good`: hết chương;
   - `ch2_chain_timeout`: để hết 15 giây, chết, tải lại đầu vòng 3;
   - `ch2_chain_wrong`: chọn từ sai dấu, chết;
   - `ch2_scald`: chọn Có ở lượt 81 độ, chết bỏng, tải lại đầu vòng 4;
   - `ch2_leave_shower`: chọn Có rồi bước ra, chết;
   - `ch2_lost_ngu`: trả lời sai cho Ngư, thua.
   Cơ chế nào chưa ghép thì `SKIP` có lý do như T-166.
3. **Menu F9:** nhảy tới đầu vòng 3, đầu vòng 4, và các mốc giữa vòng mà core cung cấp; hiện đáp án (từ đúng, Có/Không đúng theo quy luật).
4. **Đo hiệu năng:** nhà vệ sinh với hơi nước 0 và 1, nước nóng đang chảy; mục tiêu ≥ 60 FPS. JSON như T-166.
5. **Báo cáo** trong Handoff: lệnh chạy, kết quả, thời gian.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Bot và đo hiệu năng chạy được (SKIP có lý do cho phần chưa ghép)
- [x] Handoff

## Handoff (agent điền)

### Phiên 2026-10-05 — khung QA hoàn tất, chờ bản ghép
- Base `origin/main`: `c68888b`; commit triển khai: `95c6166`, đã push `lane-c/T-173-ch2-qa` trước khi viết Handoff.
- Thêm `-Chapter 2`, sáu case, profile để integrator điền ID/API thật; chưa tự đặt ID gameplay. Bot quan sát EventBus, kiểm tra dấu tiếng Việt / ba từ gần nhất / từ cụt / đường vào vòng tám từ, dự đoán nước chỉ từ nhiệt độ đã thấy. Thao tác vật lý cần trạng thái hoặc signal thật xác nhận; không tự đánh dấu hoàn thành gameplay.
- Menu debug F9 có vòng 3/4 và hỗ trợ mốc bổ sung từ profile, hiện đáp án, chạy với userdata riêng. Bản chưa ghép vô hiệu hóa nút nhảy. Đã xem ảnh smoke: chữ đọc được, hai nút đang bị vô hiệu hóa; chưa xác nhận nhảy cảnh thật hay thao tác F9 trong chương 2.
- Đo hiệu năng dùng nhà vệ sinh thật, nước nóng đang chảy, steam 0/1; kiểm tra trạng thái trong từng frame, xuất JSON. Không có scene thì SKIP, không đo cảnh thay thế.
- Thêm tám test công cụ: dấu, lịch sử, đường nối/vòng lặp, bẫy, chuỗi 30 nhiệt độ, observer, thiếu binding, xác nhận signal vật lý. Hướng dẫn schema và lệnh nằm trong `tools/README.md`.

### Kiểm tra và bằng chứng
Chạy tại `D:\GAME_WORK\lane-c`, Godot 4.7.2, ngày 2026-10-05:

| Lệnh | Kết quả | Bằng chứng / thời gian |
|---|---|---|
| `pwsh tools/test.ps1` | `RESULT: 422 passed, 0 failed` (exit 0) | `build/T-173-tests-final.log`; bao gồm cả 8 test mới. Không ghi nhận tổng wall-clock của runner. |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)` (exit 0) | `build/T-173-check-final.log` |
| `pwsh tools/playthrough.ps1 -Chapter 2 -Scenario all -RequireComplete` | `RESULT: playthrough 0 passed, 0 failed, 6 skipped` (exit 2) | `tools/reports/T-173-main-scenarios.json`; mỗi case khoảng 0,01–0,02 giây, 0 phút gameplay do dừng ở preflight. |
| `pwsh tools/playthrough.ps1 -Chapter 2 -Performance -RequireComplete` | `RESULT: playthrough 0 passed, 0 failed, 1 skipped` (exit 2) | `tools/reports/T-173-main-performance.json`; report 0,001 giây, launcher khoảng 4,34 giây; `views: []`, chưa có FPS. |
| `pwsh tools/qa-menu.ps1 -Chapter 2 -Smoke` | `RESULT: qa-menu SKIP chapter2 (T-170 scene/stage unavailable; menu rendered)` (exit 2) | Log `build/T-173-menu.log`; đã render menu, chưa chạy jump. |

- Artifact bot: `build/playthrough/39d4a673d0df4e4c90e837595d157b89`; performance: `build/playthrough/25355fd2e11148279b11b8c2c4631703`.
- Ảnh menu: `build/qa-menu/20af61ee902045a6afac85c3cf5da920/userdata/Godot/app_userdata/Ky Tuc Xa Sau 12 Gio/ch2-menu.png`.
- Các file `build/` là artifact cục bộ; hai báo cáo JSON trong `tools/reports/` được commit. Exit 2 của `-RequireComplete` phản ánh SKIP, không phải PASS toàn chương.

### Còn dở / Blocked
- **Blocked: bản main hiện chưa có `chapter2.tscn`, director chương 2, lexicon và các binding gameplay/hiệu năng.** Sáu case đều SKIP có lý do; chưa kiểm chứng end-to-end cái chết, reload `ch2_r3/ch2_r4`, mở khóa chương 3, menu nhảy thật hoặc ≥60 FPS.
- Checklist bot/hiệu năng được đánh dấu theo ngoại lệ SKIP có lý do trong card. Đây là bàn giao khung; bước chạy trên bản ghép ngày 2026-10-08 và playtest vẫn còn chờ.
- Sau khi ghép T-170/T-171/T-172/T-174 và phần liên quan: điền profile theo README, chạy lại ba lệnh Chapter 2 ở trên; xử lý mọi FAIL và SKIP còn lại trước khi kết luận chương 2 đạt.
- Chưa chạy export/release cho thay đổi này; chỉ kiểm tra guard debug bằng mã nguồn và test hiện có.

### Yêu cầu thay đổi ngoài phạm vi
- Integrator/core (T-170): cung cấp scene/director, API `start()` / `auto_start`, `run_from(stage_id)` hoặc thông báo API thay thế; ID vòng 3/4 và các mốc giữa vòng; lexicon thật có text/valid/dead_end; đường dẫn death UI, checkpoint/reload, choice ID/indices và ba nhiệt độ Ngư, cờ nhiệt độ tại thời điểm chết bỏng 81°C. Profile để trống cho các API chưa công bố; cần xác nhận khi ghép.
- Lane A/D và integrator: cung cấp node path, method/args, tọa độ và signal/property xác nhận cầm từng đồ, bịt giường 1/2/4, ba lần đẩy cửa, vào/ra buồng tắm, lau màn hình; trạng thái nước nóng đang chảy và mức hơi nước để đo liên tục. Không cần thêm signal nếu component hiện có đã đủ xác nhận.
- Lane B/D/core: cung cấp góc camera nhà vệ sinh và cách dựng trạng thái steam 0/1 với nước nóng đang chảy cho bài đo thật.
- Không sửa file ngoài phạm vi; không sửa `tools/godot-path.ps1` hay `docs/STATUS.md`; không cài phần mềm/plugin. Không có câu hỏi thiết kế/cốt truyện mới; các mục còn chờ là hợp đồng tích hợp.
