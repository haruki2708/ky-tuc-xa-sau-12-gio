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
- [ ] Đã đo và ghi nguyên nhân thật (khớp hay khác mục 2)
- [ ] Bảng mọi đồ dùng tay: độ cao, nhóm, cách với trước/sau, góc gập trước/sau, đồ đã dời
- [ ] Đồ trên bàn: đứng yên, gập ≤ 45°, không khom, không nhón, không rướn sâu; ảnh trước/sau
- [ ] Đồ dưới đất và thùng rác: cúi gập, gối chùng, không ngồi xổm; ảnh trước/sau
- [ ] Thứ thấp khác: cúi gập; ghi rõ đồ nào phải ngồi xổm và vì sao
- [ ] Lời nhắc và động tác cùng một luật; camera không thấy tóc hay gáy; tay trái không giơ nắm trước ngực
- [ ] Câu hỏi mục 4 (nếu có) đã đưa chủ dự án, kèm đề xuất
- [ ] Test tự động mới; nhóm test cũ và test T-239 đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt
- [ ] Handoff trung thực: cách sửa, số đo trước/sau, commit, ảnh, video, phần chưa kiểm

## Cách kiểm tra (integrator)
- Xem ảnh trước/sau, đọc diff, chạy full test và check sau merge.
- Build `KyTucXa.exe` cho chủ dự án chơi thử lấy đồ trên bàn và dưới đất.
- Báo chủ dự án dán prompt T-240.

## Handoff (agent điền)

### Đang làm dở (lane B, 10/11/2026) — lưu tiến độ, CHƯA xong
Nhánh `lane-b/T-241-protagonist-natural-reach`, tạo từ `73c4d1e` (card đọc ở commit `73c4d1e`). Phiên dừng vì hết lượt dùng; phiên sau làm tiếp từ mục "Còn lại".

**Đã xong:**
- **Đo "trước" ở `origin/main`** (log trong `build/t241/`, không commit: `table_before.log`, `posture_before.log`, `map_before.log`, `what.log`). Khớp mục 2 của card:
  - Đồ trên bàn: chỗ đứng gần nhất là `lean` (cột sống cong 70–75°), mọi chỗ xa hơn là `kneel`. Ví dụ giấy Đạt 37/39 chỗ đứng là `kneel`, thẻ Việt chỉ có 1 chỗ đứng (`kneel`), công tắc đèn bàn 27/27 `kneel`. Người chơi bấm ngay khi lời nhắc hiện (chỗ xa nhất), nên gần như lần nào cũng ngồi thụp.
  - Động tác nặng hơn lời nhắc: thẻ Đạt lời nhắc `lean` ở 9 chỗ, lúc làm chỉ 2 chỗ còn `lean`, 7 chỗ thành `kneel`; bảng tab lời nhắc `up` ở 7 chỗ, lúc làm thành `lean`/`kneel`.
  - Camera sau đầu 20–35 cm mỗi khi rướn hay quỳ (đo camera so với xương `Head` theo hướng mặt: −0,20…−0,35 m; lúc đứng +0,07 m), nên thấy gáy và tóc.
  - Clip `ual/Interact`: bàn chân dời 22–43 cm, mũi chân nhấc 7–9 cm, cổ tay trái lên cao hơn lúc đứng 42–44 cm (nắm tay trước ngực). `ual/PickUp_Table`: tay trái lên 18–22 cm.
  - Gập chỉ ở cột sống: đặt 75° thì trục hông–cổ chỉ nghiêng 55–57°.
- **Độ cao chỗ cầm (23 đồ, đo bằng code):**
  - sàn: công tắc ổ cắm kéo dài `Switch1–3` 0,06 m; đầu dây mạng `Cable_blue/gray` 0,02 m; giấy Khoa 0,05 m; thùng rác 0,18 m; ổ mạng `LanSocket` 0,35 m;
  - bàn: thẻ Việt 0,76; công tắc đèn bàn 0,79; giấy Đạt, thẻ Đạt 0,80; bảng tab 0,83; ảnh Việt 0,85–0,92;
  - tầm đứng: tủ Việt 1,00; cửa 407 1,05; chốt 1,06; **đệm Phúc 1,195 (giường tầng trên, không phải đồ thấp như card ghi)**; tủ Đạt 1,24; gõ tường 1,30;
  - cao: thẻ Phúc 1,70; thời khóa biểu 1,60–1,87; ảnh nhóm 1,86–1,93.
