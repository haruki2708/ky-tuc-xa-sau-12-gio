# T-140 — Đánh bóng tương tác và lối đi của thực thể
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
- Nhánh: `lane-a/T-140-interaction-chase-polish`
- Phụ thuộc: T-129, T-134 (done), T-136 (done). Đọc mục Review của `docs/tasks/T-134-pursuer-gaze.md` và Handoff phần 2 của `docs/tasks/T-136-segments-3-5.md`.

## Mục tiêu
Ba chỗ nhỏ lộ ra khi ghép đợt 2 và chơi thử:
- chốt cửa im lặng không làm gì khi cửa đang mở, nên lúc bị đuổi người chơi không hiểu vì sao không chốt được;
- integrator phải "hack" vùng chọn của giấy dán cửa;
- thực thể không đi qua được cửa nhà vệ sinh, nên truy đuổi 2 phải bắt đầu ở hành lang thay vì từ gương.

## Được phép sửa
`game/scenes/player/`, `game/scenes/interaction/`, `game/scenes/entity/`, `game/scripts/player/`, `game/scripts/interaction/`, `game/scripts/entity/`, `game/tests/player/`

## Yêu cầu
1. **Chốt cửa (`door_latch.gd`):**
   - khi cửa đang mở, lời nhắc đổi thành "Đóng cửa trước" (`PROMPT_CLOSE_DOOR_FIRST`, thêm vào `strings.csv`, đủ vi và en);
   - bấm E lúc đó phát tiếng lạch cạch nhỏ (dùng lại `door_latch.ogg` nhỏ hơn và pitch khác), không chốt;
   - đóng cửa xong thì lời nhắc trở lại "Chốt cửa" ngay, không phải nhìn đi chỗ khác rồi nhìn lại.
2. **Giấy đọc được (`readable.gd`):** thêm `@export var pick_depth: float` (mặc định giữ như hiện tại). Vùng chọn kéo dài ra phía trước mặt giấy (local +Z) đúng bằng `pick_depth`. `game/scenes/main/main.gd` hiện có hàm `_extend_pick_depth` làm việc này; integrator sẽ chuyển sang export sau khi merge.
3. **Thực thể đi theo lộ trình (`pursuer.gd`):**
   - `start_chase(target, spawn, route: PackedVector3Array = PackedVector3Array())`: đi lần lượt qua các điểm `route` (bán kính tới điểm khoảng 0,4 m) rồi mới đuổi thẳng mục tiêu;
   - trong lúc đi lộ trình vẫn kiểm tra bắt người và vùng an toàn như hiện tại;
   - mục đích: truy đuổi 2 xuất phát từ trước gương, đi qua cửa nhà vệ sinh (khoảng x 3,1, z −0,5 rồi z 0,6) ra hành lang. Integrator sẽ truyền lộ trình.
   - Giữ nguyên chữ ký cũ (gọi không có `route` vẫn chạy như trước).
4. **Test `game/tests/player/`:**
   - chốt không chốt được khi cửa mở, có lời nhắc và âm;
   - `pick_depth` đổi kích thước vùng chọn;
   - thực thể đi qua một khe cửa 1 m trong phòng thử nhờ `route`, và vẫn bắt được người đứng yên sau khe;
   - các test cũ của T-134 vẫn PASS.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: API mới, cách thử bằng tay, phần chưa thử

## Handoff (agent điền)
