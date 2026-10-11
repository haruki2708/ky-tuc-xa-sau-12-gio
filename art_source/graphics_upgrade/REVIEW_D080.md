# T-209 — xử lý Review G0, chuẩn bị G1 sau D-080

Base `acbf771`, nhánh T-209 giữ nguyên. G0 `87e99a6` đã ghép D-079; không làm lại. **Astra (integrator) đã nhận T-207 thay Claude web**, là đầu mối các yêu cầu core/contract dưới đây; C vẫn sở hữu schema/công cụ, B sở hữu dữ liệu. Không sửa STATUS/DECISIONS/Review card.

## Balo và mapping gửi Astra/C

[Brief Tripo Studio và quy trình nhận/xuất](TRIPO_BACKPACK.md) bổ sung bounds/pivot/trục, transform đặt cảnh, trần prototype đã review và hồ sơ provider/wallet/model/credit/license. Không bắt balo chờ rig/settings/chuông; vẫn cần G1 đạo cụ tĩnh được ghép và quyền tạo asset riêng.

Manifest hiện hành vẫn là bản nháp G0. B đề xuất mapping dưới đây, **chưa chuyển dữ liệu sang schema C** vì `t210-g0-proposal-1` trên main chưa là G1 đã review. Không đặt trường không biết thành số 0 hoặc giả `approved` để vượt validator.

| Dữ liệu B | Đích đề xuất cho Astra/C | Cần chốt |
|---|---|---|
| `id` | `asset_id` | Giữ `room407_backpack` và ID hiện hành |
| `current_scene` + `measurement_node` | `scene_path` + `binding` | Giữ `res://` cho binding runtime; file artifact dùng path tương đối repo |
| Root node hiện hành | `root_class`, `collider_policy`, `required_markers` | Balo là Node3D visual; root đặt cảnh bất biến, không thêm collider/nav; không có marker mới cần tạo |
| `measured_assets.json` bounds local | `geometry.dimensions_m`, `bounds_min_m` | Loại transform root khỏi phép đo; rest pose, khai báo có/không biến thể ẩn |
| World position/yaw/scale | Nhóm placement riêng của C | Không nhét tọa độ world vào geometry/markers local; không tự chọn tên trường |
| `source`/CREDITS | `source`/provenance + hồ sơ artifact | Tách nguồn CC0 cũ khỏi nguồn Tripo mới, URI bền vững và hash dependency/import |
| `planned_route` | Kế hoạch provider/channel riêng | `Tripo AI` / `Studio`; kế hoạch không phải bằng chứng đã tạo |
| Hồ sơ operator | `generation` và ledger tương ứng | Model version, UI parameters, task/model ID nếu có, ngày, prompt/input; Studio/API không chung số dư |
| D-079 prototype | `budget` | `triangle_limit_exclusive=3001`; 2 material, 1024², 10 MiB; chưa đo output/chi phí thì pending/null |
| Review/đồng ý thực tế | `approval` | Tách quyền nguồn, QA kỹ thuật và duyệt hình; thiếu chứng cứ không là PASS |

Yêu cầu Astra/C: ghép schema G1 + fixture root có dịch/xoay/scale + dependency hash rồi B chuyển manifest bằng commit riêng. Chưa có artifact Tripo nên không tạo record giả để validator nhận PASS. API live không là dependency của đường Studio thủ công.

## Mount chuông: có điểm vướng hình học

Nguồn âm giữ `(42,-7.7,0.2)`, noise/crowd giữ `(42,-9.9,2)`. Tên `Campus/Anchors/FireBellMount` là đề xuất đã nhận để khảo sát, **chưa thêm node production**.

Scene thật `campus/building_b.tscn`, `Floor1`:

| Mesh | Bounds liên quan (world, mét) |
|---|---|
| `Door7/Mesh` | tâm `(41.25,-8.7,0)`, size `(1.7,2.4,0.1)` → x `[40.4,42.1]`, y `[-9.9,-7.5]`, mặt hành lang z `0.05` |
| `Facade7R/Mesh` | tâm `(43.05,-8.4,0)`, size `(1.9,3,0.16)` → x `[42.1,44]`, y `[-9.9,-6.9]`, mặt hành lang z `0.08` |
| `Lintel7/Mesh` | tâm `(41.25,-7.15,0)`, size `(1.7,0.5,0.16)` → y `[-7.4,-6.9]` |

