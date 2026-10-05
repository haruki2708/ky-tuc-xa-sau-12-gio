extends CanvasLayer
## Passive chapter-three feedback. No stamina, combat or guard logic lives here.

var _stamina := 1.0
var _exhausted := false
var _elapsed := 0.0
var _guards: Dictionary = {}
var _enabled := true
var _suspended := false


func _ready() -> void:
	EventBus.stamina_changed.connect(_on_stamina)
	EventBus.bar_picked.connect(func(hits: int) -> void:
		if _enabled and not _suspended:
			$Root/BarIcon.pick(hits))
	EventBus.bar_swung.connect(func(hit: bool, hits: int) -> void:
		if _enabled and not _suspended:
			$Root/BarIcon.swing(hit, hits))
	EventBus.bar_broken.connect(func() -> void:
		if _enabled and not _suspended:
			$Root/BarIcon.break_bar())
	EventBus.guard_warned.connect(_on_guard)
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: reset_display())
	EventBus.chapter_started.connect(func(chapter: int) -> void:
		_enabled = chapter == 3
		reset_display())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: _suspend())
	EventBus.player_failed.connect(func(_reason: StringName) -> void: _suspend())
	EventBus.chapter_finished.connect(func(_chapter: int) -> void: _suspend())
	EventBus.settings_changed.connect(func(section: String, key: String) -> void:
		if section == "accessibility" and key == "reduce_scares":
			_refresh())
	reset_display()


func reset_display() -> void:
	_stamina = 1.0
	_exhausted = false
	_elapsed = 0.0
	_guards.clear()
	_suspended = false
	$Root/BarIcon.clear_icon()
	_refresh()


func _suspend() -> void:
	reset_display()
	_suspended = true
	_refresh()


func _on_stamina(value: float, exhausted: bool) -> void:
	if not _enabled or _suspended or not is_finite(value):
		return
	_stamina = clampf(value, 0.0, 1.0)
	_exhausted = exhausted
	_refresh()


func _on_guard(guard: Node3D, warned: bool) -> void:
	if not _enabled or _suspended or not is_instance_valid(guard):
		return
	var id := guard.get_instance_id()
	if warned:
		_guards[id] = weakref(guard)
	else:
		_guards.erase(id)
	_refresh()


func _process(delta: float) -> void:
	for id: int in _guards.keys():
		var guard: Node = _guards[id].get_ref()
		if not is_instance_valid(guard) or not guard.is_inside_tree():
			_guards.erase(id)
	if not get_tree().paused:
		_elapsed += delta
		$Root/BarIcon.advance(delta)
	_refresh()


func _modal() -> bool:
	if get_tree().paused:
		return true
	for reader in get_tree().get_nodes_in_group("reading_overlay"):
		if reader.is_open():
			return true
	return false


func _refresh() -> void:
	var reduced := bool(Settings.get_value("accessibility", "reduce_scares"))
	var strength := clampf((0.6 - _stamina) / 0.6, 0.0, 1.0)
	if _exhausted and _stamina < 1.0:
		strength = maxf(strength, 0.85)
	$Root.visible = _enabled and not _suspended and not _modal()
	$Root/Stamina.visible = strength > 0.0
	$Root/Stamina.material.set_shader_parameter("strength", strength)
	$Root/Stamina.material.set_shader_parameter("exhausted", _exhausted)
	$Root/Stamina.material.set_shader_parameter("elapsed", _elapsed)
	$Root/Stamina.material.set_shader_parameter("reduced", reduced)
	$Root/GuardWarning.visible = not _guards.is_empty()
	$Root/GuardWarning.material.set_shader_parameter("elapsed", _elapsed)
	$Root/GuardWarning.material.set_shader_parameter("reduced", reduced)
