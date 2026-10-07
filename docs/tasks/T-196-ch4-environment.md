# T-196 — Chương 4: thư viện 3 tầng, đường về nhà B, phòng 407 cuối, phòng bệnh viện
- Lane: B (Môi trường và 3D; lane B đã có lại token 2026-10-07, prompt `docs/handoff/lane-b.md` §1; nếu lại hết token thì phiên Claude Code web làm thay theo `docs/handoff/web.md`) | Trạng thái: done | Agent:
- Nhánh: `lane-b/T-196-ch4-environment`
- Phụ thuộc: T-183, T-189, T-190, T-192, T-194 (**đọc "Hợp đồng chung" và bảng anchor**), `docs/design/CH4_DESIGN.md`, D-054, D-067, `art_source/campus/README.md`.
- **Hạn đề xuất:** 2026-10-10. Làm theo thứ tự ưu tiên ở mục "Thứ tự", phần thấp có thể giữ đơn giản.

## Việc
### 1. Thư viện (`Campus/Library`, vỏ có sẵn ở `shells.tscn`: x 45–85, z 195–225, 3 tầng, cao 3,3 m/tầng)
- **Nội thất 3 tầng** (từ vỏ): tầng 1 sảnh và **quầy mượn sách** (`Counter`, có **thanh sắt** nhặt được: dùng `iron_bar.tscn`), **bản đồ trường** (`MapBoard`) treo tường; tầng 2 phòng đọc với **bàn đọc** (`ReadingDesk`, sổ quy tắc đặt ở đây); tầng 3 kho sách cổ. Cầu thang trong thư viện đi được giữa 3 tầng.
- **Bản đồ trường:** vẽ nhà A và nhà B bằng **vết khoanh bút đỏ mờ** (D-067 câu 2, vết cũ của trường). Dùng texture thủ tục hoặc `Label3D`/`MeshInstance3D`, không chữ tên trường (tên trường vẫn để ngỏ).
- **Cửa chính bị chặn** bằng bàn ghế từ bên trong (không mở được); **cửa phụ phía sau** (`BackDoor`) theo **hợp đồng cửa phá** (`room` = `library_back`, `is_open`, `set_open`, `blocker`, group `room_doors`), nối với đường đi trong thư viện. Ngoài cửa phụ: `LibraryZombieSpawn/S01…S06`.
- Chỗ cho jumpscare: `LibrarianSeat` (ghế sau quầy), `ScareShelf3F`, `ThrownBook3F`.
- Đường đi (navigation) trong thư viện nối với đường ngoài trời; xác ngoài cửa phụ **tới được** cửa để đập.

### 2. Đường tới thư viện và về nhà B
- `Start_split` ở cửa phía tây nhà ăn; đường từ nhà ăn tới thư viện **đi được** (đã có đại lộ và đường nhánh từ T-183, T-192); thêm vài chỗ cản/đồ rải nếu thiếu.
- `Start_return` ở sảnh tầng 1 nhà B; cửa sổ phòng quản lý vẫn là lối vào (T-183).
- 10 điểm **`StairCrowd/*`** trên cầu thang chính (3 mỗi chiếu nghỉ tầng 1–3, 1 ở tầng 4), cách nhau đủ để người chơi lách (chiếu nghỉ rộng 2,4 m).

### 3. Phòng 407 (đã có từ chương 1–2)
- **Vạt giường lật được** ở giường 1, 2, 4 (`Room407/Slat1/2/4` đặt trên vạt; nệm và đồ lộn xộn đã có). Dưới mỗi vạt có **chữ loang** (texture, không cần đọc được; D hiển thị mảnh phiếu ở UI).
- 3 điểm tìm giả `FakeLocker`, `FakeCeiling` (tấm trần thạch cao), `FakeVent` (ô thông gió, thêm nếu chưa có).
- **Cửa 407 theo hợp đồng cửa phá** (`Room407/Door`, `room` = `407`): ngoài hành lang xác đập; **mô hình hư hại** theo `door_damage_changed(&"407", fraction)`: nứt (từ 0,3), lỗ thủng (từ 0,6), bàn tay xác thò qua lỗ (từ 0,8). Dùng 3 mô hình/lớp hiển thị ẩn hiện, lắng nghe `EventBus`; không cần logic khác.
- `Start_407` trong phòng cạnh cửa. **Đừng làm hỏng** luồng chương 1–2 ở phòng 407 (test hiện có phải PASS).

