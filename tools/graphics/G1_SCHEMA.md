# T-210 — G1 đạo cụ tĩnh và Tripo, gửi Astra review

Nền `acbf771` có D-079/D-080. G0 đã ghép, không làm lại. Đây là đề xuất triển khai tiếp trong T-210; **Astra điều phối tiếp nhận T-207**, là đầu mối core/hợp đồng. B giữ dữ liệu/asset, C giữ schema/công cụ; runtime không đọc manifest hoặc gọi Tripo.

## File và cách đọc

- `manifest.schema.json`: schema JSON đề xuất `t210-g1-static-1`.
- `sample_g1_manifest.json`: mapping thử **balo cũ CC0** theo dữ liệu B; `planned_route=tripo_studio_manual` là hướng tạo bản mới, không thay nguồn/tác giả của bản cũ.
- `asset_qa.py` + `manifest_g1.py`: đọc v0 cũ và v1 mới, kiểm file/hash/geometry/metadata/credit/giới hạn kỹ thuật. Exit 1 = sai, 2 = thiếu chứng cứ hoặc chưa duyệt, 0 chỉ khi đủ toàn bộ. Hiện vẫn giữ các mục duyệt thủ công và nghiệm thu cảnh thật ở trạng thái chưa xác minh.
- `asset_dry_run.py`: tính dự toán/ledger fixture độc lập dịch vụ, **không có API transport**, không đọc key hoặc gọi mạng. `meshy_dry_run.py` giữ CLI/import lịch sử; fixture lỗi G0 tiếp tục chạy.

```powershell
python -B -m unittest discover -s tools/graphics -p test_offline.py -v
python -B tools/graphics/asset_qa.py tools/graphics/sample_g1_manifest.json
python -B tools/graphics/asset_dry_run.py tools/graphics/tripo_studio_request.json
# Chỉ sau lượt full test Windows được integrator bàn giao:
python -B tools/graphics/asset_qa.py tools/graphics/sample_g1_manifest.json --probe-log build/graphics/g1-final-full-test.log
```

`tripo_studio_request.json` hoàn toàn là **fixture**, kể cả số 1 credit, bước preview và nhãn CC0. Không phải giá Tripo, ngân sách được duyệt, hoặc giấy phép một asset Tripo thật. File G0 số 10+20/60 cũng chỉ là lịch sử giả lập.

## Mapping gửi B và Astra

B chỉ chuyển `art_source/graphics_upgrade/asset_manifest.json` sau khi schema được review/ghép; C không ghi file B. Không âm thầm chấp nhận bản B draft như v1. B giữ đủ 15 ID, chuyển từng mục có chứng cứ; không lấy mẫu balo làm budget cho nhân vật/cả phòng.

| B draft / chứng cứ G0 | Schema C v1 |
|---|---|
| `id` | `asset_id`, giữ nguyên `room407_backpack` |
| `current_scene`, `measurement_node` | `binding.scene_path`, `binding.node_path` |
| `measured_assets.json` bounds local | `geometry.dimensions_m`, `bounds_min_m`; hệ `selected_root_local` |
| `position_in_scene_m`, `local_rotation_degrees`, `local_scale` | `placement.position_m`, `rotation_degrees`, `scale`, tách khỏi geometry |
| `source.credits`, `source.license`, generator | `source.credits_file`, `license`, `uri`; bổ sung author/AI/input_rights có chứng cứ |
| `preserve` | `binding.collider_policy=preserve_gameplay`; các ràng buộc chi tiết vẫn ở contract/bindings T-207 |
| marker contract | `binding.required_markers` và `geometry.markers` (node path → tọa độ root-local); balo tĩnh hiện là danh sách/map rỗng |
| công cụ/gói khi tạo | `generation.provider/channel/wallet_id/tier/model_version/model_id/task_id/created_on/parameters/rights_evidence` |
| chi phí có chứng cứ | `budget.wallet_id/estimated_credits/consumed_credits/balance_before/balance_after` |
| người duyệt | `approval.status/reviewer`, không lấy pass kỹ thuật thay duyệt nguồn/hình ảnh |

Mẫu balo: local size **0,29 × 0,45636 × 0,30274 m**, min **(-0,145; 0,01; -0,1325)**. Placement world của root phòng mẫu: **(33,78; 0,02; -4,52)**, rotation **(0; 90; 0)**, scale **(1;1;1)**; không chỉnh những số này trong scene. Dung sai `0.0001` m trong mẫu chỉ phục vụ đối chiếu dữ liệu B làm tròn năm chữ số, không cấp quyền dịch collider/marker/gameplay.

Trần D-079 cho **prototype balo mới**: `triangle_limit_exclusive=3001` (chấp nhận đúng 3.000), `material_limit=2`, `texture_edge_limit=1024`, 10 MiB/file và LFS giữ nguyên. B đã đo balo cũ **96 tris/3 material**: nếu đưa số đo hiện hành qua trần mẫu mới thì **phải FAIL material**, không sửa số đo hoặc nới limit để qua. Mẫu hiện tại không phải asset Tripo được nghiệm thu.

