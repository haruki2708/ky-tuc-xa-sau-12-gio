# T-102 — Bộ module 3D ký túc xá dựng bằng script Blender
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
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
- [x] Chạy lại `build_kit.ps1` từ đầu thì ra đúng các file như cũ
- [x] `pwsh tools/test.ps1` PASS
- [x] Có `contact_sheet.png` và ảnh chụp `kit_showcase.tscn` từ Godot
- [x] Không chạm file ngoài phạm vi; có `CREDITS.md`
- [x] Mục Handoff đã điền, kèm số tam giác của từng mô hình

## Handoff (agent điền)

### 2026-10-02 — Lane B / Codex

**Đã làm**
- Cài Blender **5.2.2 LTS** portable chính thức ở `D:\Tools\Blender\5.2.2\`, xác minh SHA256 ZIP; không cài vào C:, không thêm plugin. Phiên bản, đường dẫn và nguồn tải nằm trong `art_source/README.md`.
- Dựng đủ 7 GLB, 9 texture tự tạo 128 px, 7 preview 512 px và contact sheet. Có script cài, build và kiểm tra tái lập; không cần file nguồn `.blend` hoặc thư viện ngoài.
- Thêm `kit_showcase.tscn`, ảnh `art_source/kit/previews/kit_showcase.png` 1280 × 720 chụp bằng Godot 4.7.2 Forward+ (Vulkan, RTX 3050 Laptop). Đã xem trực tiếp contact sheet và ảnh Godot để kiểm tra hình ảnh.
- Thêm 7 test cho kit: load/mesh/ngân sách tam giác, kích thước, ô cửa, bản lề/mặt trước, nhóm cánh quạt, texture nearest và scene showcase. Giữ đủ `.import`, `.uid` Godot sinh ra; asset nhị phân qua Git LFS, mọi file dưới 10 MB.
- Nguồn asset và khai báo hỗ trợ AI nằm ở `art_source/CREDITS.md`. Không dùng texture ngoài.
- Commit triển khai **`39a252f`** đã push thành công lên `origin/lane-b/T-102-blender-kit`, kèm 25 LFS object duy nhất (3,2 MB). Bản cập nhật checklist/Handoff này được commit riêng sau đó. Không push `main`.

**Số tam giác** (mesh triangulate trước export; chi tiết kích thước trong `art_source/kit/manifest.json`)

| Mô hình | Tam giác | Giới hạn |
|---|---:|---:|
| wall_straight | 24 | <1500 |
| wall_door | 60 | <1500 |
| door | 120 | <1500 |
| bunk_bed | 372 | <1500 |
| locker | 228 | <1500 |
| ceiling_fan | 180 | <500 |
| plastic_stool | 108 | <500 |

**Cách kiểm tra / kết quả đã chạy**
1. Từ gốc repo: `pwsh -File art_source/kit/build_kit.ps1`.
2. `pwsh -File art_source/kit/verify_rebuild.ps1`: dựng mới hai lần bằng Blender 5.2.2, so SHA256 của 24 đầu ra, kết quả **`REBUILD_RESULT: PASS 24/24 generated GLB, texture and preview hashes match`**. PNG loại metadata thời gian để hash ổn định; cam kết tái lập đã kiểm chứng trên cùng máy và bản Blender, không khẳng định hash render giống giữa mọi nền tảng.
3. `pwsh tools/test.ps1`: kết quả cuối **`RESULT: 12 passed, 0 failed`**, exit code 0 (5 test core + 7 test kit). Đã chạy sau lần rebuild cuối và các chỉnh sửa scene.
4. Lệnh chụp đầy đủ trong `art_source/README.md`; kết quả **`CAPTURE_RESULT: PASS`**. Mở contact sheet và `kit_showcase.png` trong `art_source/kit/previews/` để duyệt.
5. `git diff --cached --check` trước commit triển khai không báo lỗi; các file thay đổi chỉ thuộc phạm vi Lane B và checklist/Handoff của card này.

**Quyết định kỹ thuật / điểm cần biết khi tích hợp**
- Blender -Y qua glTF Y-up mặc định thành Godot +Z. Script bake thêm nửa vòng vào node con để mặt trước cuối là Godot -Z, giữ root identity và bản lề ở gốc. Test kiểm tra hướng tay nắm và quay cửa.
- Cửa 0,88 × 2,08 m để có khe trong ô 0,9 × 2,1 m. Lá trải local X=-0,88..0 trong Godot; đặt bản lề X=+0,44, Y=0,01 khi lắp vào ô ở gốc. Xoay quanh local Y.
- Giường bao gồm thang và khung mùng trong đúng envelope 0,9 × 2 × 1,7 m; chưa có vải mùng. Tủ chọn hai ngăn xếp dọc.
- Quạt có `fan_rotor` con độc lập, quay local Y; pivot nằm trên trục motor. Showcase nâng quạt lên 2 m để xem, asset gốc có đáy ở Y=0.
- GLB dùng nearest thuần ở cả min/mag sampler; không cần thay cài đặt project. Godot tách texture nhúng thành PNG có tiền tố model, đã commit các bản sao và import metadata.

**Còn dở / checklist chưa đạt**
- Không có mục checklist kỹ thuật nào chưa đạt. Hướng hình ảnh chờ chủ dự án duyệt qua preview; chưa coi là đã được duyệt mỹ thuật.
- Showcase chỉ phục vụ duyệt asset. Chưa lắp vào scene main, chưa có hành vi tương tác/collision trên từng mô hình; không thuộc yêu cầu T-102. Không tự suy diễn luật chơi hoặc cốt truyện.

**Yêu cầu thay đổi ngoài phạm vi**
- Không có. Không sửa `docs/STATUS.md`, cấu hình project, scene main hoặc file lane khác.

**Bị chặn**
- Không còn blocker. Sandbox từng lỗi khởi chạy PowerShell 1326, chặn mạng và log Godot; các thao tác cần thiết đã chạy lại với quyền được phê duyệt, test và push đều thành công.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`.** Test sau merge: `RESULT: 26 passed, 0 failed`.

