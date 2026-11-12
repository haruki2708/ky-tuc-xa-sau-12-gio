# T-216 — Giẻ lau nhà tắm

- `cleaning_rag.blend`, `build_cleaning_rag.py` và `game/assets/models/graphics_pilot/room407_furnished/cleaning_rag.glb`: hình vải gấp hai lớp, nếp nhăn và viền may dựng bằng Blender 5.2.2; lane B (Codex), 14/10/2026, CC0. AI hỗ trợ viết script hình học; không có ảnh AI hoặc tác vụ Tripo mới.
- Bề mặt: **Rough Linen**, [Poly Haven](https://polyhaven.com/a/rough_linen), colormass (chụp), Rico Cilliers (xử lý), **CC0-1.0**. Tái dùng ba map màu/normal OpenGL/ARM 1024² đã có trong `../room407_corner/textures/rough_linen_*.jpg`; nguồn, SHA-256 và giấy phép đã ghi trong `../room407_corner/texture_sources.json` và `../room407_corner/CREDITS.md`. GLB nhúng các map này, UV theo kích thước scan 0,27 m.
- `bath_tiles.glb` dùng lại Long White Tiles CC0, nguồn giữ nguyên tại `../room407_corner/CREDITS.md`; T-216 chỉ sửa hình học mối nối, không tạo nguồn texture mới.

# T-245 — Giẻ trên giá treo, áo của Việt, ổ khoá tủ Đạt (D-163)

- `split_towel_rack.py` → `rack_rag.glb`, `towel_rack_bare.glb`: khăn xanh và quần đùi cắt từ giá treo Tripo đợt 3 (`../tripo/room407_batch3/`, `towel_rack_r1.glb`, nguồn và giấy phép như đợt 3), dùng lại bộ texture đã nướng của giá treo. Giá treo (tấm lưng, thanh treo, móc) dựng lại bằng Blender 5.2.2, vật liệu crôm thuần số, không texture. Integrator (Claude, Fable 5.2), 12/11/2026. AI viết script hình học; không có tác vụ Tripo mới, không ảnh AI.
- `build_viet_shirt.py` → `viet_shirt.glb`: hình áo gấp dựng bằng Blender. Bề mặt **Rough Linen** (Poly Haven, CC0-1.0, nguồn ghi ở `../room407_corner/CREDITS.md`): normal và ARM giữ nguyên, màu là vân vải của bản scan nhuộm sọc xanh navy/trắng bằng numpy (`viet_shirt_color.jpg`, tác phẩm phái sinh từ ảnh CC0, CC0).
- `build_combo_lock.py` → `combo_lock.glb`: hình khoá số dựng bằng Blender; vân kim loại xước (`combo_lock_metal.png`) vẽ bằng numpy từ số ngẫu nhiên, không dùng ảnh nào; chữ số là font mặc định của Blender (Bfont, đi kèm Blender), không tên hãng, không logo. CC0.
