# T-195 — Chương 4: điện thoại làm mồi, lật vạt giường, độ bền cửa phá, cảnh chết `door_burst`
- Lane: A (Gameplay) | Trạng thái: done | Agent:
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
- [x] `BedSlat` giữ E 5 giây, tín hiệu `bed_slat_flipped`
- [x] Chỗ tìm giả 8 giây, kết quả trống
- [x] `ZombieDoor` phát `door_damage_changed`; cảnh chết `door_burst`
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: tên scene/API, cách kiểm tra

## Handoff (agent điền)

### 2026-10-07 — Lane A

- Commit mã **`d5545df`** và sửa tầm tương tác **`a9eb948`**, đã push `lane-a/T-195-ch4-gameplay`; base `origin/main` tại `ff17fb4`. Phần cơ chế và test trong phạm vi A đã xong.
- **Checklist đầu chưa đánh dấu:** ném/chuông/noise/số lần/trả điện thoại đã PASS trong test và fixture; **chưa kiểm chứng G trong game chính**, `GameInput.KEY_ACTIONS` trên base của nhánh chưa có `throw_phone`. Không sửa core hay tự đăng ký action trong mã chạy chính; không kiểm tra bản tích hợp trong thư mục của integrator.
- Không sửa `Zombie`, EventBus, GameInput, scene lane B, STATUS hoặc bản tích hợp. Chỉ thêm key riêng `PROMPT_CH4_FLIP_SLAT` đủ vi/en theo mục 2 của card và phân công chữ trong T-194; không đổi key của lane khác.

### Scene / API / ghép

| Thành phần | Cách dùng |
|---|---|
| Điện thoại mồi | `player.get_node("Head/Camera3D/PhoneItem").throw_decoy() -> bool`; đầu vào `throw_phone` được PhoneItem nhận khi core đăng ký action. `away` cho biết điện thoại đang bay/đổ chuông; `decoy` là node PhoneDecoy đang hoạt động |
| Vạt giường | `res://scenes/interaction/bed_slat.tscn`, gốc `BedSlat`, đặt tại Slat1/Slat2/Slat4 và gán `bed = 1/2/4`. `slat_visual` mặc định `SlatPivot`, có thể trỏ tới cụm mô hình B cần lật |
| Tìm giả | `res://scenes/interaction/fake_search_spot.tscn` kế thừa đúng `search_spot.tscn`, đặt ở FakeLocker/FakeCeiling/FakeVent. Hoặc instance scene cũ rồi gán `hold_seconds = 8.0`, `empty_result = true` |
| Cửa | `ZombieDoor` vẫn gán `door`/`blocker` như CH3. Core đặt thêm `durability_seconds = 75.0` cho thư viện, `90.0` cho 407; mặc định 0 giữ thời gian do xác truyền vào (`bash(delta, required_seconds)`) |
| Cảnh chết | Core phát `EventBus.player_death_started.emit(&"door_burst")`; kết thúc vẫn dùng `player.death_animation_finished`. Các lý do GRABBED/STAIRS/LIBRARY tiếp tục dùng `zombie_grab` |
| Cảnh thử | `res://scenes/player/ch4_gameplay_test.tscn`: sàn/cầu thang, player, ba vạt, ba chỗ tìm giả, cửa mẫu đúng hợp đồng |

