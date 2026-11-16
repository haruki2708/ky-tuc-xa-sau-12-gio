# T-264 — Đồ hoạ thật đợt 7: nhà nền (nhà A, giảng đường, nhà thể chất), mặt ngoài nhà B, mặt đất, đường, cây, đèn đường, hàng rào còn lại
- Lane: B | Trạng thái: todo (giao 16/11/2026) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1r).
- Nhánh: `lane-b/T-264-realistic-graphics-wave7-shells-ground` từ `origin/main` mới nhất.
- Quyết định nền:
  - **D-166:** đồ hoạ thật dựng bằng Blender, không PS1, không Tripo; ánh sáng giữ như nay; **các nhà nền (nhà A, giảng đường, nhà thể chất) thêm nội thất nhìn qua cửa**; không mở khu chơi mới.
  - **D-167/D-172/D-177:** phong cách đã duyệt, cũ vừa phải.
  - **D-175, D-178, D-180, D-181:** vật liệu đã duyệt: sân block con sâu xám, viền quét vôi trắng, hoa sứ và bằng lăng, bê tông trần, thép mạ kẽm, lưới B40, tường rào W1 (trát vôi 1,8 m + song sắt), chốt vôi vàng, tường vàng nhạt.
  - **D-176:** chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ. **D-179:** không đo FPS, không chạy bot trong đợt; **bot sân vận động T-238 chạy sau đợt này**.
  - Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 7 (A16 phần còn lại, A17, A18, A19; A05 đã làm ở T-259).
- Làm như đợt 3–6, nhưng **ba lượt** vì khu rộng: **lượt 1 khảo sát và góc mẫu rồi dừng chờ chủ dự án chọn; lượt 2 các nhà; lượt 3 mặt đất, đường, cây, hàng rào.**

## 0. Hiện trạng (integrator khảo sát 16/11; lane B kiểm lại ở bước 1)
- **Khuôn viên** 500 × 350 m: hàng rào `Fence/N` (z 290), `E` (x 420), `W` (x −80), `S` (z −60, đã thay bằng `WallSouth` ở T-262). Mặt đất y −9,9.
- **Nhà nền** `game/scenes/levels/campus/shells.tscn` (gốc `Shells` trong `campus.tscn`, 337 node, toàn PS1, 4 texture `campus/wall|glass|iron|concrete.png`), dùng ở chương 3–4:
  - **Nhà A** `BuildingA`: khối `Shell` 44 × 19,8 × 10 m ở (22; 0; 59), tức x 0…44, z 54…64, **6 tầng, đứng đối diện nhà B qua vườn hoa** (mặt trước z 54 nhìn thẳng sang hành lang nhà B); 49 ô cửa `Window*`, 6 dải tầng `ABand0…5`, **3 bóng người cửa sổ `WindowSilhouette0…2`** ở (7 / 18 / 31; −1,9; 53,8).
  - **Giảng đường** `Lecture`: khối 80 × 16,5 × 20 m ở (−10; −1,65; 190), tức x −50…30, z 180…200; 81 ô cửa, 5 dải `LectureBand*`.
  - **Nhà thể chất** `Gym`: khối 60 × 10 × 40 m ở (−30; −4,9; 110), tức x −60…0, z 90…130; 13 ô cửa, 1 dải `GymBand0`.
  - Mỗi nhà **một hộp va chạm đặc** (3 `StaticBody3D`). `LibraryBand0…2` cũng nằm trong `shells.tscn` nhưng **thuộc đợt 8, không đụng**.
  - Ảnh hiện trạng: `realistic_map/previews/survey/39_shell_a.jpg`, `40_shell_a_far.jpg`, `41_shell_lecture.jpg`, `42_shell_gym.jpg`, `43_shells_far.jpg`.
