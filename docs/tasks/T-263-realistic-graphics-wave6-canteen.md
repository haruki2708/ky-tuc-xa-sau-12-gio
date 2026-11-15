# T-263 — Đồ hoạ thật đợt 6: nhà ăn, bếp, kho (và trả đầu 6 xác trong vườn)
- Lane: B | Trạng thái: **done** (giao 15/11/2026; chọn D-181; merge `4031339` 16/11) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1q).
- Nhánh: `lane-b/T-263-realistic-graphics-wave6-canteen` từ `origin/main` mới nhất.
- Quyết định nền:
  - **D-166:** đồ hoạ thật dựng bằng Blender, không PS1, không Tripo trừ khi chủ dự án đổi; ánh sáng giữ như nay.
  - **D-167/D-172/D-177:** phong cách đã duyệt, cũ vừa phải.
  - **D-175, D-178, D-180:** các vật liệu đã duyệt: sân block xám, trát vôi, bê tông trần, thép mạ kẽm, block con sâu; cổng có chốt vôi vàng, tường vôi.
  - **D-176:** chủ dự án chỉ chơi thử một lượt khi xong toàn bộ đồ hoạ.
  - **D-179:** không đo FPS, không chạy bot trong đợt.
  - Kế hoạch: `art_source/graphics_upgrade/realistic_map/PLAN.md` đợt 6 (A15, cộng A16 quanh nhà ăn).
- Làm như đợt 3–5 (T-259, T-261, T-262): **lượt 1 góc mẫu rồi dừng chờ chủ dự án chọn; lượt 2 làm cả khu.**

## 0. Hiện trạng (HARU khảo sát 15/11; lane B kiểm lại ở bước 1)
- **Cảnh:** `game/scenes/levels/campus/canteen.tscn`, gốc `Canteen` trong `campus.tscn`, transform gốc 0 nên toạ độ trong cảnh là toạ độ thế giới.
  - Dùng ở **chương 3** (đoạn `gate` → `canteen`, 08:26–08:30) và **chương 4** (đầu chương, `Ch4/Start_split` (167; −9,9; 40,5) ngay ngoài lối tây).
  - Toàn PS1: 1.742 node (932 MeshInstance3D, 43 khối va chạm, 8 Label3D, 3 OmniLight3D); PLAN A15 ghi 19.380 tam giác, 13 vật liệu, khối 41 × 38 × 7,4 m.
  - Ảnh hiện trạng: `realistic_map/previews/survey/33_canteen_entry.jpg`, `34_canteen_tv.jpg`, `35_canteen_kitchen.jpg`, `36_canteen_store.jpg`.
- **Sảnh ăn** x 170…210, z 20…44: sàn `Floor` (190; −10; 32, meta `surface = tile`, `is_floor`), mái `Roof`, trần `Ceiling` (−5,85).
  - Tường: `Front178`, `Front202` (mặt trước z 20, cửa chính ở giữa x ≈ 190, có `Step`, `Canopy`, `CanopyPost*`), `Side` (x 210), ba khối `Back` (z 44; chừa lỗ sang bếp x ≈ 192 và sang kho x ≈ 202).
  - Ốp gạch chân tường: `TileW`, `TileE`, `TileB`.
  - 10 cửa sổ `Window*`/`WindowFrame*`/`WindowSill*` ở x 178 và 202, cùng `Pilaster*`, `Parapet*`, `ACUnit*`, `ACGrill*`.
  - Biển `SignBoard` + `SignText` "NHÀ ĂN SINH VIÊN" trên cửa chính; `SloganBoard` + `SloganText` "TIẾT KIỆM LƯƠNG THỰC, KHÔNG BỎ PHÍ CƠM".
- **Đồ trong sảnh:**
  - **21 bàn inox liền ghế** `Table_<x10>_<z10>` (x 173,5…206,5, z 22,6…37). Mỗi bàn khoảng 30 node: mặt, chân, 6 ghế đôn, khay, bát, đũa, kèm một `Collision` riêng.
  - Quầy chia cơm `Counter` (178; −9,45; 42,4) với `CounterTop`, `SneezeGlass*`, `FoodPan*`, `Food*`, `Ladle*`, `ServeWindow*`, `ServeWindowDark*`, 5 bảng giá `PriceBoard*` + `PriceText*` ("MÌ 6", "CANH 2", "THỊT 8", "RAU 3"…).
  - Hàng xếp `QueueRail`, `QueuePost*`; chỗ trả khay `TrayReturn` (209,4; −9; 39), `TrayRail`, `ReturnShelf*`, `ReturnSign` "TRẢ KHAY".
  - Bồn rửa tay `SinkBlock` (209,6; −9,5; 23,85) với `Sink*`, `Tap*`, `Mirror*`.
  - `TrayStack*`, `DirtyTray*`, `FloorTray*`, `Spill*`, `Bin*`, `SlopBin*`, `Poster*`, `CardReader`; 3 quạt trần `FanHub*`/`FanBlades*` (đứng yên); đèn tuýp `Tube*`.
- **TV:** `TV` (170,2; −7,5; 32) gồm `Case` và `Screen`, gắn tường tây qua `TVBracket`. `campus.gd.set_canteen_tv()` bật/tắt `Canteen/TV/Screen.visible`; `chapter3_director` bật TV khi người chơi vào vùng nhà ăn (`canteen_tv`, tin tức `ROOM_CH3_TV_NEWS` phát tại `Anchors/CanteenTV` (170,3; −7,5; 32)).
- **Bếp** x 186…198, z 44…52:
  - nền và vỏ: `KitchenFloor`, `KitchenSide186`, `KitchenSide`, `KitchenBack`, `KitchenRoof`;
  - bếp nấu: `Cooktop`, `Hood`, `HoodDuct`, `Chimney`, `Wok*`, `WokHandle*`, `Steamer*`, `RiceCooker*`, `RiceBucket*`, `GasCylinder*`, `OilCan*`;
  - bàn sơ chế và chậu rửa: `PrepTable`, `ChoppingBoard`, `Cleaver`, `KitchenSink`, `SinkTap`, `HangingLadle*`, `Vegetables*`;
  - **đồng hồ bếp `KitchenClock`** (192; −7,4; 51,85; meta `stopped_hour = 4`; kim `Hour`, `Minute` đứng yên), anchor `Anchors/CanteenClock`.
