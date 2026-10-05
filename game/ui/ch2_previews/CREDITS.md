# T-174 chapter 2 UI previews

- Native Godot controls, LCD, procedural steam and scald shader: project Lane D,
  written with OpenAI Codex assistance. No generated bitmap artwork or new
  external assets. Project-original UI and captures are CC0-1.0:
  https://creativecommons.org/publicdomain/zero/1.0/.
- Background reuses `../title/corridor.png`; project Lane B/Lane D, CC0-1.0.
  Source and capture information: `../title/CREDITS.md`.
- Existing Be Vietnam Pro font: `../../assets/fonts/CREDITS.md` (SIL OFL 1.1).
- Countdown fallback reuses Lane E's original `audio/ch1v2/power_switch.ogg`,
  at -12 dB on the SFX bus. See the T-164 section in `../../audio/CREDITS.md`.
  Integration can replace `ChainPanel.tick_sound` or disable `tick_enabled`
  when Lane E's dedicated countdown rig is present, avoiding duplicate ticks.
- Preview word examples, eight-word loop and the full temperature sequence
  come from the approved `docs/design/CH2_DESIGN.md`. These are fixtures for
  presentation, not production word choices or a chapter director.
- English previews localize the interface; the fixture words remain Vietnamese
  because the specified game is Vietnamese word chaining. Production UI renders
  the translated keys supplied by core without deciding word validity.

24 captures, 1920x1080, rendered in Godot 4.7.2. Open
`res://ui/ch2_ui_preview.tscn` with `-- --ch2-ui=<mode>_<locale>`:
`chain_corpse`, `chain_player`, `chain_blocked`, `chain_timeout`,
`shower_countdown`, `shower_history`, `shower_steam`, `shower_wiped`,
`corpse_lunge`, `scald`, `phone` (vi/en); plus `scald_reduced_vi`,
`camera_steam_vi`. Capture frame 4 at 30 fps with `--quit-after-frames=8`.
Use isolated APPDATA on D: because the preview sets the accessibility preference.

Shower evidence displays the actual SubViewport texture at a readable size;
mounting and reading its 0.4 x 0.3 metre quad in the final bathroom requires
integration with Lane B's ShowerScreen anchor and Lane A's interactions.
