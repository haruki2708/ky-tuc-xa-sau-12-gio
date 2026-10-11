# T-210 — Công cụ G0, đề xuất chờ G1

> **Hiện hành D-080/G1:** Tripo Studio thủ công → GLB → Blender → Godot. Đọc [G1_SCHEMA.md](G1_SCHEMA.md), `manifest.schema.json` và `sample_g1_manifest.json`. Công cụ mới là `asset_dry_run.py`, tách provider/channel/wallet. Phần G0 bên dưới cùng `meshy_dry_run.py`, `sample_request.json`, báo cáo G0 chỉ giữ để đối chiếu và tương thích lịch sử; không chuyển giá/quyền/license Meshy sang Tripo. Chưa có transport API hoặc ngân sách được cấp.

> **D-080 ngày 11/10:** nhà cung cấp mới là **Tripo AI**; đọc [hướng chuyển đổi](../../docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Nội dung G0 dưới đây ghi công cụ/kết quả trước khi đổi provider; không áp dụng giá/quyền/API Meshy sang Tripo. Studio thủ công không cần key; API dùng ví riêng. Chưa có Tripo asset hoặc transport live.

Chỉ đọc asset có sẵn; không sửa model/scene, logic hoặc budget production. Python 3 dùng thư viện chuẩn; probe dùng Godot 4.7.2 đã cài. Không cần Meshy/key/plugin. Không có đường gọi mạng hoặc chế độ live trong công cụ Meshy này.

## Kiểm asset

`sample_manifest.json` là schema mẫu **đề xuất**, `asset_qa.py` kiểm các trường và đọc file thật. Không dùng để bắt B chuyển dữ liệu trước G1. Đường dẫn tính từ gốc repo, dùng `/`, cấm đường tuyệt đối/`..`, kiểm cả đường sau resolve để chặn symlink thoát repo.

| Trường | Kiểu / ý nghĩa cần chốt ở G1 |
|---|---|
| `schema_version` | `t210-g0-proposal-1`; không là chuẩn production |
| `assets[].asset_id`, `scope`, `file` | ID duy nhất, `prototype`/`production`, file tương đối repo |
| `source` | `uri` (`repo:`/HTTPS), `author`, `license`, `credits_file`, `ai_tool`, `input_rights`; bắt buộc ghi cả AI và quyền đầu vào, `none` khi thật sự không dùng |
| `geometry` | `dimensions_m`, `bounds_min_m`, `root_scale`: vector XYZ; `tolerance_m`; `markers`: map node path → XYZ trong hệ local model sau transform |
| `generation` | `tool`, `model_id`, `task_id`, `created_on`, `parameters`; null cho Meshy ID/ngày chưa có bằng chứng, không bịa ngày |
| `budget` | `estimated_credits`, `consumed_credits`, `triangle_limit_exclusive` và căn cứ; null limit khi chờ G1, không nới ngưỡng PS1 |
| `approval` | `status`: pending/approved/rejected; `reviewer`: người duyệt hoặc null |

Mẫu cửa lấy kích thước từ `art_source/kit/build_kit.py` và ràng buộc `game/tests/levels/test_kit.gd`; nguồn CC0 tại `art_source/CREDITS.md`. Đây là bản ghi thử trong tools, không là manifest của B. License allowlist mới hỗ trợ CC0-1.0/CC-BY-3.0/CC-BY-4.0; biến thể khác cần review, không đồng nghĩa bị kết luận bất hợp pháp. Pro Private bị chặn.

Không có số đo thì chạy ngay, nhận `INCOMPLETE`, exit 2:

```powershell
python -B tools/graphics/asset_qa.py tools/graphics/sample_manifest.json
python -B -m unittest discover -s tools/graphics -p test_offline.py -v
```

Sau khi integrator xếp lượt Godot Windows, từ gốc repo:

```powershell
New-Item -ItemType Directory -Force build/graphics | Out-Null
. ./tools/godot-path.ps1
& $Godot --headless --path $GameDir --import
& $Godot --headless --path $GameDir --script res://scripts/debug/graphics_asset_probe.gd -- res://assets/models/kit/door.glb res://assets/models/kit/bunk_bed.glb 2>&1 | Tee-Object build/graphics/probe.log
python -B tools/graphics/asset_qa.py tools/graphics/sample_manifest.json --probe-log build/graphics/probe.log
```

Probe load GLB đã import, không thêm model vào SceneTree: không chạy `_ready`/AI/collision/nav. Đếm `Mesh.get_faces()` trên từng instance, đo bounds sau transform, root scale, đường node, số surface/material và kích thước texture nhận diện từ material/shader. Không lấy số tam giác tự khai. Hash file giúp bắt report sai phiên bản GLB; phải import/probe lại khi đổi importer, material, texture hoặc engine (hash GLB **không** bao trùm dependency). Không đưa GLB không tin cậy vào project để probe.

Exit: **1 FAIL**, **2 INCOMPLETE**, **0 chỉ khi mọi kiểm cần thiết đã xác minh**. Hiện G0 luôn giữ các mục chưa xác minh: quyền nguồn kiểm tay, animation bounds, texture GPU memory, tương tác/collision/nav và duyệt hình. Không dùng exit 2 làm PASS; các trường kiểm được nằm trong `measured`, sai kích thước/marker/budget là FAIL. Bounds là rest pose; chưa đo skin/animation, LOD, MultiMesh, VRAM hay FPS. Danh sách texture không là cam kết toàn bộ shader dependency.

## Ledger offline G0: tên file Meshy lịch sử

```powershell
python -B tools/graphics/meshy_dry_run.py tools/graphics/sample_request.json
```

`sample_request.json` dùng **số giả lập 10 + 20**, tối đa 2 lượt = 60; không phải giá Meshy, không phải ngân sách được duyệt. Công cụ báo công đoạn, tổng dự toán và trần; reject tổng vượt trần, license ngoài allowlist. Không đọc `MESHY_API_KEY`, không in payload/key, không có `--live`. Tên bước là nhãn dự toán nội bộ, **không phải API endpoint**. Không có API/settings mới được suy đoán.

Ledger fixture được giữ giữa các tiến trình (mọi số dư/credit đều giả lập):

```powershell
$request = 'tools/graphics/sample_request.json'
$ledger = 'build/graphics/fixture-ledgers/demo.json'
python -B tools/graphics/meshy_dry_run.py $request --fixture-ledger $ledger --event init --balance 100
python -B tools/graphics/meshy_dry_run.py $request --fixture-ledger $ledger --event reserve_submit
python -B tools/graphics/meshy_dry_run.py $request --fixture-ledger $ledger --event accepted --fixture-task-id fixture-001
python -B tools/graphics/meshy_dry_run.py $request --fixture-ledger $ledger --event timeout
python -B tools/graphics/meshy_dry_run.py $request --fixture-ledger $ledger --event resume
python -B tools/graphics/meshy_dry_run.py $request --fixture-ledger $ledger --event succeeded --consumed 30 --balance-after 70
```

State ghi atomic sau mỗi bước, lock độc quyền trên file; không reset ledger đã tồn tại. Có task ID thì resume tối đa 3 lần; timeout chưa có ID giữ `submission_unknown`, chặn submit lại và yêu cầu operator đối soát. Task failed vẫn có thể ghi credit đã tiêu. Số dư trước–sau lệch `consumed_credits` hoặc vượt khoản dự trù đưa vào `reconciliation_required`. Không tự chạy lượt thứ hai; trần lượt là giới hạn tối đa, không là quyền retry. Nếu tiến trình chết để lại `.lock`, operator kiểm không còn tiến trình giữ ledger trước khi bỏ lock; không tự bỏ lock.

**Phần live chưa triển khai/chưa nghiệm thu:** trước G2 cần integrator chỉ định một operator, G1 chốt schema, chủ dự án cấp kết nối/trần chi/license. Sau đó mới đối chiếu tài liệu Tripo API/phiên bản và giá trong đúng ví API, thêm transport/auth/balance/submit/poll/download. Adapter live sau D-080 dùng quy ước dự kiến `TRIPO_API_KEY`; không dùng key Meshy cho Tripo, chưa có client live đọc key; không đưa vào request/ledger/log. Lưu reservation trước POST; không retry POST khi mất response; lưu ID ngay khi nhận. Đối soát task/credit/số dư thật trước mọi lượt mới. Fixture không chứng minh Meshy đã kết nối hoặc resume API thật hoạt động.

## Staging và lưu bền vững — quy trình chờ G2

Chưa có downloader mạng. Đích dự kiến `build/graphics/staging/<asset_id>/<task_id>/`, ngoài `game/` và `art_source/`. Khi triển khai: chỉ HTTPS/host tải đã kiểm theo response thật; tên file do client đặt, reject `..`, absolute path, symlink/junction và archive traversal; giới hạn bytes lúc stream, kiểm header/hash/định dạng. Không log URL có query ký số. Lưu metadata allowlist (ID, ngày, license, parameters, credit, hash, kích thước), không dump nguyên response chứa URL tạm/secret.

Tải đủ model/texture đã duyệt trước khi URL hết hạn; file thiếu hoặc lớn hơn 10 MiB phải dừng, không tự import. B kiểm thủ công rồi chuyển bản nguồn bền vững vào `art_source/graphics_upgrade/` cùng CREDITS/metadata, LFS và giới hạn từng file; runtime vào vùng B sau review. `build/` và link tạm không phải kho bàn giao duy nhất. C không tự publish/copy vào production.

## Đầu ra cần web/integrator chốt

1. ID/đường node marker, hệ trục + mét + pivot, tolerance từng asset; mẫu cửa dùng origin bản lề, không ép mẫu này lên rig.
2. Schema source/generation/budget/approval và vị trí manifest B; quy tắc hash dependency sau import.
3. Budget prototype khác production, ai duyệt license/asset, operator và trần credit.
4. Scene/camera pilot B và API adapter A; UI/render settings chỉ dùng sau hợp đồng G1.

Góc chụp và ma trận hồi quy tại `qa_plan.md`. Full game tests tự tìm ba test probe mới (transform/marker, geometry thiếu và hai asset kit thật); Python fixtures chạy riêng, không sửa runner hiện có. Full test in một dòng `GRAPHICS_PROBE_JSON=...`, có thể dùng log full test làm `--probe-log` mà không mở thêm Godot. Số đo G0 đã lưu tại `reports/g0_probe.json`; đây là rest pose của kit cũ, chưa nghiệm thu visual mới hoặc FPS.
