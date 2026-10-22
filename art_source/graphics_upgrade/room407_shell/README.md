# Vỏ phòng 407 nâng cấp — cảnh thử (T-222, D-126, D-127)

Thay vỏ phòng của góc thử T-213 (`../room407_corner/`) bằng vỏ cùng mức cũ bẩn với đồ Tripo: tường, trần, sàn, gạch chân tường, khung và nẹp cửa, ngưỡng đá, máng đèn, mạng nhện, ban công (sàn, lan can, vách ngăn, cửa nhôm kính mở sẵn, đồ phơi) và cảnh bên ngoài (ban công hàng xóm, sân, cây, dãy ký túc đối diện, trời đêm). **Vào bản chơi từ D-129** (22/10/2026): `room407.gd` `shell_t222` mặc định bật; tắt thì về vỏ góc T-213 (ảnh trước, `--shell-corner`).

## Dựng lại

```powershell
python -B art_source/graphics_upgrade/room407_shell/fetch_textures.py        # CC0 Poly Haven
python -B art_source/graphics_upgrade/room407_shell/make_shell_textures.py   # texture phái sinh (vài giây)
python -B art_source/graphics_upgrade/room407_shell/make_shell_masks.py      # 4 bản đồ bẩn (khoảng 4 phút)
# Cửa Tripo (file gốc ở build/graphics/staging/doors/): cắt khung, bỏ tay nắm, nướng
$B = "D:\Tools\Blender\5.2.2\blender.exe"; $P = "build/graphics/staging/doors/prepped"; $O = "game/assets/models/graphics_pilot/room407_shell/doors"
& $B -b --factory-startup -P art_source/graphics_upgrade/room407_shell/prep_doors.py -- door_bathroom build/graphics/staging/doors/door_bathroom.glb $P/door_bathroom.glb
& $B -b --factory-startup -P art_source/graphics_upgrade/room407_shell/prep_doors.py -- door_bathroom build/graphics/staging/doors/door_bathroom.glb $P/door_bathroom_low.glb 4000
& $B -b --factory-startup -P art_source/graphics_upgrade/tripo/bake_prop.py -- --src $P/door_bathroom.glb --low $P/door_bathroom_low.glb --out $O/door_bathroom.glb --name door_bathroom --min -0.49 0 -0.02 --size 0.98 2.2 0.04 --fit box --rotate 180 --tris 8000 --tex 2048 --image-format JPEG --sharp 30
#   door_balcony: như trên với "6000" cho bản nhẹ, --min -0.46 0 -0.025 --size 0.92 2.24 0.05, không --rotate
#   door_room_r2 -> door_room: như door_bathroom, --min -0.445 0 -0.02 --size 0.89 2.1 0.04, không --rotate
& $B -b --factory-startup -P art_source/graphics_upgrade/room407_shell/prep_lever.py -- build/graphics/staging/doors/door_lever.glb build/graphics/staging/doors/prepped/door_lever.glb
#   rồi bake_prop.py --fit box với gltf_min/gltf_size mà prep_lever.py in ra, --tris 1400 --tex 1024
& $B -b --factory-startup -P art_source/graphics_upgrade/room407_shell/build_shell.py      # 6 GLB vỏ phòng
& $B -b --factory-startup -P art_source/graphics_upgrade/room407_shell/build_outside.py    # outside.glb
godot --headless --path game --import
godot --path game res://scenes/levels/room407/room407_g3_capture.tscn -- --g3-capture --shell-t222    # ảnh sau
godot --path game res://scenes/levels/room407/room407_g3_capture.tscn -- --g3-capture --shell-corner  # ảnh trước
pwsh tools/test.ps1 -Filter room407_shell
```

## Cách làm

