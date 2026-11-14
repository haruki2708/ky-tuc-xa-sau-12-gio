# Nguồn texture — `realistic_map/wave3/` (T-259)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave3/make_wave3_textures.py` vẽ bằng code (numpy + Pillow):
không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án (CC0 trong nội bộ dự án).

- `leaf_plumeria.png`, `leaf_lagerstroemia.png`, `shrubs.png`: atlas lá, hoa (có alpha, cắt alpha).
- `hedge_*`, `bark_*`, `soil_*`: mặt hàng rào xén, vỏ hoa sứ và bằng lăng, đất bồn.
- `paving_block_*`: gạch block con sâu (màu, normal, ORM).
- `mask_paving.png`, `mask_kerb.png`, `mask_bench.png`: mặt nạ cũ bẩn cho `room407_shell.gdshader` (UV2).
- `ground_grass_*`, `mask_strip.png`: bãi cỏ mòn của dải nối nhà B → vườn và mặt nạ đất trơ, ướt của nó.
- `litter.png`: giấy vở, tờ rơi (chỉ có nét, không chữ), giấy vo, túi ni lông. `board_papers.png`: sáu tờ giấy của bảng tin (không chữ, như giấy PS1).

Mọi file từ 512 px trở lên nhập nén VRAM (`compress/mode=2`, normal thêm `compress/normal_map=1`, mipmap bật).
