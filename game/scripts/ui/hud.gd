extends CanvasLayer
## Passive overlay. EventBus producers retain ownership of interaction/gameplay.

const IDLE_CROSSHAIR := Color(0.55, 0.58, 0.62, 0.8)
const FOCUSED_CROSSHAIR := Color(1.0, 1.0, 1.0, 1.0)

var _prompt_key := ""
var _subtitle_key := ""
var _subtitle_queue: Array[Dictionary] = []
var _keycap: Panel

@onready var _crosshair: ColorRect = $Root/Crosshair
@onready var _prompt: Label = $Root/Prompt
@onready var _subtitle_panel: PanelContainer = $Root/SubtitleMargin/SubtitlePanel
@onready var _subtitle: Label = $Root/SubtitleMargin/SubtitlePanel/Subtitle
@onready var _subtitle_timer: Timer = $SubtitleTimer


func _ready() -> void:
	_create_keycap()
	EventBus.interaction_focus_changed.connect(_on_focus_changed)
	EventBus.subtitle_requested.connect(_on_subtitle_requested)
	_subtitle_timer.timeout.connect(_show_next_subtitle)
	_on_focus_changed("")
	_show_next_subtitle()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_text()


func _on_focus_changed(prompt_key: String) -> void:
	_prompt_key = prompt_key
	_prompt.visible = not _prompt_key.is_empty()
	_crosshair.color = IDLE_CROSSHAIR if _prompt_key.is_empty() else FOCUSED_CROSSHAIR
	_refresh_text()


func _on_subtitle_requested(text_key: String, duration: float) -> void:
	# Invalid requests must not leave a permanent caption or stall the queue.
	if text_key.is_empty() or not is_finite(duration) or duration <= 0.0:
		return
	_subtitle_queue.append({"key": text_key, "duration": duration})
	if _subtitle_key.is_empty():
		_show_next_subtitle()


func _show_next_subtitle() -> void:
	if _subtitle_queue.is_empty():
		_subtitle_key = ""
		_subtitle_panel.hide()
	else:
		var request: Dictionary = _subtitle_queue.pop_front()
		_subtitle_key = request["key"]
		_subtitle_panel.show()
		_subtitle_timer.start(request["duration"])
	_refresh_text()


func _refresh_text() -> void:
	_prompt.text = tr("UI_INTERACTION_PROMPT") % tr(_prompt_key) if not _prompt_key.is_empty() else ""
	_subtitle.text = tr(_subtitle_key) if not _subtitle_key.is_empty() else ""
	_place_keycap.call_deferred()


func _create_keycap() -> void:
	_keycap = Panel.new()
	_keycap.name = "Keycap"
	_keycap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_keycap.show_behind_parent = true
	var box := StyleBoxFlat.new()
	box.bg_color = Color("24342d")
	box.border_color = Color("cad2bc")
	box.set_border_width_all(1)
	box.border_width_bottom = 3
	box.set_corner_radius_all(5)
	_keycap.add_theme_stylebox_override("panel", box)
	_prompt.add_child(_keycap)
	_prompt.resized.connect(_place_keycap)


func _place_keycap() -> void:
	if not is_instance_valid(_keycap) or _prompt.text.is_empty():
		return
	_keycap.visible = _prompt.get_line_count() == 1
	# Decorate the existing translated prefix; the public Label and its text stay intact.
	var prefix := tr("UI_INTERACTION_PROMPT").get_slice("%s", 0).strip_edges()
	var font := _prompt.get_theme_font("font")
	var font_size := _prompt.get_theme_font_size("font_size")
	var full_width := font.get_string_size(_prompt.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var prefix_width := font.get_string_size(prefix, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_keycap.size = Vector2(prefix_width + 12, 44)
	_keycap.position = Vector2((_prompt.size.x - full_width) * 0.5 - 6, (_prompt.size.y - 44) * 0.5)
