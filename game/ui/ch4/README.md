# Chapter 4 UI integration

The existing `res://ui/notebook/notebook.tscn` and `res://ui/phone/phone_screen.tscn` include chapter-four views. Do not instantiate additional copies of their scripts. Only the chapter end card and hospital cards need separate scene instances.

## Book

`Notebook/Root/Book/Content/Chapter4` contains `Tabs`, `CompareScroll` and `Forms`.

- `GameState.chapter == 4` enables the extra tabs; `ch4_compare_enabled` additionally gates Compare. Opening Compare emits `ch4_compare_opened`.
- Canonical RuleData from chapters 1–3 supplies prior rounds when RuleSystem has replaced the current chapter's set. Current RuleSystem entries take precedence. Round 1 displays `ch1_general_3`, the prohibition on leaving one's room identified in STORY §5. No rule text is rewritten.
- Core sets string flags `ch4_solved_r2`, `ch4_solved_r3`, `ch4_solved_r4` to its `UI_CH4_SOLVED_R2…R4` translation keys. Missing flags leave those notes empty. Rounds 1 and 5 have no solution-note column.
- Selection emits only a RuleSystem ID through `ch4_sentence_marked`. Only the matching pending `ch4_compare_result` can underline permanently; an incorrect result clears the pending underline. UI does not change suspicion, penalties or the chapter outcome.
- UI-owned string flag `ch4_ui_marked_rule` persists the accepted underline and its note in the existing GameState snapshot.

For chapter 4, opening the book does **not** pause the scene tree: door deadlines continue. The book acquires/releases the existing player control lock through exported `reader_player_path` (default `../Player`). Set that path when nesting the UI elsewhere. Other chapters keep the existing pause behavior. Death/checkpoint/chapter reset closes the reader and releases its lock.

## Survivor form and blood name

`Chapter4/Forms` includes `Collected`, `PaperScroll/Paper/Fields`, `Bite`, and `BloodName/Entry`, `BloodName/Clock`.

- `bed_slat_flipped(1|2|4)` records a distinct paper and opens the Collected papers tab. UI-owned bool flags `ch4_ui_scrap_1`, `_2`, `_4` persist the collection. Core still owns `ch4_slats_found`.
- `survivor_form_assembled` displays the assembled form. Core owns/persists `ch4_form_ready`.
- Core must supply approved string values or translation keys through `ch4_form_sex`, `ch4_form_age`, `ch4_form_dob`. Missing facts stay blank. Room 407/building B come directly from the approved chapter design. The full-name field starts blank; no answer suggestion is shown.
- `Forms.door_seconds` defaults to the approved 90-second 407 duration. Set it if core tunes the door. `door_damage_changed("407", fraction)` reports **damage / required seconds** (T-195), so the view uses `1 - fraction` as remaining durability. Other doors do not change this clock.
- Bite emits `blood_name_requested(door_seconds * remaining_fraction)`. The same signal can be issued directly by core with its authoritative remaining seconds. A restored countdown can be initialized with the optional `ch4_door_fraction` flag (**remaining** fraction); re-emitting the actual door-damage signal is preferred.
- Native LineEdit/IME sends the original text through `blood_name_typed`, once per pending attempt. `wrong` retains the draft and permits another attempt; `accepted` reveals the submitted text as a blood signature; `timeout` releases the keyboard. Core alone validates names and handles death at the deadline.
- UI-owned `ch4_ui_signature` saves the exact accepted text; core's `ch4_signed` controls restoration. Raw text is rendered literally and never interpreted as BBCode or a translation key.

## Phone and body fade

`PhoneScreen/Root/Phone/Content/Chapter4/Message` uses the same native timed editor. `fade_message_requested(seconds)` closes readers, raises the existing phone, selects chat and starts the body fade. Core supplies 12 seconds for the approved default.

- `fade_message_typed` forwards the original draft; `fade_message_closed("sent")` appends it to the real transcript only after core's reply. Timeout does not fabricate a message or choose an ending.
- Keyboard focus emits the existing `text_entry_changed` true/false pair. Esc releases the field, Enter reopens it. Actual pause freezes presentation timers; hidden UI releases focus.
- `PhoneScreen/BodyFade` is a passive CanvasLayer 9: slow silver edges and original native polygon hand silhouettes. No flash/shake is used, including with Reduce Scares enabled. `ch4_ending`, death and checkpoint reset remove it; core owns the full-screen transition and scene switch.
- `Status/DecoyCharges` displays the bell icon and count only in chapter 4, from `ch4_phone_charges` and `phone_decoy_thrown`. UI does not spend charges or trigger throws.

## Hospital and ending

- Attach `res://ui/ch4/bed_card.tscn` below each `Bed_Trung/Card`, `Bed_Nhat/Card`, `Bed_Ngu/Card`. It infers the character from its ancestor; exported `character` can override this. `Name` and `Details` are Label3D children over a native card mesh. `age_text` is optional approved data, never invented by UI.
- `ch4_ending("all"|"alone")` shows/hides companion cards. Trung's card always stays visible. Set `ch4_ending` flag before mounting cards if the signal was already emitted. Core/B owns the patients and empty beds themselves.
- Instance `res://ui/ch4/ch4_end_card.tscn` once. `chapter_finished(4)` fades to the chapter card, then thanks/credits. Credits reuse the existing title-screen sections. Core must stop gameplay before this signal. The Return button uses exported `app_path` (default `/root/App`). No chapter 5 unlock is attempted.
- Existing blood overlay now accepts `door_burst`, reusing its blood/hand layer and Reduce Scares behavior; Lane A owns the camera and door/zombie scene. Existing chapter-three stamina/bar UI now also accepts `chapter_started(4)`.

## Validation and export

`pwsh tools/test.ps1 -Filter ch4_ui` exercises signals, native Enter/Esc, control locks, damage fraction, retries, deadlines, restoration, translations and both ending cards. `ch4_ui_preview.tscn` provides VI/EN presentation fixtures; see CREDITS.md for capture arguments and limitations.

Core should exclude `ui/ch4/previews/*`, `ui/ch4/ch4_ui_preview*` and `scripts/ui/ch4_ui_preview.gd*` from release exports. Gameplay integration, OS-level Vietnamese IME composition, controller feel and the final hospital environment still require an integrated playtest.
