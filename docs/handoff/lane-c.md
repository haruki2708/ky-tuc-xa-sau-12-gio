# Prompt bàn giao — Lane C (QA và Tools)

> **11/10, sau D-082:** Astra đã bàn giao lại; integrator là Claude (Opus 5.5) ở máy. Câu hỏi core/contract và xin lượt Godot gửi về integrator. Prompt đang dùng: **mục 4**.

> **D-082:** đã review phần mới; đọc Review card và [kết luận chung](REVIEW_G1_2026-10-11.md), giữ công việc đã nhận. C chỉ được nhận probe b86a77d; sửa R1–R4 trên phần schema còn lại 7af1075 trước bàn giao lại.

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

## 4. Prompt sửa sau review D-082 (bản đầy đủ, 11/10 integrator viết lại)

Dán nguyên khối, dùng được cho cả phiên lane C cũ lẫn phiên mới. Chỉ gửi khi chủ dự án xác nhận lane C còn hạn mức.

```text
Bạn là agent Lane C (QA và Tools), game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-c. Không sửa D:\GAME_DEMO hay workspace lane khác.
Từ 11/10 integrator là Claude (Opus 5.5) ở máy, thay Astra. Mọi câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator.

VIỆC: T-210, sửa R1–R4 trên commit 7af1075 (schema/validator/dry-run), nhánh lane-c/T-210-graphics-asset-qa.
Integrator đã ghép b86a77d (probe). Không làm lại probe/G0, không sửa manifest của lane B, không nới bất kỳ ngưỡng nào.

1. git status (không ghi đè việc đang dở) → git fetch origin → rebase an toàn nhánh lên origin/main (có D-082), giữ 7af1075.
2. Đọc: docs/handoff/REVIEW_G1_2026-10-11.md (bảng R1–R4), mục Review trong docs/tasks/T-210-graphics-asset-qa.md, D-079 và D-081 trong docs/DECISIONS.md.
3. Sửa, mỗi lỗi kèm ít nhất một fixture âm tính dựng lại đúng ca trong review:
   R1: root_scale phải là (1,1,1), kiểm bằng epsilon riêng, không dùng chung tolerance vị trí.
       Tolerance của balo phải hữu hạn, không âm, tối đa 0.001 m.
       Ca phải FAIL: root_scale [2,2,2] kèm số đo nhân đôi; tolerance_m=100 kèm kích thước [99,99,99].
   R2: trần tam giác/material/texture của room407_backpack lấy từ hợp đồng D-079 đã duyệt, không lấy từ chính manifest tự khai.
       Asset khác vẫn được khai ngân sách riêng khi có contract.
       Ca phải FAIL: tự khai limit 100001 tam giác / 999 material / 8192 px, số đo 99999 / 999 / 8192.
   R3: phát hiện dependency bị thiếu hoặc đã cũ (stale). Chưa chứng minh đủ closure thì kết quả là INCOMPLETE, kèm tên dependency cụ thể.
       Ca phải FAIL/INCOMPLETE: xóa riêng hash game/importer.gd rồi sửa importer;
       mất riêng importer, material, texture, include, wrapper (mỗi thứ một fixture).
   R4: kiểm kiểu (type/const/range) đúng schema đã công bố, cho mọi provider; công bố rõ kiểu của parameters.
       Ca phải FAIL sạch (thông báo lỗi rõ ràng, không crash): generation.rights_evidence=42 khi provider self_authored.
   Đồng bộ schema, validator, test và tài liệu. Toàn bộ fixture dương tính cũ vẫn PASS.
4. Chạy fixture offline trước. Khi đạt, NHẮN integrator xin lượt rồi mới chạy: pwsh tools/test.ps1, sau đó pwsh tools/check.ps1.
   Không render, đo FPS, chạy bot hay dùng Tripo (trả phí hoặc MCP).
5. Hai lệnh đạt → commit nhỏ "T-210: fix R1–R4 ..." → git push origin lane-c/T-210-graphics-asset-qa (không push main, không mở PR) → báo nhả lượt Godot.
6. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại, gồm:
   - Bảng R1–R4: đã sửa gì; tên fixture; kết quả trước sửa (lọt) và sau sửa (FAIL/INCOMPLETE).
   - Số fixture âm/dương và kết quả.
   - Dòng RESULT của test.ps1 và check.ps1; commit hash.
   - Phần chưa kiểm, câu hỏi về contract (nếu có), có bị chặn gì không.
```
