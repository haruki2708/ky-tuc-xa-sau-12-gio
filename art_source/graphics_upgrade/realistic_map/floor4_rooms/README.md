# T-252 — mẫu phòng tầng 4 bằng Blender

Card đọc tại `a64361d`; baseline `origin/main=a64361d`. Chỉ nâng A03, không đổi đèn, cửa G5, collider, navigation hay director.

- Phòng 401–406: module 4 × 5 m, tâm X lần lượt 8, 12, 16, 20, 24, 28. Phòng 408: module 6 × 5 m, X=38…44, cửa thật vẫn X=42. Tường sau Z=−5, sàn Y=0, trần Y=3.
- Hai giường tầng sắt xanh; bàn gỗ có ngăn kéo, sách, cốc và đèn không phát sáng; tủ có khe thông khí/tay kéo; ghế và rèm gom hai bên cửa sổ. Giường tây/nội thất cũ giữ collider; đồ mới không thêm collider. Không đổi quyền ra vào phòng.
- Vỏ luôn vẽ để không thủng mặt nhà khi nhìn từ Campus. Đồ trong `Furnishings` chỉ hiện khi cửa mở hoặc còn đang khép. Cơ chế chỉ đọc `RoomDoor.is_open` và góc bản lề, không ghi trạng thái cửa. Không nhân shader vỏ phức tạp của 407.
- Mỗi phòng đổi vị trí bàn/ghế, góc ghế; giường thứ hai quay 180°. Bộ GLB và 8 vật liệu được dùng chung. Cửa sổ đêm là mặt kín đặt trước vách cũ, không tạo lỗ đi được.
- Màu, kiểu đồ, mức cũ chọn gần bộ CC0 phòng 407; **chờ chủ dự án chọn**. Đây là mẫu để duyệt, chưa chứng minh chất lượng ngang toàn bộ đồ Tripo 407 hoặc ngân sách A03–04 ≤0,35 ms; không đo FPS theo chỉ đạo.

## Dựng và kiểm tra

```powershell
& D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rooms/build_rooms.py
pwsh art_source/graphics_upgrade/realistic_map/floor4_rooms/run_stage.ps1 -Stage import
pwsh art_source/graphics_upgrade/realistic_map/floor4_rooms/run_stage.ps1 -Stage capture -State before
pwsh art_source/graphics_upgrade/realistic_map/floor4_rooms/run_stage.ps1 -Stage capture -State after
pwsh art_source/graphics_upgrade/realistic_map/floor4_rooms/run_stage.ps1 -Stage test
pwsh art_source/graphics_upgrade/realistic_map/floor4_rooms/run_stage.ps1 -Stage full
```

`install_visuals.py` chỉ dành cho áp vào corridor baseline chưa có T-252, từ chối thêm trùng. `build_rooms.py` tái sinh 7 GLB và `geometry_report.json`; số tam giác là LOD0, chưa tính giảm theo camera. Rèm thuộc nhóm đồ ẩn khi đóng cửa. Không lưu `.blend` trùng: script là nguồn chỉnh sửa.

Runner chờ khóa mỗi 30 giây, tạo bằng CreateNew, chỉ xóa khóa có token của mình. Log ở `build/t252/`. Cảnh chụp được chép tạm vào `game/_probe_tmp/` rồi xóa trong finally.

## Cách đọc ảnh

`../previews/t252/`: chương 1 và 3 thật, 1920×1080, camera/đèn giữ giống nhau trước–sau. Director không chạy, người chơi/HUD ẩn. Hai góc hành lang giữ trạng thái cửa đóng đầu chương. Bảy góc `inspection_torch` mở riêng từng cửa bằng API sẵn có để kiểm tra hình; **không phải ảnh chứng minh cửa đó mở đầu chương hoặc một lượt chơi thật**. Ảnh trước phục hồi đúng các mesh PS1 A03 và ẩn module mới, giữ G5/cửa/ánh sáng hiện hành. JSON ghi camera và trạng thái của từng ảnh. Đèn pin theo giá trị phòng 407 (1,5), không nâng ánh sáng cảnh.

Nguồn: [CREDITS.md](CREDITS.md). Số đo: [geometry_report.json](geometry_report.json).
