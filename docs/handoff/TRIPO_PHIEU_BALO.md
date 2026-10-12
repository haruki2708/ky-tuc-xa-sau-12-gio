# Phiếu ghi mẫu balo Tripo (G2, D-084)

> Phiếu theo mục 5 của `TRIPO_STUDIO_HUONG_DAN_BALO.md`. Chủ dự án báo, integrator ghi. Cập nhật dần theo từng bước.

| Mục | Ghi |
|---|---|
| Gói, ngày mua, chu kỳ, tổng tiền | **Tripo Studio Pro**, mua **12/10/2026**, trả **theo tháng**, tổng **263.000 đồng** (chủ dự án báo) |
| File điều khoản đã lưu | `tripo_terms_2026-10-12.pdf` (1 trang, chủ dự án đã kiểm đủ nội dung), `tripo_commercial_2026-10-12.pdf` (5 trang); đang ở `build/graphics/staging/room407_backpack/`, chuyển vào kho lưu bền vững của B khi nhập asset |
| Chế độ (Text/Image to 3D), model version trên UI | Text to 3D, **H3.1** (theo trao đổi 12/10; chủ dự án xác nhận lại) |
| Prompt thực đã dán | Đúng prompt mục 2 của hướng dẫn, không có ô negative prompt. Tùy chọn: Triangle, polycount 2500, PBR bật, Remove lighting bật, Ultra mesh tắt, 8K tắt, Generate in parts tắt; UI báo 30 credit/lượt |
| Ảnh đầu vào (nếu có) | Không dùng |
| Từng lượt: giờ, việc, credit trước → sau | Trước lượt 1: **3.800**. Số lượt đã dùng và credit sau: **chờ chủ dự án báo** |
| Mẫu được chọn: task/model ID | **Chờ chủ dự án báo** (hoặc "Studio không hiện") |
| Tên file đã tải, thư mục lưu | `backpack 3d model.glb` (2.603.168 byte, SHA-256 `bf60bafb0fe6c954a731aacbb0dc36ee83027dbe0f7c74057759b5bcafd343a8`), tải 12/10 16:28; bản lưu bền vững `art_source/graphics_upgrade/tripo/room407_backpack/source/tripo_original_r1.glb` |
| Riêng tư đã bật chưa | **Đã bật** (chủ dự án báo 12/10) |

## Kết quả xử lý (integrator, Claude làm thay lane B, 12/10/2026)
- **File Tripo gốc:** 1 mesh, 2.300 tam giác, 1 vật liệu PBR, 3 texture 2048² (màu, nhám/kim loại, normal), 2,6 MB; túi trước hướng glTF **+Z** (ngược basis D-085).
- **Chuẩn hóa** (`art_source/graphics_upgrade/tripo/room407_backpack/normalize_backpack.py`, Blender 5.2.2): xoay 180° quanh trục đứng (túi về **−Z**); khớp khung balo cũ size (0,29; 0,45636; 0,30274) m, min (−0,145; 0,01; −0,1325) m (co ngang khoảng 18% so với tỉ lệ gốc Tripo vì balo Tripo bè hơn khung cũ); texture 2048 → **1024**; pivot gốc (0,0,0). Kết quả `game/assets/models/graphics_pilot/room407_backpack_tripo.glb` (2,7 MB), chỉ dùng cho cảnh thử, **bản chơi chưa đổi**.
- **Công cụ C** (`g2/asset_qa_result.json`): kích thước/bounds đạt (lệch < 0,00001 m), scale 1, **2.300 tam giác < 3001, 1 vật liệu ≤ 2, 3 texture 1024 ≤ 1024**. Lỗi giấy phép ban đầu (`license not allowlisted`, công cụ viết trước D-084) đã hết sau khi công cụ nhận nhãn `LicenseRef-Tripo-Paid-D-084` (Claude làm thay lane C, chủ dự án đồng ý 12/10): **`errors: []`, INCOMPLETE**. Mục còn trống: mã model, số credit sau, các cổng duyệt tay; cache `.scn` nhị phân chưa chứng minh closure (giới hạn đã biết của công cụ, như balo cũ).
- **Ảnh:** `g2/front|back|side|underside…png` (4 góc, cùng camera/ánh sáng bộ ảnh balo cũ: túi −Z, quai +Z, đáy kín); `g2/room_far|room_near_before_cc0|after_tripo.png` và ảnh ghép `g2/compare_room_before_after.png` (cùng góc trong phòng 407).
