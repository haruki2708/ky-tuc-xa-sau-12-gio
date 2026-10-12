# T-213 — nguồn góc phòng 407

Ngày tải: 12/10/2026. Mọi bộ PBR bề mặt là ảnh chụp thật của **Poly Haven**, giấy phép **CC0-1.0** ([chính sách nguồn](https://polyhaven.com/license)). `fetch_textures.py` tải qua API công khai, kiểm MD5 của nguồn; `texture_sources.json` lưu URL từng map, tác giả, SHA-256, số byte. Map gốc nằm ở `textures/` trong thư mục này; GLB trong `game/assets/models/graphics_pilot/room407_corner/` nhúng bản cần dùng. Không cần plugin, tài khoản hoặc API key.

| Bề mặt | Bộ / URL | Tác giả | Kích thước thật của ảnh | Map |
|---|---|---|---|---|
| Tường, trần (sơn kem cũ, ố) | [Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) | Amal Kumar | 2 m, 2048² | màu, normal OpenGL, ARM |
| Sàn gạch men, phào chân tường | [Interior Tiles](https://polyhaven.com/a/interior_tiles) | Charlotte Baglioni | 1,9 m, 2048² | màu, normal OpenGL, ARM |
| Ổ điện, ống luồn dây, đèn tuýp; nguồn hạt vết ố | [Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) | Rob Tuytel | 3,2 m, 1024² (vết ố từ bản 2048²) | màu, normal OpenGL, ARM |
| Khung giường, chân bàn, đèn bàn, khung ban công | [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) | Rob Tuytel | 1 m, 1024² | màu, normal OpenGL, ARM |
| Chiếu trên nệm | [Tatami Mat](https://polyhaven.com/a/tatami_mat) | Charlotte Baglioni | 1,8 m, 1024² | màu, normal OpenGL, ARM |
| Vỏ nệm | [Rough Linen](https://polyhaven.com/a/rough_linen) | colormass (chụp), Rico Cilliers (xử lý) | 0,27 m, 1024² | màu, normal OpenGL, ARM |
| Vỏ gối kẻ ô | [Fabric Pattern 05](https://polyhaven.com/a/fabric_pattern_05) (biến thể màu `col_01`) | Rob Tuytel | 0,5 m, 1024² | màu, normal OpenGL, ARM |
| Chăn lông | [Polar Fleece](https://polyhaven.com/a/polar_fleece) | colormass (chụp), Rico Cilliers (xử lý) | 0,27 m, 1024² | màu, normal OpenGL, ARM |
| Mặt bàn, ngăn kéo | [Wood Table Worn](https://polyhaven.com/a/wood_table_worn) | Dimitrios Savva (chụp), Rico Cilliers (xử lý) | 0,55 m, 1024² | màu, normal OpenGL, ARM |

ARM: AO ở R, roughness ở G, metallic ở B. UV theo mét đúng kích thước thật của từng ảnh (vải không bị phóng to).

**Ảnh phái sinh (CC0, `make_decals.py`):** `painted_plaster_wall_cream_color.jpg` là ảnh màu Painted Plaster Wall đổi tông kem cho khớp phòng hiện hành, giữ nguyên vết ố; `water_stain.png` 512² lấy hạt bề mặt từ Plastered Wall 04, nhuộm nâu, alpha vệt nước bằng công thức. Không gọi đây là ảnh vết nước chụp nguyên bản.

**Hình học và script:** Lane B (Codex) dựng khung theo số đo repo; integrator Claude (làm thay B, 12/10) đổi vật liệu, dựng chiếu/gối/chăn (chăn bằng mô phỏng vải của Blender). Tự dựng, CC0. AI hỗ trợ viết code; không có ảnh raster AI hay tác vụ Tripo mới.

**Đồ Tripo dùng lại, không thuộc CC0:** balo D-086 và 7 món D-089. Xem [credits balo](../tripo/room407_backpack/CREDITS.md), [credits đợt 1](../tripo/room407_batch1/CREDITS.md); ngoại lệ `LicenseRef-Tripo-Paid-D-084`. `blender_textures/tripo_*.png` chỉ là ảnh tách từ chính các GLB này để file Blender mở được với đường dẫn tương đối; giấy phép giữ nguyên.

Ảnh trước: render tĩnh phòng PS1 hiện hành, nguồn/credits cũ giữ nguyên. Ảnh sau kết hợp nguồn CC0 và Tripo nêu trên; không tuyên bố toàn bộ ảnh hay file Blender là tài sản CC0 độc lập.
