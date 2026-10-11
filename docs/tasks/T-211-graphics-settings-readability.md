# T-211 — Cài đặt hình ảnh và khả năng đọc trong đồ họa mới

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](../handoff/T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** chuyển sang **Tripo AI**; giữ G0 đã ghép và task/nhánh hiện có. Đọc [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md). Handoff/checklist G0 bên dưới là lịch sử; chưa có Tripo asset hoặc client live.

- Lane: D | Trạng thái: **G0 đã review/ghép (D-079); G1 tiếp tục, toàn gói chưa done** | Agent: lane D
- Nhánh: `lane-d/T-211-graphics-settings-readability`, từ `origin/main` có D-077.
- Phụ thuộc: D-076/D-077; G0 độc lập. Key/settings mới sau G1 T-207; hình nền/cảnh mẫu T-209.
- Hạn đề xuất: phiên đầu gửi khảo sát/mockup và hợp đồng đề xuất, triển khai sau G1.

## Bối cảnh
`docs/SETTINGS.md` hiện có `video.ps1_strength` và `brightness`, B áp dụng; D ghi ConfigFile rồi phát `settings_changed`. Hướng gần chân thực cần lựa chọn hình ảnh dễ hiểu và chữ vẫn đọc được trong bóng tối. Không thêm gợi ý luật theo D-038/D-055 hoặc thay lời đã duyệt.

## Việc
1. **G0:** kiểm menu video, brightness, PS1, độ phân giải, phụ đề/điện thoại/giấy/biển và credits. Ghi các điểm dựa vào pipeline PS1; làm mockup ở vùng D và đề xuất key/type/default/range/consumer cho web/integrator.
2. **Sau G1:** triển khai những setting có backend thật đã thống nhất, ưu tiên mức Low/Medium và độ sáng; giá trị chi tiết dựa trên pilot, chưa tuyên bố preset đạt FPS. D sở hữu phần lưu/menu, B/core sở hữu phần áp dụng theo contract. Không thêm key vào file người dùng trước khi integrator cập nhật SETTINGS.
3. Xử lý file settings cũ/thiếu/sai kiểu theo hợp đồng, reset và load scene; giữ ngôn ngữ/âm lượng/input của người dùng. Chuyển mặc định khỏi PS1 chỉ khi G3 được duyệt, tránh âm thầm bật/tắt trong giai đoạn thử.
4. Kiểm chữ trên nền sáng/tối, giấy tờ, phone và subtitle ở 1080p cùng mức render thấp hơn. Thêm key UI vi/en cần thiết, không sửa block lời sinh tự động. Biển trong thế giới B sở hữu; D cung cấp yêu cầu chữ/localization, B gắn vào model.
5. Cập nhật hiển thị credits cho nguồn được nhập thật, có tên công cụ AI/license đúng; không tuyên bố Private là CC0. Nếu cần đổi cấu trúc credits ngoài vùng D thì gửi yêu cầu.

## Được phép sửa
Vùng D: `game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, thêm key trong `game/localization/strings.csv`, `game/tests/ui/`; Handoff/checklist card. Không sửa `docs/SETTINGS.md`, rendering, project.godot, main scene hoặc asset B. Không tạo control có vẻ dùng được nhưng không áp dụng gì.

## Test và bằng chứng
- Giá trị mặc định/thiếu/sai kiểu, lưu trước signal, khôi phục/reset, file cấu hình cũ không mất tùy chọn khác. Test phần consumer thật sau khi B/core ghép, không chỉ test widget đổi nhãn.
- UI đọc được, focus/chuột/menu pause vẫn đúng, không che tâm ngắm/tương tác; có ảnh so sánh vi/en. Chưa có cảnh mới ghi rõ chỉ test nền mẫu.
- `pwsh tools/test.ps1`, `pwsh tools/check.ps1` đầy đủ. Không chạy FPS để tự chọn preset khi chưa được phép.

## Checklist hoàn thành
- [x] G0: khảo sát/mockup và đề xuất contract (đã kiểm full test/check ngày 11/10; sẵn sàng review G1)
- [x] Sau Review D-079/D-080/D-081: nhận một tên ứng viên `graphics_preset`, đối chiếu consumer B, chuẩn bị migration/reset, readability và điều kiện credits Tripo
- [x] Full test/check phần sau Review trên base D-081 (đã chạy tuần tự trong lượt Windows sau C; kết quả ghi ở Handoff)
- [ ] G1: settings thống nhất trước khi dùng chung
- [ ] Preset có tác dụng thật và migration an toàn
- [ ] Kiểm khả năng đọc/vi/en và credits nhập thật
- [x] Full test/check PASS, Handoff ghi giới hạn hình ảnh/performance (cho đợt G0; các đợt sau phải kiểm lại)

## Handoff (agent điền)

### Tiếp tục sau Review D-079/D-080/D-081 — 11/10/2026

**Trạng thái hiện tại:** G0 đã được integrator nhận/ghép; tiếp tục T-211 trên đúng nhánh, không làm lại G0. Phần chuẩn bị sau Review và lượt full test/check D-081 đã hoàn tất; chưa có key/default/backend G1 đủ điều kiện triển khai production. Nội dung mục này và tài liệu mới là phản hồi hiện hành; những tên preset/Meshy trong bản ghi G0 bên dưới giữ để đối chiếu lịch sử.

- Trước phiên workspace sạch tại `aef26cb`. Đã `git fetch origin` và `git rebase origin/main` thành công tới **`acbf771` có D-080**; G0 D đã là tổ tiên main nên rebase không viết lại commit riêng hoặc cần giải xung đột. Giữ nhánh `lane-d/T-211-graphics-settings-readability`; không đổi task ID, không thao tác workspace lane khác.
- Tiếp nối lượt mới: đã bảo toàn cả card sửa dở và tài liệu migration untracked bằng stash có tên, fetch/rebase tới **`d6d76f3` có D-081**, áp lại thành công; đối chiếu nội dung xác nhận phần chuẩn bị không mất. Đã đọc handoff T-207 của Astra, contract G1 đặc biệt §6 và Review mới trong card. G0 vẫn giữ nguyên; không ghi đè Review.
- Đã đọc hướng chuyển Tripo, Review G0, Review card, AGENTS/STATUS/SETTINGS hiện hành. Nhận một tên ứng viên **`video.graphics_preset`**, ưu tiên Low/Medium; `quality_preset`, `visual_style`, `render_scale` riêng và High không đưa vào triển khai sắp tới. Default, tham số và backend còn pending; chưa thêm key vào SCHEMA/config/CSV.
- Đầu ra tiếp nối: [`game/ui/graphics_upgrade/settings_migration_review.md`](../../game/ui/graphics_upgrade/settings_migration_review.md). Có bảng consumer B, luồng lưu/reset theo allowlist, danh sách cấu hình phải bảo toàn, chín nhóm ca kiểm sau backend và hồ sơ cần nhận trước khi thêm credits Tripo. Giữ nguyên mockup G0.
- Đối chiếu mã B: `rendering/ps1_filter.gd` là consumer production; `scenes/levels/graphics_pilot/material_pilot.gd` đọc brightness và tạo lớp hậu kỳ riêng, `set_mode` chỉ là before/after PBR, **không phải preset Low/Medium**. Base hiện tại chưa có cleanup global `ps1_strength` khi rời pilot; ghi yêu cầu B xác nhận consumer duy nhất và lifecycle, D không sửa rendering hoặc bind vào NodePath động của pilot.
- Đã đọc nhánh B `21f2f9b`: pilot dùng `ShaderGlobalsOverride`/`PilotShaderOverride` để engine quản lý lifetime override; bản này chưa có trên base `d6d76f3`. Gửi Astra review/ghép dependency; D chưa cherry-pick, chưa chạy kiểm code B mới hoặc coi cleanup là backend preset. Bảng khảo sát base và cập nhật nhánh được tách rõ trong tài liệu.
- Bổ sung readability theo contract §6: ma trận native/lower 3D tại output 1080p tách khỏi output 720p; vi/en, nền sáng/tối, brightness 0.5/1.0/1.5, thứ tự layer, vùng chữ/tâm ngắm và lifetime sau pilot. B cung cấp consumer/tham số, C ghi cảnh/camera, D kiểm UI; toàn bộ là kế hoạch renderer sau dependency/lượt riêng, không báo ảnh Godot đã đạt.
- Migration/reset chuẩn bị: giữ locale/content warning/audio/input/head_bob/reduce_scares/legacy PS1 và dữ liệu khác có sẵn; reset dự kiến chỉ brightness + preset khi SETTINGS/backend đã duyệt. Lưu một lần trước signal cho reset nhiều key, không gọi reset toàn bộ, không tự ghi default lúc startup. Đây là đề xuất/ma trận kiểm, chưa là API mới hoặc bằng chứng consumer hoạt động.
- Tripo: ưu tiên Studio thủ công → GLB/texture → Blender → Godot. D chỉ nhận hồ sơ asset thật từ B/C để bổ sung credits vi/en sau nhập/duyệt; không đổi nguồn/tác giả asset CC0 cũ. Studio/API tách ví, chưa cấp ngân sách/key/ngoại lệ license; không chi credit hoặc cài plugin/MCP, không lấy API live làm dependency của UI.
- **Đầu mối core/contract hiện hành:** chủ dự án thông báo Astra (integrator) đã tiếp nhận T-207 thay Claude web. D chuyển các yêu cầu kỹ thuật sau Review về **Astra qua Handoff này**; phần ghi web trong G0 là lịch sử, không phải giao việc mới.
- **Yêu cầu gửi Astra:** hợp nhất một tên `graphics_preset`; phối hợp B chốt default/fallback/thông số Low/Medium và consumer/lifetime; chốt allowlist reset brightness + preset cùng chính sách legacy PS1; cập nhật SETTINGS rồi ghép contract trước khi D triển khai. Không cần thêm signal/autoload mới chỉ cho menu. Chi tiết và ma trận kiểm ở mục 1–4 của tài liệu liên kết trên.
- **Yêu cầu ngoài phạm vi còn lại:** B xác nhận lifetime/cleanup/consumer brightness và backend preset; B/C cung cấp provenance/license/CREDITS của asset thực nhập. Astra quyết hợp đồng core và SETTINGS. G1 balo có thể đi trước; không bắt chờ settings.
- **Kiểm tra phần sau Review:** đã nhận lượt Windows sau C; xác nhận không có tiến trình Godot của lane khác chạy trước lượt. Chạy tuần tự trên base `d6d76f3` ngày 11/10/2026 (UTC+07): `pwsh tools/test.ps1` **PASS, 743 passed / 0 failed**, exit 0, 14:18:49–14:39:26; tiếp theo `pwsh tools/check.ps1` **PASS, 0 errors, 344 script parses passed**, exit 0, 14:39:48–14:46:50. Log cục bộ bị ignore: `build/T-211/d081/full-test.log`, `build/T-211/d081/full-check.log`; result JSON tương ứng trong cùng thư mục. Test có 9 warning: hai cảnh báo UID `green_paint.png` không hợp lệ trong `wall_door.glb`/`wall_straight.glb` (dùng text path dự phòng), còn lại là warning fixture về GameState flag, checkpoint cũ, tài liệu thiếu, hiding spot thiếu anchor, puzzle thiếu data và hai light switch chưa gán light. Check có hai warning UID GLB nói trên; không có ERROR/SCRIPT ERROR. Test `test_wide_corridors::test_floor4_standalone_navigation_reaches_both_ends_and_room407` PASS trong lượt này; đây chỉ là kết quả lần chạy này, không kết luận nguyên nhân báo cáo chập chờn trước đó. Kiểm tĩnh đường dẫn/phạm vi/lịch sử và `git diff --check` **PASS**; mockup G0 không đổi. Godot đã tuần tự hóa lại `game/default_bus_layout.tres` trong lệnh kiểm; đã khôi phục đúng HEAD và xác minh không nằm trong thay đổi bàn giao. Không render/FPS/bot; không export.
- **Bàn giao:** kết quả trên chỉ thuộc lượt D-081, không dùng thay kết quả G0 hoặc lượt integrator. Đã nhả lượt Godot sau check lúc 14:46:50; không còn tiến trình Godot. Commit phần sau Review dự kiến `T-211: update migration review and validate D-081 handoff`; G0 `aef26cb` vẫn đã push/đã ghép.
- **Chặn:** triển khai setting/control mới chờ G1 settings + backend B; readability cần cảnh/consumer và lượt renderer riêng. T-211 chưa done, không tự mở G2/G3. Phần chuẩn bị và full test/check D-081 đã hoàn tất; **D đã nhả lượt Godot**.

### G0 — chuẩn bị ngày 10/10, hoàn tất kiểm ngày 11/10/2026, lane D

**Phạm vi bàn giao:** khảo sát mã nguồn, mockup độc lập vi/en và đề xuất để web tổng hợp G1. Chưa hoàn thành cả T-211. Không đổi mã chạy game, CSV, settings người dùng, luật/lời thoại, collision/nav/timing hoặc mặc định PS1.

- Workspace ban đầu sạch ở `lane-d/T-197-ch4-ui`; đã `git fetch origin` và tạo `lane-d/T-211-graphics-settings-readability` từ `origin/main` **`e3ed54a`**, có D-077/D-078. Chưa có nhánh T-211 local/remote khi kiểm.
- Mockup: [`game/ui/graphics_upgrade/settings_readability_mockup.html`](../../game/ui/graphics_upgrade/settings_readability_mockup.html). Mở trực tiếp bằng trình duyệt, zoom 100%. Có bộ chọn ngôn ngữ vi/en, nền sáng/tối, khung 1920×1080 hoặc 1280×720; chúng chỉ đổi bản mẫu để review. Các hàng setting là chữ tĩnh, không có nút/slider giả tác dụng và không ghi file cấu hình.
- Khung A đề xuất bố cục video sau G1/G3; khung B đối chiếu chữ giấy/điện thoại/phụ đề bằng dữ liệu minh họa có sẵn `UI_PHONE_PREVIEW_*`. Bản mẫu dùng font hiện có, không tải font/asset bên ngoài. Không thêm lời chơi hoặc key runtime chưa duyệt. Phần chú thích G0 chỉ dành cho reviewer.
- Đây là HTML/CSS minh họa, **không phải ảnh Godot, cảnh pilot, kiểm focus của game hoặc kết quả render scale 3D**. Giấy đặt cạnh điện thoại để so chữ; không đề xuất mở đồng thời hai UI trong gameplay.

### 1. Khảo sát hiện hành và số liệu từ nguồn

Mọi đường dẫn dưới đây tính từ gốc repo, khảo sát tại `e3ed54a`. Số px là đơn vị UI thiết kế, chưa là đo ảnh trên GPU.

| Hạng mục | Nguồn cụ thể | Hiện trạng / điểm cần giữ hoặc xử lý |
|---|---|---|
| Ghi/đọc settings | `game/scripts/ui/settings.gd`: `SCHEMA`, `get_value`, `set_value`, `reset_defaults` | 13 key thuộc 5 section; chỉ D ghi. Đọc float sai kiểu/khoảng/NaN/Inf dùng mặc định; setter nhận int cho mục float rồi ép float/clamp. Load lỗi ngoài thiếu file thì setter trả lỗi, không ghi đè. Lưu thành công rồi áp dụng audio/locale và emit `settings_changed(section, key)`. Startup không ghi file. |
| Menu dùng chung | `game/scripts/ui/settings_panel.gd`, `game/ui/pause/settings_panel.tscn`, `game/scripts/ui/title_screen.gd` | Video có head bob, brightness, PS1 strength; chưa có preset, độ phân giải hoặc render scale. Brightness/PS1 bước 0.05. Hai cột cách 64 px; title 40 px, heading 30 px; nội dung theo theme 28 px. Reset hiện gọi reset **toàn bộ** schema, có đổi locale/audio/input về mặc định; không dùng hàm này làm reset riêng video. |
| Brightness phụ thuộc PS1 | `game/rendering/ps1_filter.gd`, `ps1_filter.tscn`, `ps1_screen.gdshader` | CanvasLayer 5; brightness nhân RGB sau bước lấy mẫu/quantize, vẫn hoạt động khi strength=0. Giá trị 1.0, range 0.5–1.5; đây không phải gamma hoặc exposure. Khi thay filter cần giữ consumer brightness riêng, tránh mất độ sáng hoặc nhân hai lần. |
| Những gì tắt PS1 chưa giải quyết | `game/rendering/ps1_surface.gdshaderinc`, `mirror_surface.gdshader`, `ps1_screen.gdshader` | Shader surface/mirror vẫn `filter_nearest`. Post-filter strength=1 lấy mẫu 360 hàng, 32 mức màu/kênh; strength=0 không nâng texture/material hoặc bổ sung PBR. Giá trị global `ps1_strength` còn điều khiển vertex snapping. |
| Độ phân giải | `game/project.godot` `[display]`, `[rendering]` | Viewport thiết kế 1920×1080; `canvas_items`, aspect `expand`, window mode 2; không có key settings độ phân giải/render scale trong hợp đồng. Post-filter 360 hàng không chứng minh GPU render 3D ở 360p. Chưa đề xuất thêm lựa chọn cửa sổ/fullscreen vào pilot. |
| HUD/phụ đề | `game/ui/hud/hud.tscn`, `game/ui/theme/main_theme.tres` | Layer 10, chữ 28 px, outline 4 px; phụ đề rộng 80% màn hình, đáy cách 48 px, panel alpha 0.82. Giữ trên hậu kỳ 3D, tâm ngắm 6×6 trong viền 8×8 và vùng tương tác giữa màn hình. |
| Điện thoại | `game/ui/phone/phone_screen.tscn`, `game/scripts/ui/phone_screen.gd`, `phone_tools.gd` | Layer 12; panel nền đục `(0.025,0.04,0.055)`. Anchor X 0.61–0.98, Y 0.54–0.89 → khung lý thuyết **710.4×378 px** ở 1080p. Status 20, call 24, transcript 23, hint/map 18, tab 19 px. Khi UI thu 2/3, các cỡ này còn **13.33/16/15.33/12/12.67 px**; là rủi ro cần chụp, chưa kết luận fail. `custom_minimum_size` và nội dung có thể làm khung thật lớn hơn anchor. |
| Giấy/sổ/phiếu | `game/ui/document/document_view.tscn`, `game/scripts/ui/document_view.gd`, `paper_surface.gd`, `ch4_form.gd` | Document layer 15, body 29 px, title 36 px; chữ `#24231f`, photocopy `#d5d3c9`; handwritten dùng font variation nghiêng, không texture hóa chữ. Cỡ body ở 720p tương đương 19.33 px. Phiếu chương 4 dùng cùng paper surface, có chữ máu riêng: phải kiểm riêng, không suy kết quả từ body đen. |
| Biển trong thế giới (B) | `game/scenes/levels/floor4/corridor.tscn`: `RoomPlate_407/Mesh`; `game/scenes/levels/campus/building_b.tscn`: `KitDetail1/Plate0/Number` | Biển 407 nằm `(32, 2.42, 0.13)`, mesh có metadata `room_number=407`; metadata không phải bằng chứng chữ hiện đọc được. Ví dụ biển 101 campus là Label3D, `font_size=32`, `pixel_size=0.004`. Chưa đo pixel chữ trên màn hình hoặc khoảng cách đọc; cần camera pilot B/C, không suy từ font size thế giới. |
| Nền title | `game/ui/title/corridor.png`, `background_test.tscn`, `CREDITS.md` | Ảnh nền chụp hành lang qua PS1, nên đổi setting không tái tạo nền này. Camera nguồn `(32,1.65,1.1)` hướng −X. Thay ảnh sau khi B có pilot được duyệt và giữ hồ sơ nguồn ảnh. |
| Credits | `game/scripts/ui/title_screen.gd`: `CREDIT_SECTIONS`; `ch4_end_card.gd`; `game/localization/strings.csv`: `UI_CREDITS_*` | 5 phần KIT/AUDIO/FONT/AI/DICTIONARY dùng chung title và cuối chương 4; chữ title credits 30/26 px, cuối chương 4 28/24 px. Không có nguồn Meshy mới được nhập trong G0 này. Không đổi tác giả E thành F cho asset lịch sử. Không coi Private là CC0. |

**Đối chiếu tương phản tính từ màu nguồn:** dùng luminance sRGB `L=0.2126R+0.7152G+0.0722B` sau tuyến tính hóa, tỷ số `(L_sáng+0.05)/(L_tối+0.05)`. Với foreground theme `(0.95,0.97,1)`, panel `(0.015,0.02,0.03,0.82)` được pha alpha trong sRGB trên nền đen/trắng: **19.10:1 / 11.95:1**; giấy photocopy `#24231f/#d5d3c9`: **10.48:1**; phone foreground theme/nền đục hiện hành: **18.49:1**. Đây chỉ là phép tính màu phẳng giả định, không tính outline, antialiasing, bóng chữ, tone mapping, hiệu ứng hoặc chữ đã bị modulate; **không phải chứng nhận khả năng đọc trong Godot**. Prompt không có nền riêng phải kiểm độc lập.

### 2. Đề xuất contract để T-207/integrator chốt G1

**Bảng đề xuất, chưa có hiệu lực.** Không thêm mục nào vào `SCHEMA`/`settings.cfg` trước khi contract được ghép main và integrator cập nhật `docs/SETTINGS.md`; lane D rebase rồi mới nối backend thật.

| Section/key | Type | Default đề xuất / fallback | Range/giá trị | Writer / consumer | Điều kiện |
|---|---|---|---|---|---|
| `video.brightness` (đã có) | float | **1.0**, giữ hợp đồng hiện hành | **0.5–1.5**, UI bước 0.05 | D / B | B giữ tác dụng khi bỏ filter PS1; chỉ tác động hình 3D, không làm tối giấy/HUD. Chốt nơi áp dụng và thứ tự hậu kỳ ở G1; không tự đổi ý nghĩa sang exposure/gamma. |
| `video.ps1_strength` (đã có) | float | **1.0 đến hết G2**; fallback theo hợp đồng cũ | **0.0–1.0** | D / B | Không xóa key/menu hoặc tự ghi 0 trong G0. Quy tắc xử lý giá trị đã lưu và default khi chuyển G3 cần integrator ghi rõ. Không thêm sản phẩm PS1 song song dài hạn. |
| `video.quality_preset` (tên đề xuất) | String | **Chưa chốt**; Medium chỉ là ứng viên cho pilot, không ghi fallback cho consumer trước khi chốt | `"low"`, `"medium"` | D / B áp rendering, core chỉ phần lifecycle/project thuộc core | G1 chốt tên/default/kiểu và bảng tác dụng thực. B đề xuất chi tiết theo pilot: chất lượng bóng, ánh sáng, lọc texture/AA, render scale nếu cần. D không tự đặt tham số hoặc hứa FPS. G1 chưa đủ chi tiết thì giữ mục này pending, không hiện control. |
| `video.render_scale` (phương án tùy chọn, **chưa đề nghị bật**) | float nếu tách thành key | 1.0 là ứng viên; chưa có fallback chung | 0.5–1.0 là khoảng **đề xuất để thảo luận**, chưa thành hợp đồng | D / B, core nếu cần đổi viewport/project | Ưu tiên để preset sở hữu trước để tránh xung đột. Nếu tách key, G1 phải định nghĩa precedence với preset, cách nhận biết tùy chỉnh và tách render 3D khỏi canvas UI. Không thêm slider vào menu khi chưa cần/không có backend. |
| `video.head_bob` (đã có) | bool | **true** | true/false | D / A | Preset/migration/reset chất lượng không chạm lựa chọn chống say của người dùng. Không đổi consumer A. |

**Điểm chốt tối thiểu cần web/integrator trả lời bằng contract:**

1. B sở hữu consumer cụ thể nào cho brightness/preset trên scene hiện hành và pilot; node/path thật, đọc trong `_ready()` và khi có `settings_changed`. Một consumer áp brightness trên mỗi viewport; việc chuyển scene không được mất giá trị hoặc áp hai lần.
2. Default preset, bảng tham số Low/Medium, missing/invalid fallback và giới hạn theo pilot. Những phần chưa đủ dữ liệu phải ghi pending, không biến mục tiêu 1080p/60 thành kết quả.
3. Có cần key render scale riêng không; nếu không, chỉ có giá trị nội bộ preset. UI 2D giữ độ phân giải output khi 3D hạ độ phân giải. Không tự gọi API rendering chưa được B/core chốt.
4. Migration PS1 ở G3: khi nào bỏ control, cách xử lý key cũ, phạm vi reset. Giữ cách quay lại qua Git; không âm thầm đặt lại cấu hình trong G0/G2.

**Đối chiếu đề xuất web khi fetch ngày 11/10:** nhánh `origin/core/T-207-graphics-core-contract` tại `4fc4999`, mục 8 của `INTEGRATION_CONTRACT.md`, đang đề xuất `graphics_preset` (low/medium/high, default medium), `visual_style` (classic/realistic) và `render_scale` riêng. Những mục này **chưa ghép main/chưa có hiệu lực G1**. Bảng D dùng tên ứng viên `quality_preset`, chỉ ưu tiên Low/Medium và chưa chốt default; đây là khác biệt cần web/integrator hợp nhất trước khi triển khai, không phải hai key cùng tồn tại. D đề nghị một tên preset duy nhất, không bắt buộc High hoặc lựa chọn PS1 song song dài hạn cho pilot; nếu cần `visual_style` tạm thời phải ghi vòng đời và migration G3. Không suy ra API đã chốt từ nhánh đề xuất của web.

**Migration/reset đề xuất sau G1:**

- Giữ `Settings.set_value(section, key, value)` và signal hiện có; không cần autoload/signal mới chỉ để tạo menu. Schema mới chỉ được thêm sau SETTINGS; consumer dùng cùng default/type/range.
- Thiếu file/key: fallback khi đọc, không tự lưu hàng loạt trong startup. File parse lỗi: báo lỗi lưu hiện hành, giữ nguyên file; sai kiểu/range/NaN/Inf: dùng fallback đã chốt. Không lấy giá trị widget làm bằng chứng backend đã áp dụng.
- Chỉ cập nhật các key hình ảnh được duyệt trên ConfigFile đã load thành công; giữ nguyên locale, content warning, audio, input, head bob, reduce scares và dữ liệu khác có sẵn. Đổi preset không reset tùy chọn ngoài phạm vi đó.
- Đề xuất hành động reset riêng chất lượng/brightness; **không gọi `reset_defaults()` hiện hành** vì nó reset cả locale/audio/input. Nếu reset nhiều key, lưu một lần thành công trước các signal; save thất bại thì không emit, không áp một nửa, UI đọc lại giá trị lưu.
- Test sau G1 cần ConfigFile cũ chứa giá trị riêng của người dùng, missing/invalid values, save lỗi, reset riêng, consumer thật, tải lại scene và config. Chưa viết test giả cho preset chưa có backend.

### 3. Khả năng đọc và kế hoạch bằng chứng sau dependency

| Kiểm tra | Ma trận / cách đánh giá | Trạng thái G0 |
|---|---|---|
| Mockup cục bộ | vi/en × nền sáng/tối × 1080/720; dấu Việt, chữ dài, không tràn khung | Đã tạo artifact; kết quả kiểm bên dưới. Không thay thế ảnh game. |
| Video settings thật | Title và pause, vi/en, chuột/Tab/Shift+Tab/Enter/Esc; lỗi lưu, reset, focus sau refresh | Chờ G1/consumer. Giữ các test hiện có `test_settings.gd`, `test_pause.gd`, `test_title.gd`. |
| UI trong Godot | Output 1920×1080 với 3D native và scale thấp đã chốt; output 1280×720 riêng; nền tối/sáng và brightness 0.5/1.0/1.5 | Chưa render; không coi HTML scale là render scale 3D. Cần so chữ/phụ đề/phone/giấy bằng ảnh cùng camera. |
| Phone/HUD | Cuộc gọi/map/CCTV, lựa chọn dài, phụ đề hai dòng, dấu Việt; cuộn và timer; kiểm khoảng giữa phone/phụ đề, tâm ngắm/prompt | Chưa kiểm thực tế. Không đổi lời, thời lượng, pause/control lock để làm ảnh đẹp. Ưu tiên kiểm chữ 18/19 px khi output 720p. |
| Giấy/phiếu chương 4 | Các paper style, tên máu, dấu, đoạn dài, vi/en; không cắt dấu hoặc phải tăng sáng thế giới để đọc được | Chưa kiểm trên pilot. Giữ text sống và nội dung CSV đã duyệt, không dùng chữ AI trên texture. |
| Biển 407/hành lang | B/C cung cấp camera trước/sau cùng vị trí trong bốn chương; có ánh sáng bật/tắt, tiếp cận bằng InteractRay/đi bộ | Chưa có pilot/camera. D cung cấp yêu cầu chữ và localization; B sở hữu model/Label3D/decal. Không thay collider, marker hoặc thêm gợi ý luật. |
| Credits | Title/cuối chương 4, vi/en, đầu/cuối vùng cuộn; đối chiếu nguồn thực nhập với tên tác giả/công cụ/license | Đã kiểm cấu trúc nguồn; chưa có asset mới cần thêm. Khi B/F nhập asset mới cần hồ sơ cụ thể; không cập nhật theo dự định mua Meshy. |

Test liên quan đã có để tái sử dụng: `game/tests/ui/test_settings.gd` (default/type/save-before-signal/reset), `test_pause.gd`, `test_reading.gd`, `test_phone.gd`, `test_phone_missions.gd`, `test_ch4_ui.gd`, `test_title.gd`; consumer PS1: `game/tests/levels/test_ps1_filter.gd`. Các test này **chưa chứng minh preset mới hoặc hình ảnh pilot**.

### 4. Yêu cầu thay đổi ngoài phạm vi

- **Web T-207:** đưa bảng đề xuất mục 2 vào `INTEGRATION_CONTRACT.md`, ghi phần pending và consumer/node thật từ B; không coi bảng ở Handoff là API đã duyệt.
- **Integrator:** chốt và cập nhật `docs/SETTINGS.md` sau review G1, quyết định migration/reset G3; lane D không sửa SETTINGS/project/rendering/STATUS/DECISIONS/Review.
- **B T-209:** cung cấp điểm áp brightness sau PS1, tác dụng preset và cảnh pilot/biển có nguồn chữ riêng; gửi asset ID + tác giả/công cụ/license/CREDITS thật để D cập nhật hiển thị. Nền title mới chỉ sau pilot được duyệt.
- **C T-210 / integrator:** xếp lượt Windows full test/check/render; cung cấp camera pilot/ma trận output và render scale để so ảnh. Không chạy bot chương 3–4 hoặc FPS trong T-211 G0.
- Không yêu cầu mua/kết nối Meshy, tiêu credit hay cài MCP/plugin để hoàn thành phần chuẩn bị này.

### 5. Test/check, commit và điểm dừng

- `git diff --check`: **PASS** sau khi cập nhật đầu ra G0. Phạm vi diff chỉ card này (checklist/Handoff) và mockup mới trong `game/ui/graphics_upgrade/`.
- Mockup đã chạy bằng Edge headless, `--disable-gpu`, profile riêng trong `build/T-211/` (không khởi chạy Godot): **`RESULT: mockup browser 8 cases PASS (not Godot)`**. Ma trận vi/en × dark/light × 1920/1280 kiểm font Be Vietnam tải được, mọi nhãn có text, không tràn ngang/vượt panel, phone không chồng subtitle. Báo cáo cục bộ: `build/T-211/mockup-qa.json`; HTML probe và DOM kết quả nằm cùng thư mục. Đây chỉ là kiểm HTML, không được cộng vào số test Godot.
- Đã xem trực tiếp hai ảnh trình duyệt: `build/T-211/mockup-vi.png` (vi/tối/1080p), `build/T-211/mockup-en-light-720.png` (en/sáng/720p). Hai ảnh đều hiện chữ/khung đúng trong bản mẫu; ảnh và log dưới `build/` không đưa vào Git. Có thể tái tạo cùng trạng thái bằng mở mockup với query `?locale=vi&background=dark&resolution=1920` hoặc `?locale=en&background=light&resolution=1280`. Sáu tổ hợp còn lại chỉ kiểm DOM/bố cục, chưa xem ảnh thủ công từng tổ hợp.
- **G0 đã qua full test/check, sẵn sàng bàn giao web/integrator review G1.** Ngày 11/10 chủ dự án báo C hoàn tất và integrator bàn giao lượt Windows cho D. Đã kiểm không có tiến trình Godot khác trước khi bắt đầu; hai lệnh chạy tuần tự, không chạy render/FPS/bot riêng.
- Full `pwsh tools/test.ps1`: **`RESULT: 722 passed, 0 failed`**, exit **0**; 11/10/2026 **02:59:33–03:20:15 UTC+07**. Log: `build/T-211/full-test.log`; thời gian/exit: `build/T-211/full-test-result.json`.
- Full `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, **334 script parse PASS**, exit **0**; 11/10/2026 **03:20:43–03:29:01 UTC+07**. Log: `build/T-211/full-check.log`; thời gian/exit: `build/T-211/full-check-result.json`. Log ở `build/` chỉ lưu cục bộ, không đưa vào Git. Đây là lượt kiểm của D trên base `e3ed54a`, không lấy kết quả main làm thay.
- Cảnh báo đã ghi nhận: test có **9 WARNING**, check có **2 WARNING**. Hai cảnh báo chung là UID `green_paint.png` không hợp lệ trong `wall_door.glb`/`wall_straight.glb`, Godot dùng đường dẫn text thay thế; gửi B/integrator kiểm asset, D không sửa ngoài vùng. Bảy cảnh báo test còn lại đến từ ca dữ liệu không hợp lệ/scene độc lập: flag, checkpoint, document thiếu, hiding spot, puzzle station và hai light switch chưa gán light. Không có `ERROR`/`SCRIPT ERROR`; không giấu cảnh báo dưới kết quả PASS.
- Godot tự ghi lại định dạng `game/default_bus_layout.tres` trong lượt kiểm; file này sạch trước lượt, đã đối chiếu diff rồi khôi phục đúng HEAD sau lượt, không đưa thay đổi ngoài phạm vi vào commit. Không thay mã chạy game để làm test đạt.
- Sau check đã xác nhận không còn tiến trình Godot (11/10 khoảng 03:29 UTC+07). **D đã nhả lượt Godot.**
- Chưa render Godot, chưa chơi tay, chưa đo FPS/VRAM, chưa kiểm pilot hoặc preset mới. Không export.
- Nhánh bàn giao: `lane-d/T-211-graphics-settings-readability`; commit chứa Handoff này: **`T-211: document G0 graphics settings and readability proposal`**. Chỉ gồm card (checklist/Handoff) và mockup HTML; không push main, không mở PR.
- **G0 không còn bị chặn; T-211 chưa done.** G1 trở đi còn chờ contract ghép main + SETTINGS được integrator cập nhật; G2/G3 chờ pilot/duyệt, không tự triển khai trước. Fetch ngày 11/10 xác nhận `origin/main` vẫn `e3ed54a`; các nhánh G0 khác mới là đề xuất, chưa đủ điều kiện triển khai setting/backend mới.

## Review (integrator)

### 11/10/2026 — Astra, D-079

- Nhận **G0** từ lane D, commit `aef26cb`; ghép cùng năm nhánh còn lại. **Chưa đánh dấu toàn bộ T-211 done.**
- Nhận khảo sát và HTML vi/en; không là menu Godot hoặc bằng chứng preset hoạt động. G1 dùng một tên ứng viên graphics_preset, Low/Medium; chưa cấp key/default/backend mới. Chờ consumer brightness/preset B và SETTINGS của integrator. Reset riêng video phải giữ cấu hình khác; chưa dùng reset_defaults toàn bộ.
- Phạm vi diff đạt; không nới test, không đổi gameplay/default. Không sửa code lane trong lượt review này.
- Full Windows test/check bản ghép và kiểm `--t202-integration` là điều kiện trước commit. Kết quả thực/thời điểm/log ở message commit `D-079`; không dùng số test lane riêng thay kết quả tích hợp.
- Đọc [báo cáo chung và yêu cầu G1](../handoff/REVIEW_G0_2026-10-11.md), làm phần Review của lane trên nhánh hiện có sau fetch/rebase; không tự dùng contract G0 như API production đã chốt. Chưa chạy Meshy trả phí hoặc FPS/bot.

### 11/10/2026 — cập nhật D-080, Astra

- Nhà cung cấp hiện hành: **Tripo AI**. Tiếp tục phần việc trong [hướng chuyển đổi](../handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md); không làm lại G0 hoặc đổi source/credits lịch sử.
- Tripo Studio/API tách ví; đường thủ công không cần client API. B/C cập nhật brief/metadata/QA đúng dịch vụ; A/D/F/web giữ ràng buộc gameplay đã review. Chưa cấp ngân sách/ngoại lệ license hoặc triển khai API live.

### 11/10/2026 — D-081, đổi đầu mối core

Astra làm thay Claude web ở T-207; gửi yêu cầu core/contract về Astra. Đọc contract G1 cập nhật và [bảng việc từng lane](../handoff/T207_G1_ASTRA_2026-10-11.md), tiếp tục task/nhánh hiện có. Giữ lịch sử G0; không sửa file lane khác hoặc coi quy ước mới là bằng chứng validator/asset đã đạt.
