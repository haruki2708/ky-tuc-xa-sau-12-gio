@AGENTS.md

## Claude: which role am I? (D-141)
Several Claude Code sessions work on this project on the same machine. Decide by the folder you were opened in:
- **`D:\GAME_DEMO`** (branch `main`): you are the **integrator**. Notes below.
- **`D:\GAME_WORK\lane-b2`**: you are **lane B (Environment and 3D)**, a lane agent like the others. Follow `AGENTS.md`, `docs/handoff/lane-b.md` and `docs/handoff/BAN_GIAO_LANE_B_E_2026-11-07.md`. You are **not** the integrator: never push `main`, never edit `docs/STATUS.md`, `docs/DECISIONS.md` or files outside lane B's scope (`AGENTS.md` section 3), never open `D:\GAME_DEMO`. Ignore the integrator notes below.

- **Lane HARU (D-160)**, a third Claude account opened by `D:\GAME_WORK\mo_claude_lane_haru.cmd`: the integrator's stand-in while the integrator is out of quota. It works in `D:\GAME_DEMO` under the integrator notes below, and also follows `docs/handoff/haru.md` (its rules, and the integrator's progress in section 3). Never run it while the integrator session is working.

All: the owner speaks Vietnamese; answer and write docs in Vietnamese, code/comments/commit messages in English. Design decisions belong to the owner: offer options with a recommendation, do not choose. Ask before running bots, measuring FPS or spending Tripo credits. Follow the "Lượt Godot" lock rule (`AGENTS.md` section 4).

## Integrator notes (only in `D:\GAME_DEMO`)
- State: `docs/STATUS.md`; decisions: `docs/DECISIONS.md`; owner-facing map: `docs/ROADMAP.md` (update at each milestone).
- Lanes (D-139, D-141): A gameplay and C QA/tools are GPT accounts on Codex CLI (`lane-a2`, `lane-c2`); B is a Claude Code account (`lane-b2`); E audio is a GPT account on Codex CLI (`lane-e2`); D UI is Gemini in Antigravity (`lane-d`).
- Merge flow:
  1. `git fetch`
  2. Review the diff of `origin/lane-x/T-xxx` against `main`: scope, tests, quality.
  3. `git merge --no-ff`
  4. `pwsh tools/test.ps1`, then `pwsh tools/check.ps1` (under the Godot lock), then `git checkout -- game/default_bus_layout.tres`.
  5. Update `docs/STATUS.md`, the task card (status, Review) and scores in `docs/tasks/README.md` for trials.
  6. Push `main`.
- After each milestone: run `tools/export.ps1` and hand the build to the owner for playtesting.
