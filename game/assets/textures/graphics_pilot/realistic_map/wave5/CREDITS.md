# Nguồn texture — `realistic_map/wave5/` (T-262)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave5/make_wave5_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Chữ trên biển đặt bằng Be Vietnam Pro SemiBold (OFL, có sẵn trong `game/assets/fonts/`).
`booth_atlas.png` cắt một góc hai scan đã có trong game (Wood Table Worn, CC0 Poly Haven; terrazzo tự vẽ của đợt 1).
Tác giả: dự án (Claude, lane B). Giấy phép: như dự án.

- `asphalt_*`: nhựa đường cũ của lòng đường ngoài cổng: đá lộ, nứt chân chim, miếng vá.
- `sign_text.png`: biển tôn xanh có chữ "TRƯỜNG ĐẠI HỌC" (tên trường đã bong, còn vết keo).
- `barrier_stripes.png`: sọc đỏ trắng của rào chắn. `ground_crack.png`: vết nứt sân (có alpha).
- `bars_card.png`: song sắt của tường nhìn từ xa (có alpha).
- `booth_atlas.png`: đồ trong chốt bảo vệ gộp một texture (gỗ bàn, sàn, trang sổ, lịch không chữ, các ô màu).
- `mask_court.png`: mặt nạ sân cổng và lối lát (UV2 trên hộp A16 và dải ngoài cổng): vệt bánh xe, bẩn, vũng nước, mòn.
- `mask_strip5.png`: mặt nạ cỏ dải A16 đoạn cổng: đất trọc ở mép lối, đường xác đi, quanh gốc cây; ướt chân tường.
- `mask_gate.png`: mặt nạ cũ bẩn của tường rào, hai trụ, chốt bảo vệ (UV2).
