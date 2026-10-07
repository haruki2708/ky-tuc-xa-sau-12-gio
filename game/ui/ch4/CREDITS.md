# Chapter 4 UI (T-197)

- New native UI layouts, paper fragments, hand polygons and fade shader: original code authored with OpenAI Codex assistance for this project; CC0 1.0: https://creativecommons.org/publicdomain/zero/1.0/ . No generated bitmap art or external models were added.
- Preview background `res://ui/title/corridor.png`: existing project art; see `res://ui/title/CREDITS.md` for provenance.
- Be Vietnam Pro: existing project font; see `res://assets/fonts/` for its SIL Open Font License and credits.
- Hospital cards are original native QuadMesh/Label3D compositions; previews show the card UI only, not Lane B's hospital scene.

## Preview fixture

Run `res://ui/ch4/ch4_ui_preview.tscn` with user argument `--ch4-ui=<mode>_<locale>`.
Modes: `compare`, `marked`, `scrap`, `form`, `name`, `signed`, `fade`, `hospital_all`, `hospital_alone`, `end`, `credits`, `door`. Locales: `vi`, `en`.

Capture with the project's Godot console using an existing absolute output directory: `--write-movie D:/GAME_WORK/lane-d/build/T-197/<mode>/frame.png --fixed-fps 30 -- --ch4-ui=<mode>_<locale> --quit-after-frames=8`.
The fixture freezes effect clocks, invokes explicit test verdicts and uses a canonical name only as typed fixture input. It does not implement story decisions. Character sex/age/date-of-birth remain blank until core supplies the approved profile; prior-round solution notes require core's `ch4_solved_r2…r4` flags and translation keys. No story details are invented for previews.
