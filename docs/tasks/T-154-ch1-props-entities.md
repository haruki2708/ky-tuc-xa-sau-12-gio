# T-154 — Đạo cụ chương 1 và mô hình hai thực thể
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-154-ch1-props-entities`
- Phụ thuộc: T-153 (làm ngay sau). Đọc `docs/design/STORY.md` §3 (màu dép), §5.1, §5.2, §5.5, §10.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Đạo cụ cho các câu đố và cảnh hù của chương 1, và mô hình hai thực thể. Low-poly PS1: vật lớn dưới 1500 tam giác, vật nhỏ dưới 500, texture 64–256 px, lọc nearest. Chỉ dùng CC0, CC-BY hoặc tự làm; ghi `CREDITS.md`.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Đạo cụ** (mỗi món một scene trong `game/scenes/levels/props/`):
   - **TV CRT cũ:** `set_on(bool)` đổi màn hình tối/sáng (emission). Có slot texture để integrator đặt hình hành lang tầng 4 nhìn từ trên cao (§5.5).
   - **Hộp cầu dao:** nắp mở được; 5 cần gạt, mỗi cần có `set_switch(i, on)` cho integrator đồng bộ với panel.
   - **Tủ sắt khóa số 3 vòng:** `set_unlocked(bool)` mở cánh.
   - **Lịch treo tường cũ** (tháng 4/2009, ngày 30 khoanh đỏ, chữ lớn đọc được dưới filter PS1).
   - **Khung ảnh phòng 407 năm 2009:** 5 người low-res, mặt một người bị cào mờ. Có thêm 1 biến thể đổi tư thế để dùng cho cảnh hù "ảnh đổi tư thế".
   - **Dép theo màu:** đỏ (Phúc), xanh dương (Việt), đen (Đạt), xanh lá (Trung), và đôi thứ năm màu xám bạc. Dùng `slippers_pair` hiện có, chỉ thêm tham số màu.
   - **Áo trắng ở sân phơi:** `set_inflated(bool)` phồng lên như có người bên trong.
   - **Đèn vàng sợi đốt:** dùng cho bàn trực các tầng, kèm vùng `safe_light` theo T-153.
   - Đèn chiếu nghỉ cầu thang, nệm cuộn, kệ kho, xích và ổ khóa.
   - **Điện thoại cầm tay** (viewmodel cho T-151 và T-155): màn hình là một mặt phẳng riêng tên `Screen`, để lane D đặt texture giao diện.
2. **Người đi dép** (`walker_body.tscn`):
   - dáng sinh viên gầy, áo thun trắng ngả vàng, quần đùi, dép tổ ong xanh;
   - đầu cúi, mặt chìm trong bóng; dưới 1500 tam giác;
   - animation: `walk` (đi lệch, một chân lết), `run`, `listen` (đứng, quay đầu), `count` (giơ tay chỉ từng giường), `catch` (ngẩng mặt lên sát camera).
   - Có biến thể đổi màu dép theo tham số (đêm 4 có người đi dép thứ hai đi màu dép của bạn cùng phòng).
3. **Người thứ năm** (`watcher_body.tscn`):
   - cao khoảng 1,95 m, đứng thẳng, tay buông, mặt trắng phẳng không có nét;
   - tư thế: `stand`, `head_tilt`, `lunge` (cho jumpscare).
   - Tham số `trung_likeness` 0–1: đổi dần áo sang áo của Trung (dùng cho đêm sau; chương 1 để 0).
4. **Đặt đạo cụ** vào tầng 4–6 theo anchor của T-153 nếu là đồ trang trí cố định. Đồ có hành vi (TV, cầu dao, tủ khóa số) chỉ đặt scene, integrator nối logic.
5. **Preview và test:**
   - ảnh preview từng món và hai thực thể;
   - test load scene, số tam giác, có đủ animation theo tên;
   - các API trên chạy đúng.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md` đủ nguồn; asset tạo bằng AI ghi rõ công cụ
- [ ] Handoff: danh sách scene và API, ảnh preview

## Handoff (agent điền)
