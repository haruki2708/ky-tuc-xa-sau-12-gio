# Campus — T-183

Scene hoàn chỉnh để Lane A/C tích hợp: `res://scenes/levels/campus/campus.tscn`.
Đặt cạnh `Floor4`, cùng transform gốc (không dịch riêng một scene).
Scene thử: `res://scenes/levels/campus/campus_playtest.tscn`.

Sinh lại bằng Python đi kèm Blender portable:
`D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe art_source/campus/build_campus.py --detail`.
Bộ sinh chỉ ghi thư mục Campus, không ghi Floor4 hoặc Room407.
`--detail` còn sinh model wrapper và texture Campus; bỏ cờ này để dựng greybox.
Greybox đầu đã push ở commit `18661fc` trước khi làm chi tiết.

## Tích hợp

- Campus gỡ collision/ẩn **hai end-cap trên instance** `Floor4/Corridor/WestEnd`,
  `EastEnd`; dùng môi trường Campus, ẩn cây sân giả cũ. Khi Campus rời cây scene,
  các thuộc tính này được phục hồi. Có thể gọi `attach_floor4(floor4)` nếu core
  tạo Floor4 sau Campus; mặc định tìm `../Floor4`.
- API gốc theo card: `set_fire_door_open(bool)`, `set_main_door_chained(bool)`,
  `set_canteen_tv(bool)`, `set_stadium_lights(bool)`, `get_anchor(String)`.
  API chỉ điều khiển hình học/hiển thị, không tự phát trigger cốt truyện.
- Cửa thoát hiểm đóng và cửa chính xích khóa khi tải. API đồng bộ link navmesh.
- `Navigation/WindowCross` và `WindowCrossOut` có metadata `requires_crouch`.
  Lane A cần chuyển actor sang capsule cúi 1,15 m ở cửa sổ. Link 407 cần core
  mở cửa 407. Campus không đổi luật tương tác, chìa khóa hay AI.
- Anchor/vùng theo tên trong card; toàn bộ tọa độ ghi trong `layout.json`.
  Các tọa độ ngoài phần hợp đồng là bố trí kỹ thuật, không bổ sung nội dung truyện.
- Marker `Pxx_Wait_*` đánh dấu chỗ chờ; core quyết định khi nào tiếp tục.
  Dùng marker làm waypoint cho NavigationAgent, không nội suy đường thẳng xuyên
  vật cản giữa các marker xa nhau. Ngư bắt đầu đứng trên ghế, 3 marker đầu đưa
  xuống đất rồi nhập tuyến. Bố trí 202 marker cuối ghi trong `layout.json`.

## Kích thước và đường đi

| Khu | Giới hạn X/Z, mét | Ghi chú |
|---|---|---|
| Toàn khu | −80…420 / −60…290 | 500 × 350 m; đất −9,9 m, lớp đất nền hạ 4 cm để tránh chồng mặt lát |
| Nhà B | 0…44 / −7,6…2,4 | 6 tầng; hai cầu thang phụ thêm 5 m mỗi đầu |
| Vườn | 0…44 / 8…48 | 12 bồn, nhà A phía +Z, ghế Ngư (22; −9,33; 28) |
| Sân | 110…286 / 120…212 | 176 × 92 m; khán đài chính 80 m, 18 bậc, mái che, phía +Z; khán đài phụ 60 m, 7 bậc, phía −Z (T-192) |
| Cổng | 190…250 / −60…−20 | Sân 60 × 40 m, cổng rộng 20 m, 12 anchor bảo vệ |
| Nhà ăn | 170…210 / 20…44 | 40 × 24 m; bếp 186…198 / 44…52; kho bên cạnh |
| Giảng đường | −50…30 / 180…200 | 5 tầng, 80 × 20 m |
| Thư viện | 45…85 / 195…225 | 3 tầng, 40 × 30 m |
| Nhà thi đấu | −60…0 / 90…130 | 60 × 40 m, vỏ khóa |