- **Kho** x 198…210, z 44…52: `StoreFloor`, `StoreSide`, hai khối `StoreBack` (chừa cửa sau x ≈ 202, z 52), `Shelf*`, `StoreBox*`, `StoreSack*`, `RiceSack*`. Anchor `Anchors/CanteenExit` (202; −9,9; 52).
- **Lối tây** (`WestExit`, instance `game/scenes/levels/ch4/canteen_west_exit.tscn`): tường tây x 170 gồm `SouthWall`, `NorthWall`, `Lintel` (có va chạm), `Jamb39.5`, `Jamb41.5`, lỗ cửa z 39,5…41,5; navigation `Threshold`, `Outside`, `Inside`. PLAN xếp phần ngoài lối tây và thư viện vào đợt 8. **Đợt này chỉ làm bề mặt tường tây** cho khớp sảnh, vì tường này là mặt tường trong của sảnh. PLAN mục 9 ghi ảnh tĩnh cũ còn vật che ở lỗ, nên phải kiểm ở chương 4 thật.
- **Trong `campus.tscn`:**
  - Anchor: `Anchors/CanteenTV`, `CanteenClock`, `CanteenExit`; `Anchors/BarSpawns/B06` (194; −9,9; 40), thanh sắt trong sảnh; xác sống `Anchors/ZombieSpawns/Canteen/S01…06` và `ZombieIdle/Canteen/I01…06` (x 178…186, z 24…30, giữa các bàn).
  - Đồng đội: `Anchors/Paths/Nhat/P29` (190; 18) → `P30_Wait_canteen` (190; 32) → `P31` (202; 43) → `P32` (202; 48) → `P33` (202; 54), qua kho ra cửa sau. `Paths/Ngu/P20_Wait_canteen…P23` đi cùng đường.
  - Vùng `Zones/Canteen` (tâm (194; −7,9; 36), hộp 48 × 4 × 32).
  - Navigation: `CanteenEntry` (190; 18 → 21), `KitchenEntry` (192; 43), `StoreEntry` (202; 43), `StoreExit` (202; 51).
- **Đồ rải trong `props.tscn` quanh hộp nhà ăn (x 168…212, z 13…56):** khoảng 60 bản MultiMesh. Nhiều nhất là `D_iron_quad_p2_p0` (27), `D_paper_quad_p2_p0` (10), `D_white_quad_p2_p0` (4); còn lại là `P_white_box`, `P_iron_box`, `P_iron_cylinder`, `P_paper_box`, `P_wood_box`. Lane B phân loại: đồ rải, mảnh xác, máu.
- **Code, test, bot đụng tới nhà ăn:**
  - code: `chapter3_director.gd` (`_gate` → vùng `canteen`, TV, đợt xác sống `Canteen`, `_split_companions`), `chapter4_director.gd` (`_split`), `campus.gd` (`set_canteen_tv`);
  - âm thanh và bot: `ch3_environment.gd`, `ch3_music.gd`, `ch3_audio_bank.gd` (vùng `canteen`, reverb `CANTEEN`), `ch3_policy.gd`, `tools/ch3-profile.json` (tuyến tới nhà ăn);
  - test: `test_campus` (vùng, anchor, TV, navigation tới nhà ăn), `test_chapter3` (`test_gate_canteen_and_the_end`), `test_chapter4` (bắt đầu ngoài nhà ăn), `test_stands_props` (navigation `Start_gate → CanteenExit`, hộp `inside_canteen`), `test_t249_chapter3_bar` (B06), `test_t262_gate` (đi sang nhà ăn), `test_ch3_audio`, `test_t260_occlusion`.
- **Hiệu năng:** PLAN mục 6 cho A15 **≤ 0,60 ms** thêm. Phải gom bàn, khay theo cụm vật liệu; tách bếp và kho; không cho mọi vật nhỏ đổ bóng. Rủi ro lớn nhất là số lần vẽ: hiện có 932 mesh node, phần lớn là bàn và khay lặp.

## 1. Chủ dự án chốt
**D-181 (15/11/2026):** chủ dự án xem ảnh lượt 1 (`previews/wave6/options_*.jpg`) và chọn cả bảy câu theo đề xuất (cấu hình c):
1. Bàn ghế: **T1** bàn inox liền 6 ghế đôn tròn.
2. Sàn và tường: **F1** gạch ceramic 40 × 40 kem, tường sơn vàng nhạt, chân tường ốp gạch men trắng 1,4 m.
3. Quầy: **Q1** quầy inox có kính chắn, **bảng giá gỗ sơn đen chữ trắng** (chữ giữ nguyên).
4. Trần: **C2** thạch cao 60 × 60 ố vàng, vài tấm rơi, vài tấm võng; quạt, đèn tuýp, 3 đèn trần giữ chỗ.
5. Bếp: **K1** bếp gạch ốp men, chảo gang, nồi nhôm lớn; đồng hồ dừng 4 giờ, chụp hút chia đôi.
6. Mức bừa: **M2** (bát đổ, khay, đũa rơi nhiều hơn; chỉ là hình, không đổi va chạm).
7. Màn TV khi bật: **giữ ảnh bản tin không chữ** như góc mẫu; giọng `ROOM_CH3_TV_NEWS` giữ nguyên.

**HARU (thay integrator) trả lời các đề nghị trong Handoff lượt 1:**
- Hộp A16 **x 166…218, z 13…60, trừ góc x 166…170, z 37…60** như lane B chốt.
- Lượt 2 được sửa `test_t262_gate.gd`: số bản thu về 0 trong chunk dùng chung với hộp cổng (giữ kiểm tra 180 bản của cổng, thêm phần của hộp nhà ăn). Được đổi hằng `PROPS_KEPT_MD5` trong `test_t261_stadium.gd` lần nữa. Ghi lý do trong comment.
- Occluder hình hộp cho vỏ nhà ăn: việc của core. HARU làm sau khi T-263 merge; lane B không tự thêm.
- Full test và check của lượt 1 (bị dừng vì thiếu RAM) **không cần chạy lại**; lượt 2 chạy đủ cả hai trước commit cuối.

## 2. Việc, theo hai lượt

### Lượt 1 — sửa đầu 6 xác, khảo sát và góc mẫu, rồi DỪNG chờ chủ dự án chọn
0. **Trả đầu 6 xác trong vườn** (lỗi của T-259, lane B phát hiện ở T-262; HARU cho phép). T-259 ẩn cả node `Parts/P_paper_box_p0_p0` (nằm trong `A16_ALL`), trong đó có đầu của 6 xác ở (11,2; 16,9), (29,1; 27,6), (14,3; 37,0), (0,2; 7,6), (16,6; 18,8), (31,1; 30,4), rồi đặt giấy đúng các chỗ đó. Sửa theo cách lane B ghi ở Handoff lượt 2 card T-262:
   - hiện lại node;
   - thu về 0 bảy bản không phải đầu (khay cơm và 6 tờ bảng tin mà T-259 đã thay);
   - bỏ 6 tờ giấy (`build_garden.py` bỏ điều kiện `mode != "all"`, dựng lại glb);
   - sửa `A16_ALL`/`A16_PARTLY` trong `test_t259_garden.gd` và hằng hoặc ngưỡng liên quan trong `test_t261_stadium.gd`, `test_t262_gate.gd` nếu đổi, ghi lý do trong comment.
   - Ảnh trước/sau 2–3 xác (`previews/wave6/heads_*.jpg`).
