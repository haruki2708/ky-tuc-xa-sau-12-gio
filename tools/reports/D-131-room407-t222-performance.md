# D-131 — Đo FPS phòng 407 với vỏ T-222 (22/10/2026); D-132 tối ưu shader vỏ (mục 4)

Máy: AMD Ryzen 5 5600H, NVIDIA GeForce RTX 3050 Laptop GPU, màn hình 144 Hz. Godot 4.7.2, Forward+ (Vulkan), VSync tắt, không giới hạn FPS.
Bản đo: `main` sau D-130 (`d11bc8f`). Vỏ mới T-222 là vỏ của bản chơi từ D-129; vỏ góc T-213 cũ (`--shell-corner`) đo lại cùng lúc để so.

## Cách đo
Cách đo giống [D-114](D-114-room407-performance.md), dùng cảnh tạm `game/_probe_tmp/perf.tscn` (đã xóa):
- dựng như `room407_g3_capture.gd`: tầng 4 và phòng đủ đồ, không có player, HUD, âm thanh, story, xác hay quản lý;
- đèn bàn bật, FOV 75;
- mỗi góc: 90 frame khởi động, rồi lấy mẫu 240 frame;
- "torch" là đèn pin bật; "tube" là đèn trần ở đỉnh nhấp nháy, trường hợp nặng nhất.

D-114 có 7 góc. Lần này thêm 3 góc ban công (`balcony_side`, `balcony_out`, `balcony_back`) cho phần cảnh bên ngoài mới.

**Lưu ý khi đo lại:**
- Chạy trong cửa sổ thì đôi khi giữa chừng mọi góc đứng im ở đúng 144,9 FPS (p95 7,0 ms), tức là bị khóa theo tần số quét màn hình. Đã bỏ hết các dòng này, và một lượt vỏ cũ phải đo lại.
- Đặt cửa sổ luôn nằm trên cùng thì cửa sổ thành 1920×1057 (chừa thanh tác vụ). Vỏ mới đo ở 1920×1057 và 1920×1080 chênh nhau dưới 1%: góc `door_overview` lần lượt 94,9 và 94,4 FPS.

## 1. 1080p: vỏ cũ và vỏ mới (FPS trung bình, torch / tube)

| Góc | D-114, vỏ cũ (15/10) | Vỏ cũ, đo lại (1920×1057) | **Vỏ mới T-222** (1920×1080) |
|---|---|---|---|
| centre | 123,8 / 103,9 | 128,3 / 101,1 | 100,7 / 82,3 |
| door_overview | 130,9 / 97,7 | 125,4 / 96,7 | 94,4 / **75,4** |
| back_overview | 134,4 / 109,9 | 134,8 / 107,6 | 108,4 / 92,2 |
| mirror_full | 135,7 / 100,8 | 129,9 / 97,2 | 111,9 / 84,8 |
| mirror_bath | 153,3 / 122,2 | 151,7 / 122,5 | 141,7 / 112,1 |
| bathroom | 200,6 / 162,7 | 172,4 / 133,7 | 146,6 / 116,5 |
| corridor_door | 235,9 / 177,7 | 243,8 / 172,4 | 194,3 / 152,1 |
| balcony_side | — | 158,7 / 126,8 | 116,7 / 99,1 |
| balcony_out | — | 572,0 / 530,5 | 298,3 / 212,0 |
| balcony_back | — | 315,0 / 241,8 | 219,0 / 162,9 |

- Vỏ cũ đo lại gần đúng như D-114, nên so được với các số cũ.
- Vỏ mới thấp nhất 75,4 FPS (`door_overview`, đèn trần); khi chỉ có đèn pin thì thấp nhất 94,4 FPS.
- p95 cao nhất của vỏ mới ở 1080p là 14,4 ms (khoảng 69 FPS), tức mọi frame chậm vẫn dưới 16,7 ms.
- So với vỏ cũ, các góc nhìn trong phòng chậm hơn 20–25%. Ở góc nặng nhất, mỗi frame tốn thêm khoảng 2,9 ms (10,3 → 13,3 ms).

## 2. 720p (FPS trung bình, torch / tube)

| Góc | Vỏ cũ | Vỏ mới T-222 |
|---|---|---|
| centre | 188,0 / 158,2 | 159,6 / 114,9 |
| door_overview | 198,9 / 143,0 | 152,2 / 115,6 |
| back_overview | 219,4 / 179,1 | 181,0 / 151,4 |
| mirror_full | 187,3 / 148,6 | 177,6 / 117,4 |
| mirror_bath | 210,9 / 163,8 | 230,2 / 151,4 |
| bathroom | — | 232,8 / 192,0 |
| corridor_door | — | 332,8 / 225,2 |
| balcony_side | — | 203,9 / 177,9 |
| balcony_out | — | 430,3 / 328,7 |
| balcony_back | — | 325,1 / 262,3 |

Các ô "—" của vỏ cũ là các dòng bị khóa 144,9 FPS nên đã bỏ.

