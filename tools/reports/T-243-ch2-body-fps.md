# T-243: bot và FPS chương 2 có thân Trần Trung

Ngày 12/11/2026. Integrator chạy sau khi chủ dự án cho phép. Nhánh `integrator/T-243-protagonist-chapter2`.

## Bot
`pwsh tools/playthrough.ps1 -Chapter 2 -Scenario ch2_good -RequireComplete -TimeScale 1`: **`PLAYTHROUGH_RESULT: PASS scenario=ch2_good real_seconds=586.64`** (T-236 không có thân: 590,31 giây), 70 mốc kiểm đạt.

Hai lượt đầu hỏng ở bước lau màn, đều đã sửa:
1. **Lau màn tính từ lúc tay chạm** (phải giữ E 1,45 s, bot giữ 1,1 s). Sửa trong game: màn tính từ lúc bấm E, như khi chưa có thân (1 s); tay vươn tới rồi xoa nốt.
2. **Bot lau từ chỗ vừa ra khỏi buồng tắm** (cách màn 1,1 m: có thân thì tay không với tới). Sửa kịch bản bot (`tools/ch2-profile.json`): bước tới đứng trong buồng tắm, sát màn (màn gắn ở tường buồng), rồi lau. Lần đầu tôi cho đứng ngoài buồng thì lần lau thứ hai (lúc nước đang chạy) kéo bot ra khỏi buồng và chết vì bỏ dở vòi sen; đổi sang đứng trong buồng thì đạt.

Chưa chạy năm ca ch2 còn lại (sai nối từ, hết giờ, bỏng, ra khỏi buồng, đoán sai).

## FPS
Script tạm `game/_probe_tmp/t243_fps.gd` (đã xóa); số liệu gốc `build/integrator/fps_body_ch2.json` (không commit).

Thiết lập:
- Nạp `chapter2.tscn` thật, director không chạy, cửa sổ 1080p, tắt vsync, không giới hạn FPS, giao diện ẩn, tắt tiếng.
- Ba xác ngồi dậy (trạng thái nói), cửa nhà tắm mở.
- 5 góc trong phòng 407. Thân Trần Trung đứng trong khung hình, quay về camera. Ở góc nhà tắm có hơi nước đầy và nước nóng chạy.
- Mỗi góc đo khi có thân, rồi khi không có thân (ẩn và ngừng xử lý): 90 khung khởi động, 240 khung đo, chạy 2 vòng.
- Máy: RTX 3050 Laptop, Ryzen 5 5600H; lúc bắt đầu còn 6 GB RAM trống.

| Góc | Có thân: TB (v1 / v2) | Có thân: 1% thấp (v1 / v2) | Không thân: TB (v1 / v2) | Không thân: 1% thấp (v1 / v2) |
|---|---|---|---|---|
| A phòng ngủ nhìn từ cửa | 122,8 / 128,1 | 73,0 / 104,9 | 121,5 / 121,0 | 70,7 / 66,5 |
| B giường các xác (ngồi) | 121,1 / 115,6 | 79,0 / 67,5 | 130,5 / 108,5 | 99,4 / 67,0 |
| C nhà tắm, hơi nước + nước nóng | 102,9 / 100,2 | 90,8 / 82,8 | 107,7 / 107,1 | 99,0 / 96,7 |
| D gương nhà tắm, hơi nước | 143,0 / 139,9 | 119,2 / 105,1 | 153,3 / 151,1 | 137,5 / 122,5 |
| E ban công | 183,6 / 159,4 | 120,0 / 100,8 | 217,3 / 210,5 | 134,1 / 131,0 |

## Kết luận
- **Mọi góc ≥ 60 FPS khi có thân**, cả trung bình lẫn 1% thấp nhất.
  - Trung bình thấp nhất: **100,2 FPS** (nhà tắm có hơi nước và nước nóng).
  - 1% thấp nhất thấp nhất: **67,5 FPS** (giường các xác); không có thân góc này cũng 67,0.
- **Thân tốn khoảng 0,4–1,6 ms/khung**: thấy rõ ở góc nhẹ (ban công: 210 → 160–184 FPS); ở các góc nặng, chênh lệch nằm trong độ dao động giữa hai vòng.
- Chương 2 nặng hơn chương 1 ở góc nhà tắm (hơi nước): khoảng 100 FPS, so với 140 ở góc nặng nhất chương 1 (D-152).
