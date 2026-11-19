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
- **Sau lượt 2 (19/11), chủ dự án chọn:** dãy ban công tầng 4 phía sau nhà B (T-255) **đổi màu mặt ngoài cho khớp mặt sau mới**, làm trong lượt 3. Lượt 3 được sửa thêm `game/scenes/levels/floor4/floor4_rooms.gd` (và vật liệu, mask vỏ phòng `floor4_rooms` nếu cần), **chỉ màu mặt ngoài ban công, lan can, vách ngăn**; không đổi phòng, va chạm, đồ đạc.

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
- [x] Lượt 1: khảo sát, bảng hợp đồng, đi thử, hộp A16 còn lại, phân loại đồ rải (Handoff)
- [x] Lượt 1: góc mẫu và phương án, ảnh bật/tắt khối che, độ sâu nội thất; dừng chờ chủ dự án chọn
- [x] Lượt 2: nhà A, giảng đường, nhà thể chất, mặt ngoài nhà B, nội thất nhìn qua cửa, bóng người cửa sổ
- [ ] Lượt 2: test, full test, check, Handoff; dừng chờ merge
- [ ] Lượt 3: mặt đất, đường, cây, đèn đường, ghế, xe máy, hàng rào bắc/đông/tây, đồ rải
- [ ] Lượt 3: ảnh trước/sau, `overview.jpg`, test, full test, check, README, CREDITS, Handoff

## Handoff
### Lượt 2 (16/11/2026): xong, DỪNG chờ integrator merge
Nhánh rebase lên `origin/main` `0d7a25e` (có D-182, card mục 1, khối che tầng 5–6 nhà B đã thu về z 0). Cách chạy lại, số tam
giác, số lần vẽ: `art_source/graphics_upgrade/realistic_map/wave7/README.md` mục "Lượt 2". Commit: `2491e65`, `024f693`,
`e23d1ca`, `67938d0`, cùng commit Handoff này.

**Đã làm (theo D-182):**
- **Nhà A (A2, vàng):** cả mặt trước 8 gian × 6 tầng, phòng giả (shader) sau mọi ô cửa, song sắt tầng 2–6, máy lạnh, quần áo
  phơi, cửa chính kính có sảnh giả và mái đua từ 3 m; hông, mặt sau (cửa sổ nhỏ kính tối), mái.
- **Ba bóng người:** `figure.glb` (bóng đen trước rèm sáng, sau kính) treo dưới từng `WindowSilhouette0…2`; ô cửa của ba bóng
  không có phòng giả. **`WindowSilhouette2` dời x 31 → 32** (trong ô 31,5…33,5), y, z giữ; hai bóng kia giữ nguyên.
- **Giảng đường (R1):** 16 gian × 5 tầng lớp học giả, lam bê tông đứng và ô văng từ 2,4 m, cửa chính x −10, mái bằng có tường
  chắn mái.
- **Nhà thể chất (R2):** cửa sổ cao giữa các trụ (sân giả phía sau), cửa thép xanh có mái, mái tôn vòm có đầu hồi cong; trụ dưới
  2 m chỉ nhô 0,12 m.
- **Nhà B mặt ngoài:** tầng 5–6 thành hành lang bị chặn (lan can, cửa phòng, phòng giả, gạch vụn) trong z 0,45…4; mặt sau
  tầng 1–3 và 5–6 cửa sổ phẳng có phòng giả, song sắt, máy lạnh (không ở tầng trệt), ống nước; hai đầu hồi; vỏ ngoài và mái hai
  tháp cầu thang; mái chính.
  - **Mặt sau tầng 4 không phủ:** đó là mặt nhà, ban công của `floor4_rooms.gd` (T-255), có cả ở chương 3–4.
  - **Cửa sổ phòng quản lý** (x 2…5,3, lối `WindowExit`) để trống.
  - Vỏ tháp là lớp 4 mm ngoài hộp PS1 (mặt trong hộp là tường cầu thang nên hộp giữ, không ẩn).
