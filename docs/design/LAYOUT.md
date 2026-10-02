# Sơ đồ tầng 4, nhà B (T-113)

> **Trạng thái: ĐÃ DUYỆT** (D-020). Dùng cho T-112 (lane B dựng greybox). Kích thước tính bằng mét, theo bộ module 2 m của T-102.

## 1. Tổng thể
Kiểu ký túc xá Việt Nam phổ biến: **hành lang ngoài** chạy dọc một bên tòa nhà, có lan can nhìn xuống sân. Các phòng nằm một phía. Nhà vệ sinh chung ở một đầu. Cầu thang và bàn trực ở đầu kia.

```
                               BẮC
   x=0      6    10   14   18   22   26   30   34   38   44
   +--------+----+----+----+----+----+----+----+----+---------+
   |  NHÀ   |401 |402 |403 |404 |405 |406 |407 |408 | CẦU     |
   |  VỆ    |    |    |    |    |    |    | ** |    | THANG   |
   |  SINH  |    |    |    |    |    |    |    |    | (khóa)  |
   +--D-----+-D--+-D--+-D--+-D--+-D--+-D--+-D--+-D--+--[T]--S-+  z=0
   |  hành lang ngoài, rộng 2,4 m       ^dép        B  bàn trực|
   +=====================================================+-----+  z=2,4
     lan can 1,1 m + dây phơi đồ          (sân, cây, dế)
                               NAM
   D = cửa   ** = phòng 407 (vào được)   B = bảng nội quy   T = loa
   S = cửa sắt kéo cầu thang, khóa xích  ^dép = 4 đôi dép trước cửa 407
```

- **Chiều dài hành lang:** 44 m. Từ cửa 407 tới bàn trực khoảng 8 m; tới nhà vệ sinh khoảng 26 m. Đi bộ hết hành lang mất khoảng 20 giây. Quãng đi dài tới nhà vệ sinh ở đoạn 5 là cố ý, để tạo căng thẳng.
- **Chỉ phòng 407 vào được.** Các phòng khác khóa. Cửa có biển số và khe sáng tối dưới chân cửa.
- **Lan can phía nam:** cao 1,1 m, nhìn ra sân tối, có tán cây và đèn đường xa. Tiếng dế và xe máy xa từ phía này. Người chơi **không** trèo hoặc rơi xuống được (có collision cao 2 m, vô hình).
- **Đầu đông:** cửa sắt kéo của cầu thang khóa bằng xích, có biển "Khóa cổng 23:00". Đây là lý do người chơi không rời tầng.

## 2. Hành lang
| Vật | Vị trí | Ghi chú |
|---|---|---|
| Đèn tuýp trần | Mỗi 4 m, ngay trước mỗi cửa phòng (9 bóng) | Mỗi bóng có `LightHum`. Bóng trước 405 là bóng chập chờn ở mức "lệch" 1 |
| Bảng nội quy đóng khung, có dấu đỏ | Tường bắc, giữa cửa 408 và bàn trực (x khoảng 38,5) | Xem cận cảnh được. Đoạn 4 có thêm giấy viết tay kẹp vào khung |
| Bàn trực tầng | Đầu đông, sát cửa cầu thang | Sổ trực, đèn bàn, ghế nhựa đỏ, điện thoại bàn cũ |
| Loa phát thanh | Tường phía trên bàn trực | Âm 3D: người chơi nghe rõ nhất khi ở gần |
| Dép trước cửa 407 | Sát cửa, phía hành lang | 4 đôi; mức "lệch" 3 hoặc khi mở cửa sai ở điều 2 thì thành 5 đôi |
| Dây phơi đồ | Dọc lan can, từ trước 403 tới trước 407 | Vài cái áo, khăn; mức "lệch" 3 thêm một áo trắng |
| Xô, chậu nhựa | Trước vài cửa phòng | Chỉ để trang trí |
| Đoạn tối (mức "lệch" 2) | Trước 402–404 | Đèn tắt, tiếng ù im |

