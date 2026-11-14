# T-259 — Đồ hoạ thật đợt 3: vườn hoa trước nhà B, dải nối từ nhà B, cảnh ngoài nhìn từ tầng 4 ở chương 1–2
- Lane: B | Trạng thái: in progress (lượt 1 xong 14/11, nhánh lane B `0dbec92`; chủ dự án đã chọn, D-175; chờ lượt 2) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1n).
- Nhánh: `lane-b/T-259-realistic-graphics-wave3-garden` từ `origin/main` mới nhất.
- Quyết định nền: **D-166** (vườn hoa: cây, hoa phổ biến ở trường Việt Nam, **giữ mật độ**, đồ hoạ thật **dựng bằng Blender, không PS1, không Tripo**; ánh sáng giữ như nay), **D-167/D-172** (phong cách nhà B đợt 1–2 đã duyệt: cũ vừa phải), **D-170** (cảnh ngoài nhìn từ tầng 4 ở chương 1–2 làm sau khi vườn xong, bằng bản nhẹ của chính vườn này). Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 3 (A12 + một phần A16).
- **PLAN mục 3 ghi "2 cụm cây/hoa Tripo, tùy chọn" cho A12: không áp dụng.** D-166 chốt Blender, không Tripo.

## 0. Hiện trạng (integrator khảo sát 14/11; lane B kiểm lại ở bước 1)
- `game/scenes/levels/campus/garden.tscn` (gốc `Garden` trong `campus.tscn`), dùng ở **chương 3 và 4**, và **nhìn thấy từ hành lang tầng 4** ở chương 3–4 (vườn nằm ngay trước nhà B). Toàn PS1: 6.564 tam giác, 19 vật liệu (T-248). Ảnh hiện trạng: `realistic_map/previews/survey/26_garden_entry.jpg`, `27_garden_bench.jpg`, `37_road_garden.jpg`.
- Sân lát `Paving` 44 × 40 m (x 0…44, z 8…48, mặt y −9,9; meta `surface = tile`, `is_floor`).
- **12 bồn hoa** `Bed{0..3}_{0..2}` (khối 6 × 0,5 × 4 m) ở x 6 / 22 / 38, z 12 / 22 / 32 / 42; mỗi bồn một cây thấp `LowTrunk*` + `LowCrown*` (tán hình nón PS1), 4 bụi `Bush*`, 12 khóm hoa `Flower*` (144 node riêng lẻ).
- **Va chạm tán `LowCrown*/CanopyCollision`** (T-251: khối hình nón, để thân Trần Trung không lọt vào tán khi chạy sát).
- 4 ghế `Bench*` + `BenchCollision*`; **ghế của Ngư `NguBench`** (22; −9,42; 28) có hai chân riêng.
- Đèn vườn: `GardenLights_*` (cột đèn vẽ bằng MultiMesh trong `foliage.gd`), 6 đèn `Flicker*` (`OmniLight3D` + `flicker.gd`, nhấp nháy).
- Đồ đổ vỡ: `FallenBunk` (giường tầng đổ, có va chạm, ở (8; −9,45; 37)), `BrokenBunk`, `DetachedRail*`. **Thanh sắt `Anchors/BarSpawns/B01` (8; −9,65; 37) nằm trên giường tầng đổ** (`chapter3_director._settle_bars` đặt thanh sắt lên mặt va chạm đầu tiên bên dưới).
- Truyện chương 3 ở vườn (`chapter3_director.gd` `_garden()`): người chơi và Minh Nhật tới `Start_garden`; Ngư ngồi ở `NguBench`, đưa thanh sắt (8 lần đánh) nếu người chơi chưa có; cảnh doạ `flowerbed_crawl`; 4 xác sống sinh ở `Anchors/ZombieSpawns/Garden/*`, đứng chờ ở `ZombieIdle/Garden/*`; vùng `Zones/Garden` quyết định "đang ở vườn". Bot chương 3 (`tools/ch3-profile.json`) dùng `Start_garden`, `ZombieSpawns/Garden/S01`, `S03` và vài toạ độ trong vườn.
- Chương 1–2 (không có khuôn viên): nhìn qua lan can tầng 4 chỉ thấy 4 "cây" hộp đen `Corridor/YardTree_*` (ở y −3,0) và một đèn `DistantStreetLamp`; khuôn viên chương 3–4 ẩn chúng (`campus.gd`). Mặt đất khuôn viên ở y −9,9.
- Hiệu năng: chương 3 đã giật nhẹ khi nhìn từ hành lang tầng 4 ra khuôn viên (1% khung chậm nhất 36–53 FPS, cả trước T-255: [T-255-rooms-fps](../../tools/reports/T-255-rooms-fps.md), [T-237](../../tools/reports/T-237-chapter-fps.md)); vườn có 40 xác sống từng xuống 31,5 FPS từng khung. **Vườn là chỗ phải giữ nhẹ nhất từ đầu.** Bộ nhớ hình sau T-257: chương 3 khoảng 1,25 GB trên 4 GB.

