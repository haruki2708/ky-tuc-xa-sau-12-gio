# Kế hoạch nâng đồ họa gần chân thực — D-076…D-081

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](../handoff/T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **11/10, D-080:** chủ dự án chọn **Tripo AI thay Meshy**. Đọc [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Giữ G0 đã ghép; Studio thủ công là hướng mẫu đầu, API dùng ví riêng. Chưa xác nhận gói đã mua/ngân sách.

> **11/10, D-079:** đã nhận G0 cả sáu lane. Đọc [Review và bước G1](../handoff/REVIEW_G0_2026-10-11.md) cùng STATUS mới; G1 đạo cụ tĩnh ưu tiên balo, rig/settings còn pending. Chưa có Tripo AI asset hoặc đổi bản chơi; kết quả kiểm bản ghép nằm trong commit D-079.

Ngày: 10/10/2026. Người lập: Astra, integrator tạm thời 10–11/10; người tiếp nhận: **Claude Code ở máy, Opus 5.5**. Chủ dự án vẫn là người dùng, quyết định mỹ thuật và chơi thử.

## 1. Đã được chủ dự án xác nhận

- Logic hiện tại về cơ bản đã ổn; ưu tiên tiếp theo là đồ họa. Hướng chọn: **gần chân thực, chấp nhận nặng và lâu hơn**.
- Máy tham chiếu: **RTX 3050 Laptop**; máy hiện tại báo 4 GB VRAM và khoảng 16 GB RAM. 1080p/60 FPS Medium là **mục tiêu thử**, chưa đo hoặc cam kết đạt.
- **D-080 ngày 11/10:** chủ dự án đổi sang **Tripo AI**. Chưa xác nhận tên gói, đã mua hoặc trần chi. Ưu tiên Studio thủ công cho mẫu balo; API là phương án riêng. Không áp dụng dự toán 100 credit Meshy cũ; chỉ lập trần Tripo sau khi biết đúng ví và công đoạn.
- Chủ dự án yêu cầu lập kế hoạch và giao sáu gói lớn, lưu Git để Opus tiếp nhận. **D-078:** lane E nghỉ vô thời hạn; tài khoản GPT Plus mới đảm nhiệm **lane F**, nhận toàn bộ vai trò âm thanh của E và T-212. Đội G0: **A, B, C, D, F và Claude web**. **D-081:** Astra tiếp nhận T-207 thay web; năm lane còn lại tiếp tục, Opus nhận lại core khi Astra bàn giao. Chủ dự án đã xác nhận hạn mức trước khi giao và trực tiếp chỉ định F thay E.
- Gói việc này chuẩn bị và thực hiện nâng hình ảnh theo từng mốc. Không suy ra chương 3–4 đã được chơi tay hoàn chỉnh, không mở giai đoạn nối game/lưu xuyên chương D-059.

## 2. Mục tiêu và giới hạn

Giữ luật chơi, độ khó Insane, lời thoại, thời điểm sự kiện, save/checkpoint, tọa độ thế giới và đường đi đã chốt. Thay mesh/material/ánh sáng và lớp chuyển đổi animation cần thiết. Nếu phát hiện lỗi logic, báo riêng cùng cách tái hiện, không trộn thành thay thiết kế trong task đồ họa.

Phân biệt **root gameplay ở tọa độ thế giới** với **transform cục bộ của model**. Chuẩn hóa model theo mét, hướng và pivot để vừa scene cũ. Visual mới không được che tia tương tác, làm collider lệch hình, cản đường hoặc dịch vị trí đầu/tay/nguồn âm quan trọng.

Đợt đầu là **phòng 407 + 10–15 m hành lang**, thêm một đạo cụ có tương tác và một nhân vật mẫu. Ưu tiên vật liệu, ánh sáng và tỉ lệ trước khi tăng số lượng model. Phòng/tầng 4 dùng chung bốn chương nên mọi thay đổi phải kiểm đủ bốn cảnh.

Toàn bộ game dự kiến 35–60 ngày công 3D/kỹ thuật; đây là ước lượng ban đầu, không phải hạn hai ngày của Astra. Lịch mới được cập nhật sau khi đo thời gian làm asset mẫu.

## 3. Các mốc bàn giao

| Mốc | Việc được làm | Điều kiện đi tiếp |
|---|---|---|
| **G0 — Chuẩn bị ngay** | Sáu lane khảo sát, kiểm kê, đề xuất hợp đồng, tạo fixture/công cụ cục bộ; dùng model đang có hoặc nguồn hợp lệ. | Handoff có đường dẫn cụ thể, số đo và đề xuất, không chỉ ý tưởng. Không cần Tripo AI để hoàn thành phần này. |
| **G1 — Chốt hợp đồng kỹ thuật** | Astra làm thay web, tổng hợp đầu ra A/B/C/D/F; integrator review node/API/manifest/settings, quyền sở hữu file và ngân sách thử. | Contract được ghép `main`, lane phụ thuộc rebase; phần chưa thống nhất được ghi rõ, không đoán. |
| **G2 — Thử Tripo AI và phòng mẫu** | Khi có tài khoản phù hợp + ngân sách + giấy phép rõ: một người vận hành tạo model, B chuẩn hóa và dựng cảnh, A nối visual, C kiểm, D/F phối hợp. | Mẫu trong Godot có ảnh cùng camera, test đạt; người dùng xem và chọn hướng. FPS cần được phép chạy riêng. |
| **G3 — Đưa mẫu vào cảnh chơi thật** | Thay từng nhóm nhỏ; tích hợp core theo contract, thử tương tác/đường đi/âm thanh. | Đạt chất lượng đã chọn, hồi quy bốn chương, dữ liệu hiệu năng khi được phép. Integrator mới duyệt chuyển mặc định. |
| **G4 — Mở rộng** | Nhà B → nhân vật → khuôn viên → thư viện/bệnh viện, bằng các đợt nhỏ trong card hoặc card con mới. | Mỗi đợt có ngân sách, phạm vi, bằng chứng và review; không thay toàn trường một lần. |

Hợp đồng là điểm đồng bộ, không là lý do để mọi lane ngồi chờ: A/B/C/D/F làm G0 độc lập, có thể dựng prototype trong phần file của mình. Những API mới cần phối hợp chỉ bắt đầu dùng chung sau G1.

## 4. Sáu gói việc đã phân công

| Task | Chủ trì | Làm ngay trong G0 | Phần lớn tiếp theo |
|---|---|---|---|
| [T-207](../tasks/T-207-graphics-core-contract.md) | **Core: Astra làm thay web (D-081)** | Lập bảng ràng buộc visual–logic, hợp đồng với A/B/C/D/F, danh sách chỗ core đang tự tạo hình. | Tích hợp model/âm thanh mới vào core theo hợp đồng, giữ hành vi; không tự làm asset B. |
| [T-208](../tasks/T-208-visual-gameplay-adapters.md) | **Lane A** | Kiểm root/collider/pose/marker và làm adapter mẫu với asset sẵn có. | Nối rig/animation mới, kiểm đồ tương tác và nhân vật; không đổi AI/độ khó. |
| [T-209](../tasks/T-209-realistic-art-pilot.md) | **Lane B** | Kiểm kê, bảng tham chiếu, kích thước/pivot; cảnh mẫu vật liệu/ánh sáng riêng. | Pipeline Tripo AI–Blender, phòng 407/hành lang, bộ nhân vật, các khu còn lại. |
| [T-210](../tasks/T-210-graphics-asset-qa.md) | **Lane C** | Kiểm asset/manifest và công cụ Tripo AI mặc định dry-run; chuẩn bị góc chụp/checklist. | Ghi credit, kiểm kết quả tải, hồi quy và báo cáo hiệu năng khi được phép. |
| [T-211](../tasks/T-211-graphics-settings-readability.md) | **Lane D** | Khảo sát menu/settings, độ sáng, UI/giấy/biển đọc được; đề xuất contract setting. | Áp dụng preset đã chốt, chuyển trải nghiệm cài đặt khỏi PS1, kiểm vi/en. |
| [T-212](../tasks/T-212-graphics-audio-anchors.md) | **Lane F** (tiếp nhận E) | Kiểm marker âm thanh và làm mẫu chuông báo cháy riêng, âm lượng nhỏ. | Gắn âm theo model/rig mới, kiểm tiếng đúng vật liệu và người dùng nghe thử. |

Các card là gói lớn có điểm dừng G0/G1/G2/G3. Mỗi điểm bàn giao có thể push một commit riêng để integrator review sớm; chưa xong phần sau thì **không ghi cả task done**. Nếu tách nhánh/card con, integrator cấp số T mới và ghi quan hệ; lane không tự chiếm số.

## 5. Hợp đồng và ranh giới file

- **Core T-207 — Astra làm thay web từ D-081** sở hữu `docs/design/graphics/INTEGRATION_CONTRACT.md`, `ASSET_BINDINGS.md` và các chỗ nối core trong card. Integrator chỉ cập nhật `docs/SETTINGS.md` khi backend/default/consumer đã đủ; việc tiếp nhận T-207 chưa mở quyền thêm key tùy ý.
- **A** sở hữu adapter ở `game/scripts/entity/`, logic tương tác trong vùng A và test `game/tests/player/`. **B** sở hữu scene model/rig, animation visual trong `game/scenes/levels/`, material/rendering và test levels. Hai lane không cùng sửa `campus/actor.gd`.
- **B** sở hữu dữ liệu asset và hồ sơ tại `art_source/graphics_upgrade/`; **C** sở hữu công cụ/schema dưới `tools/graphics/` và test tools. Schema/ID/pivot thống nhất ở G1 trước khi sinh hàng loạt dữ liệu.
- **D** là bên ghi `user://settings.cfg`; B áp dụng rendering trong vùng B. Core/project setting thuộc integrator theo card. Không thêm nút menu không có tác dụng.
- **F** tiếp nhận toàn bộ vùng âm thanh cũ của E, tạo asset/scene âm thanh; core nối `FIRE_BELL_STREAM`, B cung cấp vị trí treo chuông, A/B thống nhất marker trên rig. Dùng [prompt lane F](../handoff/lane-f.md); E nghỉ vô thời hạn, lịch sử/nguồn asset cũ giữ nguyên.
- Chỉ integrator sửa `STATUS`, `DECISIONS`, quy tắc và review/merge lên `main`. Các lane cập nhật Handoff/checklist của card mình. Prompt riêng tại [handoff](../handoff/).

Ràng buộc đã biết: `ch3_actor.gd` có `set_body`, `play_pose`, `head_position`; `campus/actor.gd` điều khiển `Rig/Hips/Chest/Head` và loại AnimationPlayer của model cũ; `corpse_body.gd` dùng `set_pose`, `set_state`, bịt miệng/máu; quản lý dùng `BladeTip` và clip. Không gắn GLB có Skeleton3D vào wrapper cũ rồi cho rằng tương thích.

## 6. Tiêu chuẩn hình ảnh và kỹ thuật để thử

Hình ảnh: phòng ở sinh viên có tỉ lệ hợp lý, sơn cũ, gạch, giường sắt và vải khác nhau rõ; vết bẩn có nguyên nhân. Giữ trời chương 3 xanh đen theo D-065. Biển/chữ Việt và tài liệu nhiệm vụ làm riêng, không dùng chữ sai do AI tạo, không thêm gợi ý trái D-038/D-055.

Godot đang dùng Forward+. Shader PS1 hiện chưa nhận bộ PBR đầy đủ; chỉ tắt `ps1_strength` chưa thay lọc nearest và texture nhỏ. Thử StandardMaterial3D/ORMMaterial3D, ánh sáng tính sẵn cho phần tĩnh, xử lý riêng đèn có bật/tắt và nhân vật/cửa chuyển động.

| Nhóm | Khoảng khởi điểm đề xuất cho prototype | Texture |
|---|---:|---|
| Đồ nhỏ | 500–3.000 tam giác | 512–1K |
| Đồ lớn/tương tác gần | 3.000–12.000 | 1K, 2K khi cần |
| Nhân vật gần | 20.000–35.000 | 2K cho phần cần nhìn rõ |
| Xác xuất hiện đông | 8.000–15.000 + LOD | Chủ yếu 1K, chia sẻ vật liệu |

Đây là **đề xuất để đo ở G1/G2**, không là lệnh tăng ngưỡng test hay bỏ giới hạn hiện hành cho asset production. B có thể làm prototype riêng, C báo số đo; chuyển budget chính thức cần integrator ghi quyết định và căn cứ. File vẫn tối đa 10 MB, Git LFS; không dùng texture 4K/8K hàng loạt. Giữ collider đơn giản; kiểm số material, texture memory, bóng và trong suốt bên cạnh số tam giác.

Mục tiêu thử 1080p/60 FPS Medium trên RTX 3050 Laptop 4 GB. Báo cáo phải ghi CPU/GPU, renderer, độ phân giải render thật, FPS trung bình/p95 và bộ nhớ. Các báo cáo 720p cũ không chứng minh 1080p đạt. Chưa được phép chạy FPS/bot trong gói lập kế hoạch này; C chỉ chuẩn bị công cụ và quy trình.

## 7. Tripo AI, giấy phép và ngân sách

- **Studio thủ công:** B cung cấp brief và số đo, chủ dự án tạo trên web trong trần đã giao, tải GLB/texture. B chuẩn hóa bằng Blender; C kiểm file/metadata. Không cần API key hoặc plugin để đi đường này.
- **API riêng:** Studio và API không dùng chung credit. Chỉ chuẩn bị/chạy adapter Tripo khi được giao phương án API, ví và trần chi; không dùng quyền mua Studio để suy ra ngân sách API. Một operator cục bộ; web không giữ key hoặc tiêu credit.
- C giữ dry-run, reservation trước submit, task ID để resume, giới hạn lượt và đối soát credit. Metadata phải phân biệt provider, Studio/API, model version, task/model ID, ngày, thông số, credit thực và giấy phép. Timeout chưa biết trạng thái không được tự POST lại.
- `tools/graphics/meshy_dry_run.py` là fixture G0 lịch sử, chưa có transport cho bất kỳ dịch vụ nào. C chuyển công cụ sang tên/cấu trúc phù hợp trong T-210; không đổi tên rồi tự nhận Tripo API đã chạy. `TRIPO_API_KEY` là quy ước biến môi trường dự kiến, chưa có client đọc; không in/commit/gửi chat hoặc cloud. Không cài MCP/plugin trong đợt chuyển kế hoạch.
- Chính sách repo giữ CC0/CC-BY; quyền thương mại Paid không tự gắn nhãn này. Lưu điều khoản/gói tại lúc tạo và quyền ảnh đầu vào, rồi chốt hồ sơ license trước nhập. Không dùng model Free làm asset thương mại theo suy diễn từ bài quảng cáo cũ; D-080 chưa cấp ngoại lệ.
- Lưu nguồn bền vững trong vùng B, CREDITS và metadata; `build/`/URL tạm không phải kho bàn giao. Giữ tác giả/license của asset CC0 cũ, chưa ghi credits Tripo khi chưa nhập asset thực.

Nguồn đã kiểm ngày 11/10: [Studio và API](https://www.tripo3d.ai/help/api-plugins/tripo-studiotripo-api), [giá Studio](https://www.tripo3d.ai/pricing), [API pricing](https://developers.tripo3d.ai/en/pricing), [quyền thương mại](https://www.tripo3d.ai/help/privacy-policy/how-to-use-tripo-models-commercially), [điều khoản](https://www.tripo3d.ai/terms). Xem [nghiên cứu Tripo](../research/TRIPO_AI_2026-10-11.md); giá cuối cùng theo đúng tài khoản/model/công đoạn tại lúc chạy. Nghiên cứu Meshy 10/10 chỉ còn là lịch sử.

## 8. Thứ tự thực hiện, review và bàn giao

1. **G0 đã ghép D-079:** sáu lane đọc Review; không làm lại G0. Cập nhật provider Tripo theo D-080 và tiếp tục G1 trong card/nhánh hiện có.
2. **Khi chủ dự án sẵn sàng:** xác nhận gói Tripo, license, ví Studio/API và trần credit. Sau G1 đạo cụ tĩnh, thử một balo rồi nhập Godot; không bắt mẫu thủ công chờ API, chưa tạo hàng loạt.
3. **Trong 11/10:** nhận Handoff, review contract trước; sau đó công cụ C, adapter A, mẫu B, phần D/F và cuối cùng wiring core. Những phần làm độc lập có thể review trước; không ghép caller trước dependency bắt buộc.
4. Mỗi lần tích hợp: kiểm diff theo phạm vi, test trên cảnh thật, toàn bộ `tools/test.ps1` + `tools/check.ps1`; thêm kiểm ngược cho lỗi/hợp đồng mới khi phù hợp. Không viết test chỉ để xác nhận con số tự đặt.
5. Asset/model mới phải được ngắm và tiếp cận bằng `InteractRay`/đi bộ thật. Kiểm cửa 407/giường, bình cứu hỏa, `FireAlarm1F`, đường 207→203, đường khuôn viên và thanh chắn chương 4. Âm thanh cần người dùng nghe.
6. Chỉ export sau đợt thay đổi game đã ghép và khi editor được xử lý theo handoff; bản commit kế hoạch này chỉ có tài liệu, **không export**.
7. Kết thúc hai ngày: cập nhật [nhật ký Astra](../handoff/NHAT_KY_ASTRA_2026-10-10_11.md), tình trạng từng card/nhánh, kết quả đã kiểm, build hiện hành, việc cần chủ dự án quyết. Opus 5.5 nhận lại vai trò integrator; không coi Astra là người phụ trách dài hạn.

## 9. Điều kiện nghiệm thu từng đợt

- Hình ảnh trong game được duyệt; có ảnh cùng góc trước/sau, không chỉ screenshot từ Tripo.
- Transform, collider, marker, API và timing khớp; không thay kết quả luật/chết/checkpoint.
- Nguồn/license rõ, số đo asset có báo cáo; full test/check đạt, lỗi sẵn có ghi riêng.
- Performance chỉ ghi đạt khi đo đúng điều kiện được phép. Chưa đo/chưa nghe/chưa chơi tay phải ghi rõ.
- Bản dùng cũ tiếp tục hoạt động trong thời gian prototype; không thêm lựa chọn PS1 song song thành tính năng bắt buộc dài hạn. Thay mặc định theo mốc G3 đã duyệt, giữ khả năng quay lại qua Git.
