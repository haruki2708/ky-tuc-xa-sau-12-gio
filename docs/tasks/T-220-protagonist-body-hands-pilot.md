# T-220 — G4 nhân vật chính có thân và tay thật, bước 1: mẫu thử trong phòng 407
- Lane: **chủ dự án + Claude** (D-122, như T-219: chủ dự án tạo thân Trần Trung trên Tripo, Claude làm phần còn lại, ghi "Claude làm thay A/B") | Trạng thái: **mới (D-121, D-122); ngoại hình Trần Trung để sau, Claude làm cơ chế trên thân tạm CC0 trước** | Agent: chủ dự án + Claude
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
