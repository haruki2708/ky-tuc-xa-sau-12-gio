extends RefCounted
## Offline profile audit: read PackedScene states without instantiating scripts,
## entering the scene tree, playing a chapter or sending input.
## DEFERRED means a reviewed runtime producer still needs runtime verification.

const PATH_KEYS := ["path", "anchor", "director", "death_ui", "death_ui_path", "bar_head_path"]
const PATH_ARRAYS := ["guard_paths", "spawn_paths"]


static func scene_paths(scene: PackedScene) -> Dictionary:
	var paths: Dictionary = {}
	_collect_state(scene.get_state(), "", paths)
	return paths


static func _collect_state(state: SceneState, prefix: String, paths: Dictionary) -> void:
	var base := state.get_base_scene_state()
	if base != null:
		_collect_state(base, prefix, paths)
	for index in state.get_node_count():
		var relative := str(state.get_node_path(index)).trim_prefix("./")
		var path := prefix if relative == "." else prefix.path_join(relative) if not prefix.is_empty() else relative
		paths[path] = true
		var nested := state.get_node_instance(index)
		if nested != null:
			_collect_state(nested.get_state(), path, paths)


static func references(value: Variant, location: String = "$", key: String = "") -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	if value is Dictionary:
		for child: String in value:
			found.append_array(references(value[child], location + "." + child, child))
	elif value is Array:
		for index in value.size():
			found.append_array(references(value[index], "%s[%d]" % [location, index], key))
	elif value is String and (key in PATH_KEYS or key in PATH_ARRAYS):
		found.append({"location": location, "path": value, "scope": "zombie" if key == "bar_head_path" else "chapter"})
	return found


static func runtime_contracts(chapter: int) -> Dictionary:
	var contracts: Dictionary = {}
	var room := "Floor4/Room407/"
	if chapter == 2:
		for pair: Array in [["RagSpot", "rag"], ["TowelSpot", "towel"], ["ShirtSpot", "shirt"]]:
			var parent := room + "Anchors/" + str(pair[0])
			contracts[parent + "/Carry_" + str(pair[1])] = [parent, "Chapter2Director"]
		for bed in [1, 2, 4]:
			var parent := room + "Anchors/Gag%d" % bed
			contracts[parent + "/GagSpot"] = [parent, "Chapter2Director"]
		for pair: Array in [["Extension/BathroomDoor", "StuckDoor"], ["Anchors/ShowerStall", "ShowerStallArea"], ["Anchors/ShowerScreen", "Wipe"]]:
			var parent := room + str(pair[0])
			contracts[parent + "/" + str(pair[1])] = [parent, "Chapter2Director"]
	if chapter == 3:
		for name: String in ["FireKey", "FireDoor", "Extinguisher2F"]:
			var parent := "Campus/Anchors/" + name
			contracts[parent + "/Use_" + name] = [parent, "Chapter3Director"]
		for number in range(1, 13):
			contracts["Chapter3Director/Guard%02d" % number] = ["Chapter3Director", "Campus/Anchors/GuardLine/G%02d" % number]
		contracts["Chapter3Director/Horde"] = ["Chapter3Director", "Campus/Anchors/ZombieSpawns"]
	return contracts


static func audit(profile: Dictionary, paths: Dictionary, zombie_paths: Dictionary = {}) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var contracts := runtime_contracts(int(profile.get("chapter", 0)))
	for reference: Dictionary in references(profile):
		var row: Dictionary = reference.duplicate()
		var available: Dictionary = zombie_paths if row.scope == "zombie" else paths
		row["status"] = "OK" if available.has(row.path) else "MISSING"
		if row.status == "MISSING" and row.scope == "chapter" and contracts.has(row.path):
			var parents_present := true
			for parent: String in contracts[row.path]:
				parents_present = parents_present and paths.has(parent)
			if parents_present:
				row.status = "DEFERRED"
		rows.append(row)
	return rows
