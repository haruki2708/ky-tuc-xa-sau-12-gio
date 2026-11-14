# Đồ hoạ thật đợt 1 — T-250 (D-166)

Bàn trực tầng 4 (A01), cầu thang thoát hiểm và cửa (A07), cầu thang chính nhà B (A06), dựng bằng Blender theo
chất liệu phòng 407 và hành lang tầng 4 (vật liệu CC0 Poly Haven đã có trong game, shader vỏ phòng 407 với bản đồ
bẩn riêng). Không dùng Tripo. Kế hoạch gốc: [`../PLAN.md`](../PLAN.md); card: `docs/tasks/T-250-realistic-graphics-wave1.md`.

## Dựng lại
```powershell
$B = "D:\Tools\Blender\5.2.2\blender.exe"
python -B art_source/graphics_upgrade/realistic_map/wave1/make_wave1_textures.py    # texture tự vẽ (khoảng 1 phút)
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave1/build_duty_desk.py   # 7 glb bàn trực
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave1/build_stairs.py      # main_stairs, fire_stairs
& $B -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave1/build_fire_door.py   # 5 glb cửa thoát hiểm
python -B art_source/graphics_upgrade/realistic_map/wave1/make_wave1_materials.py   # vật liệu .tres + .import (use_external)
python -B art_source/graphics_upgrade/realistic_map/wave1/patch_scenes.py           # gắn vào building_b.tscn, duty_desk.tscn
godot --headless --path game --import
pwsh tools/test.ps1 -Filter t250
```
Ảnh: chép `capture_wave1.gd` vào `game/_probe_tmp/` cùng một scene gốc gắn script đó (không commit), rồi theo Lượt Godot:
`godot --path game res://_probe_tmp/capture_wave1.tscn -- --chapter=3 --set=a01,a07,a06 --tag=after`
(`--chapter=1 --set=a01` cho bàn trực ở chương 1). Ghép trước/sau: `python -B .../make_compare.py`.

## Cách làm
- **Hợp đồng gameplay giữ nguyên** (PLAN mục 4): không đổi va chạm, dẫn đường, marker, tên node. Hình PS1 chỉ bị ẩn
  (`visible = false` trên Mesh hoặc node hình), không xoá. Test `game/tests/levels/test_t250_realistic_wave1.gd`
  so dấu vân tay mọi va chạm của hai cầu thang, cửa thoát hiểm, bàn trực với main.
- **Vật liệu:** mỗi glb chỉ mang vật liệu giữ chỗ `W1*`; file `.import` của nó trỏ từng vật liệu sang
  `game/assets/models/graphics_pilot/realistic_map/wave1/materials/*.tres` (dùng chung, không chép texture).
  Tường, trần, bậc dùng `game/rendering/room407_shell.gdshader` như hành lang tầng 4; UV2 trỏ vào bản đồ bẩn
  `mask_stair_wall.png` (mỗi tầng một lượt: bẩn chân tường, vệt tay ngang tay vịn, vệt nước, mốc góc) và
  `mask_stair_floor.png` (mép bậc bẩn, giữa bậc mòn bóng).
- **Bàn trực:** gỗ Wood Table Worn như bàn học phòng 407; nằm gọn trong hộp va chạm của bàn PS1. Ngăn kéo giữa
  `Desk/Model/KeyDrawer` trượt ra 0,34 m theo +Z bằng `duty_desk.gd` (`set_drawer_open`), chưa ai mở nó (động tác
  lấy chìa là T-247 dòng 5, card sau). Chìa thật nằm trên đáy ngăn kéo ở y 0,650 (`KeyStem/Model`). Đồng hồ (chỉ có
  ở chương 3–4, nằm trong `building_b.tscn`) dừng lúc 4 giờ, ba kim là node riêng xoay quanh trục đồng hồ.
  Đèn bàn và ghế nhựa là đồ phòng 407 dùng lại.
