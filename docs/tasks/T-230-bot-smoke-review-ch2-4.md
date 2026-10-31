# T-230 — Rà bot và smoke test chương 2–4 sau đợt nâng đồ họa
- Lane: C (QA và Tools) | Trạng thái: todo | Agent: (chủ dự án điền tên tài khoản GPT mới)
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
- [ ] Báo cáo đủ bot chương 2, 3, phần chương 4, smoke test
- [ ] Mỗi kết luận "hỏng" có dòng code hoặc node path làm bằng chứng
- [ ] Công cụ kiểm tĩnh và test (nếu làm) đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (theo luật lượt Godot trong `AGENTS.md`)
- [ ] Handoff trung thực, có commit hash

## Cách kiểm tra
- Integrator đọc báo cáo, thử lại vài kết luận "hỏng" bằng cách đọc code hoặc load scene.
- Chủ dự án quyết có chạy bot hay không.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
