# Nguồn texture — `realistic_map/wave7/` (T-264)

Mọi file ở đây do `art_source/graphics_upgrade/realistic_map/wave7/make_wave7_textures.py` vẽ bằng code (numpy + Pillow,
bộ vẽ lá của đợt 3): không tải ảnh, không ảnh AI. Tác giả: dự án (Claude, lane B). Giấy phép: như dự án.

- `leaf_bang.png`, `bark_bang_*`: bàng (Terminalia catappa), lá to hình trứng ngược mọc thành hoa thị ở đầu cành, vài lá đỏ.
- `leaf_phuong.png`, `bark_phuong_*`: phượng vĩ (Delonix regia), lá kép lông chim hai lần, một ô hoa đỏ.
- `leaf_xacu.png`, `bark_xacu_*`: xà cừ (Khaya senegalensis), cành lá kép nhỏ, sẫm.
  Hình dáng vẽ theo mô tả thực vật của từng loài (không đồ lại ảnh nào). Tham chiếu để đối chiếu bằng mắt:
  https://en.wikipedia.org/wiki/Terminalia_catappa, https://en.wikipedia.org/wiki/Delonix_regia,
  https://en.wikipedia.org/wiki/Khaya_senegalensis (ảnh trong các bài, giấy phép ghi ở từng ảnh; không dùng trong game).
- `interior_atlas.png`: phòng giả sau ô cửa (phòng ký túc, lớp học, nhà thể chất, sảnh).
- `mask_facades7.png`: mặt nạ cũ bẩn (UV2) của mặt nhà. `mask_road7.png`, `mask_verge7.png`: lượt 3 vẽ lại cho cả khuôn viên
  500 × 350 m (vá, nứt, bẩn, vũng nước, vệt bánh xe; đất trơ dọc vỉa, gốc cây, lối đi).
- `tree_far_bang.png`, `tree_far_phuong.png`, `tree_far_xacu.png`: thẻ cây xa (lượt 3), ghép từ chính atlas lá và màu vỏ ở
  đây theo dáng tán từng loài.
- `paint_line.png`: vạch sơn đường mòn; `palette7.png`: ô màu phẳng cho đồ nhỏ (`palette7.json` ở thư mục art_source).
