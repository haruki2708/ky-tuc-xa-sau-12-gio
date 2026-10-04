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
- [x] Handoff: API, cách dàn cảnh mẫu, phần chưa thử, yêu cầu cho lane B/E/integrator

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Scene đúng đường dẫn `res://scenes/entity/manager.tscn`.
- Ngoài `slashed(target)` mỗi nhát, phát thêm signal **`slash_finished`** khi chém xong cả loạt; `walk_to()` kết thúc bằng signal `arrived`. Luồng chương chờ hai signal này (tối đa 8 giây).

## Handoff (agent điền)

### Kết quả ngày 2026-10-04 — Lane A

**Blocked: chưa đạt điều kiện toàn bộ test PASS.** Actor và scene thử đã làm xong trong phạm vi, nhưng test core `test_chapter1.gd::test_manager_hears_a_breath` không tương thích với actor thật. Cần integrator xử lý fixture/luồng nghe trước khi duyệt hoàn thành; không sửa core hay giảm yêu cầu gameplay để làm xanh test.

- Nhánh tạo từ `origin/main` tại `d000c8f` (đã có T-151), không dựa trên nhánh T-151 chưa merge.
- Commit code `c173212` đã push lên `lane-a/T-152-manager-corpses` trước khi điền Handoff này. Không sửa STATUS, core, player, audio, level hay project settings.
- Thêm manager có va chạm, navmesh/route, hỏi–nghe, chém nhiều nhát, lao/kết liễu và cập nhật giảm hù dọa trực tiếp. Có model capsule/dao dự phòng, ghép rig âm thanh hiện hữu và model T-154 qua export.
- Thêm `EntityVisibility.is_seen_by()` dùng chung, `UnseenPoser`, scene thử bốn giường/ba xác, ba key vi/en, 18 test mới. Pursuer không thay đổi.

### API và điểm nối

- `res://scenes/entity/manager.tscn`, script `DormManager`: gán `player`, `look_target` (giường đang hỏi), `body_scene` và tùy chọn `audio_rig` trước khi thêm vào cây. Nếu thiếu player, `kill_player()` tìm CharacterBody3D cha của camera hiện hành. Không có look_target thì giữ hướng hiện tại.
- `walk_to(position, via = PackedVector3Array())`: đi qua `via`, hoặc export `route`, rồi tới đích. `enter_room(points)` dùng các điểm thế giới theo thứ tự; `stand_at(marker)` đi tới và quay theo hướng -Z của marker; `open_door(door)` gọi `set_open(true)`. Tốc độ mặc định 0,9 m/s. `arrived` chỉ phát sau khi thực sự tới hết tuyến. Có navmesh thì dùng NavigationAgent3D; không có thì đường nối các waypoint phải thông thoáng. Tuyến bị chắn không báo tới đích giả.
- `ask(line_key)` dừng lệnh trước, quay về look_target, gọi `ManagerAudio.say()`/phụ đề dự phòng. Chờ hết thời lượng lời rồi mới nghe trong `listen_seconds = 6`; kết thúc phát `answered(heard)` một lần. Tiếng động được đo trong 4 m từ đầu actor (gốc + 1,6 m), không phụ thuộc radius do nguồn phát khai báo. `hear()` chỉ nhận trong lúc nghe, kể cả trả lời chat phải do integrator gọi đúng cửa sổ này. Pause không tích thời gian hay nhận hear/noise.
- `slash(target)` mặc định sáu nhát, cách nhau 0,45 s; mỗi nhát phát `slashed(target)`, hết loạt phát `slash_finished`. Actor gọi `play_slash()` trên rig hiện hữu; khi nối slashed cho lane B đổi giường, tránh nối thêm âm thanh gây phát đôi. `stop()` hoặc lệnh mới hủy kết quả đang chờ; target bị giải phóng thì hủy loạt.
- `kill_player()` là lệnh thi hành kết quả do đạo diễn quyết định: lao có va chạm trong tối đa 0,65 s, diễn kết liễu rồi phát `EventBus.player_caught(&"manager")` một lần. Đây không phải AI tự truy đuổi/ra luật; đạo diễn cần dàn khoảng cách trước khi gọi. Giảm hù dọa bỏ chém cận mặt. Core/UI sở hữu màn đen/chết; Ch1PlayerAudio đã xử lý âm thanh kill theo player_caught nên actor không phát thêm lần nữa.
- Âm thanh: ưu tiên rig được gán, rồi group `manager_audio`, sau cùng tự instance rig hiện hữu nếu có. Bước chân/kéo dao theo quãng đường thực đi trên sàn; riêng Drag theo BladeTip. `stop()` dừng nguồn âm nhưng không gọi `stop_emitting()` vốn khóa vĩnh viễn rig dùng chung.
- Model: root Node3D ở chân, hướng -Z; AnimationPlayer đầu tiên trong model với tên `walk`, `stand`, `ask`, `slash`, `lunge`, `kill`; Marker3D tên `BladeTip`. Thiếu animation không làm lỗi actor. Chưa ghép model cuối của T-154.
- `UnseenPoser`: gán subject/camera/animation_player hoặc để tự tìm parent/camera hiện hành/AnimationPlayer đầu tiên; `poses` mặc định `dead_a`, `dead_b`, `head_turn`, `eyes_open`. Có thể dùng tên animation hoặc đường dẫn node con; animation được lấy tư thế cuối rồi dừng, không chạy tiếp khi người chơi nhìn lại. `enabled` tắt và reset đếm; `rng_seed` khác 0 cho kết quả lặp lại.
- Sau mỗi khoảng liên tục không bị nhìn đủ `min_unseen_seconds = 4`, tung một lần với `chance = 0.35`; thành công chuyển tư thế kế tiếp và phát `pose_changed(name)`. Nhìn lại reset đếm. Helper kiểm tra khoảng cách <15 m, frustum và ray mask world tới gốc/tâm/các góc mesh; bỏ collider của người cầm camera. Đây là kiểm tra điểm mẫu bảo thủ để giữ nguyên khi thấy một phần mesh, không phải kiểm tra từng pixel.

