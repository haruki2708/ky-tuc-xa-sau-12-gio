# T-257 — Nén bộ nhớ hình (VRAM) cho texture đồ hoạ mới: đồ Tripo và vỏ phòng 407, nhà B
- Lane: core (integrator làm) | Trạng thái: **xong** (14/11/2026, HARU làm tiếp từ integrator) | Nhánh: `integrator/T-257-vram-compress`
- Giao việc: chủ dự án chọn 13/11/2026 trong lúc lane B làm T-256 ("Nén bộ nhớ hình phòng 407").

## Vì sao
- Đo sau T-255 ([báo cáo](../../tools/reports/T-255-rooms-fps.md)): chương 3 dùng **3.665 MB trên 4.096 MB** bộ nhớ hình (RTX 3050 Laptop). Lane B từng gặp màn hình đen ở 3.950 MB.
- Nguyên nhân chính: texture của đồ Tripo phòng 407 và vật liệu CC0 được Godot nhập ở chế độ **không nén** (`compress/mode=0`), vì nhập ở chế độ không cửa sổ thì Godot không tự chuyển sang nén VRAM như khi mở trong editor. Một texture 2048² không nén chiếm khoảng 21 MB, nén (S3TC) còn 2,7–5,3 MB.
- Kiểm kê 13/11 (`game/assets/models/graphics_pilot/`, `game/assets/textures/graphics_pilot/`): 393 texture không nén, cộng lại khoảng **3,3 GB** nếu nạp hết. Texture phòng mới T-255 và mask hành lang đã nén sẵn (lane B).

## Việc
1. Đổi `.import` của **333 texture màu, normal, độ nhám/kim loại từ 1024 px trở lên** trong `room407_batch1/2/3`, `room407_corner`, `room407_furnished`, `room407_shell`, `realistic_map` sang nén VRAM (`compress/mode=2`); texture normal thêm `compress/normal_map=1` (nén kiểu hai kênh, giữ chi tiết). Không đổi file ảnh, không đổi mô hình, không đổi vật liệu.
2. **Không nén ở lượt này:** texture dưới 1024 px (lợi ít); texture có chữ hoặc hình đọc gần (lịch, thời khoá biểu, poster, mặt đồng hồ, sổ trực, bảng thông báo, nhãn bình cứu hoả); bầu trời đêm; mask của shader vỏ nhà B; texture nhân vật (quản lý, Trần Trung: mặt nhìn gần, xét riêng nếu cần thêm bộ nhớ); texture PS1 cũ (`textures/kit`, `props`, `room407`, `ch1_models`: test yêu cầu không nén).
3. Ảnh trước/sau cùng camera trong chương 1 và 3 thật (1080p, đèn pin), ghép cho chủ dự án so: `art_source/graphics_upgrade/vram_compress/previews/`.
4. Đo bộ nhớ hình trước/sau ở chương 1 và 3; báo cáo `tools/reports/T-257-vram-compress.md`.
5. Full test, check; build bản chơi.

## Kiểm
- Ảnh sau không thấy khác bằng mắt ở khoảng cách chơi; chỗ nào thấy rõ vệt nén thì trả texture đó về không nén (hoặc nén chất lượng cao) và ghi lại.
- Test cũ đạt (`test_kit`, `test_props`, `test_room407`, `test_ch1_models` vẫn yêu cầu texture PS1 không nén: không đụng).

## Handoff
- **14/11/2026 00:20, lane HARU** (thay integrator hết hạn mức, theo các bước integrator soạn; [báo cáo](../../tools/reports/T-257-vram-compress.md)).
- Đổi 333 `.import` (109 normal map nén hai kênh); nhập lại có khoá: 18 giây, không lỗi.
- **Bộ nhớ hình: chương 1 đỉnh 3.505 → 1.143 MB, chương 3 đỉnh 3.664 → 1.249 MB** (cùng camera, cùng đèn pin).
- Ảnh trước/sau: PSNR 35–45 dB; chỗ khác rõ chỉ là quạt trần, quạt đứng đang quay. Cận cảnh 1:1 (chăn, màn, sàn, tường, tủ, nhà tắm, hai bàn): không thấy vệt nén, normal không lạ. **Không texture nào phải trả về không nén.** Ảnh ghép `art_source/graphics_upgrade/vram_compress/previews/compare_ch1.jpg`, `compare_ch3.jpg`, `compare_closeup.jpg`.
- Trong 333 có 2 texture thanh sắt chương 3 (`protagonist/iron_bar_*`, normal và orm của đồ cầm tay; không phải thân, mặt Trần Trung); không có trong ảnh vì thân người chơi bị ẩn khi chụp.
- Full test 975/0, check 0. Không chạy bot, không đo FPS.
- Còn để nguyên (nếu sau cần thêm bộ nhớ): texture dưới 1024 px, texture có chữ, bầu trời, mask shader nhà B, texture nhân vật, texture PS1 cũ.
- Chờ chủ dự án xem ảnh so sánh và chơi thử bản build sau merge.
