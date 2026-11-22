# T-267 — Đồ hoạ thật đợt 10: năm phòng trường quay CCTV (102, 306, 209, 106, 310) và đồ nhỏ phòng 407
- Lane: B | Trạng thái: **done, merged 22/11 `d36c7a2b`; full test 1096/0, check 0; bản chơi `d36c7a2b`** (card viết 20/11/2026 trong lúc lane B làm T-266 lượt 2) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`. Chủ dự án tự dán prompt (`lane-b.md` mục 1u).
- **Model (D-183):** lane B **Opus 5.5, effort xhigh**. Nếu một lượt bị trả sửa hai lần vì cùng một lỗi, lượt sửa tiếp theo dùng **max**. Phần của integrator (chuyển phương án, review, full test + check, merge) dùng Fable 5.2, Mythos 5.2 high hoặc Opus 5.5.
- Nhánh: `lane-b/T-267-realistic-graphics-wave10-cctv-room407` tạo từ `origin/main` **sau khi T-266 merge**. Lúc đó phòng 407 đã có ô thông gió và nắp trần ở cả bốn chương (D-187 điểm 5).
- Quyết định nền:
  - **D-166:**
    - đồ hoạ thật dựng bằng Blender, không làm mẫu Tripo mới; ánh sáng giữ như nay;
    - **CCTV là cảnh thật, giữ nguyên góc máy và độ rõ** (PLAN mục 9, câu Q6, phương án a).
  - **D-167/D-172/D-177:** phong cách nhà B đã duyệt, cũ vừa phải. Dùng lại vật liệu của đợt 1–9 trước khi làm vật liệu mới.
  - **D-176:** chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ. Đây là đợt môi trường cuối của kế hoạch.
  - **D-179, D-184:** không đo FPS, không chạy bot.
  - Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 10 (A24–A28, A30). Các mục khác của đợt 10 đã làm xong: A02–A04 ở T-255 và T-256; A29 (hành lang trường quay) ở T-256.
- Làm như các đợt trước, chia **hai lượt**:
  - lượt 1: khảo sát, hình mẫu một phòng, phương án, rồi dừng chờ chủ dự án chọn;
  - lượt 2: cả năm phòng, đồ nhỏ phòng 407, ảnh kiểm đồng bộ bốn chương.

## 0. Hiện trạng (integrator khảo sát 20/11 bằng file, chưa chạy Godot; lane B kiểm lại ở bước 1)

### 0a. Trường quay CCTV (`game/scenes/levels/cctv/cctv_set.tscn`)

**Cách nạp:**
- `Chapter1Director._build_cctv()` nạp trường quay, đặt dưới Y = −60.
- Director chương 2, 3, 4 kế thừa `_ready()` của chương 1 và không bỏ bước này. Vì vậy **trường quay được nạp ở cả bốn chương**, kể cả chương 3–4 vốn không dựng cảnh CCTV nào.
- Hệ quả: texture mới của trường quay chiếm bộ nhớ hình cả ở chương 3, chương nặng nhất (T-255 từng làm màn hình đen hẳn vì hết bộ nhớ hình ở chương 3).

**Feed:**
- Mỗi feed là một `SubViewport` **320 × 240**, chế độ `UPDATE_WHEN_VISIBLE`. Camera của feed chép transform và FOV của `Cam` nguồn.
- Chương 1 có chín feed: `cam_102/306/209/106`, `hall_102/306/209/106`, `cam_corridor`. Chương 2 thêm `hall_310` và `cam_310` (`chapter2_director.gd`, khoảng dòng 885).
- Người chơi xem feed ở tab Camera của điện thoại (UI của lane D).

**Mỗi phòng** (`Room102`, `Room306`, `Room209`, `Room106`, `Room310`) gồm:
- **Vỏ:** `Floor`, `WestWall`, `EastWall`, `BackWall`, `FrontWallLeft`, `FrontWallRight`, `DoorLintel`, `Ceiling`. Mỗi cái là StaticBody3D có `Collision` và `Mesh`.
- **`Hall`** (hành lang trước cửa): `Floor`, `OuterWall`, `Ceiling`, `EndWest`, `EndEast`, `RoomWallWest`, `RoomWallEast`, đèn `Tube`, marker `Start`, `Cam` (FOV 70, far 30).
- **Đồ PS1 của bộ kit cũ:**
  - `BunkA`, `BunkB` (`kit/bunk_bed.glb`) có mùng `NetLower`, `NetUpper`; phòng 310 không có mùng;
  - `Locker1…4`, `Desk`, `Stool`, `CeilingFan`;
  - đèn `NightLight`.
- **Đồ riêng từng phòng** (PLAN A24–A28; là dấu hiệu để nhận ra phòng):
  - 102: áo, dép, poster;
  - 306: khăn, xô, đồ trên bàn;
  - 209: bốn quyển sách, đồ phơi;
  - 106: đồ trên bàn và đèn bàn đang bật (`DeskLamp` + `Fixture`). Test kiểm 106 có đèn bàn, 102 không có;
  - 310: ba xác `Corpse1`, `Corpse2`, `Corpse4`.
- **Số phòng và marker:** `NumberInside`, `NumberOutside` (Label3D), marker `Door`, `ManagerSpot`, `VictimBed`.
- **Nạn nhân và camera:** `Victim` (sinh viên), `Cam` (FOV 66, far 30).

**Cảnh trong truyện:**
- **Chương 1:**
  - 102: Hùng ra mở cửa (`answer`);
  - 306: điện thoại của Kiệt sáng (`phone_lit`; Trung nói câu `n_kiet_lit`);
  - 209: Bảo co người im lặng (`cower`);
  - 106: Đăng ngồi dậy, đèn bàn bật (`sit_up`, `dang_lamp`).
- **Quản lý:**
  - đi **thẳng** theo tuyến `Hall/Start` → `Door` → (x của cửa, z phòng − 0,6) → `ManagerSpot`. Bản đồ dẫn đường rỗng, nên quản lý không né vật cản;
  - khi quản lý đi qua z phòng − 0,15, điện thoại chuyển từ feed hành lang sang feed phòng;
  - quản lý chém, nạn nhân chuyển sang tư thế `dead`, rồi quản lý quay ra theo đường cũ.
- **Chương 2 (D-046):** phòng 310 thua trò chơi: ba xác chuyển sang `lunge`, nạn nhân `dead`.

**Ảnh hiện trạng có sẵn:** `art_source/graphics_upgrade/realistic_map/previews/survey/cctv_{102,106,209,306,310}_{1,2}.jpg`. Đây là ảnh 1080p, không phải khung feed.

**Bộ đồ cùng tòa có thể dùng lại:**
- Phòng tầng 1–3 nhà B nhìn qua cửa (đợt 2, T-253): **giường tầng khung thép nhẹ và tủ thép**, trong `game/assets/models/graphics_pilot/realistic_map/wave2/floor{1,2,3}_rooms.glb`; lá cửa `room_door_leaf.glb`; biển số phòng `room_plate.glb`. Các phòng 102, 106 ở tầng 1, 209 ở tầng 2, 306 và 310 ở tầng 3, nên trông cùng một tòa.
- Phòng 203 dùng đồ của 407: khoảng 63.000 tam giác cho giường và bàn.
- Hành lang trường quay `Corridor/RealSet` (`floor4_rest/cctv_corridor.glb`, T-256): 2.526 tam giác.

**Nhân vật:** bốn sinh viên (`student_*.tscn`) và ba xác (`corpse_*.tscn`) vẫn là người khối PS1. **Nhân vật không thuộc đợt này** (PLAN: nhân vật chỉ kê tên). Test giữ mỗi sinh viên dưới 1.500 tam giác.

### 0b. Đồ nhỏ phòng 407 (A30)
- Theo PLAN A30, các món gồm:
  - sổ, giấy, bộ sạc, ổ điện, chỗ dây đàn, nút tắm;
  - nằm trong `game/scenes/levels/room407/room407_anchors.tscn` (là `Anchors` của `room_407.tscn`) và các mesh `Ch1*` do director sinh;
  - tổng 636 tam giác, 19 vật liệu; người chơi nhìn ở 0,2–1 m khi đọc hay lấy.
- Việc: bevel và normal ở chỗ cần. Giữ chữ, UV, key dịch; giữ LED, mặt phản chiếu, dây cáp mới. Giấy chỉ hai tam giác là hợp lý.
- **Bẫy:** `room407.gd._furnish()` ẩn mọi `MeshInstance3D` không nằm trong `KEEP_PS1` và không thuộc cây đồ thật. Vì vậy hình mới trong phòng 407 phải đi một trong hai đường như C2 của T-266 (D-187 điểm 5).
- Ở bước 1, lane B kiểm kê:
  - món nào còn hình khối;
  - món đó thuộc file nào: scene của lane B, scene tương tác của lane A, hay mesh do director sinh;
  - đề xuất những file được sửa. Integrator duyệt danh sách này khi review lượt 1 và ghi vào mục 1.

## 1. Chủ dự án chốt
**D-188 (21/11/2026), sau lượt 1** (nhánh lane B `126b6fc`, review đạt). Chủ dự án chọn điểm 1–4; integrator chọn điểm 5–9.
1. **Đồ trong phòng: D2.** Chủ dự án chọn D2, khác đề xuất D1 của lane B.
   - Cả năm phòng dùng giường tầng và tủ Tripo của phòng 407, cùng nệm, gối, chăn, bàn, ghế, quạt của 407.
   - Đồ riêng từng phòng (mục 0a) giữ đúng chỗ.
   - Không thêm bộ nhớ hình, vì đồ 407 đã được nạp ở mọi chương.
2. **Tường sau: W2.** Cửa ban công và cửa sổ có song, đều đóng. Chỉ là hình; va chạm vẫn là tường cũ.
3. **Mùng: thay bằng mùng của phòng 407.** Chủ dự án chọn thay, khác đề xuất giữ của lane B.
   - Mùng PS1 `NetLower`, `NetUpper` là con của instance giường kit: chỉ ẩn mesh, giữ node.
   - Mùng mới giữ trạng thái đóng hay mở như cũ ở từng tầng giường. Phòng 310 vẫn không có mùng.
   - Ảnh feed trước/sau phải cho thấy: từ `Cam` vẫn thấy rõ nạn nhân, và mùng ở phòng 209 vẫn đọc được như dấu hiệu.
4. **Cửa mở vào trong, bảng số sơn xanh đậm sau chữ: đồng ý.**
   - Lá cửa `wave2/room_door_leaf.glb`, nép mép đông của ô cửa.
   - `Label3D` giữ nguyên; bảng xanh đặt phía sau chữ.
5. **Hành lang: H1**, như đề xuất. Là hành lang tầng 1–3 nhà B, dùng vật liệu riêng:
   - dùng lại texture có sẵn;
   - mask nhỏ, tối đa 512 px, nén VRAM, thay cho ba mask 4096 px chưa nén của đợt 2.
6. **Occlusion cho feed.**
   - Phần core integrator đã làm (`1324a2aa`): feed chép `far` của `Cam` và bật `use_occlusion_culling`.
   - Lượt 2, lane B thêm occluder hộp (`OccluderInstance3D` + `BoxOccluder3D`) ở tường năm phòng và năm hành lang.
   - Occluder **chỉ đặt trong năm nhánh `Room*`**, không đặt trong `Corridor` (để giữ dấu vân tay của T-256).
   - **Bằng chứng:** chụp bật và tắt occluder ở mọi feed phòng và feed hành lang; hai ảnh phải **giống nhau từng điểm ảnh**. Cách chụp như khối che thư viện (báo cáo T-260, mục bổ sung 20/11): cho chạy 3 s rồi mới dừng thời gian, và chụp hai trạng thái liền nhau.
7. **Trần**, đo khi đã bật occlusion:
   - mỗi phòng tối đa 160.000 tam giác; mỗi glb đợt 10 dưới 5.000 tam giác;
   - feed phòng tối đa 150 lần vẽ, feed hành lang tối đa 250 lần vẽ (main chưa có occlusion: 289–310);
   - bộ nhớ hình: chương 1–2 thêm tối đa 25 MB cho cả đợt, chương 3 thêm tối đa 5 MB;
   - mọi texture đợt 10 mà chương 1–2 phải nạp đều nén VRAM.
8. **A30: các file được sửa** (integrator duyệt):
   - `game/scenes/levels/ch1_models/dat_notebook.tscn` (sổ của Đạt và sổ hợp âm);
   - `game/scenes/levels/ch1v2/guitar_songbook.tscn`;
   - `game/scenes/levels/room407/khoa_outlet.tscn`;
   - `game/scenes/levels/ch1v2/trash_bin.tscn`;
   - `game/scenes/levels/room407/room407_anchors.tscn`: chỉ hai mesh `ShowerYes/Button`, `ShowerNo/Button`. Ở chương 2 người chơi thấy và bấm hai mesh này; director chỉ ẩn `Placeholder` của cụm `Choice`;
   - `game/scenes/levels/floor4/floor4.tscn`: chỉ transform của `Door407/Pivot/RulesPaper`, để đưa tờ nội quy sát mặt cánh Tripo, hết lệch 4 cm. Test nào băm `floor4` mà bị đổi thì cập nhật hằng số, kèm bằng chứng: bỏ dòng đó ra thì trùng main (như integrator làm ở T-266).

   **Ràng buộc:**
   - Trong mỗi scene chỉ đổi node mesh và vật liệu. Mọi node khác (script, `Area3D`, `CollisionShape3D`, `HandTarget`, marker, giá trị export) phải trùng main, kiểm bằng dấu vân tay từng scene trong `test_t267_*`.
   - Hình bao của mỗi món lệch không quá vài cm so với cũ, vì tay ở T-239, T-241, T-243 nhắm vào các món này.
   - Không đặt hình mới ở đường dẫn khớp `REPLACED_PS1` của `room407.gd` (ví dụ `Anchors/TrashBin/Base`, `Anchors/TrashBin/Slat*`), vì khi phòng có đồ thật, các đường dẫn đó bị ẩn. Ảnh trước/sau chụp trong chương thật để thấy hình mới thật sự hiện.

   **Không sửa:**
   - `charger.tscn` (nằm trong tủ Đạt đóng), `router.tscn` (chỉ còn LED);
   - giấy đọc được `Ch1*`;
   - ổ cắm nối dài, phích, cổng LAN, cáp.
9. **Nhân vật** (sinh viên, xác): giữ người khối, ngoài phạm vi. Hình mới trong `Room310` không được có hàm `set_state`, vì `_cctv_310` gọi hàm đó trên mọi node con của phòng.

## 2. Việc, theo hai lượt

### Lượt 1 — khảo sát, hình mẫu một phòng, phương án, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi vào Handoff:**
   - Kiểm lại mục 0. Grep mọi chỗ code, test, UI đụng tới trường quay: `cctv_set`, `CctvSet`, `Room102`…`Room310`, `Hall/Cam`, `VictimBed`, `ManagerSpot`, `Victim`, `Corpse`, `NightLight`, `DeskLamp`, `NumberInside`, `cctv_feed`.
   - **Bảng hợp đồng:** node nào phải giữ tên, vị trí, va chạm, camera.
   - **Ảnh đúng khung feed**, chụp trong chương thật lúc director dựng cảnh:
     - mỗi phòng một ảnh feed phòng và một ảnh feed hành lang, lúc quản lý đang ở đó;
     - chương 1: gọi `_cctv_scene` như `test_cctv`; phòng 310 ở chương 2: gọi `_cctv_310`;
     - lấy ảnh trực tiếp từ `SubViewport` 320 × 240 rồi phóng ×3 theo kiểu giữ điểm ảnh. Trong cảnh chụp tạm, đặt `UPDATE_ALWAYS` cho feed;
     - kèm một ảnh 1080p cùng camera.
   - **Kiểm kê đồ nhỏ phòng 407** theo mục 0b, kèm ảnh chụp cách 0,3–0,6 m có bật đèn pin.
2. **Hình mẫu:** một phòng cùng hành lang của nó, chụp ở khung feed và ở 1080p. Đề xuất phòng 306, vì dấu hiệu điện thoại sáng ở đó khó giữ nhất.
3. **Phương án.** Mỗi phương án ghi số tam giác, số vật liệu, số lần vẽ của feed; đề xuất một:
   - **Đồ trong phòng:**
     - (D1) bộ nhẹ của đợt 2 (giường tầng khung thép, tủ thép), cộng đồ vải và đồ riêng của từng phòng lấy từ đồ 407. Ít tam giác hơn, nhưng thêm texture vào chương 1–2 (mục 5);
     - (D2) đồ 407 đầy đủ như T-255: nhiều tam giác hơn, giống 407 hơn, gần như không thêm bộ nhớ hình ở chương nào.
   - **Tường sau:**
     - (W1) tường trơn như nay;
     - (W2) cửa ban công và ô cửa sổ đóng như phòng thật. Chỉ là hình; va chạm vẫn là tường cũ.
   - **Hành lang trước cửa:** dùng module hành lang tầng 1–3 của đợt 2, hay bộ `cctv_corridor` của T-256 (có lan can mở). Giữ vị trí `Start` và `Cam`.
   - **Dấu hiệu trên feed:** chứng minh ở 320 × 240 vẫn thấy rõ:
     - nạn nhân trên giường, quản lý ở cửa, số phòng;
     - điện thoại sáng ở 306, đèn bàn ở 106, mùng ở 209, ba xác ở 310.
     Nếu mùng che nạn nhân thì nói rõ và đề xuất độ trong của mùng.
   - **Người khối giữa phòng thật trên feed trông thế nào:** ghi nhận xét, kèm ảnh. **Không làm nhân vật.**
4. Commit, push nhánh, ghi Handoff, **báo và dừng**. Integrator chuyển phương án cho chủ dự án, rồi ghi lựa chọn và danh sách file A30 được sửa vào mục 1.

### Lượt 2 — cả năm phòng, đồ nhỏ 407, đồng bộ bốn chương (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
5. Làm cả năm phòng và năm hành lang theo phương án đã chọn.
6. Làm đồ nhỏ phòng 407 (A30) theo danh sách integrator đã duyệt ở lượt 1.
7. **Đồng bộ bốn chương:**
   - Chụp cùng góc ở chương 1, 2, 3 và 4:
     - phòng 407 nhìn từ cửa;
     - hành lang tầng 4 nhìn từ đầu cầu thang;
     - nhà vệ sinh chung;
     - một phòng 401–408 đang mở cửa.
   - Liệt kê những chỗ khác nhau mà không có lý do. Khác nhau do truyện thì được.
   - Chỉ chụp và báo, không sửa ngoài phạm vi.
8. Ảnh trước/sau, ảnh ghép, test, README, CREDITS, Handoff; **báo và dừng**.

## 3. Phạm vi
- **Trong đợt:**
  - năm nhánh `Room102`, `Room306`, `Room209`, `Room106`, `Room310` của `cctv_set.tscn`, gồm cả `Hall` của từng phòng;
  - script hình mới trong `game/scenes/levels/cctv/`;
  - đồ nhỏ phòng 407 theo danh sách đã duyệt ở lượt 1.
- **Không đụng:**
  - `Corridor` của trường quay (đã làm ở T-256);
  - sinh viên, xác, quản lý (nhân vật);
  - phòng 407 ngoài các món A30, và các hình T-266 đã thêm (vạt giường, ô thông gió, nắp trần, cửa bị phá);
  - mọi khu của đợt 1–9.

## 4. Hợp đồng gameplay (bắt buộc giữ)
- **Giữ tên, kiểu và transform** của:
  - mỗi `Room*`;
  - `Cam` và `Hall/Cam`, kể cả `fov` và `far`;
  - `Hall/Start`, `Door`, `ManagerSpot`, `VictimBed`, `Victim`, `Corpse1/2/4`;
  - `NumberInside`, `NumberOutside`;
  - `NightLight`, `Room106/DeskLamp`, `Hall/Tube`.
- **Đèn:** không thêm, không đổi. Phòng 102 vẫn không có `DeskLamp`.
- **Số phòng:** được ẩn `Label3D` và thay bằng biển số như `room_plate.glb`, nhưng phải cùng số và vẫn đọc được trên feed.
- **Va chạm:**
  - va chạm của năm phòng và năm hành lang phải **trùng main**, kiểm bằng dấu vân tay như T-256;
  - đồ mới không có va chạm;
  - không hình nào chắn ngang ngực trên tuyến thẳng của quản lý: `Hall/Start` → `Door` → (x của cửa, z phòng − 0,6) → `ManagerSpot`.
- **Tầm nhìn:**
  - từ `Cam` của mỗi phòng thấy `VictimBed` và đầu nạn nhân; từ `Hall/Cam` thấy cửa phòng;
  - không lưới mới nào nằm giữa camera và nạn nhân, trừ mùng mới theo D-188 (mục 1 điểm 3).
- Các dấu hiệu ở mục 2 bước 3 phải đọc được trên feed.
- Hình PS1 chỉ ẩn (`visible = false`), không xoá. Hình mới đặt dưới một node con mới, ví dụ `Real`.
- **A30:** giữ tên node, vùng tương tác, chữ, UV, key dịch. Không đổi director, luật, lời thoại.

## 5. Kỹ thuật và hiệu năng
- Dựng bằng script Blender (Blender 5.2.2 ở `D:\Tools\Blender\5.2.2`). Nguồn CC0 ghi URL, tác giả, giấy phép trong CREDITS.
- **Không tạo mẫu Tripo mới, không extension Blender, không ảnh AI.** Được dùng lại đồ Tripo có sẵn của phòng 407, như T-255 đã làm.
- **Bộ nhớ hình:** trường quay được nạp ở cả bốn chương (mục 0a).
  - Dùng lại mesh và texture đang có trước. Nhưng dùng lại đúng file **chỉ không tốn thêm bộ nhớ hình ở những chương đã nạp sẵn file đó**:
    - đồ 407 có sẵn ở cả bốn chương, vì phòng 407 có mặt ở mọi chương;
    - bộ nhẹ đợt 2 (`wave2/floor{1,2,3}_rooms.glb`) chỉ nằm trong `building_b.tscn` của khuôn viên, tức chỉ chương 3–4 nạp. Dùng nó ở trường quay sẽ thêm texture vào chương 1–2.
  - Phương án D1/D2 phải ghi rõ phần bộ nhớ hình này.
  - **Không thêm texture 2K mới.** Texture mới tối đa 1K, nén VRAM trong `.import` (`compress/mode=2`; normal thêm `compress/normal_map=1`), có test kiểm.
  - Ghi bộ nhớ hình **chương 1 và chương 3** trước/sau.
- **Ngân sách** (PLAN mục 6): **≤ 0,40 ms cho feed đang xem**; A30 ≤ 0,10 ms. Vì không đo FPS, dùng số tam giác và số lần vẽ để ước.
  - Không nâng độ phân giải feed: giữ 320 × 240.
  - Ghi số tam giác, số vật liệu, **số lần vẽ của từng feed trước/sau**.
  - Ghi tổng số tam giác của mỗi phương án. Trần cho lượt 2: mục 1 điểm 7 (D-188).
- Không đo FPS, không chạy bot (D-179, D-184).

## 6. Ảnh
- Tất cả để trong `art_source/graphics_upgrade/realistic_map/previews/wave10/`.
- **Lượt 1:** `survey_*`, `pilot_*`, `options_*.jpg`.
- **Lượt 2:**
  - `before_*` / `after_*` cùng camera; mỗi cặp gồm ảnh feed 320 × 240 phóng ×3 và ảnh 1080p;
  - `a30_*`: đồ nhỏ phòng 407 trước/sau;
  - `sync_ch{1..4}_*`: ảnh đồng bộ bốn chương;
  - ảnh ghép `overview.jpg`.

## 7. Kiểm
- **Test mới** `game/tests/levels/test_t267_*.gd`:
  - dấu vân tay va chạm của năm phòng và năm hành lang trùng main;
  - các node hợp đồng ở mục 4 giữ transform, `fov`, `far`;
  - hình PS1 đã thay thì ẩn chứ không xoá; đồ mới không có va chạm;
  - tuyến thẳng của quản lý không bị hình mới chắn: quét một hộp ngang ngực dọc tuyến;
  - không lưới mới nào chắn đường từ `Cam` tới đầu nạn nhân; điện thoại ở 306 và đèn bàn ở 106 nằm trong khung hình;
  - A30: các món vẫn đúng chỗ, không bị `_furnish()` ẩn, chữ và key dịch giữ nguyên;
  - mọi `.import` texture trong thư mục asset đợt 10 đều nén VRAM;
  - A30 (D-188 điểm 8): mỗi scene được sửa có dấu vân tay các node không phải hình, trùng main;
  - occluder chỉ nằm trong năm nhánh `Room*`; không có trong `Corridor`.
- **Trước khi chạy test:** grep `game/tests` theo tên file của mọi scene lane B sửa (`cctv_set`, `room407_anchors`, `dat_notebook`, `guitar_songbook`, `khoa_outlet`, `trash_bin`, `floor4`), rồi chạy cả những test đó. Ở T-266, sáu test khuôn viên hỏng vì nằm ngoài các bộ lọc của card.
- **Test cũ phải đạt:**
  - trường quay: `test_cctv`, `test_ch2_props`, `test_wide_corridors`, `test_t256_floor4_rest`, `test_chapter1`, `test_chapter2`, `test_story_segments_3_5`, `test_graphics_bindings`;
  - vì đụng phòng 407 (A30): `test_room407_*`, `test_floor4`, `test_ch1_*`, `test_t266*`.
- **Lane B chỉ chạy test lọc:**
  - lệnh: `pwsh tools/test.ps1 -Filter <bộ lọc>`, chạy với từng bộ lọc `t267`, `cctv`, `ch2_props`, `wide_corridors`, `t256`, `chapter1`, `chapter2`, `story_segments`, `graphics_bindings`, `room407`, `floor4`, `ch1_`, `t266`;
  - **mỗi bộ lọc chạy trực tiếp (không chạy nền), dưới 10 phút.** Claude Code dừng lượt chạy nền khi máy cạn RAM. Nếu một lệnh quá 10 phút và tự chuyển sang chạy nền, chạy ngay bộ lọc kế tiếp trực tiếp (nó tự chờ khoá Godot), để phiên không rảnh;
  - chạy xong thì `git checkout -- game/default_bus_layout.tres`;
  - **không chạy full test, không chạy check**: máy thiếu RAM. Integrator chạy một lần khi merge, lúc chủ dự án đã tắt RAV và Chrome;
  - lượt nào bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.

## 8. Được phép sửa
- Thư mục đợt 10:
  - `art_source/graphics_upgrade/realistic_map/wave10/`;
  - `art_source/graphics_upgrade/realistic_map/previews/wave10/`;
  - `game/assets/models/graphics_pilot/realistic_map/wave10/`;
  - `game/assets/textures/graphics_pilot/realistic_map/wave10/`.
- `game/scenes/levels/cctv/cctv_set.tscn` (chỉ năm nhánh `Room*`), và script hình mới trong `game/scenes/levels/cctv/`.
- Bảng bày đồ, nếu dùng như T-255: file mới đặt trong `game/scenes/levels/cctv/` hoặc `art_source/`. Chỉ đặt trong `game/data/` khi integrator đồng ý.
- A30: các file ở mục 1 điểm 8, trong giới hạn ghi ở đó (kể cả `floor4.tscn`, chỉ transform của `Door407/Pivot/RulesPaper`).
- Test mới trong `game/tests/levels/`, và card này.
- Cảnh tạm trong `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi director (`game/scripts/core/`).
- Đổi sinh viên, xác, quản lý, hay `Corridor` của trường quay.
- Đổi UI, kể cả tab Camera và kích thước feed.
- Đổi âm thanh, luật, lời thoại, `chapter*.tscn`, `game/scenes/main/`, `project.godot`.
- Tạo mẫu Tripo mới, dùng extension Blender, dùng ảnh AI.
- Chạy bot, đo FPS.
- Commit log, video, `anh_chup_sua_loi/`.
- Sửa STATUS, DECISIONS.

