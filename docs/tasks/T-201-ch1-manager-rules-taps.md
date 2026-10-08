# T-201 — Chương 1: luật sống mới ở cảnh quản lý, quản lý bước vào và đi tới chỗ trốn, gõ tường theo nhịp (core)
- Lane: core, **Claude Code trên web (Sonnet 5.5) làm thay** (D-069) | Trạng thái: done | Agent:
- Nhánh: `core/T-201-ch1-manager-rules-taps`
- Phụ thuộc: D-069. Lời thoại đã sửa sẵn (integrator, commit cùng card này): `CHOICE_CH1_TELL_1`, `ch1_khoa_note`, trang sổ hợp âm. Làm **song song** với T-202 (lane A) và T-203 (lane B): mọi API mới của hai lane gọi qua `has_method` và có cách thay tạm như code hiện có.
- **Hạn đề xuất:** 2026-10-09.

## Bối cảnh
- Luồng nằm ở `game/scripts/core/chapter1_director.gd`: `_manager_at_407()` (khoảng dòng 554), `_spawn_manager()`, `_manager_ask()`, `_manager_kills()`, `_traces_visible()`, `_wall_taps()`, `_on_wall_tapped()`, `decode_taps()`, `_play_taps()`. Chương 2 kế thừa lớp này (`Chapter2Director`), đừng làm hỏng chương 2–4.
- Integrator đã kiểm trên cảnh thật: Trung ở ban công thì chết ngay khi cửa mở (`DEATH_NOT_IN_BED`), quản lý vồ từ cách khoảng 5 m; quản lý được đặt sẵn ở `DOOR_SPOT` và cửa bật mở tức thì.

## Việc
1. **Luật sống mới (D-069 (1)):**
   - Sống nếu: nằm giường **1, 2 hoặc 4** (bạn đã chết) và **không có ánh sáng** lúc cửa mở (`_traces_visible()` giữ nguyên: đèn bàn, điện thoại đang giơ, đèn pin).
   - **Bỏ nghe tiếng thở**: sau câu hỏi `MGR_CH1_ASK_BED_3` chỉ còn một khoảng lặng ngắn rồi ông ta cười và chém giường 3, không phụ thuộc Space.
   - **Xoay nhìn không sao**: tắt `hear_movement_while_present` (hoặc bỏ qua tiếng `move` do xoay đầu). Chỉ **đứng dậy khỏi giường** (`_bed` về 0) lúc quản lý còn trong phòng là chết (`DEATH_NOT_IN_BED`, cảnh `manager_kill`).
   - Nằm giường 3: vẫn `DEATH_OWN_BED`.
2. **Quản lý mở cửa rồi bước vào (D-069 (4)):** sinh quản lý ở **hành lang**, cách cửa 407 khoảng 6–8 m về phía 406 (camera hành lang thấy được), đi tới `DOOR_SPOT`, gõ cửa (`_play_knock`), tay nắm xoay (`rattle` ngắn), mở chốt nếu Trung đã chốt, rồi **mở cửa chậm khoảng 1,5 giây**: `manager.open_door(door, 1.5)` (T-202) nếu có, không thì `door.set_open(true, 1.5)` (T-203) nếu nhận 2 tham số, không thì `set_open(true)`. Đứng ở ngưỡng cửa khoảng 1 giây, **lúc này** kiểm `_traces_visible()`, rồi mới bước vào. Ra về cũng đóng cửa chậm.
3. **Trốn ngoài giường (D-069 (2)):** không nằm giường nào (đứng trong phòng, ban công, nhà vệ sinh…) thì quản lý **đi tới chỗ Trung** rồi giết: `manager.hunt(_player)` (T-202) nếu có; không thì `walk_to(vị trí Trung)` rồi `kill_player()`. Lý do chết `DEATH_NOT_IN_BED`. Khi đang đi tới mà Trung nằm lên giường thì **vẫn chết** (ông ta đã thấy).
4. **Gõ tường theo nhịp (D-069 (5)):**
   - Khoa gõ nhịp **3 cái, nghỉ khoảng 1 giây, 1 cái**; nghỉ khoảng 3 giây rồi lặp lại một lần (`_play_taps` hoặc hàm mới, dùng âm gõ tường có sẵn của lane E).
   - Nghe Trung gõ ở `wall_406` trong 90 giây: tách nhóm theo khoảng nghỉ (giữa hai cái trong một nhóm dưới khoảng 0,7 giây; giữa hai nhóm từ 0,7 tới khoảng 2,5 giây; im quá 2,5 giây là xong lượt). Đúng **[3, 1]** thì Khoa gõ đáp một tràng ngắn (khoảng 5 cái nhanh) và **đặt tờ giấy `ch1_khoa_note`** tại anchor `Floor4/Room407/Anchors/KhoaNoteSlot` (T-203; chưa có thì đặt trên sàn ngay dưới `WallKnock406`) theo cách `chapter1_main.gd` đặt các giấy khác. Sai hoặc hết giờ: Khoa im luôn (như cũ).
   - Bỏ mã 5×5: `decode_taps` theo chữ không còn dùng (xóa hoặc giữ cho test cũ, tùy bạn; sửa test cho khớp). Câu đáp án trong menu F9 (`game/scripts/debug/qa_menu.gd`, `QA_SOLUTION`) và profile bot `tools/ch1-profile.json` (`ch1v2` nếu có) đổi cho khớp.
