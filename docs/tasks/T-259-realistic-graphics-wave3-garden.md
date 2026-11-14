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
- [x] Lượt 1: góc mẫu và phương án (cây, hoa, sân, ghế, đèn), ảnh; dừng chờ chủ dự án chọn
- [x] Lượt 2: cả vườn
- [x] Lượt 2: dải nối nhà B → vườn
- [x] Lượt 2: cảnh ngoài chương 1–2
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

### Lượt 1 — góc mẫu và phương án (lane B, 14/11/2026)
**Đã làm.** Góc mẫu quanh ghế Ngư: bồn `Bed1_1`, `Bed2_1` (viền, đất, cây, cây bụi, hoa), ghế `NguBench`, sân lát (lát cả 44 × 40 m vì là một tấm), cột đèn vườn ở hai điểm của `GardenLights_0_0` (x 1; z 10 và 24, quanh `Flicker0`, `Flicker1`). Dựng bằng script Blender, texture vẽ bằng code; không Tripo, không extension, không ảnh AI. Cách dựng lại, bảng phương án, nguồn: `art_source/graphics_upgrade/realistic_map/wave3/README.md`.
- **`garden.tscn` chưa sửa.** `capture_wave3.gd` gắn góc mẫu vào cảnh chương 3 thật lúc chạy (ẩn hình PS1 của các phần trên bằng `visible = false`), giữ sáu đèn `Flicker*` sáng 0,35 khi chụp để các phương án sáng như nhau. Không đổi va chạm, anchor, vùng, đèn, navmesh, director.
- File: `art_source/.../wave3/` (`make_wave3_textures.py`, `build_garden_pilot.py`, `make_wave3_materials.py`, `capture_wave3.gd`, `make_wave3_sheets.py`, README), `game/assets/models/graphics_pilot/realistic_map/wave3/` (10 glb, vật liệu `W3*`, `materials/foliage.gdshader`, CREDITS), `game/assets/textures/graphics_pilot/realistic_map/wave3/` (23 PNG, CREDITS), test `game/tests/levels/test_t259_garden_pilot.gd`.
- **Texture:** cả 23 file mới (512–1024 px) nhập nén VRAM (`compress/mode=2`, normal có `compress/normal_map=1`, mipmap bật; nhập thành `s3tc`). Atlas lá có alpha: mép lá xem trong ảnh không nhoè (màu được đẩy ra vùng trong suốt trước khi nén). Bộ nhớ hình chương 3 khi chụp: 1.265 MB (T-258: 1.269 MB); phần texture mới ước khoảng 17 MB.
- **Hợp đồng tán (T-251):** mọi đỉnh của cả ba cây (bản gần và bản xa) thấp hơn 2 m trên sân nằm trong đường tròn nội tiếp của khối bát giác `CanopyCollision` (nên cây xoay góc nào cũng vẫn trong khối); dưới 1,2 m chỉ có thân, bán kính ≤ 0,13 m như thân PS1. Script dựng kiểm từng đỉnh (0 đỉnh ra ngoài, lề nhỏ nhất 1 cm), test kiểm lại trên glb đã nhập. Ghế đá Ngư: mặt ghế đúng y −9,33 (anchor `NguBench`), nằm trong hộp va chạm cũ.
- Lá, hoa không đổ bóng (node `Leaves*`, `Planting*` tắt `cast_shadow`); thân, cành có bóng (chỉ đèn pin có bóng ở vườn). Lá là thẻ cắt alpha (không trộn), hai mặt, gần như không bóng gương (để không loá trắng dưới đèn trăng).

**Ảnh** (`art_source/graphics_upgrade/realistic_map/previews/wave3/`, chương 3 thật, ban đêm như chương, có và không đèn pin):
- `options_trees.jpg` (cây: hiện tại, T1, T2, T3, T1 + T3 xen), `options_beds.jpg` (F1, F2; viền K1, K2), `options_paving.jpg` (P1, P2), `options_lamp_bench.jpg` (ghế đá, cột đèn), `pilot_overview.jpg` (góc mẫu đề xuất so với hiện tại), `references.jpg` (ảnh thật của các loài, Wikimedia Commons CC0/CC BY, ghi tác giả; chỉ để so).
- Ảnh lẻ: `pilot_<phương án>_<góc>_<dark|torch>.jpg`, 62 ảnh. Góc: `bench_wide` (ghế Ngư giữa hai bồn), `bench_close`, `bed_close`, `entry` (lối giữa các bồn), `lamp`, `floor4` (từ hành lang tầng 4 nhìn xuống).

