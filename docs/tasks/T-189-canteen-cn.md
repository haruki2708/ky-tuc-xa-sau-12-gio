# T-189 — Nhà ăn kiểu nhà ăn trường học Trung Quốc
- Lane: B (**Claude làm thay**, chủ dự án yêu cầu 2026-10-06; lane B hết token) | Trạng thái: review | Agent: Claude
- Phụ thuộc: T-183, T-187.

## Lý do
Chủ dự án tham quan map: nhà ăn "bên ngoài khá sơ sài, không khác gì khối hình hộp; bên trong bàn ghế set up hỏng hết và sơ sài; cần đầy đủ không gian bên trong như nhà ăn trường học ở Trung Quốc".

## Đã làm
- Bộ dựng mới `art_source/campus/canteen_cn.py` (dùng lại `build_campus.py` và `detail.py` của lane B): chỉ ghi `game/scenes/levels/campus/canteen.tscn` và thay các ô đường đi `Dining_*` trong `campus.tscn` theo cách kê bàn mới. Không chạy lại cả bộ dựng map.
- **Bên ngoài:** cột ốp, dải cửa kính có khung và bậu, tường mái, biển đỏ "NHÀ ĂN SINH VIÊN" (chữ Be Vietnam Pro), mái che lối vào có cột, bậc thềm, cục nóng điều hòa, 6 xe đạp, bình gas, thùng rác, ống khói bếp.
- **Sảnh ăn:** 21 bàn dài mặt trắng chân sắt, mỗi bàn 6 ghế tròn đỏ/xanh gắn khung; khay inox, bát, đũa trên bàn; 3 bàn đổ, 3 bàn lệch; khay và đồ ăn vương dưới sàn. Quầy chia cơm inox có kính chắn, 12 khay thức ăn, muôi, thùng cơm, 5 ô cửa thông bếp, bảng giá, chồng khay, máy quẹt thẻ, rào xếp hàng. Gạch men trắng ngang lưng, khẩu hiệu "TIẾT KIỆM LƯƠNG THỰC, KHÔNG BỎ PHÍ CƠM", áp phích, 4 bồn rửa tay có gương, quầy "TRẢ KHAY" với khay bẩn và thùng thức ăn thừa, đèn tuýp, quạt trần.
- **Bếp:** 4 chảo trên bếp gas, chụp hút khói và ống, chồng xửng hấp, nồi cơm, bàn sơ chế (thớt, dao, rau), bồn rửa, muôi treo tường, bao gạo; sàn gạch ướt. **Kho:** kệ, thùng giấy, can dầu, bao gạo.
- **Giữ nguyên hợp đồng T-183:** khuôn nhà (x 170–210, z 20–44, bếp và kho phía sau), cửa ra vào và các lối nối đường đi, `TV/Screen` (core bật tivi), đồng hồ bếp, mọi anchor (điểm xác xuất hiện x 178–186 z 24–30 không bị bàn đè; đường đồng đội qua x = 190 rồi về cửa kho x = 202).
- **Đường đi:** bỏ 675 ô cũ, thêm 566 ô mới tránh bàn, quầy, bồn rửa, quầy trả khay.
- Sửa thêm: Godot editor đã lưu nhầm `campus.tscn` với sân vận động bị ẩn (`visible = false`) lúc chủ dự án tham quan; đã trả về bản đúng (chưa từng vào commit).

## Kiểm tra
- Ảnh trong, ngoài, bếp, quầy (chụp bằng Godot). Kết quả test: xem mục dưới.
- Test: cả bộ 580/580, check 0 lỗi (gồm test đường đi 407 → nhà ăn của lane B, luồng chương 3 qua nhà ăn).
