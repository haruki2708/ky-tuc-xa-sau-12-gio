@AGENTS.md

## Integrator notes (Claude)
- Hướng đồ họa và phân công hiện tại: D-076/D-077, `docs/design/GRAPHICS_UPGRADE_PLAN.md`, T-207 đến T-212. Giữ gameplay khi thay phần hiển thị.
- Astra điều phối tạm 10–11/10/2026. Claude Code ở máy (Opus 5.5) nhận lại qua `docs/handoff/OPUS_5_5_NHAN_LAI_DIEU_PHOI.md` và nhật ký Astra. Claude web chỉ làm phạm vi được giao của T-207.
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