**Phương án** (tam giác: bản gần / bản xa; vật liệu = số vật liệu runtime):
| Mã | Là gì | Tam giác | Vật liệu | Cách vẽ lá |
|---|---|---|---|---|
| T1 | Hoa sứ / hoa đại (*Plumeria obtusa*): cành mập rẽ đôi, chùm lá dài ở đầu cành, hoa trắng nhuỵ vàng | 6.170 / 262 | 2 | từng lá thật (lưới 3 × 3, gập theo gân, cong rủ); hoa là thẻ chéo; bản xa một thẻ quạt mỗi đầu cành |
| T2 | Bàng Đài Loan (*Terminalia mantaly*): thân thẳng, 7 tầng cành ngang | 1.788 / 207 | 2 | thẻ "đĩa" hoa thị lá nhỏ nằm gần ngang trên cành |
| T3 | Bằng lăng (*Lagerstroemia speciosa*): thân chẻ ba, tán tròn, chùm hoa tím, vài cành lá già đỏ | 1.256 / 230 | 2 | 260 thẻ cành lá trên vỏ tán, 16 chùm hoa |
| F1 | Viền chuỗi ngọc vàng xén + 4 bụi trang đỏ (3 chùm hoa mỗi bụi = 12 khóm như PS1) | 1.324 / bồn | 2 | khối hàng rào có texture lá + thẻ lá rối; bụi 40 thẻ |
| F2 | 4 khóm cẩm tú mai + 12 khóm dừa cạn hồng, trắng + cỏ ven viền, lộ đất | 432 / bồn | 1 | thẻ quanh tâm khóm |
| K1 / K2 | Viền gạch trát quét vôi trắng / sơn vàng, bẩn chân, bong góc, rêu; đất có lá khô | 684 / bồn (viền + đất) | 2 | — |
| P1 / P2 | Sân gạch block "con sâu" xám / gạch đỏ "lá dừa" 30 × 30 lát chéo ô; mặt nạ bẩn vẽ theo đúng chỗ bồn và lối đi | 12 (cả sân) | 1 | — |
| Ghế | Ghế đá mài của Ngư (một phương án) | 428 | 1 | — |
| Đèn | Cột đèn sân vườn cầu tròn, sơn xanh sẫm, chao phát sáng theo `Flicker` (một phương án) | 1.148 | 3 | — |

**Đếm trong khung hình (không đo FPS; `Performance` lúc chụp, cùng camera, không đèn pin):**
| Góc | Lần vẽ PS1 → T1 / T2 / T3 | Primitive PS1 → T1 / T2 / T3 |
|---|---|---|
| ghế Ngư giữa hai bồn | 542 → 516 / 516 / 516 | 88.126 → 106.340 / 97.576 / 96.512 |
| bồn `Bed1_1` gần | 323 → 293 | 8.563 → 25.403 / 16.639 / 15.575 |
| lối giữa các bồn | 1.058 → 1.026 | 29.420 → 45.256 / 36.492 / 35.428 |
| từ tầng 4 nhìn xuống | 527 → 497 | 21.611 → 38.451 / 29.687 / 28.623 |
Số lần vẽ giảm (mỗi bồn PS1 có hàng chục khối nhỏ, bản mới vài lưới). Ước tính cả vườn theo phương án đề xuất (8 T1 + 4 T3, F1, K1, P1, 5 ghế, 6 đèn), bản gần: khoảng 88 nghìn tam giác (PS1 6.564), 13 vật liệu (PS1 19), khoảng 15 lần vẽ nếu lượt 2 gộp lưới theo vật liệu và vẽ cây bằng MultiMesh theo loài (PS1 276). Nếu cần nhẹ hơn: bớt một tầng cành hoa sứ (còn khoảng 4 nghìn), hoặc đưa bản xa vào gần hơn (40 m → 25 m).

