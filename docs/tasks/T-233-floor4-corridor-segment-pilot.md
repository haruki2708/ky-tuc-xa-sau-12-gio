# T-233 — Hành lang tầng 4, lượt 1: mẫu đoạn 406–407 dựng bằng Blender theo phong cách phòng 407
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141)
- Nhánh: `lane-b/T-233-floor4-corridor-segment-pilot` từ `origin/main` mới nhất.
- Quyết định giao: **D-142** (chủ dự án chọn 07/11). Tiếp nối [T-229](T-229-floor4-corridor-survey.md): khảo sát, ảnh hiện trạng và kế hoạch 4 lượt ở `art_source/graphics_upgrade/floor4_corridor/PLAN.md`.
- Lượt này làm **mẫu trong cảnh thử riêng**. Không thay scene chơi được. Chủ dự án duyệt ảnh xong mới nhân rộng (lượt 2).

## Chủ dự án chọn (07/11/2026)
- "Hành lang tầng 4 thì thiết kế trong **Blender** sao cho **giống kiểu đồ họa trong phòng 407**, làm xong **kèm ảnh** để tôi duyệt."
- **Phương án A cả 4 mục** của `PLAN.md` mục 4:
  1. **Tường:** kem xám, bẩn nhẹ theo chân tường và quanh chỗ tay chạm, nối bảng màu vỏ phòng 407. Không tự thêm máu hay ký hiệu truyện.
  2. **Cửa phòng:** dùng lại mẫu cửa Tripo phòng 407 (`game/assets/models/graphics_pilot/room407_shell/doors/door_room.glb`, tay gạt `door_lever.glb`), giữ bản lề và khẩu độ từng cửa.
  3. **Mặt ngoài:** giữ hành lang mở, lan can dựng bằng Blender. Không thêm cửa sổ, kính.
  4. **Đồ trang trí:** giữ đúng đồ đang có (bảng tin, loa, đồ phơi, dép, xô). Lượt này chưa thay đồ.

## Việc cần làm
1. **Đoạn mẫu:** hành lang quanh cửa 406 (X=28) và 407 (X=32), khoảng X=26…34 trên toàn bề ngang Z=0…4, sàn tới trần:
   - tường phía phòng và nẹp chân tường, khung cửa, ngưỡng cửa;
   - sàn gạch có ron, trần, máng đèn tuýp (giữ nguyên node đèn và vị trí nguồn sáng);
   - lan can và thanh đứng phía ngoài;
   - cửa 406 dùng mẫu cửa Tripo 407, gắn đúng `Hinge`/`Leaf` hiện có (chiều mở cửa phòng khác cửa 407: xem `PLAN.md` mục 5).
2. **Cách dựng:** script Blender tái tạo được, đặt trong `art_source/graphics_upgrade/floor4_corridor/` (ví dụ `build_segment.py`), theo kỹ thuật vỏ phòng 407 (`art_source/graphics_upgrade/room407_shell/README.md`): UV theo mét, bản đồ bẩn, shader `game/rendering/room407_shell.gdshader` (bản tối ưu D-132), texture CC0 đã có trong `room407_shell/texture_sources.json`, `room407_corner/texture_sources.json`. Atlas bẩn riêng cho hành lang, không dùng lại atlas định vị giường và nhà tắm của 407.
3. **Cảnh thử:** `game/scenes/levels/floor4/corridor_g5_pilot.tscn` + `.gd`. Instance `floor4.tscn` nguyên vẹn, trong cảnh thử ẩn hình PS1 của đoạn mẫu và đặt hình mới vào. **Không sửa `floor4.tscn`, `corridor.tscn`** và các scene chơi khác.
4. **Giữ hợp đồng gameplay:** mọi node trong bảng "không được đổi tên hoặc dời" (`PLAN.md` mục 2) giữ nguyên tên, transform, khối va chạm. Hình mới nằm đúng trong khối va chạm cũ; không thêm vật cản trên lối đi (capsule 0,3 m, `test_wide_corridors`).
5. **Ảnh để chủ dự án duyệt** (1080p, Forward+, có cửa sổ), cùng góc với ảnh hiện trạng T-229 để so:
   - góc 03 và 04 (trước cửa 407: đêm và đèn pin);
   - góc 01 (đầu tây nhìn dọc hành lang), để thấy đoạn mẫu nằm giữa phần PS1;
   - cận mép cửa 406, cận lan can, cận chân tường;
   - mỗi góc một ảnh `after_*.jpg` và một ảnh ghép trước/sau `compare_*.jpg` trong `art_source/graphics_upgrade/floor4_corridor/previews/`.
   Mở rộng `corridor_capture.gd` (thêm chế độ cảnh thử) hoặc viết cảnh chụp mới, theo mẫu `room407_g3_capture.gd`.
