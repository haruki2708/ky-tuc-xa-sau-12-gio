class_name DoorBurst
extends Node3D
## Death-only staging. These visual rigs never join AI groups or deal damage.

const BODY: PackedScene = preload("res://assets/models/campus/zombie_01.tscn")
var focus_point: Vector3
var door: Node3D
var hand: Node3D
var crowd: Array[Node3D] = []
var chips: Array[Node3D] = []
var _opened: bool = false
var _advance: float = 1.0


func setup(player: Node3D, camera: Camera3D) -> void:
	top_level = true
	var found_407: bool = false
	for candidate: Node in get_tree().get_nodes_in_group(&"room_doors"):
		if candidate is not Node3D or candidate.get_world_3d() != player.get_world_3d():
			continue
		var is_407: bool = false
		for property: Dictionary in candidate.get_property_list():
			if property.name == "room":
				is_407 = str(candidate.get("room")) == "407"
		if found_407 and not is_407:
			continue
		if door == null or (is_407 and not found_407) or candidate.global_position.distance_squared_to(player.global_position) < door.global_position.distance_squared_to(player.global_position):
			door = candidate
			found_407 = is_407
	var at: Vector3 = door.global_position if door != null else player.global_position - camera.global_basis.z * 2.5
	at.y = player.global_position.y
	global_position = at
	var toward: Vector3 = player.global_position - at
	toward.y = 0
	if toward.length() > 0.01:
		look_at(at + toward)
	focus_point = at + Vector3.UP * 1.25
	_advance = clampf(toward.length() - 0.8, 0.2, 1.8)
	hand = Node3D.new()
	add_child(hand)
	_box(hand, Vector3(0, 0, 0.14), Vector3(0.12, 0.1, 0.4), Color(0.3, 0.22, 0.17))
	_box(hand, Vector3.ZERO, Vector3(0.18, 0.07, 0.17), Color(0.32, 0.23, 0.18))
	for index: int in 5:
		_box(hand, Vector3((index - 2) * 0.035, 0, -0.12), Vector3(0.027, 0.04, 0.13), Color(0.32, 0.23, 0.18))
	for index: int in 3:
		var body: Node3D = BODY.instantiate()
		add_child(body)
		body.call("set_pose", &"grab" if index == 0 else &"walk")
		crowd.append(body)
	for index: int in 6:
		chips.append(_box(self, Vector3.ZERO, Vector3(0.08, 0.25, 0.035), Color(0.3, 0.18, 0.09)))
	advance(0, false)


func advance(seconds: float, reduced: bool) -> void:
	hand.visible = not reduced and seconds < 1.0
	hand.position = Vector3(0.15, 1.25, lerpf(0.08, -0.45, smoothstep(0.0, 0.55, seconds)))
	if seconds >= 0.5 and not _opened:
		_opened = true
		if is_instance_valid(door):
			if door.has_method("set_open"):
				door.call("set_open", true)
			if door is Interactable:
				door.enabled = false
			var blocker: CollisionObject3D = door.get_node_or_null("Blocker") as CollisionObject3D
			if blocker != null:
				blocker.set_deferred("collision_layer", 0)
	for index: int in crowd.size():
		crowd[index].visible = not reduced and seconds >= 0.5
		crowd[index].position = Vector3((index - 1) * 0.48, 0, 0.3 + index * 0.4 - _advance * smoothstep(0.5, 2.2, seconds))
	for index: int in chips.size():
		chips[index].visible = not reduced and seconds >= 0.5 and seconds < 1.5
		var t: float = maxf(0, seconds - 0.5)
		chips[index].position = Vector3((index - 2.5) * (0.12 + t * 0.2), 0.7 + (index % 3) * 0.35 - t * t, -t * 1.2)
		chips[index].rotation.x = t * (index + 2)


func _box(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material = material
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	parent.add_child(node)
	return node
