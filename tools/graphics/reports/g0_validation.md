# T-210 — Kết quả G0, 11/10/2026

Nhánh `lane-c/T-210-graphics-asset-qa`, nền `e3ed54a` (D-077/D-078). Godot báo `4.7.2-stable (official)`. Lượt Windows C sau B, chạy tuần tự, múi giờ UTC+7. Chỉ xác minh phần G0; không kết luận toàn bộ T-210 done.

| Lệnh | Giờ bắt đầu–kết thúc | RESULT |
|---|---|---|
| `pwsh tools/test.ps1` | 02:27:19–02:47:46 | **725 passed, 0 failed**, exit 0 |
| `pwsh tools/check.ps1` | 02:47:50–02:56:03 | **check 0 error(s)**, **336 script parse PASS**, exit 0 |
| `python -B -m unittest discover -s tools/graphics -p test_offline.py -v` | Chạy offline, cùng phiên | **28 tests OK**, exit 0 |
| `python -B tools/graphics/asset_qa.py tools/graphics/sample_manifest.json --probe-log build/graphics/full-test.log` | Sau full test, không mở Godot | **INCOMPLETE**, exit 2, `errors=[]` |

Full test tăng 3 ca so với baseline 722: transform/marker, model thiếu geometry và hai kit GLB thật. Không đổi runner/launcher hoặc ngưỡng production. Warning từ fixture dữ liệu thiếu có trong log full test; không có `ERROR`/test FAIL.

## Số đo sau import

Đọc bằng `Mesh.get_faces()` và transform node trong full test; không suy từ manifest. Số đo chi tiết, hash GLB, bounds, node, scale và texture tại [g0_probe.json](g0_probe.json).

| Asset | Tam giác | Material | Texture | Kích thước XYZ (m, làm tròn) |
|---|---:|---:|---:|---|
| `game/assets/models/kit/door.glb` | 120 | 2 | 2 | 0,88 × 2,08 × 0,10 |
| `game/assets/models/kit/bunk_bed.glb` | 372 | 4 | 4 | 0,90 × 1,70 × 2,00 |

Cửa mẫu khớp bounds/pivot bản lề/root scale và ngưỡng tam giác đã có. Nguồn/CC0/AI được tham chiếu từ `art_source/CREDITS.md`. Marker hợp đồng rig mới chưa có; fixture dùng `Visual/Grip` để kiểm transform và Python fixture bắt marker thiếu, không coi đó là kiểm rig A/B.

Checker vẫn **INCOMPLETE**: chưa duyệt G1/G3/asset, chưa có ngày tạo có bằng chứng, provenance còn cần người duyệt, chưa đo animated bounds/VRAM và chưa kiểm tương tác/collision/nav trên visual mới. File GLB hash không bao trùm importer/material/texture: đổi dependency thì phải import và probe lại.

Kiểm kê nguồn đọc filesystem: 38 GLB, tổng 617.992 byte, file lớn nhất 63.872 byte; không GLB vượt 10 MiB. Không phải số RAM/VRAM.

## Giới hạn và nhả lượt

**C đã nhả lượt Godot** sau check; không còn tiến trình Godot khi kiểm. Không render, FPS, bot chương 3–4, gọi API Meshy, dùng credit, cài plugin hoặc mở PR. File `default_bus_layout.tres` do import tự serialize đã khôi phục về bản gốc, không thuộc gói thay đổi.

Meshy mới là dry-run/ledger fixture offline: timeout/duplicate/resume/budget/persist/lock đã kiểm, chưa có transport hoặc downloader thật. Số credit trong mẫu là giả lập, không là giá hoặc quyền chi. G1 cần web/B/integrator chốt schema/marker/budget; G2 cần tài khoản/license/key/trần chi/operator và scene pilot. Ảnh/âm thanh/chơi tay/benchmark còn chờ điều kiện riêng.

Log đầy đủ giữ cục bộ trong `build/graphics/{full-test.log,full-check.log,offline-tests.log,asset-report.json}`. Báo cáo này và JSON số đo được lưu Git để web/integrator review mà không cần log lớn.
