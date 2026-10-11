# T-211 — phản hồi Review G0, chuẩn bị settings G1

Ngày 11/10/2026, lane D. Chuẩn bị từ `acbf771` (D-079/D-080), đối chiếu bổ sung trên base **`d6d76f3` (D-081)**. Đây là đề xuất triển khai để B/Astra chốt; không phải hợp đồng settings đã có hiệu lực. **Astra (integrator) tiếp nhận T-207 thay Claude web theo D-081; yêu cầu core/contract của D gửi về Astra qua Handoff card.** G0 và phần migration/reset đã chuẩn bị được giữ, không tạo lại mockup.

Nguồn quyết định: [Review G0](../../../docs/handoff/REVIEW_G0_2026-10-11.md), [chuyển sang Tripo](../../../docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md), [Astra tiếp nhận T-207](../../../docs/handoff/T207_G1_ASTRA_2026-10-11.md), [contract G1 mục 6](../../../docs/design/graphics/INTEGRATION_CONTRACT.md), [SETTINGS hiện hành](../../../docs/SETTINGS.md). Phần settings G1 vẫn pending, độc lập G1 đạo cụ tĩnh/balo; D-081 chốt quy ước triển khai balo không mở key/control video.

## 1. Một tên preset, chưa thêm cấu hình

| Mục | Phản hồi D sau Review | Còn cần chốt |
|---|---|---|
| `video.graphics_preset` | Nhận **một tên ứng viên này**, String, ưu tiên `low`/`medium`; bỏ tên đề xuất `quality_preset` khỏi phần triển khai sắp tới | Default, fallback và thông số thực từng mức do B/Astra chốt; chưa ghi vào SCHEMA hoặc file người dùng |
| `video.brightness` | Giữ float **1.0**, range **0.5–1.5**, bước UI **0.05** theo hợp đồng đã có | Một consumer B cho mỗi viewport, lifetime khi vào/rời pilot và sau load scene |
| `video.ps1_strength` | Giữ hợp đồng hiện hành **1.0**, **0–1** trong production | Quy tắc G3 cho key cũ, không tự xóa/đổi default hoặc ghi 0 trong migration |
| `visual_style`, `render_scale` riêng, High | Không đưa vào bản triển khai dự kiến ở đợt này | Chỉ xem xét lại nếu integrator mở phạm vi; không tự thêm lựa chọn ẩn/disabled vào menu |

Đổi nhà cung cấp model không tạo thêm key settings. Không lưu provider, ví credit, API key, license hoặc đường dẫn GLB vào `user://settings.cfg`.

## 2. Đối chiếu consumer B thực tế

| Đường dẫn/hàm hiện có | Hành vi đọc từ mã nguồn ở base này | Yêu cầu phối hợp |
|---|---|---|
| `game/rendering/ps1_filter.gd`: `_ready`, `reload`, `_on_settings_changed` | Đọc ConfigFile trực tiếp, validate float/range; áp brightness vào `$Screen.material`; nghe `video.brightness`/`ps1_strength`; cập nhật global snapping | Giữ consumer production hiện hành tới mốc được duyệt; không để consumer mới nhân brightness lần nữa trên cùng hình |
| `game/scenes/levels/graphics_pilot/material_pilot.gd`: `_ready`, `_settings_changed` | Đọc brightness qua `Settings.get_value`; tạo CanvasLayer 5/ColorRect bằng mã, không có NodePath được đặt tên để D bind; signal đổi brightness cập nhật `screen` | D tiếp tục chỉ ghi cấu hình và phát signal hiện có; không truy cập node động hoặc gọi `set_mode` từ menu |
| Cùng script: `set_mode(pbr)` | Đổi material, strength hậu kỳ 0/1, global `ps1_strength` 0/1; giữ brightness đọc được. Đây là chọn before/after của fixture, **không phải backend Low/Medium** | B cung cấp consumer preset thật và bảng tác dụng sau pilot; không ánh xạ `low=false`, `medium=true` vào `set_mode` |
| Cùng script: lifecycle | Tại base này không có `_exit_tree()` khôi phục global `ps1_strength`; signal tự hết khi receiver bị giải phóng không khôi phục global | B xử lý quyền sở hữu/cleanup global, xác nhận không để pilot ảnh hưởng scene tiếp theo hoặc consumer production còn sống |