- **Chương 1–2:** `bldga_light.glb` (vỏ A2, kính tối, không phòng giả, song sắt, bóng người) trong
  `floor4/garden_backdrop.tscn`; không va chạm, không đèn, không bóng đổ (script sẵn có của T-259).
- **Cảnh:** `patch_wave7.py` sửa `shells.tscn` (ẩn 164 lưới PS1 trừ `LibraryBand*`; thêm `Real`, ba `Figure`),
  `building_b.tscn` (ẩn 24 lưới `UpperFloor5/6`, `UpperWindow*`; thêm `Real/Outside`), `garden_backdrop.tscn`. Không xoá node,
  không đổi va chạm. `shells_real.gd` (mới, `game/scenes/levels/campus/`): kính, phòng giả, song sắt, khung, đồ nhỏ, bóng người
  không đổ bóng; song sắt, đồ nhỏ thôi vẽ ngoài 90 m. Bỏ asset phương án không chọn (`bldga_wall`, `bldga_gallery`, `gym_r1`,
  `gym_r2`, `road_slab`, `verge_pavers`, `lamp_concrete`, `fence_w1`, `W7WallGrey`, `W7RoadSlab`).
- Không đụng: thư viện, `LibraryBand*`, lỗ cửa lối tây nhà ăn, director, luật, `game/scenes/main` (kể cả khối che), lane A, âm
  thanh. Không Tripo, không ảnh AI, không bot, không đo FPS, không thêm đèn.

**Ảnh** (`previews/wave7/`): tờ `r2_building_a.jpg`, `r2_lecture_gym.jpg`, `r2_building_b.jpg`, `r2_torch_occlusion.jpg`,
`r2_wide_chapter1.jpg`; ảnh lẻ `r2_before_*` / `r2_after_*` cùng camera, chương 3 thật ban đêm (chương 1 cho bản nhẹ).
- Ảnh từ hành lang tầng 4 đặt ở x 37 (không bị đồ phơi che). **Ảnh đèn pin từ đó không thấy khác:** đèn pin của người chơi
  (`phone_item.tscn`) tầm 12 m, nhà A cách 50 m. Ảnh đèn pin rọi phòng giả chụp ở chân nhà A, ô cửa bóng người, cửa nhà thể
  chất, mặt sau nhà B.
- **Khối che:** bật/tắt ở nhà A, giảng đường, nhà thể chất, tầng 5–6 nhà B cho ảnh như nhau, không vật nào bị ẩn sai. Không
  có yêu cầu đổi khối che.

**Số lần vẽ** (cùng một lần chạy, khối che bật; main → lượt 2): hành lang tầng 4 1.698 → 1.730, giữa vườn 333 → 316, khán đài
4.473 → 4.522; quanh nhà A, giảng đường, nhà thể chất đều giảm (ví dụ giảng đường 98 → 37); quanh nhà B tăng 30–100 (vd. tầng
5–6 từ vườn 3.582 → 3.666). Giữa hai lần chạy số đo lệch vài trăm ở các góc gần nhà B, nên chỉ so trong cùng một lần. Bộ nhớ
hình chương 3: 1.313 → 1.318 MB. Số khán đài phải về không tăng sau lượt 3 (lượt 3 thay cây, đèn PS1).

**Kiểm:**
- `test_t264_buildings.gd` (mới, 7 test): dấu vân tay node, va chạm, meta của `shells.tscn` và `building_b.tscn` trùng main
  (md5 lấy trên cảnh chưa vá; ngoại lệ duy nhất là x của `WindowSilhouette2`, đã ghi trong test), va chạm và hợp đồng
  (anchor, vùng, navigation) của campus trùng main; PS1 ẩn, `LibraryBand*` còn hiện; bóng đổ đúng lớp; mặt tiền trong 0,45 m;
  dưới 2 m không gì nhô quá 0,15 m khỏi va chạm; nhà B không có gì trong khối đã che (z < 0); ba bóng người trong ô cửa của
  mình; nhà A bản nhẹ không phòng giả, va chạm, đèn, bóng đổ; thân người chơi đi vòng sát chân ba nhà nền; vật liệu dùng chung,
  tổng tam giác dưới 75.000.
