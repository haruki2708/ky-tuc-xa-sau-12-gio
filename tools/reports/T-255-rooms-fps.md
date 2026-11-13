# T-255 — FPS sau khi có bảy phòng 401–406, 408 mới (chương 1 và 3 thật)

Đo ngày 13/11/2026 khoảng 23:00, integrator, chủ dự án cho phép từ trước (D-168). Nền `main` tại `8811fd2` (đã merge T-255, D-171). Tiếp nối [T-237](T-237-chapter-fps.md).

## Cách đo
- Máy: NVIDIA GeForce RTX 3050 Laptop (4 GB), Forward+, cửa sổ 1920 × 1080, tắt vsync, không giới hạn FPS. Không lane nào chạy Godot; lúc bắt đầu còn 5,5 GB RAM trống.
- Nạp `chapter1.tscn` và `chapter3.tscn` thật (chương 3 có cả khuôn viên), director không chạy (ánh sáng như lúc mở chương), người chơi và giao diện ẩn, tắt tiếng. Không có quản lý, xác sống, hiệu ứng cháy.
- 11 góc camera cố định; cửa phòng mở bằng `RoomDoor.set_open`. Mỗi góc 90 khung khởi động, 240 khung đo. "1% thấp nhất" là trung bình của 1% khung chậm nhất.
- So với phòng PS1 cũ: cùng camera, chạy lại với `Floor4.upgraded_rooms = false` (7 góc có nghĩa khi không có phòng mới). Chương 3 đo 2 vòng (vòng 2 đổi thứ tự: PS1 trước).
- Script đo tạm `game/_probe_tmp/t255_fps.gd` (đã xoá khỏi game; bản lưu `build/integrator/t255_fps.gd`), số liệu gốc `build/integrator/t255_fps*_ch*.json` (không commit).

## Chương 1 (1 vòng)
| Góc | Mới: trung bình | Mới: 1% thấp nhất | PS1: trung bình | PS1: 1% thấp nhất | Tam giác mới / PS1 (triệu) |
|---|---|---|---|---|---|
| 01 dọc hành lang từ đầu tây, cửa đóng | 136,6 | 81,9 | 167,8 | 101,5 | 1,87 / 1,83 |
| 02 dọc hành lang từ đầu đông, cửa đóng | 119,9 | 62,6 | 107,2 | 59,8 | 2,35 / 2,32 |
| 03 cửa 406 mở, đứng hành lang, đèn pin | 138,5 | 81,1 | 168,9 | 114,4 | 3,39 / 2,24 |
| 04 cửa 405 và 406 mở, đứng giữa hai cửa, đèn pin | 158,2 | 101,2 | 171,0 | 114,4 | 3,17 / 1,55 |
| 05 cả bảy cửa mở, dọc hành lang từ đầu tây | 143,0 | 86,2 | 165,0 | 101,3 | 3,98 / 1,86 |
| 06 cả bảy cửa mở, từ đầu đông, đèn pin | 130,1 | 77,7 | 124,4 | 60,7 | 4,50 / 2,53 |
| 07 trong phòng 408, đèn pin | 175,5 | 157,0 | | | 1,31 |
| 08 trong phòng 402, đèn pin | 210,9 | 148,5 | | | 0,71 |
| 09 trong phòng 406 nhìn ra cửa, đèn pin | 170,4 | 82,6 | | | 2,30 |
| 10 ban công 404 nhìn dọc dãy ban công, đèn pin | 145,9 | 95,3 | | | 2,24 |
| 11 trong phòng 407 nhìn ra cửa, đèn pin | 120,2 | 102,0 | 122,4 | 107,6 | 1,98 / 1,98 |

Bộ nhớ hình: 3.505 MB (phòng PS1: 3.417 MB).

