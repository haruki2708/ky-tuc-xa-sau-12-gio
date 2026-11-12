# T-248 — Kế hoạch thay phần đồ họa PS1 còn lại trên toàn map

**Bản khảo sát để chủ dự án duyệt, chưa giao dựng.** Lane A, ngày 12/11/2026. Nhánh `lane-a/T-248-realistic-graphics-survey`; baseline `origin/main = 84dd404`; commit cuối sửa card đã đọc: `84dd404` (`git log -1 --format=%h origin/main -- docs/tasks/T-248-realistic-graphics-survey.md`). Phiên tiếp tục giữ nguyên 71 ảnh đã có, bổ sung hai góc ban công. Không sửa game, không chạy bot, không đo FPS, không tạo model hay tiêu credit Tripo.

Đề xuất **10 đợt**, ưu tiên đường thoát khỏi nhà B và sáu điểm phụ thuộc thân chương 3 trong T-247, sau đó đi qua khuôn viên rồi các khu chương 4. Phòng 407 và G5 hành lang tầng 4 tiếp tục là chuẩn mỹ thuật; chỉ xử lý phần cũ còn nhìn thấy. Tất cả thời lượng, công và ngân sách đồ mới dưới đây là **ước lượng để lập task, chưa đo/chưa duyệt**, không phải cam kết tiến độ hay hiệu năng.

Hồ sơ đi kèm: [số đo và bộ lọc node](MEASUREMENTS.md), [chỉ mục ảnh, camera và hạn chế](previews/survey/INDEX.md), [ảnh tổng hợp](previews/survey/montage.jpg). Mã A01–A30 nhất quán giữa các bảng.

## 1. Nguồn và ranh giới khảo sát

Đọc `AGENTS.md` mục 3–5, STATUS, card T-248 mục Bối cảnh, card T-229 và `art_source/graphics_upgrade/floor4_corridor/PLAN.md`. Cốt truyện theo `docs/design/STORY.md` v2; tuyến chơi đối chiếu các tài liệu CH2/CH3/CH4 hiện hành và director, không dùng thiết kế trong archive.

| Điểm vào thực tế | Các scene/node môi trường được dùng | Kết luận phạm vi |
|---|---|---|
| `game/scenes/main/chapter1.tscn`, `chapter2.tscn` | `levels/floor4/floor4.tscn` → Corridor, Room407, DutyDesk, Washroom; director nạp `levels/cctv/cctv_set.tscn`; chương 2 thêm `levels/ch2/` | Không có Campus trong hai chapter này. Ngoại cảnh Floor4 riêng phải được rà lại, không mặc nhiên được thay khi nâng Campus. |
| `chapter3.tscn`, `chapter4.tscn` | Floor4 + `levels/campus/campus.tscn` → BuildingB, Garden, Stadium, Gate, Canteen, Shells, Ground, Road, Fence, Props, Library, Anchors | `campus.gd` bỏ hai tường chặn đầu Floor4, ẩn cây/đèn ngoại cảnh cũ, vô hiệu môi trường và navigation Floor4 thích hợp với Campus. Hai cầu thang thật thuộc BuildingB. |
| Chương 4 | `levels/library/library.tscn`; `levels/ch4/canteen_west_exit.tscn`, `ch4_anchors.tscn`; director nạp `levels/hospital/hospital_room.tscn` | Thư viện **ba tầng chơi được**, không gộp thành nhà nền. Ch4/Room407 có ván giường, chỗ tìm giả, cửa thông gió và trần giả còn primitive giữa phòng đã nâng. |
| CCTV | Room102, Room306, Room209, Room106, Room310, Corridor cùng Hall/Cam | Đây là trường quay riêng dưới Y = −60, không phải nội thất các phòng có cùng số ở BuildingB. Room310 dùng cho nội dung chương 2 dù được nạp sẵn trong bộ CCTV. |

Trong `shells.tscn` có nhà A, giảng đường, nhà thể chất và các dải trang trí; không tự thêm các dãy ký túc khác không có trong scene. Nhà B tầng 5–6 là khối mặt ngoài, không đề xuất thêm tầng chơi. UI, font, hình điện thoại và chữ tài liệu hiện hành được giữ; đây không phải một đợt thiết kế lại giao diện.

### Cách đọc số đo

Probe Godot 4.7.2 đặt trong `game/_probe_tmp/`, nạp lần lượt bốn chapter, dừng director trước tuyến chơi; lấy mesh sau `_ready`, gồm MultiMesh sinh lúc chạy. Đếm index/3 hoặc vertex/3, nhân số instance; đếm tài nguyên vật liệu thực tế riêng trong từng nhóm. Hộp bao X × Z × Y tính từ global transform, **không phải diện tích đi được**. Các mảnh ở xa nhau làm hộp bao lớn (ví dụ bình cứu hỏa tầng 2 và báo cháy tầng 1).

Chỉ số mô tả hình đang bật trong trạng thái khảo sát, chưa trừ frustum, khoảng cách hay che khuất. Không suy FPS từ tam giác. Bảng không tính chữ, hạt, ánh sáng và collider; chúng vẫn tốn tài nguyên. Không cộng vật liệu giữa các nhóm. A16 bao gồm cả mảnh xác tĩnh đã gộp chung trong Props; A17 có silhouette cửa sổ. Nhân vật chỉ được kê tên, không nằm trong kế hoạch dựng.

## 2. Bảng khu còn PS1 và chi tiết cần rà soát

Đường scene trong bảng bắt đầu tại `game/scenes/levels/`, trừ node do core sinh. T/M = tam giác / vật liệu runtime đo được; kích thước là hộp bao X × Z × Y (m). Thời gian ở khu là **ước lượng**, không phải số chơi thử, các hàng có thể chồng thời gian nhau nên không cộng thành độ dài chương. Mỗi nhóm có2–4 ảnh được chỉ mục bên dưới; ảnh cùng vị trí có thể chứng minh cả nhóm đạo cụ và nhóm căn phòng.