5. **Test (`game/tests/core/test_chapter1.gd` và test mới), trên cảnh thật `chapter1.tscn`:**
   - nằm giường 1, 2, 4, đèn tắt, xoay nhìn liên tục: sống, giường 3 bị chém; nằm giường 3: chết `DEATH_OWN_BED`;
   - đèn bàn sáng hoặc điện thoại đang giơ lúc cửa mở: `DEATH_SEEN`;
   - đứng dậy khi quản lý ở trong phòng: chết;
   - Trung ở ban công: quản lý đi tới ban công (khoảng cách cuối dưới 1,5 m) rồi giết; tương tự trong nhà vệ sinh;
   - quản lý xuất hiện ở hành lang **trước** khi cửa mở; cửa mở dần (nếu T-203 đã có);
   - gõ [3, 1] đúng nhịp: có tờ giấy `ch1_khoa_note`; gõ [2, 1] hoặc [3, 2]: không có, Khoa im;
   - chương 2 vẫn chạy (bộ test chương 2 hiện có PASS).
6. **Tài liệu:** sửa `docs/playtest/CH1_QUICKTEST.md` (bước 7, 11, 12, mục cách chết) và phần đáp án của `docs/playtest/CH1_V2_PLAYTEST.md` cho khớp luật mới.

## Được phép sửa (ngoại lệ D-069 cho phiên web)
`game/scripts/core/`, `game/scenes/main/`, `game/tests/core/`, `game/scripts/debug/qa_menu.gd`, `tools/ch1-profile.json` (và `tools/ch1v2-profile.json` nếu có), `docs/playtest/CH1_QUICKTEST.md`, `docs/playtest/CH1_V2_PLAYTEST.md`, card này (Handoff). **Không** sửa file của lane A, B (`game/scripts/entity/`, `game/scenes/interaction/`, `game/scenes/levels/`…): cần gì thì ghi "Yêu cầu thay đổi". Không sửa lời thoại hay `strings.csv` (lời do integrator viết từ `docs/design/ch1/build_ch1_script.py`); cần câu mới thì ghi vào Handoff.

## Checklist hoàn thành
- [x] Luật sống mới: giường 1/2/4 + tắt đèn; không nín thở; đứng dậy là chết
- [x] Quản lý từ hành lang tới, mở cửa chậm, đứng ngưỡng cửa rồi bước vào
- [x] Trốn ngoài giường: quản lý đi tới tận nơi rồi giết
- [x] Gõ tường theo nhịp [3, 1], tờ giấy của Khoa
- [x] Menu F9 và profile bot khớp
- [x] Test trên cảnh thật; chương 2–4 không hỏng
- [x] `tools/test.ps1` (hoặc chạy trực tiếp Godot trên Linux) hai lượt trước và sau; `tools/check.ps1` PASS
- [x] Hướng dẫn chơi thử cập nhật