1. **Khảo sát, ghi Handoff:**
   - Kiểm lại mục 0. Grep mọi chỗ code, test, bot, âm thanh đụng tới nhà ăn (`canteen.tscn`, `Canteen/`, `TV/Screen`, `KitchenClock`, `CanteenTV`, `CanteenClock`, `CanteenExit`, `B06`, `ZombieSpawns/Canteen`, `Zones/Canteen`, `KitchenEntry`, `StoreEntry`, `StoreExit`, `WestExit`, `Start_split`).
   - Lập **bảng hợp đồng**: node nào giữ tên, vị trí, va chạm.
   - **Đi thử tuyến cổng → nhà ăn → bếp → kho → cửa sau**, và đường chương 4 từ `Start_split` qua lối tây (đường đồng đội, xác sống, bot; dùng thân người chơi thật).
   - **Chốt hộp dải A16 quanh nhà ăn.** Gợi ý: sân trước cửa chính z 13…20, hai bên hông, sân sau cửa kho tới khoảng z 60; không lấn hộp T-262 (z < 13) và đường đợt 8 tây lối tây. Liệt kê chính xác đường dẫn node A16 trong hộp.
2. **Góc mẫu** gồm:
   - một góc sảnh: một mảng sàn, tường có cửa sổ, trần có đèn tuýp và quạt, 2–3 bàn liền ghế có khay và bát, một đoạn quầy chia cơm có kính chắn và bảng giá;
   - TV trên tường tây (bật và tắt);
   - một góc bếp có đồng hồ;
   - mặt tiền cửa chính có biển.

   Dựng bằng Blender, chất lượng ngang các đợt trước. Kèm **phương án để chủ dự án chọn bằng mắt**: ảnh cùng camera, chương 3 thật, ban đêm, có và không đèn pin, TV bật và tắt, có vài xác sống đứng ở `ZombieIdle/Canteen` nếu chụp được.
   - **Bàn ghế:** bàn inox liền ghế đôn tròn như hiện nay, hoặc bàn mặt đá, ghế nhựa đỏ/xanh rời (ghế rời chỉ là hình; va chạm vẫn theo khối bàn cũ).
   - **Sàn và tường:** gạch ceramic 40 × 40 kem có vết bẩn với tường sơn vàng nhạt và ốp gạch men chân tường, hoặc sàn đá mài với tường sơn xanh nhạt.
   - **Quầy chia cơm:** quầy inox có kính chắn, hoặc quầy xây ốp gạch men trắng; bảng giá giữ đúng chữ hiện có (bảng gỗ sơn đen chữ trắng, hoặc bảng in).
   - **Trần:** trần tôn lộ xà gồ thép, hoặc trần thạch cao tấm 60 × 60 ố vàng; quạt trần và đèn tuýp giữ chỗ.
   - **Bếp:** bếp gạch ốp men có chảo gang và nồi nhôm lớn, hoặc bếp inox công nghiệp.
   - **Mức bừa** sau khi bỏ chạy: như hiện nay (khay bát trên bàn, vài khay rơi, vệt đổ), hoặc bừa hơn (ghế đổ, khay vương nhiều hơn). **Không đổi va chạm.**

   Mỗi phương án ghi số tam giác, vật liệu, số lần vẽ. Đề xuất một phương án.
3. Commit, push nhánh, ghi Handoff, **báo và dừng**. HARU chuyển phương án cho chủ dự án, ghi lựa chọn vào mục 1.

### Lượt 2 — làm cả khu (sau khi chủ dự án chọn; chủ dự án dán prompt "tiếp tục")
4. **Nhà ăn (A15):**
   - vỏ sảnh trong và ngoài (tường, cửa sổ, trụ, tường chắn mái, mái hiên, bậc, biển, máy lạnh), sàn, trần, đèn tuýp, quạt;
   - cả 21 bàn, quầy chia cơm và bảng giá, hàng xếp, chỗ trả khay, bồn rửa tay và gương, đồ rải trong sảnh;
   - TV (giữ `TV/Screen` bật/tắt được);
   - bếp (bếp nấu, chụp hút, chảo, nồi, bình gas, bàn sơ chế, chậu, đồng hồ dừng như cũ);
   - kho (kệ, thùng, bao gạo, cửa sau);
   - bề mặt tường tây của `WestExit` (hai mặt, khung lỗ cửa).
5. **Dải A16 quanh nhà ăn** (chỉ trong hộp đã chốt ở bước 1). Khớp mép dải T-262 ở z 13.
6. Ảnh trước/sau, ảnh ghép, test, full test, check, Handoff.

## 3. Phạm vi A16 trong đợt này
- **Chỉ** mặt đất, đường, viền, rãnh, đồ rải **trong hộp lane B chốt ở bước 1**. Không đụng phần đã làm ở T-259, T-261, T-262 trừ đường khớp mép.
- **Không** đụng nhà nền, cây xa (đợt 7), đường sang thư viện ngoài lối tây và thư viện (đợt 8). Không thay MultiMesh nhẹ bằng hàng nghìn node.
- Mảnh xác tĩnh, máu, vệt kéo sẫm, thùng rác: không đụng. Riêng việc trả đầu xác ở bước 0 là ngoại lệ.

## 4. Hợp đồng gameplay (bắt buộc giữ)
- Không đổi tên, gốc, transform của các node có va chạm và các node code dùng:
  - trong `canteen.tscn`: `Canteen` (gốc), `Floor`, `KitchenFloor`, `StoreFloor` (và meta), `Roof`, mọi `StaticBody3D` (`Front*`, `Side`, `Back`, `Kitchen*`, `Store*`, `Counter`, `TrayReturn`, `SinkBlock`, `PrepTable`, `Cooktop`, `KitchenSink`, `Table_*/Collision`), `TV`, `TV/Screen`, `KitchenClock` (meta `stopped_hour`);
  - trong `canteen_west_exit.tscn`: `WestExit` (va chạm `SouthWall`, `NorthWall`, `Lintel`, navigation `Threshold`, `Outside`, `Inside`);
  - trong `campus.tscn`: `Anchors/CanteenTV`, `CanteenClock`, `CanteenExit`, `BarSpawns/B06`, `ZombieSpawns/Canteen/*`, `ZombieIdle/Canteen/*`, `Paths/*/P*_Wait_canteen` và các điểm sau, `Zones/Canteen`, navigation.
- **Va chạm giữ nguyên:** test so dấu vân tay với main như T-259, T-261, T-262; bàn, quầy, tường, cửa, bếp, kho, đồ rải. Ghế rời (nếu chọn) chỉ là hình.
- **TV, đồng hồ, cửa giữ như cũ:**
  - TV bật/tắt bằng `Screen.visible`, nhìn thấy từ cửa chính và từ giữa sảnh như bản PS1;
  - đồng hồ bếp vẫn dừng đúng giờ cũ;
  - lỗ cửa chính, bếp, kho, cửa sau, lối tây không hẹp hơn.
- Tuyến đồng đội, xác sống, bot (toạ độ `tools/ch3-profile.json`) không bị đồ mới chặn; người chơi không kẹt; thanh sắt B06 vẫn cúi nhặt được (`test_t249`).
- Hình PS1 chỉ ẩn (`visible = false` hoặc thu instance MultiMesh về 0 như T-261, T-262), không xoá.
- Không đổi luật, lời thoại, director, âm thanh, vùng reverb, ánh sáng. Giữ 3 đèn `CeilingLight` như cũ, không thêm đèn. Chữ trên biển, bảng giá, khẩu hiệu giữ đúng nội dung.

