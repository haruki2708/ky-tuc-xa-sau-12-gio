# T-166 — Công cụ thử chương 1 bản 2: nhảy tới nhiệm vụ, bot 8 nhiệm vụ, đo hiệu năng camera
- Lane: C (QA và Tools) | Trạng thái: doing (công cụ đã merge, chờ chạy trên bản ghép) | Agent:
- Nhánh: `lane-c/T-166-ch1v2-qa-tools`
- Phụ thuộc: T-157. **Đọc `docs/design/CH1_V2_MISSIONS.md`** (D-039…D-042).
- **Hạn:** phần 1 và 3 hết ngày **2026-10-06**; phần 2 chạy trên bản ghép **sáng 2026-10-07**.

## Mục tiêu
Chương 1 bản 2 dài khoảng 60 phút, độ khó Insane, chết là làm lại cả vòng. Người làm và chủ dự án cần nhảy thẳng tới đoạn muốn thử. Bot phải biết làm 8 nhiệm vụ mới. 5 camera an ninh render cùng lúc có thể làm tụt FPS, cần đo.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Menu thử nhanh** (chỉ có trong bản debug và bản chơi thử, ẩn trong bản phát hành; dùng `OS.is_debug_build()` hoặc tham số dòng lệnh `-- --qa-menu`):
   - mở bằng **F9** trong chương 1;
   - **nhảy tới:** đầu mở đầu, vòng 1, mất mạng (4:28), gõ tường (4:38), giữ cửa (4:35), vòng 2, ngay trước khi quản lý tới 407, cứu Minh Nhật. Nhảy bằng cách gọi `Chapter1Director.run_from()` hoặc API nhảy mà integrator cung cấp (ghi yêu cầu vào Handoff nếu cần thêm);
   - **bật/tắt:** bất tử (không chết, chỉ ghi log lý do), hiện đáp án (mã tủ, công tắc đúng, chữ của tiếng gõ), tua nhanh x4;
   - không lưu gì vào bản lưu thật của người chơi.
2. **Bot chương 1 bản 2:**
   - thêm thao tác: gõ tường theo mã (chuỗi số → các lần `wall_tapped` đúng nhịp), bật công tắc ổ điện, cắm dây mạng theo màu, chốt cửa, lục đồ (tủ Việt, nệm, sọt rác), tắt đèn bàn, xem tab camera, nhập mã tủ qua panel;
   - kịch bản mới:
     - `ch1v2_good`: làm đủ 8 nhiệm vụ, xong chương;
     - `ch1v2_wrong_switch`: bật công tắc 3, ổ chập, vẫn sửa được;
     - `ch1v2_door_late`: không chốt cửa kịp, chết, tải lại đầu vòng 1;
     - `ch1v2_lamp_on`: để đèn bàn sáng khi quản lý vào, chết, tải lại đầu vòng 2;
     - `ch1v2_wrong_advice`: chọn sai lời khuyên cho Minh Nhật, thua.
   - Cơ chế nào chưa merge thì `SKIP` có lý do như T-157. Profile mới `tools/ch1v2-profile.json`; integrator điền ID thật khi ghép.
3. **Đo hiệu năng:**
   - phòng 407 mới (khi T-162 merge) ở các góc: cửa, giường, nhà vệ sinh, ban công;
   - **khi tab Camera đang mở** (5 camera SubViewport);
   - ghi JSON như T-157. Mục tiêu ≥ 60 FPS.
4. **Báo cáo** trong Handoff: lệnh chạy, kết quả, thời gian, chỗ kẹt.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Menu thử nhanh dùng được trên `main` hiện tại
- [x] Bot và đo hiệu năng chạy được (SKIP có lý do cho phần chưa ghép)
- [x] Handoff

## Handoff (agent điền)

### 2026-10-05 — Lane C, phần công cụ sẵn sàng review

