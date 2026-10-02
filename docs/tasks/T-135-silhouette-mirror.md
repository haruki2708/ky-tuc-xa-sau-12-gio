# T-135 — Bóng người và gương phản chiếu chậm
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Có ảnh ở mục 6, FPS ghi trong Handoff
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [x] Mục Handoff đã điền: API, cách gắn; ghi rõ phần nào chưa thử bằng tay

## Handoff (agent điền)

### Đã làm
- Lane B, 2026-10-03. Triển khai đã commit/push `e7a67f2` lên `origin/lane-b/T-135-silhouette-mirror` trước khi ghi bàn giao này. Hoàn tất phần Lane B, chờ review/tích hợp T-134/T-136.
- `game/scenes/levels/entity/silhouette.tscn`: mô hình Blender mới, **408 tam giác**, cao khoảng 1,85 m, gốc ở chân, mặt trước -Z; vai gù nhẹ, tay dài, đầu nghiêng, không mặt. Shader gần đen, viền tối, rung đỉnh PS1, dither 4 × 4 và lắc lư chậm ở node con. Không tự điều khiển truy đuổi hoặc thêm collision.
- `reflection_body.tscn`: **612 tam giác**, áo thun/quần đùi/dép, đầu có pivot riêng. Vật liệu PS1 và layer render được gán tại bước import theo pipeline kit; không thêm plugin.
- Thay hộp `Washroom/Mirror` bằng gương có SubViewport **560 × 190**, camera đối xứng qua mặt kính và frustum lệch tâm. Phản chiếu phòng thật, hiển thị thân người chơi trên layer riêng, không đưa HUD vào viewport. Camera vẫn theo mắt hiện tại để giữ đúng parallax; chỉ thân/hướng đầu dùng lịch sử trễ. Chỉ render khi Player ở trong bounds nhà vệ sinh và trước mặt kính.
- Có script Blender, scene thử riêng, script chụp/đo FPS, 6 test mới; cập nhật generator tầng để không sinh lại hộp gương cũ và `art_source/CREDITS.md`. Tất cả source/asset mới nằm trong phạm vi; không sửa main, Player, core, audio hoặc export preset.

### API và cách gắn
- Gán `Pursuer.body_scene = preload("res://scenes/levels/entity/silhouette.tscn")`. `set_visible_amount(value: float)` clamp 0…1, 0 ẩn hẳn; gọi được trước `_ready()`, material riêng từng instance.
- Sau khi main sẵn sàng: `$Floor4/Washroom/Mirror.follow = $Player`. `follow` là gốc ở chân, có `Head/Camera3D` (hoặc Camera3D con). Chưa gán thì gương tắt; không tự tìm Player trong main.
- `set_lag(0.5)`: trễ vị trí, hướng thân và hướng camera 0,5 s; 0 theo ngay. API clamp 0…10 s, không đủ lịch sử thì giữ mẫu đầu. Ra khỏi phòng xóa lịch sử.
- `stare()`: giữ thân ở tư thế đang hiển thị, quay đầu về mắt phản chiếu để nhìn thẳng ra kính vào Player. Đầu tiếp tục theo vị trí mắt khi Player di chuyển.
- `release()`: bỏ stare, đưa lag về 0, xóa lịch sử; frame sau theo tư thế hiện tại. Gọi khi khôi phục checkpoint/kết thúc hiệu ứng; đặt lại lag nếu cần chu kỳ mới.
- `step_out() -> Vector3`: điểm world-space ngay trước bồn, hiện tại **(1.27, 0.03, -1.85)**; có sàn và capsule r=0,3 m cao 1,85 m không chạm tường/bồn. Truyền điểm này cho `Pursuer.start_chase()`.
- Render layer **19** dành cho kính (camera gương loại ra), **20** dành cho thân phản chiếu. Gương loại layer 20 khỏi camera của follow và khôi phục bit cũ khi unbind/thoát tree. Camera bổ sung cũng cần loại layer 20. Thiết kế hiện tại dành cho một gương/một Player.
- Không tự kích hoạt luật, sting hoặc đọc `reduce_scares`: integrator quyết định lúc gọi `stare()`/fade và áp dụng tùy chọn giảm hù dọa theo D-024.

### Kiểm tra và bằng chứng
Lần chạy đầy đủ cuối trên Godot 4.7.2, mã thoát 0:

```text
pwsh tools/test.ps1
RESULT: 179 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
ENTITY_CAPTURE_RESULT: PASS 3 views
```