## Checklist
- [x] Lượt 1: khảo sát, bảng hợp đồng, ảnh feed hiện trạng của năm phòng và năm hành lang, kiểm kê đồ nhỏ phòng 407
- [x] Lượt 1: hình mẫu một phòng, phương án; dừng chờ chủ dự án chọn
- [x] Lượt 2: năm phòng, năm hành lang
- [x] Lượt 2: đồ nhỏ phòng 407
- [x] Lượt 2: ảnh đồng bộ bốn chương, ảnh trước/sau, `overview.jpg`, test lọc, README, CREDITS, Handoff

## Review integrator, lượt 2 và merge (22/11/2026)
- **Đạt, merged** `d36c7a2b` (no-ff từ nhánh `5075217`). Không cần commit sửa.
- **Phạm vi đúng D-188:**
  - `cctv_set.tscn`: thêm 55 node, 11 trong mỗi nhánh `Room*`; không xoá node nào; `Corridor` không đổi.
  - 45 occluder, mỗi phòng 9 cái, mỗi cái nằm trong một tường cũ.
  - `floor4.tscn`: chỉ đổi z của `Door407/Pivot/RulesPaper` (−0,025 → −0,063).
  - `room407_anchors.tscn`: chỉ đổi mesh và vật liệu của `ShowerYes/Button`, `ShowerNo/Button`; sub-resource `t172_button` không còn ai dùng.
  - Bốn scene A30 khác: chỉ đổi mesh.
  - Không test cũ nào bị đổi.
