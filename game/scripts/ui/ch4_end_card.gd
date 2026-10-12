extends CanvasLayer
## Core stops gameplay. This view owns only the chapter card, thanks and credits.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
const SECTIONS = preload("res://scripts/ui/title_screen.gd").CREDIT_SECTIONS
@export var app_path: NodePath = ^"/root/App"
var active := false
var elapsed := 0.0


func _ready() -> void:
	var content := Layout.card($Root, Rect2(0.16, 0.10, 0.68, 0.8))
	Layout.cinematic_style($Root/Card)
	Layout.label(content, "End", "UI_CH4_END", 46).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Layout.label(content, "Thanks", "UI_CH4_THANKS", 36).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var scroll := ScrollContainer.new()
	scroll.name = "Credits"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_theme_constant_override("separation", 24)
	scroll.add_child(lines)
	for section: String in SECTIONS:
		Layout.label(lines, section + "Title", "UI_CREDITS_" + section + "_TITLE", 28)
		Layout.label(lines, section + "Text", "UI_CREDITS_" + section + "_TEXT", 24)
	Layout.button(content, "Return", "UI_RETURN_TITLE", _return_title)
	EventBus.chapter_finished.connect(func(chapter: int) -> void:
		if chapter == 4 and not active:
			active = true
			elapsed = 0.0
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_refresh())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: close_card())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: close_card())
	_refresh()


func close_card() -> void:
	active = false
	elapsed = 0.0
	_refresh()


func _process(delta: float) -> void:
	if active and not get_tree().paused:
		elapsed += delta
		_refresh()


func _refresh() -> void:
	$Root.visible = active
	$Root/Shade.color.a = clampf(elapsed / 2.0, 0.0, 1.0)
	$Root/Card.visible = active and elapsed >= 2.0
	for path in ["Thanks", "Credits", "Return"]:
		get_node("Root/Card/Content/" + path).visible = active and elapsed >= 5.0


func _return_title() -> void:
	if active and elapsed >= 5.0:
		get_node(app_path).return_to_title()
