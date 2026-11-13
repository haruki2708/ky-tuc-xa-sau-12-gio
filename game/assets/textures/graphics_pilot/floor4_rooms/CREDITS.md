# Nguồn texture — `game/assets/textures/graphics_pilot/floor4_rooms/`

T-255 (D-168). Tạo bằng `art_source/graphics_upgrade/floor4_rooms/make_room_textures.py` (numpy, Pillow). Tác giả: dự án (Claude, lane B). Giấy phép: như dự án. Không có ảnh tải ngoài, không dùng ảnh AI.

| File | Là gì |
|---|---|
| `mask_rooms.png` | Mask cũ hoá (bong sơn, bẩn, vệt nước, mốc; sàn: bẩn ron, bẩn, ướt, mòn) của bảy vỏ phòng, cho shader vỏ phòng 407, vẽ bằng code theo mặt bằng từng phòng |
| `blanket_messy_<màu>.jpg`, `blanket_folded_<màu>.jpg`, `pillow_<màu>.jpg`, `shirt_<màu>.jpg`, `curtain_<màu>.jpg` | Bản tô lại màu (giữ sáng tối, đổi sắc độ) của texture chăn, gối, áo (Tripo, phòng 407, `room407_batch2/`) và rèm ban công (`room407_furnished/`). Ảnh gốc theo hồ sơ của chúng: chăn, gối, áo là Tripo trả phí (D-084, hồ sơ ở `art_source/graphics_upgrade/room407_*`); rèm là bản nhuộm vải lanh quét CC0 của T-222 (`art_source/graphics_upgrade/room407_furnished/make_lived_in_textures.py`, nguồn ở `CREDITS.md` cùng thư mục) |
