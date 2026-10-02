# T-138 — Đạo cụ thật thay khối hộp tạm
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-138-real-props`
- Phụ thuộc: T-112, T-121, T-135 (done). D-021: đồ họa đẹp làm sau, giờ đến lúc làm.

## Mục tiêu
Demo đã chơi được trọn vẹn nhưng nhiều thứ trên tầng 4 vẫn là khối hộp greybox. Task này thay các đạo cụ người chơi **nhìn gần và tương tác** bằng mô hình low-poly kiểu PS1, dựng bằng script Blender như bộ kit (T-102, T-121).

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Mô hình mới**, dùng chung pipeline kit (vật liệu PS1, texture 64–256 px, lọc nearest, có collision khi cần):
   | Đạo cụ | Nơi dùng | Ghi chú |
   |---|---|---|
   | Bàn trực + ghế + đèn bàn + sổ trực đóng + con dấu | `duty_desk` | Sổ trực **mở** do integrator đặt (giấy đọc được); không đặt thêm sổ trùng chỗ anchor `DutyLog` |
   | Bảng tin khung gỗ, mặt bần | Bảng nội quy, anchor `HallBoard` | Giấy do integrator đặt lên |
   | Bồn rửa men trắng + vòi inox | Nhà vệ sinh (3 bồn) | Vòi giữa (`Tap_2`, anchor `WashroomTapRunning`) cần **dòng nước chảy**: scene `water_stream.tscn` có hàm `set_running(on: bool)` (mặt phẳng texture cuộn kiểu PS1, có bọt dưới đáy bồn) |
   | Cửa buồng vệ sinh | 3 buồng | Khép, không mở được |
   | Đôi dép tổ ong / dép lê | Trước cửa phòng | Scene `slippers_pair.tscn`, `@export var color: Color`. Integrator dùng cho đôi dép thứ năm (màu đỏ sẫm) |
   | Áo thun trắng phơi trên móc | Dây phơi, anchor `ClotheslineExtraShirt` | Scene `shirt_hanging.tscn`, có lắc nhẹ theo gió |
   | Xô nhựa | Các node `Bucket_*` ở hành lang | |
2. **Gỡ các mặt phẳng giấy tạm** trùng chỗ với giấy đọc được do integrator đặt: `HallBoardPaper`, khối `DutyLog` trên bàn, `Washroom/Notice`. Giữ nguyên anchor.
3. **Cửa phòng 407 (`door407.gd`):** lời nhắc đổi theo trạng thái, "Mở cửa" / "Đóng cửa" (thêm key `PROMPT_OPEN_DOOR`, `PROMPT_CLOSE_DOOR` vào `strings.csv`, đủ vi và en).
4. **Không đổi tên hoặc vị trí** các node code đang dùng: `Corridor/CorridorLight_*`, `Room407/Room407MainLight`, `Room407/BunkA/Net_Phuc`, `Net_Viet`, `BunkB/Net_Trung`, `Net_Dat`, `Washroom/Mirror`, mọi node trong `Anchors/`, `Door407/Pivot/RulesPaper`, `fan_rotor`. Nếu bắt buộc phải đổi thì ghi vào "Yêu cầu thay đổi".
5. **Ngân sách:** đồ lớn dưới 1500 tam giác, đồ nhỏ dưới 500; vẫn ≥ 60 FPS ở hành lang và nhà vệ sinh (ghi số FPS như T-135).
6. **Test `game/tests/levels/`:** scene load được; các node ở mục 4 vẫn tồn tại đúng chỗ; `set_running` bật tắt được dòng nước; `slippers_pair.color` đổi được màu; số tam giác trong giới hạn.
7. **Ảnh:** bàn trực, bảng tin, bồn rửa có vòi chảy, đôi dép trước cửa, áo trên dây phơi.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Có ảnh ở mục 7, FPS ghi trong Handoff
- [ ] `CREDITS.md` cập nhật
- [ ] Handoff: API `water_stream`, `slippers_pair`, `shirt_hanging`; phần chưa thử bằng tay

## Handoff (agent điền)