| Mã / khu | Chương dùng | Scene → node | Hộp bao m; T/M | Thời gian và khoảng nhìn |
|---|---|---|---|---|
| A01 — Bàn trực tầng 4, chìa và đồng hồ | 1–4 | `floor4/duty_desk.tscn → DutyDesk; campus/building_b.tscn → DeskClock, KeyStem/Tooth` | 3.05 × 0.74 × 2.76; **1,456/23** | 1–3 phút/lượt; nhìn 0,3–2 m |
| A02 — Nhà vệ sinh chung | 1–4 (scene chung) | `floor4/washroom.tscn → Washroom` | 6.2 × 5.1 × 3.35; **1,794/21** | 1–3 phút nếu ghé; 0,5–3 m |
| A03 — Phòng 401–406, 408: phần cũ còn hiện | 1–4; mở cửa theo chương | `floor4/corridor.tscn → RoomInterior_*, Floor_*, BackWall_*, RoomPartition_*` | 38.2 × 5.1 × 3.35; **756/6** | Đi qua nhiều lần, 10–40 giây/cửa; 1–8 m |
| A04 — Đồ rời hành lang tầng 4 | 1–4 | `floor4/corridor.tscn → Bucket_*, Slippers_*, HangingCloth_*, Clothesline` | 24.45 × 3.8 × 2.16; **1,404/14** | 2–5 phút tổng mỗi lượt hành lang; 0,5–25 m |
| A05 — Cảnh ngoài tầng 4 riêng chương 1–2 | 1–2; bị Campus ẩn ở3–4 | `floor4/corridor.tscn → YardTree_*, DistantStreetLamp` | 43.0 × 9.1 × 5.0; **84/3** | Thoáng nhìn 5–30 giây/lượt; xa dưới tầng4 |
| A06 — Cầu thang chính | 3–4 | `campus/building_b.tscn → MainStairs, Handrail_-4*, UpperRubbleDetail` | 5.32 × 10.58 × 15.95; **1,164/3** | 1–3 phút/lượt; sát chân đến10m |
| A07 — Cầu thang thoát hiểm + cửa + sập | 3–4 | `campus/building_b.tscn → FireStairs, FireDoor, FireRubbleDetail, StairCrack` | 5.32 × 10.58 × 15.95; **984/3** | 1–3 phút; cửa0,3–1m, bậc sát chân |
| A08 — Tầng 3 nhà B | 3–4 | `campus/building_b.tscn → Floor3, KitDetail3` | 44.2 × 11.75 × 3.45; **2,832/9** | 1–3 phút; 0,5–44m |
| A09 — Tầng 2 nhà B, gồm đồ phòng 203 | 3–4 | `campus/building_b.tscn → Floor2, KitDetail2, Room203Bed/Desk` | 44.2 × 11.75 × 3.45; **3,264/15** | 3–6 phút gồm cứu Nhật; 0,5–44m |
| A10 — Tầng 1, sảnh, phòng quản lý và lối cửa sổ | 3–4 | `campus/building_b.tscn → Floor1, KitDetail1, MainDoor, ManagerDesk, Knife, Window*` | 44.2 × 14.97 × 3.45; **2,952/13** | 3–6 phút; phòng0,3–5m, sảnh xa |
| A11 — Bình cứu hỏa và hộp báo cháy | 3; scene tái dùng4 | `BuildingB/FireExtinguisher, ExtinguisherHandle; Anchors/FireAlarm1F (core sinh)` | 48.17 × 2.41 × 3.17; **72/3** | 10–40 giây/món; 0,3–1,5m |
| A12 — Vườn hoa | 3–4 | `campus/garden.tscn → Garden` | 44.0 × 40.0 × 3.14; **6,564/19** | 3–7 phút; 0,5–40m |
| A13 — Sân vận động | 3–4 nhìn lại | `campus/stadium.tscn → Stadium` | 176.35 × 118.65 × 18.21; **8,340/38** | 5–10 phút; sân sát chân, khán đài5–150m |
| A14 — Cổng và chốt bảo vệ | 3–4 nhìn lại | `campus/gate.tscn → Gate` | 60.0 × 40.0 × 8.62; **804/6** | 3–6 phút; 1–60m |
| A15 — Nhà ăn, bếp, kho | 3–4 | `campus/canteen.tscn → Canteen/TV, KitchenFloor, StoreFloor và đồ lặp` | 41.14 × 38.1 × 7.39; **19,380/13** | 8–15 phút; tương tác0,3–3m, sảnh40m |
| A16 — Sân, đường, hàng rào, cây và đồ rải | 3–4 | `campus/campus.tscn → Ground/Road/Fence; props.tscn → Parts/Decals/Trees` | 500.3 × 350.3 × 10.51; **46,181/454** | 10–20 phút cộng nhiều đoạn; sát đất đến250m |
| A17 — Nhà A và bóng người cửa sổ | 3–4 | `campus/shells.tscn → BuildingA, ABand*, WindowSilhouette*` | 44.0 × 10.33 × 19.87; **684/7** | Thoáng nhìn nhiều lần; 20–100m, chân nhà có thể gần |
| A18 — Giảng đường + nhà thể chất | 3–4 | `campus/shells.tscn → Lecture/Gym và Band*` | 90.0 × 110.33 × 16.57; **1,224/4** | Thoáng nhìn trên đường; 20–200m |
| A19 — Mặt ngoài tầng 5–6 nhà B | 3–4 | `campus/building_b.tscn → UpperFloor5/6, UpperWindow*` | 44.0 × 11.65 × 6.3; **288/2** | Thoáng nhìn từ sân; 10–80m |
| A20 — Thư viện ba tầng, gồm chỉ ngoài | 3 đóng; 4 vào | `library/library.tscn → Library; Shells/LibraryBand*` | 40.22 × 30.44 × 10.29; **8,052/11** | 8–15 phút dự kiến; 0,3–30m |
| A21 — Lối tây nhà ăn | 4; cùng scene nhà ăn3 | `ch4/canteen_west_exit.tscn → Canteen/WestExit` | 0.32 × 24.0 × 4.6; **60/2** | 5–20 giây; 0,3–3m |
| A22 — Bổ sung 407 chương 4 | 4 | `ch4/ch4_anchors.tscn → Anchors/Ch4/Room407` | 7.78 × 3.38 × 2.68; **174/7** | 2–5 phút; 0,3–3m, cửa đếm90s |
| A23 — Phòng bệnh viện | 4 đoạn kết | `hospital/hospital_room.tscn → HospitalRoom` | 5.2 × 6.1 × 3.4; **758/6** | 1–3 phút dự kiến; camera gần0,5–4m |
| A24 — CCTV 102 | 1 (nạp chung ở chapter khác) | `cctv/cctv_set.tscn → Room102 + Hall` | 6.1 × 7.65 × 3.35; **4,184/23** | 10–60 giây/lần xem; camera cố định |
| A25 — CCTV 306 | 1 (nạp chung) | `cctv/cctv_set.tscn → Room306 + Hall` | 6.1 × 7.65 × 3.35; **4,464/29** | 10–60 giây/lần xem; camera cố định |
| A26 — CCTV 209 | 1 (nạp chung) | `cctv/cctv_set.tscn → Room209 + Hall` | 6.1 × 7.65 × 3.35; **3,980/20** | 10–60 giây/lần xem; camera cố định |
| A27 — CCTV 106 | 1 (nạp chung) | `cctv/cctv_set.tscn → Room106 + Hall` | 6.1 × 7.65 × 3.35; **4,228/27** | 10–60 giây/lần xem; camera cố định |
| A28 — CCTV 310 | 2 (scene được nạp sẵn từ1) | `cctv/cctv_set.tscn → Room310 + Hall` | 6.1 × 7.65 × 3.35; **2,468/15** | 30–90 giây/lần xem; camera cố định |
| A29 — CCTV Corridor | 1–2 (nạp chung) | `cctv/cctv_set.tscn → Corridor` | 10.4 × 4.4 × 3.35; **432/4** | 10–60 giây/lần xem; camera cố định |
| A30 — Chi tiết tương tác và giấy phẳng 407 | 1–4 | `floor4/room_407.tscn → Anchors; Ch1*/Mesh do director sinh` | 7.61 × 5.95 × 1.87; **636/19** | Đọc/lấy5–60 giây/món; 0,2–1m |