## 1. Chủ dự án chốt
**D-175**, ngày 14/11/2026. Chủ dự án chọn trên ảnh lượt 1 của lane B (`art_source/graphics_upgrade/realistic_map/previews/wave3/`, commit `0dbec92` trên nhánh lane B). Mọi câu đều theo đề xuất:
1. **Cây:** hoa sứ (hoa đại, T1) và bằng lăng (T3) xen nhau, **8 bồn hoa sứ, 4 bồn bằng lăng**. Lane B tự chọn bồn nào trồng bằng lăng; rải đều để nhìn từ tầng 4 không dồn về một phía.
2. **Hoa trên cây:** giữ như ảnh. Hoa sứ có hoa trắng nhuỵ vàng; bằng lăng có chùm hoa tím và vài cành lá già đỏ.
3. **Trong bồn:** F1 cho cả 12 bồn, tức viền chuỗi ngọc xén thấp và 4 bụi trang đỏ (12 khóm hoa như PS1). Để "mỗi bồn khác nhau một chút", xoay, lệch chỗ hoặc đổi cỡ bụi; không thêm loài.
4. **Viền bồn:** K1, gạch trát quét vôi trắng. Trong ảnh lượt 1, dưới đèn trăng viền hơi ngả be. Lượt 2 chỉnh lại cho ra màu vôi trắng cũ, bẩn ở chân.
5. **Sân:** P1, gạch block "con sâu" xám.
6. **Ghế, đèn:** ghế đá mài và cột đèn cầu tròn như ảnh. Bốn ghế có tựa `Bench0…3` làm cùng kiểu đá mài có tựa. **Không sơn chữ** lên ghế.
7. **`DistantStreetLamp` (chương 1–2):** chỉ ẩn hình cột (`Fixture`, `Stem`), giữ nguồn sáng OmniLight3D đúng chỗ. Cột đèn của bản nhẹ đặt đúng vị trí đèn đó.
8. **Bảng tin trong vườn:** lượt 2 làm hình mới đúng chỗ cũ, nằm trong hộp va chạm cũ `Props/Solids/Body_p0_p0/S0`. Giấy dán giữ nguyên, không đổi chữ.

D-173 vẫn áp dụng: không đo FPS sau merge. Theo phương án này, cả vườn ở bản gần ước khoảng 88 nghìn tam giác. Muốn nhẹ hơn thì dùng các cách lane B đã nêu: gộp lưới theo vật liệu, vẽ cây bằng MultiMesh, bớt một tầng cành hoa sứ, kéo khoảng chuyển sang bản xa lại gần.

## 2. Việc, theo hai lượt

### Lượt 1 — khảo sát và góc mẫu, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi Handoff:** kiểm lại mục 0; tìm mọi chỗ code, test, bot đụng tới vườn (grep `garden.tscn`, `Garden/`, `NguBench`, `Start_garden`, `ZombieSpawns/Garden`, `BarSpawns/B01`, `flowerbed_crawl`, `FallenBunk`, `CanopyCollision` trong `game/scripts/`, `game/tests/`, `tools/*.json`, kể cả `chapter4_director.gd`) và lập **bảng hợp đồng** (node nào giữ tên, vị trí, va chạm). Liệt kê **chính xác đường dẫn node A16** nằm trong phạm vi mục 3 (dải nối).
2. **Góc mẫu** quanh ghế Ngư: hai bồn `Bed1_1`, `Bed2_1`, ghế `NguBench`, một đoạn sân lát, một cột đèn vườn. Dựng bằng Blender, chất lượng ngang phòng 407 và nhà B đợt 1–2. Kèm **phương án để chủ dự án chọn bằng mắt** (ảnh cùng camera, chương 3 thật, ban đêm như chương, có và không đèn pin):
   - **cây thấp trong bồn**: 2–3 loài cây hay trồng ở sân trường, ký túc xá Việt Nam (lane B đề xuất loài, có ảnh tham chiếu thật, ghi nguồn);
   - **hoa, bụi trong bồn**: 2 phương án;
   - **sân lát, viền bồn, ghế đá, cột đèn**: phương án đề xuất (một hoặc hai).
   Mỗi phương án ghi số tam giác, vật liệu, cách vẽ lá. Đề xuất một phương án.
