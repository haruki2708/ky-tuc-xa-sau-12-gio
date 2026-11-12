# Số đo hình học — T-248

Đo tĩnh bằng Godot 4.7.2, baseline `84dd404`, ngày 12/11/2026. Đơn vị m. X × Z × Y là hộp bao hình học ở tọa độ thế giới; không phải diện tích có thể đi. Tất cả số đếm dưới đây là instance đang bật `is_visible_in_tree()` trong trạng thái khảo sát, không phải tam giác thực sự được GPU vẽ trong một khung hình.

| Mã | Khu | Chương lấy mẫu | Hộp bao X × Z × Y (m) | Tam giác | Vật liệu runtime riêng | Mesh node / instance |
|---|---|---:|---|---:|---:|---:|
| A01 | Bàn trực tầng 4, chìa và đồng hồ | 3 | 3.05 × 0.74 × 2.76 | 1,456 | 23 | 25 / 25 |
| A02 | Nhà vệ sinh chung | 1 | 6.2 × 5.1 × 3.35 | 1,794 | 21 | 31 / 31 |
| A03 | Phòng 401–406, 408: phần cũ còn hiện | 1 | 38.2 × 5.1 × 3.35 | 756 | 6 | 63 / 63 |
| A04 | Đồ rời hành lang tầng 4 | 1 | 24.45 × 3.8 × 2.16 | 1,404 | 14 | 9 / 9 |
| A05 | Cảnh ngoài tầng 4 riêng chương 1–2 | 1 | 43.0 × 9.1 × 5.0 | 84 | 3 | 7 / 7 |
| A06 | Cầu thang chính | 3 | 5.32 × 10.58 × 15.95 | 1,164 | 3 | 97 / 97 |
| A07 | Cầu thang thoát hiểm + cửa + sập | 3 | 5.32 × 10.58 × 15.95 | 984 | 3 | 82 / 82 |
| A08 | Tầng 3 nhà B | 3 | 44.2 × 11.75 × 3.45 | 2,832 | 9 | 204 / 204 |
| A09 | Tầng 2 nhà B, gồm đồ phòng 203 | 3 | 44.2 × 11.75 × 3.45 | 3,264 | 15 | 200 / 200 |
| A10 | Tầng 1, sảnh, phòng quản lý và lối cửa sổ | 3 | 44.2 × 14.97 × 3.45 | 2,952 | 13 | 204 / 204 |
| A11 | Bình cứu hỏa và hộp báo cháy | 3 | 48.17 × 2.41 × 3.17 | 72 | 3 | 3 / 3 |
| A12 | Vườn hoa | 3 | 44.0 × 40.0 × 3.14 | 6,564 | 19 | 273 / 277 |
| A13 | Sân vận động | 3 | 176.35 × 118.65 × 18.21 | 8,340 | 38 | 106 / 587 |
| A14 | Cổng và chốt bảo vệ | 3 | 60.0 × 40.0 × 8.62 | 804 | 6 | 67 / 67 |
| A15 | Nhà ăn, bếp, kho | 3 | 41.14 × 38.1 × 7.39 | 19,380 | 13 | 931 / 931 |
| A16 | Sân, đường, hàng rào, cây và đồ rải | 3 | 500.3 × 350.3 × 10.51 | 46,181 | 454 | 558 / 3252 |
| A17 | Nhà A và bóng người cửa sổ | 3 | 44.0 × 10.33 × 19.87 | 684 | 7 | 62 / 62 |
| A18 | Giảng đường + nhà thể chất | 3 | 90.0 × 110.33 × 16.57 | 1,224 | 4 | 102 / 102 |
| A19 | Mặt ngoài tầng 5–6 nhà B | 3 | 44.0 × 11.65 × 6.3 | 288 | 2 | 24 / 24 |
| A20 | Thư viện ba tầng, gồm chỉ ngoài | 4 | 40.22 × 30.44 × 10.29 | 8,052 | 11 | 671 / 671 |
| A21 | Lối tây nhà ăn | 4 | 0.32 × 24.0 × 4.6 | 60 | 2 | 5 / 5 |
| A22 | Bổ sung 407 chương 4 | 4 | 7.78 × 3.38 × 2.68 | 174 | 7 | 17 / 17 |
| A23 | Phòng bệnh viện | 4 | 5.2 × 6.1 × 3.4 | 758 | 6 | 64 / 64 |
| A24 | CCTV 102 | 1 | 6.1 × 7.65 × 3.35 | 4,184 | 23 | 33 / 33 |
| A25 | CCTV 306 | 1 | 6.1 × 7.65 × 3.35 | 4,464 | 29 | 32 / 32 |
| A26 | CCTV 209 | 1 | 6.1 × 7.65 × 3.35 | 3,980 | 20 | 34 / 34 |
| A27 | CCTV 106 | 1 | 6.1 × 7.65 × 3.35 | 4,228 | 27 | 31 / 31 |
| A28 | CCTV 310 | 1 | 6.1 × 7.65 × 3.35 | 2,468 | 15 | 25 / 25 |
| A29 | CCTV Corridor | 1 | 10.4 × 4.4 × 3.35 | 432 | 4 | 9 / 9 |
| A30 | Chi tiết tương tác và giấy phẳng 407 | 1 | 7.61 × 5.95 × 1.87 | 636 | 19 | 60 / 60 |

