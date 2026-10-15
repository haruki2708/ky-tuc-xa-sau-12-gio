# D-114 — Đo FPS phòng 407 đủ đồ (15/10/2026)

Máy: AMD Ryzen 5 5600H, NVIDIA GeForce RTX 3050 Laptop GPU, Godot 4.7.2, Forward+ (Vulkan), VSync tắt, không giới hạn FPS.
Bản đo: `main` sau D-113 (`cf7f23e`): phòng đủ đồ G3, 2 gương phản chiếu thật (D-105), ánh sáng tối D-113.

## 1. Bộ đo có sẵn: `pwsh tools/playthrough.ps1 -Performance` (main.tscn, 1280×720)
Player/HUD/âm thanh chạy, story tắt, 90 frame khởi động + 240 frame mẫu mỗi góc.

| Góc | FPS trung bình | p95 (ms) |
|---|---|---|
| bed_1_phuc | 181,9 | 5,74 |
| bed_2_viet | 174,5 | 6,30 |
| bed_3_trung | 169,4 | 6,32 |
| bed_4_dat | 170,7 | 6,66 |
| door_407 | 169,6 | 6,01 |
| corridor | 352,4 | 3,76 |
| washroom | 164,7 | 8,86 |

Bộ đo luôn ép cửa sổ 1280×720 (chạy với `--resolution 1920x1080` vẫn ghi 1280×720), nên không dùng để đo 1080p.

## 2. Cảnh đo riêng phòng 407 (cảnh tạm, đã xóa), 1920×1080 và 1280×720
Dựng như `room407_g3_capture.gd` (tầng 4 + phòng đủ đồ, không player/HUD/âm thanh/story, không có xác/quản lý), đèn bàn bật.
"torch" = đèn pin bật; "tube" = đèn trần ở đỉnh nhấp nháy (trường hợp nặng nhất: đèn trần đổ bóng toàn phòng).

| Góc | 1080p torch | 1080p tube | 720p torch | 720p tube |
|---|---|---|---|---|
| centre | 123,8 | 103,9 | 203,4 | 162,8 |
| door_overview | 130,9 | **97,7** | 202,4 | 147,6 |
| back_overview | 134,4 | 109,9 | 222,1 | 188,9 |
| mirror_full (nhìn gương đứng) | 135,7 | 100,8 | 197,0 | 159,0 |
| mirror_bath (nhìn gương nhà tắm) | 153,3 | 122,2 | 259,2 | 186,7 |
| bathroom | 200,6 | 162,7 | 352,7 | 292,2 |
| corridor_door | 235,9 | 177,7 | 375,4 | 278,7 |

p95 cao nhất ở 1080p: 10,45 ms (door_overview, tube) ≈ 96 FPS.

## Kết luận
- Mục tiêu 1080p/60 FPS trên RTX 3050 Laptop **đạt** ở mọi góc đo, thấp nhất ~98 FPS (đèn trần nhấp nháy), ~124 FPS khi chỉ có đèn pin.
- Còn khoảng 35–40% dư cho G4 (nhân vật). Chưa đo: chương thật có player/HUD/âm thanh/story, xác và quản lý, campus chương 3.
