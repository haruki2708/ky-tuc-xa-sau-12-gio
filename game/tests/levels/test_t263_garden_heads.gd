extends TestCase
## T-263 round 1, step 0: the six garden corpses get their heads back. T-259 had hidden props.tscn
## Parts/P_paper_box_p0_p0 whole and laid paper cards where those heads were; the chunk is shown again with only the
## pieces T-259 replaced (a rice tray, the notice board's six sheets) scaled to 0, and no litter card covers a head.

const PROPS := preload("res://scenes/levels/campus/props.tscn")
const STRIP_PROPS := "res://assets/models/graphics_pilot/realistic_map/wave3/strip_props.glb"
const CHUNK := "Parts/P_paper_box_p0_p0"
## Main's matrices of the six heads (instances #1-3 and #10-12 of the chunk): origin x, z.
const HEADS := [Vector2(11.2119, 16.8944), Vector2(29.1026, 27.6073), Vector2(14.2825, 36.9593), Vector2(0.147, 7.5621),
	Vector2(16.5682, 18.8205), Vector2(31.0673, 30.4178)]
const SKIN := Color(0.9, 0.7, 0.6)


func test_chunk_shown_with_six_heads_and_the_replaced_pieces_scaled_to_zero() -> void:
	var props := PROPS.instantiate()
	var chunk := props.get_node(CHUNK) as Node3D
	assert_true(chunk.visible, CHUNK + " shown again")
	var data: PackedFloat32Array = chunk.get("data")
	assert_eq(data.size(), 13 * 16, "13 instances, entries kept")
	var heads: Array[Vector2] = []
	var zeroed := 0
	for k in range(0, data.size(), 16):
		var basis_zero := data[k] == 0.0 and data[k + 4] == 0.0 and data[k + 8] == 0.0
		if Color(data[k + 12], data[k + 13], data[k + 14]).to_html(false) == SKIN.to_html(false):
			var scale := Vector3(data[k], data[k + 1], data[k + 2]).length()
			assert_true(absf(scale - 0.22) < 0.001, "head #%d at full size (%f)" % [k / 16, scale])
			assert_true(absf(data[k + 10] + 9.78) < 0.001, "head #%d on the paving" % [k / 16])
			heads.append(Vector2(data[k + 9], data[k + 11]))
		else:
			assert_true(basis_zero, "replaced piece #%d scaled to 0" % [k / 16])
			zeroed += 1
	assert_eq(zeroed, 7, "the tray and the six notice-board sheets")
	assert_eq(heads.size(), 6, "six heads")
	for head: Vector2 in HEADS:
		var found := false
		for at: Vector2 in heads:
			found = found or at.distance_to(head) < 0.001
		assert_true(found, "head at %s back where main had it" % head)
	props.free()


func test_no_litter_card_lies_over_a_head() -> void:
	var root := (load(STRIP_PROPS) as PackedScene).instantiate() as Node3D
	var litter := root.find_child("Litter", true, false) as MeshInstance3D
	assert_not_null(litter, "strip_props.glb has its litter mesh")
	var to_root := litter.transform  # the glb root sits at x 0, z 0 (campus.tscn StripBGarden/Props)
	var up := litter.get_parent() as Node3D
	while up != null and up != root:
		to_root = up.transform * to_root
		up = up.get_parent() as Node3D
	var mesh := litter.mesh
	var triangles := 0
	var covering: PackedStringArray = []
	for surface in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		for t in range(0, index.size(), 3):
			var a := to_root * verts[index[t]]
			var b := to_root * verts[index[t + 1]]
			var c := to_root * verts[index[t + 2]]
			triangles += 1
			for head: Vector2 in HEADS:
				if Geometry2D.point_is_inside_triangle(head, Vector2(a.x, a.z), Vector2(b.x, b.z), Vector2(c.x, c.z)):
					covering.append("%s" % head)
	assert_true(triangles >= 2 * 54, "54 litter cards (%d triangles)" % triangles)
	assert_true(covering.is_empty(), "no litter card over a head: %s" % ", ".join(covering))
	root.free()
