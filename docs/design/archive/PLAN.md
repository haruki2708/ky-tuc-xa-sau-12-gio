# Kế hoạch tổng — "Ký túc xá sau 12 giờ"

> **PHẦN CHƠI CŨ — KHÔNG CÒN DÙNG.** Thuộc bản demo "người thứ năm" (tag git `demo-v1`). Thiết kế hiện hành: `docs/design/STORY.md` (v2, D-034, D-035). Giữ lại để tham khảo.

Duyệt ngày 2026-10-02. Các quyết định chi tiết xem `DECISIONS.md`.

## Mục tiêu
- Bản demo 15–20 phút đăng **itch.io** trong 6–8 tuần (mục tiêu 6 tuần), ngân sách tài nguyên 0đ.
- Demo là phép thử thị trường. Chỉ chốt quy mô bản Steam sau khi có số liệu từ demo.
- Nền tảng PC Windows, chuột và bàn phím. Song ngữ Việt/Anh ngay từ đầu.

## Trải nghiệm cốt lõi
Mỗi đêm có một bộ "Nội quy ban đêm", và **một vài dòng đã bị sửa**. Người chơi làm việc thường ngày, so sánh các bản nội quy, dùng sổ trực và hồ sơ để tìm dòng giả, rồi quyết định làm theo luật nào. Làm sai thì ký túc xá biến đổi: kinh dị chủ yếu đến từ hậu quả; jumpscare hiếm và 2 cảnh truy đuổi theo kịch bản chỉ xảy ra khi người chơi tin nhầm dòng giả (D-024). Chi tiết xem `design/GDD.md`.

## Các giai đoạn
Mỗi mốc đều phải có bản `.exe` chạy được.

| Giai đoạn | Thời gian | Sản phẩm | Tiêu chí xong |
|---|---|---|---|
| P0 Chuẩn bị | 2–4 ngày | Repo, khung Godot, công cụ test và export, tài liệu | Agent clone repo, chạy test và export được |
| P1 Prototype greybox | Tuần 1–2 | Điều khiển, tương tác, sổ tay, 1 luật chạy trọn vòng, song ngữ | **Cổng kiểm tra:** chủ dự án thấy cơ chế thú vị |
| P2 Định hướng hình ảnh và âm thanh | Tuần 2–3 | 1 góc hành lang hoàn chỉnh; chốt nội quy và cốt truyện demo | Chủ dự án duyệt; ≥60 FPS |
| P3 Sản xuất | Tuần 3–5 | Đủ khu vực, 5 đoạn chơi, điểm danh có giọng đọc, kết thúc, checkpoint, menu | Chơi trọn 12–20 phút không kẹt |
| P4 Hoàn thiện | Tuần 6–7 | Sửa lỗi, bản tiếng Anh, tối ưu, 3–5 người chơi thử | Không còn lỗi chặn; ≥70% người thử chơi hết |
| P5 Phát hành | Tuần 7–8 | Trang itch.io | Đăng công khai |

**Nếu bị chậm:** chủ dự án quyết định **không cắt nội dung**; lùi lịch phát hành thay vì cắt (D-020). Danh sách cắt cũ (bỏ nhà vệ sinh, giảm đoạn chơi, bỏ giọng đọc, rút ngắn demo) không còn áp dụng.

## Phạm vi demo
- **Khu vực:** 1 tầng gồm phòng 4 người, hành lang, nhà vệ sinh chung, bàn trực, cầu thang bị chặn.
- **Nhân vật:** 3 bạn cùng phòng nằm tĩnh sau mùng. Bảo vệ chỉ có giọng trên loa. Thực thể chỉ lộ qua bóng và âm thanh.
- **Để sau:** AI quái vật đi tuần tự do, ẩn nấp (demo chỉ có 2 cảnh truy đuổi theo kịch bản, D-024), nhiều tầng hoặc nhiều đêm, NPC có hoạt họa, lồng tiếng Anh, tay cầm, thành tựu Steam.

## Lane và phân công
Xem `AGENTS.md` §3.
- **Tuần đầu:** mỗi agent làm một task thử (T-101…T-105). Chấm theo `tasks/README.md`, sau đó mới gán lane chính thức và cân nhắc giảm số tài khoản.

## Rủi ro chính
| Rủi ro | Cách giảm |
|---|---|
| Cơ chế đọc nội quy thành nhàm vì quá nhiều chữ | Cổng kiểm tra P1; luật ngắn, thiên về hành động |
| Tài nguyên từ nhiều nguồn trông lệch nhau | Phong cách PS1 với texture thấp và filter chung |
| Tạo cảm giác sợ không dùng jumpscare rất khó | Dành nhiều thời gian cho âm thanh |
| Hạn mức Claude Pro | Claude chỉ làm việc lõi và review |
| Pháp lý | Ghi giấy phép mọi asset; khai báo AI trên Steam; không dùng tên trường thật; không mô phỏng Dorm 17 |
