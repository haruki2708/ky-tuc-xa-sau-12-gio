extends CanvasLayer
## F9 opens a debug-only menu. Mutating controls launch an isolated child
## process first; APPDATA is inherited only by that process, then restored.

const QA_DIRECTOR := preload("res://scripts/debug/qa_director.gd")
const SCENE := "res://scenes/main/chapter1.tscn"
const LABELS := {
	"QA_TITLE": ["Thử nhanh chương 1 — F9 đóng", "Chapter 1 QA — F9 closes"],
	"QA_SESSION": ["Thao tác mở phiên thử riêng; không dùng bản lưu thật.", "Actions open a separate session with isolated saves."],
	"QA_PROLOGUE": ["Đầu mở đầu", "Prologue"], "QA_R1": ["Vòng 1", "Round 1"],
	"QA_NETWORK": ["Mất mạng (4:28)", "Network lost (4:28)"],
	"QA_WALL": ["Gõ tường (4:38)", "Wall taps (4:38)"],
	"QA_DOOR": ["Giữ cửa (4:35)", "Hold the door (4:35)"],
	"QA_R2": ["Vòng 2", "Round 2"], "QA_MANAGER": ["Trước quản lý tới 407", "Before manager enters 407"],
	"QA_ADVICE": ["Cứu Minh Nhật", "Save Minh Nhat"],
	"QA_GOD": ["Bất tử (ghi log lý do chết)", "Invincible (log death reasons)"],
	"QA_ANSWERS": ["Hiện đáp án bản 2", "Show v2 answers"],
	"QA_SPEED": ["Tua nhanh x4", "Fast forward x4"],
	"QA_MISSING": ["Chưa có API/mốc trong profile T-160", "T-160 API/stage not bound in profile"],
	"QA_SOLUTION": ["Bản 2: tủ 2109; công tắc 2; dây xanh.\nKhoa: gõ 3 cái, nghỉ 1 giây, 1 cái ở tường 406 → mẩu giấy \"Nó hỏi số giường.\"\nQuản lý: nằm giường 1, 2 hoặc 4, tắt đèn bàn và điện thoại, không đứng dậy.", "V2: locker 2109; switch 2; blue cable.\nKhoa: knock 3, pause 1 s, 1 on wall 406 → the note \"He asks for bed numbers.\"\nManager: lie on bed 1, 2 or 4, lamp and phone off, do not get up."],
}
const DESTINATIONS := ["prologue", "r1", "network", "wall", "door", "r2", "manager", "advice"]
const KEYS := ["QA_PROLOGUE", "QA_R1", "QA_NETWORK", "QA_WALL", "QA_DOOR", "QA_R2", "QA_MANAGER", "QA_ADVICE"]
var jumps: Dictionary = {"prologue": "prologue", "r1": "r1", "r2": "r2", "manager": "r2_manager"}
var panel: PanelContainer
var answers: Label
var invincible: bool = false
var fast: bool = false
var saved_pause: bool = false
var saved_mouse: int = Input.MOUSE_MODE_VISIBLE
var _translations: Array[Translation] = []
var _jumping: bool = false


static func isolated() -> bool:
	var root := OS.get_environment("QA_PLAYTHROUGH_ROOT").replace("\\", "/")
	return not root.is_empty() and OS.get_user_data_dir().replace("\\", "/").begins_with(root + "/")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	for language in ["vi", "en"]:
		var catalog := Translation.new()
		catalog.locale = language
		for key: String in LABELS:
			catalog.add_message(key, LABELS[key][0 if language == "vi" else 1])
		TranslationServer.add_translation(catalog)
		_translations.append(catalog)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter-profile="):
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--chapter-profile=")))
			if data is Dictionary and data.get("jumps") is Dictionary:
				jumps.merge(data.jumps, true)
	_build()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-stage=") and isolated() and "--qa-chapter=2" not in OS.get_cmdline_user_args() and "--qa-chapter=3" not in OS.get_cmdline_user_args():
			invincible = "--qa-invincible" in OS.get_cmdline_user_args()
			fast = "--qa-fast" in OS.get_cmdline_user_args()
			var box := panel.get_child(0)
			box.get_node("QA_GOD").set_pressed_no_signal(invincible)
			box.get_node("QA_SPEED").set_pressed_no_signal(fast)
			jump.call_deferred(arg.trim_prefix("--qa-stage="))