6. **Test** trong `game/tests/levels/`: cảnh thử load được; mọi node hợp đồng trong `PLAN.md` mục 2 còn đủ, đúng transform; lối đi capsule vẫn thông.

## Được phép sửa
- `art_source/graphics_upgrade/floor4_corridor/` (script, `.blend` nếu cần, `previews/`, `README.md`, `CREDITS.md`).
- `game/assets/models/graphics_pilot/floor4_corridor/` (mới), `game/assets/textures/` (texture mới của hành lang).
- `game/scenes/levels/floor4/corridor_g5_pilot.tscn`, `.gd` (mới), `corridor_capture.gd`, `.tscn`.
- `game/rendering/` (chỉ thêm; không đổi shader 407 đang dùng trong bản chơi).
- `game/tests/levels/` (test mới).
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa scene chơi được: `floor4.tscn`, `corridor.tscn`, `duty_desk.tscn`, `washroom.tscn`, `floor4.gd`, `door407.gd`, phòng 407, campus.
- Không tiêu credit Tripo (lượt này dùng lại cửa 407). Không tải asset chưa rõ giấy phép (chỉ CC0, CC-BY).
- Không đo FPS, không chạy bot. Ghi số tam giác, số vật liệu, kích thước texture của đoạn mẫu để lượt sau ước tính.
- Không tự quyết thêm về hình dáng ngoài phương án A: chỗ nào phương án A chưa nói rõ thì đưa 2–3 lựa chọn kèm ảnh trong Handoff.

## Checklist hoàn thành
- [x] Script Blender tái tạo được đoạn mẫu; GLB mỗi file ≤ 10 MB, qua LFS, có `.import`
- [x] Cảnh thử `corridor_g5_pilot` có đoạn mẫu 406–407, phần còn lại giữ PS1
- [x] Ảnh `after_*` và `compare_*` 1080p đủ các góc mục 5
- [x] Node hợp đồng giữ nguyên, có test; lối đi thông
- [x] `CREDITS.md` ghi nguồn texture, mẫu cửa Tripo (D-084)
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [x] Handoff trung thực, có commit hash, số tam giác/vật liệu/texture

## Cách kiểm tra
- Chạy cảnh chụp có cửa sổ, Forward+ (không `--headless`).
- Integrator xem ảnh, đưa chủ dự án duyệt. Duyệt xong mở lượt 2 (nhân rộng cả hành lang, cửa 401…408) theo `PLAN.md` mục 7.

## Handoff (agent điền)
### Phiên 2026-11-08 (lane B, tài khoản Claude, D-141)
Nhánh `lane-b/T-233-floor4-corridor-segment-pilot`, rebase lên `origin/main` `e744649` (đã có T-231, T-232, T-234). Commit nội dung: `46819d9` (đoạn mẫu Blender, bản đồ bẩn, GLB), `cf3f831` (cảnh thử, chế độ chụp, test), `dcb6e62` (ảnh, README, CREDITS); card này ở commit ngay sau. Chưa merge, chưa có PR.

