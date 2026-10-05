# T-184 — Chương 3: bot, menu nhảy 4 khu, đo FPS ngoài trời
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-184-ch3-qa`
- Phụ thuộc: T-166, T-173, T-180. **Đọc `docs/design/CH3_DESIGN.md`** (D-052, D-054).
- **Hạn đề xuất:** đo FPS trên greybox của lane B ngay khi có (2026-10-07…08); khung bot hết ngày 2026-10-08; chạy trên bản ghép sau khi integrator ghép.

## Mục tiêu
Chương 3 là map lớn ngoài trời với tới 40 xác cùng lúc: **FPS là rủi ro lớn nhất**. Đo sớm, báo sớm. Sau đó làm bot và menu thử nhanh cho 4 khu.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Hợp đồng (core, không sửa)
- **Signal** EventBus mục "Chapter 3": `zombie_woke`, `zombie_stunned`, `bar_picked`, `bar_swung`, `bar_broken`, `stamina_changed`, `companion_state_changed`, `guard_warned`; có sẵn: `player_caught`, `player_death_started`, `checkpoint_*`, `chapter_*`.
- **Scene và anchor:** card T-183 (lane B, `res://scenes/levels/campus/campus.tscn`, `Campus/Anchors`, `Zones`); xác và đồng đội: card T-182 (lane A, `Zombie`, `ZombieHorde`, `companion.tscn`, `guard.tscn`).
- **Core (T-181) sẽ có:**
  - `scenes/main/chapter3.tscn`, `Chapter3Director` với `run_from(&"b"|&"garden"|&"stadium"|&"gate")`;
  - checkpoint `ch3_b`, `ch3_garden`, `ch3_stadium`, `ch3_gate`;
  - lý do chết `DEATH_CH3_GRABBED`, `DEATH_CH3_GUARD`.
  Tới lúc đó, dùng scene của lane B và A để đo.

## Yêu cầu
1. **Đo FPS sớm** (`tools/playthrough.ps1 -Performance` hoặc công cụ riêng):
   - greybox khuôn viên, camera đi theo đường đi chuẩn từ phòng 407 tới nhà ăn;
   - đo với 0, 20, 40 xác hoạt động;
   - báo FPS trung bình, thấp nhất, chỗ tụt; so ngưỡng 60 FPS (tối thiểu 30) ở 1280 × 720;
   - ghi kết quả vào Handoff và **báo ngay** nếu dưới ngưỡng, kèm khu và số xác.
2. **Menu F9 chương 3:** nhảy tới 4 khu (đầu nhà B, vườn hoa, sân vận động, cổng); bật/tắt xác; cho thanh sắt; nạp đầy thể lực.
3. **Bot chương 3** (`ch3_bot.gd`, `tools/ch3-profile.json`), dùng chung khung `chapter_bot.gd`. Kịch bản:
   - `ch3_good`: đi hết 4 khu theo đường đồng đội, lấy chìa khóa, gây tiếng động ở 203, nhận thanh sắt, sống qua sân vận động, không lại gần bảo vệ, tới hết chương, mở khóa chương 4;
   - `ch3_grabbed`: đứng yên cho xác tóm → `DEATH_CH3_GRABBED`, nạp đúng khu;
   - `ch3_guard`: đi thẳng vào hàng bảo vệ → `DEATH_CH3_GUARD`, nạp `ch3_gate`.
   Bot đi bằng navmesh, dùng thanh sắt khi xác chắn đường.
4. **Test** (`game/tests/tools/`): policy đường đi, policy đập xác, preflight profile, menu F9.
5. **Không chạy bot thật cả chương** khi chưa có bản ghép và chưa được integrator yêu cầu (tốn RAM, lâu). Đo FPS ngắn (vài phút) thì được.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Kết quả FPS trên greybox (0 / 20 / 40 xác)
- [x] Handoff: lệnh chạy, profile, kết quả

## Handoff (agent điền)

### Phiên 2026-10-06 — bàn giao khung, chưa có kết quả FPS thật
- Base `origin/main`: `b9fcee5`; commit triển khai `8341b1d`, đã push `lane-c/T-184-ch3-qa` trước khi ghi Handoff.
- Thêm `-Chapter 3`, profile `tools/ch3-profile.json`, ba case good/grabbed/guard dùng lớp `chapter_bot.gd`. Player đi bằng input theo navmesh; kiểm tra endpoint, tránh vùng bảo vệ, nhắm/raycast vùng đầu xác trước khi vung sắt. Good cần mốc lấy chìa/gây tiếng động 203/sống qua sân, đồng đội, nhận sắt, hoàn thành chương và unlock 4. Case âm tính kiểm tra lý do chết/khu/kind/UI/checkpoint và scene mới. Chưa chạy các luồng này trên bản ghép.
- Thêm menu F9 bốn khu và binding thao tác bật/tắt xác, cho sắt, nạp thể lực. Nút thiếu scene/API bị khóa. Menu dùng phiên QA/bản lưu riêng; không sửa progress/checkpoint thật.
- Benchmark renderer riêng dựng Floor4 + Campus và Zombie thật, không chạy story: camera theo navmesh từ 407 tới nhà ăn, mức 0/20/40 xác; kiểm tra trạng thái active mỗi frame; JSON theo khu/anchor, mean/min FPS, p95/max frame ms, phần cứng; cảnh báo `CH3_PERF_ALERT` ngay khi mean <60 hoặc min <30. Không dùng fixture/khối hộp thay Campus hoặc xác để tạo số FPS.
- Sáu test công cụ: đường navmesh/guard radius, policy vung sắt, preflight, thống kê FPS, signal/input cleanup, menu/controls bằng fixture. Fixture trong `tests/tools/fixtures/` chỉ phục vụ unit test.
- Schema và cách điền profile chi tiết trong `tools/README.md`; các trường chưa có hợp đồng thật để null, không tự đoán cờ/core API.

