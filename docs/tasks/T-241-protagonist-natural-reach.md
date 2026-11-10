# T-241 — Lấy đồ tự nhiên: đứng yên với đồ trên bàn, cúi gập với đồ dưới thấp (chủ dự án chơi thử 10/11)
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141), Opus 5.5 (effort do chủ dự án đặt; đề xuất max như T-239 vì đụng IK cả thân)
- Nhánh: `lane-b/T-241-protagonist-natural-reach` từ `origin/main` mới nhất (có merge T-239 `450157a` và card này).
- Quyết định giao: **D-156** (10/11/2026). Chủ dự án chơi bản `build/windows/KyTucXa.exe` 10/11 01:02 (build từ `9d1fde9`, đã có T-239):
  - **Khen:** "động tác cầm đã trông tự nhiên hơn rồi". Giữ nguyên cách cầm của T-239.
  - **Chê:** "khoảng cầm thẻ sinh viên và tờ giấy (thiếu tự nhiên)". Chủ dự án muốn:
    - lấy đồ ở bàn thì chỉ đứng im rồi với tay lấy;
    - chỉ lấy giấy dưới đất và lục thùng rác mới cúi người.
- **T-240 (khảo sát) chờ card này merge** (D-156: chủ dự án chọn T-241 trước, T-240 sau).
- Bối cảnh cần đọc:
  - Handoff [T-239](T-239-protagonist-hand-fixes.md): cách đo trên xương đã dựng, cách chụp trong chương 1.
  - [T-227](T-227-protagonist-tripo-body-motions.md) mục cuối: D-152, rướn, quỳ, nhón.
  - Đầu file `game/scripts/player/player_body.gd`.

## 1. Chủ dự án đã chốt (D-156, 10/11)
| Nhóm | Đồ (lấy danh sách thật bằng code, xem mục 6) | Động tác chốt |
|---|---|---|
| **Đồ trên bàn** | giấy Đạt, thẻ Đạt, thẻ Việt, bảng tab trên sổ hợp âm, ảnh Việt, và mọi đồ khác nằm trên mặt bàn | **Đứng yên, gập hông nhẹ:**<br>- chân không bước, gót không nhấc;<br>- thân gập **tối đa khoảng 30–45°**, phần còn lại do cánh tay;<br>- **không** ngồi xổm hay khom, **không** rướn sâu, **không** nhón chân. |
| **Giấy dưới đất, thùng rác** | mẩu giấy của Khoa (trên sàn trước ổ điện, sát mép giường dưới), lục thùng rác (`SearchTrashBin`) | **Cúi gập, gối hơi chùng:**<br>- đứng rồi gập người xuống, đầu gối chùng một chút như người cúi nhặt đồ;<br>- **không** ngồi xổm;<br>- camera đi theo vừa đủ, không thấy tóc hay gáy của chính mình.<br>Nếu giường cản người cúi tới mẩu giấy Khoa thì xem mục 3 "Dời đồ" và mục 4. |
| **Thứ thấp khác** | ổ điện, ổ mạng, dây mạng sát chân tường, lục đệm giường dưới (`SearchPhucMattress`), và mọi thứ dùng tay khác nằm thấp | **Cúi gập như đồ dưới đất.** Chỉ ngồi xổm khi cúi gập không với tới; ghi rõ những đồ nào phải ngồi xổm. |
| **Không đổi** | đồ cao phải nhón chân (thẻ Phúc, ảnh nhóm, thời khóa biểu Phúc), cửa 407, công tắc, gõ tường, chốt cửa… ở tầm đứng | Giữ như hiện tại (D-152, T-239). |

- **Đồ trên bàn nằm quá sâu:** người chơi phải bước lại gần thì lời nhắc mới hiện. Nếu đứng ở mọi chỗ thân người vừa vẫn không với được theo cách trên, **dời đồ ra gần mép bàn** (xem mục "Được phép sửa"). Không được nới giới hạn gập.
- **Nghĩa là thay phần "rướn người, quỳ" của D-152** cho đồ trên bàn và đồ thấp. Nhón chân với đồ cao vẫn giữ.

## 2. Nguyên nhân integrator đọc ra từ code (lane B tự đo để xác nhận)
- **Chọn cách với** (`_judge_goal`, khoảng dòng 1316) theo thứ tự:
  1. `near`: gập ≤ `MAX_BEND` 45°, hoặc nhón chân;
  2. `up`: nhón và rướn ≤ 45°;
  3. `lean`: rướn tới `LEAN_BEND` **75°**;
  4. `kneel`: khom (`player._set_crouched(true)`), rồi gập tới `KNEEL_BEND` **85°**.
  
  Đồ nằm sâu trong bàn rơi vào `lean` hoặc `kneel`. Lane B T-239 ghi: thẻ Đạt, giấy Đạt, bảng tab, ảnh Việt là `lean`. Test D-152 in ra `near 7, kneel 10, lean 4, up 2`, đo ở chỗ đứng gần nhất tìm được, không phải chỗ đứng tự nhiên nhất.