Test mới xác nhận độ trễ vị trí/hướng bằng timeline kiểm soát và `_process` thực; freeze/stare/release; layer/mask và frustum khi mắt lệch tâm; tắt render ngoài phòng; điểm step_out có sàn/không va chạm; số tam giác/kích thước bóng, fade riêng từng instance và sway. Smoke trong lần chạy đầy đủ cuối load được mọi scene, không còn lỗi material.

Ghi chú QA: một lần chạy riêng `pwsh tools/test.ps1 -Filter smoke` sau sửa material có `1 passed, 0 failed` nhưng launcher trả FAIL vì lúc thoát còn 42 ObjectDB instances/3 resources. Chưa xác định nguồn giữ tài nguyên của lần chạy riêng đó; không ghi nhận lỗi này trong lần chạy đầy đủ cuối hoặc capture thoát qua `App.quit()`. Đề nghị Lane C kiểm tra cleanup của runner khi lọc smoke, không bỏ qua kiểm tra lỗi engine.

Ảnh đã xem: [bóng cuối hành lang tối](../../art_source/entity/previews/silhouette_corridor.png), [gương bình thường](../../art_source/entity/previews/mirror_normal.png), [gương stare](../../art_source/entity/previews/mirror_stare.png).

| Góc đo | FPS trung bình | Frame p95 (ms) | Gương render |
|---|---:|---:|---|
| Gương bình thường | 559,12 | 2,305 | Có |
| Gương stare | 543,88 | 2,443 | Có |
| Bóng hành lang | 543,51 | 2,483 | Không |

Máy Ryzen 5 5600H / RTX 3050 Laptop, Forward+ Vulkan, 1280 × 720, PS1 strength=1, VSync/max FPS tắt; toàn bộ tầng, Player physics, HUD và âm thanh hoạt động. Mỗi góc warm-up 90 frame rồi đo 240 frame bằng đồng hồ thực, không fixed-fps. Hai góc có gương vượt 60 FPS. Đây là mẫu đứng yên, chưa đại diện mọi máy hoặc truy đuổi hoàn chỉnh. Số đo gốc: [performance.json](../../art_source/entity/previews/performance.json).

Cách thử: mở `res://scenes/levels/entity/mirror_test.tscn`, F6; WASD/chuột, phím **1** gương bình thường/release, **2** lag 0,5 s, **3** stare, **4** hành lang có bóng, Esc menu. Lệnh dựng model/chụp và mô tả kỹ thuật: [README](../../art_source/entity/README.md).

### Chưa thử bằng tay / giới hạn
- Đã chạy test tự động và kiểm tra ba ảnh render thực. Chưa có phiên chơi bằng chuột/bàn phím của người dùng, chưa review cảm giác quay đầu/fade trong chuyển động.
- Chưa ghép hoặc chơi thử truy đuổi T-134/T-136, checkpoint và tùy chọn giảm hù dọa trong luồng đoạn 5. Không tự đoán luật/cốt truyện.
- Không có checklist bắt buộc nào chưa đạt trong phạm vi thành phần Lane B.

### Yêu cầu thay đổi ngoài phạm vi
1. **Integrator/Lane A:** gán follow trong main, gán silhouette vào Pursuer.body_scene và nối `set_lag(0.5) → stare() → start_chase(..., step_out())` theo D-024; gọi `release()` khi phục hồi, xử lý `reduce_scares` tại luồng chơi. Không cần đổi Player scene: mask camera được thành phần gương quản lý.
2. **Integrator/Lane C:** thêm `scenes/levels/entity/mirror_test*` và `assets/models/entity/reflection_import.gd` vào loại trừ bản xuất trong `game/export_presets.cfg`; giữ model/scene/script runtime. Chưa chạy export/package vì không thuộc checklist card.
3. **Lane C:** rà soát cảnh báo tài nguyên khi chạy riêng `-Filter smoke` nêu trên; cân nhắc drain cleanup trước khi runner thoát. Không sửa runner ngoài phạm vi.

### Trạng thái chặn
Không bị chặn ở triển khai, test đầy đủ, check hoặc push. Các bước tích hợp/chơi thử và ghi chú QA đã chuyển rõ cho lane phụ trách.

### Review (integrator, 2026-10-03)
- Đạt. Merge `aeee9ab`. Bóng người 408 tam giác rất hợp không khí; gương phản chiếu thật, FPS > 500.
- Đã làm các yêu cầu ngoài phạm vi: `main.gd` gán `Mirror.follow = $Player`; `export_presets.cfg` loại `mirror_test*`, `reflection_import.gd` (và `pursuer_test*` của T-134).
- Ghi chú smoke chạy riêng còn tài nguyên lúc thoát: chuyển lane C khi có task QA tiếp.