- **Mặt ngoài nhà B** (`building_b.tscn`): `UpperFloor5`, `UpperFloor6` (khối mặt ngoài tầng 5–6), 22 `UpperWindow*`, `UpperRubble*`. Còn PS1 khi nhìn từ ngoài: mặt sau tầng 1–3 (tầng 4 đã là dãy ban công T-255), hai đầu hồi, vỏ ngoài hai tháp cầu thang (T-250 nâng tường tới 6,3 m nhưng mặt ngoài vẫn vật liệu PS1), mái. Ảnh `survey/44_upper_b.jpg`, `45_upper_b_side.jpg`.
- **Mặt đất, đường, cây** (`campus.tscn`):
  - `Ground`: 70 ô `Tile_*` 50 × 50 m (y −10,09).
  - `Road`: `Avenue` (hình đã rút còn x 0…180 ở T-262), `EastBranch` (310; 68), `StadiumEastAccess` (298; 166); `WestBranch`, `StadiumWestAccess` đã ẩn hình (T-259, T-261).
  - Cây: 48 cụm `Trees_*` (MultiMesh qua `foliage.gd` kiểu `tree`: thân nón + hai tầng tán nón, tầm vẽ 125 m) và **116 hộp va chạm thân `TreeTrunk0…115`**.
  - Đèn đường: 11 cụm `StreetLights_*` (`foliage.gd` kiểu `lamp`, cột 7 m); nguồn sáng trong `Props/Lights`.
  - 3 ghế `RoadBench*` + `BenchBody*`, 3 xe máy đổ `FallenMoped*` + `MopedBody*` (có va chạm).
  - `Fence/N`, `E`, `W`: còn PS1 (có va chạm).
  - `Props` (`props.tscn`: `Parts`, `Decals`, `Solids`, `Lights`, `Trees`): đồ rải, mảnh xác, máu, vệt kéo gộp MultiMesh.
  - Ảnh hiện trạng: `survey/37_road_garden.jpg`, `38_road_gate.jpg`.
- **Phần A16 đã làm, không làm lại:** `StripBGarden` (T-259), `StripGardenStadium` và trong sân vận động (T-261), `StripGate` hộp x 180…262, z −60…13 và `WallSouth` (T-262), `StripCanteen` hộp x 166…218, z 13…60 trừ góc x 166…170, z 37…60 (T-263). **Còn lại** gồm cả **đường vòng phía bắc sân vận động** (HARU ghi ở T-261: còn nền PS1) và đường sang thư viện.
- **Truyện và code:**
  - Chương 3: người chơi đi nhà B → vườn → sân vận động → cổng → nhà ăn; nhà A luôn thấy từ vườn và từ hành lang nhà B.
  - Chương 4: từ lối tây nhà ăn đi tới thư viện (x 45…85, z 195…225), ngang qua giảng đường; Ngư và Minh Nhật chỉ nói qua bộ đàm về giảng đường và nhà thể chất (`chat:ngu_lecture`, `chat:n_gym`), **người chơi không vào các nhà này**.
  - Không code nào gọi tên `Shells/*`, `WindowSilhouette*`, `UpperFloor*`. `Zones/Road`, xác sống đứng chờ trên đường (`ZombieIdle/Road`), các tuyến `Anchors/Paths/*`, bot (`tools/ch3-profile.json`) dùng mặt đường và lối đi.
- **Khối che (occlusion culling, T-260, của core):** `game/scenes/main/occlusion/occluders_campus.tscn` có **ba hộp đặc `Shells_BuildingA_Shell`, `Shells_Gym_Shell`, `Shells_Lecture_Shell`** (trùng hộp va chạm của ba nhà) và `BuildingB_UpperFloor*`. **Nội thất đặt bên trong các hộp này sẽ không được vẽ** cho tới khi integrator thu hộp che vào trong. Xem mục 5.
- **Hiệu năng:** PLAN mục 6: A16 **không tăng** thời gian khung ở góc nhìn toàn khuôn viên; A17–A19 **≤ 0,20 ms cho cả ba nhóm**. Chương 3 vốn giật nhẹ khi nhìn ra khuôn viên. Đây là đợt rộng nhất: số lần vẽ và tán cây là rủi ro chính.