- **Ảnh "trước"** 1080p, chương 1 thật (bật đèn trần để thấy thân): `build/t241/shots/before/*.png` (34 tấm, chưa chép vào `previews/t241/`).
- **Code (commit WIP, chưa chạy full test):**
  - `game/scripts/player/body_lean_modifier.gd` (mới): gập ở hông (xoay khung chậu quanh khớp háng, hông lùi và hạ), chia phần nhỏ cho cột sống, vai với xoay ra trước, cổ ngửa lại; giải lại hai chân để bàn chân đứng nguyên chỗ, gót không nhấc; tay trái buông theo trọng lực.
  - `player_body.gd`: luật mới theo độ cao chỗ cầm (không theo tên đồ):
    - từ 0,6 m trở lên: `near` = đứng yên, gập hông tối đa `MAX_BEND` 45° (hông 80%, lưng 20%), kẹp/móc với tới đầu ngón; cao quá tay thì nhón như cũ (`up` chỉ còn cho đồ cao hơn vai);
    - dưới 0,6 m: `stoop` = cúi gập tới `STOOP_BEND` 130°, hông lùi 16 cm, hạ 12 cm cho gối chùng;
    - thân không tự ngồi xổm nữa; `kneel` chỉ còn khi người chơi tự khom. Bỏ `lean` 75°.
    - `perform` làm đúng cách lời nhắc đã chấm, không leo thang (`_reaches`, `_plan`).
    - Mọi thao tác tay dùng clip `idle` làm nền (bỏ `ual/Interact`, `ual/PickUp_Table`).
    - Camera đặt đúng mắt theo tư thế đã tính của khung hình này (`_follow_head`, không trễ khung, không còn 60%), có chặn không cho chui vào tường (`_clear`).
    - `stoop_seconds` (mặc định 1 giây) để quay bản 1,4 giây cho chủ dự án so.
  - Chạy `pwsh tools/test.ps1 -Filter protagonist_body`: 18 đạt, 0 lỗi. **Chưa chạy** nhóm `t239`, `protagonist_chapter1`, full test, check.

**Còn lại (theo thứ tự):**
1. Chạy `-Filter t239` và `-Filter protagonist_chapter1`; chạy probe `--mode=table` và `--mode=posture` để có số "sau". Probe tạm ở `game/_probe_tmp/t241_probe.gd` (không commit; mất thì viết lại theo mô tả trong file), chạy bằng `build/t241/run_godot.ps1` (tự giữ khóa Lượt Godot).
2. Xem ảnh "sau", chỉnh hằng số (`STAND_*`, `STOOP_*`), kiểm gối chùng +15…+40° so với lúc đứng.
3. Xét đồ nào không còn với tới theo luật mới rồi dời ra mép bàn (dự đoán: công tắc đèn bàn, giấy Đạt, thẻ Việt, có thể ảnh Việt). Dời quá 10 cm thì hỏi chủ dự án.
4. Giấy Khoa: nằm ở miệng khe giữa tủ Việt và giường (khe rộng 0,45 m, người chơi không vào được), đứng gần nhất cách 0,33 m; phải kiểm đầu có chạm tủ hay giường khi cúi, nếu chạm thì đưa hai phương án (a)/(b) ở mục 4.
5. `LanSocket` nằm giữa bàn Việt và kệ giày (kệ cao 0,45 m): kiểm cúi qua kệ giày.
6. Test mới trong `game/tests/player/` (mục 6), sửa `test_lean_crouch_and_toes_put_the_hand_on_the_thing`.
7. Ảnh sau, ảnh ghép `compare_ban.jpg`, `compare_thap.jpg`, video 1 giây và 1,4 giây; README, CREDITS.
8. Full `pwsh tools/test.ps1`, `pwsh tools/check.ps1`, `git checkout -- game/default_bus_layout.tres`, commit, push, điền Handoff đầy đủ.

**Sẽ báo chủ dự án (chưa quyết):**
- Cửa, công tắc, gõ tường ở tầm đứng giờ cũng đứng yên, tay trái buông (vì clip `ual/Interact` là nguồn của bước chân và nắm tay trước ngực). Tầm với cửa ngắn lại khoảng 10 cm so với kiểu rướn 75° cũ.
- Câu hỏi mục 4 (1 giây hay dài hơn, dời đồ quá 10 cm, giấy Khoa) chờ có ảnh và video "sau".

**Yêu cầu thay đổi ngoài phạm vi:** chưa có.
