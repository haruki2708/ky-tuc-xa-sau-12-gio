# Phone UI integration (T-155)

Instance `res://ui/phone/phone_screen.tscn` once under the gameplay scene, on the
main viewport. CanvasLayer 12 keeps it above the PS1 filter and HUD, below modal
reading/pause panels. Do not put it inside a low-resolution world viewport.

The phone never pauses the tree or changes mouse mode. It listens to the T-150
EventBus signals. E/interact answers while raised. Number keys select replies;
with a captured mouse, wheel highlights an option and left click confirms it.
With a visible mouse, buttons also accept direct clicks. Outside a choice the
wheel scrolls the transcript; Shift+wheel scrolls members. Movement is untouched.
Answering/choosing releases `interact` because the current player polls that
action in physics, independently of whether the event was handled.

`choice_seconds` is exported (default 10); `subtitle_seconds` defaults to 4.
Only one choice may be pending. Modal document/puzzle/pause/reading panels hide
the UI and suspend its timer. Battery exhaustion cancels the call, blacks the
phone and prevents replies; the interrupted choice returns -1 at its original
deadline. Charging does not resume that call. Core owns subsequent story flow.

## Checkpoint API

- `snapshot() -> Dictionary`: version 1, deep copied and JSON serializable.
- `restore(data: Dictionary)`: restores UI state without replaying signals,
  subtitles, sounds, or already completed replies. Call after adding to tree.
- Fields: history, members, raised, battery, minutes, flashlight, incoming,
  call, choice, options, remaining, selected, disconnected_choice, version.
- History entries contain id, sender, name_key, text_key, minutes, outgoing,
  spoken. Members map an id to state and name_key.

Integrator must store this dictionary in the chapter checkpoint and coordinate
restoration with the physical phone's battery/light/raised/call state. This UI
does not write checkpoint files. Auto-raising a reply emits `phone_raised(true)`;
the player controller must observe that event and update its own phone state.

Messages load through `MessageData.load_by_id()`. Supply real data in
`game/data/messages/`; the preview subclass overrides only the loader and uses
neutral test fixtures. Member names come from `sender_name_key`; for members
who have not spoken, seed `members` through restore with their approved name
keys, or supply their MessageData before emitting member state updates. Unknown
members temporarily show their id; the UI invents no character names.

Lane E should listen to the existing `phone_call_incoming` event for ringtone,
stop on answer/empty battery, and play spoken voice on message events. The phone
already emits `subtitle_requested` once per spoken message, including while
lowered: audio must not duplicate that subtitle. No ringtone or voice asset is
included in this UI task.

## Preview and evidence

Run `res://ui/phone/phone_test.tscn` (F6) for a group with four neutral replies.
Pass `-- --phone-capture=incoming`, `group`, `incoming_en`, `group_en` or `hidden`
to choose the fixture. No authored story dialogue, save or progress is changed.
For screenshots use movie recording at 1920x1080 and select a frame before
`App.quit()` starts (it pauses the tree, correctly hiding the phone).

`previews/` contains VI/EN incoming/group images. Chapter/warning evidence is in
`../title/previews/` with `chapters_*` and `warning_ch1_*` filenames.

## Asset credits

Phone frame, flashlight glyph, member status/avatar and vignette are native
Godot drawing/shader code authored with OpenAI Codex; no third-party art added.
Evidence PNGs are Godot-rendered captures of this UI. The preview reuses the
existing corridor and font; their provenance is recorded in
`../title/CREDITS.md` and `../../assets/fonts/CREDITS.md`.
