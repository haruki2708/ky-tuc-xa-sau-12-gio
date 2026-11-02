# T-229 — Khảo sát và kế hoạch hành lang tầng 4

Khảo sát tĩnh: 01/11/2026; chụp và xem ảnh: 02/11/2026. Lane B mới (Codex), nhánh `lane-b/T-229-floor4-corridor-survey`, nền `2773a3f608f33a2bda719a3dcfbf74900cfe07c0`. Đây là đề xuất chờ chủ dự án duyệt, không phải quyết định mỹ thuật hay cấp ngân sách. Không thay scene chơi, không chạy bot, không đo FPS, không gọi Tripo.

## 1. Hiện trạng đo từ scene

Đơn vị mét, tọa độ theo gốc Floor4 (trùng world khi root ở gốc). X tăng về phía bàn trực/đầu đông, +Z hướng lan can; phòng ở phía −Z. Số dưới đây lấy từ transform và BoxShape trong scene, không ước lượng từ ảnh. Vật liệu và hình hiển thị phải tính cả `_ready()` của `floor4.gd`.

| Hạng mục | Số lượng, kích thước/vị trí | Hiện trạng |
|---|---|---|
| Hành lang | 44 × 4 m, X=0…44, Z=0…4; mặt sàn Y=0; mặt dưới trần Y=3 | PS1: sàn khối dày 0,2 m, trần dày 0,15 m, tường module kit |
| Lan can ngoài | Z=3,99, dài 44 m; 89 thanh đứng cách 0,5 m; thanh trên Y=1,07 | PS1; có `RailingBarrier` vô hình cao 2 m tại Z=4,05 để không rơi |
| Cửa 401…406 | 6 cửa ở X=8,12,16,20,24,28; Z=0 | PS1; `LockedDoor_*` có Hinge/Leaf/Blocker, có thể mở theo chương 3 |
| Cửa 407 | Lỗ cửa tâm X=32; trục `Door407`=(32,44;0,01;0) | Cánh và cần gạt Tripo được treo lại vào Pivot ở runtime; khung/vỏ phòng gần chân thực. `Leaf` PS1 vẫn tồn tại nhưng mesh bị ẩn |
| Cửa 408 | `Doorway_408`, `LockedDoor_408` ở X=42; bảng số ở (42;2,42;0,13) | PS1; phòng 408 thật ở X=38…44. Vị trí cũ X=36 là `Former408Wall`, còn `Sealed408` tại (36;1,02;0,13). T-190 đã duyệt giữ tấm bịt cũ cho tương thích chương 1–2; không coi dấu này là cửa thật |
| Đèn hành lang | 9 OmniLight: X=8…40 bước 4, Y=2,8, Z=2; energy=1, range=4,7 | Máng đèn khối PS1. `CorridorLight_408` vẫn ở X=36, không cùng X cửa 408. Scene ghi không bóng; runtime bật bóng các đèn có phạm vi chạm phòng 407 |
| Cửa sổ | Không có node cửa sổ trong `corridor.tscn` | Mặt ngoài là hành lang mở có lan can. Không tự thêm kính/vách/cửa sổ, vì đổi bố cục và đường nhìn |
| Bàn trực | Root (38;0;0); bàn tâm (40;0,4;0,42); va chạm 1,5 × 0,8 × 0,65 m | Bàn, đồ bàn, điện thoại, ghế nhựa, bảng tin, loa và đèn bàn đều PS1 |
| Đèn bàn/loa/bảng | Đèn (39,5;1,06;0,42), energy=0,6/range=2; loa model (40;2,55;0,11); bảng (38,5;1,6;0,14) | Không đồng nhất vị trí model và anchor âm thanh/tài liệu: giữ cả hai |
| Nhà vệ sinh chung | 6 × 5 m, X=0…6, Z=−5…0, cao 3 m; cửa vào rộng 1,2 m, cao 2,3 m | PS1; khác nhà tắm riêng 407 đã nâng |
| Thiết bị nhà vệ sinh | 3 buồng ở X=1,3,5; mặt cửa Z=−3,55; 3 bồn/vòi cạnh tường X≈0,36, Z=−0,85/−1,85/−2,85; gương và nước chảy | PS1; `Washroom/Details` vẫn bộ đạo cụ cũ. Đèn (3;2,8;−2), energy=1,2/range=5 |
| Đồ phơi/dép/xô | 5 món vải ở X=17,20,23,27,30, Z=3,87; 4 đôi dép X=30,5…31,55; 3 xô X=11,19,35 | PS1. Có mẫu Tripo xô, dép, ghế trong thư viện phòng 407 để đề xuất tái dùng |
| Cầu thang | Floor4 độc lập có hai tường chặn đầu; cầu thang thật thuộc Campus | Chương 3–4: chiếu nghỉ chính (−2,5;−0,12;2), thoát hiểm (46,5;−0,12;2), cửa thoát hiểm (44;0;2). PS1; không suy ra từ các subresource cũ không còn được instance trong bàn trực |
| Ngoại cảnh | 4 `YardTree_*`, một `DistantStreetLamp` | PS1 của Floor4 độc lập; Campus ẩn chúng và dùng ngoại cảnh riêng |
| Phòng 407 phía trong | Root (30;0;0), sàn 8 × 7 m | Đã nâng Tripo/Blender T-215/T-222/T-226; không xây lại trong G5 hành lang |

