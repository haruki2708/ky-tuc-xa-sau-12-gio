# T-190 — Cửa phòng và điểm sinh xác

22 cửa có chung script `res://scenes/levels/room_door.gd` (`RoomDoor`):
`room: StringName`, `is_open: bool`, `set_open(bool)`, con `Blocker` lớp 1,
thuộc group `room_doors` sau khi vào cây. Đây là `Node3D`, không phải
`Interactable`. Mặc định đóng; gọi mở sẽ tắt collision qua deferred update
và quay `Hinge` ra hành lang trong 0,3 giây. Gọi đóng phục hồi collider;
đổi hướng giữa chừng hủy tween trước. Core gắn `ZombieDoor`, gán `door`
bằng node cửa và `blocker` bằng `door.get_node("Blocker")`.

Tầng 4 dùng lại mesh cửa gỗ cũ. `room_door_visual.gd` bỏ collider nhập kèm
GLB; collision chỉ do `Blocker` quản lý. Tầng 2–3 dùng cánh hộp gỗ đơn giản
như bản cũ. Các cửa hốc xác từng bị ẩn nay hiện lại. Không tự gắn AI,
không sinh xác, không thêm tương tác người chơi hay quyết định nhịp đập.

## Hợp đồng node và tọa độ

Tất cả tọa độ dưới đây là global khi Floor4 và Campus có transform gốc.
`RoomSpawns` đặt z=-1,5; chừa trống cả điểm lệch +0,6 m theo x cho xác thứ
hai. Vùng nav rộng 1,3 m, sâu 2 m (z=-2,5…-0,5); link từ z=-0,6 tới z=1,2
luôn bật, collider cửa chịu trách nhiệm chặn khi đóng.

| Phòng | Node cửa | Anchor dưới `Campus/Anchors/RoomSpawns` | (x,y,z) |
|---|---|---|---|
| 401 | `Floor4/Corridor/LockedDoor_401` | `B4/R401` | (8,0,-1.5) |
| 402 | `Floor4/Corridor/LockedDoor_402` | `B4/R402` | (12,0,-1.5) |
| 403 | `Floor4/Corridor/LockedDoor_403` | `B4/R403` | (16,0,-1.5) |
| 404 | `Floor4/Corridor/LockedDoor_404` | `B4/R404` | (20,0,-1.5) |
| 405 | `Floor4/Corridor/LockedDoor_405` | `B4/R405` | (24,0,-1.5) |
| 406 | `Floor4/Corridor/LockedDoor_406` | `B4/R406` | (28,0,-1.5) |
| 408 | `Floor4/Corridor/LockedDoor_408` | `B4/R408` | (42,0,-1.5) |
| 301 | `Campus/BuildingB/Floor3/Door0` | `B3/R301` | (2.75,-3.3,-1.5) |
| 302 | `Campus/BuildingB/Floor3/Door1` | `B3/R302` | (8.25,-3.3,-1.5) |
| 303 | `Campus/BuildingB/Floor3/Door2` | `B3/R303` | (13.75,-3.3,-1.5) |
| 304 | `Campus/BuildingB/Floor3/Door3` | `B3/R304` | (19.25,-3.3,-1.5) |
| 305 | `Campus/BuildingB/Floor3/Door4` | `B3/R305` | (24.75,-3.3,-1.5) |
| 306 | `Campus/BuildingB/Floor3/Door5` | `B3/R306` | (30.25,-3.3,-1.5) |
| 307 | `Campus/BuildingB/Floor3/Door6` | `B3/R307` | (35.75,-3.3,-1.5) |
| 308 | `Campus/BuildingB/Floor3/Door7` | `B3/R308` | (41.25,-3.3,-1.5) |
| 201 | `Campus/BuildingB/Floor2/Door0` | `B2/R201` | (2.75,-6.6,-1.5) |
| 202 | `Campus/BuildingB/Floor2/Door1` | `B2/R202` | (8.25,-6.6,-1.5) |
| 204 | `Campus/BuildingB/Floor2/Door3` | `B2/R204` | (19.25,-6.6,-1.5) |
| 205 | `Campus/BuildingB/Floor2/Door4` | `B2/R205` | (24.75,-6.6,-1.5) |
| 206 | `Campus/BuildingB/Floor2/Door5` | `B2/R206` | (30.25,-6.6,-1.5) |
| 207 | `Campus/BuildingB/Floor2/Door6` | `B2/R207` | (35.75,-6.6,-1.5) |
| 208 | `Campus/BuildingB/Floor2/Door7` | `B2/R208` | (41.25,-6.6,-1.5) |

