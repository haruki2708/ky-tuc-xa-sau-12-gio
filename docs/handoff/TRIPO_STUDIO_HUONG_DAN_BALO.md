# Hướng dẫn chủ dự án: tạo mẫu balo trên Tripo Studio (G2)

> Viết 12/10/2026 bởi integrator (Claude, Opus 5.5) theo D-084, D-085. Người bấm tạo: **chủ dự án**. Đọc hết một lượt trước khi mua.
> Giao diện Tripo có thể đổi theo thời gian: tên nút dưới đây là mô tả, **cái gì thấy trên màn hình thì ghi đúng như thế** vào phiếu ở mục 5.

## 1. Trước khi mua
- Chỉ mua khi STATUS ghi **G1 balo đã nghiệm thu (D-085)**.
- Mua gói **Pro** của **Tripo Studio** (web), **không** mua gói API. Ghi lại: ngày mua, thanh toán tháng hay năm, tổng tiền thực trả ở bước thanh toán.
- Lúc mua, **lưu lại điều khoản**: mở trang Terms và trang hướng dẫn dùng thương mại của Tripo, in ra PDF (Ctrl+P → Save as PDF). Đặt tên `tripo_terms_<ngày>.pdf`, `tripo_commercial_<ngày>.pdf`. D-084 bắt buộc có bản lưu, không chỉ đường link.
- Trong cài đặt tài khoản/model: nếu có tùy chọn **riêng tư (Private)**, bật lên để model không hiện công khai.

## 2. Tạo balo (tối đa 5 lần, D-084)
1. Chọn chế độ **tạo từ chữ (Text to 3D)**. Ảnh đầu vào chỉ dùng nếu là **ảnh anh/chị tự chụp** (ví dụ một chiếc balo thật ở nhà, không có logo); không dùng ảnh trên mạng.
2. Dán prompt sau (tiếng Anh, đã rút gọn từ brief của lane B):

   ```text
   A worn, inexpensive student backpack resting upright on the floor. Faded olive-gray fabric, two black shoulder straps on the back, a small carry loop on top, one flat front pocket. Subtle seams and wear. Closed bottom, straps attached. No logos, no text, no items sticking out. Realistic, game-ready, PBR textures.
   ```
   Nếu có ô "negative prompt": `logo, text, brand, floating parts, open bag, items, baked shadows`.
3. Tùy chọn (nếu UI có):
   - Số mặt/đa giác: chọn mức **thấp** hoặc đặt giới hạn khoảng **3000 tam giác** nếu có ô nhập (trần D-079 là dưới 3001).
   - Texture: **có**, kiểu **PBR**, độ phân giải **1024** nếu chọn được (trần là 1024 × 1024).
   - Không cần rig, animation, phân phần.
4. Bấm tạo. **Mỗi lần bấm tạo (kể cả tạo lại, sửa texture, remesh) là 1 lượt** trong 5 lượt. Ghi lại credit trước và sau mỗi lượt.
5. Xem kết quả: xoay quanh, kiểm **mặt sau có quai, đáy kín, có túi trước, không chữ/logo, không mảnh bay**. Không cần đúng kích thước: lane B sẽ chỉnh kích thước và hướng trong Blender.
6. Hết 5 lượt mà chưa có mẫu ổn: **dừng**, báo integrator xem lại prompt. Không tạo tiếp.

## 3. Tải về
- Chọn mẫu tốt nhất, tải định dạng **GLB** (kèm texture). Nếu có tùy chọn "kích thước/scale" thì để mặc định.
- Lưu vào `D:\GAME_DEMO\build\graphics\staging\room407_backpack\<ngày>_<lượt>\` (thư mục `build` không lên Git). Không đổi tên file gốc.
- Chụp màn hình trang chi tiết của mẫu, có thấy **mã task/model ID** (nếu Tripo hiện), model version, các tùy chọn đã chọn.

## 4. Gửi lại cho integrator
Nhắn: "Đã tạo balo Tripo, file ở `build/graphics/staging/room407_backpack/...`" kèm phiếu ở mục 5. Integrator (hoặc lane B) làm tiếp: xoay đúng hướng mặt trước (−Z), chỉnh kích thước, giảm tam giác/gộp vật liệu nếu cần, nhập Godot ở thư mục mẫu riêng, chạy công cụ kiểm của C và chụp ảnh trước/sau cho anh/chị duyệt. **Balo trong bản chơi chưa bị thay** cho tới khi anh/chị duyệt (G3).

## 5. Phiếu ghi (chép vào tin nhắn)

| Mục | Ghi |
|---|---|
| Gói, ngày mua, chu kỳ, tổng tiền | |
| File điều khoản đã lưu | |
| Chế độ (Text/Image to 3D), model version trên UI | |
| Prompt thực đã dán (nếu sửa so với mục 2) | |
| Ảnh đầu vào (nếu có): ai chụp, ở đâu | |
| Từng lượt: giờ, việc (tạo/tạo lại/texture/remesh), credit trước → sau | |
| Mẫu được chọn: task/model ID (hoặc "Studio không hiện") | |
| Tên file đã tải, thư mục lưu | |
| Riêng tư đã bật chưa | |