## 5. Kỹ thuật và hiệu năng
- **Dựng bằng script Blender** (Blender 5.2.2 portable ở `D:\Tools\Blender\5.2.2`).
  - Được dùng texture, mesh **CC0** (Poly Haven, ambientCG…) nếu ghi URL, tác giả, giấy phép trong CREDITS.
  - **Không cài extension/addon Blender, không Tripo, không ảnh AI.**
  - Chữ vẽ bằng font có sẵn trong game (Be Vietnam Pro, OFL), hoặc giữ `Label3D` cũ nếu hợp.
- Dùng lại bộ vật liệu đã duyệt khi hợp: trát vôi, bê tông, thép mạ kẽm, inox, gạch men của đợt 1–5.
- Ngân sách (PLAN mục 6): **≤ 0,60 ms** thêm.
  - Ghi số tam giác, vật liệu, số lần vẽ cho góc mẫu và cả khu, **ở góc nhìn rộng nhất**: từ cửa chính nhìn sảnh, từ quầy nhìn ra cửa.
  - **Bàn, ghế, khay, bát lặp phải gộp** (MultiMesh hoặc lưới gộp theo cụm), không để mỗi bàn vài chục lần vẽ.
  - Bếp và kho dùng `visibility_range` hoặc bản xa khi nhìn từ sảnh.
  - Vật nhỏ không đổ bóng.
- **Mọi texture mới từ 512 px trở lên phải nén VRAM:** `.import` đặt `compress/mode=2`, normal thêm `compress/normal_map=1`. Ghi bộ nhớ hình chương 3 trước/sau.
- Occlusion culling (D-174) đã bật. Vỏ nhà ăn kín có thể thêm occluder hình hộp, nhưng occluder thuộc cảnh core (`game/scenes/main/occlusion/`): **không tự thêm**, ghi vào "Yêu cầu thay đổi" nếu thấy đáng.
- Không đo FPS, không chạy bot (D-179).

## 6. Ảnh
- Thư mục `art_source/graphics_upgrade/realistic_map/previews/wave6/`:
  - bước 0: `heads_*`;
  - lượt 1: `pilot_*` và bảng phương án;
  - lượt 2: `before_*`/`after_*` cùng camera trong **chương 3 thật**: từ cửa chính nhìn sảnh, TV bật và tắt, quầy chia cơm, giữa các bàn (có xác sống nếu chụp được), bếp và đồng hồ, kho và cửa sau, mặt tiền từ sân, dải A16; thêm 1–2 góc **chương 4** ở lối tây (`Start_split`); ảnh ghép tổng `overview.jpg`.
- Ban đêm như chương, có và không đèn pin.

## 7. Kiểm
- Test mới `game/tests/levels/test_t263_*.gd`:
  - dấu vân tay va chạm nhà ăn, bếp, kho, bàn, `WestExit`, đồ rải trùng main; node, anchor, vùng, navigation giữ nguyên; hình PS1 ẩn;
  - `Canteen/TV/Screen` bật/tắt được; `KitchenClock` còn meta `stopped_hour`;
  - capsule đi được từ cửa chính tới `P30_Wait_canteen`, qua `KitchenEntry`, `StoreEntry` ra `CanteenExit`, và từ `Start_split` vào lối tây;
  - **mọi `.import` texture trong thư mục asset đợt 6 có `compress/mode=2`** (normal có `compress/normal_map=1`); glb chỉ dùng vật liệu chung;
  - dải A16 nằm trong hộp đã chốt và chỉ ẩn đồ PS1 trong hộp;
  - bước 0: 6 đầu xác vườn hiện lại, không còn tờ giấy đè lên.
- Test cũ đạt: `test_campus`, `test_chapter3`, `test_chapter4`, `test_ch3_*`, `test_stands_props`, `test_t249_chapter3_bar`, `test_t259*`, `test_t261*`, `test_t262*`, `test_graphics_bindings`, `test_t260_occlusion`. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## 8. Được phép sửa
- Thư mục đợt 6:
  - `art_source/graphics_upgrade/realistic_map/wave6/` và `.../previews/wave6/`;
  - `game/assets/models/graphics_pilot/realistic_map/wave6/`;
  - `game/assets/textures/graphics_pilot/realistic_map/wave6/`;
  - `game/assets/models/graphics_pilot/realistic_map/CREDITS.md` (thêm mục `wave6/`).
- Cảnh và script:
  - `game/scenes/levels/campus/canteen.tscn`;
  - `game/scenes/levels/ch4/canteen_west_exit.tscn`, chỉ hình (ẩn hình PS1, thêm hình mới);
  - `campus.tscn`: phần hình A16 trong mục 3 và node lớp thật mới;
  - `props.tscn`: chỉ đồ rải trong hộp, trừ mảnh xác, máu, vệt kéo, thùng rác; và bước 0;
  - script cảnh mới trong `game/scenes/levels/campus/`.
- Cho bước 0:
  - `art_source/graphics_upgrade/realistic_map/wave3/` (`build_garden.py`) và glb đợt 3 liên quan;
  - `test_t259_garden.gd`, `test_t261_stadium.gd`, `test_t262_gate.gd`: chỉ hằng và ngưỡng do trả đầu xác, có comment. Lượt 2 (D-181): thêm phần đếm bản thu về 0 của hộp nhà ăn trong `test_t262_gate.gd` và hằng `test_t261_stadium.gd`.
- Test mới trong `game/tests/levels/`; card này (Checklist, Handoff).
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `campus.gd`, `scenes/entity/` (lane A), `chapter*.tscn`, occluder core.
- Sửa vườn (T-259), sân vận động (T-261), cổng (T-262) ngoài đường khớp mép và bước 0; thư viện; khu ngoài mục 3.
- Tripo, credit Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [x] Lượt 1, bước 0: trả đầu 6 xác trong vườn, ảnh trước/sau
- [x] Lượt 1: khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp và danh sách node A16 (Handoff)
- [x] Lượt 1: góc mẫu và phương án (bàn ghế, sàn và tường, quầy, trần, bếp, mức bừa), ảnh TV bật/tắt; dừng chờ chủ dự án chọn
- [x] Lượt 2: sảnh, quầy, TV, bếp, kho, tường tây
- [x] Lượt 2: dải A16 quanh nhà ăn
- [x] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
### Lượt 2 (15/11/2026, D-181): xong cả khu
Card đọc ở `origin/main` `d27337c` (D-181). Nhánh rebase lên `d27337c` (không xung đột), đẩy lại bằng `--force-with-lease`.
Cách chạy lại, số liệu đầy đủ: `art_source/graphics_upgrade/realistic_map/wave6/README.md` mục "Lượt 2".