Nguồn: `game/scenes/levels/floor4/{floor4,corridor,duty_desk,washroom}.tscn`, `floor4.gd`, `game/scenes/levels/campus/{campus.gd,building_b.tscn}`. Các kiểm tra kích thước và capsule hiện có: `test_floor4.gd`, `test_wide_corridors.gd`.

## 2. Bảng không được đổi tên hoặc dời

Các đường dẫn dưới đây là hợp đồng cho lượt dựng sau. Trong T-229 toàn bộ scene chơi giữ nguyên. Chỉ thay phần hình dưới đúng node khi có card triển khai; không xoá collider để khớp hình mới.

| Node/anchor/hợp đồng | Giá trị cần giữ | Nơi phụ thuộc và rủi ro |
|---|---|---|
| `Floor4/{Corridor,Room407,Washroom,DutyDesk,Environment,Anchors}` | Tên, gốc và transform | `chapter1_director.gd` và các director kế thừa, `main.gd`, `campus.gd` |
| `Door407/Pivot`, `Leaf`, `RulesPaper`, `HandlePivot/Grip`, `InteractShape` | Root (32,44;0,01;0), chiều mở −90°, vùng tương tác | `door407.gd`, `_hang_furnished_door()`, chapter1: gõ, rung cần gạt, mở cửa, đi vào. Cần gạt runtime scale 1,4 |
| `Anchors/RulesPaper407`, `DoorGap`, `Threshold/Shape` | Giấy theo cánh qua `sync_door_anchor()`; Threshold tâm (32;1;0,30), size (0,90;2;0,36), mask=2 | Giấy và khe cửa phải theo trạng thái cánh, không đóng băng world transform của giấy |
| `Corridor/RoomPartition_38/Mesh` | Tên vẫn tồn tại, hình ẩn nhưng collision còn | D-113 tránh hai mặt tường chồng lên vỏ 407 |
| `Corridor/Navigation`, `Room407Link` | Link (32;0,03;−0,7) → (32;0;1,2); navmesh hiện có | Floor4 độc lập sử dụng; Campus tắt cả hai và phục hồi khi tháo. Không bake navmesh bằng đồ trang trí mới |
| Lối quản lý chương 1 | (25,5;0,05;2) → (32;0,05;2) → (32;0,05;0,6) → (32;0,05;−0,8) | `CORRIDOR_SPOT`, `CORRIDOR_VIA`, `DOOR_SPOT`, `MANAGER_VIA/OUT_VIA` trong chapter1 director; quản lý dùng NavigationAgent và route tường minh, không có node Patrol riêng trong corridor |
| Lối ngoài liên tục | Capsule bán kính 0,3 m, cao 1,75 m; đường X=0,4…43,6 tại Z=3 | `test_wide_corridors`; không thêm chậu/ghế/chân cột vào đường này |
| `Corridor/WestEnd`, `EastEnd`, `RailingBarrier`, sàn/trần/tường/collision của các phòng | World collision layer=1, metadata sàn `surface=tile`; không đổi khẩu độ | Campus bỏ hai nắp đầu chỉ ở instance; tường mới không được bịt lại lối sang cầu thang |
| `LockedDoor_401…406`, `LockedDoor_408` + `Blocker/Hinge/Leaf` | Thuộc tính `room`, group `room_doors`; 408 ở X=42; Hinge local (0,44;0,01;0), mở +90° | `room_door.gd`, `room_door_visual.gd`, chapter3 `_open_room`, `_wave_408`: mở sau lấy chìa, 2 xác sống. Không thay bằng cánh tĩnh |
| `RoomPlate_*`, `Former408Wall`, `Sealed408` | Giữ số phòng và vị trí hiện tại theo bố trí T-190 đã duyệt | T-190 Handoff mục điều chỉnh bố trí, `art_source/campus/room_doors.py` và T-206: tấm bịt X=36 được giữ có chủ đích; cửa thật X=42 |
| `Anchors/seg1_start…seg5_start` | (32;0,03;1,6), (32,95;0,03;−0,75), (32;0,03;−1,2), (32,9;0,03;−1,25), (32;0,03;2); giữ rotation | Điểm vào/checkpoint; các anchor này còn được test cấu trúc |
| `Anchors/Door407`, `Room407LightSwitch`, `Locker_Trung`, `Phone_Trung`, `Bed_Phuc`, `Bed_Viet`, `Bed_Dat`, `Bed_Trung`, `Slippers407` | Giữ toàn bộ transform trong floor4.tscn | Tương tác, điểm giường và chỗ nấp. Ch1 dùng giường an toàn 1/2/4; ch2 dùng Zones và BathroomDoor của Room407. Không có chỗ nấp mới ở hành lang |
| `Anchors/HallBoard`, `HallBoardNote`, `DutyLog`, `Speaker` | (38,5;1,6;0,19), (38,7;1,9;0,205), (39,8;0,85;0,42), (40;2,45;0,37) | Tài liệu và âm thanh; không scale anchor theo model bàn/loa |
| `Anchors/WashroomTapRunning`, `WashroomMirror`, `WashroomNotice` | (0,24;1;−2,85), (0,15;1,62;−1,85), (0,15;1,55;−3,25); giữ rotation | `main.gd` lắp tương tác; `Washroom/Mirror.follow`, TapWater, va chạm bồn/buồng không đổi |
| `Anchors/ClotheslineExtraShirt`, `DarkSection` | (25,5;1,76;3,87), (16;1,5;2) | Đánh dấu hiệu ứng/truyện cũ còn tồn tại; không dùng để tự thêm sự kiện v2 |
| `CorridorLight_* / LightHum`, các `AmbientZone`, `ReverbZone`, `YardInsects`, `SpeakerIdle` | Vị trí, node path, mask, tín hiệu/âm thanh | Lane F sở hữu âm thanh. Đổi visual máng đèn không di chuyển nguồn hay sửa bus |
| `Campus/BuildingB/{MainStairs,FireStairs,FireDoor}` và `Navigation/FireDoorLink` | Lối vào X=0/44, Z=0…4; cửa (44;0;2) | Ch3 chìa thoát hiểm và đuổi; ch4 vẫn dùng Campus. Không chụp cửa mở rồi báo đó là mặc định |
| `Campus/Anchors/FireKey`, `FireDoor`, `RoomSpawns/B4/R408`, `Navigation/Room408Link` | Chìa (39,8;0,66;0,42), spawn (42;0;−1,5), link vào cửa 408 X=42 | Bàn trực mới phải để chìa nhìn/nhặt được. Không di chuyển anchor xuống theo mặt bàn mới |
| CCTV `CCTVSet/Corridor/Cam` | Corridor root (26;0;0), Cam local (0,3;2,75;3,7), FOV=75, far=30 | Ch1 `_build_cctv` đăng ký `cam_corridor`; đây là set riêng, không có camera CCTV trong Floor4. Nâng Floor4 không tự nâng hình trên điện thoại |

