# T-220 — G4 nhân vật chính có thân và tay thật, bước 1: mẫu thử trong phòng 407
- Lane: **chủ dự án + Claude** (D-122, như T-219: chủ dự án tạo thân Trần Trung trên Tripo, Claude làm phần còn lại, ghi "Claude làm thay A/B") | Trạng thái: **D-124: bước 1 xong trên thân tạm CC0 (camera nhìn theo tay, phải đứng gần, tay trái cầm điện thoại, tay nắm cửa gạt); chờ chủ dự án duyệt, ban công chưa có cửa; Trần Trung (Tripo) chưa có** | Agent: chủ dự án + Claude
- Quyết định: **D-121**. Chủ dự án: "1: thấy cả người( cúi thấy chân, có bóng, hiện trên gương), 2 : thao tác tay mất 1 giây ( nhưng phải thấy thao tác chân thật nhất như là cầm lên trên tay đầy đủ động tác chứ không phải là ấn nút nhặt đồ là nó có trong tay). giữ nguyên thời gian thật", "câu 3 tôi chọn theo (c) nhé".
- Phụ thuộc:
  - D-120: quy trình Tripo → Godot của quản lý (`art_source/graphics_upgrade/manager/`), `HandGripModifier`, `ArmReachModifier`;
  - T-208: bảng hợp đồng gameplay–hình (InteractRay, capsule, `View`/`Exit` của chỗ nấp, camera chết);
  - `game/scripts/player/player.gd`, `game/scripts/core/interactable.gd`, `game/scenes/levels/mirror.gd` (`ReflectionBody`, layer 20).

## Mục tiêu
Làm trong một **cảnh thử phòng 407**; bản chơi chưa đổi. Người chơi có thân thật:
- cúi nhìn thấy hai chân, có bóng dưới đèn, thấy mình trong gương;
- làm được **3 thao tác bằng tay**, mỗi thao tác **đúng 1,0 s** và hiện đủ động tác:
  1. **mở cửa phòng 407:** tay với tới tay nắm, vặn, kéo hoặc đẩy, cánh cửa quay theo tay;
  2. **mở tủ Việt:** tay với tới chốt, kéo cánh tủ quay theo bản lề;
  3. **nhặt giấy:** cúi hoặc với tay, ngón kẹp tờ giấy, nhấc lên trước mặt, rồi mới mở khung đọc.

Chủ dự án chơi thử mẫu này để quyết hai việc:
- đã đủ thật chưa;
- có trả phí quay video + AI (motion capture) cho các thao tác tay không (D-121 câu 3, cách c).

## Luật giữ nguyên (D-121)
- 1,0 s thao tác **tính vào thời gian luật**: không nới đồng hồ, không đổi tầm nghe hay tầm nhìn của quái.
- Giữ các số của T-208:
  - InteractRay dài 2 m, mask 5;
  - capsule cao 1,75 m;
  - tốc độ đi 2,2, chạy 3,6, cúi 1,2 m/s;
  - độ cao mắt khi đứng và khi cúi như hiện tại.
- `EventBus.interacted` vẫn phát đúng một lần mỗi thao tác.
- **Đề xuất để chủ dự án chốt khi chơi thử** (ghi kết quả vào card):
  - trong 1 s không đi được, vẫn xoay nhìn được;
  - hiệu ứng gameplay (cửa bắt đầu mở, đồ vào tay) xảy ra ở mốc chạm khoảng 0,45 s; khung đọc giấy mở ở 1,0 s.

## Việc cần làm
1. **Thân**
   - **Thân tạm CC0** (ví dụ người mẫu của Quaternius) để làm cơ chế ngay, không chờ mô hình.
   - **Thân thật Trần Trung** từ Tripo:
     - chủ dự án tạo theo phiếu `docs/handoff/TRIPO_NHAN_VAT_CHINH.md`; integrator soạn phiếu sau khi chủ dự án chốt ngoại hình;
     - Auto Rig có xương ngón tay (đã chạy được ở quản lý);
     - Retopo khoảng 15.000–20.000 tam giác (chỉ một nhân vật), texture ≤ 2048².
2. **Chuyển động (D-121 câu 3, cách c)**
   - **Nguồn:** bộ chuyển động CC0 (Quaternius Universal Animation Library hoặc tương đương) và preset Tripo (gói trả phí, D-084).
   - **Cần có:** đứng, đi, chạy, đi khi cúi, xoay tại chỗ, với tay cao, ngang và thấp, nhặt dưới thấp, đẩy cửa, kéo cửa.
   - **Đưa vào Godot:** qua `BoneMap` → `SkeletonProfileHumanoid`, để mọi thân người (Trần Trung, xác sống, bạn học) dùng chung một bộ.
   - **Xem bằng mắt từng clip** trước khi dùng. Bài học T-219: `Idle_Loop` của Quaternius là dáng khuỵu gối.
   - **Chỉnh trong Blender bằng script:** thời lượng 1,0 s, bỏ trôi hông, chân không trượt.
