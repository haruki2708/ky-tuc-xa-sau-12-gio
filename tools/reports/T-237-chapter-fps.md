# T-237 — FPS hành lang tầng 4 mới trong chương 1 và 3 thật

Đo ngày 09/11/2026, integrator, chủ dự án cho phép (chọn A sau D-149). Nền `main` tại `e46491e` (mã T-237 là `f7efdc3`). Tiếp nối [D-148](D-148-corridor-fps.md), lần đó chỉ đo cảnh thử (hành lang và phòng 407).

## Cách đo
- Máy: NVIDIA GeForce RTX 3050 Laptop, AMD Ryzen 5 5600H; Forward+, tắt vsync, không giới hạn FPS. Không lane nào chạy Godot; lúc bắt đầu còn 6,8 GB RAM trống.
- **Phần 1, 1080p** (khung vẽ 1920×1080; cửa sổ bị Windows thu còn 1920×1057): nạp `chapter1.tscn` và `chapter3.tscn` thật, director không chạy (ánh sáng như lúc mở chương), người chơi và giao diện ẩn, tắt tiếng. Chương 3 có cả Campus. Dùng đúng 8 góc (chương 1) và 11 góc (chương 3) của bộ ảnh `previews/round3_playable/`.
  - Mỗi góc đo hành lang mới rồi PS1 (bật/tắt bằng `Floor4CorridorShell.set_upgraded`, cùng camera, cùng lượt): 90 khung khởi động, 240 khung đo. Chạy 2 vòng.
  - Script đo tạm (`game/_probe_tmp/chapter_fps.gd`), đã xóa; số liệu gốc `build/integrator/fps_ch1.json`, `fps_ch3.json` (không commit).
  - Không có quản lý, xác sống, hiệu ứng cháy của chương 3 trong phần này.
- **Phần 2, 720p, có xác sống:** công cụ sẵn có `pwsh tools/playthrough.ps1 -Chapter 3 -Performance` (`ch3_performance`): Floor4 (nay có hành lang mới) + Campus, camera đi theo đường từ phòng 407 qua cửa thoát hiểm tới nhà ăn, 0, 20 và 40 xác sống thật đang đuổi.

### Chương 1
| Góc | Mới: FPS trung bình (v1 / v2) | Mới: 1% thấp nhất (v1 / v2) | PS1: FPS trung bình (v1 / v2) | PS1: 1% thấp nhất (v1 / v2) |
|---|---|---|---|---|
| 01 đầu tây nhìn dọc hành lang, đêm | 208,0 / 212,6 | 144,0 / 160,3 | 174,7 / 205,2 | 94,7 / 118,3 |
| 02 đầu đông nhìn dọc hành lang, đêm | 168,2 / 171,9 | 88,2 / 110,3 | 188,2 / 165,0 | 114,6 / 111,9 |
| 03 cửa 407, đêm | 160,0 / 161,0 | 103,9 / 112,9 | 187,7 / 172,0 | 132,6 / 111,2 |
| 04 cửa 407, đèn pin | 147,2 / 150,0 | 98,5 / 100,9 | 172,4 / 166,0 | 115,1 / 102,3 |
| 19 hết hành lang phía tây, đêm | 352,9 / 366,2 | 238,0 / 311,4 | 433,6 / 447,2 | 280,7 / 295,4 |
| 20 hết hành lang phía đông, đêm | 285,8 / 286,5 | 210,5 / 215,8 | 346,0 / 325,7 | 318,5 / 134,7 |
| 21 đầu tây, đèn pin | 363,7 / 352,5 | 260,2 / 307,8 | 427,2 / 416,0 | 306,1 / 280,1 |
| 22 đầu đông, đèn pin | 267,0 / 281,7 | 179,5 / 266,7 | 320,1 / 341,7 | 226,9 / 327,7 |

