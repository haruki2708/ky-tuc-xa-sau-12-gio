# T-255 — Các phòng 401–406, 408: sâu như phòng 407, có nhà tắm và ban công, đồ đầy đủ như 407, mở cửa đi vào được
- Lane: B | Trạng thái: todo (làm sau T-254, T-253; chủ dự án đổi thứ tự được) | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh** (khó thì max). Chủ dự án tự dán prompt (`lane-b.md` mục 1k).
- Nhánh: `lane-b/T-255-floor4-rooms-like-407` từ `origin/main` mới nhất.
- Quyết định: **D-168** (13/11/2026). Chủ dự án xem mẫu lane C ([T-252](T-252-floor4-rooms-sample-codex.md), không merge): "chất lượng không đạt, tôi muốn các phòng khác rộng bằng phòng 407 và đồ đạc trong đó đầy đủ như phòng 407 (khi chơi, chúng ta có thể mở được cửa các phòng đó)", giao lane B.

## 1. Chủ dự án đã chốt (D-168)
- **Kích thước:** giữ hành lang 44 m và vị trí mọi cửa (không dời cửa, cầu thang, không đổi đường đi của quản lý, xác sống, bot). Mỗi phòng giữ bề rộng ô hiện có (401–406 rộng 4 m, x 6…30; 408 rộng 6 m, x 38…44) nhưng **sâu bằng phòng 407**, **có nhà tắm và ban công như 407**.
- **Vào phòng:** ở mọi chương, người chơi **mở cửa bằng tay và đi vào khám** được. Chỉ để khám: không thêm câu đố, manh mối, đồ nhặt (thêm sau nếu chủ dự án muốn). Cửa nào đang có cảnh truyện (ví dụ xác phá cửa ở chương 3, cửa đóng/mở theo director) giữ nguyên hành vi đó.
- **Đồ đạc:** **đầy đủ như phòng 407** (giường tầng, nệm, chăn, gối, mùng, bàn học, ghế, tủ, quạt, đèn, đồ sinh hoạt, quần áo, đồ trên bàn, rèm…), **mỗi phòng một khác**, như phòng của các nhóm sinh viên khác nhau: dùng lại đồ phòng 407 (Tripo đã có, Blender đã có) nhưng bày khác, đổi màu chăn, rèm, quần áo, bớt hay thêm đồ cá nhân. Chất lượng ngang phòng 407 (D-166: dựng Blender, không ưng thì chủ dự án đổi Tripo).
- Phong cách nhà B đã duyệt (D-167) cho phần chung; phòng thì theo phòng 407.
- **Mẫu T-252 không đạt:** phòng 4 × 5 m, đồ thưa, cùng một bố cục, rèm và nệm trông mới. Có thể tham khảo script `art_source/graphics_upgrade/realistic_map/floor4_rooms/` trên nhánh `lane-c/T-252-floor4-rooms-sample` nếu hữu ích.

## 2. Hiện trạng (đọc trước)
- Hành lang tầng 4: `art_source/graphics_upgrade/floor4_corridor/` (`corridor_layout.py`: `BAYS`, `DOORS`; `build_corridor.py`), `game/scenes/levels/floor4/corridor.tscn`, `floor4.tscn`. Cửa 401…406 ở x 8, 12, …, 28 và 408 ở x 42 (`RoomDoor`, cánh mở ra hành lang); phòng 407 chiếm x 30…38.
- Phòng 407: `game/scenes/levels/room407/` (`room407.gd`, `room407_furnish.gd`, `game/data/room407/placements.json`), vỏ `art_source/graphics_upgrade/room407_shell/`, đồ `room407_furnished/`, `game/assets/models/graphics_pilot/room407_*`. Cửa 407 mở bằng tay: `Door407`, `DoorLatch407`, `HandTarget`, `DoorHandles` (T-239, T-242).
- Chương 3–4: tầng 4 nằm trong nhà B của khuôn viên (`campus/building_b.tscn`); phòng sâu thêm phải khớp vỏ nhà B nhìn từ ngoài và không đè cầu thang (T-250).
- Kế hoạch đồ hoạ: `art_source/graphics_upgrade/realistic_map/PLAN.md` (A03, ngân sách mục 6).