Rà tĩnh: cả bốn `chapter*_director.gd`, `manager.gd`, `ch3_actor.gd`, `companion.gd`, scene chapter1…4, `campus.gd`, `room_door.gd`, các test levels. Ch3/4 dùng Campus cùng Floor4, ch1/2 dùng Floor4 độc lập. Không xem dữ liệu demo/archive là thiết kế đang hiệu lực. Chưa chơi tay hay chạy AI; bảng này không thay cho hồi quy sau triển khai.

## 3. Bộ ảnh 1080p và cách tái tạo

Cảnh mới: `game/scenes/levels/floor4/corridor_capture.tscn` + `.gd`. Chỉ camera cố định, không player/director/bot. 10 ảnh đầu là Floor4 độc lập; hai ảnh cuối thêm Campus để thấy cầu thang thật. Không bật/tắt đèn có sẵn hay thay Environment: `night` = ánh sáng đêm mặc định, `torch` = thêm đèn pin camera (energy 1,5, range 12 m, góc 28°, có bóng). Không coi ảnh này là một checkpoint chơi được. Không dựng thêm chữ/số/giấy mà director mới đặt khi chơi.

| Ảnh trong `previews/` | Nội dung |
|---|---|
| [before_01_west_night.jpg](previews/before_01_west_night.jpg) | Đầu tây nhìn dọc về phía 407/bàn trực, lan can và đèn |
| [before_02_east_night.jpg](previews/before_02_east_night.jpg) | Đầu đông nhìn ngược, nhịp cửa/phơi đồ |
| [before_03_door407_night.jpg](previews/before_03_door407_night.jpg), [before_04_door407_torch.jpg](previews/before_04_door407_torch.jpg) | Cùng camera trước cửa 407: đêm/đèn pin |
| [before_05_desk_night.jpg](previews/before_05_desk_night.jpg), [before_06_desk_torch.jpg](previews/before_06_desk_torch.jpg) | Cùng camera bàn trực, bảng, loa, điện thoại |
| [before_07_washroom_night.jpg](previews/before_07_washroom_night.jpg), [before_08_washroom_torch.jpg](previews/before_08_washroom_torch.jpg) | Toàn cảnh nhà vệ sinh chung và cận bồn/gương |
| [before_09_sealed_old408_night.jpg](previews/before_09_sealed_old408_night.jpg) | Dấu niêm phong ở vị trí 408 cũ X=36 |
| [before_10_door408_torch.jpg](previews/before_10_door408_torch.jpg) | Cửa 408 thật ở X=42 |
| [before_11_main_stairs_torch.jpg](previews/before_11_main_stairs_torch.jpg), [before_12_fire_stairs_torch.jpg](previews/before_12_fire_stairs_torch.jpg) | Cầu thang chính/thoát hiểm khi có Campus; camera đặt trên chiếu nghỉ, không mở cửa thoát hiểm |