### 4. Phòng bệnh viện (`res://scenes/levels/hospital/hospital_room.tscn`)
- Phòng nhỏ khoảng 5 × 6 m, sáng trắng: `Bed_Trung` ở giữa, `Bed_Nhat`, `Bed_Ngu` hai bên (mỗi giường có `Card` là `Marker3D`; lane D gắn thẻ tên), giá truyền dịch, máy theo dõi (`MonitorAudio`), cửa sổ, tủ đầu giường, hai chỗ cho y tá (`Nurse1`, `Nurse2`), `Camera_Wake`. Mô hình Minh Nhật và Ngư nằm giường dùng lại `nhat.tscn`, `ngu.tscn` ở tư thế nằm (hoặc khối đơn giản có chăn).
- Nhỏ nhưng **sạch, sáng** khác hẳn đêm của chương 1–3.

## Thứ tự ưu tiên (nếu thiếu thời gian)
1. Phòng 407 (vạt giường, cửa phá, mô hình hư hại) và `Start_*`.
2. Thư viện tầng 1–2 (quầy, bàn đọc, bản đồ, cửa phụ).
3. Cầu thang `StairCrowd`, phòng bệnh viện.
4. Thư viện tầng 3 (kho sách) và chi tiết thêm.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`, card này (Handoff). **Không** sửa code core, lane A, D, E.

**Cảnh báo dựng map:** giữ các thay đổi đã có trên `main` (T-187…T-192, D-062, D-065); xem `art_source/campus/README.md` (mục T-192) về `t192.py`; không chạy `build_campus.py` riêng nếu chưa chắc nó không ghi đè sửa tay.

## Test (`game/tests/levels/`)
Cửa phụ thư viện và cửa 407 đóng thì chặn capsule, mở thì thông; có đường đi từ `Start_split` → thư viện (cửa phụ) → `Start_return` → `Start_407`; mỗi `StairCrowd/*` trên cầu thang đi được; `Slat1/2/4` đủ gần giường; `hospital_room.tscn` nạp được và có đủ node tên ở trên; ngân sách tam giác.

## Checklist hoàn thành
- [x] 407: vạt giường, 3 chỗ giả, cửa phá với 3 mức hư hại, `Start_407`
- [x] Thư viện: quầy, bàn đọc, bản đồ khoanh mờ, cửa phụ phá được, 3 chỗ hù dọa; vào được từ ngoài
- [x] `Start_*` đủ 4, `StairCrowd/*` đủ 10, `LibraryZombieSpawn/S01…S06`
- [x] Phòng bệnh viện đủ node theo hợp đồng
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS (hoặc "không có test FAIL mới" trên Linux); ảnh: integrator chụp khi review
- [x] Handoff: tọa độ anchor, đường dẫn node, số tam giác

## Handoff (agent điền)

### 2026-10-07 — Lane B / Codex

- Commit triển khai **`2efc64f`**, đã push `lane-b/T-196-ch4-environment`; gốc `origin/main` tại `ff17fb4`.
- Đã dựng thư viện đủ 3 tầng trong đúng footprint x45–85, z195–225; sàn y−9,9/−6,6/−3,3. Có cầu thang đi được, quầy và `Counter/IronBar` dùng scene sẵn có, bàn đọc/sách, kho sách, bản đồ hai vòng bút đỏ mờ không tên trường, bàn ghế chặn cửa chính và cửa phụ. Chỉ thay subtree vỏ Library cũ; giữ các vỏ khác.
- Nhà ăn trước đó chưa có lối tây: thay riêng `Canteen/Side170` bằng `Canteen/WestExit`, mở khoảng z39,5–41,5 tại x170, nối navigation ngoài trời. Giữ đồ đạc T-192 và lối kho cũ. Không chạy generator campus cũ, không sửa BuildingB/Floor4 hay cấu hình đêm D-065.
- 407 có ba vạt lật, texture chữ loang 128px, ba điểm giả/tấm trần/ô gió; cửa có lớp nứt/lỗ thủng/tay. Phòng bệnh viện 5×6 m sáng trắng, đủ hợp đồng; người nằm dùng khối có chăn theo phương án đơn giản được card cho phép.
- Nguồn dựng, cách chạy lại và API chi tiết: [README](../../art_source/ch4_environment/README.md). Tất cả tọa độ anchor: [manifest](../../art_source/ch4_environment/manifest.json). Texture mới qua LFS; nguồn/CC0 và khai báo Codex trong `game/assets/textures/ch4/CREDITS.md`.

### Đường dẫn và tọa độ ghép

**Gốc anchor là `Campus/Anchors/Ch4/`, kể cả nhánh `Room407/`**, theo bảng T-194. Tọa độ dưới đây là world khi Campus/Floor4 ở transform mặc định; đơn vị m.

| Anchor | (x, y, z) |
|---|---|
| `Start_split` | (167, −9.9, 40.5) |
| `Start_library` | (65, −9.9, 223) |
| `Start_return` | (4, −9.9, 2) |
| `Start_407` | (32, 0.03, −0.85) |
| `Counter` | (58, −9, 206) |
| `MapBoard` | (45.25, −8.1, 211) |
| `ReadingDesk` | (58, −5.71, 216) |
| `LibrarianSeat` | (57, −9.44, 207.5) |
| `ScareShelf3F` | (57, −3.3, 218) |
| `ThrownBook3F` | (73, −1.1, 218) |
| `Room407/Slat1`, `Slat2`, `Slat4` | (30.65, 1.18, −3); (30.65, 0.41, −3); (37.35, 1.18, −2.7) |
| `Room407/FakeLocker`, `FakeCeiling`, `FakeVent` | (30.65, 1.1, −0.45); (33, 2.92, −2); (37.8, 2.35, −1) |

- `LibraryZombieSpawn/S01…S03`: x=62/65/68, y=−9.9, z=228; `S04…S06` cùng x/y, z=231.
- `StairCrowd/L1_01…03`, `L2_01…03`, `L3_01…03`: (x,z) lần lượt (−4,2.8), (−2.5,1.4), (−1,2.8); y lần lượt −9.9/−6.6/−3.3 theo tầng. `L4_01`=(−4,0,2.8). Giữ chiếu nghỉ 4 m hiện có, không thu về kích thước cũ trong mô tả card.
- Cửa thư viện thật: **`Campus/Library/BackDoor`**, (65,−9.9,225), `room=&"library_back"`. Cửa 407 adapter: **`Campus/Anchors/Ch4/Room407/Door`**, bản lề (32.44,0.01,0), `room=&"407"`. Cả hai có `is_open`, `set_open(bool)`, `Blocker`, `blocker`, group `room_doors`.
- Campus và Floor4 là hai node anh em; giữ `Campus.floor4_path=../Floor4` hoặc gán đường dẫn đúng. **Đợi một lượt deferred sau khi thêm Campus** rồi core gắn ZombieDoor cho adapter 407. Khi mở riêng subscene không có Campus/Floor4, adapter không kích hoạt collider/group.
- Adapter 407 điều khiển cửa cũ `Floor4/Door407`; giữ tương tác/chốt/khe cửa/anchor tờ luật. Không gắn ZombieDoor đồng thời vào cả adapter và cửa cũ. Khi tháo Campus, collider và hiển thị cửa cũ được trả lại.
- `EventBus.door_damage_changed(&"407", fraction)`: nứt ≥0.3, lỗ thật trên mô hình ≥0.6, tay ≥0.8. `set_damage_fraction(0)` reset; collider vẫn chặn đến khi `set_open(true)`. Không có đếm độ bền/luật chết trong Lane B.
- `bed_slat_flipped(1/2/4)` lật đúng vạt, hé mặt chữ bằng cách ẩn riêng màn giường tương ứng. `Slat*/set_flipped(false)` hoặc tháo scene khôi phục màn; Lane A gắn tương tác giữ E, Lane D hiển thị giấy đọc được.
- Bệnh viện: `res://scenes/levels/hospital/hospital_room.tscn`, root `HospitalRoom`. Bed_Trung/Nhat/Ngu ở x=0/−1.65/1.65, y=z=0; mỗi `Card` local=(0,0.88,1.08). Nurse1/2=(−0.72/0.72,0,1.9); MonitorAudio=(0,1.2,−1.85); Camera_Wake=(0,0.94,−0.64), góc (24°,180°,0°). `set_companions_visible(bool)` chỉ đổi hai node Patient của Nhật/Ngư, không quyết định kết.

