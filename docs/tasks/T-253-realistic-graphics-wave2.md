# T-253 — Đồ hoạ thật đợt 2: hành lang tầng 3→1, phòng 203, sảnh, phòng quản lý, bình cứu hoả, hộp báo cháy (nhà B)
- Lane: **B** (D-167: chủ dự án duyệt phong cách đợt 1, 13/11/2026) | Trạng thái: **merged 13/11 (`75550f1`), D-169; chủ dự án duyệt 14/11 (D-172)**: chủ dự án chọn theo cả ba đề xuất; integrator gắn hộp báo cháy (yêu cầu thay đổi 1); yêu cầu 2 (occlusion culling) chờ đo FPS | Agent: tài khoản Claude lane B, Opus 5.5 xhigh (khó thì max); chủ dự án tự dán prompt (`lane-b.md` mục 1j).
- Nhánh: `lane-b/T-253-realistic-graphics-wave2` từ nhánh `lane-b/T-254-floor4-landing-guard-rail` (cùng sửa `building_b.tscn`: làm nối tiếp để khỏi xung đột).
- **Phong cách đã duyệt (D-167):** dùng lại bộ vật liệu, màu, chi tiết của đợt 1: tường trát hai màu (dưới xanh xám, trên kem), chân tường đá mài, sàn và bậc đá mài, cửa thép sơn xanh, lan can song thép xanh tay vịn gỗ, shader vỏ phòng 407 với bản đồ bẩn riêng. Ảnh mẫu: `realistic_map/previews/wave1/compare_overview.jpg`.
- Quyết định: **D-165, D-166** (10 đợt theo đường người chơi đi; dựng bằng Blender theo chất lượng phòng 407, không ưng thì đổi Tripo; nhà B cũ vừa; ánh sáng giữ như nay). Card viết sẵn 13/11/2026 để giao ngay khi đợt 1 được duyệt.

## 1. Phạm vi (`art_source/graphics_upgrade/realistic_map/PLAN.md` mục 2–4)
| Mã | Khu | Scene và node | Làm, phải giữ |
|---|---|---|---|
| A08 | Tầng 3 nhà B | `campus/building_b.tscn` → `Floor3`, `KitDetail3` | Hành lang, vách, bảng số, đèn, lan can (bộ dùng chung với tầng 2 và 1, theo kiểu đợt 1); phòng sau cửa chỉ làm mặt nhìn thấy. Giữ chặn cửa, chỗ xác xuất hiện và phá cửa. |
| A09 | Tầng 2, phòng 203 | `Floor2`, `KitDetail2`, `Room203Bed`, `Room203Desk` | Như A08; phòng 203 dùng giường và bàn bản nhẹ của phòng 407. Giữ cửa 203 mở lúc đầu, chỗ Minh Nhật, tuyến cứu, `Room203Door` (13,75; −6,6; 0). |
| A10 | Tầng 1, sảnh, phòng quản lý, cửa sổ | `Floor1`, `KitDetail1`, `MainDoor`, `ManagerDesk`, `Knife`, `Window*`, `GlassShard`, `LobbyRail` | Sảnh, cửa chính và xích, bàn quản lý, dao, khung cửa sổ, kính vỡ. **Bậu cửa sổ và đường bước khớp va chạm** (T-247 dòng 10; `ManagerWindow` (4; −8,9; −7,6), bậu cao 1 m). Cửa chính vẫn không là lối thoát; cửa sổ vẫn đi khom qua, không thêm gợi ý (D-055). |
| A11 | Bình cứu hoả tầng 2, hộp báo cháy tầng 1 | `BuildingB/FireExtinguisher`, `ExtinguisherHandle`; `Anchors/FireAlarm1F` (core dựng hộp lúc chạy) | **Dựng bằng Blender** (PLAN đề xuất Tripo cho bình; D-166: Blender trước). Gá bình, cổ bình và tay cầm rõ; hộp báo cháy có mặt nút. Giữ `Use_Extinguisher2F` (48,83; −5,5; 2,4), `Use_FireAlarm1F` (0,9; −8,5; 0,12; cao 1,4 m), âm thanh, tầm thu hút. Hộp báo cháy do core dựng: lane làm glb, ghi "Yêu cầu thay đổi" để integrator thay chỗ core dựng hộp. |