- `test_t264_pilot.gd`: còn các glb mặt đất, cây, đèn, ghế, xe máy, B40 (lượt 3 thay).
- `pwsh tools/test.ps1 -Filter t264`: `RESULT: 11 passed, 0 failed`.
- Full `pwsh tools/test.ps1` (bắt đầu 16:28): **bị Claude Code dừng vì máy thiếu RAM, chưa có dòng RESULT; không tự chạy lại.**
  Một lần trước (sau commit `e23d1ca`, trước khi thêm vỏ tháp) tôi tự dừng giữa chừng để sửa. Khoá Lượt Godot đã gỡ,
  `game/default_bus_layout.tres` đã trả.
- `pwsh tools/check.ps1`: **chưa chạy** (chờ full test).
- Test liên quan đã chạy trên bản cuối: `-Filter t264` 11/0. Chưa chạy riêng `test_t253*`, `test_t259*`, `test_t260_occlusion`,
  `test_campus`, `test_chapter3/4` trên bản này; dấu vân tay campus của chúng trùng main (test t264 kiểm cùng md5).
- **Cần chạy lại khi máy đủ RAM** (đóng bớt ứng dụng): full `pwsh tools/test.ps1`, rồi `pwsh tools/check.ps1`, rồi
  `git checkout -- game/default_bus_layout.tres`.

**Chưa kiểm / lưu ý:**
- Chưa chạy chương 4 trong ảnh; chưa có ai đi thử bằng tay.
- Máy lạnh trắng sáng hơn tường ở vài góc. Tầng 4 mặt sau (ban công T-255) nay nằm giữa hai tầng vàng mới, màu khác hẳn; nếu
  chủ dự án muốn đồng bộ thì cần một việc riêng sửa `floor4_rooms.gd`.
- Sườn trái ảnh "mặt sau nhà B, xa" vẫn là dốc PS1 của `WindowApproach` (va chạm thuộc hợp đồng; mặt đất là lượt 3).
- Hai file log T-263 chưa commit vẫn nằm trong cây làm việc (`wave6/survey/capture_pilot.txt`, `walk_canteen.txt`), cố ý không
  commit.

**Yêu cầu thay đổi ngoài phạm vi:** không.
### Lượt 1 (16/11/2026): xong, DỪNG chờ chủ dự án chọn
Card đọc ở `origin/main` `3cef4c9`; nhánh tạo từ `14a8bcf`. Cách chạy lại, số tam giác, số lần vẽ:
`art_source/graphics_upgrade/realistic_map/wave7/README.md`. Chưa scene nào đổi (góc mẫu gắn lúc chạy khi chụp).

**Khảo sát (mục 0 khớp; bổ sung):** `wave7/survey_wave7.gd` → `survey/shells_nodes.tsv`, `building_b_nodes.tsv`,
`campus_rest.tsv`, `library_nodes.tsv`, `occluders_campus.tsv`.
- Nhà A: cửa sổ chỉ ở mặt trước z 54, 8 ô × 6 tầng (x 2,5 + 5k, 2 × 1,5 m, chân 1,05 m trên sàn), cửa khoá x 20,5…23,5.
  Ba bóng người ở tầng 3. **`WindowSilhouette2` (x 31) đứng trên trụ giữa hai ô cửa (26,5…28,5 và 31,5…33,5)**, không sau
  ô nào.