- **Script `cctv_room_real.gd`:**
  - dựng phòng lúc chạy;
  - mọi mesh chỉ vẽ trong phạm vi 40 m quanh camera, nên góc nhìn của người chơi (luôn cao hơn trường quay hơn 60 m) không tốn thêm;
  - không có `set_state`, `_process`.
- **Số đo**, đều dưới trần mục 1 điểm 7:
  - mỗi phòng 112.629–156.690 tam giác;
  - feed phòng 112–140 lần vẽ, feed hành lang 92–135; feed hành lang tầng 4 giảm từ 167 xuống 59;
  - bộ nhớ hình chương 1 thêm 16 MB.
- **Bật/tắt occluder:**
  - 10/12 feed giống nhau từng điểm ảnh;
  - hành lang 306: 11 điểm lệch tối đa 2/255;
  - phòng 310 trước khi thua: lệch 1/255, do khung tự dao động ngay cả giữa hai khung cùng trạng thái;
  - cả hai dưới ngưỡng 6/255 đã dùng cho khối che thư viện. Chấp nhận.
  - Lane B ghi: trong Godot 4.7.2, ẩn rồi hiện lại một occluder thì nó thôi che. Vì vậy lane B so bằng cách bật/tắt occlusion của viewport; trong game occluder không bao giờ bị ẩn.