## 3. Việc
1. **Khảo sát và đề xuất bố cục trước khi dựng** (ghi trong Handoff, có ảnh hoặc sơ đồ): độ sâu 407 thật bao nhiêu, phòng 4 m rộng xếp đồ ra sao cho đủ như 407 (407 rộng 8 m), nhà tắm và ban công đặt thế nào, phía sau nhà có đủ chỗ không (ngoại cảnh chương 1–2, nhà B chương 3–4). Thứ cần chủ dự án chọn thì đưa phương án kèm đề xuất rồi làm theo đề xuất, ghi "chờ chủ dự án chọn".
2. Dựng vỏ phòng (tường, sàn, trần, cửa sổ, nhà tắm, ban công) theo cách vỏ 407; va chạm cho phòng mới.
3. Đồ đạc mỗi phòng một khác, chất lượng 407.
4. **Cửa mở bằng tay và đi vào được** ở mọi chương: dùng lại cách cửa 407 (tay nắm, `HandTarget`, thân Trần Trung có ở chương 1–3). Phần nào ngoài phạm vi lane B (script người chơi, director, `Protagonist`) thì ghi "Yêu cầu thay đổi" cho integrator, không tự sửa.
5. **Nặng máy:** bảy phòng đủ đồ như 407 rất nặng. Chỉ vẽ nội thất phòng khi cửa phòng đó mở hoặc người chơi ở trong; dùng bản nhẹ cho đồ nhỏ. Ghi số tam giác, vật liệu, đèn mới, chỗ nghi nặng. Lane B không đo FPS; **chủ dự án đã cho phép integrator đo FPS khi T-255 xong** (13/11).
6. Ảnh trước/sau 1080p trong chương 1 và chương 3: từ hành lang qua cửa mở, đứng trong từng phòng, nhà tắm, ban công; ảnh ghép tổng.

## 4. Kiểm
- Test mới `game/tests/levels/`: mỗi phòng có vỏ, va chạm, nhà tắm, ban công, đồ; cửa mở được bằng tay ở chương 1–4, người chơi đi vào được (không kẹt); hành lang, cửa, cầu thang, đường đi của quản lý và xác sống không đổi; nội thất ẩn khi cửa đóng.
- Test cũ đạt: `test_floor4*`, `test_corridor_g5*`, `test_room407*`, `test_chapter1`…`test_chapter4`, `test_ch3_*`, `test_t250_*`, `test_graphics_bindings`. Full test và check trước commit cuối.
- Không chạy bot, không đo FPS, không tiêu credit Tripo.

## 5. Được phép sửa
- `art_source/graphics_upgrade/` (thư mục mới cho phòng), `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/floor4/` (hành lang, phòng), `game/scenes/levels/campus/building_b.tscn` (chỉ phần khớp vỏ nhà B với phòng sâu thêm), script cảnh trong `game/scenes/levels/`, `game/data/` chỉ nếu tạo bảng bày đồ riêng cho các phòng (như `room407/placements.json`; báo trong Handoff), test mới `game/tests/levels/`, card này.

## 6. Không được
- Dời cửa, đổi hành lang 44 m, cầu thang, đường đi quản lý và xác sống, luật chơi, cảnh truyện ở các cửa đang có sự kiện.
- Sửa phòng 407; sửa director, script người chơi (ghi "Yêu cầu thay đổi").
- Tripo, credit Tripo; bot, FPS; commit log, video, `anh_chup_sua_loi/`; sửa STATUS, DECISIONS.

## Checklist
- [ ] Khảo sát, đề xuất bố cục (Handoff)
- [ ] Vỏ phòng, nhà tắm, ban công, va chạm
- [ ] Đồ đạc mỗi phòng một khác
- [ ] Cửa mở bằng tay, vào được ở mọi chương
- [ ] Ẩn nội thất khi cửa đóng
- [ ] Ảnh chương 1, 3; test; full test; check; Handoff

## Handoff

### 13/11/2026 — lane B (Claude, Opus 5.5): bước 1, khảo sát và đề xuất bố cục
Nhánh `lane-b/T-255-floor4-rooms-like-407` từ `origin/main` `5388911` (commit card đã đọc: `82631bd`). Lúc mở phiên không có thay đổi dở.

**Đo trên cảnh** (ảnh hiện trạng chương 1 và 3: `art_source/graphics_upgrade/floor4_rooms/previews/before_*`; sơ đồ đề xuất: `previews/plan_proposal.png`):
- **Phòng 407:** rộng 8 m (trong x 30,1…37,9), sâu 6,925 m từ tường hành lang tới mặt trong tường sau, tường sau dày 0,15 m, ban công sâu 1,375 m (lan can tới z −8,55), trần 3 m. Nhà tắm 2,525 × 2,85 m ở góc sau phía đông, cửa 1,0 m. Ban công chỉ sau phần phòng ngủ, cửa 1,0 × 2,3 m. 120 món đồ trong `game/data/room407/placements.json`.
- **Phòng 401–406, 408 hiện nay:** chỉ sâu 5 m (hộp `BackWall_*` ở z −5), không nhà tắm, không ban công. Đồ là vài hộp PS1 (`RoomInterior_*`). 401–406 rộng 4 m (lòng 3,8 m); 408 rộng 6 m (x 38…44).
- **Cửa:** `LockedDoor_*` (`RoomDoor`) đã mang cánh Tripo của 407 (G5). Cánh mở ra hành lang; mở ra được chỉ do director hoặc xác sống (`ZombieDoor`, chương 3–4). Lỗ cửa 0,88 m giữa phòng (401–406), lệch về phía đông ở 408 (x 42).
- **Xác sống chương 3:** sinh ở `RoomSpawns/B4/R4xx` (cửa x, z −1,5), con thứ hai lệch +0,6 m; dải dẫn đường x ±0,65, z −2,5…−0,5. Bày đồ phải chừa trống khoảng này (khung đỏ trên sơ đồ).
- **Phía sau:**
  - Chương 3–4: mặt sau nhà B tầng 1–3 ở z −7,7; tầng 4 hiện là một rãnh tối thụt vào 2,6 m, chỉ ban công 407 nhô ra (`before_ch3_rooms_14_facade_outside`). Phòng sâu như 407 lấp đúng rãnh đó. Không đè cầu thang: tường giếng thang thoát hiểm chạy tới z −6,4, phòng 408 đặt mặt tường đông ở x 43,84 như T-253.
  - Chương 1–2: ngoài ban công 407 là phông `room407_shell/outside.glb`. Phông này có **ban công giả của tầng 4 cứ 8 m một ô**, trùng chỗ ban công thật của 401–406, 408; vách ngăn giả rơi giữa ban công 402, 404, 406, 408.

