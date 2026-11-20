extends TestCase
## T-266 round 2 (D-187 points 7-12): the ending's ward. Contract nodes kept, the PS1 boxes only hidden, both endings,
## the K2 frame (Camera_Wake looks up 11 degrees), nothing between Trung's eye and the cards, and lane D's card readable
## from that eye on both faces in lit paper (the UI exception of point 11).

const WARD := "res://scenes/levels/hospital/hospital_room.tscn"
const CARD := "res://ui/ch4/bed_card.tscn"
const ASPECT := 16.0 / 9.0
var ward: Node3D


func before_each() -> void:
	ward = load(WARD).instantiate()
	tree.root.add_child(ward)
	await wait_frames(2)


func after_each() -> void:
	ward.queue_free()
	await wait_frames(2)


func test_contract_nodes_and_ps1_only_hidden() -> void:
	for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
		assert_true(ward.get_node(bed) is Node3D, bed)
		assert_true(ward.get_node(bed + "/Card") is Marker3D, bed + "/Card")
		assert_true((ward.get_node(bed + "/Card") as Node3D).position.is_equal_approx(Vector3(0, 0.88, 1.08)), bed + "/Card unmoved")
		assert_true(ward.get_node(bed + "/Patient") is Node3D, bed + "/Patient")
		assert_not_null(ward.get_node_or_null(bed + "/Real"), bed + " has its stainless bed")
	assert_true((ward.get_node("Bed_Nhat") as Node3D).position.is_equal_approx(Vector3(-1.65, 0, 0)))
	assert_true((ward.get_node("Bed_Ngu") as Node3D).position.is_equal_approx(Vector3(1.65, 0, 0)))
	for key in ["Nurse1", "Nurse2", "MonitorAudio"]:
		assert_true(ward.get_node(key) is Marker3D, key)
	assert_true((ward.get_node("Nurse1") as Node3D).position.is_equal_approx(Vector3(-0.72, 0, 1.9)), "Nurse1 behind the curtain, unmoved")
	assert_true((ward.get_node("Nurse2") as Node3D).position.is_equal_approx(Vector3(0.72, 0, 1.9)), "Nurse2 behind the curtain, unmoved")
	var camera := ward.get_node("Camera_Wake") as Camera3D
	assert_true(camera.position.is_equal_approx(Vector3(0, 0.94, -0.64)), "the eye where it was")
	assert_true(camera.rotation_degrees.is_equal_approx(Vector3(11, 180, 0)), "K2: looking up 11 degrees (%s)" % camera.rotation_degrees)
	assert_eq(camera.fov, 78.0, "FOV kept")
	assert_true(ward.get_node("Environment") is WorldEnvironment)
	assert_true(ward.get_node("CeilingLight") is OmniLight3D and ward.get_node("CeilingLight/LightHum") != null)
	assert_true(ward.get_node("West/Mesh") is MeshInstance3D)
	assert_true(ward.has_method("set_companions_visible"))
	var ps1 := 0
	for mesh: MeshInstance3D in ward.find_children("*", "MeshInstance3D", true, false):
		if _is_new(mesh):
			continue
		ps1 += 1
		assert_false(mesh.visible, "PS1 hidden, node kept: " + String(ward.get_path_to(mesh)))
	assert_true(ps1 >= 60, "the PS1 meshes are all still there (%d)" % ps1)
	assert_eq(ward.find_children("*", "Light3D", true, false).size(), 1, "no light added (D-167)")
	var curtain := ward.get_node("Real/Curtain") as Node3D
	assert_not_null(curtain.find_child("Shadow", true, false), "Y1: the two shadows on the curtain")


func test_endings_occupied_or_flat_sheets() -> void:
	ward.set_companions_visible(true)
	for bed in ["Bed_Nhat", "Bed_Ngu"]:
		assert_true((ward.get_node(bed + "/Patient/Real") as Node3D).is_visible_in_tree(), bed + ": a body under the blanket")
		assert_false((ward.get_node(bed + "/Empty") as Node3D).is_visible_in_tree(), bed + ": no folded blanket")
	ward.set_companions_visible(false)
	for bed in ["Bed_Nhat", "Bed_Ngu"]:
		assert_false((ward.get_node(bed + "/Patient") as Node3D).visible, bed + "/Patient hidden (lonely ending)")
		assert_true((ward.get_node(bed + "/Empty") as Node3D).is_visible_in_tree(), bed + ": flat sheet, blanket folded")
	assert_true((ward.get_node("Bed_Trung/Patient/Real") as Node3D).is_visible_in_tree(), "Trung in his bed either way")


