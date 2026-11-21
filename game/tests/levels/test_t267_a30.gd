extends TestCase
## T-267 (card section 1 point 8, D-188) A30: room 407's small things. Only their meshes and materials change, in the
## scenes the integrator listed; every other node (script, area, shape, hand target, marker, label, exported value,
## transform) is main's: a print of each scene's nodes, meshes reduced to path, class and transform, matches main's.
## floor4.tscn changes one value, Door407/Pivot/RulesPaper's position (onto the Tripo leaf's face): its print without that
## node's row is main's, and that row differs from main's in the position alone. Each thing's bounds stay within a few
## centimetres of main's (the hands of T-239/T-241/T-243 reach for them); nothing new hides behind REPLACED_PS1; in
## room 407 furnished (floor4.tscn, as every chapter has it) the new meshes draw; the rules paper lies on the leaf.

## Scene -> [md5 of its rows on main 53d4d0e (main's files, in this test runner), {subtree: main's mesh bounds}].
const SCENES := {
	"res://scenes/levels/ch1_models/dat_notebook.tscn": ["e525e85ab3e984670d11152c3080892f",
		{"": AABB(Vector3(-0.106, 0.0, -0.14), Vector3(0.206, 0.0285, 0.28))}],
	"res://scenes/levels/ch1v2/guitar_songbook.tscn": ["731849f4eb178fe5abec8a701312b904",
		{"": AABB(Vector3(-0.106, 0.0, -0.14), Vector3(0.206, 0.0285, 0.28))}],
	"res://scenes/levels/room407/khoa_outlet.tscn": ["889cbd19809c9c09f5fa5275f9bb60b2",
		{"": AABB(Vector3(0.1, -0.097, -0.087), Vector3(0.0305, 0.194, 0.174))}],
	"res://scenes/levels/ch1v2/trash_bin.tscn": ["1d9403a28d349ca19e2f312b8622ce7b",
		{"Waste0": AABB(Vector3(-0.075, 0.0675, -0.05), Vector3(0.07, 0.025, 0.1)),
		"Waste1": AABB(Vector3(-0.035, 0.0675, -0.05), Vector3(0.07, 0.025, 0.1)),
		"Waste2": AABB(Vector3(0.005, 0.0675, -0.05), Vector3(0.07, 0.025, 0.1))}],
	"res://scenes/levels/room407/room407_anchors.tscn": ["a6b4351d195333745f81f8069edc762d",
		{"ShowerYes": AABB(Vector3(5.3895, 1.175, -5.945), Vector3(0.035, 0.05, 0.11)),
		"ShowerNo": AABB(Vector3(5.3895, 1.175, -6.165), Vector3(0.035, 0.05, 0.11))}],
}
const FLOOR4 := "res://scenes/levels/floor4/floor4.tscn"
const RULES_PAPER := "Door407/Pivot/RulesPaper"
## floor4.tscn on main 53d4d0e: the md5 of its rows without RulesPaper's, and RulesPaper's own row.
const FLOOR4_WITHOUT_RULES := "415f5fe3979f9e177f7968130988d018"
const RULES_ROW_MAIN := "Door407/Pivot/RulesPaper|Node3D|(-0.44, 1.39, -0.025)(0.0, 0.0, 0.0)(1.0, 1.0, 1.0)|process_mode=0|process_priority=0|process_physics_priority=0|process_thread_group=0|physics_interpolation_mode=0|auto_translate_mode=0|editor_description=|rotation_edit_mode=0|rotation_order=2|top_level=false|visible=true|visibility_parent=|script=<null>"
const RULES_AT := Vector3(-0.44, 1.39, -0.063)
## "A few centimetres" (card): each side of a thing's bounds.
const SLACK := 0.03
const A30_MESHES := "res://assets/models/graphics_pilot/realistic_map/wave10/a30/"
## Meshes now on the new models, under Floor4/Room407/Anchors (DatNote, the songbook's book and chord box, the outlet,
## the bin's paper, the two buttons).
const NEW_MESH_NODES := 42
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		if is_instance_valid(node):
			node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func test_only_meshes_and_materials_change() -> void:
	for path: String in SCENES:
		var root := (load(path) as PackedScene).instantiate() as Node3D
		var rows := scene_rows(root)
		print("T267_A30_PRINT %s %s %d" % [path.get_file(), "\n".join(rows).md5_text(), rows.size()])
		assert_eq("\n".join(rows).md5_text(), SCENES[path][0], path.get_file() + ": every node but the meshes as main has it")
		var bounds: Dictionary = SCENES[path][1]
		for sub: String in bounds:
			var now := mesh_bounds(root, sub)
			var was: AABB = bounds[sub]
			var drift := maxf((now.position - was.position).abs()[(now.position - was.position).abs().max_axis_index()],
				(now.end - was.end).abs()[(now.end - was.end).abs().max_axis_index()])
			print("T267_A30_BOUNDS %s %s %s (main %s) drift %.4f" % [path.get_file(), sub, now, was, drift])
			assert_true(drift <= SLACK, "%s %s: bounds within a few cm of main's (%.3f m)" % [path.get_file(), sub, drift])
		root.free()
	var floor4 := (load(FLOOR4) as PackedScene).instantiate() as Node3D
	var kept := PackedStringArray()
	var rules := ""
	for row in scene_rows(floor4):
		if row.begins_with(RULES_PAPER + "|"):
			rules = row
		else:
			kept.append(row)
	floor4.free()
	print("T267_A30_FLOOR4 %s %d" % ["\n".join(kept).md5_text(), kept.size()])
	assert_eq("\n".join(kept).md5_text(), FLOOR4_WITHOUT_RULES, "floor4.tscn: every row but RulesPaper's as main has it")
	assert_eq(rules, RULES_ROW_MAIN.replace("(-0.44, 1.39, -0.025)", str(RULES_AT)), "RulesPaper: only its position differs")


