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
- [x] Khảo sát, đề xuất bố cục (Handoff)
- [x] Vỏ phòng, nhà tắm, ban công, va chạm
- [x] Đồ đạc mỗi phòng một khác
- [x] Cửa mở bằng tay, vào được ở mọi chương
- [x] Ẩn nội thất khi cửa đóng
- [x] Ảnh chương 1, 3; test; full test; check; Handoff (full test 970/5: 5 test lane A cần integrator, xem Handoff)

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

### 13/11/2026 — lane B (Claude, Opus 5.5): bước 2, dựng xong bảy phòng
Commit: `97ddc6a` (vỏ, va chạm, đồ, cửa tay, test), `ef57058` (ẩn đồ ban công, sửa xung đột với `test_floor4`, `test_corridor_g5`, README, CREDITS), `24a36b0` (nén texture vì chương 3 hết VRAM, ảnh sau, ảnh ghép), `b61665c` (sửa sau full test lần 1), commit cuối (Handoff). Nhánh đã push.

**Đã làm (theo đề xuất bước 1):**
- **Vỏ phòng** `art_source/graphics_upgrade/floor4_rooms/` (`build_rooms.py`, Blender) → `game/assets/models/graphics_pilot/floor4_rooms/room_<n>.glb`:
  - sâu như 407 (mặt trong tường sau z −6,925, ban công tới lan can −8,55, trần 3 m);
  - nhà tắm góc sau, hai phòng cạnh nhau đối xứng; ốp gạch tới 1,8 m, sàn chống trơn, phễu thoát nước, ô cửa lá sách nghiêng nhìn ra ban công;
  - khung cửa xanh như 407, len chân tường, đèn tuýp (tắt), công tắc, dây phơi trong phòng và ngoài ban công;
  - ban công cả bề ngang phòng, vách ngăn 2 m, lan can và gờ, trần ban công.
  - Vật liệu: shader vỏ 407 với mask cũ hoá vẽ bằng code theo mặt bằng từng phòng (405 bỏ trống cũ nhất).
- **Va chạm** (`game/scenes/levels/floor4/floor4_rooms.gd`): hộp cho tường, sàn (`RoomFloor`, `surface = tile`), trần, nhà tắm, ban công, đồ cứng (giường, tủ, bàn, ghế đẩu, kệ, tủ lạnh, bồn cầu…). Phòng PS1 cũ (`Floor_`, `BackWall_`, `Ceiling_`, `RoomInterior_`, `Room408BackWall`) bị ẩn và tắt va chạm, không xoá. Vách ngăn, cửa (`RoomDoor`, `Blocker`), hành lang, cầu thang giữ nguyên.
- **Đồ đạc** (`make_placements.py` → `game/data/floor4_rooms/rooms.json`, bảng bày đồ riêng như `room407/placements.json`; **báo integrator vì nằm trong `game/data/`**):
  - Số món: 401: 79, 402: 79, 403: 79, 404: 70, 405: 52, 406: 74, 408: 90.
  - Toàn bộ là đồ có sẵn của 407. Chăn, gối, áo, rèm tô lại màu theo từng phòng.
  - Chủ đề: 401 gọn gàng, học (hai bàn, kệ sách); 402 bừa, đồ ăn, máy tính, chiếu và bàn gấp; 403 bóng đá (bóng, giày, mũ bảo hiểm, poster); 404 âm nhạc (ba đàn guitar, tai nghe); 405 nửa trống (giường trơ, vali, thùng, tủ mở trống); 406 nấu ăn (nồi cơm, nồi, ấm, tủ lạnh, bình nước, mâm cơm); 408 sáu người (ba giường, sáu tủ, giá phơi, đồ phơi khắp nơi, hai quạt trần).
  - Script tự kiểm: không đồ cứng nào trong ô xác sống ra (chương 3), không xuyên tường.
