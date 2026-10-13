# Phòng 407 đủ đồ — cảnh làm thử (D-096)

Cảnh: `game/scenes/levels/graphics_pilot/room407_furnished_pilot.tscn`. Dùng lại vỏ phòng, ánh sáng và vật liệu CC0 của góc phòng T-213 (`../room407_corner/`), thay toàn bộ đồ bằng đồ Tripo đợt 1 + đợt 2 và nệm + chiếu Blender. Bản chơi chưa đổi (G3).

- `placements.json`: 67 vị trí theo bố cục thật của `room_407.tscn`, `room407_details.tscn`, `extension.tscn` (cột `source_node` là node gốc). Hướng: mặt trước model quay −Z, `yaw` theo độ.
- `build_mattress.py`: nệm vải lanh + chiếu (cùng hàm và vật liệu của `build_corner.py`), đáy y=0, mặt nệm y=0,05. Ván giường Tripo ở 0,38 / 1,15 m nên mặt nệm khớp chỗ nằm 0,43 / 1,20 của `room407_anchors.tscn`.
- Dây phơi trong phòng là dây tạm trong script; bản Blender làm theo D-095 cùng mùng, poster, giấy, dây điện.
- Nhà tắm có camera và bóng đèn riêng (vị trí `BathLight` của `extension.tscn`); ban công chưa đặt đồ.

Chạy: `& D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P art_source/graphics_upgrade/room407_furnished/build_mattress.py`, sau đó `godot --path game res://scenes/levels/graphics_pilot/room407_furnished_pilot.tscn -- --furnished-capture` (Forward+). Phím **1…8** đổi camera, **L** đèn tuýp/đèn pin, **B** trước/sau. Test: `pwsh tools/test.ps1 -Filter room407_furnished`.

Ảnh: `previews/` (8 góc × đèn tuýp/đèn pin, 3 góc có ảnh PS1 trước), `capture_report.json`; xem nhanh `previews/summary_furnished.jpg`.