Kích thước sử dụng đáng chú ý: hành lang B dưới44 × 4m, phòng theo bay5,5 × 7,6m; vườn44 × 40m; đường chạy sân176 × 92m (hộp bao cả mái/khán đài lớn hơn); nhà ăn chính40 × 24m, bếp/kho mỗi12 × 8m; nhà A44 × 10m, giảng đường80 × 20m, nhà thể chất60 × 40m; thư viện40 × 30m ×3tầng; bệnh viện5 × 6m. Hộp bao A24–28 gồm cả Hall nên lớn hơn phòng4 × 5m.

**Phần đã nâng/giữ:** G5Corridor, cửa hành lang và Door407; Furnished/TripoProps/vỏ407, cáp mới, gương hiện hành; khăn/áo thật T-245 và bộ nhà tắm riêng407. `levels/ch2/{towel,shirt,clothesline,bathroom_effects,zones}` vẫn cần hồi quy ở đợt10 nhưng không coi toàn bộ là PS1: các placeholder ẩn không tính vào bảng. Hơi nước/mặt gương là hiệu ứng, không dùng số tam giác để kết luận phải dựng lại. A30 gồm16tam giác giấy đọc runtime để không bỏ sót lớp chữ, không đề xuất thay văn bản.

## 3. Cách dựng từng khu và mức chi tiết

Ưu tiên Blender cho kiến trúc có kích thước chính xác, cửa, bản lề, tay nắm, collider và đồ lặp. Tái dùng bộ PBR CC0 và asset 407/G5 **sau khi kiểm lại nguồn và chi phí**, không sao nguyên đồ nặng cho mọi phòng. Tripo chỉ là danh sách ứng viên để chủ dự án tạo sau khi duyệt; số dưới đây là **mẫu khác nhau**, không phải số instance hay số lượt tạo.

