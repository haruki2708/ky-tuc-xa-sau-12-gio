# T-249 — Thân Trần Trung vào chương 3, phần không phụ thuộc cảnh: thanh sắt, ngoảnh lại khi chạy, thở dốc
- Lane: **HARU làm thay lane B** (lane B hết hạn mức; chủ dự án chọn 12/11) | Trạng thái: **merged 12/11/2026** (full test 939/0, check 0), chờ chủ dự án chơi thử (HARU, integrator, rồi lane B làm) | Agent: tài khoản Claude của HARU, mở trong **`D:\GAME_WORK\lane-b2`** bằng `D:\GAME_WORK\mo_claude_haru_lam_lane_b.cmd`; model đề xuất **Fable 5.2 high**. Chủ dự án tự dán prompt (integrator không điều khiển lane Claude).
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
- [x] Bật thân chương 3
- [x] Mô hình thanh sắt Blender, cầm trong tay phải (dòng 1)
- [x] Vung bổ chéo, gãy rơi khỏi tay (dòng 2)
- [x] Nhặt cúi 1,4 s, B05/B06 với được (dòng 3)
- [x] Ngư đưa thanh vào tay (dòng 4)
- [x] Ngoảnh lại khi chạy (dòng 11), thở dốc (dòng 12)
- [x] Test mới, test cũ đạt; ảnh `previews/t249/`
- [x] Full test, check; push nhánh; Handoff

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

### 12/11/2026 — lane B (Claude, Opus 5.5) làm tiếp và hoàn tất
Nhánh `lane-b/T-249-protagonist-chapter3-bar`, nhận ở `163b38d`. Commit: `872ce07` (lần chạy đầu: bật thân, đặt thanh, cầm đầu gần, cú vung), `14ef7e7` (test mới, thở dốc an toàn), và commit ảnh, CREDITS, README, card này.
Full `pwsh tools/test.ps1`: `RESULT: 939 passed, 0 failed` (12/11, 21:34–22:03, log `build/t249/full_test.log`, không commit). `pwsh tools/check.ps1`: `RESULT: check 0 error(s)` (22:03–22:20, `build/t249/full_check.log`); sau đó đã `git checkout -- game/default_bus_layout.tres`. Chạy ở `14ef7e7`; commit sau chỉ thêm ảnh, CREDITS, README, card.

**Đã làm (theo "Việc còn lại" ở trên):**
1. **Biên dịch:** code HARU và integrator viết biên dịch được ngay, không lỗi kiểu. Cây node `iron_bar.glb` đúng như code đọc (`Armature/Skeleton3D/Bar`, 7 xương `Bar0…Bar6`, `HalfGrip`, `HalfTip`).
2. **Đặt thanh:** `_settle_bars` đặt mọi thanh nằm lên mặt dưới nó (`IronBar.rest_on`), tia dò xuống thêm 0,3 m. Thanh nằm cách mặt đất đúng một bán kính ống (1,45 cm). `test_ch2_4_hand_targets.gd`: thanh sắt kiểu nắm `HOOK`, độ cao 6 thanh của director đo so với mặt ngay dưới thanh (0,008–0,025 m), chương 3 có thân.
3. **Bật thân:** `chapter3.tscn` `protagonist_body = true`; `test_protagonist_chapter1.gd` (chương 1–3 có thân, chương 4 chưa).
4. **Chạy thử trong chương 3 thật** (cảnh tạm `game/_probe_tmp/`, đã xoá; bản sao `build/t249/probe_backup/`, không commit). Sửa theo ảnh:
   - **Cú vung:** lúc chạm, thanh chúi xuống ngang gối trong khi luật trúng đầu ở tầm mắt. Đổi `BAR_SWING`, `BAR_BLOW` (0,5 → 0,46): giơ qua vai phải, chạm khi thanh chếch lên ngang tầm đầu phía trước, rồi vụt xuống bên trái. Thời gian, tầm, luật trúng không đổi.
   - **Nhặt thanh, lỗi thật:** đi tới từ phía một đầu thanh thì `IronBar.hand_target` giữ đầu "bên phải" cũ, có khi là đầu xa (cách vai 1,54 m) nên **không hiện lời nhắc**. Nay đứng dọc theo thanh thì cầm đầu gần; đứng bên cạnh thì vẫn đầu bên phải.
   - **Thở dốc:** `_tick_breath` gọi `bool(null)` khi người chơi giả trong test không có thể lực (lỗi script trong nhóm `protagonist`, `t24`). Nay so `== true`.
   - Không đổi `BAR_READY`, `BACK_*`, `BREATH_*`: ảnh trông ổn.