- **Bố cục** [`shell_layout.py`](shell_layout.py): mỗi mặt tường, sàn, trần, ban công là một hình chữ nhật theo số đo vỏ cũ (tường cửa z=0, tường tây x=0,1, đông 7,9, sau −6,925, trần 3, nhà tắm x 5,375…7,9). Tên node giữ như vỏ cũ (`FrontWallWest`, `BathroomSide`, `RoomDoor`, `BathroomDoor`, `FluorescentTube*`) để code cũ chạy nguyên.
- **Hai lớp UV:** UV1 theo mét cho texture CC0 lặp lại; UV2 trỏ vào bản đồ bẩn riêng của mặt đó (atlas 2048², tường 164 px/m, sàn 193, trần và ban công 260). Shader [`game/rendering/room407_shell.gdshader`](../../../game/rendering/room407_shell.gdshader):
  - tường, trần, mặt ngoài: R bong sơn (lộ lớp vữa của scan Peeling Painted Wall), G bẩn, B vết nước có viền ố, A mốc lấm tấm;
  - sàn, gạch chân tường: R bẩn ron gạch, G bẩn, B ướt (bóng, tối), A mòn bóng theo lối đi.
- **Bản đồ bẩn** [`make_shell_masks.py`](make_shell_masks.py) vẽ theo vị trí thật:
  - vết dầu tóc trên tường cạnh gối 4 giường;
  - tay bẩn quanh công tắc, mép cửa phía chốt;
  - khói đen sau tủ lạnh, bẩn sau kệ giày, cạnh bàn Phúc;
  - ẩm chân tường lan từ nhà tắm ra phía phòng (có viền ố, sơn phồng bong);
  - vệt dột từ trần, mốc góc trần nhà tắm và quanh vòi sen;
  - vết poster cũ đã gỡ (mảng sạch hơn, keo vàng ở 4 góc, lỗ đinh);
  - vết cào ở độ cao ghế, balo;
  - trên trần: vết loang có 3 vòng ố, nứt, khói đèn, bụi quanh quạt;
  - trên sàn: lối đi mòn, bụi chân tường và gầm giường, vết vòng xô, vết giày;
  - dấu chân ướt từ cửa nhà tắm tới giường Trung, vũng nước dưới bình lọc.
- **Cửa:** cả ba cánh là Tripo (cửa phòng lượt 2), tay nắm Tripo hai mặt ở phía chốt; tay nắm cửa phòng treo lên `Door407/Pivot/HandlePivot` (`floor4.gd`) để cảnh rung tay nắm từ hành lang vẫn rung đúng trục.
  - Cửa phòng: khung gỗ sơn xanh, nẹp 7 cm, 3 bản lề, ngưỡng đá; khung đi theo tường cửa khi game dịch tường 0,105 m (`room407.gd` `DOOR_WALL_PARTS`).
  - Cửa nhà tắm: khung kem.
  - Cửa ban công: khung nhôm sát mép ngoài tường, để cánh mở ra ngoài được gần 180°. D-127: cánh mở sẵn 172°, áp vào tường ngoài phía đông (`fixtures/BalconyDoorPivot`), không chắn lối ra ban công.
  - Bản lề và va chạm cửa ban công: `game/scenes/levels/room407/balcony_door.tscn`; `room407.gd` đặt nó lên trục của vỏ và treo cánh lên (D-129).
- **Ban công:** chiếc khăn chương 2 (`Anchors/TowelSpot`, đồ cầm được) chuyển lên dây phơi mới và vẽ bằng khăn Tripo (`placements_t222.json`, `room407.gd` `T222_*`); thêm 2 áo phơi.
- **Bên ngoài** [`build_outside.py`](build_outside.py): 9 phòng × 6 tầng mỗi dãy, cách 22 m. Đồ xa không vát cạnh, gộp theo vật liệu (khoảng 22.600 tam giác). Trời, ô cửa sáng đèn và đèn sân không bị sương mù che (`Room407Furnish.OUTSIDE_UNLIT`).

## Chưa xong

- Người chơi chưa tự đóng/mở cửa ban công trong bản chơi (mở/đóng bằng tay có trong cảnh thử T-220): làm cùng T-220 bước 5 (D-130).
- Tay nắm Tripo gắn tĩnh trên cánh; cảnh thử T-220 gắn `HandTarget` lên chúng (`DoorHandles.take`).
- FPS (D-131, `tools/reports/D-131-room407-t222-performance.md`): 1080p thấp nhất 75 FPS, chậm chủ yếu do shader `room407_shell.gdshader`; tối ưu shader chờ chủ dự án chọn.

Nguồn và giấy phép: [`CREDITS.md`](CREDITS.md). Ảnh: `previews/before/`, `previews/after/`, so sánh `previews/compare_*.jpg`.