Đề nghị B bàn giao: file/node chịu trách nhiệm, key được nghe, validation/default dùng chung, số consumer trên viewport, cách khôi phục global khi rời pilot, hành vi khi scene thay/reload, bằng chứng consumer áp giá trị thực. Chưa tự chọn phương án snapshot/restore global hay API mới thay B. Cần giữ giá trị settings người dùng nếu họ đổi brightness khi pilot đang mở.

**Dependency mới đã đọc, chưa ghép vào base:** nhánh B `origin/lane-b/T-209-realistic-art-pilot` tại `21f2f9b` đổi pilot sang node `ShaderGlobalsOverride` tên `PilotShaderOverride` và đặt `params/ps1_strength` qua override thay vì ghi global trực tiếp. Đây là lời giải cleanup do B cung cấp, không phải thay đổi D viết; D không cherry-pick hoặc tự đánh dấu đã kiểm trên main. Astra review/ghép trước, D/C kiểm vòng đời thực sau khi có dependency. Sửa cleanup không đồng nghĩa có backend Low/Medium hoặc đã duyệt default/settings mới.

## 3. Luồng lưu, migration và reset đề xuất

Điều kiện bắt đầu viết mã: SETTINGS được integrator cập nhật và ghép main; contract B nêu consumer/backend thật, default/range đã chốt. Khi đủ điều kiện D rebase, cập nhật vùng UI và kiểm cả consumer. Hiện không thêm hàm public/reset control mới.

1. **Startup/đọc:** không ghi file. Thiếu file hoặc key dùng default trong SETTINGS đã duyệt. Sai kiểu/range/không hữu hạn đọc fallback mà không tự sửa file. Preset chưa có hợp đồng thì không được đọc bằng default tự đặt.
2. **Đổi một setting:** dùng luồng `Settings.set_value` hiện có: load ConfigFile → validate đầu vào → cập nhật đúng key → save → áp phần D sở hữu → emit `settings_changed`. B đọc lại giá trị đã lưu và áp hình ảnh; UI refresh từ store. Không emit trước save, không gọi consumer qua NodePath.
3. **Migration:** file cũ không có preset vẫn được load; fallback mới chỉ sau khi hợp đồng có hiệu lực. Không dùng `clear()`/tạo schema mới đè file cũ, không gọi reset toàn bộ và không ghi mọi default lúc khởi động. Không tự diễn giải `quality_preset`/`visual_style` trong một file lạ như alias được duyệt. Key cũ/không biết giữ nguyên khi ghi một key hợp lệ, chưa thêm alias hoặc version key.
4. **Reset riêng hình ảnh:** chuẩn bị allowlist dự kiến `brightness` và `graphics_preset`; chỉ hiện hành động này sau khi cả hai mục được duyệt/có backend. Default preset còn pending. Không reset nguyên section `video` vì chứa `head_bob` và legacy `ps1_strength`. Chính sách xóa/chuyển legacy PS1 thuộc quyết định G3 riêng.
5. **Reset nhiều key:** load một bản ConfigFile, thay đúng allowlist, save một lần. Chỉ sau save thành công mới thông báo các key được đổi; callback đầu tiên phải đọc thấy toàn bộ giá trị mới. Đây là yêu cầu thứ tự quan sát, chưa hứa khả năng phục hồi mất điện/ghi đĩa nguyên tử. Không gọi tuần tự nhiều `set_value` tạo trạng thái nửa reset.
6. **Lỗi load/save:** giữ mã lỗi và hiện lỗi lưu bằng UI hiện hành, không emit hay áp một nửa giá trị, widget đọc lại store. Không tự xóa/tạo lại file parse lỗi. Test lỗi save phải xác minh file trước/sau; nếu cơ chế ghi không giữ được file khi lỗi thì báo để bổ sung phương án ghi an toàn trước khi bật control.

Danh sách cần bảo toàn theo **giá trị và kiểu** sau đổi/reset video: `ui.locale`, `ui.content_warning_seen`, cả sáu key audio, `input.mouse_sensitivity`, `video.head_bob`, `accessibility.reduce_scares`, `video.ps1_strength` và section/key lạ đã có. Không hứa giữ byte/comment/thứ tự file sau một lần save thành công vì ConfigFile có thể tuần tự hóa lại; file chỉ được đọc hoặc load thất bại phải không bị ghi. Không tạo key lạ mới trong production.

## 4. Ma trận kiểm sau khi backend được chốt

Dùng user data cách ly của `tools/test.ps1`, không dùng settings thật. Tái sử dụng `game/tests/ui/settings_test_case.gd` để trả lại file/locale/audio/mouse/pause sau mỗi ca; quan sát signal và consumer thật thay vì chỉ nhìn widget. Các ca dưới đây là kế hoạch, **chưa viết/chưa chạy** cho preset mới.

