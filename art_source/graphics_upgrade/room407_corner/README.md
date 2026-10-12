# T-213 — góc phòng 407, pilot độc lập

Cảnh: `game/scenes/levels/graphics_pilot/room407_corner_pilot.tscn`. File xem trong Blender: [room407_corner.blend](room407_corner.blend), texture dùng đường dẫn tương đối trong repo và `blender_textures/`. Mở cùng checkout đã lấy LFS, không chép riêng file `.blend`. Bản chơi và các marker gameplay giữ nguyên.

## Dựng lại

Từ gốc workspace Lane B, Python có Pillow/numpy đã dùng trong pipeline repo, Blender portable 5.2.2:

```powershell
python -B art_source/graphics_upgrade/room407_corner/fetch_textures.py
python -B art_source/graphics_upgrade/room407_corner/make_decals.py   # vết ố, tường kem, vải vuông 1024
& D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P art_source/graphics_upgrade/room407_corner/build_corner.py
python -B art_source/graphics_upgrade/room407_corner/audit_assets.py
& D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P art_source/graphics_upgrade/room407_corner/audit_blend.py
# Chỉ sau khi nhận lượt Godot từ integrator và máy trống:
& D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game --import
pwsh tools/test.ps1 -Filter room407_corner
& D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game res://scenes/levels/graphics_pilot/room407_corner_pilot.tscn -- --corner-capture
pwsh tools/test.ps1
pwsh tools/check.ps1
```

Chạy cảnh riêng để xem: phím **1…5** đổi camera, **L** đổi đèn tuýp/đèn pin, **B** đổi trước/sau. Mặc định góc so giường/bàn với đồ Tripo. Không chạy capture hoặc ghi file khi smoke nạp cảnh; không chạy script gameplay, audio, physics/nav của phòng nguồn. `ShaderGlobalsOverride` tự giải phóng khi rời pilot, không ghi Settings. APPDATA khi kiểm nên đặt trong `build/` của chính lane; `tools/test.ps1` đã tự cô lập dữ liệu test.

## Số đo và phạm vi

`build_corner.py` dùng mét room-local Godot; khi xuất Blender đổi `(x,y,z)` thành `(x,-z,y)`, glTF trả lại Y-up. Godot đặt root ở **(30,0,0)**. Số đo lấy từ `../MEASUREMENTS.md`, `../measured_assets.json`, các mesh/shape của `floor4/room_407.tscn`, `ch1v2/bunk_a_frame.tscn`, `ch1v2/extension.tscn`; baseline main **25e3bfe**.

| Phần | Mốc pilot / nguồn, m |
|---|---|
| Sàn | x=0…8 (hết bề rộng phòng); z=−7…0; mặt trên y=0 (mở tới cửa và tường đông để giữ vị trí dép/giày) |
| Tường tây | tâm x=0, dày 0,2; mặt trong x=0,1; cao 3 |
| Tường sau | z=−7, dày 0,15; mặt trong −6,925; BackWest rộng 2,3, BackEast rộng 1,9 |
| Ô mở ban công | x=2,3…3,3; y=0…2,3, lintel tâm y=2,65; khung bao trong pilot |
| Trần | mặt dưới y=3; dày 0,15 |
| Giường A | tâm (0,65;0;−3); cột x=0,22/1,08, z=−3,98/−2,02; nệm 0,8×0,05×1,9; mặt nằm y=0,43/1,20 |
| Bàn | tâm x=1,8 z=−4,55; rộng 1,5, sâu 0,65, mặt trên y=0,76 |
| Đèn tuýp | giữ vị trí hiện hành x=2 z=−1,2; mesh ở y≈2,84…2,91; light y=2,76 |

View/Exit và Corpse1/2 chỉ đọc từ `room407_anchors.tscn`, **không thay hoặc tạo collider**. Test đối chiếu actual bounds nhập GLB, không chỉ so metadata. Lún nệm tối đa 3 mm, cạnh vát 3…18 mm tùy vật; điểm bằng ở mặt nệm vẫn trong sai số 1 cm. Khung sắt ống tròn sơn xanh có vòng hàn và đầu bu-lông, UV theo mét quanh ống. Nệm bọc vải lanh, trên trải chiếu 2 mm (một tấm giữa hai nẹp viền của ảnh chiếu); gối kẻ ô dựng từ khối chia lưới (phồng giữa, mép chụm, đáy phẳng). **Chăn lông** dựng bằng mô phỏng vải Blender (cloth: va chạm nệm/gối/thanh giường/thang, vải "nở" 16–18 % để tự gợn nếp, làm mượt nếp cỡ ô lưới, dày 12 mm): giường dưới chăn bị tung ra, giường trên chăn nhàu ở cuối giường. Mô phỏng chạy lại cho cùng kết quả (dòng `DRAPE` trong log). Bàn có cạnh vát, yếm, ngăn kéo/tay nắm/chân ống.