3. Commit, push nhánh, ghi Handoff, **báo và dừng**. Integrator chuyển phương án cho chủ dự án, ghi lựa chọn vào mục 1.

### Lượt 2 — làm cả vườn (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
4. **Vườn hoa (A12):** cả 12 bồn, 12 cây, bụi, hoa (giữ mật độ, mỗi bồn khác nhau một chút), sân lát, viền, 4 ghế và ghế Ngư, cột đèn vườn, đồ đổ vỡ (giường tầng đổ, lan can rời) theo đúng vị trí và va chạm cũ.
5. **Dải nối nhà B → vườn (A16, chỉ phần trong mục 3).**
6. **Cảnh ngoài chương 1–2 (A05, D-170):** bản nhẹ của chính vườn này (cây, bồn, đèn, sân; không va chạm) đặt dưới tầng 4 ở chương 1–2, **cùng toạ độ thế giới** với vườn của khuôn viên, thay 4 hộp đen `YardTree_*` và `DistantStreetLamp` (chỉ ẩn, không xoá). Trước khi dựng, đo: tầng 4 ở chương 1–2 và 3–4 có cùng gốc toạ độ không; ở chương 1–2 dưới lan can có mặt đất ở độ cao nào; lan can tầng 4 nhìn thấy dải z nào. Khuôn viên chương 3–4 vẫn ẩn bản nhẹ này (như đang ẩn `YardTree_*` trong `campus.gd`); chương 1–2 vẫn nạp được khi không có khuôn viên.
7. Ảnh trước/sau, ảnh ghép, test, full test, check, Handoff.

## 3. Phạm vi A16 trong đợt này
- **Chỉ** mặt đất, viền, rãnh, đồ rải (rác, giấy, gạch vỡ) **trong dải từ mặt trước nhà B tới hết vườn**: x −6…50, z 4…50, y −10,5…−6. Lane B liệt kê đúng đường dẫn node ở bước 1 trước khi sửa.
- **Không** đụng đường, hàng rào, cây và đồ rải ở các khu khác (sân vận động, cổng, nhà ăn, đường lớn): đó là các đợt 4–7. Không thay MultiMesh nhẹ bằng hàng nghìn node.

## 4. Hợp đồng gameplay (bắt buộc giữ)
- Không đổi tên, gốc, transform: `Garden`, `Paving` (và meta), `Bed*`, `LowTrunk*`, `LowCrown*`, `Bench*`, `BenchCollision*`, `NguBench` và hai chân, `FallenBunk`, `BrokenBunk`, `DetachedRail*`, `Flicker*` (vị trí, năng lượng, màu, tầm, script), `GardenLights_*` (điểm đặt); trong `campus.tscn`: `Anchors/Start_garden`, `Anchors/NguBench`, `Anchors/ZombieSpawns/Garden/*`, `Anchors/ZombieIdle/Garden/*`, `Anchors/BarSpawns/B01`, `Zones/Garden`, navigation.
- **Va chạm giữ nguyên** (test so dấu vân tay với main như T-250, T-253): bồn, ghế, ghế Ngư, giường tầng đổ, sân lát, thân cây.
- **Va chạm tán T-251 giữ nguyên, và mọi tán lá nhìn thấy ở độ cao dưới 2 m phải nằm trong khối `CanopyCollision` của cây đó** (nếu không, thân Trần Trung lại lọt vào tán). Tán trên 2 m được rộng hơn. `test_t251_ground_garden` phải đạt **không sửa**.
- Thanh sắt `B01` vẫn nằm trên giường tầng đổ và nhặt được; Ngư vẫn ngồi đúng ghế; lối đi giữa các bồn, tuyến đồng đội, xác sống, bot (toạ độ T-251 đã kiểm) không bị cây, hoa, đồ mới chặn.
- Hình PS1 chỉ ẩn (`visible = false`), không xoá. Không đổi luật, thời gian, lời thoại, director, `Ch3Use`.
- Ánh sáng giữ như nay (D-166): không thêm đèn, không đổi đèn có sẵn; cột đèn mới chỉ là hình quanh điểm đèn cũ, vật liệu phát sáng theo đèn nhấp nháy như máng đèn hành lang.

