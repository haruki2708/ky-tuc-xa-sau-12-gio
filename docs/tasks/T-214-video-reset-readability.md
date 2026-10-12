# T-214 — Nâng cấp giao diện đẹp (kinh dị, gần chân thực) + đặt lại riêng Hình ảnh + chữ dễ đọc ở 720p
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done (D-091) | Agent: lane D; commit/push: Claude làm thay (D hết hạn mức 12/10)
- Nhánh: `lane-d/T-214-video-reset-readability`
- Phụ thuộc: T-211 (khảo sát G0/D-082). Không phụ thuộc hợp đồng `graphics_preset` (vẫn chờ T-207/T-213).
- Prompt: `docs/handoff/lane-d.md` mục 4.
- Yêu cầu chủ dự án (12/10): "giao diện thật đẹp, không quá đơn giản như trước".

## Hướng thiết kế
Phong cách **kinh dị ký túc xá Việt Nam, gần chân thực**, khớp hướng đồ họa mới (D-076): tối, ấm lạnh tương phản (ánh đèn tuýp xanh lạnh, giấy ố vàng, đỏ cảnh báo dùng tiết chế), chất liệu thật (giấy, kim loại sơn, kính màn hình) thay cho hộp màu phẳng; chuyển động tinh tế (mờ dần, chập chờn nhẹ, rung rất nhẹ khi có sự cố), không lòe loẹt. Chữ rõ ràng trên hết: đẹp nhưng không được khó đọc.

## Việc (theo thứ tự ưu tiên; commit sau mỗi việc)
1. **"Đặt lại hình ảnh"** (nhỏ, làm trước): `game/scripts/ui/settings.gd` thêm `reset_section(section)` chỉ đưa khóa của một mục `SCHEMA` về mặc định; nạp file cũ, giữ mọi mục/khóa khác (kể cả khóa lạ), **lưu một lần trước khi phát tín hiệu**, lỗi lưu thì không phát tín hiệu; nút "Đặt lại hình ảnh"/"Reset video" có hộp xác nhận trong settings panel; key vi/en; test (giữ ngôn ngữ, âm lượng, chuột, `content_warning_seen`, khóa lạ; thứ tự lưu/tín hiệu; lỗi lưu).
2. **Màn hình tiêu đề**: nền 3D động (cảnh hành lang tầng 4 ban đêm có sẵn, chỉ instance để xem, camera trôi chậm, đèn tuýp chập chờn) hoặc nền ảnh chụp từ cảnh đó nếu nền 3D quá nặng; logo tên game có chữ đẹp, phong cách; menu có trạng thái hover/focus rõ (phím, chuột, tay cầm); hạt nhiễu phim nhẹ + viền tối (vignette); chuyển cảnh mờ dần.
3. **Menu tạm dừng + Cài đặt**: khung nền trong mờ có chất liệu (nhiễu/giấy/kim loại), viền mảnh, tab mục có biểu tượng, thanh trượt/nút bật tắt tùy biến cùng phong cách, khoảng cách đều, hiệu ứng mở/đóng 150–250 ms.
4. **Điện thoại trong game**: trông như smartphone thật (viền máy, góc bo, thanh trạng thái giờ/pin/sóng, biểu tượng tab như ứng dụng, ánh sáng màn hình nhẹ), giữ nguyên mọi tab, nút, dữ liệu và luồng chương 1–4.
5. **Giấy tờ, ghi chú, phụ đề, gợi ý tương tác (E), màn chết, thẻ tên chương**: nền giấy thật (texture CC0), chữ đánh máy/viết tay hợp ngữ cảnh cho giấy tờ (vẫn dễ đọc), gợi ý phím có biểu tượng phím, thẻ chương và màn chết kiểu điện ảnh.
6. **Độ dễ đọc**: chụp 1280×720 và 1920×1080 (vi và en) các màn trên; mọi chữ **≥ 16 px ở 720p**, độ tương phản đủ (chữ trên nền tối/ảnh), không tràn chữ.

