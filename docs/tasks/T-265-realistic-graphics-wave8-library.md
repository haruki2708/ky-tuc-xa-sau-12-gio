# T-265 — Đồ hoạ thật đợt 8: thư viện ba tầng (vỏ ngoài, ba tầng trong, cầu thang, cửa sau) và dải đất quanh thư viện
- Lane: B | Trạng thái: **todo, chưa giao** (card viết 19/11/2026; giao **sau khi T-264 lượt 3 merge**) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`. Chủ dự án tự dán prompt (`lane-b.md` mục 1s).
- **Model (D-183):** lane B **Opus 5.5, effort xhigh** (model cao nhất của lane B). Lượt nào bị trả sửa hai lần cùng một lỗi thì lượt sửa dùng **max**. Phần của integrator (chuyển phương án, review, khối che, hình cho jumpscare nếu có): **Mythos 5.2 high**.
- Nhánh: `lane-b/T-265-realistic-graphics-wave8-library` từ `origin/main` mới nhất (đã có đợt 7 lượt 3).
- Quyết định nền:
  - **D-166:** đồ hoạ thật dựng bằng Blender, không PS1, không Tripo; ánh sáng giữ như nay; không mở khu chơi mới.
  - **D-167/D-172/D-177:** phong cách đã duyệt, cũ vừa phải.
  - **D-175, D-178, D-180, D-181, D-182:** vật liệu đã duyệt: tường vàng nhạt, trát vôi, bê tông trần, gạch ceramic kem, ốp gạch men trắng, trần thạch cao ố, block con sâu xám, thép mạ kẽm, lam bê tông, phòng giả sau ô cửa (shader, không đèn), đường nhựa cũ, lề cỏ úa.
  - **D-176:** chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ. **D-179:** không đo FPS, không chạy bot trong đợt.
  - Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 8 (A20; A21 xem mục 0).
- Làm như đợt 3–6: **hai lượt. Lượt 1 khảo sát, góc mẫu và phương án rồi dừng chờ chủ dự án chọn; lượt 2 làm cả thư viện.** Lượt 2 quá lớn thì dừng sau "vỏ ngoài + tầng 1 + cầu thang", báo, integrator merge rồi làm tiếp tầng 2–3.

## 0. Hiện trạng (integrator khảo sát 19/11; lane B kiểm lại ở bước 1)
- **Cảnh:** `game/scenes/levels/library/library.tscn` (lane B dựng ở T-196), gốc `Library` trong `campus.tscn`, **gốc đặt ở (45; −9,9; 195)**: toạ độ thế giới = toạ độ trong cảnh + (45; −9,9; 195). Khối 40 × 30 m, tức **x 45…85, z 195…225**, ba tầng cách 3,3 m (sàn ở y −9,9 / −6,6 / −3,3), mái ở y ≈ 0.
  - Toàn PS1: 1.532 node (667 MeshInstance3D, 104 khối va chạm, 23 NavigationRegion3D, 23 NavigationLink3D, 6 OmniLight3D, 6 AudioStreamPlayer3D), 10 vật liệu màu trơn. PLAN A20: 8.052 tam giác.
  - Có trong **chương 3 và 4** (cùng `campus.tscn`). Chương 3 người chơi không có việc ở đây nhưng nhìn thấy vỏ ngoài (thư viện nằm phía tây sân vận động). Chương 4 đoạn `library` (08:40–08:50) chơi trong nhà.
  - Ảnh hiện trạng: `realistic_map/previews/survey/ch4_library_floor1.jpg`, `ch4_library_floor2.jpg`, `ch4_library_floor3.jpg`, `ch4_library_back.jpg`. **Mỗi tầng rất trống**: sàn 40 × 30 m chỉ có 3 kệ (tầng 2 thêm 3 bàn đọc).
- **Vỏ** (toạ độ trong cảnh):
  - sàn mỗi tầng ba khối `Floor<t>_Main`, `_South`, `_North` (meta `surface = tile`, `is_floor`), `StairBase`;
  - tường `West<t>` (x 0), `East<t>` (x 40), mặt trước z 0 (`FrontW`, `FrontE`, `FrontLintel` ở tầng 1; `Front1`, `Front2`), mặt sau z 30 (`BackW`, `BackE`, `BackLintel`; `Back1`, `Back2`), `Roof`. **Tường tầng 2–3 là khối đặc**: 24 "cửa sổ" `Window<t>_<x>_<z>` + `Sill*` (x 5, 13, 27, 35 ở mặt trước và mặt sau) chỉ là tấm tối dán mặt trong tường, không có lỗ.
  - `LibraryBand0…2` trong `shells.tscn` (ở (65; −9,9 / −6,6 / −3,3; 194,82)): ba dải mặt trước nhìn từ ngoài. T-264 để nguyên, còn hiện.
- **Cầu thang** phía đông: `Stairs0`, `Stairs1` (va chạm), tay vịn `Rail<t>_34`, `Rail<t>_39` + `RailCollision*` (x 34 và 39, z ≈ 9), navigation `StairNav*`, `StairTop*`, `StairBottom*`, `StairAccess*`, `StairSide*`, `StairFoot*`.
- **Cửa:**
  - **Cửa chính** `FrontDoor` (20; 1,2; 0): khối va chạm đóng cứng, không mở. Sau cửa là **chướng ngại** `Barricade` (bàn, có va chạm `Top`) và `BarricadeChair0…2` ở z 1 (CH4_DESIGN: cửa chính bị chặn bằng bàn ghế từ bên trong).
  - **Cửa sau** `BackDoor` (20; 0; 30), script `room_door.gd`, `room = library_back`: `Blocker` (va chạm), `Hinge` ở x −0,97 quay 90° khi mở, `Hinge/Leaf/Mesh`, `Hinge/Handle`; navigation `DoorThreshold`, `DoorInside`, `DoorOutside`. **Lối vào duy nhất.** Director gắn `Use_BackDoor` (E mở/đóng) và `ZombieDoor`: 6 xác (`Anchors/Ch4/LibraryZombieSpawn/S01…06`, x 62…68, z 228…231) đập **75 giây** thì vỡ, vỡ rồi mở hẳn.
- **Đồ:**
  - tầng 1: `Counter` (12; 0; 11) có `Panel` (va chạm) và **thanh sắt `Counter/IronBar`** ở (1; 0,9; 0) trên mặt quầy; `LibrarianChair` (12; 0; 12,5); `MapBoard` (0,15; 1,8; 16) trên tường tây, gồm `Paper`, năm khối `DormB`, `DormA`, `Library`, `Canteen`, `Stadium` và **hai vòng bút đỏ `FadedCircle0_*`, `FadedCircle1_*` quanh nhà B và nhà A**; kệ `Shelf0_6`, `Shelf0_12`, `Shelf0_28` (z 23);
  - tầng 2: kệ `Shelf1_*` (z 7); ba bàn đọc `ReadingTable8`, `13`, `27` (z 21, có va chạm `Top`) và 6 ghế `Chair<x>_±1`;
  - tầng 3: kệ `Shelf2_*` (z 23).
  - Mỗi kệ khoảng 93 node (lưng, hai hông, các đợt có va chạm; từng cuốn `Book<h>_<i>` là node riêng), meta `triangle_budget = 1500`.
- **Đèn và tiếng:** mỗi tầng hai `Light<t>_9`, `Light<t>_25` (OmniLight3D ở (9 hoặc 25; cao 2,8 so với sàn; 16), năng lượng 0,65, tầm 16, màu xanh nhạt), mỗi đèn một `LightHum` (`light_hum.gd`).
- **Anchor chương 4** (`game/scenes/levels/ch4/ch4_anchors.tscn`, toạ độ thế giới):
  - `Start_library` (65; −9,9; 223), `Counter` (58; −9,0; 206), `MapBoard` (45,25; −8,1; 211), `LibrarianSeat` (57; −9,44; 207,5), `ReadingDesk` (58; −5,71; 216, trên `ReadingTable13`), `ScareShelf3F` (57; −3,3; 218, kệ `Shelf2_12`), `ThrownBook3F` (73; −1,1; 218, nóc kệ `Shelf2_28`).
- **Code dùng thư viện** (`game/scripts/core/chapter4_director.gd`):
  - `_in_library()` theo hộp `LIBRARY_MIN/MAX` (45…85; 195…225);
  - dùng tay ở `Ch4/ReadingDesk` (mở sổ, tab Đối chiếu), `Ch4/MapBoard` (tài liệu `ch4_map`), `Ch4/LibrarianSeat` (tài liệu `ch4_diary`), cửa sau;
  - jumpscare theo khoảng cách: `librarian_rise` (4 m quanh `LibrarianSeat`), `books_fall` (3 m quanh `ScareShelf3F`), `shelf_corpse` (2,5 m quanh `ThrownBook3F`), `back_door_hit` (cửa sau hỏng 30%). Lane B kiểm ở bước 1 xem các jumpscare này **có hình hay chỉ có tiếng**.
  - Âm thanh: vùng `library` (`ch4_music.gd`, `ch4_audio_bank.gd`).
- **Test đang giữ hợp đồng:** `test_ch4_environment` (cửa sau chặn/mở/đóng lại/bị phá; tuyến `Start_split → Start_library → Start_return`; lên tầng 2, 3 tại (65; −6,6; 211), (65; −3,3; 211); tới quầy (60; −9,9; 207,5) và bàn đọc (60,2; −6,6; 216); 6 điểm sinh xác tới (65; −9,9; 226); **mỗi node con tên `Shelf*` của `Library` dưới 1.500 tam giác**), `test_chapter4`, `test_ch2_4_hand_targets` (điểm đặt tay ở bàn đọc, bản đồ, ghế thủ thư, `Counter/IronBar` cao 0,2…1,9 m, cửa sau), `test_room_doors`, `test_ch4_audio`, `test_t264_buildings` (đang khẳng định `LibraryBand*` còn hiện).
- **Lối tây nhà ăn (A21): đã xong ở T-263** (hai mặt tường, khung cửa, cánh cửa thép mở áp tường; vật che lỗ đã hết). Góc x 166…170, z 37…60 ngoài lối tây thuộc đợt 7 lượt 3. **Đợt này không làm lại**: bước 1 chỉ chụp 2 ảnh chương 4 từ `Start_split` để xác nhận lỗ cửa, hè và dải đợt 7 khớp nhau; lệch thì ghi Handoff.
- **Quanh thư viện:** T-264 để lại **vùng đợt 8 x 39…91, z 189…231** (thư viện và 6 m quanh nó): mặt đất, cây, đèn, đồ rải trong vùng này chưa ai làm. Đường sang thư viện ngoài vùng này thuộc đợt 7 lượt 3.
- **Khối che (occlusion culling, của core):** thư viện **chưa có hộp che nào**. Integrator thêm sau khi đợt này merge (như nhà ăn ở T-263), xem mục 5.
- **Hiệu năng:** PLAN mục 6 cho A20–A21 **≤ 0,60 ms** thêm. Rủi ro chính: sách (hàng nghìn cuốn), ba tầng cùng vẽ, kính.

## 1. Chủ dự án chốt
**D-185 (20/11/2026):** chủ dự án giao integrator xem ảnh lượt 1 và chọn ("xem ảnh và cứ chọn những đề xuất bạn chọn, không cần hỏi tôi đâu"). Integrator chọn theo cấu hình **c** của lane B, cộng các điểm ghi "(integrator)" dưới đây. Lượt 2 làm đúng các mục này.

**Review lượt 1 (integrator, 20/11):** đạt, chưa merge (lượt 1 chỉ có góc mẫu). Nhánh `66d6a77`, full test `1063 passed, 0 failed`. Integrator đã xem mọi tờ phương án và bản đồ lối đi.

**Review lượt 2 (integrator, 20/11 sáng sớm):** đạt về hình và test, **chưa merge**; cần **lượt 3 nhỏ** (mục 14, D-186). Nhánh `3d10898` (`860939d` + danh sách commit). Đã kiểm:
- diff `game/` chỉ có thêm (một dòng sửa: `test_t264_buildings` đổi câu `LibraryBand*` còn hiện → đã ẩn, đúng mục 8). Navigation là lưới dựng sẵn trong `library.tscn`, không dòng nào của main bị sửa;
- `test_t265_library` (14/0): dấu vân 1.533 dòng trùng main, 667 hình PS1 ẩn, 111 khối thêm kiểm từng khối theo luật mục 4, hai lan can đúng hộp và cách navigation ≥ 0,31 m, thân người chơi đi cả ba tầng và bị lan can chặn, tuyến xác từ 6 điểm sinh lên tầng 3;
- không còn `W7RoomClass` trong thư viện; ảnh bật/tắt occlusion giống nhau;
- số lần vẽ giảm hoặc bằng ở mọi góc; góc vườn đợt 7 primitive +0,5 % (vỏ thư viện ở 190 m), chấp nhận, xem lại sau khi integrator thêm khối che;
- độ ướt sàn (`wet_strength` 0,35) thấp hơn sàn các đợt đã duyệt (nhà ăn 0,9, tầng 4 1,2–1,3): giữ nguyên;
- **full test của lane B bị dừng vì thiếu RAM, check chưa chạy**: integrator chạy một lần full test + check sau lượt 3 (kèm khối che), khi chủ dự án đã tắt RAV và Chrome.

1. **Mức đầy: M2, có thêm dãy kệ hai mặt trong bốn khoang lớn** (integrator). Ảnh `options_fill.jpg` cho thấy M2 nhìn ngang mắt gần như M1, phòng vẫn trống. Các dãy kệ của ảnh mẫu M3 ở tầng 1 (`options_fill_m3_floor1.jpg`) đều nằm trọn trong vùng xanh, tức đã thoả điều kiện M2 ở mục 4. Vì vậy lấy các dãy đó vào M2:
   - **Mọi món thêm, kể cả dãy kệ, theo đúng điều kiện M2 ở mục 4:** ngoài mọi vùng navigation cộng 0,6 m; không chắn đường thẳng giữa hai vùng; lối bên cạnh rộng ít nhất 1,2 m; ngoài vòng 1,5 m; không che đường nhìn cửa sau → quầy và đầu cầu thang tầng 2 → bàn đọc; có va chạm dưới `Real/Added`; có danh sách trong Handoff và có test. **Navigation và tuyến xác không đổi; không làm M3**, nên không có card navigation.
   - **Tầng 1:** đồ M2 cộng các dãy của ảnh mẫu M3 thoả điều kiện; góc tây nam quanh quầy, ghế thủ thư và bản đồ giữ trống như ảnh M2.
   - **Tầng 2 (phòng đọc):** đồ M2 cộng vài dãy ở khoang xa bàn đọc; giữ trống 3 m quanh ba bàn đọc.
   - **Tầng 3 (kho sách cổ, CH4_DESIGN):** chỉ những dãy của ảnh mẫu M3 thoả điều kiện, kệ gỗ cũ.
   - Dãy kệ hai mặt có sách. Bản gần dùng atlas, bản xa là hộp; giữ ngân sách mục 6.
2. **Kệ:** kệ thép sơn xám, sách đầy ở tầng 1–2; tầng 3 kệ gỗ cũ, sách vơi, có đợt đổ nghiêng. **Sửa (integrator):** lưng kệ thép nhìn từ phía sau (`options_window.jpg`) đang giống khối đá hoa cương; đổi thành tôn sơn có nẹp và đường gấp, bớt lốm đốm.
3. **Sàn, tường:** F1 (ceramic kem, tường vàng nhạt, chân gạch); tầng 3 sàn xi măng.
4. **Trần:** C2 (tấm 60 × 60 ố, vài tấm rơi; máng đèn đúng chỗ 6 đèn, các máng khác tắt).
5. **Quầy:** Q1. **Ghế thủ thư** đứng thẳng, mặt ghế 0,46 m (anchor `LibrarianSeat`, `ch4_diary`).
6. **Bàn đọc:** T1; sổ quy tắc đúng chỗ anchor `ReadingDesk`.
7. **Cửa sổ nhìn từ trong:** kính tối, song sắt, rèm bạc màu.
8. **Mặt ngoài:** E1 (tường vàng, dải trắng, lam bê tông đứng ≤ 0,45 m).
   - **Ô cửa nhìn từ ngoài là kính tối có rèm phía sau, không dùng phòng giả** (integrator). `W7RoomClass` vẽ lớp học có bảng đen, không hợp thư viện; trong nhà các ô này là kính tối có rèm, nên hai phía phải khớp.
   - **Mặt đông và tây** (integrator): thêm ô cửa chỉ ở mặt ngoài, cùng nhịp với mặt trước và sau, kính tối, rèm kéo kín, để nhìn từ sân vận động (`options_facade_far.jpg`) không còn là khối trơn. Trong nhà các tường này giữ trơn.
9. **Bản đồ trường:** bản in trong khung kính nhôm.
   - **Hai vòng đỏ** vẽ trong hình đúng đường `FadedCircle*` cũ; ẩn 52 đoạn PS1 (integrator đồng ý cách của lane B; không script hay test nào đọc `FadedCircle`). Lượt 2 có test so vị trí hai vòng trong hình với đường `FadedCircle` cũ.
   - **Giảm phản chiếu của kính** để dưới đèn pin vẫn đọc rõ vòng đỏ ở 2 m (`options_map.jpg` hàng 2 bị loá; integrator).
10. **Mức bừa:** bừa vừa. **Không bày sẵn kết quả jumpscare** (integrator nói rõ):
    - trong 2 m quanh `ScareShelf3F`, `ThrownBook3F`, kệ `Shelf2_12` và `Shelf2_28` không rải sách, giấy, không có kệ đổ;
    - quanh quầy và ghế thủ thư (`librarian_rise`) không có gì giống xác;
    - ghế thủ thư không đổ.
11. **Lan can ô cầu thang tầng 2 và 3: có, có va chạm** (integrator; trả lời câu 11 và "Yêu cầu thay đổi"). Cùng mục 14 (D-186), đây là **thay đổi gameplay duy nhất** của đợt.
    - **Vị trí:** mép tây ô cầu thang, x 79, z 199…209, cao 1,1 m từ mặt sàn, ở tầng 2 và tầng 3. Kiểu như lan can cầu thang (thép dẹt, tay vịn gỗ).
    - **Cách làm:** là **phần thêm dưới `Real/Added`**, không sửa va chạm có sẵn.
    - **Điều kiện:** nằm ngoài mọi vùng và link navigation cộng bán kính xác sống (lấy từ cảnh xác, ghi số vào Handoff).
    - **Test:**
      - dấu vân va chạm ghi đúng hai đoạn lan can này là phần thêm;
      - đi thử bằng thân người chơi tầng 1 → tầng 2 → nhịp hai → tầng 3 và ngược lại không kẹt;
      - tuyến navigation từ 6 điểm sinh lên tầng 3 vẫn thông;
      - người chơi đi vào mép tây ô cầu thang ở z 200, 205, 208 thì bị chặn, không rơi.
12. **Dải đất quanh thư viện:** như góc mẫu (hè 0,8 m, rãnh nắp bê tông, sân lát block trước cửa chính, thềm đá mài, cỏ úa khớp mặt nạ đợt 7). Sáu điểm sinh xác để trống; hai đống gạch vụn có va chạm giữ nguyên.
13. **Khối che:** integrator thêm hộp che cho thư viện sau khi đợt này merge (theo "Mặt đặc kín" lane B ghi ở Handoff lượt 1). Lượt 2 chụp vài góc bật và tắt occlusion culling như mục 5.
14. **Bịt các chỗ còn rơi được của ô cầu thang (D-186, integrator, review lượt 2).** Va chạm PS1 của ô (toạ độ thế giới): sàn tầng 2 và 3 hở x 79…85, z 199…209; tay vịn đông của mỗi nhịp `RailCollision*_39` ở x 83,95…84,05; mặt trong tường đông ở x 84,89. Còn ba chỗ rơi:
    - **Khe đông** x 84,05…84,89 (rộng 0,84 m, thân người chơi 0,6 m), z 199…209, ở tầng 2 và tầng 3: đi về bắc từ sàn phía nam (z < 199), hoặc về nam từ sàn phía bắc (z > 209), là rơi xuống tầng 1 (3,3 m từ tầng 2, 6,6 m từ tầng 3).
    - **Mép nam ở tầng 3** x 79…84, z 199: tầng 3 không có nhịp đi lên, nên đi về bắc từ vùng `StairFoot2` là rơi 3,3 m xuống chân nhịp hai (lane B báo ở lượt 2).
    - Cách bịt: **lan can có va chạm, kiểu như lan can mép tây** (thép dẹt, tay vịn gỗ, cao 1,1 m từ mặt sàn), là phần thêm dưới `Real/Added`, tên bắt đầu bằng `WellRail` để test kiểm hộp và khoảng cách navigation như hai đoạn mép tây. Integrator đề xuất bốn đoạn (lane B đo lại, ghi toạ độ thật vào Handoff):
      - `WellRail_F3S`: tầng 3, x 78,86…84,89, z ≈ 198,92…199, nối `WellRail_F3` tới tường đông (bịt cả mép nam lẫn đầu nam khe đông);
      - `WellRail_F2SE`: tầng 2, x 84,05…84,89, z ≈ 198,92…199 (đầu nam khe đông; lối vào nhịp hai x 79…84 **để hở**);
      - `WellRail_F2NE`, `WellRail_F3NE`: tầng 2 và tầng 3, x 84,05…84,89, z ≈ 209…209,08 (đầu bắc khe đông; lối ra của nhịp **để hở**).
    - **Không** lấp khe bằng sàn (sẽ thành hành lang hẹp ngoài navigation, người chơi trốn được) và **không** dùng khối đặc (khối đó phải qua luật M2 mục 4, sát `StairNav` sẽ trượt).
    - Mỗi đoạn cách mọi vùng và link navigation ≥ 0,31 m (bán kính xác). Đoạn nào chỉ nối tiếp một tay vịn PS1 trên cùng đường x mà không thể cách xa hơn tay vịn đó thì được gần bằng tay vịn đó; ghi số đo và lý do trong Handoff, test kiểm đúng số đó.

## 2. Việc, theo ba lượt (lượt 3 thêm sau review lượt 2)

### Lượt 1 — khảo sát, góc mẫu, phương án, rồi DỪNG chờ chủ dự án chọn
1. **Khảo sát, ghi Handoff:**
   - Kiểm lại mục 0. Grep mọi chỗ code, test, bot, âm thanh, công cụ đụng tới thư viện (`library.tscn`, `Library/`, `library_back`, `BackDoor`, `FrontDoor`, `Barricade`, `Counter`, `IronBar`, `MapBoard`, `ReadingTable`, `Shelf`, `LibraryBand`, `Start_library`, `LibrarianSeat`, `ReadingDesk`, `ScareShelf3F`, `ThrownBook3F`, `LibraryZombieSpawn`, `LIBRARY_MIN`, `ch4_map`, `ch4_diary`, `levels/ch4/review.gd`, `ch4_menu.gd`).
   - **Bảng hợp đồng**: node nào giữ tên, vị trí, va chạm, navigation.
   - **Bản đồ lối đi từng tầng**: vẽ (ảnh nhìn từ trên) các vùng navigation, các khối va chạm, các anchor; đánh dấu **chỗ sàn trống nằm ngoài mọi vùng navigation cộng 0,6 m** (chỗ có thể thêm đồ mà không chạm lối đi). Việc này quyết định phương án "mức đầy" ở bước 3.
   - **Đi thử** bằng thân người chơi thật trong chương 4: `Start_library` → mở cửa sau → quầy, lấy thanh sắt → bản đồ → cầu thang lên tầng 2 → bàn đọc → tầng 3 → `ScareShelf3F`, `ThrownBook3F` → quay xuống, ra cửa sau; vòng quanh ngoài thư viện cách tường 0,7 m; đứng ở 6 điểm sinh xác.
   - **Jumpscare:** ba jumpscare trong nhà và tiếng đập cửa có hình gì (xác thủ thư, sách rơi, xác trên kệ) hay chỉ có tiếng; ghi rõ.
   - **Vùng đợt 8 ngoài nhà** (x 39…91, z 189…231 trừ nền nhà): liệt kê đường dẫn node và số bản MultiMesh (cây, đèn, đồ rải); phân loại đồ rải, mảnh xác, máu, vệt kéo; **đếm đầu xác trong từng node trước khi đụng**.
   - Hai ảnh lối tây nhà ăn ở chương 4 (mục 0).
2. **Góc mẫu** (Blender, chất lượng ngang các đợt trước; ảnh cùng camera trong **chương 4 thật**, ban đêm như chương, có và không đèn pin):
   - **Tầng 1:** góc quầy thủ thư có thanh sắt, ghế thủ thư, bản đồ trường trên tường tây, một kệ; nhìn từ cửa sau vào.
   - **Tầng 2:** một bàn đọc có ghế (bàn `ReadingTable13` có sổ quy tắc), một kệ, một ô cửa sổ.
   - **Cầu thang** một nhịp có tay vịn.
   - **Cửa sau** nhìn từ ngoài (đóng) và từ trong (mở), **cửa chính có chướng ngại** nhìn từ trong.
   - **Mặt ngoài:** một đoạn mặt trước ba tầng có cửa chính, chụp từ sân và một ảnh xa (từ phía sân vận động, chương 3).
3. **Phương án để chủ dự án chọn bằng mắt** (mỗi phương án ghi số tam giác, vật liệu, số lần vẽ; đề xuất một):
   - **Mức đầy của ba tầng** (câu quan trọng nhất, vì hiện mỗi tầng chỉ 3 kệ):
     - **M1** giữ đúng bố cục thưa hiện nay, chỉ thay hình;
     - **M2** thêm đồ ở **sát tường và ở chỗ sàn trống ngoài lối đi** (kệ sát tường, tủ phích thư mục, bàn báo, xe đẩy sách, thùng sách, cây cảnh chết khô), đồ thêm **có va chạm**, không đổi navigation;
     - **M3** thêm cả dãy kệ giữa phòng thành các lối hẹp như thư viện thật (**phải đổi navigation và tuyến xác sống**: lane B chỉ dựng ảnh mẫu, không tự làm; nếu chủ dự án chọn thì integrator làm phần navigation, test trong một card riêng).
     - Kèm ảnh nhìn từ trên cho từng mức ở tầng 1 và tầng 3 (tầng 3 là "kho sách cổ" theo CH4_DESIGN).
   - **Kệ sách:** kệ thép sơn xám kiểu thư viện trường, hay kệ gỗ; mức sách (đầy, vơi, có đợt đổ nghiêng).
   - **Sàn và tường trong:** gạch ceramic kem và tường vàng nhạt như nhà ăn (D-181), hay sàn đá mài (granito) và tường quét vôi trắng ngà chân tường sơn xanh; tầng 3 có khác tầng dưới không (sàn xi măng, kệ gỗ cũ).
   - **Trần:** thạch cao 60 × 60 ố vàng như nhà ăn, hay trần bê tông trần có quạt trần; hai đèn mỗi tầng giữ chỗ (máng đèn tuýp).
   - **Quầy thủ thư:** quầy gỗ dán có mặt kính, tủ phích thư mục, máy tính màn hình CRT tắt; hay quầy xây ốp gạch. Mặt quầy **giữ đúng độ cao** để thanh sắt nằm trên.
   - **Bàn đọc:** bàn gỗ dài ghế gỗ rời; có vách ngăn giữa bàn và đèn bàn (không sáng) hay không.
   - **Cửa sổ:** nhìn từ trong là kính tối có song sắt và rèm bạc màu, hay cửa chớp gỗ khép; nhìn từ ngoài dùng phòng giả sau ô cửa như D-182 hay kính tối. Tường vẫn là khối đặc: không đục lỗ.
   - **Mặt ngoài:** tường vàng như các nhà khác kèm **lam bê tông đứng che nắng** suốt ba tầng (kiểu thư viện trường thập niên 80–90), hay mặt đá rửa xám có biển chữ "THƯ VIỆN" trên cửa chính (chữ vẽ trong hình, font Be Vietnam Pro).
   - **Bản đồ trường:** bản in trong khung kính, hay bản vẽ tay trên giấy dán bảng gỗ. **Hai vòng bút đỏ quanh nhà A và nhà B phải còn và nhìn rõ ở 2 m**; bố cục năm khối nhà giữ đúng; đối chiếu với tài liệu `ch4_map` người chơi mở ra để hai bản không trái nhau.
   - **Mức bừa:** như nay (gần như gọn), hay có sách rơi, ghế đổ, giấy vương, xe đẩy sách lật (chỉ là hình; vật cao trên 3 cm không nằm trên lối đi). **Không bày sẵn kết quả của jumpscare** (không rải sẵn sách dưới kệ `ScareShelf3F`, không đặt xác trên kệ).
   - **Dải đất quanh thư viện:** sân lát block con sâu trước cửa chính và bậc thềm, hè bê tông và rãnh có nắp quanh nhà như nhà ăn; phía cửa sau là hè hẹp và đất (chỗ 6 điểm sinh xác phải trống).
4. Commit, push nhánh, ghi Handoff, **báo và dừng**. Integrator chuyển phương án cho chủ dự án (AskUserQuestion, có đề xuất), ghi lựa chọn vào mục 1.

### Lượt 2 — cả thư viện (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
5. **Vỏ ngoài** bốn mặt, mái, cửa chính (đóng), cửa sau (mở được), cửa sổ; ẩn `LibraryBand0…2`.
6. **Ba tầng trong:** sàn, tường, trần, máng đèn, cửa sổ; quầy, ghế thủ thư, bản đồ; 9 kệ và sách; 3 bàn đọc và 6 ghế; chướng ngại cửa chính; cầu thang và tay vịn; đồ thêm theo mức đầy đã chọn.
7. **Dải đất** trong vùng đợt 8 ngoài nhà, khớp mép với dải đợt 7 ở x 39, x 91, z 189, z 231.
8. Ảnh trước/sau, ảnh ghép, test, full test, check, README, CREDITS, Handoff; **báo và dừng**.

### Lượt 3 — bịt ô cầu thang (mục 14, D-186; chủ dự án dán prompt lượt 3)
9. `git fetch`, **rebase nhánh lên `origin/main`** (lấy mục 1 và lượt 3 này), `git lfs pull`.
10. **Test trước:** viết các phép thử rơi vào `test_t265_library.gd` và chạy trên bản lượt 2 (chưa có lan can mới); chúng **phải hỏng** (người chơi rơi). Phép thử: thân người chơi đi thẳng
    - về bắc ở x 84,47 từ z 197, trên tầng 2 và tầng 3;
    - về nam ở x 84,47 từ z 211, trên tầng 2 và tầng 3;
    - về bắc ở x 80, 82 và 84,47 từ z 197, trên tầng 3.

    Phép thử nào **không** rơi trên bản lượt 2 thì bỏ đoạn lan can tương ứng và ghi lý do. Đi về bắc ở x 80…84 từ z 197 trên **tầng 2** vẫn phải lên được nhịp hai (lối vào để hở).
11. **Dựng** các đoạn lan can của mục 14 (glb `stairs` và `Real/Added`), thêm vào `RAILS` và tăng `ADDED` trong test. Các phép thử ở bước 10 phải qua: người chơi dừng trên sàn, không rơi.
12. **Kiểm:** `pwsh tools/test.ps1 -Filter t265` và `-Filter t264` (cả tuyến đi bộ ba tầng và tuyến xác từ 6 điểm sinh vẫn qua). **Không chạy full test, không chạy check**: máy thiếu RAM; integrator chạy một lần full test + check khi merge (kèm khối che thư viện), lúc chủ dự án đã tắt RAV và Chrome. Thêm 1–2 ảnh lan can mới (`r3_well.jpg`). Ghi Handoff `### Lượt 3`, commit, push, **báo và dừng**.

