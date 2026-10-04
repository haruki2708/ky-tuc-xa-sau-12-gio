# T-154 — Mô hình chương 1: quản lý, xác ba bạn cùng phòng, đạo cụ
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-154-ch1-models`
- Phụ thuộc: T-153 (làm ngay sau). Đọc `docs/design/STORY.md` v2 §0, §2, §9.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Mô hình thực thể và đạo cụ cho chương 1, theo phong cách PS1: vật lớn dưới 1500 tam giác, vật nhỏ dưới 500, texture 64–256 px, lọc nearest. Chỉ dùng CC0, CC-BY hoặc tự làm; ghi `CREDITS.md`; asset tạo bằng AI phải ghi công cụ.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Quản lý** (`manager_body.tscn`, dùng làm `body_scene` cho T-152):
   - Người đàn ông cao khoảng 1,95 m, đồng phục quản lý ký túc xá cũ, sờn; mặt chìm trong bóng, chỉ thấy miệng.
   - Tay cầm **dao phay dài**, mũi dao chạm đất.
   - Animation:
     - `walk`: nặng nề, dao kéo lê;
     - `stand`, `ask`: nghiêng đầu về phía giường;
     - `slash`: chém xuống, dùng lặp được nhiều nhát;
     - `lunge`: lao tới;
     - `kill`: kết liễu sát camera.
   - Có một node `BladeTip` (Marker3D ở mũi dao) để lane E đặt nguồn âm kéo dao.
2. **Xác ba bạn cùng phòng** (`corpse_phuc.tscn`, `corpse_viet.tscn`, `corpse_dat.tscn`):
   - Mỗi người dáng và áo khác nhau, nhận ra được: Phúc áo đỏ, Việt áo kẻ, Đạt áo thể thao đen.
   - Tư thế (animation một khung hoặc node con) cho `unseen_poser` của T-152:
     - `dead_a`: nằm như đang ngủ;
     - `dead_b`: tay buông khỏi giường;
     - `head_turn`: đầu quay về phía giữa phòng;
     - `eyes_open`: mắt mở.
   - Tư thế cho chương 2 (làm sẵn nếu kịp): `sit_up` (ngồi dậy, mắt trống rỗng).
   - Máu: texture thấp, đỏ sẫm, không làm chi tiết giải phẫu.
3. **Đạo cụ:**
   - **Cục sạc** điện thoại (đặt trong tủ của Đạt).
   - **Cục phát wifi nhỏ**, đèn nhấp nháy, có `set_led(on)`.
   - **Thẻ sinh viên hoặc sổ tay của Đạt**: mặt chữ đọc được dưới filter PS1, có chỗ ghi ngày sinh để làm mã khóa (integrator chọn mã).
   - **Mảnh vụn giường bị chém**: nệm rách, mút bông, gỗ vụn.
   - **Giẻ lau** (cho chương 2, làm sẵn nếu kịp).
   - **Điện thoại cầm tay** (viewmodel cho T-151 và T-155): màn hình là một mặt phẳng riêng tên `Screen` để lane D đặt texture giao diện.
4. **Đặt vào phòng 407:** xác ở anchor `Corpse1`, `Corpse2`, `Corpse4` (T-153); sạc trong tủ Đạt; đồ trang trí cố định thì đặt luôn. Đồ có hành vi (tủ, cục phát) chỉ đặt scene, integrator nối logic.
5. **Preview và test:**
   - ảnh preview từng mô hình và cảnh phòng có đủ xác;
   - test: load scene, số tam giác, đủ tên animation và tư thế, có `BladeTip`, có `Screen`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md` đủ nguồn
- [ ] Handoff: danh sách scene, animation, API

## Handoff (agent điền)
