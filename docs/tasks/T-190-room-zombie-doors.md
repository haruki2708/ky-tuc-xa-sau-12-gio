# T-190 — Nhà B: cửa phòng mở được để xác đi ra từ trong phòng (tầng 4, 3, 2)
- Lane: B | Trạng thái: done | Agent:
- Nhánh: `lane-b/T-190-room-zombie-doors`
- Phụ thuộc: T-183, T-187, T-188. **Đọc D-061 trong `docs/DECISIONS.md`**, `docs/design/CH3_DESIGN.md` mục N2–N4, card T-183 và T-187 (mục Handoff), `art_source/campus/README.md`, `art_source/wide_corridors/README.md`.
- Phần luồng (khi nào cửa bật, bao nhiêu xác) là của core: T-191. Card này chỉ làm map.
- **Hạn: càng sớm càng tốt** (chủ dự án đang chơi thử chương 3).

## Vì sao
Chủ dự án chơi thử: ra khỏi 407 thì khoảng 12 xác hiện ra cùng lúc giữa hành lang tầng 4 (điểm `ZombieSpawns/B4`, `ZombieIdle/B4` ở z = 2,1, ngay trước cửa 401–406), quá khó và không tự nhiên. D-061: xác phải **đi ra từ trong các phòng**: cửa bị đập vài giây rồi bật mở, xác bước ra hành lang.

Hiện trạng:
- **Tầng 4** (`game/scenes/levels/floor4/corridor.tscn`, dùng chung cho chương 1–3): phòng 401–406, 408 có `LockedDoor_4xx` chỉ là mô hình `door.glb`, không mở được; trong phòng có `Floor_`, `BackWall_`, `Ceiling_`; chưa có đường đi (navigation) trong phòng.
- **Tầng 3, 2** (`art_source/campus/build_campus.py` → `building_b.tscn`): mỗi tầng 8 phòng, `x = 2.75 + 5.5·i`, phòng số `i + 1` (203 là i = 2). Phòng i = 1, 4, 6 đã có "hốc xác" (cửa ẩn, `Alcove%d_%d` + `AlcoveLink%d_%d`) nhưng **cửa bị ẩn** (lối mở toang) và core chưa dùng.

## Được phép sửa
- `art_source/campus/`, `art_source/wide_corridors/` (nếu tầng 4 sinh từ đây),
- `game/scenes/levels/floor4/corridor.tscn` (chỉ cửa phòng, phần trong phòng, không đổi vị trí phòng 407, bàn trực, cửa thoát hiểm),
- `game/scenes/levels/campus/building_b.tscn`, `game/scenes/levels/campus/campus.tscn` (chỉ phần Navigation và Anchors nêu dưới),
- script mới trong `game/scenes/levels/` (ví dụ `room_door.gd`),
- `game/tests/levels/` (test mới), card này (Handoff).

**Cảnh báo dựng map:** không chạy lại toàn bộ bộ dựng nếu chưa chắc nó không ghi đè sửa đổi của T-187, T-188, T-189 (xem README). Nếu chạy, so sánh diff và chỉ giữ phần của card này.

## Yêu cầu
### 1. Cửa phòng mở được (hợp đồng cho core và lane A)
Áp dụng cho **mọi phòng** ở tầng 4 (401–406, 408), tầng 3 (301–308), tầng 2 (201, 202, 204–206, 208). **Không** áp dụng cho 407 (đã có cửa riêng), 203 (đã có `Room203Door`) và **207** (D-062: giữ là phòng để mở, không cửa, làm chỗ nấp; bình cứu hỏa mới ở chiếu nghỉ cầu thang thoát hiểm tầng 2).
- Mỗi cửa là một node `Node3D` dùng script mới (ví dụ `RoomDoor`), có:
  - `@export var room: StringName` (ví dụ `&"401"`, `&"305"`),
  - `var is_open: bool` (mặc định `false`), `func set_open(open: bool) -> void` (quay cánh cửa ra phía hành lang khoảng 0,3 giây; mở thì tắt va chạm của `Blocker`),
  - con `Blocker` là `StaticBody3D` lớp 1 (world) che kín khung cửa khi đóng,
  - thuộc group `room_doors`.
  Hợp đồng này khớp `ZombieDoor` của lane A (`scripts/interaction/zombie_door.gd`: cần `is_open`, `set_open(bool)` và collider `blocker`); core sẽ gắn `ZombieDoor` lúc chạy.
