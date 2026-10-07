# T-195 — Chương 4: điện thoại làm mồi, lật vạt giường, độ bền cửa phá, cảnh chết `door_burst`
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-195-ch4-gameplay`
- Phụ thuộc: T-182, T-190, T-194 (hợp đồng chung, **đọc mục "Hợp đồng chung"**), `docs/design/CH4_DESIGN.md`, D-067.
- **Hạn đề xuất:** 2026-10-10.

## Việc
### 1. Điện thoại làm mồi (D-067 câu 3, cách A)
- Phím **`throw_phone` (G)** (core thêm vào `GameInput`): ném điện thoại về điểm đang nhìn (tầm tối đa 15 m, rơi theo vòng cung ngắn, chạm sàn hoặc bậc thang). Chỉ chạy ở chương 4 (khi `GameState.get_flag(&"ch4_phone_charges", 0) > 0`).
- Điện thoại **đổ chuông 6 giây** tại chỗ rơi: phát `EventBus.phone_decoy_thrown(at, charges_left)` và `EventBus.noise_emitted(at, 25.0, &"phone_decoy")` (xác dùng mã tiếng ồn sẵn có để quay về phía đó; **không sửa `Zombie`**). Trừ một lần (`ch4_phone_charges`, tối đa 3). Điện thoại trong tay được **trả lại sau khi chuông ngừng** (không phải nhặt).
- Không ném được khi đang gõ chữ (`text_entry_changed(true)`), khi menu mở, hoặc khi hết lần.
- Mô hình điện thoại rơi: dùng khối sẵn có, không cần mô hình mới (lane B có thể thay sau).

### 2. Lật vạt giường (D-067, phòng 407)
- Scene `res://scenes/interaction/bed_slat.tscn`: node `BedSlat` (`Interactable`) với `@export var bed: int` (1, 2, 4). **Giữ E 5 giây** (thanh tiến trình); xong thì phát `EventBus.bed_slat_flipped(bed)`, tắt tương tác (`once`). Prompt `PROMPT_CH4_FLIP_SLAT` (thêm key vào `strings.csv`).
- Khi đang giữ E: người chơi **đứng yên** nhưng vẫn quay nhìn được; nhả E giữa chừng thì tiến trình **tụt dần** (không reset hẳn).
- **Chỗ tìm giả:** dùng `search_spot.tscn` sẵn có cho `FakeLocker`, `FakeCeiling`, `FakeVent`: giữ E **8 giây**, kết quả **trống**; không phát tín hiệu nhiệm vụ.

### 3. Độ bền cửa phá và cảnh chết `door_burst`
- `ZombieDoor` (T-182) thêm: mỗi nhịp phát `EventBus.door_damage_changed(id, fraction)` với `id` = `door.room` (hoặc tên node), `fraction` = `damage_seconds / required_seconds` (0..1); phát lại chỉ khi đổi hơn 0,02. Không đổi cách hoạt động cũ (chương 3, T-190 vẫn chạy).
- **Cảnh chết `door_burst`** (`player_death_started(&"door_burst")`): cửa vỡ, bàn tay xác và đám xác tràn vào, camera ngã ra sau (chọn một tư thế nhìn thấy cửa). Lane D máu, lane E tiếng.
- Cảnh chết `zombie_grab` dùng lại cho `DEATH_CH4_GRABBED`, `STAIRS`, `LIBRARY`.

### 4. Test
`game/tests/player/`: ném điện thoại (số lần, noise phát đúng, trả lại điện thoại, không ném khi gõ chữ), `BedSlat` (giữ 5 giây, nhả giữa chừng tụt dần, một lần), `ZombieDoor` phát `door_damage_changed`, tất cả test cũ của chương 3 vẫn PASS.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`, card này (Handoff). **Cần sửa ngoài phạm vi** (input action, EventBus, strings của lane khác) thì ghi "Yêu cầu thay đổi".

## Checklist hoàn thành
- [ ] G ném điện thoại, noise 25 m, 3 lần, trả lại, tín hiệu đúng
- [ ] `BedSlat` giữ E 5 giây, tín hiệu `bed_slat_flipped`
- [ ] Chỗ tìm giả 8 giây, kết quả trống
- [ ] `ZombieDoor` phát `door_damage_changed`; cảnh chết `door_burst`
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: tên scene/API, cách kiểm tra

## Handoff (agent điền)

## Review (integrator)