## Ràng buộc
- **Font**: chỉ font giấy phép OFL/CC0/CC-BY **có đủ dấu tiếng Việt** (kiểm thật các chữ ă â đ ê ô ơ ư và 5 dấu); ghi `game/assets/fonts/CREDITS.md` (URL, tác giả, giấy phép, SHA-256) và kèm file giấy phép. Texture UI: CC0/CC-BY, ghi credits.
- **Không đổi nội dung chữ**, key cũ, luồng chơi, luật, lời thoại; chỉ thêm key `UI_` mới khi cần (vi + en).
- Giữ tên node/đường dẫn mà script và test đang dùng; mọi test UI cũ (`test_settings`, `test_pause`, `test_title`, `test_phone*`, `test_reading`, `test_ch4_ui`…) vẫn đạt; bổ sung test cho phần mới khi hợp lý.
- Không sửa core (`game/scripts/core/`), cảnh chương, `project.godot`. Cần tín hiệu/autoload mới thì ghi "Yêu cầu thay đổi" trong Handoff.
- Nền 3D màn tiêu đề không được làm chậm vào game; nếu tốn tài nguyên thì dùng ảnh chụp. Không đo FPS, không bot.
- Âm thanh hover/click: không tự thêm (vùng lane F); ghi đề xuất vào Handoff.