**Ảnh để chủ dự án duyệt** (1080p, Forward+, có cửa sổ, đèn của scene không chỉnh, không chạy đạo diễn chương), trong `art_source/graphics_upgrade/floor4_corridor/previews/`:
- Xem nhanh tất cả: `compare_overview.jpg` (mỗi hàng: trái PS1, phải mẫu).
- Góc T-229: `compare_03_door407_night.jpg`, `compare_04_door407_torch.jpg`, `compare_01_west_night.jpg` (thêm `compare_02_east_night.jpg`). Ở góc 01 đoạn mẫu cách camera 25 m nên rất nhỏ; vì vậy thêm góc gần hơn `compare_21_segment_in_corridor_night.jpg` để thấy đoạn mẫu nằm giữa phần PS1.
- Cận mép cửa 406: `compare_13_door406_night.jpg`, `compare_14_door406_torch.jpg`, cửa 406 đang mở `compare_19_door406_open_torch.jpg`.
- Cận lan can: `compare_15_railing_night.jpg`, `compare_16_railing_torch.jpg`. Cận chân tường: `compare_17_wall_base_torch.jpg`. Trần và máng đèn: `compare_18_ceiling_lamp_night.jpg`.
- Mỗi góc có `after_*.jpg`; `before_*.jpg` của 01–04 là ảnh T-229, các góc 13–21 chụp trước/sau trong cùng một lượt. Danh sách camera: `previews/g5_capture_report.json`.

**Đã làm**
- Đoạn mẫu x 26…34, toàn bề ngang z 0…4, sàn tới trần, dựng bằng script Blender tái tạo được (`build_segment.py`, số đo chung ở `segment_layout.py`), theo kỹ thuật vỏ phòng 407: UV1 theo mét cho texture CC0, UV2 vào atlas bản đồ bẩn riêng của hành lang (`make_segment_masks.py`), shader `game/rendering/room407_shell.gdshader` dùng nguyên (không sửa, không thêm file trong `game/rendering/`).
  - Tường phía phòng: vữa sơn kem của phòng 407 nhuộm xám nhẹ (phương án A, một màu, bỏ dải sơn xanh chân tường của bản PS1). Bẩn: chân tường (nước lau, giày), vệt tay nhạt phía chốt mỗi cửa, sứt sơn cạnh nẹp, ẩm chân tường từng mảng. Không máu, không chữ, không ký hiệu.
  - Gạch chân tường 10 cm, sàn gạch 40 cm có ron bẩn, làn đi mòn bóng, mép ngoài ẩm do mưa hắt. Trần vữa sơn có bồ hóng trên máng đèn, dải ẩm ở mép ngoài, một vết dột, vài vết nứt.
  - Khung cửa 406, 407 như cửa phòng 407 (lót khung gỗ sơn xanh, nẹp 7 cm, ngưỡng đá). Cửa 406 dùng cánh Tripo `door_room.glb` và 2 tay gạt `door_lever.glb` của phòng 407 (không tiêu credit), treo vào `LockedDoor_406/Hinge` có sẵn: `RoomDoor.set_open()` vẫn mở cánh ra hành lang như bản PS1; có nẹp chặn và 3 bản lề nhìn từ hành lang. Cửa 407 giữ nguyên cánh Tripo đang có trong bản chơi, chỉ thêm khung phía hành lang.
  - Máng đèn tráng men 2 bóng tuýp như phòng 407 dưới đèn 406 và 407; node đèn, vị trí nguồn sáng giữ nguyên; bóng tuýp sáng, tắt, chập chờn theo đèn (đạo diễn chương vẫn điều khiển đèn). Máng mới không đổ bóng nên mất luôn dải tối dọc trần mà hộp đèn PS1 tạo ra.
  - Lan can thép sơn xanh (Green Metal Rust CC0): trụ vuông 50 mm cách 2 m, tay vịn ống 50 mm ở 1,07 m, thanh dưới, song đứng. Hai biến thể (xem mục lựa chọn).
