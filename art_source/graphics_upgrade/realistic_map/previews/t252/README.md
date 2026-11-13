# Ảnh duyệt T-252 — phòng 401–406, 408

40 ảnh gốc **1920×1080** từ `chapter1.tscn` và `chapter3.tscn`, Forward+, baseline `bf26f59` (có T-250), ngày 13/11/2026. Xem nhanh: [chương 1](compare_ch1.jpg), [chương 3](compare_ch3.jpg); các phòng/góc còn lại: [chương 1](compare_ch1_remaining.jpg), [chương 3](compare_ch3_remaining.jpg).

- `ch{1,3}_{before,after}_hall_{west,east}_closed.jpg`: camera ngoài hành lang, cửa đóng theo đầu chương. Chỉ thay A03 nên gần như không khác; bàn trực/cầu thang T-250 giữ nguyên ở cả hai phía.
- `ch{1,3}_{before,after}_room_{401,402,403,404,405,406,408}_inspection_torch.jpg`: đứng ngoài cửa, mở riêng cửa đó bằng `RoomDoor.set_open` để kiểm hình. Đèn pin năng lượng 1,5 theo phòng 407.
- `..._room_408_side_inspection_torch.jpg`: góc chéo phụ, cho thấy giường tây và phần rộng hơn của 408.
- **Các ảnh `inspection` là dàn trạng thái cửa để xem đồ, không phải lượt chơi hoặc bằng chứng cửa mở ngay đầu chương.** Director `auto_start=false`; người chơi và HUD ẩn; dùng đèn và môi trường của cảnh chương thật. Không bot, không FPS, không thêm đèn phòng.
- Ảnh trước phục hồi mesh A03 gốc, giữ nguyên G5 và vách 407 mà bản chơi đã ẩn. Cùng camera/đèn/cửa giữa hai phía; không sửa phơi sáng ảnh. Bốn JSON ghi camera, FOV và trạng thái từng ảnh.

Lane C đã tự xem từng góc trước/sau, sửa chăn xuyên nệm và góc phụ 408 bị cánh cửa che rồi chụp lại. Ảnh ghép chỉ giảm kích thước và thêm nhãn, không chỉnh màu/ánh sáng.

**Còn chưa ưng / chờ chủ dự án chọn:** rèm và nệm xanh theo scan Rough Linen có sẵn khá mới; đồ sinh hoạt thưa và nếp vải còn đều hơn phòng 407; các phòng dùng chung bố cục, chỉ bàn/ghế thay vị trí và góc. Mức chi tiết được giữ nhẹ cho góc nhìn ngoài cửa. Chưa kết luận đạt chất lượng ngang toàn bộ phòng 407.

**Yêu cầu thay đổi ngoài phạm vi:** chương 3 vẫn thấy tường PS1 bên đông 408, thuộc `Campus/BuildingB/FireStairs/Wall43.92` (tường kéo cao tới tầng 4), không phải `Corridor/Room408EastWall` đã ẩn. Cần integrator/lane B xử lý mặt hướng vào 408 khi đồng bộ cầu thang với phòng; lane C không sửa `building_b.tscn` và không ẩn node của lane B từ module này. Ảnh chương 1 không có Campus nên không có mảng đó.

Nguồn và cách tái tạo: [`../../floor4_rooms/README.md`](../../floor4_rooms/README.md), [`../../floor4_rooms/CREDITS.md`](../../floor4_rooms/CREDITS.md).