**Đề xuất của lane B:** **T1 hoa sứ (đại) cho phần lớn bồn, xen T3 bằng lăng ở khoảng 4/12 bồn** (ảnh cột 5): hoa sứ là cây quen ở sân trường, chùa, nghĩa trang Việt Nam, dáng cành trơ nổi rõ trong đêm, hoa trắng bắt đèn pin, hợp không khí kinh dị; tán bắt đầu cao nên lối đi và hợp đồng tán dễ giữ. Bằng lăng xen vào cho vườn bớt đều và có khối tán dày nhìn từ tầng 4. **F1** (gọn, kiểu trường học, che đất, giữ đủ 4 bụi + 12 khóm hoa), **K1 quét vôi**, **P1 gạch block xám** (P2 đỏ rất nổi dưới đèn trăng, át cảnh), ghế đá mài và đèn cầu như ảnh. T2 bàng Đài Loan nhìn ngang ban đêm giống cây thông, khó nhận ra.

**Câu hỏi cho chủ dự án:**
1. Cây trong bồn: T1, T2, T3 hay T1 + T3 xen kẽ (đề xuất)? Nếu xen: bao nhiêu bồn mỗi loài?
2. Hoa sứ có hoa trắng như ảnh, hay chỉ lá? Bằng lăng giữ chùm hoa tím và vài cành lá già đỏ?
3. Cây bụi, hoa: F1 hay F2, hay phần lớn F1 và vài bồn F2 (để "mỗi bồn khác nhau một chút")?
4. Viền bồn: K1 quét vôi trắng hay K2 sơn vàng?
5. Sân: P1 gạch block xám hay P2 gạch đỏ lá dừa?
6. Ghế đá mài, cột đèn cầu: đạt chưa? Bốn ghế `Bench0…3` (có tựa) làm cùng kiểu đá mài có tựa. Có muốn dòng chữ sơn kiểu "Quà tặng của khoá…" trên tựa ghế (rất quen ở trường Việt Nam)? Lane B chưa làm vì chữ, năm có thể đụng cốt truyện.
7. Hai câu ở phần khảo sát: `DistantStreetLamp` (chỉ ẩn cột, giữ đèn?) và bảng tin trong vườn (lượt 2 có làm hình không?).

**Lượt 2 cần làm thêm (đã biết):** gắn hẳn vào `garden.tscn` (hình mới là con mới của `Garden`, PS1 chỉ ẩn); gộp viền, đất, cây bụi theo vật liệu; cây vẽ bằng MultiMesh theo loài hoặc node riêng có `visibility_range`; đồng bộ chao đèn với `Flicker*` trong `foliage.gd` (phần `garden`); dải A16; bản nhẹ chương 1–2; test theo card mục 7.

**Kiểm:**
- `pwsh tools/test.ps1 -Filter t259`: `RESULT: 4 passed, 0 failed` (texture nén VRAM; tán dưới 2 m trong khối `CanopyCollision`; glb chỉ dùng vật liệu chung; ghế Ngư đúng mặt ghế cũ). Test này bắt được một thẻ lá bản xa của bằng lăng thò ra ngoài khối dưới 2 m: đã sửa script dựng.
- Full `pwsh tools/test.ps1` (trên `7a67225` + Handoff): `RESULT: 997 passed, 0 failed`.
- `pwsh tools/check.ps1`: **chưa có kết quả.** Lần chạy bị Claude Code dừng giữa chừng vì máy thiếu RAM (đang ở bước parse script, các file đã qua đều PASS); theo luật hệ thống không tự chạy lại. Lượt 1 chỉ thêm asset, script dựng và một test; không sửa scene, script game. File khoá Godot của lần chạy đó đã xoá.

**Yêu cầu thay đổi:** không có.

### Lượt 2 — cả vườn, dải nối, cảnh ngoài chương 1–2 (lane B, 14/11/2026, D-175)
Nhánh rebase lên `origin/main` `b6126d3` (có card mục 1); vì rebase nên lần push đầu của lượt 2 dùng `--force-with-lease` trên nhánh này. Cách dựng lại, chi tiết từng phần: `art_source/graphics_upgrade/realistic_map/wave3/README.md` (mục Lượt 2).

