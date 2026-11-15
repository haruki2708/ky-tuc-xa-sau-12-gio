# T-262 — Đồ hoạ thật đợt 5: cổng trường, chốt bảo vệ, đường tới cổng
- Lane: B | Trạng thái: in progress, lượt 2 (giao 15/11/2026; chọn D-180) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1p).
- Nhánh: `lane-b/T-262-realistic-graphics-wave5-gate` từ `origin/main` mới nhất.
- Quyết định nền: **D-166** (đồ hoạ thật dựng bằng Blender, không PS1, không Tripo trừ khi chủ dự án đổi; ánh sáng giữ như nay), **D-167/D-172/D-177** (phong cách đã duyệt: cũ vừa phải), **D-175** (sân block xám, viền quét vôi của vườn), **D-178** (sân vận động: bê tông trần, thép mạ kẽm, lưới B40, trụ trát vôi; dải nối có đường block con sâu), **D-176** (chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ), **D-179** (không đo FPS, không chạy bot trong đợt). Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 5 (A14 + A16 đoạn cổng).
- Làm như đợt 3–4 (T-259, T-261): **lượt 1 góc mẫu rồi dừng chờ chủ dự án chọn; lượt 2 làm cả khu.**

## 0. Hiện trạng (HARU khảo sát 15/11; lane B kiểm lại ở bước 1)
- `game/scenes/levels/campus/gate.tscn` (gốc `Gate` trong `campus.tscn`, transform gốc 0), dùng ở **chương 3** (đoạn `gate`, 08:23) và nhìn lại ở chương 4. Toàn PS1: 804 tam giác, 6 vật liệu, khối 60 × 40 × 8,6 m (PLAN A14). Ảnh hiện trạng: `realistic_map/previews/survey/31_gate_approach.jpg`, `32_guard_booth.jpg`, `38_road_gate.jpg`.
- Node gốc (có va chạm): `Court` (sân lát trước cổng, tâm (220; −9,92; −40), meta `surface = tile`, `is_floor`), `Pillar209` (trụ cổng tây (209; −6,9; −59), **nghiêng 7°**), `Pillar231` (trụ đông), `Gate` (khối va chạm cổng đóng (220; −7,9; −59), hình đã ẩn sẵn), `Booth` (chốt bảo vệ (240; −8,4; −54)). Hình không va chạm: `GateBar210…230` (21 song cổng), `GateCross0.5`, `GateCross3.4` (thanh ngang), `HalfFallenSign` (biển tên trường rơi nửa, (219; −4,1; −59)), `SignScar0…7`, `BoothRoof`, `BoothWindow`, `PillarCrack`, `RoadCrack*` (vết nứt có nhánh). Không có đèn trong `gate.tscn`.
- **Tường rào phía nam** của cả khuôn viên là một khối dài `campus.tscn` `Fence/S` (tâm (170; −8,4; −60)), cổng nằm trên đường tường này. Thanh chắn đỏ trắng, ô tô, cọc giao thông, giấy, mảnh xác quanh sân cổng nằm trong `props.tscn` (MultiMesh `P_*`, `D_*`).
- **12 bảo vệ** đứng hàng ngang trước cổng: `Anchors/GuardLine/G01…G12` (x 210 → 230, z −54, y −9,9); `chapter3_director._place_guards()` đặt nhân vật `scenes/entity/guard.tscn` (lane A) tại đó. Lại gần một bảo vệ dưới **12 m** (`GUARD_TURN_RADIUS`) là chết (`DEATH_CH3_GUARD`). Vùng `Zones/GuardRadius` (tâm (220; −8,4; −52,5)). `Anchors/GuardBooth` (240; −9,9; −51), `Anchors/Clues/GatePillar` (209; −9,9; −58).
- Truyện chương 3 ở cổng (`_gate()`): tới `Anchors/Start_gate` (220; −9,9; −25), xác sống ra ở `Anchors/ZombieSpawns/Gate/S01…06`, chờ ở `ZombieIdle/Gate/I01…06`, rồi đi sang nhà ăn (`Zones/Canteen`; nhà ăn quanh (190; −10; 32), **đợt 6, không đụng**). Vùng `Zones/Gate` (tâm (220; −7,9; −40)). Đồng đội: `Anchors/Paths/Nhat/P27_Wait_gate`, `Paths/Ngu/P17_Wait_gate`.
- Code, test, bot dùng cổng: `chapter3_director.gd` (`_gate`, `_place_guards`, vùng), `ch3_environment.gd`, `ch3_guard_audio`, `ch3_bot.gd` (kịch bản `ch3_guard`), `ch3_policy.gd`, `ch3_actions.gd`, `ch3_menu*.gd`, `profile_static_audit.gd`, `tools/ch3-profile.json`; test `test_campus.gd` (anchor `Start_gate`, vùng `Gate`, `GuardRadius`), `test_chapter3.gd`, `test_ch3_profile.gd`, `test_stands_props.gd` (navigation tới cổng).
- Hiệu năng: PLAN mục 6: A14 **≤ 0,25 ms** thêm; tách chốt khỏi cổng, đồ trong chốt khuất không cần vẽ; **không che đường nhìn tới hàng bảo vệ**.

## 1. Chủ dự án chốt
**D-180 (15/11/2026):** chủ dự án xem ảnh lượt 1 (`previews/wave5/options_*.jpg`) và chọn cả tám câu theo đề xuất (phương án a có chữ):
1. Cánh cổng: **G1** sắt hai cánh, song mũi giáo sơn xanh, tấm tôn dưới, cao 3 m.
2. Trụ và biển: **P1** trụ trát quét vôi + **SA** biển tôn xanh treo dưới vòm giàn thép. Trụ tây vẫn nghiêng 7°, biển rơi nửa.
3. Chữ: **"TRƯỜNG ĐẠI HỌC"**, phần tên trường bong chỉ còn vết keo (như ảnh mẫu).
4. Chốt bảo vệ: **K1** xây trát quét vôi vàng, mái bê tông, cửa sổ có song; đồ bên trong như góc mẫu (lượt 2 gộp atlas).
5. Tường rào: **W1** trát quét vôi 1,8 m + song sắt tới 3 m.
6. Phạm vi tường: **cả `Fence/S` 500 m** (module lặp bằng MultiMesh hoặc lưới gộp, xa bỏ song rời thay bằng mặt phẳng).
7. Sân cổng và khoảng đất sang nhà ăn: **C2** block con sâu xám như dải nối D-178.
8. **Thay luôn 5 ô tô PS1 và đồ rơi** (ba lô, giày, dép, điện thoại) trong hộp bằng bản thật, đúng chỗ, đúng góc, đúng va chạm; mảnh xác, máu, vết nứt, vệt kéo giữ nguyên.

