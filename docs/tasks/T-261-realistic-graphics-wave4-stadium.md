# T-261 — Đồ hoạ thật đợt 4: sân vận động, khán đài, dải nối vườn → sân vận động
- Lane: B | Trạng thái: **done** (giao 15/11/2026, D-176; chọn D-178; merge `e0bb9e8` 15/11) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1o).
- Nhánh: `lane-b/T-261-realistic-graphics-wave4-stadium` từ `origin/main` mới nhất.
- Quyết định nền: **D-166** (đồ hoạ thật dựng bằng Blender, không PS1, không Tripo trừ khi chủ dự án đổi; ánh sáng giữ như nay), **D-167/D-172** (phong cách nhà B đợt 1–2: cũ vừa phải), **D-175** (vườn đợt 3: sân block xám, viền quét vôi, đèn cầu: dải nối phải khớp mép vườn), **D-176** (giao đợt này; chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ). Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 4 (A13 + một phần A16).
- Làm như đợt 3 (T-259): **lượt 1 góc mẫu rồi dừng chờ chủ dự án chọn; lượt 2 làm cả khu.**

## 0. Hiện trạng (HARU khảo sát 15/11; lane B kiểm lại ở bước 1)
- `game/scenes/levels/campus/stadium.tscn` (gốc `Stadium` trong `campus.tscn`, transform gốc 0), dùng ở **chương 3 và 4**. Toàn PS1: 8.340 tam giác, 38 vật liệu, khối 176 × 119 × 18 m (T-248 A13). Ảnh hiện trạng: `realistic_map/previews/survey/28_stadium_entry.jpg`, `29_stadium_stands.jpg`, `30_stadium_track.jpg`.
- Tâm sân khoảng (198; −9,9; 166). Node gốc: `TrackBounds` (va chạm), `Grass`, `RunningSurface`, `Lane0…7`, `StartLane0…6`, `PitchLine*`, `PitchEdge*`, hai khung thành `Goal±1`, `GoalPost*`, `GoalCross*`; khán đài `MainBleachers` (khán đài chính có mái, phía z ≈ 213–228), `SecondaryBleachers` (bê tông, va chạm, meta `surface = concrete`); 9 cột mái `RoofColumn0…8`; 12 đoạn hàng rào `Fence0…11`; 12 trụ cổng `GatePost<x>_<z>_±5` (6 cổng: hai đầu x 110 và 286 ở z 166; bốn cổng ở x 148, 248 phía z 120 và z 212); 4 cột đèn pha `Pole0…3` và 16 chao `FloodHousing*`; đồ rải trên khán đài và sân `Stand_*` (MultiMesh hộp/trụ: rào chạy vượt, ghế, giấy…).
- **Đèn pha `Floodlights`**: 4 `OmniLight3D` (năng lượng 12, tầm 145 m, không bóng), **mặc định tắt**. `chapter3_director._stadium()` gọi `campus.set_stadium_lights(true)` khi vào đoạn sân vận động (cảnh doạ `stadium_lights`), tắt lại khi xong (`campus.gd` dòng 75: chỉ đổi `Stadium/Floodlights.visible`).
- Truyện chương 3 ở sân (`_stadium()`): tới `Anchors/Start_stadium` (115; −9,9; 166, cổng tây); sống sót **240 giây** trong khi xác sống ra từng đợt ở `Anchors/ZombieSpawns/Stadium/*` (6 điểm), đứng chờ ở `ZombieIdle/Stadium/*` (6 điểm); vùng `Zones/Stadium` (tâm 198; −3,9; 166) và `Zones/Bleachers` (tâm 198; −5,65; 220,75) quyết định "đang ở sân", "đang ở khán đài" (còi báo `SirenSpot` (198; −3,25; 227,6) trên khán đài chính). Thanh sắt: `Anchors/BarSpawns/B02` (154; −9,9; 221) và `B03` (164; −9,82; 225,5) **dưới gầm khán đài chính**.
- Code, test, bot dùng sân: `chapter3_director.gd`, `campus.gd`, `ch3_audio_bank.gd`, `ch3_environment.gd`, `ch3_music.gd`, `reverb_zone.gd`, `ch3_bot.gd`, `ch3_menu*.gd`, `ch3_policy.gd`, `tools/ch3-profile.json`; test `test_stands_props.gd` (T-192: khán đài cao có mái sát đường chạy, người chơi thật đi từ đường chạy lên hàng cao nhất, chui vào gầm khán đài nhặt thanh sắt, navigation vườn → sân → cổng → nhà ăn → khán đài, **ngân sách tam giác `TRIANGLE_BUDGET_STADIUM = 12000`**), `test_campus.gd`, `test_chapter3.gd`, `test_ch3_*`, `test_ch2_4_hand_targets.gd`, `test_t249_chapter3_bar.gd`.
- Hiệu năng: **đây là trận nặng nhất chương 3** (xác sống ra liên tục 4 phút, sân rộng nhìn được nhiều thứ cùng lúc, 4 đèn pha tầm 145 m). PLAN mục 6: A13 **≤ 0,50 ms** thêm; khán đài lặp dùng instancing, mái xa nhẹ.
- D-149: bot sân vận động (T-238) hoãn tới khi sân có đồ hoạ mới. Sau đợt này HARU hỏi chủ dự án có chạy T-238 không; lane B không chạy bot.

