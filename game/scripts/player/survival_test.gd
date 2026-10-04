extends Node3D
## Standalone controls fixture. Puzzle data is an existing QA sample, not chapter design.

const BUNK: PackedScene = preload("res://scenes/interaction/bunk_spot.tscn")
const HIDE: PackedScene = preload("res://scenes/interaction/hide_spot.tscn")
const PUZZLE: PackedScene = preload("res://scenes/interaction/puzzle_station.tscn")

var _charging: bool = false
var _noise_source: StringName = &""
var _noise_radius: float = 0.0


func _ready() -> void:
	_box(Vector3(10, 0.2, 10), Vector3(0, -0.1, 0), Color(0.2, 0.23, 0.24))
	_box(Vector3(10, 3.5, 0.2), Vector3(0, 1.75, -5), Color(0.3, 0.3, 0.28))
	_box(Vector3(10, 3.5, 0.2), Vector3(0, 1.75, 5), Color(0.3, 0.3, 0.28))
	_box(Vector3(0.2, 3.5, 10), Vector3(-5, 1.75, 0), Color(0.3, 0.3, 0.28))
	_box(Vector3(0.2, 3.5, 10), Vector3(5, 1.75, 0), Color(0.3, 0.3, 0.28))
	for number: int in range(1, 5):
		var x: float = -2.0 if number <= 2 else 2.0
		var upper: bool = number in [1, 4]
		var height: float = 1.85 if upper else 0.45
		_box(Vector3(1.0, 0.15, 2), Vector3(x, height, -2.8), Color(0.23, 0.3, 0.27))
		var spot: HideSpot = BUNK.instantiate()
		spot.name = "Bunk%d" % number
		spot.set("bed_number", number)
		spot.position = Vector3(x, 0, -1.7)
		add_child(spot)
		spot.get_node("CollisionShape3D").position.y = height + 0.2
		spot.get_node("View").position.y = height + 0.4
		var label: Label3D = Label3D.new()
		label.text = tr("UI_SURVIVAL_TEST_BED") % number
		label.position = Vector3(0, height + 0.3, 0.05)
		label.font_size = 32
		spot.add_child(label)
	for x: float in [-2.45, -1.55, 1.55, 2.45]:
		_box(Vector3(0.08, 2.4, 0.08), Vector3(x, 1.2, -2.8), Color(0.12, 0.13, 0.14))
	_box(Vector3(1, 2, 0.7), Vector3(-3.8, 1, 0), Color(0.2, 0.25, 0.27))
	var station: Interactable = PUZZLE.instantiate()
	station.name = "PuzzleStation"
	station.set("puzzle_id", &"locker_combo_601")
	station.position = Vector3(-3.8, 1.2, 0.45)
	add_child(station)
	_box(Vector3(1, 2, 0.7), Vector3(3.8, 1, 0), Color(0.2, 0.25, 0.27))
	var hiding: HideSpot = HIDE.instantiate()
	hiding.name = "LockerHide"
	hiding.position = Vector3(3.8, 0, 0.5)
	add_child(hiding)
	$Overlay/Help.text = tr("UI_SURVIVAL_TEST_HELP")
	EventBus.noise_emitted.connect(_on_noise)


func _box(size: Vector3, location: Vector3, color: Color) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	body.add_child(mesh)
	body.position = location
	add_child(body)


func _process(_delta: float) -> void:
	var phone: Node = $Player/Head/Camera3D/PhoneItem
	$Overlay/Status.text = tr("UI_SURVIVAL_TEST_STATUS") % [
		int(GameState.get_flag(&"player_bed", 0)), str($Player.holding_breath),
		phone.battery, str(_charging), str(phone.in_call), str(_noise_source), _noise_radius]


func _on_noise(_position: Vector3, radius: float, source: StringName) -> void:
	_noise_source = source
	_noise_radius = radius


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var phone: Node = $Player/Head/Camera3D/PhoneItem
	match event.physical_keycode:
		KEY_Y:
			_charging = not _charging
			phone.charge(5.0 if _charging else 0.0)
		KEY_U:
			phone.set_in_call(not phone.in_call)
		KEY_B:
			phone.set_battery(1.0)
		KEY_K:
			EventBus.puzzle_solved.emit(&"locker_combo_601")
		KEY_X:
			EventBus.puzzle_closed.emit(&"locker_combo_601")