- Base `origin/main`: `c97874e`. Triển khai: `ae63f67`, đã push `origin/lane-c/T-166-ch1v2-qa-tools` trước commit Handoff này. Chỉ sửa file Lane C và checklist/Handoff card này.
- Menu F9 gắn qua Autoplay, chỉ tạo ở debug hoặc khi có `--qa-menu`. Phiên chơi thường mở **tiến trình QA riêng**, APPDATA dưới `build/qa-menu/`; thao tác QA không ghi checkpoint/progress thật. Mỗi lần nhảy dựng scene mới, gọi `run_from()`; giữ quyền pause và chuột khi đóng menu. Bất tử dùng subclass debug chặn hai hook chết, ghi lý do; x4 dùng Engine.time_scale; đáp án vi/en lấy đúng D-039, có nhãn “bản 2”.
- Đã thử bốn mốc thực trên main: mở đầu, vòng 1, vòng 2, trước quản lý. **Chưa đánh dấu checklist Menu hoàn thành** vì mất mạng, gõ tường, giữ cửa, cứu Minh Nhật chưa có entry point; nút bị khóa với lý do. Không dựng mốc giả hoặc nhảy vào coroutine đang chạy.
- Bot mới có năm template và `tools/ch1v2-profile.json`. Adapter gõ 13 34 đúng khoảng nghỉ, tương tác công tắc/dây/chốt/lục/đèn, mở Sơ đồ/Camera, nhập 2109 bằng nút panel thật, cắm sạc qua API. Binding API/cờ chưa công bố để null; không tự set cờ hoàn thành. Cơ chế thiếu SKIP, schema sai hoặc API có nhưng không xác nhận trạng thái thì FAIL. Hướng dẫn schema trong `tools/README.md`.
- Performance thêm cửa/giường/nhà vệ sinh/ban công và tab Camera. Chỉ đo Camera khi có ≥5 SubViewport chạy UPDATE_ALWAYS và Camera3D, thuộc group cctv_feed; không đếm gương. JSON có phần cứng, cấu hình, mean FPS, p95 frame ms, ngưỡng 60 FPS; góc chưa ghép không có số FPS.

### Đã chạy

