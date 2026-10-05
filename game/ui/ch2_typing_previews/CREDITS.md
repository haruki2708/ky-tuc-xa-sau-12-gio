# T-179 — typing UI previews

- Files: `chain_player_{vi,en}.png`, `chain_blocked_{vi,en}.png`, `prediction_nhat_{vi,en}.png`, `prediction_ngu_{vi,en}.png`, `credits_end_{vi,en}.png`.
- Author: project Lane D, assisted by OpenAI Codex (GDScript UI, tests, localization and capture setup). Screenshots rendered by Godot 4.7.2; no image-generation model or new external assets.
- Original UI implementation and capture composition: CC0-1.0, https://creativecommons.org/publicdomain/zero/1.0/ .
- Background reused from [`../title/corridor.png`](../title/corridor.png); source and CC0 authorship: [`../title/CREDITS.md`](../title/CREDITS.md).
- Font: existing Be Vietnam Pro, SIL OFL 1.1; see [`../../assets/fonts/CREDITS.md`](../../assets/fonts/CREDITS.md). Font license is unchanged.
- Dictionary attribution shown in Credits follows [`../../data/ch2/DICTIONARY_LICENSE.md`](../../data/ch2/DICTIONARY_LICENSE.md): Vietnamese/English Wiktionary contributors, extracts by kaikki.org (wiktextract), adapted list CC BY-SA 4.0 (approved D-051 exception). The preview does not redistribute the word list.

## Reproduce

Run Godot from the lane checkout with an isolated APPDATA under `build/T-179/capture-userdata`:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://ui/ch2_ui_preview.tscn --windowed --write-movie build/T-179/chain_player_vi/frame.png --fixed-fps 30 -- --ch2-ui=chain_player_vi --quit-after-frames=8
```

Use the named modes above with `_vi`/`_en`. Credits uses `res://ui/title/title_test.tscn --title-capture=credits_end` (or `credits_end_en`). Evidence is frame `00000004`, rendered at the game's 1920×1080 viewport. These are isolated UI fixtures, not full chapter gameplay. The accented entry in the chain fixture is assigned text, **not proof of Unikey/EVKey/Windows IME input**.