## 3. Phạm vi
- **Trong đợt:** `library.tscn`; `LibraryBand*` trong `shells.tscn` (chỉ ẩn); mặt đất, cây, đèn, đồ rải trong hộp x 39…91, z 189…231.
- **Không đụng:** lối tây nhà ăn và nhà ăn; các dải và nhà đã làm ở đợt 1–7 (trừ đường khớp mép); phòng 407 chương 4 và bệnh viện (đợt 9); CCTV (đợt 10).
- Mảnh xác tĩnh, máu, vệt kéo: không đụng.
- Không mở cửa chính, không thêm lối vào (cửa sổ vỡ chui được là đổi gameplay: không làm).

## 4. Hợp đồng gameplay (bắt buộc giữ)
- Không đổi tên, gốc, transform:
  - `Library` (gốc), mọi `StaticBody3D` có sẵn (`Floor*` và meta, `StairBase`, `West*`, `East*`, `Front*`, `Back*`, `Roof`, `Stairs*`, `RailCollision*`, `FrontDoor`, `Barricade/Top`, `Counter/Panel`, `ReadingTable*/Top`, các khối của `Shelf*`);
  - `BackDoor` và các con `Blocker`, `Hinge`, `Hinge/Leaf`, `Hinge/Handle` (cánh mới **treo dưới `Hinge`**, bản lề đúng chỗ cũ, quay 90° không cắm vào tường; khổ cửa không hẹp hơn);
  - `Counter/IronBar` (vị trí; mặt quầy mới ở đúng độ cao cũ, thanh sắt nằm trên mặt quầy, không lơ lửng, không chìm);
  - `MapBoard` (vị trí, hai vòng đỏ), `Light*` và `LightHum`;
  - mọi `NavigationRegion3D`, `NavigationLink3D`;
  - `Anchors/Ch4/*` trong `ch4_anchors.tscn` (không sửa file này).