## Phạm vi và cách tái kiểm tra

- Mở lần lượt `chapter1.tscn` đến `chapter4.tscn`; đặt `auto_start=false` trước khi thêm scene, chờ `_ready` sinh đồ, dừng xử lý scene. Không chạy tuyến chơi, bot hoặc bộ đo hiệu năng. Bệnh viện được instantiate bằng `_show_hospital()` của director; môi trường và ánh sáng bệnh viện chỉ bật khi chụp bệnh viện.
- Duyệt `MeshInstance3D` và `MultiMeshInstance3D`. Với mỗi surface tam giác: số phần tử index / 3, hoặc vertex / 3 khi không có index. Nhân theo số instance của MultiMesh (tôn trọng `visible_instance_count`). Đọc material override/active material, đếm ID resource duy nhất trong từng nhóm. Mesh AABB được biến đổi bởi global transform và từng instance transform rồi hợp lại.
- Không cộng số vật liệu giữa các hàng: tài nguyên có thể dùng chung; số vật liệu runtime cũng khác số bộ PBR nguồn. Không lấy tam giác làm công thức suy FPS. Không tính collider, NavigationMesh, Marker3D, Label3D hay hạt vào tam giác mesh. Hạt, chữ, đèn và shader vẫn có chi phí ngoài bảng.
- G5, cửa đã nâng và phần Furnished/TripoProps của 407 bị loại bằng phạm vi node. Mesh PS1 cũ đã ẩn không được tính là đồ cần thay. A30 là primitive tương tác cần rà soát mỹ thuật, không khẳng định mọi primitive đều lỗi; cáp mới và mặt gương hiện hành được giữ.
- A16 giữ số của cụm Props đã gộp, trong đó có mảnh hình nhân/xác tĩnh; không thể tách chính xác từng xác từ MultiMesh đã gộp chỉ bằng tên node. Phần nhân vật chỉ ghi danh sách trong PLAN, không giao dựng ở T-248. A17 cũng gồm silhouette cửa sổ. A23 bỏ `Patient` nhưng giữ chăn và giường.
- A24–A29 bỏ Victim/Corpse/Manager theo node; actor được liệt kê riêng. Room310 được scene CCTV nạp sẵn ở chương 1 nhưng nội dung dùng ở chương 2. Các trạng thái ẩn sau tương tác/đổi chương không được giả làm số đếm trạng thái chơi đầy đủ.

## Bộ lọc node đã dùng

Đường dẫn tính từ root chapter; regex bên dưới ghi rõ ranh giới để integrator có thể lập lại probe. Chỉ chạy probe tạm ở `game/_probe_tmp/`, không lưu script/log vào sản phẩm.

