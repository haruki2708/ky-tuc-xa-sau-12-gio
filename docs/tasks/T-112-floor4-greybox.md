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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Có 4 ảnh chụp ở mục 10 (đã chụp đủ 5 góc được liệt kê)
- [x] FPS đo được ghi trong Handoff
- [x] Danh sách vật đang dùng hộp tạm (để làm mô hình thật ở task sau)
- [x] Không chạm file ngoài phạm vi
- [x] Mục Handoff đã điền

## Handoff (agent điền)

### Đã làm
- Lane B, 2026-10-02. Commit triển khai `9434c66` đã push lên `origin/lane-b/T-112-floor4-greybox` trước khi ghi bàn giao này.
- Dựng tầng theo LAYOUT D-020: hành lang 44 × 2,4 m, phòng 407, nhà vệ sinh, bàn trực/cổng khóa; dùng lại kit và primitive cho vật còn thiếu. Scene tĩnh, chia bốn phần để chỉnh trực tiếp trong editor.
- Đủ 24 anchor có tên/hướng theo card; `RulesPaper407` đi theo cánh cửa. Cửa 407 mở/đóng bằng E, collision theo bản lề; các cửa khác cố định. Có rào collision 2 m và metadata tile trên 11 sàn.
- Đặt đủ đèn, LightHum, vùng âm/reverb phòng/hành lang/vệ sinh/bàn trực, quạt, dế/xe máy phía sân và nước nhỏ giọt. Ba giường có mùng đóng và hình nộm, giường Trung có mùng mở.
- Thêm scene `floor4_playtest.tscn` dùng Player/HUD/menu/footsteps hiện có, generator scene, script chụp/đo FPS và 6 test tầng. Không sửa main, core, âm thanh, localization hoặc import texture ngoài phạm vi.

### Kiểm tra và bằng chứng
Đã chạy trên Godot 4.7.2:

```text
pwsh tools/test.ps1
RESULT: 117 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
FLOOR4_CAPTURE_RESULT: PASS 5 views
```

Test mới kiểm tra cấu trúc/kích thước/anchor, metadata sàn, cửa và giấy gắn cánh, đường capsule r=0,3 m cao 1,75 m, chống vượt lan can, đèn và vùng âm. Đường tới vòi kết thúc trong tầm tương tác, không đặt capsule vào bồn rửa. Đã kiểm tra hình ảnh render thực; chưa có phiên chơi thử thủ công của chủ dự án.

Ảnh 1280 × 720: [hành lang nhìn tây](../../art_source/floor4/previews/corridor_west.png), [hành lang nhìn đông](../../art_source/floor4/previews/corridor_east.png), [phòng 407](../../art_source/floor4/previews/room_407.png), [nhà vệ sinh](../../art_source/floor4/previews/washroom.png), [bàn trực](../../art_source/floor4/previews/duty_desk.png). Mục 10 liệt kê 5 góc dù checklist ghi 4 ảnh; đã chụp đủ cả 5.

FPS trung bình đo bằng thời gian thực, không dùng fixed-fps:

| Góc | FPS trung bình | Frame p95 (ms) |
|---|---:|---:|
| Hành lang tây | 566,88 | 2,056 |
| Hành lang đông | 489,42 | 2,808 |
| Phòng 407 | 496,91 | 2,489 |
| Nhà vệ sinh | 539,77 | 2,357 |
| Bàn trực | 524,35 | 2,640 |

Máy: Ryzen 5 5600H, RTX 3050 Laptop; Forward+/Vulkan, 1280 × 720, VSync/max FPS tắt. Mỗi góc warm-up 90 frame, đo 240 frame; Player physics, HUD, âm thanh hoạt động và cửa 407 mở. Cả 5 góc vượt 60 FPS; đây là mẫu đứng yên, chưa đại diện mọi máy hoặc gameplay tương lai. Số đo gốc: [performance.json](../../art_source/floor4/previews/performance.json).

Cách kiểm tra lại: mở `game/scenes/levels/floor4/floor4_playtest.tscn`, F6, WASD/chuột/E/Esc. Lệnh dựng lại và chụp hình có trong [README](../../art_source/floor4/README.md).

### Vật tạm và phần chờ task sau
- Hộp/primitive: sàn/trần/vách thiếu module; bàn học/bàn trực; bồn rửa, vòi, gương và vách/cửa buồng vệ sinh.
- Thanh/hộp: lan can, song cửa sổ, cổng sắt, xích/khóa, dây phơi/khăn-áo, máng đèn tuýp và thân đèn bàn.
- Hộp nhỏ: điện thoại, sổ trực, bảng/giấy/biển phòng/biển cổng, dép, xô/chậu, loa, công tắc. Capsule đại diện ba bạn cùng phòng; cây và đèn sân là khối xa.
- Biển và giấy là mặt tạm chưa có chữ; số phòng lưu ở tên node/metadata. Gương chưa có phản chiếu chậm; đồ vật ngoài cửa 407 chưa gắn gameplay. Loa dùng tạm `fluorescent_flicker.ogg` có sẵn ở -28 dB làm nhiễu ngắt quãng.
- Không còn mục checklist chưa đạt trong phạm vi greybox. Không tự thêm luật/cốt truyện; các tương tác và hiệu ứng theo luật chờ lane phụ trách.

### Yêu cầu thay đổi ngoài phạm vi
1. **Integrator:** thay hành lang tạm trong `game/scenes/main/main.tscn` bằng `res://scenes/levels/floor4/floor4.tscn`; đặt transform Player theo `Floor4/Anchors/seg1_start`. Giữ HUD/menu/footsteps hiện có, bỏ đèn/environment/nguồn âm tạm trùng với tầng mới. Floor4 không kèm Player/UI; scene playtest chỉ dùng kiểm tra riêng.
2. **Integrator/Lane D:** thêm key dịch vi/en cho biển phòng 401–408 và biển khóa cổng 23:00 theo LAYOUT, rồi gắn vào các mặt tạm. Lane A gắn tài liệu/đồ vật tương tác qua Anchors. Chưa sửa localization vì card không cho phép đường dẫn này.
3. **Lane E:** thay âm nhiễu tạm của loa bàn trực bằng clip loa rè chuyên dụng; đã có emitter và vùng âm bàn trực.

### Trạng thái chặn
Không bị chặn. Triển khai và kiểm tra greybox hoàn tất; các yêu cầu trên dành cho bước tích hợp/nội dung tiếp theo.
