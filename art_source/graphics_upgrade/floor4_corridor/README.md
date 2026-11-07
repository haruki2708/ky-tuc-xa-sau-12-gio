# Hành lang tầng 4 — đồ họa gần chân thực

- **T-229** (khảo sát, 02/11/2026): số đo, bảng hợp đồng gameplay, 12 ảnh hiện trạng, kế hoạch 4 lượt: [`PLAN.md`](PLAN.md); phiếu Tripo nháp [`TRIPO_NHAP.md`](TRIPO_NHAP.md).
- **T-233** (lượt 1, D-142): mẫu đoạn x 26…34 quanh cửa 406 và 407, phương án A cả 4 mục, phong cách vỏ phòng 407 ([`../room407_shell/README.md`](../room407_shell/README.md)). Chỉ trong cảnh thử, chưa vào bản chơi.

## T-233: đoạn mẫu 406–407

### Có gì
| Phần | Cách làm |
|---|---|
| Tường phía phòng (mặt hành lang z 0,1) | Một tấm theo đúng lỗ cửa; sơn kem của phòng 407 nhuộm xám nhẹ; shader vỏ 407 với bản đồ bẩn riêng của hành lang: bẩn chân tường (nước lau nhà, giày), vệt tay bên phía chốt mỗi cửa, sứt sơn cạnh nẹp, ẩm chân tường từng mảng |
| Gạch chân tường | Dải 10 cm cắt từ gạch sàn, dừng ở nẹp cửa |
| Sàn | Gạch 40 cm (Floor Tiles 08); ron bẩn, bụi dồn ở chân tường và mép sàn ngoài, làn đi giữa hành lang và lối rẽ vào cửa mòn bóng, mép ngoài ẩm do mưa hắt |
| Trần | Vữa sơn như trần phòng 407; bồ hóng trên máng đèn, dải ẩm có viền ố ở mép ngoài, một vết dột, vài vết nứt |
| Khung cửa 406, 407 | Như cửa phòng 407: lót khung gỗ sơn xanh, nẹp 7 cm, ngưỡng đá. 407 nối tiếp khung có sẵn của phòng (nửa phía phòng); 406 có nẹp chặn phía phòng và 3 bản lề nhìn từ hành lang (cửa mở ra hành lang) |
| Cánh cửa 406 | Cánh Tripo của phòng 407 và 2 tay gạt, treo vào `LockedDoor_406/Hinge`: `RoomDoor.set_open()` mở nó ra hành lang như cánh PS1 |
| Máng đèn | Máng tráng men 2 bóng tuýp của phòng 407, dưới đèn 406 và 407; đèn và nguồn sáng giữ nguyên vị trí; bóng tuýp sáng/tắt/chập chờn theo đèn |
| Lan can | Thép sơn xanh: trụ vuông 50 mm cách 2 m, tay vịn ống 50 mm, thanh dưới, song đứng. Hai biến thể: song cách 12,5 cm (mặc định) và nhịp 0,5 m như PS1 |

Giữ PS1 trong lượt này: biển số phòng, đồ phơi, dây phơi, xô, nội thất phòng 406, phần hành lang ngoài x 26…34.

### Không đổi gameplay
- `floor4.tscn`, `corridor.tscn` và mọi scene chơi không sửa. Cảnh thử ẩn hình PS1 (mesh) của đoạn mẫu, cắt sàn/trần/lan can dài 44 m thành hai đoạn ngoài mẫu; không xóa, dời hay đổi tên node nào; không thêm va chạm.
- `game/tests/levels/test_corridor_g5.gd`: so toàn bộ node của Floor4 trước/sau khi dựng (vị trí, va chạm, đèn, navigation, âm thanh), hình mới không lấn vào lối đi, lối capsule thông, cánh 406 mở/đóng theo `RoomDoor`, bóng tuýp theo đèn.

### Xem và dựng lại
```powershell
# Cảnh thử đi bộ được (Godot editor, F6): G bật/tắt đoạn mẫu (so với PS1), R đổi lan can
#   res://scenes/levels/floor4/corridor_g5_pilot.tscn
python -B art_source/graphics_upgrade/floor4_corridor/make_segment_masks.py        # 3 bản đồ bẩn (~1 phút)
& "D:\Tools\Blender\5.2.2\blender.exe" -b --factory-startup -P art_source/graphics_upgrade/floor4_corridor/build_segment.py
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage g5test      # test của mẫu (chờ khóa Godot)
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage g5          # import lại rồi chụp ảnh 1080p (chờ khóa Godot)
pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage full        # full test rồi check trong một lượt Godot
python -B art_source/graphics_upgrade/floor4_corridor/make_compare.py              # ảnh ghép trước/sau
```
Log ở `build/floor4_corridor/` (không commit). Số tam giác, vật liệu, dung lượng: [`geometry_report.json`](geometry_report.json).

Nguồn và giấy phép: [`CREDITS.md`](CREDITS.md).
