# T-256 — Tầng 4 lượt 3–4 (phần còn lại): nhà vệ sinh chung, đồ ở hành lang, rà cửa thoát hiểm, trường quay CCTV hành lang
- Lane: B | Trạng thái: **todo, giao sau khi [T-255](T-255-floor4-rooms-like-407.md) merge** (cùng sửa `corridor.tscn`, làm nối tiếp để khỏi xung đột) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1l).
- Nhánh: `lane-b/T-256-floor4-washroom-corridor-props` từ `origin/main` mới nhất (đã có T-255).
- Quyết định: **D-170** (xem mục 1). Nền: D-166 (dựng Blender theo chất lượng phòng 407, không ưng thì chủ dự án đổi Tripo; ánh sáng giữ như nay; CCTV cảnh thật, giữ góc và độ rõ), D-167 (phong cách nhà B đã duyệt).
- Khảo sát: integrator, 13/11/2026 (đọc scene, script, ảnh `realistic_map/previews/survey/`, ảnh T-250, T-254; chưa chụp ảnh mới vì lane B đang giữ khoá Godot).

## 0. "Lượt 3–4" của kế hoạch hành lang còn lại gì
Kế hoạch gốc: `art_source/graphics_upgrade/floor4_corridor/PLAN.md` mục 7 (lượt 3: bàn trực, nhà vệ sinh chung, đồ phơi; lượt 4: cầu thang, review tích hợp, CCTV). Mã khu: `realistic_map/PLAN.md` (A01–A30).

| Hạng mục | Mã | Hiện trạng 13/11 | Ở card này |
|---|---|---|---|
| Bàn trực tầng 4 | A01 | **Xong** (T-250, D-167) | Không |
| Cầu thang chính, thoát hiểm, cửa thoát hiểm | A06, A07 | **Xong** (T-250); lan can mép chiếu nghỉ tầng 4 **xong** (T-254) | Chỉ rà cửa mở sát lan can (phần C) |
| Phòng 401–406, 408 | A03 | Lane B đang làm (T-255), chưa merge | Không |
| **Nhà vệ sinh chung** | A02 | **PS1 toàn bộ** (1.794 tam giác, 21 vật liệu): hộp sàn, tường, trần màu trơn; 3 cửa buồng `stall_front.glb` vân ô vuông; 3 bồn và vòi PS1; gương là tấm xám phẳng; máng đèn hộp. Riêng tường lối vào phía hành lang đã là vỏ G5 | **Phần A** |
| **Đồ ở hành lang** | A04 | **PS1**: dây phơi, 5 món vải (`hanging_cloth.gd`, có đung đưa), 3 xô (`Bucket_11/19/35`, có va chạm), 4 đôi dép `Slippers_0…3` (đang ẩn) | **Phần B** |
| **Cửa thoát hiểm mở chồng lan can** | A07 | Lỗi ghi ở T-237 (cánh PS1 một tấm 3,8 m dày 12 cm, nằm z 3,84…3,96, đè lan can z 3,99). T-250 đã thay bằng hai cánh thép dày 4,5 cm: cánh chính bản lề ở z 3,9, mở ra nằm z ≈ 3,88…3,92, cách song lan can khoảng 5 cm. **Theo số đo thì hết chồng; tay gạt mặt ngoài (nhô khoảng 6 cm) có thể chạm song.** Chưa có ảnh cận | **Phần C** (rà, sửa nếu còn) |
| **CCTV hành lang tầng 4** | A29 | **PS1** (432 tam giác): hộp kín 10 × 4 m, **tường ngoài xây kín** (hành lang thật là lan can mở), 3 cửa 405/406/407 cách nhau 3,2 m (thật: 4 m), số phòng `Label3D`, một đèn. Feed 320 × 240 trên điện thoại chương 1–2 | **Phần D** |
| Cảnh ngoài nhìn từ tầng 4, chương 1–2 | A05 | **PS1**: 4 "cây" là hộp đen, 1 đèn đường xa không có cột. Chương 3–4 ẩn chúng, thấy vườn hoa thật của khuôn viên | Không (D-170: chờ đợt 3 vườn hoa) |
| CCTV các phòng 102, 306, 209, 106, 310 | A24–A28 | PS1 (2.468–4.464 tam giác mỗi phòng) | Không (không thuộc tầng 4; card riêng sau, dùng bộ đồ phòng T-253/T-255) |

