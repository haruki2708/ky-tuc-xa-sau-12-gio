# T-216 — Sửa 3 lỗi nhà tắm phòng 407 sau G3
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: lane B
- Phụ thuộc: D-103…D-106 trên `main` (`75c526e` trở đi). Quyết định giao: **D-107** (chủ dự án chọn giao lane B).
- Nhánh: `lane-b/T-216-bathroom-fixes` từ `origin/main` mới nhất.

## Chủ dự án báo (chơi thử build 20:28, 14/10)
> "phòng tắm có vẻ lỗi, rẻ lau thì vẫn là ps1 lại được đặt trên bồn rửa mặt (này là lỗi à), và bảng điều khiển lại sau vòi hoa sen khiến tôi không thể thấy được (nên đặt cạnh vòi hoa sen) và 1 góc tường của nhà tắm bị nhấp nháy do lỗi (khắc phục lỗi này)"

## Nguyên nhân integrator đã dò (kiểm lại trước khi sửa)
Toạ độ là toạ độ cục bộ của `Room407` (gốc ở góc tường cửa/tường tây; tường cửa z = 0, tường sau z = −6,925; nhà tắm x 5,375…7,9, z −4,075…−6,925).

1. **Giẻ lau PS1 trên bồn rửa mặt.** Đây là **giẻ của chương 2**, vật người chơi cầm đi để bịt miệng xác (N3):
   - Điểm neo `Anchors/RagSpot` ở (5,65; 0,88; −5,0), trong `scenes/levels/room407/room407_anchors.tscn`. Bên dưới có `Model` = `scenes/levels/ch1_models/rag.tscn` (hình PS1).
   - `chapter2_director.gd` gắn `carry_item` vào điểm neo này. Khi người chơi cầm giẻ thì ẩn `Model`; khi thả thì hiện lại.
   - Bồn rửa mới (`Sink`, placements.json) đặt ở (5,55; 0,36; −5,0), nên điểm neo cũ rơi vào lòng bồn.
   - Bản chơi giữ hình PS1 vì `room407.gd` để `Anchors` trong `KEEP_PS1`.
   - Ngoài ra còn một giẻ PS1 thứ hai ở `Details/CleaningRag` (1,22; 0,016; −4,3). Giẻ này chỉ để trang trí (T-154) và cũng đang nằm trong `KEEP_PS1`.
2. **Bảng điều khiển sau vòi sen.**
   - Điểm neo `Anchors/ShowerScreen` ở (6,18; 1,45; −6,78), cũng trong `room407_anchors.tscn`.
   - Chương 2 gắn vào đây màn hình LCD (`ui/shower/shower_screen.tscn`) và vùng lau hơi nước (`scenes/interaction/shower_screen.tscn`).
   - Hai nút chọn `Anchors/ShowerYes` (6,07; 1,20; −6,76) và `Anchors/ShowerNo` (6,29; 1,20; −6,76) nằm ngay dưới bảng.
   - Vòi sen mới `Shower` ở (6,18; 0,8; −6,69) đứng ngay phía trước nên che mất cả bảng lẫn hai nút.
3. **Góc tường nhà tắm nhấp nháy.** Nghi do hai mặt phẳng trùng nhau, chưa xác nhận góc nào:
   - Trong `art_source/graphics_upgrade/room407_furnished/build_lived_in.py`, hàm `bath_tiles()`: `CapWest`/`CapEast` chạy hết chiều z, còn `CapBack`/`CapFront` chạy hết chiều x. Mặt trên các nẹp này cùng nằm ở y ≈ 1,806, nên chồng lên nhau ở 4 góc.
   - Mặt sau của gạch trùng mặt tường vỏ phòng.
   - Các decal ẩm/mốc chạm góc.
   - Phải tìm đúng góc trên ảnh chụp trước khi sửa.

## Việc cần làm
1. **Giẻ lau (chương 2):**
   - Làm giẻ hình mới, gần chân thực: vải gấp/vắt, texture CC0 có ghi nguồn. Dùng Blender (`D:\Tools\Blender\5.2.2`) hoặc đề xuất prompt Tripo cho chủ dự án.
   - Đặt giẻ ở chỗ hợp lý trong nhà tắm, nhìn thấy và với tới được, không nằm trong lòng bồn. Ví dụ: vắt trên mép bồn, trên giá khăn `TowelRack`, hoặc trên kệ `BathShelf`. Chọn chỗ không bị đồ khác che.
   - Giữ tên `Anchors/RagSpot`, `Model` và luồng cầm/thả của chương 2.
   - Thay hình giẻ trang trí `Details/CleaningRag` bằng cùng model mới.
   - Cập nhật `test_ch2_props.gd` dòng kiểm `RagSpot/Model` nếu đổi cảnh model.
