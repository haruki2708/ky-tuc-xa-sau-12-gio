extends CanvasLayer
## Presentation only: the core owns the survivor count.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
@export_range(0.1, 20.0) var display_seconds := 4.0
var _remaining := 0.0
var _count := 0


func _ready() -> void:
	var content := Layout.card($Root, Rect2(0.18, 0.39, 0.64, 0.22))
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root/Card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var text := Layout.label(content, "Count", "", 52)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$Root.hide()
	EventBus.survivor_count_changed.connect(_announce)
	EventBus.player_failed.connect(func(_id: StringName) -> void:
		_remaining = 0.0
		$Root.hide())


func _announce(count: int) -> void:
	_count = maxi(0, count)
	_remaining = display_seconds
	$Root.modulate.a = 1.0
	$Root.show()
	_refresh()


func _process(delta: float) -> void:
	if _remaining <= 0.0 or get_tree().paused:
		return
	_remaining = maxf(0.0, _remaining - delta)
	$Root.modulate.a = minf(1.0, _remaining / minf(1.0, display_seconds))
	$Root.visible = _remaining > 0.0


func _refresh() -> void:
	$Root/Card/Content/Count.text = tr("UI_SURVIVORS_COUNT") % _count


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()
