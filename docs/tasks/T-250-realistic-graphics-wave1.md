# T-250 — Đồ hoạ thật đợt 1: bàn trực tầng 4, cầu thang thoát hiểm và cửa, cầu thang chính nhà B
- Lane: B | Trạng thái: **merged 13/11/2026** (full test 949/0, check 0); chủ dự án duyệt phong cách (D-167) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max), chủ dự án tự dán prompt (`lane-b.md` mục 1h).
- Nhánh: `lane-b/T-250-realistic-graphics-wave1` từ `origin/main` mới nhất.
- Quyết định giao: **D-166** (12/11/2026): chủ dự án duyệt kế hoạch [T-248](T-248-realistic-graphics-survey.md) với 10 đợt theo đường người chơi đi; mọi thứ dựng **bằng Blender trước, theo đúng chất lượng đồ phòng 407**; chỗ nào chủ dự án không ưng thì đổi sang Tripo sau.

## 1. Chủ dự án đã chốt (D-166)
- **Phong cách nhà B:** cùng chất liệu với phòng 407 và hành lang tầng 4 (G5), cũ vừa phải; không thành phế tích, không sạch mới.
- **Dựng bằng Blender, không dùng Tripo** ở đợt này (kể cả điện thoại bàn, loa treo mà PLAN đề xuất Tripo): chân thực như đồ phòng 407; vật liệu CC0 như phòng 407 và hành lang. Chủ dự án xem ảnh, thứ nào không ưng thì đổi sang Tripo ở lượt sau.
- **Ánh sáng giữ như hiện nay**, chỉ chỉnh vật liệu cho dễ nhìn.
- Động tác của Trần Trung ở chỗ này (T-247 dòng 5 chìa trong ngăn kéo, 6 cửa thoát hiểm có ổ khoá, 9 chân trên cầu thang) **chưa làm** ở card này: chỉ dựng hình sao cho làm được sau (ngăn kéo tách riêng trượt được, ổ khoá và tay nắm là node riêng trên cánh, mặt bậc nhìn thấy khớp mặt bậc va chạm).

## 2. Phạm vi (PLAN mục 2–4, mã khu A01, A06, A07)
| Mã | Khu | Scene và node | Làm |
|---|---|---|---|
| A01 | Bàn trực tầng 4, chìa, đồng hồ | `game/scenes/levels/floor4/duty_desk.tscn` → `DutyDesk`; `campus/building_b.tscn` → `DeskClock`, `KeyStem`/`KeyTooth` | Bàn có thân và **ngăn kéo riêng có ray trượt**, chìa riêng, đồng hồ, bảng, ghế, đèn (dùng lại hoặc chỉnh từ bộ đồ phòng 407), điện thoại bàn, loa treo. Giữ vị trí chìa (`FireKey` ở (39,8; 0,66; 0,42)), mặt bàn, đồng hồ, nguồn tiếng. |
| A07 | Cầu thang thoát hiểm, cửa, đoạn sập | `campus/building_b.tscn` → `FireStairs`, `FireDoor`, `FireRubbleDetail`, `StairCrack` | Bậc, chiếu nghỉ, tay vịn, tường; **cánh cửa thép có bản lề, ổ khoá và tay nắm là node riêng**; mảnh sập không lấn tuyến. Giữ pivot cửa, blocker, vùng `Collapse2F` (46,5; −6,6; −1). |
| A06 | Cầu thang chính | `campus/building_b.tscn` → `MainStairs`, `Handrail_-4*`, `UpperRubbleDetail` | Bậc, chiếu nghỉ, trụ, tay vịn, phần chặn tầng trên, mảnh vỡ theo số đo. **Mặt bậc nhìn thấy khớp collider**, giữ độ cao tầng 3,3 m (tầng 1/2/3/4 ở Y = −9,9 / −6,6 / −3,3 / 0) và vùng chặn. |

Hợp đồng gameplay (PLAN mục 4): không đổi tên, transform gốc, marker, signal, đường dẫn tài nguyên mà director và test đang tìm. Thay hình dưới node sở hữu; **giữ nguyên collider, navmesh, layer, `Ch3Use`** (`Use_FireKey`, `Use_FireDoor`). Không đổi luật chơi.

