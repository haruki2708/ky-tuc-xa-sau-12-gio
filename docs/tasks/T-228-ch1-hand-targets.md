# T-228 — Điểm đặt tay (`HandTarget`) cho đồ dùng được trong chương 1
- Lane: A (Gameplay) | Trạng thái: todo | Agent: (chủ dự án điền tên tài khoản GPT mới)
- Nhánh: `lane-a/T-228-ch1-hand-targets` từ `origin/main` mới nhất.
- Quyết định giao: **D-139** (việc thử đầu tiên của tài khoản lane A mới). Integrator chấm theo bảng trong `docs/tasks/README.md`.
- Phụ thuộc: T-220 (cơ chế tay, D-121, D-124), T-227 lượt 1 (thân Trần Trung, `5289def`).

## Bối cảnh
- Nhân vật chính có thân (T-220, T-227) dùng đồ bằng tay trong 1 giây: tay vươn tới `HandTarget` của đồ, nắm, rồi đồ mới chạy.
  - `HandTarget` (`game/scripts/interaction/hand_target.gd`) là một `Marker3D` đặt **làm con của Interactable**, đúng chỗ tay chạm. Có kiểu nắm `grip` (GRIP nắm cả bàn, PINCH hai ngón, HOOK móc ngón), `pick_up` (đồ cầm lên mắt như tờ giấy), `lever` (cần gạt vặn trước).
  - `Interactable.hand_target(from)` (`game/scripts/core/interactable.gd`) lấy marker gần người chơi nhất. Đồ dùng được hai phía thì mỗi phía một marker.
  - Đồ **không có** `HandTarget` vẫn bấm là xong như cũ. Bản chơi chưa có thân (chỉ cảnh thử `graphics_pilot/protagonist_pilot.tscn` có), nên thêm marker **không đổi gì** trong bản chơi hiện tại.
- Hiện chỉ 5 thứ có tay, đều gắn tạm bằng code trong cảnh thử: cửa 407, cửa nhà tắm, cửa ban công (qua `DoorHandles.take`), tủ của Việt, tờ giấy của Đạt (`protagonist_pilot.gd`, hàm `_add_targets`).
- Việc này chuẩn bị cho bước đưa thân vào 4 chương (T-220 bước 5): mọi đồ dùng tay của chương 1 có sẵn điểm đặt tay.

## Mục tiêu
Mọi đồ **dùng bằng tay** trong chương 1 có `HandTarget` đặt đúng chỗ tay chạm, đúng kiểu nắm, gắn trong scene hoặc script **của lane A**.

## Việc cần làm
1. **Kiểm kê** đồ tương tác của chương 1. `chapter1_director.gd` tạo phần lớn (đọc, không sửa): giấy `readable.tscn`, `search_spot.tscn`, `wall_knock.tscn`, `power_strip.tscn`, `lan_cable.tscn`, `lan_socket.tscn`, `desk_lamp_switch.tscn`, `door_latch.tscn`, `puzzle_station.tscn`, `bunk_spot.tscn`, cùng `light_switch.tscn` và các `StoryTrigger`. Ghi bảng vào Handoff: tên, scene, đặt ở đâu trong chương 1 (anchor), dùng tay hay không, kiểu nắm, chỗ đặt.
2. **Gắn `HandTarget`** cho đồ dùng tay, theo chú thích đầu file `hand_target.gd`:
   - công tắc, nút: PINCH, marker trên mặt nút;
   - giấy: PINCH, `pick_up = true`, ngay trong mép phải, giữa chiều cao (như tờ giấy của Đạt trong cảnh thử). Kích thước giấy khác nhau nên đặt marker theo `size` trong `readable.gd`, không cố định trong `.tscn`;
   - dây mạng, ổ cắm: kiểu nắm hợp lý, ghi lý do;
   - tủ, ngăn kéo, chốt cửa: HOOK hoặc GRIP ở mép hoặc tay nắm;
   - đồ một scene dùng cho nhiều chỗ (ví dụ `search_spot` cho nhiều tủ): kiểm marker đúng ở **từng chỗ** chương 1 đặt nó.
3. **Không gắn** (ghi trong bảng, để bước sau): giường và chỗ nấp (`bunk_spot`, `hide_spot`, `gag_spot`: leo, nằm, nấp là T-227 bước sau), `StoryTrigger` (core), cửa 407 (đã có, thuộc level), đồ chương 2–4.
4. **Test** mới `game/tests/player/test_ch1_hand_targets.gd`:
   - mỗi đồ trong bảng "dùng tay" có ít nhất một `HandTarget`, đúng `grip` và `pick_up`;
   - marker nằm trong hoặc sát (≤ 5 cm) khối va chạm của chính đồ đó ở vị trí chương 1 đặt, cao 0,2–1,9 m so với sàn;
   - đồ trong bảng "không gắn" vẫn trả `hand_target() == null`;
   - người chơi **không** có thân vẫn dùng mọi đồ như cũ (test chương 1 cũ đạt).

## Được phép sửa
- `game/scenes/interaction/*.tscn` của các đồ trên: chỉ thêm node `HandTarget`.
- `game/scripts/interaction/*.gd` của các đồ trên: chỉ phần tạo hoặc đặt `HandTarget` (ví dụ `readable.gd` đặt marker theo `size`).
- `game/tests/player/test_ch1_hand_targets.gd` (mới).
- Card này: chỉ Checklist và Handoff.

## Không được
- **Không sửa** `game/scripts/player/player.gd`, `player_body.gd`, `game/scripts/interaction/hand_target.gd`, `door_handles.gd`: integrator đang làm T-227 trên các file này. Cần thêm kiểu nắm hay đổi cách chọn marker thì ghi "Yêu cầu thay đổi".
- Không sửa `chapter1_director.gd`, `chapter1_main.gd` (core), scene level (`game/scenes/levels/`, lane B), cảnh thử `graphics_pilot/`.
- Không đổi luật, lời thoại, thời gian, cách chơi; không đổi va chạm, vùng bấm của đồ.
- Không chạy bot, không đo FPS, không tiêu credit Tripo.

## Checklist hoàn thành
- [ ] Bảng kiểm kê đủ đồ chương 1 trong Handoff
- [ ] `HandTarget` cho mọi đồ dùng tay, đúng kiểu nắm
- [ ] `test_ch1_hand_targets.gd` đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (theo luật lượt Godot trong `AGENTS.md`)
- [ ] Handoff trung thực, có commit hash

## Cách kiểm tra
- `pwsh tools/test.ps1 -Filter ch1_hand_targets` khi đang làm; full test và check trước khi commit.
- Integrator sẽ gỡ phần gắn tạm trong cảnh thử, chụp ảnh tay chạm từng đồ trên thân Trần Trung khi ghép.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
