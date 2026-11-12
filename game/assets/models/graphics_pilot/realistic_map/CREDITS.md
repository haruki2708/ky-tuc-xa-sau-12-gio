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
