extends TestCase
## T-259 round 1: the garden pilot's assets (realistic_map/wave3, not yet hung in garden.tscn; capture_wave3.gd puts
## them into chapter 3 for the option stills). Checks what the owner's choice will build on: every new texture is VRAM
## compressed (card section 5), the three tree options keep their foliage lower than 2 m inside T-251's
## CanopyCollision (an octagonal frustum, read from garden.tscn; the inscribed circle is used so the tree may be
## turned any way), the glbs carry only the shared W1/W3 materials, and Ngư's bench sits where the PS1 seat was.

const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave3/"
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave3/"
const GARDEN := preload("res://scenes/levels/campus/garden.tscn")
const TREES := ["tree_plumeria.glb", "tree_mantaly.glb", "tree_lagerstroemia.glb"]
const GLBS := ["tree_plumeria.glb", "tree_mantaly.glb", "tree_lagerstroemia.glb", "beds_pilot.glb", "planting_a.glb",
	"planting_b.glb", "paving_block.glb", "paving_red.glb", "bench_ngu.glb", "garden_lamp.glb"]
## Card section 4: crowns may be wider than the collision from 2 m over the paving up.
const FREE_HEIGHT := 2.0
## Under the canopy block only the trunk may stand, as thin as the PS1 trunk (radius 0.1 m) plus a little flare.
const TRUNK_RADIUS := 0.13


func test_every_wave3_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
		assert_true(config.get_value("params", "mipmaps/generate"), file + " has mipmaps")
		var meta: Dictionary = config.get_value("remap", "metadata", {})
		assert_true(meta.get("vram_texture", false), file + " imported as a VRAM texture")
	assert_true(count >= 23, "wave 3 textures found (%d)" % count)


## Bottom and top rings of the canopy block, in metres above the paving: [height, inscribed radius].
func _canopy() -> Array:
	var garden := GARDEN.instantiate() as Node3D
	var crown := garden.get_node("LowCrown1_1") as Node3D
	var shape := (garden.get_node("LowCrown1_1/CanopyCollision/Shape") as CollisionShape3D).shape as ConvexPolygonShape3D
	var paving := garden.get_node("Paving") as Node3D
	var paving_top := paving.position.y + ((garden.get_node("Paving/Collision") as CollisionShape3D).shape as BoxShape3D).size.y / 2.0
	var rings := {}
	for p: Vector3 in shape.points:
		var key := snappedf(p.y, 0.001)
		if not rings.has(key):
			rings[key] = []
		rings[key].append(Vector2(p.x, p.z))
	var out := []
	for key: float in rings:
		var ring: Array = rings[key]
		ring.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.angle() < b.angle())
		var inscribed := INF
		for i in ring.size():
			var a: Vector2 = ring[i]
			var b: Vector2 = ring[(i + 1) % ring.size()]
			inscribed = minf(inscribed, Geometry2D.get_closest_point_to_segment(Vector2.ZERO, a, b).length())
		out.append([crown.position.y + key - paving_top, inscribed])
	garden.free()
	out.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	return out


func _local_transform(node: Node3D, root: Node3D) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var at := node
	while at != root:
		xf = at.transform * xf
		at = at.get_parent() as Node3D
	return xf


func test_tree_options_keep_low_foliage_inside_the_canopy_block() -> void:
	var rings := _canopy()
	assert_eq(rings.size(), 2, "canopy block has a bottom and a top ring")
	var bottom: float = rings[0][0]
	var top: float = rings[1][0]
	assert_true(absf(bottom - 1.2) < 0.01 and absf(top - 2.8) < 0.01, "canopy spans 1.2-2.8 m over the paving")
	for file: String in TREES:
		var scene := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		var meshes := scene.find_children("*", "MeshInstance3D", true, false)
		assert_eq(meshes.size(), 4, file + ": near and far bark and leaves")
		for mesh: MeshInstance3D in meshes:
			var xf := _local_transform(mesh, scene)
			var bad := 0
			var checked := 0
			for surface in mesh.mesh.get_surface_count():
				var verts: PackedVector3Array = mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
				for v in verts:
					var p := xf * v
					if p.y >= FREE_HEIGHT:
						continue
					checked += 1
					var r := Vector2(p.x, p.z).length()
					var limit := TRUNK_RADIUS
					if p.y >= bottom:
						var t := (p.y - bottom) / (top - bottom)
						limit = lerpf(float(rings[0][1]), float(rings[1][1]), t)
					if r > limit + 0.001:
						bad += 1
			assert_eq(bad, 0, "%s %s: vertices under 2 m outside the canopy block (of %d)" % [file, mesh.name, checked])
		scene.free()


func test_pilot_glbs_use_only_the_shared_materials() -> void:
	for file: String in GLBS:
		var scene := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_not_null(material, "%s %s surface %d" % [file, mesh.name, surface])
				if material != null:
					var path := material.resource_path
					assert_true(path.begins_with("res://assets/models/graphics_pilot/realistic_map/wave3/materials/W3")
						or path.begins_with("res://assets/models/graphics_pilot/realistic_map/wave1/materials/W1"),
						"%s %s uses a shared material (%s)" % [file, mesh.name, path])
		scene.free()


func test_ngu_bench_sits_on_the_ps1_seat() -> void:
	var garden := GARDEN.instantiate() as Node3D
	var seat := garden.get_node("NguBench") as Node3D
	var box := ((garden.get_node("NguBench/Collision") as CollisionShape3D).shape as BoxShape3D).size
	var seat_top := seat.position.y + box.y / 2.0
	var paving_y := -9.9
	garden.free()
	var scene := (load(MODELS + "bench_ngu.glb") as PackedScene).instantiate() as Node3D
	var mesh := scene.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var aabb := _local_transform(mesh, scene) * mesh.get_aabb()
	scene.free()
	assert_true(absf(paving_y + aabb.end.y - seat_top) < 0.005, "bench top at the PS1 seat top (Ngư's anchor)")
	assert_true(absf(aabb.position.y) < 0.005, "bench stands on the paving")
	assert_true(aabb.size.x <= box.x + 0.001 and aabb.size.z <= box.z + 0.001, "bench inside the seat's footprint")
