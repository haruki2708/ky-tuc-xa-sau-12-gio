# Chương 2 "Trò chơi": cách vượt từng thử thách (để test nhanh)

> Bản để chủ dự án thử nhanh các chức năng. **Lộ hết đáp án.** Dữ liệu lấy đúng từ game: `docs/design/CH2_SCRIPT.md`, `game/data/ch2/`.

**Vào chương:** `D:\GAME_DEMO\build\windows\KyTucXa.exe` → **Chọn chương** → **Chương 2**.
Chết thì làm lại từ **đầu vòng** đang chơi (đầu vòng 3 hoặc đầu vòng 4).

**Hướng trong phòng 407**, tính khi đứng ở cửa nhìn vào phòng:
- **bên trái:** giường tầng dãy A (Phúc ở tầng trên, Việt ở tầng dưới), tủ của Việt sát tường gần cửa;
- **bên phải:** giường tầng dãy B (Đạt ở tầng trên, tầng dưới là giường Trung);
- **phía sau bên phải:** cửa nhà vệ sinh;
- **phía sau bên trái:** ban công.

---

## Vòng 3: nối từ (6:00–7:00)

### Luật
- Lượt theo thứ tự **Phúc → Việt → Đạt → Trung (bạn)** → Phúc …
- Đến lượt bạn: bảng hiện **4 từ**, bấm **1–4** trong **15 giây**.
- Từ đúng phải **bắt đầu bằng tiếng cuối của từ trước, đúng cả dấu**, và **không trùng 3 từ gần nhất** (bảng có hiện 3 từ gần nhất).
- Chỉ trả lời được khi đứng **trong phòng ngủ**. Ở nhà vệ sinh hoặc ban công, bảng mờ đi với dòng "Họ không nghe thấy bạn", nhưng đồng hồ vẫn chạy.
- **Ba bẫy thường gặp:**
  - đúng tiếng nhưng **sai dấu**, ví dụ cần "vở …" mà gặp "vỡ nát";
  - âm gần giống nhưng khác tiếng, ví dụ "sính lễ" khi cần "sinh …";
  - lặp lại một từ vừa nói.

### N1. Lượt đầu
Phúc "điểm danh" → Việt "danh sách" → Đạt "sách vở" → bạn chọn **"vở kịch"**. Đây là từ duy nhất đúng.

### N2. Gài bẫy xác (mua thời gian)
Thỉnh thoảng trong 4 từ có **từ cụt**: từ đúng luật, nhưng không có từ nào nối tiếp được. Chọn từ đó thì xác kế tiếp ú ớ hết 15 giây, gục xuống, 10 giây sau bật dậy rồi bắt đầu chuỗi mới. Bạn có khoảng **25 giây rảnh**.

Danh sách từ cụt: **sống sót, chết chóc, người ngợm, thần thánh, kinh khủng, mê man, lạnh lẽo**.

### N3. Lấy 3 miếng giẻ (mỗi lần cầm một món)
| Món | Ở đâu | Gợi ý đường đi |
|---|---|---|
| **Áo của Việt** | Trong tủ của Việt (tường trái, gần cửa) | Gần nhất, lấy trước |
| **Giẻ lau** | Trên bồn rửa trong **nhà vệ sinh** (cửa mở sẵn ở vòng 3) | Ra khỏi phòng ngủ, phải canh giữa hai lượt |
| **Khăn tắm** | Trên dây phơi ngoài **ban công** | Xa nhất, nên gài bẫy xác (N2) rồi mới đi |

Nhìn vào món đồ, bấm **E** để cầm. Cầm món khác thì món cũ tự về chỗ cũ.

### N4. Bịt miệng 3 xác
- Cầm đồ, đến sát đầu xác, nhìn vào miệng xác, bấm **E**.
- Xác bị bịt vẫn quay mặt nói, nhưng chỉ ú ớ. Tới lượt nó thì nó gục rồi bật dậy, và lượt chuyển sang người kế tiếp.
- **Jumpscare:** bịt đúng lúc xác **đang nói** thì nó quay sang nhìn chằm chằm vào bạn (không chết).

Thử: bịt cả 3 xác (Phúc, Việt, Đạt).

### N5. Vòng lặp "học"
- Bịt đủ 3 xác thì chỉ còn bạn nối, và mỗi lượt luôn có một từ dẫn dần về vòng lặp.
- Khoảng 6:35 Minh Nhật gửi vòng lặp vào chat:
  > **học sinh → sinh viên → viên phấn → phấn đấu → đấu tranh → tranh luận → luận văn → văn học** → học sinh …
- Lái chuỗi về chữ "học", rồi chọn đúng 8 từ của vòng **liên tiếp**: vòng 3 kết thúc sớm và nhảy tới 7:00.

### Các mốc khác của vòng 3 (chỉ xem)
- **6:02:** ba xác ngồi dậy (jumpscare).
- Khi một xác gục lần đầu: Ngư nói xác không sợ thua.
- **Lượt thứ 5 của bạn:** điện thoại báo **CAM 310**, phòng 310 thua, ba xác lao vào người sống (jumpscare). Mở tab Camera bằng `]`.
- **Lượt thứ 9:** Ngư kể manh mối "kéo tay mà nó không phản ứng".

---

## Vòng 4: tắm nước nóng (7:00–8:00)

### N6. Cửa nhà vệ sinh kẹt
Cửa bị phồng nước, đóng lại. Nhìn vào cửa, bấm **E 3 lần** (mỗi lần cửa rung); lần thứ 3 cửa bật mở, hơi nóng phụt ra.