func test_new_meshes_draw_in_room_407_and_the_paper_lies_on_the_leaf() -> void:
	var floor4 := (load(FLOOR4) as PackedScene).instantiate() as Node3D
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	await wait_frames(3)
	var room := floor4.get_node("Room407") as Node3D
	var replaced: Array = room.get_script().get_script_constant_map()["REPLACED_PS1"]
	var count := 0
	for node: Node in room.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh.mesh == null or not mesh.mesh.resource_path.begins_with(A30_MESHES):
			continue
		count += 1
		var path := String(room.get_path_to(mesh))
		assert_true(mesh.is_visible_in_tree(), path + " draws in the furnished room")
		for pattern: String in replaced:
			assert_false(path.match(pattern) or path.match(pattern + "/*"), "%s is not under REPLACED_PS1 %s" % [path, pattern])
		assert_not_null(mesh.get_surface_override_material(0), path + " has its material")
	assert_eq(count, NEW_MESH_NODES, "every new mesh node found in room 407")
	# The paper's back (its box is 8 mm thick) just off the Tripo leaf's corridor face, under all of the paper.
	var paper := floor4.get_node(RULES_PAPER) as Node3D
	var leaf := floor4.get_node("Door407/Pivot/RoomDoor") as MeshInstance3D
	var to_pivot := paper.get_parent_node_3d().global_transform.affine_inverse() * leaf.global_transform
	var faces := leaf.mesh.get_faces()
	var highest := -INF
	for gx in range(-7, 8):
		for gy in range(-10, 11):
			var at := paper.position + Vector3(gx * 0.02, gy * 0.02, 0.0)
			for i in range(0, faces.size(), 3):
				var hit: Variant = Geometry3D.segment_intersects_triangle(at + Vector3(0, 0, 0.3), at - Vector3(0, 0, 0.3),
					to_pivot * faces[i], to_pivot * faces[i + 1], to_pivot * faces[i + 2])
				if hit != null:
					highest = maxf(highest, (hit as Vector3).z)
	var back := paper.position.z - 0.004
	print("T267_RULES_PAPER back %.4f, leaf's corridor face up to %.4f" % [back, highest])
	assert_true(back > highest and back - highest < 0.005, "the paper lies on the leaf (%.4f over %.4f)" % [back, highest])



## One row per node: path, class, transform; for every node that is not a MeshInstance3D also each stored property
## (built-in resources by their own stored properties). Rows sorted; nodes inside instanced scenes count too.
static func scene_rows(root: Node) -> PackedStringArray:
	# Objects inside dictionaries print as <Class#id>, and ids change from run to run (the corpses' animation libraries).
	var object_id := RegEx.create_from_string("#-?[0-9]+>")
	var rows := PackedStringArray()
	for node: Node in [root] + root.find_children("*", "", true, false):
		var row := "%s|%s" % [root.get_path_to(node), node.get_class()]
		if node is Node3D:
			row += "|" + str((node as Node3D).transform.origin.snapped(Vector3.ONE * 0.0001)) + str((node as Node3D).transform.basis.get_euler().snapped(Vector3.ONE * 0.0001)) + str((node as Node3D).scale.snapped(Vector3.ONE * 0.0001))
		if node is MeshInstance3D:
			rows.append(row + "|mesh")
			continue
		for property: Dictionary in node.get_property_list():
			if int(property.usage) & PROPERTY_USAGE_STORAGE == 0 or String(property.name) in ["transform", "position", "rotation", "scale", "quaternion", "basis", "rotation_degrees", "unique_name_in_owner"]:
				continue
			row += "|%s=%s" % [property.name, _value(node.get(property.name))]
		rows.append(object_id.sub(row, ">", true))
	rows.sort()
	return rows


static func _value(value: Variant) -> String:
	if value is Resource:
		var resource := value as Resource
		if not resource.resource_path.is_empty() and not resource.resource_path.contains("::"):
			return resource.resource_path
		var parts := PackedStringArray([resource.get_class()])
		for property: Dictionary in resource.get_property_list():
			if int(property.usage) & PROPERTY_USAGE_STORAGE == 0 or String(property.name) in ["resource_local_to_scene", "resource_name", "resource_path"]:
				continue
			var inner: Variant = resource.get(property.name)
			parts.append("%s:%s" % [property.name, inner.get_class() if inner is Object and inner != null else str(inner)])
		return "{%s}" % ",".join(parts)
	if value is float:
		return "%.5f" % value
	return str(value)


## The merged bounds of the visible meshes under root/sub (all of root when sub is empty), in root's space.
static func mesh_bounds(root: Node3D, sub := "") -> AABB:
	var box := AABB()
	var first := true
	var top := root.get_node(sub) if not sub.is_empty() else root
	for node: Node in [top] + top.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh == null or mesh.mesh == null or not mesh.visible:
			continue
		var xform := Transform3D()
		var walk: Node = mesh
		var shown := true
		while walk != root:
			xform = (walk as Node3D).transform * xform
			walk = walk.get_parent()
			shown = shown and (walk == root or (walk as Node3D).visible)
		if not shown:
			continue
		var world := xform * mesh.get_aabb()
		box = world if first else box.merge(world)
		first = false
	return box