| Mã | Blender / tái dùng | Tripo mới đề xuất | Chi tiết và phần phải giữ |
|---|---|---|---|
| A01 | Bàn có thân và ngăn kéo riêng, ray trượt; chìa, đồng hồ, bảng, ghế và đèn tái dùng/chỉnh bộ 407 | 2: điện thoại bàn, loa treo | Gần 0,3–2 m. Giữ vị trí chìa, mặt bàn, đồng hồ và nguồn tiếng; ngăn kéo là chuẩn bị cho T-247 dòng 5, không tự đổi thao tác. |
| A02 | Vỏ gạch, buồng, vòi, ống, gương; tái dùng thiết bị 407 ở biến thể nhẹ | 0 | Gần; giữ cửa vào 1,2 m, ba buồng, vòi/nước, camera gương và điểm tương tác. Không biến thành phòng tắm 407. |
| A03 | Module phòng 4 × 5 m (408 rộng hơn), vách, sàn, trần và nội thất nhìn qua cửa; bộ giường/bàn/tủ nhẹ | 0 | Trung/cận tại cửa; giữ cửa G5 mới, phòng 408 thật tại X=38…44 và dấu bịt cũ ở X=36. Không mở thêm phòng chơi. |
| A04 | Tái dùng xô, dép, áo/khăn 407 với LOD; dây và móc Blender | 0 | Gần đến 25 m; giữ số lượng, vị trí, chuyển động vải, lối đi và lan can. |
| A05 | Cây/đèn nền dùng bản nhẹ của A16, giữ gốc scene Floor4 độc lập | 0 | Xa từ tầng 4; không thêm Campus vào chương 1–2 chỉ để đồng bộ hình. |
| A06 | Bậc, chiếu nghỉ, trụ, tay vịn, phần chặn tầng trên và mảnh vỡ theo số đo | 0 | Cực gần bàn chân; T-247 dòng 9. Mặt đứng/mặt bậc phải khớp collider, giữ độ cao tầng 3,3 m và vùng chặn. |
| A07 | Như A06; thêm cánh cửa thép, bản lề, ổ khóa, tay nắm độc lập; mảnh sập không lấn tuyến | 0 | Cực gần; T-247 dòng 6 và 9. Giữ cánh quay, lối mở và trạng thái cầu thang sập. |
| A08 | Hành lang, vách, bảng số, đèn, lan can bộ B dùng chung; phòng sau cửa chỉ làm mặt nhìn thấy | 0 | Gần đến xa dọc 44 m; giữ door blockers, chỗ xác xuất hiện và phá cửa. |
| A09 | Như A08; phòng 203 dùng giường và bàn bản nhẹ | 0 | Gần 0,5–5 m trong phòng, xa ngoài hành lang; giữ cửa 203 mở lúc đầu, điểm Minh Nhật và tuyến cứu. Chìa bàn trực thuộc A01, không thuộc tầng 2 dù node nằm dưới BuildingB. |
| A10 | Sảnh, cửa chính/xích, bàn quản lý, dao, khung cửa sổ, kính vỡ; bậu và đường bước khớp collider | 0 | Gần; T-247 dòng 10. Giữ cửa chính không thành lối thoát; cửa sổ vẫn tự đi khom qua, không gợi ý mới. |
| A11 | Hộp báo cháy, nút, gá bình và tay cầm theo điểm bàn tay; chuẩn hóa bình sau bake | 1: bình cứu hỏa | Cực gần; T-247 dòng 7–8. Giữ `Ch3Use`, âm thanh, tầm thu hút và trạng thái nhiệm vụ; chuyển động mới chỉ khi chủ dự án duyệt T-247. |
| A12 | Bồn hoa, viền, ghế, đường lát; cây có thân/tán tách, biến thể ít vật liệu | 2 cụm cây/hoa đại diện, tùy chọn | Gần ở ghế Ngư, xa các bồn khác. Giữ 12 bồn, chân ghế, tuyến NPC và cây chỉ có collision thân như hiện hành; không thêm vật cản tán. |
| A13 | Mặt sân, đường chạy, vạch, khung thành, hàng rào, khán đài, mái và đèn bằng module | 0 | Gần mặt sân/bậc; phần mái và khán đài xa dùng LOD. Giữ vùng chạy, đợt xác, chỗ nhặt thanh sắt và trạng thái đèn sân. |
| A14 | Cổng, thanh chắn, chốt bảo vệ, biển và đèn; tái dùng bàn/ghế | 0 | Gần chốt, trung cổng; giữ đường tuần tra của 12 bảo vệ, vùng phát hiện và đường sang nhà ăn. |
| A15 | Vỏ, quầy, bàn ghế, kho/kệ, TV/đồng hồ, bếp và dụng cụ đơn giản; atlas khay lặp | 4: nồi lớn, chảo, bình gas, bộ khay/bát | Gần ở TV/bếp/kho, xa bàn lặp. Giữ TV bật/tắt, cửa, giờ đồng hồ, chỗ bẫy/ẩn và mặt tương tác. Bộ khay/bát là một mẫu được tách phần khi cần. |
| A16 | Mặt đất, đường, hàng rào, đèn; cây và rác theo cụm, normal/decal chung | 0 ngoài 2 mẫu A12 | Gần trên tuyến, xa phần rìa. Giữ navmesh, Zones, spawn, vị trí thanh sắt. Không thay một MultiMesh nhẹ bằng hàng nghìn Node3D độc lập. Xác tĩnh tách khỏi giao việc môi trường. |
| A17 | Mặt tiền nhà A, khung cửa và dải tầng, vật liệu tường; không làm phòng sau mọi cửa | 0 | Nền 20–100 m; chân nhà có thể tới gần nên có biến thể mặt tường đủ nét. Giữ silhouette theo truyện. |
| A18 | Giảng đường và nhà thể chất dạng vỏ ngoài có mái, cửa giả và chỉ tầng | 0 | Chủ yếu xa; không dựng nội thất hay thêm lối vào. Phần gần đường dùng tường chi tiết vừa, mặt khuất rất nhẹ. |
| A19 | Mặt ngoài tầng 5–6 B đồng bộ tầng dưới, LOD riêng | 0 | Xa và nhìn từ dưới lên; giữ tầng bị chặn, không nhân toàn bộ nội thất tầng 1–3 lên trên. |
| A20 | Thư viện ba tầng: vỏ, cửa, cầu thang, kệ, sách atlas, bàn/ghế, quầy, bản đồ và vật chặn | 0 | Gần tại quầy/bản đồ/cửa sau; xa kệ lặp. Giữ cửa chịu phá, vị trí thanh sắt, các chỗ tìm/ẩn và đường NPC lên tầng. |
| A21 | Khung lối tây và tường tiếp giáp nhà ăn; bề mặt đồng bộ A15 | 0 | Gần qua ngưỡng; giữ Threshold/Outside navigation và điểm chuyển chặng. Ảnh tĩnh còn vật che tại lỗ: integrator kiểm trong đúng giai đoạn chơi trước khi dựng. |
| A22 | Ván giường có hinge riêng, mặt chữ mặt dưới, miệng gió và trần giả; bỏ hình hộp đứng thay bằng phần nhìn đúng chức năng | 0 | Cực gần. Giữ Slat1/2/4, chữ lộ đúng lúc, chỗ tìm giả, cửa 407 và đồng hồ phá cửa. Không làm lại giường Tripo. |
| A23 | Vỏ phòng, cửa sổ, tủ cạnh giường, dây truyền và ga gối bằng Blender | 3: giường bệnh, cây truyền dịch, máy theo dõi | Gần camera kết. Giữ ba giường, thẻ tên, Camera_Wake, nguồn thoại và nhánh đồng đội còn/mất; kiểm lại cháy sáng trước chọn màu. |
| A24 | CCTV102: dùng bộ giường/tủ/bàn nhẹ, áo và nội thất đặc trưng theo scene | 0 | Theo camera cố định; giữ mọi silhouette/che khuất có ý nghĩa và Hall/Cam. |
| A25 | CCTV306: bộ chung, xô và khăn tái dùng | 0 | Như A24; không tự đổi vị trí đạo cụ nhận dạng. |
| A26 | CCTV209: bộ chung và nội thất riêng hiện có | 0 | Như A24; giữ màn, giường, vị trí nạn nhân và cửa. |
| A27 | CCTV106: bộ chung, màn và quạt trần | 0 | Như A24; không làm màn quá kín khiến mất dấu hiệu quan sát. |
| A28 | CCTV310: bộ chung, ba chỗ xác và nạn nhân đúng bố cục | 0 | Chương 2; giữ sự kiện quan sát. Nhân vật đi theo nhiệm vụ riêng. |
| A29 | Hành lang trường quay CCTV dùng module G5 rút gọn | 0 | Theo camera; giữ số cửa, thứ tự và cửa 407. Không đổi trường quay thành hành lang thật. |
| A30 | Rà sổ/giấy, bộ sạc, ổ điện, điểm dây đàn, nút tắm: bevel/normal cần thiết; giữ LED/mặt phản chiếu/cáp mới | 0 | Cực gần khi đọc/lấy; giữ chữ, UV và key dịch. Giấy hai tam giác là hợp lý, không cần dày lên chỉ vì ít tam giác. |

