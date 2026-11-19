# Nguồn texture — `realistic_map/wave8/` (T-265)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave8/make_wave8_textures.py` vẽ bằng code (numpy + Pillow,
hàm nhiễu của đợt 3): không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án. Chữ dùng font có
sẵn trong game: Be Vietnam Pro (OFL, `game/assets/fonts/OFL.txt`).

- `mask_floor8.png`, `mask_ceiling8.png`, `mask_walls8.png`: mặt nạ cũ bẩn (UV2) vẽ riêng cho thư viện: sàn và trần ba tầng
  (bẩn sát tường, quanh kệ, bàn, quầy; mòn theo lối đi; nước mưa ở cửa sau; ố trần nhiều hơn ở tầng 3), tường trong ba tầng
  và bốn mặt ngoài (vệt nước dưới cửa sổ, mốc chân tường, tay bẩn ở cửa sau).
- `books.png`: atlas 48 gáy sách (vải, da, giấy; màu phai, vạch nhũ, nhãn số hiệu thư viện chỉ là khối, không chữ đọc được),
  mép giấy và bìa.
- `map_print.png`, `map_drawn.png`: sơ đồ khuôn viên (năm khối nhà đúng chỗ bản đồ PS1 `MapBoard`, thêm giảng đường, nhà thi
  đấu, cổng trường theo tài liệu `ch4_map`; hai vòng bút đỏ đúng đường `FadedCircle*` cũ), bản in và bản vẽ tay.
- `sign_library.png`: biển "THƯ VIỆN" chữ đồng trên nền men đỏ (phương án mặt ngoài E2).
- `washed_stone_*.png`: đá rửa (sỏi nhỏ lộ trong vữa xám), màu, normal, ORM.
- `palette8.png`: ô màu phẳng cho đồ nhỏ (`palette8.json` ở thư mục art_source).

Vật liệu dùng lại của các đợt trước (scan CC0 Poly Haven và texture tự vẽ, nguồn ghi ở CREDITS của từng đợt và
`art_source/graphics_upgrade/room407_corner/CREDITS.md`): sơn trát, gạch ceramic kem và tấm trần của đợt 6, đá mài và sơn
xám của đợt 1, scan bê tông, gỗ bàn cũ, mặt đất, block con sâu, phòng giả của đợt 7.