Động tác Trần Trung ở đây (T-247 dòng 7 bình cứu hoả, 8 báo cháy, 10 cửa sổ) **không làm ở card này**; chỉ dựng hình sao cho làm được sau (bình tách khỏi gá, nút báo cháy là node riêng, bậu khớp va chạm).

## 2. Cách làm, kiểm, phạm vi file
- Như [T-250](T-250-realistic-graphics-wave1.md) mục 3–6, dùng lại bộ vật liệu và chi tiết đợt 1 đã được duyệt.
- Ngân sách (PLAN mục 6): A08–A10 ≤ 0,50 ms cho tầng đang đi (không vẽ nội thất ba tầng cùng lúc); A11 ≤ 0,10 ms.
- Ảnh trước/sau 1080p trong chương 3 thật: `art_source/graphics_upgrade/realistic_map/previews/wave2/` (ảnh hiện trạng `previews/survey/16`–`25`).
- Được sửa: phần hình A08–A11 trong `campus/building_b.tscn`, `art_source/graphics_upgrade/realistic_map/wave2/`, `game/assets/models/graphics_pilot/realistic_map/wave2/`, `game/assets/textures/`, test mới `game/tests/levels/`, card này.
- Không được: va chạm, navmesh, director, `Ch3Use`, luật; Tripo; bot, FPS.

## Checklist
- [x] A08 tầng 3
- [x] A09 tầng 2, phòng 203
- [x] A10 tầng 1, sảnh, phòng quản lý, cửa sổ
- [x] A11 bình cứu hoả, hộp báo cháy (hộp báo cháy: glb xong, chờ core gắn, xem "Yêu cầu thay đổi")
- [x] Test, full test, check, ảnh, Handoff

## Handoff

### 13/11/2026 — lane B (Claude, Opus 5.5)
Nhánh `lane-b/T-253-realistic-graphics-wave2` từ `origin/main` `1c66187` (đã có T-254; commit card đã đọc: `d1ab5ad`). Lúc mở phiên không có thay đổi dở. Không dùng Tripo, không chạy bot, không đo FPS. Script và cách dựng: `art_source/graphics_upgrade/realistic_map/wave2/README.md`.

**Đã làm** (cùng bộ vật liệu, màu, chi tiết đợt 1 đã duyệt; mọi hình PS1 chỉ ẩn, không xoá):
- **A08 tầng 3, A09 tầng 2:**
  - Hành lang: tường trát hai màu (dưới xanh xám, trên kem), chân tường đá mài, sàn đá mài có nẹp đồng phân ô, trần trát, dầm ngang trên vách phòng và dầm mép ngoài.
  - Shader vỏ phòng 407 với bản đồ bẩn vẽ riêng cho từng tầng, theo vị trí thật: vết tay hai bên mỗi cửa, vệt đá chân tường, vệt nước và mốc từ trần, lối mòn giữa hành lang, nước mưa hắt dưới lan can. Không vết nào lặp.
  - Lan can song thép sơn xanh, tay vịn gỗ trên gờ bê tông, nằm trong hộp va chạm `Rail` cũ. Máng đèn hai bóng tuýp dưới 5 đèn có sẵn (đèn không đổi).
  - Cửa phòng: khung thép xanh, ngưỡng đá, cánh thép sơn xanh bốn ô có tay gạt và bản lề. Biển số nhôm, số in bằng `Label3D` cũ (đổi font và màu).
  - Phòng sau cửa: chỉ mặt nhìn thấy, cộng giường tầng khung thép nhẹ và tủ thép, nằm gọn trong hộp va chạm `RoomInterior_*` cũ.
  - **Phòng 203:** đồ phòng 407 (khung giường, nệm, chăn gối, bàn, sách, ghế nhựa, xô, dép) trong `Room203BedBody`/`Room203DeskBody`, ngoài vùng dẫn đường của phòng. Cánh cửa gập sát tường trong (203 không có node cửa, luôn mở). `Room203Door`, chỗ Minh Nhật, tuyến cứu giữ nguyên.