Thấy thêm khi khảo sát (lane B xác minh, ghi Handoff):
1. Ảnh `previews/wave1/after_ch3_a07_4_door_open_torch.jpg`: trên lỗ cửa thoát hiểm còn **một hộp xanh lá trơn** (có vẻ biển "EXIT" PS1) và góc trên bên phải còn **một mảng cột vân ô vuông PS1**. Tìm node sở hữu; thuộc phạm vi lane B thì thay (biển thoát hiểm kiểu hộp đèn xanh "LỐI THOÁT", tối, không thêm đèn), do core dựng thì ghi "Yêu cầu thay đổi".
2. Gương nhà vệ sinh chung (`mirror.tscn`, T-135) ở chương 1–4 không ai gán `follow` nên chỉ là tấm xám. Bản demo cũ `main.tscn` (chỉ test dùng) gán `follow = $Player` và có cảnh đuổi từ gương (`story_director.gd`): **giữ node `Washroom/Mirror`, vị trí và script**.
3. Nhà vệ sinh chung **không có sự kiện nào ở chương 1–4** (chỉ bản demo cũ dùng vòi nước và gương). Người chơi ghé vào là để khám.

## 1. Chủ dự án đã chốt (D-170, 13/11/2026)
- **Buồng vệ sinh:** ba buồng **có bên trong** (bệ xổm, vòi, xô, gáo…), **cửa khép hờ** mỗi buồng một góc để nhìn vào được. **Không tương tác**, không đổi va chạm (hộp `StallDoor_*` vẫn chặn ở mặt cửa): cánh mở **vào trong**, khe hở hẹp hơn vai người để chỗ bị chặn trông hợp lý. Nếu thấy cần đổi va chạm cho tự nhiên thì ghi "Yêu cầu thay đổi", không tự đổi.
- **Chỗ rửa:** **máng rửa dài xây ốp gạch men, ba vòi** (kiểu ký túc xá cũ), không dùng bồn sứ chân đứng. Ba hộp va chạm `Sink_*` và vị trí ba vòi giữ nguyên; máng phủ kín ba hộp (khe giữa các hộp 0,38 m, người không lọt).
- **Gương:** **phản chiếu thật** như gương phòng 407 (D-105: `mirror.tscn` với `rendering/mirror_surface_hd.gdshader`, chỉ vẽ khi đang nhìn vào; xem `room407.gd` `_hang_mirror`, `_update_mirror_follow`), **mép ố mốc**, có vết bẩn. Thấy thân Trần Trung trong gương ở chương có thân. Phần gán `follow` ở chương 1–4 nếu phải sửa ngoài phạm vi lane B thì ghi "Yêu cầu thay đổi" (integrator làm); bản demo cũ `main.tscn` vẫn chạy như cũ.
- **Đồ ở hành lang:** thay đồ cũ bằng đồ thật và **thêm vừa phải** trước mỗi phòng (dép, chổi, cây lau nhà, chậu, móc áo, thùng rác…), mỗi phòng một khác; sát tường hoặc sát lan can, lối đi trống (mục 3).
- **CCTV hành lang tầng 4:** **dựng lại trường quay** bằng bộ hành lang thật (lan can mở), giữ camera; không đổi code truyện, không đổi nội dung người chơi thấy (mục 5).
- **Cảnh ngoài chương 1–2 (4 hộp đen, đèn đường):** **không làm ở card này**; chờ đợt 3 (vườn hoa) xong rồi đặt bản nhẹ của chính vườn đó.