- **Va chạm có sẵn giữ nguyên** (test so dấu vân tay với main). Hình mới nằm trên hoặc trong khối va chạm cũ: mặt sàn nhìn thấy trùng mặt va chạm (lệch ≤ 2 cm), bậc thang nhìn thấy trùng bậc va chạm, kệ và bàn mới khít khối cũ (lệch ≤ 3 cm), tay vịn trong `RailCollision*`.
- **Đồ thêm (chỉ khi chủ dự án chọn M2):**
  - mỗi món cao trên 0,3 m phải có va chạm riêng (`StaticBody3D` lớp 1, đặt dưới node `Real/Added`), người chơi không đi xuyên;
  - nằm **ngoài mọi vùng navigation cộng 0,6 m**, không chắn đường thẳng giữa hai vùng, lối còn lại bên cạnh mỗi món rộng ít nhất **1,2 m**;
  - không trong 1,5 m quanh mọi anchor chương 4, cửa sau, chân và đầu cầu thang;
  - không che đường nhìn từ cửa sau tới quầy, từ đầu cầu thang tầng 2 tới bàn đọc;
  - danh sách (tên, vị trí, kích thước) ghi trong Handoff và có test.
- **Chỗ dùng tay không đổi:** người chơi vẫn đứng được ở chỗ cũ để dùng bàn đọc, bản đồ, ghế thủ thư, cửa sau, nhặt thanh sắt (`test_ch2_4_hand_targets`). Sổ quy tắc trên bàn `ReadingTable13` nằm đúng chỗ anchor `ReadingDesk`.
- Tuyến xác sống từ 6 điểm sinh qua cửa sau, lên cả ba tầng không bị đồ mới chặn; người chơi không kẹt.
- Hình PS1 chỉ ẩn (`visible = false`), không xoá. Hình mới đặt dưới node `Real` (như các đợt trước), **không đặt dưới các node `Shelf*`** (test ngân sách 1.500 tam giác của T-196 đếm theo các node đó). Bản MultiMesh của `props.tscn` chỉ thu từng bản về 0.
- Ánh sáng giữ như nay (D-166): 6 đèn giữ vị trí, màu, năng lượng, tầm; không thêm đèn; kính và màn hình không phát sáng.
- Không đổi luật, lời thoại, director, âm thanh, tài liệu `ch4_map`, `ch4_diary`.