| Ca | Dữ liệu đầu vào / thao tác | Kết quả cần quan sát |
|---|---|---|
| File thiếu | Mở settings và load scene | Không tự tạo file; consumer áp default đã duyệt; không phát signal giả |
| File cũ đầy đủ | `locale="en"`, warning=true, audio khác mặc định, sensitivity=0.003, head_bob=false, reduce_scares=true, brightness=1.25, ps1_strength=0.4; chưa có preset | Mở menu không ghi file; chọn một preset chỉ thêm/đổi key đã duyệt, giữ nguyên các giá trị khác |
| Key sai/thiếu | Brightness là int/string/NaN/Inf hoặc ngoài 0.5–1.5; preset sai kiểu/giá trị | Đọc fallback đã chốt, không sửa file khi chỉ đọc; phân biệt setter chấp nhận int rồi ép float/clamp với reader float nghiêm ngặt hiện hành |
| Reset riêng video | File cũ ở trên, thêm preset hợp lệ và section/key sentinel có sẵn | Chỉ brightness/preset về default; head_bob/PS1 và toàn bộ dữ liệu ngoài allowlist giữ nguyên; callback đầu đọc được cả hai giá trị đã lưu |
| Parse/load lỗi | File không đọc được hoặc sai cấu trúc | Trả lỗi, không xóa/ghi đè/emit; có thông báo lỗi lưu; không áp giá trị trên widget như thể đã lưu |
| Save lỗi | Gây lỗi tại bước lưu trong fixture cách ly | Không signal/áp backend; xác minh nội dung file không bị hỏng và lần đọc sau; chưa có cơ chế tiêm lỗi thì ghi thiếu bằng chứng, không giả PASS |
| Chuyển scene | Đổi brightness, mở/rời pilot, load lại scene production | Giá trị lưu còn nguyên, đúng một consumer áp mỗi viewport; global snapping không rò từ pilot; độ sáng không bị nhân đôi |
| Lặp tín hiệu/lifecycle | Thay brightness nhiều lần, đóng/mở scene/menu | Không tích lũy callback/consumer, không ghi ngoài D, không mất giá trị sau reload |
| UI sau backend | vi/en; keyboard/chuột, focus, pause, lỗi lưu, reset | Control có tác dụng thật; chữ giấy/phone/subtitle không bị hạ độ phân giải cùng 3D; không che tâm ngắm/prompt |

Các test hiện có trong `test_settings.gd` vẫn kiểm hợp đồng cũ. Ca reset toàn bộ hiện tại được giữ nguyên vì nó phục vụ hành động reset hiện hành; không sửa kỳ vọng của ca đó để giả lập reset riêng video chưa được viết.

### 4.1. Yêu cầu readability gửi B/C/Astra theo contract mục 6

Đây là kế hoạch bằng chứng khi có consumer/cảnh phù hợp và lượt renderer được cấp, **chưa thực hiện trong lượt full test/check hiện tại**. Không đặt render scale mới hoặc chọn default preset để dựng ảnh trước G1.

| Phần cần kiểm | Điều kiện / bằng chứng mong đợi | Owner |
|---|---|---|
| Tách 3D/UI | Một lớp áp brightness vào hình 3D dưới HUD/phone/giấy/menu; không dùng modulate toàn root UI, không nhân brightness hai lần. Đối chiếu layer 5 với 10/12/15/20 hiện hành, không coi chỉ đúng số layer là đủ nếu compositor thay đổi | B cung cấp consumer; D kiểm UI; C ghi cảnh/camera |
| Hai loại độ phân giải | Output 1920×1080: đối chiếu render 3D native và mức thấp **do backend đã duyệt** trong khi canvas UI giữ output; output 1280×720 là phép kiểm riêng của chữ nhỏ/bố cục, không thay thế phép kiểm render 3D thấp | B công bố mức thực; C chụp đúng điều kiện; D xem chữ |
| Nền và độ sáng | vi/en trên nền pilot sáng/tối tại brightness 0.5/1.0/1.5, cùng camera và trạng thái đèn. Phone/giấy/subtitle giữ độ sáng/độ rõ của UI khi brightness 3D thay đổi | B/C dựng đối chiếu, D kiểm các vùng chữ |
| Nội dung khó đọc | Tiếng Việt có dấu, phụ đề hai dòng, phone transcript/map/CCTV 18–24 px, giấy 29 px, chữ máu/phiếu chương 4, nút/nhãn EN dài; ghi ảnh và vùng bị cắt/tràn hoặc thiếu nét | D dùng dữ liệu hiện hành; không sửa lời hay tạo gợi ý luật |
| Tâm ngắm và thao tác | Prompt không bị phone/subtitle che; scroll/focus/chuột/Tab/Shift+Tab/Enter/Esc, mở/đóng pause vẫn đúng. Giấy kiểm riêng theo cơ chế reading overlay thật | D; giữ input lock/pause/timing hiện có |
| Rời pilot/load lại | Giá trị brightness đã lưu còn nguyên, scene mới đọc lại đúng, override hết hiệu lực; xác nhận shader cũ và chữ UI không đổi ngoài phạm vi | B giữ lifetime, D/C quan sát sau khi B được ghép |

