# T-228 — Điểm đặt tay (`HandTarget`) cho đồ dùng được trong chương 1
- Lane: A (Gameplay) | Trạng thái: done (D-140) | Agent: (chủ dự án điền tên tài khoản GPT mới)
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
- [x] Bảng kiểm kê đủ đồ chương 1 trong Handoff
- [x] `HandTarget` cho mọi đồ dùng tay, đúng kiểu nắm
- [x] `test_ch1_hand_targets.gd` đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (theo luật lượt Godot trong `AGENTS.md`)
- [x] Handoff trung thực, có commit hash

## Cách kiểm tra
- `pwsh tools/test.ps1 -Filter ch1_hand_targets` khi đang làm; full test và check trước khi commit.
- Integrator sẽ gỡ phần gắn tạm trong cảnh thử, chụp ảnh tay chạm từng đồ trên thân Trần Trung khi ghép.

## Handoff (agent điền)
### Phiên 2026-11-01 → 2026-11-02 — Codex lane A (D-139)

- Workspace mới: `D:\GAME_WORK\lane-a2`; đã clone, `git lfs install --local`, `git lfs pull`, fetch và tạo nhánh `lane-a/T-228-ch1-hand-targets`.
- Gốc nhánh: `2773a3f608f33a2bda719a3dcfbf74900cfe07c0` (`origin/main` lúc bắt đầu).
- Đã thêm marker cho 22 đối tượng của chương 1: 9 giấy/thẻ/ảnh (kể cả giấy Khoa), 3 điểm tìm, tường gõ, 3 công tắc ổ điện, 2 đầu dây mạng, ổ mạng, đèn bàn, chốt cửa và khóa số.
- Giấy tự đặt marker theo `size`, ở mép phải trừ 1,5 cm, giữa chiều cao; giấy cực nhỏ kẹp về tâm để không ra ngoài mép. Không dùng chiều sâu vùng bấm 15 cm làm vị trí mặt giấy.
- `search_spot` đặt marker theo `spot_id`. Tủ Việt khớp mép tủ của pilot `(30.61, 1.0, -1.31)`; nệm dùng mép model thật, không đặt tay lơ lửng tại tâm vùng bấm.
- Đèn bàn dùng marker PINCH thừa kế từ `light_switch`; đặt lại bằng lời gọi deferred sau khi director thay khối bấm bằng bounds của model. Công tắc thường giữ marker trên mặt nút.
- Không sửa collision, vùng bấm, luật, thời gian, player/body, core, level, STATUS hoặc DECISIONS. Các scene dùng chung tự có marker trong chương khác, nhưng không bổ sung đồ hay cấu hình riêng cho chương 2–4.
- Chưa chụp ảnh tay Trần Trung hoặc chơi tay; đây là kiểm tra cấu trúc/vị trí và hồi quy tự động, chưa phải duyệt hình ảnh.

#### Ngoại lệ được chủ dự án duyệt trong phiên

1. **Giữ vị trí đồ, cho phép ngoại lệ độ cao theo từng món**, vì đồ sát sàn và một số giấy cao hơn 1,9 m đã tồn tại. Test dùng danh sách tên và khoảng hẹp, không nới giới hạn chung:
   - Switch1/2/3: 0,02–0,10 m; đầu dây xanh/xám: 0,005–0,04 m (script môi trường hạ anchor xuống 0,0045 m khi chạy).
   - Điểm tìm thùng rác: 0,15–0,20 m; giấy Khoa: 0,03–0,08 m.
   - Thẻ Phúc và ảnh đội bóng: 2,0–2,1 m.
2. **Riêng marker nệm Phúc được cách collision tối đa 11 cm**, giữ collision để không đổi gameplay. Đo trong test: **0,1069 m**. Có phép kiểm riêng marker nằm trong/sát bounds model nệm thật tối đa 5 mm. Mọi món khác giữ giới hạn 5 cm.
3. Hai ngoại lệ trên là lời duyệt trực tiếp của chủ dự án trong phiên; phần yêu cầu gốc của card được giữ nguyên, chỉ ghi bổ sung tại Handoff theo phạm vi cho phép.