- **Lúc làm động tác cách với có thể nặng hơn lúc hiện lời nhắc.**
  - `perform()` (khoảng dòng 410–440) với giấy thì lấy đích là lòng bàn tay (`_pinch_palm`) và chấm lại bằng `_judge_goal(palm, GRIP)`, không cộng `finger_reach`.
  - Cộng thêm `PICK_SLACK` 3 cm.
  - Vì vậy một đồ trên bàn mà lời nhắc chấm là `near`/`lean` có thể bị làm thành `kneel`: thân ngồi thụp cạnh bàn (ảnh `compare_3_cam_giay.jpg`, khung "Nhìn từ ngoài").
- **Gập chỉ ở cột sống:** `SpineBendModifier` chia góc gập cho `Spine`, `Chest`, `UpperChest`; hông không gập, mông không lùi ra sau. Gập 60–85° như vậy trông như gập ở bụng, không giống người thật (người thật gập ở hông, mông lùi, gối chùng giữ thăng bằng).
- **Clip:**
  - `reach` = `ual/Interact`: tay trái nắm lại giơ trước ngực, lane B ghi ở Handoff T-239.
  - `reach_low` = `ual/PickUp_Table`.
  - `kneel` dùng `ual/Crouch_Idle`.
  - Chưa có tư thế cúi gập có gối chùng.
- **Camera:** `LEAN_FOLLOW` 0,6, chỉ theo 60% độ cúi của đầu, nên khi rướn qua bàn thấy gáy và tóc (Handoff T-239).

## 3. Cách làm (gợi ý, lane B quyết và ghi lý do)
- **Chia cách với theo độ cao của chỗ cầm so với bàn chân** (không theo tên đồ):
  - cao: nhón, như cũ;
  - tầm bàn: đứng gập ≤ 45°;
  - thấp: cúi gập có gối chùng, ngồi xổm chỉ khi cúi không tới.
  
  Lane B đo độ cao thật của mọi đồ rồi đặt ngưỡng, ghi bảng vào Handoff. Mặt bàn phòng 407 khoảng 0,75–0,8 m.
- **Lời nhắc và động tác dùng cùng một luật:** `can_reach` hiện thì `perform` làm đúng cách đó, không leo thang (bỏ hoặc giới hạn việc chấm lại bằng lòng bàn tay trong `perform`).
- **Gập ở hông:**
  - Phần lớn góc gập ở hông (`Hips`, hoặc xoay khung chậu), phần nhỏ ở cột sống. Hông lùi ra sau để trọng tâm vẫn trên bàn chân, gót không nhấc, chân không trượt.
  - Có thể làm bằng modifier mới, hoặc clip mới dựng trong Blender trên khung xương Trần Trung.
  - Trước khi tự dựng clip, xem gói Quaternius UAL/UAL2 (CC0, đã dùng) có clip cúi nhặt đồ hợp không.
- **Cúi gập có gối chùng:**
  - một tư thế hoặc clip với gối chùng khoảng 15–40° và hông gập sâu;
  - có thể pha tư thế đứng với `Crouch_Idle` cho riêng chân, hoặc dựng trong Blender;
  - không hạ capsule người chơi như lúc khom.
- **Tay trái** lúc tay phải với đồ:
  - buông tự nhiên bên người, hoặc tì nhẹ lên mép bàn hay đầu gối khi cúi;
  - nếu đang cầm điện thoại thì giữ cách cầm của T-239;
  - không còn nắm tay giơ trước ngực.
- **Camera:**
  - đi theo đầu đủ để thấy chỗ tay lấy đồ;
  - không bao giờ thấy tóc, gáy, cổ của chính mình;
  - được thấy tay, cánh tay, đùi và chân;
  - không lộn, không giật.
- **Dời đồ:** chỉ khi không chỗ đứng nào với được theo luật mới.
  - Dời ít nhất có thể, ra phía mép mà người chơi đứng được.
  - Đồ dời không được xuyên đồ khác (sổ, laptop, cốc bút…), phải nằm hẳn trên mặt bàn.
  - Ghi vị trí cũ và mới.

## 4. Chỗ phải hỏi chủ dự án (phương án kèm đề xuất, kèm ảnh hoặc video)
- **1 giây có đủ cho cúi nhặt dưới đất không** (D-121: mỗi thao tác 1 giây)?
  - Nếu cúi xuống rồi đứng lên trong 1 giây trông vội, đưa ảnh hoặc video của 1 giây và của bản dài hơn (ví dụ 1,4 giây) cho chủ dự án chọn.
  - Không tự đổi.
- **Đồ trên bàn phải dời xa hơn 10 cm:** hỏi trước, kèm ảnh vị trí cũ và mới.
- **Mẩu giấy Khoa:** nếu thành giường cản người cúi gập (đầu hoặc lưng chạm giường) mà dời ra ≤ 10 cm vẫn không đủ, đưa chủ dự án hai phương án kèm ảnh:
  - (a) dời mẩu giấy ra xa giường hơn;
  - (b) riêng đồ này ngồi xổm.
  
  Integrator nghiêng về (a), vì chủ dự án đã chốt đồ dưới đất thì cúi gập.
