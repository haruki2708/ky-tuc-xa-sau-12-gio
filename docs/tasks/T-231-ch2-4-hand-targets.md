# T-231 — Điểm đặt tay (`HandTarget`) cho đồ dùng được trong chương 2–4
- Lane: A (Gameplay) | Trạng thái: todo | Agent: tài khoản GPT lane A (D-139)
- Nhánh: `lane-a/T-231-ch2-4-hand-targets` từ `origin/main` mới nhất.
- Quyết định giao: **D-141** (chủ dự án duyệt 07/11). Tiếp nối T-228 (chương 1, D-140).
- Phụ thuộc: T-228 (cách đặt marker, test mẫu `game/tests/player/test_ch1_hand_targets.gd`), D-140 (`Interactable.hand_target()` bỏ qua marker của Interactable lồng bên trong).

## Bối cảnh
- Chương 1 đã có `HandTarget` cho 22 đồ (T-228). Bước tiếp theo của nhân vật chính có thân (T-220 bước 5, T-227) là đưa thân vào cả 4 chương. Mọi đồ dùng tay của chương 2–4 cần có điểm đặt tay trước.
- Bản chơi chưa có thân, nên thêm marker **không đổi gì** khi chơi hiện nay.
- Đồ tương tác chương 2–4 nằm ở 3 nơi, **quyền sửa khác nhau**:
  1. **Scene và script của lane A** (`game/scenes/interaction/`, `game/scripts/interaction/`): director chương tạo ra. Ví dụ đã thấy: chương 2 `carry_item.tscn` (giẻ, khăn, áo), `shower_screen.tscn` (lau màn), `stuck_door.tscn`, `shower_stall.tscn`, `shower_choice.tscn`, `gag_spot.tscn`; chương 3 `iron_bar.tscn`; chương 4 `bed_slat.tscn`, `fake_search_spot.tscn`; cùng `readable.tscn` và các scene chương 1 nếu chương 2–4 dùng lại. **Lane A gắn marker.**
  2. **`Ch3Use` của core** (`game/scripts/core/ch3_use.gd`, director tạo bằng code): chương 3 `Use_FireKey`, `Use_FireDoor`, `Use_Extinguisher2F`, báo cháy tầng 1; chương 4 `Use_BackDoor` và các `Use_*` khác. **Lane A không sửa core**: kiểm kê và đề xuất chỗ đặt tay, kiểu nắm cho từng cái trong Handoff. Integrator gắn.
  3. **Scene level của lane B** (`game/scenes/levels/`, ví dụ cửa phòng `room_door`, bệnh viện): **lane A không sửa**. Kiểm kê và đề xuất như mục 2.

## Việc cần làm
1. **Kiểm kê** đồ tương tác của chương 2, 3, 4: đọc `chapter2_director.gd`, `chapter3_director.gd`, `chapter4_director.gd`, scene `scenes/main/chapter2.tscn`…`chapter4.tscn`, `campus`, `hospital_room` (đọc, không sửa). Ghi bảng vào Handoff: chương, tên, scene/script, thuộc nhóm 1/2/3 ở trên, nơi đặt (anchor), dùng tay hay không, kiểu nắm, chỗ đặt.
2. **Gắn `HandTarget` cho nhóm 1**, theo chú thích đầu `hand_target.gd` và cách T-228 đã làm:
   - đồ cầm lên (giẻ, khăn, áo, thanh sắt): kiểu nắm hợp lý (GRIP cả bàn cho thanh sắt, PINCH hoặc GRIP cho vải), ghi lý do;
   - lau màn tắm: bàn tay áp lên mặt màn, ghi kiểu nắm và lý do;
   - giấy, thẻ: như T-228 (PINCH, `pick_up = true`, đặt theo `size`);
   - đồ một scene dùng nhiều chỗ: kiểm marker đúng ở **từng chỗ** chương đặt nó;
   - nếu cần đặt khác nhau theo chỗ, ưu tiên một thuộc tính `@export` hoặc tính từ khối va chạm, **tránh mã cứng theo tên chỗ** (góp ý ở Review T-228).
3. **Không gắn** (ghi trong bảng): giường, chỗ nấp, bịt miệng (`bunk_spot`, `hide_spot`, `gag_spot`: leo, nằm, nấp, bịt miệng là phần thân của T-227 bước sau), vùng đứng như `shower_stall`, `StoryTrigger`, xác sống và nhân vật. Đồ chỉ đứng vào hay nhìn vào, không chạm tay, cũng không gắn; ghi lý do.
4. **Đề xuất cho nhóm 2 và 3** (mục "Yêu cầu thay đổi" trong Handoff): mỗi đồ một dòng gồm đường dẫn node, vị trí marker (local của node đó), kiểu nắm, `pick_up`, lý do.
5. **Test mới** `game/tests/player/test_ch2_4_hand_targets.gd`, theo mẫu `test_ch1_hand_targets.gd`:
   - mỗi đồ nhóm 1 "dùng tay" có đúng một `HandTarget`, đúng `grip` và `pick_up`, kiểm **ở vị trí thật chương đặt** (instance chương, `auto_start = false`, như test T-228);
   - marker trong hoặc sát (≤ 5 cm) khối va chạm của chính đồ đó, cao 0,2–1,9 m so với sàn nơi đặt. Đồ nào cần ngoại lệ thì ghi rõ trong test và Handoff, **hỏi chủ dự án** như T-228 đã làm, không tự nới giới hạn chung;
   - đồ trong bảng "không gắn" vẫn trả `hand_target() == null`;
   - người chơi không có thân vẫn dùng mọi đồ như cũ (test chương 2–4 cũ đạt).

## Được phép sửa
- `game/scenes/interaction/*.tscn` của đồ nhóm 1: chỉ thêm node `HandTarget`.
- `game/scripts/interaction/*.gd` của đồ nhóm 1: chỉ phần tạo hoặc đặt `HandTarget`.
- `game/tests/player/test_ch2_4_hand_targets.gd` (mới).
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `player.gd`, `player_body.gd`, `hand_target.gd`, `door_handles.gd`, core (`game/scripts/core/`, kể cả `ch3_use.gd`, director), scene level (`game/scenes/levels/`), scene chương (`game/scenes/main/`), cảnh thử `graphics_pilot/`.
- Không đổi luật, lời thoại, thời gian, cách chơi; không đổi khối va chạm, vùng bấm của đồ.
- Không chạy bot, không đo FPS, không tiêu credit Tripo.

## Checklist hoàn thành
- [ ] Bảng kiểm kê đủ đồ chương 2, 3, 4 trong Handoff, chia nhóm 1/2/3
- [ ] `HandTarget` cho mọi đồ nhóm 1 dùng tay, đúng kiểu nắm
- [ ] Đề xuất vị trí, kiểu nắm cho nhóm 2 và 3 trong "Yêu cầu thay đổi"
- [ ] `test_ch2_4_hand_targets.gd` đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot, `AGENTS.md` mục 4)
- [ ] Handoff trung thực, có commit hash

## Cách kiểm tra
- Khi đang làm: `pwsh tools/test.ps1 -Filter hand_targets`. Full test và check trước khi commit.
- Integrator đọc bảng, gắn marker nhóm 2 vào core theo đề xuất; chụp ảnh tay chạm khi đưa thân vào chương.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