3. **Thân ở góc nhìn thứ nhất**
   - **Gắn thân:**
     - thân là con của `Player`, gốc ở chân, xoay theo hướng nhìn ngang;
     - camera bám điểm giữa hai mắt của xương đầu, giữ độ cao camera hiện hành (bù lệch nếu cần).
   - **Đầu:** không hiện với camera người chơi (không thấy bên trong đầu), nhưng vẫn đổ bóng và hiện trong gương.
     - Gợi ý: hai lớp. Thân đầy đủ chỉ đổ bóng và nằm ở lớp gương (layer 20); thân không đầu (xương đầu thu về 0) cho camera chính.
     - Dùng cách khác cũng được, ghi lý do.
   - **Đi:**
     - tốc độ clip theo vận tốc thật, bước dài như `walk_step_length` 1,1 m và `sprint_step_length` 1,4 m;
     - tiếng bước chân (`footstep`) khớp lúc bàn chân chạm đất;
     - cúi nhìn thấy hai bàn chân không trượt.
   - **Gương:** `ReflectionBody` của `mirror.gd` dùng thân này, giữ hiệu ứng trễ.
   - **Điện thoại và đèn pin:** hiện đang gắn vào camera. Đề xuất tay trái cầm điện thoại, tay phải thao tác; chủ dự án duyệt khi xem mẫu.
4. **Thao tác tay**
   - **Mỗi đồ vật có:**
     - `HandTarget` (`Marker3D`): chỗ đặt tay và hướng lòng bàn tay;
     - kiểu nắm: `grip` (nắm tay nắm cửa), `pinch` (kẹp giấy), `hook` (móc chốt tủ).
   - **Thời gian chung 1,0 s:**
     - 0–0,45 s **với tới:** `TwoBoneIK3D` kéo tay tới `HandTarget`, `LookAtModifier3D` cho đầu nhìn theo (cả hai có sẵn trong Godot 4.7);
     - 0,45–0,8 s **thao tác:** cửa hoặc tủ quay theo tay; giấy gắn vào xương bàn tay;
     - 0,8–1,0 s **thu tay về:** giấy đưa lên trước mặt.
   - **Ngón tay:** mở rộng `HandGripModifier` (T-219) theo kiểu nắm.
   - **API gợi ý:** `Player.perform_hand_action(target: Interactable)` kèm signal báo xong.
   - **Interactable chưa có `HandTarget`** vẫn chạy như cũ (bấm là xong), để bản chơi không gãy trong lúc chuyển.
5. **Cảnh thử** `game/scenes/levels/graphics_pilot/protagonist_pilot.tscn`:
   - tầng 4 và phòng 407 như `manager_preview.tscn`;
   - đi lại tự do, làm được 3 thao tác, có gương nhà tắm.
6. **Ảnh và video**
   - **Ảnh 1080p:** nhìn xuống chân, bóng dưới đèn trần, trong gương, giữa mỗi thao tác.
   - **Video ngắn mỗi thao tác:** Movie Maker của Godot (`--write-movie`), để chủ dự án xem chuyển động. File > 10 MiB không vào git.
7. **Test** `game/tests/player/test_protagonist_body.gd`:
   - mỗi thao tác 1,0 s ± 1 khung; không đi được trong lúc làm; hiệu ứng xảy ra đúng một lần;
   - ở mốc chạm, tay cách `HandTarget` dưới 3 cm;
   - chân không trượt: trong pha chạm đất bàn chân lệch dưới 2 cm;
   - đứng yên thì camera lệch độ cao dưới 2 cm so với hiện tại; InteractRay vẫn 2 m;
   - đầu ẩn với camera chính, hiện trong gương;
   - interactable chưa có `HandTarget` vẫn chạy như cũ.
8. **FPS:** hỏi chủ dự án trước khi đo.

## Không làm ở bước 1
- **Bản chơi 4 chương:** chưa đổi (bước 5).
- **Thao tác khác** (leo giường, nấp, bịt miệng, thanh sắt, công tắc…): bước 3.
- **NPC đi không trượt và dùng tay mở cửa:** bước 4 (quản lý đã có tay trái với cửa, D-120).
- **Cầu thang và bước chân trên bậc:** bước 2.

## Kế hoạch 5 bước (integrator đề xuất 16/10)
1. Mẫu thử phòng 407 (card này).
2. Bước chân thật.
3. 8–10 loại thao tác tay, IK và điểm cầm trên từng đồ vật.
4. NPC đi không trượt, dùng tay mở cửa.
5. Hồi quy 4 chương (cần chạy bot, phải hỏi chủ dự án trước).