**Đề xuất (làm theo đề xuất này; những điểm có chữ "chờ chủ dự án chọn" chủ dự án đổi được):**
1. **Độ sâu như 407** cho cả bảy phòng: mặt trong tường sau z −6,925, ban công z −7,075…−8,45, lan can −8,55. Mặt sau tầng 4 thành một hàng ban công liền với 407.
2. **Nhà tắm ở góc sau** như 407. 401–406: lòng 1,8 × 2,85 m. 408: 2,54 × 2,85 m, gần bằng 407. Hai phòng cạnh nhau đối xứng qua tường chung (401|402, 403|404, 405|406 dồn đường nước về một tường), nên phòng chẵn và lẻ khác bố cục. Cửa nhà tắm và cửa ban công là cửa 407 dùng lại (1,0 m), mở bằng tay. **Chờ chủ dự án chọn:** nhà tắm góc sau (đề xuất) hay nhà tắm sát cửa ra vào (không đủ chỗ vì cửa ở giữa phòng 4 m).
3. **Ban công cả bề ngang phòng** (đề xuất: mặt sau liền một dải, nhà tắm có ô cửa thoáng nhìn ra ban công); hay chỉ sau phần phòng ngủ như 407. **Chờ chủ dự án chọn.**
4. **Bày đồ** (sơ đồ):
   - 401–406: 4 sinh viên, hai giường tầng sát hai tường bên (z −0,85…−2,85), bốn tủ sắt hai bên cửa, bàn học dọc tường phía ban công, khu giữa để trống cho xác sống ra.
   - 408: 6 sinh viên, ba giường tầng.
   - Mỗi phòng một nhóm sinh viên khác nhau, dùng lại toàn bộ đồ 407 (Tripo có sẵn, Blender có sẵn), đổi màu chăn, rèm, quần áo (tô lại texture bằng numpy), đổi số và kiểu đồ cá nhân:
     - 401 gọn gàng, học hành;
     - 402 bừa bộn, đồ ăn và máy tính;
     - 403 thể thao;
     - 404 âm nhạc;
     - 405 nửa trống (hai người đã dọn đi, thùng và vali);
     - 406 nấu ăn;
     - 408 đông người, phơi đồ khắp nơi.
   - **Chờ chủ dự án duyệt** chủ đề từng phòng.
5. **Cửa vào phòng mở bằng tay ở mọi chương:**
   - Cách làm: một script tay của lane B trên cánh `RoomDoor`, cách cầm như cửa 407 (`HandTarget` ở tay gạt và mép cánh, `DoorHandles` của lane A chỉ được gọi, không sửa). Cánh vẫn mở ra hành lang như bây giờ. Cửa nhà tắm và ban công dùng `HingedDoor` của lane A như 407.
   - **Chương 3–4:** khi director gắn `ZombieDoor` vào cửa (xác đập cửa), cửa thuộc về director, tay không mở được nữa, để giữ cảnh truyện (D-168). Trước đó người chơi mở được. **Chờ chủ dự án chọn** nếu muốn khoá hẳn các cửa này ở chương 3–4.
6. **Nặng máy:** nội thất mỗi phòng chỉ vẽ khi cửa phòng đó mở hoặc người chơi ở trong. Vỏ và va chạm luôn có.
7. **Phông chương 1–2:** dựng lại `room407_shell/outside.glb`, chỉ bỏ các ban công giả của tầng 4 nơi giờ đã có phòng thật. Phòng 407 và phần phông còn lại giữ nguyên. Phông này là của bộ 407 nên ghi rõ để integrator duyệt.

**Không đổi:** hành lang, vị trí cửa, cầu thang, đường đi quản lý và xác sống, luật, director, script người chơi, phòng 407.