`capture_report.json` ghi renderer, GPU, kích thước ảnh, eye/target/FOV, cờ đèn pin và Campus; không lấy số đo FPS. Ảnh JPEG gốc không chỉnh sáng/hậu kỳ. Đã xem trực tiếp đủ 12 ảnh ngày 02/11/2026: thấy rõ hình học từng khu vực, cửa 407 khác mức chi tiết với tường PS1, bàn/loa/điện thoại còn thô. Gương nhà vệ sinh chung hiện thành mảng phẳng trong cảnh khảo sát không có player/follow; không kết luận chức năng gương trong bản chơi bị lỗi. Biển số và giấy không có nội dung do cảnh chụp không chạy director. Hai ảnh cầu thang chỉ thể hiện chiếu nghỉ và nhánh đi xuống, không đại diện toàn bộ cầu thang nhiều tầng.

Chạy lần lượt từ gốc lane-b2 khi khóa rảnh (script lấy khóa bằng CreateNew, không đè khóa lane khác; finally trả khóa):

```powershell
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage filter
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage capture
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage smoke
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage test
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage check
```

Script `filter` gọi `pwsh tools/test.ps1 -Filter test_floor4`; `capture` chạy Godot 4.7.2 console, Forward+, có cửa sổ 1920×1080; `test`/`check` gọi nguyên lệnh bắt buộc. Log ở `previews/*.log`. Nếu người khác giữ khóa thì chờ, không xoá. Lần clone đầu phải import asset trước chụp. Stage `smoke` chạy `-Filter test_smoke_scenes`; `verify.ps1` chạy smoke → full test → check và dừng khi lỗi. Cảnh chụp chỉ khởi động khi là current_scene chạy trực tiếp, nên smoke có thể instance headless mà không ghi ảnh hay thoát test runner.