func _build() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size = Vector2(530, 0)
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	for key in ["QA_TITLE", "QA_SESSION"]:
		var label := Label.new()
		label.text = key
		box.add_child(label)
	for i in DESTINATIONS.size():
		var button := Button.new()
		button.text = KEYS[i]
		button.disabled = not destination_available(DESTINATIONS[i])
		if button.disabled: button.tooltip_text = tr("QA_MISSING")
		button.pressed.connect(jump.bind(DESTINATIONS[i]))
		box.add_child(button)
	for key in ["QA_GOD", "QA_ANSWERS", "QA_SPEED"]:
		var toggle := CheckButton.new()
		toggle.text = key
		toggle.name = key
		toggle.button_pressed = invincible if key == "QA_GOD" else fast if key == "QA_SPEED" else false
		box.add_child(toggle)
		toggle.toggled.connect(_toggle.bind(key))
	answers = Label.new()
	answers.text = "QA_SOLUTION"
	answers.visible = false
	box.add_child(answers)
	panel.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		var scene := get_tree().current_scene
		if panel.visible or scene != null and scene.get_node_or_null("Chapter1Director") != null:
			set_open(not panel.visible)
			get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if value == panel.visible: return
	if value:
		saved_pause = get_tree().paused
		saved_mouse = Input.mouse_mode
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		get_tree().paused = saved_pause
		Input.mouse_mode = saved_mouse
	panel.visible = value


func _toggle(value: bool, key: String) -> void:
	if key == "QA_ANSWERS":
		answers.visible = value
		return
	if key == "QA_GOD": invincible = value
	if key == "QA_SPEED": fast = value
	if not isolated(): return # Options apply to the next isolated session.
	var scene := get_tree().current_scene
	var director := scene.get_node_or_null("Chapter1Director") if scene != null else null
	if director != null and director.get_script() == QA_DIRECTOR:
		director.invincible = invincible
	Engine.time_scale = 4.0 if fast else 1.0


func destination_available(destination: String) -> bool:
	var stage: Variant = jumps.get(destination)
	return stage is String and StringName(stage) in QA_DIRECTOR.STAGES

func jump(destination: String) -> void:
	if _jumping or not destination_available(destination): return
	if not isolated():
		_launch(destination)
		return
	_jumping = true
	set_open(false)
	get_tree().paused = false
	var old := get_tree().current_scene
	if old != null:
		old.process_mode = Node.PROCESS_MODE_DISABLED
		for node: Node in old.find_children("*", "", true, false):
			if node.has_method("stop_emitting"): node.stop_emitting()
			if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D: node.stop()
		old.queue_free()
		await get_tree().process_frame
	GameState.reset()
	GameState.chapter = 1
	var scene := load(SCENE).instantiate() as Node
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	var director := scene.get_node("Chapter1Director")
	director.set_script(QA_DIRECTOR)
	director.auto_start = false
	director.invincible = invincible
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	Engine.time_scale = 4.0 if fast else 1.0
	RuleSystem.load_rule_set(load(QA_DIRECTOR.RULE_SET_PATH))
	EventBus.chapter_started.emit(1)
	_jumping = false
	print("QA_JUMP: ", destination, " stage=", jumps[destination], " userdata=", OS.get_user_data_dir())
	director.run_from(StringName(jumps[destination]))


func _launch(destination: String) -> void:
	# No checkpoint/progress calls happen in this process. Godot resolves
	# user:// only at startup, so a second process is necessary for isolation.
	var root := ProjectSettings.globalize_path("res://../build/qa-menu/%s" % Time.get_ticks_usec())
	if DirAccess.make_dir_recursive_absolute(root) != OK: return
	var previous := OS.get_environment("APPDATA")
	var previous_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("APPDATA", root)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "res://scripts/debug/qa_preview.tscn", "--", "--qa-menu", "--qa-stage=" + destination])
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter-profile="): args.append(arg)
	if invincible: args.append("--qa-invincible")
	if fast: args.append("--qa-fast")
	var pid := OS.create_process(OS.get_executable_path(), args)
	OS.set_environment("APPDATA", previous)
	OS.set_environment("QA_PLAYTHROUGH_ROOT", previous_root)
	print("QA_SESSION: pid=", pid, " userdata=", root)


func _exit_tree() -> void:
	for catalog: Translation in _translations:
		TranslationServer.remove_translation(catalog)