**Tổng ứng viên Tripo: 12 mẫu, trong đó 2 mẫu cây/hoa tùy chọn; phương án tối thiểu 10 mẫu.** Tìm đồ đã có của 407 trước khi đặt tạo mới. Tripo chi tiết → bản nhẹ + normal bake theo D-088 và `art_source/graphics_upgrade/tripo/bake_prop.py`. Chủ dự án tự tạo theo D-095; T-248 không đặt trần lượt/credit mới. Khi giao tạo phải có tài khoản Paid, hồ sơ gói/ngày/task ID/điều khoản/nguồn đầu vào theo D-084; không coi Paid là CC0. Mỗi asset có CREDITS và khai báo AI. Bộ vật liệu kiến trúc ưu tiên nguồn CC0 đã ghi trong 407/G5; nguồn mới phải có URL, tác giả, giấy phép trước khi nhập.

## 4. Hợp đồng gameplay phải giữ khi giao đợt dựng

Không thay tên/transform root, marker, signal, resource path mà director/test đang tìm. Thay mesh dưới node sở hữu phần hình; giữ collider, input, navmesh, layer 1/2/3 và phương thức hiện hành. B thay môi trường; A/core nối tương tác theo card riêng sau duyệt, C kiểm hồi quy. Không dùng việc cần đồ mới làm lý do tự đổi luật chơi.

| Điểm cần bàn giao B ↔ A/core | Vị trí thế giới hiện hành (m) / hợp đồng | Phụ thuộc |
|---|---|---|
| FireKey | `(39.8, 0.66, 0.42)`; bàn trực ở Floor4, KeyStem/KeyTooth nằm dưới BuildingB | T-247 **5**: ngăn kéo có thể trượt; chìa riêng, điểm pinch. Thời gian thao tác mới còn chờ chủ dự án. |
| FireDoor | `(44, 0, 2)`; pivot cửa và blocker giữ nguyên | T-247 **6**: ổ khóa/tay nắm tách, điểm tay đi theo cánh. |
| Extinguisher2F | `(48.83, −5.5, 2.4)`; thân bình khoảng 0,2 × 0,55 × 0,2 m hiện hành | T-247 **7**: gá, cổ bình và điểm cầm rõ; không đổi `Use_Extinguisher2F`/tiếng động trước duyệt. |
| FireAlarm1F | `(0.9, −8.5, 0.12)`, cao 1,4 m từ tầng 1 | T-247 **8**: mặt nút có điểm đặt bàn tay; core đang dựng hộp runtime nên cần core thay tài nguyên. |
| Cầu thang | MainStairs phía X=−5…0, FireStairs X=44…49; tầng 1/2/3/4 ở Y=−9,9/−6,6/−3,3/0 | T-247 **9**: bậc nhìn khớp bậc va chạm cho foot IK; giữ vùng Collapse2F `(46.5, −6.6, −1)` và mảnh chặn trên. |
| Cửa sổ quản lý | ManagerWindow `(4, −8.9, −7.6)`; bậu cao 1 m, giữ WindowApproach/Bridge/Exit | T-247 **10**: không prompt “Trèo qua”, không thay lối khom D-055. Tay/IK chỉ là đề xuất theo T-247. |
| Phòng 203 | Room203Door `(13.75, −6.6, 0)`; phòng bay 5,5 × 7,6 m | Giữ trạng thái mở ban đầu, chỗ Minh Nhật, vùng phục kích và đường dẫn ra bình. |
| Tuyến Campus | Garden start `(22, −9.9, 8)`, Stadium `(115, −9.9, 166)`, Gate `(220, −9.9, −25)` | Giữ Anchors, Zones, Navigation/links và điểm đặt bot hiện có. T-248 không chạy bot. Không dời cây/ghế vào vị trí đồng đội. |
| Nhà ăn | TV khoảng `(170.3, −7.5, 32)`; đồng hồ `(192, −7.4, 51.85)`; cửa kho `(202, −9.9, 52)` | Không làm mất đường nhìn, nhịp TV, giờ hoặc tuyến thoát. Lối tây ở X=170, Z=39,5…41,5. |
| Thư viện | root `(45, −9.9, 195)`, 40 × 30 m; ba tầng cách 3,3 m | Giữ FrontDoor/BackDoor, bản đồ, quầy, đường cầu thang và cửa bị phá 75 s. Không “trang trí” kín lối NPC. |
| Room407 chương 4 | `Campus/Anchors/Ch4/Room407`, Slat1/2/4, FakeLocker/FakeCeiling/FakeVent | Giữ 90 s cửa 407, thứ tự tiết lộ tên, thao tác giữ E và signal `bed_slat_flipped`. |
| Bệnh viện | director nạp tại `(0, 300, 0)` | Giữ Camera_Wake, Bed_Trung/Nhat/Ngu/Card, Nurse1/2, MonitorAudio và nhánh kết. Không thêm nhân vật y tá hữu hình theo suy đoán. |

Thanh sắt cầm/vung/gãy thuộc **T-249**, không đặt thêm mẫu Tripo hoặc làm lại trong T-248. Các cửa 407/nhà tắm/ban công, tay gạt và thân Trần Trung chương 1–2 đã nâng: giữ hợp đồng T-241/T-242/T-245. Không đụng mesh cũ đang ẩn chỉ vì chúng còn trong `.tscn`.

## 5. Mười đợt đề xuất theo tuyến

Đơn vị công: **ngày-người kỹ thuật/mỹ thuật**, giả định dùng lại kit và tài nguyên hợp lệ. Bao gồm chuẩn hóa, bake, LOD, lắp cảnh và kiểm cơ bản; chưa gồm thời gian chờ chủ dự án, tạo lại Tripo hoặc giải quyết lỗi thiết kế phát hiện khi chơi. Tổng sơ bộ **54–87 ngày-người**, không phải lịch giao. Từng đợt phải có card, ảnh mẫu và chủ dự án duyệt trước khi mở rộng.