Không có `R407`/`R203`; cửa riêng của hai phòng đó giữ nguyên.
Navigation nằm dưới `Campus/Navigation`: `Room<phòng>` và
`Room<phòng>Link`; sáu hốc cũ giữ tên `Alcove2_1/4/6`, `Alcove3_1/4/6`
và `AlcoveLink...`. Nội thất tối dùng vài khối giường/tủ, chừa trống đường
ra cửa; phòng dùng lại các vách kín hiện có.

`ZombieIdle/B4/I01…I06` lần lượt là (1,0,1.6), (2.6,0,1.6), (4.2,0,1.6),
(1,0,2.7), (2.6,0,2.7), (4.2,0,2.7). Tất cả quay y=-90° để hướng nhìn −Z
địa phương nhìn về +X/phòng 407. `ZombieSpawns/*`, các nhóm idle khác,
chìa/cửa thoát hiểm/Room203Door không đổi.
[Dữ liệu máy đọc](room_doors.json), [layout toàn Campus](layout.json).

## Điều chỉnh phòng 408 đã được duyệt

Ngày 2026-10-07, chủ dự án cho phép điều chỉnh bố trí 407/408 và cho phép
sửa riêng phần hốc cầu thang cũ trong `floor4/duty_desk.tscn`.
Phòng 407 bản 2 đã chiếm x=30…38, nên đặt phòng 408 độc lập ở x=38…44,
z=-5…0, cửa x=42; phòng 407, cửa 407 và nội thất không đổi. Mặt cửa 408
cũ x=36 được bịt bằng tường, giữ node `Sealed408` để tương thích chương
1–2. Cổng sắt, vách và sàn hốc cầu thang trang trí cũ đã được thay bằng
phòng 408; bàn trực, đồ trên bàn, vị trí chìa và cửa thoát hiểm thật giữ
nguyên. Vách sau mới tên `Room408BackWall`, nằm ngoài phòng tắm 407.

`campus_room_navigation.gd` trên `Campus/Navigation` tạm đưa vùng/link
Floor4 độc lập sang map riêng khi Campus hiện diện. Chỉ tắt `enabled`
không đủ: vùng trùng vẫn hút đầu link, khiến đường từ phòng không tới
được hành lang. Khi tháo Campus, map cũ được khôi phục và RID tạm được
giải phóng. Không đổi `campus.gd` hay API tích hợp hiện có.

## Dựng lại và kiểm tra

```powershell
python art_source/campus/room_doors.py
pwsh tools/test.ps1 -Filter levels
pwsh tools/test.ps1
pwsh tools/check.ps1
D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game --script ../art_source/campus/capture_room_doors.gd --audio-driver Dummy
```

Patch chỉ ghi các scene thuộc T-190 (cộng phần `duty_desk.tscn` đã được
duyệt), `room_doors.json` và `layout.json`. Chạy lặp cho cùng kết quả.
`build_campus.py` đã đồng bộ nguồn cửa/nav/anchor; **không chạy toàn bộ
generator chỉ để áp dụng T-190**, vì scene nhà ăn T-189 được dựng riêng.
Không dựng lại generator Floor4 cũ lên phòng 407 bản 2.

Test mới kiểm tra đủ 22 cửa: capsule 0,3×1,6 m bị chặn khi đóng, đi được
khi mở rồi bị chặn lại khi đóng; chỗ đứng thứ hai; nav từ từng spawn tới
hành lang và cast liên tục dọc đường; phòng kín; tách 408/407; hướng idle;
tích hợp `ZombieDoor` thật và đổi hướng tween giữa chừng. Test cũ không bị
xóa hoặc nới expectation. Kết quả cuối ghi tại Handoff task T-190.

Ảnh scene thật: [401 mở](previews/room401_open.png),
[408 mở cạnh bàn trực](previews/room408_open.png). Chưa chơi tay toàn bộ
chương 1–3; thời điểm bật cửa/sinh xác thuộc core T-191.