## 4. Phương án chờ chủ dự án chọn

| Câu hỏi | A | B | Đề xuất để duyệt, chưa áp dụng |
|---|---|---|---|
| Màu tường/mức cũ | Kem xám, mảng bẩn thấp, nối bảng màu vỏ 407 | Sơn hai tầng kem/xanh nhạt, vệt ẩm rõ hơn | A để nối 407, chỉ bẩn theo chân tường và quanh tay chạm; không tự thêm máu/ký hiệu truyện |
| Cửa các phòng | Tái dùng mẫu Tripo 407, biến thể độ cũ bằng vật liệu | Cánh phẳng kiểu khác, cần mẫu và lượt Tripo mới | A giảm số asset, giữ bản lề/khẩu độ từng cửa; màu vẫn chờ duyệt |
| Mặt ngoài/cửa sổ | Giữ hành lang mở, dựng lan can Blender | Bổ sung khung cửa sổ/kính theo mẫu chủ dự án cung cấp | A đúng topology hiện có; B đổi đường nhìn và có thể collision nên cần quyết định thiết kế riêng |
| Đồ trang trí | Tái tạo đúng bảng/loa/phơi đồ/dép/xô hiện có | Thêm đồ mới có ý nghĩa truyện | A; B cần chủ dự án chỉ định, không tự viết nội dung giấy hay dấu hiệu |

## 5. Phần dựng Blender, phần tái dùng và Tripo

