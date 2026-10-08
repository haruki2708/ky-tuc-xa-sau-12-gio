# T-202 — Chương 1: nằm giường dễ bằng E, quản lý mở cửa bước vào, đi tới chỗ trốn
- Lane: A (Gameplay) | Trạng thái: done | Agent: lane A
- Nhánh: `lane-a/T-202-ch1-bunks-manager`
- Phụ thuộc: D-069 (góp ý chương 1, 2026-10-08). Làm song song với T-203 (lane B) và T-201 (core, Claude Code trên web).
- **Hạn đề xuất:** 2026-10-09.

## Bối cảnh (integrator đo trên cảnh thật `res://scenes/main/chapter1.tscn`)
- Vùng bấm "Nằm lên giường" (`res://scenes/interaction/bunk_spot.tscn`, `BunkSpot`, `CollisionShape3D` hộp **0,8 × 0,5 × 0,2 m**, đặt cao 0,7 m) quá nhỏ. Đứng ở lối đi, ngắm vào giường:
  - giường 2 (Việt, trái dưới): trúng **19/36** lần; lần trượt trúng khung giường tầng trên (`Board1.14`) hoặc vùng "lật nệm Phúc";
  - giường 3 (Trung, phải dưới): **0/36**, bị hộp va chạm của mô hình giường che (lane B sửa ở T-203);
  - giường 4 (Đạt, phải trên): **24/36**.
- Quản lý (`res://scripts/entity/manager.gd`): `kill_player()` lao 5 m/s trong 0,65 giây. Trung trốn ở ban công (cách khoảng 5 m) thì ông ta vồ từ ngưỡng cửa, không đi tới.

## Việc
1. **Vùng nằm giường (`bunk_spot.tscn`, `bunk_spot.gd`):** vùng bấm phủ **cả mặt giường nhìn từ lối đi**: suốt chiều dài giường (khoảng 1,9 m), từ mặt nệm lên khoảng 0,5 m, chồm ra ngoài mép giường một chút để tia ngắm chạm vùng này **trước** khung giường. Giữ `View`, `Exit`, `prompt_key`, các hàm `HideSpot`. Hướng giường: core đặt `BunkSpot` theo anchor `Room407/Anchors/Bunks/Bunk1…4` (dọc tường trái và phải, trục dài theo z); kiểm lại chiều của hộp cho đúng.
   - Nếu vùng của giường 2 chồng lên vùng "lật nệm Phúc" (`SearchPhucMattress`, giường 1): ngắm vào nệm tầng dưới phải ra "Nằm lên giường", ngắm vào nệm tầng trên ra "Lật nệm".
2. **Quản lý đi tới chỗ trốn (`manager.gd`):** thêm `hunt(target: Node3D)`: đi theo đường đi (navigation) tới gần `target` (trong khoảng 1,2 m), quay mặt, rồi `kill_player()`. Phát `arrived` như `walk_to`. Đường đi tới ban công và nhà vệ sinh của 407 do lane B bảo đảm (T-203); nếu không tới được trong 12 giây thì vẫn `kill_player()` tại chỗ đứng gần nhất.
3. **Quản lý mở cửa (`manager.gd`):** `open_door(door: Node, seconds: float = 0.0)`: phát động tác với tay mở cửa (hoạt cảnh có sẵn hoặc đơn giản: đứng yên, tay đưa ra) và gọi `door.set_open(true, seconds)` nếu cửa nhận tham số thứ hai (lane B thêm ở T-203), không thì `set_open(true)`. Phát tín hiệu `door_opened` khi cửa mở xong.
4. **Test (`game/tests/player/`):**
   - **Tia ngắm** trên cảnh thật `chapter1.tscn`: đứng ở lối đi cạnh từng giường (ít nhất 6 chỗ đứng, nhìn vào nệm), tia của người chơi trúng `BunkSpot` của đúng giường **ít nhất 80%** số lần, và bấm E thì nằm xuống. Cả **4 giường**. (Giường 3 chỉ đạt sau khi T-203 merge; trước đó ghi trong Handoff con số đo được.)
   - `hunt`: quản lý đi từ cửa 407 tới một điểm ở ban công và một điểm trong nhà vệ sinh, rồi giết.
   - `open_door(door, 1.5)`: cửa mở dần, `door_opened` phát sau khoảng 1,5 giây.

## Được phép sửa
`game/scenes/interaction/`, `game/scripts/interaction/`, `game/scenes/entity/`, `game/scripts/entity/`, `game/scenes/player/`, `game/scripts/player/`, `game/tests/player/`, card này (Handoff). Thêm key `PROMPT_*` vào `strings.csv` nếu cần.

