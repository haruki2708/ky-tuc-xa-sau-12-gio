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
| Sân | 110…286 / 120…212 | 176 × 92 m; khán đài chính 80 m, 10 hàng, phía +Z |
| Cổng | 190…250 / −60…−20 | Sân 60 × 40 m, cổng rộng 20 m, 12 anchor bảo vệ |
| Nhà ăn | 170…210 / 20…44 | 40 × 24 m; bếp 186…198 / 44…52; kho bên cạnh |
| Giảng đường | −50…30 / 180…200 | 5 tầng, 80 × 20 m |
| Thư viện | 45…85 / 195…225 | 3 tầng, 40 × 30 m |
| Nhà thi đấu | −60…0 / 90…130 | 60 × 40 m, vỏ khóa |

Vòng chạy: hai đoạn thẳng 84,39 m + hai cung bán kính 36,8 m, đo theo tim
làn đầu = **400,001 m**. Có 7 làn rộng 1,22 m, nằm trong khung sân 176 × 92 m.
Cầu thang dùng bậc hiển thị trên collision dốc liên tục để capsule không cần
thuật toán bước bậc. Khán đài có dốc tiếp cận ở đầu tây; navmesh cho từng hàng
nối về dốc, không yêu cầu actor nhảy qua bậc. Đoạn thoát hiểm 2→1 không có
navmesh; đường thay thế qua cầu thang chính. Gầm hàng sau có navmesh riêng.

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
