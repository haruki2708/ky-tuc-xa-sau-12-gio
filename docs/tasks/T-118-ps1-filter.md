# T-118 — Filter hình ảnh PS1 và sửa import texture
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-118-ps1-filter`
- Phụ thuộc: T-102, T-121 (done). **Đọc `docs/SETTINGS.md`** (mục `[video] ps1_strength` và `[video] brightness`). Làm song song với T-116 của lane D.
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh so sánh cùng một góc: filter bật (`ps1_strength = 1`) và tắt (`0`); chữ HUD sắc nét ở cả hai ảnh
- [ ] Số FPS đo được ghi trong Handoff
- [ ] Mở project bằng editor xong, `git status` không còn file `.import` của texture kit bị sửa
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật nếu có asset mới
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
