# T-138 — Đạo cụ thật thay khối hộp tạm
- Lane: B (Môi trường và 3D) | Trạng thái: review | Agent: **Claude làm thay** (chủ dự án giao, 2026-10-03)
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Có ảnh ở mục 7, FPS ghi trong Handoff
- [x] `CREDITS.md` cập nhật
- [x] Handoff: API `water_stream`, `slippers_pair`, `shirt_hanging`; phần chưa thử bằng tay

## Handoff (agent điền)

### 2026-10-03 — Claude làm thay lane B
- **13 đạo cụ** (`art_source/props/build_props.py`, dùng lại hàm kit, texture kit không chép): bàn (bàn trực và bàn học), đèn bàn, điện thoại quay số, đồ trên bàn trực (sổ đóng, con dấu, hộp mực, ống bút), bảng tin khung gỗ mặt bần, bồn rửa chân trụ, vòi inox, mặt trước buồng vệ sinh, dép lê, áo thun, khăn, xô nhựa, **loa nén** gắn tường (thay hộp loa). Nhiều nhất 316 tam giác (xô). 10 texture mới 128 px.
- **Scene có API:** `water_stream.tscn` (`set_running`), `slippers_pair.tscn` (`color`), `shirt_hanging.tscn` / `towel_hanging.tscn` (`color`, `sway`). Chi tiết ở `art_source/props/README.md`.
- **Tầng 4** (`build_floor4.py`): 4 đôi dép 4 màu trước phòng 407; 5 món đồ phơi (áo, khăn) lắc nhẹ, chừa chỗ 25,5 cho áo trắng của cốt truyện; xô, bồn rửa, vòi, buồng vệ sinh, bàn trực, bàn học, đèn bàn bằng model. Va chạm giữ hộp vô hình. `Washroom/TapWater` ở đầu vòi `Tap_2`, mặc định tắt. Anchor `WashroomTapRunning` dời tới (0,24; 1,0) cho trùng vòi mới.
- **Gỡ hộp giấy tạm:** `HallBoardPaper`, `DutyLog`, `Washroom/Notice`; gỡ `Room407/Phone` và `Room407/LightSwitch` (trùng với hình của đồ vật lane A).
- **Cửa 407:** lời nhắc "Mở cửa" / "Đóng cửa" (`PROMPT_OPEN_DOOR`, `PROMPT_CLOSE_DOOR`).
- **Test:** `game/tests/levels/test_props.gd` (6 test). `pwsh tools/test.ps1`: **224 passed, 0 failed**; `check.ps1`: 0 lỗi.
- **FPS** (RTX 3050 Laptop, 1280 × 720, tắt VSync): nhà vệ sinh khoảng 334 (gương bật, nước chảy), hành lang khoảng 334, bàn trực khoảng 343.
- **Ảnh:** `art_source/props/previews/contact_sheet.png` (từng món) và `ingame.png` (bàn trực, bảng tin, loa, bồn rửa có nước chảy, buồng vệ sinh, dép, đồ phơi, bàn học).
- **Ghi chú QA:** rò rỉ tài nguyên khi chạy riêng `-Filter smoke` là lỗi chập chờn có sẵn (main cũng bị 1/3 lần), đã giao lane C ở T-115.
- **Chưa thử bằng tay:** chưa đi lại bằng chuột và phím; chưa xem trong lúc truy đuổi.

### Yêu cầu cho integrator (T-141)
1. `StoryDirector`: đôi dép thứ năm dùng `slippers_pair.tscn` màu đỏ sẫm, đặt cạnh 4 đôi (x 31,9); áo trắng dùng `shirt_hanging.tscn`, gốc trên dây phơi (y 2,15); bật `Washroom/TapWater` khi vòi tự chảy, tắt khi khóa vòi.
