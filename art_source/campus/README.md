# Campus — T-183

Greybox đầu để Lane A/C tích hợp: `res://scenes/levels/campus/campus.tscn`.
Đặt cạnh `Floor4`, cùng transform gốc (không dịch riêng một scene).
Scene thử: `res://scenes/levels/campus/campus_playtest.tscn`.

Sinh lại bằng Python đi kèm Blender portable:
`D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe art_source/campus/build_campus.py`.
Bộ sinh chỉ ghi thư mục Campus, không ghi Floor4 hoặc Room407.

## Tích hợp

- Campus gỡ collision/ẩn **hai end-cap trên instance** `Floor4/Corridor/WestEnd`,
  `EastEnd`; dùng môi trường Campus, ẩn cây sân giả cũ. Khi Campus rời cây scene,
  các thuộc tính này được phục hồi. Có thể gọi `attach_floor4(floor4)` nếu core
  tạo Floor4 sau Campus; mặc định tìm `../Floor4`.
- API gốc theo card: `set_fire_door_open(bool)`, `set_main_door_chained(bool)`,
  `set_canteen_tv(bool)`, `set_stadium_lights(bool)`, `get_anchor(String)`.
  API chỉ điều khiển hình học/hiển thị, không tự phát trigger cốt truyện.
- Cửa thoát hiểm đóng và cửa chính xích khóa khi tải. API đồng bộ link navmesh.
- `Navigation/WindowCross` và `WindowCrossOut` có metadata `requires_crouch`.
  Lane A cần chuyển actor sang capsule cúi 1,15 m ở cửa sổ. Link 407 cần core
  mở cửa 407. Campus không đổi luật tương tác, chìa khóa hay AI.
- Anchor/vùng theo tên trong card; toàn bộ tọa độ ghi trong `layout.json`.
  Các tọa độ ngoài phần hợp đồng là bố trí kỹ thuật, không bổ sung nội dung truyện.
- Marker `Pxx_Wait_*` đánh dấu chỗ chờ; core quyết định khi nào tiếp tục.

## Kiểm tra greybox

`pwsh tools/test.ps1 -Filter campus`: hợp đồng, đóng/mở collision, capsule cửa sổ,
đoạn sập, đường navmesh 407 → tầng 2 → cửa sổ → vườn → sân → cổng → nhà ăn/kho,
khán đài và phục hồi Floor4 khi tháo Campus. Full test/check sẽ ghi trong Handoff
sau bản chi tiết.