#### Bảng kiểm kê chương 1

Các đường dẫn anchor dưới đây tương đối với `Floor4/Room407/Anchors`, trừ khi ghi khác. Vị trí marker là local của Interactable, đơn vị m. Giấy đều dùng PINCH, `pick_up = true`, `(max(0, size.x/2 - 0.015), 0, 0.0015)`; giữ trục của giấy. Các món còn lại `pick_up = false`.

| Đồ | Scene / script | Anchor / nơi đặt chương 1 | Dùng tay | Kiểu nắm và chỗ đặt |
|---|---|---|---|---|
| Giấy Đạt `ch1_dat_note` | `readable.tscn` | `DatNote`, size 0,15 × 0,21 | Có | PINCH, mép phải |
| Thẻ Đạt `ch1_dat_card` | `readable.tscn` | `DatNote` + (0,0,0.22), size 0,09 × 0,06 | Có | PINCH, mép phải |
| Lịch Phúc `ch1_phuc_schedule` | `readable.tscn` | `PhucBooks` + (0.12,-0.25,0), size 0,21 × 0,30 | Có | PINCH, mép phải |
| Ảnh Việt `ch1_viet_photo` | `readable.tscn` | `VietPhoto` + (-0.001,-0.05,0.142), size 0,15 × 0,10 | Có | PINCH, mép phải |
| Thẻ Phúc `ch1_phuc_card` | `readable.tscn` | `PhucCard`, size 0,09 × 0,06 | Có | PINCH; ngoại lệ cao >1,9 m |
| Ảnh đội bóng `ch1_team_photo` | `readable.tscn` | `TeamPhoto` + (0.062,0.1,0.05), size 0,15 × 0,10 | Có | PINCH; ngoại lệ cao >1,9 m |
| Thẻ Việt `ch1_viet_card` | `readable.tscn` | `VietLaptop` + (0.27,-0.148,0.03), size 0,09 × 0,06 | Có | PINCH, mép phải |
| Bảng gõ `ch1_tap_chart` | `readable.tscn` | `GuitarSongbook`, size 0,15 × 0,21 | Có | PINCH, mép phải |
| Giấy Khoa `ch1_khoa_note` | `readable.tscn` | `KhoaNoteSlot` + (0,0.03,0), director sinh sau | Có | PINCH; ngoại lệ sát sàn |
| Tủ Việt | `search_spot.tscn` | `VietLocker` + world (0.32,1,0) | Có | HOOK, mép cửa local (-0.06,0,0.01) |
| Nệm Phúc | `search_spot.tscn` | `PhucMattress` + world (0.5,0.1,0) | Có | HOOK, mép nệm local (-0.1,-0.105,0); ngoại lệ collision 11 cm |
| Thùng rác | `search_spot.tscn` | `TrashBin`, không offset | Có | HOOK ở cạnh thân (0.13,0.18,0), trong tầm vùng bấm; chưa duyệt ảnh thao tác |
| Tường 406 | `wall_knock.tscn` | `WallKnock406` | Có | GRIP cho bàn tay khép khi gõ; (-0.10,0,0), hướng vào mặt tường phía tây |
| Nút ổ điện 1/2/3 | `power_strip.tscn` | `PowerStrip/Switch1…3`; director đồng bộ transform từng nút | Có | PINCH, (0,0,-0.03) tại rocker, không đặt ở phích cắm |
| Đầu dây xanh/xám | `lan_cable.tscn` | `LanBlueEnd`, `LanGrayEnd` | Có | PINCH, (0,0.015,0); đầu RJ45 nhỏ, dùng hai ngón thay vì nắm cả bàn |
| Ổ mạng | `lan_socket.tscn` | `LanWallPort` | Có | PINCH, (0,0,0.02) trên mặt ổ, thao tác cắm/rút đầu RJ45 |
| Đèn bàn | `desk_lamp_switch.tscn` thừa kế `light_switch.tscn` | `DeskLampSwitch`; collision được director thay bằng bounds đèn | Có | PINCH tại phần chân đèn; tính theo collision sau bố trí, không theo anchor cũ |
| Công tắc đèn thường | `light_switch.tscn` | `Floor4/Anchors/Room407LightSwitch` chỉ là anchor; bản chương 1 hiện không sinh công tắc riêng tại đây | Có nếu instance | PINCH (0,0,0.025); test scene riêng, không tự thêm vào level |
| Chốt cửa 407 | `door_latch.tscn` | `Floor4/Door407/Pivot/DoorLatch407` | Có | GRIP, (-0.78,1.05,-0.19), trên chốt |
| Khóa số tủ Đạt | `puzzle_station.tscn` | `DatLocker` + world (-0.12,0,0), con director | Có | PINCH (0.10,0,0), gần mặt khóa số; kẹp/vặn bánh số |
| Giường 1–4 | `bunk_spot.tscn` | `Bunks/Bunk1…4` | Không gắn ở T-228 | Leo/nằm để T-227; `hand_target() == null` |
| Chỗ nấp | `hide_spot.tscn` | Không thêm instance; kiểm scene dùng chung | Không gắn ở T-228 | `hand_target() == null` |
| Chỗ bịt miệng | `gag_spot.tscn` | Không thêm instance; kiểm scene dùng chung | Không gắn ở T-228 | `hand_target() == null` |
| Cắm sạc / trigger dự phòng | `StoryTrigger` (core) | `TrungChargingCable` → `ChargerSocket`; fallback giường/khóa nếu thiếu scene | Không gắn ở T-228 | Giữ core; test trigger thực tế trả null |
| Cửa 407, nhà tắm, ban công | Level và cơ chế pilot `DoorHandles.take` | `Floor4/Door407`, `Room407/Extension` | Không gắn ở T-228 | Ngoài phạm vi; không thêm marker cửa |

