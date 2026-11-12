# T-249 — Thân Trần Trung vào chương 3, phần không phụ thuộc cảnh: thanh sắt, ngoảnh lại khi chạy, thở dốc
- Lane: **HARU làm thay lane B** (lane B hết hạn mức; chủ dự án chọn 12/11) | Trạng thái: **đang dở** (HARU rồi integrator, 12/11; xem Handoff) | Agent: tài khoản Claude của HARU, mở trong **`D:\GAME_WORK\lane-b2`** bằng `D:\GAME_WORK\mo_claude_haru_lam_lane_b.cmd`; model đề xuất **Fable 5.2 high**. Chủ dự án tự dán prompt (integrator không điều khiển lane Claude).
- Nhánh: `lane-b/T-249-protagonist-chapter3-bar` từ `origin/main` mới nhất.
- Quyết định giao: **D-165** (12/11/2026): đồ hoạ thật trước (T-248); thân chương 3 tách hai phần, phần không phụ thuộc cảnh làm ngay. Phương án các dòng lấy theo đề xuất của [T-247](T-247-protagonist-chapter3-survey.md) (`tools/reports/T-247-ch3-body-survey.md` mục 1); chủ dự án đổi dòng nào thì integrator sửa card trước khi giao.

## 1. Việc (theo bảng T-247)
| Dòng T-247 | Thao tác | Làm |
|---|---|---|
| 1 | Cầm thanh sắt | **Thanh nằm trong nắm tay phải**, như giẻ chương 2 (`PlayerBody.take_item`, T-243): đi lại buông dọc chân, góc mắt thấy đầu thanh và nắm tay. Mô hình thanh sắt thật dựng bằng Blender (ống thép ~0,85 m, gỉ, cong dần theo số lần đập như `_bend` hiện nay), thay hộp xám `IronBarWeapon._segment`. |
| 2 | Vung thanh sắt | **Bổ chéo từ vai phải xuống**: tay phải vung, ngực xoay theo (`BodyLeanModifier`), chân đứng nguyên; **0,55 s, tầm 1,5 m, luật trúng như cũ; không khoá di chuyển** (bot `strike_blocker` đi tiếp sau khi bấm). Thanh gãy (hết lượt): thanh gãy đôi rơi khỏi tay. |
| 3 | Nhặt thanh dưới đất | **Cúi gập 1,4 s** (D-157), thanh vào tay lúc chạm rồi đứng dậy cầm thanh (hiện thanh biến mất lúc chạm, tay bật về). Sửa hai thanh **B05** (cổng) và **B06** (gần nhà ăn) đang thấp hơn tầm lòng bàn tay 4 cm: có thân thì không hiện lời nhắc (nâng điểm cầm lên mặt thanh hoặc cho nắm bằng đầu ngón). |
| 4 | Ngư đưa thanh | **Thanh hiện thẳng trong nắm tay phải** khi Ngư nói xong (`give_bar`). Ngư chìa tận tay để sau, khi có mô hình Ngư. |
| 11 | Ngoảnh lại khi chạy | **Chân vẫn chạy theo hướng di chuyển, ngực và đầu ngoảnh theo camera** (tối đa ~90°); hiện thân chạy giật lùi (clip phát ngược). Code locomotion (`PlayerBody._tick_locomotion`). |
| 12 | Hết thể lực | **Ngực phập phồng, vai nhô theo nhịp thở** (modifier nhỏ), camera không đổi. |
| 13 | Cảnh chết | Giữ như chương 1–2 (D-151). Không làm gì. |

**Bật thân ở chương 3:** `chapter3.tscn` đặt `protagonist_body = true`. Mọi thứ chương 1–2 đã duyệt chạy y như cũ (T-247 đã thử: không lỗi ở 5 mốc).

**Chưa làm ở card này (chờ đồ hoạ mới, T-248):** dòng 5–10 (chìa khoá, cửa thoát hiểm, bình cứu hoả, báo cháy, chân trên cầu thang, bậu cửa sổ phòng quản lý). Trên cầu thang PS1 chân còn lún hoặc lơ lửng (T-247 dòng 9): biết, để nguyên, ghi trong Handoff.

