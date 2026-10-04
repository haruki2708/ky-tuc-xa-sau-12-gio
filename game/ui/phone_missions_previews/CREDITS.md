# T-163 phone and lock UI evidence

- Author: project Lane D, native Godot UI and procedural shaders written with
  OpenAI Codex assistance. No external artwork or generated bitmap art added.
  Project-original UI, shaders and captures: CC0-1.0,
  https://creativecommons.org/publicdomain/zero/1.0/.
- `lost_*.png`, `map_*.png`, `camera_*.png`, `lock_*.png`: Godot 4.7.2 captures,
  1920x1080, both Vietnamese and English. `blood_vi.png`,
  `blood_reduced_vi.png`, `static_vi.png` additionally show accessibility effects.
- Background and the **fixture** CCTV image reuse `../title/corridor.png`:
  Lane B/Lane D project assets, CC0-1.0; see `../title/CREDITS.md`.
  This is an isolated UI preview, not evidence of live chapter security cameras.
- Existing Be Vietnam Pro font: see `../../assets/fonts/CREDITS.md`.
- Wrong-code/alarm fallback: Lane E's original CC0 Foley
  `res://audio/sfx/door_latch.ogg`; see `../../audio/CREDITS.md`.
  The alarm stream is exported so integration can replace it with Lane E's clip.
- Neutral call messages reuse the T-155 preview fixture. The sample lock uses
  the approved N1 code and 3 attempts / 60 seconds from CH1_V2_MISSIONS.md.

Reproduce with `res://ui/phone_missions_preview.tscn` and user arguments
`--missions-ui=lost_vi` (also `lost_en`, `map_vi`, `map_en`, `camera_vi`,
`camera_en`, `lock_vi`, `lock_en`, `blood_vi`, `blood_reduced_vi`, `static_vi`).
Capture frame 4 at 30 fps with `--quit-after-frames=8`. Keep preview user data
isolated because the accessibility examples set the reduce-scares preference.
