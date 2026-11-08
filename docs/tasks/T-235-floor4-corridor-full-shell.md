# T-235 — Hành lang tầng 4, lượt 2: cả hành lang 44 m, cửa 401…408, biển số phòng mới
- Lane: B (Môi trường và 3D) | Trạng thái: done (merge 08/11/2026), chủ dự án duyệt (D-148) | Agent: tài khoản Claude lane B (D-141)
- Nhánh: `lane-b/T-235-floor4-corridor-full-shell` từ `origin/main` mới nhất.
- Quyết định giao: **D-144** (chủ dự án duyệt lượt 1 ngày 08/11). Tiếp nối [T-233](T-233-floor4-corridor-segment-pilot.md) (mẫu đoạn 406–407) và `PLAN.md` mục 7 lượt 2.
- Lượt này vẫn làm **trong cảnh thử** `corridor_g5_pilot`. Chủ dự án duyệt ảnh xong, integrator mở card đưa vào bản chơi.

## Chủ dự án chọn (08/11/2026)
- "1: tôi duyệt hướng này, 2: lan can tôi chọn A1, 3: thay luôn cùng cửa ở lượt 2."
  1. **Duyệt hướng của mẫu T-233** (tường vữa kem xám, sàn gạch 40 cm, trần, máng đèn, khung cửa kiểu 407): nhân ra cả hành lang.
  2. **Lan can A1:** song đứng cách 12,5 cm. Bỏ biến thể A2 (phím R, file `segment_railing_classic.glb`) khỏi cảnh thử và test.
  3. **Biển số phòng thay cùng cửa trong lượt này** (bỏ hộp xanh PS1).

## Việc cần làm
1. **Vỏ cả hành lang** X=0…44, Z=0…4, sàn tới trần, theo đúng kỹ thuật và vật liệu đoạn mẫu (`build_segment.py`, `segment_layout.py`, shader `room407_shell.gdshader` dùng nguyên). Chia mesh theo đoạn hoặc cụm cửa, dùng chung vật liệu; atlas bẩn mở rộng cho cả hành lang (không lặp một vết bẩn giống hệt ở mọi cửa).
2. **Cửa 401…406 và 408:** khung, nẹp, ngưỡng như cửa 406 của mẫu; cánh `door_room.glb` và tay gạt `door_lever.glb` của phòng 407 (không tiêu credit Tripo), treo vào `LockedDoor_*/Hinge` có sẵn để `RoomDoor` vẫn mở được (chương 3 mở cửa 408 cho xác sống ra). Cửa 407 giữ như mẫu.
3. **Tấm bịt cửa 408 cũ ở X=36** (`Former408Wall`, `Sealed408`): T-190 giữ có chủ đích. Dựng hình bịt hợp phong cách mới (ví dụ khung cửa cũ bị xây/ốp kín), giữ node, vị trí, va chạm. Chỗ nào chưa rõ thì đưa 2–3 lựa chọn kèm ảnh.
4. **Biển số phòng mới** cho 401…408 và tấm bịt X=36 nếu đang có biển: dựng bằng Blender (biển kim loại hoặc nhựa cũ, số in hoặc dập, hợp phong cách 407), **giữ đúng số phòng và vị trí** của `RoomPlate_*` hiện có (`PLAN.md` mục 2, T-190). Số phòng là chữ số, không cần key dịch. Đưa 2 kiểu biển kèm ảnh cận nếu chưa chắc; mặc định một kiểu, ghi lý do.
5. **Máng đèn** cho cả 9 `CorridorLight_*` như mẫu (giữ node đèn, vị trí nguồn sáng, LightHum). Lan can A1 suốt 44 m.
6. **Hai đầu hành lang** X=0 và X=44 (nối cầu thang, `WestEnd`, `EastEnd`): khép vỏ gọn ở chỗ nối; không bịt lối sang cầu thang (chương 3–4 dùng Campus). Cầu thang, bàn trực, nhà vệ sinh chung chưa làm (lượt 3, 4).
7. **Ảnh để chủ dự án duyệt** (1080p, Forward+, có cửa sổ), trước/sau cùng camera, trong `previews/`:
   - góc 01, 02 (nhìn dọc hành lang từ hai đầu), 09, 10 của T-229;
   - cận một cửa 401…406 đóng và mở; cửa 408 đóng; tấm bịt X=36;
   - cận biển số; chỗ nối hai đầu hành lang;
   - ảnh ghép `compare_overview.jpg` như lượt 1.