**Đã làm (theo D-181: T1, F1, Q1 + bảng gỗ sơn đen, C2, K1, M2, TV ảnh bản tin không chữ):**
- `canteen.tscn`: 940 hình và nhãn PS1 ẩn (`visible = false`; va chạm, node, transform, meta, 3 đèn, chữ của nhãn giữ
  nguyên). Node mới `Real` (`canteen_real.gd`) gồm 17 lớp: vỏ sảnh, cửa sổ, trần C2, đèn tuýp và quạt, bàn T1, khay bát
  M2, quầy Q1, bảng giá gỗ, TV, phòng bếp, bếp K1, đồng hồ, mặt tiền và lượt 2: phía đông sảnh, kho, mặt ngoài, xe đạp.
  - Phía đông: máng rửa tay ốp gạch trên `SinkBlock` (4 chậu, vòi, gương), kệ trả khay inox trên `TrayReturn`, biển "TRẢ KHAY"
    (giữ chữ), 2 thùng thức ăn thừa.
  - 4 tranh cổ động không chữ, 3 máy lạnh treo tường, ngưỡng cửa.
  - Kho: sàn, tường, trần, khung cửa sau với cửa cuốn cuộn lên (hộp cửa từ 2,5 m), 2 kệ thép, thùng carton, can dầu, bao gạo.
  - Mặt ngoài tường tây, đông, sau (sơn vôi vàng như mặt tiền, chân tường, gờ, trụ), mái và tường chắn mái, máng xối, bồn nước
    inox, ống khói, ống thoát nước, cục nóng máy lạnh, bình gas trong lồng sắt, thùng rác, quạt hút bếp, hộp điện.
  - 6 xe đạp đúng chỗ PS1.
- TV: màn sáng `TV/Screen/Lit` treo dưới `TV/Screen`, nên `campus.gd.set_canteen_tv` vẫn bật/tắt như cũ.
- Đồng hồ bếp vẫn dừng 4 giờ (meta `stopped_hour = 4`, kim mới ở 4:00).
- `canteen_west_exit.tscn`: 5 hình PS1 ẩn (va chạm, navigation giữ). Hai mặt tường tây và khung cửa mới; cánh cửa thép mở áp
  tường phía bắc lỗ. **Vật che lỗ mà PLAN mục 9 ghi đã hết:**
  - đó là dải ốp gạch PS1 `TileW` chạy ngang qua lỗ cửa, và áp phích `Poster3` treo trong lỗ;
  - đã kiểm ở chương 4 thật (`after_ch4_split*`).
- `campus.tscn`: node `StripCanteen` (dải A16 trong hộp đã chốt). Gồm sân trước lát gạch "con sâu" nối lối của T-262 ở z 13,
  hè bê tông và rãnh có nắp dọc tường tây, sau, đông, sân bê tông sau bếp và kho, cỏ mòn, viền.
- `props.tscn`: đúng 18 bản thu về 0 (10 giấy, 4 dép, 2 mảnh ba lô, 2 khay), thay bằng đồ mới đúng chỗ. Hai tờ giấy PS1 nằm
  trên sàn kho, tờ mới cũng đặt trên sàn kho. Vệt kéo sẫm, ki-ốt, máy bán nước, xe đạp, xe máy giữ.
- Bỏ glb, vật liệu, texture của các phương án không chọn. Test góc mẫu thay bằng `test_t263_canteen.gd`.

**Kiểm (hợp đồng):** `test_t263_canteen.gd`, 10 bài:
- Vân tay node, va chạm, đèn, chữ nhãn, `WestExit` của nhà ăn trùng main (`7da3acc4…`, 1.757 dòng, đo trên cảnh main trước
  khi vá). Va chạm campus, anchor, vùng, navigation, va chạm props trùng hằng của T-262/T-259.
- Hình PS1 ẩn đủ 945; TV bật/tắt; đồng hồ 4 giờ.
- Bàn, ghế, bếp, máng rửa, kệ trả khay, kệ kho, bao gạo nằm trên khối va chạm cũ hoặc đúng chỗ PS1; đồ ngoài nhà sát tường.
- Không lỗ cửa nào hẹp hơn (cửa chính, lối tây, cửa kho, lỗ bếp, cửa sau).
- Dải nằm trong hộp, không lấn góc đợt 8, không vào trong nhà.
- 18 bản thu về 0 đều trong hộp.
- Thân người chơi thật đi: P29 → P30 → kho → cửa sau (P33); vào bếp tới trước đồng hồ; ra lối tây; từ `Start_split` vào lối tây.
- Texture nén VRAM, glb chỉ dùng vật liệu chung.

Test cũ sửa theo phép HARU (có comment):
- `test_t262_gate.gd`: vẫn kiểm đúng 180 bản trong hộp cổng, thêm đếm 16 bản của hộp nhà ăn trong 3 chunk chung.
- `test_t261_stadium.gd`: `PROPS_KEPT_MD5` → `8a531ad2…` (2.099 dòng = 2.117 − 18).

**Ảnh:** `art_source/graphics_upgrade/realistic_map/previews/wave6/`:
- `before_*`/`after_*`: 62 ảnh, cùng camera, chương 3 thật ban đêm, có và không đèn pin, TV tắt/bật, 6 xác sống ở
  `ZombieIdle/Canteen`; thêm 3 góc chương 4 ở lối tây.
- `overview.jpg`: 20 cặp trước/sau.

**Số liệu:** toàn bộ glb đợt 6: 94.630 tam giác (PS1 19.380).
- Số lần vẽ giảm ở gần mọi góc: từ cửa chính 1.656 → 1.277, mặt tiền 1.976 → 1.160, giữa các bàn 1.443 → 850, cửa sau từ sân
  1.604 → 759, chương 4 lối tây 1.014 → 258.
- Bếp, kho gần như cũ (843 → 847, 801 → 829).
- Primitive tăng 50–90 nghìn ở góc rộng.
- Bộ nhớ hình chương 3: 1.307 → 1.307–1.309 MB.
- Không đo FPS (D-179).

**Yêu cầu thay đổi:** không có mới. Occluder hộp cho vỏ nhà ăn: HARU đã nhận làm sau khi merge. Các góc nhìn về phía tây
trong sảnh và từ trong nhìn ra lối tây vẫn vẽ cả khuôn viên sau tường (4.300–5.000 lần vẽ, bản PS1 cũng vậy).

**Full test, check:**
- `pwsh tools/test.ps1` (22:15 15/11, sau commit `9efb2a2`): **`RESULT: 1037 passed, 0 failed`**.
- `pwsh tools/check.ps1` (chạy lại 22:42 15/11 khi máy đủ RAM, cùng commit; lần đầu bị Claude Code dừng vì thiếu RAM):
  **`RESULT: check 0 error(s)`**. Sau đó `git checkout -- game/default_bus_layout.tres`.
- Khoá Lượt Godot của lần chạy bị dừng đã xoá; `game/_probe_tmp/` đã xoá.
- Test lọc: `-Filter t263` 12/0, `t262` 9/0, `t261` 12/0.

### Lượt 1 (15/11/2026): xong, DỪNG chờ chủ dự án chọn
Card đọc ở `origin/main` `12b7415`. Nhánh `lane-b/T-263-realistic-graphics-wave6-canteen`. Cách chạy lại, bảng tam giác,
vật liệu, số lần vẽ: `art_source/graphics_upgrade/realistic_map/wave6/README.md`.

