# Nguồn texture — `realistic_map/wave9/` (T-266)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave9/make_wave9_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án. Chữ dùng font có sẵn trong game:
Be Vietnam Pro (OFL, `game/assets/fonts/OFL.txt`).

- `slat_<giường>_loang.png` (2048 × 1024, giường 1, 2, 4): mặt dưới vạt giường (gỗ thông mộc) và chữ của mảnh phiếu bằng
  mực loang (bút dạ thấm vân gỗ, quệt nhòe; D-187). Lượt 1 có thêm ba kiểu `bi`, `khac`, `phieu` cho giường 2 (hình mẫu),
  lượt 2 đã xoá khỏi game (vẽ lại được bằng `make_wave9_textures.py --pilot`). Chữ đúng mảnh phiếu của UI lane D
  (`UI_CH4_FORM_SCRAP_1/2/4`, cột của `ch4_form.gd`, `FORM_FIELDS` của director).
  Vân gỗ lấy từ scan **Wood Table Worn** của Poly Haven (Dimitrios Savva, Rico Cilliers, **CC0**, đã có trong game:
  `assets/models/graphics_pilot/room407_corner/study_desk_wood_table_worn_color.jpg`; nguồn ghi ở
  `art_source/graphics_upgrade/room407_corner/CREDITS.md`), tẩy màu, nhuộm vàng, thêm vân sọc và mắt gỗ bằng code.
- `slat_plain.png`: gỗ thông mộc không chữ (cạnh vạt, dằm gỗ ở lỗ cửa).
- `door_cracks.png` (RGBA): vết nứt toác, dằm gỗ, vết móp trên mặt trong cánh cửa 407 (tâm ở chỗ lỗ thủng).
- `zombie_skin.png`: da tay xác thò qua cửa (tái, lốm đốm, bầm, máu khô).
- `nurse_shadow.png` (RGBA): bóng mờ hai người đứng yên sau rèm (Y1, D-187; không thêm đèn). Lượt 2 vẽ lại: bên trái
  y tá nghiêng, tóc búi, cầm bệnh án kẹp trên bìa; bên phải đứng ba phần tư, một tay buông, một tay đút túi áo.
- `blanket_check.png` (1024 px cho 0,5 m): chăn mỏng xanh nhạt kẻ ô đôi, sợi dệt thưa (lượt 2 vẽ lại mịn hơn).
- `bandage.png` (lượt 2): băng gạc chun quấn cẳng tay Trung (T1), các vòng quấn chéo, ố nhẹ.
- `screen_mesh.png` (RGBA): lưới chắn côn trùng sau cửa chớp thông gió (bám bụi); cũng là lưới đầu rèm bệnh viện.
- `monitor_screen.png`: màn hình máy theo dõi (nền tối, đường nhịp tim xanh, số đo), chỉ thấy từ góc phòng.

Mọi `.import` ở đây: `compress/mode=2` (nén VRAM), mipmap bật (card T-266 mục 5; test `test_t266_assets.gd`).

Dùng lại (nguồn ghi ở CREDITS của từng đợt): cánh cửa phòng 407 của game (`room407_shell/doors/door_room.glb` và ba map
của nó: mô hình Tripo AI gói trả phí, D-084, hồ sơ ở `art_source/graphics_upgrade/room407_shell/CREDITS.md`) được cắt lỗ và
giảm lưới bằng Blender cho mức "thủng" (không tạo mới trên Tripo); vải rèm `floor4_rooms/curtain_*.jpg`; sơn trát, gạch
ceramic, tấm trần của đợt 6; sơn xám của đợt 1; vật liệu dùng chung W1/W2/W6/W8 và `floor4_rest` (WRVent ở lượt 1).
Lượt 2: `W9Hoodie` (tay áo hoodie xám rách của tay xác) là scan vải `floor4_rooms/curtain_grey.jpg` nhuộm tối;
`W9VentPaint` (sơn cửa chớp ám muội) là màu trơn với `paint_grey_normal.png` của đợt 1. Không thêm nguồn ngoài.
