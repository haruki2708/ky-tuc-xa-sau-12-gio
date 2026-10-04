# T-153 — Phòng 407 chương 1

Theo `docs/design/STORY.md` v2 §5 và bảng giường T-150. Những file này là môi trường/hình ảnh; thời điểm xảy ra sự kiện và lời giải câu đố thuộc T-150/T-151/T-152.

## Đồ đạc và điểm tích hợp

Scene chính vẫn là `res://scenes/levels/floor4/room_407.tscn`. `Details` chứa mô hình cá nhân, áo phơi, xô/khăn, bốn đôi dép, chăn, máu và nệm có thể hỏng. `Anchors` instance scene riêng nên chỉnh được trong editor.

| Nhóm | Vật | Anchor dưới `Room407/Anchors` |
|---|---|---|
| Phúc, giường 1 | Giáo trình, tai nghe, poster bóng đá, mì gói trên kệ cạnh giường | `PhucBooks`, `PhucPoster` |
| Việt, giường 2 | Laptop cũ dán băng, guitar, ảnh gia đình cách điệu | `VietLaptop`, `VietPhoto` |
| Trung, giường 3 | Balo, bàn/đèn hiện có, ổ điện và dây USB có hai đầu rời, không có cục sạc | `TrungChargingCable` |
| Đạt, giường 4 | Tủ sắt với khóa số, giày thể thao, sổ tay trên bàn | `DatLocker`, `DatNote` |
| Chung | Router nhỏ trên tường, áo phơi, xô/khăn, quạt trần hiện có | `Router`, `WallKnock406`, `WallKnock408` |

`Details/Slippers/{Phuc,Viet,Trung,Dat}` là bốn đôi dép trong phòng, lần lượt đỏ/xanh dương/xanh lá/đen. Bốn node dép cũ ngoài hành lang giữ tên để tương thích code demo nhưng ẩn; integrator bỏ luồng demo khi ghép chương 1.

Sổ tay, sách và khóa chưa có nội dung/mã số; integrator/Lane D thêm nội dung đã duyệt qua localization/UI. Anchor `DatLocker` có khóa với ba bánh hình học trang trí, **không quy định độ dài mã** hoặc tự gắn lời giải. Cánh tủ vẫn dùng model/collision kit, `set_unlocked()` chỉ thể hiện móc khóa đã mở; thao tác mở cánh/lấy vật do lane gameplay ghép.

## Giường

| Đường dẫn dưới Anchors | Chủ | Vị trí gốc trong Room407 |
|---|---|---|
| `Bunks/Bunk1` | Phúc, A trên | `(0.65,1.20,-3)` |
| `Bunks/Bunk2` | Việt, A dưới | `(0.65,0.43,-3)` |
| `Bunks/Bunk3` | Trung, B dưới | `(3.35,0.43,-3)` |
| `Bunks/Bunk4` | Đạt, B trên | `(3.35,1.20,-3)` |

Mỗi anchor có `View` (camera nằm, nhìn về chân giường) và `Exit` (đứng trong lối giữa). Exit hai giường A ở `(1.5,0.03,-2.3)`, hai giường B ở `(2.5,0.03,-2.3)`, đã kiểm tra capsule r=0,3 m cao 1,75 m. Lane A instance `bunk_spot` rồi gán `bed_number`, `view`, `exit` tương ứng.

`Corpse1`, `Corpse2`, `Corpse4` nằm ở tâm mặt nệm; quy ước gốc này dành cho model **nằm** đặt theo tâm giường, đầu hướng +Z (về cửa). T-154 cần ghép body theo quy ước này hoặc thêm offset. Chưa có corpse model mới; `Sleeper_*` cũ vẫn là capsule chờ thay, các mùng giữ node path cũ. Không có Corpse3.

## API hình ảnh

