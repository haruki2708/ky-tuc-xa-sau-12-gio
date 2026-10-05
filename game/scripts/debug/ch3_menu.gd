extends CanvasLayer
## Chapter 3 shares F9 with the chapter 1 menu, but never handles its scene.

const SESSION := preload("res://scripts/debug/qa_menu.gd")
const OBSERVER := preload("res://scripts/debug/ch3_actions.gd")
const POLICY := preload("res://scripts/debug/ch3_policy.gd")
const LABELS := {
	"QA3_TITLE": [
		"Thử chương 3 — F9 đóng",
		"Chapter 3 QA — F9 closes"
	],
	"QA3_B": [
		"Nhà B",
		"Building B"
	],
	"QA3_GARDEN": [
		"Vườn hoa",
		"Garden"
	],
	"QA3_STADIUM": [
		"Sân vận động",
		"Stadium"
	],
	"QA3_GATE": [
		"Cổng trường",
		"Gate"
	],
	"QA3_MISSING": [
		"Chờ scene/API chương 3",
		"Waiting for chapter 3 scene/API"
	],
	"QA3_SAVE": [
		"Thao tác dùng phiên QA và bản lưu riêng.",
		"Actions use an isolated QA session and saves."
	],
	"QA3_ZOMBIES_ON": [
		"Bật xác",
		"Enable zombies"
	],
	"QA3_ZOMBIES_OFF": [
		"Tắt xác",
		"Disable zombies"
	],
	"QA3_GIVE_BAR": [
		"Cho thanh sắt",
		"Give iron bar"
	],
	"QA3_REFILL": [
		"Nạp đầy thể lực",
		"Refill stamina"
	]
}
var profile: Dictionary = {}
var profile_path: String = ""
var panel: PanelContainer
var observer: Node
var _catalogs: Array[Translation] = []
var _paused: bool = false
var _mouse: int = Input.MOUSE_MODE_VISIBLE
var _busy: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	profile_path = ProjectSettings.globalize_path("res://../tools/ch3-profile.json")
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter-profile=") and "--qa-chapter=3" in OS.get_cmdline_user_args(): profile_path = arg.trim_prefix("--chapter-profile=")
	if FileAccess.file_exists(profile_path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(profile_path))
		if parsed is Dictionary: profile = parsed
	for locale in ["vi", "en"]:
		var catalog := Translation.new()
		catalog.locale = locale
		for key: String in LABELS: catalog.add_message(key, LABELS[key][0 if locale == "vi" else 1])
		TranslationServer.add_translation(catalog)
		_catalogs.append(catalog)
	observer = OBSERVER.new()
	observer.profile = profile
	add_child(observer)
	_build()
	if "--qa-chapter=3" in OS.get_cmdline_user_args():
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--qa-stage="): jump.call_deferred(arg.trim_prefix("--qa-stage="))


func _build() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size.x = 540
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	for key in ["QA3_TITLE", "QA3_SAVE"]:
		var label := Label.new()
		label.text = key
		box.add_child(label)
	for destination: String in POLICY.STAGES:
		var button := Button.new()
		button.name = destination
		button.text = "QA3_" + destination.to_upper()
		button.disabled = not available(destination)
		button.tooltip_text = "QA3_MISSING" if button.disabled else ""
		button.pressed.connect(jump.bind(destination))
		box.add_child(button)
	for key in ["zombies_on", "zombies_off", "give_bar", "refill"]:
		var button := Button.new()
		button.name = key
		button.text = "QA3_" + key.to_upper()
		button.disabled = not profile.get("menu_actions", {}).get(key) is Dictionary
		button.pressed.connect(apply_action.bind(key))
		box.add_child(button)
	panel.hide()


func available(destination: String) -> bool:
	return profile.get("jumps", {}).get(destination) is String and profile.get("scene") is String and ResourceLoader.exists(profile.scene)


func _input(event: InputEvent) -> void:
	var current := get_tree().current_scene
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9 and current != null and current.get_node_or_null(str(profile.get("director", "Chapter3Director"))) != null:
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


func apply_action(key: String) -> void:
	if not SESSION.isolated():
		_launch("b")
		return
	observer.world = get_tree().current_scene
	observer.profile = {"actions": profile.get("menu_actions", {})}
	var outcome: Dictionary = await observer.perform(key)
	print("QA_CH3_ACTION: ", outcome.status, " ", outcome.reason)


func jump(destination: String) -> void:
	if _busy or not available(destination):
		print("QA_CH3_JUMP: SKIP T-181 scene/stage unavailable: ", destination)
		return
	if not SESSION.isolated():
		_launch(destination)
		return
	var scene := (load(profile.scene) as PackedScene).instantiate()
	var director := scene.get_node_or_null(str(profile.get("director", "Chapter3Director")))
	if director == null or not director.has_method("run_from") or not "auto_start" in director:
		scene.free()
		print("QA_CH3_JUMP: SKIP T-181 run_from/auto_start unavailable")
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
	GameState.chapter = 3
	get_tree().paused = false
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	if profile.get("rule_set") is String: RuleSystem.load_rule_set(load(profile.rule_set))
	EventBus.chapter_started.emit(3)
	_busy = false
	director.run_from(StringName(profile.jumps[destination]))


func _launch(destination: String) -> void:
	var root := ProjectSettings.globalize_path("res://../build/qa-menu/ch3-%s" % Time.get_ticks_usec())
	if DirAccess.make_dir_recursive_absolute(root) != OK: return
	var previous := OS.get_environment("APPDATA")
	var previous_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("APPDATA", root)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "res://scripts/debug/qa_preview.tscn", "--", "--qa-menu", "--qa-chapter=3", "--qa-stage=" + destination, "--chapter-profile=" + profile_path])
	var pid := OS.create_process(OS.get_executable_path(), args)
	OS.set_environment("APPDATA", previous)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", previous_root)
	print("QA_CH3_SESSION: pid=", pid, " userdata=", root)


func _exit_tree() -> void:
	for catalog: Translation in _catalogs: TranslationServer.remove_translation(catalog)