- **Ảnh đã xem:** `overview.jpg`, `a30_compare.jpg`.
  - D2 và mùng 407: vẫn thấy rõ nạn nhân.
  - Bảng số xanh đọc được; W2 thấy ở feed phòng 310.
  - Đồ A30 thật hơn mà vẫn đúng chỗ.
  - Ảnh bốn chương nhất quán.
- **Kiểm:**
  - Full test chạy trực tiếp theo 16 phần, mỗi phần dưới 10 phút: **1096 passed, 0 failed** (core 196, levels 323, player 266, audio 131, ui 126, tools 53, smoke 1).
  - `test_ch4_environment`, mà lane B thấy lúc đạt lúc hỏng, lần này đạt.
  - Check: **0 lỗi** (22/11 15:34).
  - Log ở `build/integrator/T267m_*.log`.
- **Bản chơi:** package PASS 22/11 15:36. File `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-d36c7a2b-win64.zip` (546 MiB). **Có đủ mười đợt đồ hoạ môi trường.**

## Handoff
*(Lane B ghi: đã làm, còn dở, cách kiểm, dòng RESULT test, commit, yêu cầu thay đổi, phần chưa kiểm.)*

### Lượt 1 (lane B, 21/11/2026; card đọc ở `d369bf8`) — xong, DỪNG chờ chủ dự án chọn
Nhánh tạo từ `origin/main` `d369bf8`. Lượt này **không sửa scene nào của game**: hình mẫu được dựng lúc chạy, trong chương 1
và 2 thật, bằng script chụp. Lượt này thêm glb hình mẫu ở `wave10/`, test `test_t267_cctv.gd`, script và ảnh. Chi tiết, bảng
số, cách chạy lại: `art_source/graphics_upgrade/realistic_map/wave10/README.md`.