| Đợt | Khu / sản phẩm có thể review | Công | Rủi ro và điều kiện qua đợt |
|---|---|---:|---|
| 1 | Bàn trực → cửa thoát hiểm → hai cầu thang: A01, A06–07; mẫu vật liệu B và chia cụm Campus trước | 5–8 | **T-247 dòng 5, 6, 9**. Chốt kích thước ngăn kéo, ổ khóa, tay gạt và bậc trước IK. Chưa tự triển khai động tác T-247. |
| 2 | Hành lang tầng 3→2→1, phòng 203, bình/báo cháy, sảnh, phòng quản lý/cửa sổ: A08–11 | 6–10 | **T-247 dòng 7, 8, 10**. Rủi ro cửa phá, cứu đồng đội, chui bậu; kiểm collider/nav và đúng tuyến trước trang trí. Sau đợt này mới đủ nền cảnh cho sáu dòng 5–10. |
| 3 | Vườn hoa và phần đường nối gần: A12 + A16 đoạn B→vườn | 5–8 | Cây mới dễ che NPC, tán alpha tốn GPU; giữ vị trí thân và test nhìn từ tầng 4. |
| 4 | Sân vận động, khán đài và lối ra: A13 + A16 đoạn nối | 5–8 | Mặt sân rất rộng, nhìn nhiều vật cùng lúc; LOD khán đài/mái và ánh đèn phải đi cùng mẫu đầu. |
| 5 | Đường tới cổng và chốt bảo vệ: A14 + A16 đoạn cổng | 3–5 | Bảo vệ cần đường nhìn cũ; vật mới không che/đẩy vùng bắt. |
| 6 | Nhà ăn → bếp → kho: A15 | 6–10 | 931 mesh node hiện hành, nhiều bàn/khay lặp; rủi ro draw call và ánh sáng bóng. Kiểm TV/giờ/cửa sau. |
| 7 | Nhà nền A, giảng đường, nhà thể chất, B tầng 5–6; hoàn thiện mặt đất/rìa và nền riêng ch1–2: A05, A16–19 | 4–7 | Không mở khu chơi mới. Kiểm toàn cảnh từ hành lang tầng 4; ưu tiên silhouette/PBR/LOD, không thêm nội thất sau cửa giả. |
| 8 | Lối tây nhà ăn → thư viện ba tầng: A20–21 | 7–11 | Cửa chịu phá, cầu thang, bản đồ, kệ và hàng rào chặn; chia tầng để che khuất. Phải kiểm trạng thái lối tây trước khi thay hình. |
| 9 | Trở về B/407 và đoạn kết bệnh viện: A22–23 | 5–8 | Ván/giấy mặt dưới, chỗ tìm giả, timer và nhánh kết; kiểm cháy sáng ở bệnh viện riêng trước duyệt chất liệu. |
| 10 | Khép phần còn sót chương 1–2: nhà vệ sinh, phòng khác tầng 4, đồ hành lang, CCTV và chi tiết 407: A02–04, A24–30 | 8–12 | Tái dùng kit đã duyệt ở các đợt trước. Giữ dấu hiệu CCTV, chữ/ảnh tài liệu, hơi nước và gương; kiểm đồng bộ cả bốn chapter. |

Mỗi đợt đi theo vòng: mẫu nhỏ → ảnh cùng camera/ánh sáng → chủ dự án duyệt → lắp rộng → integrator chạy kiểm phù hợp và đo lại chapter thật. Kế hoạch này không đổi ngưỡng test production. Tối ưu xa/che khuất là phần của từng đợt, không dồn đến đợt 7 mới bắt đầu. Các đợt chỉ là đề xuất, chưa cấp quyền sửa code/core hay scene ngoài card mới.

## 6. Ngân sách 1080p — toàn bộ đồ mới **chưa đo**

Mục tiêu dự án: trung bình ≥60 FPS trên RTX 3050 Laptop, tức **≤16,67 ms/khung**. Không có số FPS mới trong T-248. Các báo cáo nguồn, đo ở thời điểm khác nhau, không thể cộng/trộn thành một kết quả benchmark:

| Báo cáo trong `tools/reports/` | Số đo cũ có thể dùng định hướng | Giới hạn khi suy luận |
|---|---|---|
| `D-114-room407-performance.md` | 407 riêng, góc thấp nhất 1080p 97,7 FPS; p95 cao nhất 10,45 ms | Không có Campus/đầy đủ actor; không dùng làm ngân sách toàn map. |
| `D-148-corridor-fps.md` | Floor4 riêng: thấp nhất TB 122,4 FPS (8,17 ms), 1% 65,8; đổi G5 thêm khoảng 0,55 ms trung bình | Khoảng 96,5k tam giác/17 vật liệu nguồn không đại diện số vật liệu runtime chapter. |
| `T-237-chapter-fps.md` | Ch1 thấp nhất TB147,2; Ch3 góc tây74,3 (~13,46 ms), 1%42–44; góc đông1%56–57. G5 thêm ~0,45 ms trung bình | Campus đã là điểm nghẽn. Có góc cầu thang dao động lớn; số horde trong báo cáo là 720p, không đổi nhãn thành 1080p. |
| `T-243-ch2-body-fps.md` | Ch2 có thân/hơi nước/xác: TB thấp nhất100,2 (~9,98 ms), 1% thấp nhất67,5; thân khoảng0,4–1,6 ms | Không áp dụng cho horde chương3/4. Nhà tắm 407 đã nâng, không phải nhà vệ sinh chung A02. |

Ở góc Ch3 nặng đã biết, còn khoảng **3,21 ms** tới 60 FPS theo trung bình. Đề xuất chỉ cho **tổng phần nâng môi trường cùng nhìn thấy tăng tối đa khoảng1,0 ms** so với baseline cùng camera trước khi có số mới; giữ khoảng2,2 ms cho thân/tương tác và dao động. Đây là cách phân bổ thận trọng, không chứng minh đủ cho horde. Ví dụ thuần số học: 13,46+1,0=14,46 ms ≈69 FPS; thêm3,0ms chỉ còn≈60,8 FPS và gần như hết dự phòng. 1% thấp đang dưới60 nên vẫn phải giải quyết giật, dù trung bình đạt.

