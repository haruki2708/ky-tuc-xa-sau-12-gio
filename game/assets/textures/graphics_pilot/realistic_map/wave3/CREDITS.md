# Nguồn texture — `realistic_map/wave3/` (T-259)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave3/make_wave3_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án (CC0 trong nội bộ dự án).

- `leaf_plumeria.png`, `leaf_mantaly.png`, `leaf_lagerstroemia.png`, `shrubs.png`: atlas lá, hoa (có alpha, cắt alpha).
- `hedge_*`, `bark_*`, `soil_*`: mặt hàng rào xén, vỏ ba loài cây, đất bồn.
- `paving_block_*`, `paving_red_*`: gạch block con sâu, gạch đỏ lá dừa (màu, normal, ORM).
- `mask_paving.png`, `mask_kerb.png`, `mask_bench.png`: mặt nạ cũ bẩn cho `room407_shell.gdshader` (UV2).

Mọi file từ 512 px trở lên nhập nén VRAM (`compress/mode=2`, normal thêm `compress/normal_map=1`, mipmap bật).
