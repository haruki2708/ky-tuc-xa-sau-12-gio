# T-134 — Thực thể truy đuổi và phát hiện ánh nhìn
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền: API, tham số, cách gắn; ghi rõ phần nào chưa thử bằng tay

## Handoff (agent điền)