- Người chơi **không** mở được các cửa này (không phải `Interactable`). Ở chương 1–2 cửa luôn đóng: nhìn và va chạm như hiện nay.
- Tầng 3: cửa phòng i = 1, 4, 6 **hiện lại** (thôi ẩn), dùng cùng hợp đồng. Tầng 2: cửa i = 1, 4 hiện lại; **i = 6 (phòng 207) giữ mở** như bây giờ (D-062).
- **Đã đổi trước card này (D-062, Claude làm thay):** bình cứu hỏa tầng 2 (`Extinguisher2F`, `FireExtinguisher`, `ExtinguisherHandle`) dời từ x = 20 vào tường trong cùng chiếu nghỉ cầu thang thoát hiểm tầng 2 (48,83; −5,5; 2,4), sửa cả `build_campus.py` và `detail.py`. `ZombieIdle/B2` core không dùng nữa (core tự đặt 4 xác ở cửa 203). Màu trời (D-065) đã đổi trong `build_campus.py` và `campus.tscn`. Giữ các thay đổi này khi dựng lại.

### 2. Bên trong phòng và đường đi
- Mỗi phòng nêu trên kín (tường hai bên, tường sau, trần) để khi cửa mở không thấy khoảng trống và xác không đi xuyên sang phòng bên. Bên trong **tối**, vài khối giường tầng hoặc tủ đơn giản là đủ (không cần chi tiết).
- Mỗi phòng có `NavigationRegion3D` phủ khoảng 1,3 × 2 m phía trong cửa, nối ra hành lang bằng `NavigationLink3D` qua khung cửa (như `AlcoveLink`), **link luôn bật** (cửa đóng chặn bằng `Blocker`, xác tới cửa sẽ đập).
- Tầng 4: thêm vùng đường đi và link cho 401–406, 408 vào cùng chỗ có `Hall4` (bộ dựng `build_campus.py`).

### 3. Anchor
- `Anchors/RoomSpawns/B4/R401` … `R408` (không có 407), `Anchors/RoomSpawns/B3/R301` … `R308`, `Anchors/RoomSpawns/B2/R201` … `R208` (không có 203, 207): mỗi `Marker3D` đặt **trong phòng**, cách cửa khoảng 1,5 m, trên nền (y của tầng), đủ chỗ cho 2 xác đứng (core đặt xác thứ hai lệch 0,6 m).
- `Anchors/ZombieIdle/B4`: **dời 6 điểm về đầu cầu thang chính** (khoảng x 0,5–5, trên hành lang 4 m), quay mặt về phía phòng 407. Đây là đám xác "quay đầu" ở xa (jumpscare `corridor_turn`). Giữ tên `I01…I06`.
- Không đổi tên hay xóa anchor khác (`ZombieSpawns/*`, `ZombieIdle/B3`, `B2`, `B1`, `Room203Door`, `FireDoor`, `FireKey`…).

### 4. Test (`game/tests/levels/`)
- Mỗi cửa trong group `room_doors`: đóng thì capsule cỡ người (bán kính 0,3, cao 1,6) **không** đi từ trong phòng ra hành lang được; `set_open(true)` thì đi được.
- Đường đi: từ mỗi `RoomSpawns/*/R*` có đường (`NavigationServer3D.map_get_path`) tới giữa hành lang cùng tầng.
- Chương 1–2 không đổi: các test hiện có của tầng 4, phòng 407, chương 1–2 vẫn PASS.
- Chạy `pwsh tools/test.ps1` và `pwsh tools/check.ps1`; chụp ảnh hành lang tầng 4 với một cửa đang mở.

## Checklist hoàn thành
- [x] Cửa 401–406, 408, 301–308, 201–208 (trừ 203) theo hợp đồng mục 1, group `room_doors`
- [x] Trong phòng kín, có đường đi và link ra hành lang
- [x] Anchor `RoomSpawns/*`, `ZombieIdle/B4` dời về đầu cầu thang chính
- [x] Test cửa và đường đi PASS; `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Ảnh hành lang tầng 4 có cửa mở
- [x] Handoff: tên script, đường dẫn node cửa của từng tầng, tọa độ anchor

## Handoff (agent điền)

### 2026-10-07 — Lane B

**Đã làm:** commit `b3ab952`, đã push code và ảnh lên
`lane-b/T-190-room-zombie-doors`. Đủ 22 cửa đóng/mở, trong phòng kín có
giường/tủ đơn giản, 22 vùng nav/link luôn bật và 22 điểm `RoomSpawns`.
Sáu idle tầng 4 chuyển về đầu cầu thang chính. Giữ nguyên tên/vị trí mọi
anchor khác, phòng 407, cửa 203, cầu thang T-188 và nhà ăn T-189.

**Hợp đồng cho core T-191:**

- Script `res://scenes/levels/room_door.gd`, class `RoomDoor`: `room`,
  `is_open=false`, `set_open(bool)`, con `Blocker` (`StaticBody3D`, lớp 1),
  biến `blocker` trỏ tới con đó. Group `room_doors` được đăng ký khi ready.
  Không phải `Interactable`; core gắn `ZombieDoor`, gán `door` và `blocker`.
  Mở quay `Hinge` ra +z trong 0,3 giây, collider tắt qua deferred update;
  đóng phục hồi collider, đảo hướng hủy tween cũ.
