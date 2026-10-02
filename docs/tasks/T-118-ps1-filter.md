# T-118 — Filter hình ảnh PS1 và sửa import texture
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent: **Claude (integrator) làm thay lane B** theo yêu cầu chủ dự án (agent lane B hết hạn mức)
- Nhánh: `lane-b/T-118-ps1-filter`
- Phụ thuộc: T-102, T-121 (done). **Làm sau T-112** (dựng tầng). **Đọc `docs/SETTINGS.md`** (mục `[video] ps1_strength` và `[video] brightness`). Làm song song với T-116 của lane D.
- Lane B được thêm thư mục `game/rendering/` (xem `AGENTS.md` §3).

## Mục tiêu
Game có chất hình PS1 rõ rệt theo D-005: độ phân giải 3D thấp, lọc nearest, dithering, giảm số màu, đỉnh rung nhẹ. **UI, phụ đề và giấy tờ xem cận cảnh vẫn sắc nét.** Người chơi chỉnh được cường độ filter và độ sáng.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Sửa import texture (lỗi đang có):**
   - Khi mở project bằng editor, Godot tự đổi texture kit sang nén VRAM và bật mipmap, vì `detect_3d/compress_to=1`. Như vậy phá nét PS1 và làm file `.import` bị sửa mỗi lần mở editor.
   - Đặt `detect_3d/compress_to=0` cho mọi `.png.import` trong `game/assets/textures/kit/`. Giữ `compress/mode=0`, `mipmaps/generate=false`.
   - Nếu `build_kit.py` sinh hoặc ghi lại các file `.import` này thì sửa cả script.
   - Thêm test: mọi texture kit có mipmap tắt và không bị nén VRAM.
2. **Filter `game/rendering/ps1_filter.tscn`** cùng script và shader trong `game/rendering/`:
   - Chỉ ảnh hưởng hình 3D. **HUD (CanvasLayer layer 10), menu và giấy tờ không bị filter.** Đặt filter ở layer thấp hơn 10, ví dụ layer 1–5.
   - Hiệu ứng: hạ độ phân giải hiệu dụng (khoảng 320–480 px chiều cao, lọc nearest), dithering có thứ tự (Bayer 4×4), giảm độ sâu màu (khoảng 5 bit mỗi kênh). Có thể thêm fog hoặc màu cho hợp bảng màu lạnh trong GDD.
   - Cách làm do lane B chọn (SubViewport hoặc shader hậu kỳ đọc màn hình). Ghi lý do vào Handoff.
   - **Cài đặt:** đọc `[video] ps1_strength` (0 thì tắt hẳn hiệu ứng PS1) và `[video] brightness` (áp dụng kể cả khi tắt filter) lúc `_ready()`. Nghe `EventBus.settings_changed` và đọc lại khi đúng mục. Lane B chỉ đọc, không ghi file cài đặt.
3. **Rung đỉnh nhẹ (vertex snapping):**
   - Shader spatial cho mô hình kit: làm tròn vị trí đỉnh theo lưới màn hình độ phân giải thấp. Mức nhẹ, không gây chóng mặt.
   - Áp dụng cho kit bằng import script (`kit_import.gd`) hoặc material override; ghi lại cách làm.
   - **Không** làm "affine texture mapping" (méo texture), vì dễ gây khó chịu.
   - Mức rung theo `[video] ps1_strength`; bằng 0 thì không rung.
4. **Hiệu năng:** ≥ 60 FPS ở 1920×1080 trên máy dev (RTX 3050 Laptop) với `kit_showcase.tscn`. Ghi số FPS đo được vào Handoff.
5. **Scene thử:** cập nhật `kit_showcase.tscn` hoặc tạo `game/scenes/levels/ps1_showcase.tscn`, có filter và một Label HUD để chứng minh UI vẫn sắc nét.
6. **Test `game/tests/levels/`:**
   - Filter scene load được, nằm dưới layer 10.
   - `ps1_strength = 0` thì hiệu ứng tắt (tham số shader về mức trung tính); `brightness` vẫn áp dụng.
   - `settings_changed("video", "ps1_strength")` làm filter đọc lại giá trị.
   - Sao lưu và khôi phục `user://settings.cfg` của người dùng, như test T-104.
