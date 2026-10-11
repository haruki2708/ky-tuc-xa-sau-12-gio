# T-209 — hồ sơ thử balo Tripo Studio sau D-080

Chuẩn bị tiếp từ G0 đã nhận, không tạo lại bộ ảnh/texture. Provider **Tripo AI**, đường ưu tiên **Studio thủ công → GLB → Blender → Godot**. Chưa có asset Tripo, tài khoản/gói xác nhận, ngân sách hoặc ngoại lệ license. Không tạo task, không gọi API; credit thực chi của Lane B trong đợt chuẩn bị: **0**. Studio/API là hai ví riêng; thuê bao Studio không cấp quyền chi API.

## Mẫu và giới hạn đã được review

ID giữ nguyên `room407_backpack`. Nguồn đo: `measured_assets.json`, scene `res://scenes/levels/floor4/floor4.tscn`, node `Room407/Details/Trung/Backpack`; transform khai báo tại `room407/room407_details.tscn`. D-079 cho phép chốt G1 đạo cụ tĩnh riêng, không bắt balo đợi rig/settings/chuông.

| Đại lượng | Giá trị đích |
|---|---|
| Bounds local root, mét | min `(-0.145, 0.01, -0.1325)`; size `(0.29, 0.45636, 0.30274)`; max `(0.145, 0.46636, 0.17024)` |
| Tâm bounds, không phải pivot | `(0, 0.23818, 0.01887)` |
| Root đặt trong thế giới | position `(33.78, 0.02, -4.52)`, yaw `+90°`, scale `(1,1,1)` |
| Trục Godot/glTF | +Y lên; X ngang, Z chiều sâu; root/pivot `(0,0,0)` nằm dưới min Y 0.01 m |
| Prototype | ≤3.000 tam giác; ≤2 material; mỗi map ≤1024×1024; mỗi file ≤10 MiB; nhị phân Git LFS |
| Số đo cũ để đối chiếu | 96 tam giác, 3 material; không lấy 3 material cũ làm quyền vượt trần mẫu mới |

Không suy ra mặt trước balo chỉ từ yaw: operator/B đối chiếu mặt túi với model hiện hành trong Blender/Godot rồi ghi basis đã chọn. Cần ảnh chính diện, sau, dưới và cạnh; chưa có asset mới nên chưa ký xác nhận hướng. Khoảng nhìn 0.7–2 m là khoảng review đề xuất, không phải số đo người chơi. Bảo toàn root đặt cảnh và đường đi; chỉ chuẩn hóa visual bên dưới root. Không thêm collider/nav/animation vào GLB.

## Các bước khi đủ điều kiện

1. Integrator ghép G1 đạo cụ tĩnh (brief + schema C + phép đo root-local + trần thử). Chủ dự án xác nhận ví **Studio**, một operator, trần credit và số lượt cụ thể; hồ sơ license được chấp nhận theo CC0/CC-BY hoặc quyết định ngoại lệ rõ ràng. Quyền thương mại Paid tự nó chưa đủ. Chưa đủ thì dừng trước Generate, không thử bằng Free để né kiểm license.
2. Operator dùng đoạn tiếng Anh trong `BRIEFS.md`. Ghi đúng model version, chế độ và các tùy chọn hiện trên UI; không tự chọn tên option/API giả định trong tài liệu này. Lưu prompt thực và bằng chứng quyền ảnh đầu vào nếu dùng ảnh. Ghi ước tính UI trước tạo; mọi bước tạo lại/remesh/texture riêng đều phải nằm trong trần đã giao. Không tự retry khi kết quả/credit chưa rõ.
3. Tải GLB và texture vào `build/graphics/staging/room407_backpack/<id-cuc-bo>/` trước khi nhập Godot. Ghi task/model ID nếu UI cung cấp, nếu không có ghi rõ `not exposed by Studio`; ID cục bộ không giả làm ID nhà cung cấp. Lưu file nguồn thật, SHA-256 và kích thước; không dùng URL tải hết hạn làm hồ sơ duy nhất, không lưu token/query ký số. Không nạp script/plugin đi kèm asset.
4. Sau khi hồ sơ quyền được review, lưu nguồn bền vững trong thư mục riêng `art_source/graphics_upgrade/tripo/room407_backpack/<id>/` (chỉ tạo khi có nguồn); giữ bản tải nguyên vẹn và hash. Nếu file vượt 10 MiB, không commit lách giới hạn: báo C/integrator chọn nơi lưu nguồn được phép và giữ hash/tham chiếu. Không sửa credits của asset CC0 cũ.
5. Blender: nhập GLB vào collection riêng; kiểm mesh rời, mặt sau/đáy, normals, UV và map PBR. Chọn hướng hình học bằng đối chiếu cũ; đổi đơn vị sang mét. Chuẩn hóa hình học để bounds sau export đạt min/size trên, giữ pivot gốc. Ưu tiên sửa hình/silhouette khi tỉ lệ lệch; không kéo scale root gameplay để vừa. Apply transform **visual**; không bake world position/yaw vào mesh. Blender dùng Z-up, glTF dùng Y-up: kiểm round-trip export, không xoay thêm +90° theo thói quen rồi áp yaw cảnh lần nữa.
6. Retopo/giảm tam giác có kiểm silhouette, sửa UV/normals, gom ≤2 material và map ≤1024². Đếm sau triangulate/export, không dựa số face quad trong Blender. Không bake bóng/đèn vào albedo. Lưu `.blend`, GLB và map hợp lệ qua LFS, từng file đạt giới hạn; ghi thời gian sửa và số liệu trước/sau.
7. Godot: nhập dưới thư mục prototype riêng, commit `.import`/`.uid`; không thay `Backpack` production. C đo lại root-local bằng schema/probe đã duyệt, tách transform đặt cảnh, hash cả dependency/import. Chụp renderer trung tính/game, cùng góc trước/sau theo lượt Windows; review mặt sau/đáy và silhouette tại khoảng nhìn đề xuất. G1/G2 không cho phép nới test production hoặc tự đo FPS.

## Hồ sơ operator cần bàn giao (chưa phải schema C)

| Nhóm | Dữ liệu thực phải có |
|---|---|
| Quyền chạy | provider `Tripo AI`, channel/wallet `Studio`, operator, gói thực, tham chiếu duyệt ngân sách/số lượt/license |
| Tác vụ | ngày/giờ/múi giờ, model version hiển thị, task/model ID hoặc lý do không có, prompt thực, input hash/quyền, thông số UI và export |
| Đối soát | credit UI dự tính, credit thực từng bước và tổng, số dư Studio trước/sau, bằng chứng đối soát; không ghi số ví API vào đây |
| Nguồn | tác giả/công cụ, điều khoản/license và ngày lưu bằng chứng, quyết định ngoại lệ nếu có; không đổi nhãn Paid thành CC0 |
| File và sửa | tên nguồn, SHA-256, bytes, đường lưu bền vững; bản Blender/export, thời gian sửa, bounds/tris/material/map đo lại |
| Nghiệm thu | kết quả QA C, ảnh Godot và renderer/camera, người review/quyết định; trường chưa có để pending/null với lý do |

Đây là danh sách đầu vào cho schema C, không tự nhận validator hiện tại đọc được. Ước tính credit, task ID, model version và license của **asset chưa tạo** đều chưa có; không điền số giả hoặc dùng số fixture Meshy lịch sử.
