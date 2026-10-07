# T-191 — Chương 3: xác ra từ phòng theo bước chân người chơi (core)
- Lane: core (Claude, làm bằng Sonnet 5.5) | Trạng thái: done | Agent: Claude
- Phụ thuộc: T-190 (lane B), D-061.

## Việc
- Bỏ đánh thức hàng loạt xác giữa hành lang tầng 4 khi ra khỏi 407 (`_wake_near(20)` + `_spawn(&"B4", 6)` trong `chapter3_director.gd`). Ra khỏi 407: chỉ đám `ZombieIdle/B4` ở đầu cầu thang chính quay đầu (jumpscare `corridor_turn`).
- Gắn `ZombieDoor` (lane A) cho mọi cửa trong group `room_doors`. Đặt 1–2 xác vào `Anchors/RoomSpawns/<tầng>/R<phòng>` khi người chơi tới gần cửa phòng đó (cùng tầng, khoảng 8 m), xác đập cửa khoảng 2,5 giây (`door_bash_seconds`, có tiếng `play_door_hit`) rồi ra hành lang.
- Tầng 4: phòng 408 chỉ bật sau khi lấy chìa. Tầng 3: các phòng gần cầu thang thoát hiểm. Tầng 2: các phòng dọc đường từ cầu thang thoát hiểm tới cầu thang chính, giữ đám xác ở cửa 203.
- Giữ giới hạn 40 xác hoạt động; nạp checkpoint `ch3_b` thì cửa đóng lại, xác trong phòng xóa.
- Test: không còn xác thức giữa hành lang tầng 4 lúc ra khỏi 407; tới gần cửa thì xác ra sau khoảng 2–3 giây; 408 im tới khi có chìa; khu B vẫn đi trọn tới vườn hoa.
- Cập nhật `docs/playtest/CH3_QUICKTEST.md`, `CH3_WALKTHROUGH.md`; export bản mới.

## Handoff
### 2026-10-07 — Claude (Sonnet 5.5)
- **Đã làm** (`chapter3_director.gd`):
  - ra khỏi 407 **không còn** đánh thức hàng loạt xác giữa hành lang tầng 4: chỉ đám đứng sẵn ở đầu cầu thang chính quay mặt về phía Trung (`_face_idle_crowd`, jumpscare `corridor_turn`), cách 407 khoảng 30 m;
  - `_room_wave_loop` (chạy từ lúc ra khỏi 407 tới khi sang khu vườn hoa): Trung tới gần một cửa phòng trong **10 m** (cùng tầng) thì `_open_room`: đặt xác trong phòng (`RoomSpawns/<tầng>/R<phòng>`, xác thứ hai lệch 0,6 m), gắn `ZombieDoor` (lane A) cho cửa, xác **đập cửa 2,5 giây** rồi cửa bật mở; tiếng đập (`ZombieAudio.play_door_hit`, mỗi 0,7 giây) do core gọi vì lane A và lane E chưa nối;
  - kế hoạch xác (`ROOM_PLAN`): tầng 4: 406 ×2, 405 ×2, 404, 403, 402, 401; tầng 3: 308 ×2, 307, 306; **tầng 2 chỉ còn đám 4 xác ở cửa 203** (theo D-062, thu hẹp D-061); **408 bật sau khi lấy chìa** (chờ 1,5 giây, đập **3,5 giây**), 2 xác;
  - trong lúc cửa còn đóng, xác nhắm vào điểm thẳng ngoài cửa (nhắm chéo thì nó trượt dọc cánh cửa mà không bao giờ đập); khi cửa bật, xác biết Trung ở đâu **6 giây** rồi chỉ còn dựa vào mắt và tai;
  - bỏ đợt 6 xác tầng 4, 4 xác tầng 3 từ hàng xác (`ZombieSpawns/B4`, `B3`) và đám đứng sẵn tầng 3; giữ đợt 4 xác tầng 1 và đám đứng sẵn tầng 1. Xóa `_wake_near` (không còn ai dùng).
- **Nạp lại checkpoint** nạp lại cả cảnh nên cửa đóng, xác trong phòng mất (không cần code thêm).
- **Test mới** (3): ra khỏi 407 chỉ có đám ở đầu cầu thang, xác vào phòng gần đập cửa rồi mới ra hành lang, phòng xa im; 408 im tới khi lấy chìa rồi mở với 2 xác; tầng 3 chỉ mở phòng gần cầu thang thoát hiểm. Chạy mô phỏng đi bộ 407 → chìa → cửa thoát hiểm: không bị tóm; 406 và 405 bật khi Trung đã cách 12–16 m, 408 bật mở lúc Trung đã tới cửa thoát hiểm.
- **Con số khởi đầu, chỉnh sau chơi thử:** bán kính 10 m, 2,5 giây (3,5 giây cho 408), số xác mỗi phòng.
- **Chưa kiểm:** chơi tay. Chưa chạy bot.
