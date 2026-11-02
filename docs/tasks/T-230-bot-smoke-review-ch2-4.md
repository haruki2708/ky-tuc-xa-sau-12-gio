# T-230 — Rà bot và smoke test chương 2–4 sau đợt nâng đồ họa
- Lane: C (QA và Tools) | Trạng thái: done (D-140) | Agent: (chủ dự án điền tên tài khoản GPT mới)
- Nhánh: `lane-c/T-230-bot-smoke-review-ch2-4` từ `origin/main` mới nhất.
- Quyết định giao: **D-139** (việc thử đầu tiên của tài khoản lane C mới). Integrator chấm theo bảng trong `docs/tasks/README.md`.
- Lượt này **chỉ đọc code, kiểm tĩnh và báo cáo**. **Không chạy bot** (chạy bot phải hỏi chủ dự án trước).

## Bối cảnh
- Bot chương 2 và 3 viết từ 10/10 (T-180, T-181, T-193). Chương 4 chưa có bot (T-199 chưa viết card; D-068: chủ dự án không cần bot chương 3, 4 lúc đó).
- Từ 12/10 đến 23/10, nhiều thứ dùng chung cho cả 4 chương đã đổi:
  - phòng 407 thay đồ Tripo (D-103), đổi vị trí đồ, thêm va chạm (D-113, T-225: giá phơi và 7 món chặn người chơi);
  - nhà tắm sửa (D-109);
  - vỏ phòng 407 mới, có cửa ban công bản lề, mở sẵn (T-222, D-129);
  - quản lý Tripo (D-120), soi từng giường, đuổi theo (T-224);
  - ổ điện, dây mạng, quạt (T-226).

  Bot có thể còn đi theo tọa độ, tên node hay đường cũ. Chương 2–4 chưa ai chơi lại với đồ họa mới.
- File bot (lane C): `game/scripts/debug/` (`ch2_bot.gd`, `ch2_actions.gd`, `ch2_policy.gd`, `ch3_bot.gd`, `ch3_actions.gd`, `ch3_policy.gd`, `chapter_bot.gd`, `chapter_actions.gd`, `playthrough_bot.gd`, `qa_director.gd`, menu F9 `*_menu*.gd`), profile `tools/ch2-profile.json`, `tools/ch3-profile.json`, `tools/playthrough.ps1`, `tools/qa-menu.ps1`. Smoke test: `game/tests/smoke/test_smoke_scenes.gd`.

## Việc cần làm
1. **Đối chiếu tĩnh** từng bot và profile chương 2, 3 với `main` hiện tại:
   - node path, anchor, tên interactable bot gọi còn tồn tại không;
   - tọa độ đứng, điểm đi tới có rơi vào va chạm mới không (giá phơi, đồ chặn T-225, cánh cửa ban công mở sẵn D-129);
   - bước nào phụ thuộc hình hay vị trí cũ của phòng 407, nhà tắm, quản lý.
2. **Chương 4:** liệt kê những gì đang có để kiểm (menu F9 nhảy khu, smoke test) và những gì thiếu nếu sau này cần bot. Không viết bot chương 4.
3. **Smoke test:** danh sách scene `test_smoke_scenes.gd` đang load so với scene chương 2–4 hiện có. Ghi scene nào chưa được load.
4. **Công cụ kiểm tĩnh (nên có):**
   - script kiểm mọi node path và anchor trong profile hoặc bot chương 2–3 có trong scene: load scene headless, **không chơi**;
   - test kèm theo trong `game/tests/tools/`.
5. **Báo cáo** `tools/reports/T-230-bot-review.md`:
   - mỗi bot, mỗi kịch bản, mỗi bước: **OK / có thể hỏng / chắc chắn hỏng**, kèm lý do và dòng code;
   - đề xuất sửa, xếp theo mức ưu tiên;
   - ước lượng thời gian chạy bot từng chương, để chủ dự án quyết có cho chạy không.