## 3. Phần nào của vỏ mới tốn thời gian (1080p, vỏ mới)
Mỗi lượt tắt một phần của vỏ, đo 3 góc. Lượt "gốc" chạy 2 lần (đầu và cuối) và cho kết quả lặp lại.

| Thử | centre | door_overview | balcony_out |
|---|---|---|---|
| gốc (lần 1 / lần 2) | 99,5 / 81,9 và 98,8 / 82,4 | 95,5 / 75,4 và 94,6 / 74,5 | 300,5 / 214,2 và 297,0 / 209,9 |
| chất liệu thường thay shader bẩn (chỉ màu + normal) | 117,3 / 93,8 | **124,5 / 91,6** | 301,8 / 223,1 |
| ẩn cảnh bên ngoài | 105,4 / 87,5 | 100,3 / 78,6 | 367,0 / 243,3 |
| ẩn cảnh bên ngoài + ban công | 106,6 / 87,4 | 98,7 / 79,5 | 579,5 / 433,7 |
| ẩn khung và nẹp cửa | 99,5 / 82,7 | 94,3 / 75,2 | 293,6 / 214,6 |
| ẩn trần | 102,3 / 85,2 | 108,1 / 83,6 | 295,3 / 210,3 |

- **Phần lớn chi phí nằm ở shader bẩn `game/rendering/room407_shell.gdshader`** (tường, trần, sàn, ban công).
  - Ở tường và trần (sơn trên vữa), mỗi điểm ảnh đọc 9 texture: nền 3, lớp sơn bong 3, mặt nạ 1, nhiễu 2. Sàn đọc 6.
  - Thay bằng chất liệu thường thì góc `door_overview` gần bằng vỏ cũ, nhanh hơn khoảng 2,4–2,5 ms mỗi frame.
  - Ẩn trần giảm khoảng 1,3 ms, vì trần chiếm nhiều điểm ảnh và cũng dùng shader này.
- Cảnh bên ngoài tốn khoảng 0,5–0,6 ms khi đứng trong phòng.
- Khung và nẹp cửa gần như không tốn gì.
- Về hình học, vỏ rất nhẹ: các phần của vỏ cộng lại khoảng 30.000 tam giác (cảnh bên ngoài 22.588), còn đồ Tripo trong phòng khoảng 560.000.

## Kết luận (D-131)
- Mục tiêu 1080p/60 FPS trên RTX 3050 Laptop vẫn **đạt** ở mọi góc: thấp nhất 75 FPS khi đèn trần nhấp nháy, 94 FPS khi chỉ có đèn pin.
- **Phần dư cho G4 giảm.**
  - Ở góc nặng nhất, mỗi frame dùng 13,3 ms trên 16,7 ms, còn khoảng 3,4 ms. Lúc D-114 còn khoảng 6,5 ms.
  - Lượng này phải đủ cho thân người chơi (T-220 bước 5), HUD, âm thanh, story, quản lý và xác.
- Tối ưu được mà gần như không đổi hình. Chủ dự án chọn làm ngay: D-132, mục 4.
- Chưa đo: chương thật có player, HUD, âm thanh, story, xác và quản lý.

## 4. D-132 (22/10/2026): tối ưu shader vỏ, hình không đổi
Trên tường và trần, các mặt nạ cho thấy:
- sơn bong chỉ ở 1–2% diện tích (ban công 13%);
- vết nước hoặc mốc ở khoảng 15%.

Vì vậy `room407_shell.gdshader` giờ chỉ đọc 3 texture lớp sơn bong ở chỗ sơn thật sự bong, và chỉ đọc nhiễu thô ở chỗ có vết nước hoặc mốc. Sàn không còn đọc nhiễu thô, vì sàn chưa bao giờ dùng nó.
- Gradient lấy trước khi rẽ nhánh (`textureGrad`) nên mức mip không đổi.
- Ở chỗ bị bỏ qua, phép trộn vốn có trọng số 0, nên kết quả về toán học không đổi.

**Hình:** chụp lại 19 góc × 2 kiểu đèn, so từng điểm ảnh với ảnh trước khi sửa.
- Chênh lệch lớn nhất là 1/255 mức màu, tức là sai số làm tròn.
- Riêng `back_overview_tube` có vài điểm lệch, nhưng chạy lại đúng shader cũ cũng lệch y như vậy, nên đó là nhiễu khi vẽ, không do shader.
- Ảnh so sánh (trước | sau | chênh lệch ×32): `art_source/graphics_upgrade/room407_shell/previews/compare_d132.jpg`.

**Thử thêm:** lọc thường thay lọc bất đẳng hướng cho bản đồ độ nhám/AO. Nhanh hơn không đáng kể mà hình đổi chút ít (lệch tới 14/255), nên không dùng.

**FPS 1080p (FPS trung bình, torch / tube):**

