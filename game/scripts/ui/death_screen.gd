extends CanvasLayer
## Core emits player_failed(reason_key), waits five seconds and reloads.
## Do not pause the tree or initiate a second checkpoint reload here.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
@export var player_path: NodePath = ^"../Player"
@export var pause_menu_path: NodePath = ^"../PauseMenu"
var _open := false
var _reason := ""
var _count := -1
var _player: Node


func _ready() -> void:
	add_to_group("death_screen")
	add_to_group("reading_overlay") # Esc must not open the pause menu over death.
	var shade := ColorRect.new()
	shade.color = Color("050807")
	$Root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content := Layout.card($Root, Rect2(0.15, 0.27, 0.7, 0.46))
	Layout.cinematic_style($Root/Card, true)
	for spec in [["Title", "UI_CH1_DEATH_TITLE", 60], ["Reason", "", 32],
		["Count", "", 38], ["Retry", "UI_DEATH_RELOADING", 26]]:
		var text := Layout.label(content, spec[0], spec[1], spec[2])
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if spec[0] == "Title":
			text.add_theme_color_override("font_color", Color("decabe"))
			text.add_theme_font_override("font", preload("res://assets/fonts/be_vietnam_pro_semibold.ttf"))
		elif spec[0] == "Retry":
			text.add_theme_color_override("font_color", Color("adb8aa"))
	$Root.hide()
	EventBus.player_failed.connect(_on_failed)
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: close_view())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: close_view())


func is_open() -> bool:
	return _open


func _on_failed(reason_key: StringName) -> void:
	if _open:
		return
	for reader in get_tree().get_nodes_in_group("reading_overlay"):
		if reader != self and reader.is_open():
			reader.close_view()
	var menu := get_node_or_null(pause_menu_path)
	if menu != null and menu.has_method("close_menu"):
		menu.close_menu()
	_reason = String(reason_key)
	var alive := int(GameState.get_flag(&"survivors", -1))
	_count = maxi(0, alive - 1) if alive >= 0 else -1
	_open = true
	_player = get_node_or_null(player_path)
	if _player != null and _player.has_method("acquire_control_lock"):
		_player.acquire_control_lock(self)
	$Root.show()
	_refresh()


func _input(_event: InputEvent) -> void:
	if _open:
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	$Root/Card/Content/Reason.text = tr(_reason) if not _reason.is_empty() and tr(_reason) != _reason else tr("UI_DEATH_REASON_UNKNOWN")
	$Root/Card/Content/Count.text = tr("UI_SURVIVORS_COUNT") % _count if _count >= 0 else tr("UI_SURVIVORS_UNKNOWN")


func close_view() -> void:
	_open = false
	$Root.hide()
	if is_instance_valid(_player) and _player.has_method("release_control_lock"):
		_player.release_control_lock(self)
	_player = null


func _exit_tree() -> void:
	if _open:
		close_view()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()
