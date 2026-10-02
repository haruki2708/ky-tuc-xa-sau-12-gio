# T-134 — Thực thể truy đuổi và phát hiện ánh nhìn
- Lane: A (Gameplay) | Trạng thái: done | Agent:
- Nhánh: `lane-a/T-134-pursuer-gaze`
- Phụ thuộc: T-131 (âm thanh, done), T-132 (done). **Đọc `docs/design/RULES.md` mục 5b** (D-024) và `docs/SETTINGS.md` (`[accessibility] reduce_scares`). Làm song song với T-135 (lane B, hình bóng người và gương).
- Lane A được thêm thư mục `game/scenes/entity/` và `game/scripts/entity/` (xem `AGENTS.md` §3).

## Mục tiêu
Hai thành phần dùng lại được, integrator ghép vào đoạn 3 và đoạn 5 (T-136):
1. **Thực thể truy đuổi:** đi theo người chơi trong vùng tối, bắt được thì báo thua; người chơi tới **vùng an toàn** thì thoát.
2. **Bộ phát hiện ánh nhìn:** biết khi người chơi **nhìn vào** một điểm đủ lâu, dùng cho "quay lại nhìn tiếng dép sau lưng" (đoạn 3) và "nhìn vào gương" (đoạn 5).

Thực thể **không tự quyết khi nào xuất hiện**; luồng chơi (integrator) gọi bắt đầu và kết thúc.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`

## Yêu cầu
1. **`game/scenes/entity/pursuer.tscn` + `game/scripts/entity/pursuer.gd`** (`class_name Pursuer`, kế thừa `Node3D`):
   - `@export var body_scene: PackedScene`: hình bóng người (lane B làm ở T-135). Chưa có thì dùng capsule đen tạm.
   - `start_chase(target: Node3D, spawn: Vector3)`: hiện ra tại `spawn`, bắt đầu đuổi `target` (Player).
   - Di chuyển trên mặt phẳng XZ về phía mục tiêu, giữ trên sàn. Tầng 4 là hành lang thẳng và phòng; **không cần AI tìm đường phức tạp**, nhưng không được đi xuyên tường. Dùng `CharacterBody3D` hoặc kiểm tra va chạm. Nếu bị chắn thì đi men theo trục hành lang (X).
   - Tốc độ: `@export var speed: float = 2.9` (chậm hơn chạy 3,6, nhanh hơn đi bộ 2,2). Khi `reduce_scares` bật thì nhân 0,85.
   - **Bắt được:** khoảng cách ngang dưới `@export var catch_radius = 0.8` thì emit `caught`, dừng.
   - **Vùng an toàn:** node thuộc group `safe_zone` (Area3D). Mục tiêu đứng trong vùng an toàn thì thực thể dừng lại, lùi vào bóng tối, rồi emit `escaped` sau `@export var give_up_seconds = 2.0`. Integrator quyết định vùng nào là an toàn (đoạn hành lang còn đèn, phòng 407 đã chốt).
   - `stop_chase()`: biến mất ngay, dừng mọi âm thanh.
   - **Âm thanh** (T-131, bus `SFX`, không dùng `FootstepPlayer`):
     - bước `slipper_rush_01…04` theo nhịp di chuyển, không lặp lại liên tiếp;
     - `ambience/breath_close` lặp khi cách mục tiêu dưới 6 m, to dần khi lại gần;
     - khi `reduce_scares` bật, tiếng thở nhỏ hơn 6 dB.
   - Đọc `reduce_scares` từ `user://settings.cfg` bằng `ConfigFile` lúc `_ready()` và khi `settings_changed("accessibility", "reduce_scares")`; thiếu hoặc sai kiểu thì `false`.
   - Dừng hẳn khi cây scene tạm dừng (menu, sổ tay).
2. **`game/scripts/player/gaze_detector.gd`** (`class_name GazeDetector`, kế thừa `Node`):
   - `@export var camera: Camera3D`, `@export var target: Node3D`, `@export var max_angle_degrees = 35.0`, `@export var hold_seconds = 0.5`, `@export var require_line_of_sight = false`.
   - Emit `gazed` một lần khi hướng nhìn của camera nằm trong `max_angle_degrees` quanh hướng tới `target` liên tục đủ `hold_seconds`. `reset()` để dùng lại.
   - Dùng cho: tiếng dép sau lưng (target là nguồn âm phía sau, góc khoảng 50°, 0,3 giây) và gương (target `WashroomMirror`, góc khoảng 25°, 1 giây).
3. **Test `game/tests/player/`:**
   - Thực thể tiến lại gần mục tiêu đứng yên và emit `caught`; không đi xuyên một bức tường chắn giữa.
   - Mục tiêu chạy (3,6 m/s) ra xa thì khoảng cách tăng; đi bộ (2,2 m/s) thì bị bắt kịp.
   - Mục tiêu vào vùng `safe_zone` thì không bị bắt, có `escaped` sau `give_up_seconds`.
   - `reduce_scares` làm chậm thực thể; `stop_chase()` dừng âm thanh.
   - `GazeDetector` emit đúng một lần khi nhìn đủ lâu; quay đi trước khi đủ thời gian thì không emit; góc ngoài ngưỡng thì không emit.
   - Sao lưu và khôi phục `user://settings.cfg` như các test trước.
