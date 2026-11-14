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
- [x] Tường giếng thang chính không còn lấn nhà vệ sinh tầng 4 (hình và va chạm)
- [x] Kiểm phía cầu thang thoát hiểm và phòng 408
- [x] Ảnh trước/sau chương 3
- [x] Test mới, cập nhật dấu vân tay có chủ ý, full test, check, Handoff

## Handoff

### 14/11/2026 — lane B (Claude, Opus 5.5)
Nhánh `lane-b/T-258-main-stairs-wall-over-washroom` từ `origin/main` `415763a` (đã có T-256, merge `73fa437`). Commit card đã đọc: `e738e2e`. Lúc mở phiên không có thay đổi dở. Commit: `ed1a29e` (sửa tường, test, ảnh trước), `0a37767` (ảnh sau, ảnh ghép), commit cuối (Handoff, bỏ bộ góc chụp ban công 401 khỏi `capture_t258.gd`).

**Đo lại lỗi (probe ở chương 3: `floor4.tscn` + `campus.tscn`):** trong lòng nhà vệ sinh (x 0,1…5,9, z −4,9…−0,1, y 0…3) có đúng ba thứ của nhà B:
- hình và va chạm của hộp PS1 `MainStairs/Wall0.08…` (x 0…0,16);
- trong `W1Stairs/Walls`: khối `W1OldWall` trên 2,74 m (cũng tới x 0,16) và mặt đầu tường ở z −0,197 (x tới 0,16).

**Đã làm:**
- **`building_b.tscn`:** hộp PS1 tường đông giếng thang chính tách làm ba. Mặt phía cầu thang (mặt tây, x 0) giữ nguyên ở cả ba.
  - `Wall0.08…` (node cũ) chỉ còn tầng 1–3: x 0…0,16, y −10,75…0, z −6,2…−0,2. Tầng 1–3 giữ 0,16 vì T-253 đã đặt lớp trát các phòng cạnh giếng thang ở x 0,163 (`wave2/layout.py` `STAIR_WALL_W`).
  - `EastWall4` (mới): tầng 4 cạnh nhà vệ sinh, x 0…**0,1**, y 0…2,75, z −5,0…−0,2.
  - `EastWall4Back` (mới): tầng 4 phía sau nhà vệ sinh, x 0…0,16, y 0…2,75, z −6,2…−5,0. Giữ dày 0,16 như cũ để mặt ngoài sau nhà B không đổi. Chỗ nối ở z −5,0 nằm trong bề dày tường sau nhà vệ sinh nên không thấy.
  - Mỗi hộp vẫn lớp 1, mask 0, hình bằng đúng hộp va chạm, cùng vật liệu PS1 `s5`.
- **`main_stairs.glb`** (`build_stairs.py`, chỉ giếng thang chính; `fire_stairs.glb` không dựng lại):
  - khối `W1OldWall` trên 2,74 m tách ba: cạnh nhà vệ sinh tới y 3,05 chỉ tới x 0,1; phía sau nhà vệ sinh và phần trên 3,05 giữ 0,16;
  - mặt đầu tường ở z −0,197 tách ba theo cùng độ cao;
  - chỗ nhảy bậc ở y 3,05 nằm trong tấm trần nhà vệ sinh (3,0…3,15) nên không thấy;
  - `Walls` 370 → 398 tam giác.
  - Dựng lại từ script chưa sửa ra đúng đỉnh và đúng tập tam giác của glb trên main, chỉ khác thứ tự tam giác trong `Steps` và `Upper`. Vậy thay đổi thật chỉ nằm ở `Walls`.
- Lớp trát phía giếng thang (x −0,103), bậc, chiếu nghỉ, lan can, `Landing4Rail`, nhà vệ sinh, hành lang không đổi.

**Bước 4, cầu thang thoát hiểm và phòng 408:** không có lỗi tương tự. Tường giếng thang thoát hiểm (`FireStairs/Wall43.92`, x 43,84…44) và khối `W1Stairs` của nó đặt mặt đúng ở x 43,84, trùng mặt trong tường đông phòng 408 (T-255). Không hình hay va chạm nào của nhà B nằm trong phòng 408 (probe và test mới). Không sửa gì.

**Dấu vân tay đổi có chủ ý** (so bản `building_b.tscn` của main với bản mới bằng một test tạm, không commit; mọi dòng khác trùng main):
- `test_t250_realistic_wave1.gd` `COLLIDERS_MD5`: `c666d1ad…` (36 dòng) → `e6ec0257…` (38 dòng).
  - Dòng đổi: `Wall0.08000000000000007/Collision|(0.08, -4.0, -3.2)|BoxShape3D|(0.16, 13.5, 6.0)|1|0` → `…|(0.08, -5.375, -3.2)|BoxShape3D|(0.16, 10.75, 6.0)|1|0`.
  - Dòng thêm: `EastWall4/Collision|(0.05, 1.375, -2.6)|BoxShape3D|(0.1, 2.75, 4.8)|1|0`, `EastWall4Back/Collision|(0.08, 1.375, -5.6)|BoxShape3D|(0.16, 2.75, 1.2)|1|0`.
