# T-213 — góc phòng 407, pilot độc lập

Cảnh: `game/scenes/levels/graphics_pilot/room407_corner_pilot.tscn`. File xem trong Blender: [room407_corner.blend](room407_corner.blend), texture dùng đường dẫn tương đối trong repo và `blender_textures/`. Mở cùng checkout đã lấy LFS, không chép riêng file `.blend`. Bản chơi và các marker gameplay giữ nguyên.

## Dựng lại

Từ gốc workspace Lane B, Python có Pillow/numpy đã dùng trong pipeline repo, Blender portable 5.2.2:

```powershell
python -B art_source/graphics_upgrade/room407_corner/fetch_textures.py
python -B art_source/graphics_upgrade/room407_corner/make_decals.py
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
| Sàn | x=0…5,5; z=−7…0; mặt trên y=0 (mở tới cửa để giữ vị trí dép/giày) |
| Tường tây | tâm x=0, dày 0,2; mặt trong x=0,1; cao 3 |
| Tường sau | z=−7, dày 0,15; mặt trong −6,925; BackWest rộng 2,3, BackEast rộng 1,9 |
| Ô mở ban công | x=2,3…3,3; y=0…2,3, lintel tâm y=2,65; khung bao trong pilot |
| Trần | mặt dưới y=3; dày 0,15 |
| Giường A | tâm (0,65;0;−3); cột x=0,22/1,08, z=−3,98/−2,02; nệm 0,8×0,05×1,9; mặt nằm y=0,43/1,20 |
| Bàn | tâm x=1,8 z=−4,55; rộng 1,5, sâu 0,65, mặt trên y=0,76 |
| Đèn tuýp | giữ vị trí hiện hành x=2 z=−1,2; mesh ở y≈2,84…2,91; light y=2,76 |

View/Exit và Corpse1/2 chỉ đọc từ `room407_anchors.tscn`, **không thay hoặc tạo collider**. Test đối chiếu actual bounds nhập GLB, không chỉ so metadata. Lún nệm tối đa 3 mm, cạnh vát 3…18 mm tùy vật; điểm bằng ở mặt nệm vẫn trong sai số 1 cm. Vải chăn có lưới nếp gấp, viền gấu; khung sắt ống tròn có vòng hàn và đầu bu-lông. Bàn có cạnh vát, yếm, ngăn kéo/tay nắm/chân ống.

## Đồ Tripo

[placements.json](placements.json) là một nguồn chung cho Godot, Blender, báo cáo. Giữ X/Z và hướng từ scene cũ. Balo yaw +90°; tủ/nồi quay mặt −X (yaw +90°), pivot bản chuẩn hóa nằm ở đáy nên tủ y=0 thay tâm hộp cũ 0,42; nồi đặt y=0,84. Khăn gấp chuẩn hóa đã nằm ngang: không áp lại X=90°/scale=0,5 của khăn treo cũ; hạ y=0,2798 (đỉnh xô đo từ GLB ở y≈0,2792 + bù min khăn −0,0006; bucket root 0,015, cao thực ≈0,2643). Giày dùng vị trí `Details/Dat/Trainers`, dép dùng `Details/Slippers/Trung`; không dời vào góc chỉ để đẹp ảnh.

Nguồn/license từng bộ và model tại [CREDITS.md](CREDITS.md). File `.blend` chứa cả 8 đồ Tripo để xem trực tiếp; GLB mới chỉ chứa hình học tự dựng, Godot tham chiếu model Tripo đã có.

## Ngân sách, mật độ và ánh sáng

Số đếm xuất Blender tại [geometry_report.json](geometry_report.json): floor 432, architecture 540, fixtures 2.004, bunk_a 7.016, study_desk 1.400; tổng dựng mới **11.392** tam giác, Tripo **37.637**, tổng **49.029**. Mỗi mảnh kiến trúc <8.000; giường <8.000, bàn <8.000; không cộng cả phòng rồi áp trần một đồ vật. Từng GLB có tối đa 2 vật liệu. Giữ file ≤10 MiB, LFS. Audit GLB độc lập `audit_assets.py` xác nhận **49.029 tam giác, 42 map nhúng riêng biệt theo SHA-256 + 1 decal = 43 texture nội dung** (18 map CC0 + 24 map Tripo + decal); texture lặp giữa GLB được khử trùng khi tính nội dung. Số resource thực nhập và số tam giác runtime được báo thêm trong `capture_report.json`.

5 bộ × 3 map + bản 1K vữa cho chi tiết nhỏ = **18 map nguồn**, thêm **1 decal 512²**. ARM đã gộp AO/roughness/metallic; texture Tripo tính riêng, không tính trùng source JPEG với bản nhúng GLB như hai nội dung khác nhau. UV tường 1 vòng/3,2 m với 2048 px (**640 px/m**); sàn 1 vòng/2 m (**1024 px/m**). Gỗ 1 vòng/0,55 m; vải 1 vòng/0,35 m. Bề mặt nhỏ không được nâng ảnh thành 2K để tăng số giả.

Thử **SDFGI**: 4 cascades, cell 0,1 m, sky disabled trong nội thất, occlusion bật, bounce feedback 0,5. Mesh tĩnh `GI_MODE_STATIC`, ánh sáng dynamic để thay đèn tuýp/đèn pin. [Căn cứ Godot](https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_sdfgi.html). Có ảnh đối chứng SDFGI tắt cùng camera/vật liệu/exposure để xem ảnh hưởng thực; SSAO/SSIL giữ nguyên trong đối chứng. Chưa đo hiệu năng/FPS.

WorldEnvironment riêng: Filmic exposure=1; ambient xanh nhẹ energy=0,12; SSAO radius=0,35/intensity=1; SSIL radius=2/intensity=0,6; fog density=0,004; glow=0,25. Đèn tuýp energy=3,8, range=8, light_size=0,25, shadow bật; đèn bàn energy=0,55 màu ấm; đèn pin Spot energy=5/range=10/cone=38°, dưới camera 0,12 m. Không đổi project/default renderer. Ưu/nhược quan sát thực ghi sau khi xem ảnh.

## Kiểm chứng và phần chưa nghiệm thu

Trạng thái đang thực hiện: đã xuất Blender và nhập headless; chưa có kết quả test riêng/full test/check hoặc ảnh renderer của T-213. Không dùng RESULT T-209 thay cho task mới. Chờ lượt Godot trống được integrator bàn giao qua chủ dự án.

Ảnh kế hoạch: `previews/{room_far,room_near,door_wide,bed_eye,tripo_comparison}_{tube,torch}_{before,after}.png` (20 ảnh); thêm `tripo_comparison_tube_after_sdfgi_off.png`. Hai camera far/near giữ đúng eye/target/FOV=70 của balo G2; góc bed_eye ở y=1,6 m. Trước là snapshot hình ảnh phòng PS1 với shader/postprocess PS1; ánh sáng trực tiếp và exposure giữ giống ảnh sau để so hình khối/vật liệu, ảnh sau thêm GI/SSAO/SSIL. Không giả đây là ảnh chơi một chương chạy logic.

T-213 chưa là cả phòng hoặc G3: phần ngoài góc, mùng, đồ giấy/cáp/nhân vật và phản ứng tương tác không được dựng lại. Chất lượng cạnh giường/bàn so đồ Tripo cần xem ảnh thực; chưa tự đánh dấu đạt.

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