8. **Test** trong `game/tests/levels/` (mở rộng `test_corridor_g5.gd`): mọi node hợp đồng `PLAN.md` mục 2 giữ nguyên tên, transform, va chạm; capsule đi thông dọc Z=1 và Z=3 cả 44 m, vào cửa 407; mọi `LockedDoor_*` mở/đóng theo `RoomDoor` với cánh mới; cảnh thử load được. Ghi số tam giác, vật liệu, texture của cả hành lang trong Handoff.

## Được phép sửa
- `art_source/graphics_upgrade/floor4_corridor/` (script, `previews/`, `README.md`, `CREDITS.md`).
- `game/assets/models/graphics_pilot/floor4_corridor/`, `game/assets/textures/` (texture mới của hành lang).
- `game/scenes/levels/floor4/corridor_g5_pilot.tscn`, `.gd`, `corridor_capture.gd`, `.tscn`.
- `game/rendering/` (chỉ thêm; không đổi shader 407 đang dùng trong bản chơi).
- `game/tests/levels/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa scene chơi: `floor4.tscn`, `corridor.tscn`, `duty_desk.tscn`, `washroom.tscn`, `floor4.gd`, `door407.gd`, phòng 407, campus.
- Không tiêu credit Tripo, không tải asset chưa rõ giấy phép (chỉ CC0, CC-BY).
- Không đo FPS, không chạy bot. Integrator sẽ xin chủ dự án đo FPS trước khi đưa vào bản chơi.
- Không thêm máu, chữ, ký hiệu truyện. Không đổi số phòng, vị trí cửa, bố trí 408 (T-190).

## Checklist hoàn thành
- [x] Script Blender tái tạo được cả hành lang; GLB mỗi file ≤ 10 MB, qua LFS, có `.import`
- [x] Cửa 401…406, 408 dùng cánh Tripo 407, mở/đóng theo `RoomDoor`
- [x] Biển số mới đúng số, đúng vị trí; tấm bịt X=36 hợp phong cách
- [x] Lan can A1 suốt 44 m; bỏ biến thể A2
- [x] Ảnh `after_*`, `compare_*`, `compare_overview.jpg` đủ các góc mục 7
- [x] Test node hợp đồng, capsule, cửa đạt
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [x] Handoff trung thực, có commit hash, số tam giác/vật liệu/texture

## Cách kiểm tra
- Chạy cảnh chụp có cửa sổ, Forward+ (không `--headless`). Chạy test/check dài bằng tiến trình riêng ghi log (như lượt 1) để khỏi bị dừng khi máy thiếu RAM.
- Integrator xem ảnh, đưa chủ dự án duyệt.

## Handoff (agent điền)
### Phiên 2026-11-08 (lane B, Claude Opus 5.5)
**Ảnh cần xem** (1080p, Forward+, có cửa sổ; trong `art_source/graphics_upgrade/floor4_corridor/previews/round2/`, để ảnh lượt 1 trong `previews/` giữ nguyên):
1. `compare_overview.jpg`: mọi cặp trước/sau và hai cặp phương án, xem trước.
2. `compare_plates_night.jpg`, `compare_plates_torch.jpg`: hai kiểu biển số, chủ dự án chọn.
3. `compare_seal_variants.jpg`: hai kiểu cửa 408 cũ ở X=36, chủ dự án chọn.
4. Từng cặp `compare_<góc>.jpg`: 01, 02 (dọc hành lang từ hai đầu), 03 (cửa 407), 09 (tấm bịt X=36, camera T-229), 10 (cửa 408 đèn pin, camera T-229), 13/14 (cửa 403 đóng / mở, đèn pin), 15 (cửa 408 đóng, đêm), 16 (cận tấm bịt), 17/18 (cận biển số, đêm / đèn pin), 19/20 (hai đầu, Floor4 riêng), 21/22 (hai đầu khi có Campus: lối sang cầu thang để trống).

**Đã làm (cả 8 mục của card):**
1. **Vỏ cả hành lang x 0…44** theo đúng kỹ thuật và vật liệu mẫu T-233 (shader `room407_shell.gdshader` dùng nguyên, không sửa). Script lượt 1 đổi tên và mở rộng: `corridor_layout.py` (bố cục), `make_corridor_masks.py` (bản đồ bẩn), `build_corridor.py` (Blender). Chia 10 gian theo vách phòng (nhà vệ sinh, 401…406, 407 tây, 407 đông, 408), mỗi gian một mesh gồm tường, sàn, gạch chân tường, trần, mép sàn/trần phía ngoài; dùng chung 4 vật liệu. Atlas bẩn mới cho cả hành lang, vẽ theo vị trí thật nên không vết nào lặp ở mọi cửa (mỗi cửa vệt tay đậm nhạt khác, 407 đậm nhất; ẩm và vệt ướt ở cửa nhà vệ sinh; chỗ đứng trước bàn trực; 3 vết dột ở 3 chỗ; bồ hóng mỗi máng đèn một khác). Cửa nhà vệ sinh chung: má và đầu cửa trát vữa, ngưỡng đá.
2. **Cửa 401…406, 408:** khung, nẹp, ngưỡng, nẹp chặn, 3 bản lề như cửa 406 của mẫu; cánh `door_room.glb` và 2 tay gạt `door_lever.glb` của phòng 407 treo vào `LockedDoor_*/Hinge` (không tiêu credit Tripo). `RoomDoor.set_open()` mở ra hành lang như cánh PS1 (test cả 7 cửa). Cửa 407 giữ như mẫu.
3. **Cửa 408 cũ ở X=36:** giữ `Former408Wall`, `Sealed408` (node, vị trí, va chạm; chỉ ẩn hình). Dựng khung và nẹp cũ, ngưỡng đá, hai kiểu lòng cửa (xem phương án bên dưới). Ô X=36 không có biển số cũ nên không làm biển.
4. **Biển số mới 401…408** dựng bằng Blender, đúng số và tâm (x; 2,42) của `RoomPlate_*` (test so với node cũ). Chữ số vẽ bằng nét tự định nghĩa, không dùng file font. Hai kiểu, mặc định kiểu A.
5. **Máng đèn** dưới cả 9 `CorridorLight_*` (gồm `CorridorLight_Desk`); đèn, vị trí nguồn sáng, `LightHum` giữ nguyên; bóng tuýp sáng/tắt theo đèn (test cả 9). **Lan can A1** suốt 44 m (song cách 12,5 cm, trụ 2 m). Đã bỏ biến thể A2: xóa `segment_railing_classic.glb` cùng các `segment_*.glb` khác (thay bằng `corridor_*.glb`), bỏ phím R và test A2.
6. **Hai đầu:** Floor4 riêng có tường trát và gạch chân tường, gắn làm con của `WestEnd`/`EastEnd` (tên `G5EndWest`, `G5EndEast`). Campus ẩn hai nắp này nên tường mới ẩn theo, không bịt lối sang cầu thang (ảnh 21, 22; test mô phỏng `cap.hide()`). Mép tường, sàn, trần ở x 0/44 có mặt cắt khép kín. Hai trụ lan can đầu lùi vào 3 cm cho khỏi cắm vào tường đầu.
7. **Ảnh:** 33 ảnh (15 góc trước/sau, 3 ảnh phương án), 15 ảnh ghép trước/sau, 3 ảnh ghép phương án, `compare_overview.jpg`; `g5_capture_report.json` ghi camera, renderer, GPU.
8. **Test** `game/tests/levels/test_corridor_g5.gd` (viết lại cho cả hành lang, 9 test):
   - so toàn bộ node Floor4 trước/sau khi dựng: tên, transform, va chạm, đèn, navigation, âm thanh, số phòng; không thêm collider;
   - không đỉnh nào của hình mới lấn vào lối đi (kiểm từng đỉnh vì mesh đã ghép theo gian);
   - capsule đi thông dọc Z=3 cả 44 m, dọc Z=1 cả 44 m trừ đoạn trước bàn trực đi ở Z=1,1 (bàn PS1 nhô tới z 0,745; có từ trước, không do lượt này), và vào cửa 407;
   - 7 cánh mở/đóng theo `RoomDoor`; 9 máng đèn theo đèn; biển số; tấm bịt; hai đầu; cảnh thử load được.

**Không đổi gameplay:** không sửa `floor4.tscn`, `corridor.tscn`, `washroom.tscn`, `duty_desk.tscn`, `floor4.gd`, `door407.gd`, phòng 407, Campus, shader 407. Cảnh thử chỉ ẩn mesh PS1 (149 mesh), không xóa, dời, đổi tên node nào, không thêm va chạm.

**Cảnh thử** `res://scenes/levels/floor4/corridor_g5_pilot.tscn` (F6 trong editor): phím G bật/tắt hành lang mới (so với PS1), N đổi kiểu biển số, M đổi kiểu cửa 408 cũ.