Vòng chạy: hai đoạn thẳng 84,39 m + hai cung bán kính 36,8 m, đo theo tim
làn đầu = **400,001 m**. Có 7 làn rộng 1,22 m, nằm trong khung sân 176 × 92 m.
Cầu thang dùng bậc hiển thị trên collision dốc liên tục để capsule không cần
thuật toán bước bậc. Khán đài (T-192) cũng vậy: một tấm dốc liền, bậc và ghế chỉ
là hình; navmesh là một mặt dốc cho cả khán đài và một mặt phẳng cho gầm khán
đài chính. Đoạn thoát hiểm 2→1 không có navmesh; đường thay thế qua cầu thang
chính.

Cửa sổ: bậu cao 1 m, khoảng trống đứng 1,44 m, lối dốc rộng 1,8 m hai phía.
Capsule 1,15 m đi qua, capsule 1,75 m bị chặn. Link ghi `requires_crouch` là
metadata tích hợp; navmesh không tự đổi chiều cao actor. Core cần đợi map
đồng bộ sau khi instantiate trước khi truy vấn đường xa.

## Model và pose

Đường dẫn: `res://assets/models/campus/{nhat,ngu,guard,zombie_01…zombie_10}.tscn`.
Model chỉ có hình ảnh, không thêm CharacterBody/AI/hitbox hoặc luật chiến đấu.
Core bọc bằng actor của Lane A, gọi `set_pose(&"walk") -> bool`.
Các tên được hỗ trợ: `idle`, `walk`, `stunned`, `grab`, `sit`, `lie`, `wake`.
`wake` chuyển từ nằm sang đứng trong 1,5 giây và giữ đứng; thời điểm bắt đầu
được core quyết định. Root model không tự dịch chuyển theo animation.
`initial_pose` dùng để đặt pose khi spawn; `set_pose` trả false với tên không hợp lệ.

Các wrapper dùng lại đủ 4 sinh viên CCTV và 3 xác phòng 407, đổi màu áo/tóc,
thêm mắt đỏ emissive yếu và vệt máu hình học. Nhật có sơ mi trắng, Ngư có đuôi
ngựa/thanh sắt, bảo vệ có mũ đồng phục/dùi cui. Mỗi model 640–800 tam giác,
tính cả mesh nguồn bị ẩn; số chính xác trong `metrics.json`.

## Render và hiệu năng

Texture Campus sinh bằng stdlib, 64 × 64 px, nearest; model cũ tái dùng texture
128 px. Cây/đèn tĩnh là MultiMesh chia cụm 40 m, giới hạn hiển thị 125 m.
Môi trường đỏ âm u, fog density 0,018 (che dần ở khoảng 80–120 m).
Các khu là scene riêng, hình học nhỏ để frustum culling; không thêm plugin.

Chạy `Godot_v4.7.2-stable_win64_console.exe --path game --script ../art_source/campus/capture.gd --resolution 1280x720 --audio-driver Dummy`
để ghi 12 ảnh thật và `metrics.json`. Ảnh sân/khán đài bật API đèn sân để kiểm
tra; runtime mặc định tắt đèn sân và màn hình TV. Số liệu đo 120 frame/view sau
90 frame warm-up, có scene Floor4 cũ và 13 model pose tĩnh. Đây là đo render,
**chưa phải benchmark gameplay có 40 zombie AI**; Lane C đo bản tích hợp.
`zone_triangles` đếm cả mesh ẩn và các instance trong MultiMesh, không phải
số tam giác luôn được vẽ. `rendered_primitives`/draw calls ghi theo view.

## Kiểm tra

`pwsh tools/test.ps1 -Filter campus`: hợp đồng, đóng/mở collision, capsule cửa sổ,
đoạn sập, đường navmesh 407 → tầng 2 → cửa sổ → vườn → sân → cổng → nhà ăn/kho,
khán đài và phục hồi Floor4 khi tháo Campus; thêm test pose/giới hạn tam giác
và lấy mẫu capsule cách nhau tối đa 20 cm dọc tuyến navigation. Kết quả full
test/check cuối ghi trong Handoff task card.

Biển trường có tấm biển nghiêng và vết chữ mờ, không tự đặt tên trường. Nội
dung tên/localization cần core/chủ dự án chốt nếu muốn chữ đọc được.

## Cập nhật T-190 — cửa phòng