- **A10 tầng 1:**
  - Hành lang như trên; sảnh có tường thấp trát hai mặt, mặt đá mài (trong hộp `LobbyRailWest/East`).
  - Ba cửa đóng 103, 106, 108; ba hốc xác 102, 105, 107 có cánh bị phá nằm trên sàn trong phòng, ngoài dải dẫn đường.
  - Phòng quản lý: bàn gỗ đợt 1 trong `ManagerDeskBody`; dao găm mũi xuống mặt bàn ở đúng chỗ dao cũ; hộp chìa, lịch, giấy trên bàn; cánh cửa 101 mở gập sát tường.
  - **Cửa sổ:** khung thép xanh, kính trái vỡ, cánh giữa một cánh treo ra ngoài, một cánh rơi ngoài sân; mảnh kính trên bậu và sàn, không mảnh nào trên lối khom. Bậc xây trong và ngoài: mặt bậc ở giữa bậc nằm trên dốc `WindowApproach`/`WindowExit` (lệch tối đa đo được 0,1 mm). Mặt cầu qua bậu là mặt hộp `WindowBridge`. Không thêm gợi ý (D-055).
  - **Cửa chính:** hai cánh kính khung thép xanh, ô kính trên, trụ trát hai bên. `door.gd` có sẵn xoay `LeafB` ngược chiều khi mở. Xích mạ quấn hai vòng quanh hai tay nắm ngoài, khoá móc đồng; xích nằm dưới `MainDoor/Chains` nên ẩn cùng khi `set_main_door_chained(false)`. Cửa chính vẫn không là lối thoát.
- **A11:**
  - Bình bột ABC 4 kg: nhãn "BÌNH CHỮA CHÁY", đồng hồ áp suất, chốt an toàn, vòi. Bình là con của `FireExtinguisher` (node cũ giữ chỗ; hình nón PS1 vẽ trên layer 0).
  - **Cần bóp `Lever` và điểm cầm `Grip` là node riêng; giá treo `ExtinguisherBracket` là node riêng trên tường**, nhấc bình ra được. Bên cạnh có bảng "TIÊU LỆNH CHỮA CHÁY". `Use_Extinguisher2F`, tiếng, tầm thu hút không đổi.
  - **Hộp báo cháy:** `wave2/fire_alarm.glb` (hộp đỏ "BÁO CHÁY", **nút nhấn `Button` là node riêng**, điểm `Press`, đèn, ống luồn dây lên trần), vừa hộp 0,22 × 0,28 × 0,06 của core. Hộp do core dựng lúc chạy nên **trong game vẫn là hộp đỏ cũ**, xem "Yêu cầu thay đổi". Ảnh `after_a11_3_alarm_close_torch` là ảnh mẫu, chỉ gắn trong cảnh chụp.

**Hợp đồng giữ nguyên:**
- Không đổi, thêm, xoá va chạm, dẫn đường, marker, `Ch3Use`, luật, director.
- Test so **dấu vân tay mọi va chạm của `building_b.tscn`** (331 khối) và **mọi node của bản main** (2.216 node: tên, loại, vị trí toàn cục; trừ model treo thêm) đều **trùng main**.
- Riêng `Floor2/3/Door*/Hinge` (trục hình của cánh `RoomDoor`) dời từ x 0,85 vào x 0,45, mép lỗ cửa thật, như cửa tầng 4. `Blocker` và va chạm không đổi. Lý do ở "Thấy thêm" 1.

