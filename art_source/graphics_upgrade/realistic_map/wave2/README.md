# Đồ hoạ thật đợt 2 — T-253 (D-167)

Hành lang tầng 3, 2, 1 nhà B và các phòng nhìn được qua cửa (A08–A10), phòng 203, sảnh, phòng quản lý và cửa sổ,
cửa chính; bình cứu hoả tầng 2 và hộp báo cháy tầng 1 (A11). Dựng bằng Blender theo đúng bộ vật liệu, màu, chi tiết
của đợt 1 đã được duyệt (D-167). Không dùng Tripo. Card: `docs/tasks/T-253-realistic-graphics-wave2.md`.

## Dựng lại
```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave2/make_wave2_textures.py    # bản đồ bẩn, nhãn (khoảng 1 phút)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave2/build_hall.py      # floor1..3_hall/rooms, cửa, biển số
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave2/build_floor1.py    # cửa sổ, phòng quản lý, dao, cửa chính
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave2/build_fire_kit.py  # bình cứu hoả, giá, hộp báo cháy
python -B art_source/graphics_upgrade/realistic_map/wave2/make_wave2_materials.py   # vật liệu W2*.tres + .import (use_external)
python -B art_source/graphics_upgrade/realistic_map/wave2/patch_wave2.py            # gắn vào building_b.tscn (chạy trên bản main)
godot --headless --path game --import   # lần đầu chạy hai lần (PNG mới)
pwsh tools/test.ps1 -Filter t253
```
Ảnh: chép `capture_wave2.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script đó (không commit), rồi theo Lượt Godot:
`godot --path game res://_probe_tmp/capture_wave2.tscn -- --set=a08,a09,a10,a11 --tag=after --alarm_preview`
(`--alarm_preview` cần `game/_probe_tmp/alarm_preview.tscn` instance `fire_alarm.glb`: chỉ để chụp, hộp báo cháy trong
game vẫn là hộp đỏ của core). Ghép trước/sau: `python -B .../make_compare.py`.

## Cách làm
- **Hợp đồng gameplay giữ nguyên** (PLAN mục 4): không đổi, thêm, xoá va chạm, dẫn đường, marker, `Ch3Use`, tên node.
  Hình PS1 chỉ ẩn (`visible = false`). Test `game/tests/levels/test_t253_realistic_wave2.gd` so dấu vân tay **mọi
  va chạm** (331) và **mọi node** (2.216, trừ model treo thêm) của `building_b.tscn` với main.
- **Lỗ cửa phòng tầng 1–3 là 0,9 × 2,1 m**, không phải 1,7 × 2,5 m như hộp tường: bộ `wall_door` dưới
  `KitDetail<N>/Frame<i>` có va chạm riêng (`kit_import.gd`). Bộ đó được giữ, chỉ ẩn lưới (ghi đè node con `wall_door`
  của instance, `[editable]`), khung mới `Surround` ốp quanh lỗ 0,9 m. Cánh cửa là một cánh 0,89 m; trục hình `Hinge`
  của `RoomDoor` dời từ x 0,85 vào mép lỗ x 0,45 (như cửa tầng 4) để cánh quay đúng bản lề; `Blocker` và va chạm
  không đổi.
- **Vật liệu:** glb chỉ mang vật liệu giữ chỗ. `W1*` trỏ sang vật liệu đợt 1 (`wave1/materials`, không sửa),
  `W2*` sang `wave2/materials`. Tường, trần, sàn hành lang dùng `room407_shell.gdshader` với bản đồ bẩn riêng của
  đợt này (mỗi tầng một hàng trong atlas, u theo x 0…44 nên không vết nào lặp).
- **Phòng sau cửa:** chỉ mặt nhìn thấy (tường, sàn, trần, chân tường) và giường tầng nhẹ, tủ thép nằm trong hộp va
  chạm PS1 của `RoomInterior_*`. Phòng 203 dùng đồ phòng 407 (giường, nệm, chăn gối, bàn, sách, ghế, xô, dép) trong
  `Room203BedBody`/`Room203DeskBody`, cánh cửa gập sát tường trong (203 không có node cửa, luôn mở).
- **Tầng 1:** cửa ba hốc xác (phòng 102, 105, 107) đã bị phá, cánh nằm trên sàn trong phòng, ngoài dải dẫn đường;
  ba cửa 103, 106, 108 đóng (thân va chạm cũ). Phòng quản lý: bàn đợt 1 trong `ManagerDeskBody`, dao găm mặt bàn,
  cửa sổ: bậc xây đặt sao cho mặt bậc ở giữa bậc nằm trên dốc `WindowApproach`/`WindowExit` (lệch đo được 0,1 mm),
  mặt cầu qua bậu là mặt hộp `WindowBridge`; lối khom 1,8 m không có vật nào. Cửa chính: hai cánh kính, `door.gd`
  xoay `LeafB` ngược chiều khi mở; xích mới nằm dưới `MainDoor/Chains` nên ẩn cùng khi `set_main_door_chained(false)`.
- **A11:** bình cứu hoả là con của `FireExtinguisher` (node giữ chỗ cũ, hình nón PS1 vẽ trên layer 0); cần bóp
  `Lever` và điểm cầm `Grip` là node riêng; giá treo `ExtinguisherBracket` là node riêng trên tường (nhấc bình ra
  được). Hộp báo cháy do core dựng lúc chạy: chỉ có `fire_alarm.glb` (nút `Button` riêng, điểm `Press`) chờ core gắn.

Nguồn và giấy phép: `game/assets/models/graphics_pilot/realistic_map/CREDITS.md`.
