extends Node3D
## T-264 round 3 (D-182): the realistic rest of the campus (campus.tscn StripRest: Ground, Fences, Props) and the real
## trees and street lights. Visual only: no collider, light or sound. Set once when the scene loads (nothing per frame).
## - Its glb layers: the flat ground, paint, chain-link, small things and shrubs cast no shadow; the props' cells stop
##   drawing at 125 m from their centre as the PS1 chunks did (small things at 80 m).
## - Trees: every foliage.gd cluster of kind "tree" (campus Road/Trees_*, props Trees/ExtraTrees_*) keeps its points; its
##   PS1 cones are hidden and the cluster gets MultiMeshes of the species growing there (bàng along the Avenue, phượng
##   near the buildings, xà cừ in the long rows): the bark to 90 m, the near crown to 45 m, the mid crown 40..90 m, the
##   far crossed cards 85..125 m (the PS1 trees drew to 125 m). Leaves and cards cast no shadow.
## - Street lights: every cluster of kind "lamp" (Road/StreetLights_*) gets the steel light at each point, its arm over
##   the nearest road; the PS1 posts are hidden; the lights in Props/Lights stay as they are.
## The real MultiMeshes hang under this node (one child per cluster), not under the clusters.
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave7/"
const SPECIES := ["bang", "phuong", "xacu"]
const NO_SHADOW := ["Verge", "Paved", "Road", "Paint", "Edge", "Outside", "Chainlink"]
const BARK_END := 90.0
const NEAR_END := 45.0
const MID_BEGIN := 40.0
const FAR_BEGIN := 85.0
const FAR_END := 125.0
## The buildings' boxes (x0, x1, z0, z1) near which phượng grow: building B, A, the lecture hall, the gym, the library,
## the canteen (as wave7_layout.NEAR_BUILDINGS).
const NEAR_BUILDINGS := [[-5.2, 49.2, -10.8, 4.3], [0.0, 44.0, 54.0, 64.0], [-50.0, 30.0, 180.0, 200.0], [-60.0, 0.0, 90.0, 130.0],
	[45.0, 85.0, 195.0, 225.0], [170.0, 215.0, 20.0, 45.0]]
## Roads (x0, x1, z0, z1, along x): the lamps' arms reach over the nearest (as wave7_layout.lamp_yaw).
const ROADS := [[0.0, 180.0, -19.0, -11.0, true], [306.0, 314.0, -30.0, 166.0, false], [284.0, 312.0, 163.0, 169.0, true],
	[76.0, 84.0, -15.0, 169.0, false]]

var _meshes := {}


func _ready() -> void:
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		var name := String(mesh.name)
		if name in NO_SHADOW or name.begins_with("Small_") or name.begins_with("Shrubs_"):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if name.begins_with("Props_"):
			mesh.visibility_range_end = FAR_END
			mesh.visibility_range_end_margin = 12.0
		elif name.begins_with("Small_") or name.begins_with("Shrubs_"):
			mesh.visibility_range_end = 80.0
			mesh.visibility_range_end_margin = 8.0
	var campus := get_parent()
	var clusters: Array[Node] = []
	for path in ["Road", "Props/Trees"]:
		if campus != null and campus.has_node(path):
			clusters.append_array(campus.get_node(path).get_children())
	for cluster in clusters:
		var kind: Variant = cluster.get("kind")
		var points: Variant = cluster.get("points")
		if not points is PackedVector3Array or (points as PackedVector3Array).is_empty():
			continue
		if kind == "tree":
			_hide_ps1(cluster)
			_trees(cluster, points)
		elif kind == "lamp":
			_hide_ps1(cluster)
			_lamps(cluster, points)


static func species_at(x: float, z: float) -> int:
	if absf(z + 50.0) < 1.0 or absf(z - 280.0) < 1.0 or absf(x + 70.0) < 1.0 or absf(x - 410.0) < 1.0:
		return 2
	if x >= 60.0 and x <= 96.0 and z >= 0.0 and z <= 176.0:
		return 2
	for box: Array in NEAR_BUILDINGS:
		if x >= box[0] - 22.0 and x <= box[1] + 22.0 and z >= box[2] - 22.0 and z <= box[3] + 22.0:
			return 1
	return 0