### Kiểm tra và số tam giác

- Windows / Godot 4.7.2, bản cuối:
  ```text
  pwsh tools/test.ps1
  RESULT: 607 passed, 0 failed
  pwsh tools/check.ps1
  RESULT: check 0 error(s)
  ```
- 6 test mới kiểm tra capsule đóng/mở/phá cửa, đường từ cả bốn Start và ba tầng thư viện, cửa tây nhà ăn/quầy/bàn đọc, sáu điểm xác tới ngoài cửa đóng, 10 điểm cầu thang, vị trí vạt, tín hiệu/reset, tháo adapter trả lại 407 cũ, bệnh viện và ngân sách. Test T-190 vẫn kiểm tra đủ 22 cửa cũ, lọc riêng hai cửa mới.
- Lần full đầu có 607 assertion PASS nhưng wrapper FAIL do subscene anchor thiếu Campus. Đã sửa kiểm tra null; smoke test riêng `RESULT: 1 passed, 0 failed`, sau đó chạy lại **toàn bộ** suite đạt kết quả cuối ở trên. Log local: `build/t196/test-full.log`, `check.log`, `test-smoke.log`.
- Đếm mesh kể cả lớp ẩn, không tính polygon navigation: Library **8016**, Ch4 anchors/visual **342**, HospitalRoom **828**, WestExit **60** tam giác. Mỗi kệ **516**, bản đồ **708**, quầy gồm thanh sắt **84**, cửa hư hại **204**, vạt **14**, giường bệnh gồm người/chăn **132**; đều trong ngân sách từng đồ vật.
- Đã xem 9 ảnh dựng tĩnh, lần chụp cuối không lỗi engine: `build/t196/review/`. Scene tái chụp: `res://scenes/levels/ch4/review.tscn` (chỉ chạy trực tiếp có renderer, không tự chạy trong smoke/headless). Ảnh chương 4 đã ghép do integrator chụp khi review theo card. Chưa chạy bot/chơi trọn chương 4, vì scene/director chương 4 chưa có trong base này.

