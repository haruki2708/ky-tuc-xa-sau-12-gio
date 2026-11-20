extends TestCase
## T-266 round 2 (replaces round 1's test_t266_pilot): every wave-9 texture imports VRAM compressed (card section 5),
## every glb uses only the shared realistic-map materials, and the pieces hung in the scenes fit card section 5's ceilings.

const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave9/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave9/"
const SHIPPED := ["slat_bed1", "slat_bed2", "slat_bed4", "vent", "hatch", "door_cracks", "door_broken", "zombie_hand", "ward_shell",
	"footwall", "curtain_y1", "ward_bed", "iv", "patient_t1", "patient_side", "bed_empty"]


func test_every_wave9_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
	assert_true(count >= 11, "wave 9 textures found (%d)" % count)


func test_glbs_use_only_shared_materials() -> void:
	var found := PackedStringArray()
	for file in DirAccess.get_files_at(MODELS):
		if not file.ends_with(".glb"):
			continue
		found.append(file.get_basename())
		var root := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_true(material != null and material.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material" % [file, mesh.name, surface])
		root.free()
	for glb: String in SHIPPED:
		assert_true(glb in found, glb + ".glb shipped")
	assert_eq(found.size(), SHIPPED.size(), "only the glbs the scenes use (round 1's options are rebuilt by build_wave9_pilot.py)")


func test_room407_pieces_fit_card_section_5() -> void:
	var campus: Node3D = load("res://scenes/levels/campus/campus.tscn").instantiate()
	tree.root.add_child(campus)
	var anchors := campus.get_node("Anchors/Ch4/Room407")
	var door := _triangles(anchors.get_node("Door"))
	print("T266_TRIANGLES Door %d" % door)
	assert_true(door < 4000, "the door proxy under 4,000 triangles (%d)" % door)
	for bed in [1, 2, 4]:
		var slat := _triangles(anchors.get_node("Slat%d" % bed))
		print("T266_TRIANGLES Slat%d %d" % [bed, slat])
		assert_true(slat < 1500, "Slat%d under 1,500 triangles (%d)" % [bed, slat])
	campus.free()


func _triangles(node: Node) -> int:
	var result := 0
	if node is MeshInstance3D and node.mesh != null:
		result += node.mesh.get_faces().size() / 3
	for child in node.get_children():
		result += _triangles(child)
	return result
