# Đạo cụ tầng 4 — T-138

Pipeline giống bộ kit (`art_source/README.md`): Python thuần trong Blender 5.2.2 → GLB → Godot, nhập qua `assets/models/kit/kit_import.gd` (vật liệu PS1). Script `build_props.py` dùng lại hàm của `kit/build_kit.py`; texture kit được tham chiếu, không chép.

## Dựng lại

```powershell
& 'D:\Tools\Blender\5.2.2\blender.exe' --background --factory-startup --python-exit-code 1 --python art_source/props/build_props.py
py -3 art_source/floor4/build_floor4.py
```

Dựng lại cho ra GLB và texture giống hệt (`build_hashes.json`). Ảnh: `previews/<tên>.png`, `previews/contact_sheet.png`, ảnh trong game `previews/ingame.png`.

## Quy ước
- Mét; Blender Z-up, mặt trước -Y, trong Godot là -Z (như kit).
- Gốc ở chân vật, trừ: `desk_lamp` (gốc ở bóng đèn, khớp OmniLight), `shirt` và `towel` (gốc trên dây phơi), `pa_horn` (gốc ở giá bắt tường), `hall_board` (gốc ở tâm), `desk_items` (gốc ở tâm mặt bàn trực, đặt cùng vị trí và hướng với bàn).
- Đạo cụ chỉ là hình. Va chạm vẫn là hộp vô hình do `build_floor4.py` sinh (bàn, bồn rửa, xô, buồng vệ sinh).

## Scene có API (`game/scenes/levels/props/`)
| Scene | API |
|---|---|
| `water_stream.tscn` | `running: bool` hoặc `set_running(on)`. Đặt ở `Washroom/TapWater` (đầu vòi `Tap_2`), mặc định tắt |
| `slippers_pair.tscn` | `color: Color`, đổi lúc nào cũng được |
| `shirt_hanging.tscn`, `towel_hanging.tscn` | `color: Color`, `sway: float`; gốc trên dây phơi (y 2,15) |

`PropTint` nhân bản mesh và vật liệu cho từng instance trước khi tô màu (không dùng surface override vì renderer headless báo lỗi).

## Số liệu
Tam giác: `manifest.json`. FPS (RTX 3050 Laptop, 1280 × 720, tắt VSync, nước đang chảy): nhà vệ sinh khoảng 334, hành lang khoảng 334, bàn trực khoảng 343.