## 2. Cần đọc
- `tools/reports/T-247-ch3-body-survey.md` (cả báo cáo; ảnh `art_source/graphics_upgrade/protagonist/previews/t247/` `b1`–`b4`, `c5`).
- `game/scripts/player/iron_bar_weapon.gd`, `player.gd` (`give_bar`, `bar_weapon`), `game/scripts/interaction/iron_bar.gd`, `game/scenes/interaction/iron_bar.tscn`, `chapter3_director.gd` (`_place_bars`, `_settle_bars`, `give_bar` ở vườn hoa).
- `game/scripts/player/player_body.gd` (`take_item`, `_tick_locomotion`), `body_lean_modifier.gd`, `protagonist.gd`.
- Chương 2 làm thế nào: `docs/tasks/T-243-protagonist-chapter2.md`, `docs/tasks/T-245-ch2-playtest-fixes.md`. Luật chương 1–2 đã duyệt (T-239, T-241, T-242, D-157, D-162): giữ nguyên.

## 3. Kiểm
- Test mới trong `game/tests/player/` (chương 3 thật, `auto_start = false`, đo trên xương đã dựng như T-243/T-245): thanh trong bàn tay phải khi cầm, khi chạy, khi vung; vung 0,55 s không khoá di chuyển; trúng/hụt như cũ; gãy thì rơi; nhặt cúi 1,4 s, đủ 7 thanh với tới được khi có thân (kể cả B05, B06); Ngư đưa thanh vào tay; chạy mà ngoảnh 180° thì chân không chạy ngược; thở dốc không đổi camera.
- Test cũ chương 3 (`test_ch3_*`, `test_ch2_4_hand_targets.gd`) và chương 1–2 vẫn đạt.
- Ảnh 3–5 khung mỗi việc (góc mắt và góc ngoài) vào `art_source/graphics_upgrade/protagonist/previews/t249/`, tự xem lại.
- Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit, theo luật Lượt Godot.
- **Không chạy bot, không đo FPS** (chủ dự án chưa cho phép; integrator hỏi khi merge). Ghi trong Handoff chỗ nghi nặng.

## 4. Được phép sửa
- `game/scripts/player/` (`player_body.gd`, `iron_bar_weapon.gd`, `player.gd` phần thanh sắt, modifier mới), `game/scripts/interaction/iron_bar.gd`, `game/scenes/interaction/iron_bar.tscn`, `game/scenes/main/chapter3.tscn` (chỉ `protagonist_body`), chỗ đặt B05/B06 (`chapter3_director.gd` `_place_bars`/`_settle_bars` hoặc anchor trong `game/scenes/levels/campus/`), test mới trong `game/tests/player/`.
- Mô hình thanh sắt: script Blender trong `art_source/graphics_upgrade/protagonist/iron_bar/`, glb trong `game/assets/models/graphics_pilot/protagonist/` (≤ 5000 tam giác, vật liệu CC0 ghi CREDITS).
- Card này (Checklist, Handoff).

## 5. Không được
- Đổi luật, thời gian, độ khó chương 3 (số lần đập, tầm, sức bền, thời gian vung).
- Sửa chương 1, 2, 4 ngoài phần dùng chung của thân (phải giữ test của chúng đạt); sửa âm thanh (lane E); STATUS, DECISIONS.
- Chạy bot, đo FPS, tiêu credit Tripo.
- Commit log, video, `anh_chup_sua_loi/`, `game/_probe_tmp/`.

## Checklist
- [ ] Bật thân chương 3
- [ ] Mô hình thanh sắt Blender, cầm trong tay phải (dòng 1)
- [ ] Vung bổ chéo, gãy rơi khỏi tay (dòng 2)
- [ ] Nhặt cúi 1,4 s, B05/B06 với được (dòng 3)
- [ ] Ngư đưa thanh vào tay (dòng 4)
- [ ] Ngoảnh lại khi chạy (dòng 11), thở dốc (dòng 12)
- [ ] Test mới, test cũ đạt; ảnh `previews/t249/`
- [ ] Full test, check; push nhánh; Handoff

## Handoff
### 12/11/2026 — HARU (dừng 20:03, hết hạn mức) rồi integrator (Fable 5.2, dừng vì gần hết hạn mức)
**Chưa xong. Code chưa chạy lần nào (chưa biên dịch, chưa test).** Nhánh `lane-b/T-249-protagonist-chapter3-bar`, commit WIP mới nhất ở đầu nhánh.