## 1. Chủ dự án chốt
**D-178 (15/11/2026):** chủ dự án xem ảnh lượt 1 (`previews/wave4/options_*.jpg`, `floodlights.jpg`) và chọn cả bảy câu theo đề xuất (phương án a):
1. Đường chạy: **R1 cao su đỏ bạc màu, nứt**, vạch sơn mòn khoảng 1/3.
2. Mặt sân: **C1 cỏ thật úa loang lổ**, trọc ở cầu môn.
3. Khán đài chính: **S1 bậc bê tông trần**, không ghế nhựa. Khán đài phụ làm cùng kiểu.
4. Cột đèn pha: **L1 thép côn mạ kẽm**; 4 đèn pha giữ nguyên, kính chao chỉ sáng khi `Floodlights` bật.
5. Hàng rào: **H1 lưới B40 trên cột ống**, trụ cổng trát vôi; cánh cổng mở gập sát rào phía ngoài, không chắn lối.
6. Mái tôn khung thép: **giữ 3 tấm bị mất** ở đầu hồi tây.
7. **Được thay đồ rải PS1 trong sân** (rào vượt, ghế, giấy, chai trong `props.tscn` và `Stand_*`), ngoài dải A16 (mục 8 đã mở thêm). **Không đụng mảnh xác, vệt kéo sẫm, thùng rác**, va chạm và điểm gameplay; hình PS1 chỉ ẩn.

## 2. Việc, theo hai lượt

### Lượt 1 — khảo sát và góc mẫu, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi Handoff:** kiểm lại mục 0; grep mọi chỗ code, test, bot, âm thanh đụng tới sân (`stadium.tscn`, `Stadium/`, `Floodlights`, `Bleachers`, `Start_stadium`, `ZombieSpawns/Stadium`, `BarSpawns/B02`, `B03`, `SirenSpot`, `TrackBounds`, `MainBleachers`, `GatePost`); lập **bảng hợp đồng** (node nào giữ tên, vị trí, va chạm). **Đi thử tuyến vườn → cổng tây sân** (đường đồng đội và bot đi, `tools/ch3-profile.json`) và **chốt hộp dải nối A16** của đợt này (gợi ý: từ mép sau vườn x 40…112, z 40…175; lane B chỉnh theo tuyến thật), liệt kê chính xác đường dẫn node A16 trong hộp.
2. **Góc mẫu** quanh cổng tây và góc khán đài chính gần `B02`/`B03`: một đoạn đường chạy và vạch, một mảng sân cỏ có khung thành, một đoạn khán đài chính (bậc, ghế ngồi, mái, cột, gầm khán đài nơi có thanh sắt), một cột đèn pha, một đoạn hàng rào và cổng. Dựng bằng Blender, chất lượng ngang nhà B đợt 1–2 và vườn đợt 3. Kèm **phương án để chủ dự án chọn bằng mắt** (ảnh cùng camera, chương 3 thật, ban đêm, **cả lúc đèn pha tắt và bật**, có và không đèn pin):
   - **đường chạy**: màu và mức cũ (ví dụ cao su đỏ bạc màu, nứt; hay xỉ than/đất nện như sân trường Việt Nam cũ);
   - **mặt sân**: cỏ (cỏ thật úa loang lổ, cỏ nhân tạo cũ);
   - **khán đài chính**: bậc bê tông trần, hoặc có ghế nhựa (màu), mái tôn khung thép;
   - **cột đèn pha, hàng rào (lưới B40 hay song sắt), cổng**: phương án đề xuất (một hoặc hai).
   Mỗi phương án ghi số tam giác, vật liệu, số lần vẽ. Đề xuất một phương án.
3. Commit, push nhánh, ghi Handoff, **báo và dừng**. HARU chuyển phương án cho chủ dự án, ghi lựa chọn vào mục 1.

### Lượt 2 — làm cả khu (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
4. **Sân vận động (A13):** đường chạy, vạch, sân cỏ, hai khung thành, hai khán đài, mái và cột, hàng rào, sáu cổng, bốn cột đèn pha và chao, đồ rải (`Stand_*`: rào vượt, ghế đổ, giấy, chai…) theo đúng vị trí và va chạm cũ. Khán đài dùng module lặp (MultiMesh hoặc một lưới gộp theo vật liệu), mái và khán đài xa có bản xa.
5. **Dải nối vườn → sân (A16, chỉ trong hộp đã chốt ở bước 1).** Khớp mép vườn đợt 3.
6. Ảnh trước/sau, ảnh ghép, test, full test, check, Handoff.

## 3. Phạm vi A16 trong đợt này
- **Chỉ** mặt đất, đường, viền, rãnh, đồ rải (rác, giấy, gạch vỡ) **trong hộp lane B chốt ở bước 1** giữa mép sau vườn và cổng tây sân. Không đụng phần đã làm ở T-259 (x −6…50, z 4…50) trừ đường khớp mép.
- **Không** đụng đường ra cổng, chốt bảo vệ, nhà ăn, nhà nền, cây xa (đợt 5–7). Không thay MultiMesh nhẹ bằng hàng nghìn node.
- Mảnh xác tĩnh, vệt kéo sẫm, thùng rác: không đụng (như T-259).