**HARU (thay integrator) cho phép thêm** (trả lời các đề nghị trong Handoff lượt 1):
- Hộp A16 **x 180…262, z −60…13** như lane B chốt (không lấn hộp nhà ăn).
- Rút ngắn hình `Road/Avenue/Mesh` còn x 0…180 (không ẩn, để `test_t261_stadium` vẫn đạt); 40 m cuối lát block con sâu.
- Cắt hình tường ở lỗ cổng và thêm dải vỉa hè, lòng đường ngoài cổng **chỉ để nhìn** (không va chạm, ở z ≤ −60,15); va chạm `Fence/S` giữ nguyên.
- **Trả lại đầu của 3 xác tĩnh** bị T-259/T-261 ẩn nhầm (`P_paper_box_p1_p0` bản 0, `P_paper_box_p2_p2` bản 1, `P_paper_box_p2_p4` bản 1 trong `props.tscn`; bỏ tờ giấy mới nếu đặt đúng chỗ đó) và hạ ngưỡng tương ứng trong `test_t261_stadium.gd` (373 → 371), ghi lý do trong Handoff.

## 2. Việc, theo hai lượt

### Lượt 1 — khảo sát và góc mẫu, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi Handoff:** kiểm lại mục 0; grep mọi chỗ code, test, bot, âm thanh đụng tới cổng (`gate.tscn`, `Gate/`, `Booth`, `Pillar209`, `Pillar231`, `GuardLine`, `GuardBooth`, `GatePillar`, `GuardRadius`, `Start_gate`, `ZombieSpawns/Gate`, `Fence/S`); lập **bảng hợp đồng** (node nào giữ tên, vị trí, va chạm). **Đi thử tuyến sân vận động → cổng → nhà ăn** (đường đồng đội, xác sống và bot đi, `tools/ch3-profile.json`) và **chốt hộp dải A16 đoạn cổng** (gợi ý: sân cổng và đường tới cổng, khoảng x 180…262, z −60…−10; không lấn vào nhà ăn x 170…210, z 13…51), liệt kê chính xác đường dẫn node A16 trong hộp.
2. **Góc mẫu** quanh cổng và chốt bảo vệ: hai trụ cổng (giữ trụ tây nghiêng 7°), cánh cổng đóng, biển tên trường rơi nửa, một đoạn tường rào hai bên cổng, chốt bảo vệ (tường, mái, cửa sổ, cửa, đồ trong chốt nhìn qua cửa sổ), thanh chắn, một mảng sân cổng. Dựng bằng Blender, chất lượng ngang các đợt trước. Kèm **phương án để chủ dự án chọn bằng mắt** (ảnh cùng camera, chương 3 thật, ban đêm, có và không đèn pin, **có hàng 12 bảo vệ đứng đúng chỗ**):
   - **cánh cổng**: ví dụ cổng sắt hai cánh song đứng sơn (màu) / cổng xếp (cổng kéo) inox hoặc sắt;
   - **trụ cổng và biển trường**: trụ bê tông trát (quét vôi hay ốp gạch); biển chữ nổi trên trụ hay biển ngang trên vòm; **chữ trên biển**: có tên trường (chủ dự án duyệt chữ) hay không chữ (như ghế D-175);
   - **chốt bảo vệ**: chốt xây trát quét vôi vàng kiểu Việt Nam / chốt lắp ghép tôn hoặc composite;
   - **tường rào nam**: tường xây trát quét vôi có song sắt phía trên / tường gạch trần; và phạm vi: chỉ đoạn nhìn thấy từ sân cổng hay cả `Fence/S` (cả khối dài, module lặp nhẹ; câu hỏi cho chủ dự án);
   - **sân cổng**: đường nhựa cũ / sân block con sâu như dải nối (D-178).
   Mỗi phương án ghi số tam giác, vật liệu, số lần vẽ. Đề xuất một phương án.
3. Commit, push nhánh, ghi Handoff, **báo và dừng**. HARU chuyển phương án cho chủ dự án, ghi lựa chọn vào mục 1.

### Lượt 2 — làm cả khu (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
4. **Cổng và chốt (A14):** trụ, cánh cổng, song, thanh ngang, biển, vết nứt (dạng decal hoặc vào texture), chốt bảo vệ (tường, mái, cửa, cửa sổ, bàn ghế và đồ bên trong nhìn qua cửa sổ), thanh chắn, tường rào theo phạm vi chủ dự án chọn, đồ rải quanh sân cổng theo đúng vị trí và va chạm cũ.
5. **Dải A16 đoạn cổng (chỉ trong hộp đã chốt ở bước 1).** Khớp mép dải nối đợt 4 nếu chạm.
6. Ảnh trước/sau, ảnh ghép, test, full test, check, Handoff.

## 3. Phạm vi A16 trong đợt này
- **Chỉ** mặt đất, đường, viền, rãnh, đồ rải (rác, giấy, cọc, thanh chắn, ô tô PS1) **trong hộp lane B chốt ở bước 1**. Không đụng phần đã làm ở T-259, T-261 trừ đường khớp mép.
- **Không** đụng nhà ăn (đợt 6), nhà nền, cây xa (đợt 7), sân vận động (T-261). Không thay MultiMesh nhẹ bằng hàng nghìn node.
- Mảnh xác tĩnh, máu, vệt kéo sẫm, thùng rác: không đụng (như T-259, T-261).