```gdscript
var room = $Floor4/Room407
room.set_blood_stage(0) # 0 sạch; 1 thấm chăn và giọt; 2 thêm vũng
room.set_slashed(0.5)   # 0..1, tám phần nệm/chăn; 1 nát hết, có vụn
room.set_flicker(true)  # cả hai đèn; hoặc gọi riêng từng đèn
room.get_node("Room407MainLight").set_flicker(false)
room.get_node("Room407DeskLamp").set_flicker(false)
room.get_node("Anchors/DatLocker").set_unlocked(true)
$Floor4/DoorGap/UnderDoorShadow.set_visible(true)
```

- `set_blood_stage(int)` clamp 0…2; gọi 0 ẩn hết vết/giọt/vũng, phù hợp để integrator xử lý giảm máu me. Giọt chạy theo delta và dừng khi cây scene pause. Không âm thanh hoặc logic gây chết trong thành phần này.
- `set_slashed(float)` clamp 0…1, NaN/INF về 0. Mỗi 1/8 tăng một mức phá hủy. Nệm/chăn Trung tách khỏi mesh khung giường, nên khi hỏng thật sự lộ vạt gỗ; mùng/khung/collision không đổi. Gọi 0 khôi phục đầy đủ, an toàn cho checkpoint.
- `set_flicker(bool)` trên room chuyển tiếp tới hai đèn; hai đèn cũng có API riêng. Tắt flicker trả đúng energy/visible lúc bắt đầu, không tự bật đèn chính sau hiệu ứng. LightHum hiện có quan sát energy thực.
- Trạng thái 4 giờ: đèn chính **energy=0**; giữ node visible để tương thích công tắc cũ. Nếu chương mới cần bật ổn định, integrator đặt energy > 0 và visible=true. Đèn bàn sáng, cửa sổ có ánh xanh, khe cửa có ánh hành lang. Không thêm WorldEnvironment cạnh tranh với tầng.
- `DatLocker.set_unlocked(bool)` là trạng thái hình ảnh móc khóa, đảo ngược được. Không phát `puzzle_solved` hoặc sửa GameState.
- `Floor4/Threshold`: Area3D world position `(32,1,0.30)`, box `(0.90,2,0.36)`, layer=0/mask=2. Integrator kết nối body_entered theo giai đoạn luật; tự nó không gây chết hoặc chặn di chuyển.
- `Floor4/DoorGap/UnderDoorShadow` mặc định ẩn. Khe sáng/bóng tự ẩn theo cửa mở qua API cửa cũ; `set_open()` và prompt/latch không đổi.

## Dựng lại, thử và kiểm tra

```powershell
& 'D:\Tools\Blender\5.2.2\blender.exe' --background --python art_source/room407/build_assets.py
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/room407/build_scenes.py
# Lần đầu cần Godot import để tạo .import, rồi:
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/room407/configure_imports.py
pwsh tools/test.ps1 -Filter room407
pwsh tools/test.ps1
pwsh tools/check.ps1
```

`build_scenes.py` chỉ sinh các scene T-153 và thêm tham chiếu vào scene tầng hiện có; chạy lại được. Nếu dùng generator tầng cũ `art_source/floor4/build_floor4.py`, chạy lại `room407/build_scenes.py` sau đó để phục hồi phần T-153. Giữ patch `floor4.gd` đồng bộ khe cửa. Import script tái dùng shader PS1 của kit; texture 128 px lossless/nearest, không mipmap, không addon.

Mở `res://scenes/levels/room407/room407_test.tscn`, F6. WASD/chuột/E/Esc như Player; phím 1 sạch/reset, 2 máu thấm, 3 vũng, 4 hỏng 50%, 5 hỏng hết, 6 bật/tắt nhấp nháy, 7 hiện/ẩn bóng dưới cửa. Scene không khởi chạy StoryDirector demo.

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/room407/capture_room407.gd --resolution 1280x720 --windowed --disable-vsync -- --ps1-strength=1
```

Preview/FPS ở `previews/`. Đo đồng hồ thực: 90 frame warm-up + 240 frame/góc, VSync tắt, không fixed-fps, toàn bộ tầng và Player physics/HUD/âm thanh/filter PS1 hoạt động. Script thoát qua App.quit(). Ảnh chưa thay cho chơi thử bằng người; chưa thử chuỗi 50 phút, quản lý chém và xác T-154.