Tâm nguồn âm chiếu vào khối `Door7` gốc, thấp hơn lintel gốc. Tuy nhiên scene còn có `KitDetail1/Frame7` (GLB `wall_door`) đặt tại `(41.25,-9.9,0)`: ảnh renderer cho thấy khung plaster phía trên/bên phải cửa nhìn thấy. Vì vậy không kết luận tâm âm nằm trên **cánh nhìn thấy** chỉ từ bounds Door7; hai lớp geometry cần phân biệt. Chưa xác nhận chi tiết bắt vít production và không dịch nguồn âm/cửa/collider để giải quyết.

Fixture `bell_mount_probe.tscn` đề xuất **giá đỡ lệch sang tường**: đĩa đỏ đường kính 0.28 m, sâu 0.12 m, tâm trùng nguồn âm; backplate tâm `(42.3,-7.7,0.09)`, size `(0.1,0.3,0.02)`, mặt sau chạm z=0.08 của facade. Tay đỡ nối về tâm chuông; chỉ là khối khảo sát, chưa phải model sản xuất. Basis mount đề xuất identity, +Y lên, +Z hướng hành lang; gốc vẫn là điểm âm. Đĩa x `[41.86,42.14]` lấn qua hình chiếu mép cửa, cần Astra/F review vị trí nhìn và loại giá đỡ trước khi chốt. Không thêm collider/tương tác/âm hoặc sửa campus.

Đã xem hai ảnh Forward+ RTX 3050 Laptop 1280×720: [chính diện](review_d080/bell_front.png), [góc nghiêng](review_d080/bell_side.png). Đĩa và giá đỡ nhìn thấy, backplate nằm trước mảng facade bên phải; đây là phương án khảo sát chờ Astra/F chọn, chưa nghiệm thu mỹ thuật hoặc clearance khi có thay asset cửa thật. Metadata camera/renderer trong `review_d080/capture_report.json`; không thay 12 ảnh G0. Lệnh sau chỉ chạy khi integrator bàn giao lượt, dùng APPDATA cục bộ dưới `build/graphics-pilot-userdata`:

```powershell
& D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path game --rendering-method forward_plus --windowed --resolution 1280x720 res://scenes/levels/graphics_pilot/bell_mount_probe.tscn -- --bell-mount-capture
```

## Cleanup shader và brightness gửi Astra/D

Pilot dùng `ShaderGlobalsOverride` với `params/ps1_strength` theo vòng đời fixture, thay việc ghi đè base global. Khi fixture rời cây, engine bỏ override, lộ lại **giá trị base hiện hành**, kể cả caller đổi base lúc pilot đang mở. Không đọc global qua API có hạn chế runtime, không lưu/khôi phục snapshot settings cũ. Brightness trong pilot chỉ có consumer `screen` (shader `ps1_screen.gdshader`); đọc `Settings.get_value("video", "brightness")` và signal hiện hành, không tạo PS1Filter gameplay song song hay ghi config.

Căn cứ engine: [ShaderGlobalsOverride](https://docs.godotengine.org/en/stable/classes/class_shaderglobalsoverride.html), [mã nguồn property `params/` và exit cleanup](https://github.com/godotengine/godot/blob/master/scene/main/shader_globals_override.cpp). Đã thêm kiểm renderer pixel cho giá trị base thay đổi trong lúc override; kết quả thực ghi ở Handoff. Headless không chứng minh pixel: test ghi rõ SKIP phần này; lượt Forward+ riêng mới nghiệm thu restoration. Không thêm key/preset hoặc consumer production.

## Rà UID green_paint

Import nguồn hiện hành: `game/assets/textures/kit/green_paint.png.import`, UID `uid://ib3fwalyl3p2`. GLB `wall_straight`, `wall_door`, `desk_lamp` tham chiếu URI texture tương đối, không chứa UID Godot. Rà file text được track chưa thấy tham chiếu UID khác tới green_paint; chưa có bằng chứng cần đổi UID/texture/GLB production. Kiểm lại log import/full test/check trong lượt mới; nếu chỉ không tái hiện thì ghi như vậy, không coi đã sửa cache máy khác. Khi tái hiện, cần Astra chuyển dòng warning và resource path đầy đủ để B xác định nguồn.

Kết quả validation và các mục còn chờ xem Handoff T-209. Toàn gói T-209 chưa done; chưa tạo asset trả phí, chưa bot/FPS hoặc chuyển mặc định đồ họa.