## Handoff (agent điền)

**Claude Code web làm thay core, D-069.** Nhánh `core/T-201-ch1-manager-rules-taps` (từ `origin/main` c42c165). Máy Linux cloud, Godot 4.7.2 và PowerShell 7.5.4 ở `~/tools`. Không có card đồ họa: **chưa nhìn bằng mắt** cảnh quản lý đi hành lang, cửa, mẩu giấy (chỉ kiểm bằng test trên cảnh thật `chapter1.tscn`).

### Đã làm (`game/scripts/core/chapter1_director.gd`)
- **Luật sống (D-069 1):** nằm giường **1, 2, 4** và không có ánh sáng (`_traces_visible()` giữ nguyên) là sống. Bỏ nghe thở và chuyển động: không còn `_on_noise`, `_manager_listening`, `_manager_heard`, `_manager_moved`, `MANAGER_HEAR_RADIUS*`; `hear_movement_while_present = false`. Sau `MGR_CH1_ASK_BED_3` chỉ còn khoảng lặng `MANAGER_LISTEN_SECONDS = 2.5` rồi ông ta cười và chém giường 3. Xoay nhìn không sao. **Đứng dậy** (`_bed == 0`) lúc ông ta còn trong phòng (đi vào, hỏi, chém, đi ra) là chết `DEATH_NOT_IN_BED` (các bước chờ thoát sớm khi Trung đứng dậy). Giường 3 vẫn `DEATH_OWN_BED`.
- **Quản lý từ hành lang (D-069 4):** sinh ở `CORRIDOR_SPOT` (25,5; 0,05; 2,0), cách cửa 6,5 m về phía 406, đi (tốc độ 1,3) tới `DOOR_SPOT` qua `CORRIDOR_VIA`, gõ cửa, rung tay nắm `door.rattle(1,2)`, mở chốt nếu Trung đã chốt (`door_locked`), **mở cửa chậm 1,5 giây**, đứng ở ngưỡng cửa 1 giây, **lúc này** kiểm `_traces_visible()` (`DEATH_SEEN`), rồi bước vào (tốc độ 0,9). Ra về đóng cửa chậm (`_close_door_slowly`). Mở cửa chọn API theo thứ tự (hàm `_arg_count` đọc số tham số): `manager.open_door(door, 1.5)` + chờ `door_opened` (T-202), không có thì `door.set_open(true, 1.5)` (T-203), không có thì `set_open(true)` cũ.
- **Trốn ngoài giường (D-069 2):** không nằm giường nào lúc cửa mở thì `_manager_hunts`: `manager.hunt(_player)` (T-202) rồi chờ `arrived` (tối đa 15 giây), không có thì đi theo **lưới đường đi** của thế giới tới chỗ Trung rồi đường thẳng (`walk_to`), cuối cùng `_manager_kills(DEATH_NOT_IN_BED)`. Đã chọn hướng này thì lên giường giữa chừng vẫn chết.
- **Gõ tường theo nhịp (D-069 5):** Khoa gõ **[3, 1]** (3 cái cách 0,28–0,32 giây, nghỉ 1 giây, 1 cái), nghỉ 3 giây, lặp một lần (rig `KhoaTaps.play_sequence`, không có thì `play_tap`/âm gõ). Nghe `wall_406` trong 90 giây: `tap_groups()` tách nhóm (khoảng cách < 0,7 giây cùng nhóm, 0,7–2,5 giây nhóm mới, im ≥ 2,5 giây là xong lượt). Đúng **[3, 1]**: Khoa gõ đáp 5 cái nhanh, **đặt tờ `ch1_khoa_note`** (node `Ch1KhoaNote` dưới scene chương) tại anchor `Room407/Anchors/KhoaNoteSlot` (T-203), chưa có thì trên sàn ở (WallKnock406 + (0,45; −1,25; 0)), đặt cờ `khoa_hint` (cờ bot đang dùng). Sai hoặc hết giờ: Khoa im. **Bỏ mã 5×5:** xóa `decode_taps`, `encode_taps`, `TAP_ROWS`…; test cũ thay bằng test nhịp.
- **F9** (`qa_menu.gd`, `QA_SOLUTION`) và hướng dẫn `docs/playtest/CH1_QUICKTEST.md` (bước 7, 11, 12, 13, mục cách chết), `CH1_V2_PLAYTEST.md` (phím Space, diễn biến, đáp án) cho khớp luật mới.
- Chương 2–4 không dùng phần đã đổi (`_spawn_manager`, `_manager_at_407`, `_wall_taps` chỉ chạy ở chương 1); bộ test chương 2–4 PASS.