| Mã | Bao gồm | Loại thêm |
|---|---|---|
| A01 | `^(Floor4/DutyDesk/&#124;Campus/BuildingB/(DeskClock/&#124;KeyStem/&#124;KeyTooth/))` | `—` |
| A02 | `^Floor4/Washroom/` | `—` |
| A03 | `^Floor4/Corridor/` | `G5&#124;Bucket_&#124;Slippers_&#124;HangingCloth_&#124;Clothesline&#124;YardTree_&#124;DistantStreetLamp` |
| A04 | `^Floor4/Corridor/(Bucket_&#124;Slippers_&#124;HangingCloth_&#124;Clothesline)` | `—` |
| A05 | `^Floor4/Corridor/(YardTree_&#124;DistantStreetLamp)` | `—` |
| A06 | `^Campus/BuildingB/(MainStairs/&#124;Handrail_-4&#124;UpperRubbleDetail/)` | `—` |
| A07 | `^Campus/BuildingB/(FireStairs/&#124;Handrail_48&#124;FireDoor/&#124;FireRubbleDetail/&#124;StairCrack/)` | `—` |
| A08 | `^Campus/BuildingB/(Floor3/&#124;KitDetail3/)` | `—` |
| A09 | `^Campus/BuildingB/(Floor2/&#124;KitDetail2/&#124;Room203)` | `—` |
| A10 | `^Campus/BuildingB/(Floor1/&#124;KitDetail1/&#124;MainDoor/&#124;LobbyRail&#124;ManagerDesk/&#124;Knife/&#124;Window&#124;GlassShard)` | `—` |
| A11 | `^Campus/(BuildingB/(FireExtinguisher&#124;ExtinguisherHandle)&#124;Anchors/FireAlarm1F/)` | `—` |
| A12 | `^Campus/Garden/` | `—` |
| A13 | `^Campus/Stadium/` | `—` |
| A14 | `^Campus/Gate/` | `—` |
| A15 | `^Campus/Canteen/` | `/WestExit/` |
| A16 | `^Campus/(Ground&#124;Road&#124;Fence&#124;Props)/` | `—` |
| A17 | `^Campus/Shells/(BuildingA/&#124;ABand&#124;WindowSilhouette)` | `—` |
| A18 | `^Campus/Shells/(Lecture&#124;Gym)` | `—` |
| A19 | `^Campus/BuildingB/(UpperFloor&#124;UpperWindow)` | `—` |
| A20 | `^Campus/(Library/&#124;Shells/LibraryBand)` | `—` |
| A21 | `^Campus/Canteen/WestExit/` | `—` |
| A22 | `^Campus/Anchors/Ch4/` | `—` |
| A23 | `^HospitalRoom/` | `/Patient/` |
| A24 | `^Chapter1Director/CctvSet/Room102/` | `/(Victim&#124;Corpse\d&#124;Manager)/` |
| A25 | `^Chapter1Director/CctvSet/Room306/` | `/(Victim&#124;Corpse\d&#124;Manager)/` |
| A26 | `^Chapter1Director/CctvSet/Room209/` | `/(Victim&#124;Corpse\d&#124;Manager)/` |
| A27 | `^Chapter1Director/CctvSet/Room106/` | `/(Victim&#124;Corpse\d&#124;Manager)/` |
| A28 | `^Chapter1Director/CctvSet/Room310/` | `/(Victim&#124;Corpse\d&#124;Manager)/` |
| A29 | `^Chapter1Director/CctvSet/Corridor/` | `/(Victim&#124;Corpse\d&#124;Manager)/` |
| A30 | `^Ch1[^/]+/Mesh$&#124;^Floor4/Room407/Anchors/(DatNote/Model/&#124;Router/Model/LED&#124;KhoaOutlet/&#124;DatLocker/Charger/&#124;VietLocker/Paper1/&#124;PhucMattress/Paper2/&#124;TrashBin/(Waste&#124;Paper3/)&#124;GuitarSongbook/&#124;ShowerScreen/Surface&#124;ShowerYes/Button&#124;ShowerNo/Button)` | `—` |