- **Bố cục thực tế (khác sơ đồ bước 1 ở chi tiết, vẫn theo đề xuất):**
  - Giường tầng z −1,5…−3,5 sát hai tường bên; bốn tủ trên tường bên cạnh cửa (z −0,1…−1,5); bàn học dọc tường phía không có nhà tắm ở nửa sau phòng.
  - Cửa nhà tắm sát vách nhà tắm (để đi qua chân giường vào được); cửa ban công cách tường bên 0,75 m.
  - 408: hai giường dọc tường đông, phía sau ô xác sống; một giường tường tây (z −1,85…−3,85, chừa chỗ cho test tường 407|408 ở (39; −1,5)); sáu tủ; cửa ban công giữa phòng.
- **Cửa:**
  - Cửa phòng: `room_door_hand.gd` (`RoomDoorHand`) cưỡi trên cánh Tripo, tay gạt nhận tay (`DoorHandles` của lane A, chỉ gọi). Cánh vẫn mở ra hành lang. `RoomDoor.set_open(open, seconds = 0.3)` thêm thời gian xoay (mặc định như cũ).
  - Khi core gắn `ZombieDoor` (chương 3–4): tay tắt; cửa đang mở bằng tay sẽ tự đóng khi không ai đứng ở ô cửa, để xác còn phá cửa.
  - Cửa nhà tắm và cửa ban công: `room_hinge.gd` + `HingedDoor` của lane A, lá cửa Tripo của 407 và tay gạt. Đóng khi bắt đầu chương; cửa ban công mở ra, áp vào mặt tường phía nhà tắm.
  - **Chương không có thân Trần Trung (chương 4)**, làm như cửa 407: cửa phòng mở bằng bấm thường (không tay gạt); cửa nhà tắm và cửa ban công để mở sẵn, không gắn `HingedDoor`. Floor4Rooms đọc `protagonist_body` của gốc chương.
- **Nặng máy:**
  - Nội thất mỗi phòng (vỏ trong, đồ, cửa nhà tắm) chỉ vẽ khi cửa phòng mở hoặc đang xoay, hoặc camera ở trong phòng hay trên ban công phòng đó.
  - Đồ trên ban công vẽ cùng nội thất, hoặc khi camera ở sau mặt nhà trong vòng 25 m.
  - Mặt sau nhà, ban công, cửa ban công luôn vẽ.
- **Phông chương 1–2** (`room407_shell/build_outside.py`, `outside.glb`): bỏ các ô ban công giả tầng 4 ở x 6…30 và 38…46 (giờ là phòng thật), bỏ sàn ô tầng 5 trùng trần ban công thật, thêm tường trơn x 44…46. Các ô khác giữ nguyên số ngẫu nhiên (đồ phơi, đèn sáng). **Thuộc bộ 407, integrator duyệt.**
- **README, CREDITS:** `art_source/graphics_upgrade/floor4_rooms/README.md`; CREDITS ở `game/assets/models/graphics_pilot/floor4_rooms/` và `game/assets/textures/graphics_pilot/floor4_rooms/`. Không Tripo, không ảnh AI cho phần mới.

**Số liệu nặng máy (để integrator đo FPS, D-168):**
- Vỏ: khoảng 1.270 tam giác mỗi phòng.
- Nội thất khi đang vẽ: khoảng 270.000 (405) đến 430.000 (408) tam giác, vì đồ Tripo của 407 nặng (gối, áo, ổ cắm khoảng 4.900; tủ, giường, bàn khoảng 7.800). Godot tự giảm chi tiết đồ ở xa (`meshes/generate_lods=true` sẵn có).
- Đồ ban công: 13.000–55.000 tam giác mỗi phòng, đã ẩn khi không thấy.
- Không thêm đèn mới. Vật liệu mới: 17 `F4*.tres`, mask 4096² và 40 ảnh vải 1024², đều nén VRAM.
- **VRAM (đo trong cảnh chụp, RTX 3050 Laptop 4 GB):** chương 1 khoảng 3.500 MB; chương 3 khoảng 3.660 MB, trước T-255 là 3.574 MB.
  - Lúc đầu texture mới để dạng không nén, chương 3 lên 3.950 MB và **màn hình đen hẳn**. Đã nén VRAM cho texture phòng và 6 texture 2048² của lá cửa nhà tắm, cửa ban công (`room407_shell/doors/door_bathroom_*`, `door_balcony_*`; chỉ phòng mới dùng, chỉ đổi file `.import`).
  - **Rủi ro chung, ngoài T-255:** chương 3 trước T-255 đã dùng gần 90% VRAM. Nhiều texture Tripo của 407 cũng để không nén (ví dụ `room407_batch2/*_basecolor.png.import` `compress/mode=0`). Đề nghị một task nén VRAM các texture đó.