[Hợp đồng cửa, bảng node/anchor và cách áp dụng patch hẹp](room_doors.md).
Phòng 408 đã chuyển sang x=38…44 theo phép của chủ dự án; phòng 407 giữ
nguyên. Dùng `python art_source/campus/room_doors.py` để áp dụng riêng
T-190; không chạy lại toàn bộ generator Campus lên nhà ăn T-189 chỉ để
cập nhật cửa. [Credits bổ sung](CREDITS.md).

## Cập nhật T-192 — khán đài làm lại, cổng, đồ rải (D-064, D-066)

Làm thay lane B bằng Claude Code trên web. **Dựng lại bằng một lệnh** (chỉ thư
viện chuẩn của Python 3, chạy từ gốc repo):

```
python3 art_source/campus/t192.py
```

`build_campus.py --detail` ghi đè mọi scene Campus, nhưng `building_b.tscn`,
`campus.tscn` và `layout.json` về sau được vá tay (cửa phòng T-190, cầu thang
T-188, bình cứu hỏa D-062, trời D-065). Vì vậy `t192.py` chạy bộ dựng và
`canteen_cn.py`, **trả ba file đó về như cũ**, rồi vá hẹp `campus.tscn` và
`layout.json`: nav của khán đài, anchor đã dời, vùng `Bleachers`, node `Props`.
Mọi thứ nó thêm có `metadata/t192 = true` và id `t192_…`, chạy lại cho cùng
kết quả (đã kiểm: băm các file giống nhau hai lần). Đừng chạy
`build_campus.py` riêng để áp dụng T-192.

| File | Việc |
|---|---|
| `stands.py` | khán đài, tường thấp, hàng rào, cổng, mái, nav khán đài |
| `scatter.py` | đồ rải dọc các tuyến (hạt giống cố định `T192`), đèn, cây thêm |
| `prims.py` | toán xoay và `Batch`: gom hộp, trụ, nón, tấm phẳng thành MultiMesh |
| `t192.py` | chạy bộ dựng rồi vá hẹp (xem trên) |
| `game/scenes/levels/campus/boxes.gd` | vẽ một mảng MultiMesh theo màu từng thể hiện |

### Khán đài và cổng (tọa độ thế giới, mặt đất y = −9,9)

| | Khán đài chính (bắc) | Khán đài phụ (nam) |
|---|---|---|
| x | 158…238 | 168…228 |
| z mặt dốc | 212,7 → 228,0 | 119,5 → 113,2 |
| bậc | 18 (cao 0,38, sâu 0,85), dốc 24,1° | 7 (cao 0,40, sâu 0,90), dốc 24,0° |
| cao nhất | 6,84 m (hàng trên cùng y = −3,25) | 2,80 m (y = −7,30) |
| tường thấp trước mặt | z = 212,4, cao 1,1 m | z = 119,8, cao 1,1 m |
| lối lên (khe tường rộng 6 m) | x = 173, 198, 223 | x = 183, 213 |
| mái | chín cột x = 158…238 (cách 10 m) ở z = 228,9, mặt mái y ≈ +0,4 | không |

- **Gầm khán đài chính:** trống, cao từ 1,9 m trở lên với z ≥ 217,7, mở ra sau lưng
  (z > 229) giữa các cột. `BarSpawns/B03` (164; −9,82; 225,5) và bốn ống sắt
  `LoosePipe` giữ nguyên chỗ; trần ở đó cao hơn 5 m, trên ngưỡng 2 m mà core dùng
  để đặt thanh sắt.
- **Cổng:** hai cổng bắc ở x ∈ [143,153] và [243,253] (z = 212,4), hai cổng nam
  cùng x (z = 119,8), cổng tây/đông giữ nguyên (z 161…171). Cổng giữa x 193…203 bị
  khán đài che nên bỏ. Hàng rào chạy z = 212,4 và 119,8 giữa các cổng; hàng rào tây
  (x = 110) và đông (x = 286) kéo tới hai đường này.
- **Anchor đã dời:** `ZombieSpawns/Stadium/S03` (198; −9,9; 122) → (249; −9,9; 123)
  (cổng nam, đầu đông); `S04` (198; −9,9; 210) → (149; −9,9; 210) (cổng bắc, đầu
  tây); `ZombieIdle/Stadium/I03` → (249; −9,9; 124), `I04` → (149; −9,9; 211);
  `Clues/SirenSpot` (198; −6,9; 226,8) → (198; −3,25; 227,575), tâm bậc trên cùng.
  `Start_stadium`, `S01`, `S02`, `S05`, `S06`, `B03` không đổi.
