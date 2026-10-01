# T-101 — Điều khiển người chơi góc nhìn thứ nhất và tương tác
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-101-player-controller`
- Phụ thuộc: P0 (xong). Dùng `EventBus` và `Interactable` có sẵn ở `game/scripts/core/`.
- Loại: task thử tuần đầu

## Mục tiêu
Người chơi đi lại và nhìn quanh mượt trong hành lang. Nhìn vào đồ vật tương tác được thì phát tín hiệu "đang nhắm". Bấm E hoặc chuột trái thì dùng đồ vật đó.

## Được phép sửa
`game/scenes/player/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`

## Yêu cầu
1. **Scene `game/scenes/player/player.tscn`**, root là `CharacterBody3D` tên `Player`:
   - Collision layer 2, mask 1.
   - Capsule cao 1,75 m, bán kính 0,3 m.
   - Node `Head` ở độ cao 1,6 m, bên trong có `Camera3D` (FOV 70).
   - `RayCast3D` tên `InteractRay`, dài 2,0 m, mask world (1) và interactable (3), va chạm với cả area và body. Có body vì không được tương tác xuyên tường.
2. **Script `game/scripts/player/player.gd`:**
   - Đi bộ 2,2 m/s, chạy (`sprint`) 3,6 m/s, có tăng tốc và giảm tốc mượt. Có trọng lực.
   - Nhìn bằng chuột: độ nhạy là `@export`, góc ngẩng/cúi giới hạn ±85°.
   - Bắt chuột khi bắt đầu chơi. Phím `pause` (Esc) chuyển qua lại giữa bắt và thả chuột. Menu pause thật sẽ làm sau ở lane D.
   - Head-bob nhẹ, tắt được bằng `@export var head_bob_enabled`. Yêu cầu này để hỗ trợ người dễ say 3D.
   - Dùng các input action có sẵn trong `GameInput`. Không thêm action mới.
3. **Tương tác:**
   - Mỗi physics frame kiểm tra collider của ray.
   - Nếu collider là `Interactable` và `enabled`, đó là đồ vật đang được nhắm.
   - Khi đồ vật đang nhắm **thay đổi**, emit `EventBus.interaction_focus_changed(prompt_key)`. Không nhắm gì thì emit chuỗi rỗng. Chỉ emit khi có thay đổi, không emit mỗi frame.
   - Bấm `interact` thì gọi `target.interact(self)`.
4. **Tiếng bước chân:**
   - Thêm `signal footstep(surface: StringName)` vào player, phát sau mỗi khoảng 0,7 m đi trên mặt đất.
   - `surface` lấy từ metadata `"surface"` của collider dưới chân. Không có metadata thì dùng `&"concrete"`.
   - Lane E sẽ nối tín hiệu này với âm thanh.
5. **Scene thử `game/scenes/player/player_test.tscn`:**
   - Sàn, tường, Player.
   - Hai hộp `Interactable` mẫu (script trong `game/scripts/interaction/`): một hộp bật/tắt một đèn, một hộp có `enabled = false`.
   - Một `Label` debug hiện `prompt_key` đang nhắm. Label này chỉ để thử; HUD thật thuộc lane D.
6. **Test `game/tests/player/test_player.gd`** (kế thừa `TestCase`):
   - Player rơi xuống và đứng trên sàn sau vài frame.
   - Dùng `Input.action_press("move_forward")` thì player di chuyển về hướng −Z.
   - Đặt một `Interactable` trước mặt thì emit focus đúng `prompt_key`. Quay đi hoặc bỏ đồ vật thì emit chuỗi rỗng.
   - Tường chắn giữa player và đồ vật thì không có focus.
   - `interact` gọi được `interact()` của đồ vật đang nhắm.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` PASS, bao gồm các test mới
- [ ] Mở `player_test.tscn` trong editor, F6 chơi được: đi, chạy, nhìn, bật/tắt đèn bằng E
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Cách kiểm tra
```
pwsh tools/test.ps1 -Filter player
```
Chụp khung hình kiểm tra: xem lệnh trong `AGENTS.md` §4, dùng scene `res://scenes/player/player_test.tscn`.

## Handoff (agent điền)
