@AGENTS.md

## Integrator notes (Claude)
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
