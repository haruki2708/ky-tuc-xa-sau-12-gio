# T-156 chapter UI captures

- `rulebook_*.png`, `survivors_*.png`, `death_*.png`, `puzzle_*.png`: rendered
  directly in Godot 4.7.2, 1920x1080. Author: project Lane D, OpenAI Codex-assisted
  native UI code. No external images or generated raster artwork added.
- Preview background reuses `../title/corridor.png`; source and CC0-1.0 license
  are documented in `../title/CREDITS.md`.
- Typeface: existing Be Vietnam Pro, see `../../assets/fonts/CREDITS.md`.
- Wrong-code sound reuses `res://audio/sfx/door_latch.ogg`, Lane E's original
  CC0 Foley; see `../../audio/CREDITS.md`. This task does not modify the clip.
- Project-original native controls and captures: CC0-1.0,
  https://creativecommons.org/publicdomain/zero/1.0/.
- Rules, death reason and lock hint use approved chapter data from the repo.

Reproduce: open `res://ui/chapter_panels_test.tscn` (F6), or pass
`-- --chapter-ui=rulebook_vi` / `rulebook_en`, `survivors_vi` / `survivors_en`,
`death_vi` / `death_en`, `puzzle_vi` / `puzzle_en`. `hint_vi` additionally previews
the scrollable hint. Screenshots use frame 4 with `--quit-after-frames=8`.
