# T-203 — Chương 1: giường tầng ngắm được, cửa 407 mở chậm, đường tới ban công, khe ổ điện tường 406
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent: lane B (1 sửa: Claude làm thay)
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
- [x] Giường tầng chỉ va chạm ở khung; giường 3, 4 ngắm được
- [x] Cửa 407 `set_open(value, seconds)`
- [x] Lưới đường đi tới ban công và nhà vệ sinh
- [x] Ổ điện có khe và anchor `KhoaNoteSlot`
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: đường dẫn node, tọa độ anchor, ảnh chụp giường và ổ điện

## Handoff (agent điền)

### 2026-10-08 — Lane B / Codex, sẵn sàng review

**Đã làm:** commit `9a9843b`, đã push lên `origin/lane-b/T-203-ch1-room407-fixes` trước khi ghi Handoff này.

- `Floor4/Room407/BunkB/WorldCollision`: thay hộp kín bằng 14 hộp theo cột, thanh hai đầu/hai bên và ván giường, bám kích thước nguồn `build_kit.py`. Giữ nguyên GLB, vị trí giường, anchor giường và các chỗ lục đồ. BunkA đã có va chạm khung, test đạt nên không sửa. `.import` đặt tên root tường minh `bunk_trung` để Godot import lại khi nhận thay đổi post-import script, tránh dùng cache hộp cũ.
- `Floor4/Door407.set_open(value: bool, seconds: float = 0.0)`: tween theo physics frame, có easing; va chạm cánh cửa và `Anchors/RulesPaper407` theo góc xoay. Gọi một tham số vẫn tức thì. Đảo chiều tiếp tục từ góc hiện tại; lệnh tức thì hủy tween; giữ `rattle`, `stop_rattle`, chốt cửa và `sync_door_anchor`. `is_open` phản ánh trạng thái đích ngay khi gọi, không phải tín hiệu mở xong; lane A dùng thời lượng để phát `door_opened`.
- `Floor4/Room407/ManagerNavigation`: lưới nối từ cửa qua lối giữa phòng đến ban công và bên trong nhà vệ sinh; khoảng hở kiểm bằng capsule bán kính 0,35 m, cao 1,9 m. Cửa trên tuyến phải mở. Generator: `art_source/room407_fixes/build_fixes.py`.
- `Floor4/Room407/Anchors/KhoaOutlet`: ổ điện thủ tục 108 tam giác, khe hở dưới nắp. Mặt ổ điện khoảng tọa độ thế giới `(30.12, 0.3, -1.8)`; dịch 20 cm theo z so với điểm gợi ý để tủ Việt không che, không dịch tủ.
- `Floor4/Room407/Anchors/KhoaNoteSlot`: **Marker3D**, tọa độ local **`(0.2, 0.015, -1.8)`**, thế giới **`(30.2, 0.015, -1.8)`**, nằm trên sàn trước ổ điện. Core đặt `ch1_khoa_note` tại đây.

**Kiểm tra đã chạy:**

```text
pwsh tools/test.ps1
RESULT: 674 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)

res://scenes/levels/room407/room407_fixes_capture.tscn
RESULT: room407 capture 3 images PASS
```

- Sáu test mới trong `game/tests/levels/test_room407_fixes.gd`: **36/36 tia world** từ lối đi đến giữa mặt nệm của cả bốn giường thông; Player thật đứng/cúi bị khung chặn; cửa đổi góc giữa chừng và hoàn tất sau khoảng 1,5 giây, va chạm/anchor theo cửa; đảo chiều/reset/rattle; đường đi đến ba điểm ban công và hai điểm nhà vệ sinh có đích đúng, capsule quét từng đoạn không chạm vật cản; anchor giấy và khe ổ điện hợp lệ. Đây không phải phép đo tỉ lệ trúng `BunkSpot` của T-202.
- Log cục bộ: `build/t203-tests-final.log`, `build/t203-check.log`, `build/t203-capture.log`. Lượt test tổng trước đó có 673 PASS/1 FAIL do scene đã được cache trước khi dịch ổ điện trong lúc test đang chạy; đã chạy lại toàn bộ trên phiên bản cuối, không còn lỗi.
- Đã mở và xem ba ảnh render: [BunkA](../../art_source/room407_fixes/previews/bunk_a.png), [BunkB](../../art_source/room407_fixes/previews/bunk_b.png), [ổ điện](../../art_source/room407_fixes/previews/khoa_outlet.png). Fixture có ánh sáng kiểm tra bổ sung, không thay ánh sáng game; ảnh đi qua Git LFS. Nguồn/CC0 và cách dựng lại: [CREDITS](../../art_source/room407_fixes/CREDITS.md).