**Xem trước** (`art_source/graphics_upgrade/realistic_map/previews/wave10/`): `survey_feeds.jpg`, `survey_a30.jpg`,
`pilot_306.jpg`, `options_d.jpg`, `options_w.jpg`, `options_h.jpg`, `options_signs.jpg`. Ảnh lẻ có tên `survey_*` và `pilot_*`;
feed thô 320 × 240 ở `wave10/survey/feeds/`. Ảnh ghép có thêm cột "như trên điện thoại", mô phỏng `ui/phone/cctv.gdshader`.

#### 1. Khảo sát
Mục 0 đúng. Thêm các điểm sau:
- **Bố cục:** năm phòng giống hệt nhau: phòng 4 × 5 m, cửa 0,9 × 2,2 m, hành lang 5,8 × 2,25 m. Gốc phòng ở x 0/6/12/18/40,
  `CctvSet` ở y −60.
- **Va chạm:** mỗi phòng có 22 hình va chạm: vỏ 8, hành lang 7, giường 2, tủ 4, bàn 1. Dấu vân tay giống nhau ở cả năm phòng.
- **Feed vẽ cả phòng bên cạnh.** Camera feed chỉ chép transform và FOV, không chép `far`. `SubViewport` của feed không bật
  occlusion culling, và trường quay không có occluder. Vì vậy feed vẽ mọi thứ trong khung nhìn, kể cả sau tường:
  - feed hành lang 102 vẽ 310 lần, vì thấy cả hành lang và phòng của 306, 209, 106; feed hành lang 310 chỉ vẽ 111 lần;
  - feed phòng thấy phòng bên trái;
  - nên mọi thứ thêm vào một phòng cũng tốn ở feed của các phòng bên cạnh.
- **Điện thoại hiện feed qua `cctv.gdshader`:** ảnh xám, lấy mẫu theo lưới 320 × 180, có sọc quét và hạt. Hệ quả:
  - màu mất hết: đèn bàn 106 chỉ còn là một mảng sáng;
  - số phòng phía trong: trên điện thoại gần như không đọc được, ở main cũng vậy.
- **Những chỗ đụng tới trường quay:**
  - `chapter1_director.gd`:
    - `_build_cctv`;
    - `_cctv_room` lấy con đầu tiên của `CctvSet` có tên chứa số phòng;
    - `_cctv_scene`; `_cctv_follow` đổi feed khi quản lý đi qua z phòng − 0,15;
    - `_cctv_kill`, `_cctv_leave`.
  - `chapter2_director.gd`:
    - `_place_ch2_props` thêm feed `hall_310` và `cam_310`;
    - `_cctv_310` gọi `set_state(&"lunge")` trên **mọi** node con của `Room310` có hàm đó, nên hình mới không được có hàm
      `set_state`.
  - Ngoài lane B: `event_bus.gd`; `phone_tools.gd`, `phone_missions_preview.gd` (lane D); `performance_bot.gd` (lane C, nhóm
    `cctv_feed`).
  - Test: `test_cctv`, `test_ch2_props` (hợp đồng 310, đầu ba xác trước `Cam`), `test_t256_floor4_rest` (vân tay `Corridor`),
    `test_wide_corridors`, `test_phone_missions`.
- **Bộ nhớ hình lúc vào chương (main):** chương 1: 1.150 MB, chương 3: 1.355 MB.

**Bảng hợp đồng** (tính trong không gian `Room<n>`; `test_t267_cctv.gd` kiểm từng dòng):

| Node | Phải giữ |
|---|---|
| `Room102/306/209/106/310` | tên, vị trí x 0/6/12/18/40 |
| 22 `CollisionShape3D` mỗi phòng | md5 `6686bf8d8b52f9bce03b1a8e4895ac0b` (in theo cách của T-256), giống nhau ở cả năm phòng |
| `Cam` | (3,72; 2,78; −4,72), xoay (−25,84; 143,07; 0), FOV 66, far 30. Riêng `Room310/Cam`: (2; 2,6; −0,35), xoay (−31,91; 0; 0) |
| `Hall/Cam` | (−0,7; 2,65; 2,2), xoay (−23,26; −65,32; 0), FOV 70, far 30 |
| `Hall/Start`, `Door`, `ManagerSpot` | (4,45; 0,05; 1,3); (2,45; 0,05; 1,2); (1,55; 0,05; −2,35) quay −60° |
| `VictimBed`, `Victim` | (0,65; 1,2; −3) |
| `Corpse1/2/4` (phòng 310) | (0,65; 0,43; −3); (3,35; 0,43; −3); (3,35; 1,2; −3) |
| `NumberInside`, `NumberOutside` | (2,45; 2,42; ∓0,11), chữ là số phòng |
| `NightLight`, `Hall/Tube`, `Room106/DeskLamp` | vị trí, năng lượng, tầm như cũ; phòng 102 không có đèn bàn |
| Mùng `BunkA` / `BunkB` → `NetLower`, `NetUpper` | giữ. Mùng là con của instance giường kit, nên chỉ ẩn mesh giường, không ẩn node giường |

**Ảnh hiện trạng:**
- mỗi phòng: `survey_<số>_hall_feed.jpg` và `survey_<số>_room_feed.jpg` (khung feed ×3), kèm `_1080.jpg` cùng camera; ghép trong
  `survey_feeds.jpg`;
- phòng 310 có thêm `survey_310_room_before` (trước khi gọi `_cctv_310`).