## 4. Hợp đồng gameplay (bắt buộc giữ)
- Không đổi tên, gốc, transform của các node có va chạm và các node code dùng: `Gate` (gốc), `Court` (và meta), `Pillar209`, `Pillar231`, `Gate/Gate`, `Booth`; trong `campus.tscn`: `Fence/S` (va chạm), `Anchors/GuardLine/G01…G12`, `Anchors/GuardBooth`, `Anchors/Clues/GatePillar`, `Anchors/Start_gate`, `Anchors/ZombieSpawns/Gate/*`, `Anchors/ZombieIdle/Gate/*`, `Anchors/Paths/*/P*_Wait_gate`, `Zones/Gate`, `Zones/GuardRadius`, `Zones/Canteen`, navigation.
- **Va chạm giữ nguyên** (test so dấu vân tay với main như T-259, T-261): sân cổng, trụ, cổng, chốt, tường rào, va chạm của đồ rải.
- **Đường nhìn tới hàng bảo vệ giữ như cũ:** từ `Start_gate` và từ đường tới cổng, người chơi phải thấy rõ cả 12 bảo vệ như bản PS1 (không thêm vật cao hơn 1 m giữa `Start_gate` và hàng bảo vệ; thanh chắn, cọc thấp như cũ). Không thêm chỗ nấp hay vật khiến người chơi bị dồn vào bán kính 12 m.
- Tuyến đồng đội, xác sống, bot (toạ độ `tools/ch3-profile.json`) không bị đồ mới chặn; người chơi không kẹt.
- Hình PS1 chỉ ẩn (`visible = false` hoặc thu instance MultiMesh về 0 như T-261), không xoá. Không đổi luật, bảo vệ (lane A), lời thoại, director, âm thanh, vùng reverb, ánh sáng.

## 5. Kỹ thuật và hiệu năng
- **Dựng bằng script Blender** (Blender 5.2.2 portable ở `D:\Tools\Blender\5.2.2`). Được dùng texture, mesh **CC0** (Poly Haven, ambientCG…) nếu ghi URL, tác giả, giấy phép trong CREDITS. **Không cài extension/addon Blender, không Tripo, không ảnh AI.** Chữ trên biển (nếu có) vẽ bằng font có sẵn trong game (Be Vietnam Pro, OFL).
- Dùng lại bộ vật liệu đã duyệt khi hợp (bê tông, trát vôi, thép mạ kẽm, thép sơn của đợt 1–4; block con sâu, vôi của đợt 3–4).
- Ngân sách (PLAN mục 6): **≤ 0,25 ms** thêm; ghi số tam giác, vật liệu, số lần vẽ cho góc mẫu và cả khu, **ở góc nhìn rộng nhất** (từ `Start_gate` nhìn cổng, từ cổng nhìn về nhà ăn). Đồ trong chốt dùng `visibility_range` hoặc bản xa; tường rào dài dùng module lặp (MultiMesh hoặc lưới gộp).
- **Mọi texture mới từ 512 px trở lên phải nén VRAM:** `.import` đặt `compress/mode=2`, normal thêm `compress/normal_map=1`. Ghi bộ nhớ hình chương 3 trước/sau.
- Occlusion culling (D-174) đã bật: chốt bảo vệ, tường rào kín có thể thêm occluder hình hộp, nhưng occluder thuộc cảnh core (`game/scenes/main/occlusion/`): **không tự thêm**, ghi vào "Yêu cầu thay đổi" nếu thấy đáng.
- Không đo FPS, không chạy bot (D-179).

## 6. Ảnh
- `art_source/graphics_upgrade/realistic_map/previews/wave5/`: lượt 1 `pilot_*` và bảng phương án; lượt 2 `before_*`/`after_*` cùng camera trong **chương 3 thật**, có hàng bảo vệ: từ `Start_gate` nhìn cổng, sát trụ cổng tây (trụ nghiêng, biển rơi), chốt bảo vệ ngoài và nhìn qua cửa sổ, thanh chắn, tường rào nam, từ cổng nhìn về nhà ăn, dải A16; ảnh ghép tổng `overview.jpg`. Ban đêm như chương, có và không đèn pin.

## 7. Kiểm
- Test mới `game/tests/levels/test_t262_*.gd`:
  - dấu vân tay va chạm cổng, trụ, chốt, sân cổng, `Fence/S`, đồ rải trùng main; node, anchor, vùng giữ nguyên; hình PS1 ẩn;
  - **đường nhìn:** tia từ `Start_gate` (cao mắt) tới từng `GuardLine/G01…G12` (cao ngực) không bị hình mới chặn;
  - capsule đi được từ `Start_gate` tới sát mép bán kính bảo vệ và sang nhà ăn theo tuyến cũ;
  - **mọi `.import` texture trong thư mục asset đợt 5 có `compress/mode=2`** (normal có `compress/normal_map=1`); glb chỉ dùng vật liệu chung;
  - dải A16 nằm trong hộp đã chốt và chỉ ẩn đồ PS1 trong hộp.
- Test cũ đạt: `test_campus`, `test_chapter3`, `test_chapter4`, `test_ch3_*`, `test_stands_props`, `test_t259*`, `test_t261*`, `test_graphics_bindings`, `test_t260_occlusion`. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## 8. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave5/`, `.../previews/wave5/`, `game/assets/models/graphics_pilot/realistic_map/wave5/`, `game/assets/textures/graphics_pilot/realistic_map/wave5/`, `game/assets/models/graphics_pilot/realistic_map/CREDITS.md` (thêm mục `wave5/`), `game/scenes/levels/campus/gate.tscn`, `campus.tscn` (hình cả `Fence/S` theo D-180, hình `Road/Avenue` rút còn x 0…180, phần hình A16 trong mục 3 và node lớp thật mới) và `props.tscn` (chỉ đồ rải trong hộp, gồm ô tô và đồ rơi theo D-180, trừ mảnh xác, máu, vệt kéo, thùng rác; và trả lại đầu 3 xác ở mục 1), `game/tests/levels/test_t261_stadium.gd` (chỉ ngưỡng số bản thu về 0, mục 1), script cảnh mới trong `game/scenes/levels/campus/`, test mới `game/tests/levels/`, card này (Checklist, Handoff).
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), bảo vệ và `scenes/entity/` (lane A), `chapter*.tscn`, occluder core; sửa vườn (T-259), sân vận động (T-261) ngoài đường khớp mép; nhà ăn; khu ngoài mục 3.
- Tripo, credit Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [x] Lượt 1: khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp và danh sách node A16 (Handoff)
- [x] Lượt 1: góc mẫu và phương án (cánh cổng, trụ và biển, chốt, tường rào, sân cổng), ảnh có hàng bảo vệ; dừng chờ chủ dự án chọn
- [x] Lượt 2: cổng, chốt, tường rào
- [x] Lượt 2: dải A16 đoạn cổng
- [x] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
(lane B ghi)

