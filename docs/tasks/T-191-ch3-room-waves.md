# T-191 — Chương 3: xác ra từ phòng theo bước chân người chơi (core)
- Lane: core (Claude) | Trạng thái: todo (chờ T-190) | Agent: Claude
- Phụ thuộc: T-190 (lane B), D-061.

## Việc
- Bỏ đánh thức hàng loạt xác giữa hành lang tầng 4 khi ra khỏi 407 (`_wake_near(20)` + `_spawn(&"B4", 6)` trong `chapter3_director.gd`). Ra khỏi 407: chỉ đám `ZombieIdle/B4` ở đầu cầu thang chính quay đầu (jumpscare `corridor_turn`).
- Gắn `ZombieDoor` (lane A) cho mọi cửa trong group `room_doors`. Đặt 1–2 xác vào `Anchors/RoomSpawns/<tầng>/R<phòng>` khi người chơi tới gần cửa phòng đó (cùng tầng, khoảng 8 m), xác đập cửa khoảng 2,5 giây (`door_bash_seconds`, có tiếng `play_door_hit`) rồi ra hành lang.
- Tầng 4: phòng 408 chỉ bật sau khi lấy chìa. Tầng 3: các phòng gần cầu thang thoát hiểm. Tầng 2: các phòng dọc đường từ cầu thang thoát hiểm tới cầu thang chính, giữ đám xác ở cửa 203.
- Giữ giới hạn 40 xác hoạt động; nạp checkpoint `ch3_b` thì cửa đóng lại, xác trong phòng xóa.
- Test: không còn xác thức giữa hành lang tầng 4 lúc ra khỏi 407; tới gần cửa thì xác ra sau khoảng 2–3 giây; 408 im tới khi có chìa; khu B vẫn đi trọn tới vườn hoa.
- Cập nhật `docs/playtest/CH3_QUICKTEST.md`, `CH3_WALKTHROUGH.md`; export bản mới.

## Handoff