#### Kiểm tra và kết quả

- `pwsh tools/test.ps1 -Filter ch1_hand_targets`: **`RESULT: 3 passed, 0 failed`**.
- `pwsh tools/test.ps1 -Filter ch1v2_interactions`: **`RESULT: 9 passed, 0 failed`**.
- Lượt T-228 đầu phát hiện đèn bàn lệch 0,1796 m; đã sửa cách đặt marker đèn. Lượt tiếp phát hiện nệm 0,1069 m; không sửa collision, dùng ngoại lệ đã duyệt.
- Full `pwsh tools/test.ps1` (02/11, 00:33–00:56): **`RESULT: 853 passed, 1 failed`**, tiếp theo **`RESULT: test FAIL (engine error or missing successful runner result)`**. Lỗi duy nhất: `test_pursuer.gd::test_running_target_increases_gap_but_walking_is_caught`, assertion `sprint widens initial 3m gap`. Các test mới T-228 và test tương tác/chapter 1 đều đạt trong lượt full. Không có dòng `SCRIPT ERROR:` hoặc `ERROR:` trong log full.
- `pwsh tools/check.ps1` (02/11, 00:56–01:10): **`RESULT: check 0 error(s)`**, exit 0. Đã chạy ngay sau full test trong cùng lượt khóa; khóa lane A được nhả khi xong.
- Kiểm chứng sau lỗi full: `pwsh tools/test.ps1 -Filter pursuer` đạt **`RESULT: 16 passed, 0 failed`**, kể cả test đã trượt. Đây không thay thế cho full PASS. Nghi vấn nhịp frame: test dịch mục tiêu một lần mỗi `_ticks(1)`, nhưng `_ticks` chờ cả physics và process frame; pursuer có thể chạy nhiều bước vật lý. Test cùng file `test_reduce_scares_changes_speed_live_and_validates_settings` đã ghi chú vấn đề này. Chưa chứng minh dứt điểm nguyên nhân hoặc tái hiện trên baseline trước T-228; không sửa file này vì ngoài danh sách được phép của card.
- Log cục bộ: `build/t228/targeted.log`, `ch1v2_interactions.log`, `pursuer.log`, `full-test.log`, `check.log`, `gate-exits.txt` (đều trong `build/t228/`); không commit log build.
- Commit triển khai: **`d074a10ba3ed4c25efcdfef0ded744ea3603b686`** — `T-228: Add chapter one hand targets and regression coverage`. Handoff nằm ở commit tài liệu kế tiếp. Đã trả lại `game/default_bus_layout.tres` trước commit. Fetch cuối phiên xác nhận `origin/main` vẫn là `2773a3f`; không cần rebase.
- **Blocked: cổng full test chưa PASS do test pursuer nói trên.** Phần marker/test T-228 đã triển khai; chưa đánh dấu checklist full test/check hoàn thành. Đề nghị integrator review lỗi và quyết định bước kiểm tiếp theo; không coi nhánh này đã đủ điều kiện merge chỉ vì test pursuer chạy riêng đạt.