- Chỗ nghi nặng: đứng ở hành lang mở hai cửa liền nhau (hai nội thất cùng lúc); đèn pin có bóng đổ chiếu vào phòng đầy đồ.

**Test:**
- Test mới `game/tests/levels/test_t255_floor4_rooms.gd`: 12/12 đạt. Gồm:
  - độ sâu như 407, tường sau, lan can, sàn tile;
  - cửa nhà tắm và ban công mở/đóng bằng tay, đúng hướng;
  - cửa phòng mở/đóng bằng tay, tay gạt nhận tay, ô cửa thông/chặn;
  - cửa có `ZombieDoor` thuộc về chương (tắt tay, tự đóng, chờ người ra khỏi ô cửa);
  - nội thất và đồ ban công ẩn/hiện đúng lúc;
  - mỗi phòng một khác, vải đúng màu;
  - phòng PS1 tắt, vách ngăn và `Blocker` giữ nguyên;
  - ô xác sống ra trống;
  - thân người chơi đi vào nhà tắm và ra ban công ở cả bảy phòng;
  - không va chạm nhà B nào nằm trong phòng (chương 3–4);
  - cả bốn chương dùng `floor4.tscn` có phòng;
  - chương không có thân: bấm thường, cửa trong để mở.
- Test cũ chạy theo bộ lọc, đạt hết trừ một (xem dưới): `test_floor4` 9/9, `test_corridor_g5` 9/9, `test_room407` 76/76, `test_ch1v2` 33/33, `test_t250` 5/5, `test_t254` 4/4, `test_graphics_bindings` 8/8, `test_chapter1` 49/49, `test_chapter2` 20/20, `test_chapter3` 22/22, `test_chapter4` 14/14, `test_ch3_` 45/45, `test_protagonist` 25/26.
- Full test lần 1 (trước `b61665c`): 968 đạt, 6 hỏng; check 0 lỗi. Đã sửa phần của lane B:
  - `RoomDoorHand` thiếu `is_open`: `PlayerBody.perform` báo lỗi script khi thân đóng cửa phòng;
  - `test_room_doors`: giường và tủ 408 chạm điểm thử tường 407|408;
  - `test_t241_reach` `Ch1VietPhoto` lệch 0,050 m (ngưỡng 0,05): 7 cửa ban công mới chen vào thứ tự test. Tay cửa ban công giờ ẩn/hiện cùng nội thất phòng.
- Sau khi sửa, chạy lại theo bộ lọc: `test_t255` 12/12, `test_room_doors` 4/4, `test_t241_reach` 6/7 (chỉ còn `WallKnock406`), `test_ch2_4_hand_targets` 0/3 (chỉ còn `RoomDoorHand` chưa phân loại, xem Yêu cầu thay đổi).
- **Full test lần 2 (sau `b61665c`): `RESULT: 970 passed, 5 failed`. Check: `RESULT: check 0 error(s)`.** Không có lỗi script. Năm test hỏng đều là test của lane A và đúng hai nguyên nhân dưới đây:
  - `WallKnock406`: `test_protagonist_chapter1` 1 test, `test_t241_reach` 1 test;
  - `RoomDoorHand` chưa phân loại: `test_ch2_4_hand_targets` 3 test, 21 dòng (7 cửa × chương 2, 3, 4).

**Lỗi test cũ không sửa được trong phạm vi lane B (test của lane A, `game/tests/player/`):**

