# Nguồn texture — `realistic_map/wave9/` (T-266)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave9/make_wave9_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án. Chữ dùng font có sẵn trong game:
Be Vietnam Pro (OFL, `game/assets/fonts/OFL.txt`).

- `slat_<giường>_<kiểu>.png` (2048 × 1024): mặt dưới vạt giường (gỗ thông mộc) và chữ của mảnh phiếu, bốn kiểu:
  `loang` (bút dạ thấm vân gỗ, quệt nhòe), `bi` (bút bi xanh tô đè), `khac` (khắc bằng vật nhọn), `phieu` (mảnh phiếu
  photocopy dán, điền bút bi). Giường 2 đủ bốn kiểu; giường 1 và 4 kiểu `loang`. Chữ đúng mảnh phiếu của UI lane D
  (`UI_CH4_FORM_SCRAP_1/2/4`, cột của `ch4_form.gd`, `FORM_FIELDS` của director).
  Vân gỗ lấy từ scan **Wood Table Worn** của Poly Haven (Dimitrios Savva, Rico Cilliers, **CC0**, đã có trong game:
  `assets/models/graphics_pilot/room407_corner/study_desk_wood_table_worn_color.jpg`; nguồn ghi ở
  `art_source/graphics_upgrade/room407_corner/CREDITS.md`), tẩy màu, nhuộm vàng, thêm vân sọc và mắt gỗ bằng code.
- `slat_plain.png`: gỗ thông mộc không chữ (cạnh vạt, dằm gỗ ở lỗ cửa).
- `door_cracks.png` (RGBA): vết nứt toác, dằm gỗ, vết móp trên mặt trong cánh cửa 407 (tâm ở chỗ lỗ thủng).
- `zombie_skin.png`: da tay xác thò qua cửa (tái, lốm đốm, bầm, máu khô).
- `nurse_shadow.png` (RGBA): bóng mờ hai người đứng (phương án Y1, in trên rèm; không thêm đèn).
- `blanket_check.png`: chăn mỏng kẻ xanh nhạt của phòng bệnh.
- `screen_mesh.png` (RGBA): lưới chắn côn trùng sau cửa chớp thông gió (bám bụi); cũng là lưới đầu rèm bệnh viện.
- `monitor_screen.png`: màn hình máy theo dõi (nền tối, đường nhịp tim xanh, số đo), chỉ thấy từ góc phòng.

Mọi `.import` ở đây: `compress/mode=2` (nén VRAM), mipmap bật (card T-266 mục 5; test `test_t266_pilot.gd`).

Dùng lại (nguồn ghi ở CREDITS của từng đợt): cánh cửa phòng 407 của game (`room407_shell/doors/door_room.glb` và ba map
của nó: mô hình Tripo AI gói trả phí, D-084, hồ sơ ở `art_source/graphics_upgrade/room407_shell/CREDITS.md`) được cắt lỗ và
giảm lưới bằng Blender cho mức "thủng" (không tạo mới trên Tripo); vải rèm `floor4_rooms/curtain_*.jpg`; sơn trát, gạch
ceramic, tấm trần của đợt 6; sơn xám của đợt 1; vật liệu dùng chung W1/W2/W6/W8 và `floor4_rest` (WRVent, CCClothGrey).