## 4. Hợp đồng gameplay (bắt buộc giữ)
- Không đổi tên, gốc, transform của các node có va chạm và các node code dùng: `Stadium`, `TrackBounds`, `MainBleachers`, `SecondaryBleachers` (và meta `surface`), `RoofColumn*`, `Fence*`, `GatePost*`, `Pole*`, `Floodlights` và 4 đèn (vị trí, năng lượng, màu, tầm, bóng); trong `campus.tscn`: `Anchors/Start_stadium`, `Anchors/ZombieSpawns/Stadium/*`, `Anchors/ZombieIdle/Stadium/*`, `Anchors/BarSpawns/B02`, `B03`, `Anchors/Clues/SirenSpot`, `Zones/Stadium`, `Zones/Bleachers`, navigation.
- **Va chạm giữ nguyên** (test so dấu vân tay với main như T-259): đường chạy, khán đài, bậc, mái, cột, hàng rào, cổng, cột đèn.
- Người chơi vẫn đi được từ đường chạy lên hàng cao nhất khán đài chính, chui vào gầm khán đài nhặt thanh sắt `B02`/`B03`; tuyến đồng đội, xác sống, bot (toạ độ `tools/ch3-profile.json`) không bị đồ mới chặn; bậc, ghế mới không làm người chơi kẹt.
- **Đèn pha:** giữ cơ chế tắt/bật hiện có (`campus.set_stadium_lights`). Chao đèn mới **phát sáng theo `Floodlights.visible`** (tắt thì tối, bật thì sáng), không thêm đèn, không đổi 4 đèn có sẵn. Mặc định (trước đoạn sân) đèn pha tắt như nay.
- Hình PS1 chỉ ẩn (`visible = false`), không xoá. Không đổi luật, thời gian 240 giây, số đợt xác, lời thoại, director, âm thanh, vùng reverb.
- `test_stands_props.gd`: các test đi lại, gầm khán đài, navigation, cổng **phải đạt không sửa**. Riêng `TRIANGLE_BUDGET_STADIUM` (ngân sách của hình PS1): được đổi cách đếm cho lớp hình thật (ví dụ chỉ đếm hình PS1, và test mới kiểm ngân sách riêng của lớp thật); ghi lý do trong Handoff, không chỉ nâng số.

## 5. Kỹ thuật và hiệu năng
- **Dựng bằng script Blender** (Blender 5.2.2 portable ở `D:\Tools\Blender\5.2.2`). Được dùng texture, mesh **CC0** (Poly Haven, ambientCG…) nếu ghi URL, tác giả, giấy phép trong CREDITS. **Không cài extension/addon Blender, không Tripo, không ảnh AI.**
- Dùng lại bộ vật liệu, màu đã duyệt khi hợp (thép sơn xanh, bê tông, đá mài của đợt 1–2; sân block, vôi của đợt 3). Cỏ: MultiMesh theo cụm hoặc texture, **không** hàng nghìn node; thẻ cỏ alpha cắt, không đổ bóng.
- Ngân sách (PLAN mục 6): sân **≤ 0,50 ms** thêm; ghi số tam giác, vật liệu, số lần vẽ cho góc mẫu và cả sân, **ở góc nhìn rộng nhất** (từ cổng tây nhìn cả sân, từ hàng cao nhất khán đài nhìn xuống), cả lúc đèn pha bật. Khán đài, mái, hàng rào xa dùng bản xa hoặc `visibility_range`.
- **Mọi texture mới từ 512 px trở lên phải nén VRAM:** `.import` đặt `compress/mode=2`, normal thêm `compress/normal_map=1`. Ghi bộ nhớ hình chương 3 trước/sau.
- Occlusion culling (D-174) đã bật: khán đài kín có thể thêm occluder hình hộp, nhưng occluder thuộc cảnh core (`game/scenes/main/occlusion/`): **không tự thêm**, ghi vào "Yêu cầu thay đổi" nếu thấy đáng.
- Không đo FPS, không chạy bot (HARU hỏi chủ dự án sau merge).

## 6. Ảnh
- `art_source/graphics_upgrade/realistic_map/previews/wave4/`: lượt 1 `pilot_*` và bảng phương án; lượt 2 `before_*`/`after_*` cùng camera trong **chương 3 thật**: cổng tây (`Start_stadium`), giữa sân, khán đài chính từ đường chạy, hàng cao nhất khán đài nhìn xuống, gầm khán đài chỗ thanh sắt, cột đèn pha, dải nối vườn → sân; **cả đèn pha tắt và bật**; ảnh ghép tổng `overview.jpg`. Ban đêm như chương, có và không đèn pin.

## 7. Kiểm
- Test mới `game/tests/levels/test_t261_*.gd`:
  - dấu vân tay va chạm sân, khán đài, hàng rào, cổng, cột đèn trùng main; node, anchor, vùng, 4 đèn giữ nguyên; hình PS1 ẩn;
  - capsule đi được từ `Start_stadium` vào sân, từ đường chạy lên hàng cao nhất, vào gầm khán đài tới `B02`/`B03`; thanh sắt nằm trên mặt đất (không lơ lửng, không chìm);
  - chao đèn mới tối khi `Floodlights` tắt, sáng khi bật;
  - **mọi `.import` texture trong thư mục asset đợt 4 có `compress/mode=2`** (normal có `compress/normal_map=1`); glb chỉ dùng vật liệu chung;
  - dải A16 nằm trong hộp đã chốt và chỉ ẩn đồ PS1 trong hộp.