4. **Scene thử** `game/scenes/entity/pursuer_test.tscn`: hành lang thẳng, Player, một vùng an toàn có đèn ở cuối, phím `P` để thực thể xuất hiện sau lưng.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền: API, tham số, cách gắn; ghi rõ phần nào chưa thử bằng tay

## Handoff (agent điền)

### Phiên 2026-10-03 — Lane A
- Đã thêm `Pursuer` (`Node3D`) với scene `res://scenes/entity/pursuer.tscn`, `GazeDetector` (`Node`) tại `res://scripts/player/gaze_detector.gd`, hành lang thử `res://scenes/entity/pursuer_test.tscn` và 18 test mới (12 pursuer, 6 gaze), kèm UID.
- Thực thể dùng `CharacterBody3D` con, capsule cao 1,8 m / bán kính 0,3 m, gốc ở chân; gravity/floor snap giữ trên sàn. Body mask world = 1, layer = 0 để không chặn Player; root đi theo vị trí body. Khi đường trực tiếp bị chắn, giữ hướng men X đến khi đường tới mục tiêu thông. Tường cũng chặn kiểm tra bắt người, tránh bắt xuyên tường mỏng trong bán kính 0,8 m.
- Vùng an toàn được kiểm tra trước bắt người; khi đã vào vùng, thực thể chuyển sang pha rút lui, đi ngược hướng mục tiêu với nửa tốc độ hiệu dụng và vẫn chịu collision. Hết thời gian thì biến mất/phát `escaped` một lần. Không tự quay lại đuổi trong pha này; luồng game có thể gọi `start_chase()` cho một lượt mới. Không có navmesh/tìm đường tổng quát; ngõ cụt hoặc bố cục phức tạp có thể khiến thực thể đứng lại thay vì tìm vòng xa.
- Audio dùng trực tiếp T-131 trên bus `SFX`: bước theo mỗi 0,9 m di chuyển ngang thực tế trên sàn, không lặp clip liên tiếp; thở loop dưới 6 m, gain tăng từ gần −24 dB ở xa đến −6 dB ở sát mục tiêu, cộng attenuation 3D. `reduce_scares` nhân tốc độ 0,85 và trừ thêm 6 dB tiếng thở. Đọc bool từ ConfigFile lúc ready và signal đúng khóa; thiếu/sai kiểu thì false, không ghi file.
- Cả hai component dùng process mode PAUSABLE. Test xác nhận di chuyển, thời gian nhìn, thời gian rút lui và playback audio ngừng khi cây scene pause; resume tiếp tục. `stop_chase()`/free mục tiêu hủy kết quả chờ và dừng âm.
- Commit code `7afde33` — `T-134: Add collision-aware pursuer, safe escape and gaze detection`; đã push `origin/lane-a/T-134-pursuer-gaze` trước khi ghi Handoff.

### API và cách gắn cho T-136
| Thành phần | API / export | Cách dùng |
|---|---|---|
| `Pursuer` | `start_chase(target: Node3D, spawn: Vector3)` | Instance scene trước, gọi sau ready. Target thường là Player; spawn là vị trí chân trong tọa độ thế giới, trên vùng sàn đi được và ngoài tường. Mỗi lần gọi khởi tạo lượt mới. Ban đầu component ẩn và không đuổi. |
| `Pursuer` | `stop_chase()`; signal `caught`, `escaped` không tham số | Stop ẩn ngay, dừng cả hai AudioStreamPlayer3D và hủy pha rút lui. Kết quả cũng dừng/ẩn trước khi emit. Integrator tự xử lý lệch/checkpoint/cốt truyện; component không gọi RuleSystem hoặc GameState. |
| `Pursuer` | `body_scene: PackedScene`; `speed = 2.9`; `catch_radius = 0.8`; `give_up_seconds = 2.0` | Gán body_scene trước ready: model Node3D của T-135, gốc ở chân, mặt hướng local −Z, chỉ là hình ảnh. Model gắn dưới `Body/Visual`; bỏ trống dùng capsule đen. Tốc độ hiệu dụng khi giảm hù là 2,465 m/s. |
| Vùng an toàn | `Area3D`, group `safe_zone` | Có CollisionShape3D, `monitoring = true`, mask player = 2. Scene thử dùng layer = 8 (không sửa project.godot). Nên dùng layer khác 0 để query vị trí cũng nhận target Node3D thường và chuyển động mới trước khi danh sách overlap cập nhật. Integrator quyết định khi nào vùng có hiệu lực, ví dụ phòng 407 chỉ an toàn khi đã chốt. |
| `GazeDetector` | `camera: Camera3D`, `target: Node3D`, `max_angle_degrees = 35.0`, `hold_seconds = 0.5`, `require_line_of_sight = false` | Thêm Node gắn script, gán camera Player và điểm nhìn. Góc tính 3D theo hướng −Z của camera; nhìn lệch/mất tham chiếu/đổi mục tiêu xóa thời gian tích lũy. LOS tùy chọn kiểm tra body world layer 1, bỏ qua body tổ tiên camera và chấp nhận collider thuộc chính target. |
| `GazeDetector` | signal `gazed`; `reset()` | Emit một lần đến khi reset. Reset xóa thời gian và nạp lại một lượt quan sát; dùng `set_physics_process(false/true)` nếu luồng game cần bật/tắt theo đoạn. Tiếng dép sau lưng: 50° / 0,3 s; gương: 25° / 1 s. |