| Khu | Phần tăng thời gian khung đề xuất khi khu đó gần camera, **chưa đo** | LOD / che khuất cần có |
|---|---|---|
| A01 | ≤0,15 ms | Cận bàn dùng bản đầy đủ; điện thoại/loa/đồ bàn nhỏ ẩn ở xa; dùng chung vật liệu. |
| A02 | ≤0,35 ms | Chỉ một cụm WC gần; che buồng khuất, giữ cách cập nhật gương hiện hành. |
| A03–04 | ≤0,35 ms tổng | Phòng đóng ẩn nội thất, khung/cửa giữ G5; đồ rời LOD sau10–20m, không nhân shader đắt. |
| A05 | ≤0,10 ms | Cây/đèn nền silhouette; không thêm bóng động riêng. |
| A06–07 | ≤0,40 ms tổng | Chia chiếu nghỉ/tầng, occluder tường kín; bậc gần chân đủ hình, xa giản lược. |
| A08–10 | ≤0,50 ms cho tầng đang đi | Không vẽ đủ nội thất ba tầng cùng lúc; cửa mở phải mở đúng vùng che; tận dụng kit G5 nhẹ. |
| A11 | ≤0,10 ms tổng | Hai vật cận, 1–2 bộ vật liệu mỗi mẫu; bỏ chi tiết nhỏ khi nhìn xa. |
| A12 | ≤0,40 ms | Cụm cây/hoa có LOD gần/trung/xa, giảm alpha overdraw và bóng; ghế gần riêng. |
| A13 | ≤0,50 ms | Khán đài lặp instancing, mái xa nhẹ; tránh hàng trăm bóng động, giữ trạng thái floodlight. |
| A14 | ≤0,25 ms | Tách chốt khỏi cổng, đồ trong chốt khuất không cần vẽ. Không che đường nhìn bảo vệ. |
| A15 | ≤0,60 ms | Gom bàn/khay theo cụm vật liệu, bếp/kho tách; không cho mọi vật nhỏ cast shadow. |
| A16 | Mục tiêu **không tăng** tại góc nhìn toàn Campus | Giảm vật liệu runtime trùng; giữ MultiMesh và chia cụm theo không gian; cây gần/trung/xa; đo lại visibility range125m hiện có, không mở rộng vô điều kiện. |
| A17–19 | ≤0,20 ms **cho cả ba nhóm** | Nhà xa một số ít vật liệu/tấm mặt tiền, không nội thất; occluder nằm trong tường kín thực tế. |
| A20–21 | ≤0,60 ms tổng | Chia tầng/kệ, sách dùng atlas và mesh cụm; cửa động không bị occluder cố định chặn. |
| A22 | ≤0,15 ms | Tái dùng giường/phòng đã nâng, chỉ thêm phần ván/vent; không nhân phòng407 thứ hai. |
| A23 | ≤0,50 ms | Phòng kết độc lập ít vật liệu; tách ánh sáng/môi trường; chưa có baseline riêng nên độ tin cậy thấp. |
| A24–29 | ≤0,40 ms cho feed đang xem | Chỉ feed cần thiết, LOD theo camera cố định; đừng nâng đồng loạt tất cả SubViewport lên1080p vì ảnh khảo sát1080p. |
| A30 | ≤0,10 ms | Giữ giấy phẳng, LED và gương; nâng bề mặt thay vì tăng mesh vô ích. |

Các trần từng hàng **không được cộng tự do**: một khung có thể nhìn nhiều nhóm; giới hạn chung Campus1,0ms bên trên ưu tiên hơn. Với khu chưa có báo cáo riêng (sân/vườn/nhà ăn/thư viện/bệnh viện/CCTV), không có cơ sở hứa một con số FPS hậu nâng; dùng các mức tăng để chọn mẫu và đo lại sau duyệt. Mục tiêu cuối mọi khu vẫn ≥60 trung bình, báo thêm p95/1% theo cùng phương pháp để tránh che giật.

Đề xuất khởi điểm tài nguyên để dựng mẫu, chưa thay tiêu chuẩn production: vật cầm/cận2–8k tam giác, vật lặp0,5–2k; LOD trung khoảng25–40% LOD0, xa5–10%; texture tile kiến trúc1–2K, atlas đồ lặp512–1K, đồ cận tối đa2K nếu có lợi nhìn thấy. Chi tiết đinh/vết rỉ nên bake normal. Chỉ áp dụng sau khi B/core/C chốt hợp đồng và đo trên máy đích. Không dùng tổng tam giác làm giới hạn duy nhất; A16 chỉ46k tam giác nhưng có454 material resource runtime, cho thấy cần kiểm cả số resource/cụm và shader.

Không thêm tường, cây lớn hoặc sương để che tầm nhìn gameplay nhằm đạt FPS. Occluder phải theo phần kiến trúc kín có sẵn. Không đưa SDFGI, đèn bóng hàng loạt hay phản chiếu thời gian thực toàn map vào mặc định mà chưa có card và số đo.

## 7. Nhân vật PS1 — chỉ kiểm kê

| Nhân vật / hình người | Nguồn / chỗ thấy | Ghi chú phạm vi |
|---|---|---|
| Phúc, Việt, Đạt dạng xác | `levels/ch1_models/corpse_*.tscn`; Floor4/Room407/Anchors/Corpse1,2,4 và CCTV310 | Vẫn khối PS1 giữa giường Tripo. Không dựng trong các đợt môi trường. |
| Sinh viên CCTV Hùng, Kiệt, Bảo, Đăng; nạn nhân310 | Bộ student scene mà `chapter1_director.gd` nạp; `CctvSet/Room*/Victim` | Trạng thái `_ready`/nạn nhân mẫu không phải toàn bộ cảnh truyện. Giữ vị trí/động tác camera; task nhân vật riêng. |
| Xác sống | `assets/models/campus/zombie_01…10.tscn`, director sinh theo vùng chương3/4 | Đã có T-221; không tạo mẫu trùng. |
| Minh Nhật, Ngư | Body từ `assets/models/campus/`, companion do director sinh theo tiến độ; nhà B/vườn, rồi đi cùng ở Campus và chương4 | Không nhất thiết hiện trong ảnh tĩnh auto_start=false. Không bỏ sót vì probe chưa spawn. |
| 12 bảo vệ | `Chapter3Director/Guard01…12`, body `assets/models/campus/guard.tscn`; khu cổng và tuần tra | T-248 không thay body, số lượng hoặc đường nhìn. |
| Xác/hình người tĩnh Campus và silhouette cửa sổ | Props đã gộp MultiMesh; Shells/WindowSilhouette* | Nằm trong số đo hình học cụm; giao kiểm kê nhân vật riêng trước tách khỏi cụm môi trường. |
| Bệnh nhân/chăn ở đoạn kết | HospitalRoom/Bed_*/Patient, tùy nhánh kết | Patient là placeholder, Nurse1/2 là marker thoại, không tự suy ra có model y tá. |

