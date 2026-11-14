# Nguồn asset — `realistic_map/wave4/` (T-261, sân vận động; D-166, D-176) — lượt 1: góc mẫu và phương án

| File | Là gì | Dựng bằng | Tác giả | Giấy phép |
|---|---|---|---|---|
| `field.glb` | Đường chạy 7 làn (`Track`), bó vỉa (`Kerb`), sân trong (`Infield`), nền quanh đường chạy (`Apron`), vạch đích và vạch xuất phát (`Marks`) | `art_source/graphics_upgrade/realistic_map/wave4/build_stadium_pilot.py` (Blender 5.2.2) | Dự án (Claude, lane B; T-261) | Như dự án |
| `goal.glb` | Khung thành thép tròn, khung đỡ lưới, lưới | như trên | như trên | Như dự án |
| `stand.glb` | Khán đài chính: bậc, lối lên, tường trước, đầu hồi, lan can, bản sàn, dầm xiên, cột, mái tôn, vì kèo, nền gầm, ống sắt chỗ B03 | như trên | như trên | Như dự án |
| `stand_seats.glb` | Phương án S2: ghế nhựa đúc trên mọi bậc ngoài lối lên | như trên | như trên | Như dự án |
| `pole_steel.glb`, `pole_concrete.glb` | Phương án L1 cột thép côn mạ kẽm / L2 cột bê tông ly tâm, khung 6 đèn pha | như trên | như trên | Như dự án |
| `fence_b40.glb`, `fence_bars.glb` | Phương án H1 rào lưới B40 / H2 rào song sắt, cánh cổng (đoạn rào phía tây và tây bắc) | như trên | như trên | Như dự án |
| `gate_pillars.glb` | Trụ cổng trát quét vôi (cổng tây, tây bắc) | như trên | như trên | Như dự án |
| `materials/*.tres`, `materials/*.gdshader` | Vật liệu W4*, shader đường chạy, mặt sân, lưới (`make_wave4_materials.py`) | | như trên | Như dự án |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình và vẽ texture bằng code.

Texture: `game/assets/textures/graphics_pilot/realistic_map/wave4/` (tự vẽ, xem `CREDITS.md` ở đó). Scan dùng lại, đã có
trong game (CC0 Poly Haven, nguồn ghi ở `art_source/graphics_upgrade/room407_corner/CREDITS.md` và `room407_shell`):
[Plastered Wall 04](https://polyhaven.com/a/plastered_wall_04) (bê tông khán đài, `W1Concrete`),
[Painted Plaster Wall](https://polyhaven.com/a/painted_plaster_wall) và [Peeling Painted Wall](https://polyhaven.com/a/peeling_painted_wall)
(trụ cổng), [Green Metal Rust](https://polyhaven.com/a/green_metal_rust) (vì kèo, rào song sắt `W3LampPaint`), nhôm của T-222
(thép mạ kẽm); sơn xám của đợt 1 (sơn trắng); cỏ, đất của đợt 3 (cỏ thật, nền).
