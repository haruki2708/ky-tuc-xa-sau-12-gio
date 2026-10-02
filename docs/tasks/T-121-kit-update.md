# T-121 — Cập nhật bộ kit: ghế nhựa kiểu Việt Nam, mùng, collision
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
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
- [x] Chạy lại `build_kit.ps1` từ đầu thì ra đúng file như cũ (`verify_rebuild.ps1` PASS)
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Có ảnh `contact_sheet.png` và `kit_showcase.png` mới, nhìn thấy mùng, thấy lờ mờ hình nộm sau mùng đóng
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [x] Mục Handoff đã điền, kèm số tam giác từng mô hình mới

## Cách kiểm tra
```
pwsh -File art_source/kit/verify_rebuild.ps1
pwsh tools/test.ps1 -Filter levels
pwsh tools/capture.ps1 -Scene res://scenes/levels/kit_showcase.tscn -Out build/captures/kit
```

## Handoff (agent điền)

### 2026-10-02 — Lane B / Codex

**Đã làm**
- Tạo nhánh từ `origin/main` tại `36ba822`, làm trong `D:\GAME_WORK\lane-b`. Đã đọc Review T-102 trước khi sửa.
- Làm lại ghế nhựa đỏ: cao 0,30 m, mặt bo góc 0,28 × 0,28 m, chân đế loe 0,36 × 0,36 m; bốn tấm thân liền khoét vòm, khe cầm xuyên hình học, nhựa roughness 0,30.
- Thêm `mosquito_net_closed.glb` và `mosquito_net_open.glb`, có mái võng/nếp vải. Bản mở vén và cột giữa cạnh dài. Không gộp mesh vào giường.
- Showcase có mùng đóng tầng dưới, mùng mở tầng trên và capsule nằm sau mùng đóng. Đã xem trực tiếp ảnh render Godot Forward+ để kiểm tra hình nộm nhìn lờ mờ qua lưới.
- Thêm collision tự sinh lúc import cho 6 mô hình cần thiết; mọi body trên layer 1. Quạt và mùng không thêm collision.
- GLB tham chiếu texture gốc ngoài file; loại cả byte ảnh nhúng khỏi GLB và xóa 16 PNG trùng cùng metadata trong `models/kit/`. Repo hiện có 10 texture gốc trong `textures/kit/`; import không sinh lại bản trùng.
- Cập nhật README, CREDITS (nguồn tự tạo, CC0, khai báo Codex hỗ trợ AI), preview, manifest/hash và test. Không cài công cụ mới, không thêm plugin, không sửa file lane khác.
- Commit triển khai **`51f222b`** đã push lên `origin/lane-b/T-121-kit-update`, gồm 17 LFS object mới (2,3 MB). Checklist/Handoff này được commit và push riêng tiếp theo. Không push `main`.

**Tam giác sau triangulate / xuất GLB**

| Mô hình | Tam giác | Giới hạn |
|---|---:|---:|
| plastic_stool (làm lại) | 320 | <500 |
| mosquito_net_closed (mới) | 360 | <500 |
| mosquito_net_open (mới) | 372 | <500 |
| wall_straight | 24 | <1500 |
| wall_door | 60 | <1500 |
| door | 120 | <1500 |
| bunk_bed | 372 | <1500 |
| locker | 228 | <1500 |
| ceiling_fan | 180 | <500 |

**Quyết định kỹ thuật / cách tích hợp**
- Mùng dùng texture lưới RGBA 128 px, **alpha scissor** (`MASK`, cutoff 0,5), hai mặt, nearest. 56,25% pixel là lỗ, còn lại là sợi; nhìn xuyên được nhưng hình nộm bị lớp sợi che một phần. Chọn cách này vì hợp nét hạt PS1 và tránh lỗi thứ tự alpha blend giữa nhiều mặt mùng. Lưới nearest có thể moiré khi nhìn xa; xem ảnh cận để duyệt chi tiết.
- Hai mùng giữ cùng gốc với giường. Tầng dưới: position `(0,0,0)`, scale `(1,1,1)`, mép Y=0,415 và điểm treo Y=1,075 m (gầm tầng trên). Tầng trên: position `(0,0.8800379,0)`, scale `(1,0.7348485,1)`, mép Y=1,185 và điểm treo Y=1,670 m (khung mùng). Transform áp dụng cho cả hai biến thể. Mép thấp hơn mặt chiếu 0,015 m.
- `.glb.import` trỏ tới `game/assets/models/kit/kit_import.gd` (`EditorScenePostImport` chuẩn Godot). Collision được lưu vào PackedScene, không cần script runtime/plugin. Tường thẳng/cửa/giường/tủ dùng hộp bounds, ghế dùng convex; riêng tường cửa dùng hai hộp trụ và một hộp dầm, giữ ô trống 0,9 × 2,1 m. Collision đơn giản của giường/tủ/cửa là hộp đặc, chưa phục vụ tương tác chi tiết bên trong.
- Texture có URI `../../textures/kit/<name>.png`; khi chuyển asset cần giữ cấu trúc thư mục và các file `.import`. Các test kiểm tra material thực sự tham chiếu thư mục texture gốc.