## 5. Kỹ thuật và hiệu năng
- **Dựng bằng script Blender** (Blender 5.2.2 portable ở `D:\Tools\Blender\5.2.2`) như các đợt trước. Được dùng mesh, texture lá, vỏ cây, đá **CC0** (Poly Haven, ambientCG…) làm nguồn nếu ghi URL, tác giả, giấy phép trong CREDITS. **Không cài extension/addon Blender, không Tripo, không ảnh AI.**
- Lá: thẻ lá alpha **cắt (alpha scissor), không trộn alpha**; lá **không đổ bóng** (trừ khi integrator đo thấy không tốn); thân và cành đổ bóng được. Mỗi cây có bản gần và bản xa (LOD hoặc `visibility_range`); hoa, cỏ lặp dùng MultiMesh theo cụm.
- Ngân sách (PLAN mục 6): vườn **≤ 0,40 ms** thêm khi ở gần; ghi số tam giác, vật liệu, số lần vẽ cho góc mẫu và cả vườn. Bản nhẹ chương 1–2: rất nhẹ (gợi ý ≤ 30 nghìn tam giác, ít vật liệu, không bóng).
- **Mọi texture mới từ 512 px trở lên phải nén VRAM:** trong `.import` đặt `compress/mode=2`, texture normal thêm `compress/normal_map=1` (Godot nhập ở chế độ không cửa sổ để mặc định **không nén**, T-257 vừa phải sửa 333 file vì việc này). Texture lá có alpha: kiểm ảnh sau khi nén, mép lá không nhoè.
- Không đo FPS, không chạy bot. **D-173: chủ dự án không cho đo FPS sau merge đợt này**, nên ghi số tam giác, vật liệu, số lần vẽ thật kỹ.

## 6. Ảnh
- `art_source/graphics_upgrade/realistic_map/previews/wave3/`: lượt 1 `pilot_*` và phương án; lượt 2 `before_*`/`after_*` cùng camera trong **chương 3 thật** (cổng vào vườn, giữa vườn, ghế Ngư, giường tầng đổ, nhìn từ hành lang tầng 4 xuống) và **chương 1 thật** (nhìn từ hành lang tầng 4 xuống, trước/sau bản nhẹ); ảnh ghép tổng `overview.jpg`. Ban đêm như chương, có và không đèn pin.

## 7. Kiểm
- Test mới `game/tests/levels/test_t259_*.gd`:
  - dấu vân tay va chạm vườn, ghế, giường tầng đổ trùng main; node, anchor, đèn giữ nguyên; hình PS1 ẩn;
  - tán lá dưới 2 m nằm trong khối `CanopyCollision`;
  - capsule đi được các lối giữa bồn, tới ghế Ngư, tới thanh sắt `B01`; thanh sắt nằm trên giường tầng đổ;
  - **mọi `.import` texture trong thư mục asset đợt 3 có `compress/mode=2`** (normal có `compress/normal_map=1`);
  - chương 1–2: bản nhẹ hiện, `YardTree_*` ẩn; chương 3–4: bản nhẹ ẩn.
- Test cũ đạt: `test_campus`, `test_t251_ground_garden` (không sửa), `test_wide_corridors`, `test_chapter3`, `test_chapter4`, `test_ch3_*`, `test_floor4*`, `test_t250*`, `test_t253*`, `test_t255*`, `test_t256*`, `test_graphics_bindings`. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## 8. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave3/`, `.../previews/wave3/`, `game/assets/models/graphics_pilot/realistic_map/wave3/`, `game/assets/textures/graphics_pilot/realistic_map/wave3/`, `game/scenes/levels/campus/garden.tscn`, `foliage.gd` (chỉ phần `garden`), `campus.tscn` và `props.tscn` (chỉ phần hình A16 trong mục 3), `campus.gd` (ẩn bản nhẹ khi có khuôn viên), `game/scenes/levels/floor4/` (bản nhẹ chương 1–2: `floor4.gd`, `corridor.tscn` hoặc cảnh mới), script cảnh mới trong `game/scenes/levels/`, test mới `game/tests/levels/`, card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `chapter*.tscn`; sửa nhà B, phòng 407, tầng 4 ngoài phần cảnh ngoài chương 1–2; khu ngoài mục 3.
- Tripo, credit Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [x] Lượt 1: khảo sát, bảng hợp đồng, danh sách node A16 (Handoff)
- [ ] Lượt 1: góc mẫu và phương án (cây, hoa, sân, ghế, đèn), ảnh; dừng chờ chủ dự án chọn
- [ ] Lượt 2: cả vườn
- [ ] Lượt 2: dải nối nhà B → vườn
- [ ] Lượt 2: cảnh ngoài chương 1–2
- [ ] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
### Lượt 1 — khảo sát (lane B, 14/11/2026)
Nhánh `lane-b/T-259-realistic-graphics-wave3-garden` từ `origin/main` `e517c54` (đã có T-258, T-260). Card đọc ở commit `415763a`.

