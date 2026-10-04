extends Node3D
## P runs a sample stage only; chapter rules remain in the director.

enum Stage { IDLE, DOOR, ENTER, ASK, SLASH, KILL, EXIT }
const BUNK: PackedScene = preload("res://scenes/interaction/bunk_spot.tscn")

var stage: Stage = Stage.IDLE
var door: Interactable
var bed_three: Node3D
var _cuts: int = 0


func _ready() -> void:
	_box(self, Vector3(12, 0.2, 14), Vector3(0, -0.1, 0), Color(0.3, 0.31, 0.3))
	_box(self, Vector3(8, 3.5, 0.2), Vector3(0, 1.75, -4.5), Color(0.45, 0.44, 0.4))
	for x: float in [-4.0, 4.0]:
		_box(self, Vector3(0.2, 3.5, 7.5), Vector3(x, 1.75, -0.75), Color(0.45, 0.44, 0.4))
	for x: float in [-2.35, 2.35]:
		_box(self, Vector3(3.3, 3.5, 0.2), Vector3(x, 1.75, 3), Color(0.45, 0.44, 0.4))
	_make_door()
	for number: int in range(1, 5):
		var x: float = -2.0 if number <= 2 else 2.0
		var height: float = 1.8 if number in [1, 4] else 0.4
		var mattress: Node3D = _box(self, Vector3(1.1, 0.15, 2), Vector3(x, height, -2.5), Color(0.27, 0.32, 0.3))
		if number == 3:
			bed_three = mattress
		var spot: HideSpot = BUNK.instantiate()
		spot.name = "Bunk%d" % number
		spot.set("bed_number", number)
		spot.position = Vector3(x, 0, -1.35)
		add_child(spot)
		spot.get_node("View").position.y = height + 0.45
		spot.get_node("View").rotation.y = PI
		spot.get_node("Exit").position = Vector3(-0.9 if x > 0 else 0.9, 0.02, 0)
		spot.get_node("CollisionShape3D").position.y = height + 0.2
		var label: Label3D = Label3D.new()
		label.text = tr("UI_MANAGER_TEST_BED") % number
		label.position = Vector3(0, height + 0.3, 0.1)
		spot.add_child(label)
		if number != 3:
			_make_corpse(Vector3(x, height + 0.2, -2.5), number)
	$Manager.player = $Player
	$Manager.look_target = bed_three
	$Manager.arrived.connect(_on_arrived)
	$Manager.answered.connect(_on_answered)
	$Manager.slashed.connect(_on_slashed)
	$Manager.slash_finished.connect(_leave)
	EventBus.player_caught.connect(_on_caught)
	$Overlay/Help.text = tr("UI_MANAGER_TEST_HELP")


func _make_door() -> void:
	door = load("res://scenes/levels/floor4/door407.gd").new()
	door.name = "Door"
	door.position = Vector3(-0.7, 0, 3)
	var pivot: Node3D = Node3D.new()
	pivot.name = "Pivot"
	door.add_child(pivot)
	_box(pivot, Vector3(1.4, 2.4, 0.08), Vector3(0.7, 1.2, 0), Color(0.24, 0.21, 0.16))
	var pick: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(1.4, 2.4, 0.15)
	pick.shape = shape
	pick.position = Vector3(0.7, 1.2, 0)
	door.add_child(pick)
	add_child(door)


func _box(parent: Node3D, size: Vector3, position: Vector3, color: Color) -> Node3D:
	var body: StaticBody3D = StaticBody3D.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
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
	body.position = position
	parent.add_child(body)
	return body


func _make_corpse(position: Vector3, number: int) -> void:
	var corpse: Node3D = Node3D.new()
	corpse.name = "Corpse%d" % number
	corpse.position = position
	add_child(corpse)
	for index: int in 4:
		var pose: Node3D = Node3D.new()
		pose.name = ["dead_a", "dead_b", "head_turn", "eyes_open"][index]
		corpse.add_child(pose)
		var body: MeshInstance3D = MeshInstance3D.new()
		var capsule: CapsuleMesh = CapsuleMesh.new()
		capsule.radius = 0.19
		capsule.height = 1.35
		capsule.radial_segments = 8
		capsule.rings = 3
		body.mesh = capsule
		body.rotation.x = PI / 2.0
		body.rotation.z = index * 0.05
		pose.add_child(body)
		var head: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.15
		sphere.height = 0.3
		sphere.radial_segments = 8
		sphere.rings = 4
		head.mesh = sphere
		head.position = Vector3(index * 0.035, 0.05, 0.78)
		pose.add_child(head)
	var poser: UnseenPoser = UnseenPoser.new()
	poser.name = "UnseenPoser"
	poser.camera = $Player/Head/Camera3D
	poser.rng_seed = 152 + number
	corpse.add_child(poser)
	var rustle: CorpseAudio = CorpseAudio.new()
	rustle.poser = poser
	corpse.add_child(rustle)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_P and stage == Stage.IDLE:
		start_demo()


func start_demo() -> void:
	if stage != Stage.IDLE:
		return
	_cuts = 0
	$Manager.global_position = Vector3(0, 0.02, 5)
	stage = Stage.DOOR
	$Manager.walk_to(Vector3(0, 0.02, 3.8))


func _on_arrived() -> void:
	match stage:
		Stage.DOOR:
			$Manager.open_door(door)
			stage = Stage.ENTER
			$Manager.enter_room(PackedVector3Array([Vector3(0, 0.02, 2), Vector3(0.7, 0.02, 0)]))
		Stage.ENTER:
			stage = Stage.ASK
			$Manager.ask("MGR_CH1_ASK_BED_3")
		Stage.EXIT:
			stage = Stage.IDLE
			door.call("set_open", false)


func _on_answered(heard: bool) -> void:
	if stage != Stage.ASK:
		return
	stage = Stage.KILL if heard else Stage.SLASH
	if heard:
		$Manager.kill_player()
	else:
		$Manager.slash(bed_three)


func _on_slashed(_target: Node3D) -> void:
	_cuts += 1
	# Placeholder damage feedback, never modifying lane B's room/model.
	bed_three.get_child(1).rotation.z = 0.03 * _cuts


func _on_caught(id: StringName) -> void:
	if id == &"manager" and stage == Stage.KILL:
		$Overlay/Blackout.show()
		var fade: Tween = create_tween()
		fade.tween_interval(0.4)
		fade.tween_callback($Overlay/Blackout.hide)
		_leave()


func _leave() -> void:
	stage = Stage.EXIT
	$Manager.enter_room(PackedVector3Array([Vector3(0, 0.02, 2), Vector3(0, 0.02, 5)]))


func _process(_delta: float) -> void:
	$Overlay/Status.text = tr("UI_MANAGER_TEST_STATUS") % [Stage.keys()[stage], DormManager.State.keys()[$Manager.state], _cuts]