- Cảnh thử `game/scenes/levels/floor4/corridor_g5_pilot.tscn` + `.gd`: instance `floor4.tscn` nguyên vẹn, có người chơi, HUD, menu tạm dừng như `floor4_playtest.tscn`. Phím **G** bật/tắt đoạn mẫu (so với PS1), **R** đổi lan can.
- `corridor_capture.gd`: thêm chế độ `-- --g5` chụp đoạn mẫu; chế độ mặc định T-229 giữ nguyên. `run_stage.ps1`: thêm bước `g5` (import lại rồi chụp), `g5test`, `full` (full test rồi check trong một lượt Godot), log ở `build/floor4_corridor/`.
- `make_compare.py` ghép ảnh trước/sau; `README.md`, `CREDITS.md` (texture CC0 dùng lại, cánh/tay gạt Tripo theo D-084 trỏ về hồ sơ `room407_shell/CREDITS.md`, khai báo AI cho Steam).

**Không đổi gameplay** (test `game/tests/levels/test_corridor_g5.gd`, 7 test)
- Không sửa `floor4.tscn`, `corridor.tscn`, `floor4.gd`, `door407.gd` hay scene chơi nào. Cảnh thử chỉ ẩn mesh PS1 của đoạn mẫu (cắt sàn, mái, lan can dài 44 m thành phần ngoài mẫu); không xóa, dời, đổi tên node nào; không thêm va chạm (khung, lan can, máng đèn chỉ là hình).
- Test so toàn bộ node của Floor4 khi có và không có đoạn mẫu (tên, transform, va chạm, đèn, navigation, âm thanh); hình mới không lấn vào lối đi; capsule 0,3 m đi thông dọc hành lang ở z 1 và z 3 và rẽ vào cửa 407; cánh 406 mở/đóng theo `RoomDoor`; bật/tắt đoạn mẫu; đổi lan can; bóng tuýp theo đèn; cảnh thử load được.

**Số liệu cho lượt sau** (`art_source/graphics_upgrade/floor4_corridor/geometry_report.json`)
| Phần | Tam giác | Vật liệu | GLB |
|---|---:|---|---:|
| Vỏ (tường, sàn, trần, gạch chân tường) | 120 | 4 (shader vỏ 407) | 18 KB |
| Khung 2 cửa, ngưỡng, bản lề | 2 280 | 3 | 125 KB |
| 2 máng đèn | 2 744 | 3 | 153 KB |
| Lan can A1 (song 12,5 cm) / A2 (nhịp 0,5 m) | 2 080 / 1 456 | 1 | 165 / 88 KB |
| Cánh Tripo 406 + 2 tay gạt (dùng lại) | 5 057 + 2 × 1 372 | 1 + 1 | (của 407) |
- Đoạn 8 m với lan can A1: 7 224 tam giác hình mới + 7 801 của cánh và tay gạt 406 = khoảng 15 000. Cả hành lang 44 m (8 cửa) ước khoảng 5,5 lần phần dựng mới; cánh Tripo nhân theo số cửa.
- Vật liệu: 11 vật liệu tạm `Corr*` trong GLB, gán lúc chạy: 4 ShaderMaterial (shader vỏ 407), 7 ORMMaterial3D/màu trơn. Không chép texture vào GLB.
- Texture mới: 3 bản đồ bẩn RGBA 2048×1024 (`mask_walls/floor/ceiling.png`, 0,28/0,84/0,59 MB, import BPTC không mipmap như mask 407), 245–253 px/m.
- Texture dùng lại, không chép: Painted Plaster Wall 2048² (tường, trần, như phòng 407), Floor Tiles 08 1024² (sàn, gạch chân tường), Distressed Painted Planks 1024² và màu khung xanh 1024² (khung cửa), Green Metal Rust 1024² (lan can), đá granite 512², noise 512².
- Khác `PLAN.md` mục 6: bảng nguồn ghi Plastered Wall 04 cho tường hành lang; mẫu dùng Painted Plaster Wall vì đó là vữa tường phòng 407 (chủ dự án muốn giống 407) và repo chỉ có Plastered Wall 04 bản nhỏ dùng cho đồ đạc. Cùng nguồn Poly Haven CC0, đã ghi trong `CREDITS.md`.