**Số liệu cả hành lang** (`geometry_report.json`):

| File | Tam giác | Mesh | Dung lượng |
|---|---|---|---|
| `corridor_shell.glb` (10 gian) | 406 | 10 | 61 KB |
| `corridor_ends.glb` (2 tường đầu) | 24 | 2 | 5 KB |
| `corridor_frames.glb` (9 khung + ngưỡng nhà vệ sinh) | 12 288 | 10 | 623 KB |
| `corridor_railing.glb` (A1, 10 đoạn) | 11 488 | 10 | 690 KB |
| `corridor_lamps.glb` (9 máng) | 12 348 | 9 | 639 KB |
| `corridor_plates_alu.glb` (mặc định) | 5 324 | 8 | 296 KB |
| `corridor_plates_enamel.glb` (phương án) | 3 068 | 8 | 159 KB |
| `corridor_seal_board.glb` (phương án) | 2 380 | 1 | 140 KB |

- Mặc định (vỏ, đầu, khung, lan can, đèn, biển nhôm): **41 878 tam giác, 49 mesh**.
- Cộng 7 cánh Tripo (5 057 + 2 × 1 372 = 7 801 mỗi cửa, dùng lại của 407): +54 607. **Tổng khoảng 96 500 tam giác** khi thấy hết. Cánh và khung 407 thuộc phòng 407, không tính.
- **17 vật liệu Corr\***: 11 của mẫu và 6 mới (`CorrPlateAlu`, `CorrPlateInk`, `CorrPlateEnamel`, `CorrPlatePrint`, `CorrScrew`, `CorrBoard`). Thêm vật liệu Tripo của cánh/tay gạt (dùng lại) và 9 vật liệu phát sáng bóng tuýp tạo lúc chạy.
- **Texture mới:** 3 bản đồ bẩn, PNG RGBA, nén VRAM:

  | File | Kích thước | Mật độ | Dung lượng |
  |---|---|---|---|
  | `mask_walls.png` | 4096×2048 | 207 px/m | 1,4 MB |
  | `mask_floor.png` | 4096×2048 | 191 px/m | 3,6 MB |
  | `mask_ceiling.png` | 4096×1024 | 126 px/m | 1,2 MB |

  Mẫu lượt 1 khoảng 250 px/m; tường gần mắt nhất nên giữ mật độ cao nhất.