## Đồ Tripo

[placements.json](placements.json) là một nguồn chung cho Godot, Blender, báo cáo. Giữ X/Z và hướng từ scene cũ. Balo yaw +90°; tủ/nồi quay mặt −X (yaw +90°), pivot bản chuẩn hóa nằm ở đáy nên tủ y=0 thay tâm hộp cũ 0,42; nồi đặt y=0,84. Khăn gấp chuẩn hóa đã nằm ngang: không áp lại X=90°/scale=0,5 của khăn treo cũ; hạ y=0,2798 (đỉnh xô đo từ GLB ở y≈0,2792 + bù min khăn −0,0006; bucket root 0,015, cao thực ≈0,2643). Giày dùng vị trí `Details/Dat/Trainers` đã cộng offset node `Dat` (4; 0; 0,3), tức (7,63; 0,015; −1,57), dép dùng `Details/Slippers/Trung`; không dời vào góc chỉ để đẹp ảnh.

Nguồn/license từng bộ và model tại [CREDITS.md](CREDITS.md). File `.blend` chứa cả 8 đồ Tripo để xem trực tiếp; GLB mới chỉ chứa hình học tự dựng, Godot tham chiếu model Tripo đã có.

## Ngân sách, mật độ và ánh sáng

Số đếm xuất Blender tại [geometry_report.json](geometry_report.json): floor 432, architecture 540, fixtures 2.004, bunk_a (khung + nệm) 4.784, bunk_a_bedding (chiếu, gối, chăn) 7.124, study_desk 1.400; tổng dựng mới **16.284** tam giác, Tripo **37.637**, tổng **53.921**. Mỗi GLB ≤ 8.000 tam giác (đồ lớn, D-088), ≤ 10 MiB, LFS. Mỗi GLB tối đa 2 vật liệu, riêng `bunk_a_bedding` 3 (chiếu, vỏ gối, chăn). `audit_assets.py` kiểm độc lập: số tam giác theo index GLB, ảnh nhúng vuông và trong trần, SHA-256 nguồn; kết quả **53.921 tam giác, 51 texture nhúng khác nhau + 1 decal**.

Map gốc ở `textures/` của thư mục này (không nằm trong `game/` để không bị đóng gói vào bản xuất; GLB đã nhúng bản cần dùng). Nguồn và kích thước thật từng bộ: [CREDITS.md](CREDITS.md). UV theo mét đúng kích thước thật: tường/trần 2 m với 2048 px (**1024 px/m**), sàn 1,9 m với 2048 px (**≈1078 px/m**), sắt 1 m/1024, chiếu 1,8 m, gỗ 0,55 m, vải lanh và chăn lông 0,27 m, vỏ gối 0,5 m. Hai bộ vải colormass gốc 1024×1017/1026 được `make_decals.py` đưa về 1024² (bản `_square_`) cho nén GPU.

Thử **SDFGI**: 4 cascades, cell 0,1 m, sky disabled trong nội thất, occlusion bật, bounce feedback 0,5. Mesh tĩnh `GI_MODE_STATIC`, ánh sáng dynamic để thay đèn tuýp/đèn pin. [Căn cứ Godot](https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_sdfgi.html). Có ảnh đối chứng SDFGI tắt cùng camera/vật liệu/exposure; SSAO/SSIL giữ nguyên trong đối chứng. **Quan sát:** SDFGI làm góc phòng và trần sáng hơn khoảng 8 % (trung bình ảnh R/G 130/126 so với 121/120), ánh dội ấm từ sàn gạch lên tường, góc khuất dưới giường không đen kịt; nhược điểm: phải chờ vài chục khung hình để ổn định (capture chờ 100 khung), có thể loang sáng nhẹ qua tường mỏng, chưa đo hiệu năng/FPS. Chưa thử VoxelGI/LightmapGI.

