extends CanvasLayer
## Chapter 2 shares F9 with the chapter 1 menu, but never handles its scene.

const SESSION := preload("res://scripts/debug/qa_menu.gd")
const OBSERVER := preload("res://scripts/debug/ch2_actions.gd")
const POLICY := preload("res://scripts/debug/ch2_policy.gd")
const LABELS := {
	"QA2_TITLE": ["Thử chương 2 — F9 đóng", "Chapter 2 QA — F9 closes"],
	"QA2_R3": ["Đầu vòng 3", "Start round 3"], "QA2_R4": ["Đầu vòng 4", "Start round 4"],
	"QA2_MISSING": ["Chờ scene/API/mốc của T-170", "Waiting for T-170 scene/API/stage"],
	"QA2_SHOW": ["Hiện đáp án từ dữ liệu đã thấy", "Show answers from observed data"],
	"QA2_UNKNOWN": ["Chưa có từ/lịch sử nhiệt độ để tính đáp án.", "No word/temperature history to calculate an answer."],
	"QA2_WORD": ["Nối từ: %s", "Word chain: %s"],
	"QA2_WATER": ["Nước lượt tới: %s (theo nhiệt độ vừa hiện)", "Next water slot: %s (from the last revealed temperature)"],
	"QA2_YES": ["Có", "Yes"], "QA2_NO": ["Không", "No"],
	"QA2_SAVE": ["Nhảy mở phiên QA riêng; không dùng bản lưu thật.", "Jump opens an isolated QA session with separate saves."],
}
var profile: Dictionary = {}
var profile_path: String = ""
var panel: PanelContainer
var answers: Label
var observer: Node
var _catalogs: Array[Translation] = []
var _paused: bool = false
var _mouse: int = Input.MOUSE_MODE_VISIBLE
var _busy: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	profile_path = ProjectSettings.globalize_path("res://../tools/ch2-profile.json")
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter-profile=") and "--qa-chapter=2" in OS.get_cmdline_user_args(): profile_path = arg.trim_prefix("--chapter-profile=")
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
	if "--qa-chapter=2" in OS.get_cmdline_user_args():
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--qa-stage="): jump.call_deferred(arg.trim_prefix("--qa-stage="))


func _build() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size.x = 540
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	for key in ["QA2_TITLE", "QA2_SAVE"]:
		var label := Label.new()
		label.text = key
		box.add_child(label)
	var destinations: Dictionary = profile.get("jumps", {"r3": null, "r4": null})
	for destination: String in destinations:
		var button := Button.new()
		button.name = destination
		button.text = "QA2_" + destination.to_upper() if destination in ["r3", "r4"] else destination
		button.disabled = not available(destination)
		button.tooltip_text = "QA2_MISSING" if button.disabled else ""
		button.pressed.connect(jump.bind(destination))
		box.add_child(button)
	var show := CheckButton.new()
	show.text = "QA2_SHOW"
	show.toggled.connect(func(value: bool) -> void: answers.visible = value)
	box.add_child(show)
	answers = Label.new()
	answers.text = "QA2_UNKNOWN"
	answers.hide()
	box.add_child(answers)
	panel.hide()


func available(destination: String) -> bool:
	return profile.get("jumps", {}).get(destination) is String and profile.get("scene") is String and ResourceLoader.exists(profile.scene)


func _input(event: InputEvent) -> void:
	var current := get_tree().current_scene
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9 and current != null and current.get_node_or_null(str(profile.get("director", "Chapter2Director"))) != null:
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


func _process(_delta: float) -> void:
	if not panel.visible or not answers.visible: return
	var text: Array[String] = []
	if observer.chain_pending:
		var choice: Dictionary = observer.recommendation("legal")
		if choice.status == "PASS": text.append(tr("QA2_WORD") % choice.word)
	if not observer.temperatures.is_empty():
		text.append(tr("QA2_WATER") % tr("QA2_YES" if POLICY.shower_yes(observer.temperatures) else "QA2_NO"))
	answers.text = "\n".join(text) if not text.is_empty() else tr("QA2_UNKNOWN")


func jump(destination: String) -> void:
	if _busy or not available(destination):
		print("QA_CH2_JUMP: SKIP T-170 scene/stage unavailable: ", destination)
		return
	if not SESSION.isolated():
		_launch(destination)
		return
	var scene := (load(profile.scene) as PackedScene).instantiate()
	var director := scene.get_node_or_null(str(profile.get("director", "Chapter2Director")))
	if director == null or not director.has_method("run_from") or not "auto_start" in director:
		scene.free()
		print("QA_CH2_JUMP: SKIP T-170 run_from/auto_start unavailable")
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
	GameState.chapter = 2
	observer.recent.clear()
	observer.options.clear()
	observer.temperatures.clear()
	observer.chain_pending = false
	get_tree().paused = false
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	if profile.get("rule_set") is String: RuleSystem.load_rule_set(load(profile.rule_set))
	EventBus.chapter_started.emit(2)
	_busy = false
	director.run_from(StringName(profile.jumps[destination]))


func _launch(destination: String) -> void:
	var root := ProjectSettings.globalize_path("res://../build/qa-menu/ch2-%s" % Time.get_ticks_usec())
	if DirAccess.make_dir_recursive_absolute(root) != OK: return
	var previous := OS.get_environment("APPDATA")
	var previous_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("APPDATA", root)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "res://scripts/debug/qa_preview.tscn", "--", "--qa-menu", "--qa-chapter=2", "--qa-stage=" + destination, "--chapter-profile=" + profile_path])
	var pid := OS.create_process(OS.get_executable_path(), args)
	OS.set_environment("APPDATA", previous)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", previous_root)
	print("QA_CH2_SESSION: pid=", pid, " userdata=", root)


func _exit_tree() -> void:
	for catalog: Translation in _catalogs: TranslationServer.remove_translation(catalog)
