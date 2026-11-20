# T-267 — Đồ hoạ thật đợt 10: năm phòng trường quay CCTV (102, 306, 209, 106, 310) và đồ nhỏ phòng 407
- Lane: B | Trạng thái: **mới; chỉ giao sau khi T-266 merge** (card viết 20/11/2026 trong lúc lane B làm T-266 lượt 2) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`. Chủ dự án tự dán prompt (`lane-b.md` mục 1u).
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
*(Integrator ghi sau lượt 1.)*

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
  - không lưới mới nào nằm giữa camera và nạn nhân. Mùng đã có thì giữ, và giữ độ trong của mùng.
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
  - Ghi tổng số tam giác của mỗi phương án. Integrator đặt trần tam giác sau lượt 1.
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
  - mọi `.import` texture trong thư mục asset đợt 10 đều nén VRAM.
- **Test cũ phải đạt:**
  - trường quay: `test_cctv`, `test_ch2_props`, `test_wide_corridors`, `test_t256_floor4_rest`, `test_chapter1`, `test_chapter2`, `test_story_segments_3_5`, `test_graphics_bindings`;
  - vì đụng phòng 407 (A30): `test_room407_*`, `test_floor4`, `test_ch1_*`, `test_t266*`.
- **Lane B chỉ chạy test lọc:**
  - lệnh: `pwsh tools/test.ps1 -Filter <bộ lọc>`, chạy với từng bộ lọc `t267`, `cctv`, `ch2_props`, `wide_corridors`, `t256`, `chapter1`, `chapter2`, `story_segments`, `graphics_bindings`, `room407`, `floor4`, `ch1_`, `t266`;
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
- A30: chỉ các file integrator đã duyệt ở review lượt 1 (ghi ở mục 1).
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
- [ ] Lượt 1: khảo sát, bảng hợp đồng, ảnh feed hiện trạng của năm phòng và năm hành lang, kiểm kê đồ nhỏ phòng 407
- [ ] Lượt 1: hình mẫu một phòng, phương án; dừng chờ chủ dự án chọn
- [ ] Lượt 2: năm phòng, năm hành lang
- [ ] Lượt 2: đồ nhỏ phòng 407
- [ ] Lượt 2: ảnh đồng bộ bốn chương, ảnh trước/sau, `overview.jpg`, test lọc, README, CREDITS, Handoff

## Handoff
*(Lane B ghi: đã làm, còn dở, cách kiểm, dòng RESULT test, commit, yêu cầu thay đổi, phần chưa kiểm.)*
