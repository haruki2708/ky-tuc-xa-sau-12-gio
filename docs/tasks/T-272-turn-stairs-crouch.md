# T-272 — Ba mục còn lại của bước 3: xoay tại chỗ, cầu thang, dáng khom thấp

- Lane: integrator | Trạng thái: **xong (D-196)**: xoay tại chỗ và dáng cầu thang bật mặc định; dáng khom Mixamo thử rồi **không dùng** | Agent: integrator
- **Model:** Mythos 5.2 high (chủ dự án chọn)
- Quyết định nền: D-189, D-190, D-191, D-195, **D-196** ("làm 3 mục còn lại luôn đi, không cần chạy test và check nữa")

## 1. Xoay tại chỗ (bật)
- Trước: khi hướng nhìn lệch thân quá 50°, thân xoay theo và chân phát clip đi bộ chậm.
- Nay: phát clip Mixamo **Left Turn 90 / Right Turn 90** đúng chiều xoay. Công cụ đóng gói bỏ độ xoay khỏi clip (`hips_yaw: strip`, ghi số độ vào meta `turn_degrees`); game vẫn xoay thân ở tốc độ cũ (`TURN_SPEED`), clip chỉ lo bước chân, phát ở khoảng ×1,8 để một clip đi hết một phần tư vòng.
- Cờ: `PlayerBody.mx_turn`.

## 2. Cầu thang (bật)
- Trước: lên xuống cầu thang phát clip đi bộ thường.
- Nay: khi mặt đất đưa người chơi lên hoặc xuống dốc hơn 0,3 m mỗi mét (tới khi dưới 0,15), đi tới hoặc chạy tới phát clip Mixamo **Ascending Stairs / Descending Stairs** (đã bỏ phần cao dần, `hips_y: loop`). Áp dụng cho mọi cầu thang, không riêng chương 3.
- **Giới hạn (nói thẳng):** người chơi leo thang nhanh gấp nhiều lần nhịp bước của clip, nên chân **không đặt đúng từng bậc**; chỉ có dáng nhấc gối khi lên và dáng bước xuống. Đi lùi, đi ngang, đi khom trên thang vẫn như cũ.
- Cờ: `PlayerBody.mx_stairs`.

## 3. Dáng khom thấp (thử, không dùng)
- Clip khom Mixamo cao hơn mức cần: mắt nhân vật ở 1,10 m (đứng khom) và 1,22 m (đi khom), trong khi camera khom ở 1,0 m và dáng khom đang dùng (Quaternius) có mắt ở 0,81–0,84 m.
- Đã thử hạ hông clip Mixamo trong công cụ đóng gói (`lower`: hạ hông, tính lại khớp gối, giữ nguyên mắt cá; lệch 0,0 mm). Phải hạ 25 cm (đứng) và 38 cm (đi) mới vừa camera.
- Kết quả trông tệ hơn bản đang dùng: thành ngồi xổm dạng gối, một tay giơ ngang vai (dáng gốc của clip). Video `build/graphics/motion/t272_khom_cu_moi.mp4`.
- **Giữ dáng khom Quaternius** (`PlayerBody.mx_crouch` vẫn tắt). Các clip khom đã hạ vẫn nằm trong thư viện để ai muốn xem thì bật cờ.
- Muốn có dáng khom Mixamo đẹp thì cần clip khom thấp khác, phải tải thêm từ Mixamo; chủ dự án chưa trả lời có cho tải không.

## 4. Kiểm tra
- Theo D-196 **không chạy full test và check**.
- Đã chạy: `test_t272_turn_stairs.gd` (2 test mới), `test_protagonist_body` (18; sửa một dòng: lúc xoay bước, clip là `turn_left` thay cho `walk`), `test_t268` (9), smoke (1): 30 đạt, 0 hỏng. Trước đó `test_t249` (7) và `graphics_pilot` (3) đạt.
- Cảnh thử: `protagonist_pilot.tscn -- --turn-stairs-demo` (thêm `--no-mx-turn-stairs` để xem bản cũ). Dáng cầu thang mới chỉ thử trên một dốc dựng tạm trong hành lang tầng 4, chưa thử trên cầu thang thật của các màn.
- Video cũ | mới: `build/graphics/motion/t272_xoay_cau_thang_cu_moi.mp4` (23 giây).
