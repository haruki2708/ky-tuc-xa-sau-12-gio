# T-239 — Sửa 4 lỗi tay Trần Trung (chủ dự án chơi thử 09/11)
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141), **Opus 5.5, effort max** (chủ dự án yêu cầu, D-153)
- Nhánh: `lane-b/T-239-protagonist-hand-fixes` từ `origin/main` mới nhất (có `ae7496d` thân vào chương 1, `35b8759` bot/FPS, `815dad3` card này).
- Quyết định giao: **D-153** (09/11/2026). Chủ dự án chơi bản `build/windows/KyTucXa.exe` 09/11 15:50 (build từ `35b8759`, thân Trần Trung trong chương 1, D-151/D-152) và báo 4 lỗi tay, yêu cầu **"sửa dứt điểm"**.
- Bối cảnh cần đọc:
  - [T-220](T-220-protagonist-body-hands-pilot.md): D-121, mỗi thao tác tay 1 giây; D-124, tay trái cầm điện thoại, phải đứng gần, tay nắm cửa hai mặt.
  - [T-227](T-227-protagonist-tripo-body-motions.md): thân Tripo; mục cuối "Thân Trần Trung vào chương 1" (D-151/D-152).
  - Đầu file `game/scripts/player/player_body.gd`: mô tả cả hệ thống tay.