| Góc | Trước D-132 | **Sau D-132** |
|---|---|---|
| centre | 100,7 / 82,3 | 112,3 / 89,6 |
| door_overview | 94,4 / 75,4 | 112,0 / **86,0** |
| back_overview | 108,4 / 92,2 | 126,0 / 103,7 |
| mirror_full | 111,9 / 84,8 | 121,3 / 87,9 |
| mirror_bath | 141,7 / 112,1 | 153,1 / 117,5 |
| bathroom | 146,6 / 116,5 | 158,1 / 121,4 |
| corridor_door | 194,3 / 152,1 | 205,4 / 149,5 |
| balcony_side | 116,7 / 99,1 | 139,6 / 113,2 |
| balcony_out | 298,3 / 212,0 | 317,8 / 219,9 |
| balcony_back | 219,0 / 162,9 | 220,5 / 173,4 |

- `balcony_side` và `balcony_back` lấy trung bình 2 lượt đo xen kẽ shader cũ và mới trong cùng buổi. Shader cũ lúc đó đạt 116,4 / 97,8 và 208,9 / 158,4.
- Lượt đo đầu của `balcony_back` (192 FPS) là dao động: hai lượt sau đều được 220.
- Góc nặng nhất từ 75,4 lên 86,0 FPS (13,3 → 11,6 ms mỗi frame), còn dư khoảng 5,0 ms. Khi chỉ có đèn pin, thấp nhất 112 FPS.
- p95 cao nhất: 13,9 ms (`mirror_full`, đèn trần), vì gương phản chiếu thật.
- Vỏ cũ ở góc nặng nhất đạt 96,7 FPS. Phần chênh còn lại khoảng 1,3 ms là nền, nhiễu mịn và mặt nạ (đọc ở mọi điểm vì vết bẩn phủ khắp phòng), cộng với cảnh bên ngoài.

**720p sau D-132:**

| Góc | torch / tube |
|---|---|
| centre | 183,7 / 132,5 |
| door_overview | 180,5 / 130,2 |
| back_overview | 214,1 / 165,5 |
| mirror_full | 187,7 / 122,5 |
| mirror_bath | 196,4 / 151,3 |
| bathroom | 265,1 / 172,5 |
| corridor_door | 289,0 / 251,3 |
| balcony_side | 243,4 / 196,5 |
| balcony_out | 495,8 / 357,3 |
| balcony_back | 331,4 / 215,7 |

5 góc cuối đo lại vì lượt đầu bị khóa 144,9 FPS. Ở 720p, khi FPS trên khoảng 150 thì số dao động nhiều giữa các lượt; mọi góc vẫn trên 120 FPS.

## 5. T-224 (23/10/2026): quản lý đứng trong phòng, đồ vật lý, đường đi dựng lại
Đo cùng cách ở 1080p, với bản sau T-224 (`f79deed`): 16 đồ nhỏ là vật thể vật lý nằm yên, đường đi dựng khi nạp phòng (khoảng 10–18 ms, một lần). Lượt "có quản lý": quản lý Tripo đứng giữa phòng (3,6; −3,6), quay về phía cửa, chạy động tác đứng.

| Góc | Không có quản lý | **Có quản lý** |
|---|---|---|
| centre | 109,5 / 88,6 | 105,1 / 84,3 |
| door_overview | 105,1 / 81,3 | 99,6 / **79,9** |
| back_overview | 125,9 / 102,1 | 124,0 / 102,4 |
| mirror_full | 122,4 / 89,7 | 107,1 / 83,4 |
| mirror_bath | 139,8 / 119,5 | 131,6 / 109,9 |
| bathroom | 154,1 / 121,6 | 141,7 / 95,3 |
| corridor_door | 157,4 / 139,7 | 114,0 / 99,6 |
| balcony_side | 135,7 / 109,3 | 132,6 / 109,3 |
| balcony_out | 307,6 / 212,0 | 254,4 / 193,3 |
| balcony_back | 230,2 / 175,1 | 160,7 / 104,3 |

(FPS trung bình, torch / tube; hai lượt chạy liền nhau.)

- **1080p vẫn trên 60 FPS ở mọi góc khi có quản lý:** thấp nhất 79,9 FPS (`door_overview`, đèn trần).
- Quản lý tốn thêm khoảng 0,4–1,5 ms mỗi frame ở các góc thấy ông ta, nhiều hơn khi đèn trần bật (bóng của đèn trần vẽ thân ông ta thêm 6 lần) và khi ông ta hiện trong gương.
- Đồ vật lý nằm yên gần như không tốn gì. Không có quản lý, số đo bằng D-132 trong phạm vi dao động.
- **Dao động lớn trong buổi đo này:**
  - lượt lặp lại thì mọi số đều tụt 10–30%, kể cả khi không có quản lý (máy nóng hoặc có việc chạy ngầm, game không chạy);
  - có những lượt bị khóa 144,9 FPS theo màn hình.

  Đã bỏ hết các lượt này; chỉ dùng cặp lượt đầu.
- Chưa đo: chương thật có người chơi, HUD, âm thanh, story và xác.
