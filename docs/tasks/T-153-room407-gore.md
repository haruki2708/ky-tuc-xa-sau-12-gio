# T-153 — Phòng 407 chi tiết, máu me, giường bị chém
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-153-room407-gore`
- Phụ thuộc: T-112, T-121, T-138. Đọc `docs/design/STORY.md` v2 §0 (nội dung nhạy cảm), §5, và bảng số giường trong `docs/tasks/T-150-chapter1-core.md`.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-154 ngay.

## Mục tiêu
Người chơi ở **trong phòng 407 gần như suốt 50 phút** của chương 1, nên căn phòng phải đẹp, chi tiết và kể được chuyện của ba bạn cùng phòng qua đồ đạc. Chủ dự án muốn đồ họa cải thiện nhiều; ảnh tham khảo sẽ gửi sau. Trong lúc chờ, giữ phong cách PS1 nhưng nâng chất lượng: texture đẹp hơn trong giới hạn 64–256 px, nhiều đồ hơn, ánh sáng có không khí.

Tầng 5, 6 và nhà A đối diện để sang chương 3.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Đồ của từng người** (đặt trong `room_407.tscn`; có anchor để lane A gắn đồ đọc được):
   - **Phúc** (giường 1): sách giáo trình, tai nghe, poster bóng đá, mì gói.
   - **Việt** (giường 2): laptop cũ, đàn guitar, khung ảnh gia đình.
   - **Trung** (giường 3): balo, bàn học có đèn bàn, ổ cắm và dây sạc **không có cục sạc**.
   - **Đạt** (giường 4): **tủ sắt khóa số** (anchor `DatLocker`, có `set_unlocked(bool)`), thẻ sinh viên hoặc sổ tay trên bàn (anchor `DatNote`, cho manh mối mã khóa), giày thể thao.
   - **Chung:** quần áo phơi trong phòng, xô chậu, dép (4 đôi khác màu: Phúc đỏ, Việt xanh dương, Trung xanh lá, Đạt đen), **cục phát wifi nhỏ** trên tường (anchor `Router`), quạt trần (đã có).
2. **Giường và xác:**
   - 4 giường dùng được với `bunk_spot` của lane A: anchor `Anchors/Bunks/Bunk1..4`, mỗi anchor có node con `View` (camera khi nằm) và `Exit`.
   - Giường 1, 2, 4 có **chỗ đặt xác** (anchor `Corpse1`, `Corpse2`, `Corpse4`; mô hình xác làm ở T-154).
   - **Trạng thái máu** có API `set_blood_stage(stage)`:
     - 0: sạch (đầu mở đầu);
     - 1: máu thấm chăn, nhỏ giọt xuống sàn (sau khi bạn chết);
     - 2: vũng máu.
     - Dùng decal hoặc mesh phẳng, texture thấp.
   - **Giường của Trung bị chém** (`set_slashed(amount 0..1)`): nệm và chăn rách dần theo từng nhát (T-152 phát `slashed` mỗi nhát), cuối cùng nát hẳn, có mảnh vụn.
3. **Cửa phòng và ngưỡng cửa:**
   - cửa 407 giữ API cũ;
   - thêm Area3D `Threshold` ngay ngoài cửa phía hành lang để integrator làm luật "rời phòng là chết";
   - khe sáng dưới cửa (thấy bóng người đi qua bên ngoài: node `UnderDoorShadow` với `set_visible`).
4. **Ánh sáng 4 giờ sáng:** đèn chính tắt; đèn bàn, ánh xanh từ cửa sổ, ánh sáng hành lang qua khe cửa. Có API `set_flicker(bool)` cho đèn chính và đèn bàn.
5. **Tường chung với 406 và 408:** người chơi gõ tường được (anchor `WallKnock406`, `WallKnock408`, cho lane A/integrator gắn tương tác).
6. **Nhà vệ sinh chung tầng 4** (đã có): thêm vài chi tiết cho đoạn mở đầu (người chơi đi vệ sinh lúc 4 giờ).
7. **Hiệu năng:** ≥ 60 FPS khi đứng trong phòng; đo như T-112.
8. **Test và preview:**
   - test: đủ anchor; các API máu, chém, nhấp nháy chạy đúng; mọi sàn có `surface`;
   - ảnh preview: phòng sạch, phòng sau khi bạn chết, giường bị chém.
9. **Nội dung máu me:** hiển thị theo kiểu PS1 (texture thấp, màu đỏ sẫm), không làm chi tiết giải phẫu. "Giảm hù dọa" không cần xử lý ở lane B; integrator có thể gọi `set_blood_stage(0)`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh preview, số đo FPS
- [ ] `CREDITS.md` đủ nguồn
- [ ] Handoff: tên anchor và API

## Handoff (agent điền)
