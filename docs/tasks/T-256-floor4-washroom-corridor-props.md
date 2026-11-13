# T-256 — Tầng 4 lượt 3–4 (phần còn lại): nhà vệ sinh chung, đồ ở hành lang, rà cửa thoát hiểm, trường quay CCTV hành lang
- Lane: B | Trạng thái: **merged 14/11/2026** (lane B full test 984/0 trên đúng cây mã đã merge; integrator chạy lại check 0 lỗi, `test_t256` 9/9); chưa chơi thử; lỗi tường giếng thang ở chương 3–4 tách sang [T-258](T-258-main-stairs-wall-over-washroom.md) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1l).
- Nhánh: `lane-b/T-256-floor4-washroom-corridor-props` từ `origin/main` mới nhất (đã có T-255).
- Quyết định: **D-170** (xem mục 1). Nền: D-166 (dựng Blender theo chất lượng phòng 407, không ưng thì chủ dự án đổi Tripo; ánh sáng giữ như nay; CCTV cảnh thật, giữ góc và độ rõ), D-167 (phong cách nhà B đã duyệt).
- Khảo sát: integrator, 13/11/2026 (đọc scene, script, ảnh `realistic_map/previews/survey/`, ảnh T-250, T-254; đo và chụp cửa thoát hiểm trong chương 3 thật, phần C).

## 0. "Lượt 3–4" của kế hoạch hành lang còn lại gì
Kế hoạch gốc: `art_source/graphics_upgrade/floor4_corridor/PLAN.md` mục 7 (lượt 3: bàn trực, nhà vệ sinh chung, đồ phơi; lượt 4: cầu thang, review tích hợp, CCTV). Mã khu: `realistic_map/PLAN.md` (A01–A30).

| Hạng mục | Mã | Hiện trạng 13/11 | Ở card này |
|---|---|---|---|
| Bàn trực tầng 4 | A01 | **Xong** (T-250, D-167) | Không |
| Cầu thang chính, thoát hiểm, cửa thoát hiểm | A06, A07 | **Xong** (T-250); lan can mép chiếu nghỉ tầng 4 **xong** (T-254) | Chỉ rà cửa mở sát lan can (phần C) |
| Phòng 401–406, 408 | A03 | Lane B đang làm (T-255), chưa merge | Không |
| **Nhà vệ sinh chung** | A02 | **PS1 toàn bộ** (1.794 tam giác, 21 vật liệu): hộp sàn, tường, trần màu trơn; 3 cửa buồng `stall_front.glb` vân ô vuông; 3 bồn và vòi PS1; gương là tấm xám phẳng; máng đèn hộp. Riêng tường lối vào phía hành lang đã là vỏ G5 | **Phần A** |
| **Đồ ở hành lang** | A04 | **PS1**: dây phơi, 5 món vải (`hanging_cloth.gd`, có đung đưa), 3 xô (`Bucket_11/19/35`, có va chạm), 4 đôi dép `Slippers_0…3` (đang ẩn) | **Phần B** |
| **Cửa thoát hiểm mở chồng lan can** | A07 | Lỗi ghi ở T-237 (cánh PS1 một tấm 3,8 m dày 12 cm, nằm z 3,84…3,96, đè lan can z 3,99). T-250 đã thay bằng hai cánh thép dày 4,5 cm: cánh chính bản lề ở z 3,9, mở ra nằm z ≈ 3,88…3,92, cách song lan can khoảng 5 cm. **Đã đo 13/11: tấm cánh hết chồng; chỉ còn tay gạt mặt ngoài đâm vào tay vịn lan can khoảng 2 cm** | **Phần C** (sửa tay gạt) |
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
**Integrator đã đo và chụp trong chương 3 thật, main `de24a94` (13/11 21:23; ảnh `realistic_map/previews/floor4_rest/before_ch3_firedoor_*.jpg`):**

