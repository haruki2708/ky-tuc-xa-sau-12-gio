# T-266 — Đồ hoạ thật đợt 9: phòng 407 ở chương 4 (vạt giường, ba chỗ tìm giả, cửa bị phá) và phòng bệnh viện của đoạn kết
- Lane: B | Trạng thái: **lượt 1 xong, review đạt; D-187 đã chọn, chờ chủ dự án dán lượt 2** (card viết 20/11/2026, sau khi T-265 merge) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`. Chủ dự án tự dán prompt (`lane-b.md` mục 1t).
- **Model (D-183):** lane B **Opus 5.5, effort xhigh**. Lượt nào bị trả sửa hai lần cùng một lỗi thì lượt sửa dùng **max**. Phần của integrator (chuyển phương án, review, sửa core nếu có, full test + check): **Fable 5.2 hoặc Mythos 5.2 high**.
- Nhánh: `lane-b/T-266-realistic-graphics-wave9-room407-hospital` từ `origin/main` mới nhất (đã có đợt 8 và hai sửa core `138cff2`, `78365fa`).
- Quyết định nền:
  - **D-166:** đồ hoạ thật dựng bằng Blender, không PS1, không Tripo; ánh sáng giữ như nay; **bệnh viện là phòng bệnh công, sáng dịu**.
  - **D-167:** ánh sáng phòng bệnh đã sửa (môi trường riêng, không nắng khuôn viên, tường sơn xanh xám). Máy chủ dự án để độ sáng 1,45.
  - **D-167/D-172/D-177:** phong cách đã duyệt, cũ vừa phải. Vật liệu đã duyệt ở các đợt 1–8 dùng lại trước.
  - **D-176:** chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ. **D-179, D-184:** không đo FPS, không chạy bot.
  - Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 9 (A22, A23).
- Làm như các đợt trước: **hai lượt. Lượt 1 khảo sát, hình mẫu và phương án rồi dừng chờ chủ dự án chọn; lượt 2 làm cả hai khu.**

## 0. Hiện trạng (integrator khảo sát 20/11; lane B kiểm lại ở bước 1)

### 0a. Phòng 407 ở chương 4 (A22)
- **Phòng 407 đã là đồ thật** từ G3 và T-222 (vỏ, 4 giường tầng, tủ, bàn, nệm, chăn, gối, mùng: `room_407.tscn`, `room407.gd`, `Room407Furnish`, `game/data/room407/`). **Đợt này không làm lại phòng.**
- Phần còn PS1 là **những thứ chương 4 thêm vào phòng**: nhánh `Room407` trong `game/scenes/levels/ch4/ch4_anchors.tscn` (174 tam giác, toàn `BoxMesh` màu trơn). `ch4_anchors.tscn` gắn dưới `Campus/Anchors/Ch4`; `Room407` đặt ở (30; 0; 0), tức toạ độ trong nhánh trùng toạ độ phòng 407.
- **Lưu ý:** `campus.tscn` có ở **chương 3 và chương 4**, nên các hình dưới đây cũng hiện trong phòng 407 ở chương 3 (chương 3 bắt đầu trong phòng). Chương 1–2 không có `Campus`, nên không có chúng. Xem câu hỏi "nhất quán bốn chương" ở bước 3.
- **Ba vạt giường** `Slat1` (0,65; 1,18; −3: tầng trên giường A, giường 1 của Phúc), `Slat2` (0,65; 0,41; −3: tầng dưới giường A, giường 2 của Việt), `Slat4` (7,35; 1,18; −2,7: tầng trên giường B, giường 4 của Đạt):
  - mỗi cái là `Marker3D` có `slat_visual.gd`, con `Hinge` (lệch 0,43 m về phía tường), `Hinge/Board/Mesh` (hộp nâu 0,86 × 0,035 × 1,45) và `Hinge/Ink` (tấm phẳng 0,80 × 1,38 ở mặt dưới, texture `assets/textures/ch4/slat_ink.png` 128 px; cả ba vạt dùng chung một hình);
  - khi có `EventBus.bed_slat_flipped(bed)`: `Hinge` quay 70° quanh trục z trong 0,45 giây (giường 4 quay −70°), và mùng `Net_Phuc`, `Net_Viet`, `Net_Dat` của giường đó bị ẩn (trả lại khi thoát);
  - **nệm, chăn, gối của giường không động** (`MattressPhuc`, `BlanketPhuc`, `PillowPhuc` và tương tự cho `Viet`, `Dat`): tấm ván quay xuyên qua chúng. CH4_DESIGN khu 5 viết: "lật vạt giường, ném nệm và đồ đạc xuống";
  - director gắn `BedSlat<n>` (vùng dùng tay, giữ E 5 giây, `HandTarget` kiểu móc) vào từng marker; tấm thay thế `SlatPivot` của nó đã ẩn.
- **Ba chỗ tìm giả** (giữ E 8 giây, không có gì): marker `FakeLocker` (0,65; 1,1; −0,45), `FakeCeiling` (3; 2,92; −2), `FakeVent` (7,8; 2,35; −1). Director gắn `SearchLocker`, `SearchCeiling`, `SearchVent` (node `SearchSpot`, có tín hiệu `searched`). Hình hiện có: `CeilingPanel` (hộp kem 0,8 × 0,035 × 0,8 ở y 2,96), `VentFrame` (hộp tối 0,04 × 0,45 × 0,65 trên tường đông) và `VentSlat0…5`. Tủ ở `FakeLocker` là tủ Tripo có sẵn của phòng.
- **Cửa 407 bị phá** `Door` (`door407_proxy.gd`): bám theo `Floor4/Door407`, có `Blocker` (va chạm 0,88 × 2,1 × 0,08). Hình hư hại theo `EventBus.door_damage_changed(&"407", mức)`:
  - `Damage/Cracks` (7 que đen), hiện từ 30 %;
  - `Damage/Hole` (bốn hộp nâu `Left`, `Right`, `Top`, `Bottom` làm khung quanh lỗ), hiện từ 60 %; lúc đó cánh cửa Tripo `Door407/Pivot/Leaf` bị ẩn;
  - `Damage/Hand` (cẳng tay, bàn tay, bốn ngón bằng hộp), hiện từ 80 %.
  - Cửa chịu 90 giây (`ROOM407_DOOR_SECONDS`), bốn xác đập ngoài hành lang. Cửa vỡ mà chưa ký tên là chết (`DEATH_CH4_DOOR`: "tay xác thò qua lỗ thủng rồi tràn vào").
- **Hai lỗi core integrator vừa sửa (20/11), đã có trên main:**
  - `138cff2`: ở chương 4, ba xác bạn cùng phòng vẫn nằm trên giường 1, 2, 4 (chỉ chương 3 ẩn chúng); nay director chương 4 ẩn từ đầu chương.
  - `78365fa`: ba chỗ tìm giả hiện một hộp xám thay thế (`Placeholder` của `search_spot.tscn`); nay ẩn.
  - Ảnh khảo sát cũ `previews/survey/ch4_slats.jpg`, `ch4_vent.jpg` (12/11) còn thấy cả hai lỗi này; lane B chụp lại.
- **Code dùng:** `chapter4_director.gd` (`_room407`, `_place_room_props`, `_on_bed_slat_flipped`, `_on_407_broken`), `scripts/interaction/bed_slat.gd`, `search_spot.gd`, `scripts/ui/ch4_form.gd` (UI ghép phiếu của lane D: mỗi vạt lật ra một mảnh phiếu), jumpscare `neck_hand`.
- **Test đang giữ hợp đồng:**
  - `test_ch4_environment`: marker `Slat<n>` cách marker giường `Bunk<n>` dưới 0,1 m; sau tín hiệu thì `slat.flipped` và `Hinge.rotation.z` lớn hơn 1 rad; `Fake*` là `Marker3D`; proxy mở/đóng theo cửa gốc; `Damage/Cracks`, `Hole`, `Hand` hiện đúng ở 0,3 / 0,6 / 0,8; cánh gốc ẩn từ 0,6; thoát thì mùng và cánh trả lại; **`Room407/Door` dưới 500 tam giác, mỗi `Slat<n>` dưới 500 tam giác** (đếm mọi `MeshInstance3D` con).
  - `test_chapter4` (vạt với tới được bằng tia dùng tay; giường trống; không hộp xám), `test_ch4_gameplay`, `test_ch2_4_hand_targets` (ba `bed_slat` kiểu móc), `test_room_doors`.
- **Hiệu năng:** PLAN mục 6 cho A22 **≤ 0,15 ms** thêm.

### 0b. Phòng bệnh viện của đoạn kết (A23)
- **Cảnh:** `game/scenes/levels/hospital/hospital_room.tscn` (lane B dựng ở T-196; 937 dòng), gốc `HospitalRoom`, script `hospital_room.gd`. Director nạp lúc kết và đặt ở (0; 300; 0). Toàn PS1: 758 tam giác, 6 vật liệu màu trơn.
- **Phòng** 5 × 6 × 3 m (x ±2,5; z ±3; sàn y 0, trần y 3): `Floor`, `Ceiling`, `West`, `East`, `HeadWall` (z −3), `FootWall` (z +3), mỗi cái là `StaticBody3D` có `Mesh`.
- **Ba giường** dọc trục z, đầu giường phía z âm: `Bed_Trung` (x 0), `Bed_Nhat` (x −1,65), `Bed_Ngu` (x +1,65). Mỗi giường: `Frame`, `Mattress` (có va chạm), `Pillow`, hai `End*`, bốn `Leg*`, `Patient` (`Blanket`, `Head`: hai hộp), marker `Card` (0; 0,88; 1,08) ở chân giường. Kèm `Cabinet_*` (z −2), `IV_*` (cây truyền: `Pole`, `Base`, `Hook`, `Bag`).
- **Khác:** `Monitor` (0; 1,2; −2) trên tường đầu giường, `Screen`, `Trace0…9`, marker `MonitorAudio`; `Window` và `WindowCross` trên tường đông (x 2,485; y 1,9; z −0,7); marker `Nurse1` (−0,72; 0; 1,9), `Nurse2` (0,72; 0; 1,9); `Camera_Wake`; `Environment` (môi trường riêng: nền xám, ánh sáng nền 0,22); `CeilingLight` (OmniLight3D ở (0; 2,8; 0), năng lượng 0,75, tầm 8, không bóng) có `Fixture` và `LightHum`.
- **`hospital_room.gd`:** `set_companions_visible(bool)` bật/tắt `Bed_Nhat/Patient` và `Bed_Ngu/Patient`. Kết thật (`all`): hai bạn nằm hai giường bên, còn hôn mê. Kết một mình (`alone`): hai giường trống.
- **Diễn biến** (`_ending_4`): màn tối 2 giây → hiện phòng bệnh → sáng dần 1,5 giây → y tá 1, y tá 2, tiếng máy theo dõi hụt một nhịp (`monitor_skip`), y tá 1, Trung hỏi, y tá 2 trả lời theo kết → tối dần → thẻ "Hết chương 4". Khoảng nửa phút. Director gắn thẻ tên UI (`ui/ch4/bed_card.tscn`, lane D) vào ba marker `Card`.
- **Camera cố định.** `Camera_Wake` ở (0; 0,94; −0,64), xoay (24°; 180°; 0), FOV 78: mắt người nằm trên giường giữa, nhìn về tường chân giường, ngước 24°. Người chơi không đi, không xoay được. Integrator tính từ toạ độ (lane B chụp lại để xác nhận):
  - **trong khung:** trần (phần lớn nửa trên), tường chân giường, nửa xa của hai tường bên; mép dưới là chăn của Trung và thẻ tên; chân hai giường bên và thẻ của chúng ở hai góc dưới;
  - **ngoài khung:** máy theo dõi (sau đầu, chỉ nghe tiếng), cửa sổ (ngang vai phải), tủ đầu giường, đèn trần (ngay trên đầu, ngoài mép trên); cây truyền ở ngang camera, lane B kiểm.
- **Hai y tá chỉ có tiếng**, phát từ `Nurse1`, `Nurse2` ở chân giường: **ngay giữa khung hình, cách mắt 2,5 m, mà ở đó không có ai.** PLAN dặn "không thêm nhân vật y tá hữu hình theo suy đoán". Đây là câu hỏi lớn nhất của đợt (bước 3).
- **Ánh sáng (D-167):** `test_hospital_light` giữ: camera dùng môi trường riêng của phòng; không đèn hướng nào của khuôn viên chiếu tới; ánh sáng nền ≤ 0,3; `CeilingLight` ≤ 1,0; tường `West/Mesh` có độ sáng màu dưới 0,75 (không trắng giấy).
- **Test khác:** `test_ch4_environment::test_hospital_contract_occupancy_and_triangle_budgets`: ba `Bed_*/Card` là `Marker3D`; **mỗi `Bed_*` dưới 1.500 tam giác**; `Nurse1`, `Nurse2`, `MonitorAudio` là `Marker3D`; `Camera_Wake` là `Camera3D`; `set_companions_visible`. `test_chapter4` (hai kết), `test_ch4_ui` (thẻ tên), `test_ch4_audio`.
- **Ảnh hiện trạng:** `previews/hospital_light/compare_hospital_light.jpg` (trước/sau D-167, hàng dưới là đúng khung `Camera_Wake`), `previews/survey/ch4_hospital_beds.jpg`, `ch4_hospital_wake.jpg`.
- **Hiệu năng:** PLAN mục 6 cho A23 **≤ 0,50 ms**. Phòng độc lập, không liên quan khối che.

## 1. Chủ dự án chốt
**D-187 (20/11/2026):** chủ dự án chọn bốn câu Y, N, K, C theo đề xuất của lane B; integrator chọn các mục còn lại sau khi xem mọi tờ phương án lượt 1. Lượt 2 làm đúng các mục này.

**Review lượt 1 (integrator, 20/11):** đạt, chưa merge (lượt 1 chỉ có hình mẫu). Nhánh `29c1476` chỉ thêm file trong các thư mục đợt 9, cùng card, CREDITS chung và `test_t266_pilot` (3/0); không sửa cảnh, script hay test cũ. Integrator đã đối chiếu code và xác nhận hai lỗi lane B tìm ra: hư hại cửa 407 không hiện trên cánh Tripo; vạt giường 2 quay 70° thì đâm qua tầng trên.

**Phòng 407**
1. **Vạt: V2b**, cả ba giường: 9 tấm ván 14,5 cm, khe 1,6 cm, đóng trên hai thanh dọc, rộng 0,72 m (bản lề dời theo bề rộng mới).
   - **Mỗi giường một góc lật** trong `slat_visual.gd`: giường 2 khoảng 62° để không đâm tầng trên, giường 1 và 4 giữ khoảng 70°.
   - Góc nào cũng trên 1 rad; lật vẫn mất ≤ 0,6 giây.
2. **Chữ: mực loang**, ba vạt ba texture, đúng chữ của ba mảnh phiếu UI (như `options_ink_beds.jpg`). Trước khi lật không thấy chữ.
3. **Nệm, chăn, gối: N2, không va chạm** (chủ dự án chọn). Khi lật, ba món Tripo có sẵn của giường (`furnished_prop`; đồ giường 1 đi theo `Anchors/PhucMattress/Pivot`) rơi xuống sàn cạnh giường, và trở về chỗ cũ khi thoát. Điều kiện:
   - rơi bằng một chuyển động ngắn (≤ 0,6 giây, cùng lúc vạt quay), không hiện ra tức thì;
   - nằm trên mặt sàn (không lơ lửng, không chìm), không xuyên khung hay thanh giường nào trên đường rơi;
   - **giường 1 và giường 2 là một giường tầng** (cùng x, z), nên đồ giường 1 rơi từ tầng trên xuống đúng khoảng sàn trước giường 2. Đồ của mỗi giường có chỗ nằm riêng, không chồng xuyên nhau, **dù lật theo thứ tự nào** (1 rồi 2, hay 2 rồi 1);
   - ở mọi chỗ người chơi đứng hoặc ngồi xổm để lật vạt (các tia dùng tay của `test_chapter4`), camera không nằm trong món đồ nào; đồ rơi không che tia dùng tay tới vạt khác hay tới ba chỗ tìm giả;
   - mùng vẫn ẩn khi lật như nay.
4. **Nắp trần: H1**, nắp thăm trần tôn sơn có khung. **Ô thông gió:** cửa chớp tôn sơn có lưới, muội.
   - **Có phản hồi khi tìm xong:** chớp thông gió treo lệch một vít, nắp trần hé xuống. Tủ Phúc giữ nguyên (đã mở sẵn).
   - Script hình nghe tín hiệu `searched` của node `Search*` mà director gắn dưới marker lúc vào đoạn `room407`, nên phải nối khi node con đó xuất hiện. Chuyển động ngắn, trả lại khi thoát. Không sửa core.
5. **C2: ô thông gió và nắp trần có trong phòng 407 ở cả bốn chương** (chủ dự án chọn). Cách làm:
   - Hình đặt trong phòng 407 gốc (`room_407.tscn`, có ở cả bốn chương).
   - **Bẫy:** `room407.gd._furnish()` ẩn mọi `MeshInstance3D` của cảnh nằm ngoài `KEEP_PS1` và ngoài cây đồ thật. Thêm thẳng vào cảnh thì hình bị ẩn ở mọi chương. Chọn một trong hai đường và ghi trong Handoff:
     - (a) một node riêng mới (ví dụ `Wave9Fixtures`), thêm đường dẫn của nó vào `KEEP_PS1`;
     - (b) một dòng đặt đồ mới qua `Room407Furnish` (`placements.json`).
   - Không đổi chỗ hay hình của món nào có sẵn.
   - Ở chương 3–4, ẩn `CeilingPanel`, `VentFrame`, `VentSlat0…5` của `ch4_anchors.tscn` (giữ node), để không vẽ hai lần.
   - Phản hồi khi tìm (mục 4) tìm hai hình này trong phòng gốc qua `campus.floor4_path`, như `slat_visual.gd` làm với mùng, và trả lại khi thoát.
   - Ở chương 1–2 chúng chỉ là hình: không va chạm, không lời nhắc, không vùng dùng tay. Kiểm khoảng hở với quạt trần (2; 2,28; −2,5).
6. **Cửa 407 bị phá.** Đây là sửa lỗi đang có trên main, làm trong `door407_proxy.gd` (phần hình). Cánh người chơi thấy là cánh Tripo `Floor4/Door407/Pivot/RoomDoor`.
   - **30 %:** vết nứt toác trên chính cánh đó.
   - **60 %:** cánh vỡ có lỗ, mảnh gỗ toác, thấy hành lang qua lỗ.
     - Từ 60 %, **ẩn cả `Pivot/RoomDoor`** (cùng `Pivot/Leaf` như nay) và trả lại cả hai trong `_exit_tree`.
     - **Bốn hộp nâu PS1 dưới `Damage/Hole`** là thứ hành lang đang nhìn thấy từ 60 %: thay bằng cánh vỡ, ẩn hộp, giữ node.
   - **80 %:** tay xác cùng kiểu xác sống (tay áo hoodie xám rách, da tái).
   - Lỗ đặt dưới tờ nội quy `Pivot/RulesPaper` phía hành lang; không đụng tay nắm `HandlePivot`.
   - **Kiểm mức 80 % từ hành lang khi có bốn xác đứng ở cửa** (lượt 1 chưa kiểm): tay không lơ lửng, cánh vỡ không hở.

**Phòng bệnh viện**
7. **Y1: rèm quây có bóng** (chủ dự án chọn).
   - Rèm quây kéo ngang chân giường Trung (z khoảng 1,5). Bóng mờ hai người là một lớp trên nếp rèm; không thêm đèn.
   - Hai bóng **đứng yên, nhìn ra là hai người bình thường** (một người cầm bệnh án), không ra dáng ma hay quái.
   - `Nurse1`, `Nurse2` ở sau rèm: giữ như nay, hoặc dời cho khớp hai bóng (ghi số).
   - Có ở cả hai kết. Không dựng nhân vật y tá.
8. **K2** (chủ dự án chọn): `Camera_Wake` ngước 11° thay vì 24°; giữ vị trí và FOV.
9. **Vỏ phòng** như hình mẫu: tường hai màu (chân xanh nhạt cao 1,2 m, trên trắng ngà, có chỉ sơn), sàn ceramic, trần tấm 60 × 60, máng đèn tuýp đúng chỗ `CeilingLight`. Giường inox, nệm bọc xanh, ga trắng ngà, chăn kẻ xanh nhạt.
10. **Người trên giường:**
    - **Trung: T1** (chăn có dáng người, cẳng tay quấn băng, dây truyền nối tới cây truyền).
    - **Nhật, Ngư** (kết thật): dáng người dưới chăn, đầu quay vào tường, không lộ mặt.
    - **Kết một mình:** hai giường ga phẳng, chăn gấp ở chân giường.
11. **Thẻ tên. Ngoại lệ phạm vi UI, giao lane B.** Đây là chỗ kể chuyện, không chỉ là hình: ở kết thật, người chơi phải **đọc được tên Nhật và Ngư từ `Camera_Wake` (khung K2)**.
    - Hiện tại thẻ quay mặt chữ ra chân giường, nên từ mắt Trung chỉ thấy mặt sau trắng.
    - Giấy dùng vật liệu **không chịu sáng** (`shading_mode = 0`), nên ở độ sáng 1,45 thì cháy trắng.
    - Lane B được sửa `game/ui/ch4/bed_card.tscn` và `game/scripts/ui/ch4_bed_card.gd` để:
      - có chữ ở cả hai mặt (mặt sau cùng nội dung với mặt trước, chữ không bị ngược);
      - giấy chịu ánh sáng của phòng, màu tối hơn một chút, ở độ sáng 1,45 không cháy trắng;
      - giữ API (`character`, `age_text`, `ending`, `refresh()`, luật hiện/ẩn theo kết); `test_ch4_ui` vẫn đạt;
      - có khung kẹp thẻ ở chân giường, khớp marker `Card`.
12. Ánh sáng giữ theo D-167 (`test_hospital_light`). Ở độ sáng 1,45 không vùng nào cháy trắng, kể cả thẻ tên.

## 2. Việc, theo hai lượt

### Lượt 1 — khảo sát, hình mẫu, phương án, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi Handoff:**
   - Kiểm lại mục 0. Grep mọi chỗ code, test, UI, âm thanh, công cụ đụng tới hai khu (`ch4_anchors`, `Room407/Slat`, `slat_visual`, `slat_ink`, `FakeLocker`, `FakeCeiling`, `FakeVent`, `CeilingPanel`, `VentFrame`, `door407_proxy`, `Damage/`, `bed_slat`, `search_spot`, `hospital_room`, `Camera_Wake`, `Bed_`, `Card`, `Nurse`, `MonitorAudio`, `set_companions_visible`, `bed_card`, `levels/ch4/review.gd`).
   - **Bảng hợp đồng**: node nào giữ tên, vị trí, va chạm, API.
   - **Phòng 407, trong chương 4 thật** (`director.run_from(&"room407")`, không tự chạy bot): ghi rõ lúc đó trong phòng sáng hay tối, đèn nào bật. Chụp: toàn phòng từ cửa; từng giường 1, 2, 4 trước và sau khi lật; ba chỗ tìm giả; cửa nhìn từ trong phòng ở mức hỏng 0, 30, 60, 80 %. Chụp thêm phòng 407 ở chương 3 (một ảnh thấy ô thông gió và tấm trần) và chương 1 (cùng góc, để thấy khác nhau).
   - **Từng vạt:** tấm ván nằm ở đâu so với giát của giường Tripo và nệm; trên mỗi giường có những món nào (tên trong `placements.json`); khi lật thì xuyên qua món nào. Đọc `ch4_form.gd` và hình mảnh phiếu của UI, để chữ trên vạt khớp với mảnh phiếu người chơi nhận.
   - **Tay xác:** xác sống trong chương 4 dùng hình gì (`scenes/entity/zombie.tscn` và các thân của nó); bàn tay thò qua cửa nên lấy từ đâu cho cùng kiểu.
   - **Bệnh viện:** chụp đúng khung `Camera_Wake` qua `director._show_hospital()` ở **cả hai kết**, ở độ sáng 1,0 và 1,45; vẽ sơ đồ phòng nhìn từ trên có hình nón nhìn của camera; liệt kê vật trong khung, ngoài khung.
2. **Hình mẫu** (Blender, chất lượng ngang các đợt trước; ảnh cùng camera trong cảnh thật):
   - **407:** giường 2 (tầng dưới, gần mắt nhất) với vạt mới, trước và sau khi lật, thấy chữ ở mặt dưới; ô thông gió; tấm trần; cửa ở ba mức hỏng nhìn từ trong phòng.
   - **Bệnh viện:** đây là cảnh một camera, nên hình mẫu là **khung hình kết**: trần, tường chân giường, chăn và thẻ của Trung, chân hai giường bên; ở cả hai kết, độ sáng 1,0 và 1,45. Kèm một ảnh nhìn từ góc phòng để thấy cả ba giường.
3. **Phương án để chủ dự án chọn bằng mắt** (mỗi phương án ghi số tam giác, vật liệu, số lần vẽ; đề xuất một):
   - **Phòng 407:**
     - **Vạt giường là gì:** (V1) một tấm ván ép liền như nay; (V2) giát gỗ nhiều nan đóng trên hai thanh dọc, kiểu giường tầng ký túc xá, chữ viết vắt qua các nan.
     - **Nệm, chăn, gối khi lật** (hiện ván quay xuyên qua chúng): (N1) bị hất dồn về phía tường, nằm lại trong lòng giường, dựng nghiêng theo ván; (N2) rơi xuống sàn cạnh giường. Chỉ là hình thì người chơi đi xuyên qua; có va chạm thì có thể chặn lối trong lúc cửa đang bị phá. Ghi rõ từng cách, có ảnh; N2 có va chạm là đổi gameplay, chỉ làm khi chủ dự án chọn.
     - **Chữ ở mặt dưới:** mực loang, bút bi đè nhiều lần, hay khắc bằng vật nhọn; **ba vạt ba hình khác nhau**, khớp ba mảnh phiếu của UI; đọc được vài chữ ở 1 m dưới đèn pin, không cần đọc hết (UI mới là chỗ đọc).
     - **Trần:** nắp thăm trần bằng tôn sơn trắng có khung, hay một tấm trần lệch; **ô thông gió:** cửa chớp tôn sơn có lưới, bám bụi. Giữ đúng chỗ marker.
     - **Phản hồi khi tìm xong ba chỗ giả** (hiện không có gì thay đổi): nắp trần hé, chớp thông gió lệch, cánh tủ mở; hay giữ nguyên. Nếu làm: script hình của lane B nghe tín hiệu `searched` của node `Search*` con của marker; không sửa core.
     - **Nhất quán bốn chương:** ô thông gió và tấm trần hiện chỉ có ở chương 3–4. (C1) giữ như vậy; (C2) cho chúng có ở cả bốn chương (đưa hình vào phòng 407 gốc; integrator duyệt cách làm). Ghi thiệt hơn.
     - **Cửa bị phá:** ba mức. Nứt: vết nứt trên cánh cửa thật. Thủng: cánh gãy có lỗ, mảnh gỗ toác, thấy hành lang qua lỗ. Tay thò: tay xác cùng kiểu xác sống đang có. Nhìn từ trong phòng là chính; nhìn từ hành lang không được hở, không lơ lửng.
   - **Bệnh viện:**
     - **Hai y tá** (câu quan trọng nhất): (Y1) **rèm quây giường** kéo ngang chân giường, tiếng phát sau rèm, bóng mờ hai người in trên rèm (hình trong shader hoặc lưới phẳng, không thêm đèn); (Y2) dời chỗ phát tiếng ra ngoài khung, ví dụ cửa phòng mở hé ở tường chân giường, tiếng vọng từ cửa; (Y3) giữ như nay, y tá không có hình; (Y4) y tá có hình thật: là nhân vật, phải làm trên Tripo như quản lý, **không làm trong đợt này**, chỉ ghi chỗ đứng. Dựng ảnh mẫu cho Y1 và Y2.
     - **Khung hình:** (K1) giữ `Camera_Wake` như nay; (K2) hạ góc ngước từ 24° xuống khoảng 10–12°, để chân hai giường bên và thẻ tên vào khung rõ hơn, bớt trần. Chụp cả hai. Camera chuyển động (chớp mắt, quay đầu) là việc của director: không làm, thấy cần thì ghi đề xuất.
     - **Vỏ phòng** (phòng bệnh công, sáng dịu, D-166): tường sơn hai màu (chân tường xanh nhạt, trên trắng ngà) hay ốp gạch men chân tường; sàn gạch ceramic hay đá mài; trần thạch cao tấm 60 × 60 hay trần bê tông có quạt trần; đèn là máng tuýp đúng chỗ `CeilingLight`.
     - **Giường:** giường inox bệnh viện công, nệm bọc xanh, ga trắng; chăn mỏng kẻ hay chăn xanh nhạt.
     - **Trung trên giường** (góc nhìn thứ nhất): (T1) chăn có dáng thân và hai chân, một cẳng tay quấn băng đặt trên chăn có dây truyền chạy ra cây truyền; (T2) chỉ chăn có dáng người.
     - **Nhật và Ngư** (kết thật; chỉ thấy phần chân giường): dáng người dưới chăn, không lộ mặt. **Kết một mình:** hai giường trống, ga phẳng, hay nệm cuộn lại.
     - **Thẻ tên:** khung kẹp thẻ ở chân giường, khớp marker `Card` (thẻ là UI của lane D, giữ nguyên).
     - **Thứ ngoài khung** (máy theo dõi, tủ, cây truyền, cửa sổ): dựng mức vừa, đúng chỗ cũ, không tốn công chi tiết.
4. Commit, push nhánh, ghi Handoff, **báo và dừng**. Integrator chuyển phương án cho chủ dự án, ghi lựa chọn vào mục 1.

### Lượt 2 — cả hai khu (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
5. **Phòng 407:** ba vạt (hình, chữ, nệm chăn gối theo cách đã chọn), tấm trần, ô thông gió, phản hồi tìm kiếm nếu chọn, cửa bị phá ba mức.
6. **Bệnh viện:** vỏ phòng, ba giường, người trên giường theo hai kết, cách xử lý y tá đã chọn, khung hình đã chọn, thứ ngoài khung.
7. Ảnh trước/sau, ảnh ghép, test, README, CREDITS, Handoff; **báo và dừng**.

## 3. Phạm vi
- **Trong đợt:** nhánh `Room407` của `ch4_anchors.tscn`; `slat_visual.gd`, `door407_proxy.gd` (chỉ phần hình); `hospital_room.tscn`, `hospital_room.gd`.
- **Không đụng:**
  - phòng 407 gốc (`room_407.tscn`, `room407.gd`, `Room407Furnish`, `game/data/room407/`, đồ Tripo), trừ hai việc: đọc `Room407.furnished_prop(tên)` để dời nệm, chăn, gối của ba giường lúc lật (trả lại khi thoát, như mùng hiện nay); và C2 (D-187, mục 1 điểm 5): chỉ thêm hình ô thông gió và nắp trần theo một trong hai đường đã nêu;
  - mọi node khác trong `ch4_anchors.tscn` (`Start_*`, anchor thư viện, `LibraryZombieSpawn`, `StairCrowd`): không đổi một dòng;
  - thư viện, khuôn viên, tầng 4 ngoài phòng 407; CCTV và chi tiết nhỏ phòng 407 (đợt 10).
- Chương 1–2: phòng 407 chỉ thêm ô thông gió và nắp trần (C2); mọi thứ khác không đổi hình.
- **Ngoại lệ UI (D-187, mục 1 điểm 11):** thẻ tên bệnh viện `game/ui/ch4/bed_card.tscn`, `game/scripts/ui/ch4_bed_card.gd`.

## 4. Hợp đồng gameplay (bắt buộc giữ)
- **Phòng 407:**
  - `Slat1`, `Slat2`, `Slat4`: tên, vị trí, `slat_visual.gd` với `bed`, `flipped`, `set_flipped()`; con `Hinge` còn tên và vẫn quay quanh z hơn 1 rad khi lật (test); lật mất không quá 0,6 giây; mùng vẫn ẩn khi lật và trả lại khi thoát.
  - Vùng dùng tay `BedSlat<n>` của director gắn dưới marker: hình mới không che tia tới nó (`test_chapter4` bắn tia từ bốn phía ở 0,8 và 1,2 m).
  - `FakeLocker`, `FakeCeiling`, `FakeVent`: tên, vị trí. Không chỗ nào trở thành chỗ có đồ.
  - `Door`: API `room`, `is_open`, `set_open()`, `blocker`, `damage_fraction`, `set_damage_fraction()`, nhóm `room_doors`; `Blocker` giữ hộp va chạm; `Damage/Cracks`, `Damage/Hole`, `Damage/Hand` còn tên và hiện đúng ở 0,3 / 0,6 / 0,8; cánh gốc ẩn từ 0,6 và trả lại khi thoát; va chạm của cánh gốc trả lại khi thoát.
  - Không thêm va chạm trong phòng (D-187: N2 không va chạm).
  - Không bày sẵn lời giải: trước khi lật, không thấy chữ; ba chỗ giả không trông "có đồ" hơn ba giường.
- **Bệnh viện:**
  - Giữ tên và kiểu node: `HospitalRoom`, `Bed_Trung`, `Bed_Nhat`, `Bed_Ngu` và con `Card` (vị trí giữ, trừ khi khung kẹp thẻ cần lệch vài cm: ghi số), `Bed_*/Patient`, `Nurse1`, `Nurse2`, `MonitorAudio`, `Camera_Wake`, `Environment`, `CeilingLight` và `LightHum`, `West/Mesh`; `set_companions_visible()`.
  - `Nurse1`, `Nurse2`, `Camera_Wake`: chỉ đổi vị trí hoặc góc theo phương án Y, K chủ dự án chọn.
  - Ánh sáng theo D-167: không thêm đèn, không đổi `Environment` và `CeilingLight` ngoài giới hạn của `test_hospital_light`. Ở độ sáng 1,45 không vùng nào cháy trắng.
  - Kết thật thấy được hai giường bên có người và thẻ tên; kết một mình thấy hai giường trống.
- Hình PS1 chỉ ẩn (`visible = false`), không xoá node; hình mới đặt dưới node con mới (ví dụ `Real`).
- Không đổi luật, lời thoại, director, âm thanh, UI (trừ thẻ tên, mục 1 điểm 11).

## 5. Kỹ thuật và hiệu năng
- Script Blender (Blender 5.2.2 ở `D:\Tools\Blender\5.2.2`) như các đợt trước; nguồn mesh, texture **CC0** ghi URL, tác giả, giấy phép trong CREDITS. **Không extension Blender, không Tripo, không ảnh AI.** Chữ dùng font có sẵn trong game hoặc vẽ bằng script.
- Dùng lại vật liệu đã duyệt (gỗ, thép, inox, gạch ceramic, trần thạch cao, tường sơn của đợt 1–8) trước khi thêm vật liệu mới.
- **Ngưỡng tam giác của test T-196** (`test_ch4_environment`): hình mới vẫn đếm dưới `Room407/Door`, `Room407/Slat<n>`, `Bed_*`. Được nâng ba ngưỡng này lên con số thật cộng khoảng dư, có comment lý do, nhưng không quá: mỗi `Slat` 1.500, `Door` 4.000, mỗi `Bed_*` 8.000. Cả phòng bệnh viện không quá 80.000 tam giác.
- Ngân sách (PLAN mục 6): 407 **≤ 0,15 ms**, bệnh viện **≤ 0,50 ms**. Ghi số tam giác, vật liệu, **số lần vẽ trước/sau cùng camera** ở: phòng 407 từ cửa (chưa lật và đã lật cả ba, cửa hỏng 80 %), và khung `Camera_Wake` ở hai kết.
- **Mọi texture mới từ 512 px trở lên phải nén VRAM** trong `.import` (`compress/mode=2`; normal thêm `compress/normal_map=1`); có test. Ghi bộ nhớ hình chương 4 trước/sau.
- Không đo FPS, không chạy bot (D-179, D-184).

## 6. Ảnh
- `art_source/graphics_upgrade/realistic_map/previews/wave9/`: lượt 1 `survey_*`, `pilot_*`, `options_*.jpg`, sơ đồ `plan_hospital.jpg`; lượt 2 `before_*`/`after_*` cùng camera trong chương 4 thật, ảnh ghép `overview.jpg`. Ảnh bệnh viện luôn có cả độ sáng 1,0 và 1,45, cả hai kết.

## 7. Kiểm
- Test mới `game/tests/levels/test_t266_*.gd`:
  - nhánh `Room407` của `ch4_anchors.tscn`: marker, `Blocker`, script còn như main; phần còn lại của file trùng main từng dòng;
  - lật từng vạt: hình quay, góc của giường 2 không đâm tầng trên, mùng ẩn, nệm chăn gối đi đúng chỗ đã chọn và trả lại khi thoát; chưa lật thì mặt chữ không lộ ra phía phòng;
  - N2 (D-187 mục 1 điểm 3): lật bunk A theo cả hai thứ tự (1 rồi 2, 2 rồi 1), đồ của hai giường không chồng xuyên nhau, nằm trên sàn; camera ở các chỗ dùng tay không nằm trong món nào;
  - phản hồi khi tìm: sau tín hiệu `searched`, chớp và nắp đổi tư thế, trả lại khi thoát;
  - C2: ô thông gió và nắp trần hiện ở phòng 407 chương 1 và chương 4; ở chương 3–4 hình PS1 `CeilingPanel`, `VentFrame`, `VentSlat*` đã ẩn (không vẽ hai lần);
  - cửa: ba lớp hư hại hiện đúng mức; ở mức 60 % trở lên không còn hình nào của cánh nguyên (`Pivot/RoomDoor`, `Pivot/Leaf`, bốn hộp `Damage/Hole`); thoát thì trả lại;
  - bệnh viện: node hợp đồng còn đủ; hai kết bật/tắt đúng; khung `Camera_Wake` thấy thẻ của Trung (điểm `Card` nằm trong khung); không lưới nào của phòng nằm giữa mắt và thẻ;
  - thẻ tên: ở kết thật, mặt có chữ của thẻ Nhật và thẻ Ngư hướng về `Camera_Wake`, không lưới nào chắn giữa camera và thẻ, chữ mặt sau giống mặt trước; giấy không còn là vật liệu không chịu sáng;
  - mọi `.import` texture trong thư mục asset đợt 9 nén VRAM.
- Test cũ đạt: `test_ch4_environment`, `test_chapter4`, `test_chapter4_data`, `test_ch4_gameplay`, `test_ch2_4_hand_targets`, `test_room_doors`, `test_hospital_light`, `test_ch4_ui`, `test_ch4_audio`, `test_ch4_menu`, `test_chapter3`, `test_t260_occlusion`, `test_t265*`; vì C2 thêm cả test phòng 407 chương 1–2: `test_room407_*`, `test_floor4`, `test_chapter1`, `test_chapter2`, `test_ch1_*`, `test_ch2_props`, `test_graphics_bindings`. Được sửa: ba ngưỡng tam giác nêu ở mục 5; không nới kiểm tra khác.
- **Lane B chỉ chạy test lọc** (`pwsh tools/test.ps1 -Filter t266`, `-Filter ch4`, `-Filter chapter4`, `-Filter hospital`, `-Filter room_doors`, `-Filter hand_targets`, `-Filter room407`, `-Filter floor4`, `-Filter chapter1`, `-Filter chapter2`, `-Filter ch1_`, `-Filter ch2_props`, `-Filter graphics_bindings`, `-Filter ch4_ui`), rồi `git checkout -- game/default_bus_layout.tres`. **Không chạy full test, không chạy check**: máy thiếu RAM; integrator chạy một lần khi merge, lúc chủ dự án đã tắt RAV và Chrome. Lượt bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.

## 8. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave9/`, `.../previews/wave9/`, `game/assets/models/graphics_pilot/realistic_map/wave9/`, `game/assets/textures/graphics_pilot/realistic_map/wave9/`;
- `game/scenes/levels/ch4/ch4_anchors.tscn` (chỉ nhánh `Room407`), `slat_visual.gd`, `door407_proxy.gd`, script hình mới trong `game/scenes/levels/ch4/`;
- `game/scenes/levels/hospital/hospital_room.tscn`, `hospital_room.gd`, script hình mới trong thư mục đó;
- C2 (D-187 mục 1 điểm 5): `game/scenes/levels/room407/room_407.tscn` (chỉ thêm node hình mới) và `room407.gd` (chỉ thêm đường dẫn vào `KEEP_PS1`), hoặc thêm một dòng vào `game/data/room407/placements.json` qua `Room407Furnish`;
- thẻ tên (D-187 mục 1 điểm 11): `game/ui/ch4/bed_card.tscn`, `game/scripts/ui/ch4_bed_card.gd`;
- test mới và ba ngưỡng ở mục 5 trong `game/tests/levels/`; card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi director (`game/scripts/core/`), `bed_slat`, `search_spot`, UI khác ngoài thẻ tên (`game/ui/`, `game/scripts/ui/`), âm thanh, luật, lời thoại, `room_door.gd`, `chapter*.tscn`, `game/scenes/main/`, `project.godot`, phòng 407 gốc (ngoài mục 3).
- Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Lượt 1: khảo sát hai khu, bảng hợp đồng, ảnh hiện trạng (407 ở chương 1, 3, 4; khung kết ở hai kết, hai độ sáng), sơ đồ phòng bệnh
- [ ] Lượt 1: hình mẫu và phương án; dừng chờ chủ dự án chọn
- [ ] Lượt 2: phòng 407 (ba vạt, trần, thông gió, cửa bị phá)
- [ ] Lượt 2: bệnh viện (vỏ, giường, người, y tá, khung hình)
- [ ] Lượt 2: ảnh trước/sau, `overview.jpg`, test lọc, README, CREDITS, Handoff

## Handoff
*(Lane B ghi: đã làm, còn dở, cách kiểm, dòng RESULT test, commit, yêu cầu thay đổi, phần chưa kiểm.)*
