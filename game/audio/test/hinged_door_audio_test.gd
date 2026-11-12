extends Node3D
## T-244 listening fixture. No director, saves, gameplay noise or settings changes.

const ROOM := preload("res://scenes/levels/floor4/room_407.tscn")
const SPOTS: Array[Vector3] = [Vector3(5.8, 1.6, -3.0), Vector3(6.4, 1.6, -6.3), Vector3(2.8, 1.6, -7.75)]
var room: Node3D
var camera: Camera3D
var doors: Array[HingedDoor] = []


func _ready() -> void:
	room = ROOM.instantiate() as Node3D
	add_child(room)
	# Silence existing ambience only inside this isolated listening scene.
	for node: Node in room.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.call("stop_emitting")
		(node as AudioStreamPlayer3D).stop()
		node.process_mode = Node.PROCESS_MODE_DISABLED
	for path: String in HingedDoorAudio.DOORS:
		var door := HingedDoor.fit(room.get_node(path) as Node3D)
		doors.append(door)
	HingedDoorAudio.attach_all(room)
	var light := OmniLight3D.new()
	light.position = Vector3(4.0, 2.5, -5.0)
	light.omni_range = 10.0
	light.light_energy = 0.7
	add_child(light)
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	listen_at(0)


func listen_at(index: int) -> void:
	camera.global_position = room.to_global(SPOTS[index])
	var target := doors[1 if index == 2 else 0].hinged.global_position
	target.y = camera.global_position.y - 0.3
	camera.look_at(target)


func swing_door(index: int, open: bool, seconds: float = 0.9) -> void:
	doors[index].swing(open, seconds)


func stop_all() -> void:
	for door: HingedDoor in doors:
		door.swing(door.is_open, 0.0)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_1: swing_door(0, true)
		KEY_2: swing_door(0, false)
		KEY_3: swing_door(1, true)
		KEY_4: swing_door(1, false)
		KEY_5: swing_door(1, true, 0.5)
		KEY_R:
			swing_door(0, false, 0.0)
			swing_door(1, true, 0.0)
		KEY_C: listen_at(0)
		KEY_B: listen_at(1)
		KEY_V: listen_at(2)
		KEY_SPACE: stop_all()
		KEY_ESCAPE:
			stop_all()
			App.quit()
