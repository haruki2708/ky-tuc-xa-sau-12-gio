# T-112 — Greybox tầng 4 nhà B

Nguồn bố cục: `docs/design/LAYOUT.md` (D-020). Scene tích hợp: `res://scenes/levels/floor4/floor4.tscn`. X chạy từ tây sang đông, phòng ở -Z, sân/lan can ở +Z, sàn Y=0.

## Chơi thử và dựng lại

Mở `res://scenes/levels/floor4/floor4_playtest.tscn` và F6. Scene này instance tầng, Player/HUD/menu/footsteps hiện có; bắt đầu tại `seg1_start`. WASD đi, chuột nhìn, E bật/mở cửa 407, Esc mở menu. Chỉ cửa 407 có hành vi tạm; các vật khác là vị trí chờ gameplay.

`floor4.tscn` giữ riêng môi trường, không kèm Player/UI để integrator dùng lại. Nó instance `corridor`, `room_407`, `washroom`, `duty_desk`; tất cả có thể xem/sửa trực tiếp trong editor.

Scene được sinh thành văn bản tĩnh bằng Python chuẩn, không cần Blender chạy hoặc plugin:

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/floor4/build_floor4.py
pwsh tools/test.ps1 -Filter floor4
pwsh tools/test.ps1
pwsh tools/check.ps1
```

Sửa generator trước khi dựng lại để không mất chỉnh sửa scene thủ công. Generator chỉ ghi sáu `.tscn` trong `game/scenes/levels/floor4/`; giữ nguyên script `.gd` và asset kit.

## Các vị trí và khoảng thông thủy

- Hành lang: X=0…44, Z=0…2,4; cửa phòng tại X=8,12,16,20,24,28,32,36. Chín đèn tại X=8…40, bước 4 m, Y=2,8, có LightHum gán đúng đèn.
- Phòng 407: X=30…34, Z=-5…0, trần Y=3. Hai giường x=30,65/33,35; mùng Phúc/Việt/Đạt đóng có capsule; mùng Trung mở. Bốn tủ chia hai bên lối vào để giữ đường đi ở giữa.
- Nhà vệ sinh: X=0…6, Z=-5…0. Cửa ở X=3 rộng 1,2 m; ba bồn rửa dọc tường tây và ba buồng khóa ở phía bắc. Vòi tự chảy được đánh dấu ở bồn cuối, Z=-2,85.
- Bàn trực: X=40; bảng ở X=38,5; cổng khóa cầu thang ở X=41,95. Lan can Y=1,1 có thêm collision vô hình cao 2 m. Cả hai đầu hành lang được chặn.
- Mọi sàn, kể cả bảy phòng đóng và chiếu nghỉ sau cổng khóa, có `metadata/surface = &"tile"` và collision world layer 1. Không dùng CSG động.
- Cửa 407: bản lề X=32,44, Y=0,01, Z=0. Mở vào phòng 90°; collision theo cánh. `set_open(bool)`/`interact()` là API greybox, chưa khóa cửa theo cốt truyện. `Anchors/RulesPaper407` đi theo mặt trong cánh khi mở/đóng.
- Các anchor khác giữ đúng tên trong task card, dưới `Floor4/Anchors`. `seg1` quay bắc; `seg5` quay tây; `seg3` quay ra cửa. Các điểm hồi sinh đã kiểm tra không giao collision.
- Đi vào phòng rồi qua đầu cánh cửa mở tại `(32,0.03,-1.35)` trước khi rẽ về phía công tắc/tủ Trung. Đây là khoảng đi tự nhiên quanh cánh cửa, không xuyên qua lá cửa.
- Đường tới vòi kết thúc ở `(1.25,0.03,-2.85)`, cách vòi trong tầm tương tác; anchor vòi nằm trên vật, không phải chỗ đặt capsule vào bồn.

## Âm và ánh sáng

Dùng nguyên script Lane E: `LightHum`, `AmbientEmitter`, `AmbientZone`, `ReverbZone`. ROOM ở phòng 407; CORRIDOR ở hành lang và vùng bàn trực riêng; BATHROOM ở nhà vệ sinh. Tiếng quạt trong phòng, dế/xe máy ở phía sân, nhỏ giọt ngẫu nhiên ở bồn cuối. Loa bàn trực dùng tạm clip nhiễu điện có sẵn `fluorescent_flicker.ogg` ở -28 dB, ngắt quãng và chỉ nghe khi ở trong vùng bàn trực; cần Lane E thay bằng tiếng loa rè chuyên dụng. Đèn bàn phòng vẫn sáng độc lập với đèn chính. Chưa gắn sự kiện luật làm đèn nhấp nháy hoặc tắt từng đoạn.

Đèn cục bộ không bật shadow để giữ chi phí thấp khi nhìn dọc 44 m. Đây là ánh sáng greybox; bóng đổ và filter PS1 là bước khác. Không sửa các import texture đang chờ T-118.

## Vật tạm cần thay bằng model/nội dung ở task sau

- Hộp: sàn/trần/vách thiếu module; bàn học, bàn trực; bồn rửa/vòi/gương/vách-cửa buồng vệ sinh; tủ đã dùng model kit.
- Thanh/hộp: lan can, song cửa sổ, cửa sắt, xích/khóa, dây phơi/khăn-áo, đèn tuýp/máng, thân đèn bàn.
- Hộp nhỏ: điện thoại Trung/điện thoại bàn, sổ trực, bảng/giấy nội quy, dép (4 đôi), xô/chậu, loa, công tắc; capsule đại diện ba bạn cùng phòng.
- Khối xa: tán cây và đèn sân; không có địa hình sân chơi được.
- Các biển số/biển khóa cổng và giấy hiện là mặt tạm, chưa có chữ/story UI. Số phòng lưu trong tên node/metadata. Cần integrator thêm key dịch trước khi hiển thị chữ; không ghi cứng nội dung ngoài hợp đồng localization.
- Gương hiện là mặt tối, chưa có phản chiếu chậm; loa có hình khối/anchor và âm nhiễu tạm nêu trên. Không dựng hoặc suy diễn luật/cốt truyện.

## Ảnh và đo hiệu năng

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/floor4/capture_floor4.gd --resolution 1280x720 --windowed --disable-vsync
```

Ghi 5 ảnh trong `previews/`: hành lang từ 407 nhìn tây/đông, phòng, vệ sinh, bàn trực. Task liệt kê 5 góc dù checklist ghi 4 ảnh; đã giữ đủ 5 góc. `performance.json` lưu CPU/GPU, renderer, điều kiện đo, FPS trung bình và p95 thời gian frame của từng góc.

Mỗi góc warm-up 90 frame rồi đo 240 frame bằng đồng hồ thực; VSync/max FPS tắt, không `--fixed-fps`. Scene chơi thử, Player physics, HUD và âm thanh vẫn hoạt động. Đây là mẫu góc đứng yên, không phải cam kết hiệu năng mọi máy hoặc toàn bộ gameplay tương lai.

Nguồn: mọi model/texture dùng lại kit đã ghi trong `../CREDITS.md`; hình khối mới do generator Lane B/Codex tạo, không có asset bên ngoài.
