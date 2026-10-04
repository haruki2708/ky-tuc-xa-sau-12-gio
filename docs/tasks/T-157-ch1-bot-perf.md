# T-157 — Bot chơi chương 1, đo hiệu năng, kiểm tra lưu game
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-157-ch1-bot-perf`
- Phụ thuộc: T-115 (bot cũ). Phần cuối cần T-150 ghép xong. Đọc `docs/design/STORY.md` v2 §5 và `tools/README.md`.
- **Hạn:** phần công cụ hết ngày **2026-10-05**; chạy trên bản ghép **2026-10-07**.

## Mục tiêu
Chương 1 dài khoảng 50 phút, có nhiều cách chết. Mỗi lần ghép đều cần bot chơi trọn chương, kiểm tra các nhánh chết đều tải lại checkpoint đúng, và đo FPS.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Bot hiểu cơ chế mới** (`playthrough_bot.gd`, `Autoplay`):
   - nằm lên một giường theo số (`bunk_spot` của T-151), rời giường;
   - nín thở N giây; đứng yên không xoay camera;
   - giơ/hạ điện thoại; bắt máy (`phone_call_answered`);
   - chọn lựa chọn trong cuộc gọi (`chat_choice_made`);
   - giải câu đố (phát `puzzle_solved` hoặc nhập qua panel nếu đã có);
   - đi tới một điểm.
   - Cơ chế nào chưa merge thì bỏ qua hành động đó, ghi `SKIP` kèm lý do, không làm fail cả lượt.
2. **Kịch bản chương 1** (`tools/playthrough.ps1 -Chapter 1 -Scenario …`):
   - `ch1_good`: rời giường trong 60 giây, đi vệ sinh rồi về, không ra khỏi phòng sau Tổng tắc, bắt máy, lấy sạc, khi quản lý tới thì nằm giường của bạn và nín thở. Tới cuối chương: `Progress.unlocked_chapter() >= 2`.
   - `ch1_stay_in_bed`: không rời giường lúc mở đầu, nên chết; kiểm tra màn chết và tải lại.
   - `ch1_leave_room`: ra khỏi phòng ở vòng 1, nên chết; kiểm tra tải lại đầu vòng 1.
   - `ch1_own_bed`: nằm giường của mình khi quản lý tới, nên chết; kiểm tra tải lại checkpoint trước khi quản lý vào.
   - Dùng file `progress` và `checkpoint` tạm.
   - Ba kịch bản demo cũ: giữ chạy được tới khi integrator thay luồng chương. Khi bỏ thì ghi rõ trong Handoff.
3. **Đo hiệu năng:** các góc cố định trong phòng 407 (nhìn từng giường, nhìn cửa), hành lang tầng 4, nhà vệ sinh. FPS trung bình và p95 như T-112, ghi JSON.
4. **Kiểm tra lưu game:** tải lại giữa chương giữ `GameState.chapter`, pin điện thoại, lịch sử cuộc gọi (khi T-155 có `snapshot/restore`); chọn chương 2 khi chưa mở thì không vào được.
5. **Báo cáo** trong Handoff: thời gian trong game và thời gian thật của mỗi kịch bản; chỗ bot bị kẹt.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Công cụ chạy được trên `main` hiện tại (bỏ qua có lý do phần chưa có)
- [ ] Sau khi integrator ghép: 4 kịch bản PASS, số đo FPS
- [x] Handoff: lệnh chạy, kết quả, chỗ kẹt

## Handoff (agent điền)

### Lane C — phần công cụ, 2026-10-04

- Nhánh tạo từ `origin/main` tại `37bdfa7`; commit công cụ `8ac367e` đã push lên `lane-c/T-157-ch1-bot-perf`. Chỉ sửa debug, tests/tools, tools và checklist/Handoff của card này.
- Thêm `chapter_actions.gd` dùng chung cho bot và Autoplay: giường theo số/rời giường, nín thở/đứng yên không quay camera, giơ/hạ điện thoại, bắt cuộc gọi đang tới, chọn lựa chọn đang chờ, giải station câu đố, teleport tới điểm. Thiếu component trả SKIP; dữ liệu sai hoặc component có nhưng không làm đúng trả FAIL. Autoplay theo dõi signal ngay từ lúc khởi động để không bỏ lỡ cuộc gọi trước command đầu tiên; timeline dừng trong lúc command chờ.
- Thêm bốn template trong `game/scripts/debug/ch1_scenarios.json`, observer chương 1, profile mẫu `tools/ch1-profile.example.json`. Các ID đoạn/checkpoint/lựa chọn và thời lượng nín thở chưa được core công bố nên để null, không đoán. Khi đủ binding, observer chạy template và kiểm tra tín hiệu hoàn thành/mở chương hoặc nguyên nhân chết, UI hiện, scene thực sự thay thế và checkpoint tải lại.
- Launcher hỗ trợ `-Chapter 1`, đếm SKIP riêng; `-RequireComplete` trả exit 2 nếu còn SKIP, lỗi thật trả 1. `progress`/`checkpoint` nằm trong APPDATA riêng và được dọn; bot chương kiểm tra prefix user data trước khi dùng API lưu. Lượt probe thoát sớm được dừng âm thanh/free scene/drain trước `App.quit()`; không lọc bỏ ERROR.
- Probe/test đã kiểm chứng `GameState.chapter` qua checkpoint tạm và Progress độc lập. Có bước kiểm tra reload scene giữ pin/lịch sử bằng API thực khi T-151/T-155 có mặt; **chưa chạy được bước đó**, chưa xác minh UI khóa chương 2. Không tự thêm dữ liệu pin/chat vào checkpoint để thay công việc của core.
- Thêm benchmark renderer thật bảy góc, JSON có CPU/GPU/renderer/cấu hình/camera, FPS trung bình và p95 frame ms. Giữ cả ba luồng demo cũ, chưa bỏ luồng nào. Hướng dẫn đầy đủ ở `tools/README.md`.

**Lệnh và kết quả đã chạy:**

| Lệnh | Dòng RESULT | Exit |
|---|---|---|
| `pwsh tools/test.ps1` | `RESULT: 265 passed, 0 failed` | 0 |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)` | 0 |
| `pwsh tools/playthrough.ps1 -Scenario all` | `RESULT: playthrough 3 passed, 0 failed` | 0 |
| `pwsh tools/playthrough.ps1 -Chapter 1 -Scenario all -ChapterProfile tools/ch1-profile.example.json` | `RESULT: playthrough 0 passed, 0 failed, 4 skipped` | 0 |
| `pwsh tools/playthrough.ps1 -Chapter 1 -Scenario all -RequireComplete` | `RESULT: playthrough 0 passed, 0 failed, 4 skipped` | 2 (đúng yêu cầu CI) |
| `pwsh tools/playthrough.ps1 -Performance` | `RESULT: playthrough 1 passed, 0 failed` | 0 |

