# T-203 — nguồn hình học và ảnh kiểm tra

- `game/scenes/levels/room407/khoa_outlet.tscn`: hình học gốc do Lane B / Codex (OpenAI) viết bằng Python stdlib; CC0-1.0. Nguồn: [build_fixes.py](https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio/blob/lane-b/T-203-ch1-room407-fixes/art_source/room407_fixes/build_fixes.py).
- `previews/*.png`: ảnh render Godot 4.7.2 của scene tầng 4 hiện có; CC0-1.0. Fixture: `res://scenes/levels/room407/room407_fixes_capture.tscn`. Có ánh sáng kiểm tra bổ sung trong fixture, không thay ánh sáng game.
- Va chạm BunkB bám kích thước khung CC0 từ `art_source/kit/build_kit.py`; giữ nguyên GLB. BunkA không đổi.
- Khai báo AI: Codex viết mã, hình học thủ tục, test và tài liệu; không dùng công cụ sinh ảnh, asset tải ngoài hoặc plugin.

Dựng lại lưới và ổ điện bằng Python sẵn có trên ổ D:

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/room407_fixes/build_fixes.py
```

Lưới biểu diễn tâm capsule bán kính 0,35 m, cao 1,9 m. Đường qua cửa cần cửa mở; T-203 không quyết định quản lý được mở cửa lúc nào. Lưới tránh giường, bàn, ghế, tủ lạnh và mép cửa. Generator chỉ cập nhật tài nguyên lưới trong `room_407.tscn` và scene ổ điện.