- **Điện thoại:** cần `GameState.chapter == 4` và `ch4_phone_charges > 0`; giới hạn 3 trước khi trừ. Chặn khi typing, menu/modal/pause, ẩn nấp, hết lượt hoặc điện thoại chưa trở lại. Không có mặt sàn phù hợp thì trả false, không trừ lượt. Đường bay ngắn 0,7 giây, nhô tối đa 0,75 m; ray quét từng bước tránh xuyên tường, gặp cạnh đứng thì rơi xuống; vị trí đích trong 15 m, có thể là sàn/bậc thang. Không sửa hành vi nghe tiếng của Zombie.
- Trừ một lượt khi ném; **khi chạm chỗ rơi** phát `phone_decoy_thrown(at, charges_left)` một lần để E phát chuông tại đó. `noise_emitted(at, 25.0, &"phone_decoy")` phát lúc rơi rồi mỗi giây trong 6 giây (6 nhịp tổng); không phát thêm signal thrown mỗi nhịp. Hết chuông tự trả điện thoại, không cần nhặt. Mô hình và đèn pin trên tay ẩn khi ném, khôi phục trạng thái trước đó nếu player đang dùng được; không mở UI đè lên typing/modal khi trả. Scene hủy thì điện thoại mồi cũng hủy.
- **Giữ E:** `HoldInteractable` giữ tiến trình bằng giây, giảm 1 giây tiến trình mỗi giây khi nhả; quay nhìn ra chỗ khác vẫn giữ được thao tác đã bắt đầu. Khóa riêng di chuyển (`acquire_movement_lock`/`release_movement_lock` trên Player), không khóa chuột nhìn. Nhả E, typing/modal, ra xa hơn 3 m hoặc xóa vật sẽ nhả khóa; pause đóng băng tiến trình. Thanh tiến trình không có chữ riêng, nằm dưới prompt, đã kiểm tra ảnh ở mức ~40%.
- **BedSlat:** đủ 5 giây thì lật Pivot trong 0,45 giây, tắt tương tác trước khi phát `bed_slat_flipped(bed)` để không phát lặp. Không nhận bed 3. Core/D sở hữu mảnh phiếu, số mảnh và việc ghép. Mô hình vạt hiện là khối gỗ thử; B cần gắn cụm vạt/nệm thật qua Pivot hoặc nghe signal.
- **Tìm giả:** đủ 8 giây thì đánh dấu đã tìm, không phát `searched`, không mở document, không phát `bed_slat_flipped`; chỉ còn signal tương tác chung `interacted`. SearchSpot cũ mặc định `hold_seconds = 0`, `empty_result = false`, giữ hành vi tức thời và phát kết quả cũ.
- **Độ bền:** `door_damage_changed(id, fraction)` lấy `door.room`, thiếu thì tên node; fraction clamp 0..1. Phát lần đầu 0, tiếp theo khi lệch hơn 0,02; luôn gửi mốc 0/1 khi đổi để UI không kẹt ở 99%. Sau khi vỡ không báo nhầm về 0. Cách đếm tiếp xúc, nhiều xác không nhân damage, mở cửa và collider của CH3 giữ nguyên; thời gian CH4 cố định không bị giá trị 10 giây của xác ghi đè.
- **DoorBurst:** hoạt cảnh 3 giây, ưu tiên cửa room `407` trong group `room_doors` cùng world, nếu thiếu dùng cửa gần nhất/điểm trước camera. Có bàn tay và mảnh gỗ thủ tục, ba rig `zombie_01.tscn` sẵn có tiến qua cửa; chỉ là mô hình diễn cảnh, không thêm AI hay phát verdict. Cửa mở ở nhịp 0,5 giây. Camera ngã lùi, quét collision và vẫn hướng về cửa. Giảm hù dọa bỏ bàn tay/đám xác/mảnh gỗ và rung; không tạo máu cho kind này (D phụ trách). Không thay điều kiện chết/checkpoint của core.

Tầm với 3 m của tương tác giữ E được đo từ **camera**, không phải chân player: đã bổ sung test dùng ray E thật với FakeCeiling ở y = 3,3 m, tránh chặn nhầm mục tiêu trên trần dù ray ngắm đã tới được.

### Kiểm chứng

