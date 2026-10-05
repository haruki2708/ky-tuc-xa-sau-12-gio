# T-171 — Chương 2: cầm giẻ, bịt miệng xác, buồng tắm, cảnh chết mới
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-171-ch2-interactions`
- Phụ thuộc: T-161. **Đọc kỹ `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn: hết ngày 2026-10-07.**

## Mục tiêu
Cơ chế tương tác cho chương 2. Lane A chỉ làm **cơ chế**; luật thắng/thua và thứ tự diễn biến do core (T-170) điều khiển qua signal và API.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (core, không sửa)
- `EventBus.corpse_state_changed(bed, state)`, `chain_choice_blocked(blocked)`, `shower_choice_made(run_water)`, `shower_steam_changed(level)`.
- `EventBus.player_death_started(kind)` có thêm `corpse_lunge`, `scald`.

## Yêu cầu
1. **Cầm đồ một tay** (`carry_item.gd` + `.tscn`, kế thừa `Interactable`):
   - export `item_id` (`&"rag"`, `&"towel"`, `&"shirt"`), `prompt_key`;
   - E thì cầm, món đồ theo camera như dây mạng T-161; chỉ cầm **một món một lúc**, cầm món khác thì món cũ rơi về chỗ cũ;
   - signal `picked(item_id)`, `dropped(item_id)`; API `consume()` (core gọi khi đồ đã dùng để bịt miệng: món đồ biến mất khỏi tay).
2. **Bịt miệng xác** (`gag_spot.gd`, kế thừa `Interactable`):
   - export `bed` (1, 2, 4); gắn ở đầu xác, anchor của lane B;
   - chỉ hiện lời nhắc "Bịt miệng" khi đang cầm đồ; E thì phát signal `gag_requested(bed, item_id)`. **Core quyết định** có bịt được không và gọi `consume()`;
   - xác đã bịt thì tắt tương tác (`set_gagged(true)`).
3. **Cửa nhà vệ sinh kẹt** (`stuck_door.gd`): cần **đẩy vai 3 lần** (E). Mỗi lần: camera giật nhẹ, `noise_emitted(…, 6.0, &"door_bash")`, signal `bashed(count)`. Lần 3 thì gọi `set_bathroom_door_open(true)` của `Room407` (T-162) và phát `opened`. API `reset()`.
4. **Buồng tắm** (`shower_stall.gd`, Area3D): signal `player_inside_changed(inside)`, thuộc tính `player_inside`. Gắn vào vùng buồng tắm của lane B (`Anchors/ShowerStall`, T-172).
5. **Nút trên màn hình vòi sen**: hai vùng `ShowerYes`, `ShowerNo` (E) phát `EventBus.shower_choice_made(true/false)`; API `set_enabled(bool)` (core bật khi đang đếm ngược). **Lau màn hình**: giữ E 1 giây trên vùng `ShowerScreen`, phát signal `wiped()`. Bấm được cả khi đứng trong buồng tắm.
6. **Cảnh chết mới** (Player nghe `player_death_started`, khoảng 3 giây, phát `death_animation_finished` như T-161):
   - **`corpse_lunge`:** quay camera về xác gần nhất (group `ch2_corpse`), xác lao tới (lane B diễn), camera giật mạnh, ngã ngửa, máu bắn camera;
   - **`scald`:** khựng lại, camera rung co rút, nhìn xuống tay (không cần mô hình tay; rung và nghiêng), gục xuống sàn buồng tắm, hơi nước trùm (lớp hơi nước và bỏng là của lane D);
   - "Giảm hù dọa": không có máu, không lao sát mặt.
7. **Test:** cầm/đổi/thả đồ, bịt miệng chỉ khi đang cầm, cửa kẹt 3 lần, vùng buồng tắm, nút Có/Không chỉ khi được bật, lau giữ 1 giây, hai cảnh chết. Scene thử `ch2_interactions_test.tscn`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Scene thử có đủ đồ để thử bằng tay
- [ ] Handoff: tên scene, API, signal

## Handoff (agent điền)