| Khi cửa mở | x | y | z |
|---|---|---|---|
| Tấm cánh chính `Leaf/Model` | 42,06…44,01 | 0,01…2,39 | 3,875…3,940 |
| Ổ khoá `Leaf/Lock` | 42,11…42,15 | 0,92…1,17 | 3,865…3,935 |
| **Tay gạt `Leaf/Handle`** | 42,10…42,27 | **1,024…1,076** | 3,813…**3,987** |
| Cánh phụ `LeafB` | 42,18…44,01 | 0,01…2,39 | 0,100…0,166 |
| Lan can G5: tay vịn ống | cả hành lang | **1,045…1,095** | **3,965**…4,015 |
| Lan can G5: song đứng | cách 12,5 cm | 0,20…1,05 | 3,982…3,998 |
| Khung cửa 408 | 41,55…42,44 | | −0,14…0,09 |

- **Tấm cánh và ổ khoá không còn chồng lan can** (cách tay vịn 2,5 cm, cách song 4 cm); cánh phụ không chạm tường và cửa 408.
- **Còn một chỗ: tay gạt mặt ngoài của cánh chính đâm vào tay vịn lan can khoảng 2 cm** (cùng độ cao 1,05 m; ảnh `before_ch3_firedoor_1_handle_in_handrail_torch.jpg`).
- Sửa **chỉ phần hình**, chọn cách ít đổi nhất, ví dụ: cho cánh chính dừng ở khoảng 86–87° trong `door.gd` (script của lane B; cánh phụ vẫn 90°), hoặc dời trục bản lề hình vào trong 3 cm. `Leaf` giữ va chạm và trạng thái như cũ; không đổi `Use_FireDoor`, blocker, trục va chạm, `FireDoorLink`. Tay gạt và ổ khoá vẫn nằm trong hộp `Use_FireDoor` khi cửa đóng (test T-250).
- Thấy thêm 1 làm ở phần này: hộp xanh lá trên cửa (ảnh `..._2_ps1_sign_torch.jpg`) và cột vân ô vuông PS1 ở đầu đông, phía lan can, từ khoảng y 2,4 tới trần (ảnh `..._3_ps1_column_torch.jpg`).

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
- [x] Phần A nhà vệ sinh chung, ảnh trước/sau chương 1 và 3
- [x] Phần B đồ hành lang, lối đi trống
- [x] Phần C tay gạt cửa thoát hiểm không đâm tay vịn lan can (ảnh trước/sau), Thấy thêm 1
- [x] Phần D trường quay CCTV hành lang
- [x] Test mới, test cũ, full test, check (check sau rebase bị dừng vì thiếu RAM, chưa chạy hết; xem Handoff)
- [x] README, CREDITS, ảnh ghép, Handoff

## Handoff

### 13–14/11/2026 — lane B (Claude, Opus 5.5)
Nhánh `lane-b/T-256-floor4-washroom-corridor-props` từ `origin/main` `8aad1c3` (đã có T-255), cuối phiên rebase lên `69f2488` (đã có T-257 nén VRAM, không trùng file nào). Commit card đã đọc: `7e12f86`. Lúc mở phiên không có thay đổi dở. Commit sau rebase: `7ddba25` (phần A), `e430fe7` (B, C, D), `f01458d` (ảnh, sửa sau ảnh), `10a26f5` (gương theo `test_mirror`), `9d97d8c` (biển thoát hiểm treo dưới khung, theo `test_t253`), commit cuối (Handoff).

