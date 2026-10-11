# Hợp đồng tích hợp đồ họa — T-207, G1 từng phần

> **D-082, review tiếp:** đã nhận A/B/D/F và probe C `b86a77d`; schema/validator `7af1075` chưa được nhận vì R1–R4. Đọc [kết luận hiện hành](../../handoff/REVIEW_G1_2026-10-11.md). B chưa chuyển manifest; các mốc/commit G0 bên dưới là căn cứ lịch sử, không thay kết quả D-082.

**11/10/2026, D-081 — Astra làm thay Claude web theo yêu cầu chủ dự án.** G0 của sáu lane đã ghép ở D-079; provider hiện hành là Tripo AI (D-080). Claude web tạm dừng T-207; đầu mối core là Astra trong hai ngày điều phối, sau đó bàn giao Opus. Giữ tác giả và số đo G0 của web trong [ASSET_BINDINGS.md](ASSET_BINDINGS.md).

**Hiệu lực:** quy ước đạo cụ tĩnh ở §2–3 là quyết định kỹ thuật để B/C triển khai sau khi D-081 lên main. Đây không phải xác nhận validator đã hỗ trợ schema mới, asset đã đạt hoặc G2 đã mở. Các điều kiện đóng G1 ở §9 còn phải có bằng chứng B/C. Rig/settings/chuông có trạng thái riêng; không giữ balo chờ chúng.

Nguồn đối chiếu: main `acbf771`, Review [D-079](../../handoff/REVIEW_G0_2026-10-11.md), [D-080](../../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md), Handoff T-208…T-212. Đợt D-081 chỉ sửa tài liệu; không đổi runtime, asset, SETTINGS hoặc công cụ lane.

## 1. Ràng buộc chung

1. Giữ root gameplay, vị trí thế giới, collider/nav, vùng tương tác, luật, AI, save và timing. Chuẩn hóa model dưới visual; không dịch root để sửa model sai kích thước.
2. Director/AI giữ một nguồn sự kiện. Clip không phát lại `noise_emitted`, chém, bắt/chết hoặc hoàn tất luật. Model mới không có root motion kéo nhân vật thêm lần nữa.
3. Giữ model hiện hành cho tới khi phần thay được kiểm và duyệt. Model không hợp lệ phải bị chặn ở QA; fallback runtime là dự phòng, không biến asset lỗi thành đạt.
4. Core không đọc manifest, không thêm registry/autoload/signal tổng quát. Chỉ mở điểm nối cụ thể khi dependency của nó đã ghép và có test.
5. Pilot riêng trước; chưa đổi scene chương hoặc mặc định hình ảnh. Tia `InteractRay` dài 2 m, mask 5 vẫn giữ; visual không tự thêm va chạm hoặc che vùng dùng.

## 2. G1 đạo cụ tĩnh — balo `room407_backpack`

### 2.1 Binding và số đo đã có

| Thuộc tính | Giá trị / căn cứ |
|---|---|
| Scene nguồn | `res://scenes/levels/floor4/floor4.tscn` |
| Root chọn để đo / thay visual | `Room407/Details/Trung/Backpack`, thuộc B |
| Bounds trong hệ root | min `(-0.145, 0.01, -0.1325)` m; size `(0.29, 0.45636, 0.30274)` m |
| Đặt trong floor4 | position `(33.78, 0.02, -4.52)` m; rotation `(0,90,0)` độ; scale `(1,1,1)` |
| Phép đo G0 | 96 tam giác, 3 material của balo cũ; `art_source/graphics_upgrade/measured_assets.json#room407_backpack` |
| Phạm vi mẫu mới | Đạo cụ tĩnh, không rig/clip hoặc marker gameplay mới; không lấn đường đi/va chạm bàn |
| Trần prototype D-079 | **≤3.000 tam giác, ≤2 material, mỗi chiều texture ≤1024 px; ≤10 MiB/file, Git LFS** |
| Mục tiêu mới so với mốc cũ | 3 material của mẫu cũ không là ngoại lệ cho trần 2 material của mẫu mới. Không áp trần mới ngược lên tất cả asset PS1 |

