# D-152: bot và FPS chương 1 có thân Trần Trung

Ngày 09/11/2026. Integrator chạy sau khi chủ dự án cho phép. Nền `main` tại `ae7496d`.

## Bot
`pwsh tools/playthrough.ps1 -V2 -Scenario ch1v2_good -RequireComplete` cho kết quả `PLAYTHROUGH_RESULT: PASS scenario=ch1v2_good real_seconds=838.97 game_minutes=120`. Đây là lần đầu bot đi trọn chương 1 khi người chơi có thân, tức là phải đứng đủ gần đồ vật mới dùng được (D-124).

Chưa chạy bốn ca ch1v2 còn lại: sai công tắc, mở cửa muộn, bật đèn, khuyên sai.

## FPS
`playthrough.ps1 -V2 -Performance` trả về SKIP vì `ch1v2-profile.json` chưa gắn góc đo nào (door/bed/washroom/balcony đều là null). Vì vậy tôi đo bằng script tạm, dùng lại `chapter_fps.gd` của T-237 (đã xóa sau khi đo).

Thiết lập đo:
- Nạp `chapter1.tscn` thật, director không chạy, 1080p, tắt vsync, không giới hạn FPS.
- Dùng 8 góc của T-237.
- Thân Trần Trung đứng cách camera 1,6 m, trong khung hình, quay mặt về camera.
- Mỗi góc đo khi có thân rồi khi không có thân (ẩn và ngừng xử lý): 90 khung khởi động, 240 khung đo, chạy 2 vòng.
- Máy: RTX 3050 Laptop, Ryzen 5 5600H; lúc bắt đầu còn 2,2 GB RAM trống.
- Số liệu gốc ở `build/integrator/fps_body_ch1.json` (không commit).

| Góc | Có thân: TB (v1 / v2) | Có thân: 1% thấp (v1 / v2) | Không thân: TB (v1 / v2) | Không thân: 1% thấp (v1 / v2) |
|---|---|---|---|---|
| 01 đầu tây, đêm | 168,8 / 149,5 | 110,4 / 83,9 | 159,9 / 114,1 | 100,3 / 60,1 |
| 02 đầu đông, đêm | 171,3 / 147,2 | 110,6 / 72,7 | 151,2 / 128,2 | 78,3 / 81,4 |
| 03 cửa 407, đêm | 150,8 / 146,3 | 99,6 / 101,9 | 147,4 / 148,3 | 98,1 / 86,2 |
| 04 cửa 407, đèn pin | 140,2 / 146,1 | 92,9 / 121,9 | 142,0 / 136,9 | 94,7 / 85,2 |
| 19 hết hành lang tây, đêm | 344,0 / 344,6 | 259,4 / 329,6 | 372,5 / 388,2 | 245,5 / 351,3 |
| 20 hết hành lang đông, đêm | 241,8 / 242,4 | 154,5 / 170,1 | 272,4 / 274,0 | 107,5 / 181,5 |
| 21 hết hành lang tây, đèn pin | 306,5 / 235,5 | 170,1 / 108,3 | 326,0 / 255,0 | 179,7 / 142,4 |
| 22 hết hành lang đông, đèn pin | 209,1 / 160,4 | 121,6 / 82,2 | 257,2 / 213,9 | 157,8 / 117,8 |

## Kết luận
- **Mọi góc ≥ 60 FPS khi có thân**, cả trung bình lẫn 1% thấp nhất.
  - Trung bình thấp nhất: **140,2 FPS** (cửa 407, đèn pin).
  - 1% thấp nhất thấp nhất: **72,7 FPS** (đầu đông).
- **Thân tốn khoảng 0,2–1,6 ms/khung** ở các góc cuối hành lang (19–22), nơi cảnh nhẹ, nên phần chi phí của thân thấy rõ.
- **Ở các góc nặng (01–04), chênh lệch nhỏ hơn độ dao động giữa hai vòng**; có góc còn đo được nhanh hơn khi có thân.
- So với T-237, các góc 01–04 vẫn trong cùng khoảng (T-237: trung bình 147–213, lần này 140–171).