Quản lý đã dùng thân mới; Trần Trung chương1–2 đã có thân. Không xếp họ vào danh sách đồ PS1 cần dựng lại. UI chết và tay/máy điện thoại giữ theo card hiện hành; thân chương3 phần không phụ thuộc cảnh do T-249 xử lý.

## 8. Hạn chế ảnh và việc integrator cần biết

Ảnh tĩnh chụp ở1920×1080 bằng Godot Forward+, giữ environment/đèn của scene và dùng đèn pin khảo sát ở các góc tối (chỉ mục ghi rõ). Camera được đặt trực tiếp, không giả làm một lượt chơi hoàn chỉnh; UI/Player được ẩn. Không có cảnh horde chạy, cánh cửa phá xong, nước nóng đủ chu kỳ hay bình minh chạy tới cuối. Những trạng thái đó là việc kiểm ở đợt triển khai.

- Các ảnh nhà nền rất tối phản ánh ánh sáng scene ở mốc khảo sát, không chứng minh nhà đã đủ chi tiết. A18 dùng cả góc xa chung để đánh giá silhouette.
- `ch2_clothesline.jpg` bị cánh cửa che: giữ theo yêu cầu tiếp tục phiên; hai ảnh `ch2_balcony_*` là góc bổ sung để đánh giá. Khăn/áo ban công và nhà tắm407 hiện đã nâng, không đặt lại Tripo vì ảnh cũ che khuất.
- Hai ảnh bệnh viện mất chi tiết vùng trắng. Đã tự xem; chỉ dùng xác nhận bố cục khung giường/cây truyền/máy. Chưa chạy kết thúc tự nhiên nên **không kết luận lỗi production hay tự đổi exposure**. Integrator cần kiểm đúng ending để có mẫu ánh sáng trước đợt9.
- Lối tây nhà ăn trong ảnh tĩnh có phần hình chắn/treo qua lỗ. Cần đối chiếu trạng thái chapter4 trước nâng A21, không tự xóa collider/props.
- Probe khởi tạo ban đầu từng lỗi import cache, import lại thành công; chỉ dùng số đếm mesh sau khi sửa probe đếm PrimitiveMesh và các lượt cuối hoàn tất. Log không nằm trong commit. Không chạy full test/check theo ngoại lệ của card; kiểm ảnh, đường dẫn, phạm vi diff và LFS thay thế cho kiểm tài liệu.

Yêu cầu ngoài phạm vi để integrator lập card sau duyệt: core nối ngăn kéo/ổ khóa/tay nắm/bình/hộp báo cháy runtime; B sở hữu hình/collider; A nối hand targets/IK theo quyết định T-247; C đo chapter thật và hồi quy; D chỉ tham gia nếu cần đổi cách hiển thị chữ, không tự sửa nội dung truyện. Không yêu cầu sửa ngay trong T-248.

## 9. Câu hỏi cho chủ dự án

Không có quyết định thiết kế nào được coi là đã duyệt trong khảo sát. Mỗi câu dưới đây có một đề xuất để integrator chuyển chủ dự án; phần lập kế hoạch không bị chặn bởi việc chưa có trả lời.

| # | Cần chốt | Phương án | Đề xuất |
|---|---|---|---|
| Q1 | Phong cách, mức cũ/bẩn của nhà B | (a) Cùng chất liệu407/G5, xuống cấp vừa; (b) Bỏ hoang/rỉ sét nặng; (c) Sạch mới | **a**, bảo toàn bối cảnh đang sử dụng; vết bẩn cục bộ không biến mọi phòng thành phế tích. |
| Q2 | Cây và hoa vườn | (a) Cây/hoa phổ thông trong khuôn viên Việt Nam, giữ mật độ/vị trí; (b) Ít cây và tán thưa hơn; (c) Vườn rậm hơn | **a**, chọn mẫu cụ thể qua ảnh tham chiếu trước Tripo; không tăng tán che NPC/lối thoát. |
| Q3 | Nhà A, giảng đường, nhà thể chất | (a) Chỉ mặt ngoài chân thực, phần gần đường rõ hơn; (b) Thêm nội thất nhìn qua cửa; (c) Mở thêm khu chơi | **a**, b/c cần thiết kế và scope riêng; scene hiện không có nội thất chơi cho các nhà này. |
| Q4 | Ánh sáng đêm/sương/bình minh | (a) Giữ nhịp chương, chỉ cân vật liệu/độ đọc; (b) Thêm sương nhẹ trang trí; (c) Đổi toàn bộ tông và độ tối | **a** trước; nếu chọn b/c phải duyệt ảnh cùng camera và kiểm đường nhìn AI, không dùng sương để che lỗi hiệu năng. |
| Q5 | Tripo và đồ tái dùng | (a) Tối đa danh mục12 mẫu đề xuất, ưu tiên10 mẫu thiết bị; (b) Blender/tái dùng toàn bộ; (c) Thêm nhiều đồ riêng từng phòng | **a**, kiểm kho407 trước; hai mẫu cây/hoa tùy chọn. Đây là danh mục, không phải hạn mức trả phí hay số lượt tạo. |
| Q6 | CCTV sau nâng | (a) Môi trường thật nhưng giữ góc/màn/độ rõ dấu hiệu; (b) Giữ nguyên PS1 trong màn hình; (c) Làm CCTV sắc nét như camera người chơi | **a**, thống nhất thế giới mà không làm thay luật quan sát; mức nhiễu/độ nét cuối cần ảnh duyệt. |
| Q7 | Bệnh viện | (a) Phòng bệnh công cơ bản, sáng dịu, giữ ba giường; (b) Phòng tư hiện đại; (c) Trắng mờ siêu thực | **a**, nhưng trước hết integrator xác minh ánh sáng ending vì ảnh probe đang cháy trắng; không tự kết luận c là ý đồ. |
| Q8 | Thứ tự và các thao tác T-247 | (a) Duyệt10 đợt, chốt riêng dòng5–10 trước làm động tác; (b) Đưa toàn bộ tầng4/CCTV lên trước Campus; (c) Làm mọi môi trường trước mọi thao tác | **a**, đồ bàn/cửa/bậc được chốt sớm, T-249 vẫn tiến hành độc lập. Động tác ngăn kéo/bình/báo cháy và IK cửa sổ theo phương án T-247 cần chủ dự án duyệt riêng. |