## 1. Chủ dự án chốt
**D-182 (16/11/2026):** chủ dự án xem ảnh lượt 1 (`previews/wave7/options_*.jpg`) và chọn cả chín mục theo đề xuất:
1. Nội thất nhìn qua cửa: **b**, phòng giả vẽ bằng shader sau mọi ô cửa (không thêm đèn; đèn pin rọi vào thấy phòng). Nhà B cũng dùng phòng giả như nhà A.
2. Kiểu nhà A: **A2**, tường có cửa sổ từng phòng.
3. Màu tường ba nhà nền: **vàng như nhà ăn**.
4. Mái: giảng đường **R1** mái bằng có lam bê tông; nhà thể chất **R2** mái tôn vòm.
5. Đường và lề: **nhựa cũ có vá, vạch mờ; lề cỏ úa và đất** (chỉ sân trước các nhà lát block); đèn đường **cột thép cần vươn**.
6. Cây ven đường: **ba loài** (bàng dọc đại lộ, phượng gần các nhà, xà cừ thành hàng dài), mật độ giữ như nay.
7. Hàng rào bắc, đông, tây: **lưới B40 trên cột ống** (mặt nam giữ tường W1).
8. Bóng người cửa sổ thứ ba (`WindowSilhouette2`, x 31, đang trúng trụ tường): **dời vào ô cửa bên cạnh**.
9. Chương 1–2: **có** bản nhẹ nhà A (vỏ A2, không phòng giả, không song sắt, không đèn, xa trong sương), **không có bóng người cửa sổ**.

**Integrator trả lời các đề nghị trong Handoff lượt 1:**
- **Cho phép đổi vị trí `WindowSilhouette2`**: x từ 31 sang trong ô cửa x 31,5…33,5 (gợi ý 31,6…32,5), y và z giữ. Hai bóng kia giữ nguyên. Test dấu vân tay node ghi rõ ngoại lệ này.
- **Hộp A16 còn lại** như lane B chốt: cả khuôn viên trừ các dải đã làm, nền các nhà, và vùng đợt 8 (x 39…91, z 189…231, `LibraryBand*`, lỗ cửa lối tây nhà ăn). Góc x 166…170, z 37…60 thuộc đợt này.
- **Khối che:** với b và A2 chỉ phải sửa hộp tầng 5–6 nhà B. **Integrator đã thu** `BuildingB_UpperFloor5`, `BuildingB_UpperFloor6` từ z 3,7 về **z 0,0** (16/11, đã vào main; `make_occluders.py`, `occluders_campus.tscn`). Ba hộp nhà nền giữ nguyên (đặc từ 0,5 m sau mặt nhà; phòng giả chỉ sâu 0,3 m). Lượt 2: **phòng giả và mọi chi tiết mặt tiền phải nằm trong 0,45 m tính từ mặt nhà**; hành lang tầng 5–6 nhà B nằm trong z 0…4. Sau khi dựng, chụp lại bật/tắt khối che ở nhà A, giảng đường, nhà thể chất, tầng 5–6 nhà B; thấy vật bị ẩn thì ghi "Yêu cầu thay đổi".
- **Ảnh lượt 2 từ hành lang tầng 4 nhà B:** ảnh lượt 1 bị một tấm khăn phơi che gần hết nhà A. Đặt camera ở chỗ không bị đồ phơi che (ví dụ x 34…40) và thêm một ảnh có đèn pin rọi sang nhà A.
- Số lần vẽ ở góc khán đài (4.598 → 4.643 ở góc mẫu) phải về không tăng sau lượt 3, như lane B đã nêu.
- Lượt 1 không chạy check là đúng (chưa sửa cảnh). Lượt 2 và 3 chạy đủ full test và check.

## 2. Việc, theo ba lượt

