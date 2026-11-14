# T-261 — Đồ hoạ thật đợt 4: sân vận động, khán đài, dải nối vườn → sân vận động
- Lane: B | Trạng thái: todo (giao 15/11/2026, D-176) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1o).
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
(HARU điền sau lượt 1, khi chủ dự án chọn trên ảnh mẫu)

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
- `art_source/graphics_upgrade/realistic_map/wave4/`, `.../previews/wave4/`, `game/assets/models/graphics_pilot/realistic_map/wave4/`, `game/assets/textures/graphics_pilot/realistic_map/wave4/`, `game/assets/models/graphics_pilot/realistic_map/CREDITS.md` (thêm mục `wave4/`), `game/scenes/levels/campus/stadium.tscn`, `campus.tscn` và `props.tscn` (chỉ phần hình A16 trong mục 3), `campus.gd` (chỉ phần đèn sân nếu cần cho chao đèn), script cảnh mới trong `game/scenes/levels/campus/`, `game/tests/levels/test_stands_props.gd` (chỉ cách đếm ngân sách, mục 4), test mới `game/tests/levels/`, card này (Checklist, Handoff).
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `chapter*.tscn`, occluder core; sửa vườn (T-259) ngoài đường khớp mép, nhà B, tầng 4; khu ngoài mục 3.
- Tripo, credit Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Lượt 1: khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp và danh sách node A16 (Handoff)
- [ ] Lượt 1: góc mẫu và phương án (đường chạy, cỏ, khán đài, đèn pha, hàng rào, cổng), ảnh đèn tắt/bật; dừng chờ chủ dự án chọn
- [ ] Lượt 2: cả sân vận động
- [ ] Lượt 2: dải nối vườn → sân
- [ ] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
(lane B ghi)