### Lượt 2 (15/11/2026, D-180): xong, chờ review
Nhánh rebase lên `origin/main` `f19bf4b` (D-180), đẩy bằng `--force-with-lease`. Cách chạy lại, bảng tam giác/vật liệu, số
lần vẽ đầy đủ: `art_source/graphics_upgrade/realistic_map/wave5/README.md` (mục Lượt 2).

**Đã làm theo mục 1:**
- `gate.tscn`: ẩn 43 node hình PS1 (sân, hai trụ, chốt, 21 song cổng, 2 thanh ngang, biển rơi nửa, 9 vết sẹo biển, cửa sổ
  và mái chốt, 3 vết nứt đường, vết nứt trụ); thêm `Real` (`gate_real.gd`): sân block con sâu (C2), dải vỉa hè và lòng đường
  ngoài cổng chỉ để nhìn (z ≤ −60,15), vết nứt sân đúng chỗ PS1, trụ P1 (trụ tây nghiêng 7°), cổng G1, vòm + biển SA
  "TRƯỜNG ĐẠI HỌC" rơi nửa, chốt K1 (7 vật liệu) và đồ bên trong một atlas (1 vật liệu, vẽ trong 30 m).
- `campus.tscn`: `Fence/S/Mesh` ẩn (va chạm giữ); `WallSouth`: W1 dọc cả 500 m trừ lỗ cổng, 17 khối 30 m, song sắt thật
  trong 45 m, thẻ song phẳng từ 45 m (chuyển dần 5 m); `Road/Avenue/Mesh` rút còn x 0…180 (BoxMesh 180 m, mesh dời 20 m
  sang tây; node `Road/Avenue` và hiển thị không đổi, `test_t261` vẫn đạt); `StripGate` trong hộp x 180…262, z −60…13: cỏ mòn,
  lối lát block con sâu từ sân lên mép hộp và rẽ tây về phía cửa nhà ăn, 37 m cuối đại lộ lát block, bó vỉa, viền; đồ rải:
  5 ô tô sedan cũ (màu PS1, đúng chỗ, đúng góc, trong khối va chạm cũ), 2 rào chắn, 6 cọc, ba lô, giày, dép, điện thoại,
  38 tờ giấy, đống gạch vỡ.
- `props.tscn`: thu cỡ về 0 đúng 180 bản trong hộp (so với main bằng script: không bản nào khác đổi); xác, máu, vết nứt,
  vệt kéo, ghế, bồn cây, xe máy, xe đạp, thùng gỗ, biển chỉ đường, bảng tin, cột đèn, cây giữ nguyên.
- **Trả đầu 3 xác** (`P_paper_box_p1_p0` bản 0, `P_paper_box_p2_p2` bản 1, `P_paper_box_p2_p4` bản 1) bằng ma trận main
  (từ `wave3/a16_ps1_props.json`, `wave4/w4_ps1_props.json`); bỏ tờ giấy đặt đúng chỗ đó: sửa `wave3/build_garden.py`,
  `wave4/build_stadium.py` (vẫn rút số ngẫu nhiên như cũ), dựng lại `wave3/strip_props.glb`, `wave4/strip_stadium_props.glb`;
  so đỉnh với main: chỉ mất đúng 1 và 2 tờ.
- Test cũ phải sửa vì việc trả đầu (HARU cho phép mục 1): `test_t261_stadium.gd` ngưỡng 373 → 371 **và** hằng
  `PROPS_KEPT_MD5` (2.303 → 2.124 dòng: bớt 180 bản đợt này thay, thêm đầu xác (43,6; 30,2) nằm ngoài hộp A16 của T-261
  nên thành dòng "giữ"); `test_t259_garden.gd` bỏ `Parts/P_paper_box_p1_p0` khỏi `A16_PARTLY` (phần duy nhất bị ẩn ở đó là
  cái đầu, nay `zeroed > 0` không còn đúng). Đổi `PROPS_KEPT_MD5` và `test_t259` là ngoài chữ của mục 1 nhưng là hệ quả trực
  tiếp; lý do ghi trong comment của hai file.
- Bỏ khỏi `game/` các phương án không chọn (P2, G2, SB và chữ nổi, K2, W2, biển không chữ, texture gạch, composite, mặt
  nạ băng biển, vật liệu tương ứng); `barrier.glb`, `cone.glb` gộp vào đồ rải. `test_t262_gate_pilot.gd` thay bằng
  `test_t262_gate.gd` (9 test).

**Hợp đồng giữ (`test_t262_gate`):** dấu vân tay node và va chạm `gate.tscn` (145 dòng), va chạm cả `campus.tscn` (957),
anchor/vùng/navigation, va chạm `props.tscn` trùng main (md5 tính trên bản sao `origin/main` trong `_probe_tmp`, đã xoá);
hình PS1 ẩn, không xoá; chỉ đúng 180 bản trong hộp thu về 0, 3 đầu trở lại; lớp `StripGate` nằm trong hộp; cổng, trụ,
chốt, biển (phần dưới 2,3 m), tường, ô tô nằm trong khối va chạm cũ hoặc ngoài tầm với; tia từ 4 điểm mắt (`Start_gate`,
(220; −15), (205; −16), (235; −30)) tới ngực 12 bảo vệ không cắt tam giác mới nào; thân người chơi đi `Start_gate` → mép
12 m → về → `P28` → `P29` → `P30_Wait_canteen`; 11 texture đợt 5 nén VRAM; glb chỉ dùng vật liệu chung; cả đợt 52.586 tam giác.