## Handoff (người làm điền)

### D-123 (19/10/2026): cơ chế bước 1 trên thân tạm CC0 (Claude làm thay A/B)

**Đã làm:**
- **Thân tạm:** Quaternius Universal Animation Library, CC0, lấy từ nhánh lane C. Nối xương sang `SkeletonProfileHumanoid` khi import; nguồn ghi ở `game/assets/models/characters/standin/CREDITS.md`.
- **`PlayerBody`** (`game/scripts/player/player_body.gd`), `player.set_body()`:
  - lớp nhìn không đầu, không đổ bóng; lớp gương có đầu, đổ bóng (layer 20);
  - mắt dưới camera theo từng động tác; cúi nhìn thì đầu nhô ra trước để thấy chân;
  - chân không trượt (đo tốc độ lùi của bàn chân phẳng trong động tác).
- **Thao tác tay 1,0 s:**
  - IK hai khúc tay, xoay cổ tay theo kiểu cầm, khép ngón;
  - cúi lưng khi tay không đủ dài, camera theo đầu 60%;
  - dùng đồ ở 0,45 s;
  - tay đi về chỗ động tác gốc rồi mới buông.
- **Đồ vật:**
  - `HandTarget` trên từng đồ;
  - `Interactable.interact_by_hand`;
  - cửa 407 quay theo tay (`door407.gd` dùng `hand_seconds`), tủ Việt cũng vậy (trong cảnh thử);
  - giấy nhấc lên trước mắt rồi mới đọc, đọc xong đặt lại đúng chỗ.
- **Cảnh thử** `graphics_pilot/protagonist_pilot.tscn`:
  - 19 ảnh ở `art_source/graphics_upgrade/protagonist/previews/`;
  - video `build/graphics/protagonist/t220_demo.mp4` (không vào git);
  - cách chạy ở `art_source/graphics_upgrade/protagonist/README.md`.
- **10 test** `game/tests/player/test_protagonist_body.gd`.

**Chủ dự án xem video, góp ý 19/10 (đã sửa):**
- "tay cầm giấy bị vung ngược phía sau":
  - đọc xong, giấy biến về bàn ngay và tay rơi thẳng về tư thế đứng; nay tay đưa giấy xuống đặt lại rồi thu về theo đường thẳng;
  - cảnh quay từ ngoài lấy nhầm camera quay phim làm mắt; nay luôn dùng mắt người chơi.
- "giấy lọt qua tay", "tờ giấy cần lọt qua cái tay cầm 1 chút", "cầm từ méc phải hoặc trái", "vẫn xuyên qua lòng bàn tay":
  - cầm mép phải, ngón cái phía trước, các ngón phía sau;
  - mép giấy dừng sát mặt lòng bàn tay;
  - test kiểm tra không xuyên.

**Chờ chủ dự án quyết khi xem cảnh thử:**
1. **Đứng xa đồ vật** (tia tương tác dài 2 m, tay chỉ với được khoảng 0,6 m, cúi thêm khoảng 0,2 m). Chọn một:
   - (a) người tự bước tới trong 1 giây (vị trí người chơi đổi khoảng 0,5 m);
   - (b) phải đứng gần mới dùng được;
   - (c) tay với hết cỡ, đồ vẫn dùng được (kém thật).
2. **Tay trái cầm điện thoại/đèn pin** (bộ CC0 có sẵn `Idle_Torch`).
3. **Trong 1 giây** không đi được nhưng vẫn xoay nhìn được (đang làm vậy).
4. **Nhịp chân khi đi nhanh** (bước gốc 0,9 m/s, người chơi đi 2,2 m/s): bước 2 sẽ giãn sải chân.

**Chưa làm:**
- **Trần Trung (Tripo):** ngoại hình chủ dự án để sau.
- **Đưa vào bản chơi (bước 5):**
  - thân phản chiếu trong gương đang là bản PS1 có độ trễ (chương 2); cảnh thử ẩn nó đi;
  - lúc nấp thì ẩn thân;
  - cửa quay vào người khi đứng quá gần;
  - cửa ban công phòng 407 (D-130): người chơi mở/đóng bằng tay như cảnh thử; quản lý chương 1 mở cửa này như cửa nhà tắm (`chapter1_director.gd` `_bathroom_door_between`).

### D-124 (20/10/2026): chủ dự án chốt 3 câu và thêm tay nắm cửa (Claude làm thay A/B)

**Chủ dự án:** "1 : đồng ý, 2 (b), 3 : có. Tôi có bổ sung 1 ý là làm các cánh cửa phòng, nhà vệ sinh, ban công có tay nắm, vặn cửa để sau nhân vật mở hay đóng cửa sẽ tự nhiên hơn".

