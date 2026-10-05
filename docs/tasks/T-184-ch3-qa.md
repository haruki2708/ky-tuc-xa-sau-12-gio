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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Kết quả FPS trên greybox (0 / 20 / 40 xác)
- [ ] Handoff: lệnh chạy, profile, kết quả

## Handoff (agent điền)