- `pwsh tools/test.ps1`: **`RESULT: 618 passed, 0 failed`**, exit 0, không lỗi engine. Log local `build/T-195-full-final.log`.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. Log local `build/T-195-check-final.log`.
- `pwsh tools/test.ps1 -Filter test_ch4_gameplay`: **`RESULT: 17 passed, 0 failed`**. Log local `build/T-195-ch4-ceiling.log`.
- Test mới kiểm tra: tối đa 3 lần ném, điểm rơi/noise/chuông 6 giây/trả lại, G với action được đăng ký trong fixture test, chặn nhập chữ/modal/pause/chương cũ, va tường/rơi lên bậc/thu hút Zombie cũ, cleanup; BedSlat 1/2/4, ray Player + E, 5 giây, giảm tiến trình, giữ chuột nhìn, nhả khóa; 3 chỗ giả 8 giây không kết quả nhiệm vụ; damage id/ngưỡng/mốc/cuối/thời gian 75 giây; death thường/giảm hù dọa/nhìn về đúng cửa và scene load. Toàn bộ test Player/CH3 cũ nằm trong lượt full PASS.
- Đã chạy Godot có render và xem ảnh: `build/T-195-door-preview/frame00000010.png`, `frame00000040.png`, `frame00000080.png`; `build/T-195-door_burst_reduced-preview/frame00000060.png`; `build/T-195-slat-final/frame00000060.png` và `frame00000185.png`. Không lỗi engine trong các lượt chụp; ảnh/log local ignored, không commit.
- Chạy fixture: `D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game res://scenes/player/ch4_gameplay_test.tscn`. E giữ tương tác; G ném; 1 xem door_burst; R tải lại. **G trong fixture có fallback riêng nếu core chưa đăng ký action, không áp dụng cho scene game chính.** Sau `--` có thể thêm `--preview=slat`, `--preview=phone`, `--preview=door_burst` hoặc `--preview=door_burst_reduced` để chụp tự động.
- **Chưa test** G trong chapter4.tscn thực, chơi tay liền chương 4, model vạt/nệm thật, cửa thư viện/407 bản T-196, UI/máu/chuông của D/E và checkpoint T-194: các phần này chưa có trên base. Test/render fixture không thay thế chơi thử bản ghép.

### Yêu cầu thay đổi ngoài phạm vi / chặn

1. **Blocked — nối G trong game chính trên base của nhánh:** core/T-194 thêm `"throw_phone": [KEY_G]` vào `GameInput.KEY_ACTIONS`, khởi tạo số lượt `ch4_phone_charges` (tối đa 3), khôi phục số lượt theo checkpoint và đặt `GameState.chapter = 4`. A đã nhận action và xóa trạng thái giữ action ở hai biên typing; không sửa file core.
2. **Core + B/T-196:** đặt BedSlat tại các anchor với bed đúng, đặt fake search scene/cấu hình trên; ghép vạt/nệm thật, chữ/mảnh giấy; gắn ZombieDoor cho hai cửa và đặt `durability_seconds` 75/90. Core nối điều kiện chết sang kind `door_burst`; scene cửa cần group `room_doors`, `room`, `set_open()` và `Blocker` như T-194.
3. **D/E:** D xử lý mảnh phiếu, máu khi `door_burst`; E phát chuông 6 giây tại `at` từ `phone_decoy_thrown` và tiếng phá cửa/death theo hợp đồng. A không thêm âm thanh hoặc overlay máu mới ngoài phạm vi.

Không còn lỗi trong cơ chế độc lập được kiểm chứng. Không có câu hỏi mới về cốt truyện/luật chơi; chỉ còn các phụ thuộc ghép nêu trên.

## Review (integrator)

### 2026-10-07 — Claude (integrator): **duyệt, đã merge**
- Đúng card và làm kỹ: điện thoại mồi (3 lần, noise 25 m mỗi giây trong 6 giây, tự trả, chặn khi gõ chữ hoặc menu), `HoldInteractable` (giữ E, tụt dần khi nhả, tầm với đo từ camera), `BedSlat`, chỗ tìm giả 8 giây không kết quả, `ZombieDoor.durability_seconds` và `door_damage_changed`, cảnh chết `door_burst` (có bản giảm hù). 17 test mới.
- **Core đã nối:** phím `throw_phone` (G) có sẵn trong `GameInput` từ T-194; `GameState.chapter = 4` và `ch4_phone_charges = 3` khi vào chương; `durability_seconds` 75 giây (cửa thư viện) và 90 giây (407); `BedSlat` giường 1, 2, 4 và 3 chỗ tìm giả đặt vào anchor `Ch4/Room407/*` của lane B (ẩn khối gỗ thử, mô hình vạt của lane B tự lật theo `bed_slat_flipped`); test tia ngắm: cả 3 vạt đều tới được.
- Merge xung đột `strings.csv` (core và lane A cùng thêm cuối file): giữ cả hai.
- **Chưa kiểm bằng tay:** G trong game thật, cảm giác giữ E.
