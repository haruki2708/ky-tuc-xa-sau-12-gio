# T-151 — Sinh tồn: nằm trên giường, nín thở, tiếng động, cúi, điện thoại và đèn pin, trạm câu đố
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-151-survival-phone`
- Phụ thuộc: T-150 phần 1 (đã có trên `main`). Đọc `docs/design/STORY.md` (v2) §5 và bảng số giường trong `docs/tasks/T-150-chapter1-core.md`.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-152 ngay.

## Mục tiêu
Chương 1 diễn ra gần như hoàn toàn trong phòng 407:
- mở đầu: người chơi nằm trên giường và phải ngồi dậy rời giường trong 60 giây;
- vòng 2: phải **nằm trên giường của bạn cùng phòng đã chết**, nín thở, không nhúc nhích khi quản lý đứng trong phòng.

Ngoài ra cần tiếng động cho thực thể nghe, điện thoại (nhóm chat là giao diện chính của chương), đèn pin và tủ khóa số.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/tests/player/`, thêm key vào `game/localization/strings.csv`.

## Hợp đồng có sẵn (không sửa)
- Phím: `crouch`, `phone`, `flashlight`, `hold_breath`.
- Signal: `noise_emitted`, `player_hidden`, `breath_held`, `phone_raised`, `flashlight_toggled`, `phone_battery_changed`, `puzzle_opened`, `puzzle_closed`, `puzzle_solved`.
- `PuzzleData.load_by_id(id)`.

## Yêu cầu
1. **Giường nằm được** (`bunk_spot.gd` + `.tscn`, kế thừa `Interactable`):
   - Export: `bed_number: int` (1–4), `view: NodePath` (vị trí camera khi nằm), `exit: NodePath` (chỗ đứng khi rời giường).
   - E thì nằm lên (giường tầng trên có động tác trèo ngắn); E lần nữa thì rời giường.
   - Khi nằm: không đi được; xoay đầu giới hạn khoảng ±70° ngang, −10…+40° dọc. Phát `player_hidden(true, &"bunk")`.
   - API: `GameState` cờ `player_bed` = số giường đang nằm (0 khi không nằm); hàm `Player.lie_on(spot)` để integrator đặt người chơi nằm sẵn lúc bắt đầu chương; signal `entered`, `exited`.
   - **"Nhúc nhích" khi đang nằm:** xoay đầu nhanh (vận tốc góc vượt ngưỡng) hoặc rời giường thì phát `noise_emitted(…, 2.0, &"move")`. Ngưỡng là export.
2. **Chỗ nấp chung** (`hide_spot.gd`): gầm giường, tủ sắt, buồng vệ sinh. Dùng cho chương 3–4.
   - Export `kind`, `view`, `exit`; API `is_occupied()`, `pull_out()`; phát `player_hidden`.
   - Làm cùng một khung với `bunk_spot`.
3. **Nín thở** (khi đang nằm hoặc đang nấp):
   - Giữ Space thì im lặng, tối đa 8 giây, phát `breath_held(true/false)`.
   - Hết 8 giây thì thở hắt bắt buộc, bán kính 4 m; nghỉ 4 giây mới nín lại được.
   - Không nín thở thì cứ khoảng 3 giây có một hơi thở, bán kính 1,5 m, `source = &"breath"`.
4. **Tiếng động khi đi:**
   - mỗi bước chân phát `noise_emitted(vị trí, bán kính, &"step")`: chạy 12 m, đi 5 m, cúi 1,5 m;
   - hàm `Player.make_noise(radius, source)`;
   - chốt cửa phát tiếng 3 m, công tắc 2 m.
5. **Cúi:** giữ C hoặc Ctrl; camera khoảng 1,0 m; 1,2 m/s; không chạy; chỉ đứng dậy khi trên đầu trống.
6. **Điện thoại cầm tay** (`phone_item.gd`, gắn vào Player):
   - Q giơ hoặc hạ, phát `phone_raised`; có mô hình đơn giản trong tay. Màn hình là việc của T-155.
   - F bật đèn pin (SpotLight3D theo camera, khoảng 12 m), phát `flashlight_toggled`.
   - **Pin:** export `battery`, `drain_per_second_flashlight` (mặc định 0,2 %/giây), `drain_per_second_call` (mặc định 0,05 %/giây khi đang trong cuộc gọi; integrator bật bằng `set_in_call(bool)`).
   - Hết pin thì đèn tắt; phát signal riêng `battery_empty`.
   - API: `set_battery()`, `charge(percent_per_second)` để integrator gọi khi cắm sạc.
   - Phát `phone_battery_changed` khi đổi số nguyên.
7. **Trạm câu đố** (`puzzle_station.gd`):
   - Export `puzzle_id`; E thì phát `puzzle_opened`.
   - Người chơi đứng yên cho tới khi có `puzzle_closed` hoặc `puzzle_solved`.
   - Đã giải thì `solved = true`, phát signal `solved`, không mở lại.
8. **Scene thử:** phòng có giường tầng (4 `bunk_spot`), một tủ có trạm câu đố, chỗ tối để thử đèn pin.
9. **Test `game/tests/player/`:**
   - nằm và rời giường; cờ `player_bed`;
   - nhúc nhích phát tiếng; nín thở 8 giây rồi thở hắt;
   - bán kính tiếng bước chân; cúi;
   - pin tụt và sạc; trạm câu đố.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: API, cách gắn vào phòng 407 (cho integrator), cách thử, phần chưa thử

## Handoff (agent điền)