## 2. Phần A — Nhà vệ sinh chung (`game/scenes/levels/floor4/washroom.tscn`)
Phòng 6 × 5 m (x 0…6, z −5…0), cao 3 m, lối vào rộng 1,2 m cao 2,3 m ở x 2,4…3,6.

**Làm:**
- Vỏ: tường ốp gạch men tới khoảng 1,8 m, trên trát sơn (kem như hành lang), trần trát có mốc, sàn gạch chống trơn hơi dốc về ga thoát sàn, ngưỡng cửa. Dùng shader vỏ phòng 407 (`rendering/room407_shell.gdshader`) với **bản đồ bẩn vẽ riêng cho phòng này** (ố vàng dưới vòi, mốc góc trần, vệt nước chân tường, lối mòn từ cửa vào). Gạch: dùng lại bộ gạch nhà tắm 407 hoặc Anti Skid Tiles (CC0, đã có trong `texture_sources.json`), đổi màu, khổ gạch để **không giống nhà tắm riêng của 407**.
- Ba buồng (x 1, 3, 5; mặt cửa z −3,55; vách x 0, 2, 4): vách xây ốp gạch hoặc tấm, cửa buồng, bản lề, chốt; bên trong theo mục 1.
- Chỗ rửa cạnh tường tây (x ≈ 0,36; z −0,85 / −1,85 / −2,85): theo mục 1; ba vòi ở đúng chỗ ba `Tap_*`, ống nước lộ trên tường, ống thoát.
- Gương trên tường tây (tâm (0,145; 1,62; −1,85)): theo mục 1.
- Máng đèn tuýp thay hộp `WashroomLight/Fixture` (kiểu máng hành lang G5; bóng sáng theo đèn như `TubeSync`). Quạt thông gió hoặc ô thoáng trên tường sau, móc treo, xô, chậu, cây lau nhà, bảng nội quy nhỏ ở chỗ `Anchors/WashroomNotice` (không chữ đọc được mới; giấy đọc được do core dán).
- `Washroom/Details` (`room407/washroom_details.tscn`, đồ PS1 của T-153: xà phòng, khăn…): thay bằng đồ thật tương ứng hoặc ẩn; không xoá node.

**Giữ nguyên (hợp đồng):**
- Mọi `StaticBody3D` và hình va chạm: `Floor` (meta `surface = tile`, `is_floor`), bốn tường, `Ceiling`, `Entrance*`, `StallDoor_0…2` (1,94 × 2,2 × 0,08), `StallPartition_0…2`, `Sink_0…2` (0,52 × 0,86 × 0,62). Hình mới nằm trong hoặc sát các hộp này; hình PS1 chỉ ẩn (`visible = false`), không xoá.
- `Tap_0…2`, `TapWater` (0,282; 0,985; −2,85), `Mirror` (node, vị trí, hướng), `WashroomLight` (vị trí, năng lượng 1,2, màu, tầm 5 m, không bóng), `LightHum`, `WaterDrips`, `ReverbZone`, `AmbientZone`.
- `Floor4/Anchors/WashroomTapRunning`, `WashroomMirror`, `WashroomNotice`.
- Tường lối vào phía hành lang là của vỏ G5 (`corridor_shell.gd` đã ẩn `Washroom/Entrance*`): mặt trong phải khớp mép, không chồng mặt, không nhấp nháy.
- Chương 3–4: nhà vệ sinh nằm trong nhà B của khuôn viên, sát cầu thang chính (x −5…0) và phòng 401 mới của T-255 (x 6…10): không lấn, không hở nhìn từ ngoài.