2. **Bảng điều khiển:**
   - Dời `Anchors/ShowerScreen` cùng `ShowerYes`/`ShowerNo` (giữ vị trí tương đối: hai nút dưới bảng, Có bên trái, Không bên phải) ra **cạnh vòi sen**: trên tường sau hoặc tường bên, ngang tầm vai (y ≈ 1,4–1,5). Mặt bảng quay vào nhà tắm, cách mặt gạch 3–5 mm, không trùng mặt gạch.
   - Đứng ở chỗ người chơi tắm hoặc ở cửa nhà tắm phải nhìn thấy, ngắm trúng và lau được.
   - Giữ `metadata/size`, node `Surface`, hướng mặt bảng như contract chương 2.
3. **Góc nhấp nháy:**
   - Chụp các góc nhà tắm (cả 4 góc trên và góc dưới) để tìm đúng chỗ nhấp nháy.
   - Sửa tận gốc: ưu tiên sửa `build_lived_in.py` rồi xuất lại `bath_tiles.glb` bằng Blender, không vá tạm trong Godot.
   - Ghi rõ góc nào và nguyên nhân thật.
4. **Kiểm:**
   - Thêm test, gợi ý file `game/tests/levels/test_room407_bathroom_fixes.gd`:
     - `RagSpot` không nằm trong khối bao của `Sink`;
     - `ShowerScreen` không bị khối bao `Shower` che theo tia nhìn từ chỗ đứng tắm (6,18; 1,6; −5,6) và từ cửa nhà tắm;
     - các nẹp gạch không chồng nhau.
   - Các test chương 2 cũ (`test_ch2_props`, `test_ch2_interactions`, `test_chapter2*`) phải đạt.
   - Chụp ảnh trước/sau bằng `scenes/levels/room407/room407_g3_capture.tscn -- --g3-capture` (Forward+). Có thể thêm góc nhìn trong `VIEWS`, ví dụ `shower_panel`, `rag`, góc bị nhấp nháy.

## Được phép sửa
- `game/scenes/levels/room407/room407_anchors.tscn`: chỉ `RagSpot`, `ShowerScreen`, `ShowerYes`, `ShowerNo`.
- `game/scenes/levels/room407/room407_details.tscn`: chỉ `CleaningRag`.
- Hai file mới: model/texture giẻ trong `game/assets/models/graphics_pilot/room407_furnished/` và nguồn trong `art_source/graphics_upgrade/room407_furnished/`.
- `art_source/graphics_upgrade/room407_furnished/build_lived_in.py` (`bath_tiles`) và file `bath_tiles.glb` xuất lại.
- `game/data/room407/placements.json` và `decals.json`: chỉ các dòng trong nhà tắm.
- `game/scenes/levels/room407/room407.gd`: **chỉ** hai danh sách `KEEP_PS1`/`REPLACED_PS1`, nếu cần.
- `game/scenes/levels/room407/room407_g3_capture.gd`: chỉ thêm góc nhìn.
- Test: `game/tests/levels/` và dòng `RagSpot/Model` trong `game/tests/levels/test_ch2_props.gd`.
- `CREDITS.md` nếu thêm texture.

Cần sửa ngoài danh sách trên (ví dụ `chapter2_director.gd`, `cables.gd`, UI chương 2) thì ghi "Yêu cầu thay đổi" trong Handoff, không tự sửa.

## Không được
- Không đổi luật, lời thoại, thời gian, cách chơi chương 2 (cầm giẻ, chọn tắm, lau hơi nước).
- Không đổi va chạm hoặc đường đi trong nhà tắm, trừ khi bắt buộc để với tới bảng hoặc giẻ (khi đó ghi rõ).
- Không đo FPS, không chạy bot, không tiêu credit Tripo khi chủ dự án chưa đồng ý.

## Bàn giao
- Full `pwsh tools/test.ps1` rồi `pwsh tools/check.ps1`. Xin lượt Godot qua integrator trước khi chạy.
- Commit nhỏ "T-216: …", push nhánh, không push `main`.
- Handoff gồm:
  - vị trí mới của giẻ và bảng (toạ độ);
  - góc nhấp nháy và nguyên nhân thật;
  - danh sách ảnh trước/sau;
  - dòng RESULT test và check;
  - commit hash;
  - phần chưa kiểm.

## Handoff
_(lane B điền)_

## Review
_(integrator điền)_