**Đã kiểm tra / cách chạy lại**
1. `pwsh -File art_source/kit/verify_rebuild.ps1`: **`REBUILD_RESULT: PASS 29/29 generated GLB, texture and preview hashes match`**. Hai lần dựng mới cùng Blender 5.2.2 LTS/cùng máy; không khẳng định hash ảnh giống trên mọi nền tảng.
2. `pwsh tools/test.ps1`: **`RESULT: 35 passed, 0 failed`**, exit code 0. Trong đó 12 test kit: có kích thước/đế loe/khe ghế, ngân sách mesh, alpha mùng, transform hai tầng, collision layer và texture không trùng.
3. Test capsule dùng `PhysicsDirectSpaceState3D.cast_motion`, r=0,3 m/h=1,75 m; đi hai chiều tại X=0 và ±0,14 m qua cửa đã xoay. Có đối chứng bị trụ trái/phải và dầm chặn để tránh PASS do thiếu collider.
4. `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0.
5. Chụp bằng `art_source/kit/capture_showcase.gd` với Godot 4.7.2, renderer Forward+/Vulkan. **`CAPTURE_RESULT: PASS`**, **`CAPTURE_DETAIL_RESULT: PASS`**. Lệnh đầy đủ trong `art_source/README.md`.
6. Ảnh: `art_source/kit/previews/contact_sheet.png` (9 ô), `kit_showcase.png` (cận giường/hình nộm), `kit_showcase_overview.png` (cả bộ). Hai ảnh Godot đều 1280 × 720. Ảnh riêng ghế và hai mùng là 512 × 512.
7. `git diff --cached --check` và kiểm tra phạm vi trước commit không có lỗi; nhị phân qua LFS, file dưới 10 MB.

**Còn dở / checklist chưa đạt**
- Không có mục checklist kỹ thuật nào chưa đạt. Ảnh T-121 chờ chủ dự án duyệt mỹ thuật; chưa coi là đã được duyệt.
- Chưa lắp vào tầng T-112 hoặc thêm gameplay; ngoài yêu cầu task này. Không tự thêm luật chơi/cốt truyện.

**Yêu cầu thay đổi ngoài phạm vi**
- Không có. Không sửa `docs/STATUS.md`, project settings, main scene hoặc file lane khác.

**Bị chặn**
- Không còn blocker. Fetch/push GitHub bị giới hạn mạng sandbox đã chạy lại với quyền được phê duyệt; test/check/capture cũng đã chạy thành công.

## Review (integrator, 2026-10-02)
**Kết quả: chấp nhận, đã merge vào `main`.** Sau merge (gồm T-101…T-105): `test.ps1` → `RESULT: 54 passed, 0 failed`; `check.ps1` → `RESULT: check 0 error(s)`.

- Đúng phạm vi, không cần yêu cầu thay đổi ngoài lane.
- **Ghế nhựa:** đạt. Nhận ra ngay là ghế nhựa đỏ lùn Việt Nam (thân loe, mặt bên khoét vòm, khe cầm xuyên thật).
- **Collision:** sinh tự động khi import bằng `EditorScenePostImport`, không cần plugin. Test `cast_motion` có cả đối chứng trụ/dầm chặn, rất tốt.
- **Texture trùng:** đã bỏ; GLB tham chiếu `textures/kit/`, có test chặn tái phát.
- **Mùng:** kỹ thuật đúng (alpha scissor, hai mặt, không collision, đúng độ cao hai tầng, thấy hình nộm bên trong). **Hình ảnh chưa đạt theo nhận xét của integrator:** mắt lưới quá to (chu kỳ 4 px trên texture 128 px), sợi quá rõ, nhìn giống lồng sắt hoặc lưới rào hơn vải mùng. Hình nộm hiện quá rõ. **Chủ dự án đã duyệt giữ nguyên (D-013).**

**Ghi chú cho task sau (không chặn):**
1. Collision của giường, tủ và cửa là hộp đặc theo bounds. Người chơi không chui được vào gầm giường hay đứng sát thang. Đủ cho P1; nếu sau này cần nằm hoặc trốn thì làm collision chi tiết hơn.
2. `kit_import.gd` dùng lớp editor (`EditorScenePostImport`). Khi xuất bản build, lane C nên loại file này khỏi export (export filter) để bản phát hành gọn hơn.

**Chấm điểm (1–5):** phạm vi 5 · checklist 5 · test 5 · chất lượng code 5 · bàn giao trung thực 5 · số vòng sửa 0.