**Bước 0 — đầu 6 xác trong vườn: đã trả.** `props.tscn` `Parts/P_paper_box_p0_p0` hiện lại; 7 bản T-259 đã thay (khay
#0, 6 tờ bảng tin #4…9) thu cỡ về 0, giữ mục; 6 đầu (#1…3, #10…12) giữ ma trận main (`wave6/patch_canteen.py heads`).
`wave3/build_garden.py` bỏ điều kiện `mode != "all"`; `wave3/strip_props.glb` dựng lại: 54 mẩu giấy, so từng đỉnh với bản
cũ chỉ mất đúng 6 tờ ở 6 chỗ đầu, các lưới khác (gạch vỡ, ống, bảng tin, tờ bảng tin) trùng hết. Test cũ sửa theo (có
comment): `test_t259_garden.gd` chuyển `P_paper_box_p0_p0` từ `A16_ALL` sang `A16_PARTLY`; `test_t261_stadium.gd`
`PROPS_KEPT_MD5` → `d5c2dcb8…` (2.117 dòng: bớt 7 bản thu về 0, dòng "visible" của chunk thành true). `test_t262` không đổi.
Test mới `test_t263_garden_heads.gd` (6 đầu đủ cỡ đúng chỗ main, 7 bản về 0, không tờ giấy nào phủ lên đầu).
Ảnh `previews/wave6/heads_<1..6>_<before|after>[_torch].jpg`, bảng `heads.jpg`.

**Khảo sát (kiểm lại mục 0 của card: khớp).** `wave6/survey_canteen.gd` → `survey/canteen_nodes.tsv` (1.758 node: vị trí,
mesh, AABB, vật liệu, va chạm, meta), `survey/campus_canteen.tsv`. Thêm so với mục 0: `Bike0…5` (x 172…181, z 17,2) nằm
trong `canteen.tscn`; cửa sổ PS1 là tấm kính dán ngoài tường liền (không lỗ); bếp hở 12 m sang sảnh (x 186…198, không có
tường), lỗ cửa kho x 201…203; cửa chính là khe x 186…194 cao hết tường; trụ PS1 (mỗi 5 m) đè lên cửa sổ (mỗi 3 m); hộp
chụp hút PS1 che gần hết `KitchenClock` khi nhìn từ sảnh.
Chỗ đụng tới nhà ăn: `campus.gd` (`set_canteen_tv`: `Canteen/TV/Screen.visible`); `chapter3_director.gd` (`_gate` chờ vùng
`canteen`, `_scare(&"canteen_tv")`, TV, `ROOM_CH3_TV_NEWS` tại `Anchors/CanteenTV`, `_spawn(&"Canteen")`, `_split_companions`
đi tiếp từ `P*_Wait_canteen`); `chapter4_director.gd` (`_arrive_at("Ch4/Start_split")`); âm thanh `ch3_environment.gd`,
`ch3_music.gd`, `ch3_audio_bank.gd` (vùng `canteen`, reverb `CANTEEN`); bot `ch3_policy.gd`, `tools/ch3-profile.json`
(tuyến `gate`: P28 → P29 → P30_Wait_canteen; tuyến hiệu năng tới `ZombieSpawns/Canteen/S01`); test `test_campus`,
`test_chapter3::test_gate_canteen_and_the_end`, `test_chapter4`, `test_ch4_environment` (đường từ (172; 40,5) tới
`Start_split`), `test_stands_props` (đường `Start_gate → CanteenExit`, hộp `inside_canteen`), `test_t249_chapter3_bar` và
`test_ch2_4_hand_targets` (B06), `test_t262_gate` (đi tới `P30_Wait_canteen`), `test_ch3_audio`.

**Bảng hợp đồng (giữ tên, vị trí, va chạm; lượt 2 test so dấu vân tay với main):**
| Cảnh | Node | Vị trí / cỡ |
|---|---|---|
| `canteen.tscn` | `Canteen` (gốc, transform 0); `Floor` (meta `surface=tile`, `is_floor`) | (190; −10; 32), 40 × 0,2 × 24 |
| | `KitchenFloor`, `StoreFloor` (cùng meta) | (192 / 204; −10; 48), 12 × 0,2 × 8 |
| | `Roof` | (190; −5,3; 32), 41 × 0,3 × 25 |
| | `Front178`, `Front202` | z 20, x 170…186 / 194…210, cao −9,9…−5,3 |
| | `Side210`; `Back178`, `Back199.5`, `Back206.5` | x 210; z 44 (x 170…186, 198…201, 203…210) |
| | `KitchenSide186`, `KitchenSide198`, `KitchenBack` | x 186 / 198 (z 44…52), z 52 |
| | `StoreSide`, `StoreBack199`, `StoreBack207` | x 210 (z 44…52); z 52 (x 198…200, 204…210) |
| | `Counter`, `TrayReturn`, `SinkBlock` | (178; −9,45; 42,4) 15 × 0,9 × 1; (209,4; −9; 39) 1 × 1,8 × 3; (209,6; −9,5; 23,85) 0,6 × 0,8 × 4,6 |
| | `Cooktop`, `PrepTable`, `KitchenSink` | (192; −9,45; 51,2) 8 × 0,9 × 1,1; (188,9; −9,45; 46,6) 1 × 0,9 × 4,4; (187,2; −9,45; 49,3) 1,2 × 0,9 × 0,9 |
| | `Table_*/Collision` (21) | 2,6 × 0,9 × 2 ở (x; −9,45; z) của bàn; 3 bàn xoay (`1735_370` 9°, `1835_270` 5°, `1965_325` −7°) |
| | `TV`, `TV/Screen` (tắt sẵn), `KitchenClock` (meta `stopped_hour = 4`) | (170,2; −7,5; 32), (170,29; −7,5; 32), (192; −7,4; 51,85) |
| | `CeilingLight25/33/40` | OmniLight e 1,1, tầm 19, màu a3b08a, không bóng (giữ, không thêm đèn) |
| `canteen_west_exit.tscn` | `WestExit`: `SouthWall`, `NorthWall`, `Lintel`; `Threshold`, `Outside`, `Inside` | x 170: z 20…39,5 / 41,5…44; lanh tô −7,5…−5,3; lỗ z 39,5…41,5 |
| `campus.tscn` | `Anchors/CanteenTV`, `CanteenClock`, `CanteenExit`, `BarSpawns/B06` | (170,3; −7,5; 32), (192; −7,4; 51,85), (202; −9,9; 52), (194; −9,9; 40) |
| | `ZombieSpawns/Canteen/S01…06`, `ZombieIdle/Canteen/I01…06` | x 178/182/186, z 24/29 và 25/30 |
| | `Paths/Nhat/P29…P33`, `Paths/Ngu/P19…P23` | (190; 18) → (190; 32) chờ → (202; 43) → (202; 48) → (202; 54) |
| | `Zones/Canteen`; `Navigation/CanteenEntry`, `KitchenEntry`, `StoreEntry`, `StoreExit`; `Ch4/Start_split` | (194; −7,9; 36) 48 × 4 × 32; (190; 18 → 21), (192; 43 → 45), (202; 43 → 45), (202; 51 → 54); (167; −9,9; 40,5) |

**Đi thử (`wave6/walk_canteen.gd`, campus thật, thân người chơi thật `move_and_slide`): mọi tuyến tới đích.** Đồng đội
Nhất P28 → P33 và Ngư P18 → P23 (cửa chính, sảnh, kho, cửa sau); tuyến bot `Start_gate → P28 → P29 → P30`; vòng bếp tới
trước đồng hồ (192; 49,6) và quanh bàn sơ chế; vòng kho ra cửa sau tới z 57; các lối giữa dãy bàn; trước quầy tới chỗ trả
khay; chương 4 `Start_split` → lối tây → trong sảnh → ra lại, vòng phía tây ra trước cửa chính, sân sau về `Start_split`.
Navmesh: `Start_gate → P30` 20 m, `P30 → CanteenExit` 28 m (qua `StoreEntry`), `P30 →` trước đồng hồ (qua `KitchenEntry`),
cả 6 điểm sinh và 6 điểm đứng → P30 và → `CanteenExit`, `Start_split → P30` qua lối tây: đều thông. `Start_split →
Start_library` không thông trên navmesh của riêng campus (thư viện không nằm trong cảnh thử; như main, không thuộc đợt này).
Tia nhìn: mắt ở cửa chính → TV và giữa sảnh → TV thông. Ba đoạn "STUCK" trong log là đường thẳng tôi cố ý kẻ xuyên qua
bàn và ki-ốt, không phải tuyến. Chân người chơi trong khu: x 166…220, z 8…57.

**Hộp A16 chốt: x 166…218, z 13…60, trừ góc x 166…170, z 37…60** (phần ngoài lối tây, đường sang thư viện: đợt 8). Sân
trước nối mép T-262 ở z 13 (lối lát T-262 x 186…217, z 7…13 hướng cửa chính), hai bên hông, sân sau tới z 60.
Danh sách đủ: `wave6/a16_box_nodes.json` (`list_a16_box.py`). Mặt đất: `Ground/Tile_170_-10`, `Ground/Tile_170_40` (giữ,
cỏ mới nằm trên 1 cm như đợt 3–5). Thay ở lượt 2 (18 bản, thu về 0): `Decals/D_paper_quad_p2_p0` #0…4, #20…25 (giấy),
`Decals/D_white_quad_p2_p0` #0, 1, 5, 6 (dép), `Parts/P_white_box_p4_p0` #3, 4 (ba lô), `Parts/P_paper_box_p5_p1` #0 và
`Parts/P_white_box_p5_p1` #0 (khay). Giữ: 27 vệt kéo sẫm `D_iron_quad_p2_p0` #6…32 (kéo vào bếp và kho), ki-ốt
(214; 17), máy bán nước (182,2; 16), xe đạp đổ (208,4; 17), xe máy sau kho (207,6; 54,6), va chạm `Solids` của chúng.
Đồ ngoài tường thuộc `canteen.tscn` (A15, lượt 2 cùng nhà ăn): `Bike0…5`, `Bin205`, `Bin206.2`, `GasCylinder0/1`,
`ACUnit*`, `Chimney`.

**Góc mẫu và phương án.** 21 glb trong `game/assets/models/graphics_pilot/realistic_map/wave6/`, 15 texture trong
`game/assets/textures/.../wave6/` (đều `compress/mode=2`, normal có `normal_map=1`), vật liệu `W6*`. Chưa scene nào dùng:
`capture_wave6.gd` gắn vào chương 3 thật lúc chạy, ẩn 838 node hình PS1 (va chạm, node, meta giữ), màn sáng treo dưới
`Canteen/TV/Screen` (bật/tắt bằng `set_canteen_tv` như cũ), 6 xác sống đứng ở `ZombieIdle/Canteen`. Góc mẫu làm cả sảnh
(vỏ, cửa sổ thật, trần, 20 đèn tuýp, 3 quạt, 21 bàn, quầy, bảng giá, TV), cả bếp và mặt tiền; phía đông sảnh (bồn rửa,
trả khay), kho, áp phích, mặt ngoài tường bên/sau còn PS1.
Ảnh: `art_source/graphics_upgrade/realistic_map/previews/wave6/`: `options_tables.jpg`, `options_floor_walls.jpg`,
`options_counter.jpg`, `options_ceiling.jpg`, `options_kitchen.jpg`, `options_mess.jpg`, `options_tv.jpg` (TV tắt/bật),
`options_facade.jpg`; ảnh đơn `pilot_<before|a|b|c|d>_<góc>[_tv][_torch].jpg`.
| Mục | Phương án | Tam giác | Vật liệu |
|---|---|---|---|
| Bàn ghế | **T1** bàn inox liền 6 ghế đôn (như PS1) / T2 mặt đá + 126 ghế nhựa rời | 23.100 / 24.360 | 3 / 4 |
| Sàn và tường | **F1** ceramic 40 × 40 kem, tường vàng nhạt, ốp gạch men trắng 1,4 m / F2 đá mài, tường xanh nhạt, chân tường sơn dầu xanh | vỏ 2.138 (chung) | 3 đổi chỗ |
| Quầy | **Q1** inox + kính chắn / Q2 xây ốp gạch men trắng; bảng giá **gỗ sơn đen chữ trắng** / bảng in | 3.996 / 3.876; bảng 130 | 4 / 6; 2 |
| Trần | **C2** tấm 60 × 60 ố vàng (6 tấm rơi, 2 võng) / C1 tôn lộ xà gồ, kèo thép | 516 / 820 | 3 / 3 |
| Bếp | **K1** bếp gạch ốp men cháy khói, chảo gang, nồi nhôm / K2 bếp inox công nghiệp | 1.752 / 1.964 | 8 / 4 |
| Mức bừa | M1 như PS1 / **M2** bừa hơn (bát đổ, khay, đũa, mảnh bát rơi ở lối đi; với T2 thêm ghế đổ) | 22.504 / 27.034 | 2 / 2 |
Chung: cửa sổ 5.721 (4 vật liệu), đèn quạt 2.644, TV 108, phòng bếp 2.828, đồng hồ 190, mặt tiền 522. Cả góc mẫu
cấu hình a 66.149 tam giác, b 72.335 (PS1 19.380). Số lần vẽ giảm ở mọi góc (từ cửa chính 1.656 → 1.295; từ quầy nhìn
ra cửa 1.122 → 693; giữa các bàn 1.246 → 724; trần 617 → 254; mặt tiền 1.976 → 1.213); primitive tăng 50–80 nghìn ở góc
rộng (cửa chính 83 k → 143 k). Bộ nhớ hình chương 3 1.307 → 1.309…1.310 MB khi nạp cả hai bộ. Không đo FPS (D-179).

**Đề xuất: T1, F1, Q1 + bảng gỗ sơn đen, C2, K1, M2 (ảnh cấu hình c, và a cho các góc c không chụp).** T1 khớp khối va
chạm bàn liền ghế và là kiểu bàn nhà ăn sinh viên quen thuộc; F1 sáng, xác sống nổi rõ trên nền; Q1 là quầy chia cơm phổ
biến; bảng gỗ viết tay hợp "cũ vừa phải"; C2 hợp mái bằng có tường chắn mái nhìn từ ngoài, ít tam giác; K1 có khói ám, đúng
bếp tập thể; M2 cho thấy cảnh bỏ chạy mà không đổi va chạm (với T1 ghế liền nên không có ghế đổ).

**Câu hỏi cho chủ dự án:**
1. Chọn từng mục: bàn ghế (T1/T2), sàn và tường (F1/F2), quầy (Q1/Q2), bảng giá (gỗ sơn đen/in), trần (C2/C1), bếp (K1/K2),
   mức bừa (M1/M2). Có thể trộn.
2. Màn TV khi bật: bản tin không chữ (đề xuất, vì lời đọc `ROOM_CH3_TV_NEWS` đã kể tin) hay muốn khác (nhiễu sóng, màn
   xanh, có dòng chữ khẩn cấp — chữ mới là nội dung cốt truyện)?
3. Đồng ý hộp A16 x 166…218, z 13…60 (trừ góc tây bắc của đợt 8)?

**Yêu cầu thay đổi (integrator):**
- Lượt 2 sẽ thu về 0 các bản giấy/dép trong `D_paper_quad_p2_p0`, `D_white_quad_p2_p0` ở hộp nhà ăn; hai chunk này (cùng
  `D_iron_quad_p2_p0`) nằm trong `CHUNKS` của `test_t262_gate.gd`, test đó đòi mọi bản thu về 0 trong các chunk nằm trong
  hộp cổng và tổng đúng 180. Xin cho phép sửa `test_t262_gate.gd` ở lượt 2 (chỉ đếm/kiểm các bản trong hộp cổng), comment lý
  do. `test_t261` (`PROPS_KEPT_MD5`) cũng sẽ phải đổi lần nữa vì các bản này nằm ngoài hộp T-261.
- Occluder: các góc nhìn về phía tây trong sảnh (TV, lối tây, bếp nhìn chéo) vẽ cả khuôn viên sau tường (4.300–5.200 lần vẽ,
  PS1 cũng vậy). Đề nghị integrator cân nhắc một occluder hộp cho vỏ nhà ăn trong `game/scenes/main/occlusion/` (card mục 5).

**Kiểm:** `-Filter t263` 8 passed (heads 2, pilot 6); `-Filter t259` 11, `t261` 12, `t262` 9 passed (sau khi sửa hằng ở
bước 0). **Full `pwsh tools/test.ps1` chưa có kết quả:** lần chạy lúc 19:28 15/11 bị Claude Code dừng vì máy thiếu RAM (khoảng
3 GB trống), không phải test lỗi; theo hướng dẫn, không tự chạy lại. **`pwsh tools/check.ps1` chưa chạy** (bước 0 có đổi
`props.tscn`, nên cần chạy). Cần chạy lại cả hai khi máy rảnh RAM (đóng bớt ứng dụng), rồi `git checkout --
game/default_bus_layout.tres`. Khoá Lượt Godot của lần chạy bị dừng đã xoá; `game/_probe_tmp/` đã xoá.

## Review (HARU thay integrator, 16/11/2026)
**Đạt, merge `4031339`** (nhánh lane B `1c8a98e`; gốc nhánh là main `d27337c` nên cây sau merge trùng hệt cây lane B đã kiểm).
- **Phạm vi:** 309 file, tất cả trong phạm vi lane B và mục 8. Code duy nhất là `canteen_real.gd` mới: chạy một lần khi nạp
  cảnh, đặt tầm vẽ (bàn 60 m, khay bát và kho 40 m, bếp và phía đông 45 m, xe đạp và đồ rải 80 m) và tắt bóng đồ nhỏ, phẳng.
- **Cảnh:**
  - `canteen.tscn`: không xoá dòng nào. 940 node PS1 chỉ thêm `visible = false` (932 hình, 8 `Label3D`); thêm lớp `Real`
    (17 glb) và `TV/Screen/Lit`. 3 đèn, va chạm, meta giữ nguyên.
  - 8 nhãn chữ ẩn nhưng chữ vẽ lại vào texture đúng nội dung (HARU xem ảnh): "NHÀ ĂN SINH VIÊN", khẩu hiệu "TIẾT KIỆM
    LƯƠNG THỰC, KHÔNG BỎ PHÍ CƠM", bảng giá CƠM 5 / RAU 3 / THỊT 8 / CANH 2 / MÌ 6, "TRẢ KHAY".
  - `canteen_west_exit.tscn`: 5 hình PS1 ẩn, va chạm và navigation giữ.
  - `campus.tscn`: thêm `StripCanteen`. `props.tscn`: chỉ đổi dữ liệu MultiMesh, 18 bản trong hộp x 166…218, z 13…60 thu
    về 0 (HARU kiểm toạ độ), cộng 7 bản của bước 0 trả đầu 6 xác vườn.
- **Test cũ sửa theo phép HARU (D-181), có comment:** `test_t262_gate` vẫn đòi đúng 180 bản trong hộp cổng, phần còn lại phải
  nằm trong hộp nhà ăn (16); `test_t261` hằng `PROPS_KEPT_MD5` 2.099 bản; `test_t259` chuyển `P_paper_box_p0_p0` sang
  `A16_PARTLY` (bước 0).
- **`test_t263_canteen` (10 bài):** vân tay node, va chạm, đèn, chữ nhãn, `WestExit` trùng main; PS1 ẩn đủ 945; TV bật/tắt,
  đồng hồ 4 giờ; đồ mới trên khối va chạm cũ; không lỗ cửa nào hẹp; dải trong hộp; thân người chơi đi P29 → kho → cửa sau,
  vào bếp, ra lối tây, từ `Start_split` vào lối tây. `test_t263_garden_heads` (2 bài).
- **Ảnh** (`previews/wave6/`, HARU xem quầy, sảnh từ cửa có TV bật, mặt tiền, góc lối tây): đúng D-181.
- **Số liệu:** cả đợt 94.630 tam giác; số lần vẽ giảm ở gần mọi góc (cửa chính 1.656 → 1.277, lối tây chương 4 1.014 → 258),
  bếp, kho gần như cũ; bộ nhớ hình chương 3 gần như không đổi.
- **Kiểm:** trên nhánh (cùng cây với main sau merge) lane B chạy full test **`RESULT: 1037 passed, 0 failed`** và check
  **`RESULT: check 0 error(s)`**. Lần kiểm sau merge của HARU (16/11 23:22) bị Claude Code dừng vì máy thiếu RAM trước khi chạy
  test nào; **chủ dự án quyết không chạy lại** (16/11) vì cây trùng hệt.
- **Việc tiếp theo của core:** occluder hộp cho vỏ nhà ăn trong `game/scenes/main/occlusion/` (D-181, lane B đề nghị ở lượt 1).
- Không đo FPS, không chạy bot (D-179).