## 3. Cách làm (theo vòng của PLAN mục 5)
1. **Mẫu trước:** dựng A01 (bàn trực) trước, chụp ảnh trước/sau cùng góc ở chương 3 thật (và chương 1, vì bàn trực có ở mọi chương), tự xem lại. Ghi số tam giác, vật liệu.
2. Rồi A07 và A06, cũng ảnh trước/sau: đứng dưới chân cầu thang, giữa cầu thang, chiếu nghỉ, trước cửa thoát hiểm (đóng, mở), đoạn sập.
3. Script Blender trong `art_source/graphics_upgrade/realistic_map/wave1/`, glb trong `game/assets/models/graphics_pilot/realistic_map/wave1/`, CREDITS ghi nguồn vật liệu. Mẫu: cách dựng hành lang tầng 4 (`art_source/graphics_upgrade/floor4_corridor/`) và đồ phòng 407 (`room407_furnished/`, `room407_shell/`).
4. Ảnh `art_source/graphics_upgrade/realistic_map/previews/wave1/` (1080p, ánh sáng của chương); một ảnh ghép trước/sau cho chủ dự án.
5. **Không đo FPS, không chạy bot** (chủ dự án chưa cho); ghi số tam giác, vật liệu, đèn mới (nếu có) để ước lượng.

## 4. Kiểm
- Test mới trong `game/tests/levels/`: các node mà director/test tìm vẫn còn đúng chỗ; collider cầu thang không đổi (so với main); cửa thoát hiểm vẫn quay đúng, ổ khoá và tay nắm đi theo cánh; ngăn kéo là node riêng trượt được; mặt bậc nhìn thấy cách mặt bậc va chạm ≤ 2 cm.
- Test cũ chương 1–4 đạt (`test_chapter3`, `test_ch3_*`, `test_ch2_4_hand_targets`, `test_t249_chapter3_bar`, `test_floor4*`, `test_room407*`…). Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit.

## 5. Được phép sửa
- `art_source/graphics_upgrade/realistic_map/wave1/`, `.../previews/wave1/`, `game/assets/models/graphics_pilot/realistic_map/`, `game/assets/textures/` (vật liệu CC0 mới), `game/scenes/levels/floor4/duty_desk.tscn`, `game/scenes/levels/campus/building_b.tscn` (phần hình của A01, A06, A07), script dựng cảnh trong `game/scenes/levels/` nếu cần, test mới trong `game/tests/levels/`, card này.
- Cảnh tạm `game/_probe_tmp/`: không commit, xoá khi xong.

## 6. Không được
- Đổi collider, navmesh, luật, thời gian, director (`game/scripts/core/`), `Ch3Use`; làm động tác cho Trần Trung (T-247 dòng 5, 6, 9).
- Dùng Tripo, tiêu credit Tripo; chạy bot, đo FPS.
- Sửa khu ngoài A01, A06, A07 (hành lang tầng 1–3, sảnh, phòng 203… là đợt 2).
- Commit log, video, `anh_chup_sua_loi/`. Sửa STATUS, DECISIONS.

## Checklist
- [x] A01 bàn trực (ngăn kéo riêng), ảnh trước/sau
- [x] A07 cầu thang thoát hiểm, cửa (ổ khoá, tay nắm riêng), đoạn sập, ảnh
- [x] A06 cầu thang chính, ảnh
- [x] Test mới, test cũ đạt, full test, check (test mới, test cũ, full test đạt; check bị dừng vì máy thiếu RAM, chủ dự án bảo không cần chạy lại)
- [x] CREDITS, ảnh ghép trước/sau, Handoff

## Handoff

### 13/11/2026 — lane B (Claude, Opus 5.5)
Nhánh `lane-b/T-250-realistic-graphics-wave1` từ `origin/main` `ee05aa5` (commit card đã đọc: `ee05aa5`). Xong phần lane B, chờ integrator review. Không dùng Tripo, không chạy bot, không đo FPS.