Đơn vị mét, +Y lên. Giữ yaw/điểm đặt nguồn; không áp hướng −Z của nhân vật một cách máy móc cho mọi đạo cụ. B phải minh họa mặt trước của balo theo basis nguồn trong brief. Wrapper/pivot chuẩn hóa thuộc B; phép đo nghiệm thu tính cả các transform chuẩn hóa bên trong root, không tính transform đặt root trong cảnh. Prompt Tripo không bảo đảm đơn vị/pivot; B sửa ở Blender và C đo artifact xuất cuối.

### 2.2 Cách đo và bằng chứng C cần cung cấp

- **Root-local:** nếu root được đặt dịch/xoay/scale bất kỳ, bounds và marker tương đối root vẫn không đổi. Root transform được ghi riêng. Có thể tính `inverse(root_global) * child_global * vertex`, hoặc duyệt bỏ transform của chính root rồi tích transform con. Không bỏ transform con hoặc so AABB world với AABB local.
- Với wrapper, `measurement_root` phải chỉ đúng node đã được quy ước, không tùy chọn root thuận tiện để vượt kiểm. B/C ghi rõ file GLB thuần hay scene wrapper được đo; wrapper có offset thì phải được kiểm cùng artifact, không chỉ đo GLB riêng.
- C thêm fixture root dịch/xoay/scale khác identity, child transform khác identity và marker; fixture phải phát hiện cách nhân root hiện tại. Không đổi gameplay root để làm báo cáo khớp.
- `tolerance_m` áp riêng phép so vị trí/bounds. Với mẫu balo, chuẩn hóa về bounds trên; **sai số kỹ thuật tối đa 0.001 m cho mỗi thành phần** khi xuất/import, không là quyền nới collider/marker. Scale không có đơn vị mét: C kiểm riêng root scale `(1,1,1)` với sai số số thực đã ghi rõ trong công cụ. B báo nếu mục tiêu này không thể đạt mà vẫn giữ hình; không tự mở dung sai ±5% hoặc 30% của draft G0.
- Báo mesh/surface/material/texture thật sau import; tham chiếu geometry thiếu phải là INCOMPLETE/FAIL phù hợp. Các biến thể ẩn, rest pose, skin/animation/LOD chưa hỗ trợ phải được ghi rõ; không cộng số khảo sát cả cụm thành số một asset.
- B/C thống nhất hash theo **tập dependency**: nguồn GLB/scene, wrapper/script liên quan, material/texture ngoài, cấu hình `.import`, phiên bản Godot và probe. Báo cáo cũ phải bị coi stale khi một dependency đổi. Không bắt mọi máy có cùng byte của cache `.godot`; C định nghĩa cách ghi dấu artifact import cục bộ và bằng chứng tái import. Dependency chưa liệt kê hết → chưa đủ chứng cứ.
- D-082 nhận probe C `b86a77d`: đã bỏ root placement khỏi bounds/marker và bổ sung dependency hash/fixture. Validator G1 vẫn chưa được nhận; R1–R4 phải sửa trước khi dùng làm cổng kiểm schema. Bằng chứng probe không thay nghiệm thu wrapper/closure/asset.

## 3. Manifest — C sở hữu schema, B sở hữu dữ liệu

Đích dữ liệu vẫn `art_source/graphics_upgrade/asset_manifest.json`; schema/validator/mẫu thuộc `tools/graphics/`. Giữ ID B, đặc biệt `room407_backpack`. C đề xuất version G1 tách `t210-g0-proposal-1`; không nhận dữ liệu G1 bằng parser G0 chỉ vì đổi chuỗi version. C bàn giao schema và fixture trước, B chuyển dữ liệu sau khi schema được integrator ghép. C không sửa manifest B; B không sửa validator C.