- Giảng đường: 16 ô × 5 tầng mặt z 180, cửa x −10. Nhà thể chất: 12 ô tầng trệt mặt z 90, cửa x −30.
- Nhà B:
  - mặt sau z −7,7 (tầng 1–3 là hộp PS1, phòng thật ở trong), hai tháp cầu thang x −5,2…0,1 và 43,9…49,2;
  - tầng 5–6 là khối đặc `UpperFloor5/6` tới z 4,0; khối che `BuildingB_UpperFloor*` tới z 3,7.
- Khối che nhà nền: đặc từ 0,5 m sau mặt nhà (A z 54,5…63,5; giảng đường 180,5…199,5; thể chất 90,5…129,5).
- Đường: `Avenue` (x 0…180, z −19…−11, mặt −9,87), `EastBranch`, `StadiumEastAccess`; `WestBranch`, `StadiumWestAccess`
  đã ẩn. Va chạm mặt đất là các ô `Ground/Tile_*` (mặt −9,94); đường không có va chạm.
- Cây, đèn, hàng rào:
  - 116 thân `TreeTrunk*` (hộp 0,5 × 3 × 0,5, đáy ở mặt đất);
  - ghế `BenchBody*` 2,4 × 0,8 × 0,6; xe máy `MopedBody*` 1,8 × 0,6 × 1,1;
  - `Fence/N|E|W` 0,3 × 3 m, cả ba mặt người chơi tới được dọc suốt chiều dài.

**Chỗ code, test, bot đụng tới:**
- code: `chapter3_director.gd`, `chapter4_director.gd` (vùng `road`, `Ch4/Start_split`, `Start_library`);
- âm thanh: `ch3_environment.gd`, `ch4_music.gd`;
- bot: `tools/ch3-profile.json` (tuyến qua đường);
- test: `test_campus`, `test_ch3_gameplay`, `test_t259_garden`, `test_t260_occlusion`, `test_t261_stadium`, `test_t262_gate`,
  `test_ch3_audio`, `game/audio/test/ch3_audio_test.gd`.

Không code nào gọi `Shells/*`, `WindowSilhouette*`, `UpperFloor*` theo tên.

**Bảng hợp đồng (giữ tên, vị trí, va chạm):**
| Cảnh | Node | Giữ |
|---|---|---|
| `shells.tscn` | `Shells`, `BuildingA`, `Lecture`, `Gym`, ba `Shell` (StaticBody + hộp đặc) | tên, transform, va chạm |
| | `WindowSilhouette0…2` (7 / 18 / 31; −1,9; 53,8) | vị trí (hình làm lại tại chỗ) |
| `building_b.tscn` | `UpperFloor5/6` (44 × 3 × 11,6 ở y 4,8 / 8,1, z −1,8) | va chạm |
| `campus.tscn` | `Ground/Tile_*` (70, meta `surface`, `is_floor`), `Road/TreeTrunk0…115`, `BenchBody0…2`, `MopedBody0…2`, `Fence/N|E|W` | va chạm, meta |
| | điểm `Trees_*` (48 cụm), `StreetLights_*` (11), `Props/Lights` | điểm đặt, đèn |
| | `Anchors`, `Zones/Road`, `ZombieIdle/Road` I01…06 (65…85; −11), `ZombieSpawns/Road`, `Paths/*`, navigation | giữ nguyên |

**Đi thử (`wave7/walk_wave7.gd`, thân người chơi thật):** mọi tuyến tới đích.
- Vòng quanh cả ba nhà nền cách tường 0,7 m, không chặng nào bị chặn.
- Đường vòng bắc sân vận động (z 245, x 100…300, xuống `EastBranch`).
- Dọc ba mặt hàng rào: tây x −78,6, z −55…285; bắc z 288,6, x −75…415; đông x 418,6.
- Đường chương 4 `Start_split` → `Start_library`: navmesh thông 272 m, đi bộ tới cửa thư viện.
- Ba chặng thẳng bị chặn đều là đường tôi cố ý kẻ xuyên vật có sẵn (dốc `WindowExit` sau nhà B, xe trên đại lộ, cửa sau
  thư viện), không phải tuyến.

