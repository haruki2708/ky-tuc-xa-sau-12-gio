extends CanvasLayer
## Procedural screen blood sits below DeathScreen; core owns the death sequence.

var _elapsed := 0.0
var _kind: StringName = &"none"


func _ready() -> void:
	$Root.hide()
	EventBus.player_death_started.connect(_start)
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: _clear())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: _clear())
	EventBus.settings_changed.connect(func(section: String, key: String) -> void:
		if section == "accessibility" and key == "reduce_scares":
			_refresh())


func _start(kind: StringName) -> void:
	_kind = kind
	_elapsed = 0.0
	$Root.visible = kind in [&"fall_back", &"bed_burst", &"manager_kill"]
	_refresh() # The manager's full splash is visible in the very first rendered frame.


func _clear() -> void:
	_kind = &"none"
	_elapsed = 0.0
	$Root.hide()


func _process(delta: float) -> void:
	if $Root.visible and not get_tree().paused:
		_elapsed += delta
		_refresh()


func _refresh() -> void:
	$Root.material.set_shader_parameter("elapsed", _elapsed)
	$Root.material.set_shader_parameter("splash", _kind == &"manager_kill")
	$Root.material.set_shader_parameter("reduced", bool(Settings.get_value("accessibility", "reduce_scares")))