| Lệnh | Kết quả thật |
|---|---|
| `pwsh tools/test.ps1` | `RESULT: 360 passed, 0 failed`, exit 0 |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)`, exit 0 |
| `pwsh tools/qa-menu.ps1 -Smoke` | `RESULT: qa-menu PASS (four real stage jumps, F9, invincibility, answers, x4, isolated saves)`, exit 0 |
| `pwsh tools/playthrough.ps1 -V2 -Scenario all` | `RESULT: playthrough 0 passed, 0 failed, 5 skipped`, exit 0 |
| `pwsh tools/playthrough.ps1 -V2 -Scenario all -RequireComplete` | `RESULT: playthrough 0 passed, 0 failed, 5 skipped`, exit **2**, đúng nghĩa “chưa hoàn thành” |
| `pwsh tools/playthrough.ps1 -V2 -Performance` | `RESULT: playthrough 0 passed, 0 failed, 1 skipped`, exit 0 |

- Log: `build/T-166-tests-final.log`, `build/T-166-check-final.log`, `build/T-166-menu-final.log`, `build/T-166-v2-final.log`, `build/T-166-performance.log`.
- Smoke renderer Forward+/Vulkan thực; phát F9 qua Input và thao tác nút toggle thật. Ảnh đã xem: `build/qa-menu/4cc115214cf449cc93b72dcfbd110d6f/userdata/Godot/app_userdata/Ky Tuc Xa Sau 12 Gio/qa-menu.png`. Đọc được tiếng Việt, bốn mốc mới vô hiệu hóa, trạng thái toggle đúng. Chưa export/chạy release; guard release đã rà soát trong source.
- JSON bot có version/base và kết quả từng case: [`tools/reports/T-166-main-scenarios.json`](../../tools/reports/T-166-main-scenarios.json). Lần strict cuối: good **0,322 s**, wrong_switch **0,312 s**, door_late **0,315 s**, lamp_on **0,310 s**, wrong_advice **0,358 s** trong bot; cả năm **0 phút game** vì dừng ở preflight thiếu binding. Đây không phải thời lượng chơi chương 1.
- JSON performance: [`tools/reports/T-166-main-performance.json`](../../tools/reports/T-166-main-performance.json), process **5,86 s**, views rỗng, SKIP cả năm góc. **Chưa đo FPS phòng mới hoặc năm camera; chưa xác nhận ≥60 FPS.** Không dùng số phòng cũ thay thế.

- Regression chương 1 bản đầu: `pwsh tools/playthrough.ps1 -Chapter 1 -ChapterProfile tools/ch1-profile.json -Scenario all` → `RESULT: playthrough 4 passed, 0 failed`, exit 0. Log `build/T-166-ch1-regression.log`. Thời gian trong bot: good 195,77 s / 120 phút game; stay_in_bed 11,28 s / 0 phút; leave_room 56,63 s / 5 phút; own_bed 150,66 s / 103 phút. Case good kiểm tra reload thật giữ pin/lịch sử và mở chương 2; ba case chết xác nhận scene reload thật. Kết quả này thuộc **bản đầu**, không thay cho bản 2.
### Yêu cầu thay đổi ngoài phạm vi / việc tiếp theo

1. **T-160/core:** cung cấp entry point `run_from()` an toàn cho mất mạng 4:28, gõ tường 4:38, giữ cửa 4:35, cứu Nhật (có thể mở rộng STAGES). Điền ID thật trong `jumps`/`bindings`: segment quản lý/nghe, cờ mạng/chập/cửa/gõ/ghép biên bản, tọa độ toilet/phòng mới. Xác nhận cờ chờ tồn tại đủ lâu cho bot quan sát. Không tự suy ID từ giờ trong thiết kế.
2. **T-161/T-163:** sau merge, điền đường dẫn/API và trạng thái xác nhận cho các adapter trong profile. Dây mạng nếu cần hai thao tác cầm rồi cắm trên hai node, Lane C cần bổ sung adapter theo API công bố. Kiểm tra nút panel mới còn đúng đường dẫn và không vượt số lần thử. Xác nhận tab Camera có thể mở bằng UI thật.
3. **T-162/T-165/core:** cung cấp góc nhìn phòng mở rộng và năm feed thật để bind performance. Nếu SubViewport nằm ngoài cây con của node cctv_feed, Lane C cập nhật cách kiểm kê theo cấu trúc thật trước khi đo.
4. Sau ghép: đối chiếu lịch N2/N3/N4 để sửa mạng/gõ tường không bỏ lỡ cửa 10 giây; rà lại hook bất tử nếu pipeline chết thay đổi; chạy năm case với `-RequireComplete` tới **5 PASS/0 SKIP**, xác nhận reload đầu vòng 1/2, rồi đo performance riêng, không đồng thời chạy test/Godot khác. Chưa xác nhận những hành vi này trên bản 2.

**Blocked: phần xác nhận tích hợp bản 2 và bốn mốc menu mới chờ T-160/T-161/T-162/T-163/T-165.** Main hiện tại vẫn là chương 1 bản đầu. Phần công cụ đã kiểm thử có thể review; chưa coi toàn task T-166 hoàn thành.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge phần công cụ.** Đúng phạm vi. Bot bản 2 dùng tương tác thật, không tự đặt cờ hoàn thành; SKIP/FAIL rõ ràng; menu QA tách bản lưu.
- **Integrator đã điền `tools/ch1v2-profile.json`:**
  - cờ trạng thái mới do core giữ tới cuối vòng: `network_lost`, `network_restored`, `door_threat`, `door_safe`, `wall_prompt`, `strip_tripped`, `strip_switch_1..3`, `lan_plugged`;
  - cờ có sẵn: `khoa_hint` (Khoa đã gõ "SO GIUONG"), `form_assembled`, `desk_lamp_on`, `door_locked`, `charging`;
  - segment `r2_manager` và `r2_listen`;
  - đường dẫn thật tới công tắc ổ điện, chỗ lục, tường, chốt cửa, đèn bàn, tủ Đạt, ổ sạc;
  - dây mạng dùng `Chapter1Director.qa_plug_cable(color, player)`: gọi đúng hai lần `interact` thật (cầm dây, rồi cắm vào ổ).
- Còn chờ: `map_tab`/`camera_tab` (T-163 của D), góc đo hiệu năng và 5 feed (T-165 của B), nút nhảy tới mất mạng/gõ tường/giữ cửa/cứu Nhật (core, làm sau bản chơi thử nếu kịp).
- **Integrator sửa bot (`ch1v2_actions.gd`, `ch1v2_bot.gd`):**
  - so sánh an toàn kiểu `_same()`, vì GDScript 4 báo lỗi khi so `bool == String`;
  - JSON đọc số `2` thành `2.0`, nên `power_switch` nhận cả float.
- Core đồng bộ cờ `door_locked` theo chốt thật ở đầu vòng 1.
- **`ch1v2_door_late`: PASS** (315 s thật, chết `DEATH_DRAGGED_OUT`, tải lại `ch1_r1`). Mất mạng, công tắc 2, dây xanh, mạng có lại: đều PASS.

