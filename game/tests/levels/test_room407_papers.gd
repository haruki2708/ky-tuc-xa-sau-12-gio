extends TestCase
## D-106: room 407's papers and cables in the furnished room.

const FLOOR := "res://scenes/levels/floor4/floor4.tscn"
const READABLE := preload("res://scenes/interaction/readable.tscn")
const READABLE_SCRIPT := preload("res://scripts/interaction/readable.gd")
const CHAPTER := preload("res://scenes/main/chapter1_main.gd")
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _paper(document_id: StringName, look: StringName = &"") -> Node3D:
	var paper := READABLE.instantiate() as Node3D
	paper.document_id = document_id
	paper.look = look
	fixtures.append(paper)
	tree.root.add_child(paper)
	return paper


func _texture(paper: Node3D) -> Texture2D:
	return ((paper.get_node("Mesh") as MeshInstance3D).material_override as StandardMaterial3D).albedo_texture


func test_every_document_style_has_a_paper_look() -> void:
	for file in DirAccess.get_files_at(DocumentData.DIRECTORY):
		if not file.ends_with(".tres"):
			continue
		var document := load(DocumentData.DIRECTORY + file) as DocumentData
		assert_true(READABLE_SCRIPT.LOOKS.has(document.style), "%s style %s" % [file, document.style])
	var note := _paper(&"ch1_dat_note")
	assert_eq(note.paper_look(), &"handwritten", "the document's style picks the sheet")
	assert_eq(_texture(note), note.LOOKS[&"handwritten"])
	var photo := _paper(&"ch1_team_photo", &"photo")
	assert_eq(_texture(photo), photo.LOOKS[&"photo"], "look overrides the style")
	assert_eq(_paper(&"").paper_look(), &"photocopy", "no document: photocopy")
	note.document_id = &"room_paper_407"
	assert_eq(_texture(note), note.LOOKS[&"photocopy"], "changing the document changes the sheet")


func test_photos_sit_in_their_frames_and_every_paper_is_visible() -> void:
	var floor4 := (load(FLOOR) as PackedScene).instantiate() as Node3D
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	var room := floor4.get_node("Room407") as Node3D
	var holder := Node3D.new()
	fixtures.append(holder)
	tree.root.add_child(holder)
	CHAPTER.place_papers(room.get_node("Anchors") as Node3D, holder)
	var props := room.get_node("Furnished/TripoProps")
	for pair in [["Ch1TeamPhoto", "TeamPhoto"], ["Ch1VietPhoto", "FamilyPhoto"]]:
		var paper := holder.get_node(pair[0]) as Node3D
		var frame := props.get_node(pair[1]) as Node3D
		var bounds: AABB = frame.transform * Room407Furnish.local_bounds(frame)
		assert_true(bounds.grow(0.01).has_point(room.to_local(paper.global_position)), pair[0] + " inside " + pair[1])
		assert_true(String(paper.paper_look()).begins_with("photo"), pair[0] + " is a photo")
	assert_true(props.get_node_or_null("HelmetLocker") == null, "the helmet no longer covers the team photo")
	# Desk papers lie on a desk top (furnished desks are 0.76 m high), not in the air.
	for paper_name in ["Ch1DatNote", "Ch1DatCard", "Ch1VietCard"]:
		var y := room.to_local((holder.get_node(paper_name) as Node3D).global_position).y
		assert_true(y > 0.755 and y < 0.81, "%s on the desk (y %.3f)" % [paper_name, y])
	await wait_frames(2)
	var space := room.get_world_3d().direct_space_state
	for paper: Node3D in holder.get_children():
		# Nothing furnished between a reader half a metre in front of the sheet and the sheet.
		if paper.name == &"Ch1TapChart":
			continue  # lies under the songbook's chord grid, as before D-106
		var face := paper.global_position + paper.global_basis.z * 0.01
		var query := PhysicsRayQueryParameters3D.create(paper.global_position + paper.global_basis.z * 0.45, face)
		var hit := space.intersect_ray(query)
		assert_true(hit.is_empty(), "%s blocked by %s" % [paper.name, hit.get("collider")])


func test_cables_are_round_rubber_leads_with_plugs() -> void:
	var floor4 := (load(FLOOR) as PackedScene).instantiate() as Node3D
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	var cables := floor4.get_node("Room407/Cables")
	for cable_name in ["BlueCable", "GrayCable", "RouterPower", "KettlePower", "LaptopPower"]:
		var mesh := (cables.get_node(cable_name) as MeshInstance3D).mesh
		assert_true(mesh.surface_get_material(0) is StandardMaterial3D, cable_name + " rubber material")
		var arrays := mesh.surface_get_arrays(0)
		assert_true((arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() > 200, cable_name + " bends round its corners")
		assert_not_null(arrays[Mesh.ARRAY_NORMAL], cable_name + " smooth normals")
	for end_name in ["LanBlueEnd", "LanGrayEnd"]:
		var plug := floor4.get_node("Room407/Anchors/%s/Plug" % end_name)
		assert_not_null(plug.get_node_or_null("Boot"), end_name + " RJ45 boot")
	assert_true(cables.set_plugged(&"blue", true))
	assert_true((cables.get_node("BlueCable") as MeshInstance3D).mesh.get_faces().size() > 0, "replugged cable rebuilt")
