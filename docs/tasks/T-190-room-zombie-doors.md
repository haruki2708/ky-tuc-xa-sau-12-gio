# T-190 — Nhà B: cửa phòng mở được để xác đi ra từ trong phòng (tầng 4, 3, 2)
- Lane: B | Trạng thái: todo | Agent:
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
Áp dụng cho **mọi phòng** ở tầng 4 (401–406, 408), tầng 3 (301–308), tầng 2 (201, 202, 204–206, 208). **Không** áp dụng cho 407 (đã có cửa riêng), 203 (đã có `Room203Door`) và **207** (D-062: giữ là phòng để mở, không cửa, làm chỗ nấp cạnh bình cứu hỏa mới ở x = 39,5).
- Mỗi cửa là một node `Node3D` dùng script mới (ví dụ `RoomDoor`), có:
  - `@export var room: StringName` (ví dụ `&"401"`, `&"305"`),
  - `var is_open: bool` (mặc định `false`), `func set_open(open: bool) -> void` (quay cánh cửa ra phía hành lang khoảng 0,3 giây; mở thì tắt va chạm của `Blocker`),
  - con `Blocker` là `StaticBody3D` lớp 1 (world) che kín khung cửa khi đóng,
  - thuộc group `room_doors`.
  Hợp đồng này khớp `ZombieDoor` của lane A (`scripts/interaction/zombie_door.gd`: cần `is_open`, `set_open(bool)` và collider `blocker`); core sẽ gắn `ZombieDoor` lúc chạy.
- Người chơi **không** mở được các cửa này (không phải `Interactable`). Ở chương 1–2 cửa luôn đóng: nhìn và va chạm như hiện nay.
- Tầng 3: cửa phòng i = 1, 4, 6 **hiện lại** (thôi ẩn), dùng cùng hợp đồng. Tầng 2: cửa i = 1, 4 hiện lại; **i = 6 (phòng 207) giữ mở** như bây giờ (D-062).
- **Đã đổi trước card này (D-062, Claude làm thay):** bình cứu hỏa tầng 2 (`Extinguisher2F`, `FireExtinguisher`, `ExtinguisherHandle`) dời từ x = 20 về x = 39,5, sửa cả `build_campus.py` và `detail.py`. `ZombieIdle/B2` core không dùng nữa (core tự đặt 4 xác ở cửa 203). Màu trời (D-065) đã đổi trong `build_campus.py` và `campus.tscn`. Giữ các thay đổi này khi dựng lại.

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
- [ ] Cửa 401–406, 408, 301–308, 201–208 (trừ 203) theo hợp đồng mục 1, group `room_doors`
- [ ] Trong phòng kín, có đường đi và link ra hành lang
- [ ] Anchor `RoomSpawns/*`, `ZombieIdle/B4` dời về đầu cầu thang chính
- [ ] Test cửa và đường đi PASS; `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Ảnh hành lang tầng 4 có cửa mở
- [ ] Handoff: tên script, đường dẫn node cửa của từng tầng, tọa độ anchor

## Handoff (agent điền)

## Review (integrator)