## 5. Khối che (occlusion culling) — phối hợp với integrator
- Lane B **không sửa** `game/scenes/main/occlusion/` (của core).
- Lượt 1: ghi trong Handoff những mặt nào của thư viện là khối đặc kín sau khi dựng (tường tây, đông, sàn giữa tầng, mái) và chi tiết mặt ngoài lấn ra bao nhiêu (lam, bậc thềm), để integrator đặt hộp che lọt trong tường.
- Lượt 2: chi tiết mặt tường trong và ngoài **nằm trong 0,45 m tính từ mặt tường** (như đợt 7). Chụp vài góc bật và tắt occlusion culling (`get_tree().root.use_occlusion_culling`) để chắc khối che đang có của khuôn viên không ẩn nhầm vật mới.
- **Sau khi đợt này merge, integrator thêm hộp che cho thư viện** (sàn giữa tầng, tường ngoài, mái) bằng `make_occluders.py`, kèm ảnh bật/tắt và `test_t260_occlusion`.

## 6. Kỹ thuật và hiệu năng
- Script Blender (Blender 5.2.2 ở `D:\Tools\Blender\5.2.2`) như các đợt trước; nguồn mesh, texture **CC0** ghi URL, tác giả, giấy phép trong CREDITS. **Không extension Blender, không Tripo, không ảnh AI.** Chữ dùng font có sẵn trong game (Be Vietnam Pro, OFL).
- Dùng lại bộ vật liệu đã duyệt (tường vàng, trát vôi, gạch ceramic, trần thạch cao, thép, gỗ dán của đợt 1–7) trước khi thêm vật liệu mới.
- **Sách:** gáy sách dùng **atlas** (vài chục gáy khác nhau), mỗi kệ một lưới gộp hoặc MultiMesh theo cụm; không để mỗi cuốn một node hay một lần vẽ. Bản xa của kệ (`visibility_range`) là hộp có texture gáy sách.
- **Ba tầng:** vật nhỏ không đổ bóng; đồ của tầng người chơi không đứng dùng `visibility_range` hoặc ẩn theo tầng bằng script cảnh (chỉ hình, kiểu `floor4_rooms.gd`), miễn không vật nào hiện trễ khi đi cầu thang.
- Ngân sách (PLAN mục 6): **≤ 0,60 ms** thêm. Ghi số tam giác, vật liệu, **số lần vẽ trước/sau cùng camera** (`RenderingServer.get_rendering_info`) ở: cửa sau nhìn vào tầng 1, giữa tầng 2, giữa tầng 3, đầu cầu thang, ngoài sân nhìn mặt trước. Ba góc toàn cảnh của đợt 7 (hành lang tầng 4 nhà B, giữa vườn, trên khán đài) **không được tăng**.
- **Mọi texture mới từ 512 px trở lên phải nén VRAM** trong `.import` (`compress/mode=2`; normal thêm `compress/normal_map=1`); có test. Ghi bộ nhớ hình chương 4 trước/sau.
- Không đo FPS, không chạy bot (D-179).

