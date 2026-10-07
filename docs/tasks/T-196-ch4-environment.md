# T-196 — Chương 4: thư viện 3 tầng, đường về nhà B, phòng 407 cuối, phòng bệnh viện
- Lane: B (Môi trường và 3D; lane B đã có lại token 2026-10-07, prompt `docs/handoff/lane-b.md` §1; nếu lại hết token thì phiên Claude Code web làm thay theo `docs/handoff/web.md`) | Trạng thái: todo | Agent:
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
- [ ] 407: vạt giường, 3 chỗ giả, cửa phá với 3 mức hư hại, `Start_407`
- [ ] Thư viện: quầy, bàn đọc, bản đồ khoanh mờ, cửa phụ phá được, 3 chỗ hù dọa; vào được từ ngoài
- [ ] `Start_*` đủ 4, `StairCrowd/*` đủ 10, `LibraryZombieSpawn/S01…S06`
- [ ] Phòng bệnh viện đủ node theo hợp đồng
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS (hoặc "không có test FAIL mới" trên Linux); ảnh: integrator chụp khi review
- [ ] Handoff: tọa độ anchor, đường dẫn node, số tam giác

## Handoff (agent điền)

## Review (integrator)
