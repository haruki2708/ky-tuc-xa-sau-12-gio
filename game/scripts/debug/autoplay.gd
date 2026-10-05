extends Node
## Optional QA autoload. Idle unless --autoplay=<path> is supplied.

signal playback_finished
signal command_finished(outcome: Dictionary)

const CHAPTER_ACTIONS := preload("res://scripts/debug/chapter_actions.gd")
var _commands: Node
var _command_busy: bool = false
var command_failed: bool = false

var quit_on_finish: bool = true
var _events: Array[Dictionary] = []
var _held: Array[StringName] = []
var _frame: int = 0
var _cursor: int = 0
var _end_frame: int = 0
var _active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.is_debug_build() or "--qa-menu" in OS.get_cmdline_user_args():
		var menu := preload("res://scripts/debug/qa_menu.gd").new()
		menu.name = "QAMenu"
		add_child(menu)
		var ch2_menu := preload("res://scripts/debug/ch2_menu.gd").new()
		ch2_menu.name = "Chapter2QAMenu"
		add_child(ch2_menu)
	# Observe calls/choices before the first scheduled command; otherwise an
	# answer_call event would miss an already ringing phone.
	_commands = CHAPTER_ACTIONS.new()
	add_child(_commands)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--autoplay="):
			if not load_recording(arg.trim_prefix("--autoplay=")):
				get_tree().quit(1)
			return


func load_recording(path: String) -> bool:
	stop()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not json.data is Array:
		return false
	var parsed: Array[Dictionary] = []
	var previous: int = -1
	for value: Variant in json.data:
		if not value is Dictionary:
			return false
		var event: Dictionary = value
		var number: Variant = event.get("frame")
		if not _is_number(number) or number < 0 or number != floor(number) or number < previous:
			return false
		previous = int(number)
		var operations: int = 0
		for key: Variant in event:
			if key not in ["frame", "press", "release", "mouse_dx", "mouse_dy", "command"]:
				return false
		if event.has("command"):
			if not event.command is Dictionary or not CHAPTER_ACTIONS.valid(event.command) or event.size() != 2:
				return false
			operations += 1
		for key: String in ["press", "release"]:
			if event.has(key):
				if not event[key] is String or not InputMap.has_action(event[key]):
					return false
				operations += 1
		for key: String in ["mouse_dx", "mouse_dy"]:
			if event.has(key):
				if not _is_number(event[key]):
					return false
				operations += 1
		if operations == 0:
			return false
		parsed.append(event)
	_events = parsed
	_frame = 0
	_cursor = 0
	_end_frame = maxi(previous, 0) + 30
	_active = true
	command_failed = false
	print("AUTOPLAY: loaded %d events from %s" % [_events.size(), path])
	return true


func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _process(_delta: float) -> void:
	if not _active or _command_busy:
		return
	while _cursor < _events.size() and int(_events[_cursor]["frame"]) == _frame:
		var event: Dictionary = _events[_cursor]
		if event.has("command"):
			_cursor += 1
			_run_command(event.command)
			return
		if event.has("press"):
			var action := StringName(event["press"])
			Input.action_press(action)
			if action not in _held:
				_held.append(action)
		if event.has("release"):
			var action := StringName(event["release"])
			Input.action_release(action)
			_held.erase(action)
		if event.has("mouse_dx") or event.has("mouse_dy"):
			var motion := InputEventMouseMotion.new()
			motion.relative = Vector2(event.get("mouse_dx", 0), event.get("mouse_dy", 0))
			motion.screen_relative = motion.relative
			get_viewport().push_input(motion, true)
		_cursor += 1
	if _frame >= _end_frame:
		stop()
		playback_finished.emit()
		if quit_on_finish:
			print("AUTOPLAY: finished after %d frames" % (_frame + 1))
			_request_quit()
	_frame += 1


func stop() -> void:
	_active = false
	if is_instance_valid(_commands):
		_commands.cancel()
	for action: StringName in _held:
		Input.action_release(action)
	_held.clear()


func _run_command(command: Dictionary) -> void:
	_command_busy = true
	_commands.world = get_tree().current_scene
	var outcome: Dictionary = await _commands.execute(command)
	print("AUTOPLAY_COMMAND: %s %s" % [outcome.status, outcome.reason])
	command_finished.emit(outcome)
	_command_busy = false
	if outcome.status == "FAIL":
		command_failed = true
		stop()
		if quit_on_finish:
			get_node("/root/App").quit(1)


func _exit_tree() -> void:
	stop()


func _request_quit() -> void:
	var app := _get_app()
	if app != null:
		app.quit()
	else:
		_quit_tree()


func _get_app() -> Node:
	return get_node_or_null("/root/App")


func _quit_tree() -> void:
	get_tree().quit()