## 7. Ảnh
- `art_source/graphics_upgrade/realistic_map/previews/wave8/`: lượt 1 `pilot_*`, `options_*.jpg`, bản đồ lối đi `plan_floor<t>.jpg`; lượt 2 `before_*`/`after_*` cùng camera trong **chương 4 thật** (cửa sau từ ngoài, từ cửa sau nhìn vào, quầy và thanh sắt, bản đồ ở 2 m, cửa chính có chướng ngại, cầu thang, bàn đọc, mỗi tầng một ảnh rộng, tầng 3 ở hai chỗ jumpscare, mặt trước từ sân, dải quanh nhà) và 1–2 ảnh **chương 3** nhìn thư viện từ xa; ảnh ghép `overview.jpg`. Ban đêm như chương, có và không đèn pin.

## 8. Kiểm
- Test mới `game/tests/levels/test_t265_*.gd`:
  - dấu vân tay va chạm có sẵn, node, navigation, đèn của `library.tscn` trùng main (lớp `Real` để ngoài bản in, như T-264); hình PS1 ẩn, không xoá;
  - cửa sau: cánh mới treo dưới `Hinge`, đóng thì chặn, mở thì thông (capsule 0,3 m), bị phá thì mở;
  - thanh sắt nằm trên mặt quầy mới (khe ≤ 2 cm); hai vòng đỏ của bản đồ còn hiện;
  - mặt sàn và bậc thang nhìn thấy trùng va chạm;
  - đồ thêm (nếu có): mỗi món có va chạm, ngoài navigation cộng 0,6 m, cách anchor 1,5 m, lối bên cạnh ≥ 1,2 m;
  - thân người chơi đi được tuyến đã đi thử ở bước 1; tuyến navigation của `test_ch4_environment` vẫn thông;
  - bản MultiMesh thu về 0 đúng danh sách, không bản mảnh xác nào bị đụng;
  - mọi `.import` texture trong thư mục asset đợt 8 nén VRAM.