- Test cũ đạt: `test_stands_props` (trừ ngân sách như mục 4), `test_campus`, `test_t259*`, `test_t251*`, `test_chapter3`, `test_chapter4`, `test_ch3_*`, `test_ch2_4_hand_targets`, `test_t249*`, `test_graphics_bindings`, `test_t260_occlusion`. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## 8. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave4/`, `.../previews/wave4/`, `game/assets/models/graphics_pilot/realistic_map/wave4/`, `game/assets/textures/graphics_pilot/realistic_map/wave4/`, `game/assets/models/graphics_pilot/realistic_map/CREDITS.md` (thêm mục `wave4/`), `game/scenes/levels/campus/stadium.tscn`, `campus.tscn` và `props.tscn` (chỉ phần hình A16 trong mục 3, và theo D-178 đồ rải trong sân vận động trừ mảnh xác, vệt kéo, thùng rác), `campus.gd` (chỉ phần đèn sân nếu cần cho chao đèn), script cảnh mới trong `game/scenes/levels/campus/`, `game/tests/levels/test_stands_props.gd` (chỉ cách đếm ngân sách, mục 4), test mới `game/tests/levels/`, card này (Checklist, Handoff).
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `chapter*.tscn`, occluder core; sửa vườn (T-259) ngoài đường khớp mép, nhà B, tầng 4; khu ngoài mục 3.
- Tripo, credit Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [x] Lượt 1: khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp và danh sách node A16 (Handoff)
- [x] Lượt 1: góc mẫu và phương án (đường chạy, cỏ, khán đài, đèn pha, hàng rào, cổng), ảnh đèn tắt/bật; dừng chờ chủ dự án chọn
- [x] Lượt 2: cả sân vận động
- [x] Lượt 2: dải nối vườn → sân
- [x] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
### Lượt 2 (15/11/2026, D-178, lane B, Claude Opus 5.5) — xong, chờ review
Nhánh rebase lên `origin/main` `072b7bb` (card mục 1), đẩy lại bằng `--force-with-lease` một lần. Làm đúng phương án a
và hai ý thêm của D-178. Cách dựng lại, số liệu đầy đủ: `art_source/graphics_upgrade/realistic_map/wave4/README.md`
(mục "Lượt 2").

**Đã làm**
- **`stadium.tscn`:** 114 node hình PS1 chỉ ẩn (`Grass`, lưới tường hai khán đài, trụ cổng, cột đèn, dải đường chạy và
  vạch, khung thành, 16 chao, mọi `Stand_*`); không xoá node nào. Node mới `Real` (`stadium_real.gd`): `Field` (R1 đường
  cao su đỏ bạc màu, vạch sơn mòn khoảng 1/3; C1 cỏ thật úa, trọc ở cầu môn, đủ vạch sân; bó vỉa; nền quanh đường chạy),
  `MainStand` (S1 bê tông trần, mái tôn trên vì kèo thép sơn xanh, thiếu 3 tấm ở đầu hồi tây; gầm có ống sắt chỗ B03),
  `SouthStand` (S1, 7 bậc, không mái như PS1), `Fences` (H1 lưới B40 cả 12 đoạn, 12 cánh cổng gập sát rào phía ngoài
  0,14 m), `Pillars` (12 trụ trát vôi), `Goals/Goal0…1`, `Poles/Pole0…3` (L1, chao quay về tâm sân), `Props`.
- **Đèn pha:** 4 đèn và cơ chế `campus.set_stadium_lights` giữ nguyên (`campus.gd` không sửa). Kính chao là một vật liệu
  chung, sáng khi `Floodlights` hiện, tối khi ẩn (tín hiệu `visibility_changed`, không xử lý mỗi khung).
- **Đồ rải trong sân (D-178 câu 7):** trong `props.tscn` thu cỡ về 0 (giữ mục) 274 bản PS1: 15 rào vượt (30 cột, 15
  thanh), 9 túi thể thao, 18 ba lô và 18 túi trước, 22 chiếc giày, 5 khay và 5 tờ giấy lót, 9 thùng gỗ dưới khán đài, 105
  tờ giấy, 14 dép, 12 điện thoại. Bản mới (`stadium_props.glb`) đặt đúng chỗ, đúng góc từng mảnh PS1, giữ màu PS1 của túi,
  giày, dép. Mảnh xác, máu, vệt nứt và vệt kéo sẫm, thùng rác giữ nguyên; va chạm của thùng gỗ giữ nguyên. Rào vượt bị
  đổ có chân lún tới 10 cm vào nền như bản PS1.
- **Dải A16** (`campus.tscn`, hộp x 50…110, z −11…176 đã chốt ở lượt 1): ẩn `Road/WestBranch/Mesh`,
  `Road/StadiumWestAccess/Mesh`; node mới `StripGardenStadium` (`garden_real.gd` của đợt 3): bãi cỏ mòn (lối từ vườn ra
  đường, mép đường, dải đất xác sống đi tới cổng tây), đường lát gạch block con sâu của vườn (D-175 P1) có vệt bánh xe và
  vũng nước sát bó vỉa, bó vỉa bê tông, 96 mẩu giấy rác và 2 đống gạch vỡ (22 khối, 6 ống) đúng chỗ PS1 (99 bản PS1 thu cỡ
  về 0; `Decals/D_paper_quad_p0_p0` ẩn cả node vì phần còn lại của nó, sau T-259, đều nằm trong hộp). Mặt đường giữ cao
  độ mặt đường PS1 để vệt nứt PS1 vẫn nằm trên mặt đường. Mép x 50 khớp dải của vườn đợt 3 (cùng texture cỏ, cùng cao độ, cùng cách đặt UV).