| Nguồn G0 B / yêu cầu core | Ánh xạ cần có trong schema G1 C | Điều cần phân biệt |
|---|---|---|
| `id` | `asset_id` | Giữ giá trị, không tạo ID thứ hai cho cùng balo |
| `current_scene`, `measurement_node` | Binding scene + node nguồn, measurement root | Scene dùng vật thể khác với file model được QA |
| `file` của mẫu C | Artifact model/wrapper thực, đường tương đối repo | Chưa có asset Tripo thì để pending; không gán file cũ thành đầu ra Tripo |
| Core | `binding`, `root_class`, `required_markers`, `collider_policy` | Balo là `prop`; không thêm collider. Class/path thật lấy từ artifact B, không bịa trước |
| `measurement_ref`, số đo B | `geometry.dimensions_m`, `bounds_min_m`, root scale; placement riêng | Ghi coordinate space/root, tolerance có đơn vị; marker map theo cùng root |
| `source.kind/credits/license` | `source.uri/author/license/credits_file/ai_tool/input_rights` | Dữ liệu nguồn cũ giữ riêng với nguồn asset thay; CC0 cũ không thành license Tripo |
| Tripo thủ công hoặc API | `generation`: provider, channel, model version/ID, task ID nếu có, ngày, parameters | Provider `tripo`, channel `studio`/`api`; tên trường chính xác C công bố. Không yêu cầu task API cho mẫu Studio |
| Trần thử và chi phí | `budget`: geometry limits và credit ghi riêng từng ví | Nếu giữ exclusive: `triangle_limit_exclusive=3001`; 0 credit chỉ khi thực sự không chi, chưa biết thì null/pending |
| Phép đo và duyệt | Report, dependency hash và `approval` | Tách schema hợp lệ, QA kỹ thuật và duyệt hình/license. Không dùng một chữ approved để suy cả ba |

Các tên trường G0 nêu trong bảng là đầu vào để C thiết kế schema thật; không phải file JSON G1 đã tồn tại. Contract này chốt ý nghĩa/owner/ràng buộc, C công bố tên/version cuối và bảng mapping; integrator kiểm trước khi B chuyển dữ liệu.

**Tripo:** ưu tiên Studio thủ công → GLB → Blender → Godot. Studio/API dùng ví riêng theo D-080; client API không là dependency của mẫu thủ công. Ghi nguồn đầu vào và điều khoản/gói tại lúc tạo; không gắn nhãn CC0/CC-BY bằng suy đoán từ quyền thương mại. Chưa cấp ngoại lệ license, trần credit hoặc đặt tác vụ trả phí. Công cụ `meshy_dry_run.py` vẫn là fixture G0, không chứng minh đã có transport Tripo.

## 4. Nhân vật và attachment — phần độc lập còn cần A/B/F

| Consumer | Quy ước giữ / việc cần bàn giao | Owner |
|---|---|---|
| `Ch3Actor` | Giữ `set_body`, `play_pose`, `head_position`; A đề xuất acknowledgement khi pose bị từ chối, xử lý model cũ cùng frame và cache. Test G0 chỉ chứng minh sau deferred free; chưa sửa production | A; B cung cấp wrapper |
| Model campus / guard | Bảng pose gồm `idle/walk/stunned/grab/sit/lie/wake` và `warn`; guard có đường `turn_head_to`. Không im lặng ánh xạ `warn` sang idle; chưa có skeleton contract hoàn chỉnh | A/B |
| Xác | Giữ `set_pose` khác `set_state`, gag/máu/look-at độc lập; phạm vi cả 3 xác 407 và 3 xác CCTV 310. B wrapper, A `UnseenPoser`; không gắn GLB skeleton vào Rig Node3D cũ | B/A/core |
| Head / Gag | Head đã cập nhật khi hitbox/LOS/death camera/âm đọc; `gag_anchor.gd` hiện bám Head mỗi frame, không là anchor cố định trong phòng. Giữ pick volume/offset và timing; B công bố đường attachment mới nếu đổi rig | B/A/F/core |
| Quản lý | `BladeTip`, `LeftArm`, clip `stand/walk/ask/slash/lunge/kill`; animation không phát `slashed` lần hai. Chốt ai ghi transform khi procedural và animation cùng dùng khớp | B/A |
| Audio quản lý / zombie | Hiện Speech của quản lý và Voice/Foley zombie ở root; chỉ Drag bám BladeTip. Không tự chuyển tất cả âm sang Head. Marker thiếu: không phát ở world origin; F/A đề xuất fallback cụ thể | F/A/core |
| `UnseenPoser`, `door_burst` | Snapshot pose đang seek/pause và consumer zombie ngoài Ch3Actor cần adapter riêng. Giữ timing cửa, camera và reduce_scares | A/B/core |

