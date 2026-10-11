# Prompt bàn giao — Lane B (Môi trường và 3D)

> **11/10, D-083:** schema/validator G1 của C đã ghép; integrator là Claude (Opus 5.5) ở máy. Prompt đang dùng: **mục 4** (chuyển manifest balo + hướng mặt trước).

> **D-082:** đã review phần mới; đọc Review card và [kết luận chung](REVIEW_G1_2026-10-11.md), giữ công việc đã nhận. Không làm lại G0 hoặc tự chạy một vòng test mới chỉ vì nhận thông báo; tiếp tục đúng phần còn thiếu trong Review.

> **D-081, 11/10:** Astra làm thay Claude web ở T-207 theo yêu cầu chủ dự án. Đầu mối core/contract chuyển về integrator; web tạm dừng. Đọc [bàn giao G1](T207_G1_ASTRA_2026-10-11.md); giữ G0 và task/nhánh hiện có.

> **D-080, 11/10:** dùng **Tripo AI thay Meshy**. Studio thủ công ưu tiên cho mẫu đầu; API dùng ví riêng. Đọc [cập nhật provider](TRIPO_AI_CHUYEN_DOI_2026-10-11.md), tiếp tục gói hiện có và giữ kết quả G0.

> **D-079, 11/10:** G0 đã review/ghép. Khi tiếp tục, fetch/rebase main chứa D-079 rồi đọc Review của card và [yêu cầu G1](REVIEW_G0_2026-10-11.md); không làm lại G0 theo đoạn prompt cũ. Đây là phần tiếp của gói đã giao, chưa mở Tripo AI trả phí hoặc production.

**10/10/2026:** T-209, D-076/D-077; chủ dự án xác nhận lane còn hạn mức. Astra chỉ điều phối tạm 10–11/10, Opus 5.5 ở máy nhận lại sau đó. Card đã phân công; trạng thái thực xem Handoff.

## 1. Prompt giao task (dán nguyên khối)
```text
Bạn là agent Lane B (Môi trường và 3D) của game Ký túc xá sau 12 giờ, Godot 4.7.2/GDScript.
Task T-209: art pipeline và phòng 407 gần chân thực. Trả lời/tài liệu tiếng Việt, code tiếng Anh.
D-081: Astra làm thay Claude web ở T-207. Gửi yêu cầu core/contract về Astra.
Đọc docs/handoff/T207_G1_ASTRA_2026-10-11.md và contract G1 cập nhật.
Repo: https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio.git
Chỉ làm trong D:\GAME_WORK\lane-b; không sửa D:\GAME_DEMO hoặc workspace lane khác.

1. Kiểm git status ở workspace của bạn; không ghi đè công việc đang có. git fetch origin.
   Nhánh: lane-b/T-209-realistic-art-pilot. Nếu local đã có thì switch và pull --ff-only.
   Nếu chỉ origin có thì tạo tracking branch. Nếu chưa có thì tạo từ origin/main có D-081.
   Rebase an toàn lên origin/main có D-081, giữ mọi thay đổi cục bộ.
2. Đọc AGENTS.md, docs/STATUS.md, docs/design/GRAPHICS_UPGRADE_PLAN.md và docs/tasks/T-209-realistic-art-pilot.md.
   Đọc docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md và Review card.
3. G0 đã ghép D-079. Đọc Review và cập nhật D-080, tiếp tục các yêu cầu G1 đúng lane; không làm lại G0.
   Những bước sau phụ thuộc G1/G2 làm khi điều kiện trong card đủ; không tự đoán API/setting.
   Chỉ sửa đúng vùng của card. Giữ logic, collision, nav, timing; không sửa luật hoặc lời thoại.
4. Tripo AI chưa được xác nhận gói/đã mua/ngân sách; Studio/API tách credit: không tiêu credit, không cài MCP/plugin.
   Không chạy bot chương 3–4 hoặc FPS. Phần chuẩn bị/công cụ không cần chờ các quyền này.
5. Bàn giao từng phần bằng commit nhỏ “T-209: ...”; không đánh dấu cả gói done khi mới xong G0.
   Trước commit: full pwsh tools/test.ps1 và pwsh tools/check.ps1; ghi RESULT và những gì chưa kiểm.
   Phối hợp integrator xếp lượt full test/render trên Windows, tránh nhiều lượt Godot tranh tài nguyên.
   git push -u origin lane-b/T-209-realistic-art-pilot. Không push main, không mở PR nếu chưa được yêu cầu.
6. Cập nhật Handoff/checklist card của bạn, báo: đã làm; test/check; dependency/mục chưa đạt;
   yêu cầu ngoài phạm vi; commit/nhánh; có chặn gì không. Không sửa STATUS/DECISIONS/Review.
```

## 2. Prompt tiếp tục
```text
Tiếp tục T-209 ở D:\GAME_WORK\lane-b, nhánh lane-b/T-209-realistic-art-pilot.
Kiểm git status, fetch, switch/pull --ff-only an toàn; đọc Handoff tại docs/tasks/T-209-realistic-art-pilot.md.
Đọc STATUS và kế hoạch đồ họa để biết mốc G1/G2 đã đủ chưa. Rebase origin/main nếu cần, không mất thay đổi cục bộ.
Làm các phần còn được mở trong card và bàn giao theo mục 1; không tạo lại asset/tác vụ Tripo AI đã có task ID.
```

