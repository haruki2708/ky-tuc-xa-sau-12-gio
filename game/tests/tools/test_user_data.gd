extends TestCase


func test_user_data_is_isolated_by_launcher() -> void:
	var expected := OS.get_environment("QA_EXPECTED_USER_ROOT")
	if expected.is_empty():
		return # Direct Godot invocations do not use the PowerShell launcher.
	var actual := OS.get_user_data_dir().replace("\\", "/")
	assert_true(actual.begins_with(expected + "/"), "user:// must stay under unique QA data root: " + actual)
