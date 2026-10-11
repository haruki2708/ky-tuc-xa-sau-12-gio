# T-209 — bản khai G1 balo hiện hành sau D-083

Đầu vào kiểm hiện hành của B: [backpack_g1_manifest.json](backpack_g1_manifest.json), `schema_version=t210-g1-static-1`, duy nhất ID chữ thường `room407_backpack`. Bản [asset_manifest.json](asset_manifest.json) G0 giữ nguyên để tra cứu lịch sử; không gửi bản G0 vào validator G1. Schema/validator thuộc C, không được sửa trong lượt B này.

## Binding và nguồn số đo

Theo T-207 `INTEGRATION_CONTRACT.md` §2.1 và `ASSET_BINDINGS.md` §2.5: owner **B**, class đích **Node3D**, scene `res://scenes/levels/floor4/floor4.tscn`, node `Room407/Details/Trung/Backpack`. Artifact là `game/assets/models/room407/backpack.glb`, CC0 T-153, `self_authored/local`; Tripo Studio chỉ là planned_route cho mẫu tương lai.

Manifest được lập từ mục `room407_backpack` trong **báo cáo đo thật G0 của B** `measured_assets.json`; không chép số từ mẫu C. Probe mới của C đã đối chiếu imported GLB và node được chọn trong floor4, bỏ transform root khi tính bounds, giữ transform con. `facing_report.json` xác nhận class Node3D, scene_file_path đúng GLB, placement world `(33.7799987793,0.0199999996,-4.5199999809)`, rotation `(0,90,0)`, scale `(1,1,1)`; khớp khai báo `(33.78,0.02,-4.52)` trong sai số số thực. Root trong room407_details local x=3.78, phòng cộng x=30. Không thêm marker/collider/nav hoặc sửa placement.

| Đại lượng | Số đo imported mới (C probe) | Trần/điều kiện |
|---|---|---|
| Kích thước XYZ, m | `(0.29000002,0.45639998,0.30270001)` | Root-local, rest pose, include_hidden |
| Bounds min XYZ, m | `(-0.14500001,0.01000001,-0.13250001)` | Tolerance khai `0.0001 m`, trong trần D-081/D-083 `0.001 m` |
| Root scale | `(1,1,1)` | Epsilon riêng không đơn vị `0.00001` |
| Tam giác | 96 | `<3001`, không nới D-079 |
| Vật liệu | 3 | `≤2`: balo cũ phải FAIL |
| Texture | moss/cloth/ink, 3 albedo ×128² | Mỗi chiều ≤1024 px |

Target manifest từ G0 vẫn là size `(0.29,0.45636,0.30274)`, min `(-0.145,0.01,-0.1325)`; độ lệch mỗi thành phần với số đo imported mới dưới 0.00004 m, nhỏ hơn tolerance khai 0.0001 m. Không sửa target hoặc nới sai số. `bound_node_measurement` và `glb_measurement` trong [facing_report.json](backpack_g1/facing_report.json) đã đối chiếu khớp. Texture hiện có moss/cloth/ink đều 128×128; không có texture Tripo mới.

Không lấy số liệu cũ làm chứng cứ đã tạo/duyệt asset Tripo. Ngày tạo nguồn chưa có chứng cứ để điền chính xác thì giữ null; hồ sơ source/credits không đổi tác giả. Owner và facing không là field schema mới: owner xác nhận ở tài liệu/contract; basis **−Z trước, +Y lên, pivot `(0,0,0)`** trong [brief kèm bốn ảnh đã xem](TRIPO_BACKPACK.md#hướng-mặt-trước).

## Kiểm chứng

Đã kiểm schema không probe: `errors: []`, `status: INCOMPLETE`, exit 2. Sau khi nhận lượt, chạy probe C mới trên GLB rồi validator:

```powershell
& D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://scripts/debug/graphics_asset_probe.gd -- res://assets/models/room407/backpack.glb > build/t209-g1-probe.log
python -B tools/graphics/asset_qa.py art_source/graphics_upgrade/backpack_g1_manifest.json --probe-log build/t209-g1-probe.log
```

Output nguyên văn: `"errors": ["material budget exceeded"]`, `"status": "FAIL"`, **exit 1**. Đây là ca âm tính đúng cho balo cũ 3 > 2, **không phải QA PASS**. Không có lỗi schema/kiểu/scale/tolerance hay geometry khác. Sau full test sẽ chạy lại trên log mới nhất:

```powershell
python -B tools/graphics/asset_qa.py art_source/graphics_upgrade/backpack_g1_manifest.json --probe-log build/t209-g1-full-test.log
```

Output đầy đủ được giữ tại [asset_qa_result.json](backpack_g1/asset_qa_result.json), gồm measured/hash và `unavailable`. Lượt probe GLB có 368 mục unavailable: 315 `missing_dependency_hash`, 43 `dependency_closure_unproven`, 10 mục duyệt/phép đo khác. Validator R3 quét cả `binding.scene_path` floor4 trong khi probe GLB không hash toàn scene/wrapper; cache nhị phân cũng chưa chứng minh đủ closure. Đây là giới hạn evidence đã nêu ở G1_SCHEMA, không thêm hash giả, đổi binding hoặc bỏ mục chưa kiểm để thành PASS. Integrator/C cần xác định chứng cứ wrapper/closure khi nghiệm thu mẫu mới; báo cáo kỹ thuật hiện tại chỉ chứng minh ca FAIL vật liệu đúng và dữ liệu B hợp schema. Full test/check và trạng thái cuối ghi ở Handoff T-209.

Ảnh facing/probe chỉ chạy khi integrator bàn giao Godot, APPDATA cô lập dưới `build/graphics-pilot-userdata`. Không tạo lại G0, pilot vật liệu hoặc mount survey; không Tripo/MCP/FPS/bot.
