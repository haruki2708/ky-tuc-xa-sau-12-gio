# T-213 — nguồn góc phòng 407

Ngày tải: 12/10/2026. Các bộ PBR bề mặt thực của **Poly Haven**, giấy phép **CC0-1.0**: [chính sách nguồn](https://polyhaven.com/license). Không dùng texture G0 tự sinh 256 px cho bề mặt mới. `texture_sources.json` lưu URL tải từng map, tác giả, SHA-256, số byte; `fetch_textures.py` kiểm MD5 do API nguồn cung cấp. Không cần plugin, tài khoản hoặc API key.

| Bề mặt | Bộ / URL | Tác giả | Độ phân giải mỗi map | Map dùng |
|---|---|---|---|---|
| Vữa tường, trần; bản thu nhỏ cho chi tiết sứ | [Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) | Rob Tuytel | 2048² tường/trần, bản nguồn 1024² cho chi tiết nhỏ | Diffuse, Normal OpenGL, ARM |
| Gạch men, phào chân tường | [Interior Tiles](https://polyhaven.com/a/interior_tiles) | Rob Tuytel | 2048² | Diffuse, Normal OpenGL, ARM |
| Sắt sơn giường, khung, chân bàn, đèn | [Rusty Painted Metal](https://polyhaven.com/a/rusty_painted_metal) | Amal Kumar | 1024² | Diffuse, Normal OpenGL, ARM |
| Nệm, chăn, gối, đường may | [Denim Fabric](https://polyhaven.com/a/denim_fabric) | Rob Tuytel | 1024² | Diffuse, Normal OpenGL, ARM |
| Mặt bàn, ngăn kéo | [Wood Table Worn](https://polyhaven.com/a/wood_table_worn) | Dimitrios Savva (Photography), Rico Cilliers (Processing) | 1024² | Diffuse, Normal OpenGL, ARM |

ARM chứa AO ở R, roughness ở G, metallic ở B. Texture nằm trong `game/assets/models/graphics_pilot/room407_corner/textures/`; các GLB nhúng bản map tương ứng. Ống tuýp dùng map vữa làm biến thiên bề mặt, emission bổ sung trong pilot; chưa có bộ ảnh kính đèn chuyên biệt. Vải denim được dùng làm nghiên cứu độ dệt của chăn/nệm, chưa phải thiết kế vải cuối cùng.

`water_stain.png` 512²: `make_decals.py` lấy hạt bề mặt từ Plastered Wall 04, nhuộm nâu và tạo alpha vệt nước bằng công thức. Là **decal phái sinh CC0**, không gọi đây là ảnh vết nước chụp nguyên bản. Hình học và script T-213: Lane B (Codex), tự dựng theo số đo repo, CC0; AI hỗ trợ viết code, không có raster AI hay tác vụ Tripo mới.

Tám model Tripo được tái sử dụng nguyên bản đã duyệt, **không thuộc CC0**: balo D-086 và 7 món D-089. Xem [credits balo](../tripo/room407_backpack/CREDITS.md), [credits đợt 1](../tripo/room407_batch1/CREDITS.md); ngoại lệ `LicenseRef-Tripo-Paid-D-084`. `blender_textures/tripo_*.png` chỉ là ảnh tách từ chính các GLB này để file Blender mở được với đường dẫn tương đối; giấy phép giữ nguyên. Không gộp giấy phép model Tripo vào giấy phép hình học tự dựng.

Ảnh trước: bản render tĩnh từ phòng PS1 hiện hành, nguồn/công cụ/credits cũ giữ nguyên. Ảnh sau kết hợp nguồn CC0 và Tripo nêu trên; không tuyên bố toàn bộ ảnh/file Blender là tài sản CC0 độc lập.
