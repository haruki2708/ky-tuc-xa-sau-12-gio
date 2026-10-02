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
- [x] `pwsh tools/test.ps1` PASS, bao gồm các test mới
- [ ] Mở `player_test.tscn` trong editor, F6 chơi được: đi, chạy, nhìn, bật/tắt đèn bằng E
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Cách kiểm tra
```
pwsh tools/test.ps1 -Filter player
```
Chụp khung hình kiểm tra: xem lệnh trong `AGENTS.md` §4, dùng scene `res://scenes/player/player_test.tscn`.

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane A
- Đã làm: thêm `player.tscn` với capsule 1,75 m / bán kính 0,3 m, layer 2 / mask 1, Head 1,6 m, Camera FOV 70 và ray 2 m (mask 1 + 3, area + body).
- Controller có đi bộ 2,2 m/s, chạy 3,6 m/s, tăng/giảm tốc, trọng lực, mouse-look giới hạn ±85°, Esc bắt/thả chuột và head-bob tắt được. Chỉ dùng action có sẵn.
- Focus theo danh tính đồ vật và prompt; không phát lặp mỗi frame. Xử lý đồ vật disabled, bị xóa, ngoài tầm và bị tường che. Action `interact` gọi `interact(self)` một lần mỗi lần bấm; E/chuột trái dùng mapping có sẵn trong GameInput.
- `footstep(surface: StringName)` phát theo mỗi 0,7 m dịch chuyển ngang thực tế trên sàn; ray dưới chân đọc metadata `surface`, mặc định `concrete`. Không phát khi đứng yên, bay hoặc giữ nút đi vào tường. Lane E có thể nối trực tiếp signal này.
- Scene thử có sàn, tường, hộp xanh bật/tắt đèn, hộp đỏ disabled và Label hiện nguyên `prompt_key` để debug. Dùng key sẵn có `PROMPT_INTERACT`, không thêm chữ HUD hoặc key dịch.
- Quyết định kỹ thuật: origin Player ở chân; bob dịch camera, giữ collider và Head ổn định. Controller lưu trạng thái bắt chuột được yêu cầu vì display server headless không thực hiện OS mouse capture. Test headless xác minh trạng thái này và góc nhìn; không thay thế kiểm tra chuột thật.
- Đã thêm 14 test gameplay, commit cả các `.uid` do Godot sinh. Commit code: `903ff79` — `T-101: Add first-person movement, interaction and footstep tests`; đã push lên `origin/lane-a/T-101-player-controller` trước khi cập nhật Handoff.

### Kiểm tra và phần còn lại
- Đã chạy `pwsh tools/test.ps1` bằng Godot `4.7.2.stable.official.ed1daf0bf`: **`RESULT: 19 passed, 0 failed`**, exit code 0 (5 test nền + 14 test gameplay).
- Lượt đầu `RESULT: 18 passed, 1 failed` do test đòi OS mouse capture trong headless. Đã sửa quản lý trạng thái bắt chuột và test tương ứng, chạy lại toàn bộ đạt kết quả phía trên.
- Test mới bao phủ cấu hình scene, rơi/đứng, hướng đi/tốc độ/đường chéo/tăng giảm tốc, focus/disabled/xóa/đổi target/tầm ray, tường chắn, interact một lần mỗi lần bấm, khoảng cách và bề mặt bước chân, airborne, head-bob, logic mouse-look/Esc, Label và bật/tắt đèn trong scene thử.
- `git diff --cached --check` đã sạch trước commit code. Chỉ thay đổi bốn thư mục được phép cùng checklist/Handoff của card này.
- **Chưa kiểm tra thủ công bằng editor/F6**, chưa xác nhận cảm giác đi/chạy/nhìn, bắt/thả chuột hệ điều hành hay bấm E/chuột trái bằng thiết bị thật; checklist này giữ nguyên chưa đạt. Phiên này kiểm tra gameplay tự động trong headless. Chưa chụp ảnh kiểm tra hình ảnh.
- Cách kiểm tra tiếp: mở `game/project.godot`, mở `res://scenes/player/player_test.tscn`, F6; WASD đi, Shift chạy, chuột nhìn, Esc bắt/thả chuột. Nhìn hộp xanh rồi bấm E hoặc chuột trái để bật/tắt đèn; hộp đỏ không có focus và không tương tác. Bỏ chọn `head_bob_enabled` trên Player để thử tắt bob. Chạy riêng test bằng `pwsh tools/test.ps1 -Filter player`.
- Không còn phần code/test tự động bị chặn. Sandbox Windows gặp lỗi tạo tiến trình 1326; đã chạy lệnh ngoài sandbox bằng cơ chế cấp quyền. Không cài phần mềm hay thêm plugin.

### Yêu cầu thay đổi
- Integrator: khi tích hợp gameplay vào hành lang chính, instance `res://scenes/player/player.tscn` trong `game/scenes/main/main.tscn`, đặt vị trí spawn trên sàn và thay camera tĩnh hiện tại. Lane A không sửa scene main vì ngoài phạm vi; scene thử độc lập đã dùng Player mới.
- Không yêu cầu thêm input action, autoload, signal EventBus hoặc thay đổi luật chơi/cốt truyện. Không có câu hỏi thiết kế còn treo.
