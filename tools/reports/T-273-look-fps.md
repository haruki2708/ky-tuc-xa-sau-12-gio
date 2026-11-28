# T-273 — FPS của đồ hoạ theo ảnh GPT (R0), đo dở

Đo ngày 28/11/2026, integrator (Opus 5.5), trên nhánh `integrator/T-273-map-look` tại `38071d3c`. Chủ dự án cho đo ("2 đo fps đi"), đóng Chrome và Zalo trước khi đo, rồi **dừng việc đo giữa chừng** ("không cân đo nữa, tôi thấy ổn rồi"). **Chỉ có chương 1; chương 3 chưa đo.**

- Máy: RTX 3050 Laptop (4 GB), Forward+, cửa sổ 1920 × 1080, tắt vsync, cắm điện, chế độ nguồn Balanced. RAM trống 5,7–6,6 GB. Không Blender, không Chrome.
- Hình ra màn qua GPU tích hợp AMD, màn 120 Hz. Thời gian khung đo bằng đồng hồ vì thế dao động nhiều hơn các lần đo trước.
- Script: `art_source/graphics_upgrade/map_look/fps.gd` (cùng góc máy với T-260, thêm 8 góc mẫu R0). Mỗi lần chạy Godot đo một chế độ: tắt (không tham số) hoặc bật (`--look=1`). Trước khi đo, mỗi góc được hiện qua một lượt để biên dịch shader. Mỗi góc: 90 khung khởi động, 240 khung đo.
- Script tách phần: `fps_parts.gd` (bỏ từng phần), `fps_variants.gd` (so cả cấu hình, đo thời gian GPU).
- Số gốc: `build/integrator/t273_fps_ch1_{off,on}_r{1,2}.json`, `t273_parts_ch1.json`, `t273_variants_ch1*.json` (không commit).

## Chương 1: FPS trung bình, tắt → bật

| Góc | Vòng 1: tắt | Vòng 1: bật | Thêm mỗi khung |
|---|---:|---:|---:|
| 01 hành lang nhìn tây, cửa đóng | 112 | 104 | +0,7 ms |
| 02 hành lang nhìn đông, cửa đóng | 162 | 92 | +4,7 ms |
| 03 cửa 406 mở, đèn pin | 120 | 76 | +4,8 ms |
| 04 cửa 405, 406 mở, đèn pin | 173 | 77 | +7,2 ms |
| 05 mở cả 7 cửa, nhìn tây | 109 | 87 | +2,3 ms |
| 06 mở cả 7 cửa, nhìn đông, đèn pin | 139 | 79 | +5,4 ms |
| 07 trong 408, đèn pin | 179 | 78 | +7,3 ms |
| 08 trong 402, đèn pin | 216 | 107 | +4,7 ms |
| 09 trong 406 nhìn ra, đèn pin | 180 | 77 | +7,5 ms |
| 10 ban công 404, đèn pin | 138 | 113 | +1,6 ms |
| **11 trong 407 nhìn ra cửa, đèn pin** | 111 | **60** | +7,5 ms |
| 12 xiên cửa 407 | 132 | 76 | +5,5 ms |
| Mẫu: hành lang nhìn tây | 196 | 87 | +6,4 ms |
| Mẫu: bàn trực | 202 | 90 | +6,1 ms |
| Mẫu: cửa nhà vệ sinh | 328 | 159 | +3,2 ms |
| Mẫu: máng rửa, đèn pin | 323 | 167 | +2,9 ms |

- **Bật đồ hoạ mới, chương 1 vẫn đạt trung bình ≥ 60 FPS** ở mọi góc. Thấp nhất **60 FPS** (trong phòng 407 nhìn ra cửa); phần lớn 76–113 FPS.
- **Vượt mức cho phép của kế hoạch** (thêm tối đa 1,5 ms mỗi khung): 13/16 góc thêm 2,3–7,5 ms.
- Vòng 2 (bật trước, tắt sau) chậm hơn vòng 1 ở **cả hai chế độ** (ví dụ góc 07 tắt: 179 rồi 136). Integrator cho là máy bị dùng hoặc cửa sổ Godot bị che trong lúc đo nên không dùng số vòng 2. Bảng chỉ lấy vòng 1, nên chỉ coi là độ lớn.

## Phần nào tốn

Đo thời gian GPU của từng khung, mỗi cấu hình đo hai chiều rồi lấy trung bình. Hai góc đo được trọn vẹn trước khi Godot ngừng vẽ (các góc sau cho số đứng yên, đã bỏ):

| Cấu hình | 02 hành lang nhìn đông | 07 trong 408, đèn pin |
|---|---:|---:|
| Tắt hết các phần của đồ hoạ mới | 3,8 ms | 11,3 ms |
| Đầy đủ (như chủ dự án đã xem) | 9,6 ms | 14,9 ms |
| Như đầy đủ, nhưng 4 đèn hành lang có bóng đổ (gần 407, D-104) giữ tầm cũ, không bóng mềm | 6,6 ms | 12,9 ms |
| Như trên, các đèn còn lại tầm × 1,25 thay vì × 1,6, tắt glow | 6,1 ms | 12,5 ms |
| Như trên, tắt SSAO | 4,3 ms | 12,9 ms |

Kết luận:
- **Tốn nhất là 4 đèn hành lang có bóng đổ.** Tầm × 1,6 làm khối bóng đổ của chúng chứa nhiều vật hơn, bóng mềm (`light_size`) làm mỗi điểm bóng phải lấy mẫu nhiều lần. Giữ tầm cũ và tắt bóng mềm cho riêng 4 đèn này lấy lại khoảng 2–3 ms.
- Tiếp theo là SSAO (khoảng 1–2 ms), lớp bề mặt ố và ướt (khoảng 0,9 ms ở góc 02), glow (khoảng 0,5 ms).
- Trời đêm, đèn pin mới, đèn trăng: không đáng kể.

## Chưa biết

- **Chương 3 chưa đo.** Trước đồ hoạ mới, góc nặng nhất chương 3 là 70–75 FPS (T-260). Nếu cũng thêm 4–7 ms như chương 1 thì có thể xuống dưới 60 FPS. Đây là ước đoán, chưa phải số đo.
- Các cấu hình rẻ hơn mới đo trên 2 góc, chưa chụp ảnh để so với ảnh đã duyệt.
