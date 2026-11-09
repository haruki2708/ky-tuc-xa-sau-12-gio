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
| **Giấy dưới đất, thùng rác** | mẩu giấy của Khoa (trên sàn trước ổ điện), lục thùng rác (`SearchTrashBin`) | **Cúi gập, gối hơi chùng:**<br>- đứng rồi gập người xuống, đầu gối chùng một chút như người cúi nhặt đồ;<br>- **không** ngồi xổm;<br>- camera đi theo vừa đủ, không thấy tóc hay gáy của chính mình. |
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
  - người chơi không khom, trừ những đồ đã ghi là phải ngồi xổm;
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
- `game/scenes/levels/room407/room407_anchors.tscn`: chỉ vị trí các anchor đồ trên bàn (`DatNote`, `VietLaptop`, `GuitarSongbook`, `VietPhoto`), và chỉ khi phải dời đồ. Sửa test vị trí liên quan (`game/tests/levels/test_room407_fixes.gd`) nếu có.
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
