# T-193 — Chương 3: điền profile bot (`tools/ch3-profile.json`), menu F9 dùng được
- Lane: C | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-193-ch3-bot-profile`
- Phụ thuộc: T-184 (khung bot, đã merge), T-181…T-192 (chương 3 đã ghép). **Đọc** card T-184 (Handoff, Review), `tools/README.md` mục "Profile bot và menu", `docs/playtest/CH3_WALKTHROUGH.md`, `game/scripts/core/chapter3_director.gd`.
- **Hạn: không gấp**; chủ dự án sẽ cho chạy bot sau khi chơi thử xong.

## Việc
Khung bot, menu F9 và công cụ đo FPS đã có (T-184), nhưng các phần `routes`, `bindings`, `menu_actions`, `guard_target` trong `tools/ch3-profile.json` còn `null` nên bot chương 3 và các nút F9 chưa chạy được. Card này điền các phần đó bằng dữ liệu thật của chương 3, thêm test, và kiểm menu F9.

## Dữ kiện core (integrator cung cấp, đã có trên `main`)
Cảnh `res://scenes/main/chapter3.tscn`; node gốc có `Player`, `Chapter3Director`, `Campus`, `Floor4`. Anchor ở `Campus/Anchors/...` (tọa độ toàn cục; tầng 4 ở y = 0, mặt đất y = −9,9).

**Cờ (GameState) và vật tương tác**
| Việc | Cờ postcondition | Gọi thế nào |
|---|---|---|
| Lấy chìa thoát hiểm | `ch3_has_key` = true | node `Campus/Anchors/FireKey/Use_FireKey` (`Ch3Use`), method `interact`, arg `$player`; người chơi đứng gần anchor `FireKey` |
| Mở cửa thoát hiểm | `ch3_fire_door_open` = true | `Campus/Anchors/FireDoor/Use_FireDoor`, `interact` (cần có chìa) |
| Đập bình cứu hỏa (gây tiếng động kéo xác khỏi cửa 203) | `ch3_alarm` = true | `Campus/Anchors/Extinguisher2F/Use_Extinguisher2F`, `interact` |
| Sống qua sân vận động | `ch3_stadium_survived` = true (mới) | tự đặt sau 240 giây trong sân |
| Khu hiện tại | `ch3_zone` = `b` / `garden` / `stadium` / `gate` / `canteen` | chỉ đọc |
| Hết chương | `Progress.unlock(4)` và signal `EventBus.chapter_finished(3)` | |

**Luồng nhà B hiện nay** (đọc `_building_b` trong director): ra khỏi 407; hành lang gần trống, xác trong phòng 406, 405 (và 404…401 nếu đi hướng tây) đập cửa rồi ra khi người chơi tới gần (10 m), phòng 408 bật sau khi lấy chìa; chìa → cửa thoát hiểm → cầu thang tới tầng 2 → đập bình cứu hỏa (ở tường trong cùng chiếu nghỉ tầng 2, anchor `Extinguisher2F`) → **nấp phòng 207** (phòng không cửa, anchor `RoomSpawns/B2/…` không có; điểm trong phòng khoảng (35,75; −6,6; −4,5)) chờ đám 4 xác ở cửa 203 đi vào chiếu nghỉ (khoảng 20 giây) → ra, đi về cầu thang chính (đầu tây) → tầng 1 → phòng quản lý → chui cửa sổ (`requires_crouch`) → vườn hoa. Chi tiết và con số: `docs/tasks/T-191-ch3-room-waves.md`, `T-190`, D-062.
Đồng đội **đi theo sau** người chơi (D-063); bot không cần dẫn họ.

**Móc cho menu/bot (mới, trong `Chapter3Director`):** `debug_zombies_on()`, `debug_zombies_off()`, `debug_give_bar()`, `debug_refill()`; verify được bằng `Chapter3Director/Horde` property `max_active` (40 / 0), `Player` property `stamina` (1,0), `Player.bar_weapon`.
Bảo vệ có tên ổn định `Chapter3Director/Guard01` … `Guard12` (hàng `Campus/Anchors/GuardLine/G01…G12`). Cảnh chết: `DeathScreen/Root` (như `ch2-profile.json`), `death kind` `zombie_grab` / `guard_shock`. Checkpoint `ch3_b`, `ch3_garden`, `ch3_stadium`, `ch3_gate`.

## Yêu cầu
1. **`routes.b|garden|stadium|gate`**: dãy waypoint (anchor hoặc tọa độ tuyệt đối) kèm `action` theo bảng trên; tuyến nhà B theo luồng ở trên, các khu còn lại theo `Campus/Anchors/Paths/Nhat` và `Ngu` (đường thật của đồng đội) rồi `CH3_WALKTHROUGH.md`. Bot không được teleport; đường đi do navmesh.
2. **`bindings`**: `key_taken`, `noise_203`, `stadium_survived` (cờ ở bảng), `death_ui`, `bar_head_path` (vùng đầu trong `Zombie`, xem `scenes/entity/zombie.tscn`: node `HeadHitbox`), `guard_paths` (`Guard01…12`), `grab_stage` (khu mà đứng yên có xác tới tóm; đề xuất `garden`), `guard_target` (waypoint trong hàng bảo vệ, ví dụ `Campus/Anchors/GuardLine/G06`).
3. **`menu_actions`**: `zombies_on/off`, `give_bar`, `refill` gọi bốn hàm `debug_*` ở trên, kèm `verify` bằng property.
4. **Test** (`game/tests/tools/`): schema profile đã điền, các đường dẫn node/anchor tồn tại trong cảnh thật, các hành động gọi được và đặt đúng cờ (dùng cảnh thật `chapter3.tscn`, không dùng fixture cho kết luận này).
5. **Kiểm menu:** `pwsh tools/qa-menu.ps1 -Chapter 3 -Smoke` phải chạy thật (không SKIP), cả bốn khu và bốn nút debug; ghi kết quả.

**Không chạy bot cả chương** (`playthrough.ps1 -Scenario ...`): tốn RAM và lâu; chủ dự án sẽ cho chạy riêng khi sẵn sàng, integrator sẽ chạy. Chỉ chạy test, check và `qa-menu -Smoke`. Đo FPS (`-Performance`) đã có kết quả 2026-10-07 (xem T-181), không cần đo lại.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`, card này (Handoff). Cần API thêm ở core/lane A/B thì ghi vào "Yêu cầu thay đổi", không tự sửa.

## Checklist hoàn thành
- [ ] `routes` 4 khu có action đủ (chìa, cửa, bình, nấp 207, cửa sổ, nhận sắt, sân, bảo vệ, nhà ăn)
- [ ] `bindings`, `menu_actions`, `guard_target` điền thật, không còn `null`
- [ ] Test mới PASS; `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] `qa-menu -Smoke` chạy thật, ghi kết quả
- [ ] Handoff: những gì chưa chắc (đường đi bot có thể sai chỗ nào), yêu cầu ngoài phạm vi

## Handoff (agent điền)

## Review (integrator)