- Có chỗ khác cần chọn về kiểu động tác mà card chưa nói thì hỏi theo cùng cách.

## 5. Phải giữ nguyên
- Cách cầm T-239 (dáng ngón, cầm đọc, nhấc mép rồi kẹp, điện thoại, cửa 407 theo phía) và mọi test T-239.
- Mỗi thao tác 1 giây (D-121, trừ khi chủ dự án chọn khác ở mục 4); phải đứng gần mới dùng được (D-124).
- Mọi đồ dùng tay của chương 1 vẫn với tới được từ ít nhất một chỗ đứng (D-152: 23/23 khi có mẩu giấy Khoa). Nếu tổng đổi thì ghi lý do.
- Chết thì thả giấy, cất thân (D-151). Thân nằm giường lúc đầu chương. Gương hiện thân.
- Quản lý (`manager_body.tscn`) không đổi. Chương 2–4 không có thân.

## 6. Kiểm tra
**Bảng đồ (bắt buộc, trong Handoff):**
- Lấy danh sách bằng code, cùng vòng lặp với `test_every_hand_thing_can_be_reached_from_a_standing_spot`, có đặt mẩu giấy Khoa.
- Mỗi đồ một dòng: tên, độ cao chỗ cầm, nhóm (cao / bàn / thấp), cách với trước và sau, góc gập trước và sau, có dời không.

**Ảnh** (1080p, chương 1 thật, cảnh tạm trong `game/_probe_tmp/` rồi xóa; tự xem lại từng tấm):
- Đồ trên bàn: giấy Đạt, thẻ Đạt, thẻ Việt, bảng tab, ảnh Việt. Mỗi đồ chụp góc mắt lúc chạm và góc ngoài người lúc chạm, thấy cả thân và chân.
- Mẩu giấy Khoa, thùng rác, một ổ điện thấp, đệm giường dưới: góc mắt lúc chạm, góc ngoài lúc chạm, góc ngoài lúc đứng lên.
- Lưu `art_source/graphics_upgrade/protagonist/previews/t241/after_*.jpg`.
- Thêm ảnh ghép trước/sau cho từng nhóm (`compare_ban.jpg`, `compare_thap.jpg`). Ảnh "trước" chụp ở `origin/main` lúc bắt đầu.
- **Nên có video ngắn** (lấy thẻ Đạt, lấy mẩu giấy Khoa, lục thùng rác), vì chủ dự án chê chuyển động, không chỉ tư thế. Để trong `build/`, không commit; Handoff ghi đường dẫn.

**Test tự động mới** trong `game/tests/player/`, đo trên xương đã dựng như T-239:
- **Đồ trên bàn,** suốt thao tác:
  - người chơi không khom (`crouched` false);
  - gót không nhấc;
  - mỗi bàn chân trượt ≤ 2 cm;
  - góc gập thân ≤ 45°, đo bằng góc giữa trục hông–ngực và phương thẳng đứng.
- **Đồ dưới đất, thùng rác, thứ thấp:**
  - người chơi không khom. Riêng thứ thấp khác (không phải giấy dưới đất hay thùng rác) được ngồi xổm khi cúi không tới, và phải ghi tên. Mẩu giấy Khoa chỉ được ngồi xổm nếu chủ dự án chọn (b) ở mục 4;
  - gối chùng trong khoảng lane B đặt, ghi lý do;
  - gót không nhấc;
  - tay tới chỗ cầm như ngưỡng hiện có.
- **Lời nhắc và động tác cùng một luật:** với mọi đồ, ở mọi chỗ đứng mà `can_reach` đúng, cách với lúc `perform` thuộc đúng nhóm của đồ đó.
- **Camera không thấy đầu mình:** suốt mọi cách với, camera không nằm sau hay trong đầu, cổ của thân. Ví dụ camera luôn ở trước xương `Head` theo hướng mặt một khoảng tối thiểu, hoặc cách đo khác lane B chọn.
- **Tay trái:** khi không cầm điện thoại thì không giơ cao trước ngực lúc tay phải với đồ. Lane B đặt ngưỡng độ cao.
- Sửa test D-152 (`test_protagonist_chapter1.gd`, `test_lean_crouch_and_toes_put_the_hand_on_the_thing`) cho đúng luật mới. Ghi lý do trong Handoff.
- Nhóm test cũ phải đạt: `protagonist`, `t239`, `hand_targets`, `ch1_bunks`, `room407`, `player_death`, `manager`, `mirror`.

**Trước commit:** full `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`.
- Theo luật Lượt Godot: khóa `D:\GAME_WORK\GODOT_DANG_CHAY.txt`, mỗi lần một lượt nặng, không tắt Godot của lane khác.
- Chạy bằng tiến trình pwsh riêng, log trong `build/`.
- Sau đó: `git checkout -- game/default_bus_layout.tres`.

