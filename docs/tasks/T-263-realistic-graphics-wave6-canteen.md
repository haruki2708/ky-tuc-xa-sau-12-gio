# T-263 — Đồ hoạ thật đợt 6: nhà ăn, bếp, kho (và trả đầu 6 xác trong vườn)
- Lane: B | Trạng thái: todo (giao 15/11/2026) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1q).
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
(HARU ghi sau lượt 1)

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
  - `test_t259_garden.gd`, `test_t261_stadium.gd`, `test_t262_gate.gd`: chỉ hằng và ngưỡng do trả đầu xác, có comment.
- Test mới trong `game/tests/levels/`; card này (Checklist, Handoff).
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi va chạm, navmesh, anchor, vùng, ánh sáng, âm thanh, luật, director (`game/scripts/core/`), `campus.gd`, `scenes/entity/` (lane A), `chapter*.tscn`, occluder core.
- Sửa vườn (T-259), sân vận động (T-261), cổng (T-262) ngoài đường khớp mép và bước 0; thư viện; khu ngoài mục 3.
- Tripo, credit Tripo, extension Blender, ảnh AI; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Lượt 1, bước 0: trả đầu 6 xác trong vườn, ảnh trước/sau
- [ ] Lượt 1: khảo sát, bảng hợp đồng, đi thử tuyến, chốt hộp và danh sách node A16 (Handoff)
- [ ] Lượt 1: góc mẫu và phương án (bàn ghế, sàn và tường, quầy, trần, bếp, mức bừa), ảnh TV bật/tắt; dừng chờ chủ dự án chọn
- [ ] Lượt 2: sảnh, quầy, TV, bếp, kho, tường tây
- [ ] Lượt 2: dải A16 quanh nhà ăn
- [ ] Ảnh trước/sau, test mới, test cũ, full test, check, README, CREDITS, Handoff

## Handoff
(lane B ghi)
