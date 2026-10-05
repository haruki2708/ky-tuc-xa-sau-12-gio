# T-185 — Chapter-three UI and evidence

- Author: project Lane D, assisted by OpenAI Codex for GDScript, shaders, native scenes, localization, tests and capture setup.
- Original UI: `ch3_status.tscn`, `ch3_end_card.tscn`, `stamina.gdshader`, `guard_warning.gdshader`; scripts `ch3_status.gd`, `iron_bar_icon.gd`, `ch3_end_card.gd`, `ch3_ui_preview.gd` under `res://scripts/ui/`. The iron-bar silhouettes are drawn with native polylines. Bloody handprints and electrical death effects extend `../death/blood_overlay.gdshader` procedurally; no external texture or image-generation model.
- Original code/visual composition: CC0-1.0, https://creativecommons.org/publicdomain/zero/1.0/ . Project source: https://github.com/tuaanh666/ky-tuc-xa-sau-12-gio .
- Background: existing `../title/corridor.png`, a Godot capture of this project's corridor; CC0 sources and authors in [`../title/CREDITS.md`](../title/CREDITS.md).
- Font: existing Be Vietnam Pro, SIL OFL 1.1, attribution at [`../../assets/fonts/CREDITS.md`](../../assets/fonts/CREDITS.md). No new font or audio asset.

## Evidence

`previews/` contains 28 unedited Godot 4.7.2 screenshots, with LFS storage and committed `.import` files:

- VI/EN pairs: `stamina_full`, `stamina_low`, `stamina_exhausted`; `bar_new`, `bar_bent`, `bar_broken`; `zombie_grab`, `guard_shock`, `guard_warning`; `end_card`, `chapters`.
- Additional VI frames: `guard_flash`, `guard_dark`; `stamina_exhausted_reduced`, `zombie_grab_reduced`, `guard_shock_reduced`, `guard_warning_reduced`.

Reproduce from the lane checkout with APPDATA isolated under `build/T-185/capture-userdata`:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://ui/ch3/ch3_ui_preview.tscn --windowed --write-movie build/T-185/stamina_low_vi/frame.png --fixed-fps 30 -- --ch3-ui=stamina_low_vi --quit-after-frames=8
```

Evidence uses frame `00000004`, rendered at the project's 1920×1080 viewport. Fixture state is frozen at the relevant moment. The chapter-title subtitle demonstrates readable HUD text above the stamina/guard layers; it is a preview caption, not an added story line. These screenshots exercise isolated UI components, not the campus or integrated chapter-three gameplay.
