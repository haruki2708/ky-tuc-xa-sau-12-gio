# D-148 — FPS hành lang tầng 4 lượt 2 (T-235)

Đo ngày 08/11/2026, integrator, chủ dự án cho phép (D-148). Nền `main` tại `e9e1050`.

## Cách đo
- Máy: NVIDIA GeForce RTX 3050 Laptop, cửa sổ 1920×1080, Forward+, tắt vsync, không giới hạn FPS.
- Cảnh: `floor4.tscn` cộng hành lang mới của `corridor_g5_pilot.gd` (`PILOT.build`), bật/tắt hành lang mới bằng `set_upgraded` để so với PS1 trên cùng camera, cùng lượt chạy. Không có người chơi, quản lý, xác sống, đạo diễn chương hay Campus.
- 7 camera của T-229/T-235 (đêm và đèn pin; hai đầu, cửa 407, 408, 403), mỗi camera mỗi trạng thái 90 khung khởi động rồi 240 khung đo. Chạy 2 vòng; tiến trình dùng chung 6,2 GB RAM trống, không lane nào chạy Godot.
- Tiêu chí dự án: 1080p ≥ 60 FPS (RTX 3050 Laptop).

## Kết quả (hành lang mới)
| Góc | FPS trung bình (vòng 1 / vòng 2) | FPS thấp nhất 1% (vòng 1 / vòng 2) | ms/khung (vòng 1 / vòng 2) |
|---|---|---|---|
| 01 đầu tây, đêm | 187,5 / 159,1 | 87,7 / 75,3 | 5,33 / 6,28 |
| 02 đầu đông, đêm | 164,0 / 134,6 | 107,2 / 72,4 | 6,10 / 7,43 |
| 02 đầu đông, đèn pin | 165,5 / 122,4 | 124,1 / 65,8 | 6,04 / 8,17 |
| 03 cửa 407, đêm | 123,7 / 130,5 | 87,9 / 126,0 | 8,08 / 7,66 |
| 10 cửa 408, đèn pin | 156,6 / 154,7 | 104,2 / 88,8 | 6,39 / 6,47 |
| 13 cửa 403, đêm | 140,3 / 132,0 | 83,9 / 79,0 | 7,13 / 7,58 |
| 20 hết hành lang phía đông | 242,3 / 245,6 | 227,0 / 233,4 | 4,13 / 4,07 |

- **Thấp nhất:** trung bình **122,4 FPS** (02 đèn pin, vòng 2); 1% thấp nhất **65,8 FPS** (cùng góc). Mọi số đều **≥ 60**.
- **So với PS1** trên cùng camera, cùng lượt chạy (14 cặp): hành lang mới **luôn chậm hơn một chút**, trung bình **+0,55 ms/khung**, nhiều nhất **+2,3 ms** (cửa 403, vòng 2); chỉ 2 trong 14 cặp PS1 chậm hơn (02 đêm vòng 1, 01 vòng 2 chênh 0,05 ms). Riêng góc 01 (nhìn dọc cả hành lang từ đầu tây) FPS thấp nhất 1% **tụt khoảng 40** ở cả hai vòng (128 → 88 và 105 → 75): đây là chi phí thật, lặp lại, không phải nhiễu; vẫn trên 60.

## Giới hạn
- Cảnh chỉ có hành lang và phòng 407 (phòng 407 đã đủ đồ), không có quản lý, xác sống, phản chiếu gương, Campus. Ở chương 3–4 (Campus) và khi quản lý/xác trong hành lang, chi phí sẽ cao hơn; chưa đo.
- Hai vòng lệch nhau lớn (ví dụ cửa 403 PS1 165 và 189 FPS); số tin được là cỡ độ lớn và so sánh trong cùng vòng, không phải số tuyệt đối.
- Chưa đo 1440p, 4K hay cấu hình thấp hơn RTX 3050 Laptop.

## Kết luận
Hành lang mới (khoảng 96 500 tam giác khi thấy hết, 17 vật liệu) **đạt ≥ 60 FPS ở 1080p**, dư khoảng 8 ms mỗi khung ở góc nặng nhất; chậm hơn PS1 khoảng 0,55 ms mỗi khung. **Đủ điều kiện đưa vào bản chơi**; khi đưa vào cần đo lại trong chương thật (có quản lý, xác, Campus).
