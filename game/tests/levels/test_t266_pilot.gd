extends TestCase
## T-266 round 1: the wave-9 pilot's assets (no scene uses them yet; capture_wave9_pilot.gd hangs them at run time). Every
## texture of the wave imports VRAM compressed (card section 5), every glb uses only the shared realistic-map materials, and
## the pieces fit card section 5's ceilings once round 2 hangs them where they go: each Slat under 1,500 triangles, the door
## proxy (its 204 PS1 triangles + cracks, broken leaf, hand) under 4,000, each Bed_* (PS1 132 + bed + patient + empty-bed
## pieces) under 8,000, the whole ward under 80,000. Round 2 replaces this test with test_t266_*.gd on the scenes.

const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave9/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave9/"
const SLATS := ["slat_v1_bed2", "slat_v2_bed2", "slat_v2b_bed2"]
const DOOR := ["door_cracks", "door_broken", "zombie_hand"]
const PS1_DOOR := 204
const PS1_BED := 132
const WARD := ["ward_shell", "footwall_door", "curtain_y1", "iv", "iv", "iv"]
const BED := ["ward_bed", "patient_side", "bed_empty", "bed_rolled"]
const TRUNG := ["ward_bed", "patient_t1"]


func _triangles(glb: String) -> int:
	var root := (load(MODELS + glb + ".glb") as PackedScene).instantiate() as Node3D
	var total := 0
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		total += mesh.mesh.get_faces().size() / 3
	root.free()
	return total


func _sum(glbs: Array) -> int:
	var total := 0
	for glb: String in glbs:
		total += _triangles(glb)
	return total


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
	assert_true(count >= 13, "wave 9 textures found (%d)" % count)


func test_glbs_use_only_shared_materials() -> void:
	var count := 0
	for file in DirAccess.get_files_at(MODELS):
		if not file.ends_with(".glb"):
			continue
		count += 1
		var root := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_true(material != null and material.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material" % [file, mesh.name, surface])
		root.free()
	assert_true(count >= 22, "wave 9 glbs found (%d)" % count)


func test_pilot_pieces_fit_card_section_5() -> void:
	for slat: String in SLATS:
		var tris := _triangles(slat) + 26
		print("T266_TRIANGLES Slat2 with %s %d" % [slat, tris])
		assert_true(tris < 1500, "%s: a Slat under 1,500 triangles (%d)" % [slat, tris])
	var door := _sum(DOOR) + PS1_DOOR
	print("T266_TRIANGLES Door %d" % door)
	assert_true(door < 4000, "the door proxy under 4,000 triangles (%d)" % door)
	var side := _sum(BED) + PS1_BED
	var trung := _sum(TRUNG) + PS1_BED
	print("T266_TRIANGLES Bed_Nhat/Bed_Ngu %d, Bed_Trung %d" % [side, trung])
	assert_true(side < 8000 and trung < 8000, "each Bed_* under 8,000 triangles (%d, %d)" % [side, trung])
	var ward := _sum(WARD) + trung + 2 * side + 828
	print("T266_TRIANGLES ward %d" % ward)
	assert_true(ward < 80000, "the ward under 80,000 triangles (%d)" % ward)