Chưa tạo API chung/signal mới. A/B gửi bảng path, return/failure, owner transform, thứ tự cập nhật, pause/reset cho từng consumer; core chỉ nối khi đã ghép dependency. Giữ fallback đang có; thiếu marker bắt buộc phải bị test hợp đồng bắt, không chấp nhận root bất kỳ làm điểm đầu/miệng.

## 5. Nút và chuông — phần độc lập còn cần B/F/core

- **Nút `FireAlarm1F` chỉ chương 3**, core tạo tại `(0.9,-8.5,0.12)`, vùng dùng `(0.5,0.6,0.5)`. B cung cấp scene **visual riêng**, core instance sau điều kiện chương. Không đặt sẵn nút tương tác trong campus dùng chung chương 4.
- **Mồi AI:** `(42,-9.9,2)`, bán kính 45 m, phát một lần; giữ số xác và nơi kéo crowd.
- **Nguồn âm:** `(42,-7.7,0.2)`, tên dự kiến `Campus/Anchors/FireBellMount`. D-082 đã xem ảnh khảo sát B: giá đỡ bám facade, basis đề xuất identity/+Z ra hành lang, envelope đĩa 0.28×0.28×0.12 m. Nhận làm căn cứ kỹ thuật, chưa phải marker production; không nhập vị trí âm vào vị trí mồi.
- F đã có `res://audio/graphics_upgrade/fire_bell_soft.ogg`: mẫu riêng 4 s, `loop=false`, preview và test; chưa được nghe/duyệt, chưa thay stream core. Giữ stream finite cho tới W2.
- W2 sẽ dùng deadline dừng 20 s độc lập `finished`, dọn khi chết/reset và xử lý pause theo contract được kiểm; chưa triển khai hoặc tuyên bố đã sửa production. F preview không là bằng chứng `_ring_bell` đã đổi. Không phát thêm noise từ stream/animation.

## 6. Settings/readability — giữ hợp đồng hiện hành

`docs/SETTINGS.md` chưa thêm key. Hợp nhất đề xuất D/web về **một tên ứng viên `graphics_preset`**, ưu tiên Low/Medium; default, bảng tham số, migration G3 còn pending. `quality_preset`, High, `visual_style` và `render_scale` tách riêng trong draft cũ không được coi đã duyệt; D chưa bật control không có backend.

- Consumer hiện hành: `game/rendering/ps1_filter.gd` dưới CanvasLayer đọc brightness/ps1_strength ở ready và khi signal; Screen nằm dưới HUD/menu. Brightness `1.0`, range `0.5–1.5`; ps1_strength `1.0`, range `0–1`, chưa đổi.
- D-082 nhận pilot B dùng `ShaderGlobalsOverride` theo vòng đời; integrator kiểm pixel Forward+ 3/3, gồm base đổi trong lúc override và được trả lại sau thoát. Brightness pilot có một screen consumer; đây chưa phải backend Low/Medium. B/D tiếp tục contract consumer cho cảnh production, không làm tối UI hoặc áp hai lần.
- D giữ writer lưu trước signal. Migration/reset video không xóa locale/audio/input/head_bob/reduce_scares; không gọi reset toàn bộ. F/A tiếp tục consumer hiện có.
- B đưa backend/tham số có tác dụng thật, D đề xuất missing/invalid fallback và reset, C kiểm bằng cảnh phù hợp. Chỉ sau đó integrator cập nhật SETTINGS. 1080p/60 FPS trên RTX 3050 vẫn là mục tiêu chưa đo; HTML mockup không thay ảnh Godot.

## 7. Đầu vào đã nhận và việc tiếp theo