**Đã làm (nguồn `art_source/graphics_upgrade/realistic_map/floor4_rest/`, README ở đó):**
- **A, nhà vệ sinh chung** (`washroom.glb`, 11.208 tam giác, 28 vật liệu; script cảnh `game/scenes/levels/floor4/washroom_real.gd` gắn ở gốc `washroom.tscn`):
  - Tường ốp gạch men xanh nhạt tới 1,8 m, khổ gạch nhỏ hơn nhà tắm 407; trên trát kem. Trần trát có mốc. Sàn gạch chống trơn dốc 1,2 cm về ga thoát. Dùng shader vỏ 407 với mask 1K vẽ riêng: ố vàng dưới vòi, ướt quanh máng và trước buồng, mốc góc trần, lối mòn từ cửa.
  - Ba buồng xây ốp gạch: bệ xổm trên bậc, vòi thấp trên ống thả từ đường ống dọc tường sau, xô, gáo, thùng rác nhỏ. Cánh cửa sơn xanh khép hờ **vào trong** 24°, 31°, 19°: khe hẹp hơn vai người, không tương tác.
  - Máng rửa dài xây ốp gạch, phủ kín ba hộp `Sink_*`: ba vòi tường đúng chỗ ba `Tap_*` (miệng vòi tại `TapWater`), ống cấp lộ dưới gương, ống đứng ở góc tường trước lên đường ống chạy trên gương và dọc tường sau tới vòi các buồng, ống thoát ra ga, xà phòng, ca nhựa.
  - **Gương phản chiếu thật như 407**: mặt HD (lọc mịn, ánh kính), đi theo người chơi cầm camera; có thân Trần Trung thì ẩn hình thế PS1. Khung nhôm mới; mép tráng bạc bong và đốm nước nằm trên lớp riêng, gương không tự phản chiếu nó.
  - Kính giữ 2,8 × 0,95 m, viewport 560 × 190, và gương vẫn vẽ khi người chơi ở trong phòng trước kính (không chỉ khi đang nhìn vào như 407), vì `test_mirror` kiểm đúng các số và cách vẽ này.
  - Bảng tin (khung nhôm, nền bần) đặt ngay sau mép nam của kính, tâm z −3,39, lệch 14 cm khỏi `Anchors/WashroomNotice` (z −3,25: anchor rơi đúng mép kính). Giấy đọc được ở anchor chỉ bản demo cũ `main.gd` dán, các chương 1–4 không dán.
  - Máng đèn tuýp thay hộp `WashroomLight/Fixture`, ống sáng theo đèn. Ô thoáng gạch bông, móc, khăn, xô và cây lau, chậu.
  - Gán `follow` cho gương làm được trong script cảnh lane B (như `room407.gd`), không cần core. Demo `main.tscn` gán `follow = $Player` vẫn như cũ.
  - Hình PS1 chỉ ẩn (kể cả `Details`, `Tap_*`, `Mirror/Frame`). Va chạm, đèn, âm thanh, vùng, anchor giữ nguyên.
- **B, đồ hành lang** (`corridor_props.glb` 8.834 + `cloths.glb` 372 tam giác; node `RealProps` với `corridor_props.gd` ở cuối `corridor.tscn`):
  - Dây phơi thật võng 3 cm giữa các móc trần. Quần áo thật (áo trên mắc, khăn vắt, quần) gắn vào `HangingCloth_0…4` nên **vẫn đung đưa**. `Anchors/ClotheslineExtraShirt` để trống: bản demo cũ treo áo riêng ở đó.
  - Ba xô cũ đổi hình, giữ va chạm.
  - Mỗi phòng một khác:
    - nhà vệ sinh: xô lau và chổi;
    - 401: kệ giày;
    - 402: ghế nhựa và chậu, dép;
    - 403: giày thể thao và bóng;
    - 404: bao đàn;
    - 405: thùng carton dọn đi, túi rác;
    - 406: can nước 20 l, thùng mì, dép;
    - 407: ô;
    - 408 cũ: chổi, hót rác.
  - Sát lan can: chậu ngâm đồ, xô, ghế nhựa.
  - Đồ cỡ xô trở lên có hộp va chạm (D-135). Tất cả sát tường (z ≤ 0,62) hoặc sát lan can (z ≥ 3,32), cách mỗi cửa 0,9 m sang hai bên trong vùng 1,3 m trước cửa.
  - Dép `Slippers_0…3` vẫn ẩn như trước: đã có dép Tripo ở `Anchors/Slippers407` (story_director dùng anchor đó), bật lại sẽ trùng.