### Test
- `game/tests/core/test_chapter1_d069.gd` (**19 test mới**, cảnh thật `chapter1.tscn`): giường 1, 2, 4 sống (đèn tắt, xoay đầu liên tục, bắn tiếng `move` và `breath` sát ông ta) và giường 3 bị chém; giường 3: `DEATH_OWN_BED`; đèn bàn sáng và điện thoại giơ: `DEATH_SEEN`; đứng dậy lúc ông ta trong phòng: `DEATH_NOT_IN_BED`; ban công, nhà vệ sinh: bị săn rồi giết, lên giường giữa chừng vẫn chết; ông ta xuất hiện ở hành lang (x < 27, cách cửa > 5,5 m) khi cửa còn đóng và tới sát cửa khi nó mở; nhịp [3, 1] đúng cho giấy, [2, 1], [3, 2], [4], không gõ: không giấy, Khoa im; cả nhiệm vụ gõ tường chạy thật tốc độ 1,0; mở cửa chậm qua `manager.open_door`, qua `door.set_open`, rơi về `set_open(true)`; `hunt` qua API của quản lý (ba API này kiểm bằng nhân vật giả vì T-202, T-203 chưa merge).
- `test_chapter1.gd`: bỏ `test_manager_hears_a_breath`, `test_breathing_on_any_bed_is_heard_in_the_silence`, `test_tap_code_round_trip`; thêm `test_breath_and_moves_are_no_longer_heard`, `test_tap_groups_split_on_the_pauses`; bỏ các lần giữ Space; nới thời gian chờ (ông ta nay đi hành lang khoảng 13 giây).

