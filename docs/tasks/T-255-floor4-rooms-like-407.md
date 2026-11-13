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
(lane B điền)