**Đồ nhỏ phòng 407 (A30):** bảng đầy đủ trong README, ảnh gần có đèn pin ở `survey_a30.jpg`.
- Khoảng 616 tam giác hình khối, có ở cả bốn chương.
- Tất cả các món đều nằm dưới `Anchors` (trong `KEEP_PS1`), nên không cần đường C2.
- **Đề xuất file lane B được sửa ở lượt 2** (integrator duyệt):
  - `ch1_models/dat_notebook.tscn` (sổ, dùng cho cả sổ Đạt và sổ hợp âm);
  - `ch1v2/guitar_songbook.tscn` (chỗ dây đàn);
  - `room407/khoa_outlet.tscn` (ổ điện Khoa);
  - `room407/room407_anchors.tscn`: chỉ hai mesh `ShowerYes/Button` và `ShowerNo/Button` (nút tắm, hiện là hộp trắng không vật
    liệu);
  - `ch1v2/trash_bin.tscn` (giấy vụn).
- Ưu tiên thấp:
  - `ch1_models/charger.tscn`: bộ sạc nằm trong tủ Đạt đóng, khi chơi không nhìn thấy;
  - `ch1_models/router.tscn`: chỉ còn LED, giữ.
- Không sửa:
  - giấy đọc được `Ch1*`: `readable.tscn` của lane A, do director đặt; giấy hai tam giác là hợp lý;
  - ổ cắm nối dài, phích, cổng LAN, cáp: đã là hình thật;
  - `Door407/Pivot/RulesPaper` trong `floor4.tscn`: từ trong phòng không thấy, phía hành lang lệch 4 cm (đã ghi ở T-266). Sửa
    hay không do integrator quyết.

#### 2. Hình mẫu phòng 306 và hành lang (`pilot_306.jpg`)
- **Dựng bằng Blender, chỉ dùng vật liệu và texture có sẵn của đợt 1–2.** Ba glb ở
  `game/assets/models/graphics_pilot/realistic_map/wave10/`, toạ độ cục bộ của `Room<n>`, nên một bộ dùng chung cho cả năm
  phòng:
  - `cctv_room.glb` (2.386 tam giác): vỏ phòng; tường sau W1 hoặc W2; khung cửa sơn xanh; bảng số; bóng đèn ngủ treo ở chỗ
    `NightLight`.
    - Bảng số là tấm sơn xanh đậm đặt sau chữ `Label3D`, như nhà B. Lý do: biển nhôm `room_plate.glb` làm chữ trắng xoá trên
      feed.
  - `cctv_hall.glb` (1.502): hành lang tầng 1–3 của nhà B (đợt 2). Lan can sắt cho tầng 2–3 (209, 306, 310), lan can xây cho
    tầng 1 (102, 106); máng đèn ở chỗ `Hall/Tube`; ngoài lan can là trời tối.
  - `cctv_light_set.glb` (3.784): D1, gồm giường tầng thép và tủ thép kiểu đợt 2.
  - Cánh cửa dùng lại `wave2/room_door_leaf.glb`, mở vào trong, nằm dọc mép cửa phía đông.
- **Đồ 407 dùng chung:**
  - mọi phòng: bàn, ghế, quạt trần, nệm, gối, chăn;
  - riêng phòng 306: khăn, xô, đồ trên bàn, đặt đúng chỗ cũ.
- **Giữ nguyên:** mùng PS1 (hợp đồng), người khối, đèn.
- **Kiểm tầm nhìn bằng test** (đã sửa hai chỗ test bắt được: dầm mép hành lang từng ôm lấy vị trí `Hall/Cam`; thanh đầu giường
  từng chắn tia từ `Cam` của 310 tới đầu nạn nhân):
  - tuyến thẳng của quản lý trống ở ngang ngực;
  - từ `Cam` thấy đầu nạn nhân ở cả năm phòng;
  - từ `Hall/Cam` thấy cửa.

#### 3. Phương án (số đo trên cùng một khung, phòng 306)

| | Tam giác / vật liệu của phòng | Feed phòng: lần vẽ / tam giác | Bộ nhớ hình chương 1 / chương 3 |
|---|---|---|---|
| main | 4.464 / 29 | 111 / 33.697 | 1.150 / 1.355 MB |
| **D1**: giường, tủ nhẹ đợt 2 + đồ 407 | 105.280 / 38 | 136 / 96.958 | +73 / +0 MB (gồm cả hành lang H1) |
| **D2**: giường, tủ Tripo của 407 | 148.494 / 37 | 133 / 128.427 | thêm +0 so với D1 (đồ 407 đã nạp) |
| **W2** thay W1 (chỉ thấy ở feed 310) | +864 tam giác | +5 lần vẽ (feed 310: 141 → 146) | +0 |
| **H1** / **H2**: hành lang | 1.502 tam giác cả hai | feed hành lang 306: 289 → 318 | H1 dùng mask 4096 px chưa nén: ~60 MB của con số +73 MB ở chương 1 |

- **Đồ trong phòng: đề xuất D1.**
  - Phòng 102–310 chính là các phòng tầng 1–3 của nhà B. Ở chương 3–4, nhìn qua cửa những phòng đó đã thấy đúng bộ giường,
    tủ này (đợt 2), nên dùng D1 thì cùng một tòa.
  - Ít hơn D2 khoảng 43.000 tam giác mỗi phòng; số lần vẽ như nhau.
  - D2 giống phòng 407 hơn.
  - Phần lớn tam giác của cả hai phương án là đồ Tripo 407 dùng chung (gối, chăn, bàn, quạt).
- **Tường sau: đề xuất W2.**
  - Chỉ có feed 310 nhìn về tường sau. Trong feed đó, ô cửa sổ có song và cửa ban công sau bàn làm 310 đọc ra là phòng ở thật.
  - Rẻ: +864 tam giác, +5 lần vẽ; bốn feed còn lại không tốn gì.
- **Hành lang: đề xuất H1** (đúng là hành lang tầng 1–3 nhà B).
  - Ở lượt 2, H1 dùng vật liệu riêng: cùng texture 407, nhưng mask nhỏ (≤ 512 px, nén VRAM) thay cho ba mask 4096 px chưa nén
    của đợt 2.
  - Ước tính chương 1–2 chỉ còn thêm khoảng 10–15 MB thay vì 73 MB; chương 3 vẫn +0.
  - H2 (vật liệu hành lang tầng 4 của T-256) chỉ khác vật liệu.
- **Dấu hiệu trên feed** (`options_signs.jpg`): ở khung 320 × 240 đều đọc được: nạn nhân trên giường, quản lý ở cửa, số phòng
  trên bảng xanh, điện thoại sáng ở 306, mùng ở 209, đèn bàn ở 106, ba xác ở 310.
  - Mùng không che nạn nhân: mùng tầng trên của giường A vẫn mở như main.
  - Trên điện thoại (ảnh xám): số phòng phía trong vẫn mờ, như ở main; các dấu hiệu khác vẫn rõ.
- **Người khối giữa phòng thật:** quản lý thật đứng cạnh sinh viên và xác khối.
  - Ở 1080p, người khối lộ rõ là đồ chơi.
  - Trên feed 320 × 240, và nhất là qua bộ lọc xám, họ vẫn đọc được tư thế, nên không phá cảnh.
  - Không làm nhân vật (ngoài phạm vi).
- **Trần đề xuất cho lượt 2:**
  - D1: ≤ 120.000 tam giác mỗi phòng; D2: ≤ 160.000;
  - mỗi glb đợt 10: < 5.000 tam giác;
  - feed phòng: ≤ 150 lần vẽ; feed hành lang: ≤ 340.

