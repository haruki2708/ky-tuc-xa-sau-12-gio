# T-135 — Bóng người và gương

Đọc bố cục và diễn biến đã duyệt: `docs/design/RULES.md` §5b (D-024). Đây là thành phần hình ảnh, không tự kích hoạt luật, sting hay truy đuổi.

## Asset và dựng lại

- `res://scenes/levels/entity/silhouette.tscn`: bóng cao khoảng 1,85 m, gốc ở chân, mặt trước -Z, 408 tam giác. Script Blender dựng vai gù nhẹ, đầu nghiêng, tay dài; không mặt hoặc chi tiết quần áo. Shader đen có viền tối, rung đỉnh theo global `ps1_strength`, fade bằng ordered dither 4 × 4. Lắc lư nằm ở node con, không làm đổi transform gốc của controller.
- `set_visible_amount(value: float)`: clamp 0…1, có thể gọi trước `_ready()`; mỗi instance có material riêng. 0 ẩn hẳn. Không có collision hoặc logic đuổi; gán scene này vào `Pursuer.body_scene` của Lane A.
- `reflection_body.tscn`: 612 tam giác, áo thun, quần đùi, dép; `HeadPivot` riêng để quay đầu. Vật liệu màu phẳng dùng shader PS1 hiện có, chuyển tại bước import bằng `reflection_import.gd` như pipeline kit. Không collision/shadow; mesh chỉ nằm trên render layer 20.

```powershell
& 'D:\Tools\Blender\5.2.2\blender.exe' --background --python art_source/entity/build_entity.py
pwsh tools/test.ps1 -Filter mirror
```

Script dùng Blender đã có, không cài addon. Blender có thể báo không ghi được cache extension khi chạy trong sandbox; hai GLB vẫn được tạo thành công. `manifest.json` lưu số tam giác từ nguồn; test kiểm tra lại mesh sau import Godot. GLB/PNG qua Git LFS; `.import` và `.uid` đi cùng source.

## Gương và API tích hợp

`Floor4/Washroom/Mirror` đã thay hộp cũ bằng `res://scenes/levels/mirror.tscn`, script `res://scenes/levels/mirror.gd`. Mặt gương có trục local +Z hướng vào phòng, +Y lên trên. Trong nhà vệ sinh nó nằm tại `(0.145, 1.62, -1.85)`, quay Y=90°. Phần generator T-112 cũng đã đổi tham chiếu để không tạo lại hộp cũ.

Integrator gán sau khi các node sẵn sàng:

```gdscript
var mirror = $Floor4/Washroom/Mirror
mirror.follow = $Player
mirror.set_lag(0.5)
# Khi luồng chơi yêu cầu:
mirror.stare()
# Điểm world-space để đưa cho Pursuer.start_chase:
var spawn: Vector3 = mirror.step_out()
# Kết thúc hiệu ứng hoặc tải checkpoint:
mirror.release()
```

- `@export var follow: Node3D`: gốc Player ở chân; lấy camera `Head/Camera3D` hoặc Camera3D con đầu tiên. Thiếu follow/camera thì gương tắt. Không tự tìm Player bằng đường dẫn tới main.
- `set_lag(seconds)`: 0 bám ngay, 0,5 trễ nửa giây. Clamp 0…10 giây; NaN/INF về 0. Lịch sử lưu vị trí/hướng thân và hướng camera; nội suy giữa hai mẫu. Chưa đủ lịch sử thì giữ mẫu sớm nhất. Ra khỏi phòng xóa lịch sử để lần vào sau không hiện tư thế cũ.
- `stare()`: khóa vị trí/hướng thân ở mẫu đang hiển thị; đầu quay nhanh, êm về camera ảo phía sau mặt gương. Kết quả trên kính là nhìn thẳng vào người chơi, tiếp tục theo mắt người chơi khi họ di chuyển. Không tự phát âm hoặc gọi truy đuổi.
- `release()`: bỏ stare, đặt lag=0, xóa lịch sử và bám tư thế hiện tại ở frame kế tiếp. Integrator gọi lại `set_lag()` nếu muốn chu kỳ mới.
- `step_out() -> Vector3`: vị trí `(1.27, 0.03, -1.85)` trong bố cục hiện tại, trước bồn, có sàn và đủ chỗ capsule r=0,3 m cao 1,85 m. Tính theo transform phòng để dùng được khi cả tầng dịch chuyển.
- Cây scene pause thì lịch sử/tư thế ngừng cập nhật. Scene không đọc tùy chọn `reduce_scares`; integrator quyết định bỏ `stare()`/fade hình đột ngột theo hợp đồng D-024.

## Kỹ thuật render

SubViewport **560 × 190**, dùng chung World3D với phòng, có camera riêng; không instance lại HUD/CanvasLayer, không có audio listener. Camera đặt ở vị trí mắt đối xứng qua mặt kính, frustum lệch tâm khớp bốn mép kính; near plane ở kính loại bức tường sau lưng. Texture lật ngang để trả đúng phép phản chiếu. Tham khảo API chính thức: [Camera3D.set_frustum](https://docs.godotengine.org/en/stable/classes/class_camera3d.html#class-camera3d-method-set-frustum).

Camera/phòng luôn theo mắt hiện tại để parallax không trôi; chỉ hình người có độ trễ theo API. Đây là phản chiếu căn phòng hiện tại, không phải ảnh quay sẵn hay toàn bộ khung hình bị trễ.

- Layer 19: mặt kính; camera gương loại layer này để tránh phản chiếu đệ quy.
- Layer 20: thân phản chiếu; camera Player được tắt bit này lúc bind, khôi phục đúng giá trị cũ lúc unbind hoặc gương thoát tree. Không sửa file Player/project. Camera bổ sung do integrator tạo cũng cần loại layer 20.
- Chỉ bật UPDATE_ALWAYS khi chân follow nằm trong `room_bounds` theo tọa độ Washroom và mắt ở trước kính; ngoài phòng dùng UPDATE_DISABLED, ẩn thân và mặt kính chuyển màu tối. Bounds mặc định khớp phòng 6 × 5 m.
- Thiết kế cho một gương nhà vệ sinh và một Player. Chưa thiết kế cơ chế chia sẻ layer/mask cho nhiều gương cùng theo một camera.

## Chơi thử, ảnh và FPS

Mở `res://scenes/levels/entity/mirror_test.tscn`, F6. WASD/chuột như Player; **1** về gương bình thường, **2** đặt lag 0,5 s (đi ngang/xoay để thấy trễ), **3** stare, **4** tới hành lang tối có bóng. Bấm 1 để release. Esc mở menu hiện có. Scene thử không thêm chữ gameplay hoặc key localization.

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/entity/capture_entity.gd --resolution 1280x720 --windowed --disable-vsync -- --ps1-strength=1
pwsh tools/test.ps1
pwsh tools/check.ps1
```

`previews/` có ba ảnh: `silhouette_corridor.png`, `mirror_normal.png`, `mirror_stare.png`; `performance.json` ghi FPS từ thời gian thực (không fixed-fps), warm-up 90 frame + đo 240 frame mỗi góc, VSync tắt. Scene chứa toàn bộ tầng, Player physics/HUD/âm thanh và filter PS1. Script thoát qua `App.quit()` để drain âm thanh.

Đã kiểm tra ảnh render và test tự động. Chưa có phiên người dùng chơi thử bằng chuột/bàn phím; chưa ghép hoặc thử đoạn truy đuổi T-134/T-136. FPS là mẫu đứng yên trên máy được ghi trong JSON, không phải cam kết mọi cấu hình máy.