## Được phép sửa
- `tools/reports/T-230-bot-review.md` (mới).
- Công cụ kiểm tĩnh mới:
  - trong `game/scripts/debug/` (script mới), hoặc `tools/` (trừ `godot-path.ps1`);
  - test trong `game/tests/tools/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- **Không chạy bot, không đo FPS** (`playthrough.ps1`, `*_bot.tscn`, `*_performance.tscn`).
- Không sửa bot hay profile đang có trong lượt này. Sửa ở lượt sau, sau khi integrator review báo cáo và chủ dự án cho chạy bot.
- Không sửa scene, script gameplay, core, level.
- Không tiêu credit Tripo.

## Checklist hoàn thành
- [x] Báo cáo đủ bot chương 2, 3, phần chương 4, smoke test
- [x] Mỗi kết luận "hỏng" có dòng code hoặc node path làm bằng chứng
- [x] Công cụ kiểm tĩnh và test (nếu làm) đạt
- [x] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (theo luật lượt Godot trong `AGENTS.md`)
- [x] Handoff trung thực, có commit hash

## Cách kiểm tra
- Integrator đọc báo cáo, thử lại vài kết luận "hỏng" bằng cách đọc code hoặc load scene.
- Chủ dự án quyết có chạy bot hay không.

## Handoff (agent điền)
- Phiên 01–02/11/2026, lane C mới (Codex), base `2773a3f608f33a2bda719a3dcfbf74900cfe07c0`.
- Đã làm: báo cáo `tools/reports/T-230-bot-review.md` đủ từng bước/case ch2–3, ch4, smoke, ưu tiên sửa và thời gian dự trù; công cụ `profile_static_audit.gd` cùng ba test. Kiểm 129 tham chiếu: 100 có sẵn, 29 phụ thuộc producer runtime, 0 thiếu chưa giải thích. Tính tĩnh điểm đứng với tám collider T-225 và cửa ban công từ GLB/placement.
- Phát hiện chính: aim Wipe vẫn ở vị trí cũ; điểm bedroom chồng bàn gấp theo capsule/box tĩnh; bot ch3 chưa kiểm báo cháy tầng 1; chưa có menu F9/bot ch4. Không sửa profile/bot/gameplay để xử lý các phát hiện trong lượt này.
- Kiểm tra: `pwsh tools/test.ps1 -Filter test_profile_static_audit` → `RESULT: 3 passed, 0 failed`, exit 0. Lượt lọc đầu bắt lỗi chuẩn hóa `./` trong công cụ mới, đã sửa và chạy lại đạt.
- Full test/check: lượt 23:29 ngày 01/11 bị ngắt, chưa có RESULT; đã xác nhận session/tiến trình lane C không còn và tiếp tục lúc 23:59 theo yêu cầu chủ dự án. Lượt chạy lại tuần tự dưới khóa lane C: `RESULT: 854 passed, 0 failed` (exit 0, xong 02/11 00:20:52), rồi `RESULT: check 0 error(s)` (exit 0, xong 00:33:55). Khóa đã dọn trong finally.
- Còn dở: không còn phần triển khai/kiểm tra nào trong phạm vi T-230; các sửa bot/profile là đề xuất lượt sau, chờ integrator review và chủ dự án cho chạy.
- Commit nội dung đã kiểm: `700c1294909a8d8441233cd716f82e0d0d15d9bd` — `T-230: Audit chapter bot profiles and document smoke coverage`. Commit tiếp theo chỉ chốt hash/checklist Handoff này. Nhánh bàn giao: `lane-c/T-230-bot-smoke-review-ch2-4`.
- Cách kiểm: đọc báo cáo và chạy lại test lọc trên; kết quả static không đồng nghĩa bot chạy hết chương. Log phiên trong `build/t230/` (không commit build).
- Yêu cầu thay đổi: integrator review và giao lượt sau cho sửa aim/tọa độ profile, kiểm đường đi/collider thật, bổ sung coverage báo cháy; cân nhắc menu4/smoke UI allowlist. Nếu cần đổi collider/navmesh/API core, chuyển B/core, không tự sửa ngoài phạm vi.
- Chưa kiểm: bot end-to-end, physics/raycast/walking toàn tuyến, FPS/hình ảnh, chơi tay ch4. Không chạy bot/benchmark/Tripo, không sửa STATUS/DECISIONS.
- Blocked: không. Full test/check đều đạt; không coi các lỗi bot tìm được là đã sửa.

## Review (integrator, 02/11/2026)
- **Đạt, đã merge** (D-140). Điểm: 5 · 5 · 5 · 5 · 5 · 0 vòng (`docs/tasks/README.md`).
- Integrator kiểm lại: aim lau màn trong `tools/ch2-profile.json` (36.18, 1.45, −6.78) lệch màn thật ở x=35.387 (`room407_anchors.tscn` ShowerScreen + offset phòng 30); `qa-menu.ps1` chỉ nhận chương 1–3; profile ch3 không có báo cháy tầng 1. Đúng.
- Bước tiếp: chủ dự án quyết có sửa và chạy bot chương 2, 3 không (thời gian dự trù ở báo cáo mục 7); chương 4 cần card riêng nếu muốn bot.