| Lane / G0 đã ghép | Đầu ra có thật | Làm tiếp ngay | Điều kiện nghiệm thu phần tương ứng |
|---|---|---|---|
| A `e27fe28` | `visual_adapter_g0.gd/.tscn`, 5 test, bảng consumer trong T-208 | Hoàn thiện đề xuất lifecycle/pose/Head và phối hợp wrapper B theo §4 | Dependency/code mới có test, không tự nhận skeleton đã tương thích |
| B `87e99a6` | 15 mục manifest, 13 mục đo, brief, pilot và 12 ảnh | Brief balo chứa số đo §2; mặt trước/pivot, mapping với C; cleanup pilot | Chuyển manifest sau schema C được ghép; QA và ảnh model mới còn chờ |
| C `c434343` | `asset_qa.py`, sample manifest, probe, 28 fixture offline | Schema/version và mapping §3, sửa root-local, kiểm dependency/giới hạn theo §2 | Fixture dương/âm + report khớp B; không đổi dữ liệu B thay lane |
| D `aef26cb` | Đề xuất contract và mockup HTML vi/en | Chuẩn bị reset/migration/readability theo §6 với consumer B | Chờ backend/default/SETTINGS; chưa thêm control |
| F `2dcd25a` | Mẫu chuông CC0, preview, 3 test | Chốt attachment/finite stream với A/B; cung cấp lệnh nghe có sẵn | Chủ dự án nghe; marker/W2 production còn chờ |
| Web `4fc4999` → Astra | Bindings, contract G0, 8 test core | Astra tổng hợp tài liệu G1 D-081 và nhận yêu cầu từ năm lane | Không khởi chạy web song song T-207; G0 giữ tác giả |

Thời điểm fetch D-081: chưa có commit G1 mới trên sáu nhánh remote. Khi lane đẩy mới, integrator review commit thực trước khi đổi trạng thái; bảng này không thay Handoff của lane.

## 8. W1–W4 sau dependency (chưa thực hiện)

| Phần | Điều kiện mở | Kiểm phải giữ |
|---|---|---|
| W1 hình nút | Scene visual B và binding được review | Chỉ chương 3, vùng dùng/collider không đổi; dùng hai lần vẫn một mồi |
| W2 chuông | Stream được duyệt, mount B và contract vòng đời | Deadline độc lập finished; finite/loop, pause/death/reset; không thêm noise |
| W3 wrapper/adapter | A/B bàn giao từng loại, gồm CCTV/UnseenPoser/door_burst | Pose/state/Head/BladeTip, fallback, giữ timer/collision/sự kiện |
| W4 đường dẫn asset | Mẫu B qua QA và duyệt hình cho phần đưa vào chương | File thật có nguồn/license, fallback và hồi quy bốn chương |

Giữ API cửa/phòng trong ASSET_BINDINGS; cửa 407 chương 3–4 dùng proxy/Blocker khác chương 1–2. Không đổi core chỉ để thêm một balo vào scene thử B. Không đổi toàn trường trong một commit.

## 9. Điều kiện đóng G1 balo và chuyển sang mẫu Tripo

1. **Quy ước:** §2–3 và số đo/budget được ghi trên main D-081. Đây là đầu vào làm tiếp cho B/C, không phải PASS công cụ.
2. **C bàn giao:** schema/version chính thức, fixture root-local/marker, hash dependency, giới hạn tam giác/material/texture/file và report có phân biệt FAIL/INCOMPLETE. Integrator review/ghép.
3. **B bàn giao:** brief cụ thể và manifest chuyển sang schema C, placement/measurement root/facing rõ. B/C chứng minh kiểm cùng một artifact mẫu cũ/hợp lệ; dữ liệu sai bị phát hiện. Chưa cần trả tiền để kiểm quy trình này.
4. **Integrator ghi kết quả G1:** chỉ khi 2–3 đạt mới mở kiểm tạo mẫu. Nếu thiếu dữ liệu, ghi đúng trường/owner; không quay về trạng thái “chờ Handoff cả năm lane”.
5. **Trước đặt mẫu:** gói Tripo, quyền nguồn/license và trần credit thực được xác nhận. Sau tạo, B chuẩn hóa/lưu nguồn bền vững, C kiểm, chụp Godot để chủ dự án duyệt. Rig/settings/chuông không là điều kiện của balo tĩnh.

Full test/check sau mọi chỉnh sửa theo handoff; D-081 ghi giờ/kết quả/log trong message commit, không dùng lượt D-080 thay. Không chạy FPS/bot chương 3–4, chưa nghe/chơi tay và chưa có Tripo asset. EXE hiện hành không đổi vì đợt này chỉ cập nhật tài liệu.
