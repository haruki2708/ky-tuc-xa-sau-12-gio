# T-216 — Ảnh đối chiếu nhà tắm

Ảnh gốc Forward+, RTX 3050 Laptop, Godot 4.7.2, 1280×720; cùng camera trước/sau, không chỉnh ảnh. `before/` là phòng tại `45fa1c4`, `after/` là bản sửa T-216. Mỗi thư mục có 30 ảnh; `capture_report.json` ghi camera, FOV, kích thước và SHA-256. Đèn pin (`torch`) và đèn trần (`tube`) giữ nguyên cấu hình D-104. Hai góc sát nẹp chỉ chụp đèn pin. Không đo FPS, không chạy bot.

## Xem nhanh

- Giẻ trên giá khăn: [trước](before/t216_rag_rack_torch.png) / [sau](after/t216_rag_rack_torch.png).
- Bảng từ chỗ đứng tắm: [trước](before/t216_panel_side_torch.png) / [sau](after/t216_panel_side_torch.png).
- Bảng từ cửa: [trước](before/t216_panel_door_torch.png) / [sau](after/t216_panel_door_torch.png).
- Nẹp góc đông-bắc: [trước](before/t216_cap_ne_close_torch.png) / [sau](after/t216_cap_ne_close_torch.png); camera lệch 2 cm: [trước](before/t216_cap_ne_shift_torch.png) / [sau](after/t216_cap_ne_shift_torch.png).

Cảnh chụp G3 có nền bảng và nút; LCD/nội dung câu đố chỉ được director chương 2 gắn khi chơi. Test T-216 gắn vùng lau và vùng nút thật để kiểm tia tương tác 2 m, va chạm tường và hoàn tất lau từ hai chỗ đứng. Đây là ảnh cảnh và kiểm tự động; chưa thay cho chơi tay chương 2.

## Danh mục đầy đủ

Các tên dưới đây có cả hậu tố `_torch.png` và `_tube.png` trong **cả** `before/` và `after/`:

| Tên | Nội dung |
|---|---|
| `t216_panel_side` | Bảng trên tường bên, nhìn từ chỗ tắm |
| `t216_panel_door` | Bảng nhìn từ cửa nhà tắm |
| `t216_rag_rack` | Giá khăn và giẻ mới |
| `t216_shower_stall` | Vòi sen và bảng cũ nhìn từ chỗ tắm |
| `t216_shower_entry` | Vòi sen nhìn từ cửa |
| `t216_rag` | Phía bồn/kệ cũ |
| `t216_corner_nw_top` | Góc tây-bắc trên |
| `t216_corner_ne_top` | Góc đông-bắc trên |
| `t216_corner_sw_top` | Góc tây-nam trên, phía cửa |
| `t216_corner_se_top` | Góc đông-nam trên |
| `t216_corner_nw_low` | Góc tây-bắc dưới |
| `t216_corner_ne_low` | Góc đông-bắc dưới |
| `t216_corner_sw_low` | Góc tây-nam dưới |
| `t216_corner_se_low` | Góc đông-nam dưới |

Thêm `t216_cap_ne_close_torch.png`, `t216_cap_ne_shift_torch.png` cho mỗi bản.

## Nguyên nhân và phạm vi

`geometry_report.json` đo trực tiếp GLB gốc trong LFS và GLB xuất lại: ba giao thể tích giữa `CapWest/CapBack`, `CapEast/CapBack`, `CapEast/CapFront` giảm từ 3 xuống 0. Các nẹp cũ cùng có mặt trên y ≈ 1,812 m; phần giao hình hộp là 14×14 mm, gồm cả vùng vát mép giao nhau và các mảnh đồng phẳng. Góc đông-bắc được chụp sát và lệch camera để đối chiếu; tây-bắc/đông-nam có cùng cấu trúc lỗi. Tây-nam là cửa, không có `CapFront` nối vào `CapWest`. Không đủ thông tin để khẳng định góc đông-bắc chính là góc chủ dự án đã gặp khi chơi.

Sửa trong `build_lived_in.py::bath_tiles`: nẹp sau/trước dừng trước nẹp bên 1 mm, không còn phủ xuyên nhau; sửa tâm `TilesFront` để đầu phía đông dừng đúng mép gạch bên thay vì lấn 4 mm. Không dịch tường, không thay decal, collision, ánh sáng hay shader để che lỗi.

Giẻ dùng một GLB vải gấp cho cả `RagSpot/Model` và `Details/CleaningRag`; giá khăn hạ 15 cm để thấy mặt giẻ từ tầm mắt 1,6 m. Model 3.200 tam giác, 1 vật liệu, map CC0 1024²; nguồn ở `../../build_cleaning_rag.py`, `../../cleaning_rag.blend`, credits ở `../../CREDITS.md`. Gạch xuất lại 1.032 tam giác, 3 vật liệu, 7.372.100 byte.

## Chụp lại

Mở `res://scenes/levels/room407/room407_g3_capture.tscn` với `-- --g3-capture` (Forward+). Các góc T-216 được thêm vào `VIEWS`, xuất mặc định về `previews/g3/`. Giữ cửa sổ render không thu nhỏ khi chụp; `frame_post_draw` dừng nếu cửa sổ bị thu nhỏ. Phiên này dùng runner tạm chọn các `id` bắt đầu `t216_` và cố định cửa sổ 1280×720; cảnh gốc còn tự thêm 16 ảnh giấy, nên log ghi 46 ảnh, báo cáo ở đây giữ 30 ảnh thuộc T-216. Toàn bộ ảnh G3 cũ đã được khôi phục nguyên bản sau khi lưu bằng chứng riêng ở đây.
