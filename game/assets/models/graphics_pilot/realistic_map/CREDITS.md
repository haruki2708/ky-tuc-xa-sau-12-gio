# Nguồn asset — `game/assets/models/graphics_pilot/realistic_map/`

Đồ hoạ thật theo kế hoạch T-248 (D-166). Mỗi đợt một thư mục con.

## `wave1/` — T-250: bàn trực tầng 4 (A01), cầu thang thoát hiểm và cửa (A07), cầu thang chính (A06)

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `duty_desk.glb` | Bàn trực gỗ một hộc tủ; ngăn kéo giữa `KeyDrawer` là node riêng chạy trên ray thép | `art_source/graphics_upgrade/realistic_map/wave1/build_duty_desk.py` (Blender 5.2.2) | Dự án (Claude, lane B; T-250) | Như dự án |
| `duty_key.glb` | Chìa khoá cầu thang thoát hiểm (đồng), vòng thép, thẻ nhựa đỏ | như trên | như trên | Như dự án |
| `duty_desk_items.glb` | Sổ trực mở và bút, sổ cũ, hộp mực và con dấu, ca men, ống bút, giấy rời | như trên | như trên | Như dự án |
| `desk_phone.glb` | Điện thoại bàn phím bấm cũ, dây xoắn | như trên | như trên | Như dự án |
| `wall_clock.glb` | Đồng hồ treo tường, dừng lúc 4 giờ (manh mối chương 3); ba kim là node riêng | như trên | như trên | Như dự án |
| `pa_speaker.glb` | Loa nén treo tường trên giá | như trên | như trên | Như dự án |
| `notice_board.glb` | Bảng bần khung nhôm, giấy ghim | như trên | như trên | Như dự án |
| `main_stairs.glb`, `fire_stairs.glb` | Hai cầu thang: bậc bê tông ốp đá mài, chiếu nghỉ, tường trát sơn hai màu, chân tường đá mài, tay vịn tường, lan can giếng thang, tầng trên bị chặn (đoạn thang gãy, đống đổ), cầu thang thoát hiểm sập đoạn tầng 2 → 1, vết nứt tường | `build_stairs.py` | như trên | Như dự án |
| `fire_door_frame.glb`, `fire_door_leaf.glb`, `fire_door_leaf_b.glb`, `fire_door_lock.glb`, `fire_door_handle.glb` | Cửa thoát hiểm hai cánh thép sơn xanh, khung, ổ khoá và tay gạt tách riêng | `build_fire_door.py` | như trên | Như dự án |
| `materials/*.tres` | Vật liệu Godot dùng chung cho các glb trên (`make_wave1_materials.py`) | | như trên | Như dự án |

**Không dùng Tripo, không tạo ảnh bằng AI** cho đợt này. AI (Claude) viết script dựng hình và vẽ texture bằng code.

