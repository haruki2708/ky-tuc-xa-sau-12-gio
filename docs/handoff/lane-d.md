# Prompt bàn giao — Lane D (UI và Đa ngôn ngữ)

> **D-082:** đã review phần mới; đọc Review card và [kết luận chung](REVIEW_G1_2026-10-11.md), giữ công việc đã nhận. Không làm lại G0 hoặc tự chạy một vòng test mới chỉ vì nhận thông báo; tiếp tục đúng phần còn thiếu trong Review.

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** dùng **Tripo AI thay Meshy**. Studio thủ công ưu tiên cho mẫu đầu; API dùng ví riêng. Đọc [cập nhật provider](TRIPO_AI_CHUYEN_DOI_2026-10-11.md), tiếp tục gói hiện có và giữ kết quả G0.

> **D-079, 11/10:** G0 đã review/ghép. Khi tiếp tục, fetch/rebase main chứa D-079 rồi đọc Review của card và [yêu cầu G1](REVIEW_G0_2026-10-11.md); không làm lại G0 theo đoạn prompt cũ. Đây là phần tiếp của gói đã giao, chưa mở Tripo AI trả phí hoặc production.

**10/10/2026:** T-211, D-076/D-077; chủ dự án xác nhận lane còn hạn mức. Astra chỉ điều phối tạm 10–11/10, Opus 5.5 ở máy nhận lại sau đó. Card đã phân công; trạng thái thực xem Handoff.

## 1. Prompt giao task (dán nguyên khối)
```text
Bạn là agent Lane D (UI và Đa ngôn ngữ) của game Ký túc xá sau 12 giờ, Godot 4.7.2/GDScript.
Task T-211: cài đặt hình ảnh và khả năng đọc. Trả lời/tài liệu tiếng Việt, code tiếng Anh.
D-081: Astra làm thay Claude web ở T-207. Gửi yêu cầu core/contract về Astra.
Đọc docs/handoff/T207_G1_ASTRA_2026-10-11.md và contract G1 cập nhật.
Repo: https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git
Chỉ làm trong D:\GAME_WORK\lane-d; không sửa D:\GAME_DEMO hoặc workspace lane khác.

1. Kiểm git status ở workspace của bạn; không ghi đè công việc đang có. git fetch origin.
   Nhánh: lane-d/T-211-graphics-settings-readability. Nếu local đã có thì switch và pull --ff-only.
   Nếu chỉ origin có thì tạo tracking branch. Nếu chưa có thì tạo từ origin/main có D-081.
   Rebase an toàn lên origin/main có D-081, giữ mọi thay đổi cục bộ.
2. Đọc AGENTS.md, docs/STATUS.md, docs/design/GRAPHICS_UPGRADE_PLAN.md và docs/tasks/T-211-graphics-settings-readability.md.
   Đọc docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md và Review card.
3. G0 đã ghép D-079. Đọc Review và cập nhật D-080, tiếp tục các yêu cầu G1 đúng lane; không làm lại G0.
   Những bước sau phụ thuộc G1/G2 làm khi điều kiện trong card đủ; không tự đoán API/setting.
   Chỉ sửa đúng vùng của card. Giữ logic, collision, nav, timing; không sửa luật hoặc lời thoại.
4. Tripo AI chưa được xác nhận gói/đã mua/ngân sách; Studio/API tách credit: không tiêu credit, không cài MCP/plugin.
   Không chạy bot chương 3–4 hoặc FPS. Phần chuẩn bị/công cụ không cần chờ các quyền này.
5. Bàn giao từng phần bằng commit nhỏ “T-211: ...”; không đánh dấu cả gói done khi mới xong G0.
   Trước commit: full pwsh tools/test.ps1 và pwsh tools/check.ps1; ghi RESULT và những gì chưa kiểm.
   Phối hợp integrator xếp lượt full test/render trên Windows, tránh nhiều lượt Godot tranh tài nguyên.
   git push -u origin lane-d/T-211-graphics-settings-readability. Không push main, không mở PR nếu chưa được yêu cầu.
6. Cập nhật Handoff/checklist card của bạn, báo: đã làm; test/check; dependency/mục chưa đạt;
   yêu cầu ngoài phạm vi; commit/nhánh; có chặn gì không. Không sửa STATUS/DECISIONS/Review.
```

## 2. Prompt tiếp tục
```text
Tiếp tục T-211 ở D:\GAME_WORK\lane-d, nhánh lane-d/T-211-graphics-settings-readability.
Kiểm git status, fetch, switch/pull --ff-only an toàn; đọc Handoff tại docs/tasks/T-211-graphics-settings-readability.md.
Đọc STATUS và kế hoạch đồ họa để biết mốc G1/G2 đã đủ chưa. Rebase origin/main nếu cần, không mất thay đổi cục bộ.
Làm các phần còn được mở trong card và bàn giao theo mục 1; không tạo lại asset/tác vụ Tripo AI đã có task ID.
```

## 3. Prompt yêu cầu sửa
```text
Integrator trả T-211: git fetch origin; đọc Review trên origin/main:docs/tasks/T-211-graphics-settings-readability.md.
Rebase nhánh lane-d/T-211-graphics-settings-readability lên origin/main, sửa đúng từng ý trong phạm vi.
Chạy full test/check, cập nhật Handoff và push nhánh; nêu rõ phần chưa kiểm/đang chờ.
```

## 4. Prompt T-214: nâng cấp giao diện đẹp + đặt lại riêng Hình ảnh + chữ 720p (12/10)

