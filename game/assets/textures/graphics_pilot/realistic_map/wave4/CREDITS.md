# Nguồn texture — `realistic_map/wave4/` (T-261)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave4/make_wave4_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án (CC0 trong nội bộ dự án).

- `track_rubber_*`: đường chạy cao su đỏ bạc màu, hạt, vết nứt, miếng vá (R1). `track_cinder_*`: đường chạy xỉ than (R2).
- `turf_*`: cỏ nhân tạo cũ, sợi xẹp, hạt cao su (C2). Cỏ thật (C1) dùng `wave3/ground_grass_*` và `wave3/soil_*`.
- `roof_sheet_*`: tôn kẽm sóng, ô-xít trắng, vệt rỉ dưới bu lông xà gồ.
- `chainlink.png`: lưới B40 (có alpha). `net.png`: lưới khung thành (có alpha).
- `mask_field.png`: mặt nạ nền sân (UV2 trên `TrackBounds`): đất trọc, ướt, cỏ úa, cỏ nhân tạo mòn.
- `mask_stand.png`: mặt nạ cũ bẩn khán đài và trụ cổng cho `room407_shell.gdshader` (UV2).

Mọi file từ 512 px trở lên nhập nén VRAM (`compress/mode=2`, normal thêm `compress/normal_map=1`, mipmap bật).
