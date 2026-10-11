# Số đo G0 — T-209

> **D-080 ngày 11/10:** nhà cung cấp mới là **Tripo AI**; đọc [hướng chuyển đổi](../../docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Nội dung G0 dưới đây ghi công cụ/kết quả trước khi đổi provider; không áp dụng giá/quyền/API Meshy sang Tripo. Studio thủ công không cần key; API dùng ví riêng. Chưa có Tripo asset hoặc transport live.

Nguồn scene ở `e3ed54a`. `measure_assets.gd` đo các PackedScene ngoài cây gameplay bằng Godot 4.7.2; RESULT: graphics inventory 13 assets measured PASS. Báo cáo máy: [measured_assets.json](measured_assets.json).

| ID | Bounds cục bộ (m) | Tam giác gộp | Material riêng |
|---|---|---:|---:|
| room407_floor | 8 × 0.2 × 7 | 12 | 1 |
| room407_wall | 0.2 × 3 × 7 | 12 | 1 |
| room407_bunk_a | 0.9 × 1.7 × 2 | 7740 | 6 |
| room407_bunk_b | 0.9 × 1.7 × 2 | 4536 | 7 |
| room407_locker | 0.76 × 1.77 × 0.56 | 228 | 3 |
| room407_desk | 1.5 × 0.76 × 0.65 | 132 | 2 |
| room407_fan | 1.02379 × 0.62 × 1.18217 | 180 | 3 |
| room407_backpack | 0.29 × 0.45636 × 0.30274 | 96 | 3 |
| room407_cloth | 0.8 × 0.065 × 1.875 | 192 | 2 |
| door407_leaf | 0.88 × 2.08 × 0.1 | 120 | 2 |
| corridor_floor | 44 × 0.2 × 4 | 12 | 1 |
| extinguisher_body | 0.2 × 0.55 × 0.2 | 48 | 1 |
| extinguisher_handle | 0.17 × 0.055 × 0.07 | 12 | 1 |

**Cách đọc:** số gộp gồm mọi MeshInstance3D dưới node, cả mùng/capsule/biến thể ẩn. Vì vậy 7.740/4.536 tam giác của hai cụm giường không phải số của một model GLB; không so trực tiếp với trần PS1 1.500 tam giác/model hoặc nới test production. Chưa loại đối tượng ẩn theo trạng thái chương, chưa đo draw call hay VRAM.

Bounds lấy trong hệ cục bộ root mục kiểm kê, trước khi áp transform của root; vị trí cộng dồn, scale, rotation và kích thước texture albedo nằm trong JSON. Đây là số đo serialized/off-tree: vật liệu sàn/tường do room407.gd gán trong _ready không được tính vào danh sách texture của probe. Fixture khôi phục riêng ba binding này khi render.

Balo hiện hành chỉ 96 tam giác, bounds 0.29 × 0.45636 × 0.30274 m. Đây là mẫu đề xuất cho Tripo từ D-080 sau khi được cấp quyền; không có GLB mới hoặc tác vụ Meshy nào trong G0.

Pilot thêm bốn vật liệu dùng 12 map 256², tổng file PNG 540.202 byte; không thêm mesh. Chưa tuyên bố budget gần chân thực đạt, chưa đo bộ nhớ GPU/FPS. Cần C/web thống nhất phép đếm surface/material và biến thể ở G1.

Nút báo cháy và chuông không có mục đo PackedScene: xem căn cứ runtime trong manifest. Nút có hộp .22 × .28 × .06 m trong core; chuông chưa có mesh/bounds, không gán số giả.
