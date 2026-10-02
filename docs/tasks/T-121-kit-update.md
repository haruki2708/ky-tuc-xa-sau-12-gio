# T-121 — Cập nhật bộ kit: ghế nhựa kiểu Việt Nam, mùng, collision
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-121-kit-update`
- Phụ thuộc: T-102 (done). Đọc mục **Review** trong `docs/tasks/T-102-blender-kit.md` trước khi làm.

## Mục tiêu
Sửa bộ kit theo nhận xét của chủ dự án (D-012). Ghế nhựa phải nhận ra ngay là ghế nhựa đỏ Việt Nam. Giường tầng có mùng, vì mùng là chi tiết quan trọng của truyện: bạn cùng phòng nằm sau mùng. Mọi mô hình có collision để dựng tầng ở T-112.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Làm lại `plastic_stool`: ghế nhựa đỏ lùn kiểu quán vỉa hè**
   - Cao khoảng **0,30 m**. Mặt ghế vuông khoảng 0,28 × 0,28 m, bo góc.
   - Bốn chân **loe ra** phía dưới, chân đế rộng khoảng 0,36 × 0,36 m. Mỗi mặt bên là một tấm liền, khoét vòm ở giữa, không phải 4 chân que.
   - Giữa mặt ghế có **khe hoặc lỗ để cầm** (làm bằng hình học hoặc alpha scissor).
   - Màu đỏ nhựa hơi bóng. Dưới 500 tam giác.
   - Giữ tên file `plastic_stool.glb`.
2. **Mùng (`mosquito_net`)**
   - Là mô hình riêng, không gộp vào `bunk_bed`. Đặt cùng gốc tọa độ với giường để lắp vào **từng tầng** (tầng dưới treo vào gầm tầng trên; tầng trên treo vào khung mùng).
   - Hai biến thể:
     - `mosquito_net_closed.glb`: buông kín bốn phía, mép dưới dắt vào chiếu.
     - `mosquito_net_open.glb`: một cạnh dài vén lên và cột lại.
   - Vải hơi võng, không phẳng như hộp. Màu trắng ngà hoặc xanh nhạt.
   - **Bán trong suốt:** nhìn xuyên qua thấy lờ mờ hình dáng người nằm bên trong. Dùng texture lưới với alpha scissor, hoặc alpha dither cho hợp phong cách PS1. Ghi lý do chọn cách nào vào Handoff.
   - Dưới 500 tam giác mỗi biến thể.
   - Cập nhật `kit_showcase.tscn`: một giường có mùng đóng ở tầng dưới và mùng mở ở tầng trên. Đặt một hình nộm (capsule) nằm sau mùng đóng để kiểm tra độ trong.
3. **Collision cho mọi mô hình**
   - Tường, tường có cửa, cửa, giường, tủ, ghế có collision đơn giản (hộp hoặc convex), trên **layer 1 (world)**. Quạt trần và mùng không cần collision.
   - Ô cửa của `wall_door` phải đi qua được: Player có capsule bán kính 0,3 m, cao 1,75 m.
   - Cách làm do lane B chọn (hậu tố `-col`/`-colonly` khi import, hoặc tạo trong script). Ghi lại vào `art_source/README.md`.
4. **Bỏ texture trùng lặp**
   - Hiện Godot tách texture nhúng trong GLB ra `game/assets/models/kit/*.png`, trùng với `game/assets/textures/kit/*.png`. Làm sao để mỗi texture chỉ còn một bản trong repo.
5. **Preview:** cập nhật `contact_sheet.png` (thêm 2 mùng) và `kit_showcase.png`.
6. **Test `game/tests/levels/`:**
   - Ghế cao 0,30 m ±5%, đáy rộng hơn mặt ghế.
   - Hai mô hình mùng load được, nằm trong ngân sách tam giác, material có bật trong suốt.
   - Mỗi mô hình cần collision có ít nhất một collision shape trên layer 1.
   - Một capsule bán kính 0,3 m đi xuyên qua ô cửa của `wall_door` mà không bị chặn. Kiểm tra bằng `PhysicsDirectSpaceState3D.cast_motion` hoặc cách tương đương.

## Checklist hoàn thành
- [ ] Chạy lại `build_kit.ps1` từ đầu thì ra đúng file như cũ (`verify_rebuild.ps1` PASS)
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Có ảnh `contact_sheet.png` và `kit_showcase.png` mới, nhìn thấy mùng, thấy lờ mờ hình nộm sau mùng đóng
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [ ] Mục Handoff đã điền, kèm số tam giác từng mô hình mới

## Cách kiểm tra
```
pwsh -File art_source/kit/verify_rebuild.ps1
pwsh tools/test.ps1 -Filter levels
pwsh tools/capture.ps1 -Scene res://scenes/levels/kit_showcase.tscn -Out build/captures/kit
```

## Handoff (agent điền)