- **Cầu thang:** va chạm của mỗi vế là một dốc trơn (không bậc). Bậc nhìn thấy đặt sao cho **mặt bậc ở giữa bậc
  nằm đúng trên dốc** (đo được lệch tối đa ghi trong test); ở mũi bậc bậc cao hơn dốc 7,5 cm, ở chân bậc thấp hơn
  7,5 cm (dốc không thể khớp bậc ở mọi điểm). Vế 3B thoát hiểm có 12 bậc như hình PS1 cũ (1,65 m / 0,15 làm tròn
  lên 12 do số thực), các vế khác 11.
- **Tầng trên tầng 4:** không có va chạm nào trên cao, nên phần chặn được dựng ngoài tầm với: chiếu nghỉ trung gian
  ở 1,65 m, vế lên tầng 5, sàn chiếu nghỉ tầng 5 (làm trần cho tầng 4), vế từ tầng 4 đi lên gãy mất 40 % phía dưới
  (treo trên giếng thang), đống đổ trong hộp `UpperRubble` chặn lối lên. Tường được nâng tới 6,3 m và có mái.
- **Cửa thoát hiểm:** lỗ cửa rộng 3,8 m nên làm hai cánh. Cánh chính treo trên `FireDoor/Leaf` (trục cũ, va chạm
  cũ); cánh phụ `FireDoor/LeafB` chỉ là hình, `door.gd` xoay nó ngược chiều khi mở để cả hai áp vào hai bên
  hành lang. `FireDoor/Leaf/Lock` (gốc ở lỗ khoá) và `FireDoor/Leaf/Handle` (gốc ở trục tay gạt) là node riêng.
- **Đoạn sập (thoát hiểm, tầng 2 → 1):** vế 2A còn 40 % trên cùng, một tấm sàn gãy nghiêng tựa xuống tường sau,
  đống đổ nén chặt trong hộp `Collapse`, không lấn ra chiếu nghỉ tầng 2 hay vế 3B. Tầng 1 dưới gầm có sàn bê tông
  và mảnh vỡ phẳng.
- **T-258, tường đông giếng thang chính ở tầng 4:** ở chương 3–4, nhà vệ sinh tầng 4 (T-256) đứng sát tường này.
  Mặt trong tường tây nhà vệ sinh ở x 0,1, nhưng hộp PS1 `MainStairs/Wall0.08…` và khối `W1OldWall` trên 2,74 m
  tới x 0,16, nên lấn 6 cm vào phòng. Giờ, ở tầng 4 (y 0…3,05) và ngay cạnh nhà vệ sinh (z −5…−0,2), tường chỉ tới
  x 0,1:
  - hộp PS1 tách làm ba: tầng 1–3 giữ nguyên `Wall0.08…`, tầng 4 cạnh nhà vệ sinh là `EastWall4`, tầng 4 phía sau
    nhà vệ sinh là `EastWall4Back` (vẫn dày 0,16);
  - trong `main_stairs.glb`, khối trên 2,74 m và mặt đầu tường ở z −0,197 tách theo cùng cách (`build_stairs.py`:
    `WASHROOM_FACE`, `WASHROOM_Z`, `FLOOR4_Y`);
  - mặt phía cầu thang (x 0, lớp trát ở x −0,103) không đổi;
  - cầu thang thoát hiểm không đổi: tường của nó ở x 43,84 trùng mặt trong phòng 408, không lấn.
  Test: `game/tests/levels/test_t258_main_stairs_wall.gd`. Ảnh: chép `capture_t258.gd` vào `game/_probe_tmp/` như
  trên, chạy `godot --path game res://_probe_tmp/capture_t258.tscn -- --tag=after`; ảnh ra
  `../previews/floor4_rest/t258_*.jpg`, ghép bằng `make_compare_t258.py`.

Nguồn và giấy phép: `game/assets/models/graphics_pilot/realistic_map/CREDITS.md`.
