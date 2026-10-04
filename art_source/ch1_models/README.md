# T-154 — Model và đạo cụ chương 1

Model tự dựng bằng hình học Godot, các khớp Node3D và AnimationPlayer; không cần Skeleton3D, importer model, plugin hoặc tải asset ngoài. Scene vẫn chỉnh được trong editor. Generator Python chỉ dùng thư viện chuẩn; texture thủ tục 128 px, shader PS1 dùng lại của dự án. Nguồn và khai báo AI ở [CREDITS](../CREDITS.md).

## Scene và số tam giác

Tất cả ở `res://scenes/levels/ch1_models/`:

| Scene | Tam giác | Ghi chú |
|---|---:|---|
| `manager_body.tscn` | 776 | Đồng phục cũ, mặt tối chỉ miệng sáng, dao dài; cao khoảng 1,94 m ở pose nghỉ |
| `corpse_phuc.tscn` | 592 | Áo đỏ, thân rộng 0,39 m |
| `corpse_viet.tscn` | 592 | Áo kẻ, thân hẹp 0,34 m |
| `corpse_dat.tscn` | 616 | Áo thể thao đen hai sọc, thân rộng 0,42 m |
| `charger.tscn` | 60 | Cục sạc hai chấu, cổng USB |
| `router.tscn` | 180 | Hai anten, khe tản nhiệt, LED |
| `dat_notebook.tscn` | 108 | Mặt giấy với ba Label3D riêng, font tiếng Việt có sẵn |
| `phone_viewmodel.tscn` | 50 | Màn hình QuadMesh riêng tên `Screen` |
| `bed_debris.tscn` | 72 | Mút, vải nệm rách, gỗ vụn |
| `rag.tscn` | 40 | Giẻ có nếp gấp, chuẩn bị cho chương 2 |

Đếm tất cả mesh, cả phần đang ẩn; Label3D sinh chữ theo nội dung không nằm trong số tam giác hình học của sổ. Không model nào thêm collider hoặc AI.

## Quản lý

Gán `manager_body.tscn` vào `body_scene` của T-152. Gốc ở chân, +Y lên, phía trước là **-Z**, đơn vị mét. `AnimationPlayer` trực tiếp dưới root:

| Clip | Độ dài | Loop |
|---|---:|---|
| `stand` | 2,4 s | Có, autoplay |
| `walk` | 1,6 s | Có; hai chân/ tay trái đung đưa, tay dao giữ mũi sát sàn |
| `ask` | 2 s | Không, nghiêng đầu sang giường |
| `slash` | 1,2 s | Không; nâng dao tại 0,40 s, giữ tới 0,57 s, xuống tại 0,77 s, trở về nghỉ cuối clip |
| `lunge` | 0,65 s | Không; nghiêng người và dịch Rig tối đa 0,36 m về -Z |
| `kill` | 0,9 s | Không; giơ dao rồi chém gần camera, nhát xuống tại 0,46 s |

`RESET` cũng có. Mỗi clip ghi đầy đủ các kênh pose để chuyển từ lunge/slash sang stand không giữ lại offset. Các clip không dịch root/collision; Lane A điều khiển vị trí, hướng, nhịp chém, giảm hù dọa và tín hiệu gameplay. Có thể gọi `play("slash")` lại sau mỗi lần kết thúc để chém nhiều nhát; không có method track gây sát thương.

**`BladeTip` ngay dưới root** là Marker3D ổn định cho âm thanh. Script đồng bộ nó với `Rig/Hips/Chest/RightArm/Elbow/Hand/BladeTip` sau AnimationPlayer mỗi frame. Ở stand/walk, y=0,015 m so với gốc chân. Khi seek clip bằng tool/test, gọi `BladeTip._process(0)` trước khi đo ngay trong cùng frame. Nguồn âm có thể làm con của marker hoặc lấy global_position. Không đính sẵn manager_audio để tránh nhân đôi nguồn của T-152/T-158.

## Xác bạn cùng phòng

Scene đã nằm tại `Room407/Anchors/Corpse1/Body`, `Corpse2/Body`, `Corpse4/Body`; gốc đúng tâm mặt nệm, đầu hướng +Z. Capsule `Sleeper_*` cũ giữ node path và ẩn. Không đặt xác trên giường Trung.