### Chương 3
| Góc | Mới: FPS trung bình (v1 / v2) | Mới: 1% thấp nhất (v1 / v2) | PS1: FPS trung bình (v1 / v2) | PS1: 1% thấp nhất (v1 / v2) |
|---|---|---|---|---|
| 01 đầu tây nhìn dọc hành lang, đêm | 74,5 / 74,3 | 42,0 / 44,4 | 76,3 / 74,6 | 48,3 / 44,5 |
| 02 đầu đông nhìn dọc hành lang, đêm | 100,0 / 97,7 | 56,1 / 57,2 | 105,6 / 103,8 | 83,9 / 60,3 |
| 03 cửa 407, đêm | 107,1 / 108,8 | 66,0 / 66,5 | 107,2 / 108,8 | 70,3 / 73,2 |
| 04 cửa 407, đèn pin | 110,9 / 98,8 | 63,4 / 61,1 | 113,9 / 115,2 | 74,0 / 70,4 |
| 19 hết hành lang phía tây, đêm | 238,5 / 194,5 | 147,0 / 119,4 | 239,9 / 298,5 | 152,7 / 174,9 |
| 20 hết hành lang phía đông, đêm | 129,1 / 117,4 | 77,3 / 73,3 | 140,8 / 136,0 | 83,2 / 89,7 |
| 21 đầu tây, đèn pin | 257,0 / 209,3 | 136,7 / 112,8 | 214,0 / 304,2 | 137,3 / 191,8 |
| 22 đầu đông, đèn pin | 142,1 / 118,6 | 101,8 / 71,6 | 135,9 / 145,0 | 91,8 / 96,6 |
| 11 cầu thang chính, đèn pin | 246,7 / 192,6 | 158,7 / 127,5 | 212,4 / 229,2 | 123,7 / 127,4 |
| 12 cầu thang thoát hiểm, đèn pin | 158,9 / 108,5 | 133,6 / 63,0 | 122,2 / 135,6 | 79,1 / 109,3 |
| 23 cửa thoát hiểm mở, đèn pin | 127,1 / 119,9 | 75,1 / 74,8 | 142,2 / 123,2 | 95,4 / 76,8 |

## Kết quả phần 1 (1080p)
- **Chương 1:** mọi góc **≥ 60** cả trung bình lẫn 1% thấp nhất. Thấp nhất: trung bình **147,2 FPS** (cửa 407, đèn pin), 1% thấp nhất **88,2 FPS** (đầu đông). Hành lang mới chậm hơn PS1 trung bình **+0,40 ms/khung** (13 trên 16 cặp chậm hơn, nhiều nhất +1,0 ms).
- **Chương 3:** FPS trung bình mọi góc **≥ 60**, thấp nhất **74,3 FPS** (góc 01). Hành lang mới chậm hơn PS1 trung bình **+0,45 ms/khung** (17 trên 22 cặp, nhiều nhất +1,8 ms).
- **1% thấp nhất dưới 60 ở chương 3, góc nhìn dọc hành lang:**
  - Góc 01 (đầu tây nhìn dọc cả hành lang): **42–44 FPS với hành lang mới, 44–48 FPS với PS1**. Trung bình hai bên gần bằng nhau (74 và 75 FPS), nên chỗ tụt này **do Campus**, có từ trước, không phải do hành lang mới. Từ góc này thấy cả khuôn viên qua lan can.
  - Góc 02 (đầu đông nhìn dọc hành lang): 56–57 FPS với hành lang mới, 60–84 với PS1. Ở góc này hành lang mới **làm tụt thêm** khoảng 0,6 ms trung bình.
  - Hai góc đó ở chương 1 (không Campus) trên 88 FPS.
- Hai vòng lệch nhau khá lớn ở vài góc (ví dụ cầu thang thoát hiểm mới 158,9 và 108,5 FPS), như D-148: số tin được là độ lớn và so trong cùng vòng.

## Kết quả phần 2 (720p, xác sống, công cụ sẵn có)
`PLAYTHROUGH_RESULT: PASS scenario=performance` (ngưỡng của công cụ: trung bình ≥ 60, thấp nhất ≥ 30).

| Số xác sống | FPS trung bình cả đường | FPS thấp nhất cả đường | Đoạn phòng 407 (tầng 4): trung bình / thấp nhất |
|---|---|---|---|
| 0 | 200,4 | 37,0 | 132,7 / 37,0 |
| 20 | 165,8 | 42,1 | 123,5 / 70,2 |
| 40 | 151,2 | 31,5 (vườn) | 109,3 / 61,3 |

- Mọi đoạn trung bình ≥ 60; khung chậm nhất là từng khung riêng lẻ (công cụ ghi thấp nhất, không phải 1% thấp nhất), chủ yếu ở vườn, nhà ăn, cửa sổ quản lý và lúc mới bắt đầu.

## Kết luận
- Hành lang mới **đạt tiêu chí 1080p ≥ 60 FPS trung bình** trong cả chương 1 và 3 thật; tốn thêm khoảng 0,4–0,45 ms mỗi khung so với PS1, như D-148 (0,55 ms).
- **Chương 3 có giật nhẹ khi nhìn dọc hành lang ra khuôn viên** (1% thấp nhất 42–57 FPS). Phần lớn do Campus, có cả khi để hành lang PS1; hành lang mới góp thêm một ít ở góc đầu đông. Không chặn bản chơi thử. Nên xử lý khi làm đồ họa Campus (giảm vật ở xa, che tầm nhìn ra ngoài, hoặc dùng chung vật liệu cho hành lang: hiện 127 vật liệu riêng).
- Chưa đo: chương 2 và 4, khi quản lý hoặc xác sống trong hành lang tầng 4, hiệu ứng cháy chương 3, 1440p/4K, máy yếu hơn.