- Tầng 4: `Floor4/Corridor/LockedDoor_401`…`LockedDoor_406`,
  `Floor4/Corridor/LockedDoor_408`.
- Tầng 3: `Campus/BuildingB/Floor3/Door0`…`Door7` ứng với 301…308.
- Tầng 2: `Campus/BuildingB/Floor2/Door0`, `Door1`, `Door3`…`Door7`
  ứng với 201,202,204…208. 407 và 203 vẫn dùng cửa riêng cũ.
- `room_door_visual.gd` bỏ collider GLB dư khỏi cánh cửa tầng 4; chỉ
  `Blocker` điều khiển va chạm. Cửa hốc tầng 2–3 từng bị ẩn nay hiện lại.
- Navigation nằm trong `Campus/Navigation`: `Room<phòng>` và
  `Room<phòng>Link`; các hốc cũ giữ `Alcove2_1/4/6`, `Alcove3_1/4/6` và
  tên `AlcoveLink...`. Link luôn bật, xác có đường tới cửa để đập.
- `campus_room_navigation.gd` trên `Campus/Navigation` tạm đưa nav/link
  Floor4 độc lập sang map riêng để chúng không hút đầu link của phòng mới.
  Tháo Campus sẽ phục hồi map và giải phóng RID tạm. Test nav chương 1–2
  độc lập vẫn PASS; không sửa `campus.gd` hoặc logic core/Lane A.

**Tọa độ anchor mới:** global, mét; mọi `R*` có z=-1,5; chừa đủ chỗ cho
xác thứ hai lệch +0,6 m theo x. Vùng nav x±0,65, z=-2,5…-0,5, cao độ tầng.

| Nhóm dưới `Campus/Anchors/RoomSpawns` | Tên theo thứ tự | x theo thứ tự | y |
|---|---|---|---|
| B4 | R401,R402,R403,R404,R405,R406,R408 | 8,12,16,20,24,28,42 | 0 |
| B3 | R301,R302,R303,R304,R305,R306,R307,R308 | 2.75,8.25,13.75,19.25,24.75,30.25,35.75,41.25 | -3.3 |
| B2 | R201,R202,R204,R205,R206,R207,R208 | 2.75,8.25,19.25,24.75,30.25,35.75,41.25 | -6.6 |

`Campus/Anchors/ZombieIdle/B4` giữ nguyên I01…I06, quay y=-90° để nhìn
về +X/phòng 407:

| Anchor | Cũ (x,y,z) | Mới (x,y,z) |
|---|---|---|
| I01 | (8,0,2.1) | (1,0,1.6) |
| I02 | (12,0,2.1) | (2.6,0,1.6) |
| I03 | (16,0,2.1) | (4.2,0,1.6) |
| I04 | (20,0,2.1) | (1,0,2.7) |
| I05 | (24,0,2.1) | (2.6,0,2.7) |
| I06 | (28,0,2.1) | (4.2,0,2.7) |

[Bảng đầy đủ từng cửa/anchor và hướng dẫn dựng lại](../../art_source/campus/room_doors.md),
[JSON cho core/tools](../../art_source/campus/room_doors.json).

### Điều chỉnh bố trí và phạm vi đã được chủ dự án duyệt

Phát hiện phòng 407 bản 2 chiếm x=30…38; phía sau cửa 408 cũ tại x=36
thuộc 407, đã bị bỏ sàn/tường riêng. Chủ dự án trả lời trực tiếp:
**“Cho phép điều chỉnh bố trí 407/408”**, sau đó
**“Cho phép sửa phần hốc cũ”** trong `floor4/duty_desk.tscn`.

Đã đặt 408 độc lập tại x=38…44, z=-5…0, cửa x=42; bịt mặt cửa cũ bằng
tường và giữ node `Sealed408` tương thích chương 1–2. Dỡ riêng cổng sắt,
vách/sàn của hốc cầu thang trang trí cũ sau bàn trực trong file được mở
phạm vi; thay bằng phòng 408. Bàn trực, đồ/chìa trên bàn, cửa thoát hiểm
thật, phòng 407 và nội thất giữ nguyên. `Room408BackWall` ở vị trí mới,
không cắt phòng tắm 407. Không chỉnh luật chơi/cốt truyện.