## Root-local, rest pose và chứng cứ import

Probe bỏ transform của root được chọn khi tính bounds/marker, vẫn nhân transform của con. `root_placement` ghi riêng position/rotation/scale của root; `root_scale` vẫn được báo để kiểm scale import. Chưa áp các giá trị placement vào scene. Fixture mới đặt root có dịch chuyển, xoay cả ba trục và scale không đều, xác nhận bounds/marker không đổi.

Policy hiện tại: `pose=rest`, `visibility_policy=include_hidden`; tính cả mesh ẩn, không tự chọn biến thể. Với nhiều pose/variant hoặc skin, cần B/A xác định mẫu riêng; không coi bounds này là animated bounds. Fixture mesh ẩn bảo vệ việc báo rõ policy. MultiMesh/particle/procedural runtime và tương tác/nav vẫn ngoài nghiệm thu probe này.

`report_for()` bổ sung SHA-256 của GLB, `.import`, output trong `.godot/imported/`, importer và dependency resource (material/shader/texture), thêm `project.godot`, mã probe và phiên bản Godot. Duyệt dependency theo [ResourceLoader.get_dependencies của Godot](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html#class-resourceloader-method-get-dependencies), xử lý path fallback của UID; shader/texture đang đo cũng được đưa vào tập hash. Hash file hiện tại khác report → FAIL; thiếu evidence/closure → INCOMPLETE. Đây là kiểm report còn khớp file, không chứng minh cache được rebuild đúng nếu ai sửa importer mà bỏ import.

Phải import/probe lại sau thay source/importer/material/texture/setting/engine. Dependency runtime ghép tên động hoặc variant chưa được nạp cần bổ sung evidence/fixture, không tự nhận closure bao phủ mọi mã tùy ý. Report có hash cache chỉ dùng để kiểm cùng workspace sau import; máy khác regenerate cache thì đo lại, không bỏ kiểm hash cho qua. Báo cáo G0 lịch sử không có v1 evidence, giữ nguyên và không dùng nó duyệt asset G1 mới.

Đối chiếu lượt Windows phát hiện `ResourceLoader.get_dependencies()` bỏ sót `extends/preload` của importer GDScript. Probe bổ sung quét các literal `res://` trong `.gd/.gdshader/.gdshaderinc`, nên hash cả importer cha, shader biến thể và include shader; fixture asset thật bắt buộc các đường này. Đây là phép quét bảo thủ, có thể lấy cả tham chiếu trong comment/nhánh chưa chạy; đường động hoặc đường tương đối ngoài tập dependency do loader trả về vẫn cần kiểm riêng, không coi đây là parser GDScript hoàn chỉnh.

## Tripo Studio thủ công trước

1. B đưa brief balo và đầu vào có quyền cho chủ dự án. Chỉ tạo có phí sau khi đã có ví Studio/trần chi/license phù hợp; D-080 chưa cấp các điều kiện này.
2. Khi có asset thật, lưu provider `tripo`, channel `studio`, wallet ID không chứa email/key dạng `tripo:studio:<alias>`, tier/model version/ngày/model ID/thông số, bằng chứng gói lúc tạo/đầu vào/điều khoản. Task ID được phép null nếu Studio không cung cấp, **không cần API key**.
3. Ghi số dư trước/sau và credit thực cùng ví; chênh lệch không khớp consumed thì dừng đối soát, không quy tất cả giao dịch tài khoản cho một model. Tải GLB và đủ texture vào staging ngoài nguồn, B lưu nguồn bền vững/CREDITS rồi chuẩn hóa Blender, nhập Godot scene riêng.
4. C kiểm artifact xuất cuối. `tier=paid` chỉ mô tả gói khi tạo; vẫn kiểm `source.license` theo allowlist repo. Thiếu bằng chứng Paid/quyền đầu vào → INCOMPLETE; dùng nhãn Paid như giấy phép hoặc ví không khớp → FAIL. Chưa có ngoại lệ license.

API là phương án riêng, provider `tripo`, channel `api`, ví `tripo:api:<alias>` và task ID thật. Không mượn số dư Studio. CLI generic mặc định chỉ dry-run; fingerprint/ledger giữ provider + channel + wallet, chặn resume qua ví/dịch vụ khác. Ledger cũ chưa ghi phạm vi ví phải được operator đối soát; không tự đổi fingerprint hoặc POST lại. Ledger fixture chỉ mô phỏng reservation/timeout/resume, không điều khiển Studio hoặc chứng minh API Tripo hoạt động. Tên biến `TRIPO_API_KEY` vẫn là dự kiến, không có code đọc nó.

## Cần Astra/B xác nhận khi review

Astra chốt field/path/default ở T-207 và điều kiện nghiệm thu đạo cụ tĩnh, B xác nhận mapping/root_class/node path và chuyển dữ liệu sau schema được ghép. Cần giữ phần pending rig/settings/chuông tách riêng. Không sửa core, renderer mặc định, collision/nav/timing hoặc settings trong gói C này. Full Windows test/check vẫn phải nhận bàn giao lượt; các fixture Python không thay kết quả Godot.