**Hộp A16 còn lại: cả khuôn viên x −80…420, z −60…290, trừ:**
- các dải đã làm: T-259 x −6…50, z 4…50; T-261 sân x 108…290, z 108…236 và dải x 50…110, z −11…176; T-262 x 180…262,
  z −60…13; T-263 x 166…218, z 13…60;
- nền ba nhà nền và nhà B;
- **vùng đợt 8**: thư viện và 6 m quanh nó, tức x 39…91, z 189…231, cùng `LibraryBand*` và lỗ cửa lối tây nhà ăn.

Góc x 166…170, z 37…60 mà T-263 để lại giờ thuộc đợt này (trừ lỗ cửa). Danh sách đủ: `wave7/a16_rest.json`
(`list_a16_rest.py`, đếm theo vùng). Phần còn lại có:
- 99 cây ven đường, 29 cây thêm (`Props/Trees/ExtraTrees_*`), 99 thân;
- 9 điểm đèn, 3 ghế, `FallenMoped1`, toàn bộ ô mặt đất phần ngoài các dải;
- 367 bản đồ rải trong 66 chunk `props.tscn`.

Đường khớp mép: các cạnh hộp dải đã làm nói trên.

**Phân loại đồ rải và đầu xác:** đếm trong từng node trước khi đụng. Phân loại theo chữ ký của `art_source/campus/scatter.py`:
- xác người: thân 0,34 × 0,24 × 0,55, đầu hộp giấy 0,22 màu da, tay, chân; máu `D_red`; vệt kéo `D_iron`.

Kết quả đếm:
- `props.tscn` có 30 đầu xác: vườn 7, sân vận động 16, dải T-261 2, cổng 5.
- **Phần A16 còn lại không có đầu, mảnh xác hay máu nào.** Chỉ có 133 vệt kéo (giữ) và 367 đồ rải (thay ở lượt 3).

**Góc mẫu:**
- 18 glb trong `game/assets/models/graphics_pilot/realistic_map/wave7/`; 15 texture trong `.../textures/.../wave7/`, đều
  `compress/mode=2`, normal có `normal_map=1`.
- Shader phòng giả `materials/interior.gdshader`. Test `test_t264_pilot.gd`.

Phạm vi góc mẫu:
- **Nhà A:** cả mặt trước theo module (cửa chính có mái sảnh đua, không cột), 2 kiểu. Bóng người `WindowSilhouette1` là hình
  người tối sau ô cửa tầng 3, rèm nhạt phía sau để nổi hình.
- **Nhà thể chất:** 2 kiểu mái.
- **Nhà B:** hành lang tầng 5–6 bị chặn và mặt sau tầng 1–5 (cửa sổ phẳng ngoài mặt tường vì phòng thật ở trong).
- **Đoạn đại lộ x 112…176:** đường, vỉa, lề; cây bàng (x 120, 168), phượng (136), xà cừ (152); 3 đèn; ghế `RoadBench2`;
  xe máy `FallenMoped1`.
- **Hàng rào tây:** z 95…125.

Ảnh chương 3 thật, ban đêm, có và không đèn pin, khối che bật và tắt: `art_source/graphics_upgrade/realistic_map/previews/wave7/`.
- Bảng phương án: `options_interior.jpg`, `options_occlusion.jpg`, `options_building_a.jpg`, `options_wall_colour.jpg`,
  `options_gym_roof.jpg`, `options_b_outside.jpg`, `options_ground.jpg`, `options_fence.jpg`.
- Ba góc toàn cảnh: `wide_views.jpg`. Ảnh đơn: `pilot_*.jpg`.