## Được phép sửa
- `game/scripts/player/`: `player_body.gd`, `protagonist.gd`, các modifier (`spine_bend_modifier.gd`, `tiptoe_modifier.gd`, `hand_align_modifier.gd`, `finger_pose_modifier.gd`…), thêm file mới.
- `game/scripts/player/player.gd`: **chỉ** phần camera hoặc khom mà thân cần (ví dụ cho thân đặt độ cao mắt khi cúi). Thay đổi khác ghi "Yêu cầu thay đổi".
- `game/assets/models/characters/protagonist/`: import, clip mới dựng trên khung xương Trần Trung; không thay mesh Tripo.
- `game/assets/models/characters/standin/`: chỉ thêm clip UAL/UAL2 CC0 vào danh sách dùng.
- `game/scenes/main/chapter1_main.gd`: chỉ vị trí đồ trong `PAPERS`, theo mục 3 "Dời đồ".
- `game/scenes/levels/room407/room407_anchors.tscn`, chỉ khi phải dời đồ:
  - vị trí các anchor đồ trên bàn: `DatNote`, `VietLaptop`, `GuitarSongbook`, `VietPhoto`;
  - `KhoaNoteSlot`: dời ra xa giường ≤ 10 cm, xa hơn thì hỏi (mục 4).
  
  Sửa test vị trí liên quan trong `game/tests/levels/test_room407_fixes.gd` (`KhoaNoteSlot` đang bị test giữ ở (30.55, .015, −1.8), D-152).
