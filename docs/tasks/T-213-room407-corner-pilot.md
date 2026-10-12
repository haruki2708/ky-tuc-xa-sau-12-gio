# T-213 — Làm thử góc phòng 407 gần chân thực (kiến trúc + vật liệu + ánh sáng)
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-213-room407-corner-pilot`
- Phụ thuộc: D-076 (đồ họa gần chân thực), D-086 (balo Tripo), D-088/D-089 (7 đồ phòng 407 bằng Tripo, quy trình AAA), **D-090** (làm thử góc phòng trước khi thay cả cụm vào bản chơi).
- Prompt: `docs/handoff/lane-b.md` mục 5.

## Mục tiêu
Chứng minh **phòng và tòa nhà làm bằng Blender theo số đo + texture CC0 chụp thật + ánh sáng tốt** trông gần chân thực, ăn khớp với đồ Tripo đã có, **trước khi** thay cả cụm vào bản chơi (G3). Chủ dự án xem ảnh trước/sau và mở được file Blender để xem trực tiếp.

## Phạm vi: "góc phòng 407"
Vùng quanh chỗ của Trung, đúng vị trí thật trong `floor4.tscn` (root phòng 407 ở world (30,0,0); số đo: `art_source/graphics_upgrade/MEASUREMENTS.md`, `measured_assets.json`). Tối thiểu:
- **Sàn gạch men** phần phòng từ tường tây (x≈30) tới qua bàn học/tủ lạnh (x≈35,5), từ giường A tới tường sau (z≈−2,5…−7); **hai mặt tường** giáp góc đó (có phào chân tường, ổ điện, vết ố); **trần** và **đèn tuýp**; nếu phần tường đó có cửa sổ/ban công thì làm luôn khung cửa sổ.
- **Giường tầng A** (sắt, nệm, chăn): dựng lại bằng Blender đúng số đo hiện hành (nệm y=0,43 / 1,20), giữ chỗ nằm, View/Exit, Corpse1/2 như mô tả ở `MEASUREMENTS.md`. Đây là bản thử trong cảnh pilot, chưa thay giường trong bản chơi.
- **Bàn học** (StudyDesk) và đèn bàn: dựng lại bằng Blender hoặc giữ bản cũ nếu không kịp (ghi rõ).
- Đặt sẵn đồ Tripo đã duyệt, đúng vị trí/hướng của đồ cũ: balo `graphics_pilot/room407_backpack_tripo_r2.glb`; `graphics_pilot/room407_batch1/` ghế, tủ lạnh + nồi cơm (trên nóc tủ), xô + khăn (khăn hạ theo xô mới cao ≈ 0,26 m), dép, giày.

## Cách làm
1. **Hình khối:** script Blender (Python) theo số đo, không dựng tay rồi lưu mất dấu. Cạnh vát nhẹ (bevel), phào chân tường, khung cửa, ổ điện; giữ đúng mặt tường/sàn hiện hành (không xê dịch bề mặt va chạm). Đồ lớn ≤ 8.000 tam giác, đồ nhỏ ≤ 5.000 (D-088); kiến trúc tính theo từng mảnh, báo tổng tam giác cả góc.
2. **Vật liệu:** texture PBR **CC0 chụp thật** từ **ambientCG** hoặc **Poly Haven** (màu, normal, roughness, AO): tường vôi ố/bong, gạch men sàn kiểu ký túc xá Việt Nam, sắt sơn giường, vải chăn/nệm, gỗ/ván bàn. Tối đa 2048² cho bề mặt lớn lặp lại, 1024² cho đồ nhỏ. Ghi URL, tên bộ, giấy phép vào `CREDITS.md`. **Chỉ CC0/CC-BY**; không dùng ảnh trên mạng khác.
3. **Chi tiết bề mặt:** decal (vết ố, vết nước, nứt, dấu bẩn quanh ổ điện/công tắc), không thêm chữ hay manh mối cốt truyện mới.
4. **Ánh sáng (Godot 4.7.2, Forward+):** đèn tuýp trần (đèn + mesh phát sáng), bóng đổ mềm; thử ít nhất một cách ánh sáng gián tiếp (SDFGI, VoxelGI hoặc LightmapGI) và ghi ưu/nhược; tonemap, SSAO/SSIL, sương mờ nhẹ. **Cài đặt chỉ trong cảnh pilot** (WorldEnvironment riêng), không đổi `project.godot` hay renderer mặc định. Hai trạng thái: **đèn bật** và **đèn tắt + đèn pin/điện thoại** (không khí đêm kinh dị của game).
5. **Cảnh pilot:** `game/scenes/levels/graphics_pilot/room407_corner_pilot.tscn` (+ script nếu cần). Không sửa `floor4.tscn`, `room_407.tscn`, `room407_details.tscn`, `extension.tscn` hay cảnh chương. Không thêm va chạm/nav mới vào cảnh chơi.
6. **Xem trong Blender:** lưu file `.blend` của góc phòng (texture đóng gói hoặc trỏ tương đối) trong `art_source/graphics_upgrade/room407_corner/` (≤ 10 MiB mỗi file, LFS) để chủ dự án/integrator mở Blender xem trực tiếp.

## Tiêu chí chất lượng (integrator review theo đúng các mục này; còn "khối" thì trả lại)
Bản G0 (`art_source/graphics_upgrade/previews/room_game_after.png`) vẫn là khối hộp với texture tự sinh 256 px; T-213 phải khác hẳn:
- **Không mặt nào chỉ có màu trơn**: mọi bề mặt có texture PBR chụp thật (màu + normal + roughness, AO nếu có); mật độ texture tường/sàn tối thiểu khoảng **512 px mỗi mét** (đứng cách 1 m vẫn nét).
- **Mọi cạnh lộ ra đều vát** (bevel), không có góc vuông sắc như hộp; tường có phào chân tường, khung cửa/cửa sổ có độ dày, ổ điện/công tắc nổi khỏi tường.
- **Giường tầng và bàn học phải ngang tầm đồ Tripo** khi đặt cạnh nhau trong cùng khung hình: ống sắt tròn có mối hàn/ốc, nệm có đường may và lún, chăn có nếp; bàn có cạnh, vân gỗ, vết xước. Nếu bản Blender không đạt, **được phép dùng Tripo cho phần nhìn của giường/bàn** (chủ dự án tạo theo prompt B soạn, khớp số đo bằng `art_source/graphics_upgrade/tripo/bake_prop.py`), giữ nguyên node va chạm, chỗ nằm, View/Exit, Corpse như hiện hành.
- **Ánh sáng có chiều sâu**: có bóng đổ và vùng tối/sáng rõ, ánh sáng gián tiếp làm góc phòng không đen kịt; không bị chói trắng.
- **Ảnh so sánh bắt buộc**: một ảnh đặt giường/bàn mới cạnh balo, ghế, tủ lạnh Tripo trong cùng khung hình.

## Đầu ra
- `art_source/graphics_upgrade/room407_corner/`: script dựng, `.blend`, `CREDITS.md`, `README.md` (số đo, nguồn, tổng tam giác/texture, cách chạy lại).
- `game/assets/models/graphics_pilot/room407_corner/`: GLB + texture + `.import`.
- Cảnh pilot + script chụp (cờ dòng lệnh, chỉ chạy khi có cờ, cần renderer thật).
- **Ảnh trước/sau** 1280×720 (và 1920×1080 nếu được), **cùng camera**: tối thiểu 4 góc gồm 2 góc giống `art_source/graphics_upgrade/tripo/room407_backpack/g2_r2/room_far*/room_near*` (để so với ảnh balo), một góc rộng nhìn từ cửa vào, một góc ngang tầm mắt người chơi (1,6 m) nhìn giường A; mỗi góc ở 2 trạng thái ánh sáng. "Trước" = phòng hiện hành trong game (PS1).
- `capture_report.json`: camera, FOV, renderer, GPU, cài đặt GI/môi trường, tổng tam giác, danh sách texture và kích thước.
- **Test** (`game/tests/levels/`): cảnh pilot nạp được (headless), các mặt tường/sàn/nệm khớp số đo hiện hành trong 0,01 m, đồ Tripo đúng vị trí đồ cũ.

## Không làm
Không Tripo, không đo FPS, không chạy bot, không sửa core/cảnh chương/cảnh mặc định, không đổi luật, lời thoại. Không thay đồ trong bản chơi (G3 làm sau, theo D-090).

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/graphics_pilot/`, `game/tests/levels/`, card này (Handoff).

## Checklist hoàn thành
- [ ] Hình khối góc phòng + giường A (+ bàn) bằng script Blender (hoặc Tripo cho phần nhìn giường/bàn), đúng số đo
- [ ] Đạt mục "Tiêu chí chất lượng" (ảnh so sánh cạnh đồ Tripo)
- [ ] Vật liệu CC0 chụp thật, credits đầy đủ
- [ ] Decal, ánh sáng 2 trạng thái, thử GI
- [ ] Đặt đủ balo + 7 đồ Tripo đúng chỗ
- [ ] File `.blend` để xem trực tiếp
- [ ] Ảnh trước/sau ≥ 4 góc × 2 ánh sáng + `capture_report.json`
- [ ] Test
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS (xin lượt integrator)
- [ ] Handoff

## Handoff (agent điền)

## Review (integrator)