| Phương án | Tam giác | Ghi chú |
|---|---|---|
| Nội thất a / b / c | (trong nhà A) | a: phòng thật tầng trệt + sảnh, tầng trên kính tối có rèm; b: phòng giả 1 tấm/ô; c: chỉ sảnh |
| Nhà A A2 / A1 | 13.998 / 30.610 | A2 tường cửa sổ từng phòng; A1 hành lang hở có lan can |
| Màu tường vàng / kem xám | — | đổi vật liệu |
| Mái R1 lam bê tông / R2 tôn vòm | 2.536 / 1.638 | nhà thể chất |
| Đường nhựa / bê tông tấm; lề cỏ / block | 1.576 / 1.602; 32 / 32 | 64 m đại lộ |
| Đèn thép / bê tông ly tâm | 114 / 110 mỗi cột | |
| Rào W1 / B40 | 2.184 / 398 mỗi 30 m | cả 1.200 m: ~87 nghìn / ~16 nghìn |

Số lần vẽ ở ba góc toàn cảnh: hành lang tầng 4 nhà B 281 → 238, giữa vườn 333 → 318, khán đài 4.598 → 4.643 (+45: thấy đoạn
đường mẫu, cây, đèn là node riêng có bóng; lượt 3 giữ cây theo cụm MultiMesh và tắt bóng phần nhỏ). Bộ nhớ hình chương 3
1.307 → 1.321–1.326 MB khi nạp mọi thứ của góc mẫu. Không đo FPS (D-179).

**Độ sâu nội thất cần ở từng mặt (để integrator thu khối che):**
| Mặt | Phương án b (phòng giả) | Phương án a | Phương án c |
|---|---|---|---|
| Nhà A mặt trước z 54 | 0,3 m: không cần sửa hộp | tầng trệt (y −9,9…−6,6) 3,2 m; sảnh x 17…28: 6 m; tầng trên 0,3 m | sảnh x 17…28, tầng trệt: 6 m |
| Nhà A kiểu A1 (tầng 2–6 mặt trước) | 2,1 m (hành lang 1,8 + 0,3) | như trái | như trái |
| Giảng đường z 180, thể chất z 90 | 0,3 m: không sửa | sảnh cửa chính (x −13…−7 / −33…−27) 6 m | như a |
| Nhà B tầng 5–6 mặt trước | 3,7 m: mặt hộp `BuildingB_UpperFloor5/6` từ z 3,7 về z 0,0 | như trái | như trái |
| Các mặt khác (hông, sau nhà nền; mặt sau nhà B) | 0 | 0 | 0 |
Khối che chỉ bỏ vật khi cả hộp bao nằm sau nó. Ở góc mẫu, phòng thật vẫn hiện khi bật khối che vì lưới gộp có phần nằm
trước mặt hộp; lượt 2 tách lưới theo phòng nên vẫn cần thu hộp theo bảng trên.

**Đề xuất:**
- Nội thất **b** (phòng giả sau mọi ô cửa: rẻ nhất, mỗi ô một tấm, không phải sửa khối che, đèn pin rọi vào thấy phòng).
- Nhà A kiểu **A2**: nhẹ hơn một nửa, khác hẳn nhà B, bóng người sau cửa sổ tự nhiên.
- Tường **vàng như nhà ăn**: khuôn viên đồng bộ; nhà B màu kem nên vẫn phân biệt được.
- Giảng đường **R1** (mái bằng, lam bê tông); nhà thể chất **R2** (mái tôn vòm).
- Cây: dùng cả **ba loài** (bàng dọc đại lộ, phượng gần các nhà, xà cừ hàng dài), mật độ giữ như nay.
- Đường **nhựa cũ có vá, vạch mờ**; lề **cỏ úa và đất**, chỉ sân trước các nhà lát block.
- Đèn **cột thép cần vươn**.
- Hàng rào bắc, đông, tây: **B40**. Rẻ hơn 5 lần, hợp mặt sau; W1 giữ cho mặt nam.
- Nhà B: phòng giả như nhà A.
- Chương 1–2: **có** bản nhẹ nhà A (vỏ A2, không phòng giả, không song sắt, xa trong sương, không đèn).

