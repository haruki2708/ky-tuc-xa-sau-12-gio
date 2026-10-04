# T-165 — Khu camera an ninh: 4 phòng sinh viên và mô hình sinh viên
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-165-cctv-rooms-students`
- Phụ thuộc: T-153, T-154; làm **ngay sau T-162**. Đọc mục "Camera an ninh" trong `docs/design/CH1_V2_MISSIONS.md` (D-041).
- **Hạn: sáng 2026-10-07.**

## Mục tiêu
Ở vòng 2, người chơi xem qua camera an ninh trên điện thoại cảnh quản lý giết bốn bạn trong cuộc gọi. Lane B dựng nơi diễn ra và các nhân vật. Core dàn cảnh: đặt quản lý (T-152), cho sinh viên đổi tư thế, nối camera vào điện thoại.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Scene `res://scenes/levels/cctv/cctv_set.tscn`**, đặt xa tòa nhà (ví dụ Y = −60), gồm 4 **phòng tiêu chuẩn**:
   - dùng lại khung phòng 407 cũ 4×5 m: 2 giường tầng, 4 tủ, bàn, cửa;
   - bày đồ khác nhau, có biển số phòng: **102** (Hùng), **306** (Kiệt), **209** (Bảo), **106** (Đăng);
   - mỗi phòng có:
     - `Camera3D` tên `Cam` ở góc trần (góc nhìn camera an ninh, thấy cửa và giường của nạn nhân);
     - anchor `Door`, `VictimBed`, `ManagerSpot`;
     - ánh sáng riêng; phòng 106 có **đèn bàn sáng**, các phòng khác tối.
   - Thêm **một đoạn hành lang tầng 4 giả** có `Cam` nhìn về phía cửa 407 (camera hành lang).
2. **Mô hình 4 sinh viên còn sống** (`student_hung.tscn`, `student_kiet.tscn`, `student_bao.tscn`, `student_dang.tscn`), dưới 1500 tam giác, khác nhau rõ (dáng, áo, tóc). Tư thế (animation một khung hoặc ngắn):
   - `lie_awake` (nằm thức), `sit_up` (ngồi dậy), `answer` (giơ tay "dạ có"), `phone_lit` (cầm điện thoại sáng màn hình; màn hình phát sáng), `cower` (co ro, run), `dead` (gục, máu).
   - Kiệt có điện thoại phát sáng; Đăng ngồi dưới đèn bàn.
3. Máu me theo phong cách PS1 như T-154, không chi tiết giải phẫu.
4. **Test và preview:** scene load; đủ phòng, camera, anchor; đủ tên tư thế; ảnh nhìn từ từng `Cam`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md`, ảnh preview từ từng camera
- [ ] Handoff: đường dẫn node, tư thế

## Handoff (agent điền)