## 3. Phòng 407 (4 m × 5 m, cao 3 m)
```
              BẮC (cửa sổ có song sắt)
   +---------------------------------+
   | [bàn học + đèn bàn]  [ghế đỏ]   |
   |                                  |
   | [giường tầng A]   [giường tầng B]|
   |  trên: Phúc        trên: Đạt     |
   |  dưới: Việt        dưới: Trung   |
   |               (quạt trần)        |
   | [tủ sắt x2]         [tủ sắt x2]  |
   +----------------D------[công tắc]-+
              hành lang (NAM)
```
| Vật | Ghi chú |
|---|---|
| 2 giường tầng | Ba giường có mùng **đóng** và người nằm (Phúc, Việt, Đạt). Giường dưới bên B (của Trung) có mùng **mở** |
| 4 tủ sắt | Tủ của Trung mở được. Trong cửa tủ dán **hồ sơ phòng 407** (4 tên, 4 ảnh thẻ) |
| Cửa | Khóa và mở được. **Giấy nội quy photo** dán ở mặt trong cánh cửa (có điều 3 giả) |
| Công tắc đèn chính | Cạnh cửa, phía trong. Đèn chính là đèn tuýp trần (có `LightHum`) |
| Đèn bàn | Luôn sáng, đủ để nhìn sau khi tắt đèn chính |
| Quạt trần | Có `AmbientEmitter` tiếng quạt; mức "lệch" 4 thì quay chậm lại |
| Điện thoại của Trung | Trên giường Trung; rung báo 0 giờ ở đoạn 1 |

## 4. Nhà vệ sinh chung (6 m × 5 m)
| Vật | Ghi chú |
|---|---|
| Dãy 3 bồn rửa và gương dài | Một vòi tự chảy ở đoạn 5. Gương dùng reflection probe hoặc camera phụ để làm "hình phản chiếu chậm nửa nhịp" |
| Tờ "Nội quy (6 điều)" | Dán cạnh gương |
| 3 buồng vệ sinh | Cửa khép, không vào được |
| Vòi nước nhỏ giọt | `AmbientEmitter` nhỏ giọt ngẫu nhiên |
| Sàn | Gạch men ướt, metadata `surface = &"tile"` (sau này có thể thêm `wet_tile`) |

**Không cắt nhà vệ sinh** (D-020), kể cả khi chậm tiến độ.

## 5. Âm thanh theo khu
| Khu | ReverbZone | AmbientZone |
|---|---|---|
| Phòng 407 | `ROOM` | Quạt trần, tiếng ù đèn chính |
| Hành lang | `CORRIDOR` | Dế và xe máy xa (từ phía sân), tiếng ù các đèn tuýp |
| Nhà vệ sinh | `BATHROOM` | Nước nhỏ giọt, tiếng ù đèn |
| Khu bàn trực | `CORRIDOR` | Tiếng rè nhỏ của loa khi không phát |

Mọi sàn phải có metadata `surface` (Review T-105).

## 6. Điểm hồi sinh (checkpoint)
Node `Marker3D` đặt tên đúng `checkpoint_id`:

| `checkpoint_id` | Vị trí |
|---|---|
| `seg1_start` | Hành lang trước cửa 407, quay mặt vào cửa |
| `seg2_start` | Trong phòng 407, cạnh công tắc đèn |
| `seg3_start` | Trong phòng 407, quay ra cửa |
| `seg4_start` | Trong phòng 407, cạnh tủ của Trung |
| `seg5_start` | Hành lang trước cửa 407, quay về phía tây |

## 7. Module cần thêm (task sau của lane B)
Bộ kit T-102/T-121 đã có: tường, tường có cửa, cửa, giường tầng, mùng, tủ sắt, quạt trần, ghế nhựa. Greybox T-112 dùng hộp tạm cho những vật còn thiếu, làm thật ở task sau:
- lan can và song cửa sổ,
- bồn rửa và gương, vách buồng vệ sinh,
- bàn học, bàn trực, đèn bàn,
- bảng nội quy đóng khung, biển số phòng,
- loa phát thanh, cửa sắt kéo, xích,
- dép, dây phơi, áo, xô chậu,
- đèn tuýp có máng.
