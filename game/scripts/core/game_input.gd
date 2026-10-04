extends Node
## Registers all input actions at startup so project.godot stays free of
## serialized InputEvent blobs. Physical keycodes keep WASD layout-independent.
## Owner: integrator. New actions: request them in your task card.

const KEY_ACTIONS := {
	"move_forward": [KEY_W],
	"move_back": [KEY_S],
	"move_left": [KEY_A],
	"move_right": [KEY_D],
	"sprint": [KEY_SHIFT],
	"interact": [KEY_E],
	"notebook": [KEY_TAB],
	"pause": [KEY_ESCAPE],
	# Chapter 1 (T-150): survival and the phone (docs/design/STORY.md §5).
	"crouch": [KEY_C, KEY_CTRL],
	"phone": [KEY_Q],
	"flashlight": [KEY_F],
	"hold_breath": [KEY_SPACE],
}

const MOUSE_ACTIONS := {
	"interact": [MOUSE_BUTTON_LEFT],
}


func _enter_tree() -> void:
	for action: String in KEY_ACTIONS:
		_ensure_action(action)
		for keycode: Key in KEY_ACTIONS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = keycode
			InputMap.action_add_event(action, ev)
	for action: String in MOUSE_ACTIONS:
		_ensure_action(action)
		for button: MouseButton in MOUSE_ACTIONS[action]:
			var ev := InputEventMouseButton.new()
			ev.button_index = button
			InputMap.action_add_event(action, ev)


func _ensure_action(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