- **C, cửa thoát hiểm** (`building_b.tscn`, chỉ `FireDoor`):
  - Không đổi góc mở hay trục bản lề, vì test T-250 (phải đạt) kiểm `Leaf` đúng 90°, kiểm vị trí `Leaf`, và kiểm ổ khoá, tay gạt bám cứng theo cánh. Cách ít đổi nhất là dùng tay gạt bản gọn `fire_door_handle_compact.glb`: cần gạt phía hành lang trên cổ ngắn, thanh gạt cách mặt cánh 3,1 cm (đợt 1: khoảng 5,6 cm). Node `Handle`, vị trí, va chạm như cũ.
  - Khi mở, tay gạt dừng cách tay vịn khoảng 3 mm (trước: lấn khoảng 2 cm) và cách song đứng khoảng 2 cm.
  - Thấy thêm 1: hộp xanh trơn trên cửa là hộp `W1ExitSign` của khung cửa đợt 1. Hộp đèn mới `FireDoor/Frame/ExitSign` "LỐI THOÁT / EXIT" (tắt, không thêm đèn) bọc kín hộp cũ, không phải sửa khung. Node treo dưới `FireDoor/Frame` (khung đứng ở gốc `FireDoor`): lần full test đầu, đặt thẳng dưới `FireDoor` làm `test_t253` báo lệch dấu vân tay node của main (2219 dòng thay vì 2216). Dưới khung thì nó thuộc nhóm model treo thêm mà test đó bỏ qua, như model đợt 1–2.
  - Thấy thêm 1, cột ô vuông PS1: là hộp `FireStairs/FrontRail` của giếng thang thoát hiểm (x 43,9…49,1, z 4,025…4,175, tới 2,75 m) cùng khối đợt 1 phía trên. Che bằng một trụ trát màu hành lang (`EndCover` trong `exit_sign.glb`, x 43,84…44,06, z 3,95…4,18, y 2,38…3,05), không sửa giếng thang.
- **D, trường quay CCTV hành lang** (`cctv_corridor.glb`, 2.526 tam giác; `cctv_set.tscn` thêm `Corridor/RealSet`):
  - Tường trát, sàn gạch, len, trần, khung cửa xanh, cửa panô sơn (nhẹ hơn lá Tripo 5.057 tam giác mỗi cái, feed chỉ 320 × 240), biển nhôm sau số `Label3D` cũ, máng đèn.
  - **Lan can mở** thay tường ngoài (va chạm `OuterWall` giữ nguyên, ngoài lan can là khoảng tối).
  - Khoảng cửa giữ 3,2 m như set để camera thấy đúng ba cửa như cũ. `Cam`, `Tube`, `Door405/406/407` (chỉ ẩn hình kit), mọi va chạm, vị trí set giữ nguyên.

**Texture mới (cả ba ≤ 1K, nén VRAM):** `mask_washroom.png` 1024², `mirror_stain.png` 1024×512, `exit_sign.png` 512×192. Còn lại dùng lại scan CC0 và vải tô màu của T-255. Không Tripo, không ảnh AI. CREDITS ở hai thư mục `floor4_rest` của model và texture.

**Nặng máy:**
- Nhà vệ sinh 11.208 tam giác (trần 30.000).
- Đồ hành lang thêm 9.206 tam giác (8.834 + 372 quần áo; trần 25.000).
- Trường quay 2.526 tam giác (trần 15.000).
- Tay gạt 392, biển và trụ che 146 tam giác.
- Không đèn, không bóng mới.
- VRAM đo trong cảnh chụp chương 3: 3.693 MB (T-255 đo 3.665 MB). Số này đo trước khi rebase lên T-257 (nén VRAM); sau rebase chưa đo lại.
- Gương nhà vệ sinh: viewport 560 × 190 như cũ, vẽ khi người chơi ở trong phòng trước kính.

**Thấy thêm khi làm (lane B xác minh, ngoài phạm vi):**
- **Chương 3–4, tường tây nhà vệ sinh bị tường giếng thang chính che.** `Campus/BuildingB/MainStairs/Wall0.08…/Mesh` (hộp PS1, x 0…0,16, từ tầng 1 tới y 2,75) và khối `W1Stairs` (T-250, trên 2,74 m, cũng tới x 0,16) đặt mặt ngoài ở x 0,16, trong khi mặt trong tường tây nhà vệ sinh ở x 0,1.
  - Vì vậy trong chương 3–4, tường khảm PS1 đứng che 6 cm phía tây nhà vệ sinh, che luôn gương, ống, bảng tin. Lỗi này có từ trước: ảnh `before_ch3_washroom_04_washroom_sinks.jpg` trên main cũng thấy, gương cũ cũng bị che.
  - Nằm trong `building_b.tscn` ngoài phần C nên tôi không sửa.
