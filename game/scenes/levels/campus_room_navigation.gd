extends Node3D
## Detach redundant standalone Floor4 navigation while Campus owns the hall.
## Disabled regions can still attract link endpoints on overlapping geometry.

var _detached: Array[Dictionary] = []
var _parking_map: RID


func _ready() -> void:
	_parking_map = NavigationServer3D.map_create()
	call_deferred("_detach_standalone")


func _process(_delta: float) -> void:
	if _detached.is_empty():
		_detach_standalone()


func _detach_standalone() -> void:
	var campus := get_parent()
	var floor4 := campus.get_node_or_null(campus.floor4_path)
	if floor4 == null:
		return
	if not _detached.is_empty():
		return
	for path in ["Corridor/Navigation", "Corridor/Room407Link"]:
		var navigation := floor4.get_node_or_null(path)
		if navigation == null:
			continue
		_detached.append({"node": weakref(navigation), "map": navigation.get_navigation_map()})
		navigation.set_navigation_map(_parking_map)
	set_process(false)


func _exit_tree() -> void:
	for entry in _detached:
		var navigation: Object = entry.node.get_ref()
		if is_instance_valid(navigation):
			navigation.set_navigation_map(entry.map)
	if _parking_map.is_valid():
		NavigationServer3D.free_rid(_parking_map)