### Lượt 1 — khảo sát và góc mẫu, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi Handoff:**
   - Kiểm lại mục 0. Grep mọi chỗ code, test, bot, âm thanh đụng tới nhà nền, đường, cây, hàng rào (`shells.tscn`, `Shells/`, `WindowSilhouette`, `UpperFloor`, `UpperWindow`, `Road/`, `TreeTrunk`, `Trees_`, `StreetLights`, `Fence/`, `Ground/Tile`, `MopedBody`, `BenchBody`, `Zones/Road`, `ZombieIdle/Road`, `ZombieSpawns/Road`).
   - **Bảng hợp đồng**: node nào giữ tên, vị trí, va chạm.
   - **Đi thử** bằng thân người chơi thật: các lối quanh ba nhà nền (sát chân tường, góc nhà), đường vòng bắc sân vận động, đường chương 4 từ lối tây nhà ăn tới cửa thư viện, dọc ba mặt hàng rào ở chỗ người chơi tới được.
   - **Chốt hộp A16 còn lại**: liệt kê chính xác đường dẫn node và số bản MultiMesh trong phần chưa làm; đánh dấu phần giáp các dải đã làm (đường khớp mép) và phần **để cho đợt 8** (quanh thư viện trong vòng 6 m quanh hộp x 45…85, z 195…225, và `LibraryBand*`).
   - Phân loại bản MultiMesh trong `props.tscn`: đồ rải, mảnh xác, máu, vệt kéo. **Đếm đầu xác trong từng node trước khi đụng** (bài học T-259: ẩn cả node làm mất đầu 9 xác).
2. **Góc mẫu** (Blender, chất lượng ngang các đợt trước; ảnh cùng camera trong chương 3 thật, ban đêm như chương, có và không đèn pin, gần và xa):
   - **Nhà A:** một đoạn mặt trước 3 gian × 6 tầng có cửa ra vào tầng trệt, có một trong ba bóng người cửa sổ; chụp từ chân nhà, từ vườn, và **từ hành lang tầng 4 nhà B nhìn sang**.
   - **Giảng đường hoặc nhà thể chất:** một góc nhà có cửa chính.
   - **Nhà B:** một đoạn mặt ngoài tầng 5–6 và một đoạn mặt sau tầng 1–3, chụp từ sân.
   - **Mặt đất và cây:** một đoạn đường có vỉa, một mảng đất/cỏ, 3–4 cây ven đường, một cột đèn đường, một ghế, một xe máy đổ, một đoạn hàng rào phía tây.
3. **Phương án để chủ dự án chọn bằng mắt** (mỗi phương án ghi số tam giác, vật liệu, số lần vẽ; đề xuất một):
   - **Nội thất nhìn qua cửa (D-166):** (a) phòng thật nông sau cửa kính ở tầng trệt và sảnh cửa chính, tầng trên kính tối có rèm, vài ô cửa vỡ; (b) nội thất giả bằng shader/thẻ ảnh sau mọi ô cửa; (c) chỉ sảnh ở cửa chính. Ghi rõ **độ sâu nội thất** cần ở mỗi mặt nhà (để integrator sửa khối che).
   - **Kiểu nhà A** (ký túc xá 6 tầng đối diện): hành lang hở có lan can như nhà B, hay mặt tường có cửa sổ từng phòng.
   - **Màu tường nhà nền:** vàng nhạt như nhà ăn, hay kem/xám khác nhà B để dễ phân biệt.
   - **Giảng đường, nhà thể chất:** mái bằng có lam bê tông, hay mái tôn vòm (nhà thể chất).
   - **Cây ven đường:** 2–3 loài cây trường Việt Nam (ví dụ phượng, bàng, xà cừ, sao đen), có ảnh tham chiếu thật ghi nguồn; mật độ **giữ như nay**.
   - **Mặt đường và vỉa:** nhựa cũ có vá và vạch mờ, hay bê tông tấm; mặt đất ngoài đường: cỏ úa và đất, hay lát block.
   - **Đèn đường:** cột thép cần vươn, hay cột bê tông ly tâm.
   - **Hàng rào bắc, đông, tây:** tường W1 như phía nam (D-180), hay lưới B40 trên cột ống cho các mặt sau.
   - **Bóng người cửa sổ nhà A:** giữ đúng ba chỗ; hình bóng đứng sau rèm/kính tối (không thêm đèn).
   - **Chương 1–2:** có đặt bản nhẹ của nhà A đối diện vườn (nhìn từ hành lang tầng 4) không; nếu có thì chỉ là hình xa trong sương, không đèn.