static func lamp_yaw(x: float, z: float) -> float:
	var best := INF
	var yaw := 0.0
	for road: Array in ROADS:
		var cx := clampf(x, road[0], road[1])
		var cz := clampf(z, road[2], road[3])
		var d := Vector2(x - cx, z - cz).length()
		if d < best:
			best = d
			if road[4]:
				yaw = 0.0 if (road[2] + road[3]) / 2.0 > z else PI
			else:
				yaw = PI / 2.0 if (road[0] + road[1]) / 2.0 > x else -PI / 2.0
	return yaw


static func _hide_ps1(cluster: Node) -> void:
	for child in cluster.get_children():
		if child is MultiMeshInstance3D:
			(child as MultiMeshInstance3D).visible = false


## {mesh name: [Mesh, its transform in the glb]} of a model, loaded once.
func _parts(file: String) -> Dictionary:
	if not _meshes.has(file):
		var root := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		var parts := {}
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			parts[String(mesh.name)] = [mesh.mesh, mesh.transform]
		root.free()
		_meshes[file] = parts
	return _meshes[file]


func _multi(holder: Node3D, name: String, mesh: Mesh, local: Transform3D, xforms: Array[Transform3D], begin: float, end: float,
		shadow: bool) -> void:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = xforms.size()
	for i in xforms.size():
		multi.set_instance_transform(i, xforms[i] * local)
	var instance := MultiMeshInstance3D.new()
	instance.name = name
	instance.multimesh = multi
	# Where each one stands (tests read it: a headless renderer keeps no MultiMesh transforms).
	var origins := PackedVector3Array()
	for xform in xforms:
		origins.append(xform.origin)
	instance.set_meta("origins", origins)
	instance.visibility_range_begin = begin
	instance.visibility_range_begin_margin = 5.0 if begin > 0.0 else 0.0
	instance.visibility_range_end = end
	instance.visibility_range_end_margin = 8.0 if end < FAR_END else 12.0
	if not shadow:
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(instance)


func _holder(cluster: Node) -> Node3D:
	var holder := Node3D.new()
	holder.name = cluster.name
	add_child(holder)
	return holder


func _trees(cluster: Node, points: PackedVector3Array) -> void:
	var holder := _holder(cluster)
	var by_species := {}
	for p in points:
		var sp: int = species_at(p.x, p.z)
		if not by_species.has(sp):
			var fresh: Array[Transform3D] = []
			by_species[sp] = fresh
		# A turn and a size of its own, from where it stands (the same each run).
		var h := absf(sin(p.x * 12.9898 + p.z * 78.233) * 43758.5453)
		var yaw := fmod(h, 1.0) * TAU
		var s := 0.9 + fmod(h * 7.31, 1.0) * 0.2
		var list: Array[Transform3D] = by_species[sp]
		list.append(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * s), p))
	for sp: int in by_species:
		var parts: Dictionary = _parts("tree_%s.glb" % SPECIES[sp])
		var xforms: Array[Transform3D] = by_species[sp]
		var tag := String(SPECIES[sp]).capitalize()
		_multi(holder, tag + "Bark", parts.Bark[0], parts.Bark[1], xforms, 0.0, BARK_END, true)
		_multi(holder, tag + "Leaves", parts.Leaves[0], parts.Leaves[1], xforms, 0.0, NEAR_END, false)
		_multi(holder, tag + "LeavesMid", parts.LeavesMid[0], parts.LeavesMid[1], xforms, MID_BEGIN, BARK_END, false)
		_multi(holder, tag + "Far", parts.Far[0], parts.Far[1], xforms, FAR_BEGIN, FAR_END, false)


func _lamps(cluster: Node, points: PackedVector3Array) -> void:
	var holder := _holder(cluster)
	var xforms: Array[Transform3D] = []
	for p in points:
		xforms.append(Transform3D(Basis(Vector3.UP, lamp_yaw(p.x, p.z)), p))
	var parts: Dictionary = _parts("lamp_steel.glb")
	for part: String in parts:
		_multi(holder, part, parts[part][0], parts[part][1], xforms, 0.0, FAR_END, part != "LampGlass")