**Kiểm lại mục 0: đúng.** Số đo cụ thể (toạ độ thế giới; `Garden` đặt ở gốc toạ độ của `Campus`; sân y −9,9):
- `Paving`: StaticBody (22; −9,93; 28), hộp 44 × 0,06 × 40, mặt trên y −9,90, meta `surface = tile`, `is_floor`.
- Bồn `Bed{i}_{j}`: i là hàng theo z (12 / 22 / 32 / 42), j là cột theo x (6 / 22 / 38). Hộp va chạm 6 × 0,5 × 4, miệng bồn y −9,40. Con `Soil` 5,7 × 0,08 × 3,7, mặt đất trong bồn y −9,33 (nổi 7 cm trên miệng bồn).
- Cây `LowTrunk{i}_{j}`: trụ bán kính 0,08–0,10 m, y −9,7…−8,1. **Thân cây không có va chạm riêng**; khối bồn chặn người chơi (PLAN ghi "collision thân", thực tế không có, giữ nguyên như vậy).
- `LowCrown{i}_{j}`: nón cụt bán kính 1,1 → 0,175 m, y −8,7…−7,1 (1,2…2,8 m trên sân). Con `CanopyCollision` cùng hình (ConvexPolygon 16 điểm, layer 1). Ở 2 m trên sân (y −7,9) khối tán còn bán kính 0,64 m; dưới 1,2 m không có khối tán.
- Bụi `Bush{i}_{j}_{k}` (k 0…3): trụ bán kính 0,45–0,65, cao 1 m (y −9,7…−8,7), xếp dọc trục x của bồn (lệch −1,9 / −0,6 / +0,7 / +2,0 m). Hoa `Flower{i}_{j}_{k}_{m}` (m 0…2): hộp 10 cm ở y −8,8 trên đỉnh bụi, 144 node. Bụi, hoa không có va chạm; người chơi đứng được trên miệng bồn (test T-251 đặt capsule ở y −9,35).
- Ghế `Bench0…3` (Node3D: `Seat`, `Leg-0.85`, `Leg0.85`, `Back`) ở (2; 22), (42; 22), (6; 47), (38; 47), y −9,9; `BenchCollision0…3` hộp 2,4 × 0,8 × 0,6, tâm y −9,5. Ghế Ngư `NguBench`: StaticBody (22; −9,42; 28), mặt ngồi 2,4 × 0,18 × 0,7 (mặt trên −9,33), không tựa. Hai chân `NguBenchLeg21.15` và `NguBenchLeg22.85` là Node3D riêng, ngang hàng `NguBench`, không va chạm.
- Đèn: `GardenLights_0_0` (x 1; z 10 và 24), `_0_1` (1; 40), `_1_0` (43; 10 và 24), `_1_1` (43; 40). Đây là `foliage.gd` kind `garden`: cột 3 m và chao phát sáng vẽ bằng MultiMesh. Đèn `Flicker0…5`: OmniLight3D ở y −7,0, cùng x và z với cột, tầm 5 m, không bóng, màu (0,7; 0,72; 0,45), `flicker.gd` (năng lượng 0,35 hoặc 0,015). **Không có cột đèn nào gần ghế Ngư**; gần nhất là (1; 24), cách 21 m.
- Đồ đổ: `FallenBunk` StaticBody (8; −9,45; 37) hộp 2 × 0,9 × 2 (Mesh PS1 đã ẩn từ trước), `BrokenBunk` (`kit/bunk_bed.glb` nằm nghiêng 90°), `DetachedRail0…3`.
- Ánh sáng chương 3–4 (`campus.tscn`): `Dawn` DirectionalLight3D 0,65, **không bóng**; ambient 0,65; sương 0,018. Đèn pin người chơi có bóng.
- Đếm hiện trạng (probe, chưa trừ culling): `Garden` 532 node, 6.564 tam giác, 19 vật liệu, 276 lần vẽ (mỗi surface một lần).