- Blender: module tường theo lỗ cửa hiện có, sàn gạch và ron, trần, nẹp, khung cửa/ngưỡng, máng đèn tuýp, lan can; bảng tin và giấy phẳng không có chữ. Cửa sổ: **khối lượng hiện tại bằng 0**, chỉ lập module sau khi phương án B được duyệt. Cầu thang dựng bậc/lan can bám nguyên collision ramp/landing của Campus, không đổi độ dốc.
- Tái dùng kỹ thuật T-222: `shell_layout.py`, UV1 theo mét + UV2 mask bẩn, shader `room407_shell.gdshader` đã tối ưu D-132. Tạo atlas riêng hành lang, không dùng lại atlas bẩn định vị giường/nhà tắm của 407. Tách mesh ở ranh giới phòng, không chồng mặt x=38. Không kéo dài cả GLB phòng 407 để làm hành lang.
- Tái dùng cánh `room407_shell/doors/door_room.glb`, tay gạt, vật liệu sàn/tường/nẹp. Phải chuẩn hóa visual vào đúng hinge cửa khác; không thay `RoomDoor` bằng `Door407` vì chiều mở trái ngược.
- Có sẵn Tripo `room407_batch1/{stool,bucket,slippers}.glb`, `room407_batch2/{desk,desk_lamp,sink}.glb`: đề xuất dùng lại đúng tỷ lệ khối tương ứng. Bàn trực phải kiểm hình bàn và điểm chìa; nếu mẫu bàn học không phù hợp thì dựng Blender theo footprint cũ, không tạo mới tự động. Khăn gấp không thay khăn treo; vải phơi dựng Blender hoặc tái dùng vải phù hợp sau duyệt.
- Tripo mới đề xuất: **điện thoại bàn** và **loa phóng thanh** (2 mẫu, mỗi mẫu dự kiến 1–3 lượt = 2–6 lượt). Có lựa chọn dựng Blender cả hai = 0 lượt Tripo. Cửa biến thể chỉ là tùy chọn B: thêm 1–3 lượt nếu được giao. Chi tiết xem `TRIPO_NHAP.md`; đây không phải trần credit đã cấp. Không suy rộng D-095 của phòng 407 thành quyền tiêu tiền cho T-229.
- Làm sau/giữ PS1: nội thất 401…406/408 (trừ phần cửa đã duyệt), sân xa, các tầng thấp và các set CCTV. Nhà vệ sinh chung có thể giữ trong hai lượt đầu, xử lý ở lượt 3. Nội thất phòng 407 đã nâng giữ nguyên. Không tuyên bố CCTV đã gần chân thực khi chỉ đổi Floor4.

### Texture CC0 dự định