**Kiểm:**
- Test mới `game/tests/levels/test_t253_realistic_wave2.gd` (9 test, đạt):
  - va chạm và node trùng main;
  - model mới không có va chạm, chỉ ẩn lưới PS1, đèn còn nguyên;
  - không đỉnh mới nào trong lối đi hành lang ba tầng;
  - 15 cửa phòng: cánh vừa lỗ cửa, quay ra hành lang đúng bản lề, đóng lại đúng chỗ; ba cửa tầng 1 vẫn chặn; bộ `wall_door` vẫn có va chạm;
  - 24 biển số đúng số, in trên mặt nhôm;
  - giường, tủ, đồ phòng 203 nằm trong hộp va chạm, ngoài vùng dẫn đường phòng 203;
  - bậc cửa sổ trên dốc (28 điểm, lệch tối đa 0,1 mm), lối khom trống;
  - cửa chính hai cánh, mở áp hai trụ, xích ẩn cùng;
  - bình, cần bóp, điểm cầm, giá riêng; hộp báo cháy có nút riêng.
- Nhóm test cũ chạy riêng đều đạt: `t253` 9, `room_doors` 4, `sealed_408` 2, `campus` 5, `graphics_bindings` 8, `t250` 5, `t254` 4, `fire_stairs` 3, `wide_corridors` 4, `manager` 32.
- **Full test** (13/11 16:01–16:32, chạy lại theo yêu cầu chủ dự án, sau khi xoá `game/_probe_tmp/`): `RESULT: 963 passed, 0 failed`, không có lỗi engine.
- **Check** (16:32–16:53): `RESULT: check 0 error(s)`. Sau đó `git checkout -- game/default_bus_layout.tres`.
- Lượt đầu lúc 15:50 bị Claude Code dừng sau khoảng 4 phút vì máy thiếu RAM, chưa chạy được test nào; khoá Godot của lượt đó đã xoá.
- **Chưa kiểm:** chưa chơi bằng tay; chưa chạy bot, chưa đo FPS (không được phép); chưa chụp chương 4 (cùng cảnh nhà B, chỉ khác trạng thái cửa chính và xác).

**Ảnh** `art_source/graphics_upgrade/realistic_map/previews/wave2/`:
- Ảnh 1080p, chương 3 thật, director giữ, ánh sáng lúc mở chương, có/không đèn pin khảo sát như T-248. `before_*`/`after_*` cùng camera: 8 góc A08, 8 góc A09, 13 góc A10, 3 góc A11. Ảnh trước gồm đúng các góc khảo sát 16–25.
- Ghép: `compare_a08.jpg`, `compare_a09.jpg`, `compare_a10.jpg`, `compare_a11.jpg`, **tổng hợp `compare_overview.jpg`**.
- Đã tự xem từng ảnh. Sửa sau khi xem:
  - dây đèn mọc lệch ra giữa trần;
  - đầu tường cầu thang và 10 cm tường trước tháp thang còn PS1;
  - tường phòng 101, 108 lùi sau tường tháp thang;
  - bậu cửa sổ hở 2 cm;
  - nhãn bình mất UV;
  - dao bóng gương;
  - xích mảnh quá khó thấy;
  - cánh cửa đôi đặt sai lỗ cửa (xem "Thấy thêm" 1).
- Script chụp: `wave2/capture_wave2.gd`, dùng tạm trong `game/_probe_tmp/` (đã xoá, không commit).

**Số đo để ước lượng** (chưa đo FPS):

| Khu | Tam giác mới | Trước (T-248) | Vật liệu | Đèn mới |
|---|---|---|---|---|
| A08 tầng 3 | 35.208 (hành lang 8.696, phòng 9.008, 8 khung 568, 8 cánh 1.472, 8 biển 148) | 2.832 / 9 | 12 (W1 dùng lại + W2) | 0 |
| A09 tầng 2 | 34.168 + 63.000 đồ phòng 407 ở phòng 203 (cùng lưới, cùng texture với phòng 407) | 3.264 / 15 | 12 + đồ 407 | 0 |
| A10 tầng 1 | 30.643 (xích cửa chính 4.056, cửa sổ 1.405, bàn 1.284, bảng tin 2 × 864) | 2.952 / 13 | 11 + 7 | 0 |
| A11 | 1.894 (bình 1.572, giá và bảng 322); hộp báo cháy 386 khi core gắn | 72 / 3 | 7 + 6 | 0 |

