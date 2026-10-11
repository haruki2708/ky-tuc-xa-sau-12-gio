# T-210 — Kết quả sửa G1 và chuyển Tripo, 11/10/2026

Nhánh `lane-c/T-210-graphics-asset-qa`, nền `acbf771` có D-080. Chỉ làm trong workspace C, giữ G0 đã ghép. Đầu mối core/hợp đồng T-207: **Astra điều phối**. Gói này bàn giao schema/công cụ để review, **chưa hoàn thành toàn bộ T-210 hoặc nghiệm thu asset prototype**.

## RESULT của bản sửa cuối

Windows, Godot `4.7.2-stable (official)`, múi giờ UTC+7. Chủ dự án đã bàn giao lượt và yêu cầu chạy tuần tự test → check, không cần xin lại.

| Lệnh | Thời điểm | RESULT |
|---|---|---|
| `pwsh tools/test.ps1` | 13:42:32–14:02:51 | **745 passed, 0 failed**, exit 0 |
| `pwsh tools/check.ps1` | 14:02:59–14:09:58 | **0 error(s), 344 script parse PASS**, exit 0 |
| `python -B -m unittest discover -s tools/graphics -p test_offline.py -v` | Sau bổ sung kiểm dependency | **42 tests OK**, exit 0 |
| Validator mẫu G1 với log full test cuối | Sau test, không mở Godot | **FAIL**, exit 1, lỗi duy nhất `material budget exceeded` |

Năm ca probe Godot đạt: transform con/marker; thiếu geometry; ba asset thật sau import; root dịch/xoay/scale không identity; mesh ẩn. So với nền ghép 743, thêm hai ca và mở rộng ca asset thật. Full suite giữ nguyên runner/ngưỡng production. Ca `test_floor4_standalone_navigation_reaches_both_ends_and_room407` đạt ở lượt Windows này; không kết luận đã sửa lỗi Linux từng được báo.

## Số đo và giới hạn nghiệm thu

[g1_probe.json](g1_probe.json) lấy trực tiếp từ `GRAPHICS_PROBE_JSON` trong full test cuối, không mở thêm lượt render/probe. Policy: selected-root-local, rest pose, gồm mesh ẩn; placement tách riêng.

| Asset | Tam giác | Material | Texture | Kích thước XYZ (m, làm tròn) | File đã hash |
|---|---:|---:|---:|---|---:|
| Cửa kit | 120 | 2 | 2 | 0,88 × 2,08 × 0,10 | 15 |
| Giường kit | 372 | 4 | 4 | 0,90 × 1,70 × 2,00 | 21 |
| Balo phòng 407 cũ | 96 | 3 | 3 | 0,29000 × 0,45640 × 0,30270 | 19 |

Balo có min **(-0,14500; 0,01000; -0,13250)**; sai khác size sau import so với B `(0.29, 0.45636, 0.30274)` dưới dung sai mẫu **0,0001 m**. Không sửa transform/asset B. Tập hash đã đọc được toàn bộ đường được probe phát hiện, không có `dependency_unavailable`; gồm source GLB, import config/cache, importer cha/con, shader/include/texture, project và mã probe. Hash cache chỉ áp dụng workspace hiện tại; máy khác phải import/đo lại.

**Asset FAIL là kết quả đúng:** balo cũ có 3 material, trần prototype D-079 là 2. Trần tam giác tối đa 3.000, texture edge 1024 và file 10 MiB giữ nguyên. Không nới ngưỡng để cho mẫu qua; đây không phải asset Tripo mới. Validator còn báo thiếu nghiệm thu G1/G3/asset/visual, người duyệt, ngày tạo, xác minh provenance, placement/gameplay/collision/nav, animated bounds và VRAM. Không lấy test kỹ thuật đạt thay nghiệm thu này.

## Sửa phát hiện khi đối chiếu

Lượt đầu full test **13:14:57–13:35:08: 745/0, exit 0**; check **13:35:14–13:42:12: 344 script, 0 error, exit 0**. Đối chiếu số đo trong lúc check phát hiện loader bỏ sót `extends/preload` GDScript, khiến importer cha và shader include chưa có hash. Đã bổ sung quét bảo thủ các literal `res://` trong source; thêm assertion với `kit_import.gd`, shader cutout và shader include, cùng fixture Python bắt hash cũ của importer cha/include. Không chỉnh asset hoặc importer B.

Probe kiểm riêng sau sửa đạt **5/0**, rồi chạy lại **toàn bộ test → check** cho diff cuối như bảng trên. Log lượt đầu giữ riêng, không dùng nó thay kết quả cuối. Phép quét literal có thể gồm comment/nhánh chưa chạy; dependency ghép động hoặc đường tương đối chưa được loader trả về vẫn cần kiểm riêng. Chi tiết hợp đồng và hạn chế tại [G1_SCHEMA.md](../G1_SCHEMA.md).

## Bàn giao và phần chờ

Schema `t210-g1-static-1` giữ ID/mapping B và tách generation provider/channel/wallet; Studio thủ công không cần API key/task. Công cụ generic `asset_dry_run.py` giữ fixture G0 qua wrapper Meshy, không có transport, không đọc key/gọi mạng/tiêu credit. Credit và nhãn license trong fixture Tripo chỉ là dữ liệu giả, không là ngân sách/quyền được cấp. Paid vẫn chịu allowlist CC0/CC-BY.

Astra review schema/path/default/điều kiện đạo cụ tĩnh; B xác nhận mapping và tự chuyển manifest sau khi ghép. G2 cần asset thật cùng hồ sơ license/ví/trần chi/operator. Chưa kiểm render/FPS/bot, visual/chơi tay mới, tài khoản/API Tripo thật hoặc downloader. Không sửa core/settings, logic/collision/nav/timing/luật/lời thoại, STATUS/DECISIONS/Review; không mở PR.

**C đã nhả lượt Godot lúc 14:09:59**, xác nhận không còn tiến trình Godot sau full check. File bus do import tự serialize được trả lại bản gốc, không thuộc diff bàn giao. Log cục bộ: `build/graphics/g1-final-full-test.log`, `g1-final-full-check.log`, `g1-final-asset-report.json`, `g1-offline-tests.log`; lượt đầu `g1-full-test.log`, `g1-full-check.log`; kiểm riêng `g1-probe-recheck.log`. Báo cáo G0 được giữ nguyên.
