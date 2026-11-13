# T-258 — Chương 3–4: tường giếng cầu thang chính lấn vào nhà vệ sinh tầng 4, che gương và máng rửa
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B, `D:\GAME_WORK\lane-b2`; model **Opus 5.5 xhigh**. Chủ dự án tự dán prompt (`lane-b.md` mục 1m).
- Nhánh: `lane-b/T-258-main-stairs-wall-over-washroom` từ `origin/main` mới nhất (đã có T-256).
- Nguồn: yêu cầu thay đổi 1 của [T-256](T-256-floor4-washroom-corridor-props.md) (lane B phát hiện); integrator xác nhận trên ảnh `realistic_map/previews/floor4_rest/compare_washroom_ch3.jpg`.

## Lỗi
- Ở chương 3–4 (tầng 4 nằm trong nhà B của khuôn viên), tường đông của giếng cầu thang chính đặt mặt ngoài ở **x 0,16**, còn mặt trong tường tây nhà vệ sinh ở **x 0,1**:
  - `Campus/BuildingB/MainStairs/Wall0.08…` (hộp PS1 một khối từ tầng 1 lên tới y 2,75, x 0…0,16, có va chạm);
  - khối `W1Stairs` của T-250 phía trên 2,74 m (cũng tới x 0,16).
- Hậu quả: trong nhà vệ sinh tầng 4 thấy **một bức tường khảm PS1 đứng trước tường tây 6 cm**, che gương phản chiếu, ống nước, bảng tin của T-256 (máng rửa chỉ còn thấy phần nhô ra). Lỗi có từ trước T-256 (gương cũ cũng bị che). Chương 1–2 không bị (không có khuôn viên).
- Va chạm của hộp đó cũng lấn 6 cm vào phòng.

## Việc
1. Ở độ cao tầng 4 (y 0…3,05), mặt đông của tường giếng thang chính không được vượt quá mặt ngoài tường tây nhà vệ sinh (x ≤ 0,1 trong đoạn z −5…0): lùi phần tầng 4 của tường về x ≤ 0,1, hoặc tách hộp PS1 thành phần tầng 1–3 (giữ nguyên) và phần tầng 4 (lùi hoặc ẩn nếu mặt trong của `W1Stairs` đã đủ kín). Dựng lại phần tương ứng của `W1Stairs` (`art_source/graphics_upgrade/realistic_map/wave1/build_stairs.py`) nếu cần.
2. Nhìn từ trong giếng thang (chiếu nghỉ tầng 4, vế 4A, 4B) tường vẫn kín, không hở, không nhấp nháy; nhìn từ ngoài nhà B không hở.
3. Va chạm: người chơi trong nhà vệ sinh chạm tường ở x 0,1 (tường của chính nhà vệ sinh), không còn hộp lấn. **Đây là đổi va chạm có chủ ý, chỉ ở tầng 4, đoạn tường này.** Va chạm phía cầu thang (mặt tây của tường, lối đi vế thang, chiếu nghỉ, `Landing4Rail`) không đổi.
4. Kiểm cùng lỗi ở **phía cầu thang thoát hiểm với phòng 408** (x 44; T-255 đã đặt tường đông 408 ở x 43,84) và ghi kết quả; có lỗi tương tự thì sửa cùng cách.
5. Ảnh trước/sau chương 3: cùng camera với `after_ch3_washroom_*` của T-256 (máng rửa và gương, gương cận), thêm một ảnh từ chiếu nghỉ tầng 4 cầu thang chính nhìn về tường đó. Để ở `realistic_map/previews/floor4_rest/` (`t258_before_*`, `t258_after_*`, `compare_t258.jpg`).

## Kiểm
- Cập nhật có chủ ý các test đang giữ dấu vân tay va chạm và node của `building_b.tscn` (`test_t250_realistic_wave1`, `test_t253_realistic_wave2`, `test_t254_landing_rail`, `test_t256_floor4_rest` nếu liên quan): **chỉ** phần hộp tường này đổi; ghi rõ dòng nào đổi trong Handoff. Không nới test khác.
- Test mới: ở chế độ khuôn viên, trong nhà vệ sinh tầng 4 không có hình hay va chạm nào của nhà B nằm trong lòng phòng (x 0,1…5,9, z −4,9…−0,1, y 0…3); tia từ giữa phòng về phía tây chạm tường nhà vệ sinh ở x 0,1; capsule vẫn đi được vế 4A, 4B và chiếu nghỉ tầng 4 cầu thang chính như trước.
- `test_fire_stairs`, `test_campus`, `test_floor4*`, `test_t255*` đạt. Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` trước commit cuối.

## Được phép sửa
- `game/scenes/levels/campus/building_b.tscn` (chỉ tường giếng thang chính đoạn tầng 4, và phía thoát hiểm nếu bước 4 thấy lỗi), `art_source/graphics_upgrade/realistic_map/wave1/` và glb sinh ra, ảnh, test trong `game/tests/levels/`, card này.

## Không được
- Đổi nhà vệ sinh (`washroom.tscn`, T-256), hành lang, cầu thang (bậc, chiếu nghỉ, lan can, lối đi), navmesh, director, luật. Tripo, bot, FPS. Sửa STATUS, DECISIONS.

## Checklist
- [ ] Tường giếng thang chính không còn lấn nhà vệ sinh tầng 4 (hình và va chạm)
- [ ] Kiểm phía cầu thang thoát hiểm và phòng 408
- [ ] Ảnh trước/sau chương 3
- [ ] Test mới, cập nhật dấu vân tay có chủ ý, full test, check, Handoff

## Handoff
(lane B điền)