## Checklist hoàn thành
- [ ] Vùng nằm giường phủ cả giường; test tia ngắm 4 giường (giường 3 sau T-203)
- [ ] `hunt(target)` đi tới ban công, nhà vệ sinh rồi giết
- [x] `open_door(door, seconds)` và `door_opened`
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: API mới cho core, con số tia ngắm đo được

## Handoff (agent điền)

### Lane A — 2026-10-09

Đã push mã `0f4c465` lên `lane-a/T-202-ch1-bunks-manager`, base `c42c165`.
**Blocked: kiểm chứng đầy đủ trên cảnh thật còn chờ T-203** (va chạm giường 3, navmesh tới ban công/nhà vệ sinh, cửa nhận thời lượng). Phần API Lane A và test độc lập đã xong; core nối luồng ở T-201. Hai checklist đầu giữ chưa đạt vì các phụ thuộc này.

**Đã làm**

- `bunk_spot.tscn`: hộp chọn rộng 1,15 m, cao 0,5 m, dài theo z 1,9 m, bắt đầu tại mặt nệm. Với tầng trên, nâng đáy vùng chọn thêm 0,05 m để tia hướng xuống tầng dưới đi qua bên dưới. Giữ `View`, `Exit`, prompt và API `HideSpot`.
- `SearchSpot` có `spot_id = phuc_mattress`: chỉnh riêng hộp chọn tại mép nệm trên thành 0,16 × 0,15 × 0,2 m, nâng tâm 0,075 m. Ngắm nệm dưới và vùng lật nệm trên ra hai prompt đúng; không đổi anchor hay nội dung nhiệm vụ.
- Cảnh chương 2–4 giữ kích thước vùng nằm cũ. Xác định chương qua director của cảnh sở hữu, vì `GameState.chapter` lúc dựng cảnh có thể còn là chương trước. Điều này giữ tương tác lật vạt chương 4 hoạt động (regression được bộ test phát hiện và đã sửa).
- Quản lý có trạng thái `HUNTING`, `OPENING`; dùng tay trái của model hiện có hoặc tay của hình thay thế để mở cửa. Không sửa model lane B.
- Thêm 5 test trên cảnh thật và 6 test quản lý. Sửa phép đo trong test pursuer cũ: tính tốc độ theo số bước vật lý thực tế, thay vì coi 60 lượt chờ xen kẽ physics/process là đúng một giây. Hai lượt trước đã lộ lỗi thời gian này; không đổi code pursuer.

**API cho core T-201**

- `manager.hunt(target: Node3D)`: theo vị trí hiện tại của target bằng `NavigationAgent3D`, giữ tốc độ `speed` hiện có (mặc định 0,9 m/s), kiểm tra lại đích mỗi 0,25 giây. Trong phạm vi ngang 1,2 m và không bị tường che: quay mặt, phát `arrived`, rồi gọi `kill_player()`. `hunt` gán target làm `player` của quản lý.
- Sau 12 giây chưa tới: gọi `kill_player()` từ vị trí đã đi tới, không dịch chuyển tức thời. **Timeout không phát `arrived`**; core theo dõi `EventBus.player_caught(&"manager")` để kết thúc cả nhánh tới nơi và timeout. 12 giây là thời gian đi tìm, trước pha lao/vồ hiện có. Không gọi `kill_player()` ngay sau `hunt`, vì sẽ hủy pha đi tìm.
- `manager.open_door(door: Node, seconds: float = 0.0)`: dừng đi, quay về cửa, đưa tay ra; dò chữ ký `set_open`. Cửa nhận hai tham số được gọi `set_open(true, seconds)` và `door_opened` phát khi hết thời lượng. Cửa cũ chỉ nhận một tham số mở ngay và hoàn tất bất đồng bộ ở frame xử lý kế tiếp. Có thể gọi rồi `await manager.door_opened`.
- Pause giữ nguyên tiến độ đi tìm/mở cửa. `stop()` hoặc lệnh mới hủy hành vi và callback cũ; target/cửa bị giải phóng cũng hủy an toàn. Callback `arrived` được phép đổi lệnh mà không gây thêm một lần giết.

**Số đo trên `res://scenes/main/chapter1.tscn`, giữ nguyên va chạm của base**

Mỗi giường: 6 vị trí đứng ở lối đi (cách tâm giường theo x 0,9/1,2 m, lệch z −0,6/0/+0,6 m), mỗi vị trí ngắm 6 điểm dọc nệm; mắt cao 1,63 m, dùng `Player/Head/Camera3D/InteractRay` thật với tầm 2 m. Mỗi giường ngắm trúng được kiểm tra bấm E và `player_bed` đúng số.