### Cách thử và kết quả thực tế

- Mở `res://scenes/entity/manager_test.tscn`, F6, nhấn P: đến cửa → mở/vào → hỏi giường 3 → nghe → chém giường trống nếu yên lặng, hoặc lao/kết liễu nếu nghe → rời và đóng cửa. E dùng BunkSpot; Space giữ hơi khi đã nằm. Có ba xác placeholder với CorpseAudio nối pose_changed. Hai nhánh mẫu đã chạy bằng test tự động.
- `pwsh tools/test.ps1 -Filter test_manager`: `RESULT: 12 passed, 0 failed`.
- `pwsh tools/test.ps1 -Filter test_unseen_poser`: `RESULT: 6 passed, 0 failed`.
- `pwsh tools/test.ps1 -Filter test_pursuer`: `RESULT: 16 passed, 0 failed`.
- **Toàn bộ** `pwsh tools/test.ps1`: `RESULT: 341 passed, 1 failed`; launcher tiếp tục báo `RESULT: test FAIL (engine error or missing successful runner result)`, exit 1. Đây là lỗi assertion core nêu dưới, không phải toàn bộ test PASS. Cả 18 test mới và 16 test pursuer đều PASS trong lần chạy toàn bộ này.
- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`, exit 0.
- `pwsh tools/capture.ps1 -Scene res://scenes/entity/manager_test.tscn -Frames 2 -KeepEvery 1 -Out build/captures/T-152-manager`: `RESULT: capture PASS (2 gameplay frames)`. Đã xem ảnh đầu cảnh: bốn giường/ba xác placeholder. Chưa xác minh hình ảnh toàn bộ hoạt cảnh bằng chơi tay.
- Các lệnh Godot thành công/đếm test ở trên chạy ngoài sandbox sau khi lần chạy pursuer trong sandbox gặp lỗi đọc root certificate store. Không cài công cụ/phần mềm mới.
- Chưa chơi F6 bằng chuột/phím, chưa nghe âm thanh bằng tai, chưa duyệt chém cận mặt/giảm hù dọa bằng hình ảnh, chưa chạy tay cả chương với model T-154. Các giới hạn này không được coi là đã kiểm thử.

### Yêu cầu thay đổi ngoài phạm vi

1. **Integrator — blocker test:** `game/tests/core/test_chapter1.gd::test_manager_hears_a_breath` chờ `_manager_listening` rồi lập tức phát tiếng thở tại `(33.35, 1.2, -3.0)` radius 1,5. `chapter1_director.gd::_manager_at_407` bật cờ ngay sau spawn tại `DOOR_SPOT = (32, 0.05, 0.6)`, trước lệnh đi vào. Vì vậy khoảng cách tới tai actor thật khoảng 3,87 m, vượt bán kính 1,5 của core. Khi chưa có scene manager, core dùng `MANAGER_SPOT` giả định gần giường nên fixture cũ đạt. Lỗi: expected `[&"ch1_r2_manager"]`, got `[]`. Cần fixture chờ actor tới vị trí/cửa sổ nghe thực rồi phát noise; đồng thời đồng bộ thời gian actor với fixture `director.time_scale = 0.002` hoặc inject actor stub trong test core. Hiện timeout chờ di chuyển cũng bị nhân time_scale nên có thể hết trước khi actor tới nơi.
2. **Integrator — câu hỏi hợp đồng nghe:** card T-152 yêu cầu 4 m chỉ sau khi nói; core `_on_noise` dùng `max(radius, 1.0)` và bật nghe suốt lúc vào phòng/chém. Test im lặng trên giường Việt cũng kỳ vọng noise radius 1,5 không được nghe. Xin xác nhận/chốt cùng chủ dự án và thống nhất core/test với card; Lane A giữ đúng API 4 m của card, không tự đổi luật. Nối `answered(heard)` và `hear()` cho câu trả lời chat; tránh hai bộ đếm/cửa sổ nghe khác nhau.
3. **Integrator — dàn cảnh thật:** gán player/look_target giường và model body_scene; nối `slashed` với `Room407.set_slashed(progress)` để nát dần mỗi nhát (core hiện chỉ đặt 1,0 khi cả loạt xong). Luồng chết muốn thấy lao/kết liễu cần gọi `kill_player()` theo kết quả đạo diễn rồi xử lý player_caught/màn đen. Kiểm tra tuyến 0,9 m/s phù hợp timeout 8 s; không coi các test tăng tốc của core là chứng cứ hoạt cảnh thời gian thực đã đúng.
4. **Lane B/E:** gắn model T-154 và các pose theo hợp đồng trên; gắn UnseenPoser lên ba xác trong phòng thật, nối CorpseAudio.poser trước ready. Actor đã gọi rig bước/kéo/chém và rig say phát phụ đề, tránh phát trùng ở signal slashed/player_caught. Chưa cần thêm asset/plugin/settings/signal EventBus.

Giữ checklist test ở trạng thái chưa đạt cho đến khi integrator xử lý blocker và chạy lại toàn bộ suite. Nhánh đã có code/test để review, chưa sẵn sàng xác nhận hoàn thành T-152.