**Số liệu** (chương 3, cùng camera, trước → sau): số lần vẽ phần lớn góc giảm nhẹ hoặc như cũ (từ `Start_gate` 351 → 336,
biển 448 → 432, rào chắn 479 → 466, góc rộng 4.442 → 4.427); góc nhìn chốt tăng (35 → 61; đèn pin 43 → 85, chốt 7 vật liệu,
đèn pin đổ bóng). Primitive thêm 10…22 nghìn ở góc gần, góc rộng khoảng 1,5 triệu thêm 6…22 nghìn. Bộ nhớ hình chương 3
1.278…1.279 → 1.288…1.290 MB. Không đo FPS (D-179).

**Ảnh:** `art_source/graphics_upgrade/realistic_map/previews/wave5/before_*`, `after_*` (17 góc, 27 ảnh mỗi bên, hàng 12
bảo vệ đứng đúng chỗ, có và không đèn pin), `overview.jpg`.

**Còn lại / ghi chú:**
- **6 xác trong vườn vẫn mất đầu** (ngoài phép mục 1): T-259 ẩn cả node `Parts/P_paper_box_p0_p0` (`A16_ALL`), trong đó có
  đầu của 6 xác ở (11,2; 16,9), (29,1; 27,6), (14,3; 37,0), (0,2; 7,6), (16,6; 18,8), (31,1; 30,4) và T-259 đặt giấy đúng
  các chỗ đó. Sửa: hiện lại node, thu về 0 bảy bản không phải đầu (khay cơm, 6 tờ bảng tin T-259 đã thay), bỏ 6 tờ giấy
  (`build_garden.py` chỉ cần bỏ điều kiện `mode != "all"`), sửa `A16_ALL`/`A16_PARTLY` trong `test_t259`. Chờ HARU cho phép.
- Vết nứt PS1 trong dải (giữ nguyên) nằm ở −9,84: trên cỏ mới (−9,93) cao 9 cm, trên sân (−9,90) 6 cm như PS1.
- Chưa gộp vật liệu của chốt K1 (7) và ô tô (11 trong một mesh cho cả 5 xe).
- Không đề nghị occluder (sau tường là khoảng trống).

**Kiểm:** `-Filter t262` 9 passed; `-Filter t261` 12 passed; `-Filter t259` 11 passed. Full `pwsh tools/test.ps1` trên
`39aec28`: `RESULT: 1025 passed, 0 failed`. `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`. Đã
`git checkout -- game/default_bus_layout.tres` sau mỗi lần chạy.

### Lượt 1 — phần 2: góc mẫu và phương án (15/11/2026, xong; DỪNG chờ chủ dự án chọn)
Chưa sửa scene nào (`gate.tscn`, `campus.tscn`, `props.tscn` như main). Góc mẫu: 17 glb trong
`game/assets/models/graphics_pilot/realistic_map/wave5/`, 16 texture tự vẽ (đều `compress/mode=2`, normal có
`compress/normal_map=1`), vật liệu `W5*`; `capture_wave5.gd` gắn vào chương 3 thật lúc chạy và ẩn hình PS1 tương ứng. Cách
chạy, bảng tam giác/vật liệu/lần vẽ đầy đủ: `art_source/graphics_upgrade/realistic_map/wave5/README.md`.

**Ảnh** (`art_source/graphics_upgrade/realistic_map/previews/wave5/`, chương 3 thật, ban đêm, có và không đèn pin, 12 bảo
vệ đứng đúng chỗ): 5 bảng để chọn `options_gate.jpg`, `options_sign.jpg`, `options_booth.jpg`, `options_wall.jpg`,
`options_court.jpg`; ảnh lẻ `pilot_<before|a|b|c|d>_<góc>[_torch].jpg` (67 ảnh, 11 góc: từ `Start_gate`, cuối đường vào, sát
trụ tây, biển rơi nửa, thanh chắn, chốt, qua cửa sổ chốt, tường hai phía cổng, mặt sân, nhìn qua cổng ra ngoài).
Cấu hình: `a` = C2 P1 G1 SA có chữ K1 W1; `b` = C1 P2 G2 SB có chữ K2 W2; `c` = `a` không chữ; `d` = `b` không chữ (chỉ chụp
các góc thấy biển). Trụ và biển ghép chéo được (P1 + SB, P2 + SA); hai thứ chỉ chụp theo cặp cho đỡ số ảnh.

| Mục | Phương án | Tam giác | Vật liệu |
|---|---|---|---|
| Cánh cổng | **G1** sắt hai cánh sơn xanh (màu thép sơn xanh đã duyệt), tấm tôn dưới, song mũi giáo, cao 3 m / **G2** cổng xếp inox 1,9 m | 2.292 / 11.348 | 3 / 3 |
| Trụ | **P1** trát quét vôi (như viền bồn D-175, trụ sân D-178) / **P2** ốp gạch đỏ, gờ và mũ quét vôi | 330 / 138 | 3 / 4 |
| Biển | **SA** biển tôn xanh treo dưới vòm giàn thép / **SB** băng trát vữa có chữ nổi đỏ, bắt giá trên mũ trụ; cả hai rơi nửa, đầu tây còn treo, đầu đông tựa trước cổng | 2.252 / 72 + 2.488 chữ | 4 / 3 |
| Chữ | **có chữ** mẫu "TRƯỜNG ĐẠI HỌC", phần tên trường đã bong còn vết keo / **không chữ** (mọi chữ rơi, còn vết keo, không đọc được) | | |
| Chốt | **K1** xây trát quét vôi vàng, mái bê tông, cửa sổ có song / **K2** lắp ghép composite trắng, khung thép xanh, mái tôn; đồ bên trong chung (526 tam giác, vẽ trong 30 m) | 650 / 420 | 10 / 7 |
| Tường rào | **W1** trát quét vôi 1,8 m + song sắt tới 3 m / **W2** gạch trần 2,7 m, trụ gạch, gờ bê tông (đoạn mẫu x 186…262, ngoài đoạn vẫn PS1) | 3.976 / 768 | 2 / 2 |
| Sân cổng | **C2** block con sâu xám (như dải nối D-178) / **C1** nhựa đường cũ | 8 / 8 | 1 / 1 |
| Chung | Rào chắn sọc đỏ trắng di động (2), cọc giao thông (6), vết nứt sân đúng chỗ PS1, vỉa hè và lòng đường ngoài cổng | 488 + 1.116 + 18 + 48 | |
PS1 `gate.tscn`: 804 tam giác, 6 vật liệu. Cả góc mẫu: phương án a 11.704 tam giác, b 17.438. Số lần vẽ (PS1 → a → b):
từ `Start_gate` 351 → 323 → 320; cuối đường vào 382 → 353 → 350; biển, đèn pin 448 → 418 → 416; chốt, đèn pin 43 → 78 → 72
(chốt và đồ bên trong nhiều vật liệu: lượt 2 gộp atlas); góc rộng nhìn cả khu 4.439 → 4.406 → 4.403. Primitive thêm khoảng
10–28 nghìn tuỳ góc. Bộ nhớ hình chương 3 (đã nạp cả hai bộ phương án): 1.291…1.294 MB. Không đo FPS (D-179).

