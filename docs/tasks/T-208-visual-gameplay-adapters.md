# T-208 — Adapter model, animation và tương tác giữ nguyên gameplay
- Lane: A | Trạng thái: **ready — G0** | Agent: lane A
- Nhánh: `lane-a/T-208-visual-gameplay-adapters`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập, API chung sau G1 T-207; model mẫu T-209 cho G2/G3.
- Hạn đề xuất: gửi bản khảo sát/adapter mẫu trong phiên đầu; bàn giao nhân vật theo nhóm sau đó.

## Bối cảnh
`game/scripts/entity/ch3_actor.gd` đã có `set_body`, `play_pose`, `head_position`; `$Visual/Fallback` và node `Head` cần giữ hoạt động. `manager.gd` tìm `BladeTip`/AnimationPlayer. Các wrapper `campus/actor.gd`, `ch1_models/corpse_body.gd` thuộc B đang dựa vào khớp Node3D; model Meshy có skeleton cần đường nối khác. Game có giường, cửa, bịt miệng, vạt giường và thanh sắt; model đẹp không được che tia ngắm hoặc thay khoảng cách gameplay.

## Việc
1. **G0:** khảo sát consumer của visual trong vùng A: root/collider, pose, Head/BladeTip, điểm tay/miệng, timeline tấn công và death camera. Ghi bảng trong Handoff cho T-207/T-209. Dùng model hiện có để dựng thử adapter nhỏ; chưa cần Meshy.
2. **Sau G1:** triển khai giao diện adapter trong vùng A, chấp nhận visual cũ và visual rig mới; hỗ trợ thay thân nhiều lần, null/fallback, pause, reset scene/checkpoint. Movement/collision do root gameplay giữ, tránh root motion mới gây đi hai lần.
3. **G2:** phối hợp B kiểm một sinh viên trước: đứng/đi/nằm/ngồi/quay đầu; sau đó quản lý và xác. Các pose đặc thù bịt miệng, máu, thức dậy, chém/vồ phải được ánh xạ rõ; không âm thầm bỏ pose thiếu. B tự sửa wrapper/clip vùng B theo hợp đồng.
4. **G3/G4:** kiểm vật tương tác và toàn bộ nhân vật theo từng nhóm. Chỉnh offset hoặc attachment phục vụ model, giữ tầm ngắm, va chạm, tốc độ, AI, sát thương, cooldown và thời điểm luật. Thấy vấn đề do kích thước model thì báo B, không đổi bố cục để che lỗi.

## Được phép sửa
Vùng A trong AGENTS §3: `game/scenes/player/`, `interaction/`, `entity/`, `game/scripts/player/`, `interaction/`, `entity/`, `game/tests/player/`; chỉ các phần liên quan adapter/tương tác. Handoff/checklist card. Không sửa `game/scenes/levels/`, rendering, core, test levels, SETTINGS. Yêu cầu B/core ghi qua Handoff.

## Test và bằng chứng
- Test thay visual trên actor thật: root transform/collider không dịch ngoài chủ đích; `set_body` liên tiếp không nhân đôi model; Head theo đầu mới, fallback hợp lệ; pose/pause/reset đúng.
- Với nhân vật có rig: marker theo bone khi chuyển động; timing sự kiện không nhân đôi, animation không chiếm movement AI. Có fixture lỗi marker/pose để chứng minh kiểm tra bắt đúng lỗi.
- Kiểm `InteractRay` thật cho giường/cửa/đồ được thay; đi bộ đến vị trí tương tác. Chạy các test D-069…D-075 liên quan trên scene thật khi ghép dependency B.
- Chạy toàn bộ `pwsh tools/test.ps1` và `pwsh tools/check.ps1`; chưa có model mới thì ghi rõ giới hạn, không báo đã tương thích Meshy.

## Checklist hoàn thành
- [ ] G0: bảng ràng buộc và prototype adapter
- [ ] G1: API thống nhất với web/B/F (F tiếp nhận E theo D-078)
- [ ] Pilot nhân vật/đạo cụ kiểm trong scene thật
- [ ] Không đổi hành vi AI/collision/timing và có fallback
- [ ] Full test/check PASS, Handoff phân biệt mẫu thử và production

## Handoff (agent điền)
Chưa bắt đầu; chưa có model Meshy để nghiệm thu.

## Review (integrator)
Chưa review triển khai.