### Còn lại / yêu cầu thay đổi / bị chặn

- Không còn hạng mục môi trường của Lane B bỏ dở; không cần mở rộng phạm vi file, không có blocker.
- Phần ghép đã thuộc T-194/195/197/198: core tạo scene/director và điều khiển hai cửa/đợt xác/checkpoint/kết; A gắn BedSlat/SearchSpot/ZombieDoor theo anchor; D gắn giấy và thẻ giường; E gắn âm thanh. Không tự sửa các file của các lane đó, không thêm luật hay lời truyện.

## Review (integrator)

### 2026-10-07 — Claude (integrator): **duyệt, đã merge**
- Đúng card: thư viện 3 tầng trong vỏ cũ (quầy có thanh sắt, bàn đọc, kho sách, bản đồ khoanh đỏ mờ, cửa phụ phá được), lối ra phía tây nhà ăn, anchor `Ch4/*` đủ bảng T-194 (manifest), 3 vạt giường và cửa 407 có 3 mức hư hại (lớp trung gian điều khiển cửa cũ, không làm hỏng chương 1–3), phòng bệnh viện đủ node. 6 test mới; ngân sách tam giác ổn.
- **Core đã nối:** đọc anchor thật thay cho điểm thay tạm; gắn `ZombieDoor` vào lớp trung gian 407 và cửa phụ thư viện; xác ở `LibraryZombieSpawn` và `StairCrowd`; thẻ giường của lane D gắn vào `Bed_*/Card` và `set_companions_visible` theo kết.
- **Lỗ hổng của card core (không phải lỗi lane B):** cửa phụ là lối vào duy nhất của thư viện nhưng hợp đồng "cửa phá được" không cho người chơi mở. Core thêm chỗ dùng E mở/đóng cửa phụ (`PROMPT_CH4_BACK_DOOR`), vỡ rồi thì thôi.
- **Ảnh:** chưa chụp lại sau khi ghép; sẽ xem khi chủ dự án chơi thử.