**Giữ hợp đồng (test `test_t262_gate_pilot`, 8 test):** cánh cổng trong khối `Gate/Gate` 20 × 4 × 0,18 m; trụ trong khối
trụ (trụ tây nghiêng 7°, chân chôn 0,3 m); biển phần dưới 2,3 m nằm trong bề dày 0,18 m của khối cổng; chốt trong khối
`Booth` (mái chìa trên 2,85 m); tường trong khối `Fence/S`; mặt sân trên khối `Court`; dải ngoài cổng ở z ≤ −60,15 (không tới
được); rào chắn trong khối 2,2 × 1,0 × 0,5 m của PS1; tia từ mắt (1,6 m) ở `Start_gate`, (220; −15), (205; −16), (235; −30)
tới ngực 12 bảo vệ không cắt tam giác nào của mọi phương án và hai rào chắn; không vật mới nào cao hơn 1 m giữa
`Start_gate` và hàng bảo vệ (rào chắn 0,95 m, cọc 0,7 m như PS1). Texture nén VRAM, glb chỉ dùng vật liệu chung.

**Đề xuất: phương án a có chữ** — G1, P1 + SA, chữ "TRƯỜNG ĐẠI HỌC" (tên bong), K1, W1, C2. Lý do: hợp các lựa chọn đã
duyệt (thép sơn xanh, trụ và viền quét vôi D-175/D-178, sân block con sâu của dải nối D-178); cổng sắt cao 3 m đọc rõ là
cổng trường đóng kín sau hàng bảo vệ, rẻ hơn G2 năm lần tam giác; biển xanh trên vòm giống biển PS1 nên người chơi nhận ra
ngay "biển tên trường rơi nửa" (manh mối), mà trường vẫn không tên; chốt vôi vàng là kiểu chốt trường Việt Nam quen thuộc;
tường quét vôi có song sắt nhẹ mắt hơn gạch trần, đi cùng trụ. Tường rào: đề xuất làm **cả `Fence/S`** (module 3 m lặp
bằng MultiMesh, xa thì bỏ song sắt rời thay bằng mặt phẳng), vì chỗ nối với tường PS1 thấy rõ ở mọi góc rộng.

**Câu hỏi cho chủ dự án** (HARU chuyển, ghi lựa chọn vào mục 1):
1. Cánh cổng G1 hay G2?
2. Trụ P1 hay P2? Biển SA (vòm thép, biển tôn) hay SB (chữ nổi trên băng trát)? (ghép chéo được)
3. Chữ trên biển: "TRƯỜNG ĐẠI HỌC" để tên trường bong (như ảnh), chữ khác do chủ dự án đưa, hay không chữ? Chữ nằm trong
   hình (như bảng giá nhà ăn), bản tiếng Anh vẫn thấy chữ Việt.
4. Chốt K1 hay K2?
5. Tường rào W1 hay W2; phạm vi chỉ đoạn quanh sân cổng (x 186…262 như ảnh, chỗ nối PS1 thấy rõ) hay cả `Fence/S` 500 m?
6. Sân cổng C2 hay C1? (Phần còn lại của hộp A16 lượt 2: 40 m cuối `Road/Avenue` lát block con sâu như `WestBranch` đợt
   4, khoảng đất sang nhà ăn theo vật liệu sân đã chọn; rút ngắn hình `Road/Avenue` còn x 0…180, không ẩn.)
7. Lượt 2 có thay luôn 5 ô tô PS1 và đồ rơi (ba lô, giày, dép, điện thoại) trong hộp bằng bản thật (một mẫu sedan cũ dựng
   Blender, màu theo màu PS1, đúng chỗ, đúng va chạm) không? Đề xuất: có; giấy, cọc, rào chắn thì card đã giao.
8. (Integrator) Cho phép lượt 2 trả lại đầu của 3 xác tĩnh bị T-259/T-261 ẩn nhầm (xem phần 1) không?

**Hộp A16 chốt rộng hơn gợi ý của card** (z tới 13 thay vì −10): nếu HARU muốn giữ z −60…−10 thì khoảng z −10…13 để đợt 7.

**Chưa làm, cố ý:** không sửa scene; không gộp atlas đồ trong chốt; không occluder (chốt nhỏ, sau tường là khoảng trống:
không có gì để che, không đề nghị thêm). Ảnh chụp trước lần thu chân rào chắn vào 3 cm (cho vừa khối 0,5 m).

**Cách kiểm tra:** `pwsh tools/test.ps1 -Filter t262` (8 PASS); xem 5 bảng `options_*.jpg`; chạy lại ảnh theo README.

**Kiểm:** `pwsh tools/test.ps1 -Filter t262`: 8 passed, 0 failed. **Full `pwsh tools/test.ps1`: 1024 passed, 0 failed**
(chạy lại theo yêu cầu chủ dự án, trên commit `8511f98`; lần chạy trước bị Claude Code dừng vì máy thiếu RAM). `check.ps1`
chưa chạy. Lượt 1 không sửa scene, code hay test cũ nào, chỉ thêm asset mới chưa scene nào dùng và một file test mới.