- Cánh cửa phòng (T-255) mở ra hành lang không có va chạm. Đồ mới đã chừa vùng cánh quét.

**Yêu cầu thay đổi (integrator):**
1. **Tường giếng thang chính lấn nhà vệ sinh ở chương 3–4** (mục trên). Đề xuất một việc nhỏ cho lane B trong `building_b.tscn`: tầng 4 lùi mặt đông của tường giếng thang (hộp PS1 `Wall0.08…` và khối `W1Stairs` trên 2,74 m) về x 0,1, hoặc ẩn phần tầng 4 của mesh PS1 nếu mặt trong của `W1Stairs` đã đủ. Va chạm hộp đó cũng lấn 6 cm (người chơi chạm tường ở x 0,16 thay vì 0,1), không ảnh hưởng gì khác.
2. Không cần core gán `follow` cho gương: `washroom_real.gd` làm như `room407.gd`.

**Câu hỏi cho chủ dự án (đã làm theo đề xuất, đổi được):**
- Màu gạch nhà vệ sinh (xanh nhạt xỉn), góc khép hờ của ba cánh cửa buồng (24°, 31°, 19°).
- Đồ trước mỗi phòng (danh sách ở trên): có muốn bớt hay thêm.
- Tay gạt gọn: thanh gạt phía hành lang cách mặt cánh 3,1 cm (đợt 1: 5,6 cm). Nếu muốn giữ tay gạt to thì cần đổi test T-250 để cho cánh dừng ở khoảng 89°.

**Ảnh** (`art_source/graphics_upgrade/realistic_map/previews/floor4_rest/`):
- trước và sau cùng camera: `before_*` / `after_*`; phần A, B ở chương 1 và 3; phần C ở chương 3; phần D (feed và trường quay) ở chương 1;
- ảnh trước của C, D chụp bằng file cảnh của main;
- ghép: `compare_washroom_ch1.jpg`, `compare_washroom_ch3.jpg`, `compare_corridor_ch1.jpg`, `compare_corridor_ch3.jpg`, `compare_firedoor_ch3.jpg`, `compare_cctv_ch1.jpg`, `overview.jpg` (tổng quan cho chủ dự án).

**Test:**
- `game/tests/levels/test_t256_floor4_rest.gd`: 9/9 đạt. Gồm:
  - dấu vân tay va chạm nhà vệ sinh trùng main (và bằng bản PS1);
  - node, anchor, đèn giữ nguyên; hình PS1 ẩn; ngân sách tam giác;
  - gương HD đi theo người chơi; capsule tới trước từng vòi, từng buồng;
  - va chạm cũ của hành lang trùng bản không có đồ mới; đồ cứng mới không lấn lối và vùng cửa;
  - lối z 3 và tuyến quản lý z 2 thông; quần áo vẫn đung đưa;
  - tay gạt mở cách tay vịn, biển bọc hộp cũ;
  - trường quay CCTV: dấu vân tay va chạm trùng main, camera, đèn, cửa giữ nguyên, lan can mở.