## 3. Phần B — Đồ ở hành lang (`game/scenes/levels/floor4/corridor.tscn`)
- Dây phơi (`Clothesline`, y 2,15, z 3,87): dây thật có độ võng nhẹ, móc vào cột hoặc trần; 5 món vải `HangingCloth_0…4` (x 17, 20, 23, 27, 30) thay bằng áo, quần, khăn thật (dùng lại hoặc dựng theo quần áo phòng 407 và đồ phơi ban công T-255), **vẫn đung đưa** (`hanging_cloth.gd` hoặc cách tương đương, không đổi script core). Giữ `Anchors/ClotheslineExtraShirt` (25,5; 1,76; 3,87).
- 3 xô `Bucket_11/19/35` (z 0,35, có va chạm): thay hình bằng xô 407 (`room407_batch1/bucket.glb`) bản nhẹ, đổi màu; giữ va chạm.
- Dép `Slippers_0…3` (x 30,5…31,55, z 0,35, đang ẩn): tìm lý do ẩn (có thể vì đã có dép Tripo ở `Anchors/Slippers407`); không bật lại nếu trùng.
- Đồ thêm theo mục 1.
- **Lối đi phải trống:** capsule bán kính 0,3 m cao 1,75 m đi thẳng x 0,4…43,6 tại z 3 (`test_wide_corridors`); tuyến quản lý chương 1 (z 2, rẽ vào cửa 407 ở x 32); tuyến xác sống, đồng đội chương 3; vùng cánh cửa các phòng mở ra hành lang (+90°, T-255: mở bằng tay) và hai cánh cửa thoát hiểm. Đồ mới chỉ đặt sát tường phòng (z ≤ 0,5) giữa các cửa hoặc sát lan can (z ≥ 3,6), không đặt trong 1,2 m trước mỗi cửa.
- Đồ nhỏ không cần va chạm; đồ từ cỡ xô trở lên có va chạm (D-135).

## 4. Phần C — Cửa thoát hiểm mở sát lan can (`campus/building_b.tscn` → `FireDoor`)
- Chụp cận trong chương 3 khi cửa mở: cánh chính (`FireDoor/Leaf`, bản lề z 3,9) so với lan can G5 (z 3,99) và gờ chân lan can; cánh phụ `LeafB` so với tường và khung cửa 408.
- Còn chồng hình (tay gạt, ổ khoá, bản lề chạm song hoặc gờ) thì sửa **chỉ phần hình**: ví dụ dời bản lề hình vào trong vài cm, hoặc cho cánh dừng ở góc nhỏ hơn 90° trong `door.gd` (script của lane B; `Leaf` giữ va chạm và trạng thái như cũ). Không đổi `Use_FireDoor`, blocker, trục va chạm.
- Không chồng thì ghi "không cần sửa" kèm ảnh.
- Thấy thêm 1 (hộp xanh trên cửa, mảng cột PS1) làm ở phần này.

## 5. Phần D — Trường quay CCTV hành lang (`game/scenes/levels/cctv/cctv_set.tscn` → `Corridor`)
D-170: dựng lại trường quay.
- Dùng module hành lang G5 (tường trát, sàn gạch, trần, khung cửa xanh, cánh Tripo, biển số nhôm, máng đèn, **lan can mở** thay tường ngoài) rút gọn cho đoạn 405–407; khoảng cách cửa theo hành lang thật nếu không làm đổi thứ camera thấy (ba cửa, cửa 407 nhận ra được).
- Giữ `Corridor/Cam` (vị trí, hướng, FOV 75, far 30), `Tube` (đèn), tên node `Door405/406/407`, mọi va chạm, vị trí set (dưới Y = −60 khi director nạp). `test_cctv`, `test_wide_corridors` (dùng `Corridor/Cam`) phải đạt.
- Feed chỉ 320 × 240: mô hình nhẹ, không texture mới; không tăng độ phân giải feed.
- Ngoài lan can của set là khoảng tối (không dựng cảnh ngoài).