## The K2 frame (16:9, the vertical FOV 78) holds the three cards, and no mesh of the room lies between the eye and them.
func test_cards_in_frame_and_unblocked_in_both_endings() -> void:
	var camera := ward.get_node("Camera_Wake") as Camera3D
	for ending: StringName in [&"all", &"alone"]:
		GameState.set_flag(&"ch4_ending", String(ending))
		var cards := _hang_cards()
		ward.set_companions_visible(ending == &"all")
		await wait_frames(1)
		for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
			var card := cards[bed] as Node3D
			if not card.visible:
				assert_true(bed != "Bed_Trung" and ending == &"alone", "only the two companions' cards hide, alone")
				continue
			var point := card.global_position
			var ndc := _ndc(camera, point)
			assert_true(absf(ndc.x) < 0.95 and absf(ndc.y) < 0.95, "%s's card in the K2 frame (%s, %s)" % [bed, ndc, ending])
			for corner: Vector3 in [Vector3(-0.2, 0.07, 0), Vector3(0.2, 0.07, 0), Vector3(0, -0.06, 0)]:
				var target := card.global_transform * corner
				var hit := _blocker(camera.global_position, target, card)
				assert_true(hit.is_empty(), "nothing between the eye and %s's card (%s): %s" % [bed, ending, hit])
		for card: Node in cards.values():
			card.queue_free()
		await wait_frames(1)
	GameState.set_flag(&"ch4_ending", "alone")


## D-187 point 11: in the true ending Nhat's and Ngu's names read from Trung's eye: the face toward the eye carries the
## same text, unmirrored; the paper takes the room's light (not unshaded) and is not paper white.
func test_cards_read_from_the_bed_head_in_lit_paper() -> void:
	GameState.set_flag(&"ch4_ending", "all")
	var cards := _hang_cards()
	await wait_frames(1)
	var eye := (ward.get_node("Camera_Wake") as Camera3D).global_position
	for bed in ["Bed_Nhat", "Bed_Ngu", "Bed_Trung"]:
		var card := cards[bed] as Node3D
		assert_true(card.visible, bed + "'s card shown (all)")
		var front := card.get_node("Name") as Label3D
		var back := card.get_node("NameBack") as Label3D
		assert_eq(back.text, front.text, bed + ": the back says what the front says")
		assert_eq((card.get_node("DetailsBack") as Label3D).text, (card.get_node("Details") as Label3D).text)
		assert_false(back.double_sided or front.double_sided, "each face draws only its own text (no mirror image)")
		var facing := back.global_transform.basis.z
		assert_true(facing.dot(eye - back.global_position) > 0.0, bed + ": the lettered face looks at Trung's eye")
		var paper := (card.get_node("Paper") as MeshInstance3D).mesh.surface_get_material(0) as BaseMaterial3D
		assert_true(paper.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED, "the paper takes the ward's light")
		assert_true(paper.albedo_color.get_luminance() < 0.8, "and is a shade darker than white (%.2f)" % paper.albedo_color.get_luminance())
	assert_eq((cards["Bed_Nhat"].get_node("NameBack") as Label3D).text, tr("UI_CH4_PATIENT_NHAT"))
	assert_eq((cards["Bed_Ngu"].get_node("NameBack") as Label3D).text, tr("UI_CH4_PATIENT_NGU"))
	GameState.set_flag(&"ch4_ending", "alone")


func test_triangle_budgets_card_section_5() -> void:
	var total := _triangles(ward)
	for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
		var tris := _triangles(ward.get_node(bed))
		print("T266_TRIANGLES %s %d" % [bed, tris])
		assert_true(tris < 4000, "%s under 4,000 triangles (%d)" % [bed, tris])
	print("T266_TRIANGLES ward %d" % total)
	assert_true(total < 80000, "the ward under 80,000 triangles (%d)" % total)


func _hang_cards() -> Dictionary:
	var cards := {}
	for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
		var card := (load(CARD) as PackedScene).instantiate() as Node3D
		ward.get_node(bed + "/Card").add_child(card)
		cards[bed] = card
	return cards


func _ndc(camera: Camera3D, point: Vector3) -> Vector2:
	var local := camera.global_transform.affine_inverse() * point
	var half_y := tan(deg_to_rad(camera.fov / 2.0))
	return Vector2(local.x / (-local.z * half_y * ASPECT), local.y / (-local.z * half_y))


## The first visible mesh of the ward (not the card itself) whose triangles cross the segment (stopping 1 cm short).
func _blocker(from: Vector3, to: Vector3, card: Node3D) -> String:
	var end := from + (to - from) * (1.0 - 0.01 / from.distance_to(to))
	for mesh: MeshInstance3D in ward.find_children("*", "MeshInstance3D", true, false):
		if not mesh.is_visible_in_tree() or card.is_ancestor_of(mesh):
			continue
		var box := mesh.global_transform * mesh.get_aabb()
		if not box.grow(0.01).intersects_segment(from, end):
			continue
		var faces := mesh.mesh.get_faces()
		for index in range(0, faces.size(), 3):
			var a := mesh.global_transform * faces[index]
			var b := mesh.global_transform * faces[index + 1]
			var c := mesh.global_transform * faces[index + 2]
			if Geometry3D.segment_intersects_triangle(from, end, a, b, c) != null:
				return String(ward.get_path_to(mesh))
	return ""


func _is_new(node: Node) -> bool:
	while node != ward:
		if node.name in [&"Real", &"Empty"]:
			return true
		node = node.get_parent()
	return false


func _triangles(node: Node) -> int:
	var result := 0
	if node is MeshInstance3D and node.mesh != null:
		result += node.mesh.get_faces().size() / 3
	for child in node.get_children():
		result += _triangles(child)
	return result