Dán nguyên khối, dùng được cho phiên cũ lẫn phiên mới. Chỉ gửi khi chủ dự án xác nhận lane D còn hạn mức.

```text
Bạn là agent Lane D (UI và Đa ngôn ngữ), game kinh dị "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-d. Không sửa D:\GAME_DEMO hay workspace lane khác.
Integrator là Claude (Opus 5.5) ở máy. Câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator qua chủ dự án.

VIỆC: T-214. Chủ dự án yêu cầu "giao diện thật đẹp, không quá đơn giản như trước". Phong cách: kinh dị ký túc xá Việt Nam, gần chân thực
(tối, đèn tuýp xanh lạnh, giấy ố vàng, đỏ cảnh báo dùng tiết chế; chất liệu thật như giấy, kim loại sơn, kính màn hình thay cho hộp màu phẳng;
chuyển động tinh tế: mờ dần, chập chờn nhẹ). Đẹp nhưng chữ phải rõ.
Không thêm graphics_preset/render scale hay control đồ họa mới (vẫn chờ hợp đồng). T-211 giữ nguyên, không làm lại.

1. git status (không ghi đè việc đang dở) → git fetch origin → tạo nhánh lane-d/T-214-video-reset-readability từ origin/main mới nhất.
   Card docs/tasks/T-214-video-reset-readability.md có thể chưa lên origin/main ngay lúc này: nếu chưa có thì làm theo prompt này, khi có thì rebase và đọc card.
2. Đọc: AGENTS.md, docs/STATUS.md, card T-214 (nếu đã có), Handoff/Review T-211, game/scripts/ui/settings.gd, settings_panel, title, pause, phone, document UI,
   game/ui/theme/, game/assets/fonts/CREDITS.md và các test trong game/tests/ui/.
3. Làm theo thứ tự, commit nhỏ sau mỗi việc ("T-214: ..."):
   (1) Nút "Đặt lại hình ảnh"/"Reset video": settings.gd thêm reset_section(section) chỉ đặt lại một mục SCHEMA; nạp file cũ, giữ mọi mục/khóa khác kể cả khóa lạ,
       lưu một lần trước khi phát tín hiệu, lỗi lưu thì không phát tín hiệu; nút có hộp xác nhận trong settings panel; key vi/en; test.
   (2) Màn tiêu đề: nền 3D động (instance cảnh hành lang tầng 4 có sẵn chỉ để xem, camera trôi chậm, đèn chập chờn) hoặc ảnh chụp từ cảnh đó nếu nặng;
       logo tên game có chữ phong cách; menu hover/focus rõ cho phím, chuột, tay cầm; nhiễu phim nhẹ + viền tối; chuyển cảnh mờ dần.
   (3) Menu tạm dừng + Cài đặt: khung trong mờ có chất liệu, viền mảnh, tab có biểu tượng, thanh trượt/nút bật tắt tùy biến, hiệu ứng mở/đóng 150–250 ms.
   (4) Điện thoại trong game: như smartphone thật (viền, góc bo, thanh trạng thái giờ/pin/sóng, tab như ứng dụng có biểu tượng); giữ mọi tab, nút, dữ liệu, luồng chương 1–4.
   (5) Giấy tờ, ghi chú, phụ đề, gợi ý phím E (có biểu tượng phím), màn chết, thẻ tên chương: nền giấy thật, chữ đánh máy/viết tay hợp ngữ cảnh nhưng dễ đọc, kiểu điện ảnh.
   (6) Chụp 1280×720 và 1920×1080 (vi và en): mọi chữ ≥ 16 px ở 720p, đủ tương phản, không tràn chữ; bảng cỡ chữ.
   Dùng theme chung trong game/ui/theme/ để các màn thống nhất.
4. Ràng buộc: font chỉ OFL/CC0/CC-BY có đủ dấu tiếng Việt (kiểm ă â đ ê ô ơ ư và 5 dấu), ghi game/assets/fonts/CREDITS.md + file giấy phép; texture UI CC0/CC-BY có credits.
   Không đổi nội dung chữ, key cũ, luồng chơi, luật, lời thoại; chỉ thêm key UI_ mới (vi + en). Giữ tên node/đường dẫn mà script và test dùng; mọi test UI cũ vẫn đạt.
   Không sửa game/scripts/core/, cảnh chương, project.godot; cần signal/autoload mới thì ghi "Yêu cầu thay đổi". Âm thanh hover/click là vùng lane F: chỉ ghi đề xuất.
   Không đo FPS, không bot.
5. Ảnh trước/sau từng màn (720p, 1080p, vi, en) kèm bảng cỡ chữ và danh sách font/texture + giấy phép.
6. Khi cần renderer thật (chụp ảnh) hoặc full test/check: NHẮN integrator xin lượt rồi mới chạy pwsh tools/test.ps1, sau đó pwsh tools/check.ps1.
7. Hai lệnh đạt → git push origin lane-d/T-214-video-reset-readability (không push main, không mở PR) → báo nhả lượt Godot.
   Sắp hết hạn mức thì dừng ở bước đang làm, commit phần đã có ("T-214 WIP: ..."), push, ghi Handoff rõ đã xong việc nào, còn dở việc nào.
8. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại: việc đã xong (1–6), ảnh trước/sau, font/texture + giấy phép,
   key mới, dòng RESULT test.ps1/check.ps1, commit hash, phần chưa làm, yêu cầu thay đổi ngoài phạm vi, có bị chặn gì không.
```
