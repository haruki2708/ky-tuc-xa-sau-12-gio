# Đồ điện nhỏ phòng 407 (T-226, D-136)

Chủ dự án báo ổ cắm nối dài, đầu dây mạng và ổ mạng trên tường "vẫn là dạng hình khối", rồi chọn để Claude dựng bằng Blender (D-136).

- `build_electrics.py` (Blender 5.2.2) ghi ra `game/assets/models/graphics_pilot/room407_electrics/`:
  - `power_strip_ch1.glb`: ổ cắm nối dài của chương 1 (nhiệm vụ N2).
    - `Case`: vỏ hai nửa có đường nối, 3 hốc công tắc, lỗ đèn, 3 lỗ cắm tròn hai chân, chỗ ra dây ở đầu −X.
    - `Rocker1..3`: công tắc bập bênh, gốc đặt ở bản lề.
    - `LED1..3`: đèn báo khi bật.
  - `mains_plug.glb`: phích hai chân tròn (màu thân do game đặt).
  - `router_adapter.glb`: cục sạc router có băng keo đỏ (`RedTape`).
  - `rj45_plug.glb`: đầu dây mạng: thân trong, 8 chân đồng, lẫy gài, chụp đuôi `Boot` (màu theo dây).
  - `lan_wall_port.glb`: mặt ổ mạng 2 cổng, gốc đặt trên mặt tường.
- Kích thước viết theo trục Godot. Màu PBR trơn, không texture, vì mỗi món chỉ vài cm và nhận ra được nhờ hình dáng dưới đèn pin.
- Trong game:
  - `ch1v2/power_strip.tscn`: `power_strip.gd` chuyển vỏ, công tắc, đèn của mẫu sang các node `Case`, `SwitchN/Rocker`, `SwitchN/LED` mà luật chơi đang dùng.
  - `ch1v2/cables.gd`: đầu RJ45, mặt ổ mạng, dây của 3 phích cắm, dây ổ cắm nối dài và dây quạt đứng cắm vào 2 ổ tường Tripo mới (`SocketStrip`, `SocketFan` trong `placements.json`).
- Số tam giác: ổ cắm 3.184; mỗi phích 1.140, cục sạc router 1.080; RJ45 660; ổ mạng 1.262.
- Ảnh trước/sau trong chương 1, đèn pin 1,5: `compare_t226.jpg`. Video quạt đứng chạy (không đưa vào git): `build/graphics/room407/t226_quat.mp4`.

Chạy: `& D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P art_source/graphics_upgrade/room407_electrics/build_electrics.py`.
