@AGENTS.md

## Integrator notes (Claude)
- D-081: **Astra làm thay Claude web** ở T-207 trong repo tích hợp theo yêu cầu chủ dự án. Web tạm dừng; Opus nhận phần còn dở. Đọc `docs/handoff/T207_G1_ASTRA_2026-10-11.md` và contract G1 cập nhật.
- D-080: chủ dự án chọn **Tripo AI thay Meshy**. Đọc `docs/handoff/TRIPO_AI_CHUYEN_DOI_2026-10-11.md`; Studio/API tách credit, ưu tiên Studio thủ công cho mẫu đầu. Chưa xác nhận gói/mua/ngân sách hoặc ngoại lệ license.
- Hướng đồ họa và phân công hiện tại: D-076/D-077, `docs/design/GRAPHICS_UPGRADE_PLAN.md`, T-207 đến T-212. Giữ gameplay khi thay phần hiển thị.
- D-078: lane E nghỉ vô thời hạn; lane F dùng tài khoản GPT Plus mới nhận toàn bộ vai trò âm thanh và T-212. Dùng `docs/handoff/lane-f.md`, workspace `D:\GAME_WORK\lane-f`, nhánh `lane-f/T-212-graphics-audio-anchors`; giữ nguyên lịch sử E.
- Astra điều phối tạm 10–11/10/2026. Claude Code ở máy (Opus 5.5) nhận lại qua `docs/handoff/OPUS_5_5_NHAN_LAI_DIEU_PHOI.md` và nhật ký Astra. G0 của Claude web đã ghép; từ D-081, T-207 do integrator tiếp nhận.
- `docs/ROADMAP.md` là bản đồ lộ trình cho chủ dự án: cập nhật mỗi khi qua mốc (chốt chương, đóng cổng G, đổi hướng lớn).
- `D:\GAME_DEMO` is the integration checkout on `main`. Lane agents work in `D:\GAME_WORK\lane-<x>`.
- Merge flow:
  1. `git fetch`
  2. Review the diff of `origin/lane-x/T-xxx` against `main`: scope, tests, quality.
  3. `git merge --no-ff`
  4. `pwsh tools/test.ps1`
  5. Update `docs/STATUS.md` and the task card status.
  6. Push `main`.
- After each milestone: tag `v0.x`, run `tools/export.ps1`, and hand the build to the owner for playtesting.
- The owner communicates in Vietnamese; docs are Vietnamese, code is English.