- **Gỡ phương án không chọn** khỏi `game/` (ghế nhựa, cột bê tông, rào song sắt, đường xỉ than, cỏ nhân tạo); script vẫn
  dựng lại được (README).
- **`test_stands_props.gd`** (card mục 4): chỉ đổi cách đếm `TRIANGLE_BUDGET_STADIUM`: đếm hình PS1 của `Stadium`, bỏ
  qua `Real` (hình PS1 vẫn còn, đã ẩn; ngân sách 12.000 vẫn đúng cho phần đó). Lớp thật có ngân sách riêng 36.000 trong
  `test_t261_stadium` (đang 29.266 tam giác, 27 mesh). Các test đi lại, gầm khán đài, navigation, cổng không sửa, vẫn đạt.

**Hợp đồng** (`test_t261_stadium`, dấu vân tay lấy từ bản `origin/main` `072b7bb` của ba scene): va chạm sân
`30bb677d…` (53), node, transform, meta, 4 đèn và `Floodlights` `be790db1…` (257 node), anchor, vùng, navigation của
campus `2d7e21ae…` (1.079 dòng), va chạm `props.tscn` `97c2301b…` (175), 2.303 bản đồ rải giữ nguyên `10295745…`: tất cả
trùng main. Capsule đi được từ `Start_stadium` vào sân, từ đường chạy lên hàng cao nhất, vòng cổng tây bắc vào gầm tới
B03, tới B02; nền mới dưới B02, B03 cao hơn sàn va chạm 4 mm, không có gì mới treo thấp hơn 2,2 m trên chỗ thanh sắt; trong
gầm hai khán đài không có gì mới thấp hơn 1,9 m (ngoài cột, nằm trong khối va chạm `RoofColumn*`); rào, trụ, chân cột đèn
nằm sát khối va chạm cũ; 11 texture mới đều nén VRAM; glb chỉ dùng vật liệu chung.

**Số liệu** (chương 3, cùng camera với ảnh trước): số lần vẽ cổng tây 628 → 562, `Start_stadium` 139 → 89, giữa sân
74 → 57, khán đài từ mép sân 70 → 54, đầu hồi tây 1.465 → 1.404, cột đèn 712 → 708; dải A16: 973 → 925, 166 → 108,
1.540 → 1.490. Bốn góc rộng nhìn cả khu thêm 56…90 lần vẽ; primitive ở các góc này dao động khoảng ±250 nghìn giữa hai lần
chạy cùng scene, nên đo riêng bằng cách bật/tắt `Real`: lớp mới thêm khoảng 18–27 nghìn. Bộ nhớ hình chương 3 tăng khoảng
11 MB (1.267…1.270 → 1.278…1.281 MB). Không đo FPS, không chạy bot.

**Ảnh:** `art_source/graphics_upgrade/realistic_map/previews/wave4/`: `before_*`, `after_*` (13 góc: cổng tây ngoài và
trong, giữa sân, khán đài chính từ mép sân, hàng cao nhất, gầm khán đài, đầu hồi tây chỗ B02, cột đèn pha, khán đài phụ,
đầu đông, ba góc dải A16; đèn pha tắt và bật, có đèn pin ở các góc gần), ảnh ghép `overview.jpg` (13 cặp).