### Lượt 1 — phần 1: khảo sát, hợp đồng, đi thử tuyến, hộp A16 (15/11/2026)
Nhánh `lane-b/T-262-realistic-graphics-wave5-gate` từ `origin/main` `1b63065` (card đọc ở `1b63065`). Chưa sửa scene nào.
Script: `art_source/graphics_upgrade/realistic_map/wave5/` (`gate_layout.py` số đo, `walk_route.gd` đi thử tuyến,
`list_a16_box.py` → `a16_box_nodes.json`).

**Kiểm lại mục 0:** đúng như card, thêm mấy điểm:
- Trụ `Pillar209` nghiêng 7° quanh tâm nên chân khối va chạm hở 11 cm ở góc đông (góc tây chìm 6 cm); bản mới phải
  phủ kín chân trụ (như nền bị đội lên, nứt).
- `Fence/S` chạy thẳng sau cổng (không có lỗ cổng), cách cánh cổng 1 m. Nền đất chỉ tới z −60: ngoài tường là khoảng
  trống. Muốn nhìn qua cánh cổng thấy đường phố thì phải cắt hình tường ở lỗ cổng và thêm một dải vỉa hè, lòng đường
  ngoài cổng chỉ để nhìn (không va chạm, người chơi không tới được); va chạm `Fence/S` vẫn giữ nguyên.
- Mặt sân cổng ở −9,90; nền đất quanh sân −9,94; mặt `Road/Avenue` −9,87 (không có va chạm riêng).
- Sân cổng còn có: thanh sắt `Anchors/BarSpawns/B05` (228; −29) (`test_t249` kiểm cúi nhặt được), xe máy đổ
  `Road/FallenMoped2` + va chạm `MopedBody2` (225; −25) trong `campus.tscn`; đèn `Props/Lights/Lamp2` (240,8; −5; −22) và
  đèn khẩn cấp ô tô `Props/Lights/Hazard0` (236; −8; −26).
- Bảo vệ (`guard.gd`, lane A): cảnh báo 3 m, bắt 1,5 m; `GUARD_TURN_RADIUS` 12 m chỉ là cảnh quay đầu (`guard_turn`).

**Code, test, bot đụng tới cổng:** `chapter3_director.gd` (`_gate`, `_place_guards` đặt bảo vệ ngay trong `_ready`,
`_watch_scares`, vùng `Gate`/`Canteen`/`Road`), `guard.gd`, `ch3_environment.gd` (vùng `gate`), `ch3_guard_audio`,
`ch3_bot.gd`/`ch3_policy.gd`/`ch3_menu*.gd` (chặng `gate`), `profile_static_audit.gd` (`Guard01…12` ↔ `GuardLine`),
`tools/ch3-profile.json` (tuyến `stadium` kết thúc `P24 → P25 → P26 → Start_gate`, tuyến `gate`
`P28 → P29 → P30_Wait_canteen`, `guard_target` = `G06`, điểm xác `Gate/S01…06`); test `test_campus` (anchor, vùng),
`test_chapter3` (`run_from(&"gate")`, `DEATH_CH3_GUARD`), `test_ch3_profile`, `test_stands_props` (navmesh
`Start_gate → CanteenExit`), `test_t249_chapter3_bar` (B05), `test_t261_stadium` (`Road/Avenue/Mesh` phải hiện).
Không có âm thanh hay reverb gắn vào node của `gate.tscn`.

**Bảng hợp đồng (giữ tên, vị trí, va chạm; lượt 2 so dấu vân tay với main):**
| Node | Vị trí, kích thước | Va chạm | Ghi chú |
|---|---|---|---|
| `Gate` (gốc `gate.tscn` trong `campus.tscn`) | transform 0 | — | |
| `Court` | (220; −9,92; −40), hộp 60 × 0,04 × 40; meta `surface = tile`, `is_floor` | có | `Court/Mesh` chỉ ẩn |
| `Pillar209` | (209; −6,9; −59), xoay z 7°, hộp 1,4 × 6 × 1,4 | có | `Mesh` chỉ ẩn |
| `Pillar231` | (231; −6,9; −59), hộp 1,4 × 6 × 1,4 | có | `Mesh` chỉ ẩn |
| `Gate/Gate` | (220; −7,9; −59), hộp 20 × 4 × 0,18 | có | hình đã ẩn sẵn |
| `Booth` | (240; −8,4; −54), hộp 5 × 3 × 4 | có | `Mesh` chỉ ẩn |
| Hình PS1 không va chạm | `GateBar210…230`, `GateCross0.5`, `GateCross3.4`, `HalfFallenSign`, `SignScar0…8`, `BoothWindow`, `BoothRoof`, `RoadCrack212/222/233` (7 nhánh), `PillarCrack` (7 nhánh) | — | lượt 2 chỉ ẩn |
| `campus.tscn` `Fence/S` | (170; −8,4; −60), hộp 500 × 3 × 0,3 | có | `Fence/S/Mesh` chỉ ẩn hoặc thay theo phạm vi chủ dự án chọn |
| `Anchors/GuardLine/G01…G12` | x 210 → 230 (cách 1,82 m), y −9,9, z −54 | — | |
| `Anchors/GuardBooth`, `Clues/GatePillar`, `Start_gate` | (240; −51), (209; −58), (220; −25), y −9,9 | — | |
| `Anchors/ZombieSpawns/Gate/S01…06`, `ZombieIdle/Gate/I01…06` | x 196/200/204, z −30/−25 (idle −29/−24) | — | |
| `Paths/Nhat/P26`, `P27_Wait_gate`, `P28`, `P29`; `Paths/Ngu/P16…P19` | (220; −15), (220; −30), (220; 10), (190; 18) | — | |
| `Anchors/BarSpawns/B05` | (228; −9,9; −29) | — | mặt sân giữ cao độ −9,90 |
| `Zones/Gate`, `Zones/GuardRadius`, `Zones/Canteen`, `Zones/Road` | (220; −40) 60 × 40; (220; −52,5) 22 × 3; (194; 36) 48 × 32; (110; −15) 220 × 10 | — | |
| `props.tscn` `Solids` trong hộp A16 | 26 khối (2 thanh chắn `s17`, 5 ô tô `s16`, đống gạch, ghế, bồn cây, thân cây, xe máy…) | có | giữ cả, đồ mới đặt đúng chỗ đúng góc |
| Đèn | `Props/Lights/Lamp2`, `Hazard0` | — | không đổi |