**Đã làm** (script, cách dựng: `art_source/graphics_upgrade/realistic_map/wave1/README.md`):
- **A01 bàn trực** (`duty_desk.tscn`, giữ tên mọi node): bàn gỗ một hộc tủ (gỗ Wood Table Worn như bàn phòng 407), nằm gọn trong hộp va chạm bàn PS1. **Ngăn kéo giữa `Desk/Model/KeyDrawer` là node riêng trên ray thép**, `duty_desk.gd` `set_drawer_open(0…1)` trượt ra 0,34 m theo +Z (chưa ai gọi; động tác là T-247 dòng 5). Chìa thật (đồng, vòng thép, thẻ nhựa đỏ) là `KeyStem/Model` trong `building_b.tscn`, nằm trên đáy ngăn kéo y 0,650, không đi theo ngăn kéo (node riêng như card yêu cầu). Đồng hồ treo tường tròn dừng 4 giờ, ba kim là node riêng (`DeskClock/Model/HourHand…`). Điện thoại bàn phím bấm có dây xoắn, loa nén trên giá (dây lên trần), bảng bần khung nhôm có giấy ghim, sổ trực mở, sổ cũ, hộp mực, con dấu, ca men, ống bút. Đèn bàn và ghế nhựa dùng lại đồ phòng 407. Vị trí chìa, mặt bàn (0,80), đồng hồ, nguồn tiếng (`SpeakerIdle`, `Anchors/Speaker`) giữ nguyên.
- **A07 cầu thang thoát hiểm:** bậc bê tông ốp đá mài (mũi bậc, hai rãnh chống trượt), chiếu nghỉ đá mài, tường trát sơn hai màu (dưới xanh xám, trên kem) với chân tường đá mài chạy theo dốc thang, tay vịn gỗ trên tường, lan can giếng thang (song thép sơn xanh, tay vịn gỗ, trụ đầu thang). Tường dùng shader vỏ phòng 407 với bản đồ bẩn riêng (bẩn chân tường, vệt tay, vệt nước nhạt, mốc góc); bậc mép bẩn, giữa mòn.
  - **Cửa thoát hiểm:** lỗ cửa 3,8 m nên làm **hai cánh thép** trong khung thép, ô trát phía trên tới trần. Cánh chính treo trên `FireDoor/Leaf` (trục và va chạm cũ); **`FireDoor/Leaf/Lock` (gốc ở lỗ khoá) và `FireDoor/Leaf/Handle` (gốc ở trục tay gạt) là node riêng trên cánh**, cách mép giữa 6,5 cm, cao 0,98/1,05 m, nằm trong hộp `Use_FireDoor`. Cánh phụ `FireDoor/LeafB` chỉ là hình (không va chạm); `door.gd` thêm 4 dòng xoay nó ngược chiều khi mở để hai cánh áp vào lan can và tường hành lang, không chạm cửa 408.
  - **Đoạn sập tầng 2 → 1:** vế 2A còn 40 % trên cùng, gãy có thép lòi; tấm sàn gãy nghiêng tựa tường sau; đống đổ nén chặt lấp hộp `Collapse` (mặt trước là bức đá vụn cao quá tầm mắt), không lấn chiếu nghỉ tầng 2 hay vế 3B. Vết nứt tường (`StairCrack` cũ ẩn) vẽ lại trên tường ngoài trên vế 4B.
- **A06 cầu thang chính:** như A07 (không có đoạn sập); sàn bê tông dưới gầm thang tầng 1 thay cỏ.
- **Phần chặn tầng trên (cả hai):** không có va chạm nào trên cao nên dựng ngoài tầm với: chiếu nghỉ trung gian 1,65 m, vế lên tầng 5, sàn chiếu nghỉ tầng 5 (thành trần tầng 4), vế từ tầng 4 đi lên **gãy mất 40 % dưới, treo trên giếng thang**, đống đổ trong hộp `UpperRubble` chặn lối lên. Tường nâng tới 6,3 m có mái (mặt ngoài phần nâng dùng đúng vật liệu PS1 cũ của tường để khớp từ ngoài).
- **Giữ hợp đồng:** không đổi, không thêm, không xoá collider, navmesh, marker, `Ch3Use`; hình PS1 chỉ ẩn (`visible = false`). Riêng `door.gd` (trong `scenes/levels/campus`, phạm vi B) thêm xoay `LeafB` nếu có.

**Kiểm:**
- Test mới `game/tests/levels/test_t250_realistic_wave1.gd` (5 test, đạt): dấu vân tay mọi va chạm của hai cầu thang, cửa thoát hiểm, bàn trực **trùng main** (36 khối, md5 ghi ở test); marker, node cũ đúng chỗ; ngăn kéo trượt riêng, bàn trong hộp va chạm, chìa trên đáy ngăn kéo; cửa quay, ổ khoá và tay gạt đi theo cánh, cánh phụ quay theo, mở ra không chạm cửa 408; **mặt bậc nhìn thấy tại giữa mỗi bậc cách dốc va chạm tối đa 0,1 mm** (226 điểm đo, 10 vế); chiếu nghỉ đúng mặt va chạm; đống đổ, vế gãy không lọt vào khoảng đi được.
- Nhóm test cũ chạy riêng đều đạt: `t250` 5, `campus` 5, `fire_stairs` 3, `props` 21, `floor4` 9, `corridor_g5` 9, `chapter3` 29, `ch3_` 45, `hand_targets` 6, `t249` 7, `room407_furnished` 8, `smoke` 1.
- **Full test** (13/11 01:09–01:38, sau khi xoá `game/_probe_tmp/`): `RESULT: 944 passed, 0 failed`, không có lỗi engine.
- **Check: chưa xong.** `pwsh tools/check.ps1` chạy từ 01:38 thì bị Claude Code dừng lúc 01:45 vì máy thiếu RAM (đang ở bước parse script, mọi dòng đã chạy đều PASS). 13/11: chủ dự án xem kết quả và bảo **không cần chạy lại check** ("tôi thấy ok rồi"). `game/default_bus_layout.tres` không đổi.