WorldEnvironment riêng: Filmic exposure=1; ambient xanh nhẹ energy=0,12; SSAO radius=0,35/intensity=1; SSIL radius=2/intensity=0,6; fog density=0,004; glow=0,25. Đèn tuýp energy=2,6 (integrator hạ từ 3,8 vì trần quanh đèn cháy sáng), range=9, light_size=0,25, shadow bật; ống đèn phát sáng ×1,2; sương mù không phủ nền (`fog_sky_affect=0`) để ngoài ban công tối; đèn bàn energy=0,55 màu ấm; đèn pin Spot energy=5/range=10/cone=38°, dưới camera 0,12 m. Không đổi project/default renderer.

## Kiểm chứng và phần chưa nghiệm thu

12/10 (Claude làm thay B): `pwsh tools/test.ps1 -Filter room407_corner` **3/3 đạt**; capture Forward+ thật **`RESULT: room407 corner capture 21 images PASS`**, không ERROR; `audit_assets.py`, `audit_blend.py` đạt. Full test/check ghi trong commit ghép. Vỏ phòng được dựng kín (tường đông, tường cửa có lỗ cửa và cánh cửa đóng, vách nhà tắm, trần 8 m) chỉ để góc rộng không lộ khoảng trống; đồ khác trong phòng (tủ, giường B, quạt, quần áo…) chưa dựng lại nên phòng trông trống.

Ảnh: `previews/{room_far,room_near,door_wide,bed_eye,tripo_comparison}_{tube,torch}_{before,after}.png` (20 ảnh); thêm `tripo_comparison_tube_after_sdfgi_off.png`. Hai camera far/near giữ đúng eye/target/FOV=70 của balo G2; góc bed_eye ở y=1,6 m. Trước là snapshot hình ảnh phòng PS1 với shader/postprocess PS1; ánh sáng trực tiếp và exposure giữ giống ảnh sau để so hình khối/vật liệu, ảnh sau thêm GI/SSAO/SSIL. Không giả đây là ảnh chơi một chương chạy logic.

T-213 chưa là cả phòng hoặc G3: phần ngoài góc, mùng, đồ giấy/cáp/nhân vật và phản ứng tương tác không được dựng lại. Integrator đánh giá trên ảnh: khung giường, chiếu, gối, chăn và bàn đứng được cạnh đồ Tripo; tổng thể góc rộng còn "sạch và trống" so với game AAA vì thiếu đồ lặt vặt, vết bẩn, dây điện. Chủ dự án quyết định đạt hay làm tiếp.

## Danh mục ảnh bàn giao

Các liên kết dưới đây chỉ có bằng chứng khi capture hoàn tất; xem RESULT và Handoff.

| Camera | Tuýp: trước | Tuýp: sau | Đèn pin: trước | Đèn pin: sau |
|---|---|---|---|---|
| Far, giống G2 | [room_far_tube_before.png](previews/room_far_tube_before.png) | [room_far_tube_after.png](previews/room_far_tube_after.png) | [room_far_torch_before.png](previews/room_far_torch_before.png) | [room_far_torch_after.png](previews/room_far_torch_after.png) |
| Near, giống G2 | [room_near_tube_before.png](previews/room_near_tube_before.png) | [room_near_tube_after.png](previews/room_near_tube_after.png) | [room_near_torch_before.png](previews/room_near_torch_before.png) | [room_near_torch_after.png](previews/room_near_torch_after.png) |
| Từ cửa | [door_wide_tube_before.png](previews/door_wide_tube_before.png) | [door_wide_tube_after.png](previews/door_wide_tube_after.png) | [door_wide_torch_before.png](previews/door_wide_torch_before.png) | [door_wide_torch_after.png](previews/door_wide_torch_after.png) |
| Giường, mắt 1,6 m | [bed_eye_tube_before.png](previews/bed_eye_tube_before.png) | [bed_eye_tube_after.png](previews/bed_eye_tube_after.png) | [bed_eye_torch_before.png](previews/bed_eye_torch_before.png) | [bed_eye_torch_after.png](previews/bed_eye_torch_after.png) |
| Giường/bàn cạnh Tripo | [tripo_comparison_tube_before.png](previews/tripo_comparison_tube_before.png) | [tripo_comparison_tube_after.png](previews/tripo_comparison_tube_after.png) | [tripo_comparison_torch_before.png](previews/tripo_comparison_torch_before.png) | [tripo_comparison_torch_after.png](previews/tripo_comparison_torch_after.png) |

Đối chứng: [tripo_comparison_tube_after_sdfgi_off.png](previews/tripo_comparison_tube_after_sdfgi_off.png). Metadata: [capture_report.json](previews/capture_report.json).
