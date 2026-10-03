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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Handoff: API mới, cách thử bằng tay, phần chưa thử

## Handoff (agent điền)

### Phiên 2026-10-03 — Lane A
- Nền `origin/main`: `7dbce51`. Commit code `7a6ed09` (`T-140: Polish latch feedback, readable picking and pursuer routes`) đã push lên `origin/lane-a/T-140-interaction-chase-polish` trước khi ghi Handoff.
- Chốt cửa: cửa mở hiện `PROMPT_CLOSE_DOOR_FIRST` (vi/en). Bấm tương tác chỉ phát `door_latch.ogg` trên SFX ở −10 dB, pitch 1,15; không đổi trạng thái/flag và không emit `EventBus.interacted`, tránh Main phát thêm âm chốt bình thường. Chốt thành công vẫn dùng signal/cue hiện có, dừng âm thất bại còn đang phát. Lời nhắc cập nhật ngay theo signal tương tác; thay đổi cửa bằng code được đồng bộ ở physics tick kế tiếp. Player nhận thay đổi key trên cùng đối tượng nên không phải nhìn đi chỗ khác. Cửa không có `is_open` vẫn dùng được như trước.
- Giấy: thêm `pick_depth: float = 0.004` (mét), gán trước hoặc sau ready đều được. Collider có kích thước `(size.x, size.y, pick_depth)`, tâm local z = `pick_depth / 2`, kéo từ local z = 0 tới `pick_depth`; mesh vẫn dày 0,004 m. Thay `size` giữ độ sâu đã chọn, mỗi instance có shape riêng. Giá trị dưới 0,001 được chặn ở 0,001 để tránh collider không hợp lệ.
- Thực thể: `start_chase(target: Node3D, spawn: Vector3, route: PackedVector3Array = PackedVector3Array())`. `spawn` và các điểm là tọa độ thế giới tại chân; chuyển động lấy XZ, gravity giữ trên sàn. Route được sao chép; sửa mảng của bên gọi không đổi lượt đuổi đang chạy. Bỏ route hoặc truyền mảng rỗng giữ cách đuổi cũ.
- Đi lần lượt qua điểm, bán kính tới điểm 0,4 m. Nếu hướng tới điểm kế tiếp hoặc mục tiêu còn vướng collider, tiến gần điểm hiện tại hơn trước khi chuyển, tránh cắt góc/mắc tại mép cửa. Khi hết route trở lại đuổi thẳng và men X theo hành vi T-134. Trong route vẫn ưu tiên vùng an toàn, kiểm tra bắt người, pause, settings và âm bước/thở như cũ. `stop_chase()`/bắt được/thoát hủy route; lần gọi mới không giữ điểm cũ.
- Route là đường do integrator bố trí, không phải tìm đường tự động: mỗi đoạn cần đủ rộng cho capsule bán kính 0,3 m. Điểm nằm sau tường kín có thể khiến thực thể mắc lại nhưng không xuyên tường.

### Kiểm tra
- Thêm 6 test (4 route, 2 tương tác/vùng chọn) và mở rộng test chốt hiện có.
- `pwsh tools/test.ps1 -Filter test_pursuer`: **`RESULT: 16 passed, 0 failed`**, exit 0.
- `pwsh tools/test.ps1`: **`RESULT: 224 passed, 0 failed`**, exit 0. Bao gồm toàn bộ test T-134 và test luồng truy đuổi tích hợp hiện có.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. `git diff --cached --check` sạch trước commit code.
- Test vật lý xác nhận đi qua khe 1 m tại x = 3,1 / z = 0 với hai điểm `(3.1, 0, -0.5)`, `(3.1, 0, 0.6)`, không vòng ngoài phòng và bắt được mục tiêu đứng sau khe. Có test thứ tự điểm, điểm trùng/khác cao độ, pause, restart hai tham số, tường kín, bắt người/vùng an toàn trước khi hoàn thành route.
- Test tương tác xác nhận chốt không khóa khi cửa mở, có cue nhỏ/pitch khác, không signal thành công, đủ bản dịch và đổi lời nhắc trên cùng ray focus; ray chạm vùng chọn giấy đã quay, resize và các instance không ảnh hưởng nhau.
- Lượt gameplay đầu: `RESULT: 61 passed, 2 failed`. Một lỗi thật là chuyển từ điểm cuối sang mục tiêu quá sớm ở khe cửa; đã sửa kiểm tra va chạm cả hướng tới mục tiêu. Một lỗi test do so sánh float chính xác; đổi sang dung sai. Các lượt cuối nêu trên đã PASS.

### Cách thử bằng tay / phần chưa thử
1. F6 `res://scenes/interaction/interaction_test.tscn`: mở cửa, nhìn chốt và bấm E; phải hiện “Đóng cửa trước”, nghe lạch cạch nhỏ và cửa vẫn mở. Đóng cửa rồi nhìn chốt để khóa/mở khóa; khi cửa đổi trạng thái bằng code mà giữ ray trên chốt, lời nhắc phải cập nhật. Có thể dùng Remote Inspector đổi `is_open` để kiểm tra giữ nguyên focus.
2. Trong scene thử, đặt `Paper.pick_depth = 0.15` ở Inspector; bật hiển thị collision và kiểm tra collider dài về local +Z, mesh không dày lên. Thay `size` và quay giấy để kiểm tra hướng vùng chọn.
3. Sau khi integrator ghép route vào tầng 4: kích hoạt truy đuổi từ gương, chạy qua cửa nhà vệ sinh; thực thể phải đi qua hai điểm ở khe cửa rồi đuổi ngoài hành lang. Thử đứng lại để bị bắt và chạy vào phòng 407 đã chốt để thoát; kiểm tra Esc/Giảm hù dọa. Scene `pursuer_test.tscn` với P vẫn kiểm tra cách gọi cũ không có route.
- **Chưa thử bằng tay:** chưa F6 bằng chuột/phím thật, chưa nghe cân bằng âm mới, chưa chụp hình. Chưa xác nhận lộ trình mới từ gương trên tầng 4 vì phần gọi route thuộc integrator; test khe cửa dùng phòng thử vật lý. Không coi test headless là đã duyệt cảm giác truy đuổi/âm thanh.

### Yêu cầu thay đổi ngoài phạm vi / chặn
- **Integrator / T-141:** tại `game/scenes/main/main.gd`, thay các lời gọi `_extend_pick_depth(paper)` bằng gán `paper.pick_depth = PAPER_PICK_DEPTH` (0,15), rồi bỏ helper cũ. Export mặc định 0,004 giữ tương thích scene chưa cấu hình.
- **Integrator / T-141:** tại `game/scripts/core/story_director.gd`, đổi truy đuổi 2 sang spawn trước gương và truyền `PackedVector3Array([Vector3(3.1, 0, -0.5), Vector3(3.1, 0, 0.6)])`; xác nhận tọa độ theo bố trí tầng 4 hiện tại, ghép lại thời điểm bắt đầu/kết thúc theo thiết kế đã chốt. Lane A không sửa luồng chơi này.
- Không cần signal/input/settings/plugin mới; chỉ thêm key CSV mà card cho phép. Không sửa file ngoài phạm vi hoặc bản tích hợp. Không có câu hỏi luật chơi/cốt truyện mới.
- Không còn blocker code/test/push. Mạng sandbox và lỗi tạo tiến trình Windows 1326 đã được xử lý bằng cơ chế chạy lệnh ngoài sandbox có cấp quyền; không cài công cụ.
