# T-216 — Sửa 3 lỗi nhà tắm phòng 407 sau G3
- Lane: B (Môi trường và 3D) | Trạng thái: done (D-109) | Agent: lane B; ghép: integrator (Claude làm thay commit, lane B hết hạn mức)
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
### Lane B — 14/10/2026

- Workspace `D:\GAME_WORK\lane-b`, nhánh `lane-b/T-216-bathroom-fixes`, gốc `origin/main` = `45fa1c4`. Đã cất 129 file staged T-213 vào `stash@{0}` với thông điệp **`T-213 staged leftovers, superseded by D-092`**, kiểm workspace sạch rồi fetch/tạo nhánh. Stash và nhánh T-213 vẫn giữ nguyên; không đưa phần cũ vào T-216.
- Chủ dự án đã xác nhận **“Đã cấp lượt, cứ chạy”** cho Forward+ trước/sau và full test/check trong phiên này. Mọi lượt dùng APPDATA riêng dưới `build/t216/userdata` (test runner còn tách UUID riêng).

**Đã sửa**

| Điểm/đồ | Vị trí Room407-local mới (m) | Hướng / ghi chú |
|---|---|---|
| `Anchors/RagSpot` | `(7.827, 1.509, -5.3)` | yaw 90°, nằm trên giá khăn, toàn bộ hình giẻ ngoài AABB bồn |
| `TowelRack` trong placements | `(7.892, 1.15, -5.3)` | hạ 15 cm để mặt giẻ nhìn thấy ở tầm mắt 1,6 m; hình trang trí không có collider |
| `Anchors/ShowerScreen` | `(5.387, 1.45, -6.0)` | yaw 90°, mặt quay +X vào nhà tắm; cách mặt gạch tây x=5.383 đúng 4 mm |
| `Anchors/ShowerYes` | `(5.407, 1.20, -5.89)` | yaw 90°, bên trái khi nhìn bảng |
| `Anchors/ShowerNo` | `(5.407, 1.20, -6.11)` | yaw 90°, bên phải khi nhìn bảng |

- Giẻ: `game/assets/models/graphics_pilot/room407_furnished/cleaning_rag.glb`, dùng chung tại `RagSpot/Model` và `Details/CleaningRag`. Hai lớp vải gấp, nếp nhăn, viền cuốn; Blender 5.2.2, texture Rough Linen CC0 đã có. Nguồn `art_source/graphics_upgrade/room407_furnished/build_cleaning_rag.py`, `cleaning_rag.blend`, `CREDITS.md`. 3.200 tam giác, 1 material, 3 map 1024², GLB 3.013.404 byte; kèm map/import do Godot tách ra. Không dùng Tripo hay nguồn mới không rõ license.
- Giữ `RagSpot`, `Model`, `Surface`, `metadata/size`, quan hệ nút so với bảng `(-/+0.11, -0.25, +0.02)` trong hệ trục bảng. Luồng cầm/thả/lau/chọn nước dùng script hiện hành; không đổi collision, nav, thời gian, luật, UI, ánh sáng, shader hoặc `KEEP_PS1`.
- Góc lỗi được kiểm bằng ảnh cận **đông-bắc**, thêm camera lệch 2 cm; hình học GLB gốc có 3 giao nẹp: tây-bắc (`CapWest/CapBack`), đông-bắc (`CapEast/CapBack`), đông-nam (`CapEast/CapFront`). Mặt trên đồng phẳng y ≈ 1.812 m, giao hộp 14×14 mm kèm mép vát; tây-nam là cửa nên không có cặp giao như giả thuyết 4 góc ban đầu. Sửa tận nguồn `build_lived_in.py::bath_tiles`: nẹp sau/trước dừng trước nẹp bên 1 mm; sửa tâm gạch `TilesFront` để hết lấn 4 mm vào gạch đông. Xuất lại **chỉ bàn giao thay đổi `bath_tiles.glb`**, 1.032 tam giác, 7.372.100 byte; đo GLB trước/sau cho **3 → 0 cặp giao**. Không đủ thông tin để khẳng định góc đông-bắc là chính góc chủ dự án đã thấy trong lần chơi báo lỗi.

**Ảnh và bằng chứng**