## 3. Prompt yêu cầu sửa
```text
Integrator trả T-209: git fetch origin; đọc Review trên origin/main:docs/tasks/T-209-realistic-art-pilot.md.
Rebase nhánh lane-b/T-209-realistic-art-pilot lên origin/main, sửa đúng từng ý trong phạm vi.
Chạy full test/check, cập nhật Handoff và push nhánh; nêu rõ phần chưa kiểm/đang chờ.
```

## 4. Prompt sau D-083: chuyển manifest balo và chốt hướng mặt trước (bản đầy đủ, 11/10 integrator viết)

Dán nguyên khối, dùng được cho cả phiên lane B cũ lẫn phiên mới. Chỉ gửi khi chủ dự án xác nhận lane B còn hạn mức.

```text
Bạn là agent Lane B (Môi trường và 3D), game "Ký túc xá sau 12 giờ" (Godot 4.7.2). Trả lời/tài liệu tiếng Việt, code tiếng Anh.
Chỉ làm trong D:\GAME_WORK\lane-b. Không sửa D:\GAME_DEMO hay workspace lane khác.
Từ 11/10 integrator là Claude (Opus 5.5) ở máy, thay Astra. Mọi câu hỏi core/contract và việc xin lượt chạy Godot đều gửi về integrator.

VIỆC: T-209, phần G1 cho balo room407_backpack, nhánh lane-b/T-209-realistic-art-pilot.
D-083 đã ghép schema/validator G1 của lane C vào main. Không làm lại G0/brief/pilot/mount survey đã nhận (D-082).
Không sửa tools/graphics/ (vùng C), core, collision/nav/timing, cảnh chơi mặc định. Không nới trần D-079 hay sai số D-081.

1. git status (không ghi đè việc đang dở) → git fetch origin → rebase an toàn nhánh lên origin/main (có D-083).
2. Đọc: docs/handoff/REVIEW_G1_2026-10-11.md (mục B), Review trong docs/tasks/T-209-realistic-art-pilot.md,
   D-079/D-081/D-083 trong docs/DECISIONS.md, tools/graphics/G1_SCHEMA.md, tools/graphics/sample_g1_manifest.json,
   art_source/graphics_upgrade/TRIPO_BACKPACK.md.
3. Chuyển manifest: tạo bản khai G1 cho room407_backpack trong art_source/graphics_upgrade/ (schema_version "t210-g1-static-1").
   Số đo lấy từ đo thật root-local (measured_assets.json / probe), không chép số của file mẫu C.
   Giữ asset_id đúng chữ thường "room407_backpack". Xác nhận node path, root_class, placement, owner theo contract T-207.
   Giữ manifest G0 cũ làm lịch sử, ghi rõ bản nào đang có hiệu lực.
4. Chốt hướng mặt trước (facing) của balo hiện hành, TRƯỚC khi có mẫu Tripo:
   - Mở model hiện hành, xác định mặt trước (mặt có túi/khóa nhìn ra người chơi) theo trục root-local (ví dụ +X/-Z), kèm hướng lên.
   - Chụp 4 ảnh cùng ánh sáng: trước, sau, cạnh, dưới; ghi trục lên ảnh hoặc tên file.
   - Ghi basis đã chọn vào TRIPO_BACKPACK.md (mục "Hướng mặt trước"): trục trước, trục lên, pivot, ảnh tham chiếu,
     và quy tắc xoay GLB Tripo về đúng basis này trong Blender trước khi nhập.
   - Schema G1 chưa có field facing: KHÔNG tự thêm field vào schema. Ghi trong brief; nếu thấy cần field, nêu đề xuất trong Handoff.
5. Chạy công cụ C trên manifest mới:
   python -B tools/graphics/asset_qa.py <manifest G1 của B> --probe-log <log probe/full test mới nhất>
   Kết quả mong đợi: balo CŨ FAIL đúng lỗi "material budget exceeded" (3 > 2); không có lỗi schema/kiểu/scale/tolerance nào khác.
   Lỗi khác ngoài material: sửa dữ liệu của B; nếu do công cụ C sai, ghi vào Handoff, không sửa tools/graphics/.
   Không gọi balo cũ là asset Tripo, không hạ yêu cầu để nó PASS.
6. Khi sẵn sàng full test/check Windows: NHẮN integrator xin lượt rồi mới chạy pwsh tools/test.ps1, sau đó pwsh tools/check.ps1.
   Render ảnh facing cũng là lượt Godot: xin lượt cùng lúc. Không đo FPS, chạy bot hay dùng Tripo (trả phí hoặc MCP).
7. Hai lệnh đạt → commit nhỏ "T-209: ..." → git push origin lane-b/T-209-realistic-art-pilot (không push main, không mở PR) → báo nhả lượt Godot.
8. Cập nhật Handoff trong card (không sửa STATUS, DECISIONS hay mục Review) và báo lại, gồm:
   - Đường dẫn manifest G1; bảng số đo (kích thước, bounds_min, tam giác, vật liệu, texture) và nguồn đo.
   - Basis mặt trước/lên/pivot đã chọn, 4 ảnh tham chiếu.
   - Lệnh asset_qa đã chạy và nguyên văn errors/status.
   - Dòng RESULT của test.ps1 và check.ps1; commit hash.
   - Phần chưa kiểm, đề xuất contract (nếu có), có bị chặn gì không.
```
