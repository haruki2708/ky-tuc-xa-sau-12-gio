# T-112 — Dựng greybox tầng 4 nhà B
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-112-floor4-greybox`
- Phụ thuộc: T-102, T-121 (done), T-113 (đã duyệt, D-020). **Đọc kỹ `docs/design/LAYOUT.md`**, đọc thêm `docs/design/RULES.md` mục 5 để biết đồ vật nào dùng ở đoạn nào.
- **Làm trước T-118** (filter PS1): cổng kiểm tra P1 cần tầng chơi được hơn là filter.

## Mục tiêu
Một tầng chơi được, đúng sơ đồ: hành lang ngoài 44 m có lan can, 8 phòng (chỉ 407 vào được), nhà vệ sinh chung, bàn trực, cầu thang khóa. Đặt sẵn mọi vị trí đồ vật và điểm hồi sinh để lane A và integrator gắn gameplay vào.

Đây là **greybox**: dùng bộ kit đã có. Vật nào chưa có mô hình thì dùng hộp hoặc primitive có kích thước đúng, màu gần đúng.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Cấu trúc scene** trong `game/scenes/levels/floor4/`:
   - `floor4.tscn`: scene gốc, instance các phần bên dưới.
   - `corridor.tscn`: hành lang, lan can, dây phơi, đèn, cửa các phòng 401–408 (khóa).
   - `room_407.tscn`: phòng 407 theo `LAYOUT.md` mục 3.
   - `washroom.tscn`: nhà vệ sinh theo mục 4.
   - `duty_desk.tscn`: bàn trực, loa, bảng nội quy, cửa sắt cầu thang.
2. **Kích thước** đúng `LAYOUT.md` (sai lệch ±0,2 m). Trục: hành lang chạy theo X (tây → đông), phòng ở phía bắc (−Z), lan can ở phía nam (+Z). Mặt sàn hành lang ở Y = 0.
3. **Collision:**
   - Mọi tường, sàn, đồ lớn có collision trên layer 1.
   - Lan can có thêm một tường vô hình cao 2 m để không trèo qua được.
   - Cửa 407 mở được (bản lề đúng như mô hình `door`). Các cửa khác cố định.
   - Player (capsule r = 0,3 m, cao 1,75 m) đi được từ cửa 407 tới cuối nhà vệ sinh và tới bàn trực, không bị kẹt.
4. **Sàn:** mọi mặt sàn có metadata `surface = &"tile"` (Review T-105).
5. **Đèn:**
   - 9 đèn tuýp hành lang (mỗi 4 m), đèn chính phòng 407, đèn bàn phòng 407, đèn nhà vệ sinh, đèn bàn trực. Đặt tên rõ: `CorridorLight_401` … `CorridorLight_408`, `CorridorLight_Desk`, `Room407MainLight`, `Room407DeskLamp`…
   - Mỗi đèn tuýp có một `LightHum` (script `res://scripts/audio/light_hum.gd` của lane E, chỉ dùng, không sửa) gán vào đèn đó.
   - Mục tiêu ≥ 60 FPS. Ghi số FPS đo được.
6. **Âm thanh theo khu** (`LAYOUT.md` mục 5): đặt `ReverbZone` và `AmbientZone` (script của lane E) cho phòng 407, hành lang, nhà vệ sinh. Tiếng dế ở phía sân, tiếng nước nhỏ giọt trong nhà vệ sinh, tiếng quạt trong phòng.
7. **Điểm gắn gameplay:** tạo node rỗng (`Marker3D` hoặc `Node3D`) đúng vị trí, **đúng tên** dưới đây, gom trong node `Anchors` của `floor4.tscn`. Lane A và integrator sẽ gắn đồ vật tương tác vào các điểm này:
   - `seg1_start`, `seg2_start`, `seg3_start`, `seg4_start`, `seg5_start` (`LAYOUT.md` mục 6, có hướng quay mặt)
   - `Door407`, `Room407LightSwitch`, `RulesPaper407` (mặt trong cánh cửa), `Locker_Trung` (tủ có hồ sơ phòng), `Phone_Trung`
   - `Bed_Phuc`, `Bed_Viet`, `Bed_Dat`, `Bed_Trung`
   - `Slippers407` (chỗ để dép trước cửa)
   - `HallBoard` (bảng nội quy), `HallBoardNote` (chỗ kẹp giấy viết tay), `DutyLog` (sổ trực trên bàn), `Speaker` (loa)
   - `WashroomTapRunning` (vòi tự chảy), `WashroomMirror`, `WashroomNotice` (tờ 6 điều)
   - `ClotheslineExtraShirt` (áo trắng ở mức "lệch" 3), `DarkSection` (đoạn trước 402–404)
8. **Mùng:** dùng `mosquito_net_closed` cho giường Phúc, Việt, Đạt (có hình nộm nằm bên trong như showcase) và `mosquito_net_open` cho giường Trung.
9. **Test `game/tests/levels/`:**
   - `floor4.tscn` load và instance được, không lỗi.
   - Có đủ các node trong mục 7, đúng tên.
   - Mọi `StaticBody3D` hoặc `CSGShape3D` làm sàn có metadata `surface`.
   - Capsule của Player đi được theo các đường: `seg1_start` → cửa 407 → bàn trực; `seg5_start` → cửa nhà vệ sinh → `WashroomTapRunning`. Dùng `cast_motion` hoặc `NavigationServer`, tùy lane B chọn.
   - Không đi ra ngoài lan can được.
10. **Ảnh:** chụp hành lang nhìn từ cửa 407 về hai phía, trong phòng 407, nhà vệ sinh, bàn trực.
11. **Yêu cầu thay đổi:** ghi vào Handoff để integrator thay hành lang tạm trong `main.tscn` bằng `floor4.tscn` và đặt Player ở `seg1_start`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Có 4 ảnh chụp ở mục 10
- [ ] FPS đo được ghi trong Handoff
- [ ] Danh sách vật đang dùng hộp tạm (để làm mô hình thật ở task sau)
- [ ] Không chạm file ngoài phạm vi
- [ ] Mục Handoff đã điền

## Handoff (agent điền)