**Đã làm theo D-175:**
- **Vườn (A12, `garden.tscn`):** 253 node PS1 chỉ ẩn (`visible = false`: lưới sân, lưới và đất 12 bồn, 12 thân, 12 tán, 48 bụi, 144 khóm hoa, lưới và hai chân ghế Ngư, `Bench0…3`, `BrokenBunk`, `DetachedRail0…3`); không xoá, không đổi tên, gốc, transform. Node mới `Real` (`garden_real.gd`): sân P1, 12 viền K1 quét vôi trắng (chỉnh lại màu: vôi trắng cũ, bẩn chân, không ngả be), đất, F1 ở cả 12 bồn (mỗi bồn lật/lệch mẫu bụi, đổi cỡ bụi, đổi cao hàng rào một chút; không thêm loài), 12 cây đúng tâm bồn: **bằng lăng ở `Bed0_0`, `Bed1_2`, `Bed2_1`, `Bed3_0`** (mỗi hàng một cây, cột 0, 2, 1, 0 để nhìn từ tầng 4 không dồn một phía), còn lại 8 hoa sứ (3 biến thể hoa sứ, 2 biến thể bằng lăng, mỗi cây một góc xoay); ghế Ngư và 4 ghế đá mài có tựa, không chữ; giường tầng thép đổ nghiêng đúng hộp giường kit cũ, thanh chắn giường trên nằm ở mặt va chạm cũ (y −8,95) ngay dưới thanh sắt B01; 4 thanh lan can rời theo đúng transform `DetachedRail*`.
- **Đèn vườn:** `foliage.gd` (chỉ phần `garden`) treo cột đèn cầu tại đúng 6 điểm của `GardenLights_*` (cột PS1 vẫn dựng, ẩn); quả cầu sáng theo năng lượng đèn `Flicker*` đứng trên điểm đó. Không thêm, không đổi đèn nào.
- **Dải nối nhà B → vườn (A16):** `campus.tscn` → node mới `StripBGarden`: bãi cỏ mòn x −6…50, z 4,2…50 quanh sân (lối mòn trơ đất dọc mặt trước nhà B, từ nhà B tới cổng vườn x 22, quanh mép sân; ướt cạnh rãnh), viền bê tông quanh sân, rãnh có tấm đan dọc mặt trước nhà B (z 6,45…6,8, vài tấm vỡ, thiếu); 61 mẩu giấy vở, tờ rơi, giấy vo, túi ni lông đúng chỗ giấy PS1; ba đống gạch vỡ dựng theo đúng từng khối PS1 (42 khối, 9 ống sắt) trong hộp va chạm cũ; **bảng tin làm lại** trong hộp va chạm cũ `Props/Solids/Body_p0_p0/S0`, mặt quay về nhà B như PS1, 6 tờ giấy đúng chỗ cũ, không chữ. `props.tscn`: 122 mẩu PS1 được thay chỉ ẩn (chunk thay hẳn: ẩn node; chunk một phần trong dải: thu cỡ các mẩu trong dải về 0, giữ mục). Không đụng mảnh xác tĩnh, vệt kéo sẫm, thùng rác, đường, hàng rào, cây khu khác. **Ghi chú:** ba đống gạch vỡ vắt qua mốc z 50 (va chạm tới z 53), lane B thay trọn từng đống thay vì cắt đôi ở z 50.
- **Cảnh ngoài chương 1–2 (A05):** đo trước khi dựng: tầng 4 ở chương 1–2 và 3–4 **cùng gốc toạ độ** (`Floor4`, `Corridor` ở gốc trong `chapter1–3.tscn`); ở chương 1–2 **dưới lan can không có mặt đất nào** (tia từ (22; −0,5; z) xuống, z 5…45, không chạm gì), chỉ sương nâu sẫm (mật độ 0,032, ambient 0,24); lan can tầng 4 (thanh song, z 4,05) nhìn được từ z ≈ 4 ra tới chân trời sương. Bản nhẹ `floor4/garden_backdrop.tscn` (dưới `Floor4/Corridor`): bãi cỏ phẳng rộng quá tầm sương, sân, 12 bồn rút gọn, 12 cây bản xa đúng loài, biến thể, góc xoay như chương 3, 6 cột đèn cầu (sáng tĩnh), cột đèn đường cao tới đúng chỗ đèn `DistantStreetLamp`. Không va chạm, không bóng, không đèn. `YardTree_*` và `Fixture`, `Stem` của `DistantStreetLamp` ẩn, **nguồn sáng giữ nguyên**. `campus.gd` ẩn bản nhẹ khi có khuôn viên (chương 3–4), như vẫn ẩn `YardTree_*`.

