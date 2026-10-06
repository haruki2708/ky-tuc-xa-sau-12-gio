extends Node3D
## Visual/geometry contract for T-183. No chapter rules or actor AI.
@export var floor4_path: NodePath = NodePath("../Floor4")
var fire_door_open: bool = false
var main_door_chained: bool = true
var _restores: Array[Dictionary] = []


func _ready() -> void:
	set_fire_door_open(fire_door_open)
	set_main_door_chained(main_door_chained)
	set_canteen_tv(false)
	set_stadium_lights(false)
	call_deferred("attach_floor4", get_node_or_null(floor4_path))


func attach_floor4(floor4: Node3D) -> void:
	# Open only the two end caps on this live instance; legacy scenes stay intact.
	if floor4 == null or not _restores.is_empty():
		return
	# Floor4 also works without Campus in chapters 1-2. Avoid overlapping
	# navigation regions when the complete campus supplies the same corridor.
	for path in ["Corridor/Navigation", "Corridor/Room407Link"]:
		var navigation := floor4.get_node_or_null(path)
		if navigation:
			_restores.append({"node": weakref(navigation), "property": &"enabled", "value": navigation.enabled})
			navigation.enabled = false
	for path in ["Corridor/WestEnd", "Corridor/EastEnd"]:
		var cap := floor4.get_node_or_null(path) as StaticBody3D
		if cap:
			_restores.append({"node": weakref(cap), "property": &"collision_layer", "value": cap.collision_layer})
			_restores.append({"node": weakref(cap), "property": &"visible", "value": cap.visible})
			cap.collision_layer = 0
			cap.hide()
	var environment := floor4.get_node_or_null("Environment") as WorldEnvironment
	if environment:
		_restores.append({"node": weakref(environment), "property": &"environment", "value": environment.environment})
		environment.environment = null
	for decor in floor4.get_node("Corridor").get_children():
		if decor is Node3D and (String(decor.name).begins_with("YardTree_") or decor.name == &"DistantStreetLamp"):
			_restores.append({"node": weakref(decor), "property": &"visible", "value": decor.visible})
			decor.hide()


func _exit_tree() -> void:
	for entry in _restores:
		var node: Object = entry.node.get_ref()
		if is_instance_valid(node):
			node.set(entry.property, entry.value)


func set_fire_door_open(open: bool) -> void:
	fire_door_open = open
	if not has_node("BuildingB/FireDoor"):
		return
	$BuildingB/FireDoor.set_open(open)
	$Navigation/FireDoorLink.enabled = open


func set_main_door_chained(value: bool) -> void:
	main_door_chained = value
	if not has_node("BuildingB/MainDoor"):
		return
	$BuildingB/MainDoor/Chains.visible = value
	$BuildingB/MainDoor.set_open(not value)
	$Navigation/MainDoorLink.enabled = not value


func set_canteen_tv(on: bool) -> void:
	if has_node("Canteen/TV/Screen"):
		$Canteen/TV/Screen.visible = on


func set_stadium_lights(on: bool) -> void:
	if has_node("Stadium/Floodlights"):
		$Stadium/Floodlights.visible = on


func get_anchor(name: String) -> Node3D:
	return get_node_or_null(NodePath("Anchors/" + name.trim_prefix("Anchors/"))) as Node3D