**Đã làm:**
- **Camera nhìn theo tay** (`PlayerBody._look`):
  - camera quay về phía tay (85% quãng, tối đa 40°) trong lúc với tới, cầm, đặt xuống rồi trả lại;
  - chuột vẫn điều khiển chồng lên.
- **Phải đứng gần** (`PlayerBody.can_reach`, `player.gd` `_update_focus`):
  - đồ dùng bằng tay chỉ hiện "[E]" khi tay với tới (cúi tối đa 45°);
  - đồ không có `HandTarget` vẫn dùng được từ 2 m.
- **Tay trái cầm điện thoại** (`PlayerBody._tick_phone`):
  - bật đèn pin: máy cầm thấp ở góc trái, đèn phát từ máy và chiếu theo hướng nhìn;
  - giơ máy: đưa lên trước mặt, các ngón ôm mép máy.
- **Tay nắm cửa gạt:**
  - mô hình `game/assets/models/props/door_lever.glb` dựng bằng `art_source/graphics_upgrade/protagonist/build_door_lever.py`;
  - `DoorHandles.fit` gắn cả hai mặt cửa, mỗi mặt có `HandTarget` gắn trên cần gạt;
  - `HandTarget.lever` cho tay nắm cần, vặn xuống 35° trong 0,15 s rồi cửa mới quay; buông tay cần bật về;
  - `Interactable.hand_target(from)` chọn tay nắm phía người chơi đứng.
  - Cửa 407: tay nắm treo trên `HandlePivot` nên cảnh rung tay nắm từ hành lang vẫn rung cả hai.
  - Cửa nhà vệ sinh: mở được bằng tay trong cảnh thử.
  - Tay nắm hộp PS1 cũ ẩn đi.
- **Cảnh thử:** 26 ảnh; video `build/graphics/protagonist/t220_demo.mp4` (34 giây, thêm đèn pin và cửa nhà vệ sinh).
- **Test:** thêm 4, còn 14.

**Còn hỏi chủ dự án:**
- **Ban công không có cánh cửa:** hiện chỉ có khung, ngưỡng và rèm. Thêm cửa là thêm một đồ phải mở (1 giây) trên đường ra ban công, ảnh hưởng thời gian các chương có đi ra ban công. Chọn:
  - không thêm;
  - cửa cánh có tay nắm gạt;
  - cửa nhôm kính lùa.
- **Tay nắm:** dùng bản Blender đang có, hay chủ dự án tạo bản Tripo (giống thật hơn, có vết xước)?

### T-222 (22/10/2026, D-129): tay nắm Tripo và cửa ban công trong cảnh thử (Claude làm thay A/B)

- Vỏ phòng T-222 vào bản chơi, nên cảnh thử cũng dùng vỏ mới. Cả 3 cửa đã có tay nắm Tripo gắn sẵn: `DoorHandles.take` gắn `HandTarget` lên chúng, thay cho `DoorHandles.fit` (tay nắm PS1 tạm). Điểm nắm `TRIPO_GRIP_POINT` nằm trên thanh gạt Tripo (ngắn hơn, đứng xa mặt cửa hơn bản tạm).
- Cửa ban công (`Extension/BalconyDoor`) mở/đóng bằng tay như cửa nhà tắm (`HandHinge`). Vùng bấm đi theo cánh: mở sẵn thì cánh áp tường ngoài, phải ra ban công mới với tới.
- Chụp: `-- --body-capture --shots=a,b` chụp lại vài ảnh, giữ phần còn lại của báo cáo. Đã chụp lại `door_press_tube`, `lever_close_tube`, `bath_door_press_tube` (tay trên thanh gạt Tripo) và thêm `balcony_door_reach_torch`, `balcony_door_side_tube`.
- Đóng cửa ban công từ ngoài ban công thì cánh quay qua chỗ người chơi đứng: cùng việc "cửa quay vào người khi đứng quá gần" của bước 5.

### D-125 (20/10/2026): cửa nhà vệ sinh mở xong biến mất, đã sửa (cả bản chơi)

- **Chủ dự án:** "ok tôi thấy ok rồi", rồi báo "khi mở cửa nhà vệ sinh, mở xong thì cánh cửa mất ( điều này rất phi vật lý )".
- **Nguyên nhân:** bản lề nằm trong bề dày tường phía tây phòng tắm, mở 90° thì cánh chìm vào tường.
- **Sửa:**
  - `bathroom_door.gd` mở tới 82°;
  - dời cụm bồn rửa (bồn, gương nhỏ, cốc bàn chải, đồ vệ sinh) vào trong 22 cm để cánh cửa không cắm vào bồn mà lối vào vẫn rộng (`placements.json`);
  - test trong `test_room407_bathroom_fixes.gd`.