**Đã có trên nhánh**
- HARU (`963a664`): mô hình thanh sắt `game/assets/models/graphics_pilot/protagonist/iron_bar.glb` (script `art_source/graphics_upgrade/protagonist/iron_bar/build_iron_bar.py`: ống thép gỉ 0,85 m, 7 xương `Bar0…Bar6` để uốn, hai nửa gãy `HalfGrip`, `HalfTip`); dáng tay `game/scripts/player/bar_hand.gd` (`FIST`, `HOOK`, `BAR_IN_FIST`, `BAR_IN_HOOK`, sinh từ `bar_grip.py`); `breath_modifier.gd`, `torso_turn_modifier.gd`; `iron_bar_weapon.gd` (mô hình mới, `make_model`, `bend`, `wear`, `drop`, gọi `hand.swing_bar`); `iron_bar.gd` (`rest_on`, chờ tay rồi mới `queue_free`).
- Integrator (commit WIP sau đó), **viết xong nhưng chưa chạy**:
  - `player_body.gd` (cuối file, mục "T-249"): `_tick_bar` (thanh trong nắm tay phải, tư thế sẵn sàng `BAR_READY`, vung `BAR_SWING` 0,55 s không khoá di chuyển, gãy `_break_bar` rơi hai nửa), `_place_bar` (đặt thanh theo tay đã dựng), nhặt thanh (`_bar_reach`, `_bar_hook`, `_on_bar_picked`: móc bằng đầu ngón rồi lăn vào nắm tay), `swing_bar`, `_tick_breath` (thở dốc khi `player.exhausted`), ngoảnh lại khi chạy trong `_tick_locomotion` (`_back_side`, `_look_chest`, `_look_head`, `BACK_*`), `can_handle` (đang cầm thanh thì không nhón giấy), `_torso` và `_breath` thêm trong `_build_modifiers`.
  - `iron_bar.gd`: `hand_target()` dời `HandTarget` về đầu thanh bên phải người với (`_side`), `grip_frame()`; `iron_bar.tscn`: `grip = 2` (HOOK, lấy bằng đầu ngón: sửa B05/B06 thiếu 4 cm).

**Việc còn lại, theo thứ tự**
1. Import rồi biên dịch: `pwsh tools/test.ps1 -Filter test_ch3_gameplay` (lượt Godot). Sửa lỗi cú pháp/kiểu nếu có. Cần kiểm: `EventBus.bar_picked` có đúng một tham số; `IronBarWeapon.halves()` trả node có `global_transform` đúng (xem cây node của `iron_bar.glb`).
2. `chapter3_director.gd` `_settle_bars`: gọi `bar.rest_on(hit.position.y)` thay cho `+ 0.05`, tia dò kéo xuống dưới mốc 0,3 m (B05, B06 không trúng mặt đất). Rồi sửa giới hạn độ cao trong `game/tests/player/test_ch2_4_hand_targets.gd` (`_bar_height_limits`, và `"iron_bar": [HandTarget.Grip.GRIP, false]` → `HOOK`) theo số in `T231_BAR`.
3. `game/scenes/main/chapter3.tscn`: `protagonist_body = true`.
4. Cảnh thử trong `game/_probe_tmp/` (không commit): chương 3 thật, `auto_start = false`, `player.give_bar(8)`, chụp góc mắt và góc ngoài: đứng, đi, chạy, vung (8 khung), gãy, nhặt B01…B06, chạy ngoảnh lại (S + chạy), thở dốc. Chỉnh hằng số `BAR_READY`, `BAR_SWING`, `BACK_*`, `BREATH_*` theo ảnh. **Chỗ cần nhìn kỹ:** khuỷu tay khi vung (IK không có pole khi không `acting`), thanh có xuyên thân hay camera không, góc mắt có thấy đầu thanh không, thân quay lưng khi ngoảnh lại có lộ cổ trong góc mắt không.
5. Test mới `game/tests/player/test_t249_chapter3_bar.gd` theo card mục 3; test cũ `test_ch3_*`, `test_chapter3`, `test_ch3_ui`, `test_ch3_audio`, `test_ch2_4_hand_targets`, `test_protagonist_*`, `test_t24*` phải đạt.
6. Ảnh `art_source/graphics_upgrade/protagonist/previews/t249/`, CREDITS cho thanh sắt (tự dựng, không tải texture), full test, check, Handoff, push.

**Quyết định kỹ thuật đã chọn (báo chủ dự án khi bàn giao)**
- Tư thế cầm: thanh **chếch lên phía trước ở tư thế sẵn sàng** (nắm tay trước hông phải) để góc mắt thấy đầu thanh và độ cong; không buông dọc chân như chữ trong bảng T-247 (hai ý đó không cùng lúc được). Đổi bằng `BAR_READY`.
- Đang cầm thanh mà gặp giấy: đọc tại chỗ như khi không có thân (không nhón lên). Chương 3 không có chỗ nào vừa có thanh vừa có giấy.
- Đang làm việc khác bằng tay (1 giây) thì không vung được (`IronBarWeapon.swing` trả `false`).
- Nhặt thanh khi tay đang có thanh: thanh trong tay thẳng lại (thanh mới), không có động tác đổi thanh.

**Chưa kiểm:** tất cả. Không chạy bot, không đo FPS.

