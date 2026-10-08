# T-202 — Chương 1: nằm giường dễ bằng E, quản lý mở cửa bước vào, đi tới chỗ trốn
- Lane: A (Gameplay) | Trạng thái: todo | Agent:
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
- [ ] `open_door(door, seconds)` và `door_opened`
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: API mới cho core, con số tia ngắm đo được

## Handoff (agent điền)

## Review (integrator)