### N7. Mỗi lượt 2 phút: CÓ hay KHÔNG
- Màn hình đếm ngược khoảng **8 giây**. Nhìn vào nút dưới màn hình, bấm **E**:
  - **CÓ:** phải **đứng trong buồng tắm** suốt lượt. Bước ra là chết. Nước từ **50 độ** trở lên là chết bỏng.
  - **KHÔNG:** không xả nước, đứng đâu cũng được.
- Không chọn kịp thì chết.
- Cần đủ **25 phút** (13 lượt CÓ an toàn) trước 8:00.

### N8. Lau màn hình
Nước nóng (từ 40 độ) làm màn hình mờ. Nhìn vào màn hình, **giữ E 1 giây** để lau. Lau được cả khi đứng trong buồng tắm.

### N9. Quy luật nhiệt độ (đáp án)
**Chữ số hàng chục của lần sau = chữ số hàng đơn vị của (tổng hai chữ số lần trước).**
Ví dụ: 67 → 6+7 = 13 → lần sau 3x độ (an toàn); 81 → 9 → 9x độ (chết).

Chọn đúng từng lượt (bảng đã tính sẵn, đủ 26 phút ở lượt 24):

| Lượt | Giờ | Nhiệt độ | Chọn | Đã tắm |
|---|---|---|---|---|
| 1 | 7:02 | 67 | KHÔNG | 0 |
| 2 | 7:04 | 37 | **CÓ** | 2 |
| 3 | 7:06 | 8 | **CÓ** | 4 |
| 4 | 7:08 | 81 | KHÔNG | 4 |
| 5 | 7:10 | 96 | KHÔNG | 4 |
| 6 | 7:12 | 58 | KHÔNG | 4 |
| 7 | 7:14 | 37 | **CÓ** | 6 |
| 8 | 7:16 | 1 | **CÓ** | 8 |
| 9 | 7:18 | 19 | **CÓ** | 10 |
| 10 | 7:20 | 4 | **CÓ** | 12 |
| 11 | 7:22 | 43 | **CÓ** | 14 |
| 12 | 7:24 | 74 | KHÔNG | 14 |
| 13 | 7:26 | 19 | **CÓ** | 16 |
| 14 | 7:28 | 9 | **CÓ** | 18 |
| 15 | 7:30 | 94 | KHÔNG | 18 |
| 16 | 7:32 | 35 | **CÓ** | 20 |
| 17 | 7:34 | 86 | KHÔNG | 20 |
| 18 | 7:36 | 41 | **CÓ** | 22 |
| 19 | 7:38 | 52 | KHÔNG | 22 |
| 20 | 7:40 | 79 | KHÔNG | 22 |
| *(Ngư gọi, N10)* | | | | |
| 21 | 7:42 | 63 | KHÔNG | 22 |
| 22 | 7:44 | 94 | KHÔNG | 22 |
| 23 | 7:46 | 31 | **CÓ** | 24 |
| 24 | 7:48 | 45 | **CÓ** | 26 → hết vòng, nhảy tới 8:00 |

Lượt 13 (7:26) gương thoáng hiện bóng quản lý (jumpscare).

### N10. Cứu Ngư (sau lượt 20)
- Ngư gọi: ba lần gần nhất bên cô ấy là **74, 15, 62**, hỏi lượt tới chọn gì. Có **10 giây**.
- Đáp án: **câu 1, "Đừng xả. Chọn Không."** (62 → 8 → lượt tới 8x độ).
- Chọn câu 2 thì Ngư chết và bạn **thua**.

### Hết chương (8:00)
Loa báo còn 3 người, hiện thẻ "Hết chương 2", mở khóa chương 3.

---

## Thử từng cách chết
| Muốn thử | Làm thế nào | Về lại |
|---|---|---|
| Hết giờ nối từ | Không bấm gì khi tới lượt | Đầu vòng 3 |
| Nối sai | Chọn từ sai dấu, ví dụ "vỡ nát" ở lượt đầu | Đầu vòng 3 |
| Ra khỏi phòng | Bước qua cửa 407 | Đầu vòng đang chơi |
| Bỏng | Chọn **CÓ** ở lượt 1 (67 độ) | Đầu vòng 4 |
| Bước ra khi đã chọn CÓ | Chọn CÓ ở lượt 2, rồi bước ra khỏi buồng | Đầu vòng 4 |
| Không chọn | Để đếm ngược hết ở bất kỳ lượt nào | Đầu vòng 4 |
| Thiếu 25 phút | Chọn KHÔNG hết các lượt | Đầu vòng 4 |
| Mất Ngư | Ở N10 chọn câu 2 | Đầu vòng 4 |

## Nhảy thẳng tới vòng 4 (đỡ chơi lại vòng 3)
Mở game từ thư mục dự án (bản `.exe` không có menu này):
```
D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe --path D:\GAME_DEMO\game
```
Vào chương 2, bấm **F9**, chọn **vòng 3** hoặc **vòng 4**.

## Ghi lại giúp
- Âm thanh: giọng xác đọc từ có nghe rõ chữ không; tiếng ú ớ, nước sôi, đếm ngược; to hay nhỏ.
- Bảng nối từ: đọc kịp trong 15 giây không; có thấy rõ 3 từ gần nhất.
- Màn hình vòi sen: đọc được không khi đứng trong buồng tắm.
- Độ khó: tự đoán được quy luật nhiệt độ không (thiết kế D-046 là **không gợi ý**).
- Lỗi: kẹt, không bấm được, chữ sai. Ghi giờ trong game.
