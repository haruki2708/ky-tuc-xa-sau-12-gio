# T-246: Tủ Việt mở cánh: bỏ "tường vô hình" trước tủ

| Lane: integrator | Nhánh: `integrator/T-246-viet-locker-door-collision` | Trạng thái: merged 12/11/2026 (full test 925/0, check 0); **chủ dự án chơi thử bản `04ddc7d` đạt 13/11** |
|---|---|---|

Chủ dự án chọn làm trước (12/11/2026, sau khi duyệt T-245): "bước 2 làm trước đi". Integrator nhận làm vì việc nhỏ và vừa thấy lỗi khi làm T-245 (card T-245, mục "Thấy thêm, chưa sửa").

## 1. Lỗi
- Cánh tủ Việt vẫn dùng khối va chạm của cánh tủ PS1, rộng 0,6 m. Cánh tủ Tripo nhìn thấy chỉ rộng 0,32 m.
- Khi cánh mở (chương 2 mở sẵn), phần thừa 0,28 m đứng chắn trước tủ mà không nhìn thấy gì.

## 2. Sửa
- `room407.gd` `_fit_viet_locker_door`: khối va chạm của cánh lấy đúng bề rộng cánh Tripo (đo từ lưới, khoảng 0,32 m); vẫn quay theo bản lề như trước.
- Nửa tủ còn lại có cánh đóng liền thân tủ, không mở được. Trước đây khối 0,6 m che luôn nửa này, nay nó có khối riêng `Anchors/VietLocker/FixedDoor` (đứng yên), nên người chơi không lách vào trong thân tủ được.
- Cảnh PS1 (không có đồ Tripo) giữ nguyên cánh 0,6 m.

## 3. Kiểm
- Test mới `test_room407_playable_furnished.gd::test_viet_locker_door_blocks_only_where_it_shows`: khi đóng và khi mở, hai đầu khối va chạm nằm trong cánh nhìn thấy; khối nửa đóng nằm trong thân tủ; hai khối cộng lại khép kín mặt trước như cánh PS1; cảnh PS1 giữ nguyên.
- `test_physics_and_navigation_are_unchanged` miễn cho `FixedDoor` (khối mới, có chủ đích).
- **Kết quả:** full test 925/0, check 0.

## 4. Chủ dự án xem khi chơi
- Chương 2: đi sát trước nửa tủ Việt đang mở, chỗ ngoài mép cánh tủ không còn bị chặn; cánh tủ và nửa tủ đóng vẫn chặn như thường.

## Chơi thử
- 13/11/2026: chủ dự án chơi bản `04ddc7d` (gồm T-244, T-246, T-249, T-251) và xác nhận: "ok tôi đã chơi thử rồi, ổn đấy".