#### 4. Câu hỏi cho chủ dự án
1. Đồ trong phòng: D1 hay D2? (đề xuất D1)
2. Tường sau: W1 hay W2? (đề xuất W2)
3. Hành lang: H1 hay H2? (đề xuất H1, mask nhỏ)
4. Cửa phòng mở vào trong, và bảng số sơn xanh sau chữ: đồng ý không?
5. Mùng: lượt 2 giữ mùng PS1 như hợp đồng, hay thay bằng mùng của 407 với cùng độ trong? Mùng là món "PS1" rõ nhất còn lại
   trên feed. Đề xuất: giữ, trừ khi chủ dự án muốn thay.

#### 5. Kiểm
- **Test lọc.** Năm bộ lọc chạy liền nhau từ 15:05 ngày 21/11 và đều đạt:
  - `-Filter t267`: `RESULT: 4 passed, 0 failed`
  - `-Filter cctv`: `RESULT: 9 passed, 0 failed`
  - `-Filter ch2_props`: `RESULT: 7 passed, 0 failed`
  - `-Filter wide_corridors`: `RESULT: 4 passed, 0 failed`
  - `-Filter t256`: `RESULT: 9 passed, 0 failed`
- **Bị dừng, có lẽ vì máy thiếu RAM: không chạy lại.** Khoảng 15:09, lúc đang chạy `-Filter chapter1`, Claude Code báo đã dừng
  lượt chạy nền. Máy lúc đó còn 1,6–1,8 GB trống; T-266 cũng bị dừng đúng kiểu này.
  - Lane B thoạt đầu tưởng là do giới hạn thời gian nên mở chạy lại, rồi tự dừng lại ngay. Lần chạy lại không cho kết quả nào.
  - Các tiến trình Godot sót lại của lane B (`chapter1`, `chapter2`) đã tắt.
  - `chapter1` và `chapter2` không có dòng RESULT.
  - Chưa chạy: `story_segments`, `graphics_bindings`, `room407`, `floor4`, `ch1_`, `t266`.
- Lượt 1 không sửa scene, script game hay test cũ nào. Ba glb mới chưa gắn vào đâu, nên các bộ lọc chưa chạy vẫn kiểm đúng như
  main.
- Đã `git checkout -- game/default_bus_layout.tres`.
- **Commit:** `8b64c4a` (WIP) và commit cuối "T-267: round 1 …" (hash xem `git log`).
- Không chạy full test, không chạy check (card mục 7). Không bot, không đo FPS.
- Cảnh tạm `game/_probe_tmp/` đã xoá; khoá `GODOT_DANG_CHAY.txt` của lượt này đã gỡ; Blender, Godot đã đóng.
- **Yêu cầu thay đổi ngoài phạm vi: không bắt buộc.** Gợi ý cho core, tuỳ integrator: bật `use_occlusion_culling` trên
  `SubViewport` của feed (trong `_add_feed`). Khi đó lane B thêm occluder hộp ở tường các phòng (trong `Room*`), để feed không
  vẽ phòng bên cạnh. Chỉ chép `far = 30` của `Cam` thì không đủ, vì các phòng chỉ cách nhau 6 m.

### Lượt 2 (lane B, 22/11/2026; card đọc ở `53d4d0e`) — xong, DỪNG
Nhánh rebase lên `origin/main` `53d4d0e` (mục 1 D-188, core `1324a2a`). Vì rebase viết lại hai commit lượt 1, nhánh được đẩy bằng
`--force-with-lease` (chỉ nhánh của lane B). Chi tiết, bảng số, cách chạy lại: `art_source/graphics_upgrade/realistic_map/wave10/README.md`,
mục "Lượt 2".

**Ảnh** (`art_source/graphics_upgrade/realistic_map/previews/wave10/`): `overview.jpg`; `compare_rooms.jpg` (feed ×3 trước/sau,
kèm bản như trên điện thoại), `compare_1080.jpg`; `before_*`/`after_*` (feed và 1080p cùng camera); `a30_compare.jpg`, `a30_*`;
`sync.jpg`, `sync_ch{1..4}_*`. Feed thô và log: `wave10/survey/feeds/r2_*.png`, `wave10/survey/r2_*.txt`.

#### 1. Năm phòng, năm hành lang (D-188 điểm 1–7, 9)
- **`cctv_set.tscn`, chỉ năm nhánh `Room*`** (`patch_cctv_set.py`), mỗi phòng thêm hai node:
  - `Real` (script `game/scenes/levels/cctv/cctv_room_real.gd`) lúc chạy ẩn mọi mesh PS1 của phòng (giữ node, ghi vào
    `replaced`), trừ người. Sau đó đặt:
    - vỏ phòng với W2, khung cửa, bảng số xanh sau `Label3D`, lá cửa mở vào trong dọc mép đông;
    - hành lang H1;
    - đồ 407 kiểu D2 như T-255;
    - mùng 407 đúng trạng thái mùng PS1;
    - đồ riêng từng phòng ở chỗ cũ.
  - `Occluders`: 9 hộp, mỗi hộp nằm trong một hộp va chạm tường PS1.
  - Không va chạm, không đèn, không `set_state`.
  - `Corridor` không đụng.
- **Mùng tầng trên vén (nạn nhân nằm ở đó):** phòng 407 không có. `build_wave10_net.py` chạy chính script mùng 407, chỉ đổi hai
  chỗ:
  - mái cao 1,0 m trên nệm (407: 0,86 m), vì đầu Đăng (106, `sit_up`) và Bảo (209, `cower`) lòi qua mái thấp;
  - ô vải 5 cm, để glb dưới 5.000 tam giác.
  Từ `Cam` vẫn thấy rõ nạn nhân qua mặt vén, mùng 209 vẫn đọc được (`compare_rooms.jpg`).
- **Hành lang H1:** vật liệu riêng `CW*`, cùng scan với đợt 2, trên ba mask nhỏ (512 × 256, 512 × 256, 256 × 128), nén VRAM.
  Tường đầu hành lang kéo tới mép ngoài, để lan can dừng ở tường.
- **Số đo khi bật occlusion** (main = `53d4d0e`):
  - tam giác mỗi phòng: 112.629–156.690 (trần 160.000);
  - glb: 2.370 / 1.502 / 4.506 (trần 5.000);
  - feed phòng: 112–140 lần vẽ (trần 150);
  - feed hành lang: 92–135 lần vẽ (trần 250);
  - `cam_corridor`: 167 → 59 lần vẽ;
  - bộ nhớ hình chương 1: 1.150 → 1.166 MB (+16, trần 25);
  - bộ nhớ hình chương 3: đồ mới thêm 0 MB (cả lượt chạy 1.355 → 1.358 MB; 3 MB lên khi vẽ góc nhìn xuống, trước khi gắn
    đồ; trần 5).
- **Hình `Real` chỉ vẽ trong 40 m quanh camera.** Người chơi luôn cách trường quay trên 60 m. Trên main, góc nhìn người chơi
  thẳng xuống vẫn vẽ cả trường quay PS1; nay ít lần vẽ hơn (chương 3: 2.664 → 2.047).
- **Bật/tắt occluder** (chạy 3 s rồi gần như dừng thời gian, chụp liền nhau):
  - 10/12 feed giống hệt từng điểm ảnh;
  - hành lang 306: 11 điểm ảnh lệch tối đa 2/255, là một vệt dọc ở mép tường đầu hành lang;
  - phòng 310 trước khi thua: mọi điểm ảnh dao động 1/255 cả giữa hai khung cùng trạng thái (nhiễu môi trường chương 2). Số
    lần vẽ bật và tắt bằng nhau (142), nên ở góc này occluder không bỏ vật nào;
  - không điểm nào vượt 6/255.
- **Bẫy Godot 4.7.2:** ẩn một `OccluderInstance3D` (hay gỡ khỏi cây) rồi hiện lại thì nó không che nữa, cho tới khi một
  viewport bật lại cờ occlusion (`survey/r2_occ_probe.txt`). Vì vậy ảnh so sánh bằng cách bật/tắt cờ của viewport. Trong game
  occluder không bao giờ ẩn.