**Đếm (không đo FPS, D-173).** Tam giác bản gần: hoa sứ 5,2 / 6,9 / 5,9 nghìn mỗi biến thể (lượt 2 bớt lá còn 12–16 lá mỗi chùm), bằng lăng 1,3 nghìn; cây cả vườn khoảng 53 nghìn (bản xa cả 12 cây 3,3 nghìn); viền và đất 8,2 nghìn; trồng bồn 15,9 nghìn; 5 ghế 3,8 nghìn; 6 đèn 6,9 nghìn; giường đổ 1,5 nghìn; sân 12 → **vườn khoảng 89 nghìn tam giác** (PS1 6.564). Dải A16 khoảng 6 nghìn; bản nhẹ chương 1–2 4,3 nghìn. Vật liệu runtime của vườn: 15 (PS1 19). Trong khung hình (`Performance` lúc chụp, cùng camera, không đèn pin; primitive tính cả lượt depth):
| Góc | Lần vẽ trước → sau | Primitive trước → sau |
|---|---|---|
| cổng vào vườn | 975 → 779 | 24.121 → 91.735 |
| giữa vườn | 1.760 → 1.642 | 41.526 → 99.490 |
| ghế Ngư | 202 → 130 | 6.675 → 58.030 |
| bảng tin (mặt trước) | 981 → 784 | 23.517 → 102.823 |
| tầng 4 nhìn xuống, chương 3 | 531 → 293 | 21.976 → 106.940 |
| tầng 4 nhìn xuống, chương 1 | 20 → 24 | 4.638 → 8.838 |
Bộ nhớ hình khi chụp: chương 3 1.248 → 1.267 MB, chương 1 1.141 → 1.152 MB. Mọi texture mới nhập nén VRAM.

**Ảnh** (`art_source/graphics_upgrade/realistic_map/previews/wave3/`): `overview.jpg` (12 cặp trước/sau), ảnh lẻ `before_*`, `after_*` (chương 3: c1 cổng vào vườn, c2 giữa vườn, c3 ghế Ngư, c4 giường tầng đổ, c5 tầng 4 nhìn xuống, c6 dải nối, c7 bảng tin mặt sau, c8 mép sau vườn, c9 ghế có tựa, c10 cột đèn, c11 bảng tin mặt trước; chương 1: f1–f3 tầng 4 nhìn xuống), có và không đèn pin. Ảnh "trước" chụp trên bản main của các scene.

**Kiểm:**
- Test mới `game/tests/levels/test_t259_garden.gd` (thay `test_t259_garden_pilot.gd` của lượt 1), `-Filter t259`: `RESULT: 11 passed, 0 failed`. Gồm: dấu vân tay **va chạm vườn (32), node và đèn vườn (524), anchor/vùng/navigation của campus (1.079 dòng), va chạm `props.tscn` (175) trùng main**; PS1 ẩn, lớp `Real` đủ (12 cây đúng tâm bồn, 8 hoa sứ, 5 ghế, 6 cột đèn, lá không bóng); quả cầu đèn sáng/tắt theo `Flicker`; mọi đỉnh dưới 2 m của 12 cây đã đặt nằm trong khối bát giác `CanopyCollision` của bồn đó; capsule đi được các lối giữa bồn, từ `Start_garden`, tới ghế Ngư, tới cạnh B01; B01 nằm trên mặt −8,95 và thanh chắn giường mới ở đúng chỗ đó; ghế Ngư đúng mặt ghế cũ; dải A16 nằm trong dải và chỉ ẩn đồ PS1 trong dải; mọi `.import` texture đợt 3 `compress/mode=2` (normal `normal_map=1`); glb chỉ dùng vật liệu chung; chương 1–2 bản nhẹ hiện, chương 3–4 ẩn, `YardTree_*` ẩn, đèn `DistantStreetLamp` giữ.
- Test cũ (lọc): `t251` 5/5 (không sửa), `test_campus` 5/5, `wide_corridors` 4/4, `graphics_bindings` 8/8, `test_floor4` 9/9, `t250` 5/5, `t253` 9/9, `props` 21/21, `t255` 12/12, `t256` 9/9, `test_chapter3` 22/22.
- Full test, check: (điền sau khi chạy).

**Yêu cầu thay đổi:**
1. `game/assets/models/graphics_pilot/realistic_map/CREDITS.md` (file chung, ngoài danh sách được sửa của card): thêm một dòng mục `wave3/` trỏ tới `wave3/CREDITS.md` (nguồn đợt 3 đã ghi đủ ở đó).