(1) `test_protagonist_chapter1.gd::test_every_hand_thing_can_be_reached_from_a_standing_spot` và `test_t241_reach.gd::test_what_stands_at_desk_height_or_higher_is_taken_standing_still` cùng báo `WallKnock406` (chỗ gõ tường sang 406 trong phòng 407, room-local (0,12; 1,3; −1,65)) không với tới được.
- Đã đo bằng probe tạm (đã xoá): trước T-255, cả 51 chỗ đứng với tới được đều ở x 29,5–29,6, tức **trong phòng 406, với qua tường**. Không chỗ nào trong 407 với tới được.
- Lý do: trong 407, chỗ đứng giữa tủ của Việt và giường A chỉ rộng 0,4 m, người chơi rộng 0,6 m.
- Giờ 406 có giường tầng ở đúng chỗ đó nên test lộ ra. **Trong game thật** (thân Trần Trung, chương 1) chỗ gõ này có lẽ đã không dùng được từ trước, vì `player.gd` bỏ thứ tay không với tới.

(2) `test_ch2_4_hand_targets.gd` (ba test chương 2, 3, 4) báo `unclassified interactable: .../Corridor/LockedDoor_40x/Hinge/Hand`.
- Test này liệt kê mọi loại vật tay trong chương; cửa phòng mở bằng tay (D-168) là loại mới `RoomDoorHand`.
- Không đổi được từ phía lane B mà vẫn giữ D-168 (cửa phòng mở được ở mọi chương).

**Yêu cầu thay đổi (integrator):**
1. `WallKnock406` (lỗi (1)), chọn một trong hai:
   - (a) **đề xuất:** dời mốc `WallKnock406` (`room407_anchors.tscn`, phòng 407, ngoài phạm vi T-255) tới chỗ đứng được trên cùng bức tường, ví dụ phía trên đầu giường A hoặc sát cửa;
   - (b) lane A sửa test chỉ tìm chỗ đứng cùng phía tường với vật (trong 407). Cách này không sửa được lỗi trong game.
2. Lane A, `test_ch2_4_hand_targets.gd` `_check_inventory` (lỗi (2)): phân loại `RoomDoorHand` như `Door407`:
   - có thân: `hand_target()` khác null, `grips.size() == 3` (hai tay gạt và mép cánh);
   - không thân: `hand_target() == null`.
3. Tuỳ chọn, cho director: `chapter3_director._open_room` có thể bỏ qua phòng khi người chơi đang ở trong phòng đó. Hiện chỉ 408 (sau khi lấy chìa) có thể gặp; xác sẽ sinh ngay cạnh người chơi.
4. Duyệt `outside.glb` (bộ 407) và file `.import` của 6 texture lá cửa trong `room407_shell/doors/` (chỉ đổi cách nén).

**Chờ chủ dự án chọn (giữ từ bước 1, đã làm theo đề xuất):**
- nhà tắm góc sau;
- ban công cả bề ngang;
- chủ đề từng phòng;
- khoá hẳn cửa phòng ở chương 3–4 hay không.

Thêm:
- Cánh cửa phòng mở ra hành lang không có va chạm (như trước T-255): quản lý, xác, người chơi đi xuyên qua cánh đang mở. Thêm va chạm sẽ đổi đường đi của quản lý, nên chưa làm.
- Phòng không có đèn riêng (đèn tuýp tắt), chỉ đèn pin và ánh hành lang.

**Ảnh** (`art_source/graphics_upgrade/floor4_rooms/previews/`):
- trước: `before_ch1_*`, `before_ch3_*`;
- sau: `after_ch1_*` (17), `after_ch3_*` (18);
- ghép: `compare_ch1.jpg`, `compare_ch3.jpg`, `new_views_ch1.jpg`, `new_views_ch3.jpg`, `overview.jpg` (tổng quan cho chủ dự án).

**Cách kiểm tra:**
- `pwsh tools/test.ps1 -Filter test_t255`.
- Chơi chương 1: ra hành lang, mở cửa 401–406, 408 bằng tay, vào nhà tắm, ra ban công.
- Chương 3: phòng tầng 4 vẫn bị xác phá cửa như cũ.
- Chụp lại: chép `capture_t255.gd` vào `game/_probe_tmp/` (xem đầu file; có `--rooms=off`, `--hide=`, ghi VRAM).