**Ảnh** `art_source/graphics_upgrade/realistic_map/previews/wave1/` (1080p, chương thật, director giữ, ánh sáng lúc mở chương, có/không đèn pin khảo sát như T-248): `before_*`/`after_*` cùng camera (chương 1 và 3 cho bàn trực, chương 3 cho cầu thang), ghép `compare_a01.jpg`, `compare_a07.jpg`, `compare_a06.jpg`, **tổng hợp `compare_overview.jpg`**, phương án `compare_options.jpg`. Ảnh `after_*_7_drawer_open_torch` cho chìa đi theo ngăn kéo **chỉ trong cảnh chụp** để thấy chìa. Đã tự xem từng ảnh; sửa sau khi xem: quai ca men lạc chỗ, dây loa xuyên đồng hồ, đá mài quá thô, vệt nước như gỉ, đống đổ thưa như đá bay, tường hành lang PS1 nhô vào lòng thang (xem dưới).

**Số đo để ước lượng** (chưa đo FPS):
| Khu | Tam giác mới | Trước (T-248) | Vật liệu | Đèn mới |
|---|---|---|---|---|
| A01 | 11.030 (bàn 1.284, chìa 760, đồ bàn 1.428, điện thoại 3.314, đồng hồ 1.156, loa 2.224, bảng 864) + đèn, ghế phòng 407 | 1.456 / 23 | 32 vật liệu nhỏ (1 lớp gỗ quét, còn lại màu trơn hoặc texture nhỏ) | 0 |
| A07 | 17.976 cầu thang + 2.220 cửa | 984 / 3 | 13 + 7 (dùng chung với A06) | 0 |
| A06 | 15.676 | 1.164 / 3 | 13 (dùng chung) | 0 |
Mỗi glb chỉ mang vật liệu giữ chỗ; `.import` trỏ sang `materials/*.tres` dùng chung, texture CC0 có sẵn không chép lại.

**Thấy thêm (có từ trước, chưa sửa, ngoài phạm vi):**
1. **Hộp va chạm `FireStairs/Collapse` nhô 0–14 cm lên trên 3 bậc cuối vế 3A thoát hiểm** (z −3,78…−4,2): đi xuống vấp một bậc vô hình. Không đổi va chạm được, nên mình rải một lớp đá vụn thấp đúng chỗ đó (mặt trên không quá mặt hộp, test có kiểm) để chỗ gồ có hình.
2. **Mép chiếu nghỉ tầng 4 phía giếng thang (vế B) hở, không lan can, không va chạm** ở cả hai cầu thang: bước ra là rơi xuống tầng 3. Lan can chỉ có hình sẽ đi xuyên được, nên mình **không** vẽ (xem câu hỏi 4).
3. Tường hành lang PS1 của tầng 1–3 nhà B (`Floor*/East`, `Floor*/West`) nhô 10 cm vào lòng cầu thang; lớp trát mới phía hành lang đưa ra 10,3 cm để phủ, tay vịn tường phía đó lùi theo.
4. Dốc va chạm không có bậc: bậc nhìn thấy khớp ở giữa bậc, nhưng ở mũi bậc cao hơn dốc 7,5 cm, cuối bậc thấp hơn 7,5 cm. Cho IK chân (T-247 dòng 9) nên có va chạm bậc riêng trên một lớp không phải lớp người chơi (lane A/core quyết).
5. `main.tscn` (bản demo cũ, chỉ test dùng) dán giấy đọc được vào `Anchors/HallBoard`, `HallBoardNote`, `DutyLog`: mặt bảng mới sát tường hơn bảng PS1 nên giấy đó cách mặt bần khoảng 8 cm. Chương 1–4 không dùng.
6. Nhìn từ hành lang tầng 1–3 vẫn thấy tường hành lang PS1 cạnh cầu thang (đợt 2, A08–A10). Tháp cầu thang nhìn từ ngoài cao thêm tới 6,3 m (mặt ngoài vẫn vật liệu PS1; mặt ngoài nhà B là đợt 7).