**Code, test, bot đụng tới vườn** (grep đủ các từ khoá của card trong `game/scripts/`, `game/tests/`, `game/scenes/`, `tools/*.json`):
| Chỗ | Dùng gì |
|---|---|
| `chapter3_director.gd` `_garden()` | `Start_garden` (tới nơi, Nhật nhập ở +1,2 m theo x), `NguBench` (Ngư `_join(..., false)` đứng ở anchor; gặp khi người chơi cách < `NGU_MEET_RADIUS` 4 m), `_horde.place_idle(&"Garden")`, `_scare(&"flowerbed_crawl")` (chỉ phát `EventBus.scare_triggered`, không gắn node vườn nào), `_spawn(&"Garden", 4)` |
| `chapter3_director.gd` khác | `_zone()` đọc `Zones/Garden`; tiếp tục từ điểm lưu thì quay mặt PI; `_settle_bars`: tia layer 1 từ B01 + 2 m xuống, thanh sắt nằm trên mặt va chạm đầu tiên (mặt trên `FallenBunk`, y −9,0) |
| `chapter4_director.gd` | không nhắc tới vườn |
| `scripts/debug/ch3_menu.gd` | mục "Garden" |
| `tools/ch3-profile.json` (bot) | `Start_garden`, `ZombieSpawns/Garden/S01…S06` |
| `test_t251_ground_garden` | 12 `LowCrown*` phải là **MeshInstance3D mang CylinderMesh** (test đọc bán kính từ mesh, kể cả khi ẩn); tia ngang chạm `CanopyCollision` đúng mặt nón; capsule tại (7,8; −9,35; 12) bị tán chặn; anchor không chạm tán; navmesh cách tâm tán ≥ 1,4 m; tuyến Nhật/Ngư không chạm tán |
| `test_chapter3`, `test_t249_chapter3_bar` | `Start_garden`, `NguBench` (+ lệch 1–1,5 m) |
| `test_campus`, `test_stands_props`, `test_wide_corridors`, `test_ch3_profile` | anchor, `Zones/Garden`, `Garden/Paving` z, chuyển vùng b → Garden |

**Bảng hợp đồng (lượt 2 giữ nguyên tên, gốc, transform, va chạm):**
| Node | Giữ | Hình mới làm gì |
|---|---|---|
| `Garden` (gốc trong `campus.tscn`) | tên, transform 0 | hình mới là con mới của `Garden` |
| `Paving` + `Collision`, meta | nguyên | ẩn `Paving/Mesh`, sân mới phủ đúng mặt y −9,90 |
| `Bed{i}_{j}` + `Collision` | nguyên | ẩn `Mesh`, `Soil/Mesh`; viền và đất mới nằm trong hộp 6 × 0,5 × 4 |
| `LowTrunk{i}_{j}` | nguyên | ẩn; thân mới mọc đúng tâm |
| `LowCrown{i}_{j}` + `CanopyCollision` | nguyên, **giữ CylinderMesh** (test T-251 đọc) | ẩn; tán dưới 2 m nằm trong khối nón |
| `Bush*`, `Flower*` | nguyên | ẩn; cây bụi, hoa mới trong lòng bồn |
| `Bench0…3`, `BenchCollision0…3` | nguyên | ẩn lưới con; ghế mới trong hộp va chạm |
| `NguBench` + `Collision`, `NguBenchLeg21.15`, `NguBenchLeg22.85` | nguyên | ẩn lưới; mặt ghế mới ở đúng y −9,33 (Ngư ngồi theo anchor `Anchors/NguBench` y −9,33) |
| `FallenBunk` + `Collision`, `BrokenBunk`, `DetachedRail0…3` | nguyên; B01 vẫn nằm trên mặt −9,0 | lượt 2 làm hình theo đúng chỗ |
| `GardenLights_*` (điểm đặt) | `points` nguyên | cột đèn mới vẽ tại đúng các điểm |
| `Flicker0…5` | vị trí, năng lượng, màu, tầm, script | không đổi; chao đèn mới phát sáng theo năng lượng đèn |
| `campus.tscn`: `Anchors/Start_garden`, `Anchors/NguBench`, `Anchors/ZombieSpawns/Garden/*`, `Anchors/ZombieIdle/Garden/*`, `Anchors/BarSpawns/B01`, `Anchors/Paths/Nhat`, `Anchors/Paths/Ngu`, `Zones/Garden`, `Navigation` | không sửa | |

