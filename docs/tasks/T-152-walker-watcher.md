# T-152 — Hai thực thể: Người đi dép (lang thang) và Người thứ năm (chỉ đi khi không bị nhìn)
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-152-walker-watcher`
- Phụ thuộc: T-151 (làm ngay sau, có thể tạo nhánh từ nhánh T-151 nếu T-151 chưa merge; ghi rõ trong Handoff). Đọc kỹ `docs/design/STORY.md` §5.1, §5.2, §5.4.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Hai thực thể chính của game, làm đúng các con số trong `STORY.md` §5. Chương 1 chỉ dùng chúng theo kịch bản (integrator gọi API), nhưng code phải chạy được kiểu đi tuần tự do để dùng cho đêm 2 trở đi.

## Được phép sửa
`game/scenes/entity/`, `game/scripts/entity/`, `game/tests/player/` (thêm thư mục `game/tests/entity/` nếu cần), thêm key vào `strings.csv`.

## Yêu cầu
1. **Người đi dép** (`walker.gd`, `walker.tscn`):
   - **Trạng thái:** `idle`, `patrol`, `listen`, `search`, `chase`, `lost`. Đổi trạng thái thì phát `EventBus.entity_state_changed(&"walker", state)`.
   - **Tốc độ:** đi tuần 1,2 m/s; tìm và mất dấu 1,8 m/s; đuổi 2,9 m/s.
   - **Di chuyển** bằng `NavigationAgent3D` trên navmesh của lane B (T-153). Có thể đi qua cầu thang giữa các tầng.
   - **Đi tuần:**
     - `start_patrol(points: Array[Node3D])`: đi vòng qua các điểm.
     - Điểm có metadata `action = &"count"` thì dừng khoảng 3 giây, giơ tay đếm (gọi animation `count` nếu model có), rồi phát signal `counted(room_area)`. Integrator dùng signal này để xử lý việc người chơi nấp trong mùng bị đếm.
   - **Nghe:**
     - nhận `noise_emitted` có khoảng cách ≤ bán kính tiếng động;
     - đang đi tuần thì chuyển sang `listen` (đứng 3–5 giây, quay đầu về phía tiếng), rồi `search` tới chỗ phát ra tiếng;
     - tiếng ở tầng khác vẫn kéo nó tới đó.
   - **Nhìn:**
     - hình nón 70°, tia nhìn không bị chặn;
     - tầm 10 m trong chỗ sáng, 3 m trong chỗ tối; người chơi bật đèn pin thì 15 m;
     - "Sáng hay tối" lấy từ Area3D trong group `lit_area` của lane B. Không có thông tin thì coi là tối;
     - thấy đủ **0,7 giây** mới chuyển sang `chase`. Trong 0,7 giây đó phát signal `noticing` (để âm thanh cho tiếng hít vào).
   - **Mất dấu:** tìm 20–30 giây quanh vị trí thấy người chơi lần cuối, rồi quay lại đi tuần.
   - **Vùng an toàn:** không bước vào Area3D trong group `safe_light` (đèn vàng sợi đốt). Đang đuổi mà người chơi vào vùng đó thì dừng ở mép, đứng 3 giây rồi chuyển sang `lost`.
   - **Chỗ nấp:**
     - thấy người chơi chui vào (đang `chase` hoặc đang nhìn thấy) thì tới gọi `pull_out()` rồi bắt;
     - nghe tiếng thở (`source = &"breath"`) cách ≤ 1,5 m cũng vậy;
     - không có hai điều trên thì dừng trước chỗ nấp 2–3 giây rồi đi, phát signal `lingered(spot)`.
   - **Bắt:** cách ≤ 0,8 m khi `chase` thì phát `EventBus.player_caught(&"walker")` và signal riêng `caught`, rồi dừng. Màn hù và tải lại checkpoint do integrator làm.
   - **API theo kịch bản:** `appear_at(transform)`, `chase_player()`, `walk_to(position)`, `stop()` (biến mất). Chương 1 dùng: xuất hiện ở chiếu nghỉ cầu thang rồi đuổi.
   - **Phòng 407 đêm 1–3:** không vào được phòng khóa cửa. Cửa có metadata `locked` hoặc integrator báo; ghi cách làm vào Handoff.
   - **"Giảm hù dọa"** (`[accessibility] reduce_scares`): tốc độ còn 80%.
   - **Model:** dùng `body_scene` như `pursuer.gd` (lane B làm ở T-154). Chưa có thì dùng capsule.
   - **Âm thanh:** gắn `res://audio/entities/walker_audio.tscn` của lane E (T-158) nếu có. API của nó: `play_step(running: bool)`, `set_breathing(on: bool)`, `play_inhale()`, `play_whisper()`. Chưa có thì bỏ qua, không lỗi.
2. **Người thứ năm** (`watcher.gd`, `watcher.tscn`):
   - **Bị nhìn** khi: nằm trong frustum camera, tia từ camera tới nó không bị chặn, và cách người chơi < 20 m. Khi đó đứng im tuyệt đối.
   - **Không bị nhìn** quá 2 giây thì **nhảy** sang một điểm khác trong `anchors` (mảng Marker3D integrator truyền vào). Điểm mới phải gần người chơi hơn và **không nằm trong tầm nhìn** của camera tại thời điểm nhảy. Không trượt liên tục.
   - Đèn tắt hoặc chớp tắt trên người nó cũng tính là không bị nhìn: dùng `lit_area` như trên; đèn pin chiếu vào thì coi là sáng.
   - Tới cách sau lưng người chơi ≤ 1,5 m thì phát `EventBus.player_caught(&"watcher")` và signal `caught`.
   - **Đợt theo dõi:**
     - `start_watch(anchors: Array[Node3D], duration: float)`: phát `EventBus.watcher_active(true, vị trí)`, phát lại mỗi khi nó nhảy;
     - hết giờ thì `stop_watch()` và phát `watcher_active(false, vị trí)`;
     - trạng thái `hidden`, `watching`, `closing_in` phát qua `entity_state_changed(&"watcher", …)`.
   - **Không tự di chuyển khi Người đi dép đang đuổi** (§5.4): nghe `entity_state_changed(&"walker", &"chase")`.
   - **Không có tiếng bước chân.**
   - **Model:** `body_scene` (T-154); chưa có thì dùng capsule trắng cao 1,9 m.
3. **Scene thử** `walker_test.tscn` và `watcher_test.tscn`:
   - có navmesh đơn giản, chỗ nấp từ T-151, một vùng `safe_light`, một vùng `lit_area`;
   - có phím bật đi tuần, đuổi, đợt theo dõi.
4. **Test:**
   - Người đi dép: chuyển trạng thái theo tiếng động và bán kính; thấy đủ 0,7 giây mới đuổi; không vào `safe_light`; lôi người chơi ra khỏi chỗ nấp khi thấy chui vào; đứng chờ rồi đi khi không thấy; bắt trong 0,8 m.
   - Người thứ năm: đứng im khi bị nhìn; nhảy sang điểm gần hơn và nằm ngoài tầm nhìn; bắt khi ≤ 1,5 m; không nhảy khi Người đi dép đang đuổi.
   - Test cũ của `pursuer` vẫn PASS. `pursuer.gd` vẫn giữ nguyên cho các cảnh truy đuổi của demo.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: API, các con số đã dùng, cách thử, phần chưa thử, yêu cầu cho lane B/E/integrator

## Handoff (agent điền)
