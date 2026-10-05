# T-165 — Khu camera an ninh: 4 phòng sinh viên và mô hình sinh viên
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent: Claude (làm thay lane B, chủ dự án yêu cầu 2026-10-05)
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] `CREDITS.md`, ảnh preview từ từng camera
- [x] Handoff: đường dẫn node, tư thế

## Handoff (agent điền)

### Claude làm thay (2026-10-05)
- Chủ dự án yêu cầu Claude làm T-165 thay lane B. Làm thẳng trên `main`.
- **Generator:** `art_source/cctv/build_cctv.py`, dùng lại helper T-153/T-154 và prop kit. Không tải asset ngoài; 6 texture mới 128 px. Chi tiết node và tư thế trong `art_source/cctv/README.md`.
- **Đặt nạn nhân ở tầng trên giường dãy A:** từ camera trần, tầng dưới bị tầng trên và màn che.
- **Sửa core** (`chapter1_director.gd`), tìm ra khi chạy thử trong chương:
  - `walk_to` không truyền đường thì quản lý dùng lộ trình mặc định của tầng 4;
  - navmesh chung là của phòng 407, nên quản lý ở phòng camera đi lạc rồi rơi;
  - cách sửa: quản lý ở phòng camera đi thẳng tới `ManagerSpot`, dùng một bản đồ điều hướng riêng, rỗng; bản đồ được giải phóng khi rời chương.
- **Kiểm chứng:**
  - `test_cctv.gd` 4 test: đủ phòng, camera, anchor; camera thấy giường nạn nhân; đủ 6 tư thế, dưới 1500 tam giác, máu khi chết, điện thoại sáng; chương tạo đủ 5 feed;
  - ảnh từ từng camera và ảnh tab Camera thật trên điện thoại (quản lý vào và giết ở phòng 102) trong `art_source/cctv/previews/`.
- **Chưa làm:** đo FPS lúc mở tab Camera (bot hiệu năng của C cần feed `UPDATE_ALWAYS`; core để `UPDATE_WHEN_VISIBLE`, tức chỉ feed đang xem mới render).