5. **Test mới** `game/tests/player/test_t249_chapter3_bar.gd`, 7 test, chương 3 thật, đo trên xương đã dựng:
   - thân ở chương 3;
   - thanh trong nắm tay phải khi đứng, chạy, giữa cú vung, sau cú vung (chuôi cách xương bàn tay < 13 cm, đo được 9,6 cm; cách các xương sống > 10 cm; không còn thanh trước camera);
   - vung đúng 0,55 s, đang chạy vẫn chạy (chậm nhất > 2,9 m/s);
   - đập trời trượt (`[false, 8]`), đập đầu trúng và xác tê liệt; lần cuối gãy, hai nửa rơi nằm dưới đất, tay hết thanh;
   - đủ 7 thanh với tới bằng cúi gập (mỗi thanh 30–32 chỗ đứng trên lưới thử, kể cả B05, B06); nhặt B05: cúi 1,4 s, không khom, thanh mới trong tay, thanh dưới đất biến mất;
   - Ngư đưa thanh (vườn hoa, director thật): thanh vào nắm tay;
   - chạy mà camera quay ra sau: clip chạy phát xuôi, thân hướng theo chiều chạy (lệch < 15°), ngực ngoảnh > 20°, đầu thêm; đi lùi giữ như cũ;
   - hết sức: camera lệch < 1 mm, vai nhô > 8 mm; hồi sức thì hết thở dốc.
6. **Nhóm test cũ, chạy riêng đều đạt:** `ch3` 45, `chapter3` 29, `hand_targets` 6, `protagonist` 26, `t24` 35, `t249` 7.

**Số đo chính** (cảnh tạm, chương 3):
| Việc | Đo |
|---|---|
| Cầm, đứng | chuôi cách xương bàn tay 9,6 cm; thanh cách camera 0,65 m; góc mắt thấy đầu thanh |
| Vung | 0,55 s; đang đi vẫn đi 1,25 m trong 0,55 s (2,2 m/s); thanh không gần xương thân nào dưới 16 cm |
| Gãy | trúng, xác tê liệt; hai nửa chạm đất sau khoảng 1,2 s |
| Nhặt | 7/7 thanh với tới (180–212 chỗ đứng mỗi thanh, vòng 0,25–1 m); cúi 1,4 s, đầu hạ còn 0,5 m |
| Ngoảnh lại | thân lệch hướng chạy 0°, ngực 38°, đầu 25°, clip chạy tốc độ +1,14 |
| Thở dốc | camera đứng yên; vai nhô 15 mm mỗi nhịp |

**Ảnh:** `art_source/graphics_upgrade/protagonist/previews/t249/`, 35 tấm 1080p, chương 3 thật, ánh sáng của chương (đêm). Đã tự xem từng tấm.
- `1_` cầm (đứng, cúi nhìn, đi, chạy);
- `2_` vung (6 khung, cả lúc đang đi);
- `3_` gãy;
- `4_` nhặt (5 khung);
- `5_` Ngư đưa;
- `6_` ngoảnh lại khi chạy, đi lùi;
- `7_` thở dốc;
- `x_nen_gia_phong_407_chan_lun.jpg`: xem "Thấy thêm".

**Quyết định kỹ thuật (giữ như integrator đã chọn, báo chủ dự án):**
- Tư thế sẵn sàng: thanh chếch lên phía trước, nắm tay trước hông phải (không buông dọc chân), để góc mắt thấy đầu thanh. Ảnh `1_cam_*`.
- Đang cầm thanh mà gặp giấy: đọc tại chỗ, không nhón lên.
- Đang làm việc khác bằng tay thì không vung được.
- Nhặt thanh khi đang có thanh: thanh trong tay thẳng lại (thanh mới).
- Thêm (lane B): đứng dọc theo thanh thì cầm đầu gần (sửa lỗi không hiện lời nhắc ở trên).