**Thời gian thực / trong game:**

| Kịch bản | Bot (giây thật) | Tiến trình (giây thật) | Thời gian trong game | Kết quả |
|---|---|---|---|---|
| ch1_good | 0,09 | 1,62 | 0 phút (chỉ probe) | SKIP |
| ch1_stay_in_bed | 0,07 | 1,80 | 0 phút (chỉ probe) | SKIP |
| ch1_leave_room | 0,06 | 1,46 | 0 phút (chỉ probe) | SKIP |
| ch1_own_bed | 0,07 | 1,46 | 0 phút (chỉ probe) | SKIP |
| demo correct | 83,05 | 84,31 | 23:50–01:40, 110 phút | PASS, ending 1 / lệch 0 |
| demo deviant | 83,99 | 85,18 | 23:50–01:40, 110 phút | PASS, ending 2 / lệch 4 |
| demo mirror | 84,82 | 85,98 | 23:50–01:40, 110 phút | PASS, ending 1 / lệch 2 |

Các con số chương 1 trên **không phải thời gian chơi hết chương**. Probe không khởi động luồng demo để giả làm chương mới. Không có lượt nào kẹt ở bản công cụ cuối; lượt chưa có cơ chế dừng ở SKIP. Bộ test cuối bổ sung hồi quy cho việc nhận signal trước command đầu tiên; probe và benchmark không xác nhận hành vi cơ chế thật chưa merge.

**FPS trên main hiện tại, chưa phải bản ghép chương 1:** Ryzen 5 5600H, RTX 3050 Laptop, Godot 4.7.2 Forward+/Vulkan, 1280×720, VSync/max FPS tắt. Mỗi góc warm-up 90 frame, đo 240 frame thời gian thực; story tắt, physics/HUD/audio chạy. Lượt đo hoàn tất trước lượt chạy demo. JSON đã commit: [T-157-main-performance.json](../../tools/reports/T-157-main-performance.json).

| Góc | FPS trung bình | p95 frame (ms) |
|---|---|---|
| Giường 1 Phúc | 524,94 | 1,944 |
| Giường 2 Việt | 524,02 | 1,967 |
| Giường 3 Trung | 525,41 | 1,947 |
| Giường 4 Đạt | 514,17 | 2,146 |
| Cửa 407 | 528,67 | 1,953 |
| Hành lang | 562,10 | 2,374 |
| Nhà vệ sinh | 537,42 | 2,501 |

Log local (build được ignore): `build/T-157-tests-final.log`, `build/T-157-check-final.log`, `build/T-157-demo.log`, `build/T-157-chapter-final.log`, `build/T-157-chapter-strict.log`, `build/T-157-performance.log`. JSON từng probe chương nằm trong `build/playthrough/4413cbc4867a45e6b7592894d916a68a/<scenario>/report.json`.

**Yêu cầu thay đổi / thông tin ngoài phạm vi:**

1. T-150: sau khi ghép, cung cấp ID thật cho các binding trong profile mẫu: đoạn mở đầu/vòng 1/trước quản lý, checkpoint của ba nhánh chết, rule ID báo qua `player_failed`, puzzle sạc, lựa chọn báo lời giải cho Nhật/index đúng và cửa sổ nín thở. Cung cấp path UI chết. Nếu API/tên node khác hợp đồng đã đọc, Lane C sẽ điều chỉnh adapter theo API công bố, không yêu cầu đổi cốt truyện để khớp bot.
2. T-151/T-155/T-150: cần phone_item, phone_screen có snapshot/restore và đường lưu/khôi phục pin/lịch sử thật trong checkpoint; cần scene/path nút chọn chương 2. Hiện chỉ có hợp đồng signal/Progress, nên chưa kết luận PASS cho pin/lịch sử hoặc khóa UI. Chưa phát hiện lỗi sản phẩm ở các phần này vì chúng chưa tích hợp.

**Blocked (phần kiểm chứng bản ghép):** T-150 chưa có luồng chương 1, T-151/T-155 chưa có component/UI trên main này. Phần công cụ đã hoàn tất để review; checklist thứ ba giữ mở. Khi có bản ghép, điền profile thật, đối chiếu tọa độ với T-153, chạy `-Chapter 1 -Scenario all -RequireComplete` (phải 4 PASS, 0 SKIP), kiểm chứng reload pin/lịch sử/chọn chương rồi đo lại `-Performance`. Không coi số đo main hiện tại hoặc template chưa chạy là bằng chứng chương 1 hoàn thành.
