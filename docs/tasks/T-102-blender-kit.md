# T-102 — Bộ module 3D ký túc xá dựng bằng script Blender
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-102-blender-kit`
- Phụ thuộc: P0 (xong)
- Loại: task thử tuần đầu

## Mục tiêu
Chứng minh pipeline sau chạy được: **script Python → Blender headless → file .glb → Godot**. Pipeline phải tạo ra các mô hình ký túc xá Việt Nam theo phong cách PS1, có ảnh preview để chủ dự án duyệt hướng hình ảnh.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Cài Blender bản LTS mới nhất dạng portable (.zip)** vào `D:\Tools\Blender\<phiên-bản>\`.
   - Không dùng bản installer, không cài vào ổ C:.
   - Ghi phiên bản và đường dẫn vào `art_source/README.md`.
2. **Script dựng mô hình:**
   - Script `art_source/kit/build_kit.py` chạy được bằng lệnh:
     ```
     blender --background --python art_source/kit/build_kit.py
     ```
   - Thêm `art_source/kit/build_kit.ps1` để gọi lệnh trên.
   - Script dựng **7 mô hình**:
     | Tên file | Mô tả | Ghi chú |
     |---|---|---|
     | `wall_straight` | Tường thẳng 2 m × 3 m × 0,2 m | Chân tường sơn màu khác |
     | `wall_door` | Tường có ô cửa 0,9 × 2,1 m | |
     | `door` | Cánh cửa gỗ cũ | Gốc tọa độ đặt ở **bản lề** để xoay được |
     | `bunk_bed` | Giường tầng khung sắt 0,9 × 2,0 × 1,7 m | Có thang, có khung treo mùng |
     | `locker` | Tủ sắt 2 ngăn | |
     | `ceiling_fan` | Quạt trần | Cánh quạt là object con riêng để xoay |
     | `plastic_stool` | Ghế nhựa đỏ | |
3. **Quy ước mô hình:**
   - Đơn vị mét. Gốc tọa độ ở chân, giữa vật. Mặt trước hướng −Y trong Blender, tương đương −Z trong Godot.
   - Đồ lớn dưới 1500 tam giác, đồ nhỏ dưới 500.
   - Texture 64–256 px, có thể vẽ bằng script hoặc lấy ảnh CC0 thu nhỏ. Lọc nearest trong Godot.
4. **Xuất file:**
   - Mô hình: `game/assets/models/kit/<tên>.glb`.
   - Texture: `game/assets/textures/kit/`.
   - Ảnh preview 512 px: `art_source/kit/previews/<tên>.png`, kèm một ảnh ghép `contact_sheet.png`.
5. **Scene trưng bày `game/scenes/levels/kit_showcase.tscn`:** đặt cả 7 mô hình thẳng hàng, có ánh sáng, để chụp ảnh kiểm tra.
6. **Test `game/tests/levels/test_kit.gd`:**
   - Mỗi file .glb load được và có ít nhất một mesh.
   - Kích thước bounding box đúng thông số ±5% (ít nhất cho `wall_straight`, `wall_door` và `bunk_bed`).
7. **Ghi nguồn:** `art_source/CREDITS.md` liệt kê nguồn của mọi texture không tự tạo.

## Checklist hoàn thành
- [ ] Chạy lại `build_kit.ps1` từ đầu thì ra đúng các file như cũ
- [ ] `pwsh tools/test.ps1` PASS
- [ ] Có `contact_sheet.png` và ảnh chụp `kit_showcase.tscn` từ Godot
- [ ] Không chạm file ngoài phạm vi; có `CREDITS.md`
- [ ] Mục Handoff đã điền, kèm số tam giác của từng mô hình

## Handoff (agent điền)