- Đúng phạm vi file. Pipeline script → Blender headless → GLB → Godot chạy được và tái lập được (có `verify_rebuild.ps1`, so hash).
- Test tốt: kiểm tra số tam giác, kích thước, ô cửa trống, bản lề và hướng mặt trước của cửa, cánh quạt quay độc lập, texture lọc nearest.
- Ghi nguồn và khai báo AI đầy đủ trong `art_source/CREDITS.md`.
- Hình ảnh: đúng hướng PS1. Bảng màu (chân tường xanh, vôi vàng, sắt sẫm, ghế đỏ) khớp GDD. **Chủ dự án chưa duyệt mỹ thuật**; xem `art_source/kit/previews/contact_sheet.png`.

**Việc cần làm kèm task sau của lane B (T-112, T-118), không chặn:**
1. **Collision:** các mô hình chưa có va chạm. Khi dựng tầng ở T-112, tường, cửa, giường và tủ cần collision (ví dụ dùng hậu tố `-col`/`-colonly` trong Blender, hoặc thêm `StaticBody3D` trong scene con). Player hiện đi xuyên qua được.
2. **Texture bị nhân đôi:** Godot tách texture nhúng trong GLB ra `assets/models/kit/*.png`, trùng với `assets/textures/kit/*.png`. Nên xuất GLB tham chiếu texture ngoài, hoặc đổi cách import để chỉ còn một bản.
3. **Ghế nhựa đỏ** hiện là ghế đẩu 4 chân thẳng. Ghế nhựa đỏ kiểu Việt Nam thường thấp, chân loe và có lỗ trên mặt ghế. Chờ ý kiến chủ dự án.
4. Giường chưa có vải mùng (đã ghi trung thực). Mùng là chi tiết quan trọng của truyện: bạn cùng phòng nằm sau mùng.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