- Mỗi glb chỉ mang vật liệu giữ chỗ. `.import` trỏ sang `wave1/materials` (không sửa) hoặc `wave2/materials` (21 vật liệu mới).
- Phần lớn tam giác nằm ở cánh cửa và đồ phòng 203; nếu đo FPS thấy nặng thì cắt bớt được (cánh cửa còn khoảng 600, phòng 203 bỏ gối, chăn gấp, ghế).
- PLAN mục 6 muốn không vẽ nội thất ba tầng cùng lúc. Dự án chưa bật occlusion culling (`project.godot`, core) nên chưa làm được bằng occluder; xem "Yêu cầu thay đổi".

**Thấy thêm (có từ trước):**
1. **Lỗ cửa phòng tầng 1–3 thật ra chỉ 0,9 × 2,1 m**: bộ `wall_door` dưới `KitDetail<N>/Frame<i>` có va chạm riêng (trụ, lanh tô; `kit_import.gd`), nằm trong hộp tường 1,7 m. Trên main, cánh PS1 1,7 m vẽ đè lên trụ và khi mở thì quay xuyên trụ.
   - Mình giữ nguyên va chạm, làm cánh 0,89 m vừa lỗ thật, dời trục hình `Hinge` vào mép lỗ.
   - Không đổi cách xác phá cửa hay tuyến đi (test `room_doors` đạt).
2. Mặt ngoài nhà B (tường sau quanh cửa sổ, tháp cầu thang nhìn từ sân) vẫn PS1. Đó là đợt 7 (A19). Thấy rõ ở `after_a10_7_window_outside_torch`.
3. Tường trước tháp cầu thang nhô 10 cm vào đầu hành lang mỗi tầng; đã trát phủ.

**Câu hỏi cho chủ dự án:**
1. **Cửa chính sảnh** (`after_a10_5_main_door_torch`, `after_a10_12_chain_torch`): hai cánh kính khung thép xanh, xích quấn tay nắm (đang dùng, **đề xuất**: nhìn thấy sân, hợp cảnh bị nhốt); hay cửa sắt xếp kéo ngang có khoá móc (hay gặp ở ký túc xá, kín hơn, không thấy ra ngoài)?
2. **Bảng tiêu lệnh chữa cháy** cạnh bình tầng 2 (`after_a11_2_extinguisher_close_torch`): giữ (**đề xuất**: đúng thực tế, làm bình dễ thấy) hay bỏ?
3. **Hộp báo cháy** (`after_a11_3_alarm_close_torch`, ảnh mẫu): hộp đỏ nút tròn "BÁO CHÁY / NHẤN MẠNH" như đang dựng (**đề xuất**), hay kiểu kính "đập vỡ" (cần thêm trạng thái kính vỡ khi bấm)?

**Yêu cầu thay đổi ngoài phạm vi:**
1. **Core, hộp báo cháy (A11):** `chapter3_director.gd` `_place_fire_alarm()` thay `BoxMesh` đỏ bằng instance `res://assets/models/graphics_pilot/realistic_map/wave2/fire_alarm.glb` dưới marker `FireAlarm1F`.
   - Gốc glb ở tâm hộp cũ, mặt hướng +Z (hành lang). Nút `Button` là node riêng, nhấn theo −Z; điểm tay `Press`.
   - `Use_FireAlarm1F` giữ nguyên. Cập nhật `test_graphics_bindings.gd` ("one greybox visual (core's own)" đếm `MeshInstance3D` con trực tiếp).
2. **Core, occlusion culling:** muốn đạt yêu cầu "không vẽ nội thất ba tầng cùng lúc" (PLAN mục 6) thì cần bật `rendering/occlusion_culling/use_occlusion_culling` trong `project.godot`. Sau đó lane B thêm `OccluderInstance3D` theo sàn, tường kín. Nên làm khi có số đo FPS.