- **Texture dùng lại** (không sao chép): sơn kem, lớp bong, Floor Tiles 08, khung xanh và vân ván, Green Metal Rust, đá granite, nhiễu (như mẫu). Thêm nhôm xước tự vẽ T-222 (biển A) và Wood Table Worn CC0 (ván ốp kiểu 2). Nguồn: `CREDITS.md`.
- Mọi GLB ≤ 1 MB, PNG ≤ 3,6 MB, ảnh ≤ 1 MB; đi qua LFS, có `.import`.

**Phương án chờ chủ dự án chọn** (đã làm sẵn cả hai, đổi bằng một dòng):
- **Biển số** (`compare_plates_night.jpg`, `compare_plates_torch.jpg`):
  - A, nhôm, số dập nổi sơn đen. **Đề xuất A**: màu trung tính hợp tường kem và khung xanh, ánh kim nổi rõ dưới đèn pin, cùng chất nhôm với khung cửa ban công 407.
  - B, men xanh, số in trắng: gần màu biển PS1 cũ, dễ đọc từ xa hơn nhưng thêm một màu nhấn mới vào hành lang.
- **Cửa 408 cũ ở X=36** (`compare_seal_variants.jpg`):
  - Kiểu 1, xây kín trát lại, giữ khung cũ, sơn mới hơn, nứt quanh mép. **Đề xuất kiểu 1**: đúng ghi chú T-190 ("bịt mặt cửa cũ bằng tường"), trung tính, nhìn ra ngay là cửa cũ đã bịt mà không gợi ý có gì giấu bên trong.
  - Kiểu 2, ốp 5 tấm ván cũ bắt vít trong khung: gần ý "tấm bịt" của bản PS1 hơn, gây tò mò hơn, nhưng dễ bị hiểu thành dấu hiệu truyện (card cấm thêm ký hiệu truyện).