**Còn dở / giới hạn:** không còn việc triển khai trong phạm vi T-203. Chưa chơi tay bản ghép T-201/T-202, chưa xác nhận chuỗi quản lý mở cửa → `hunt` → giết trên bản tích hợp; các phần đó thuộc core/lane A.

**Yêu cầu thay đổi ngoài phạm vi:** integrator/T-201/T-202 cần xử lý mở cửa nhà vệ sinh trước khi quản lý đi qua khi `hunt` mục tiêu bên trong. `Room407/Extension/BathroomDoor` mặc định đóng; mã chương 1 hiện chưa gọi mở (chương 2 có gọi riêng). API sẵn có: `Room407.set_bathroom_door_open(true)`. Test đường đi của T-203 mở cả cửa 407 và cửa nhà vệ sinh trước khi quét capsule. Không tự đổi trạng thái cửa mặc định vì đây là hành vi gameplay dùng chung chương 1–2; core/lane A quyết định thời điểm mở. Các điểm ghép đã giao sẵn: core đặt giấy vào `KhoaNoteSlot`, lane A gọi API cửa hai tham số và kiểm `hunt`/`BunkSpot` sau ghép.

**Chặn:** không bị chặn trong phạm vi lane B. Fetch/checkout LFS, test và render đã chạy được sau khi cấp quyền ngoài sandbox. Có stash `Recovery: partial T-203 checkout after LFS credential failure` lưu checkout dở từ bước chuẩn bị; giữ nguyên để có thể kiểm tra, không áp lại vào nhánh task.

## Review (integrator)

### 2026-10-09 — Claude (integrator, Opus): **đã merge, yêu cầu sửa 1 ý**
- Tốt: va chạm khung 14 hộp thay hộp kín, cửa 407 `set_open(value, seconds)` có tween và đảo chiều, lưới đường đi tới ban công và trong nhà vệ sinh, ổ điện có khe và `KhoaNoteSlot` tại (30,2; 0,015; −1,8). Ảnh xem trước rõ. Core đã mở cửa nhà vệ sinh khi quản lý săn tới sát cửa (theo yêu cầu ngoài phạm vi của lane B).
- **Yêu cầu sửa (chủ dự án chọn trả về lane B):** đứng ở lối đi cách giường Trung 0,9 m, tia ngắm vào nệm giường 3 bị **thanh chắn bên của giường tầng trên** chặn: `Floor4/Room407/BunkB/WorldCollision`, hộp `Side_1_11_-0_43` (0,04 × 0,07 × 1,96 m, tâm (36,92; 1,11; −2,7)). Chế độ bắt buộc của lane A: giường 3 trúng **18/36** (cần ≥ 80%). Sửa: bỏ va chạm của thanh chắn này (người chơi không với tới độ cao đó; khung dưới vẫn chặn người đi xuyên), hoặc hạ/thu nhỏ sao cho tia từ mắt 1,63 m ở cách 0,9 m tới mặt nệm không chạm. Kiểm lại bằng:
  `godot --headless --path game res://tests/run_tests.tscn -- --filter=ch1_bunks_manager --t202-integration` (đặt APPDATA tạm dưới `build/` như `tools/test.ps1`): giường 3 phải ≥ 29/36. Giữ test "không đi xuyên giường" của T-203.
- **Cập nhật cùng ngày: Claude làm thay lane B** (chủ dự án chọn, vì sau khi ghép test tia ngắm của lane A làm cả bộ test FAIL): `room407_import.gd` không tạo va chạm cho hai thanh chắn bên của giường tầng trên (chỉ còn hình); cột, ván và thanh dưới giữ nguyên. `bunk_trung.glb.import` đổi `root_name` thành `bunk_trung_frame` để mọi máy import lại (cùng mẹo lane B đã dùng). Kết quả chế độ bắt buộc: giường 1–4 đều **36/36**; test "không đi xuyên giường" của T-203 PASS. Không còn yêu cầu sửa cho lane B.
