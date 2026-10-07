# Chương 3 "Truy sát": cách vượt từng khu (để test nhanh)

> Bản để chủ dự án thử nhanh. **Lộ hết đáp án.** Thiết kế: `docs/design/CH3_DESIGN.md`; lời thoại: `docs/design/CH3_SCRIPT.md`.

**Vào chương:** `D:\GAME_DEMO\build\windows\KyTucXa.exe` → **Chọn chương** → **Chương 3** (đã mở khóa sẵn trên máy anh/chị; nếu chưa thấy, chơi hết chương 2 hoặc báo integrator).
**Chết** thì làm lại từ **đầu khu** đang chơi: nhà B, vườn hoa, sân vận động hoặc cổng.

**Điều khiển mới:**
- **Shift** chạy, tốn thể lực. Viền màn hình tối dần là sắp hết hơi; hết hẳn thì chỉ đi bộ được một lúc và thở dốc to (xác nghe thấy).
- **Chuột trái** vung thanh sắt khi đang cầm. Phải **nhắm vào đầu** xác: trúng thì xác gục khoảng 5 giây. Thanh sắt cong dần (xem biểu tượng góc dưới) và **gãy sau 8 lần trúng**.
- **E** nhặt đồ, mở cửa. **Ctrl** cúi.
- Xác chạm vào người (khoảng 1 m) là **chết ngay**.

---

## Vượt nhanh (tóm tắt)

1. **Phòng 407:** nghe loa xong, ba bạn cùng phòng bật dậy. **Chạy ngay ra cửa.**
2. **Hành lang tầng 4:** cầu thang chính (đầu xa phòng 407) đầy xác, nhưng ở **xa**; hành lang gần bạn trống. Các phòng 406, 405… phía sau bị đập cửa rồi xác bước ra khi bạn đi ngang (nghe tiếng đập là biết); lấy chìa xong thì phòng 408 cạnh bàn trực cũng bật mở. Đi về phía **bàn trực** (gần phòng 407), mở ngăn kéo lấy **chìa khóa** (E), rồi mở **cửa cầu thang thoát hiểm** ở cuối hành lang cùng phía (E).
3. **Cầu thang thoát hiểm:** xuống tầng 3, rồi tầng 2. Đoạn xuống tầng 1 **đã sập**.
4. **Tầng 2:** Minh Nhật gọi, cậu ấy kẹt trong **phòng 203**, 4 xác đang đập cửa. **Bình cứu hỏa** treo ở tường trong cùng chiếu nghỉ cầu thang thoát hiểm tầng 2: bấm **E** để đập, rồi **nấp sâu trong phòng 207** (phòng không cửa gần đó). Tiếng động kéo cả đám đi hết hành lang vào chiếu nghỉ; ra khỏi 207 rồi đi về phía cầu thang chính. Minh Nhật ra khi đám xác rời cửa và đi theo sau bạn.
5. Băng qua hành lang tầng 2 tới **cầu thang chính** (đầu kia), xuống tầng 1.
6. **Tầng 1:** cửa chính bị xích. Vào **phòng quản lý** ở cuối sảnh, **cúi (Ctrl)** và chui qua **cửa sổ vỡ**. Đi vòng ra **vườn hoa** trước nhà B.
7. **Vườn hoa:** tới gần **Ngư** (đứng trên ghế đá). Cô ấy đưa thanh sắt. Thử đập xác bò ra từ bồn hoa.
8. **Sân vận động:** hai bạn đi theo sau bạn tới đây. Sống sót khoảng **4 phút**: chạy vòng, cắt qua sân cỏ, lên khán đài để thở; đập đầu xác chắn đường. Thanh sắt mới ở **gầm khán đài**.
9. **Cổng trường:** **đừng lại gần bảo vệ** (khoảng 3 m thì họ giơ dùi cui; tiến thêm hoặc đập trúng họ là chết).
10. **Nhà ăn:** tivi bật và đọc bản tin. Ba người chia nhau ra, hết chương 3.

---

## Chỗ đáng chú ý khi thử
- **Thanh sắt rải trên map:** vườn hoa (giường tầng đổ), gầm khán đài sân vận động, và vài chỗ khác.
- **Tiếng còi cứu hộ rất nhỏ:** đứng yên ở chỗ cao nhất khán đài.
- **Manh mối động đất:** đồng hồ bàn trực dừng lúc 4:00; tường cầu thang nứt; cột cổng nghiêng.
- **Jumpscare:** cả hành lang quay đầu khi ra khỏi 407; xác trên bậc cầu thang tầng 3; con dao trong phòng quản lý; xác bò ra ở vườn hoa; đèn sân chớp sáng; bảo vệ quay đầu; tivi nhà ăn.

## Thử từng cách chết
| Muốn thử | Làm thế nào | Về lại |
|---|---|---|
| Bị xác tóm | Đứng yên cho xác tới | Đầu khu đang chơi |
| Bảo vệ | Đi thẳng vào hàng bảo vệ, hoặc đập trúng một người | Đầu khu cổng |

## Nhảy thẳng tới một khu (đỡ chơi lại)
Mở game từ thư mục dự án (bản `.exe` không có menu này):
```
D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe --path D:\GAME_DEMO\game
```
Vào chương 3, bấm **F9**, chọn **nhà B**, **vườn hoa**, **sân vận động** hoặc **cổng**.

## Ghi lại giúp
- **FPS / giật:** chỗ nào giật, nhất là vườn hoa khi đông xác (đo trên máy: trung bình trên 100 FPS).
- **Xác:** quá dễ hay quá khó né; có bị tóm "oan" không (chưa chạm mà đã chết).
- **Thanh sắt:** đập có dễ trúng đầu không; 8 lần có đủ không.
- **Thể lực:** hết hơi nhanh quá hay chậm quá.
- **Đồng đội:** có chạy đúng hướng, có bị kẹt không.
- **Đường đi:** có chỗ nào kẹt, không qua được (cửa sổ phòng quản lý, cầu thang, khán đài).
- **Sân vận động:** có tối quá không.
- **Âm thanh:** chưa ai nghe bằng tai; to hay nhỏ, có rõ không.