- `test_t253_realistic_wave2.gd`:
  - `COLLIDERS_MD5` `b3bd51f1…` (331 dòng) → `4563095c…` (333): cùng ba dòng như trên (đường dẫn có tiền tố `MainStairs/`).
  - `NODES_MD5` `eba52505…` (2216 dòng) → `976f35d0…` (2222): ba dòng `Wall0.08…` (body, `Collision`, `Mesh`) đổi tâm y −4 → −5,375; thêm sáu dòng `EastWall4`, `EastWall4Back` (body, `Collision`, `Mesh` mỗi cái).
- `test_t254_landing_rail.gd`, `test_t256_floor4_rest.gd`: không giữ dấu vân tay của các hộp này, không đổi.

**Test:**
- Test mới `game/tests/levels/test_t258_main_stairs_wall.gd`: 5/5 đạt.
  - Ở chế độ khuôn viên, không có hình hay va chạm nào của khuôn viên trong lòng nhà vệ sinh và phòng 408.
  - Tám tia từ trong phòng bắn về phía tây chạm tường ở x 0,1 (lệch 0): giữa các vòi, dưới gương, trong buồng, sát trần.
  - Ba hộp tường đúng số đo: mặt tây ở x 0, tổng thể tích bằng hộp của main trừ dải 6 cm.
  - Lớp trát phía giếng thang kín ở mọi điểm dò (y −1,5…3,6, z −0,3…−6,1).
  - Capsule (player thật) đi chiếu nghỉ tầng 4, xuống vế 4A, 4B tới chiếu nghỉ tầng 3 và lên lại.
  - Chạy với file của main: ba test đầu báo lỗi (thấy hộp lấn ở x 0,16), hai test cuối đạt. Đúng ý đồ: phần không được đổi thì không đổi.
- Test cũ chạy lọc, tất cả đạt: `test_t250` 5/5, `test_t253` 9/9, `test_t254` 4/4, `test_t256` 9/9, `test_fire_stairs` 3/3, `test_campus` 5/5, `test_floor4` 9/9, `test_t255` 12/12, `test_sealed_408` 2/2.
- Full test và check trên `0a37767` (trước commit cuối; commit cuối chỉ đổi card và bỏ một bộ góc chụp thử khỏi `capture_t258.gd`):
  ```
  RESULT: 989 passed, 0 failed
  RESULT: check 0 error(s)
  ```

**Ảnh** (`art_source/graphics_upgrade/realistic_map/previews/floor4_rest/`, chương 3, chụp bằng `wave1/capture_t258.gd`):
- `t258_before_*`, `t258_after_*`, ghép ở `compare_t258.jpg` (`wave1/make_compare_t258.py`);
- nhà vệ sinh: `w1_sinks`, `w2_mirror`, `w3_trough` (cùng camera với `after_ch3_washroom_04_washroom_sinks`, `a4_mirror`, `a5_trough` của T-256), `w4_wall_top` (đỉnh tường sát trần);
- giếng thang: `s1_landing4` (chiếu nghỉ tầng 4), `s2_flight4b` (từ vế 4B nhìn lên), `s3_wall_end` (đầu tường chỗ chiếu nghỉ gặp hành lang): trước và sau như nhau, tường kín;
- `o1_behind_b`: từ ngoài, sau nhà B.
- VRAM trong cảnh chụp chương 3: 1.269 MB (sau T-257).

**Thấy thêm khi làm (ngoài phạm vi, chưa sửa):**
- **Tường sau nhà vệ sinh không có mặt ngoài** (có từ T-256, do lane B làm).
  - `washroom_real.gd` ẩn hình PS1 `BackWall/Mesh`, còn `washroom.glb` chỉ dựng mặt trong. Nên từ ngoài, phía sau nhà B, nhìn xuyên được vào ba buồng: ảnh `t258_before_o1_behind_b.jpg` và `t258_after_o1_behind_b.jpg` giống nhau, T-258 không gây ra.
  - Đã chụp thử từ ban công phòng 401 ở chương 1 và 3: tường bên ban công che hết, không thấy. Chưa kiểm người chơi có đứng được chỗ nào khác để thấy không.
  - Card này cấm đổi nhà vệ sinh nên tôi không sửa.

**Yêu cầu thay đổi (integrator):**
1. Việc nhỏ cho lane B: thêm mặt ngoài (trát) cho tường sau nhà vệ sinh trong `washroom.glb` (`floor4_rest/build_washroom.py`, file của T-256), và kiểm luôn các mặt ngoài khác của nhà vệ sinh đã ẩn hình PS1 (mặt trên trần, tường đông giáp phòng 401). Không đụng va chạm.