## 6. Cách làm, ảnh
1. **Mẫu trước:** phần A một góc (chỗ rửa, gương, một buồng), chụp cùng camera với `previews/survey/03_washroom_entry.jpg`, `04_washroom_sinks.jpg`; tự xem rồi làm rộng.
2. Script Blender trong `art_source/graphics_upgrade/realistic_map/floor4_rest/`, glb trong `game/assets/models/graphics_pilot/realistic_map/floor4_rest/`, README và CREDITS (nguồn vật liệu CC0, đồ Tripo dùng lại ghi theo D-084).
3. Ảnh 1080p trong **chương 1 và chương 3 thật** (director giữ, ánh sáng của chương, có và không đèn pin), trước/sau cùng camera: `art_source/graphics_upgrade/realistic_map/previews/floor4_rest/`; một ảnh ghép tổng cho chủ dự án. Ảnh "trước" có sẵn: `previews/survey/03`, `04`, `07`, `08`, `cctv_corridor_1`, `cctv_corridor_2`.
4. **Nặng máy:** các phòng T-255 đã nặng (mỗi phòng 300–500 nghìn tam giác; chương 3 từng hết bộ nhớ hình, phải nén texture). Card này **không thêm texture 2K mới**: dùng lại texture đã có, bản đồ bẩn ≤ 1K, nén VRAM. Mục tiêu tam giác: nhà vệ sinh ≤ 30 nghìn, đồ hành lang thêm ≤ 25 nghìn cả hành lang, trường quay CCTV ≤ 15 nghìn. Không đèn mới, không bóng mới. Ngân sách khung (PLAN mục 6): A02 ≤ 0,35 ms, A04 ≤ 0,2 ms. Ghi số tam giác, vật liệu thật.
5. Không đo FPS, không chạy bot (integrator đo sau merge nếu chủ dự án cho).

## 7. Kiểm
- Test mới `game/tests/levels/test_t256_*.gd`: dấu vân tay mọi va chạm của `washroom.tscn`, của đồ hành lang cũ và của `cctv_set.tscn/Corridor` **trùng main** (như test T-250, T-253); node, anchor cũ đúng chỗ; hình PS1 đã thay thì ẩn, không xoá; capsule đi hết lối z 3 và vào được nhà vệ sinh tới trước từng buồng, từng vòi; đồ mới không nằm trong vùng cấm ở mục 3; cửa thoát hiểm mở không chạm lan can (nếu có sửa).
- Test cũ đạt: `test_floor4*`, `test_corridor_g5*`, `test_wide_corridors`, `test_props`, `test_mirror`, `test_cctv`, `test_story_segments_3_5`, `test_chapter1`…`test_chapter4`, `test_t250_*`, `test_t254_*`, test của T-255. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## 8. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/floor4_rest/`, `.../previews/floor4_rest/`, `game/assets/models/graphics_pilot/realistic_map/floor4_rest/`, `game/assets/textures/` (chỉ bản đồ bẩn mới), `game/scenes/levels/floor4/washroom.tscn`, `game/scenes/levels/floor4/corridor.tscn` (chỉ đồ rời phần B), `game/scenes/levels/floor4/corridor_shell.gd` (nếu cần treo đồ như vỏ G5), `game/scenes/levels/room407/washroom_details.tscn`, `game/scenes/levels/cctv/cctv_set.tscn` (chỉ node `Corridor`), `game/scenes/levels/campus/building_b.tscn` và `campus/door.gd` (chỉ phần C), script cảnh mới trong `game/scenes/levels/floor4/`, test mới, card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 9. Không được
- Đổi, thêm, xoá va chạm (trừ va chạm cho đồ mới cỡ xô trở lên ở phần B), navmesh, anchor, luật, director, script trong `game/scripts/`; đổi ánh sáng, âm thanh.
- Sửa phòng 407, các phòng T-255, bàn trực, cầu thang; sửa các phòng CCTV 102, 306, 209, 106, 310.
- Tripo, credit Tripo; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Phần A nhà vệ sinh chung, ảnh trước/sau chương 1 và 3
- [ ] Phần B đồ hành lang, lối đi trống
- [ ] Phần C cửa thoát hiểm và lan can (ảnh; sửa nếu còn chồng), Thấy thêm 1
- [ ] Phần D trường quay CCTV hành lang
- [ ] Test mới, test cũ, full test, check
- [ ] README, CREDITS, ảnh ghép, Handoff

## Handoff
(lane B điền)