- `game/scenes/levels/graphics_pilot/protagonist_pilot.*` (cảnh thử).
- `art_source/graphics_upgrade/protagonist/` (Blender, ảnh, README, CREDITS), `game/tests/player/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không đổi cách cầm của T-239. Không sửa `game/scripts/entity/hand_grip_modifier.gd`, `door407.gd`, director, rule, `game/scripts/core/`.
- Không nới giới hạn gập cho đồ trên bàn để khỏi dời đồ.
- Không tiêu credit Tripo, không chạy bot, không đo FPS.
- Không sửa STATUS, DECISIONS. Không commit `anh_chup_sua_loi/`, `game/_probe_tmp/`, log, video.
- Thấy lỗi ở động tác khác (đi, chạy, nằm giường, điện thoại…): chỉ ghi lại trong Handoff để T-240 khảo sát.

## Checklist hoàn thành
- [x] Đã đo và ghi nguyên nhân thật (khớp hay khác mục 2)
- [x] Bảng mọi đồ dùng tay: độ cao, nhóm, cách với trước/sau, góc gập trước/sau, đồ đã dời
- [x] Đồ trên bàn: đứng yên, gập ≤ 45°, không khom, không nhón, không rướn sâu; ảnh trước/sau
- [x] Đồ dưới đất và thùng rác: cúi gập, gối chùng, không ngồi xổm; ảnh trước/sau
- [x] Thứ thấp khác: cúi gập; ghi rõ đồ nào phải ngồi xổm và vì sao
- [x] Lời nhắc và động tác cùng một luật; camera không thấy tóc hay gáy; tay trái không giơ nắm trước ngực
- [x] Câu hỏi mục 4 (nếu có) đã đưa chủ dự án, kèm đề xuất
- [x] Test tự động mới; nhóm test cũ và test T-239 đạt
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt
- [x] Handoff trung thực: cách sửa, số đo trước/sau, commit, ảnh, video, phần chưa kiểm

## Cách kiểm tra (integrator)
- Xem ảnh trước/sau, đọc diff, chạy full test và check sau merge.
- Build `KyTucXa.exe` cho chủ dự án chơi thử lấy đồ trên bàn và dưới đất.
- Báo chủ dự án dán prompt T-240.

## Handoff (agent điền)

### Kết quả (lane B, 10/11/2026)
Nhánh `lane-b/T-241-protagonist-natural-reach`, tạo từ `73c4d1e` (card đọc ở commit `73c4d1e`). Commit: `f3ea1ce` (gập ở hông, luật theo độ cao), `4f4d595` (chỉnh theo ảnh, dời thẻ Việt), `1966bb1` (test), `a9188a0` (ảnh, README, CREDITS, nhịp đứng lên), và commit card này.
Full `pwsh tools/test.ps1`: 904 đạt, 0 lỗi (10/11, 17:12–17:42, log `build/t241/full_test.log`, không commit). `pwsh tools/check.ps1`: 0 lỗi (17:42–18:10, `build/t241/full_check.log`); sau đó đã `git checkout -- game/default_bus_layout.tres`. Hai lượt chạy ở commit `a9188a0`; sau đó chỉ thêm 5 ảnh và card này.

**Chờ chủ dự án chọn (mục 4), xem "Câu hỏi cho chủ dự án" bên dưới.** Mặc định trong code đang là 1 giây (D-121 chưa đổi).

### Nguyên nhân đo được (ở `origin/main` `73c4d1e`, trước khi sửa)
Khớp mục 2 của card, thêm hai điểm card chưa nói. Log: `build/t241/table_before.log`, `posture_before.log` (không commit).
- **Lời nhắc hiện đầu tiên ở chỗ nặng nhất.** Cách với càng nặng thì với càng xa, nên khi người chơi bước lại gần, lời nhắc hiện đầu tiên ở vùng `kneel`. Giấy Đạt: 37/39 chỗ đứng là `kneel`. Thẻ Việt: chỉ 1 chỗ đứng, `kneel`. Công tắc đèn bàn: 27/27 `kneel`. Vì vậy gần như lần nào cũng ngồi thụp cạnh bàn.
- **Động tác nặng hơn lời nhắc:** thẻ Đạt lời nhắc `lean` ở 9 chỗ, lúc làm chỉ 2 chỗ còn `lean`, 7 chỗ thành `kneel`. Bảng tab lời nhắc `up` ở 7 chỗ, lúc làm thành `lean` hoặc `kneel`.
- **Gập chỉ ở cột sống:** đặt 75° thì trục hông–cổ nghiêng 55–57°, hông không lùi.
- **Clip:** `ual/Interact` dời bàn chân 22–43 cm, nhấc mũi chân 7–9 cm, đưa cổ tay trái lên 42–44 cm (nắm tay trước ngực). `ual/PickUp_Table` đưa tay trái lên 18–22 cm.
- **Camera:** theo 60% và trễ một khung hình, nên nằm sau xương `Head` 20–35 cm (theo hướng mặt) mỗi khi rướn hay quỳ; lúc đứng là trước 6–10 cm.
- **Thêm 1:** lúc nhón chân và lúc quỳ, clip `idle`/`Crouch_Idle` bị phát nhanh gấp 5,6 lần (chạy hết clip trong 1 giây).
- **Thêm 2:** clip `idle` của Trần Trung tự dời mắt cá 9,7 cm và vai phải khoảng 5 cm trong mỗi chu kỳ 5,6 giây, gối đổi 5–36°. Phép chấm tầm với cũ lại đo trên khung đầu clip, nên tay lệch chỗ đã tính vài cm.

### Cách sửa
- **Luật mới, chia theo độ cao chỗ cầm so với bàn chân** (`_judge_goal`, không theo tên đồ):
  - **từ 0,6 m trở lên** (`near`): đứng yên, gập ở hông tối đa `MAX_BEND` 40° (hông 80%, lưng 20%), vai với xoay ra trước tối đa 25°, hông lùi 2 cm. Kẹp và móc với tới đầu ngón. Không với tới thì không hiện lời nhắc (người chơi bước lại gần, D-124).
  - **cao hơn vai 20 cm** (`OVERHEAD`): nhón chân như T-227, D-152, giữ nguyên.
  - **dưới 0,6 m** (`stoop`): cúi gập tới `STOOP_BEND` 130° (hông 75%), hông lùi 16 cm, hạ 12 cm để gối chùng, vai với hạ 30°.
  - **Thân không tự ngồi xổm nữa.** Bỏ `lean` 75° và việc tự khom. `kneel` chỉ còn khi người chơi tự bấm khom: thân với từ tư thế khom.
- **Lý do chọn 40°, không lấy hết 45°:** người chơi thường bấm ngay khi lời nhắc hiện, tức ở chỗ xa nhất, nên góc tối đa chính là dáng hay thấy nhất. 40° đặt ra cho trục hông–ngực nghiêng 25–30° đo được ("gập hông nhẹ").
- **Lý do ngưỡng 0,6 m:** đứng gập 40°, tay duỗi thẳng chỉ xuống tới khoảng 0,55–0,6 m. Trong chương 1 không có đồ nào nằm giữa 0,35 m và 0,76 m.
- **Lời nhắc và động tác một luật:** `can_reach` và `perform` cùng gọi `_reaches`; `perform` giữ đúng cách với đã chấm (`_plan`), không chấm lại bằng lòng bàn tay để leo thang. Giấy nằm ngoài tầm lòng bàn tay thì đầu ngón kéo trượt lại gần như T-239 (tối đa 12 cm). Ảnh đứng trong khung thì lời nhắc xét theo chỗ lòng bàn tay kẹp tới được, không kéo ảnh ra khỏi khung.
- **Gập ở hông:** `BodyLeanModifier` mới (`game/scripts/player/body_lean_modifier.gd`) xoay khung chậu quanh khớp háng, dời hông, chia phần gập cho cột sống, ngửa cổ lại, giải lại hai chân để bàn chân đứng nguyên chỗ, tay trái buông theo trọng lực. `PlayerBody._leaned` tính vai và mắt bằng đúng các bước đó.
- **Clip nền:** mọi thao tác tay đứng trên `idle`, giữ yên khung hiện tại trong lúc với; tầm với chấm trên chính tư thế đó (`_joints`). Không còn phát `ual/Interact`, `ual/PickUp_Table`.
- **Bàn tay phải giữ như T-239:** dưới lớp cong ngón vẫn lấy dáng ngón của clip cũ (`ual/Interact` cho đồ từ 0,95 m; bàn tay mở của `ual/Crouch_Idle` cho đồ thấp hơn), vì nền `idle` nắm tay lại. `hand_grip_modifier.gd` không đổi.
- **Camera:** đặt đúng mắt theo tư thế đã tính của khung hình đó (không trễ, không còn 60%). Có chặn 12 cm trước tường (`_clear`). Chỗ nào cúi mà đầu chạm tường, tủ, giường thì không hiện lời nhắc (`_head_free`).
- **Nhịp cúi:** đồ thấp buông tay ở 0,62 giây (không phải 0,8), để đứng lên có 0,38 giây thay vì 0,2 giây.
- `player.gd` không đổi.

### Bảng 23 đồ dùng tay của chương 1
Lấy bằng cùng vòng lặp với `test_every_hand_thing_can_be_reached_from_a_standing_spot`, có đặt mẩu giấy Khoa. "Số chỗ đứng" là số điểm thân người chơi đứng vừa (vòng 0,25–1,2 m, 48 hướng) mà lời nhắc hiện. "Chỗ xa nhất" là nơi lời nhắc hiện đầu tiên khi bước lại gần. Góc "trước" là góc cong cột sống đặt ra; góc "sau" là tổng hông và lưng.

| Đồ | Độ cao (m) | Nhóm | Trước: số chỗ đứng theo cách với | Trước, chỗ xa nhất | Sau: số chỗ đứng | Sau, chỗ xa nhất | Dời |
|---|---|---|---|---|---|---|---|
| `Switch1` (ổ cắm kéo dài) | 0,06 | thấp | quỳ 61 | quỳ, 75° | cúi 89 | cúi, 130° | không |
| `Switch2` | 0,06 | thấp | quỳ 88 | quỳ, 75° | cúi 158 | cúi, 130° | không |
| `Switch3` | 0,06 | thấp | quỳ 115 | quỳ, 75° | cúi 196 | cúi, 130° | không |
| `Cable_blue` (đầu dây mạng) | 0,02 | thấp | quỳ 83 | quỳ, 80° | cúi 137 | cúi, 125° | không |
| `Cable_gray` | 0,02 | thấp | quỳ 75 | quỳ, 80° | cúi 117 | cúi, 125° | không |
| `Ch1KhoaNote` (giấy Khoa) | 0,05 | thấp | quỳ 9 | quỳ, 80° | cúi 24 | cúi, 130° | không |
| `SearchTrashBin` (thùng rác) | 0,18 | thấp | quỳ 208 | quỳ, 60° | cúi 296 | cúi, 125° | không |
| `LanSocket` (ổ mạng) | 0,35 | thấp | quỳ 11 | quỳ, 50° | cúi 14 | cúi, 115° | không |
| `Ch1VietCard` (thẻ Việt) | 0,76 | bàn | quỳ 1 | quỳ, 25° | đứng 10 | đứng, 40° | 10 cm ra mép trước bàn |
| `DeskLampSwitch` (đèn bàn) | 0,79 | bàn | quỳ 27 | quỳ, 15° | đứng 16 | đứng, 40° | không |
| `Ch1DatNote` (giấy Đạt) | 0,80 | bàn | rướn 2, quỳ 37 | quỳ, 25° | đứng 37 | đứng, 40° | không |
| `Ch1DatCard` (thẻ Đạt) | 0,80 | bàn | rướn 2, quỳ 38 | quỳ, 10° | đứng 40 | đứng, 40° | không |
| `Ch1TapChart` (bảng tab) | 0,83 | bàn | rướn 28, quỳ 69 | quỳ, 25° | đứng 103 | đứng, 40° | không |
| `Ch1VietPhoto` (ảnh Việt) | 0,85–0,92 | bàn | rướn 6, quỳ 11 | quỳ, 20° | đứng 11 | đứng, 40° | không |
| `SearchVietLocker` (tủ Việt) | 1,00 | tầm đứng | gần 44, nhón 45, rướn 27 | rướn, 75° | đứng 142 | đứng, 40° | không |
| `Door407` | 1,05 | tầm đứng | gần 84, rướn 53 | rướn, 75° | đứng 142 | đứng, 40° | không |
| `DoorLatch407` (chốt) | 1,06 | tầm đứng | gần 71, rướn 39 | rướn, 70° | đứng 146 | đứng, 40° | không |
| `SearchPhucMattress` (đệm Phúc) | 1,20 | tầm đứng | gần 38, nhón 28, rướn 32 | rướn, 75° | đứng 132 | đứng, 40° | không |
| `DatLocker` (tủ Đạt) | 1,24 | tầm đứng | gần 30, nhón 26, rướn 9 | rướn, 75° | đứng 84 | đứng, 40° | không |
| `WallKnock406` (gõ tường) | 1,30 | tầm đứng | gần 14, nhón 11 | nhón, 45° | đứng 39 | đứng, 35° | không |
| `Ch1PhucCard` (thẻ Phúc) | 1,70 | cao | gần 14, nhón 30 | nhón, 35° | gần 14, nhón 30 | nhón, 35° | không |
| `Ch1PhucSchedule` (thời khóa biểu) | 1,60–1,87 | cao | nhón 10 | nhón, 35° | nhón 10 | nhón, 35° | không |
| `Ch1TeamPhoto` (ảnh nhóm) | 1,86–1,93 | cao | nhón 11 | nhón, 30° | nhón 11 | nhón, 30° | không |

- Tổng: 23/23 với tới được (D-152 in ra `near` 13, `stoop` 8, `up` 2). Không đồ nào phải ngồi xổm.
- **Khác card:** `SearchPhucMattress` cao 1,20 m (đệm giường tầng trên), nên thuộc tầm đứng, không phải đồ thấp.
- Số "trước" của `LanSocket` và `WallKnock406` gồm cả chỗ đứng bên kia tường (phép chấm tầm với không xét tường; trong game tia nhìn bị tường chặn nên không hiện lời nhắc). Số "sau" chỉ tính chỗ đứng nhìn thấy đồ.
- **Thẻ Việt:** `PAPERS`, offset so với anchor `VietLaptop` từ (0,27; −0,148; 0,03) thành (0,27; −0,148; −0,07). Vị trí cũ cách mép trước bàn 34 cm, mới 24 cm. Chỗ mới trống: cách mép phải laptop 5 cm, không chạm hộp cơm hay ấm.

### Số đo sau (trên xương đã dựng, ở chỗ đứng xa nhất)
Log: `build/t241/posture_final.log`, `table_final.log`, test `test_t241_reach.gd`.
| Số đo | Trước | Sau |
|---|---|---|
| Đồ trên bàn: thân có tự khom | có, gần như mọi chỗ đứng | không |
| Đồ trên bàn, tầm đứng: trục hông–cổ nghiêng | 40–58° (quỳ, rướn) | 32–38° (trục hông–ngực, cái test đo: 25–30°) |
| Bàn chân trượt trong lúc với | 22–43 cm (clip với tay), 33 cm (quỳ) | ≤ 1 cm |
| Gót và mũi chân nhấc (không tính nhón) | mũi chân 5–10 cm, gót tới 1,3 cm | ≤ 0,5 cm |
| Camera so với xương `Head` theo hướng mặt | sau đầu 20–35 cm | trước đầu 6–10 cm, như lúc đứng |
| Cổ tay trái lên so với lúc buông | 42–44 cm (đồ tầm đứng), 18–22 cm (bàn) | ≤ 1 cm |
| Đồ thấp: góc gối | 125° (ngồi xổm) | 61–73° (đứng đầu clip: 36°) |
| Đồ thấp: mắt xuống thấp nhất | 0,78–0,96 m | 0,39–0,73 m |
| Lời nhắc khác động tác | 14 chỗ đứng (thẻ Đạt 7, bảng tab 7) | 0 trong 1044 chỗ đứng |

### Ảnh và video
- Ảnh sau, 1080p, chương 1 thật: `art_source/graphics_upgrade/protagonist/previews/t241/after_*.jpg` (38 tấm; `den_pin` = tay trái cầm điện thoại bật đèn pin; `ban` = đồ trên bàn, `thap` = đồ thấp, `dung` = tầm đứng; `_mat` mắt người chơi, `_ngoai` nhìn từ ngoài; số là phần trăm giây).
- Ảnh ghép trước/sau: `previews/t241/compare_ban.jpg`, `compare_thap.jpg`. Ảnh "trước" chụp ở `73c4d1e`.
- Ảnh chụp ở chỗ đứng xa nhất còn hiện lời nhắc, bật đèn trần để thấy thân (chương 1 thật tắt đèn trần).
- Video (không commit): `build/t241/video/t241_lay_do_1_0_giay.mp4` (thẻ Đạt, giấy Khoa, thùng rác, công tắc ổ điện; mỗi đồ một lần mắt người chơi, một lần nhìn từ ngoài) và `build/t241/video/t241_cui_nhat_1_4_giay.mp4` (ba đồ thấp, cúi 1,4 giây).
- Đã tự xem từng tấm ảnh và các khung hình của hai video.

### Câu hỏi cho chủ dự án (mục 4)
1. **Cúi nhặt đồ dưới thấp: 1 giây hay dài hơn?**
   - (a) Giữ 1 giây (D-121). Mắt đi xuống khoảng 1,1 m rồi lên lại trong 1 giây, khá gấp.
   - (b) **Đề xuất:** 1,4 giây cho riêng đồ thấp (8 đồ ở chương 1). Đồ trên bàn và tầm đứng vẫn 1 giây. Giá phải trả: người chơi bị khóa di chuyển thêm 0,4 giây mỗi lần nhặt đồ dưới sàn.
   - Đổi bằng một dòng: `PlayerBody.stoop_seconds`. Xem hai video ở trên.
2. **Dời đồ quá 10 cm:** không có. Chỉ thẻ Việt dời đúng 10 cm.
3. **Mẩu giấy Khoa:** cúi gập lấy được từ 24 chỗ đứng, đầu không chạm tủ hay giường. Không cần dời, không cần ngồi xổm.
4. **Cửa, chốt, tủ, gõ tường (tầm đứng):** giờ cũng đứng yên, gập hông tối đa 40°, tay trái buông. Lý do: clip `ual/Interact` là nguồn của bước chân và nắm tay trước ngực, và kiểu rướn 75° đã bỏ. Tầm với cửa còn 0,65 m (trước 0,75 m). Nếu chủ dự án muốn giữ dáng cũ cho riêng cửa thì báo lại.
5. **Độ sâu khi cúi:** tay Trần Trung ngắn hơn người thật khoảng 10%, nên với đồ sát sàn thân gập 115–130° và mắt xuống còn 0,4–0,5 m. Muốn nông hơn thì phải cho gối chùng nhiều hơn (gần ngồi xổm) hoặc nâng đồ lên.

### Test
- **Mới:** `game/tests/player/test_t241_reach.gd`, 7 test:
  - đồ từ tầm bàn trở lên (12 đồ, chỗ đứng xa nhất): `near`, không khom, gót ≤ 1,5 cm, chân trượt ≤ 2 cm, trục hông–ngực ≤ 45°, camera trước đầu ≥ 3 cm, tay trái lên ≤ 10 cm, tay tới chỗ cầm;
  - đồ thấp (8 đồ): `stoop`, không khom, góc gối 50–80°, gót, chân, camera, tay như trên;
  - đồ cao (3 đồ): camera vẫn trước đầu;
  - lời nhắc và động tác trùng nhau ở 1044 chỗ đứng, đúng nhóm theo độ cao, góc trong giới hạn;
  - vai và camera nằm đúng chỗ đã tính (lệch < 1,5 cm và < 3 cm);
  - thân không tự khom; người chơi tự khom thì với từ tư thế khom;
  - `stoop_seconds` kéo dài đúng thời gian đặt, thao tác khác vẫn 1 giây.
- **Ngưỡng gối 50–80°:** góc gối đo trên khớp là 36° lúc đứng (đầu clip `idle`) và 125° lúc ngồi xổm. 50–80° là chùng thêm 15–45°, chưa tới nửa đường xuống ngồi xổm. Đo được 61–73°.
- **Sửa:** `test_protagonist_chapter1.gd`, `test_lean_crouch_and_toes_put_the_hand_on_the_thing` thành `test_standing_bending_down_and_toes_put_the_hand_on_the_thing`. Lý do: test cũ đòi phải có một lần `kneel` và kiểm thân tự khom rồi tự đứng lên, đúng là điều D-156 bỏ. Test mới đòi có `near`, `stoop`, `up`, không có `kneel`, `lean`, và thân không khom.
- **Nhóm cũ, chạy riêng đều đạt:** `protagonist` 26, `t239` 6, `hand_targets` 6, `ch1_bunks` 5, `room407` 75, `player_death` 16, `manager` 32, `mirror` 6; `t241` 7.

### Chưa kiểm hoặc còn hạn chế
- Chưa chơi bằng tay. Mọi kiểm tra là test tự động, ảnh và video chụp tự động.
- **Tay trái cầm điện thoại bật đèn pin** (trường hợp hay gặp vì phòng tối): đã chụp thẻ Đạt, giấy Khoa, thùng rác (`previews/t241/after_den_pin_*.jpg`). Tay trái giữ đúng cách cầm T-239 và đi theo camera cả khi cúi. Hạn chế: điện thoại đặt theo camera, nên khi cúi sát thùng rác mép máy chạm vành thùng. Chưa có test tự động cho trường hợp này.
- Ở sát mép tầm với, lời nhắc có thể hiện rồi tắt theo nhịp lắc của clip `idle` (vai lắc khoảng 5 cm mỗi 5,6 giây), vì tầm với giờ chấm trên tư thế đang đứng. Bước thêm vài cm là hết.
- Từ lúc đứng yên tới lúc với, clip `idle` dừng tại khung hiện tại; thở và lắc người ngừng trong 1 giây đó.
- Chương 2–4 chưa có thân, nên luật mới chưa chạy ở đó. Khi đưa thân vào cần đo lại từng đồ.
- `kneel` (người chơi tự khom rồi với) chỉ có test trong cảnh thử, chưa có ảnh.

### Lỗi ở chỗ khác, chỉ ghi lại cho T-240
- Clip `idle` của Trần Trung tự dời mắt cá gần 10 cm mỗi chu kỳ, gối đổi 5–36°: đứng yên mà chân trượt.
- Bắt đầu thao tác tay thì thân quay thẳng theo hướng nhìn ngay lập tức (T-227), nếu chân đang lệch thì có một cú xoay tức thì.
- `WallKnock406` và `LanSocket` có chỗ cầm nằm trong tường khoảng 10 cm; phép chấm tầm với không xét tường (lời nhắc vẫn đúng vì tia nhìn bị chặn).
- Khi mở cửa 407 từ trong mà đứng gần bản lề, cánh quét qua chỗ người đứng (đã ghi ở T-239).

**Yêu cầu thay đổi ngoài phạm vi:** không có.