7. **Yêu cầu thay đổi:** ghi vào Handoff để integrator gắn filter vào `main.tscn`.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh so sánh cùng một góc: filter bật (`ps1_strength = 1`) và tắt (`0`); chữ HUD sắc nét ở cả hai ảnh
- [x] Số FPS đo được ghi trong Handoff
- [x] Mở project bằng editor xong, `git status` không còn file `.import` của texture kit bị sửa
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật nếu có asset mới
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Phiên 2026-10-02 — Claude (integrator) làm thay lane B
> Chủ dự án yêu cầu Claude làm task này vì agent lane B hết hạn mức. Làm trên nhánh `lane-b/T-118-ps1-filter`, chỉ sửa trong phạm vi lane B, cộng `project.godot` (shader global, thuộc integrator) và phần gắn vào `main.tscn` (integrator).

**Đã làm**
1. **Sửa import texture:** cả 10 texture kit trên `main` **đã bị commit ở dạng nén VRAM và có mipmap** (`compress/mode=2`, `mipmaps/generate=true`). Đặt lại `compress/mode=0`, `mipmaps/generate=false`, `detect_3d/compress_to=0`. `build_kit.py` không ghi file `.import`, nên không cần sửa script. Thêm test `test_kit_textures_are_lossless_without_mipmaps` (kiểm cả file `.import` lẫn ảnh đã import).
2. **Filter màn hình** `game/rendering/ps1_filter.tscn` (CanvasLayer layer 5, dưới HUD 10 và menu 20):
   - shader `ps1_screen.gdshader`: hạ độ phân giải (360 dòng khi strength = 1, nội suy về độ phân giải gốc khi strength giảm), dithering Bayer 4×4, 32 mức mỗi kênh (5 bit), nhân độ sáng;
   - chọn shader hậu kỳ đọc `hint_screen_texture` thay vì SubViewport: không phải đổi cấu trúc scene, và UI ở layer cao hơn tự nhiên không bị filter;
   - `ps1_filter.gd` đọc `[video] ps1_strength` và `[video] brightness` theo `docs/SETTINGS.md` (sai kiểu hoặc ngoài khoảng thì dùng mặc định), nghe `settings_changed`. Strength = 0 và brightness = 1 thì ẩn hẳn pass, không tốn chép màn hình. Tham số debug `-- --ps1-strength=X` chỉ dùng để chụp ảnh, không ghi file.
3. **Rung đỉnh nhẹ:** shader spatial `ps1_surface.gdshader` (đục) và `ps1_surface_cutout.gdshader` (alpha scissor, hai mặt, cho mùng), dùng chung `ps1_surface.gdshaderinc`: albedo lọc nearest, làm tròn vị trí đỉnh theo lưới 240 dòng chia cho `ps1_strength` (shader global trong `project.godot`, filter đặt giá trị). Strength = 0 thì không rung. Không làm affine texture mapping.
   - `kit_import.gd` chuyển vật liệu của **cả 9 mô hình kit** sang shader này khi import, giữ texture, màu và roughness. Thêm import script cho quạt và hai mùng.
   - Tắt `meshes/generate_lods` cho kit (mô hình vài trăm tam giác không cần LOD). Thay đổi này cũng làm mọi máy import lại kit, không dính bộ nhớ đệm cũ.
   - Hộp greybox của tầng 4 (vật tạm) chưa rung; khi thay bằng mô hình thật qua kit (D-021) sẽ tự có.
4. **Test:** `test_ps1_filter.gd` (5 test: dưới HUD, mặc định, strength 0 tắt nhưng brightness vẫn áp dụng, đọc lại khi đổi cài đặt, giá trị sai). Cập nhật `test_kit.gd` cho vật liệu shader. Test core kiểm filter có trong `main.tscn` và nằm dưới HUD.

**Kiểm tra**
- `pwsh tools/test.ps1`: `RESULT: 125 passed, 0 failed`. `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.
- Ảnh so sánh cùng góc (hành lang nhìn về tây, có phụ đề): `art_source/ps1/previews/ps1_strength_1.png` (bật) và `ps1_strength_0.png` (tắt). Chữ phụ đề sắc nét ở cả hai.
- **FPS** (`main.tscn`, vsync tắt, 240 frame sau 90 frame khởi động, Vulkan Forward+, RTX 3050 Laptop): **390 FPS** khi bật filter, **424 FPS** khi tắt.
- **Chưa kiểm** mục "mở editor xong `git status` không còn `.import` bị sửa" bằng giao diện editor (Claude không mở GUI). `--import` headless không còn sửa file; test khóa các giá trị import. Chủ dự án mở editor sẽ xác nhận.
- Chưa có người chơi thử cảm nhận độ rung đỉnh.

**Yêu cầu thay đổi:** không có (integrator tự gắn filter vào `main.tscn`).