### Texture dùng lại (đã có trong game, CC0 Poly Haven)
Không chép thêm bản nào; vật liệu trỏ thẳng vào file sẵn có:
- [Wood Table Worn](https://polyhaven.com/a/wood_table_worn) (Dimitrios Savva, Rico Cilliers): bàn trực, tay vịn gỗ. Nguồn ghi ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`.
- [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (Rob Tuytel): cánh và khung cửa thoát hiểm, song lan can.
- [Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) (Amal Kumar; bản nhuộm kem của T-213): tường, trần cầu thang.
- [Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (Rob Tuytel): bê tông vỡ.
- [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall) (Dimitrios Savva; bản sơn lại kem của T-222): lớp sơn bong trên tường cầu thang (shader vỏ phòng 407).
- Nhôm và đá ngưỡng tự vẽ của T-222 (`room407_shell/make_shell_textures.py`): khung bảng tin, ngưỡng cửa thoát hiểm.

### Texture tự vẽ (CC0, `make_wave1_textures.py`, numpy + Pillow)
`game/assets/textures/graphics_pilot/realistic_map/wave1/`: mặt đồng hồ (số vẽ bằng font Be Vietnam Pro, OFL, có trong game), bần, giấy thông báo, bìa và trang sổ trực, sơn xám loa, đá mài, bản đồ bẩn tường và bậc cầu thang, vết nứt. Chữ trên giấy chỉ có hai tiêu đề "LỊCH TRỰC", "THÔNG BÁO"; phần còn lại là nét giả chữ.

### Đồ phòng 407 dùng lại (Tripo, D-084)
`room407_batch2/desk_lamp.glb` (đèn bàn) và `room407_batch1/stool.glb` (ghế nhựa) đặt ở bàn trực; giấy phép và hồ sơ giữ như credits gốc (`art_source/graphics_upgrade/tripo/room407_batch1/CREDITS.md`, `room407_batch2/`). Không tạo mẫu Tripo mới.

## `wave2/` — T-253: tầng 3 → 1 nhà B (A08–A10), bình cứu hoả tầng 2 và hộp báo cháy tầng 1 (A11)

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `floor1_hall.glb`, `floor2_hall.glb`, `floor3_hall.glb` | Hành lang mỗi tầng: tường trát hai màu, chân tường đá mài, sàn đá mài có nẹp phân ô, trần trát, dầm; lan can song thép tay vịn gỗ (tầng 2–3), tường thấp sảnh (tầng 1), máng đèn hai bóng tuýp | `art_source/graphics_upgrade/realistic_map/wave2/build_hall.py` (Blender 5.2.2) | Dự án (Claude, lane B; T-253) | Như dự án |
| `floor1_rooms.glb`, `floor2_rooms.glb`, `floor3_rooms.glb` | Bên trong các phòng nhìn được qua cửa: tường, sàn, trần; giường tầng khung thép nhẹ và tủ thép hai cánh trong hộp va chạm PS1 | như trên | như trên | Như dự án |
| `door_surround.glb`, `room_door_leaf.glb`, `room_plate.glb` | Khung cửa phòng (ốp quanh lỗ cửa 0,9 × 2,1 m của bộ `wall_door`), cánh thép sơn xanh bốn ô có tay gạt, biển số nhôm (số in bằng Label3D) | như trên | như trên | Như dự án |
| `manager_window.glb`, `manager_room.glb`, `knife.glb` | Cửa sổ phòng quản lý (khung thép, kính vỡ, cánh treo ngoài, cánh rơi), bậc lên xuống bậu khớp dốc va chạm; hộp chìa, lịch, giấy trên bàn; dao găm vào mặt bàn | `build_floor1.py` | như trên | Như dự án |
| `main_door_frame.glb`, `main_door_leaf.glb`, `main_door_leaf_b.glb`, `main_door_chain.glb` | Cửa chính sảnh: hai cánh kính khung thép xanh, ô kính trên, trụ trát hai bên; xích quấn hai vòng quanh tay nắm, khoá móc | `build_floor1.py` | như trên | Như dự án |
| `extinguisher.glb`, `extinguisher_bracket.glb` | Bình bột ABC 4 kg (cần bóp và điểm cầm là node riêng), giá treo tường riêng, bảng tiêu lệnh chữa cháy | `build_fire_kit.py` | như trên | Như dự án |
| `fire_alarm.glb` | Nút báo cháy tầng 1 (nút nhấn là node riêng), đèn, ống luồn dây; để core gắn thay hộp đỏ đang dựng lúc chạy | `build_fire_kit.py` | như trên | Như dự án |
| `materials/*.tres` | Vật liệu W2* của đợt này (`make_wave2_materials.py`); vật liệu W1* là của đợt 1, dùng lại, không chép | | như trên | Như dự án |

**Không dùng Tripo, không tạo ảnh bằng AI** cho đợt này. AI (Claude) viết script dựng hình và vẽ texture bằng code.

### Texture dùng lại (đã có trong game, CC0 Poly Haven)
Như đợt 1 (Painted Plaster Wall, Peeling Painted Wall, Green Metal Rust, Wood Table Worn, Plastered Wall 04, nhôm và đá ngưỡng của T-222, đá mài và sơn xám của đợt 1). Thêm:
- [Rough Linen](https://polyhaven.com/a/rough_linen) (colormass, Rico Cilliers) và [Tatami Mat](https://polyhaven.com/a/tatami_mat) (Charlotte Baglioni) của nệm phòng 407 (`room407_furnished/bunk_mattress_*`; nguồn ghi ở `art_source/graphics_upgrade/room407_furnished/CREDITS.md`): nệm, gối, chiếu cuộn các phòng.

### Texture tự vẽ (CC0, `make_wave2_textures.py`, numpy + Pillow)
`game/assets/textures/graphics_pilot/realistic_map/wave2/`: bản đồ bẩn tường, sàn, trần hành lang ba tầng (vẽ theo vị trí thật: vết tay bên mỗi cửa, vệt nước, mốc, lối mòn), nhãn bình cứu hoả ("BÌNH CHỮA CHÁY", "BỘT ABC 4 kg"), mặt đồng hồ áp suất, mặt hộp báo cháy ("BÁO CHÁY", "NHẤN MẠNH"), bảng tiêu lệnh ("TIÊU LỆNH CHỮA CHÁY" và bốn đầu mục). Chữ vẽ bằng font Be Vietnam Pro (OFL, có trong game); phần còn lại là nét giả chữ.

### Đồ dùng lại
- Phòng 203: đồ phòng 407 (Tripo, D-084) `room407_batch2/bunk_frame.glb`, `pillow.glb`, `blanket_messy.glb`, `blanket_folded.glb`, `desk.glb`, `books.glb`, `notebook.glb`; `room407_batch1/stool.glb`, `bucket.glb`, `slippers.glb`; nệm Blender `room407_furnished/bunk_mattress.glb`. Giấy phép và hồ sơ như credits gốc (`art_source/graphics_upgrade/tripo/room407_batch1/CREDITS.md`, `room407_batch2/`). Không tạo mẫu Tripo mới.
- Phòng quản lý: bàn `wave1/duty_desk.glb`; sảnh: bảng tin `wave1/notice_board.glb` (đợt 1).

## `wave3/` — T-259: vườn hoa trước nhà B (A12), dải nối nhà B → vườn (A16), bản nhẹ của vườn nhìn từ tầng 4 ở chương 1–2 (A05)

Nguồn từng file, texture và ảnh tham chiếu: [`wave3/CREDITS.md`](wave3/CREDITS.md). Dựng bằng script Blender, texture vẽ bằng code; không Tripo, không ảnh AI (D-166, D-175).