## Chương 3 (vòng 1 / vòng 2)
| Góc | Mới: trung bình | Mới: 1% thấp nhất | PS1: trung bình | PS1: 1% thấp nhất | Tam giác mới / PS1 (triệu) |
|---|---|---|---|---|---|
| 01 dọc hành lang từ đầu tây, cửa đóng | 76,2 / 67,5 | 39,9 / 41,0 | 52,8 / 77,2 | 32,7 / 43,2 | 1,65 / 1,61 |
| 02 dọc hành lang từ đầu đông, cửa đóng | 90,4 / 87,6 | 52,7 / 48,1 | 89,8 / 91,2 | 44,2 / 56,0 | 2,04 / 2,00 |
| 03 cửa 406 mở, đứng hành lang, đèn pin | 99,7 / 120,5 | 50,0 / 96,5 | 99,5 / 129,1 | 49,8 / 70,5 | 3,20 / 2,05 |
| 04 cửa 405 và 406 mở, đứng giữa hai cửa, đèn pin | 133,5 / 105,4 | 98,2 / 66,0 | 105,8 / 126,2 | 68,2 / 79,9 | 3,04 / 1,43 |
| 05 cả bảy cửa mở, dọc hành lang từ đầu tây | **62,3 / 63,5** | 39,5 / 38,1 | 70,5 / 65,2 | 44,8 / 30,1 | 3,96 / 1,64 |
| 06 cả bảy cửa mở, từ đầu đông, đèn pin | 80,8 / 70,3 | 48,8 / 36,4 | 96,0 / 79,7 | 61,5 / 43,2 | 4,41 / 2,20 |
| 07 trong phòng 408, đèn pin | 151,5 / 143,5 | 88,7 / 98,1 | | | 1,31 |
| 08 trong phòng 402, đèn pin | 173,4 / 183,1 | 109,5 / 154,1 | | | 0,70 |
| 09 trong phòng 406 nhìn ra cửa, đèn pin | 95,8 / 83,7 | 64,9 / 52,3 | | | 2,48 |
| 10 ban công 404 nhìn dọc dãy ban công, đèn pin | 80,2 / 72,6 | 49,0 / 39,7 | | | 2,14 |
| 11 trong phòng 407 nhìn ra cửa, đèn pin | 87,5 / 83,7 | 50,8 / 43,9 | 84,4 / 76,0 | 46,9 / 46,4 | 1,90 / 1,90 |

Bộ nhớ hình: 3.663–3.665 MB (phòng PS1: 3.577 MB) trên card 4 GB.

## Kết quả
- **Chương 1:** mọi góc trung bình **≥ 120 FPS**, 1% thấp nhất **≥ 62 FPS**. Mở một, hai hay cả bảy cửa vẫn trên 130 FPS trung bình.
- **Chương 3:** mọi góc trung bình **≥ 60 FPS**. Thấp nhất **62–64 FPS** ở góc 05 (cả bảy cửa mở, nhìn dọc hành lang từ đầu tây); cùng góc với phòng PS1 là 65–71 FPS, tức bảy nội thất cùng vẽ tốn khoảng 0,5–1,8 ms mỗi khung. Trường hợp hay gặp (một hoặc hai cửa mở): 100–134 FPS, ngang phòng PS1 trong sai số giữa hai vòng.
- **Cửa đóng thì phòng mới gần như không tốn gì** (góc 01, 02, 11: chênh trong sai số; nội thất ẩn khi cửa đóng, như lane B thiết kế).
- **1% thấp nhất dưới 60 ở chương 3** ở các góc thấy khuôn viên (36–53 FPS), **cả với phòng PS1** (30–56 FPS): vẫn là giật nhẹ do khuôn viên đã ghi ở T-237, không do T-255.
- Hai vòng lệch nhau lớn ở vài góc (ví dụ góc 01 PS1: 52,8 và 77,2), như các lần đo trước: số tin được là độ lớn, không phải từng FPS.
- **Bộ nhớ hình là chỗ sát nhất:** T-255 thêm khoảng 87 MB; chương 3 dùng 3.665 MB trên 4.096 MB (89%). Lane B đã gặp màn hình đen khi lên 3.950 MB (trước khi nén texture phòng). Các đợt đồ hoạ sau sẽ chạm trần nếu không nén VRAM các texture Tripo của phòng 407 (nhiều file còn `compress/mode=0`).

## Kết luận
- T-255 **đạt tiêu chí 1080p ≥ 60 FPS trung bình** ở chương 1 và 3. Không chặn bản chơi thử.
- Đề nghị trước đợt đồ hoạ tiếp theo: (1) một task nén VRAM texture Tripo của phòng 407 (lấy lại vài trăm MB); (2) bật occlusion culling (yêu cầu thay đổi của T-253): góc 05, 06 cho thấy nội thất sau tường vẫn bị vẽ khi cửa mở (4,0–4,4 triệu tam giác).
- Chưa đo: chương 2 và 4; khi có quản lý hoặc xác sống; hiệu ứng cháy chương 3; có thân Trần Trung và gương; 1440p, máy yếu hơn.
