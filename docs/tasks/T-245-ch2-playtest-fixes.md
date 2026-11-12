# T-245: Sửa sau khi chủ dự án chơi chương 2 (tay cầm điện thoại trong gương, giẻ, áo và ổ khoá thật)

| Lane: integrator (thay B) | Nhánh: `integrator/T-245-ch2-playtest-fixes` | Trạng thái: in-progress (code và mô hình xong, chưa chạy test) |
|---|---|---|

Quyết định: D-163. Model: Fable 5.2 high (chủ dự án chọn).

## 1. Chủ dự án báo gì (12/11/2026, chơi bản `e98ec15`)
1. Soi gương thấy tay cầm điện thoại không tự nhiên: khuỷu tay vểnh lên, cả cánh tay "trông có vẻ gãy" (ảnh `anh_chup_sua_loi/tay_cam_dt.png`).
2. Lấy giẻ ở nhà tắm xong mà giẻ vẫn còn trên giá (ảnh `gie_lau.png`).
3. Ổ khoá và áo của Việt còn là khối PS1: đổi thành đồ thật, integrator tự dựng bằng Blender (không dùng Tripo).

## 2. Nguyên nhân và cách sửa
### 2.1 Tay cầm điện thoại
- **Nguyên nhân:** để máy hiện trong tầm mắt, máy phải nằm trước camera 0,3 m. Tay Trần Trung dài 0,46 m (vai tới cổ tay), vai ở sau camera 0,13 m, nên tay duỗi thẳng hết cỡ, cổ tay bẻ ngược 60–75°.
- **Sửa:** gương (và mọi camera ngoài camera người chơi) vẽ tay trái theo tư thế riêng khi cầm máy: khuỷu khép cạnh sườn, máy trước ngực. Góc nhìn thứ nhất giữ nguyên như đã chốt.
  - `PlayerBody._build_mirror_arm`: bản sao xương tay trái (tiền tố `Mirror`), lưới gương gắn da vào bản sao. `MirrorArmModifier` chép tư thế tay thật sang bản sao mỗi khung hình; khi cầm máy, IK riêng đưa bản sao về tư thế gần thân (`_tick_mirror_arm`, hằng `MIRROR_PHONE_*`, `MIRROR_ELBOW`).
  - Lớp vẽ mới `VIEW_LAYER` (18): lưới góc nhìn thứ nhất và điện thoại trước mắt chỉ camera người chơi vẽ; camera khác bị tắt lớp này (`_on_node_added`, `mirror.gd`). Gương vẽ bản sao điện thoại (`MirrorPhone`) trong bàn tay gương.
- **Số đo sau sửa (tay trong gương):** khuỷu gập 80–90°, cổ tay lệch 12–16° (trước: tay thẳng, cổ tay 60–75°).

### 2.2 Giẻ
- **Nguyên nhân:** miếng giẻ thật (vải lanh mỏng nằm trên nóc giá) có biến mất, nhưng giá treo Tripo là một lưới liền có sẵn khăn xanh và quần đùi; người chơi coi khăn xanh là giẻ.
- **Sửa:** khăn xanh trở thành giẻ. `split_towel_rack.py` cắt khăn xanh khỏi lưới Tripo (`rack_rag.glb`), dựng lại giá treo sạch bằng Blender, giữ quần đùi Tripo (`towel_rack_bare.glb`). Lấy giẻ thì khăn xanh biến mất, tay phải cầm khăn xanh.
  - `room407.gd`: `_seat_rag` dời chỗ lấy xuống khăn; `FOLLOW` gắn `RackRag` vào `Anchors/RagSpot/Model`.
  - `chapter2_director.gd`: vùng nhìn và chỗ tay cầm phủ dọc chiều dài khăn (`_hang_low` có tham số).

### 2.3 Áo của Việt và ổ khoá
- `build_viet_shirt.py` → `viet_shirt.glb`: áo thun kẻ xanh navy/trắng gấp, vải scan CC0 Rough Linen. Nằm trên kệ 0,75 m của tủ Việt (kệ thật của tủ Tripo; áo PS1 lơ lửng ở 0,87 m). `Anchors/ShirtSpot` dời theo (`FURNISHED_ANCHORS`).
- `build_combo_lock.py` → `combo_lock.glb`: ổ khoá số thân đồng **4 bánh số** (mật mã 4 chữ số; khoá PS1 chỉ có 3), hiện 4-7-3-6 (không phải đáp án), còng thép móc qua bản lề khoá trên hai cánh tủ Đạt. Mở khoá: còng nhấc lên và xoay quanh chân dài (`dat_locker.gd`, nút `Shackle/Swing`).
- Giấy nhớ trên tủ Đạt lơ lửng trước cửa 5 cm: dán sát cửa và nhích lên trên bản lề khoá.

## 3. Còn phải làm
1. Sửa test cũ theo thay đổi: `test_room407.gd` (còng khoá), `test_room407_bathroom_fixes.gd` (giẻ), `test_t243_chapter2.gd` (chỗ đứng lấy áo: áo dời tới (0,36; 0,77; −1,44)).
2. Viết test mới T-245: tay gương (lớp vẽ, khuỷu thấp hơn bàn tay, cổ tay < 35°), giẻ mất khi lấy, áo và khoá là mô hình thật.
3. Kiểm chỗ bot lấy áo (`tools/ch2-profile.json` `pickup_shirt` đứng ở (31,0; 0,05; −1,25)): tay có với tới áo ở chỗ mới không; nếu không thì dời chỗ đứng.
4. Full test, check, ảnh trước/sau vào `art_source/graphics_upgrade/protagonist/previews/t245/`, README/CREDITS của `room407_furnished`, D-163, STATUS, merge, build bản chơi.
5. Xóa `game/_probe_tmp/` (không commit).

## 4. Chủ dự án xem khi chơi
- Soi gương nhà tắm và gương dài khi bật đèn pin, khi giơ máy (Q), khi ngồi, khi đi.
- Lấy giẻ (khăn xanh trên giá nhà tắm), lấy áo kẻ trong tủ Việt, nhìn ổ khoá tủ Đạt (chương 1: giải mật mã xem còng mở).
