# T-223 — Sửa lỗi chơi thử 22/10: tay nắm cửa phòng 407, đèn pin, khung điện thoại
- Lane: **integrator** (Claude làm thay B/D) | Trạng thái: **đang làm** | Agent: Claude Code ở máy (Opus 5.5)
- Quyết định: **D-133**. Chủ dự án chơi chương 1 bản 22/10 21:51 và báo lỗi, rồi chọn đèn pin mức D, khung điện thoại kiểu B.
- Liên quan: [T-224](T-224-manager-ch1-beds-chase-physics.md) (lỗi quản lý chủ dự án báo cùng lúc).

## Chủ dự án báo (22/10/2026)
> "thứ nhất: chưa làm tay nắm cửa vào phòng 407, thứ 2 đèn pin quá sáng, thứ 3: mục điện thoại bị chèn xuống màn hình nên tôi không thể thấy hết được đoạn chat và camera"

## 1. Tay nắm cửa phòng 407
**Nguyên nhân** (ảnh chụp cận hai mặt cửa):
- Cánh cửa Tripo có tay nắm gạt ở cả hai mặt (`Door407/Pivot/HandlePivot/Lever`, `Lever_001`, dài 10 cm).
- Phía hành lang, mép ô cửa của tường hành lang cũ (PS1) che mất mép cánh có tay nắm, nên nhìn từ hành lang gần như không thấy tay nắm.
- Phía trong phòng có khe sáng giữa cánh cửa và khung, nhìn xuyên ra tường hành lang.

**Sửa:** căn lại ô cửa phía hành lang cho khớp cánh và khung; tay nắm thấy rõ từ hành lang; bịt khe; chụp ảnh trước/sau hai mặt.

## 2. Đèn pin
- **D-133: mức D**, `light_energy` 1,5 ở mọi nơi.
  - Trong phòng 407 trước là 5,0 (`room407.gd` `ROOM_TORCH`, D-104).
  - Ngoài phòng trước là 2,5 (`phone_item.tscn`).
- Ảnh 4 mức: `build/t223/torch_levels.jpg` (không đưa vào repo). Mức D tối hơn mức hiện tại khoảng 25–35% theo độ sáng trung bình ảnh. Gạch trắng nhà tắm ở gần vẫn sáng trắng.
- Đèn pin dùng chung cho mọi chương. Nếu chương 3 ngoài trời quá tối thì tăng riêng cho chương đó.

## 3. Khung điện thoại
**Nguyên nhân:** khung chỉ chiếm góc dưới bên phải (`phone_screen.tscn` `Root/Phone`: ngang 0,61–0,98, dọc 0,54–0,89), nên:
- chat chỉ hiện khoảng 5 dòng;
- hình camera khoảng 340×190.

Đo ở 1920×1080 thì khung không tràn khỏi màn hình; đây là thiết kế cũ quá nhỏ.

**D-133: kiểu B**, khung nằm ngang to gấp đôi: ngang 0,50–0,98, dọc 0,30–0,95.
- Chat hiện khoảng 14 dòng.
- Camera khoảng 900×500.
- Ảnh mẫu: `build/t223/phone_layouts.jpg`.
- Các khung gắn theo điện thoại phải dời cho khỏi chồng lên khung mới: chọn câu trả lời (`Choices`), cuộc gọi đến (`Incoming`), ô gõ chữ chương 2 và chương 4 (đang đẩy mép trên lên 0,37).

## Kiểm tra
- Ảnh trước/sau cho cả 3 mục.
- Bộ test và `check.ps1`.
- Build lại bản chơi thử.
