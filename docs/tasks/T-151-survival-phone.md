# T-151 — Sinh tồn: cúi, tiếng động, chỗ nấp, nín thở, điện thoại và đèn pin, trạm câu đố
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-151-survival-phone`
- Phụ thuộc: T-150 phần 1 (đã có trên `main`). Đọc `docs/design/STORY.md` §5 (đầu mục và 5.1) và §10.
- **Hạn: hết ngày 2026-10-05.** Xong task này thì làm T-152 ngay.

## Mục tiêu
Người chơi của chương 1 cần các cơ chế sinh tồn mới: đi êm, gây tiếng động cho thực thể nghe, nấp, nín thở, giơ điện thoại xem giờ (D-027) và bật đèn pin, mở các câu đố.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`, thêm key vào `game/localization/strings.csv`.

## Hợp đồng có sẵn (T-150, không sửa)
- Phím: `crouch` (C, Ctrl), `phone` (Q), `flashlight` (F), `hold_breath` (Space).
- Signal: `EventBus.noise_emitted(position, radius, source)`, `player_hidden(hidden, spot_kind)`, `breath_held(holding)`, `phone_raised(raised)`, `flashlight_toggled(on)`, `phone_battery_changed(percent)`, `puzzle_opened(id)`, `puzzle_closed(id)`, `puzzle_solved(id)`.
- `PuzzleData.load_by_id(id)`; dữ liệu mẫu `locker_combo_601`, `fuse_box_6`.

## Yêu cầu
1. **Cúi** (`player.gd`):
   - Giữ `crouch` thì camera hạ xuống khoảng 1,0 m, capsule thấp lại, tốc độ 1,2 m/s, không chạy được.
   - Thả phím thì chỉ đứng dậy khi phía trên trống (kiểm tra bằng shape cast).
   - Bước chân khi cúi nhẹ hơn: dùng `intensity` sẵn có của signal bước chân.
   - Menu tạm dừng và các cài đặt của T-125 vẫn hoạt động như cũ.
2. **Tiếng động:** mỗi bước chân phát `EventBus.noise_emitted(vị trí chân, bán kính, &"step")`.
   - Bán kính: chạy 12 m, đi bộ 5 m, cúi 1,5 m.
   - Thêm hàm công khai `Player.make_noise(radius, source)` cho đồ vật hoặc integrator gọi (cửa đóng mạnh 15 m, làm rơi đồ 10 m).
   - Các đồ vật tương tác của lane A tự phát tiếng động hợp lý: chốt cửa 3 m, công tắc 2 m.
3. **Chỗ nấp** (`hide_spot.gd` + `hide_spot.tscn`, kế thừa `Interactable`):
   - `@export var kind: StringName` (`bed`, `locker`, `stall`, `net`), `@export var view: NodePath` trỏ tới vị trí đặt camera bên trong (nhìn qua khe).
   - E để vào; E lần nữa để ra, ra về một điểm `exit` đặt sẵn.
   - Khi nấp: người chơi không đi được, chỉ xoay đầu trong giới hạn khoảng ±50° ngang, ±25° dọc. Phát `player_hidden(true, kind)`; ra thì `player_hidden(false, kind)`.
   - API cho T-152: `is_occupied() -> bool`, `pull_out()` (đẩy người chơi ra ngay, phát `player_hidden(false, kind)`), signal `entered`, `exited`.
   - Đang nấp và không nín thở: cứ khoảng 3 giây phát một tiếng thở nhẹ, `noise_emitted(…, 1.5, &"breath")`.
4. **Nín thở:**
   - Giữ `hold_breath` khi đang nấp thì im lặng hoàn toàn, tối đa 8 giây, phát `breath_held(true)`.
   - Thả phím thì phát `breath_held(false)` và một tiếng thở ra, bán kính 2 m.
   - Giữ hết 8 giây thì bị hắt hơi thở bắt buộc, bán kính 4 m, và phải chờ 4 giây mới nín thở lại được.
5. **Điện thoại cầm tay** (`phone_item.gd`, gắn vào Player):
   - Q giơ lên hoặc hạ xuống: phát `phone_raised`. Có một mô hình điện thoại đơn giản trong tay. Màn hình trên máy là việc của lane D (T-155), lane A chỉ chừa chỗ.
   - **Đèn pin (F):** một SpotLight3D theo camera, tầm khoảng 12 m, góc hẹp. Phát `flashlight_toggled`. Bật được cả khi chưa giơ điện thoại.
   - **Pin:** bắt đầu đêm ở 100%; đèn pin bật thì tụt 1% mỗi 5 giây; 0% thì đèn tự tắt và không bật lại được. Phát `phone_battery_changed` khi đổi số nguyên.
   - API: `battery`, `set_battery(percent)` (để integrator lưu và khôi phục theo checkpoint), `is_flashlight_on()`.
6. **Trạm câu đố** (`puzzle_station.gd`, kế thừa `Interactable`):
   - `@export var puzzle_id: StringName`. E thì phát `puzzle_opened(puzzle_id)` và người chơi đứng yên cho tới khi có `puzzle_closed(puzzle_id)` hoặc `puzzle_solved(puzzle_id)`.
   - Khi đã giải: `solved = true`, lời nhắc đổi, phát signal riêng `solved`, không mở lại nữa.
   - Panel câu đố là việc của lane D (T-156). Trong scene thử, giả lập panel bằng phím tắt.
7. **Scene thử** `player_test.tscn` (hoặc một scene thử mới): có gầm giường, tủ sắt, buồng vệ sinh, mùng; một trạm câu đố; chỗ tối để thử đèn pin.
8. **Test `game/tests/player/`:**
   - tốc độ khi cúi; không đứng dậy được dưới trần thấp;
   - bán kính `noise_emitted` theo dáng đi;
   - vào/ra chỗ nấp phát đúng signal, `pull_out()`;
   - nín thở tối đa 8 giây rồi hắt hơi;
   - pin tụt khi bật đèn, hết pin thì đèn tắt;
   - trạm câu đố mở, đóng, giải.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: API, cách gắn vào tầng (cho integrator), cách thử bằng tay, phần chưa thử

## Cách kiểm tra
F6 scene thử: cúi đi; nấp từng loại chỗ nấp; nín thở; Q, F, xem pin tụt; mở trạm câu đố.

## Handoff (agent điền)
