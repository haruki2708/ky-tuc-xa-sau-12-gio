# GDD rút gọn — Demo

Tài liệu đang làm. Phần **[CẦN CHỐT]** sẽ được quyết định cùng chủ dự án ở task T-113.

## Một câu
Nửa đêm trong ký túc xá vắng người dịp nghỉ lễ, bạn phải tìm ra dòng nào trong "Nội quy ban đêm" là giả trước khi làm theo nó.

## Trụ cột trải nghiệm
1. **Suy luận hơn phản xạ.** Người chơi sợ vì không chắc mình đúng, không phải vì bị hù.
2. **Đời thường hóa bất thường.** Việc quen thuộc (tắt đèn, lấy nước, khóa cửa) bị luật biến thành rủi ro.
3. **Hậu quả có thể nhìn thấy.** Làm sai thì ký túc xá thay đổi, hiếm khi chết ngay.
4. **Rõ ràng.** Đồ vật và manh mối dễ nhận ra dù đồ họa theo phong cách PS1.

## Vòng chơi
Nhận nội quy (giấy dán, loa) → làm việc thường ngày → gặp tình huống mà luật chi phối → đối chiếu manh mối (các bản nội quy, sổ trực, hồ sơ phòng) → hành động → hậu quả hoặc tiến trình → đoạn tiếp theo.

## Hệ thống
- **Luật (RuleSystem):**
  - Mỗi luật có `id`, nội dung (key dịch), một cờ `is_fake` ẩn, điều kiện kích hoạt và hậu quả.
  - Sổ tay tự ghi lại các luật đã đọc. Người chơi có thể đánh dấu "nghi ngờ".
- **Hậu quả:** mức "lệch" tăng dần. Mỗi mức đổi môi trường: tắt đèn một đoạn, đổi số phòng, thêm tên vào danh sách điểm danh. Chỉ có 1–2 trường hợp thua thật, khi đó quay lại checkpoint.
- **Giấy tờ:** xem cận cảnh ở độ phân giải đầy đủ. Chữ lấy từ file dịch, không in vào texture.

## Diễn biến demo (nháp, [CẦN CHỐT])
| Giờ | Đoạn | Nội dung | Thời lượng |
|---|---|---|---|
| 23:50 | Hướng dẫn | Về phòng, khóa cửa, tắt đèn; học di chuyển và tương tác | 3' |
| 00:00 | Nội quy | Loa đọc nội quy; luật đầu tiên được áp dụng | 3' |
| 00:30 | Đối chiếu | Bản nội quy trong phòng lệch bảng ở hành lang một dòng; tìm sổ trực để xác định dòng giả | 5' |
| 01:00 | Điểm danh | Loa đọc 5 tên; tra hồ sơ phòng; quyết định có trả lời không | 4' |
| 01:30 | Mâu thuẫn | Hai luật chọi nhau trong nhà vệ sinh; lựa chọn; kết thúc lơ lửng, kèm màn hình mời theo dõi game | 3' |

## Phong cách
- **Hình ảnh:** PS1 rõ rệt (D-005). Bảng màu lạnh: xanh đèn tuýp, vàng ố tường vôi; một màu nhấn đỏ cho ghế nhựa và chữ nội quy.
- **Âm thanh:** quạt trần, tiếng ù đèn tuýp, dế, nước nhỏ giọt, dép lê, loa phát thanh rè. Im lặng cũng là công cụ.
- **Chi tiết Việt Nam:** mùng, giường tầng sắt, tủ sắt, ghế nhựa đỏ, xô chậu, dây phơi đồ ở hành lang, bảng nội quy đóng khung, sổ trực, giờ khóa cổng.

## [CẦN CHỐT] ở T-113
- Bộ luật của demo: số luật, câu chữ, luật nào giả.
- Tên nhân vật và lai lịch "người thứ năm".
- Sơ đồ tầng.