4. Commit, push nhánh, ghi Handoff, **báo và dừng**. Integrator chuyển phương án cho chủ dự án, ghi lựa chọn vào mục 1, sửa khối che theo độ sâu nội thất.

### Lượt 2 — các nhà (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
5. **Nhà A (A17)**, **giảng đường và nhà thể chất (A18)**, **mặt ngoài nhà B (A19 và phần còn PS1: mặt sau tầng 1–3, hai đầu hồi, vỏ tháp cầu thang, mái)**. Nội thất nhìn qua cửa theo phương án đã chọn. Ba bóng người cửa sổ đúng chỗ.
6. Bản nhẹ nhà A cho chương 1–2 nếu chủ dự án chọn.
7. Ảnh trước/sau, test, full test, check, Handoff; **báo và dừng** (integrator review, merge lượt 2 trước khi làm lượt 3, để nhánh không quá lớn).

### Lượt 3 — mặt đất, đường, cây, đèn đường, hàng rào (chủ dự án dán prompt "tiếp tục lượt 3")
8. **A16 còn lại** trong hộp đã chốt ở bước 1: mặt đất, đường (`Avenue`, `EastBranch`, `StadiumEastAccess`, đường vòng bắc sân, đường sang thư viện), vỉa, rãnh; cây (thân, tán), đèn đường, ghế, xe máy đổ; hàng rào bắc, đông, tây; đồ rải. Khớp mép với các dải đã làm.
9. Ảnh trước/sau (cả ảnh toàn cảnh từ hành lang tầng 4 nhà B và từ khán đài), ảnh ghép `overview.jpg`, test, full test, check, Handoff.

## 3. Phạm vi
- **Trong đợt:** `shells.tscn` trừ `LibraryBand*`; mặt ngoài nhà B; A16 còn lại theo hộp chốt ở bước 1.
- **Không đụng:** thư viện và 6 m quanh nó, `LibraryBand*`, lỗ cửa lối tây nhà ăn (đợt 8); bên trong nhà B, tầng 4, phòng 407; vườn, sân vận động, cổng, nhà ăn và các dải đã làm (trừ đường khớp mép); bệnh viện (đợt 9).
- Không mở lối vào nhà nền: người chơi vẫn không vào được (hộp va chạm đặc giữ nguyên).
- Mảnh xác tĩnh, máu, vệt kéo sẫm: không đụng.