- `art_source/graphics_upgrade/room407_furnished/previews/t216/README.md`: danh mục/link toàn bộ ảnh; `before/` và `after/` mỗi bên **30 ảnh 1280×720**, Forward+ / RTX 3050 Laptop, cùng camera. Gồm giẻ, bảng từ chỗ tắm/cửa, 4 góc trên + 4 góc dưới, cận nẹp và lệch camera. Hai `capture_report.json` có SHA-256; `geometry_report.json` có bounds nẹp và hash/size/tam giác GLB.
- Góc chính: `t216_rag_rack_{torch,tube}.png`, `t216_panel_side_{torch,tube}.png`, `t216_panel_door_{torch,tube}.png`, `t216_cap_ne_{close,shift}_torch.png` trong cả hai thư mục. Không chỉnh ảnh. Đã khôi phục nguyên các ảnh G3 cũ sau lượt chụp.
- Capture dùng `room407_g3_capture.tscn -- --g3-capture`; runner tạm chọn các `t216_` trong `VIEWS`. Mỗi lượt còn tự chụp 16 ảnh giấy: **`RESULT: room407 G3 capture 46 images PASS`**, giữ lại 30 ảnh thuộc T-216. Chỉ thêm góc vào script capture chính.

**Kiểm tra**

- Test mới `game/tests/levels/test_room407_bathroom_fixes.gd`: model giẻ ngoài bồn/ở trên rack/nhìn thấy; ray lấy giẻ qua collision thật; toàn mặt bảng không xuyên AABB vòi sen; khoảng cách mặt gạch; hướng và vị trí hai nút; ray 2 m tới vùng lau/nút từ `(6.18,1.6,-5.6)` và `(6.0,1.6,-4.35)`; lau đủ một giây từ cả hai chỗ; 4 nẹp không giao thể tích.
- Targeted trước khi hạ rack: **`RESULT: 4 passed, 0 failed`**. Full test sau khi hạ rack: **đang chạy, chưa kết luận**.
- Full `pwsh tools/test.ps1`: **đang chạy**. `pwsh tools/check.ps1`: **chờ full test**. Log ở `build/t216/`.
- Commit: **chưa commit; chờ full test/check**.

**Chưa kiểm / yêu cầu thay đổi**

- Chưa chơi tay chương 2 trên build xuất; cần chủ dự án xác nhận hình giẻ, góc từng gặp nhấp nháy và cảm giác lau/bấm khi chơi. Ảnh G3 chỉ có nền bảng; LCD được director chương 2 gắn trong bản chơi. Không chạy bot, không đo FPS, không export build.
- Giẻ trên tay vẫn dùng placeholder do `chapter2_director.gd`/`carry_item.tscn` hiện hành điều khiển; card này chỉ cho thay model tại điểm neo và giẻ trang trí. Nếu muốn thay cả hình cầm trên tay, integrator/lane A xử lý riêng; B không sửa file ngoài phạm vi.
- Không có yêu cầu core bắt buộc cho bản sửa này. Chờ full test/check trước khi bàn giao.

## Review
**Integrator, 14/10/2026 (D-109), nhận.** Lane B hết hạn mức sau khi sửa xong và đã khởi động full test/check; lượt đó tự chạy hết trong `D:\GAME_WORK\lane-b`: **`RESULT: 780 passed, 0 failed`**, **`RESULT: check 0 error(s)`** (log `build/t216/` của lane B). Claude làm thay phần commit: chép nguyên các file thay đổi/mới của lane B sang `D:\GAME_DEMO` (không sửa thư mục lane B; bỏ `game/default_bus_layout.tres` do test tự ghi), không đổi nội dung.
- Đã xem ảnh trước/sau: bảng + nút Có/Không trên tường tây nhà tắm nhìn rõ từ chỗ tắm và từ cửa; giẻ trên giá khăn; nẹp góc đông-bắc hết chồng mặt (còn khe nối 1 mm nhìn được khi soi gần, chấp nhận).
- Đúng phạm vi card; không đổi `KEEP_PS1`, core, luật chương 2. Hình giẻ khi cầm trên tay vẫn là placeholder của `carry_item` (ngoài phạm vi, ghi lại để xử lý khi làm G4/đồ cầm tay).
- Còn chờ chủ dự án chơi tay chương 2 (lấy giẻ, lau bảng, chọn Có/Không) và xác nhận góc nhấp nháy đã hết.