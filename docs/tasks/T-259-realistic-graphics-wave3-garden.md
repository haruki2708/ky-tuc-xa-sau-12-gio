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
- [ ] Lượt 1: khảo sát, bảng hợp đồng, danh sách node A16 (Handoff)
- [ ] Lượt 1: góc mẫu và phương án (cây, hoa, sân, ghế, đèn), ảnh; dừng chờ chủ dự án chọn
- [ ] Lượt 2: cả vườn
- [ ] Lượt 2: dải nối nhà B → vườn
- [ ] Lượt 2: cảnh ngoài chương 1–2
- [ ] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
(lane B điền)