### Kiểm tra

```text
pwsh tools/test.ps1 -Filter levels
RESULT: 82 passed, 0 failed
pwsh tools/test.ps1
RESULT: 587 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Không có `SCRIPT ERROR`/`ERROR` trong lượt cuối. Test mới kiểm tra cả 22
cửa với capsule bán kính 0,3 m/cao 1,6 m: đóng chặn, mở thông, đóng lại
chặn; điểm spawn thứ hai; đường nav bắt đầu đúng trong từng phòng và tới
hành lang, cast liên tục dọc đường; phòng kín; tách 408/407; hướng idle;
gắn `ZombieDoor` thật, đập mở và đảo chiều tween. Test cũ không bị sửa,
xóa hoặc nới expectation. Lỗi trong các lượt phát triển đã sửa và kiểm
tra lại bằng lượt full PASS trên.

Đã kiểm patch chạy lặp cho kết quả byte-identical; so với `bc0e770`, chỉ
22 anchor mới và 6 idle B4 thay đổi. Các node nhà B ngoài 15 cây cửa tầng
2–3 giữ nguyên; phần bàn trực còn lại giữ nguyên; room407 và canteen
không có diff. Log cục bộ ở `build/t190/`.

**Ảnh đã render/xem ở bản cuối:** [401 mở](../../art_source/campus/previews/room401_open.png),
[408 mở cạnh bàn trực](../../art_source/campus/previews/room408_open.png).
[Script chụp](../../art_source/campus/capture_room_doors.gd),
[credits](../../art_source/campus/CREDITS.md). Chưa chơi tay xuyên suốt
chương 1–3, chưa chạy bot playthrough/performance; không cài phần mềm,
không thêm plugin, không làm việc trong bản tích hợp.

### Yêu cầu thay đổi / còn lại / blocked

- Không còn yêu cầu sửa ngoài phạm vi chờ duyệt; mở rộng `duty_desk.tscn`
  đã được chủ dự án cho phép như trên.
- Core tiếp tục T-191: gắn AI, nhịp đập, sinh 1–2 xác, chốt 408 sau khi
  lấy chìa và reset checkpoint. T-190 chỉ cung cấp map/API, chưa bật luồng.
- Checklist 6/6 đạt; không còn phần map dở, không bị chặn.

## Review (integrator)

### 2026-10-07 — Claude: **duyệt, đã merge**
- **Phạm vi và chất lượng:** đúng hợp đồng (`RoomDoor`: `room`, `is_open`, `set_open`, `Blocker` lớp 1, group `room_doors`); cánh cửa không có va chạm, chỉ `Blocker` chặn; 22 cửa, 22 vùng đường đi và link, 22 `RoomSpawns`; `ZombieIdle/B4` dời về đầu cầu thang chính. Test mới tốt (capsule đóng chặn/mở thông, đường đi từ từng phòng, `ZombieDoor` thật đập mở).
- **Bố trí 408 và khu bàn trực:** chủ dự án đã cho phép trực tiếp với lane B. Integrator kiểm: không file nào trong code/test dùng các node cổng sắt cũ đã dỡ; phòng 407, nhà vệ sinh, cảnh chương 1–2 không đổi; ảnh chụp tầng 4 (cửa 401–406, phòng 408 cạnh bàn trực, đồng hồ 4:00) và tầng 2–3 nhìn ổn.
- **Merge:** nhánh tách trước `ed1d555`, `9795fcf` (bình cứu hỏa tầng 2, màu trời đêm) nhưng merge không xung đột; đã kiểm bình cứu hỏa vẫn ở chiếu nghỉ (48,83; −5,5; 2,4) và màu trời mới vẫn giữ.
- **Lệch với D-062 (không phải lỗi lane B, card đổi sau khi lane B nhận việc):** phòng 207 có cửa (`Floor2/Door6`). Core xử lý: vào chương 3 thì mở sẵn cửa 207 làm chỗ nấp (`_room_door(&"207").set_open(true)`), test tầng 2 kiểm cửa mở. T-191 sẽ không sinh xác ở `R207`.
- **Ghi chú nhỏ:** `campus_room_navigation.gd` dò `Floor4` mỗi khung hình tới khi tìm thấy; trong chương 3 luôn có nên không sao.
- Test sau merge (gồm bản sửa 207 của core): 589/589 PASS, check 0 lỗi.