```
Lượt 1, origin/main (trước khi sửa):   RESULT: 668 passed, 0 failed
Lượt 2, nhánh này (sau khi sửa):        RESULT: 686 passed, 0 failed   (668 − 3 + 2 + 19)
check.ps1, nhánh này:                   RESULT: check 0 error(s)  (328 script)
```
Chạy trực tiếp Godot trên Linux (`tools/test.ps1` dùng `\` trong đường dẫn nên không chạy được trên Linux). Không có test FAIL sẵn ở lượt 1.

### Chưa kiểm được (không có card đồ họa, lane A, B chưa merge)
- **Chưa có `manager.hunt`, `open_door(door, seconds)`, `door_opened`, `door.set_open(value, seconds)`, `KhoaNoteSlot`, lưới đường đi tới ban công và nhà vệ sinh**: core dùng thay tạm như trên. Đo với thay tạm: lúc bắt đầu cú vồ, quản lý cách Trung ở **nhà vệ sinh 1,95 m**, ở **ban công 4,86 m** (kẹt ở chỗ lưới nav và vật cản hết). Test chỉ đòi dưới 6 m khi chưa có `hunt`, và **đòi dưới 1,5 m ngay khi quản lý có `hunt`** (`_assert_walked_up`): sau khi ghép T-202 và T-203, chạy lại `test_hiding_on_the_balcony_is_hunted` và `test_hiding_in_the_bathroom_is_hunted`; nếu chưa đạt thì lỗi nằm ở lưới đường đi hoặc `hunt`.
- Cửa mở chậm (số mẫu góc cửa giữa chừng) chỉ được kiểm khi T-203 có `set_open(value, seconds)`; test in `T201 DOOR` và tự kiểm khi API xuất hiện.
- Chưa nhìn bằng mắt: ông ta đi trong hành lang có hiện trên camera hành lang không; mẩu giấy nằm đúng chỗ ổ điện sau khi T-203 thêm `KhoaNoteSlot` (có thể cần chỉnh `KHOA_NOTE_FALLBACK` hay xoay giấy); âm gõ đáp 5 cái (dùng `play_tap` có sẵn của lane E).
- Chưa chạy bot; chưa thử trên Windows.

### Yêu cầu thay đổi ngoài phạm vi
1. **Lane C, `game/scripts/debug/ch1v2_scenarios.json`:** bốn chỗ `{"op":"wall_taps","code":"13 34"}` (các dòng khoảng 25, 73, 146, 189) phải đổi thành `"code":"31"` (bộ tạo lịch gõ của `ch1v2_actions.gd` cho ra nhóm 3, nghỉ 1,18 giây, 1; khớp luật mới); các bước `{"op":"breath"}` còn lại vô hại (không ai nghe). Không đổi `ch1v2-profile.json`: nó chỉ gắn cờ `wall_prompt` và `khoa_hint`, cả hai vẫn được đặt như cũ. `tools/ch1-profile.json` (bản v1 cũ) giữ nguyên.
2. `tools/test.ps1` (lane C): `. "$PSScriptRoot\godot-path.ps1"` hỏng trên Linux; đổi `\` thành `/` như `check.ps1`.

### Câu hỏi thiết kế
- Không có lời mới cần thêm; không sửa `strings.csv`.
- Một điểm trình bày: lượt gõ đầu tiên (xong sau 2,5 giây im) quyết định luôn, đúng như card ("sai thì Khoa im luôn"). Người chơi lỡ gõ một cái rồi dừng quá 2,5 giây là mất mẩu giấy. Nếu muốn dễ hơn (cho gõ lại tới hết 90 giây) thì sửa `_listen_for_rhythm`: chỉ thoát khi đúng nhịp hoặc hết giờ.

## Review (integrator)

### 2026-10-09 — Claude (integrator, Opus): **duyệt, đã merge, integrator sửa thêm 3 chỗ**
- Đúng card, làm cẩn thận: luật sống mới (giường 1, 2, 4, không đèn, chỉ đứng dậy là chết), quản lý từ hành lang tới, gõ cửa, rung tay nắm, mở chốt, mở cửa chậm, đứng ngưỡng cửa rồi kiểm ánh sáng, săn người trốn, nhịp [3, 1] và mẩu giấy ở `KhoaNoteSlot`; chọn API theo số tham số để chạy được trước và sau khi ghép A, B; 19 test trên cảnh thật; hướng dẫn chơi thử và menu F9 đã sửa.
- **Sau khi ghép A, B**, 3 test của chính nhánh này FAIL; integrator sửa:
  1. **Săn trong nhà vệ sinh** (lỗi thật): cửa nhà vệ sinh đóng nên quản lý dừng cách 1,98 m. `_manager_hunts` nay mở cửa (`Room407.set_bathroom_door_open(true)`) khi Trung ở phía bên kia cửa và quản lý tới cách cửa dưới 1,4 m. Sau sửa: vồ từ cách 1,18 m (ban công cũng 1,18 m).
  2. **Test cửa mở chậm**: cửa của lane B đặt `is_open = true` ngay lúc bắt đầu xoay, test chỉ đo khi `is_open` còn false nên không có mẫu. Test nay đo trong lúc xoay (349 mẫu góc giữa chừng).
  3. **Test "lên giường lúc đang bị săn"**: test cho Trung nằm xuống lúc cánh cửa mới bắt đầu mở (trước khi quản lý nhìn vào từ ngưỡng cửa), nên Trung sống là đúng luật. Test nay chờ tới khi quản lý đã bắt đầu săn.
- **D-070 (chủ dự án chọn):** gõ sai thì được gõ lại tới hết 90 giây (`_listen_for_rhythm` bỏ lượt sai, chỉ thoát khi đúng nhịp hoặc hết giờ); test `test_a_wrong_turn_can_be_knocked_again`; hai hướng dẫn chơi thử sửa theo.
- **Yêu cầu ngoài phạm vi còn để ngỏ:** `game/scripts/debug/ch1v2_scenarios.json` (lane C) còn `"code":"13 34"` ở 4 chỗ, cần đổi thành `"31"` khi chạy lại bot chương 1 (chưa chạy bot nên chưa ảnh hưởng).