Bằng chứng cần ghi locale, output thật, mức render 3D/backend, brightness, mode fixture, camera/trạng thái đèn và commit. Không coi tỷ số màu tính từ mã hoặc HTML 8 ca G0 là PASS ảnh Godot; không suy FPS/VRAM từ ảnh hoặc full test. Biển trong thế giới do B gắn chữ/localization riêng; D kiểm đọc được, không tạo chữ AI trên texture hoặc thay collider để cải thiện ảnh.

## 5. Credits theo Tripo, chỉ khi có asset thật

Quy trình nhận nguồn ưu tiên **Tripo Studio thủ công → GLB/texture → Blender → Godot**. D không cần key/client API để chuẩn bị hoặc hiển thị credits. Studio/API tách ví; không sao chép giá hoặc ngân sách Meshy sang Tripo. Chưa có ngân sách/key/ngoại lệ license; không có tác vụ trả phí, plugin hoặc MCP trong phần việc này.

Khi B nhập asset thật, D cần hồ sơ do B/C sở hữu, không tạo schema manifest song song:

- Asset ID, đường dẫn file/scene đã nhập, hash/phiên bản đủ đối chiếu với nguồn bền vững.
- Nguồn tạo **Tripo Studio** hay **Tripo API**, người tạo/chuẩn hóa, model version và ngày tạo; ID/link tác vụ hoặc model nếu nền tảng cung cấp. Nếu thiếu ID thì ghi rõ thiếu, dùng bằng chứng xuất/nguồn thay thế theo schema được duyệt; không bịa task ID cho thao tác Studio.
- Nguồn/quyền ảnh đầu vào, bằng chứng license áp dụng cho asset và quyết định review/ngoại lệ nếu cần. Quyền thương mại Paid không tự là CC0/CC-BY.
- Đường dẫn `CREDITS.md` của asset và liên kết hồ sơ provenance; credit thực theo đúng ví thuộc B/C/operator, không hiển thị khóa hoặc thông tin ví trong UI credits.

Chỉ sau khi asset được nhập và hồ sơ được chấp nhận, D đề xuất key vi/en mới theo cấu trúc credits hiện có, giữ tên tác giả/nguồn của asset CC0 cũ. Kiểm cả title (`title_screen.gd`) và thẻ cuối chương 4 (`ch4_end_card.gd`), đầu/cuối vùng cuộn. Nếu đoạn credits cũ cần sửa thuộc người khác, gửi integrator thay vì tự ghi đè key. Hiện chưa thêm chữ Tripo vào credits người chơi hoặc sửa block lời sinh tự động.

## 6. Điểm bàn giao

- **Astra (integrator, tiếp nhận T-207):** hợp nhất tên `graphics_preset` và phần settings pending; chốt allowlist/default/reset/migration trong SETTINGS trước khi D triển khai. G1 balo không phải đợi phần này. Mục 1–4 là yêu cầu kỹ thuật D gửi Astra; không giao tiếp phần core mới cho Claude web.
- **B:** xác nhận consumer brightness duy nhất/lifetime pilot theo mục 2, cung cấp backend preset và tham số sau pilot. D chưa có dependency đủ để bật control.
- **Integrator:** đã cấp lượt Windows cho D sau C, chạy full test rồi check trên base D-081; render vẫn cần lượt riêng và không chạy trong lượt này. Kết quả thực ghi ở Handoff T-211 sau khi hai lệnh kết thúc; 722/0 và check 334 script của G0 không thay thế lượt mới.
- **Phạm vi hiện tại:** tài liệu chuẩn bị này và Handoff card; chưa sửa runtime, shader, cấu hình người chơi, mockup G0 hoặc credits lịch sử. Không mở G2/G3 hoặc đánh dấu T-211 done.
