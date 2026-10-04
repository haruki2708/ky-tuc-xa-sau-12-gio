# T-152 — Quản lý ký túc xá và xác bạn cùng phòng đổi tư thế khi không bị nhìn
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-152-manager-corpses`
- Phụ thuộc: T-151 (làm ngay sau; được tạo nhánh từ nhánh T-151 nếu T-151 chưa merge, ghi rõ trong Handoff). Đọc `docs/design/STORY.md` v2 §5 (vòng 2), §9.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
1. **Quản lý:** thực thể chính của chương 1. Ông ta đi từng phòng, hỏi số giường, chém. Cảnh ở phòng 407 là cao trào của chương: người chơi nằm trên giường của bạn đã chết, nín thở; quản lý hỏi giường số 3 rồi chém nát giường trống của Trung.
2. **Xác bạn cùng phòng:** nằm chết trên giường; mỗi khi người chơi không nhìn thì đổi tư thế một chút (đầu quay về phía người chơi…). Đây là cảm giác "luôn bị theo dõi" trong phòng kín.

## Được phép sửa
`game/scenes/entity/`, `game/scripts/entity/`, `game/tests/player/` (hoặc thêm `game/tests/entity/`), thêm key vào `strings.csv`.

## Yêu cầu
1. **Quản lý** (`manager.gd`, `manager.tscn`). Cảnh do integrator dàn dựng bằng các API dưới đây; quản lý **không** tự quyết luật chơi.
   - **Di chuyển:**
     - `walk_to(position)` (NavigationAgent3D nếu có navmesh, không thì đi thẳng theo `route` như `pursuer.gd`);
     - `open_door(door)` (gọi `set_open(true)` của cửa nếu có), `enter_room(points)`, `stand_at(marker)`.
     - Tốc độ đi 0,9 m/s, nặng nề. Signal `arrived`.
   - **Hỏi:**
     - `ask(line_key: String)`: quay mặt về giường, phát giọng (qua `manager_audio.tscn` của lane E nếu có, không thì phụ đề `EventBus.subtitle_requested`);
     - sau đó chờ `listen_seconds` (export, mặc định 6 giây) rồi phát signal `answered(heard: bool)`.
     - `heard = true` nếu trong lúc chờ có `noise_emitted` nằm trong 4 m, hoặc người chơi chọn trả lời trong nhóm chat (integrator gọi `hear()`).
   - **Chém:**
     - `slash(target: Node3D)`: animation chém nhiều nhát vào một giường, phát signal `slashed(target)` ở mỗi nhát để lane B đổi giường sang trạng thái nát và lane E phát âm.
     - `kill_player()`: lao tới người chơi, animation kết liễu, phát `EventBus.player_caught(&"manager")`. Màn chết do integrator làm.
   - **Kéo dao:** lúc đi, dao kéo lê trên sàn. Gọi `manager_audio` (`play_drag(on)`, `play_step()`) nếu có.
   - **"Giảm hù dọa":** `kill_player()` chỉ lao tới rồi màn hình tối, không có cảnh chém cận mặt.
   - **Model:** `body_scene` (lane B làm ở T-154); chưa có thì capsule cao 2 m, kèm một thanh dài làm dao.
2. **Xác đổi tư thế khi không bị nhìn** (`unseen_poser.gd`, component dùng chung):
   - Gắn vào một node có `AnimationPlayer` hoặc danh sách tư thế (tên animation hoặc node con).
   - **Bị nhìn:** trong frustum camera, tia không bị chặn, cách dưới 15 m.
   - Không bị nhìn quá `min_unseen_seconds` (mặc định 4 giây) thì có xác suất `chance` (mặc định 0,35) chuyển sang tư thế kế tiếp trong `poses`. Không bao giờ đổi khi đang bị nhìn.
   - `enabled` bật/tắt được. Signal `pose_changed(name)` để lane E phát tiếng sột soạt rất nhỏ.
   - Dùng lại logic "bị nhìn" cho chương sau. Làm gọn trong một hàm tĩnh hoặc helper `is_seen_by(camera, node, max_distance)`.
3. **Scene thử** `manager_test.tscn`: phòng có 4 giường (`bunk_spot` của T-151), một cửa; phím chạy cảnh mẫu:
   - đi tới cửa, vào phòng;
   - hỏi giường 3, chờ;
   - nếu nghe tiếng động thì `kill_player()`, không thì `slash()` giường 3;
   - rời phòng.

   Có 3 xác dùng `unseen_poser` để thử.
4. **Test:**
   - `answered(heard)` đúng theo tiếng động trong 4 m và theo `hear()`;
   - `slashed` phát đủ số nhát;
   - `kill_player()` phát `player_caught(&"manager")`;
   - `unseen_poser` không đổi khi bị nhìn, đổi khi không bị nhìn đủ lâu (dùng seed RNG cố định);
   - test cũ của `pursuer` vẫn PASS.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: API, cách dàn cảnh mẫu, phần chưa thử, yêu cầu cho lane B/E/integrator

## Handoff (agent điền)
