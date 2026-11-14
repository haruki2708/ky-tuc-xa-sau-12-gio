# Nguồn texture — `realistic_map/wave4/` (T-261)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave4/make_wave4_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án (CC0 trong nội bộ dự án).

- `track_rubber_*`: đường chạy cao su đỏ bạc màu, hạt, vết nứt, miếng vá (D-178 R1).
- `roof_sheet_*`: tôn kẽm sóng, ô-xít trắng, vệt rỉ dưới bu lông xà gồ.
- `chainlink.png`: lưới B40 (có alpha). `net.png`: lưới khung thành (có alpha).
- `mask_field.png`: mặt nạ nền sân (UV2 trên `TrackBounds`): đất trọc, ướt, cỏ úa.
- `mask_stand.png`: mặt nạ cũ bẩn hai khán đài và trụ cổng cho `room407_shell.gdshader` (UV2).
- `palette.png`: ô màu phẳng của đồ rải trong sân (màu PS1 của túi, giày, dép, điện thoại, khay; sọc rào vượt).
- `mask_strip4.png`, `mask_road.png`: mặt nạ bãi cỏ mòn và đường gạch của dải nối vườn → sân (UV2 trên hộp A16).
Cỏ thật và đất dùng lại `wave3/ground_grass_*`, `wave3/soil_*`; gạch block dùng lại `wave3/paving_block_*`.

Mọi file từ 512 px trở lên nhập nén VRAM (`compress/mode=2`, normal thêm `compress/normal_map=1`, mipmap bật).