Ưu tiên bản đã có trong `room407_shell/texture_sources.json` và `room407_corner/texture_sources.json` (có hash/nguồn), không tải thêm trong T-229. Poly Haven công bố asset CC0 tại [trang giấy phép](https://polyhaven.com/license), đã đối chiếu 01/11/2026. Tên tác giả bên dưới theo manifest của repo; hai asset tường bong và Floor Tiles 08 đã đối chiếu trang gốc.

| Dùng cho | Asset, tác giả | Giấy phép |
|---|---|---|
| Tường bong | [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall), Dimitrios Savva | CC0-1.0 |
| Tường/trần nền | [Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04), Rob Tuytel | CC0-1.0 |
| Sàn hành lang | [Floor Tiles 08](https://polyhaven.com/a/floor_tiles_08), Rob Tuytel | CC0-1.0 |
| Sàn ẩm nhà vệ sinh | [Anti Skid Tiles](https://polyhaven.com/a/anti_skid_tiles), Amal Kumar | CC0-1.0 |
| Lan can kim loại | [Green Metal Rust](https://polyhaven.com/a/green_metal_rust), Rob Tuytel | CC0-1.0 |

Khi triển khai ghi CREDITS cho từng file/biến thể tạo ra, kế thừa tác giả gốc; bản Tripo giữ hồ sơ ngoại lệ D-084, không gán nhãn CC0. Ảnh khảo sát chỉ là render asset hiện có; nguồn ảnh và công cụ nằm ở `CREDITS.md` cùng thư mục.

## 6. Rủi ro hiệu năng và kiểm chứng sau duyệt

Mục tiêu dự án 1080p ≥60 FPS trên RTX 3050 Laptop. Số 86 FPS phòng 407 D-132 là số lịch sử trong card, **không phải kết quả hành lang và không bảo đảm tổng ngân sách**. T-229 không đo FPS.

| Rủi ro | Cách dựng đề xuất | Cách xác minh trong lượt triển khai |
|---|---|---|
| Hành lang 44 m thấy nhiều module cùng lúc | Mesh/material dùng chung; chia theo đoạn/cụm cửa. Có thể MultiMesh cho thanh lan can theo đoạn ngắn | So ảnh hai đầu để thấy lặp texture; kiểm số mesh/material và chỉ đo FPS khi chủ dự án cho phép |
| Nhiều OmniLight chồng phạm vi | Giữ hiện trạng trước; không bật bóng cho tất cả. Bảo toàn bóng đèn gần 407 theo floor4.gd | Ảnh door407 cả hai phía, xem xuyên sáng; đề xuất hạn chế bóng chỉ được áp sau review |
| Occlusion sai ở hành lang mở/cửa động | Chỉ đặt occluder ở khối đặc, không phủ cửa đang mở hoặc mặt lan can | Ảnh cửa 407/408 mở và kín; không dùng culling thay collision |
| Shader mask/texture lớn | Atlas chia khu, dùng chung vật liệu; thử 1K/2K cho tài nguyên mới theo hợp đồng G1/G2 | Không nới test PS1 hay đổi project.godot; mỗi binary ≤10 MB; đối chiếu chất lượng trước tăng ngân sách |
| Cửa/bậc mới lệch gameplay | Giữ collider, marker, navmesh và route; mesh nằm đúng envelope hiện có | Capsule + nav test hiện có, test cửa/chương; chơi tay trước merge triển khai |
| Campus/CCTV tạo chênh lệch | Review riêng Floor4 độc lập, Floor4+Campus, CCTV set | Các set dùng ánh sáng khác nhau; không chữa bằng tăng sáng toàn game |

## 7. Bốn lượt nhỏ đề xuất

1. **Mẫu 1 đoạn 406–407 (cảnh thử riêng):** màu tường, gạch, trần, nẹp và một máng đèn; tái dùng cửa 407. Ảnh cùng góc 03/04, thêm cận mép cửa. Chủ dự án duyệt màu, mức cũ, vật liệu và giữ hành lang mở trước nhân rộng.
2. **Vỏ hành lang + cửa 401…408:** nhân module tới hai đầu, lan can, đèn, biển số giữ nội dung hiện có. Ảnh 01/02/09/10 và cửa đóng/mở. Giữ tấm bịt cũ X=36 theo T-190/T-206; kiểm route quản lý, nav/va chạm, không thay story.
3. **Bàn trực + nhà vệ sinh chung + đồ phơi:** dùng lại ghế/xô/dép; Tripo điện thoại/loa chỉ sau phiếu chính thức và ngân sách. Ảnh 05…08 với điểm chìa/giấy, cận vòi/gương. Chủ dự án duyệt đồ và mức cũ; lane F xác nhận nguồn âm không lệch.
4. **Mép nối cầu thang + review tích hợp:** dựng hình bậc/lan can bám collision Campus nếu card được mở; ảnh 11/12, hai đầu hành lang trong cả hai cấu hình. Integrator điều phối CCTV và hồi quy bốn chương. Test/check bắt buộc; FPS và bot chỉ chạy khi được cấp phép riêng, không suy từ việc duyệt hình.

Mỗi lượt có nhánh/card riêng và ảnh trước/sau cùng camera; chỉ vào bản chơi sau chủ dự án duyệt và integrator review/merge.

## 8. Còn chờ và giới hạn

- Chờ chủ dự án chọn mỹ thuật mục 4. Bố trí 408 đã có quyết định ở T-190, không phải việc chờ chọn lại.
- Chưa thử chơi tay, chưa đo FPS/VRAM, chưa chạy bot, chưa kiểm toàn bộ state bốn chương bằng ảnh, chưa cấp ngân sách hay tạo asset Tripo. Ảnh chụp không chứa player/quản lý đang hoạt động.
- CCTV và core thay đổi ngoài phạm vi T-229; đề nghị card riêng khi tới tích hợp. Không cần sửa ngoài phạm vi để hoàn thành bộ khảo sát này.
- Kết quả thực thi test/check và commit được ghi trung thực trong Handoff T-229; không dùng dự kiến làm kết quả.