### Kiểm tra đã chạy
| Lệnh | Kết quả | Bằng chứng |
|---|---|---|
| `pwsh tools/test.ps1 -Filter ch3_` | `RESULT: 6 passed, 0 failed` (exit 0) | `build/T-184-focused.log` |
| `pwsh tools/test.ps1` | `RESULT: 517 passed, 0 failed` (exit 0) | `build/T-184-tests.log`; bản triển khai cuối |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)` (exit 0) | `build/T-184-check.log` |
| `pwsh tools/playthrough.ps1 -Chapter 3 -Performance -RequireComplete` | `RESULT: playthrough 0 passed, 0 failed, 1 skipped` (exit 2) | `tools/reports/T-184-main-performance.json`; launcher 4,82 giây, preflight 0,001 giây; chưa lấy mẫu frame |
| `pwsh tools/qa-menu.ps1 -Chapter 3 -Smoke` | `RESULT: qa-menu SKIP chapter3 (T-181 scene/stage unavailable; menu rendered)` (exit 2) | `build/T-184-menu.log` |

- Hai launcher PowerShell đã qua parser, không có lỗi cú pháp.
- Lần test trong sandbox có engine error đọc kho chứng chỉ Windows dù sáu assertion test PASS; đã chạy lại ngoài sandbox và nhận exit 0 như bảng. Không bỏ qua engine error.
- **FPS 0 / 20 / 40:** cả ba SKIP. Mức 0 thiếu Campus và tuyến anchor; mức 20/40 còn thiếu Zombie, spawn_paths, active_property/value. JSON có `measurements: []`, không có số FPS. Mục checklist FPS giữ chưa hoàn thành; chưa thể kết luận ≥60/≥30.
- Artifact performance: `build/playthrough/a37f6f00783f4c8ea42876f5f648f8ba/performance/`; GPU renderer khởi động là RTX 3050 Laptop/Forward+, chưa đo scene.
- Đã xem ảnh menu `build/qa-menu/aefbb85af61c46c29e972b7773ba8e30/userdata/Godot/app_userdata/Ky Tuc Xa Sau 12 Gio/ch3-menu.png`: chữ tiếng Việt đọc được, bốn khu và bốn nút debug bị khóa do thiếu scene/API. Test fixture xác nhận handler F9/pause, bốn jump và postcondition của controls; **chưa xác nhận jump/controls với Chapter3Director và gameplay thật**.

### Lệnh tiếp tục sau tích hợp
Đo ngắn ngay khi có greybox và API A, chạy riêng để tránh nhiễu:

```powershell
pwsh tools/playthrough.ps1 -Chapter 3 -Performance -RequireComplete
pwsh tools/qa-menu.ps1 -Chapter 3 -Smoke
```

Chỉ chạy bot sau khi có bản ghép và integrator yêu cầu (chưa chạy trong phiên này):

```powershell
pwsh tools/playthrough.ps1 -Chapter 3 -Scenario ch3_good -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 3 -Scenario ch3_grabbed -RequireComplete
pwsh tools/playthrough.ps1 -Chapter 3 -Scenario ch3_guard -RequireComplete
```

### Yêu cầu thay đổi ngoài phạm vi / Blocked
- **Blocked: main hiện chưa có Campus của T-183, Zombie của T-182 và Chapter3Director/scene của T-181.** Chưa thể đo FPS thật hoặc xác nhận bot/menu end-to-end. Không chạy bot cả chương để dò khi thiếu bản ghép.
- Lane B/integrator: cung cấp greybox + Floor4 cùng navmesh liên thông 407 → nhà ăn, tuyến waypoint thật theo đồng đội qua đủ b/garden/stadium/gate/canteen và phân bố ít nhất 40 spawn anchor khác nhau. Điền profile rồi báo Lane C để đo sớm; cần waypoint tại chỗ nghi tụt FPS để báo đúng khu.
- Lane A/integrator: công bố node/property/value để xác nhận Zombie đang active, NodePath vùng đầu, đủ đường dẫn guard, target trao sắt và API refill thể lực. Cần API bật/tắt xác bao gồm kiểm soát đợt spawn mới, không chỉ xóa các xác hiện tại. Không tự thêm API vào core/player/horde.
- Core/integrator: điền postcondition lấy chìa/gây tiếng động 203/sống qua sân, action API tại waypoint, death UI, điểm bắt đầu case grabbed và guard_target; scene/director/run_from theo card. Xác nhận profile với A/B rồi chạy ba case khi được yêu cầu.
- Không có câu hỏi mới về luật/cốt truyện; không sửa STATUS, core/gameplay/map, không thêm plugin, không cài phần mềm. Khung và test đã bàn giao; FPS và xác nhận trên bản ghép còn dở.