- Test cũ đạt: `test_ch4_environment`, `test_chapter4`, `test_chapter4_data`, `test_ch2_4_hand_targets`, `test_room_doors`, `test_ch4_audio`, `test_ch4_menu`, `test_campus`, `test_t260_occlusion`, `test_t259*`, `test_t261*`, `test_t262*`, `test_t263*`, `test_t264*`, `test_chapter3`. Được sửa: câu khẳng định `LibraryBand*` còn hiện trong `test_t264_buildings` (đổi thành "đã ẩn ở đợt 8"), và **hằng số đếm bản MultiMesh dùng chung** trong test các đợt trước khi thu thêm bản về 0, có comment lý do; không nới kiểm tra khác.
- Mỗi lượt có sửa cảnh: full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối, rồi `git checkout -- game/default_bus_layout.tres`. Lượt bị dừng vì thiếu RAM thì ghi rõ, không tự chạy lại.

## 9. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave8/`, `.../previews/wave8/`, `game/assets/models/graphics_pilot/realistic_map/wave8/`, `game/assets/textures/graphics_pilot/realistic_map/wave8/`;
- `game/scenes/levels/library/library.tscn` (ẩn hình PS1, thêm lớp `Real`, cánh cửa mới dưới `BackDoor/Hinge`; va chạm mới chỉ cho đồ thêm theo mục 4), script cảnh mới trong `game/scenes/levels/library/`;
- `game/scenes/levels/campus/shells.tscn` (chỉ ẩn `LibraryBand*`), `campus.tscn` (hình mặt đất, cây, đèn trong hộp đợt 8; node dải mới), `props.tscn` (chỉ dữ liệu MultiMesh trong hộp đợt 8);
- test mới và các chỗ nêu ở mục 8 trong `game/tests/levels/`; card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 10. Không được
- Đổi va chạm có sẵn, navigation, anchor (`ch4_anchors.tscn`), vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `room_door.gd`, `chapter*.tscn`, `game/scenes/main/` (kể cả khối che), `project.godot`.
- Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Lượt 1: khảo sát, bảng hợp đồng, bản đồ lối đi ba tầng, đi thử, jumpscare, vùng ngoài nhà, ảnh lối tây (Handoff)
- [ ] Lượt 1: góc mẫu và phương án (mức đầy M1/M2/M3 có ảnh nhìn từ trên); dừng chờ chủ dự án chọn
- [ ] Lượt 2: vỏ ngoài, cửa chính, cửa sau, cửa sổ, ẩn `LibraryBand*`
- [ ] Lượt 2: ba tầng trong, cầu thang, quầy, bản đồ, kệ và sách, bàn đọc, chướng ngại, đồ thêm (nếu chọn)
- [ ] Lượt 2: dải đất quanh thư viện, khớp mép đợt 7
- [ ] Lượt 2: ảnh trước/sau, `overview.jpg`, test, full test, check, README, CREDITS, Handoff

## Handoff
*(Lane B ghi: đã làm, còn dở, cách kiểm, dòng RESULT test và check, commit, yêu cầu thay đổi, phần chưa kiểm.)*
