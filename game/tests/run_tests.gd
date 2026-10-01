extends Node
## Headless test runner. Usage (from repo root): tools/test.ps1
## Exit code 0 = all passed, 1 = failures. Optional filter via user arg:
##   godot --headless --path game res://tests/run_tests.tscn -- --filter=player

const TEST_ROOT := "res://tests"


func _ready() -> void:
	# Root is still setting up children during _ready; tests need to add nodes.
	await get_tree().process_frame
	var filter := _get_filter()
	var files := _find_tests(TEST_ROOT)
	files.sort()
	var passed := 0
	var failed := 0
	for path in files:
		if filter != "" and not path.contains(filter):
			continue
		var script: GDScript = load(path)
		for method in script.get_script_method_list():
			var name: String = method["name"]
			if not name.begins_with("test_"):
				continue
			var test: TestCase = script.new()
			test.tree = get_tree()
			await test.before_each()
			await test.call(name)
			await test.after_each()
			if test.failures.is_empty():
				passed += 1
				print("  PASS %s::%s" % [path.get_file(), name])
			else:
				failed += 1
				print("  FAIL %s::%s" % [path.get_file(), name])
				for f in test.failures:
					print("       - " + f)
	print("RESULT: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _get_filter() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--filter="):
			return arg.trim_prefix("--filter=")
	return ""


func _find_tests(dir_path: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for sub in DirAccess.get_directories_at(dir_path):
		out.append_array(_find_tests(dir_path.path_join(sub)))
	for file in DirAccess.get_files_at(dir_path):
		if file.begins_with("test_") and file.ends_with(".gd"):
			out.append(dir_path.path_join(file))
	return out