#### Yêu cầu thay đổi / lưu ý khi integrator ghép

- Review `game/tests/player/test_pursuer.gd::test_running_target_increases_gap_but_walking_is_caught` (ngoài phạm vi T-228): đề xuất cập nhật mục tiêu theo thời gian vật lý thực hoặc từng physics tick thay vì mỗi vòng chờ process frame, giữ nguyên tốc độ/collision/gameplay. Lane A chưa sửa và chưa nới assertion.

- Gỡ marker giấy Đạt gắn tạm trong `graphics_pilot/protagonist_pilot.gd::_add_targets` để không có hai điểm cầm cùng giấy. Không sửa pilot trong lane A.
- `Interactable.hand_target()` tìm đệ quy nên `Door407.hand_target()` có thể lấy marker của **Interactable chốt cửa con**. Không đòi cửa trả null trong test T-228 vì chốt nằm trong subtree cửa. Integrator cần review cách bỏ qua Interactable lồng nhau/chọn marker cửa khi đưa thân vào bản chơi; lane A không sửa core hoặc `door_handles.gd`.
- Chưa duyệt hình tay chạm đèn bàn/thùng rác/khóa số/tường và các đồ khác trên thân Trần Trung. Integrator chụp/duyệt theo mục Cách kiểm tra của card.
- Chưa chạy bot, đo FPS, export, chơi tay 4 chương hoặc dùng Tripo; không phát sinh credit.

## Review (integrator, 02/11/2026)
- **Đạt, đã merge** (D-140). Điểm: 5 · 4 · 5 · 4 · 5 · 0 vòng (`docs/tasks/README.md`).
- Đúng phạm vi, test kiểm đúng chỗ quan trọng (vị trí thật trong chương 1, sau khi director đổi vùng bấm), Handoff trung thực, tự nêu lỗi full test và vấn đề cửa/chốt.
- Lỗi `test_pursuer` trong full test của agent: chạy riêng đạt, lượt full của lane B, C và lượt integrator sau merge đều đạt; coi là test chập chờn khi máy bận.
- Integrator sửa khi merge: `Interactable.hand_target()` bỏ qua marker của Interactable lồng bên trong (cửa 407 không lấy marker chốt), thêm kiểm tra vào `test_ch1_hand_targets.gd`; bỏ marker giấy Đạt gắn tạm trong `protagonist_pilot.gd` và `test_protagonist_body.gd`.
- Góp ý lần sau: tránh mã cứng theo `spot_id` và so kích thước khối (`light_switch.gd`); nếu cần cấu hình theo từng chỗ đặt, đề xuất thuộc tính `@export` hoặc ghi "Yêu cầu thay đổi".