`AnimationPlayer` có `dead_a`, `dead_b`, `head_turn`, `eyes_open`, **`sit_up`** và `RESET`. Các pose dài 0,01 s, một khung, không loop. Có thể dùng trực tiếp cho `unseen_poser` hoặc gọi `set_pose(StringName) -> bool` (áp ngay, pause ở pose; tên không hợp lệ trả false). `dead_a` sạch, mắt nhắm và tay dọc thân; `dead_b` buông tay phía lối giữa; `head_turn` quay đầu vào giữa phòng, hướng của Đạt đối xứng hai giường bên kia; `eyes_open` mở mắt; `sit_up` dựng thân, mắt trống rỗng. Các pose đều khôi phục được bằng dead_a.

`set_blood_visible(bool)` chỉ bật mảng đỏ sẫm trên áo, không chi tiết giải phẫu. `Room407.set_blood_stage()` đã chuyển tiếp trạng thái này tới cả ba body: stage 0 sạch, stage 1/2 có vết. Pose không tự thay đổi máu. Mặc định dead_a + không máu để dùng trong mở đầu. Chưa gắn unseen_poser hoặc quyết định thời điểm chết.

`sit_up` là model chuẩn bị chương 2; dàn cảnh chương 2 cần xử lý mùng/giường tầng và vị trí ngồi riêng, chưa được coi là đã tích hợp gameplay chương 2.

## Đạo cụ và vị trí

- `Room407/Anchors/DatLocker/Charger`: nằm trong tủ sắt phía đông, bị cánh tủ che khi đóng; không tự nhặt hoặc mở tủ.
- `Room407/Anchors/Router/Model`: `set_led(bool)`, bật cho LED nháy chu kỳ 1,2 s; false tắt hẳn; pause cây scene dừng nháy. Router cũ trong Details đã ẩn. Không đổi trạng thái mạng/câu đố.
- `Room407/Anchors/DatNote/Model`: `set_content(title, student_name, birth_date)` nhận chuỗi đã dịch từ integrator. Scene để trống, không tự chọn mã. Ba node `Title`, `Name`, `BirthDate` có font Be Vietnam Pro, nearest, chữ tối trên nền giấy sáng; preview dùng **key DOC_CH1_DAT_CARD_* đã có trên main**. Khối sổ hạ 0,027 m so với anchor để mặt giấy không che Readable hiện có của chapter1_main. Khi tích hợp chọn một lớp chữ, tránh trùng chữ giữa Readable và Label3D.
- `phone_viewmodel.tscn`: gốc ở giữa điện thoại, màn hình hướng **-Z**, +Y là đầu máy. `Screen` là MeshInstance3D có QuadMesh 0,064 × 0,127 m, UV 0..1; `set_screen_texture(Texture2D)` chấp nhận ViewportTexture và tạo material riêng từng instance, null trả màn tối. Gợi ý gắn dưới Camera ở `(0.18,-0.16,-0.42)`, xoay Y=180° để màn hướng về camera; Lane A/D tinh chỉnh cùng UI, chưa tự sửa scene Player.
- `Room407/Details/Debris/RichDebris` hiện/ẩn theo set_slashed() hiện có; giẻ cố định ở `Room407/Details/CleaningRag`. Chưa có physics cho vụn hoặc hành vi nhặt giẻ.

## Dựng lại và kiểm tra

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/ch1_models/build_models.py
# Lần đầu chạy Godot --headless --path game --editor --import, rồi ghim import PNG:
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/ch1_models/configure_imports.py
pwsh tools/test.ps1 -Filter ch1_models
pwsh tools/test.ps1
pwsh tools/check.ps1
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/ch1_models/capture_models.gd --resolution 1280x720 --windowed --disable-vsync -- --ps1-strength=1
```

Nếu dựng lại tầng/T-153 bằng generator cũ, chạy generator này sau cùng để phục hồi placement T-154. Runtime patch chuyển blood_stage tới body trong room407.gd giữ nguyên khi sinh lại scene.

F6 `models_test.tscn`: trái/phải đổi 10 model; 1..6 chọn stand/walk/ask/slash/lunge/kill, hoặc 1..5 chọn các pose xác. Đây chỉ là showroom hình ảnh, không chạy luật chương. Ảnh ở [previews](previews/), số tam giác ở [manifest](previews/manifest.json). Có ảnh từng model, animation quản lý, pose xác, phòng đủ ba xác và góc nằm ba giường. Chưa chơi thử thủ công trọn chương hoặc ghép T-152 với viewmodel/UI T-155.