#### 2. Đồ nhỏ phòng 407 (A30, D-188 điểm 8)
- **Chỉ trong các file ở mục 1 điểm 8, chỉ đổi node mesh:** mesh OBJ mới trên đúng node cũ; vật liệu giữ của scene (shader bề
  mặt PS1 trên cùng ảnh 128 px). Nút tắm trước không có vật liệu, nay dùng nhựa trơn.
- **Hình mới:**
  - sổ Đạt: bìa bo góc, khối trang vát, 7 vòng lò xo;
  - ô hợp âm: nét mực phẳng;
  - ổ điện Khoa: khung bo cạnh, mặt ổ vát, hai khe bo, vít mũ tròn;
  - thùng rác: ba nắm giấy vo;
  - nút tắm: đế và nút bấm.
- **Các node khác trùng main:** `test_t267_a30` băm mọi node trừ phần hình của mesh, so với bản băm lấy từ file của main trong
  chính trình chạy test.
- **Hình bao lệch tối đa 1,2 cm.** Không đặt hình ở đường dẫn khớp `REPLACED_PS1`. Trong phòng 407 có đồ thật, cả 42 node mới
  đều hiện.
- **Ngân sách tam giác của test cũ giữ nguyên:**
  - `test_ch1_models`, `test_ch1v2`, `test_room407_fixes`: sổ 448, sổ hợp âm 468, ổ điện 454, dưới 500;
  - `test_ch1_models` cũng đòi vật liệu `ShaderMaterial` cho sổ.
  Lần đầu lane B làm sổ, ổ điện nặng hơn và đổi vật liệu, nên `room407_fixes` báo ổ điện quá 500 tam giác. Lane B làm lại theo
  ngân sách, không nới test (AGENTS.md).
- **`floor4.tscn`:** chỉ đổi z của `Door407/Pivot/RulesPaper`, từ −0,025 sang −0,063. Lưng tờ nay cách chỗ nhô nhất của cánh
  Tripo phía hành lang 1,2 mm (trước 4,35 cm). Chỗ tờ vắt qua ô cánh lõm thì mép còn hở theo ô lõm (1,6 cm).
  - `test_t267_a30`: băm `floor4` bỏ dòng `RulesPaper` thì trùng main; dòng đó chỉ khác vị trí.
  - Không test cũ nào băm `floor4` cả dòng này, nên không phải cập nhật hằng số nào.
  - Tay nhắm tờ từ trong phòng vẫn trúng tờ trước cửa (`test_core` 18/0).

#### 3. Đồng bộ bốn chương (`sync.jpg`)
Bốn góc ở chương 1–4: 407 từ cửa, hành lang tầng 4 từ đầu cầu thang, nhà vệ sinh chung, phòng 403. Cửa 407 và 403 được mở cho
ảnh. Chỗ khác đều có lý do:
- đèn bàn 407 bật ở chương 1–2;
- chương 3–4 tầng 4 nằm trong nhà B giữa khuôn viên: ánh sáng môi trường sáng hơn, ngoài lan can là trời đêm và các nhà;
- chương 1–2 ngoài lan can là nền đỏ thẫm.

**Không thấy chỗ khác nào không có lý do.** Không sửa ngoài phạm vi.

#### 4. Kiểm
Mỗi bộ lọc chạy trực tiếp, theo file khoá; sau mỗi lần trả `default_bus_layout.tres`. Không chạy full test, không chạy check,
không bot, không đo FPS.

**13 bộ lọc của card** (đều chạy trên trạng thái cuối, trừ ghi chú):
- `t267`: `RESULT: 8 passed, 0 failed`
- `cctv`: `RESULT: 11 passed, 0 failed`
- `ch2_props`: `RESULT: 7 passed, 0 failed`. Lần chạy đầu 6/1 ở `test_stuck_door_shakes…`, test hẹn giờ cửa nhà tắm 407, không
  đụng đợt này; đã ghi chậm như vậy ở `1324a2a`. Chạy lại đạt, lần cuối cũng đạt.
- `wide_corridors`: `RESULT: 4 passed, 0 failed`
- `t256`: `RESULT: 9 passed, 0 failed`
- `chapter1`: `RESULT: 54 passed, 0 failed` (598 s)
- `chapter2`: `RESULT: 27 passed, 0 failed`
- `story_segments`: `RESULT: 22 passed, 0 failed`
- `graphics_bindings`: `RESULT: 8 passed, 0 failed`
- `room407`: `RESULT: 83 passed, 0 failed`
- `floor4`: `RESULT: 30 passed, 0 failed`
- `ch1_`: `RESULT: 26 passed, 0 failed`
- `t266`: `RESULT: 15 passed, 0 failed`

**Grep `game/tests` theo tên các scene đã sửa** (cả `RulesPaper`): các test nằm ngoài các bộ lọc trên:
- `test_core.gd`: `RESULT: 18 passed, 0 failed`
- `t260`: `RESULT: 6 passed, 0 failed`. Lần đầu 4/2: occluder lượt này cao −0,2…3,15 m và có hộp vắt qua hai tường, trái luật
  "mỗi occluder nằm trong một hộp đặc" của test. Đã đổi thành 9 hộp, mỗi hộp trong một tường, cao 0–3 m, rồi đo lại toàn bộ.
- `ch4_environment`: `RESULT: 6 passed, 0 failed`. Có lịch sử đổi kết quả:
  - hai lần đầu 5/1 ở `test_routes_split_library_return_room_and_all_library_floors` (đường ở thư viện, nhà ăn);
  - với sáu file của main thay vào: đạt hai lần;
  - với đủ thay đổi của lane B, lần ba đạt.
  Test này chỉ nạp `floor4` và `campus`. Comment của test nói đồ thị dẫn đường của khuôn viên đồng bộ không đồng thời. Lane B
  không thấy đường nào nối tờ nội quy hay đồ A30 với lưới dẫn đường. **Nhờ integrator để ý test này lúc chạy full.**
- `ch1v2`: `RESULT: 33 passed, 0 failed`
- `corridor_g5`: `RESULT: 9 passed, 0 failed`
- `fire_stairs`: `RESULT: 3 passed, 0 failed`
- `levels/test_props.gd`: `RESULT: 6 passed, 0 failed`
- `room_doors`: `RESULT: 4 passed, 0 failed`
- `sealed_408`: `RESULT: 2 passed, 0 failed`
- `t250`: `RESULT: 5 passed, 0 failed`
- `t254`: `RESULT: 4 passed, 0 failed`
- `t255`: `RESULT: 12 passed, 0 failed`
- `t258`: `RESULT: 5 passed, 0 failed`
- `protagonist_body`: `RESULT: 18 passed, 0 failed`
- `t242`: `RESULT: 9 passed, 0 failed`
- `test_campus.gd`: `RESULT: 5 passed, 0 failed`

**Ghi chú về trạng thái lúc chạy:**
- `room407`, `ch1_`, `ch1v2`, `floor4`, `t266`, `test_core.gd` chạy trên A30 cuối, trước lần đổi occluder. Các test này không
  nạp `cctv_set.tscn`.
- Mọi bộ lọc còn lại chạy sau lần đổi occluder.
- Không lượt nào bị dừng vì thiếu RAM. Máy còn 1,0–2,6 GB trống.

**Yêu cầu thay đổi ngoài phạm vi:** không có.

**Gợi ý:** `test_ch4_environment` (đường qua đồ thị khuôn viên) phụ thuộc thời gian.

**Commit:** WIP `72a2811`, `99c8929`, và commit cuối "T-267: round 2 …" (hash xem `git log`).