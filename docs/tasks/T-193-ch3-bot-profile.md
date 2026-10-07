# T-193 — Chương 3: điền profile bot (`tools/ch3-profile.json`), menu F9 dùng được
- Lane: C | Trạng thái: done | Agent:
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
- [x] `bindings`, `menu_actions`, `guard_target` điền thật, không còn `null`
- [ ] Test mới PASS; `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] `qa-menu -Smoke` chạy thật, ghi kết quả
- [x] Handoff: những gì chưa chắc (đường đi bot có thể sai chỗ nào), yêu cầu ngoài phạm vi

## Handoff (agent điền)

### 2026-10-07 — Lane C, T-193

**Blocked: tuyến navmesh thật không tới điểm nấp 207 và nhiều waypoint ngoài trời; cần lane B/integrator sửa map. Không bỏ test lỗi hoặc sửa file ngoài phạm vi để tạo PASS.**

- Base: `origin/main` tại `61af631`; nhánh `lane-c/T-193-ch3-bot-profile`. Commit thực hiện `132459b` đã push trước khi điền Handoff này. Chỉ làm tại `D:\GAME_WORK\lane-c`.
- Điền cả bốn tuyến: mở cửa 407, chìa, cửa thoát hiểm, hai tầng cầu thang, bình cứu hỏa, nấp 207 chờ 20 giây, cầu thang chính, cửa sổ có cúi, gặp Ngư và đợi sắt, vòng sân tới cờ sống sót, tránh bảo vệ, tới nhà ăn. Tuyến dùng các điểm Nhat theo card và tọa độ thật; **đã điền nhưng chưa coi tuyến dùng được** vì audit navmesh FAIL.
- Điền cờ milestone, DeathScreen/Root, HeadHitbox, 12 Guard, grab_stage=garden và GuardLine/G06. Không thay phần performance đã có.
- Adapter đi bằng navmesh/input hỗ trợ tọa độ tuyệt đối, chờ có giới hạn và lặp tuyến tới postcondition; không teleport hoặc tự đặt cờ. Tương tác thường kiểm khoảng cách 2,5 m. Verify đọc node riêng và thuộc tính lồng (`Player.bar_weapon:hits_left`) để xác nhận đủ 8 lượt đánh, không chỉ khác null. Bot khởi tạo rule set và sự kiện bắt đầu chương như menu.
- F9 gọi bốn debug API thật và trả kết quả kiểm chứng. Smoke kiểm cả bốn API ở **mỗi** khu, nạp stamina từ 0,2 lên 1,0, kiểm F9 pause/mở/đóng. Test fixture cũ được giữ làm regression; test mới `test_ch3_profile.gd` dùng **chapter3.tscn thật**, kiểm node/anchor, chìa/cửa/bình, không tương tác từ xa, debug API và navmesh nối từng chặng/cả vòng sân.

**Kiểm tra đã chạy**

| Lệnh | Kết quả |
|---|---|
| `pwsh tools/test.ps1 -Filter ch3` (trước khi thêm audit nối navmesh) | `RESULT: 44 passed, 0 failed`; không dùng kết quả này để tuyên bố bản cuối PASS |
| `pwsh tools/test.ps1 -Filter ch3_profile` (có audit, đợi 5 physics frame đồng bộ) | `RESULT: 0 passed, 1 failed` |
| `pwsh tools/test.ps1` (bản cuối) | **`RESULT: 601 passed, 1 failed`**; exit 1, bài FAIL duy nhất là `test_real_profile_nodes_actions_and_navigation_endpoints` |
| `pwsh tools/check.ps1` | `RESULT: check 0 error(s)`; exit 0 |
| `pwsh tools/qa-menu.ps1 -Chapter 3 -Smoke` | `RESULT: qa-menu PASS chapter3 (four area jumps, four debug actions per area, F9)`; exit 0, không SKIP |

- Log đã commit: `tools/reports/T-193-test.txt`, `T-193-check.txt`, `T-193-navmesh.txt`, `T-193-menu-smoke.txt`. Log test chỉ bỏ khoảng trắng cuối dòng khi lưu; không thay kết quả. Không có SCRIPT ERROR/ERROR trong lượt full test.
- Smoke dùng renderer Forward+ / RTX 3050 Laptop GPU và userdata riêng tại `build/qa-menu/060ad9ec7e2b48dc8f415a416f23f411/`. Đã xem ảnh `userdata/Godot/app_userdata/Ky Tuc Xa Sau 12 Gio/ch3-menu.png`: đủ tám nút, chữ tiếng Việt rõ.
- Checklist tuyến và toàn bộ test còn để trống do lỗi dưới đây. Không chạy bot cả chương, hai case chết hay FPS theo giới hạn card. Chưa kiểm chứng khả năng sống sót, thời điểm nấp 207, né xác/đánh đầu, cửa sổ với input bot, nhận đủ đồng đội hay kết thúc chương bằng bot. Các phép đặt vị trí trong test chỉ là setup kiểm API, không phải bằng chứng bot đi được.

**Yêu cầu thay đổi ngoài phạm vi — lane B/integrator**

1. Mở rộng/nối navmesh vào sâu phòng 207 trong `game/scenes/levels/campus/campus.tscn`: từ `(35.75,-6.6,2)` tới điểm card `(35.75,-6.6,-4.5)`, `map_get_path` dừng tại `(35.75,-6.6,-2.5)`, cách đích 2 m. Resource `t190_s21` của `Navigation/Alcove2_6` chỉ phủ tới z=-2,5. Không tự đổi điểm nấp nông hơn vì chưa chứng minh an toàn theo luồng yêu cầu.
2. Kiểm tra navmesh ngoài trời/khả năng đăng ký vùng `Campus/Navigation/Outdoor` và kết nối cửa sổ → vườn → đường → sân → cổng → nhà ăn (`campus.tscn`, `outdoor_navigation.tres` và script liên quan nếu cần). Sau đồng bộ, điểm `(4,-9.9,-12)` chỉ tìm được endpoint `(4,-9.9,-10.7)`; Start_garden `(22,-9.9,8)` có closest/endpoint `(22,-9.9,3.55)`; Start_stadium `(115,-9.9,166)` closest `(158.5,-9.676471,213.2)`. Chưa kết luận nguyên nhân của vùng Outdoor; không sửa resource hoặc runtime map trong lane C. Danh sách đầy đủ trong `T-193-navmesh.txt`.
3. Sau khi lane B sửa, chạy lại `pwsh tools/test.ps1 -Filter ch3_profile`, rồi full test/check. Giữ ngưỡng endpoint 0,8 m và tránh bảo vệ 3,3 m; không nới ngưỡng hay teleport để bỏ qua. Bot cả chương vẫn chờ chủ dự án cho phép.

Không có câu hỏi mới về luật chơi/cốt truyện; các giá trị thời gian và điểm nấp lấy từ card/core, chưa tự suy diễn thiết kế.

## Review (integrator)

### 2026-10-07 — Claude (integrator): **duyệt, đã merge sau 3 sửa nhỏ**
- **Lane C báo "bị chặn do navmesh, cần lane B sửa map". Integrator kiểm: không cần sửa map**, chỉ có 3 vấn đề nhỏ, tất cả nằm ở chỗ dùng dữ liệu:
  1. **Test chờ chưa đủ:** lưới đường đi ngoài trời có hàng trăm vùng, đăng ký trong nhiều khung vật lý (như `test_campus.gd` đã làm: chờ tới khi điểm sân vận động nằm trên lưới). Test mới chỉ chờ 5 khung nên các điểm sân và vườn "không tới được" (kể cả `Start_stadium` có "điểm gần nhất" ở khán đài). Đã sửa: chờ tới khi `Start_stadium` có trên lưới (tối đa 600 khung). Không nới ngưỡng 0,8 m.
  2. **Điểm nấp 207 sai độ sâu:** `(35,75; −6,6; −4,5)` nằm sâu hơn vùng đường đi của phòng 207 (chỉ tới z = −2,5; phòng thật vẫn đi bộ được, nhưng bot đi theo lưới). Dữ kiện đó do integrator ghi "khoảng"; đã đổi thành `z = −2,3`, và **tăng chờ 20 → 30 giây** (đám 4 xác ở cửa 203 cần khoảng 25 giây để vào hết chiếu nghỉ).
  3. **`P14_Wait_garden` (22; −9,9; 26) nằm ngoài vùng đi được** (cạnh ghế đá Ngư; cùng nguyên nhân khiến đồng đội đứng im trước D-063). Đã đổi thành tọa độ `(20; −9,9; 26)`, vẫn trong 4 m quanh ghế đá nên Ngư vẫn trao sắt.
  Lỗi dây chuyền trong audit: mỗi chặng lấy điểm đích của chặng trước làm xuất phát, nên một điểm hỏng làm hỏng mọi chặng sau và trông như lỗi nhiều nơi. Nên cân nhắc, nếu audit này mở rộng, dùng điểm gần nhất đi được làm xuất phát tiếp theo.
- **Phần còn lại tốt:** profile đủ 4 tuyến với hành động thật (không teleport, không tự đặt cờ), xác nhận 8 lượt đánh sắt, cờ `ch3_stadium_survived`, menu F9 gọi 4 hàm `debug_*` ở mỗi khu và `qa-menu -Smoke` chạy thật, test mới dùng cảnh thật. Báo cáo log đã commit (`tools/reports/T-193-*.txt`).
- **Test sau merge: 602/602, check 0 lỗi, `qa-menu -Smoke` PASS.**
- **Chưa chạy bot cả chương** (chờ chủ dự án cho phép). Lưu ý cho lúc chạy: bot đi theo lưới, nên chỗ nấp 207 và vài chỗ ngoài trời vẫn cần xem bot có sống sót không.