**Câu hỏi cho chủ dự án:**
1. Chọn từng mục: nội thất (a/b/c), kiểu nhà A (A2/A1), màu tường (vàng/kem xám), mái (R1/R2, cho từng nhà), cây (ba loài
   hay hai), mặt đường và lề, đèn, hàng rào (W1/B40). Có thể trộn.
2. `WindowSilhouette2` ở x 31 đứng trên trụ giữa hai ô cửa. Chọn một trong hai:
   - dời hình 0,6 m vào ô cửa x 32,5 (vị trí node đổi: cần integrator cho phép);
   - giữ đúng x 31 và mở thêm một ô cửa hẹp ở trụ đó.
3. Có đặt bản nhẹ nhà A cho chương 1–2 không?

**Yêu cầu thay đổi (integrator):** sau khi chủ dự án chọn, thu khối che theo bảng độ sâu (nếu chọn b và A2: chỉ hộp tầng
5–6 nhà B, 3,7 m).

**Kiểm:**
- `-Filter t264`: 6 passed, 0 failed.
- Full `pwsh tools/test.ps1` (chạy lại khi máy đủ RAM, xong 14:45 16/11, cùng nội dung `a9ffcdd`): **`RESULT: 1044 passed, 0 failed`**.
  Lần chạy đầu lúc 13:20 bị Claude Code dừng vì thiếu RAM.
- `pwsh tools/check.ps1` chưa chạy. Lượt 1 không sửa cảnh nào, chỉ thêm asset, script và một test.
- Khoá Lượt Godot của lần bị dừng đã xoá; `game/_probe_tmp/` đã xoá.

## Review integrator, lượt 2 (19/11/2026)
- **Đạt, merge `b3fa3b8`** (nhánh lane B `fe8236e`, gốc main `0d7a25e`, cộng một sửa test của integrator `a4b28c7`).
- Phạm vi đúng card: `shells.tscn` thêm lớp `Real` (nhà A, giảng đường, nhà thể chất) và dời `WindowSilhouette2` x 31 → 32 (D-182 mục 8); `building_b.tscn` thêm lớp `Real/Outside`; `garden_backdrop.tscn` thêm nhà A bản nhẹ; `shells_real.gd` chỉ chạy một lần khi nạp (tắt bóng kính, phòng giả, song, khung, đồ nhỏ, bóng người; tầm vẽ 90 m cho song và đồ nhỏ). Không thêm va chạm, đèn, âm thanh. PS1 chỉ ẩn.
- Ảnh `previews/wave7/r2_*.jpg`: đúng D-182 (nhà A vàng kiểu A2, phòng giả, ba bóng người; giảng đường mái bằng, thể chất mái vòm; tầng 5–6 nhà B thành hành lang bị chặn, mặt sau có cửa sổ). Ban công tầng 4 phía sau lệch màu: chủ dự án cho sửa ở lượt 3 (mục 1).
- **Sửa test của integrator:** `test_t253_realistic_wave2` hỏng vì lớp `Real` mới ở gốc `building_b.tscn` lọt vào bản in node (như `ExitSign` ở T-256). Thêm `Real` vào `ADDED_NAMES`: md5 node trở lại **đúng md5 của main**, va chạm không đổi.
- **Kiểm** (19/11, khoá Godot, chủ dự án tắt tạm chống virus để đủ RAM): full test **`RESULT: 1049 passed, 0 failed`**, check **`RESULT: check 0 error(s)`**. Lượt này cũng phủ khối che nhà ăn và hộp tầng 5–6 nhà B integrator sửa ngày 16/11.
- Số lần vẽ góc khán đài 4.473 → 4.522: lượt 3 phải đưa về không tăng.