**Chưa kiểm:** chưa chơi bằng tay; chưa đo FPS, chưa chạy bot (chưa được phép); chưa xem trong chương 4 (cùng cảnh nhà B với chương 3).

**Câu hỏi cho chủ dự án** (ảnh `compare_options.jpg`):
1. **Màu cửa thoát hiểm:** xanh như lan can, khung cửa hành lang (đang dùng, **đề xuất**), xám, hay đỏ nâu?
2. **Màu chân tường cầu thang:** xanh xám (đang dùng, **đề xuất**), kem như phần trên, hay xám?
3. **Kiểu cửa:** hai cánh thép, ổ khoá âm và tay gạt (đang dùng, **đề xuất**, hợp "mở khoá" bằng chìa); hay cửa sắt xếp/song sắt kéo ngang có khoá móc (hay gặp ở ký túc xá)? Ổ khoá móc sẽ cần thêm trạng thái khoá treo/tháo khi mở.
4. **Lan can mép chiếu nghỉ tầng 4** (Thấy thêm 2): cho làm một card nhỏ thêm lan can **kèm va chạm** (đề xuất), hay để hở như nay?
5. Điện thoại bàn, loa treo dựng bằng Blender theo D-166; nếu chưa ưng thì đổi sang Tripo ở lượt sau.

**Yêu cầu thay đổi ngoài phạm vi:** va chạm cho lan can mép chiếu nghỉ tầng 4 (câu hỏi 4); va chạm bậc riêng cho IK chân (Thấy thêm 4) khi làm T-247 dòng 9.

**Chủ dự án trả lời (13/11/2026):**
1. Cửa thoát hiểm màu **xanh**: giữ như bản này.
2. Chân tường cầu thang **xanh xám**: giữ như bản này.
3. **Giữ hai cánh thép có ổ khoá và tay gạt**: giữ như bản này.
4. **Có làm** lan can mép chiếu nghỉ tầng 4. Nhờ integrator viết card (đổi va chạm nên ngoài T-250). Đề xuất cho card:
   - Ở cả hai cầu thang, mép chiếu nghỉ tầng 4 (y 0, z 0) phía giếng thang, trên vế B: Main x −2,28…−0,12 (cộng khe giếng tới −2,72), Fire x 46,72…48,88 (từ 46,28). Lan can cùng kiểu lan can giếng thang của T-250 (song thép sơn xanh, tay vịn gỗ, trụ hai đầu), cao 0,95 m, nối với lan can vế A ở trụ đầu thang.
   - Thêm một `StaticBody3D` hộp mỏng (khoảng 0,05 × 1,0 m) trên layer 1 đúng chỗ lan can, để người chơi và bot không rơi xuống tầng 3; kiểm `test_fire_stairs`, `test_campus` (đường dẫn, lối đi) và ảnh từ chiếu nghỉ tầng 4.
   - Phạm vi lane B: `building_b.tscn` (thân va chạm), `art_source/graphics_upgrade/realistic_map/wave1/build_stairs.py` (hình lan can), test trong `game/tests/levels/`.

## Review integrator (13/11/2026)
- Đạt. Phạm vi đúng: ngoài art_source, assets chỉ sửa `building_b.tscn`, `door.gd` (xoay cánh phụ), `duty_desk.tscn`, `duty_desk.gd` (mới), test mới; va chạm hai cầu thang, cửa, bàn trực trùng main (test có dấu vân tay md5).
- Sau merge (cùng T-251 và main mới nhất): full test 949/0, check 0 (lane B không chạy hết check vì máy thiếu RAM, chủ dự án miễn; integrator chạy lại sau merge đạt).
- Chủ dự án duyệt phong cách đợt 1 (D-167); đợt 2 giao lane B ([T-253](T-253-realistic-graphics-wave2.md)) sau lan can mép chiếu nghỉ tầng 4 ([T-254](T-254-floor4-landing-guard-rail.md)).
- Còn để sau (Thấy thêm): va chạm bậc riêng cho IK chân (T-247 dòng 9); hộp `FireStairs/Collapse` gồ 0–14 cm trên 3 bậc cuối vế 3A (đã phủ đá vụn cho có hình).