**Kiểm:** `pwsh tools/test.ps1 -Filter t261`: `RESULT: 12 passed, 0 failed`. Chạy riêng các test cũ: `stands_props` 8/8,
`test_campus` 5/5, `t259` 11/11, `t251` 5/5, `graphics_bindings` 8/8, `t260_occlusion` 4/4, `t249` 7/7, `hand_targets` 6/6.
Full `pwsh tools/test.ps1`: `RESULT: 1016 passed, 0 failed`. `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.
`git checkout -- game/default_bus_layout.tres` đã chạy.

**Ghi chú:** đoạn bot vòng phía bắc ngoài sân (x 80…143, z 176…226) ngoài hộp A16 nên vẫn là nền PS1. Không đề xuất
occluder cho khán đài: gầm và phía sau khán đài mở, một hộp che sẽ che sai. Sau đợt này HARU hỏi chủ dự án có chạy bot sân
vận động T-238 không (D-149); lane B không chạy bot.

**Yêu cầu thay đổi:** không có.

Commit lượt 2: `5f2e8c5` (gắn vào scene, test, ảnh trước), commit cuối lượt 2 (ảnh sau, `overview.jpg`, README, CREDITS,
Handoff).

### Lượt 1 (15/11/2026, lane B, Claude Opus 5.5) — xong, **dừng chờ chủ dự án chọn** (mục 1)
Nhánh `lane-b/T-261-realistic-graphics-wave4-stadium` từ `origin/main` `7b8431f` (card đọc ở `7b8431f`). Lượt 1 **không sửa
scene nào**: `capture_wave4.gd` gắn góc mẫu vào cảnh chương 3 thật lúc chạy và ẩn hình PS1 tương ứng. Cách dựng lại, số
liệu đầy đủ: `art_source/graphics_upgrade/realistic_map/wave4/README.md`.

**1. Khảo sát (kiểm lại mục 0).** Đúng như mục 0, thêm/khác:
- Hình khán đài, rào, mái PS1 không phải node riêng mà là MultiMesh `Stand_<vật liệu>_<hình>_<chunk>` (`boxes.gd`): bậc
  (`Stand_concrete_box_*`), dải ghế xanh, mặt bậc trắng, nẹp lối lên, song rào và thanh ngang (`Stand_iron_box_*`), xà mái,
  cột mái (`Stand_concrete_cylinder_*`), 4 ống sắt chỗ B03. `RoofColumn*`, `Fence*` chỉ có va chạm (không có `Mesh`).
  PS1 không có tấm mái (chỉ khung xà).
- Va chạm khán đài chính là **một dốc phẳng** (`MainBleachers/Slab`: từ z 212,7, y −9,9 lên z 228, y −3,06, dày 0,4 m);
  bậc hình PS1 (18 bậc 0,85 × 0,38 m) nằm ±0,19 m quanh dốc. Tường trước cao 1,1 m có 3 khe lối lên (x 170…176,
  195…201, 220…226). Gầm khán đài mở phía sau và hai đầu; B03 (164; −9,82; 225,5) dưới bản sàn, B02 (154; −9,9; 221) ngay
  ngoài đầu hồi tây, sau `Fence1`.
- Đường chạy: hai nửa vòng tròn tâm x 155,805 và 240,195 (z 166), bán kính trong 36,19, 7 làn 1,22 m; `Lane0…7` là vạch.
  `StartLane5`, `StartLane6` của PS1 nằm ngoài đường chạy (bản mới đặt vạch giữa từng làn).
- Đèn pha: `campus.gd` tắt đèn lúc `_ready`, `set_stadium_lights` chỉ đổi `Stadium/Floodlights.visible`;
  `chapter3_director._stadium()` bật lúc vào sân rồi **tắt lại sau 1,5 giây** (cảnh doạ `stadium_lights`).
- Code dùng sân: `campus.gd` (đèn), `chapter3_director.gd` (`Start_stadium`, `ZombieSpawns/Stadium`, `Clues/SirenSpot`,
  `Zones/Stadium`, `Zones/Bleachers`, đèn), `ch3_siren_audio.gd` (`SirenSpot`); `ch3_audio_bank`, `ch3_environment`,
  `ch3_music`, `reverb_zone`, `ch3_bot`, `ch3_menu*`, `ch3_policy` chỉ dùng tên vùng `stadium`, không dùng node sân.
  Test: `test_stands_props.gd` (đi lên hàng cao nhất, chui gầm tới B03, navigation, cổng mở, ngân sách 12.000 tam giác của
  `Stadium`), `test_campus.gd` (anchor, vùng, `set_stadium_lights`), `test_chapter3.gd`. Bot: `tools/ch3-profile.json`.
- **Đồ rải trên sân** (rào vượt, ghế, giấy, chai) nằm ở `props.tscn` (`Campus/Props`: `P_white_box_*`, `P_paper_*`,
  `D_paper_quad_*` trong x 110…286, z 120…232), **không** ở `Stand_*` như mục 2 bước 4 ghi (xem câu hỏi 7).

**Bảng hợp đồng** (lượt 2 giữ tên, gốc, transform; test so dấu vân tay va chạm với main):
| Node | Giữ | Hình PS1 sẽ ẩn |
|---|---|---|
| `Stadium` (gốc, transform 0), meta `tiers` (18, 7) | tên, transform, meta | — |
| `TrackBounds` (hộp 176 × 0,05 × 92, meta `surface = tile`) | va chạm | `Mesh` đã ẩn sẵn |
| `MainBleachers` (`Slab`, `FrontWall0…3`, `RearParapet`, `EndWest`, `EndEast`), `SecondaryBleachers` (như trên), meta `surface = concrete` | va chạm, transform, meta | `*/Mesh` |
| `RoofColumn0…8`, `Fence0…11` | va chạm | (không có Mesh; hình ở `Stand_*`) |
| `GatePost<x>_<z>_±5` (12 trụ 0,35 × 3,6 m) | va chạm | `*/Mesh` |
| `Pole0…3` (0,3 × 18 m) | va chạm | `*/Mesh`, `FloodHousing*` |
| `Floodlights`, `Light0…3` (năng lượng 12, tầm 145 m, màu, không bóng, mặc định ẩn) | tất cả | — |
| `Grass`, `RunningSurface`, `Lane0…7`, `StartLane0…6`, `PitchLine*`, `PitchEdge*`, `Goal±1`, `GoalPost*`, `GoalCross*`, `Stand_*` | node giữ | ẩn (Stand_* ẩn cả node khi thay hết) |
| `campus.tscn`: `Anchors/Start_stadium`, `ZombieSpawns/Stadium/S01…06`, `ZombieIdle/Stadium/I01…06`, `BarSpawns/B02`, `B03`, `Clues/SirenSpot`, `Zones/Stadium`, `Zones/Bleachers`, `Navigation` | tất cả | — |

**2. Đi thử tuyến vườn → cổng tây** (probe Godot không cửa sổ, thân người chơi thật và navmesh; không commit):
đồng đội `P14_Wait_garden` → `P15` (48; 28) → `P16` (80; 28) → `P17` (80; 166) → (115; 166), giữa `Road/WestBranch` rồi
`Road/StadiumWestAccess`; navmesh `Start_garden` → `Start_stadium` và xác sống từ vườn đi z 8…18 tới x 96 rồi dải đất
x 96…108 lên cổng tây; bot vòng thêm (80; 226) → (149; 220) → cổng tây bắc. Navmesh đi được hết; thân người đi thẳng chỉ vướng
đồ PS1 có va chạm (navmesh vòng qua). **Hộp A16 chốt: x 50…110, z −11…176, y −10,5…−6** (khác gợi ý: tuyến thật rời vườn
về phía đông ở z 28 chứ không qua mép sau z 40; mép nam z −11 là mép bắc `Road/Avenue`, đường ra cổng, không đụng). Đoạn
bot vòng bắc ngoài sân (x 80…143, z 176…226) để ngoài hộp; nền gầm và sau khán đài chính (x 140…246, z 212,6…234: B02,
B03) làm cùng khán đài (A13). Node trong hộp (đầy đủ trong `wave4/a16_box_nodes.json`):
- `campus.tscn`: ẩn `Road/WestBranch/Mesh`, `Road/StadiumWestAccess/Mesh`; nền mới phủ lên `Ground/Tile_20_-10`,
  `Tile_20_40`, `Tile_20_90`, `Tile_20_140`, `Tile_70_-10`, `Tile_70_40`, `Tile_70_90`, `Tile_70_140` (giữ va chạm).
- `props.tscn` (chỉ giấy rác trên đất và gạch vỡ): `Parts/P_paper_box_p1_p1`, `p1_p2`, `p2_p0`, `p2_p2`, `p2_p4` (1 mẩu mỗi
  chunk), `Decals/D_paper_quad_p0_p0` (25/73), `p0_p1` (31/31), `p1_m1` (8/14), `p1_p0` (13/13), `p1_p1` (6/22), `p1_p2`
  (8/34); đống gạch vỡ (87; 151) và (99; 173): `Parts/P_concrete_box_p2_p3` (11/15), `p2_p4` (11/11),
  `P_iron_cylinder_p2_p3` (3/5), `p2_p4` (3/4). Ghế đá, thùng rác, xe đạp, ô tô, cọc, cột đèn, cây, mảnh xác, vệt kéo sẫm
  không đụng.

**3. Góc mẫu** (Blender, `game/assets/models/graphics_pilot/realistic_map/wave4/`): cả mặt sân (đường chạy, bó vỉa, sân
trong, nền), 2 khung thành, **cả khán đài chính** (module 10 m: bậc, lối lên nửa bậc, tường trước, đầu hồi, lan can, bản
sàn nghiêng, dầm xiên, 9 cột, mái tôn trên vì kèo thép, nền gầm, ống sắt chỗ B03), 4 cột đèn pha (chao 6 đèn, kính sáng
theo `Floodlights`, không thêm đèn), rào phía tây và tây bắc với cổng tây, cổng tây bắc. Khán đài phụ phía nam, rào
phía đông, nam vẫn PS1 trong ảnh. 12 texture mới đều nén VRAM (`s3tc`). Kiểm hình mới chỉ nằm trong khối va chạm cũ hoặc
trên đầu người: `test_t261_stadium_pilot` 6/6.

**4. Phương án** — ảnh trong `art_source/graphics_upgrade/realistic_map/previews/wave4/`: `options_track.jpg`,
`options_pitch.jpg`, `options_stand.jpg`, `options_pole.jpg`, `options_fence.jpg`, `floodlights.jpg` (PS1 và a, đèn pha tắt và
bật), ảnh lẻ `pilot_<before|a|b|c>_<góc>_<off|on>[_torch].jpg` (10 góc, 83 ảnh).
| Hạng mục | Phương án | Tam giác | Vật liệu |
|---|---|---|---|
| Đường chạy | **R1 cao su đỏ bạc màu, nứt, vá** / R2 xỉ than, vạch vôi | 1.690 cả sân | `W4TrackRubber` / `W4TrackCinder`, `W4Apron`, `W4Paint` |
| Mặt sân | **C1 cỏ thật úa, trọc ở cầu môn** / C2 cỏ nhân tạo cũ | (trong 1.690) | `W4PitchGrass` / `W4Turf` |
| Khán đài chính | **S1 bê tông trần** / S2 + 2.160 ghế nhựa (xanh; đỏ để so) | 5.122 / + 69.120 | `W4StandConcrete`, `W4SteelFrame`, `W4RoofSheet`, `W1Concrete`, `W1Iron` (+ `W4Seat`) |
| Cột đèn pha | **L1 thép côn mạ kẽm** / L2 bê tông ly tâm | 822 / 730 mỗi cột | `W4PoleSteel`, `W4FloodBody`, `W4FloodGlass`, `W1Concrete` |
| Rào, cổng | **H1 lưới B40** / H2 song sắt sơn xanh; trụ trát vôi | 2.000 / 9.384 (120 m + 4 cánh) | `W4PoleSteel`, `W4Chainlink` / `W3LampPaint`; trụ `W4Pillar` |
PS1 cả sân 8.340 tam giác, 38 vật liệu; góc mẫu a 12.908, b 89.044. Số lần vẽ (chương 3, đèn pha tắt; bật như tắt):
cổng tây 628 → 606 (a, b), trong cổng 139 → 126, khán đài từ mép sân 70 → 66, hàng cao nhất 5.467 → 5.450, gầm 6.205 →
6.185; prim thêm khoảng 7–10 nghìn (a) hoặc khoảng 85 nghìn khi thấy khán đài (b, chủ yếu ghế); bộ nhớ hình chương 3 1.283 → 1.286 MB (a),
1.288 MB (b). Không đo FPS.

**Đề xuất:** R1 + C1 + S1 + L1 + H1 (phương án a). Lý do: đường đỏ, cỏ thật giữ được hình sân trong đêm (xỉ than tối,
mất đường viền khi chạy trốn 4 phút); bê tông trần hợp "cũ vừa phải", không có cảnh đi xuyên ghế, rẻ hơn khoảng 90 nghìn
tam giác (cả hai khán đài); B40 nhẹ, nhìn xuyên được, đúng kiểu sân trường; thép côn mảnh hợp cột 18 m.

**Câu hỏi cho chủ dự án:**
1. Đường chạy R1 hay R2?
2. Mặt sân C1 hay C2?
3. Khán đài S1 hay S2? Nếu S2: ghế xanh hay đỏ? (Ghế không có va chạm, người chơi lên bậc sẽ đi xuyên ghế như dải ghế PS1.)
4. Cột đèn pha L1 hay L2?
5. Hàng rào H1 hay H2? (Cao 1,3 m đúng va chạm cũ; cổng theo kiểu rào, trụ trát vôi.)
6. Mái: giữ 3 tấm tôn bị mất (ánh trăng lọt xuống đầu hồi tây) hay mái kín?
7. Đồ rải trên sân ở `props.tscn` (rào vượt, ghế, giấy, chai): card mục 8 chỉ cho sửa `props.tscn` phần A16 trong hộp.
   Có cho lượt 2 thay luôn đồ rải trong sân (trừ mảnh xác, vệt kéo) không? Nếu không, rào vượt, ghế PS1 sẽ đứng trên mặt
   sân mới.

**Yêu cầu thay đổi:** không có (câu 7 là phạm vi, chờ chủ dự án/HARU).

**Còn dở (lượt 2):** cả hai khán đài, sáu cổng, rào quanh sân, đồ rải theo câu 7, dải A16, gắn vào scene, bản xa/
MultiMesh cho ghế (nếu S2) và song rào (nếu H2), test dấu vân tay va chạm và đổi cách đếm `TRIANGLE_BUDGET_STADIUM`.

**Kiểm:** `pwsh tools/test.ps1 -Filter t261`: `RESULT: 6 passed, 0 failed`. Full `pwsh tools/test.ps1` (15/11, sau commit `573663d`): `RESULT: 1010 passed, 0 failed`. Check chưa chạy ở
lượt 1 (không đổi scene, code).

Commit: `8f88c0e` (pipeline góc mẫu), `573663d` (ảnh, bảng phương án, test, danh sách A16), commit cuối lượt 1 (README, CREDITS,
Handoff).

## Review (HARU thay integrator, 15/11/2026)
**Đạt, merge `e0bb9e8`** (nhánh lane B `5bc8635`; gốc nhánh là main `072b7bb` nên cây sau merge trùng hệt cây lane B đã kiểm).
- **Phạm vi:** 243 file, mọi file trong phạm vi lane B và mục 8 (đã mở thêm theo D-178). Code duy nhất: `stadium_real.gd` mới (tắt bóng lưới, rác, vạch; mờ dần đồ nhỏ theo khoảng cách; kính chao dùng chung một vật liệu, đổi sáng/tối theo tín hiệu `visibility_changed` của `Floodlights`, không xử lý mỗi khung). `campus.gd` không sửa.
- **Cảnh:** `stadium.tscn` thêm lớp `Real`, 114 node PS1 chỉ `visible = false`; `campus.tscn` ẩn hình `Road/WestBranch`, `Road/StadiumWestAccess`, thêm `StripGardenStadium` (dùng lại `garden_real.gd`); `props.tscn` chỉ đổi dữ liệu 42 MultiMesh (thu instance về 0) và ẩn một node giấy; va chạm, mảnh xác, vệt kéo, thùng rác không đổi (test so dấu vân tay với main).
- **`test_stands_props.gd`:** chỉ đổi cách đếm ngân sách (bỏ qua `Real`), đúng mục 4; lớp thật có ngân sách riêng 36.000 trong `test_t261_stadium` (đang 29.266). Các test đi lại, gầm, navigation, cổng không sửa.
- **Ảnh** (`previews/wave4/overview.jpg`, 13 cặp): đúng D-178 (đường đỏ, cỏ úa, bê tông trần, mái thiếu tấm ở đầu hồi tây, cột thép, rào B40, trụ trát vôi).
- **Lane B tự quyết:** đổi cách đếm ngân sách, gỡ phương án không chọn khỏi `game/` (script dựng lại được), giữ cao độ đường dải nối bằng đường PS1. Chấp nhận. Đoạn bot vòng phía bắc ngoài sân (x 80…143, z 176…226) còn nền PS1, để đợt 7.
- Binary đi qua LFS; CREDITS có mục `wave4/`. Không có yêu cầu thay đổi.
- **Kiểm sau merge** (khoá Godot, 15/11 05:52–06:42): full test **`RESULT: 1016 passed, 0 failed`**, check **`RESULT: check 0 error(s)`**.
- Không đo FPS, không chạy bot: HARU hỏi chủ dự án (trận sân vận động nặng nhất chương 3; bot T-238 hoãn theo D-149).
