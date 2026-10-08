# T-203 — Chương 1: giường tầng ngắm được, cửa 407 mở chậm, đường tới ban công, khe ổ điện tường 406
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-203-ch1-room407-fixes`
- Phụ thuộc: D-069 (góp ý chương 1, 2026-10-08). Làm song song với T-202 (lane A) và T-201 (core, Claude Code trên web).
- **Hạn đề xuất:** 2026-10-09.

## Bối cảnh (integrator đo trên cảnh thật `res://scenes/main/chapter1.tscn`)
- `Floor4/Room407/BunkB` (`res://assets/models/room407/bunk_trung.glb`, giường Trung dưới và Đạt trên) có `WorldCollision` là **một hộp liền 0,9 × 1,7 × 2,0 m** bọc cả giường tầng. Tia ngắm của người chơi chạm hộp này trước nên **không nằm được giường Trung** (0/36 lần ngắm trúng) và giường Đạt chỉ 24/36.
- `BunkA` (Phúc trên, Việt dưới): khung giường tầng trên (`Board1.14`) che một phần nệm tầng dưới khi nhìn từ lối đi.
- Cửa 407 (`res://scenes/levels/floor4/door407.gd`): `set_open(value)` xoay `Pivot` ngay lập tức. Chủ dự án muốn thấy quản lý mở cửa rồi bước vào.

## Việc
1. **Va chạm giường tầng:** `BunkB` (và `BunkA` nếu cần) chỉ va chạm ở **khung** (cột, thanh đầu giường, ván giường), không bọc kín khoảng trống phía trên nệm ở phía lối đi. Người chơi vẫn không đi xuyên giường. Không đổi vị trí giường, anchor `Room407/Anchors/Bunks/*` và các chỗ lục đồ (`SearchPhucMattress`, tủ, sọt rác).
2. **Cửa 407 mở chậm:** `set_open(value: bool, seconds: float = 0.0)`: `seconds > 0` thì xoay dần (tween) trong `seconds`; `0` giữ như cũ (mọi chỗ gọi cũ không đổi). Va chạm cửa theo góc mở. Giữ `rattle`, `stop_rattle`, chốt cửa (`DoorLatch407`) và `sync_door_anchor`.
3. **Đường đi trong 407:** lưới đường đi của phòng (`room_407.tscn`) phủ tới **ban công** và **trong nhà vệ sinh**, để quản lý (lane A, `hunt`) đi được từ cửa tới đó.
4. **Khe ổ điện tường 406:** trên tường trái của 407 (chung với 406), gần `WallKnock406` (khoảng x 30,1; y 0,3; z −1,6), thêm một **ổ điện âm tường** nhỏ có khe hở, và anchor `Floor4/Room407/Anchors/KhoaNoteSlot` (Marker3D, đặt ngay trước mặt ổ điện trên sàn hoặc chân tường, nơi mẩu giấy của Khoa rơi ra). Core đặt tờ giấy `ch1_khoa_note` tại anchor này.
5. **Test (`game/tests/levels/`):**
   - tia từ lối đi tới vùng nằm của giường 3 và 4 không bị hộp va chạm che (dùng điểm giữa mặt nệm làm đích);
   - người chơi (CharacterBody3D thật) vẫn không đi xuyên giường tầng;
   - `set_open(true, 1.5)`: góc cửa đổi dần, xong sau khoảng 1,5 giây; `set_open(true)` vẫn tức thì;
   - đường đi từ cửa 407 tới ban công và tới nhà vệ sinh có trên lưới;
   - có anchor `KhoaNoteSlot`.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`, card này (Handoff).

## Checklist hoàn thành
- [ ] Giường tầng chỉ va chạm ở khung; giường 3, 4 ngắm được
- [ ] Cửa 407 `set_open(value, seconds)`
- [ ] Lưới đường đi tới ban công và nhà vệ sinh
- [ ] Ổ điện có khe và anchor `KhoaNoteSlot`
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: đường dẫn node, tọa độ anchor, ảnh chụp giường và ổ điện

## Handoff (agent điền)

## Review (integrator)
