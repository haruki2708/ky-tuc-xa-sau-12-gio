# T-201 — Chương 1: luật sống mới ở cảnh quản lý, quản lý bước vào và đi tới chỗ trốn, gõ tường theo nhịp (core)
- Lane: core, **Claude Code trên web (Sonnet 5.5) làm thay** (D-069) | Trạng thái: todo | Agent:
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
- [ ] Luật sống mới: giường 1/2/4 + tắt đèn; không nín thở; đứng dậy là chết
- [ ] Quản lý từ hành lang tới, mở cửa chậm, đứng ngưỡng cửa rồi bước vào
- [ ] Trốn ngoài giường: quản lý đi tới tận nơi rồi giết
- [ ] Gõ tường theo nhịp [3, 1], tờ giấy của Khoa
- [ ] Menu F9 và profile bot khớp
- [ ] Test trên cảnh thật; chương 2–4 không hỏng
- [ ] `tools/test.ps1` (hoặc chạy trực tiếp Godot trên Linux) hai lượt trước và sau; `tools/check.ps1` PASS
- [ ] Hướng dẫn chơi thử cập nhật

## Handoff (agent điền)

## Review (integrator)