- Test cũ chạy theo bộ lọc, tất cả đạt: `test_floor4` 9/9, `test_corridor_g5` 9/9, `test_wide_corridors` 4/4, `test_props` 6/6, `test_mirror` 6/6, `test_cctv` 5/5, `test_story_segments_3_5` 22/22, `test_t250` 5/5, `test_t254` 4/4, `test_t255` 12/12.
- Full test lần 1 (trước rebase): 983 đạt, 1 lỗi. Lỗi là `test_t253_realistic_wave2.gd::test_colliders_and_main_nodes_are_main_s`, do `FireDoor/ExitSign` thêm 3 node vào dấu vân tay node. Đã sửa bằng cách treo dưới khung (mục C), không đổi test cũ. Sau đó chạy lọc: `test_t253` 9/9 (node 2216 dòng, md5 trùng main), `test_t256` 9/9, `test_t250` 5/5. Check lần 1: 0 lỗi.
- Full test và check sau rebase (`9d97d8c`, trước commit cuối):
  ```
  RESULT: 984 passed, 0 failed
  ```
  Check sau rebase **chưa chạy hết**: Claude Code dừng nó lúc máy thiếu RAM, khi đang ở bước parse (408 dòng PASS, chưa có dòng lỗi nào, không có dòng RESULT). Check trước rebase đã chạy hết: `RESULT: check 0 error(s)`. Phần rebase thêm vào chỉ có T-257 (`.import`, ảnh, tài liệu), không trùng file nào của T-256. Integrator nên chạy lại `pwsh tools/check.ps1` khi merge.

**Còn dở:**
- Check sau rebase chưa chạy hết (mục Test). Còn lại không có việc dở trong phạm vi card. Việc tường giếng thang chính lấn nhà vệ sinh ở chương 3–4 chờ integrator quyết (Yêu cầu thay đổi 1).

**Cách kiểm tra:**
- `pwsh tools/test.ps1 -Filter test_t256` (9 test), và `-Filter test_t253`, `test_t250`, `test_mirror`, `test_floor4`, `test_cctv`.
- Xem ảnh ghép `previews/floor4_rest/overview.jpg` và `compare_*.jpg`.
- Chơi chương 1 hoặc 3: vào nhà vệ sinh tầng 4 (gương phản chiếu người chơi), đi hết hành lang tầng 4, mở cửa thoát hiểm cuối hành lang (chương 3). Feed CCTV hành lang: như ảnh `compare_cctv_ch1.jpg` ở chương 1.

## Review integrator (14/11/2026)
- **Đạt, merged.** Phạm vi đúng card: hai script cảnh mới (`washroom_real.gd`, `corridor_props.gd`), bốn scene chỉ thêm node hoặc ẩn hình (`washroom.tscn`, `corridor.tscn`, `cctv_set.tscn`, `building_b.tscn` phần `FireDoor`), model, ba texture ≤ 1K, test mới. Va chạm, anchor, đèn, âm thanh giữ nguyên (test so dấu vân tay với main); hình PS1 chỉ ẩn.
- Ảnh `previews/floor4_rest/overview.jpg`, `compare_*.jpg`: đã xem. Nhà vệ sinh, đồ hành lang, tay gạt gọn, biển thoát hiểm, trường quay CCTV đúng D-170.
- **Kiểm:** cây `game/` sau merge trùng hệt cây lane B đã chạy full test **984/0** (chỉ khác tài liệu), nên không chạy lại full test (như D-169). Check của lane B bị dừng vì thiếu RAM: integrator chạy lại sau merge, **`check 0 error(s)`** (14/11 02:53–03:21), `test_t256` 9/9.
- **Yêu cầu thay đổi 1** (tường giếng cầu thang chính lấn 6 cm vào nhà vệ sinh ở chương 3–4, che gương, ống nước, bảng tin): integrator xác nhận trên `compare_washroom_ch3.jpg`; lỗi có từ trước, **tách thành [T-258](T-258-main-stairs-wall-over-washroom.md)** giao lane B. Tới khi T-258 xong, gương và máng rửa mới chỉ thấy đủ ở chương 1–2.
- Chưa đo lại bộ nhớ hình sau T-256 trên nền T-257 (lane B đo trước rebase: +28 MB so với T-255); ba texture mới đều nén VRAM.
- **Chờ chủ dự án chọn sau khi chơi thử** (đã làm theo đề xuất của lane B): màu gạch nhà vệ sinh và góc khép ba cửa buồng; đồ trước mỗi phòng bớt hay thêm; tay gạt cửa thoát hiểm bản gọn (thanh gạt cách cánh 3,1 cm thay vì 5,6 cm).
