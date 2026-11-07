extends CanvasLayer
## Chapter 4 shares F9 with the chapter 1 menu, but never handles its scene.

const SESSION := preload("res://scripts/debug/qa_menu.gd")
const STAGES := ["split", "library", "return", "room407", "end4"]
const LABELS := {
	"QA4_TITLE": ["Thử chương 4 — F9 đóng", "Chapter 4 QA — F9 closes"],
	"QA4_SAVE": ["Thao tác dùng phiên QA và bản lưu riêng.", "Actions use an isolated QA session and saves."],
	"QA4_SPLIT": ["Chia nhóm", "Split up"],
	"QA4_LIBRARY": ["Thư viện", "Library"],
	"QA4_RETURN": ["Trở về nhà B", "Return to building B"],
	"QA4_ROOM407": ["Phòng 407", "Room 407"],
	"QA4_END4": ["Tin nhắn cuối", "Last message"],
	"QA4_MISSING": ["Chưa có scene/giai đoạn chương 4", "Chapter 4 scene/stage unavailable"]
}
var profile: Dictionary = {}
var profile_path: String = ""
var panel: PanelContainer
var _catalogs: Array[Translation] = []
var _paused: bool = false
var _mouse: int = Input.MOUSE_MODE_VISIBLE
var _busy: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	profile_path = ProjectSettings.globalize_path("res://../tools/ch4-profile.json")
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter-profile=") and "--qa-chapter=4" in OS.get_cmdline_user_args(): profile_path = arg.trim_prefix("--chapter-profile=")
	if FileAccess.file_exists(profile_path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(profile_path))
		if parsed is Dictionary: profile = parsed
	for locale in ["vi", "en"]:
		var catalog := Translation.new()
		catalog.locale = locale
		for key: String in LABELS: catalog.add_message(key, LABELS[key][0 if locale == "vi" else 1])
		TranslationServer.add_translation(catalog)
		_catalogs.append(catalog)
	_build()
	if "--qa-chapter=4" in OS.get_cmdline_user_args():
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--qa-stage="): jump.call_deferred(arg.trim_prefix("--qa-stage="))


func _build() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size.x = 540
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	for key in ["QA4_TITLE", "QA4_SAVE"]:
		var label := Label.new()
		label.text = key
		box.add_child(label)
	for destination: String in STAGES:
		var button := Button.new()
		button.name = destination
		button.text = "QA4_" + destination.to_upper()
		button.disabled = not available(destination)
		button.tooltip_text = "QA4_MISSING" if button.disabled else ""
		button.pressed.connect(jump.bind(destination))
		box.add_child(button)
	panel.hide()


func available(destination: String) -> bool:
	return destination in STAGES and profile.get("jumps", {}).get(destination) in STAGES and profile.get("scene") is String and ResourceLoader.exists(profile.scene)


func _input(event: InputEvent) -> void:
	var current := get_tree().current_scene
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9 and current != null and current.get_node_or_null(str(profile.get("director", "Chapter4Director"))) != null:
		set_open(not panel.visible)
		get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if panel.visible == value: return
	if value:
		_paused = get_tree().paused
		_mouse = Input.mouse_mode
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		get_tree().paused = _paused
		Input.mouse_mode = _mouse
	panel.visible = value


func jump(destination: String) -> void:
	if _busy or not available(destination):
		print("QA_CH4_JUMP: SKIP T-232 scene/stage unavailable: ", destination)
		return
	if not SESSION.isolated():
		_launch(destination)
		return
	var scene := (load(profile.scene) as PackedScene).instantiate()
	var director := scene.get_node_or_null(str(profile.get("director", "Chapter4Director")))
	if director == null or not director.has_method("run_from") or not "auto_start" in director:
		scene.free()
		print("QA_CH4_JUMP: SKIP T-232 run_from/auto_start unavailable")
		return
	director.auto_start = false
	_busy = true
	set_open(false)
	var old := get_tree().current_scene
	if old != null:
		old.process_mode = Node.PROCESS_MODE_DISABLED
		for node: Node in old.find_children("*", "", true, false):
			if node.has_method("stop_emitting"): node.stop_emitting()
			if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D: node.stop()
		old.queue_free()
		await get_tree().process_frame
	GameState.reset()
	GameState.chapter = 4
	get_tree().paused = false
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	# Let the director attach its deferred audio rig before starting a stage.
	await get_tree().process_frame
	if profile.get("rule_set") is String: RuleSystem.load_rule_set(load(profile.rule_set))
	EventBus.chapter_started.emit(4)
	_busy = false
	director.run_from(StringName(profile.jumps[destination]))


func _launch(destination: String) -> void:
	var root := ProjectSettings.globalize_path("res://../build/qa-menu/ch4-%s" % Time.get_ticks_usec())
	if DirAccess.make_dir_recursive_absolute(root) != OK: return
	var previous := OS.get_environment("APPDATA")
	var previous_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("APPDATA", root)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "res://scripts/debug/qa_preview.tscn", "--", "--qa-menu", "--qa-chapter=4", "--qa-stage=" + destination, "--chapter-profile=" + profile_path])
	var pid := OS.create_process(OS.get_executable_path(), args)
	OS.set_environment("APPDATA", previous)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", previous_root)
	print("QA_CH4_SESSION: pid=", pid, " userdata=", root)


func _exit_tree() -> void:
	for catalog: Translation in _catalogs: TranslationServer.remove_translation(catalog)