- **Vùng `Bleachers`:** tâm (198; −5,65; 220,75), kích thước (86; 9,5; 18,5).
- **Nav:** `MainStandSeats`, `MainStandUnder`, `SouthStandSeats` (mặt dốc, gầm),
  link `MainStandAisle0…2`, `SouthStandAisle0…1` (từ đường chạy lên dốc) và
  `MainStandUnderEntry0…2` (từ sau lưng vào gầm). Các node `…Tier*`, `…Ramp*`,
  `UnderBleachers*` cũ đã bỏ. `outdoor_navigation.tres` có thêm vật cản của khán
  đài, tường, hàng rào và đồ rải. Khán đài nhỏ cũ ở z = 108 đã bỏ.

### Đồ rải (`Props`, scene `props.tscn`)

- Dọc mọi tuyến Nhật/Ngư và quanh các khu: xe máy, xe đạp (đổ hoặc dựng trong nhà
  để xe có mái), ô tô (một chiếc ở sân cổng có đèn hổ phách chập chờn), ki-ốt, máy
  bán nước, ghế đá, bồn cây, thùng rác, biển chỉ đường và bảng tin (không có chữ,
  tên trường vẫn để ngỏ như T-183), chướng ngại, nón, thùng gỗ.
- Đồ người chạy loạn: ba lô, giày, dép, điện thoại, khay cơm, giấy; xác nằm (mô hình
  tĩnh, không phải xác sống); xác và đồ vứt trên khán đài.
- Dấu động đất: vết nứt trên đường và sân, cột đèn đổ hoặc nghiêng (năm cột đứng
  cũ đã bị bỏ khỏi `StreetLights`, xem `detail.SKIP_LAMPS`), cây đổ, gạch vụn và kính
  vỡ dưới chân nhà A, nhà B và ba vỏ chương 4, rào chắn chạy ngang sân chạy.
- Hàng cây dày hơn hai bên đường (59 cây thêm, dùng `foliage.gd`); 4 cột đèn còn
  sáng cộng 6 đèn tại cột đứng sẵn, tất cả `OmniLight3D` không bóng đổ, có
  `distance_fade`.
- **Luật giữ lối:** đồ đặc cách tim tuyến ít nhất 3 m + bán kính của nó (lối trống
  ≥ 5 m), không đè điểm xuất hiện xác, đồ lớn đăng ký `obstacle()` cho lưới nav
  ngoài trời. Đồ nhỏ nằm trên đất không có va chạm. Mọi điểm tuyến luôn có ≥ 4
  thứ đáng nhìn trong 30 m (bộ dựng tự bù thêm, test kiểm lại ≥ 3).
- **Hiệu năng:** MultiMesh chia mảng 40 m (decal 80 m), cắt theo khoảng cách
  125 m (khán đài 220 m); màu từng thể hiện nên một chất liệu một nút; va chạm gom
  mỗi mảng 40 m một `StaticBody3D`. Tam giác đo bằng cách đếm lưới × số thể hiện
  như `capture.gd`: **Props 30.037** (gồm 59 cây thêm khoảng 5,3 nghìn),
  **Stadium 8.376** (trước 6.240). Chưa đo FPS (máy cloud không có card đồ họa).

### Kiểm tra

`game/tests/levels/test_stands_props.gd` (8 test): kích thước, hàng bậc và mái của
khán đài; không còn khán đài cũ, cổng mở và tường kín; SirenSpot ở chỗ cao nhất,
B03 và ống sắt dưới gầm; **người chơi thật** đi từ đường chạy lên hàng trên cùng
và vào gầm tới B03; nav từ vườn → sân → cổng → nhà ăn và từ cả sáu điểm xác tới
khán đài; mật độ đồ rải, lối trống ở 635 điểm mẫu và ngân sách tam giác.
`test_campus.gd` nay lấy `Clues/SirenSpot` làm đích thay cho tọa độ cũ.
Ảnh preview trong `previews/` và `metrics.json` **chưa cập nhật** (cần Forward+ và
card đồ họa; integrator chụp khi review).