**Thấy thêm, chưa sửa (ngoài phạm vi card):**
- **Tấm nền giả quanh nhà B:** `Floor4/Room407/Furnished/outside/OutsideGround` (80 × 28 m, cảnh nhìn ra cửa sổ phòng 407 ở chương 1–2) nổi cao hơn mặt đất thật của khuôn viên 14 cm (−9,80 so với −9,94) và không có va chạm. Ở chương 3, trong vùng đó (cả đường nội bộ cạnh nhà B):
  - chân người chơi lún vào "mặt đất";
  - thanh **B04** nằm chìm dưới tấm nền, không thấy (từ trước T-249 đã vậy: trước đây thanh ở −9,89, vẫn dưới −9,80).
  
  Ảnh `previews/t249/x_nen_gia_phong_407_chan_lun.jpg` (chụp trước khi sửa chỗ cầm; chỉ để thấy chân lún và thanh không hiện). Đề xuất: ẩn `Furnished/outside` khi có `Campus` (chương 3–4), hoặc hạ xuống −9,94. Việc của lane B nhưng ở cảnh phòng 407, nên chờ chủ dự án hoặc integrator giao.
- **Ngoảnh lại khi chạy:** góc mắt thấy vai áo của chính mình ở cạnh dưới khi nhìn hẳn ra sau (ảnh `6_ngoanh_2_mat`). Không thấy cổ hay gáy.
- Trên cầu thang chân còn lún hoặc lơ lửng (T-247 dòng 9): để nguyên theo card.

**Chưa kiểm:**
- Chưa chơi bằng tay. Mọi kiểm tra là test tự động và ảnh chụp tự động.
- Chưa thử cầm thanh khi đi khom, chạy ngang, lên xuống cầu thang, cầm điện thoại tay trái cùng lúc.
- Không chạy bot, không đo FPS (chủ dự án chưa cho phép). Chỗ nghi nặng: thanh trong tay thêm một lưới có xương (1.532 tam giác) và một modifier ngực, thở; nặng nhất lúc ở sân vận động đông xác.

**Câu hỏi cho chủ dự án:**
1. Tấm nền giả quanh nhà B (ở trên): cho làm một card nhỏ để ẩn nó ở chương 3–4 (đề xuất), hay để sau?
2. Tư thế cầm sẵn sàng (thanh chếch lên phía trước, ảnh `1_cam_*`) có được không, hay muốn buông thanh dọc chân như bảng T-247 (khi đó góc mắt không thấy thanh)?
3. Cho phép chạy bot `ch3` và đo FPS chương 3 có thân khi integrator merge không?

**Yêu cầu thay đổi ngoài phạm vi:** tấm nền giả quanh nhà B (câu hỏi 1).

## Review integrator (12/11/2026)
- Đạt. Lane B làm tiếp phần HARU và integrator để dở: code biên dịch được, lane B nâng cú vung lúc chạm lên ngang đầu, sửa lỗi phần thở dốc với người chơi giả, 7 test mới, 35 ảnh trong chương 3 thật.
- Phạm vi đúng: ngoài file của lane chỉ sửa `chapter3_director.gd` (`_settle_bars`) và `test_ch2_4_hand_targets.gd` như card cho phép, cộng `test_protagonist_chapter1.gd` (chương 3 nay có thân).
- Sau merge: full test 939/0, check 0.
- Câu hỏi của lane B chuyển chủ dự án: (1) ẩn tấm nền giả cao 14 cm quanh nhà B ở chương 3–4 (chân lún, thanh B04 chìm; có từ trước); (2) giữ tư thế cầm thanh chếch lên trước hông hay buông dọc chân; (3) cho phép bot chương 3 và đo FPS.
- Chưa kiểm (lane B ghi): chơi bằng tay; cầm thanh khi khom, trên cầu thang, khi tay trái cầm điện thoại.
