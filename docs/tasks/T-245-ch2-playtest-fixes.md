# T-245: Sửa sau khi chủ dự án chơi chương 2 (tay cầm điện thoại trong gương, giẻ, áo và ổ khoá thật)

| Lane: integrator (thay B) | Nhánh: `integrator/T-245-ch2-playtest-fixes` | Trạng thái: merged 12/11/2026 (full test 924/0 (lượt full 922/2: hai test cũ còn khẳng định hành vi cũ, sửa xong chạy lại hai file đạt 32/32), check 0); **chủ dự án chơi thử đạt 12/11** |
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
- `build_viet_shirt.py` → `viet_shirt.glb`: áo thun kẻ xanh navy/trắng gấp, vải scan CC0 Rough Linen. Nằm trên **kệ trên của tủ Việt (1,34 m, ngang ngực)**, trong nửa tủ có cánh mở. `Anchors/ShirtSpot` dời theo (`FURNISHED_ANCHORS`).
  - Áo PS1 nằm ở (0,3; 0,87; −1,25): đúng vách ngăn giữa hai nửa tủ Tripo, lơ lửng trên kệ 0,75 m.
  - Đã thử kệ 0,75 m: chỉ với tới từ một ô sàn rộng cỡ bàn tay, và vùng "lục tủ" của chương 1 (cao 1,0 m) chắn giữa mắt và áo nên không hiện gợi ý. Ở kệ 1,34 m: với tới từ một vùng sàn khoảng 30 × 35 cm trước tủ.
- `build_combo_lock.py` → `combo_lock.glb`: ổ khoá số thân đồng **4 bánh số** (mật mã 4 chữ số; khoá PS1 chỉ có 3), hiện 4-7-3-6 (không phải đáp án), còng thép móc qua bản lề khoá trên hai cánh tủ Đạt. Mở khoá: còng nhấc lên và xoay quanh chân dài (`dat_locker.gd`, nút `Shackle/Swing`).
- Giấy nhớ trên tủ Đạt lơ lửng trước cửa 5 cm: dán sát cửa và nhích lên trên bản lề khoá.

## 3. Kiểm
- **Test mới** `game/tests/player/test_t245_ch2_fixes.gd` (3 test, đo trong chương 2 thật):
  - tay gương khi bật đèn pin và khi giơ máy, nhìn ngang / cúi 35° / ngẩng 25°: khuỷu gập 55–125°, cổ tay < 35°, khuỷu thấp hơn vai ≥ 8 cm, bàn tay cách thân < 0,42 m, máy nằm trong bàn tay gương; lớp vẽ đúng (không camera nào ngoài camera người chơi vẽ lớp góc nhìn thứ nhất); cất máy thì hai tay trùng nhau lại;
  - giẻ: chỉ khăn xanh được vẽ làm giẻ, lấy bằng tay thì mất khỏi giá, đặt lại thì hiện, dùng rồi thì mất hẳn;
  - áo nằm trên kệ, trong tủ, lấy được bằng tay từ ≥ 6/24 ô sàn trước tủ; khoá PS1 không còn vẽ, khoá mới áp cửa tủ, còng mở ra và đóng về chỗ.
- **Test cũ sửa theo:** `test_room407.gd` (còng khoá), `test_room407_bathroom_fixes.gd` (giẻ là khăn trên giá), `test_t243_chapter2.gd` (chỗ đứng lấy áo).
- **Kết quả:** full test 924/0 (lượt full 922/2: hai test cũ còn khẳng định hành vi cũ, sửa xong chạy lại hai file đạt 32/32), check 0.
- **Chưa làm:** chưa chạy lại bot chương 2 (bot gọi thẳng `interact` của giẻ/khăn/áo nên không phụ thuộc chỗ đứng; cần chủ dự án cho phép mới chạy). Chưa đo lại FPS (thêm khoảng 18 xương sao chép của tay trái và một điện thoại sao chép; không thêm camera hay đèn).
- **Ảnh trước/sau:** `art_source/graphics_upgrade/protagonist/previews/t245/` (`phone_in_mirror_before_after.jpg`, `rag_shirt_lock_before_after.jpg`, ba ảnh mô hình).

### Thấy thêm, chưa sửa
- Cánh tủ Việt khi mở: khối va chạm vô hình (của tủ PS1) rộng 0,6 m, còn cánh Tripo chỉ rộng 0,32 m, nên trước nửa tủ mở có một đoạn "tường vô hình" 0,28 m. Có từ G3, không thuộc việc này.
- Mảnh giấy PS1 (`Anchors/VietLocker/Paper1`) nằm ở vách ngăn giữa hai nửa tủ.

## 4. Chủ dự án xem khi chơi
- Soi gương nhà tắm và gương dài khi bật đèn pin, khi giơ máy (Q), khi ngồi, khi đi.
- Lấy giẻ (khăn xanh trên giá nhà tắm), lấy áo kẻ trên kệ trên của tủ Việt, nhìn ổ khoá tủ Đạt (chương 1: giải mật mã xem còng mở).

## 5. Kết quả chơi thử
- 12/11/2026: chủ dự án chơi bản `e96056f` và xác nhận đạt ("tôi xác nhận test là ok rồi nhé").
