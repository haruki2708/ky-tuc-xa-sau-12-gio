# Chơi thử chương 1 "Tổng tắc" (bản 2)

**Bản chơi thử:** `D:\GAME_DEMO\build\windows\KyTucXa.exe`

Mở game, bấm **Chơi mới**, đọc màn cảnh báo nội dung. Một lượt khoảng 15–20 phút nếu làm nhanh và không chết. Thời gian trống được cắt bớt khi làm xong nhiệm vụ (D-040). Độ khó chỉ có **Insane**: chết là quay về **đầu vòng** đang chơi.

> Bản ngày 2026-10-05 chưa có khu camera của lane B (T-165). Tab Camera đang dùng cảnh tạm. Âm thanh mới của lane E chưa ai nghe bằng tai.

## Điều khiển
| Phím | Việc |
|---|---|
| WASD, chuột | Đi, nhìn |
| Shift | Chạy |
| C hoặc Ctrl | Cúi |
| E (hoặc chuột trái) | Tương tác: giường, tủ, giấy, công tắc, dây mạng, chốt cửa, tường, đèn bàn, bắt máy |
| Space (giữ) | Nín thở khi đang nằm. **Tối đa 6 giây**; quá thì thở hắt ra thành tiếng |
| Q | Giơ hoặc hạ điện thoại |
| F | Đèn pin |
| 1–4, hoặc lăn chuột rồi nhấp trái | Chọn câu trả lời trong cuộc gọi |
| `[` và `]` | Đổi tab điện thoại: Cuộc gọi, Sơ đồ, Camera (Camera có sau khi được mở khóa) |
| Mũi tên, Enter | Tab Sơ đồ: chọn phòng, đánh dấu X |
| `,` và `.` | Tab Camera: đổi camera |
| Tab | Sổ quy tắc |
| Esc | Đóng giấy đang đọc, menu tạm dừng |

Khóa số: xoay từng vòng số rồi bấm **Thử mở**. Sai 3 lần thì khóa kẹt 60 giây và kêu báo động.

## Diễn biến (không lộ đáp án)
- **4:00, mở đầu:** loa báo nằm trên giường sẽ chết. Có 60 giây để rời giường; ra nhà vệ sinh cuối hành lang rồi về phòng.
- **4:05, vòng 1:** không được ra khỏi phòng. Có cuộc gọi nhóm, pin điện thoại yếu, rồi lần lượt: mất mạng, có người gõ cửa, tiếng gõ lạ từ tường phòng bên.
- **5:00, vòng 2:** người trong nhóm chết lần lượt, xem được qua camera an ninh trên điện thoại. Có biên bản kiểm tra bị xé thành 3 mảnh trong phòng. Rồi quản lý tới kiểm tra phòng 407.
- Sau đó còn một lựa chọn quan trọng, chỉ có 10 giây.
- Hết chương thì mở khóa chương 2 ở mục **Chọn chương**.

## Nhờ anh/chị để ý và ghi lại
1. **Âm thanh:** độ to (anh/chị thích âm nhỏ), tiếng gõ tường, ổ điện chập, cục phát mạng, tay nắm cửa vặn, chuông Kiệt, tiếng chết, báo động khóa; giọng đọc eSpeak có chấp nhận được không.
2. **Độ khó:** nhiệm vụ nào không tự hiểu được? Chết mấy lần mới qua? Có cần thêm manh mối không (D-038 là không giải thích luật)?
3. **Nhịp độ:** còn chỗ nào chờ lâu hoặc chán không?
4. **Cảnh chết:** ngã ngửa phụt máu khi ra khỏi phòng, quản lý chém, giường nổ; lớp máu trên màn hình.
5. **Hình ảnh:** phòng 407 mới (nhà vệ sinh, ban công), tab Sơ đồ, tab Camera.
6. **Hai điểm bot phát hiện cần anh/chị xem có ổn không:**
   - đủ 3 mảnh thì biên bản ghép **tự mở** và game tạm dừng tới khi đóng (Esc);
   - tab Camera chỉ mở sau khi Minh Nhật nói về camera ở đầu vòng 2.
7. **Lỗi:** kẹt, rơi khỏi bản đồ, chữ sai, phím không ăn. Ghi giờ trong game (góc điện thoại) để integrator tìm lại.

Ghi nhận xét thẳng vào cuộc trò chuyện với integrator; integrator sẽ chép vào `docs/DECISIONS.md` và tạo task sửa.

## Thử nhanh từng đoạn (menu F9)
Menu F9 **không có trong file .exe**. Muốn nhảy thẳng tới một đoạn thì mở game từ thư mục dự án:

```
D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe --path D:\GAME_DEMO\game
```

Vào chương 1 rồi bấm **F9**:
- nhảy tới: mở đầu, vòng 1, vòng 2, ngay trước khi quản lý tới;
- bật/tắt: bất tử, hiện đáp án, tua nhanh x4.

Menu F9 không ghi vào bản lưu thật.

---

## Đáp án (chỉ đọc khi kẹt)
<details>
<summary>Bấm để xem</summary>

- **Pin yếu:** tủ Đạt khóa số. Mã là **2109**, ngày sinh của Phúc trên thẻ sinh viên. Lấy cục sạc, cắm ở chỗ dây sạc trên bàn.
- **Mất mạng 4:28:** bật **công tắc 2** của ổ điện (cục phát mạng khởi động 8 giây), cắm **dây xanh** vào ổ mạng trên tường. Công tắc 3 là ấm đun: ổ chập, khóa 20 giây. Không sửa thì 4:48 mạng tự có lại nhưng lỡ mất các câu nói trong lúc mất mạng.
- **4:35, Việt gõ cửa:** **chốt cửa trong 10 giây**, không thì bị lôi ra ngoài.
- **4:38, tiếng gõ tường (Khoa phòng 406):** mã gõ 5×5 không có chữ J, gõ hàng trước, cột sau. Khoa gõ "CON SONG". Trả lời **"CO"**: gõ tường 1 cái, nghỉ, 3 cái, nghỉ dài, 3 cái, nghỉ, 4 cái. Khoa gõ lại "SO GIUONG".
- **Vòng 2:** lục **tủ Việt**, **lật nệm Phúc**, **sọt rác**, đủ 3 mảnh thì biên bản tự ghép.
- **Trước khi quản lý tới:** **tắt đèn bàn**, **hạ điện thoại**, **tắt đèn pin**, **nằm lên giường của một bạn đã chết** (giường Phúc, Việt hoặc Đạt; không phải giường Trung).
- **Khi quản lý trong phòng:** không cử động, không xoay nhìn nhanh. Ông ta hỏi xong thì **giữ Space nín thở** (dưới 6 giây).
- **Cứu Minh Nhật (10 giây):** chọn câu **1**: "Nằm giường của người đã chết, tắt hết đèn, nín thở khi ông ta hỏi xong."

</details>
