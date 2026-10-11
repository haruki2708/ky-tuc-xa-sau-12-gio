# T-210 — Công cụ asset/Tripo AI và QA đồ họa

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](../handoff/T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** chuyển sang **Tripo AI**; giữ G0 đã ghép và task/nhánh hiện có. Đọc [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Handoff/checklist G0 bên dưới là lịch sử; chưa có Tripo asset hoặc client live.

- Lane: C | Trạng thái: **G0 đã review/ghép (D-079); G1 tiếp tục, toàn gói chưa done** | Agent: lane C
- Nhánh: `lane-c/T-210-graphics-asset-qa`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập; schema G1 phối hợp web/B, cảnh mẫu G2 từ B.
- Hạn đề xuất: phiên đầu có công cụ kiểm/dry-run dùng được; báo cáo hình ảnh/hiệu năng theo mốc sau.

## Bối cảnh
Mốc giao G0: 722 passed; main sau ghép D-079: 743 passed, check 0. Hình mới cần kiểm transform/marker/triangles/material/texture và tương tác; test logic không chứng minh hình ảnh đẹp/FPS. D-080 chọn Tripo AI; chưa xác nhận gói/đã mua hoặc cấp trần credit. B sở hữu dữ liệu asset, C sở hữu công cụ đọc/kiểm và quy trình tải.

## Việc
1. **G0:** tạo công cụ và README dưới `tools/graphics/`; schema manifest đề xuất gồm asset ID, nguồn/license/AI, kích thước/pivot, file, task ID, budget, số đo, tình trạng duyệt. Cung cấp mẫu nhỏ trong tools; không sửa manifest production B. Gửi schema cho G1 trước khi dùng làm chuẩn bắt buộc.
2. Công cụ kiểm đọc file thật: file tồn tại/định dạng, provenance bắt buộc, giới hạn file 10 MB, số tam giác sau import/triangulate, material/texture, scale và marker theo contract. Không gán PASS khi chưa đo được; thống kê cái nào unavailable. Giữ phân biệt cảnh prototype và production.
3. Chuẩn bị schema/QA cho **Tripo Studio thủ công** trước; client **Tripo API** là phương án riêng, **dry-run mặc định**. Studio và API dùng ví riêng; C đối chiếu v3/model/giá chính thức trước triển khai transport. Giữ fixture G0 cũ và chuyển công cụ sang tên/cấu trúc không gắn Meshy; chưa tự nhận hỗ trợ Tripo live. Không cài plugin/MCP, không gửi tác vụ trả phí. `TRIPO_API_KEY` là tên biến dự kiến của dự án; chỉ đọc khi thật sự chạy adapter Tripo được giao; không log secret. Trước submit: ước tính công đoạn/trần, kiểm số dư; lưu task ID và trạng thái để resume; timeout không tự POST trùng. Giới hạn số retry/lượt và có sổ credit, cách kiểm chênh số dư/consumed_credits.
4. Tải vào thư mục staging ngoài nguồn, kiểm file/đường dẫn và giữ metadata; artifact có thể là link tạm nên tải đủ file đã duyệt và hướng dẫn lưu bền vững. Không tự publish asset, không đặt file vào cảnh production; B xử lý và nhập.
5. **G1/G2:** chuẩn bị góc chụp cố định, bảng hồi quy bốn chương và kiểm tia ngắm/đường đi trên scene thật. Kiểm công cụ bằng fixture cả thành công/thất bại/timeout/duplicate, không cần trả tiền để test client.
6. **Khi chủ dự án cho phép riêng:** đo GPU thật 1080p Medium theo cấu hình chốt, ghi CPU/GPU/VRAM, mean/p95/max frame time, bộ nhớ và điều kiện. Giữ phép so 720p cũ tách riêng. Xem 0/20/40 xác khi công cụ/cảnh hỗ trợ, không tự chạy bot chương 3/4.

## Được phép sửa
`tools/` trừ `godot-path.ps1`, `game/scripts/debug/`, `game/tests/tools/`, `game/tests/smoke/`; Handoff/checklist card. Ưu tiên `tools/graphics/`, không viết lại test runner/launcher hiện có nếu không cần. Không sửa asset/scene B, core, project.godot, test levels, STATUS/DECISIONS. Log/ảnh lớn cục bộ ở build; kết quả cần bàn giao viết gọn trong Handoff hoặc reports vùng tools.

## Test và bằng chứng
- Dry-run không gọi mạng/tạo tác vụ; secret không xuất hiện trong log/report; sai license/path hoặc vượt budget bị phát hiện. Fixture task đã tạo nhưng timeout phải resume, không tự tính hai lần. Không in API key để kiểm biến môi trường.
- Model mẫu hợp lệ/sai bounds/thiếu marker cho thấy công cụ bắt đúng; kiểm tam giác thật thay vì số tự khai trong manifest. Tình huống chưa được hỗ trợ ghi rõ.
- Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1`. Handoff ghi chưa benchmark/chưa dùng API trả phí nếu chưa được giao; không lấy fixture làm bằng chứng cảnh game đã đạt.

## Checklist hoàn thành
- [x] Schema đề xuất và kiểm asset thật (G0; chuẩn chung chờ G1)
- [x] Meshy dry-run/resume/budget/log không lộ secret (fixture offline; chưa có API live)
- [x] Fixture lỗi và test có ý nghĩa
- [x] Góc chụp/hồi quy sẵn sàng; phần benchmark tách chờ quyền chạy (kế hoạch, chưa chụp/chơi tay visual mới)
- [x] Full test/check PASS, ghi rõ phần đã đo/chưa đo

## Handoff (agent điền)
### Sửa R1–R4 sau D-082 — Lane C, 11/10/2026

- Đầu mối hiện tại **Claude Code (Opus 5.5)**, thay Astra. Workspace sạch trước fetch; đã rebase lên `origin/main` `1b63c61` có D-082. Nội dung `7af1075` giữ qua `7255b40` (patch tương đương); không làm lại probe `b86a77d`/G0, không sửa manifest B hoặc ngưỡng production.
- Bằng chứng và cách tái kiểm: `tools/graphics/reports/r1r4_validation.md`, `r1r4_fixtures.json`; fixture `tools/graphics/test_review_r1r4.py` chạy trực tiếp trên bản cũ `7af1075` để lưu trước sửa, rồi chạy cùng ca trên bản sửa. INCOMPLETE cũ không được gọi là PASS; “lọt” là thiếu lỗi kỹ thuật/lý do dependency cụ thể.

| Review | Sửa và fixture | Trước → sau |
|---|---|---|
| R1 | Unit scale với epsilon 0,00001 riêng; tolerance balo [0; 0,001] m. `r1_double_root_and_dimensions`, `r1_tolerance_100_and_size_99`, `r1_scale_cannot_borrow_position_tolerance` | Lọt (`errors=[]`) → **FAIL**, đúng field |
| R2 | Profile D-079 độc lập với manifest, chặn tự tăng 100001/999/8192; giữ budget/basis riêng cho asset khác chờ contract. `r2_self_declared_inflated_limits` và ba ca `r2_inflated_*` | Lọt → **FAIL** budget |
| R3 | Tái dựng đường cần hash từ source/import/scene; kiểm riêng importer/material/texture/include/wrapper. `r3_removed_importer_then_changed`, năm `r3_missing_*`, `r3_opaque_cache_closure` | INCOMPLETE không nêu thiếu → **INCOMPLETE có đúng tên dependency**; năm `r3_stale_*` tiếp tục FAIL |
| R4 | Thực thi schema type/const/range cho mọi provider; parameters là object JSON hữu hạn. `r4_rights_evidence_42_*`, `r4_parameters_array_*`, `r4_schema_range`, `r4_schema_nested_parameters` | Lọt → **FAIL sạch**, đúng đường field |

- **RESULT offline: 82 tests OK, exit 0**: 42 test cũ còn đạt + **33 fixture âm tính/7 fixture dương tính mới**. Các fixture vốn đã bắt được lỗi ở bản cũ vẫn giữ FAIL, không nhận là lỗi mới. Log `build/graphics/r1r4-tests.log`. Mẫu tĩnh dương tính không có lỗi kỹ thuật, vẫn INCOMPLETE ở cổng duyệt thủ công; không suy thành nghiệm thu production.
- Nhận xác nhận bàn giao lượt từ **Opus 5.5** qua chủ dự án. **RESULT Windows R1–R4, 11/10 UTC+7:** `pwsh tools/test.ps1` **22:28:20–22:48:31: RESULT: 746 passed, 0 failed**, exit 0 → `pwsh tools/check.ps1` **22:48:50–22:55:41: RESULT: check 0 error(s)**, **345 script parse PASS**, exit 0. APPDATA import/check tách riêng trong build của C. **C đã nhả lượt Godot lúc 22:55:41**, xác nhận không còn tiến trình Godot. Không render/FPS/bot/Tripo hoặc cài MCP/plugin. Log `build/graphics/r1r4-full-test.log`, `r1r4-full-check.log`.
- Validator mẫu với probe trong full test mới: **FAIL, exit 1**, lỗi duy nhất `material budget exceeded` (balo cũ 3 > 2 material); không nới trần. Dependency scene/cache chưa đủ được liệt kê cụ thể, chưa nhận GLB probe là đã kiểm wrapper/scene. Không có diff game/âm thanh trong gói sửa.
- Gói sửa `T-210: fix R1R4 schema validation and dependency evidence`, nhánh `lane-c/T-210-graphics-asset-qa`; hash/push đối chiếu Git và thông báo cuối. Giữ quan hệ lịch sử với `7af1075` sau rebase để push thường, không force-push; không push main/mở PR. **Không còn chặn kiểm/bàn giao R1–R4.** Câu hỏi contract mới: không có; áp đúng D-079/D-081. Yêu cầu ngoài phạm vi: Claude review/ghép schema rồi B chuyển manifest; closure động/cache nhị phân/wrapper và G2 asset/license/ví/ngân sách/operator còn cần chứng cứ riêng. T-210 chưa done toàn gói.

Checklist R1–R4:
- [x] Tái hiện ca review trước sửa, lưu kết quả thực.
- [x] Đồng bộ schema/validator/fixture/tài liệu, 82 test offline đạt.
- [x] Nhận lượt Windows, chạy tuần tự full test/check và ghi RESULT thực; đã nhả lượt.
- [x] Đủ điều kiện bàn giao commit/push gói sửa theo kết quả Windows cuối.
- [ ] Integrator review/ghép R1–R4 trước khi B dùng schema.

### G1 theo D-079/D-080 — 11/10/2026, công cụ đã kiểm Windows; chờ review hợp đồng

- Đã kiểm workspace sạch, fetch và rebase an toàn nhánh hiện có lên `origin/main` **`acbf771` (D-080)**. G0 `c434343` đã nằm trong main, không làm lại, không đổi task/nhánh. Đầu mối core/T-207 hiện là **Astra điều phối**, theo chỉ định mới của chủ dự án.
- Đầu ra cho Astra/B review: `tools/graphics/manifest.schema.json` (`t210-g1-static-1`), `sample_g1_manifest.json`, `manifest_g1.py`, `G1_SCHEMA.md`. Giữ ID `room407_backpack`; mapping trực tiếp với `art_source/graphics_upgrade/measured_assets.json`: local size/min, scene/node và placement riêng. Không sửa manifest/scene B. Schema là đề xuất cần review/ghép trước khi B chuyển dữ liệu.
- Probe sửa sang **selected-root-local**, bỏ transform đặt root khỏi bounds/marker; vẫn báo riêng `root_placement/root_scale`. Fixture root dịch/xoay/scale không identity, mesh ẩn `rest/include_hidden` và ba asset thật đều đạt trên Godot. Hash source/import config/output cache/importer/resource dependency, shader/texture, project và mã probe; validator phân biệt report thiếu chứng cứ (**INCOMPLETE**) và file/hash/policy sai (**FAIL**). Khi đối chiếu lượt đầu, phát hiện loader bỏ sót importer cha/preload/include; đã bổ sung quét literal `res://`, assertion asset thật và fixture hash cũ, rồi chạy lại toàn bộ test → check. Hạn chế đường động/tương đối ghi tại `G1_SCHEMA.md`.
- D-079 balo prototype: tối đa 3.000 tris (`exclusive=3001`), 2 material, map 1024²; giữ 10 MiB/file. Số đo cuối balo cũ: **96 tris, 3 material, 3 texture 128²**, size **0,29000 × 0,45640 × 0,30270 m**, min **(-0,14500; 0,01000; -0,13250)**; khớp B trong dung sai mẫu 0,0001 m. Validator thực **FAIL, exit 1**, lỗi duy nhất `material budget exceeded`; không nới trần/sửa nguồn để qua. Đây là asset chưa đạt trần mới, không phải bộ test thất bại. Trần này không thay budget/test production hoặc áp cho nhân vật.
- `asset_dry_run.py` là công cụ generic offline, fingerprint/ledger tách provider/channel/wallet; fixture Tripo Studio tại `tripo_studio_request.json` chỉ dùng số giả 1 credit, không phải giá/ngân sách/quyền license. `meshy_dry_run.py` giữ lối gọi tương thích G0; test lỗi cũ giữ nguyên. Ledger thiếu phạm vi ví cần đối soát, không tự đổi ID/hash/resubmit. Không có transport, plugin/MCP, gọi dịch vụ hoặc đọc key.
- Metadata generation tách `self_authored/local`, `tripo/studio`, `tripo/api`, gói khi tạo, version, model/task ID, quyền Paid và file bằng chứng. Studio thủ công không bắt task API hoặc key; ví Studio/API không dùng chung. Paid không miễn kiểm allowlist CC0/CC-BY. Mẫu balo vẫn giữ nguồn CC0/Codex/Blender cũ, chỉ `planned_route` hướng tới Tripo; không đổi tác giả lịch sử.
- **RESULT offline: 42 tests OK, exit 0** (`python -B -m unittest discover -s tools/graphics -p test_offline.py -v`); gồm toàn bộ 28 ca G0 và 14 ca mới về hash dependency/import, root policy, trần prototype, mapping B, Paid/Studio/API/đối soát và ví riêng. Log cục bộ `build/graphics/g1-offline-tests.log`. Validator mẫu chưa có số đo mới trả **INCOMPLETE, exit 2, errors=[]**; CLI dry-run báo 0 network call. `git diff --check` sạch.
- **RESULT full Windows cuối, 11/10 UTC+7:** `pwsh tools/test.ps1` **13:42:32–14:02:51: 745 passed, 0 failed, exit 0** → `pwsh tools/check.ps1` **14:02:59–14:09:58: 0 error(s), 344 script parse PASS, exit 0**. Chủ dự án đã bàn giao lượt, không xin lại. **C đã nhả lượt Godot lúc 14:09:59**, xác nhận không còn tiến trình Godot. Ca navigation tầng 4 từng lỗi Linux đạt ở lượt Windows này; không nhận đã sửa lỗi Linux. Chưa render/FPS/bot, chơi tay visual mới hoặc test tài khoản Tripo thật.
- Bằng chứng: `tools/graphics/reports/g1_validation.md`, `g1_probe.json` (cửa/giường/balo: **15/21/19 file hash**, không dependency thiếu trong tập phát hiện). Log cục bộ `build/graphics/g1-final-full-test.log`, `g1-final-full-check.log`, `g1-final-asset-report.json`; giữ log lượt đầu và báo cáo G0 riêng. Lượt đầu 745/0 và check 344/0 không thay kết quả cuối sau sửa dependency. File bus do import tự serialize đã trả lại bản gốc, không bàn giao thay đổi âm thanh.
- Yêu cầu ngoài phạm vi gửi **Astra (T-207)**: review schema/path/default + điều kiện nghiệm thu đạo cụ tĩnh, tách phần rig/settings/chuông pending; gửi B xác nhận mapping/root_class/node path và chuyển manifest sau khi schema được ghép. B chuẩn hóa Blender/import asset thật khi có G1/ngân sách/license; C không sửa core/STATUS/DECISIONS/Review hoặc nguồn B.
- Gói bàn giao chia commit `T-210: fix root-local asset probe and dependency evidence` và `T-210: add Tripo static asset schema and offline QA handoff`, nhánh `lane-c/T-210-graphics-asset-qa`; hash/push đối chiếu Git và thông báo cuối. Không push main, không mở PR. **Không còn chặn kiểm Windows của phần công cụ này.** G1 hợp đồng chờ Astra/B review/ghép; G2 asset thật/license/ví/ngân sách và operator chưa đủ. Toàn gói T-210 chưa done.

Checklist G1 (không dùng checklist G0 bên dưới thay nghiệm thu mới):
- [x] Schema đạo cụ tĩnh + mapping B gửi Astra review; kiểm provider/channel/wallet và chứng cứ Paid.
- [x] Generic dry-run, giữ fixture G0; 42 fixture offline PASS.
- [x] Viết sửa root-local, hash dependency/import và fixture non-identity/hidden.
- [x] Chạy các fixture/probe mới trên Godot, đối chiếu balo B thực tế; ghi FAIL material đúng ngưỡng.
- [x] Full Windows test/check cho diff G1 đạt, đã nhả lượt; đủ điều kiện commit/push gói công cụ.
- [ ] Astra/B review và ghép hợp đồng G1; B chuyển manifest theo schema được nhận.
- [ ] G2 asset thật, license/ví/ngân sách/operator và nghiệm thu visual/scene theo điều kiện được giao.

### G0 bàn giao review — 11/10/2026, Lane C; G1/G2 chưa mở

- Nhánh `lane-c/T-210-graphics-asset-qa`, tạo từ `origin/main` `e3ed54a` có D-077/D-078; workspace ban đầu sạch. Chỉ làm trong `D:\GAME_WORK\lane-c`. Chưa coi toàn bộ T-210 done.
- Đầu ra để web/integrator chốt G1: `tools/graphics/README.md` (bảng schema/hợp đồng đề xuất), `sample_manifest.json` (cửa kit CC0, nguồn `art_source/CREDITS.md`), `asset_qa.py` (path/provenance/license/10 MiB/hash/bounds/scale/marker/budget), `meshy_dry_run.py` + `sample_request.json` (dự toán và ledger fixture có persist/resume), `qa_plan.md` (3 góc chụp lấy từ T-203 và ma trận bốn chương).
- Probe `game/scripts/debug/graphics_asset_probe.gd` đo mesh **sau import Godot**, tam giác qua `Mesh.get_faces`, bounds/scale/node/material/texture; không thêm model vào SceneTree. **Ba test GDScript PASS**: geometry transform/marker, geometry thiếu, đo cửa và giường kit thật. Số đo lưu `tools/graphics/reports/g0_probe.json`: cửa **120 tam giác / 2 material / 2 texture**, kích thước **0,88 × 2,08 × 0,10 m**; giường **372 / 4 / 4**, kích thước **0,90 × 1,70 × 2,00 m**. Đây là rest pose asset cũ, chưa là bằng chứng rig/visual mới.
- Kết quả offline: `python -B -m unittest discover -s tools/graphics -p test_offline.py -v` **28/28 PASS**, exit 0. Fixture gồm license Private/path thoát repo/LFS pointer/file >10 MiB/bounds sai/marker thiếu/hash cũ/vượt trần/số dư thiếu/timeout có hoặc không có task ID/duplicate/failed có phí/chênh số dư/giới hạn poll/không mạng/không đọc key, persist qua file/không reset ledger/khóa operator thứ hai. File cửa thật **10.848 byte**, hash lưu trong báo cáo; checker dùng log full test trả **INCOMPLETE, exit 2, errors=[]**: bounds/scale/triangle budget khớp, còn duyệt G1/asset/nguồn thủ công, ngày tạo, animation bounds, VRAM và hồi quy visual mới. Kiểm kê filesystem: **38 GLB**, tổng **617.992 byte**, lớn nhất **63.872 byte**, không GLB nào vượt 10 MiB; không suy thành RAM/VRAM sau import.
- Bổ sung trong lúc chờ lượt: validator bắt metadata/URI sai kiểu, report sai cấu trúc, số đo NaN/Infinity/âm/phân số và budget sai ngay cả khi chưa có measurement; số đo thiếu vẫn là unavailable. Năm fixture mới PASS, không dùng Godot.
- Meshy **offline-only**, 0 gọi mạng/0 credit; số 10+20, trần 60 trong fixture là dữ liệu giả, không là giá hoặc ngân sách được cấp. Ledger dùng task ID `fixture-*`, có khóa file/ghi atomic, timeout không POST lại; chưa là bằng chứng client API thật. Chưa triển khai transport/download thật vì G1/G2 chưa mở; README có quy trình staging ngoài nguồn và lưu bền vững cho B.
- Điều phối Windows: nhận lượt **C sau B** sau thông báo B đã xong. Ngày 11/10 (UTC+7), chạy tuần tự **02:27:19–02:47:46** `pwsh tools/test.ps1` → **RESULT: 725 passed, 0 failed, exit 0**; **02:47:50–02:56:03** `pwsh tools/check.ps1` → **RESULT: check 0 error(s), 336 script parse PASS, exit 0**. **C đã nhả lượt Godot**, xác nhận không còn tiến trình Godot sau check. Chỉ lấy probe trong full test, không mở thêm lượt render/probe. Chưa render/FPS/bot, chơi tay visual mới, nghe âm thanh hoặc dùng API trả phí.
- Bằng chứng/lệnh tái kiểm: `tools/graphics/reports/g0_validation.md`; log đầy đủ cục bộ `build/graphics/full-test.log`, `full-check.log`, `offline-tests.log`, `asset-report.json`. File bus do import tự serialize đã trả về đúng bản gốc; không đưa thay đổi âm thanh ngoài phạm vi vào commit.
- Cần G1: web/B thống nhất ID/schema/vị trí manifest, hệ local model/mét/pivot/marker/tolerance; budget prototype và production riêng, hash dependency sau import; A/B cung cấp contract và scene pilot. Không tự thêm API/settings hoặc nới test production. G2 cần tài khoản/key/ngân sách/license và operator được chỉ định; FPS cần quyền riêng.
- Yêu cầu ngoài phạm vi: integrator/web review schema và bổ sung quyết định vào hợp đồng G1; B sở hữu dữ liệu/CREDITS/asset bền vững. C không sửa các vùng này, STATUS/DECISIONS/Review, logic/collision/nav/timing/luật/lời thoại.
- Gói bàn giao: commit `T-210: add offline graphics asset QA and Meshy dry-run tools`, nhánh `lane-c/T-210-graphics-asset-qa`; hash/push đối chiếu Git và thông báo bàn giao cuối phiên. Không push main, không mở PR. **G0 không còn chặn; G1/G2, client/download live, kiểm scene mới và benchmark còn chờ các điều kiện bên trên. T-210 chưa done toàn gói.**

Checklist riêng G0 (không thay nghiệm thu toàn gói):
- [x] Bảng schema đề xuất, manifest mẫu và validator đọc file thật.
- [x] Dry-run offline + ledger fixture persist/resume/budget, 28 fixture PASS.
- [x] Góc chụp tham chiếu và ma trận hồi quy bốn chương, benchmark tách chờ quyền.
- [x] Probe asset thật sau import và ba test GDScript.
- [x] Full Windows test/check PASS, đủ điều kiện bàn giao commit G0.

## Review (integrator)

### 11/10/2026 — Astra, D-079

- Nhận **G0** từ lane C, commit `c434343`; ghép cùng năm nhánh còn lại. **Chưa đánh dấu toàn bộ T-210 done.**
- Nhận probe/validator/ledger offline; integrator chạy lại 28/28 fixture Python đạt. Chưa có API live. G1 cần thống nhất hệ root-local: probe hiện nhân cả transform root, mẫu identity chưa bắt sai khác với B. Thêm fixture root dịch/xoay/scale, dependency/import hash; schema phải đọc dữ liệu B sau mapping. INCOMPLETE không phải PASS nghiệm thu asset.
- Phạm vi diff đạt; không nới test, không đổi gameplay/default. Không sửa code lane trong lượt review này.
- Full Windows test/check bản ghép và kiểm `--t202-integration` là điều kiện trước commit. Kết quả thực/thời điểm/log ở message commit `D-079`; không dùng số test lane riêng thay kết quả tích hợp.
- Đọc [báo cáo chung và yêu cầu G1](../handoff/REVIEW_G0_2026-10-11.md), làm phần Review của lane trên nhánh hiện có sau fetch/rebase; không tự dùng contract G0 như API production đã chốt. Chưa chạy Meshy trả phí hoặc FPS/bot.

### 11/10/2026 — cập nhật D-080, Astra

- Nhà cung cấp hiện hành: **Tripo AI**. Tiếp tục phần việc trong [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md); không làm lại G0 hoặc đổi source/credits lịch sử.
- Tripo Studio/API tách ví; đường thủ công không cần client API. B/C cập nhật brief/metadata/QA đúng dịch vụ; A/D/F/web giữ ràng buộc gameplay đã review. Chưa cấp ngân sách/ngoại lệ license hoặc triển khai API live.

### 11/10/2026 — D-081, đổi đầu mối core

Astra làm thay Claude web ở T-207; gửi yêu cầu core/contract về Astra. Đọc contract G1 cập nhật và [bảng việc từng lane](../handoff/T207_G1_ASTRA_2026-10-11.md), tiếp tục task/nhánh hiện có. Giữ lịch sử G0; không sửa file lane khác hoặc coi quy ước mới là bằng chứng validator/asset đã đạt.

### 11/10/2026 — Astra, D-082, review tiếp G1

**Nhận một phần:** ghép `b86a77d` (probe root-local, hash và test Godot); **chưa ghép `7af1075`** (schema/validator/dry-run/report). Đã đọc Handoff trên nhánh C và chạy lại 42 fixture trên bản sao, đều đạt; ca review bổ sung vẫn bỏ sót unit scale/dung sai, trần balo, dependency bị bỏ và type rights_evidence. Chi tiết/tái hiện/yêu cầu sửa **R1–R4** tại [Review D-082](../handoff/REVIEW_G1_2026-10-11.md). Giữ nhánh và hai commit, rebase an toàn D-082 rồi sửa phần còn lại; không làm lại probe/G0, không sửa manifest B. Main chưa có schema G1; B chưa được chuyển dữ liệu. Full test/check bản ghép ghi trong commit integrator, không lấy 745/0 của C thay. T-210 chưa done.

Full test/check sau cập nhật là điều kiện commit/push; kết quả, giờ và log ở message D-082. Các phần runtime prototype/QA được nhận không đổi cảnh chơi mặc định.

### 11/10/2026 — Claude (integrator, Opus 5.5), D-083: **nhận phần sửa R1–R4, đã ghép**
- Ghép nhánh tới `d91606e` (gồm `7255b40` rebase của `7af1075`, merge giữ lịch sử `35c679f`). Phạm vi đúng: chỉ `tools/graphics/` và card này.
- Kiểm độc lập bằng script riêng trên bản sao nhánh (không dùng fixture C): R1 scale [2,2,2] và 1,0001 → FAIL; tolerance 100 m, 0,0011 m, kiểu chuỗi → FAIL. R2 trần tự khai 100001/999/8192 → FAIL; 3001 tam giác → FAIL. R3 gỡ hash importer rồi sửa → INCOMPLETE có đường cụ thể (với GLB giả: `dependency_closure_unproven:door.glb`; fixture GLB thật của C nêu đúng `game/importer.gd`); texture stale → FAIL. R4 `rights_evidence` 42 và `['ok',5]`, `parameters` [] và NaN → FAIL sạch, không crash. Mẫu cơ sở không lỗi kỹ thuật. `unittest`: 82 OK.
- **Còn lại cho lượt sau của C (không chặn ghép):** `asset_id` khác chữ hoa/thường (`Room407_Backpack`) không bị áp profile balo; nên ràng buộc mẫu ID chữ thường trong schema hoặc so sánh không phân biệt hoa thường.
- Full test/check của bản ghép ghi trong commit merge. T-210 **chưa done**: còn nghiệm thu G1 cùng manifest B, phần Tripo G2.
