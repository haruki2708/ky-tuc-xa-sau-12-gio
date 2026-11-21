# `wave10/` — T-267 (đợt 10): mask hành lang trường quay CCTV

Vẽ bằng script (numpy + Pillow) trong `art_source/graphics_upgrade/realistic_map/wave10/make_wave10_textures.py`, không ảnh
tải về, không ảnh AI. Của dự án, dùng cùng giấy phép với game.

| File | Kích thước | Dùng cho |
|---|---|---|
| `mask_cctv_hall_wall.png` | 512 × 256 | `CWHallWall`, `CWHallDado`: tường hành lang (R bong sơn, G bẩn, B ố nước, A mốc) |
| `mask_cctv_hall_floor.png` | 512 × 256 | `CWHallFloor`: sàn terrazzo (G bẩn, B ướt, A mòn) |
| `mask_cctv_hall_ceiling.png` | 256 × 128 | `CWHallCeiling`: trần (khói đèn, ẩm mép ngoài, một vết dột) |

Cả ba nhập nén VRAM (`compress/mode=2`), thay cho ba mask 4096 px chưa nén của đợt 2 (D-188 điểm 5).