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
- [ ] Schema đề xuất và kiểm asset thật
- [ ] Meshy dry-run/resume/budget/log không lộ secret
- [ ] Fixture lỗi và test có ý nghĩa
- [ ] Góc chụp/hồi quy sẵn sàng; phần benchmark tách chờ quyền chạy
- [ ] Full test/check PASS, ghi rõ phần đã đo/chưa đo

## Handoff (agent điền)
Chưa bắt đầu. Chưa được giao API key/ngân sách hoặc quyền chạy FPS/bot.

## Review (integrator)
Chưa review triển khai.
