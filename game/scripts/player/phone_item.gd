extends Node3D
## Physical phone only. The screen/call flow belongs to lane D and core.

signal battery_empty

@export_range(0.0, 100.0) var battery: float = 100.0:
	set(value):
		battery = clampf(value, 0.0, 100.0) if is_finite(value) else 0.0
		if is_node_ready():
			_sync_battery()
@export var drain_per_second_flashlight: float = 0.2
@export var drain_per_second_call: float = 0.05

@onready var model: Node3D = $Model
@onready var flashlight: SpotLight3D = $Flashlight

var raised: bool = false
var in_call: bool = false
var _charge_rate: float = 0.0
var _reported_percent: int = -1
var _empty: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	model.hide()
	flashlight.hide()
	_sync_battery()


func _unhandled_input(event: InputEvent) -> void:
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor.has_method("keyboard_input_blocked"):
			if ancestor.call("keyboard_input_blocked"):
				return
			break
		if ancestor.has_method("controls_locked"):
			if ancestor.call("controls_locked"):
				return
			break
		ancestor = ancestor.get_parent()
	if event.is_echo():
		return
	if event.is_action_pressed("phone"):
		set_raised(not raised)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("flashlight"):
		set_flashlight(not flashlight.visible)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	var drain: float = maxf(0.0, drain_per_second_flashlight) if flashlight.visible else 0.0
	if in_call:
		drain += maxf(0.0, drain_per_second_call)
	set_battery(battery + (_charge_rate - drain) * delta)


func set_raised(value: bool) -> void:
	if raised == value:
		return
	raised = value
	model.visible = raised
	EventBus.phone_raised.emit(raised)


func set_flashlight(value: bool) -> void:
	value = value and battery > 0.0
	if flashlight.visible == value:
		return
	flashlight.visible = value
	EventBus.flashlight_toggled.emit(value)


func set_in_call(value: bool) -> void:
	in_call = value


func set_battery(percent: float) -> void:
	battery = percent


func charge(percent_per_second: float) -> void:
	# A persistent rate; charge(0) disconnects the charger. Drain still applies.
	_charge_rate = maxf(0.0, percent_per_second) if is_finite(percent_per_second) else 0.0


func _sync_battery() -> void:
	var percent: int = int(ceilf(battery))
	if percent != _reported_percent:
		_reported_percent = percent
		EventBus.phone_battery_changed.emit(float(percent))
	if battery <= 0.0:
		set_flashlight(false)
		if not _empty:
			_empty = true
			battery_empty.emit()
	else:
		_empty = false


func _exit_tree() -> void:
	if raised:
		EventBus.phone_raised.emit(false)
	if is_instance_valid(flashlight) and flashlight.visible:
		EventBus.flashlight_toggled.emit(false)