## 4. Hợp đồng gameplay (bắt buộc giữ)
- Không đổi tên, gốc, transform: `Shells`, `BuildingA`, `Lecture`, `Gym` và ba `Shell` (va chạm), `WindowSilhouette0…2` (vị trí; hình được làm lại tại chỗ), `UpperFloor5/6` (va chạm), `Ground/Tile_*` (va chạm, meta bề mặt), mọi node `Road/*` có va chạm (`TreeTrunk0…115`, `MopedBody*`, `BenchBody*`), `Fence/N|E|W` (va chạm), điểm đặt `StreetLights_*`, `Props/Lights`; anchor, vùng, navigation, `Paths/*`, điểm sinh và điểm chờ xác sống trong `campus.tscn`.
- **Va chạm giữ nguyên** (test so dấu vân tay với main). Hình mới nằm trên hoặc trong khối va chạm cũ: mặt đường nhìn thấy trùng mặt va chạm (lệch ≤ 2 cm), thân cây nằm trong `TreeTrunk*`, hàng rào trong hộp `Fence/*`.
- **Tán cây:** dưới 2 m không có lá ngoài hộp thân (người chơi và xác sống đi sát gốc cây không lọt vào tán); tán từ 2 m trở lên được rộng.
- Không vật mới nào chặn lối đi, tuyến đồng đội, xác sống, bot; không che đường nhìn tới 12 bảo vệ ở cổng (`test_t262_gate`), tới ghế Ngư, tới cửa nhà ăn.
- Hình PS1 chỉ ẩn (`visible = false`), không xoá. Bản MultiMesh của `props.tscn` chỉ **thu từng bản về 0**, không ẩn cả node có lẫn mảnh xác.
- Ánh sáng giữ như nay (D-166): không thêm đèn, không đổi đèn có sẵn; cửa sổ sáng (nếu có trong phương án) chỉ là vật liệu phát sáng rất nhẹ, không chiếu ra ngoài, và phải được chủ dự án chọn ở lượt 1.

## 5. Khối che (occlusion culling) — phối hợp với integrator
- Ba hộp che của nhà nền hiện đặc bằng cả khối nhà: **nội thất nằm trong hộp sẽ bị ẩn**. Lane B **không sửa** `game/scenes/main/occlusion/` (của core).
- Lượt 1: chụp góc mẫu **bật và tắt** occlusion culling (`get_tree().root.use_occlusion_culling`) để thấy rõ; ghi độ sâu nội thất cần ở từng mặt.
- Sau khi chủ dự án chọn, **integrator thu các hộp che vào trong** (theo độ sâu lane B ghi) trước lượt 2 và báo trong card mục 1.
- Lượt 2, 3: nếu thêm khối đặc lớn mới (ví dụ tường rào kín), ghi "Yêu cầu thay đổi" để integrator thêm hộp che.

## 6. Kỹ thuật và hiệu năng
- Script Blender (Blender 5.2.2 ở `D:\Tools\Blender\5.2.2`) như các đợt trước; nguồn mesh, texture **CC0** ghi URL, tác giả, giấy phép trong CREDITS. **Không extension Blender, không Tripo, không ảnh AI.**
- **Nhà nền nhìn từ xa là chính:** mặt tiền theo module lặp, ít vật liệu, gộp lần vẽ; bản xa (LOD hoặc `visibility_range`) cho chi tiết nhỏ (song cửa, máy lạnh, ống nước). Nội thất sau cửa: rất nhẹ, không đổ bóng, chỉ hiện trong tầm gần (gợi ý ≤ 40 m).
- **Cây:** thẻ lá alpha cắt (alpha scissor), lá không đổ bóng; mỗi loài có bản gần, bản trung, **bản xa dạng thẻ chữ thập**; giữ MultiMesh theo cụm và tầm vẽ hiện có (125 m) trừ khi ghi lý do. Không thay MultiMesh bằng node riêng lẻ.
- **Mặt đất:** vật liệu lặp có biến thiên (mask hoặc trộn), không tạo texture khổng lồ cho 500 × 350 m.
- Ngân sách: ghi số tam giác, vật liệu, **số lần vẽ trước/sau cùng camera** cho mỗi góc ảnh (bằng `RenderingServer.get_rendering_info`), nhất là ba góc toàn cảnh: hành lang tầng 4 nhà B nhìn ra, giữa vườn nhìn quanh, trên khán đài. Số lần vẽ ở ba góc này **không được tăng**; tăng thì giải thích và đề xuất cách giảm.
- **Mọi texture mới từ 512 px trở lên phải nén VRAM** trong `.import` (`compress/mode=2`; normal thêm `compress/normal_map=1`); có test.
- Không đo FPS, không chạy bot (D-179).

