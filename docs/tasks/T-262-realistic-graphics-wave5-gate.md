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
- [ ] Lượt 1: khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp và danh sách node A16 (Handoff)
- [ ] Lượt 1: góc mẫu và phương án (cánh cổng, trụ và biển, chốt, tường rào, sân cổng), ảnh có hàng bảo vệ; dừng chờ chủ dự án chọn
- [ ] Lượt 2: cổng, chốt, tường rào
- [ ] Lượt 2: dải A16 đoạn cổng
- [ ] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
(lane B ghi)
