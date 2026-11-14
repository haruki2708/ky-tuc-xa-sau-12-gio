# Nguồn asset — `realistic_map/wave4/` (T-261, sân vận động và dải nối vườn → sân; D-166, D-176, D-178)

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `field.glb` | Đường chạy 7 làn (`Track`), bó vỉa (`Kerb`), sân trong (`Infield`), nền quanh đường chạy (`Apron`), vạch đích và vạch xuất phát (`Marks`) | `art_source/graphics_upgrade/realistic_map/wave4/build_stadium_pilot.py` (Blender 5.2.2) | Dự án (Claude, lane B; T-261) | Như dự án |
| `goal.glb` | Khung thành thép tròn, khung đỡ lưới, lưới | như trên | như trên | Như dự án |
| `stand.glb` | Khán đài chính: bậc, lối lên, tường trước, đầu hồi, lan can, bản sàn, dầm xiên, cột, mái tôn (thiếu 3 tấm), vì kèo, nền gầm, ống sắt chỗ B03 | như trên | như trên | Như dự án |
| `pole_steel.glb` | Cột đèn pha thép côn mạ kẽm, bậc leo, hộp điện, khung 6 đèn | như trên | như trên | Như dự án |
| `stand_south.glb` | Khán đài phụ phía nam: 7 bậc bê tông trần, lối lên, tường trước, đầu hồi, lan can, bản sàn | `build_stadium.py` | như trên | Như dự án |
| `fence_b40.glb`, `gate_pillars.glb` | Mười hai đoạn rào lưới B40 trên cột ống, cánh cổng gập; mười hai trụ cổng trát quét vôi | `build_stadium_pilot.py` (gọi từ `build_stadium.py`) | như trên | Như dự án |
| `stadium_props.glb` | Đồ rải trong sân đặt đúng chỗ đồ PS1: rào vượt, túi thể thao, ba lô, giày, khay, thùng gỗ, giấy, dép, điện thoại | `build_stadium.py` | như trên | Như dự án |
| `strip_garden_stadium.glb`, `strip_stadium_props.glb` | Dải nối vườn → sân: bãi cỏ mòn, đường lát gạch block, bó vỉa; giấy rác, hai đống gạch vỡ, ống sắt | `build_stadium.py` | như trên | Như dự án |
| `materials/*.tres`, `materials/*.gdshader` | Vật liệu W4*, shader đường chạy, mặt sân, lưới (`make_wave4_materials.py`) | | như trên | Như dự án |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

Texture: `game/assets/textures/graphics_pilot/realistic_map/wave4/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã có
trong game (CC0 Poly Haven, nguồn ghi ở `art_source/graphics_upgrade/room407_corner/CREDITS.md` và `room407_shell`):
[Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (bê tông khán đài, bó vỉa, gạch vỡ, `W1Concrete`),
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) và [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall)
(trụ cổng), [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (vì kèo, khung đỡ lưới), [Wood Table Worn](https://polyhaven.com/a/wood_table_worn)
(thùng gỗ, `W1Wood`), nhôm của T-222 (thép mạ kẽm); sơn xám của đợt 1 (sơn trắng); cỏ, đất, gạch block con sâu, giấy rác,
gạch của đợt 3.