## Đầu ra
- Ảnh **trước/sau** từng màn (720p và 1080p, vi và en) trong `game/ui/graphics_upgrade/t214/` hoặc `build/T-214/` (ảnh nhị phân trong repo qua LFS, ≤ 10 MiB/file), bảng cỡ chữ 720p, danh sách font/texture và giấy phép.
- Theme dùng chung (`game/ui/theme/`) để các màn thống nhất, thay vì chỉnh lẻ từng màn.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/localization/strings.csv` (thêm key), `game/tests/ui/`, card này (Handoff).

## Checklist hoàn thành
- [x] 1. Đặt lại hình ảnh + test
- [x] 2. Màn tiêu đề
- [x] 3. Tạm dừng + Cài đặt
- [x] 4. Điện thoại
- [x] 5. Giấy tờ, phụ đề, gợi ý E, màn chết, thẻ chương
- [x] 6. Chữ ≥ 16 px ở 720p, ảnh trước/sau
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS (lượt D, mã cuối: 753/753, check 0)
- [x] Handoff

## Handoff (agent điền)

### 12/10/2026 23:20 — Claude làm thay (commit/push)
Lane D hết hạn mức khi lượt full test/check trên mã cuối còn đang chạy. Chủ dự án nhờ integrator đảm nhiệm tiếp. Claude không sửa mã của D: chờ lượt chạy xong, sao chép đúng các file thay đổi/chưa theo dõi của workspace D (469 file, so lại sau khi check xong, không lệch) lên commit `5adf732` của D, ghép phần đề bài của card integrator với checklist/Handoff của D, rồi commit và push nhánh `lane-d/T-214-video-reset-readability`.
- `build/T214/full-test.log`: **`RESULT: 753 passed, 0 failed`**, exit 0, 22:45:56–23:06:33.
- `build/T214/full-check.log`: **`RESULT: check 0 error(s)`**, exit 0, 23:06:33–23:15:54.
### 12/10/2026 — ghi nhận ban đầu, trước renderer/test (lịch sử)

- Workspace ban đầu sạch. Đã fetch và tạo `lane-d/T-214-video-reset-readability` từ `origin/main` `25e3bfe`. T-211 giữ nguyên. Card chưa có trên origin/main lúc bắt đầu; tệp này chỉ ghi checklist/Handoff theo prompt chủ dự án, sẽ nhận nội dung card của integrator khi xuất hiện.
- Phần 1 đã viết: `Settings.reset_section(section)` reset các khóa đã biết trong đúng section, giữ khóa lạ/các section khác; load file cũ, save một lần rồi mới áp/emit. Nút `Footer/ResetVideo` và hộp xác nhận trong panel dùng chung title/pause. Reset video gồm ba khóa hiện có: head_bob, brightness, ps1_strength; không thêm setting mới. Chính sách giữ acknowledgement của reset toàn bộ vẫn nguyên.
- Key mới: `UI_RESET_VIDEO`, `UI_RESET_VIDEO_CONFIRM`, đủ vi/en. Test mới kiểm bảo toàn giá trị/kiểu và khóa lạ; file thiếu; section không hợp lệ; dữ liệu video sai; lỗi lưu giả lập tại ranh giới I/O; xác nhận/hủy và giữ tùy chọn ngoài video. Chưa chạy test mới.
- Chủ dự án đã chuyển bàn giao lượt renderer ảnh trước từ integrator Claude. Kiểm máy còn full test `D:\GAME_DEMO` PID 13128/16780, D chưa chạy Godot và không can thiệp tiến trình lane khác; chờ lượt thực trống. Sau ảnh trước sẽ nhả; ảnh sau/full test/check cần lượt mới.
- `RESULT test.ps1`: **chưa chạy**. `RESULT check.ps1`: **chưa chạy**. Chưa có ảnh trước/sau hoặc chứng nhận cỡ chữ. Chỉ kiểm tĩnh `git diff --check` tại phần 1.
- Phần 2–6 đang chuẩn bị. Font/texture mới sẽ ghi nguồn, hash và giấy phép trong CREDITS vùng D. Không sửa STATUS/DECISIONS/Review, core, project.godot, cảnh chương hoặc workspace khác.
- Yêu cầu ngoài phạm vi: lane F cân nhắc âm hover/click nhẹ; D không thêm âm. Các câu hỏi contract và lượt Godot gửi integrator Claude qua chủ dự án. Chưa có yêu cầu signal/autoload mới.

### 12/10/2026 — cập nhật sau renderer và test UI

**Đã làm theo thứ tự 1–6:**

1. Commit phần reset `5adf732`: `Settings.reset_section(section)` chỉ thay khóa SCHEMA trong section được chọn, giữ mọi khóa lạ/các section khác; save đúng một lần trước apply/signal, lỗi lưu không emit. Reset video dùng ba khóa hiện có; không thêm preset/render scale/backend. Có xác nhận/hủy, trả focus về nút sau hủy, thông báo lỗi lưu sẵn có. Test kiểm cấu hình cũ, kiểu giá trị, giữ dữ liệu ngoài video, file thiếu, section sai, save lỗi giả lập và xác nhận/hủy. Test hủy chờ hide deferred của ConfirmationDialog; không sửa/nới assert cũ.
2. Nền title là ảnh mới 1920×1080 từ cảnh hành lang tầng 4 sẵn có, scene chụp riêng, camera và đèn bù nằm trong vùng UI. Shader trôi nhẹ, chập chờn nhỏ, grain/viền tối; giảm hù dọa tắt chuyển động. Logo SemiBold, chia dòng theo vi/en mà giữ key/chữ gốc, focus/hover rõ; fade chuyển cảnh 220 ms. Phương án ảnh chụp giữ chi phí title gọn, chưa đo chênh lệch FPS với nền 3D sống.
3. Theme chung giấy/kim loại/kính, bảng màu xanh lạnh–kem–đỏ tiết chế; nút/slider/toggle/scrollbar và focus đồng bộ. Settings có ba tab biểu tượng, giữ nguyên các node điều khiển cũ và phím Back. Mở/đóng pause/settings 180 ms, pause/input đổi đồng bộ như trước; lớp ảnh đóng không sở hữu input/signal. Đã bỏ cách duplicate cây chứa Window sau khi test phát hiện crash.
4. Điện thoại có viền/góc bo/loa/camera trước/home bar, phản sáng kính, giờ/pin/sóng, icon tab. Chữ trạng thái, transcript, lựa chọn, sơ đồ, dự đoán, tin chương 4 tối thiểu 24 logical px. Giữ kích thước/vị trí, tab, payload và thời gian cũ. Độ mờ danh sách khi mất kết nối giữ 0,35 theo test cũ, không thay hợp đồng trạng thái.
5. Giấy/sổ dùng ảnh sợi giấy CC0 và mực tối, font đánh máy; giấy viết tay dùng biến thể nghiêng có sẵn. HUD thêm nền phụ đề và keycap quanh tiền tố E hiện có. Death/thẻ chương có bố cục điện ảnh và màu đồng bộ; không đổi lời hay nhịp/timer chương.
6. [192 ảnh trước/sau](../../game/ui/theme/previews/index.html), [bảng cỡ chữ/phạm vi kiểm](../../game/ui/theme/READABILITY.md), [CSV số đo từng ảnh](../../game/ui/theme/previews/typography.csv), [manifest SHA-256](../../game/ui/theme/previews/manifest.json). 24 màn/trạng thái × vi/en × 720p/1080p × trước/sau. Base trước `25e3bfe`, bản sao riêng dưới `build/T214/baseline`; không chạm workspace khác. 1.244 mục chữ trong ảnh sau, tối thiểu 16 px tại 720p; before có 194 mục dưới ngưỡng. Bổ sung kiểm bảng nối từ, nâng bốn nhãn 19–22 lên 24 logical px. Không chỉnh PNG sau render.

**Asset và key:**

- Font mới Be Vietnam Pro SemiBold và IBM Plex Mono Regular: **SIL OFL 1.1**, file gốc và license đầy đủ trong `game/assets/fonts/`; kiểm cmap và test Godot đủ chữ Việt hoa/thường/năm dấu. Be Vietnam Pro Regular cũ giữ làm font thân. [Nguồn/hash/license](../../game/assets/fonts/CREDITS.md).
- Ảnh giấy Paper001 của ambientCG/Lennart Demes: **CC0 1.0**, file 1K gốc; icon/khung SVG do D viết nguyên gốc, CC0; ảnh hành lang render từ kit dự án, CC0. [Credits UI](../../game/ui/theme/CREDITS.md), [credits nền](../../game/ui/title/CREDITS.md). Không tạo ảnh AI, không dùng credit Tripo/Meshy, không cài plugin/MCP/font hệ thống.
- Chính xác bốn key mới, đủ vi/en: `UI_RESET_VIDEO`, `UI_RESET_VIDEO_CONFIRM`, `UI_SETTINGS_ALL`, `UI_SETTINGS_PREFERENCES`. Không đổi key/dòng dịch cũ.

**Kết quả hiện tại và lượt Windows:**

- Integrator Claude bàn giao lượt ảnh trước rồi lượt kế tiếp gồm ảnh sau, kiểm tương tác và full test → check qua chủ dự án. D chờ các tiến trình GAME_DEMO kết thúc, xác nhận trống rồi chạy tuần tự; không dừng tiến trình lane khác.
- Renderer cuối: **`RESULT: T214 capture PASS (96 images)`** cho trước và sau, không `ERROR`/`SCRIPT ERROR`. Bộ sau còn kiểm close pause/settings đồng bộ và giải phóng fade overlay sau 250 ms. `RESULT: T214 review PASS (192 images; final captured text >=16px)`.
- UI: **`RESULT: 119 passed, 0 failed`**, exit 0 (`build/T214/ui-test-final.log`). Lượt đầu phát hiện crash duplicate Window; lượt tiếp phát hiện cancel deferred và alpha mất kết nối; đã sửa và chạy lại đạt. Không lấy lỗi ở lượt cũ làm PASS.
- Full test lần đầu: `RESULT: 753 passed, 0 failed`, exit 0, 22:19:28–22:40:10 +07. Check kế tiếp được D dừng có chủ đích lúc 22:41:55 (exit -1, **không có RESULT hoàn tất**) để sửa cỡ chữ bảng nối từ; chỉ dừng tiến trình thuộc lượt D. Log lịch sử `build/T214/full-test-first.log`, `check-interrupted.log` và các JSON tương ứng.
- **Đang chạy lại full `pwsh tools/test.ps1` trên mã cuối; `pwsh tools/check.ps1` sẽ chạy tuần tự khi test đạt. Chưa có kết quả full của mã cuối. D đang giữ lượt Godot.** Log `build/T214/full-test.log`, `full-check.log` và các JSON thời gian/exit cùng thư mục. Chưa push phần 2–6. Fetch cuối vẫn xác nhận main `25e3bfe`, chưa có card T-214 từ integrator.

**Chưa kiểm / yêu cầu ngoài phạm vi:**

- Chưa chơi tay hết chương 1–4, chưa dùng tay cầm vật lý, chưa chứng nhận mọi đoạn văn/trạng thái/từng pixel tương phản. Font 16 px được xác nhận cho bộ ảnh UI; chữ trên màn 3D còn phụ thuộc camera. Ảnh camera điện thoại là trạng thái chưa có feed; luồng feed thật được kiểm bởi test cũ.
- Không chạy FPS/bot/export; không thêm graphics_preset/render scale hoặc sửa SETTINGS/backend. T-211 giữ nguyên, không đánh dấu gói đồ họa done.
- Lane F/integrator: cân nhắc âm hover/click nhẹ và review độ mờ trạng thái điện thoại khi mất kết nối nếu muốn đổi hợp đồng cũ. Nền hành lang vẫn dùng kit hiện hành; nâng vật liệu 3D thuộc B/core. Không cần signal/autoload mới. Chờ kết quả full test/check trước commit/push phần còn lại, không có chặn quyền.

## Review (integrator)
2026-10-12 (Claude, integrator): **nhận, ghép vào main (D-091).** Xem 192 ảnh; mã chỉ trong vùng D, không sửa core/cảnh chương; `ui_motion.gd` chỉ là lớp hình (ảnh chụp mờ dần, không giữ input/tín hiệu), pause/input vẫn đổi đồng bộ. Font/giấy có nguồn, hash, giấy phép. Kết quả test/check của D trên mã cuối 753/753, check 0; main sau ghép chạy lại test/check trước khi push. Nhận xét chất lượng: tiêu đề, cài đặt, giấy tờ đạt hướng; điện thoại, màn chết, menu tạm dừng còn tối giản so với yêu cầu "thật đẹp", chủ dự án quyết có làm vòng 2.