**Lựa chọn cần chủ dự án quyết** (phương án A chưa nói rõ)
1. **Mật độ song lan can**, ảnh `compare_20_railing_variants.jpg`:
   - **A1 (mặc định của mẫu, đề xuất):** song đứng cách 12,5 cm. Giống lan can ký túc xá thật (khe hẹp, không lọt người), nhìn chắc, hợp với khung và cửa kiểu 407. Nhược: che bớt tầm nhìn ra sân, 2 080 tam giác mỗi 8 m.
   - **A2:** giữ nhịp 0,5 m như bản PS1. Thoáng, nhìn ra sân rõ hơn, 1 456 tam giác. Nhược: trông thưa, ít thật.
   - Đổi trong cảnh thử bằng phím R. Lượt 2 chỉ giữ một kiểu.
2. **Đồ giữ PS1 trong lượt này** (theo mục 4 của phương án A): biển số phòng (hộp xanh trên cửa), đồ phơi, dây phơi, xô, dép, bảng tin, loa, nội thất phòng 406. Ở các ảnh cận, biển số PS1 lộ rõ nhất; đề xuất thay biển số cùng lúc với cửa ở lượt 2 (cần chủ dự án đồng ý vì là đồ trang trí).

**Còn dở / giới hạn đã biết**
- Mép nối đoạn mẫu với phần PS1 ở x 26 và x 34 nhìn rõ (đổi màu tường, sàn, trần). Đây là đoạn mẫu; lượt 2 phủ cả hành lang thì hết.
- Bên trong phòng 406 (thấy khi cửa mở) vẫn là PS1.
- Ảnh đèn pin góc 04 và 16 khác ảnh đêm không nhiều vì vệt đèn rơi phần lớn vào cánh cửa và khoảng trống ngoài lan can.

**Chưa kiểm**: không đo FPS, không chạy bot (card không cho phép). Chưa có người đi thử cảnh thử bằng tay; phím G, R chỉ kiểm qua test gọi hàm, chưa bấm thật.

**Kết quả lệnh** (log trong `build/`, không commit)
- `pwsh tools/test.ps1 -Filter test_corridor_g5`: `RESULT: 7 passed, 0 failed`
- `run_stage.ps1 -Stage g5` (chụp): `RESULT: corridor g5 capture 21 images PASS`; `make_compare.py`: `RESULT: corridor compare sheets 13`
- Full `pwsh tools/test.ps1` (sau rebase, trên đúng nội dung đã commit): `RESULT: 871 passed, 0 failed`
- `pwsh tools/check.ps1` (cùng lượt Godot, `run_stage.ps1 -Stage full` chạy bằng tiến trình pwsh riêng, 03:28–04:02 ngày 08/11): `RESULT: check 0 error(s)`
- Sau đó `git checkout -- game/default_bus_layout.tres`.
- Hai lần trước, lệnh nền chờ khóa bị Claude Code dừng vì máy thiếu RAM; cả hai lần chưa lấy khóa, không để lại khóa hay tiến trình. Lần chụp ảnh thứ hai (21 ảnh, sau khi sửa bản đồ bẩn tường) đã xong trước khi bị dừng.

**Cách kiểm tra**
```powershell
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage g5test   # test của mẫu (chờ khóa Godot)
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage g5       # chụp lại 1080p
python -B art_source/graphics_upgrade/floor4_corridor/make_compare.py           # ảnh ghép
```
Đi thử: mở `res://scenes/levels/floor4/corridor_g5_pilot.tscn` trong editor, F6; G bật/tắt mẫu, R đổi lan can.

**Yêu cầu thay đổi ngoài phạm vi**: không có.
