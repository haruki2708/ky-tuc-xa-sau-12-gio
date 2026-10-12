# T-213 — Làm thử góc phòng 407 gần chân thực (kiến trúc + vật liệu + ánh sáng)
- Lane: B (Môi trường và 3D) | Trạng thái: done (D-092), chờ chủ dự án chấm chất lượng | Agent: lane B (khung, WIP `95d21ea`); Claude làm thay (B hết hạn mức 12/10): vật liệu, đồ vải, vỏ phòng, test, ảnh
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
- [x] Hình khối góc phòng + giường A (+ bàn) bằng script Blender, đúng số đo (test 1 cm đạt)
- [ ] Đạt mục "Tiêu chí chất lượng" (ảnh so sánh cạnh đồ Tripo): **chờ chủ dự án chấm**, xem nhận xét dưới
- [x] Vật liệu CC0 chụp thật, credits đầy đủ
- [x] Decal, ánh sáng 2 trạng thái, thử GI (SDFGI có/không)
- [x] Đặt đủ balo + 7 đồ Tripo đúng chỗ
- [x] File `.blend` để xem trực tiếp
- [x] Ảnh trước/sau 5 góc × 2 ánh sáng + đối chứng SDFGI + `capture_report.json`
- [x] Test
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS (ghi trong commit ghép)
- [x] Handoff

## Handoff (agent điền)

### 12/10/2026 — Claude làm thay lane B
Lane B dựng khung (WIP `95d21ea`: kiến trúc, giường, bàn, đèn, đặt 8 đồ Tripo, cảnh pilot, test) rồi hết hạn mức trước khi chạy Godot. Chủ dự án nhờ integrator làm tiếp. Render thử bản của B thấy nệm/gối/chăn còn "khối" (hộp + lưới gợn sóng, vải jean phóng to ~3,5 lần), khung giường màu gỉ hồng, tường xám trơn. Đã làm:
- **Vật liệu (Poly Haven CC0):** tường/trần Painted Plaster Wall đổi tông kem; khung giường, chân bàn, đèn: Green Metal Rust; nệm: Rough Linen; chiếu: Tatami Mat; gối: Fabric Pattern 05; chăn: Polar Fleece. UV theo mét đúng kích thước thật của ảnh, kể cả quanh ống sắt.
- **Đồ vải:** nệm + chiếu 2 mm; gối từ khối chia lưới (phồng, mép chụm, đáy phẳng); chăn lông bằng mô phỏng vải Blender (va chạm nệm/gối/thanh giường/thang, vải nở 16–18 % để tự gợn nếp, dày 12 mm). Giường dưới chăn bị tung, giường trên chăn nhàu cuối giường. Tách `bunk_a.glb` (khung + nệm, 4.784 tam giác) và `bunk_a_bedding.glb` (7.124, 3 vật liệu).
- **Sửa lỗi của bản B:** giày đặt thiếu offset node `Dat` (test vị trí từng fail); tỉ lệ gạch 2 m → 1,9 m; tác giả Interior Tiles là Charlotte Baglioni; map nguồn ~34 MB chuyển từ `game/` sang `art_source/.../textures/` (không bị đóng gói vào bản xuất); hai bộ vải 1024×1017/1026 đưa về 1024².
- **Vỏ phòng kín** (tường đông, tường cửa + lỗ cửa + cánh cửa đóng, vách nhà tắm, trần 8 m, sàn 8 m) để góc rộng không lộ khoảng trống; đèn tuýp 3,8 → 2,6 (trần quanh đèn cháy sáng); sương mù không phủ nền.
- **Kiểm tra:** test riêng `room407_corner` 3/3; capture Forward+ thật 21 ảnh PASS, không ERROR; `audit_assets.py` (55.109 tam giác gồm Tripo 37.637, 51 texture nhúng), `audit_blend.py` đạt. Ảnh tổng hợp: `art_source/graphics_upgrade/room407_corner/previews/summary_before_after.jpg`.
- **Nhận xét chất lượng (integrator):** đạt: không còn mặt màu trơn, cạnh vát, giường/chăn/gối/chiếu và bàn đứng được cạnh đồ Tripo, đèn pin cho không khí đêm tốt, SDFGI làm góc khuất sáng hơn ~8 %. Chưa đạt mức game AAA: phòng trông "sạch và trống" vì chưa dựng lại tủ, giường B, quạt trần, quần áo, mùng, dây điện, đồ lặt vặt, vết bẩn; ánh sáng đèn tuýp vẫn khá phẳng. Bản PS1 hiện hành có cảm giác "có người ở" hơn. Fridge nhìn từ sau thấy giàn nóng màu đen (đúng model Tripo đã duyệt).
- **Chưa làm:** VoxelGI/LightmapGI, FPS, 1920×1080, mùng. Không sửa cảnh chơi.

## Review (integrator)
2026-10-13 (Claude, integrator): **ghép vào main (D-092).** Phần của B và phần làm thay đã review trong phiên; phạm vi đúng vùng B, không sửa cảnh chơi/core. Chất lượng: xem nhận xét ở Handoff; mục "Tiêu chí chất lượng" để chủ dự án chấm.