### Kiểm tra và giới hạn
- Nền `origin/main` đã kiểm tra: `a04a4ce`.
- `pwsh tools/test.ps1 -Filter gaze_detector`: **`RESULT: 6 passed, 0 failed`**, exit code 0.
- `pwsh tools/test.ps1 -Filter test_pursuer`: **`RESULT: 12 passed, 0 failed`**, exit code 0.
- `pwsh tools/test.ps1`: **`RESULT: 191 passed, 0 failed`**, exit code 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit code 0. `git diff --cached --check` sạch trước commit code.
- Lượt pursuer đầu `RESULT: 11 passed, 1 failed`: kiểm tra vật cản theo khoảng ngắn làm đổi hướng quá sớm khi đi vòng. Đã sửa giữ hướng X cho đến khi toàn bộ đường thẳng tới target thông, rồi chạy lại nhóm test và toàn bộ dự án PASS.
- Test dùng physics thật để kiểm tra đứng yên bị bắt, chạy thoát/đi bộ bị bắt, tường ngăn bắt và chuyển động, đi vòng vật cản, vào vùng an toàn trong lúc đuổi, ưu tiên vùng an toàn khi sát mục tiêu, rút lui/pause/hủy/restart, speed/âm theo settings, nhịp bước thực tế, stream SFX/không lặp/dừng, body_scene thay thế và phím P. Test settings sao lưu/khôi phục nguyên byte file nếu có, xóa fixture nếu ban đầu chưa có; khôi phục pause và mouse mode. Test gaze kiểm tra góc/thời gian/nhìn ngắt quãng/reset/LOS/target mất hoặc đổi/pause/preset đoạn 3 và 5.
- **Chưa thử bằng tay:** chưa F6 bằng chuột/phím thật, chưa nghe cân bằng âm thực tế, chưa chụp hình hoặc ghép model T-135; chưa kiểm tra đường đi trong tầng 4 sau khi T-136 bố trí spawn/safe zone. Các test dùng capsule tạm và collider thử, không khẳng định mọi bố cục phòng đều có đường đi.
- Cách thử: mở `pursuer_test.tscn`, F6; P xuất hiện capsule sau lưng 5 m. WASD/Shift để đi/chạy theo hành lang tới vùng sàn xanh có đèn ở đầu +X. Esc mở menu; đổi Giảm hù dọa để so sánh. P bắt đầu lại một lượt; fixture không tự cộng lệch hoặc tải checkpoint khi caught.

### Yêu cầu thay đổi / chặn
- T-136/integrator instance Pursuer, nối `caught`/`escaped`, chọn spawn/vùng an toàn theo tình huống và gắn GazeDetector cho nguồn tiếng dép/gương; gán body_scene T-135 khi có. Không cần thêm input action, signal EventBus, settings key hay sửa audio. Phím P chỉ là shortcut của scene thử.
- Không còn blocker code/test/push hoặc code dở của T-134. Việc ghép vào tầng 4 và kiểm duyệt cảm giác thực tế thuộc T-135/T-136. Không tự quyết thời điểm xuất hiện, hậu quả, luật hoặc cốt truyện.
- Mạng sandbox bị chặn và sau đó Windows báo lỗi tạo tiến trình 1326; đã chạy lệnh cần thiết ngoài sandbox qua cơ chế cấp quyền. Không cài công cụ/plugin, không làm việc trong bản tích hợp.

### Review (integrator, 2026-10-03)
- Đạt. Merge `c988ac2`. Code gọn, pause đúng, `reduce_scares` đúng D-024, 18 test mới.
- Tích hợp ở T-136: `StoryDirector` tạo Pursuer (gắn silhouette T-135), hai vùng an toàn (hành lang còn đèn x < 26; phòng 407 khi đã chốt), GazeDetector cho tiếng dép (50°/0,3 s) và gương (25°/1 s).
- Giới hạn đã biết: thực thể không tìm đường qua cửa, nên truy đuổi 2 xuất phát từ cửa nhà vệ sinh phía hành lang. Âm lượng `slipper_rush` và tiếng thở cần chủ dự án nghe thử.