**Đi thử tuyến** (`walk_route.gd` trên main: navmesh và thân người chơi thật `player.tscn`, `move_and_slide`, 4 m/s):
- Navmesh `Start_stadium → Start_gate` (279 m) vào khu này từ phía nhà ăn: (190; 18) → (216; 13) → (220; 12) → `Start_gate`;
  `Start_gate → CanteenExit` (108 m) đi (220; −25) → (222; −10) rồi lên nhà ăn; `Start_gate → Canteen/S01` đi dọc z −24
  sang x 190 rồi lên (190; −2) → (190; 18). Đàn xác cổng `Gate/S01…06`, `I01…06` → `Start_gate`: đều tới, trong
  x 196…220, z −30…−24. Mọi đường navmesh trong khu: x 190…222, z −30…18.
- Thân người chơi đi được hết: đồng đội/bot `P25 → P26 → P27_Wait_gate → P28 → P29 → P30_Wait_canteen`, cuối tuyến bot
  `P26 → Start_gate`, tuyến bot `gate` `Start_gate → P28 → P29 → P30`, từ `Start_gate` tới (220; −41,5) (mép 12 m của bảo
  vệ gần nhất), vòng quanh sân (196; −44) → (196; −29,5) → (246; −29,5) → (246; −46) → (232; −46), và từ góc đông bắc sân ra
  đầu `Road/Avenue` rồi dọc đường về x 180. Chân người chơi trong khu: x 170…246, z −46…20.
- Đường nhìn (tia va chạm lớp 1) từ mắt ở `Start_gate` (1,6 m) tới ngực 12 bảo vệ (1,3 m): thông cả 12. Thanh chắn PS1
  cao 0,9 m, tia đi qua chỗ thanh chắn ở độ cao khoảng 1,35 m.

**Hộp A16 đoạn cổng chốt: x 180…262, z −60…13** (mặt đất y −10,5…−6). Gồm sân cổng, 40 m cuối `Road/Avenue`
(x 180…220) và khoảng đất từ sân lên tới mép nam hộp nhà ăn (z 13) mà đồng đội, bot, đàn xác và người chơi đều đi qua;
không lấn hộp nhà ăn (x 170…210, z 13…51). Rộng hơn gợi ý của card (z −60…−10) vì tuyến sang nhà ăn đi qua
z −10…13. Danh sách đầy đủ (chỉ số bản MultiMesh): `wave5/a16_box_nodes.json`. Tóm tắt:
- `campus.tscn`: `Road/Avenue/Mesh` nằm một phần trong hộp (x 180…220 của dải x 0…220; `test_t261` đòi node này hiện:
  lượt 2 đề xuất rút ngắn hình còn x 0…180 thay vì ẩn); nền mới phủ lên 4 ô `Ground/Tile_170_-60`, `Tile_220_-60`,
  `Tile_170_-10`, `Tile_220_-10` (giữ va chạm). Giữ: đèn đường `Road/StreetLights_4_-1`, `_5_-1`, cây `Road/Trees_4_-1`,
  `_5_-1`, thân cây `TreeTrunk104/105`, `Road/FallenMoped2`, `BarSpawns/B05`.
- `props.tscn` (bản MultiMesh còn hiện trên main, lượt 2 thu cỡ về 0 như T-261): 2 thanh chắn (12 bản:
  `P_white_box_p5_m2`, `P_iron_box_p5_m2`), 2 hàng cọc giao thông (12 bản: `P_white_cone_p5_m2`, đế trong
  `P_white_box_p5_m2`), 5 ô tô PS1 (70 bản: thân, cabin, kính, mui, bánh, cản, đèn trong `P_white_box_p5_m1`,
  `P_white_box_p4_m1`, `P_iron_cylinder_p5_m1`, `P_iron_cylinder_p4_m1`, `P_iron_box_p5_m1`, `P_iron_box_p4_m1`,
  `P_paper_box_p5_m1`, `P_paper_box_p4_m1`), 38 tờ giấy (`D_paper_quad_p2_m1`, `_p2_p0`, `_p3_m1`), đồ rơi (6 bản ba lô,
  10 giày, 4 dép, 14 mảnh điện thoại), đống gạch vỡ ở (214; −22,7) (14 bản). Giữ nguyên: xác (30 bản, gồm đầu xác), máu
  (6), vết nứt và vệt kéo (67), ghế đá, bồn cây, xe đạp, xe máy, thùng gỗ, biển chỉ đường, bảng tin, cột đèn, cây.

**Lỗi cũ phát hiện khi khảo sát (ngoài phạm vi, chưa sửa):** bộ lọc "giấy rác" của T-259 và T-261 bắt nhầm **đầu của 3
xác tĩnh** (khối 0,22 m màu da `(0,9; 0,7; 0,6)` tên `P_paper_box_*`, cao −9,78) nên 3 xác trên main đang mất đầu:
`P_paper_box_p1_p0` bản 0 (43,6; 30,2) (T-259), `P_paper_box_p2_p2` bản 1 (82,6; 86,5) và `P_paper_box_p2_p4` bản 1
(85,5; 161,8) (T-261). Sửa: trả lại ma trận gốc của 3 bản đó trong `props.tscn` (và bỏ tờ giấy mới đặt đúng chỗ đó nếu
có); `test_t261_stadium` đang đòi ít nhất 373 bản thu về 0 nên cần hạ còn 371. Bộ lọc đợt này đã loại riêng màu da.
Xin integrator cho phép làm việc này ở lượt 2 (hoặc giao việc riêng).
