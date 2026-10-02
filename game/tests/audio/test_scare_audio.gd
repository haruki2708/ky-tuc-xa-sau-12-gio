extends TestCase

const TARGETS := {
	"sting_low": -32.0, "sting_hit": -20.0, "slipper_place": -32.0,
	"tube_cut": -32.0, "breath_close": -36.0, "slipper_rush_01": -34.0,
	"slipper_rush_02": -34.0, "slipper_rush_03": -34.0, "slipper_rush_04": -34.0,
	"whisper_co": -30.0, "net_billow": -32.0,
}


func after_each() -> void:
	await tree.create_timer(0.1).timeout


func test_scare_loudness_report_matches_assets_and_targets() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/build_report.json"))
	var measured: Dictionary = {}
	for entry: Dictionary in report["assets"]:
		var file: String = entry["file"]
		var clip_name := file.get_file().get_basename()
		if not TARGETS.has(clip_name):
			continue
		assert_false(measured.has(clip_name), "unique measurement " + clip_name)
		measured[clip_name] = entry["lufs"]
		assert_true(is_finite(entry["lufs"]), "finite LUFS " + clip_name)
		assert_true(absf(entry["lufs"] - TARGETS[clip_name]) <= 1.0, "target LUFS " + clip_name)
		var path := "res://" + file.trim_prefix("game/")
		assert_eq(FileAccess.get_sha256(path), entry["sha256"], "measurement matches OGG " + clip_name)
		assert_true(entry["true_peak_db"] <= -1.0, "peak headroom " + clip_name)
		assert_eq(entry["loop"], clip_name == "breath_close", "report loop " + clip_name)
		if clip_name == "breath_close":
			assert_true(entry["boundary_delta"] <= 0.02, "breath loop boundary")
	assert_eq(measured.size(), TARGETS.size(), "all new sounds measured;")
	if measured.has("sting_hit") and measured.has("sting_low"):
		assert_true(measured["sting_hit"] > measured["sting_low"], "hit louder than low sting")


func test_scare_preview_keys_buses_stop_and_loop() -> void:
	var scene := load("res://audio/test/scare_test.tscn") as PackedScene
	assert_not_null(scene, "scare preview")
	if scene == null:
		return
	var room := scene.instantiate()
	tree.root.add_child(room)
	var player := room.get_node("Preview") as AudioStreamPlayer
	assert_false(player.playing, "no automatic scare on scene entry")
	var names: Array = TARGETS.keys()
	for index in names.size():
		var event := InputEventKey.new()
		event.physical_keycode = KEY_F1 + index
		event.pressed = true
		room._unhandled_key_input(event)
		assert_true(player.playing, "key starts clip %d" % index)
		assert_eq(player.stream.resource_path.get_file().get_basename(), names[index], "key selects clip;")
		assert_eq(player.bus, &"Voice" if index == 9 else &"SFX", "preview routing;")
		assert_eq(player.volume_db, 0.0, "unity audition gain;")
		assert_eq((player.stream as AudioStreamOggVorbis).loop, index == 4, "only breath loops;")
	var stop := InputEventKey.new()
	stop.physical_keycode = KEY_0
	stop.pressed = true
	room._unhandled_key_input(stop)
	assert_false(player.playing, "0 stops preview including loops")
	room.free()
