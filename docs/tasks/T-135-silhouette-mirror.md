# T-135 — Bóng người và gương phản chiếu chậm
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-135-silhouette-mirror`
- Phụ thuộc: T-112, T-118 (done). **Đọc `docs/design/RULES.md` mục 5b** (D-024). Làm song song với T-134 (lane A, thực thể truy đuổi).

## Mục tiêu
1. **Bóng người:** hình dạng thực thể. Theo `PLAN.md`, thực thể **chỉ lộ qua bóng và âm thanh**: không mặt, không chi tiết, chỉ là một khối người tối, cao gầy.
2. **Gương nhà vệ sinh:** phản chiếu thật được hình dáng người chơi, có chế độ **chậm nửa nhịp**, và có thể ra lệnh cho hình phản chiếu **quay đầu nhìn thẳng** vào người chơi (cú hù đoạn 5).

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Bóng người `game/scenes/levels/entity/silhouette.tscn`:**
   - Mô hình low-poly dựng bằng script Blender như bộ kit (dưới 800 tam giác): người cao khoảng 1,85 m, vai hơi gù, tay dài, đầu hơi nghiêng. Không mặt, không quần áo chi tiết.
   - Vật liệu: gần như đen, không phản sáng, viền mờ nhẹ (rim tối) để nhìn ra dáng trong hành lang tối. Hợp shader PS1 (rung đỉnh).
   - Gốc ở chân. Có hàm `set_visible_amount(value: float)` (0 → 1) để hiện ra hoặc mờ đi dần (dither hoặc alpha scissor, hợp PS1).
   - Nhẹ nhàng "lắc lư" chậm khi đứng yên (không cần hoạt họa đi bộ: thực thể trượt đi, càng đáng sợ).
2. **Thân người chơi trong gương** `game/scenes/levels/entity/reflection_body.tscn`: hình người đơn giản (áo thun, quần đùi, dép kiểu sinh viên ở ký túc xá), **chỉ hiện trong gương** (layer render riêng mà camera người chơi không thấy).
3. **Gương `washroom.tscn`** (thay hộp tạm ở node `Mirror`):
   - Dùng `SubViewport` + camera đối xứng qua mặt gương (hoặc kỹ thuật khác, ghi lý do), hiển thị phòng và `reflection_body` đứng tại vị trí người chơi. Độ phân giải thấp, hợp PS1. Chữ và HUD không vào gương.
   - Script `mirror.gd` (đặt trong `game/scenes/levels/`) với API:
     - `@export var follow: Node3D` (Player);
     - `set_lag(seconds: float)`: hình phản chiếu đi theo vị trí và hướng của người chơi **chậm** `seconds` giây; 0 là bình thường;
     - `stare()`: hình phản chiếu ngừng làm theo, **quay đầu nhìn thẳng ra khỏi gương** vào camera người chơi;
     - `release()`: trở lại bình thường;
     - `step_out() -> Vector3`: trả về vị trí ngay trước gương để thực thể truy đuổi xuất hiện (cảnh "bóng trong gương bước ra").
   - Chỉ render khi người chơi ở trong nhà vệ sinh (tiết kiệm).
4. **Hiệu năng:** vẫn ≥ 60 FPS trong nhà vệ sinh khi gương bật. Ghi số FPS.
5. **Test `game/tests/levels/`:** scene load được; `set_lag(0.5)` làm hình phản chiếu trễ đúng khoảng thời gian (so vị trí sau khi Player di chuyển); `stare()` làm hình phản chiếu quay về phía camera; `release()` trở lại; `step_out()` trả về điểm trên sàn nhà vệ sinh, không trong tường; bóng người dưới 800 tam giác, `set_visible_amount` đổi được.
6. **Ảnh:** bóng người đứng cuối hành lang tối; gương bình thường; gương lúc `stare()`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Có ảnh ở mục 6, FPS ghi trong Handoff
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [ ] Mục Handoff đã điền: API, cách gắn; ghi rõ phần nào chưa thử bằng tay

## Handoff (agent điền)
