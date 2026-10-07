extends CanvasLayer
## Procedural screen blood sits below DeathScreen; core owns the death sequence.

var _elapsed := 0.0
var _kind: StringName = &"none"
@export var shower_stall_path: NodePath
var _steam := 0.0
var _inside_shower := false


func _ready() -> void:
	var haze := ColorRect.new()
	haze.name = "CameraSteam"
	haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(haze)
	move_child(haze, 0)
	haze.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fog_material := ShaderMaterial.new()
	fog_material.shader = preload("res://ui/shower/steam.gdshader")
	haze.material = fog_material
	haze.hide()
	EventBus.shower_steam_changed.connect(func(level: float) -> void:
		if is_finite(level):
			_steam = clampf(level, 0.0, 1.0)
			_refresh_steam())
	if not shower_stall_path.is_empty():
		var stall := get_node_or_null(shower_stall_path)
		if stall != null and stall.has_signal("player_inside_changed"):
			stall.player_inside_changed.connect(set_shower_inside)
			set_shower_inside(bool(stall.player_inside))
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
	$Root.visible = kind in [&"fall_back", &"bed_burst", &"manager_kill", &"corpse_lunge", &"scald", &"zombie_grab", &"guard_shock", &"door_burst"]
	_refresh() # The manager's full splash is visible in the very first rendered frame.


func _clear() -> void:
	_kind = &"none"
	_elapsed = 0.0
	$Root.hide()
	$Root.position = Vector2.ZERO
	_steam = 0.0
	_inside_shower = false
	_refresh_steam()


func _process(delta: float) -> void:
	if $Root.visible and not get_tree().paused:
		_elapsed += delta
		_refresh()


func _refresh() -> void:
	$Root.material.set_shader_parameter("elapsed", _elapsed)
	$Root.material.set_shader_parameter("splash", _kind in [&"manager_kill", &"corpse_lunge", &"zombie_grab", &"door_burst"])
	$Root.material.set_shader_parameter("scald", _kind == &"scald")
	$Root.material.set_shader_parameter("handprints", _kind in [&"zombie_grab", &"door_burst"])
	$Root.material.set_shader_parameter("guard_shock", _kind == &"guard_shock")
	var reduced := bool(Settings.get_value("accessibility", "reduce_scares"))
	$Root.material.set_shader_parameter("reduced", reduced)
	$Root.position = Vector2(sin(_elapsed * 57.0), cos(_elapsed * 43.0)) * 5.0 if _kind == &"scald" and not reduced else Vector2.ZERO


func set_shower_inside(inside: bool) -> void:
	_inside_shower = inside
	_refresh_steam()


func _refresh_steam() -> void:
	$CameraSteam.visible = _inside_shower and _steam > 0.0
	$CameraSteam.material.set_shader_parameter("level", _steam if _inside_shower else 0.0)
