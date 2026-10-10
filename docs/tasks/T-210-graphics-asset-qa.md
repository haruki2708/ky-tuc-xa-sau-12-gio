# T-210 — Công cụ asset/Meshy và QA đồ họa
- Lane: C | Trạng thái: **ready — G0** | Agent: lane C
- Nhánh: `lane-c/T-210-graphics-asset-qa`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập; schema G1 phối hợp web/B, cảnh mẫu G2 từ B.
- Hạn đề xuất: phiên đầu có công cụ kiểm/dry-run dùng được; báo cáo hình ảnh/hiệu năng theo mốc sau.

## Bối cảnh
Baseline main: 722 passed, check 0. Hình mới cần kiểm transform/marker/triangles/material/texture và tương tác; test logic không chứng minh hình ảnh đẹp/FPS. Meshy chưa mua/kết nối trong lúc giao card; không có quyền chi credit. B sở hữu dữ liệu asset, C sở hữu công cụ đọc/kiểm và quy trình tải.

## Việc
1. **G0:** tạo công cụ và README dưới `tools/graphics/`; schema manifest đề xuất gồm asset ID, nguồn/license/AI, kích thước/pivot, file, task ID, budget, số đo, tình trạng duyệt. Cung cấp mẫu nhỏ trong tools; không sửa manifest production B. Gửi schema cho G1 trước khi dùng làm chuẩn bắt buộc.
2. Công cụ kiểm đọc file thật: file tồn tại/định dạng, provenance bắt buộc, giới hạn file 10 MB, số tam giác sau import/triangulate, material/texture, scale và marker theo contract. Không gán PASS khi chưa đo được; thống kê cái nào unavailable. Giữ phân biệt cảnh prototype và production.
3. Chuẩn bị client Meshy bằng REST hoặc mô tả kết nối đã có, **dry-run mặc định**. Không cài plugin/MCP, không gửi tác vụ trả phí. Đọc `MESHY_API_KEY` khi thật sự chạy; không log secret. Trước submit: ước tính công đoạn/trần, kiểm số dư; lưu task ID và trạng thái để resume; timeout không tự POST trùng. Giới hạn số retry/lượt và có sổ credit, cách kiểm chênh số dư/consumed_credits.
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
Chưa review triển khai.
