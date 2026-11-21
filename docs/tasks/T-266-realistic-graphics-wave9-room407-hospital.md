# T-266 — Đồ hoạ thật đợt 9: phòng 407 ở chương 4 (vạt giường, ba chỗ tìm giả, cửa bị phá) và phòng bệnh viện của đoạn kết
- Lane: B | Trạng thái: **done, merged 21/11 `4a56e72f`, cộng commit sửa `44843bfa` của integrator; full test 1088/0, check 0; bản chơi `44843bfa`** (card viết 20/11/2026, sau khi T-265 merge) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`. Chủ dự án tự dán prompt (`lane-b.md` mục 1t).
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
- [x] Lượt 1: khảo sát hai khu, bảng hợp đồng, ảnh hiện trạng (407 ở chương 1, 3, 4; khung kết ở hai kết, hai độ sáng), sơ đồ phòng bệnh
- [x] Lượt 1: hình mẫu và phương án; dừng chờ chủ dự án chọn
- [x] Lượt 2: phòng 407 (ba vạt, trần, thông gió, cửa bị phá)
- [x] Lượt 2: bệnh viện (vỏ, giường, người, y tá, khung hình)
- [x] Lượt 2: ảnh trước/sau, `overview.jpg`, test lọc, README, CREDITS, Handoff

## Review integrator, lượt 2 và merge (21/11/2026)
- **Đạt, merged** `4a56e72f` (no-ff từ nhánh `252f6fe`), cộng commit sửa `44843bfa` của integrator (dưới đây).
- **Phạm vi:**
  - lane B chỉ sửa file trong mục 8;
  - card ghi nhầm đường dẫn `levels/room407/room_407.tscn` (lỗi của integrator); lane B sửa đúng file `scenes/levels/floor4/room_407.tscn`;
  - hình PS1 chỉ ẩn: 31 dòng `visible = false` đều nằm trong nhánh `Room407`; hình mới ở `Real`, `Empty`, `Wave9Fixtures`, `SearchFeedback`;
  - `test_ch4_environment` nâng hai ngưỡng, vẫn trong giới hạn mục 5: `Door` 3.600 (giới hạn 4.000), `Bed_*` 4.000 (giới hạn 8.000).
- **Đúng D-187:**
  - vạt V2b: giường 2 lật 62°, giường 1 và 4 lật 70°, xong ở 0,5 s;
  - N2 không va chạm: lật theo thứ tự 1-2-4 hay 2-1-4 đều ra cùng chỗ, thoát thì trả lại;
  - C2 theo đường (a): node `Wave9Fixtures` thêm vào `KEEP_PS1`;
  - phản hồi khi tìm: script nghe `EventBus.interacted`, vì chỗ tìm giả không phát `searched`. Integrator đã kiểm: `HoldInteractable._finish()` phát tín hiệu này lúc giữ xong;
  - cửa: từ 60 % ẩn cả `RoomDoor` và `Leaf`, thoát thì trả lại;
  - `Camera_Wake` ngước 11°;
  - thẻ tên có chữ hai mặt (`NameBack`, `DetailsBack`), API giữ nguyên;
  - kết một mình hiện `Empty`.
- **Ảnh đã xem:** `overview.jpg`, `compare_407_bedding.jpg`, `compare_ward_detail.jpg`. Đọc được "Lý Minh Nhật" và "Khương Ngọc Ngư"; ở độ sáng 1,45 không cháy trắng.
- **Chấp nhận hai chỗ khác card**, vì N2 không có va chạm nên không chặn đường:
  - nệm giường 2 nằm giữa phòng, trước đầu chiếu;
  - khi nhấc lên, nệm tầng trên lướt qua thanh chắn phía tường trong 0,5 s, bị chính tấm nệm che.
  Nếu chủ dự án chơi thử thấy chướng thì đổi bảng `LANDING`.
- **Integrator sửa khi merge (`44843bfa`):**
  - **Lỗi ép kiểu:** `slat_visual.gd` ép kiểu nệm, chăn, gối `as Node3D` trước khi kiểm còn hợp lệ. Khi cảnh có ch4_anchors bị giải phóng, đồ của phòng có thể bị giải phóng trước, nên `_exit_tree` báo "Trying to cast a freed object". Hệ quả: `test_t250` thoát 1 dù cả 5 test đều đạt. Đã sửa ba vòng lặp để kiểm trước khi ép kiểu; `_exit_tree` của `search_feedback.gd` cũng được chặn như vậy.
  - **Dấu vân tay khuôn viên:** hằng `CAMPUS_CONTRACT_MD5` trong sáu test (t259, t261, t262, t263, t264 ×2) đổi sang `ff7c018d` (1096 dòng). Lý do: T-266 thêm 17 dòng hình dưới `Anchors/Ch4/Room407`. Một probe bỏ 17 dòng đó ra thì được đúng `2d7e21ae` cũ trên 1079 dòng, tức anchor, vùng và navigation không đổi. Lane B không thấy lỗi này vì các test đó nằm ngoài các bộ lọc ở mục 7.
- **Kiểm:**
  - Full test chạy nền lần đầu bị Claude Code dừng vì máy thiếu RAM (21/11 02:09 đến khoảng 02:40, không có kết quả).
  - Chủ dự án bảo chạy lại. Integrator chạy trực tiếp từng phần theo thư mục test, mỗi phần dưới 10 phút; sau khi sửa thì chạy lại `t250`, `t259` và hai test chương 4.
  - Kết quả: **1088 passed, 0 failed** (core 196, levels 315, player 266, audio 131, ui 126, tools 53, smoke 1), gồm cả sáu bộ lọc lane B chưa chạy được.
  - Check: **0 lỗi** (21/11 14:12; cho chạy nền, phiên giữ bận bằng lệnh chờ chạy trực tiếp).
  - Log ở `build/integrator/T266m_*.log`.
- **Bản chơi:** package PASS 21/11 14:17. File `build/windows/KyTucXa.exe`, zip `build/dist/KyTucXa-0.0.1-44843bfa-win64.zip` (546 MiB); có đồ hoạ đợt 1–9.

## Handoff

### Lượt 2 (lane B, 20–21/11/2026; card đọc ở `d72adcc`, D-187) — xong, DỪNG chờ review (6 lọc chưa chạy vì thiếu RAM, mục 4)
Làm đúng mục 1 (D-187). Hình PS1 chỉ ẩn (`visible = false`), node, va chạm, marker giữ; hình mới ở node con `Real` (hoặc
`Empty`, `Wave9Fixtures`, `SearchFeedback`). Chi tiết, bảng glb, tam giác, vật liệu: `art_source/graphics_upgrade/realistic_map/wave9/README.md`.

**Xem trước:** `previews/wave9/overview.jpg`, `compare_407_room.jpg`, `compare_407_bedding.jpg`, `compare_407_fall.jpg`,
`compare_407_slats.jpg`, `compare_407_spots.jpg`, `compare_407_door.jpg`, `compare_407_corridor.jpg`, `compare_ch1.jpg`,
`compare_ward.jpg`, `compare_ward_detail.jpg` (ảnh lẻ `before_*`, `after_*`).

#### 1. Đã làm
- **Phòng 407, chương 4** (`ch4_anchors.tscn`, chỉ nhánh `Room407`; phần ngoài nhánh trùng main từng dòng, test so md5):
  - Vạt **V2b** cả ba giường, chữ **mực loang** ba mảnh đúng mảnh phiếu UI; góc lật riêng (`slat_visual.gd`, `ANGLES`): giường 1, 4
    70°, giường 2 62° (đỉnh vạt dưới mặt dưới tầng trên 1,075 m). Vạt trễ 0,08 s, quay 0,42 s: xong ở 0,5 s (≤ 0,6).
  - **N2 không va chạm**: nệm, chăn, gối Tripo của giường bay theo đường riêng trong 0,55 s (cùng lúc vạt quay), nằm ở chỗ riêng,
    trả về khi `set_flipped(false)` và khi thoát. Sàn trước giường tầng A chỉ rộng 1,36 m (giữa giường và chiếu, có ổ cắm nối dài
    và bàn học ở hai đầu): đủ cho **một** tấm nệm. Nên: đồ **giường 1** (tầng trên) rơi xuống đúng khoảng sàn trước giường tầng A,
    gối và chăn gấp nằm trên nệm của chính nó; **nệm giường 2** (tầng dưới) bị đẩy ra thấp, nằm ngang trước đầu chiếu (cách cung
    mở cửa 0,17 m), chăn trên nệm, gối bên cạnh; **giường 4** như giường 1, trước giường tầng B. Thứ tự lật nào cũng vậy (vị trí
    cố định, test 1-2-4 và 2-1-4). Đồ tầng trên trượt qua mép thanh chắn rồi chúc xuống sát thành giường (trong 0,2 m), rơi đứng rồi
    đổ ra, nên không bay qua chỗ mắt người chơi đứng hay ngồi lật vạt; đồ tầng dưới đi dưới 1,0 m.
  - **Nắp trần H1, cửa chớp thông gió (C2)**: thêm vào phòng 407 gốc theo **đường (a)**: node `Wave9Fixtures` trong
    `scenes/levels/floor4/room_407.tscn` (card ghi `levels/room407/`, file thật ở `floor4/`) và `"Wave9Fixtures"` thêm vào `KEEP_PS1`
    của `room407.gd`. Có ở cả bốn chương, chỉ là hình. Ở chương 3–4 ẩn `CeilingPanel`, `VentFrame`, `VentSlat0…5`. Nắp hở quạt trần
    hơn 10 cm cả khi mở.
  - **Phản hồi khi tìm xong** (`Room407/SearchFeedback`, script mới `search_feedback.gd`): nắp hé 28° trên bản lề, chớp treo lệch
    26° từ vít góc trên (rơi theo trọng lực; lượt 1 xoay ngược), trả lại khi thoát. Tủ Phúc giữ nguyên.
  - **Cửa bị phá** (`door407_proxy.gd`, phần hình): ba lớp mới đặt đúng transform của cánh Tripo `Door407/Pivot/RoomDoor`; 30 % nứt
    toác trên cánh thật, 60 % cánh vỡ có lỗ, dằm gỗ, thấy hành lang; 80 % tay xác (tay áo hoodie xám rách, da tái). Từ 60 % ẩn cả
    `RoomDoor` và `Pivot/Leaf`, bốn hộp `Damage/Hole` ẩn (giữ node); trả lại khi thoát. Lỗi hình của main (hư hại nằm sau cánh
    Tripo) đã hết (`compare_407_door.jpg`).
- **Phòng bệnh** (`hospital_room.tscn/.gd`): vỏ hai màu, sàn ceramic, trần 60 × 60, máng đèn ở `CeilingLight`; giường inox, nệm bọc
  xanh, ga, chăn kẻ; **Trung T1**; **Nhật, Ngư** dưới chăn, không lộ mặt; **kết một mình** ga phẳng, chăn gấp (`Empty`,
  `set_companions_visible` bật ngược với `Patient`); **Y1** rèm quây ở z 1,5 với bóng hai người đứng yên (một người cầm bệnh án),
  `Nurse1/2` giữ chỗ cũ, đúng sau hai bóng; **K2** `Camera_Wake` ngước 11°, vị trí và FOV giữ. Không thêm đèn.
- **Thẻ tên** (ngoại lệ UI, `ui/ch4/bed_card.tscn`, `scripts/ui/ch4_bed_card.gd`): giấy chịu sáng, tối hơn (0,70), chữ hai mặt
  (`NameBack`, `DetailsBack`, cùng chữ, không ngược), API giữ. Từ `Camera_Wake` đọc được "Khương Ngọc Ngư", "Trần Trung",
  "Lý Minh Nhật" ở 1,0 và 1,45, không cháy trắng (`compare_ward_detail.jpg`). Khung kẹp thẻ là một phần của `ward_bed.glb`, đúng marker
  `Card` (marker không dời).
- Test: `test_t266_room407.gd`, `test_t266_ward.gd`, `test_t266_assets.gd` (thay `test_t266_pilot.gd`, đã xoá). Nâng hai ngưỡng của
  `test_ch4_environment` có comment: `Room407/Door` 500 → 3.600 (thật 3.206), `Bed_*` 1.500 → 4.000 (thật 3.270 / 3.304); `Slat` giữ
  500 (thật 362).
- Asset: 16 glb, 11 texture (nén VRAM), vật liệu mới `W9SlatUnder1/2/4`, `W9Hoodie`, `W9VentPaint`; xoá 10 glb hình mẫu và 3 texture
  chữ không dùng (dựng lại được bằng script lượt 1). CREDITS (texture đợt 9, models chung) cập nhật; không nguồn ngoài mới.

#### 2. Số đo (không đo FPS)
| Chỗ (cùng camera) | Trước (hình main) | Sau |
|---|---|---|
| Phòng 407 từ cửa, chưa lật | 3.729 lần vẽ | 3.762 (+33) |
| Phòng 407 từ cửa, lật cả ba, cửa 80 % | 3.719 | 3.776 (+57) |
| Phòng bệnh, `Camera_Wake`, kết thật / một mình | 27 / 21 (main, K1) | 42 / 34 (K2) |
| Bộ nhớ hình chương 4 | 1.301 MB (main) | 1.310 MB (phòng 407), 1.313 MB (phòng bệnh) |
Tam giác: mỗi `Slat` 362, `Door` 3.206, `Bed_Trung` 3.270, `Bed_Nhat`/`Bed_Ngu` 3.304, cả phòng bệnh 13.424 (< 80.000).

#### 3. Ghi thật, cần integrator biết
- **`searched` không bao giờ phát ở ba chỗ tìm giả**: `fake_search_spot.tscn` đặt `empty_result = true`, và `search_spot.gd`
  chỉ phát `searched` khi `not empty_result`. Script hình nghe thêm `EventBus.interacted` (mọi lần giữ E xong, `HoldInteractable._finish()`)
  của `Search<spot>` dưới marker, vẫn nối `searched` nếu sau này có. Không sửa core, lane A.
- **Không có đường rơi cứng nào sạch hoàn toàn với nệm Tripo**: nệm 0,80 m nằm sẵn dưới cả hai thanh chắn tầng trên (khe 0,70 m)
  và lấn 5 cm vào cột ở hai đầu ngay lúc nằm yên. Đường đã chọn sạch về phía phòng (thanh, cột phía phòng; test hộp xoay 201 mốc);
  khi nhấc, mép phía tường của nệm tầng trên đi qua thanh chắn phía tường (chính tấm nệm che); nệm giường 2 (1,90 m, giữa hai cột
  1,80 m) nghiêng 18,8° và còn lướt 8 mm mặt trong hai cột.
- **Chỗ nằm của nệm giường 2** ở giữa phòng (trước đầu chiếu), không "cạnh giường", vì trước giường tầng A chỉ đủ một tấm. Nếu chủ
  dự án muốn khác (ví dụ nệm giường 2 dựng tựa bàn học), chỉ cần đổi `LANDING` và đường bay trong `slat_visual.gd`.
- Từ hành lang lúc 80 %: bốn xác thật (tự đi tới sau 17,5 s, dừng 0,75–1,26 m từ giữa cửa) đứng che kín lỗ và tay
  (`compare_407_corridor.jpg`); không thấy tay lơ lửng hay cánh hở. Tờ nội quy phía hành lang (`Pivot/RulesPaper`, floor4) vẫn lệch
  4 cm khỏi mặt cánh Tripo như main: ngoài phạm vi, chưa sửa.
- Tổng số lần vẽ trôi theo thời gian trong một lượt chạy: số trên đo trước/sau liền nhau hai lần (`wave9/survey/capture_r2.txt`).

#### 4. Kiểm
Chạy các lọc của mục 7 liền nhau trong một lượt (21/11, 23:52), rồi `git checkout -- game/default_bus_layout.tres`:
- `-Filter t266`: `RESULT: 15 passed, 0 failed`
- `-Filter ch4`: `RESULT: 55 passed, 0 failed` (gồm `test_ch4_environment`, `test_ch4_ui`, `test_ch4_gameplay`, `test_ch4_audio`,
  `test_ch4_menu`, `test_ch4_voices_calls`)
- `-Filter chapter4`: `RESULT: 15 passed, 0 failed`
- `-Filter hospital`: `RESULT: 1 passed, 0 failed`
- `-Filter room_doors`: `RESULT: 4 passed, 0 failed`
- `-Filter hand_targets`: `RESULT: 6 passed, 0 failed`
- `-Filter room407`: `RESULT: 83 passed, 0 failed`
- **Bị dừng vì máy thiếu RAM** (Claude Code tự dừng lượt chạy nền khi máy cạn bộ nhớ, đang ở `-Filter floor4`), **không tự chạy lại**
  theo prompt: **chưa chạy** `floor4`, `chapter1`, `chapter2`, `ch1_`, `ch2_props`, `graphics_bindings`; `ch4_ui` đã nằm trong
  lọc `ch4` ở trên. Khoá `GODOT_DANG_CHAY.txt` của lượt này đã gỡ, không còn tiến trình Godot.
- Không chạy full test, không chạy check (card mục 7). Không bot, không đo FPS.
- Commit: `eddc170`, `7fbcd60` (WIP), commit cuối "T-266: round 2 …" (hash ở `git log`).
- Yêu cầu thay đổi ngoài phạm vi: không. (Gợi ý cho lane A, không bắt buộc: nếu muốn phản hồi khi tìm nghe đúng `searched`, cho
  chỗ tìm giả phát `searched` mà không mở tài liệu; hiện script hình đã tự nghe `EventBus.interacted`.)

### Lượt 1 (lane B, 20/11/2026; card đọc ở `81b17b3`) — xong, DỪNG chờ chủ dự án chọn
Không sửa cảnh, script hay test cũ nào. Mới: `art_source/graphics_upgrade/realistic_map/wave9/` (script khảo sát, chụp,
Blender, texture, vật liệu, sơ đồ, tờ ghép, `README.md`), ảnh `previews/wave9/`, hình mẫu
`game/assets/models|textures/graphics_pilot/realistic_map/wave9/` (22 glb, 14 texture nén VRAM, 30 vật liệu `W9*`, CREDITS),
`game/tests/levels/test_t266_pilot.gd`. Hình mẫu chỉ gắn vào cảnh lúc chụp (`capture_wave9_pilot.gd`), chưa vào game.

**Xem trước:** `previews/wave9/options_slat.jpg`, `options_bedding.jpg`, `options_ink.jpg`, `options_ink_beds.jpg`,
`options_vent_hatch.jpg`, `options_door.jpg`, `options_chapters.jpg`, `options_ward_nurse.jpg`, `options_ward_frame.jpg`,
`options_ward_patient.jpg`, `plan_hospital.jpg`, `survey_sheet_407.jpg`, `survey_sheet_ward.jpg`.

#### 1. Khảo sát (kiểm lại mục 0)
- **Phòng 407 ở chương 4 thật** (`run_from(&"room407")`, không bot; người chơi giữ lại và ẩn, bốn xác ở hành lang bị gỡ để
  không ai phá cửa): **tối**. Đèn tuýp `Room407MainLight` tắt (năng lượng 0, ẩn), còn đèn bàn 0,5, `WindowBlue` 0,2,
  `DoorGapLight` 0,22, `BathLight` 0,06; môi trường trong phòng ánh sáng nền 0,015 (room407.gd); nắng `Campus/Dawn` 0,65 không
  vào tới trong. Cần đèn pin; mọi ảnh trong phòng chụp bằng đèn pin của camera (như đèn điện thoại).
- **Mục 0 lệch so với đếm thật:** nhánh `Room407` 414 tam giác (card ghi 174; `Door` 204, mỗi `Slat` 26), phòng bệnh 828
  (card 758), mỗi `Bed_*` 132.
- **Vạt PS1:** tấm ván nằm ở y 0,392…0,428, tức **trong** nệm Tripo 4,9 cm (0,38…0,429), trên sàn giát Tripo (đỉnh 0,385).
  Lật thì xuyên qua nệm, chăn, gối. **Giường 2 (tầng dưới):** ván 0,86 m quay 70° lên tới y 1,22, **đâm qua tầng trên**
  (mặt dưới tầng trên 1,075): `survey_407_bed2_low_after_torch.jpg`.
- **Đồ trên giường** (tên trong `placements.json`): giường 1 `MattressPhuc`, `BlanketPhuc` (gấp), `PillowPhuc` (ba món này đi
  theo `Anchors/PhucMattress/Pivot`), `NetPhuc`, `TowelBunkA`; giường 2 `MattressViet`, `BlanketViet` (nhàu), `PillowViet`,
  `NetViet`, dưới gầm `Suitcase`, `FootballPhuc`; giường 4 `MattressDat`, `BlanketDat` (gấp), `PillowDat`, `NetDat`.
  Bảng đủ: `wave9/survey/room407_bed_props.tsv`.
- **Mảnh phiếu UI** (`ch4_form.gd`): giường 1 "Phiếu điều tra…" + Giới tính, Tuổi; giường 2 "…người sống sót…" + Ngày sinh,
  Phòng; giường 4 "…sau thảm họa động đất" + Tòa, Họ và tên. Chữ trên vạt mẫu làm đúng như vậy.
- **Ba chỗ tìm giả:** `SearchLocker/Ceiling/Vent` là hộp 0,4 × 0,3 × 0,2 ở đúng marker; tín hiệu `searched` chưa ai nối.
  `FakeLocker` là tủ Phúc (`LockerPhuc`, Tripo, đã mở sẵn).
- **Cửa 407 (lỗi hình đang có trên main):** cánh người chơi thấy là cánh Tripo `Floor4/Door407/Pivot/RoomDoor` (floor4.gd dời
  vào, trong không gian Pivot ở (−0,445; −0,01; −0,085), mặt trong ở z −0,105). `door407_proxy.gd` chỉ ẩn `Pivot/Leaf` (cánh kit,
  lưới đã ẩn sẵn), nên: 30 % vết nứt PS1 (z −0,047) nằm **sau** cánh, không thấy; 60 % cánh Tripo vẫn hiện, **không thấy lỗ**;
  80 % chỉ có bàn tay hộp xuyên cánh nguyên (`options_door.jpg` hàng trên). Lượt 2 sửa trong `door407_proxy.gd` (phần hình).
  Phía hành lang, cánh có `Pivot/RulesPaper` (tờ nội quy) ở y 1,39: lỗ đặt dưới nó.
- **Tay xác:** xác sống chương 3–4 là thân học sinh (`scenes/levels/cctv/student_*.tscn`, `ch1_models/corpse_*`; hộp PS1,
  áo hoodie xám, da `skin.png`). Tay mẫu theo đó: tay áo hoodie xám rách, da tái lốm đốm.
- **Chương 1 và 3:** cùng góc (`survey_ch1_vent_ceiling_torch.jpg`, `survey_ch3_…`): chương 1 không có ô thông gió và tấm
  trần (không có `Campus`), chương 3 có (PS1).
- **Bệnh viện:** đúng khung `Camera_Wake` qua `_show_hospital()` ở hai kết, độ sáng 1,0 và 1,45 (`survey_sheet_ward.jpg`); sơ đồ
  `plan_hospital.jpg` (nhìn từ trên với hình nón ngang 110° và mặt cắt dọc với K1/K2). Trong khung K1: trần (nửa trên), tường
  chân giường, nửa xa hai tường bên, chăn của Trung ở mép dưới, thẻ Trung ở giữa (y −0,60 của khung), chân hai giường bên và
  thẻ ở hai góc dưới (x ±0,74), một mép cửa sổ. Ngoài khung: máy theo dõi, `MonitorAudio`, tủ, đèn trần, ba cây truyền
  (ngang vai, sát camera), gối, đầu Trung. `Nurse1/2` ở sàn ngay dưới tâm khung, cách mắt 1,9 m.
  **Thẻ tên (UI lane D)** quay mặt chữ ra chân giường: từ mắt Trung chỉ thấy **mặt sau trắng trơn**, và ở 1,45 thì cháy trắng.
- **Chỗ trong code, test, UI, âm thanh đụng hai khu:** `campus.tscn` (instance `ch4_anchors`), `chapter4_director.gd`,
  `bed_slat.gd`/`.tscn`, `search_spot.gd`, `fake_search_spot.tscn`, `ch4_form.gd`, `ch4_ui_preview.gd`, `ch4_bed_card.gd`,
  `ui/ch4/bed_card.tscn`, `levels/ch4/review.gd`, `scripts/player/ch4_gameplay_test.gd`; test `test_ch4_environment`,
  `test_chapter4`, `test_ch4_gameplay`, `test_ch2_4_hand_targets`, `test_hospital_light`, `test_ch4_ui`, `test_ch4_voices_calls`
  (Nurse1), `test_floor4`, `test_graphics_bindings` (tên `Bed_*` của phòng 407, không phải bệnh viện).

#### 2. Bảng hợp đồng (giữ ở lượt 2)
| Node | Giữ | Ghi chú |
|---|---|---|
| `Room407/Slat1`, `Slat2`, `Slat4` (Marker3D, `slat_visual.gd`) | tên; vị trí (0,65; 1,18; −3), (0,65; 0,41; −3), (7,35; 1,18; −2,7); `bed`, `flipped`, `set_flipped()`; nghe `bed_slat_flipped` | cách `Bunk<n>` < 0,1 m |
| `Slat<n>/Hinge` | tên; quay quanh z > 1 rad khi lật, ≤ 0,6 s | lệch ∓0,43 m về phía tường; giường 2 đề xuất 62° |
| `Slat<n>/BedSlat<n>` (director gắn) | Area3D lớp 4, hộp 1,2 × 0,22 × 0,9 tâm marker + (0; 0; 0,45), `HandTarget` (0; −0,0175; 0,7) | hình mới không che tia dùng tay |
| `Floor4/Room407/BunkA|B/Net_*` | ẩn khi lật, trả khi thoát | mùng Tripo đi theo |
| `MattressViet` … (Tripo, `furnished_prop`) | chỉ dời lúc lật (N1/N2), trả khi thoát | ba món của Phúc đi theo `PhucMattress/Pivot` |
| `FakeLocker`, `FakeCeiling`, `FakeVent` | tên, vị trí, Marker3D | `Search*` con của marker (director) |
| `CeilingPanel`, `VentFrame`, `VentSlat0…5` | chỉ là hình | ẩn, hình mới dưới node con mới |
| `Room407/Door` (`door407_proxy.gd`) | `room`, `is_open`, `set_open()`, `blocker`, `damage_fraction`, `set_damage_fraction()`, nhóm `room_doors`; bám `Door407`; `Damage.rotation` = `Pivot.rotation` | |
| `Door/Blocker` | StaticBody3D, hộp 0,88 × 2,1 × 0,08 ở (−0,44; 1,05; 0), lớp 1 khi đóng | ZombieDoor dùng |
| `Damage/Cracks`, `Hole`, `Hand` | tên; hiện ở 0,3 / 0,6 / 0,8 | |
| `Door407/Pivot/RoomDoor`, `Pivot/Leaf` (+ va chạm) | ẩn từ 0,6 (cả `RoomDoor`), trả khi thoát | `HandlePivot` (tay nắm), `RulesPaper` không đụng |
| `HospitalRoom` (`hospital_room.gd`) | `set_companions_visible()` | |
| `Bed_Trung`, `Bed_Nhat` (−1,65), `Bed_Ngu` (+1,65) và `Card` (0; 0,88; 1,08), `Patient` | tên, kiểu, vị trí | thẻ lane D gắn vào `Card` |
| `Nurse1`, `Nurse2`, `MonitorAudio`, `Camera_Wake` (0; 0,94; −0,64; 24°, 180°; FOV 78) | tên, kiểu; vị trí/góc chỉ đổi theo Y, K đã chọn | |
| `Environment`, `CeilingLight` (0,75, tầm 8) + `LightHum`, `West/Mesh` | `test_hospital_light` | |

#### 3. Phương án (hình mẫu trong cảnh thật, cùng camera)
Phòng 407 (giường 2 làm mẫu):
- **Vạt** (`options_slat.jpg`): V1 ván ép liền (12 tam giác); V2 giát 9 nan 9 cm trên hai thanh dọc (348; khe 7 cm che mất
  chữ); **V2b đề xuất**: cùng khung, 9 tấm 14,5 cm khe 1,6 cm (348; đọc được chữ, ra dáng giát giường). Cả ba rộng 0,72 m.
- **Nệm, chăn, gối** (`options_bedding.jpg`): N0 như nay (ván xuyên qua); N1 dựng nghiêng theo ván sát tường (đi theo
  `Hinge`); N2 rơi xuống sàn cạnh giường. Không lưới mới, chỉ dời ba món Tripo có sẵn, trả lại khi thoát. **Đề xuất N2 không
  va chạm** (đúng CH4_DESIGN "ném nệm và đồ đạc xuống", lộ chữ rõ, phòng bị lục tung; nệm dày 5 cm nên đi xuyên khó thấy).
  N2 có va chạm đổi gameplay: chỉ làm khi chủ dự án chọn (kèm test đi được tới ba giường và ba chỗ tìm).
- **Chữ** (`options_ink.jpg`, `options_ink_beds.jpg`): mực loang (**đề xuất**, đúng "chữ loang lổ"; đọc được vài chữ ở
  1 m), bút bi đè, khắc, và thêm một kiểu: mảnh phiếu photocopy dán (giống mảnh phiếu UI nhất). Ba vạt ba texture.
- **Ô thông gió, trần** (`options_vent_hatch.jpg`): cửa chớp tôn sơn có lưới, muội (144); trần **H1 đề xuất** nắp thăm trần
  tôn sơn có khung (134) hay H2 tấm thạch cao lỏng (62). **Phản hồi khi tìm xong:** đề xuất có (chớp treo lệch một vít, nắp
  hé xuống; tủ Phúc đã mở sẵn nên giữ), script hình của lane B nghe `searched`.
- **Bốn chương** (`options_chapters.jpg`): C1 giữ chỉ chương 3–4; C2 có ở cả bốn chương (đưa vào phòng 407 gốc, integrator
  duyệt). **Đề xuất C2**: hai thứ này là đồ cố định của phòng, tự dưng xuất hiện ở chương 3 thì lệch; ở chương 1–2 không có
  lời nhắc tương tác nên không thành chỗ tìm. Thiệt: đụng phòng 407 gốc, thêm khoảng 6 lần vẽ ở chương 1–2.
- **Cửa bị phá** (`options_door.jpg`): 30 % nứt toác trên cánh thật (lớp vết nứt có alpha); 60 % cánh thật của game cắt lỗ,
  dằm gỗ, thấy hành lang qua lỗ; 80 % tay xác. Nhìn từ hành lang: tay thò ra không có thân (ảnh chụp đã gỡ bốn xác); lượt 2
  kiểm lại khi có xác đứng ở cửa.
Phòng bệnh (dựng thô):
- **Hai y tá** (`options_ward_nurse.jpg`): **Y1 đề xuất** rèm quây kéo ngang chân giường (z 1,5), bóng mờ hai người in trên rèm
  (một lớp trong suốt trên nếp rèm, không thêm đèn), tiếng giữ ở `Nurse1/2` sau rèm; Y2 cửa hé ở tường chân giường, tiếng dời
  ra hành lang; Y3 như nay. Y4 (y tá có hình, Tripo) không làm.
- **Khung** (`options_ward_frame.jpg`): K1 như nay (phần lớn là trần); **K2 đề xuất** ngước 11°: thấy thân Trung dưới chăn,
  tay băng, hai giường bên và thẻ, trần còn khoảng 1/3.
- **Vỏ phòng:** tường hai màu (chân xanh nhạt 1,2 m, trên trắng ngà, chỉ sơn), sàn ceramic, trần tấm 60 × 60, máng đèn tuýp ở
  `CeilingLight` (hình mẫu). Chưa dựng: ốp gạch men chân tường, đá mài, trần bê tông có quạt.
- **Giường:** inox, nệm bọc xanh, ga trắng ngà, chăn kẻ xanh nhạt. **Trung: T1 đề xuất** (chăn có dáng người, cẳng tay quấn
  băng, dây truyền) / T2 chỉ chăn (`options_ward_patient.jpg`). Nhật, Ngư: dáng người dưới chăn, đầu quay vào tường, không mặt.
  **Kết một mình:** ga phẳng + chăn gấp ở chân giường (**đề xuất**) / nệm cuộn ở đầu giường.
- Ở 1,45 không vùng nào của phòng cháy trắng (trừ thẻ tên lane D).

#### 4. Số đo
| Chỗ (cùng camera) | Main | Hình mẫu |
|---|---|---|
| Phòng 407 từ cửa, đèn pin (cùng lượt chụp) | 3.022 lần vẽ (chưa lật, cửa 0 %) | 3.097 (giường 2 lật V2b + N1, chớp, H1, cửa 80 %) |
| Phòng 407 từ cửa, lật cả ba, cửa 80 % (lượt khảo sát) | 3.048 | — |
| Bệnh viện, khung K1, kết thật / một mình | 27 / 21 lần vẽ, 342 / 248 tam giác | Y1: 35 / 31 lần vẽ, 9.830 / 6.280 tam giác; Y2: 39 |
| Bộ nhớ hình chương 4 | 1.301 MB | 1.307 MB (+ texture đợt 9) |
Tam giác, vật liệu từng glb: `wave9/README.md`. Ngưỡng mục 5: `test_t266_pilot` (Slat 374, Door 3.022, Bed_* ≤ 3.212, cả phòng
bệnh khoảng 13.300). Không đo FPS.

#### 5. Câu hỏi cho chủ dự án
1. Vạt V1 / V2 / **V2b**? 2. Nệm chăn gối N0 / N1 / **N2 không va chạm** / N2 có va chạm? 3. Chữ **loang** / bút bi / khắc /
mảnh phiếu? 4. Trần **H1** / H2; phản hồi khi tìm **có** / không? 5. C1 / **C2**? 6. Y1 / Y2 / Y3? 7. K1 / **K2**? 8. T1 / T2;
kết một mình **ga phẳng** / nệm cuộn? 9. (Cho integrator, lane D) thẻ tên nhìn từ mắt Trung chỉ thấy mặt sau trắng và cháy
trắng ở 1,45: giữ, hay lane D cho thẻ hai mặt hoặc tối màu hơn?

#### 6. Kiểm
- `pwsh tools/test.ps1 -Filter t266`: `RESULT: 3 passed, 0 failed`; `-Filter hospital`: 1/0; `room_doors`: 4/0;
  `hand_targets`: 6/0; `ch4`: 55/0; `chapter4`: 15/0 (mỗi lọc in `RESULT: <n> passed, 0 failed`). Sau đó `git checkout -- game/default_bus_layout.tres`.
  Không chạy full test và check (card mục 7).
- Commit: `9558eae` (WIP khảo sát và hình mẫu), commit kế tiếp "T-266: round 1 …" (README, CREDITS, test, Handoff; hash ở `git log`).
- Chưa kiểm: hình mẫu chưa vào cảnh (lượt 2); cửa nhìn từ hành lang khi có xác; hình mẫu chương 1–2 cho C2.
- Yêu cầu thay đổi ngoài phạm vi: không (câu 9 là câu hỏi cho lane D, chưa phải yêu cầu).
