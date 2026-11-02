extends TestCase
## These tests never instantiate or start bot/chapter scenes.

const AUDIT := preload("res://scripts/debug/profile_static_audit.gd")


func test_scene_inventory_uses_root_relative_paths() -> void:
	var inner := Node3D.new()
	inner.name = "Inner"
	var marker := Marker3D.new()
	marker.name = "Anchor"
	inner.add_child(marker)
	marker.owner = inner
	var packed := PackedScene.new()
	assert_eq(packed.pack(inner), OK)
	inner.free()
	var outer := Node3D.new()
	outer.name = "Outer"
	var child := packed.instantiate()
	child.name = "Nested"
	outer.add_child(child)
	child.owner = outer
	child.get_node("Anchor").owner = outer
	var scene := PackedScene.new()
	assert_eq(scene.pack(outer), OK)
	outer.free()
	var paths := AUDIT.scene_paths(scene)
	assert_true(paths.has("Nested/Anchor"), "owned descendants must be inventoried")
	assert_false(paths.has("Outer/Nested/Anchor"), "paths are relative to scene root")


func test_recursive_references_runtime_and_missing_are_distinct() -> void:
	var profile := {"chapter": 2, "scene": "res://unused.tscn", "actions": {
		"wipe": {"steps": [{"path": "Floor4/Room407/Anchors/ShowerScreen/Wipe"}]},
		"bad": {"path": "Floor4/Room407/Anchors/Typo/Wipe"}},
		"routes": [{"loop": [{"anchor": "Anchor"}], "wait_for": {"path": "Player"}}],
		"bindings": {"bar_head_path": "HeadHitbox", "guard_paths": ["MissingGuard"]}}
	var paths := {"Floor4/Room407/Anchors/ShowerScreen": true, "Chapter2Director": true, "Anchor": true, "Player": true}
	var rows := AUDIT.audit(profile, paths, {"HeadHitbox": true})
	assert_eq(rows.size(), 6, "resources excluded; nested loops, waits and arrays included")
	assert_eq(rows[0].status, "DEFERRED", "runtime creation is not static success")
	assert_eq(rows[1].status, "MISSING", "unknown dynamic-looking paths must fail")
	assert_eq(rows[2].status, "OK")
	assert_eq(rows[3].status, "OK")
	assert_eq(rows[4].status, "OK", "head is relative to zombie, not chapter")
	assert_eq(rows[5].status, "MISSING")
	paths.erase("Floor4/Room407/Anchors/ShowerScreen")
	assert_eq(AUDIT.audit(profile, paths)[0].status, "MISSING", "runtime contract requires actual parent")


func test_shipped_profiles_inventory_without_playing() -> void:
	for chapter in [2, 3]:
		var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/ch%d-profile.json" % chapter))
		var packed := load(str(profile.scene)) as PackedScene
		assert_not_null(packed)
		var paths := AUDIT.scene_paths(packed)
		var zombie_paths: Dictionary = {}
		if profile.has("zombie_scene"):
			zombie_paths = AUDIT.scene_paths(load(str(profile.zombie_scene)) as PackedScene)
		var rows := AUDIT.audit(profile, paths, zombie_paths)
		assert_false(rows.is_empty())
		var counts := {"OK": 0, "DEFERRED": 0, "MISSING": 0}
		for row: Dictionary in rows:
			counts[row.status] += 1
			print("STATIC_PATH: ch%d %s %s %s" % [chapter, row.status, row.location, row.path])
			assert_false(row.status == "MISSING", row.location + ": " + row.path)
		print("STATIC_AUDIT: ch%d %s (runtime creation, methods, visibility and collisions not executed)" % [chapter, counts])
