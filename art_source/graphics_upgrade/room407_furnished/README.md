# Phòng 407 đủ đồ — cảnh làm thử (D-096)

Cảnh: `game/scenes/levels/graphics_pilot/room407_furnished_pilot.tscn`. Dùng lại vỏ phòng, ánh sáng và vật liệu CC0 của góc phòng T-213 (`../room407_corner/`), thay toàn bộ đồ bằng đồ Tripo đợt 1 + đợt 2 và nệm + chiếu Blender. Bản chơi chưa đổi (G3).

- `placements.json`: 74 vị trí theo bố cục thật của `room_407.tscn`, `room407_details.tscn`, `extension.tscn` (cột `source_node` là node gốc). Hướng: mặt trước model quay −Z, `yaw` theo độ.
- `build_mattress.py`: nệm vải lanh + chiếu (cùng hàm và vật liệu của `build_corner.py`), đáy y=0, mặt nệm y=0,05. Ván giường Tripo ở 0,38 / 1,15 m nên mặt nệm khớp chỗ nằm 0,43 / 1,20 của `room407_anchors.tscn`.
- `build_nets.py` (D-095): mùng giường dưới đóng/mở và mùng giường trên (treo 4 dây lên trần). Hộp lưới không đáy ô ~4 cm, mô phỏng vải Blender, buộc ở 4 góc + giữa cạnh dài, mép dưới giắt quanh nệm; vải lưới là texture tự sinh (không dùng asset ngoài), viền vải trắng; mùng mở cuộn vách phía phòng (+X) lên nóc. 4.800–7.400 tam giác mỗi chiếc.
- `build_lines_poster.py` (D-095): dây phơi trong phòng (đinh tường tây → góc nhà tắm, móc áo ở y=2,58) và ban công (y=2,15); poster bóng đá của Phúc 0,42 × 0,59 m dán băng keo, góc dưới quăn. Ảnh poster `poster_football.png` do Blender render từ hình học của dự án (quả bóng 32 mảnh, cỏ sợi, đèn sân), không chữ, không logo.
- Dây điện và giấy manh mối do code trong cảnh chơi dựng và có tương tác: làm đẹp ở G3 trong code, không thay bằng mesh tĩnh.
- Nhà tắm có camera và bóng đèn riêng (vị trí `BathLight` của `extension.tscn`); ban công chưa đặt đồ.

Chạy: `& D:\Tools\Blender\5.2.2\blender.exe -b --factory-startup -P art_source/graphics_upgrade/room407_furnished/<build_mattress|build_nets|build_lines_poster>.py`, sau đó `godot --path game res://scenes/levels/graphics_pilot/room407_furnished_pilot.tscn -- --furnished-capture` (Forward+). Phím **1…8** đổi camera, **L** đèn tuýp/đèn pin, **B** trước/sau. Test: `pwsh tools/test.ps1 -Filter room407_furnished`.

Ảnh: `previews/` (8 góc × đèn tuýp/đèn pin, 3 góc có ảnh PS1 trước), `capture_report.json`; xem nhanh `previews/summary_furnished.jpg`.