| Giường | Trúng vùng nằm | Bấm E trên cảnh thật |
|---|---:|---|
| 1 | 36/36 (100%) | PASS |
| 2 | 36/36 (100%) | PASS |
| 3 | 0/36 (0%) | Chưa ngắm tới được: cả 36 tia bị `Floor4/Room407/BunkB/WorldCollision` che |
| 4 | 36/36 (100%) | PASS |

Test riêng vô hiệu hộp cũ **chỉ trong fixture** xác nhận vùng chọn và E của giường 3 hoạt động; không tính kết quả đó thay cho số đo 0/36 bên trên.

`hunt` bắt đầu từ `DOOR_SPOT = (32, 0.05, 0.6)`, cửa 407 và cửa nhà vệ sinh mở:

| Đích | Vị trí trước pha giết khi hết 12 giây | Cách đích theo phương ngang |
|---|---|---:|
| Ban công `(32.8, 0.03, -7.8)` | khoảng `(35.7, 0.001, -3.5)` | 5,19 m |
| Nhà vệ sinh `(36.85, 0.03, -5.6)` | khoảng `(36.5, 0.001, -3.5)` | 2,13 m |

Navmesh chưa phủ hai đích, nên cả hai dùng timeout rồi phát caught đúng một lần. Test với navmesh độc lập xác nhận đi vòng tường, theo target đổi vị trí, tới trong 1,2 m, phát `arrived` rồi mới giết; tường gần không được tính là đã tới nơi.

**Kiểm tra đã chạy**

- `pwsh tools/test.ps1`: **`RESULT: 679 passed, 0 failed`**, exit 0; log `build/T-202-full-verified.log`.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0; log `build/T-202-check-verified.log`.
- Regression chương 4: `RESULT: 10 passed, 0 failed`; pursuer sau sửa phép đo: `RESULT: 16 passed, 0 failed`.
- Test cửa có tween độc lập xác nhận góc trung gian, tay đưa ra, pause, signal sau khoảng 1,5 giây và cửa mở hết khi phát signal. Cửa 407 trên base chỉ có `set_open(value)`, nên test cảnh thật mới xác nhận nhánh tương thích mở ngay.
- Bộ test mặc định ghi rõ các dòng `T-202 DEPENDENCY`; chúng không chứng nhận các phụ thuộc đã đạt. Khi hộp kín giường cũ không còn hoặc navmesh đã phủ đích, test tự bắt buộc kết quả tương ứng. Sau T-203, chạy chế độ bắt buộc toàn bộ bằng Godot: `--headless --path game res://tests/run_tests.tscn -- --filter=ch1_bunks_manager --t202-integration` (dùng APPDATA tạm dưới `build/`, như `tools/test.ps1`). Chế độ này cũng yêu cầu cửa 407 hỗ trợ thời lượng.
- `git diff --check` sạch. Không chơi thử thủ công trọn chương 1 sau ghép; chưa xác nhận hình ảnh/nhịp mở cửa trên bản T-203.

**Yêu cầu thay đổi ngoài phạm vi**

1. **Lane B / T-203:** thay hộp `BunkB/WorldCollision` bằng va chạm khung; giữ anchor để test giường 3 chạy lại với mục tiêu ≥80%.
2. **Lane B / T-203:** mở rộng `Floor4/Room407/ManagerNavigation` và bảo đảm đường vật lý tới hai đích ban công/nhà vệ sinh nêu trên.
3. **Lane B / T-203:** thêm `Door407.set_open(value, seconds)`; ghép rồi kiểm tra mở thật 1,5 giây với `manager.open_door`.
4. **Core / T-201:** nối các API mới vào luồng quản lý, lý do chết và luật sống đã duyệt; chạy lại chế độ integration sau ghép A/B. Lane A không sửa director, input, luật chơi hay tài liệu của lane khác.

## Review (integrator)

### 2026-10-09 — Claude (integrator, Opus): **duyệt, đã merge**
- Đúng card, làm kỹ: vùng nằm giường 1,15 × 0,5 × 1,9 m, vùng "lật nệm Phúc" tách riêng (hai prompt đúng), chương 2–4 giữ vùng cũ; `hunt(target)` theo lưới đường đi, tới trong 1,2 m mới giết, hết 12 giây thì vồ tại chỗ; `open_door(door, seconds)` và `door_opened`; chế độ test `--t202-integration` rất có ích khi ghép.
- **Sau khi ghép A, B và T-201** (chế độ bắt buộc): giường 1, 2, 4 trúng **36/36**; săn ở ban công và nhà vệ sinh PASS; cửa mở thật 1,5 giây PASS. **Giường 3: 18/36**: từ chỗ đứng cách 0,9 m, tia bị thanh chắn bên của giường tầng trên (`BunkB/WorldCollision/Side_1_11_-0_43`, cao 1,11 m) chặn; đứng 1,2 m thì trúng hết. Trả về lane B (T-203), không phải lỗi của lane A.
