extends Node3D
## T-256 (D-170) part B: the floor-4 corridor's loose things, real (art_source/graphics_upgrade/realistic_map/floor4_rest/
## build_corridor_props.py), node "RealProps" at the end of corridor.tscn (its siblings are ready before it).
## - The old clothesline, buckets and washing keep their nodes; their PS1 meshes hide. The old buckets keep their
##   collision boxes; the washing still sways (hanging_cloth.gd turns the old nodes, the new cloths ride on them,
##   added after their _ready so their tint leaves the new cloths alone).
## - What is new stands against the room wall between the doors or by the railing, clear of the walkway and of the
##   doors' swing (card T-256 section 3); things a bucket's size or more get a box collider inside their bounds
##   (D-135): the glb's Solid_* objects.

const PROPS := preload("res://assets/models/graphics_pilot/realistic_map/floor4_rest/corridor_props.glb")
const CLOTHS := preload("res://assets/models/graphics_pilot/realistic_map/floor4_rest/cloths.glb")
const OLD_MESHES: Array[String] = ["Clothesline/Mesh", "Bucket_11/Model", "Bucket_19/Model", "Bucket_35/Model"]
const CLOTH_NODES: Array[String] = ["HangingCloth_0", "HangingCloth_1", "HangingCloth_2", "HangingCloth_3", "HangingCloth_4"]
## build_corridor_props.py LINE: the wire's height at its hooks, where they hang, how far it sags between them.
const LINE_Y := 2.15
const LINE_DROPS: Array[float] = [16.0, 21.5, 24.1, 28.5, 32.0]
const LINE_SAG := 0.03
## A solid thing's box sits this far inside its bounds (x and z).
const INSET := 0.02

## Off only to picture the corridor as main has it (before stills): set it before the corridor enters the tree.
@export var upgraded := true
var model: Node3D


func _ready() -> void:
	if not upgraded:
		return
	var corridor := get_parent() as Node3D
	model = PROPS.instantiate() as Node3D
	model.name = "Model"
	add_child(model)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		if String(mesh.name).begins_with("Solid_"):
			_box(mesh)
	for path: String in OLD_MESHES:
		var old := corridor.get_node_or_null(path) as Node3D
		if old != null:
			old.visible = false
	var cloths := CLOTHS.instantiate() as Node3D
	for k in CLOTH_NODES.size():
		var hanger := corridor.get_node_or_null(CLOTH_NODES[k]) as Node3D
		var cloth := cloths.get_node_or_null("Cloth%d" % k) as Node3D
		if hanger == null or cloth == null:
			continue
		for child: Node in hanger.get_children():
			if child is Node3D:
				(child as Node3D).visible = false
		cloths.remove_child(cloth)
		cloth.owner = null
		cloth.name = "RealCloth"
		hanger.add_child(cloth)
		cloth.position = Vector3(0.0, line_y(hanger.position.x) - LINE_Y, 0.0)
	cloths.free()


## The wire's height at x (between its hooks it sags a little).
static func line_y(x: float) -> float:
	for k in LINE_DROPS.size() - 1:
		var a: float = LINE_DROPS[k]
		var b: float = LINE_DROPS[k + 1]
		if x >= a and x <= b:
			var t := (x - a) / (b - a)
			return LINE_Y - 4.0 * LINE_SAG * t * (1.0 - t)
	return LINE_Y


## A static box (world layer) inside a solid thing's bounds, named after it.
func _box(mesh: MeshInstance3D) -> StaticBody3D:
	var bounds: AABB = global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
	var body := StaticBody3D.new()
	body.name = "Body" + String(mesh.name).trim_prefix("Solid")
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	shape.name = "Collision"
	var box := BoxShape3D.new()
	box.size = (bounds.size - Vector3(INSET, 0.0, INSET) * 2.0).max(Vector3.ONE * 0.02)
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	body.position = bounds.get_center()
	return body
