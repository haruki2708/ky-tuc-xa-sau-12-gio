# Bộ module ký túc xá — T-102 / T-121

Pipeline: Python thuần trong Blender → GLB → Godot 4.7.2. Không cần addon hoặc thư viện Python bên ngoài.

## Công cụ

- Blender **5.2.2 LTS**, Windows x64 portable ZIP, xác minh ngày 2026-10-02.
- Executable: `D:\Tools\Blender\5.2.2\blender.exe`.
- [Nguồn ZIP và SHA256 chính thức](https://download.blender.org/release/Blender5.2/).
- ZIP SHA256: `3849d17a682cba006075aaa3f3597ecb5c9c30ec31035b2e092c53e40679b535`.
- `portable/` nằm cạnh executable; wrapper chuyển tài nguyên người dùng và temp sang `art_source/kit/.scratch.tmp/` (Git bỏ qua). Không cài công cụ vào ổ C:.
- Cài lại bằng `pwsh -File art_source/kit/install_blender.ps1`; script tải ZIP, kiểm tra SHA256 rồi giải nén vào ổ D:.

## Dựng và kiểm tra

Chạy từ gốc repo:

```powershell
pwsh -File art_source/kit/build_kit.ps1
pwsh tools/test.ps1
pwsh tools/check.ps1
```

Hoặc gọi trực tiếp theo task card:

```powershell
& 'D:\Tools\Blender\5.2.2\blender.exe' --background --python art_source/kit/build_kit.py
```

`build_kit.ps1 -Blender <path>` cho phép chỉ định executable khác, nhưng kiểm tra hash tái lập phải dùng cùng bản Blender và nền tảng. Script luôn dựng scene mới từ đầu, seed cố định 102, render Cycles CPU 24 samples. Không cần file `.blend` đầu vào. PNG preview loại metadata thời gian render; không thay đổi pixel.

- 9 GLB: `game/assets/models/kit/` (7 vật dụng, mùng đóng và mùng mở).
- 10 texture gốc 128 × 128 px: `game/assets/textures/kit/`.
- Preview từng vật: `art_source/kit/previews/<name>.png`, 512 × 512 px.
- Contact sheet: `kit/previews/contact_sheet.png`, 768 × 768 px. Hàng 1: tường, tường cửa, cửa; hàng 2: giường, tủ, quạt; hàng 3: ghế, mùng đóng, mùng mở.
- `kit/manifest.json`: kích thước và tam giác thật sau triangulate.
- `kit/build_hashes.json`: SHA256 của 29 đầu ra Blender (9 GLB, 10 texture, 10 preview). Ảnh Godot riêng không nằm trong danh sách này.
- GLB tham chiếu `../../textures/kit/<name>.png`. Bước đóng gói loại cả image bufferView lẫn byte PNG nhúng, rồi cập nhật offset/index của geometry; mỗi texture chỉ có một file trong repo. Phải giữ cấu trúc thư mục khi chuyển asset. Godot không còn tạo PNG trùng trong `models/kit/`.

Kiểm chứng tái lập hai lần build hoàn chỉnh:

```powershell
pwsh -File art_source/kit/verify_rebuild.ps1
```

Chụp lại showcase bằng renderer thật, từ gốc repo:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/kit/capture_showcase.gd --resolution 1280x720 --windowed --disable-vsync --quit-after 180
```

Ảnh ra `art_source/kit/previews/kit_showcase.png` (cận giường, thấy hình nộm sau mùng đóng) và `kit_showcase_overview.png` (cả bộ). Script tự thoát sau khi lưu. Không dùng `--headless` để chụp ảnh. Scene mở trực tiếp được ở `game/scenes/levels/kit_showcase.tscn`.

## Quy ước và điểm tích hợp

- Mét; Blender Z-up, mặt trước -Y. GLTF Y-up thông thường biến -Y thành +Z, vì vậy script bake thêm nửa vòng quanh Z vào các node con trước export để mặt trước cuối cùng là **Godot -Z**. Root giữ transform đơn vị; test kiểm tra phía tay nắm cửa.
- Vật đặt chân ở Y=0 trong Godot; riêng mùng giữ gốc tham chiếu tại chân giường. Gốc X/Z theo tâm kết cấu; quạt dùng tâm trục quay, cửa dùng chân bản lề.
- Tường: 2 × 3 × 0,2 m (X/Y/Z Godot); phần sơn chân tường cao 1,05 m. Ô cửa trống 0,9 × 2,1 m.
- Cửa: lá 0,88 × 2,08 m có khe lắp. Trong Godot lá trải từ X=-0,88 đến X=0; đặt pivot tại X=+0,44, Y=0,01 để vừa ô cửa đặt ở gốc. Xoay root quanh Y để mở; collision con theo root. Chưa gắn hành vi gameplay.
- Giường: 0,9 × 1,7 × 2,0 m (X/Y/Z), bao gồm thang và khung mùng. Thang nằm trong envelope được giao. Mùng là GLB riêng, không gộp vào giường.
- Ghế đỏ: cao 0,30 m, mặt bo góc 0,28 × 0,28 m, đáy loe 0,36 × 0,36 m; mỗi bên là tấm liền khoét vòm. Khe cầm xuyên hình học 0,09 × 0,026 m. Nhựa roughness 0,30; 320 tam giác.
- Quạt: node `fan_rotor` là con riêng, xoay local Y; thân/móc treo không xoay. Asset gốc đặt phần thấp nhất ở Y=0; showcase nâng lên 2 m để xem rõ.
- Tủ hai ngăn xếp dọc; bảng tên để trống. Không thêm chữ hiển thị, luật chơi hay cốt truyện.
- Texture nearest thuần: GLB sampler `minFilter=magFilter=9728`. Test xác nhận `BaseMaterial3D.TEXTURE_FILTER_NEAREST`, không cần đổi `project.godot`.
- Showcase là scene duyệt asset, có sàn collision world layer 1. Chưa lắp bộ kit vào màn chơi chính.
- Hướng T-102 đã được duyệt theo D-012; các thay đổi T-121 có ảnh mới để duyệt.

## Lắp mùng vào hai tầng

Hai GLB `mosquito_net_closed` (360 tam giác) và `mosquito_net_open` (372 tam giác) có cùng gốc tọa độ với giường, cùng envelope tham chiếu tầng dưới. Parent dưới node giường:

| Vị trí | Position Godot | Scale Godot | Cao độ mép / điểm treo |
|---|---|---|---|
| Tầng dưới | `(0, 0, 0)` | `(1, 1, 1)` | Y=0,415 / 1,075 m |
| Tầng trên | `(0, 0.8800379, 0)` | `(1, 0.7348485, 1)` | Y=1,185 / 1,670 m |

Cả hai biến thể dùng được ở cả hai tầng bằng transform trên. Tầng trên có khoảng treo thấp hơn, chỉ co theo Y; mesh không có collision. Mép dưới thấp hơn mặt chiếu 0,015 m để trông được dắt vào chiếu. Tầng dưới treo sát gầm giường trên, tầng trên treo dưới thanh khung mùng. Bản mở vén/cột giữa cạnh dài local X âm trong Godot. Grid có độ võng ở mái và nếp nhăn trên vách.

`net_weave.png` là texture RGBA 128 px có lỗ lưới alpha 0 và sợi alpha 1; 56,25% pixel là lỗ. GLB `alphaMode=MASK`, cutoff 0,5, hai mặt; Godot nhập thành alpha scissor. Chọn cách này để có lỗ nhìn xuyên và nét hạt PS1, tránh phải sắp xếp các lớp alpha blend. Lưới nearest có thể xuất hiện moiré khi nhìn xa; đây là mức lọc hiện tại của kit. Hình nộm capsule trong showcase chỉ là vật kiểm tra độ trong theo task card.

## Collision khi import

Sáu file `.glb.import` trỏ tới `res://assets/models/kit/kit_import.gd`, dùng [EditorScenePostImport](https://docs.godotengine.org/en/stable/classes/class_editorscenepostimport.html). Script lưu `StaticBody3D` và shape vào PackedScene khi import, không cần addon hoặc script chạy trong game.

- Tường thẳng, cửa, giường và tủ: một BoxShape3D theo bounds thực của mesh.
- Tường cửa: hai hộp trụ 0,55 × 2,1 × 0,2 m và một hộp dầm 2 × 0,9 × 0,2 m. Giữ ô trống 0,9 × 2,1 m.
- Ghế: một ConvexPolygonShape3D theo đỉnh mesh, ôm chân loe; các lỗ nhỏ không ảnh hưởng collision.
- Các body chỉ trên layer 1 (world), mask 0. Quạt và hai mùng không có collision.
- Collision giường/tủ/cửa là xấp xỉ hộp đặc, chưa mô phỏng khoảng trống bên trong hoặc chân giường. Không dùng cho tương tác chi tiết.
- Commit `.import` và `kit_import.gd.uid` cùng asset. Sau khi sửa import script, chọn Reimport các GLB liên quan; một lần import sạch cũng tự sinh collision đúng.
- Test `cast_motion` với capsule r=0,3 m, h=1,75 m đi hai chiều, giữa cửa và lệch ±0,14 m, kể cả tường đã xoay. Có đối chứng capsule bị trụ trái/phải và dầm chặn.

Nguồn và khai báo AI: [CREDITS.md](CREDITS.md).