## 7. Ảnh
- `art_source/graphics_upgrade/realistic_map/previews/wave7/`: lượt 1 `pilot_*`, `options_*.jpg`; lượt 2, 3 `before_*`/`after_*` cùng camera trong chương 3 thật (và chương 4 cho đường tới thư viện, giảng đường); ảnh ghép `overview.jpg`. Ban đêm như chương, có và không đèn pin.

## 8. Kiểm
- Test mới `game/tests/levels/test_t264_*.gd`:
  - dấu vân tay va chạm, node, anchor, vùng, navigation của `shells.tscn`, `Ground`, `Road`, `Fence`, mặt ngoài nhà B trùng main; hình PS1 ẩn, không xoá;
  - ba bóng người cửa sổ đúng chỗ;
  - mặt đường nhìn thấy trùng mặt va chạm; thân cây trong hộp thân; không lá dưới 2 m ngoài hộp thân;
  - thân người chơi đi được các tuyến đã đi thử ở bước 1 (quanh ba nhà, đường vòng bắc sân, lối tây nhà ăn → cửa thư viện);
  - số bản MultiMesh thu về 0 đúng danh sách, **không bản mảnh xác nào bị đụng**;
  - mọi `.import` texture trong thư mục asset đợt 7 nén VRAM.
- Test cũ đạt: `test_campus`, `test_stands_props`, `test_t251_ground_garden`, `test_t259*`, `test_t260_occlusion`, `test_t261*`, `test_t262*`, `test_t263*`, `test_chapter3`, `test_chapter4`, `test_ch3_*`, `test_wide_corridors`, `test_t250*`, `test_t253*`, `test_t255*`. Được sửa **hằng số đếm bản MultiMesh dùng chung** trong `test_t259_garden`, `test_t261_stadium`, `test_t262_gate`, `test_t263_canteen` khi thu thêm bản về 0, có comment lý do (như D-180, D-181); không nới kiểm tra khác.
- Mỗi lượt có sửa cảnh: full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối, rồi `git checkout -- game/default_bus_layout.tres`. Lượt bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.

## 9. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave7/`, `.../previews/wave7/`, `game/assets/models/graphics_pilot/realistic_map/wave7/`, `game/assets/textures/graphics_pilot/realistic_map/wave7/`;
- `game/scenes/levels/campus/shells.tscn` (trừ `LibraryBand*`), `building_b.tscn` (chỉ hình mặt ngoài: `UpperFloor*`, `UpperWindow*`, mặt sau tầng 1–3, đầu hồi, vỏ tháp cầu thang, mái), `campus.tscn` (hình `Ground`, `Road`, `Fence/N|E|W`, node dải mới), `props.tscn` (chỉ dữ liệu MultiMesh trong hộp A16 đã chốt), `foliage.gd`, script cảnh mới trong `game/scenes/levels/campus/`;
- bản nhẹ chương 1–2 (nếu được chọn): cảnh và script của T-259 trong `game/scenes/levels/floor4/`;
- test mới và các hằng số nêu ở mục 8 trong `game/tests/levels/`; card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 10. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `chapter*.tscn`, `game/scenes/main/` (kể cả khối che), `project.godot`.
- Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Lượt 1: khảo sát, bảng hợp đồng, đi thử, hộp A16 còn lại, phân loại đồ rải (Handoff)
- [ ] Lượt 1: góc mẫu và phương án, ảnh bật/tắt khối che, độ sâu nội thất; dừng chờ chủ dự án chọn
- [ ] Lượt 2: nhà A, giảng đường, nhà thể chất, mặt ngoài nhà B, nội thất nhìn qua cửa, bóng người cửa sổ
- [ ] Lượt 2: test, full test, check, Handoff; dừng chờ merge
- [ ] Lượt 3: mặt đất, đường, cây, đèn đường, ghế, xe máy, hàng rào bắc/đông/tây, đồ rải
- [ ] Lượt 3: ảnh trước/sau, `overview.jpg`, test, full test, check, README, CREDITS, Handoff

## Handoff
(lane B điền)
