# Bộ module ký túc xá — T-102

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
```

Hoặc gọi trực tiếp theo task card:

```powershell
& 'D:\Tools\Blender\5.2.2\blender.exe' --background --python art_source/kit/build_kit.py
```

`build_kit.ps1 -Blender <path>` cho phép chỉ định executable khác, nhưng kiểm tra hash tái lập phải dùng cùng bản Blender và nền tảng. Script luôn dựng scene mới từ đầu, seed cố định 102, render Cycles CPU 24 samples. Không cần file `.blend` đầu vào. PNG preview loại metadata thời gian render; không thay đổi pixel.

- 7 GLB: `game/assets/models/kit/`.
- 9 texture gốc 128 × 128 px: `game/assets/textures/kit/`.
- Preview từng vật: `art_source/kit/previews/<name>.png`, 512 × 512 px.
- Contact sheet: `kit/previews/contact_sheet.png`, 1024 × 512 px. Thứ tự trái sang phải: tường, tường cửa, cửa, giường; hàng dưới: tủ, quạt, ghế.
- `kit/manifest.json`: kích thước và tam giác thật sau triangulate.
- `kit/build_hashes.json`: SHA256 của 24 đầu ra Blender (7 GLB, 9 texture, 8 preview). Ảnh Godot riêng không nằm trong danh sách này.
- Godot mặc định tách ảnh nhúng GLB thành các PNG có tiền tố tên model trong `game/assets/models/kit/`; các bản sao này và `.import` được commit cùng asset.

Kiểm chứng tái lập hai lần build hoàn chỉnh:

```powershell
pwsh -File art_source/kit/verify_rebuild.ps1
```

Chụp lại showcase bằng renderer thật, từ gốc repo:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/kit/capture_showcase.gd --resolution 1280x720 --windowed --disable-vsync --quit-after 180
```

Ảnh ra `art_source/kit/previews/kit_showcase.png`. Script tự thoát sau khi lưu. Không dùng `--headless` để chụp ảnh. Scene mở trực tiếp được ở `game/scenes/levels/kit_showcase.tscn`.

## Quy ước và điểm tích hợp

- Mét; Blender Z-up, mặt trước -Y. GLTF Y-up thông thường biến -Y thành +Z, vì vậy script bake thêm nửa vòng quanh Z vào các node con trước export để mặt trước cuối cùng là **Godot -Z**. Root giữ transform đơn vị; test kiểm tra phía tay nắm cửa.
- Vật đặt chân ở Y=0 trong Godot. Gốc X/Z theo tâm kết cấu; quạt dùng tâm trục quay, cửa dùng chân bản lề.
- Tường: 2 × 3 × 0,2 m (X/Y/Z Godot); phần sơn chân tường cao 1,05 m. Ô cửa trống 0,9 × 2,1 m.
- Cửa: lá 0,88 × 2,08 m có khe lắp. Trong Godot lá trải từ X=-0,88 đến X=0; đặt pivot tại X=+0,44, Y=0,01 để vừa ô cửa đặt ở gốc. Xoay root quanh Y để mở. Chưa gắn hành vi gameplay/collision.
- Giường: 0,9 × 1,7 × 2,0 m (X/Y/Z), bao gồm thang và khung mùng. Thang nằm trong envelope được giao. Không có vải mùng.
- Quạt: node `fan_rotor` là con riêng, xoay local Y; thân/móc treo không xoay. Asset gốc đặt phần thấp nhất ở Y=0; showcase nâng lên 2 m để xem rõ.
- Tủ hai ngăn xếp dọc; bảng tên để trống. Không thêm chữ hiển thị, luật chơi hay cốt truyện.
- Texture nearest thuần: GLB sampler `minFilter=magFilter=9728`. Test xác nhận `BaseMaterial3D.TEXTURE_FILTER_NEAREST`, không cần đổi `project.godot`.
- Showcase là scene duyệt asset, có sàn collision world layer 1. Chưa lắp bộ kit vào màn chơi chính.
- Hướng hình ảnh còn chờ chủ dự án duyệt qua contact sheet và ảnh Godot.

Nguồn và khai báo AI: [CREDITS.md](CREDITS.md).
