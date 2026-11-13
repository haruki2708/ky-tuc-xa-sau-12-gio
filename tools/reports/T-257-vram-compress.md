# T-257 — Nén bộ nhớ hình (VRAM) cho texture đồ hoạ mới

Làm ngày 13/11/2026, 23:20–23:30, lane HARU (thay integrator hết hạn mức), theo các bước integrator soạn trong [`handoff/haru.md`](../../docs/handoff/haru.md) mục 3. Card: [T-257](../../docs/tasks/T-257-vram-compress-room407-textures.md). Lý do: sau T-255 chương 3 dùng 3.665 MB trên 4.096 MB bộ nhớ hình ([báo cáo FPS T-255](T-255-rooms-fps.md)).

## Kết quả
| | Trước: đỉnh bộ nhớ hình | Sau: đỉnh bộ nhớ hình | Trước: texture | Sau: texture |
|---|---|---|---|---|
| Chương 1 (12 góc) | 3.505 MB | **1.143 MB** (−2.362) | 3.359 MB | 998 MB |
| Chương 3 (8 góc) | 3.664 MB | **1.249 MB** (−2.415) | 3.502 MB | 1.087 MB |

Ảnh không thấy khác ở khoảng cách chơi, kể cả cận cảnh 1:1. **Không texture nào phải trả về không nén.**

## Đã đổi
- 333 file `.import` của texture màu, normal, độ nhám/kim loại từ 1024 px trở lên: `compress/mode` 0 → 2 (nén VRAM, S3TC/BPTC trên máy tính). 109 normal map thêm `compress/normal_map` 0 → 1 (nén hai kênh). Không đổi file ảnh, mô hình hay vật liệu.
- Theo thư mục (`game/assets/models|textures/graphics_pilot/`): `room407_batch1` 21, `room407_batch2` 96, `room407_batch3` 90, `room407_corner` 33, `room407_furnished` 36, `room407_shell` 42, `realistic_map` 10, balo `room407_backpack_tripo_r2_*` 3, thanh sắt chương 3 `protagonist/iron_bar_*` 2 (normal và orm của đồ cầm tay, không phải thân hay mặt Trần Trung).
- Danh sách chọn từ bản kiểm kê integrator làm 13/11 (393 texture đang không nén); script đổi `build/integrator/t257_apply.ps1` (không commit).
- Nhập lại có khoá Godot (`--headless --import`): 18 giây, thoát 0, không lỗi. Mỗi `.import` giờ trỏ tới `*.s3tc.ctex`, `vram_texture: true`.

## Không nén ở lượt này
Texture dưới 1024 px; texture có chữ hoặc hình đọc gần (lịch, thời khoá biểu, poster, mặt đồng hồ, sổ trực, bảng thông báo, nhãn bình cứu hoả); bầu trời đêm; mask shader vỏ nhà B; texture nhân vật (quản lý, thân và mặt Trần Trung); texture PS1 cũ (`textures/kit`, `props`, `room407`, `ch1_models`: test yêu cầu không nén). Nếu sau này cần thêm bộ nhớ, đây là nhóm xét tiếp.

## Cách đo và so ảnh
- Cảnh chụp tạm (`game/_probe_tmp/t257_capture.gd`, đã xoá; bản lưu `build/integrator/t257_capture.gd`): nạp `chapter1.tscn`, `chapter3.tscn` thật, director không chạy, người chơi và giao diện ẩn, tắt tiếng, đèn pin khảo sát gắn camera, cửa sổ 1920 × 1080, Forward+. Bộ nhớ đọc bằng `RenderingServer.get_rendering_info` (`VIDEO_MEM_USED`, `TEXTURE_MEM_USED`), lấy giá trị lớn nhất qua các góc.
- "Trước" do integrator chụp lúc 23:07 (cùng script, cùng camera); "sau" HARU chụp lúc 23:28.
- Độ khác từng cặp (`make_compare.py` in ra): PSNR 35–45 dB, độ sáng trung bình gần như không đổi. Ba cặp khác nhiều nhất (`ch3_08` 30,2 dB, `ch1_11` 35,3 dB, `ch1_04` 36,7 dB) chỉ khác ở quạt trần và quạt đứng đang quay (cánh quạt ở góc khác giữa hai lượt chụp), không phải do nén.
- Soi cận cảnh 1:1 giữa khung hình: chăn và màn giường (`01`, `08`), sàn gạch và balo (`07`), tường sát (`12`), tủ sắt (`02`), gạch nhà tắm (`06`), bàn Phúc có hộp giấy (`03`), bàn trực có sổ và con dấu (`10`): không thấy vệt khối, bệt màu, normal sai (bóng sai, tối sai).
- Thanh sắt không có trong ảnh (thân người chơi bị ẩn khi chụp); hai texture của nó chỉ là normal và orm.

## Ảnh cho chủ dự án
`art_source/graphics_upgrade/vram_compress/previews/`:
- `compare_ch1.jpg`, `compare_ch3.jpg`: từng góc, trái trước, phải sau (thu nhỏ);
- `compare_closeup.jpg`: 8 cận cảnh 1:1;
- ảnh gốc `before_*.jpg`, `after_*.jpg`. Ghép lại bằng `python -B art_source/graphics_upgrade/vram_compress/make_compare.py`.

## Kiểm
- Full test sau khi nén: **975 passed, 0 failed** (13/11 23:34 → 14/11 00:03); check: **0 lỗi** (00:20). Các test yêu cầu texture PS1 không nén (`test_kit`, `test_props`, `test_room407`, `test_ch1_models`) vẫn đạt vì không đụng texture đó.
- Không chạy bot, không đo FPS (nén texture không đổi hình học hay ánh sáng; số FPS T-255 vẫn là mốc).
