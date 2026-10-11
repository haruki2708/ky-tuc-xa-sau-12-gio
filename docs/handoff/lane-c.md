# Prompt bàn giao — Lane C (QA và Tools)

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** dùng **Tripo AI thay Meshy**. Studio thủ công ưu tiên cho mẫu đầu; API dùng ví riêng. Đọc [cập nhật provider](TRIPO_AI_CHUYEN_DOI_2026-10-11.md), tiếp tục gói hiện có và giữ kết quả G0.

> **D-079, 11/10:** G0 đã review/ghép. Khi tiếp tục, fetch/rebase main chứa D-079 rồi đọc Review của card và [yêu cầu G1](REVIEW_G0_2026-10-11.md); không làm lại G0 theo đoạn prompt cũ. Đây là phần tiếp của gói đã giao, chưa mở Tripo AI trả phí hoặc production.

**10/10/2026:** T-210, D-076/D-077; chủ dự án xác nhận lane còn hạn mức. Astra chỉ điều phối tạm 10–11/10, Opus 5.5 ở máy nhận lại sau đó. Card đã phân công; trạng thái thực xem Handoff.

## 1. Prompt giao task (dán nguyên khối)
```text
Bạn là agent Lane C (QA và Tools) của game Ký túc xá sau 12 giờ, Godot 4.7.2/GDScript.
Task T-210: kiểm asset, QA/metadata Tripo Studio và công cụ dry-run; API Tripo là phương án riêng. Trả lời/tài liệu tiếng Việt, code tiếng Anh.
D-081: Astra làm thay Claude web ở T-207. Gửi yêu cầu core/contract về Astra.
Đọc docs/handoff/T207_G1_ASTRA_2026-10-11.md và contract G1 cập nhật.
Repo: https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git
Chỉ làm trong D:\GAME_WORK\lane-c; không sửa D:\GAME_DEMO hoặc workspace lane khác.

1. Kiểm git status ở workspace của bạn; không ghi đè công việc đang có. git fetch origin.
   Nhánh: lane-c/T-210-graphics-asset-qa. Nếu local đã có thì switch và pull --ff-only.
   Nếu chỉ origin có thì tạo tracking branch. Nếu chưa có thì tạo từ origin/main có D-081.
   Rebase an toàn lên origin/main có D-081, giữ mọi thay đổi cục bộ.
2. Đọc AGENTS.md, docs/STATUS.md, docs/design/GRAPHICS_UPGRADE_PLAN.md và docs/tasks/T-210-graphics-asset-qa.md.
   Đọc docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md và Review card.
3. G0 đã ghép D-079. Đọc Review và cập nhật D-080, tiếp tục các yêu cầu G1 đúng lane; không làm lại G0.
   Những bước sau phụ thuộc G1/G2 làm khi điều kiện trong card đủ; không tự đoán API/setting.
   Chỉ sửa đúng vùng của card. Giữ logic, collision, nav, timing; không sửa luật hoặc lời thoại.
4. Tripo AI chưa được xác nhận gói/đã mua/ngân sách; Studio/API tách credit: không tiêu credit, không cài MCP/plugin.
   Không chạy bot chương 3–4 hoặc FPS. Phần chuẩn bị/công cụ không cần chờ các quyền này.
5. Bàn giao từng phần bằng commit nhỏ “T-210: ...”; không đánh dấu cả gói done khi mới xong G0.
   Trước commit: full pwsh tools/test.ps1 và pwsh tools/check.ps1; ghi RESULT và những gì chưa kiểm.
   Phối hợp integrator xếp lượt full test/render trên Windows, tránh nhiều lượt Godot tranh tài nguyên.
   git push -u origin lane-c/T-210-graphics-asset-qa. Không push main, không mở PR nếu chưa được yêu cầu.
6. Cập nhật Handoff/checklist card của bạn, báo: đã làm; test/check; dependency/mục chưa đạt;
   yêu cầu ngoài phạm vi; commit/nhánh; có chặn gì không. Không sửa STATUS/DECISIONS/Review.
```

## 2. Prompt tiếp tục
```text
Tiếp tục T-210 ở D:\GAME_WORK\lane-c, nhánh lane-c/T-210-graphics-asset-qa.
Kiểm git status, fetch, switch/pull --ff-only an toàn; đọc Handoff tại docs/tasks/T-210-graphics-asset-qa.md.
Đọc STATUS và kế hoạch đồ họa để biết mốc G1/G2 đã đủ chưa. Rebase origin/main nếu cần, không mất thay đổi cục bộ.
Làm các phần còn được mở trong card và bàn giao theo mục 1; không tạo lại asset/tác vụ Tripo AI đã có task ID.
```

## 3. Prompt yêu cầu sửa
```text
Integrator trả T-210: git fetch origin; đọc Review trên origin/main:docs/tasks/T-210-graphics-asset-qa.md.
Rebase nhánh lane-c/T-210-graphics-asset-qa lên origin/main, sửa đúng từng ý trong phạm vi.
Chạy full test/check, cập nhật Handoff và push nhánh; nêu rõ phần chưa kiểm/đang chờ.
```