**Quyết định kỹ thuật nhỏ** (trong phạm vi lane, ghi để integrator biết):
- Ảnh lượt 2 để trong `previews/round2/`, không đè ảnh lượt 1 mà card T-233 đang dẫn.
- Tường mới phủ cả mặt phía phòng của tường (z −0,1) ở các gian 401…406, 408 và nhà vệ sinh. Riêng hai gian của phòng 407 giữ lớp mỏng như mẫu, vì vỏ phòng 407 đã vẽ mặt trong.
- Atlas sàn chia mỗi gian làm 2 dải để xếp chặt hơn (191 thay vì 166 px/m). Nhiễu chạy theo tọa độ bề mặt nên các mảnh nối liền, không thấy đường ghép trong ảnh.

**Giới hạn đã biết:**
- Còn PS1, theo card để lượt 3–4 (thấy trong ảnh 14, 19, 21, 22):
  - bên trong các phòng 401…406, 408 và nhà vệ sinh chung; mặt trong tường trước của các phòng này nay là vữa trơn của tường mới;
  - bàn trực, bảng tin, loa, đồ phơi, xô, dép;
  - cầu thang và chiếu nghỉ của Campus.
- 7 cánh cửa cùng một mẫu Tripo (giống hệt nhau, chỉ vệt bẩn quanh cửa khác nhau). PLAN mục 4 có ý "biến thể độ cũ bằng vật liệu", chưa làm.
- Vết dột ở x 41 khá to và rõ (ảnh 02, 20). Muốn nhỏ hơn thì sửa một số trong `make_corridor_masks.py`.

**Chưa kiểm:**
- Chưa đo FPS, chưa chạy bot (card không cho phép); integrator sẽ xin chủ dự án đo FPS trước khi đưa vào bản chơi.
- Chưa đi thử bằng tay trong cảnh thử; phím G/N/M chỉ được test qua hàm.
- Cấu hình Campus mới chỉ chụp ảnh, chưa đi bộ qua chỗ nối.
- Set CCTV không đổi.

**Kết quả:**
- Test riêng `test_corridor_g5`: `RESULT: 9 passed, 0 failed`.
- Chụp ảnh: `RESULT: corridor g5 capture 33 images PASS` (lần cuối 12:36, sau khi sửa camera ảnh 16 và màu ván).
- Ghép ảnh: `RESULT: corridor compare sheets 18`.
- Full test: `RESULT: 875 passed, 0 failed` (12:37–12:59).
- Check: `RESULT: check 0 error(s)` (12:59–13:14).
- Chụp, full test và check chạy liền nhau trong một tiến trình `pwsh` riêng (`run_stage.ps1 -Stage g5`, rồi `-Stage full`), mỗi bước tự lấy khóa bằng CreateNew và trả khóa khi xong. Log trong `build/floor4_corridor/` (không commit). Sau đó `git checkout -- game/default_bus_layout.tres`.
- Khóa do integrator giữ từ 11:59 đến 12:36; lane B chờ, không đụng tiến trình của lane khác.
- Nền: nhánh tạo từ `origin/main` `ea6414d`; test và check chạy trên nền này. Lúc commit, `main` đã có thêm 4 commit (T-227, D-145, D-146) không đụng file nào của lane B, nên chưa rebase để kết quả test vẫn đúng nền.

**Commit:**
- `9b82835`: vỏ cả hành lang, cửa, biển số, bản đồ bẩn, script Blender.
- `29d3ed3`: cảnh thử, chế độ chụp, test.
- `821ddd9`: ảnh lượt 2, ảnh ghép, README, CREDITS.
- Commit card này ngay sau.

**Yêu cầu thay đổi:** không. **Blocked:** không.

## Review (integrator, 08/11/2026)
- **Đạt, merge vào `main`.** Đúng phạm vi lane B (`art_source/`, model/texture `graphics_pilot/floor4_corridor/`, cảnh thử, test `levels`); không sửa scene chơi, không tiêu credit Tripo. Đã bỏ lan can A2 theo D-144. Hai phương án có sẵn, chủ dự án chọn bằng ảnh: biển số A (nhôm), cửa 408 cũ kiểu 1 (xây kín, trát vữa); đều là mặc định của lane B (D-148).
- Kiểm tra trên `main` sau merge (nhánh tách từ `main` cũ): full `RESULT: 884 passed, 0 failed`, check `RESULT: check 0 error(s)`.
- **Tiếp theo:** integrator đo FPS (chủ dự án cho phép, D-148), rồi mở card đưa hành lang mới vào bản chơi. Còn PS1: bên trong phòng 401–406 và 408, bàn trực, nhà vệ sinh chung, đồ phơi, cầu thang (lượt 3–4).
