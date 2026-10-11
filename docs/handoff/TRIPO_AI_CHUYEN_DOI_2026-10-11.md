# D-080 — chuyển kế hoạch asset từ Meshy sang Tripo AI

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

Ngày 11/10/2026, chủ dự án: “tôi sẽ đổi sang mua tripo AI thay vì meshy AI”. Nhà cung cấp hiện hành là **Tripo AI**. Chưa xác nhận gói cụ thể/đã mua; không kế thừa số credit, giá, API hoặc license Meshy. Đọc [nghiên cứu Tripo](../research/TRIPO_AI_2026-10-11.md).

## Phạm vi chuyển đổi

- Giữ T-207…T-212, nhánh và owner A/B/C/D/F + Claude web; G0 đã ghép ở `7dd9f8e`, không làm lại. G1 đạo cụ tĩnh vẫn ưu tiên balo, sau đó phòng 407/hành lang và nhân vật mẫu.
- **Studio trước:** chủ dự án thao tác web theo brief B, B nhận GLB/texture và chuẩn hóa. Không cần API key, plugin hoặc client live của C để thử theo đường thủ công khi G1/ngân sách/license đã đủ.
- **API riêng:** chỉ làm khi được giao phương án và ví API; không dùng credit Studio cho lời gọi API. C kiểm theo tài liệu Tripo hiện hành, key cục bộ, ledger riêng từng nhà cung cấp/ví. Không đổi tên client Meshy rồi coi là đã hỗ trợ Tripo.
- Trần kỹ thuật balo của D-079 giữ nguyên: tối đa 3.000 tris, 2 material, texture 1024², 10 MiB/file và LFS. World transform/collider/nav/logic không đổi; Blender chuẩn hóa visual theo số đo B.
- Quyền thương mại không tự đổi thành CC0/CC-BY; lưu hồ sơ nguồn/license trước nhập. Không cấp ngoại lệ hoặc ngân sách trong quyết định đổi nhà cung cấp.

## Mỗi lane tiếp tục việc gì

| Lane | Cập nhật trong gói đã giao |
|---|---|
| **B / T-209** | Dùng brief cho Tripo Studio, ghi rõ model version/thông số và credit thực theo ví Studio; giữ số đo/pivot/triangles. Nhận GLB/texture, lưu nguồn bền vững rồi sửa Blender và chụp Godot. Không tạo lại G0 hoặc đổi credits của asset cũ. |
| **C / T-210** | Tiếp tục schema/QA độc lập nhà cung cấp; thêm metadata phân biệt Tripo Studio/API, quyền Paid và cách đối soát. Fixture `meshy_dry_run.py` hiện vẫn là G0 offline cũ, không có transport Tripo. Chuyển tên/cấu trúc generic hoặc adapter Tripo trong G1, giữ fixture lỗi; không coi các số giả lập 10+20/60 là giá mới. API live chưa là dependency của nhập thủ công. |
| **A / T-208** | Dùng GLB/rig đã được B chuẩn hóa; tiếp tục adapter Head/pose/lifecycle. Không giả định rig Tripo tương thích NodePath cũ hoặc tự đổi AI/timing. |
| **D / T-211** | Tiếp tục settings/readability; chỉ thêm credits Tripo khi asset thật đã nhập và có hồ sơ. Không ghi Tripo là tác giả của asset CC0 cũ. |
| **F / T-212** | Tiếp tục marker/chuông, nhận attachment từ B/A. Đổi dịch vụ tạo 3D không yêu cầu tạo lại âm G0. |
| **Core / T-207 — Astra làm thay web từ D-081** | Tổng hợp contract G1; dữ liệu model/manifest ghi provider rõ, runtime không phụ thuộc API Tripo. Không giữ key/gọi dịch vụ trả phí trên cloud. |

## Prompt cập nhật chung

```text
Chủ dự án đã đổi từ Meshy sang Tripo AI theo D-080.
D-081: Astra làm thay web ở T-207; prompt này gửi A/B/C/D/F.
Đọc docs/handoff/T207_G1_ASTRA_2026-10-11.md; gửi yêu cầu core về Astra.
Tiếp tục task hiện có, không làm lại G0 hoặc đổi nhánh/task ID.
Fetch và rebase an toàn lên origin/main có D-081; giữ thay đổi cục bộ đang có.
Đọc docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md,
docs/handoff/REVIEW_G0_2026-10-11.md và Review card của bạn.
Ưu tiên quy trình Tripo Studio thủ công → GLB → Blender → Godot.
Studio và API dùng credit riêng. Chưa có ngân sách/key/license exception;
không tự tạo tác vụ trả phí hoặc cài plugin/MCP.
Làm đúng phần của lane, ghi Handoff/test/check và push nhánh khi đủ điều kiện.
Windows full test/check/render vẫn cần integrator bàn giao lượt.
```

Các Handoff/Review G0, nghiên cứu Meshy và log lịch sử được giữ để đối chiếu. Tên Meshy còn xuất hiện trong các phần đó không là hướng mua/chạy mới. Tài liệu hiện hành, phần việc tương lai và `planned_route` của manifest đã chuyển sang Tripo.

Đợt D-080 chỉ cập nhật tài liệu và nhãn định tuyến trong manifest; không sửa runtime, generator, script kiểm hay workspace lane. Full test/check sau cập nhật là điều kiện commit; kết quả và thời điểm ghi trong message commit D-080. Không export hoặc tạo asset trả phí. Số tiếp theo D-081, T-213.