**Node A16 trong dải x −6…50, z 4…50, y −10,5…−6** (probe trên `campus.tscn` thật, trừ `Garden` và `BuildingB`; `Props` vẽ bằng MultiMesh lúc chạy nên đếm theo từng bản sao):
| Node | Là gì | Trong dải |
|---|---|---|
| `Ground/Tile_-30_-10`, `Tile_-30_40`, `Tile_20_-10`, `Tile_20_40` (`campus.tscn`) | 4 tấm nền cỏ PS1 50 × 50 m có va chạm, meta `tile`, mặt trên y −9,94 (thấp hơn sân lát 4 cm) | một phần mỗi tấm; không sửa tấm, lượt 2 chỉ đắp hình mới lên trên trong dải |
| `Props/Parts/P_concrete_box_p0_p1` | gạch bê tông vỡ | 11/42 bản (ba đống ở z 49–51, x 7,5 / 22 / 36) |
| `Props/Parts/P_iron_cylinder_p0_p1` | thanh sắt cạnh đống gạch | 1/9 (7,5; 50,5) |
| `Props/Parts/P_paper_box_p0_p0`, `_p0_p1`, `_p1_p0` | giấy, túi rác | 13/13, 1/1, 1/3 (6 trong số đó là giấy dán trên bảng tin) |
| `Props/Parts/P_white_box_m1_p0`, `_p0_p0`, `_p0_p1`, `_p1_p0`; `P_white_cylinder_m1_p0` | túi, khối trắng; thùng (−3; 11,8) | 6/6, 31/31, 3/3, 7/15, 1/2 |
| `Props/Decals/D_iron_quad_m1_p0`, `_p0_p0` | vết bẩn, vệt kéo sẫm trên sân | 11/54, 79/102 |
| `Props/Decals/D_paper_quad_m1_p0`, `_p0_p0`; `D_white_quad_m1_p0`, `_p0_p0` | giấy, mảnh trắng trên sân | 4/4, 48/73; 1/1, 8/41 |
| `Props/Decals/D_red_quad_p0_p0` | vết đỏ (máu) | 15/15 |
| `Props/Parts/P_iron_box_p0_p0`, `P_wood_box_p0_p0` | **bảng tin** (hai cột sắt, tấm gỗ) ở (30,5; 11,1), va chạm `Props/Solids/Body_p0_p0/S0` | 3/3, 1/1 |
| `Props/Trees/ExtraTrees_1_0` | 2 cây PS1 ở x 51,7 | ngoài dải (tâm x > 50), chỉ tán chạm mép; không đụng |
| `Props/Solids/Body_m1_p0/S1`, `Body_p0_p1/S0…S2` | va chạm thùng, đống gạch | không sửa |
Ghi chú A16: các cụm khối trắng kèm vết đỏ ở (11,5; 17), (16,3; 18,5), (29; 27), (14,5; 36,6), (43; 30,3) là **mảnh xác tĩnh** (PLAN mục 2: xác tĩnh gộp trong `Props`, tách khỏi việc môi trường): lượt 2 không đụng. Không có `Road`, `Fence` nào trong dải.

**Câu hỏi / ghi chú cho lượt 2:**
1. `DistantStreetLamp` (tầng 4, chương 1–2) là một **OmniLight3D** (năng lượng 0,5, tầm 7 m), `Fixture` và `Stem` là con. Ẩn cả node sẽ tắt đèn, trái với "giữ ánh sáng". Đề xuất: chỉ ẩn `Fixture`, `Stem`, giữ đèn (hoặc đặt cột đèn của bản nhẹ đúng chỗ đèn).
2. Bảng tin trong vườn (`P_iron_box_p0_p0` + `P_wood_box_p0_p0` + giấy) nằm trong `props.tscn`. Card mục 3 chỉ kể "mặt đất, viền, rãnh, đồ rải": lượt 2 có làm hình bảng tin không? Lane B đề xuất có (cùng chỗ, trong hộp va chạm cũ).