## 1. Bốn lỗi
Ảnh 1080p của chủ dự án ở `art_source/graphics_upgrade/protagonist/previews/t239/before_*.png` (bản gốc trong `D:\GAME_DEMO\anh_chup_sua_loi\`, thư mục đó không có trong git).

| # | Ảnh | Chủ dự án thấy | Đúng phải là |
|---|---|---|---|
| 1 | `before_tay_cam_dien_thoai.png` | Tay trái xuyên điện thoại: ngón đè lên, xuyên mặt màn hình, máy chìm trong lòng bàn tay | Máy nằm trong lòng bàn tay trái, mặt sau tựa vào lòng bàn tay. Ngón cái ôm cạnh gần, bốn ngón ôm cạnh xa và mặt sau. Không phần nào của tay xuyên thân máy, không ngón nào che màn hình. Đúng ở **cả hai tư thế**: giơ lên đọc, cầm thấp bật đèn. Đúng cả lúc chuyển giữa hai tư thế. |
| 2 | `before_tay_cam_nam_cua.png` | Đóng cửa 407 từ trong phòng thì tay nắm tay nắm **phía ngoài**; động tác sai | Ở trong phòng **không bao giờ dùng tay nắm mặt ngoài** (chủ dự án). Tay không xuyên cánh, không vòng qua mép cánh để với tay nắm bên kia. Chỗ cầm khi cánh đang mở theo mục 4 (chủ dự án chọn). Tay **bám theo chỗ cầm** khi cánh quay, không đứng giữa không trung, rồi buông. Mở cửa đang đóng vẫn như D-124: tay nắm phía người chơi, nhấn xuống rồi cánh mới quay. |
| 3 | `before_tay_cam_giay.png` | Tay phải xuyên tờ giấy đang cầm đọc; tay co gần thành nắm đấm | Kẹp mép phải tờ giấy: ngón cái ở mặt trước (phía mắt), các ngón khác ở mặt sau. Mép giấy nằm sâu trong kẽ ngón cái và ngón trỏ. Không ngón nào xuyên mặt giấy. |
| 4 | `before_tay_lay_giay.png` | Lấy giấy trên bàn sai, không giống người thật: bàn tay úp thẳng, chọc ngón trỏ xuống, với ngang qua cuốn sổ | Bàn tay tới gần mép giấy với ngón hơi khép. Ngón cái và ngón trỏ kẹp mép giấy (hoặc đầu ngón miết, nhấc mép rồi kẹp) rồi mới nhấc lên. Giấy chỉ rời mặt bàn khi ngón đã kẹp. Tay không xuyên bàn hay đồ trên bàn. |

Ảnh 4 còn cho thấy tờ giấy hình như nằm vắt qua cuốn sổ hợp âm: một phần trên mặt sổ, một phần thò ra dưới mép. Cần kiểm xem đó là vị trí đặt sẵn sai hay chỉ do góc nhìn; kết quả ghi trong Handoff.

## 2. Nguyên nhân integrator đọc ra từ code (lane B phải tự xác nhận trước khi sửa)
Dòng tham chiếu ở commit `815dad3`.

**Chung cho lỗi 1, 3, 4 (ngón tay):**
- **Ngón tay:**
  - Ngón do `HandGripModifier` (`game/scripts/entity/hand_grip_modifier.gd`) điều khiển. Modifier này chỉ cong 4 ngón (`GRIP_BONES` dòng 146, `LEFT_GRIP_BONES` dòng 115), cùng một góc cho mọi khớp, quanh một trục.
  - Góc cong **cộng thêm vào tư thế ngón của clip đang chạy**: `ual/Interact`, `ual/PickUp_Table`, `idle`, `crouch_idle`. Vì vậy hình bàn tay đổi theo clip, không cố định theo kiểu cầm.
  - Modifier không biết đồ vật nên ngón cong xuyên qua.
  - Góc lấy từ `GRIP_DEGREES` dòng 152, `READ_CURL` dòng 61, `PHONE_CURL` dòng 114.
- **Ngón cái không được điều khiển ở đâu cả** (trong code không có chữ "Thumb"). Ngón cái đứng theo clip nên không kẹp được.
  - Trong Skeleton3D của Godot, xương ngón cái mang tên humanoid sau `trung_bone_map.tres`: `RightThumbMetacarpal`, `RightThumbProximal`, `RightThumbDistal` (bên trái tương tự).
  - Trong file GLB gốc là `RightHandThumb1…3`; tên `…Thumb4` là điểm đầu ngón.
- **Khoảng cách tay–vật là số ước lượng**: `HAND_HALF` 2 cm, `HOLD_GAP`, `PAPER_GAP`, `THUMB_DEPTH` (dòng 62–70). Các số này chưa đo trên bàn tay Tripo thật (độ dày lòng bàn tay, độ dài từng đốt).
- **Lưu ý:** `HandGripModifier` dùng chung với **quản lý** (`game/scenes/entity/manager_body.tscn`, tay cầm dao). Không đổi hành vi của file này. Cần hệ ngón mới thì viết modifier riêng cho người chơi trong `game/scripts/player/`.

**Lỗi 1, điện thoại** (`_tick_phone`, dòng 777):
- Lòng bàn tay đặt lên mặt sau, ngón hướng chéo `0.8·x + 0.6·y` của máy, cong đều 50°.
- `_phone_half` chỉ là nửa độ dày máy; code không dùng bề rộng máy. Ngón dài hơn bề ngang máy nên cong qua mép rồi đè lên màn hình.
- Cần kiểm thêm dấu của trục lòng bàn tay trái (`_find_palm_axis("LeftHand", …)`, dòng 1367): nếu sai dấu thì lòng bàn tay đang úp vào màn hình.
- Hai tư thế: `PHONE_RAISED_*` và `PHONE_LOW_*` (dòng 104–113).

**Lỗi 2, cửa:**
- **Chọn tay nắm sai bên:**
  - `perform()` (dòng 343) lấy `target.hand_target(_reach_from())`, tức là `Interactable.hand_target()` (`game/scripts/core/interactable.gd:39`) chọn **marker gần vai phải nhất**.
  - `can_handle`/`can_reach` (dòng 313–330) dùng cùng cách chọn và **chỉ đo khoảng cách**, không xét cánh cửa chắn giữa vai và tay nắm. Đổi cách chọn thì phải đổi cả hai chỗ để lời nhắc và hành động luôn khớp nhau (D-152).
- **Hình học cửa 407** (integrator tính từ `floor4.tscn` và `door407.gd`, lane B kiểm lại bằng số đo):
  - Bản lề (`Door407/Pivot`) ở (32,44; 0; 0). Cánh rộng khoảng 0,88 m, mép tự do ở phía −x. Tường hành lang ở z = 0, phòng ở z < 0.
  - Mở = `Pivot.rotation.y` −90°: cánh quay **vào trong phòng**, nằm dọc mặt phẳng x = 32,44, mép tự do tới khoảng (32,44; −0,88).
  - Khi cánh mở: mặt trong (lúc đóng nhìn vào phòng) quay về **+x (phía đông)**; mặt ngoài quay về **−x (phía tây)**, tức phía khoảng trống cửa ra vào.
  - Trong ảnh 2, người chơi đứng phía tây cánh, gần khoảng trống cửa: mặt hướng về người chơi là mặt ngoài. Vì vậy code chọn tay nắm ngoài; tay nắm trong lúc đó nằm **sau cánh**.
  - Hệ quả: quy tắc "trong phòng thì luôn dùng tay nắm mặt trong" sẽ bắt tay vòng qua mép hoặc xuyên cánh (IK không biết va chạm). Không làm theo quy tắc đó; xem mục 4.
- **Nhịp thời gian:**
  - 0–0,45 s: tay tới tay nắm (`CONTACT`).
  - 0,45–0,6 s: nhấn tay nắm (`LEVER_SECONDS`).
  - 0,6 s: `_use()` cho cánh quay trong 0,4 s còn lại (tween `TRANS_SINE` trong `door407.gd` `set_open`).
  - 0,8 s (`RELEASE`): tay rời tay nắm, quay về từ một điểm cố định trong khi cánh vẫn đang quay.
  - Kết quả: tay chỉ bám tay nắm khoảng 0,2 s. Lúc đóng cửa vẫn nhấn tay nắm như lúc mở.
- **Phạm vi:**
  - Trong bản chơi chỉ **cửa 407** có tay nắm nhận tay (`Protagonist.attach`, `game/scripts/player/protagonist.gd`).
  - Cửa nhà tắm và cửa ban công làm sau (D-154), nên cách chọn tay nắm mới phải **dùng chung được** cho mọi cửa có `DoorHandles`.
  - Cảnh thử `protagonist_pilot` có lớp `HandHinge` riêng (`protagonist_pilot.gd:86`, cho tủ Việt, cửa nhà tắm, cửa ban công). Hàm `hand_target()` của lớp này cũng chọn **cái gần nhất**, đúng chỗ D-154 sẽ dùng lại. Sửa luôn chỗ này theo cùng một quy tắc, tốt nhất là gọi chung một hàm.
  - Chốt cửa 407 (`door_latch.tscn`, Interactable lồng bên trong, T-228) giữ nguyên.

**Lỗi 3, cầm giấy đọc** (`_read_basis`, dòng 752; `_update_carried`, dòng 1058):
- Ngón hướng lên, lòng bàn tay quay ngang về giữa tờ giấy, tức là nằm trong mặt phẳng tờ giấy. Ngón cong về phía lòng bàn tay nên quét ngang qua mặt giấy.
- Tờ giấy chỉ lùi về phía mắt 1 cm (`THUMB_DEPTH`).
- Lúc đọc, thân chạy clip `idle` (`_read()`, dòng 828), cộng thêm `READ_CURL` nên tay co gần thành nắm đấm.

**Lỗi 4, lấy giấy** (`_grip_basis` kiểu PINCH, dòng 734; `_contact`/`_carry`, dòng 1019–1036):
- Lòng bàn tay úp xuống, ngón chĩa xuống phía trước. Ngón chỉ bắt đầu cong ở 60% đường với tay. Ngón cái tự do, nên trông như chọc ngón trỏ.
- Bản sao tờ giấy nhảy vào tay ngay lúc `CONTACT`, không có lúc kẹp.
- Điểm cầm của giấy nằm ở mép phải, cách mép 1,5 cm, giữa chiều cao (`readable.gd`, dòng 59).
- Clip với: `ual/PickUp_Table` (đồ thấp) hoặc `ual/Interact`. Với rướn và quỳ (D-152) còn có cúi người.

## 3. Cách làm (gợi ý, lane B quyết và ghi lý do)
1. **Đo trước khi sửa.** Viết một bài đo ghi vị trí các đốt ngón (gồm ngón cái) so với điện thoại, tờ giấy, tay nắm ở đúng các khung hình lỗi. Ghi con số "xuyên bao nhiêu mm" vào Handoff, để sau khi sửa so lại được.
2. **Tư thế ngón theo kiểu cầm, không cộng vào clip:**
   - mỗi kiểu (kẹp giấy, nắm tay nắm, cầm điện thoại, tay thả lỏng lúc với tới) có một tư thế ngón **tuyệt đối** cho cả 5 ngón, gồm ngón cái;
   - đổi tư thế mượt theo pha;
   - nếu cần thì cho ngón dừng ở mặt vật (đo bằng hình học vật hoặc bằng va chạm).
3. **Nguồn tư thế ngón**, tùy lane B:
   - tính trong code;
   - dựng trên rig Tripo bằng Blender (`D:\Tools\Blender\`) rồi xuất thành clip hoặc dữ liệu tư thế;
   - lấy tư thế tay trong Quaternius UAL/UAL2 (CC0, đã có ở `assets/models/characters/standin/`).
   
   Ghi rõ đã chọn cách nào, vì sao, file ở đâu. Asset ngoài chỉ được dùng CC0 hoặc CC-BY.
4. **Cửa:**
   - Chọn chỗ cầm theo quy tắc chủ dự án chốt ở mục 4, không theo khoảng cách.
   - Bắt buộc: không đốt nào của tay phải (vai → đầu ngón) cắt cánh cửa trong suốt thao tác.
   - `can_reach` cũng phải xét điều này: tay nắm bị cánh che thì không đưa ra cho người chơi.
   - Cần chỗ cầm ở mép cánh thì thêm `HandTarget` ở mép tự do của cánh cửa 407 qua `Protagonist.attach` hoặc `DoorHandles`. Cảnh thử đã có mẫu: lớp `HandHinge`, kiểu cầm `HOOK`, `protagonist_pilot.gd:219`.
   - Khi đóng, tay bám chỗ cầm trong đoạn cánh quay mà tay còn với tới, rồi buông, cánh tự quay nốt.
5. **Trong 1 giây:** được chia lại các pha (`CONTACT`, `RELEASE`, `LEVER_SECONDS`, thời gian cánh quay truyền qua `interact_by_hand`) miễn tổng thao tác vẫn 1 giây (D-121). Phần đặt giấy lại sau khi đọc (`PUT_DOWN_SECONDS`, `LET_GO_SECONDS`) chỉnh nhẹ được.

## 4. Chỗ phải hỏi chủ dự án (đưa phương án kèm đề xuất, kèm ảnh hoặc video)
Hỏi **trước khi làm phần cửa**, các lỗi khác làm song song được.

**Đóng cửa 407 đang mở, người chơi trong phòng, tay cầm vào đâu?** Chủ dự án đã chốt: không phải tay nắm mặt ngoài. Đưa ảnh dựng thử cho từng cách:
- (a) **Luôn cầm mép tự do của cánh**, kéo hoặc đẩy cánh về khung. Đứng phía nào cũng làm được.
- (b) **Theo phía đứng:**
  - nếu mặt trong đang quay về phía người chơi (đứng phía đông cánh), cầm tay nắm mặt trong và đẩy cánh về khung; tay nắm về đúng chỗ khi cửa đóng;
  - nếu không (đứng phía tây như ảnh 2), cầm mép tự do kéo về.
- (c) Như (b), nhưng **ở phía tây thì không cho đóng**: không hiện lời nhắc, người chơi phải bước sang phía đông.
- **Integrator nghiêng về (b)**: giống người thật nhất, không bắt người chơi đi vòng.

**Từ hành lang** (cánh mở vào trong phòng) thì cầm tay nắm mặt ngoài kéo về, hay cầm mép? Lane B đề xuất theo cùng nguyên tắc.

- **Đóng cửa có nhấn tay nắm không?** Integrator nghiêng về không: nắm rồi kéo hoặc đẩy, chốt tự bật vào. Mở cửa vẫn nhấn trước (D-124).
- **Lấy giấy kiểu nào?** Kẹp thẳng mép, hay miết đầu ngón nhấc mép rồi kẹp? Chọn kiểu nhìn thật nhất mà vẫn vừa 1 giây.
- Nếu muốn đủ tự nhiên mà phải vượt 1 giây, hoặc phải đổi `door407.gd`: **dừng, hỏi trước**, không tự làm.

## 5. Phải giữ nguyên
- Mỗi thao tác 1 giây (D-121); phải đứng gần mới dùng được (D-124).
- 23/23 đồ chương 1 vẫn với tới được bằng đứng, nhón chân, rướn, quỳ (D-152). Lời nhắc và hành động chọn cùng một điểm cầm.
- Thời gian luật, cốt truyện; chết thì thả giấy, cất thân (D-151); thân nằm giường lúc đầu chương; gương hiện thân.
- Quản lý (`manager_body.tscn`) cầm dao như cũ.
- Chương 2–4 không có thân: không đổi gì.

## 6. Kiểm tra
**Ảnh và video** (bắt buộc, tự xem lại từng tấm trước khi báo xong):
- Chụp 1080p trong **cảnh chương 1 thật** (`chapter1.tscn`, `Chapter1Director.auto_start = false`), bằng một cảnh tạm trong `game/_probe_tmp/` (không commit, xóa trước khi commit).
  - Cảnh thử `protagonist_pilot` có sẵn chế độ chụp và góc nhìn ngoài người (`_capture`, `_show_third_person`) để tham khảo.
- Mỗi lỗi: góc mắt người chơi và một góc bên ngoài, ở các mốc quan trọng.
  - **Điện thoại:** giơ lên, cầm thấp, đang chuyển.
  - **Cửa:** chạm tay nắm, giữa lúc quay, lúc buông. Có cả đóng từ trong, mở từ trong, đóng từ ngoài, mở từ ngoài.
  - **Lấy giấy:** chạm, kẹp, nhấc.
  - **Cầm đọc:** thẻ sinh viên, giấy dòng kẻ, ảnh.
- Thêm vài đồ cùng loại khác, tối thiểu: ảnh Việt, thẻ Phúc trên nóc tủ (với nhón chân), mẩu giấy của Khoa dưới gầm giường (với quỳ).
- Lưu `art_source/graphics_upgrade/protagonist/previews/t239/after_*.jpg`, thêm một tấm ghép trước/sau cho mỗi lỗi.
- Nên có video ngắn cho cửa và lấy giấy, ví dụ `build/graphics/protagonist/t239_*.mp4`, không commit.
- **Đã biết:** chụp có cửa sổ lúc đọc mẩu giấy của Khoa từng bị treo hai lần (D-152), chạy headless thì không. Gặp lại thì ghi cách tái hiện vào Handoff, đừng mất thời gian quá lâu.

**Test tự động mới** trong `game/tests/player/`:
- **Không xuyên:** điểm dọc các đốt ngón (gồm ngón cái và đầu ngón, cộng bán kính ngón đo trên mesh Tripo) không lọt vào hộp điện thoại ở cả hai tư thế. Với tờ giấy lúc đọc: ngón cái ở mặt trước, các ngón khác ở mặt sau, không đốt nào cắt mặt giấy trong phạm vi tờ.
- **Cửa:**
  - Kiểm đúng quy tắc chủ dự án chọn ở mục 4, ở nhiều chỗ đứng: phía đông và phía tây cánh, trong phòng và ngoài hành lang, với cánh đóng, mở và đang quay.
  - Đứng trong phòng thì không bao giờ chọn tay nắm mặt ngoài.
  - `can_reach` và `perform` chọn cùng một chỗ cầm.
  - Không đốt nào của tay phải cắt hộp cánh cửa trong suốt thao tác.
  - Lúc tay đang cầm, khoảng cách tay–chỗ cầm nhỏ hơn một ngưỡng; lane B đặt ngưỡng và ghi lý do.
- **Lấy giấy:** tờ giấy chỉ rời chỗ khi đầu ngón cái và ngón trỏ đã ở mép giấy.
- Có thể sửa test cũ nếu ngưỡng cũ không còn đúng (ví dụ `test_protagonist_chapter1.gd` đo tay tới đồ trong `0.06 + finger_reach`), nhưng phải ghi lý do trong Handoff.
- Các nhóm test cũ phải đạt: `protagonist`, `hand_targets`, `ch1_bunks`, `room407`, `player_death`, `manager`, `mirror`.

**Trước commit:** full `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`.
- Theo luật Lượt Godot: khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt`, mỗi lần chỉ chạy một lượt Godot nặng, không tắt Godot của lane khác.
- Chạy bằng tiến trình pwsh riêng, log vào `build/`. Mỗi lượt khoảng 25 phút.
- Sau đó: `git checkout -- game/default_bus_layout.tres`.

## Được phép sửa
- `game/scripts/player/`: `player_body.gd`, `hand_align_modifier.gd`, `protagonist.gd`, các modifier, thêm file mới.
- `game/scripts/interaction/`: `door_handles.gd`, `hand_target.gd`.
- `game/scripts/core/interactable.gd`: **chỉ hàm `hand_target()`** và chú thích của nó. Thay đổi khác ghi "Yêu cầu thay đổi".
- `game/scenes/main/chapter1_main.gd`:
  - kiểu cầm và điểm cầm trong `PAPERS`;
  - vị trí giấy chỉ khi tờ giấy đang xuyên đồ khác (ví dụ ảnh 4). Phải giữ test với tới D-152 đạt và ghi lại vào Handoff.
- `game/scenes/interaction/readable.tscn`, `game/scripts/interaction/readable.gd`: chỉ phần `HandTarget`.
- `game/scenes/levels/graphics_pilot/protagonist_pilot.*` (cảnh thử).
- `game/assets/models/characters/protagonist/`: import, bone map, tư thế ngón mới; không thay mesh Tripo.
- `art_source/graphics_upgrade/protagonist/` (Blender, ảnh), `game/tests/player/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `game/scripts/entity/hand_grip_modifier.gd` (quản lý dùng), `door407.gd`, director, rule, phần khác của `game/scripts/core/`, phòng 407.
- Không tiêu credit Tripo: nếu thấy cần làm lại tay trên Tripo thì ghi đề xuất cho chủ dự án. Không chạy bot, không đo FPS.
- Không sửa STATUS, DECISIONS. Không commit `anh_chup_sua_loi/`, `game/_probe_tmp/`, log.
- Thấy lỗi ở thao tác tay khác (công tắc, dây mạng, ổ điện, chốt cửa, tủ, nan giường…): **chỉ ghi lại** trong Handoff (ảnh, mô tả), không sửa trong card này.

## Checklist hoàn thành
- [ ] Đã đo và ghi nguyên nhân thật của từng lỗi (khớp hay khác mục 2)
- [ ] Lỗi 1 điện thoại: không xuyên ở hai tư thế và lúc chuyển; ảnh trước/sau
- [ ] Lỗi 2 cửa: chỗ cầm đúng quy tắc chủ dự án chọn (mục 4), trong phòng không dùng tay nắm ngoài, tay không cắt cánh; tay bám chỗ cầm khi đóng và mở; ảnh, video
- [ ] Lỗi 3 cầm giấy đọc: kẹp mép, ngón cái trước, ngón khác sau, không xuyên; ảnh trước/sau
- [ ] Lỗi 4 lấy giấy: kẹp rồi mới nhấc; ảnh trước/sau; đã kiểm tờ giấy vắt qua cuốn sổ
- [ ] Mọi giấy, thẻ, ảnh chương 1 dùng cách cầm mới (kể cả với nhón chân, rướn, quỳ)
- [ ] Câu hỏi mục 4 đã đưa chủ dự án, kèm đề xuất
- [ ] Test tự động mới cho cả 4 lỗi; nhóm test cũ đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt
- [ ] Handoff trung thực: cách sửa, số đo trước/sau, commit hash, ảnh ở đâu, phần chưa kiểm

## Cách kiểm tra (integrator)
- Xem ảnh trước/sau, đọc diff, chạy full test và check.
- Build `KyTucXa.exe` cho chủ dự án chơi thử lại bốn chỗ này.

## Handoff (agent điền)
