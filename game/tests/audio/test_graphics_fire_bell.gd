extends TestCase

const FIXTURE := preload("res://audio/graphics_upgrade/fire_bell_preview.tscn")
const STREAM := preload("res://audio/graphics_upgrade/fire_bell_soft.ogg")
var _fixture: Node3D


func after_each() -> void:
	tree.paused = false
	if is_instance_valid(_fixture):
		_fixture.stop_preview()
		_fixture.free()
	await tree.create_timer(0.1).timeout


func test_candidate_decodes_and_matches_source_report() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/graphics_upgrade/build_report.json"))
	var entry: Dictionary = report.assets[0]
	assert_eq(FileAccess.get_sha256(STREAM.resource_path), entry.sha256)
	assert_eq(FileAccess.get_sha256("res://../audio_source/graphics_upgrade/raw/fire_bell_soft.wav"), entry.raw_sha256)
	assert_false(STREAM.loop, "Core currently awaits finished; imported candidate must stay finite")
	assert_true(absf(STREAM.get_length() - 4.0) < 0.01)
	assert_true(absf(entry.lufs - entry.target_lufs) <= 1.0)
	assert_true(entry.true_peak_db <= -2.0)
	assert_true(entry.boundary_delta < 0.01)
	var playback := STREAM.instantiate_playback()
	playback.start()
	var peak := 0.0
	for frame in playback.mix_audio(1.0, ceili(STREAM.get_length() * 48000)):
		assert_true(is_finite(frame.x) and is_finite(frame.y))
		peak = maxf(peak, absf(frame.x))
	assert_true(peak > 0.000001 and peak < 0.8, "Non-silent, unclipped decoded signal")
	playback.stop()


func test_loop_survives_clip_end_and_pause_stop_reload_leave_one_source() -> void:
	_fixture = FIXTURE.instantiate()
	tree.root.add_child(_fixture)
	assert_eq(_fixture.player, null, "Fixture starts silent")
	_fixture.play_clip(false, true)
	var first: AudioStreamPlayer3D = _fixture.player
	assert_false(STREAM.loop, "Preview must not mutate the shared resource")
	first.seek(3.9)
	await tree.create_timer(0.3).timeout
	assert_true(first.playing, "Private loop continues beyond the finite clip length")
	_fixture.toggle_pause()
	await tree.create_timer(0.1).timeout
	assert_false(first.can_process())
	var paused_at := first.get_playback_position()
	await tree.create_timer(0.2).timeout
	assert_true(absf(first.get_playback_position() - paused_at) < 0.05)
	_fixture.toggle_pause()
	await tree.create_timer(0.15).timeout
	assert_true(first.can_process() and first.playing)
	_fixture.play_clip(true)
	assert_false(first.playing)
	assert_eq(_fixture.find_children("*", "AudioStreamPlayer3D", true, false).size(), 1)
	_fixture.stop_preview()
	assert_eq(_fixture.find_children("*", "AudioStreamPlayer3D", true, false).size(), 0)
	_fixture.play_clip(false, true)
	var old_player: WeakRef = weakref(_fixture.player)
	_fixture.free()
	_fixture = FIXTURE.instantiate()
	tree.root.add_child(_fixture)
	await tree.process_frame
	assert_eq(old_player.get_ref(), null, "Scene disposal releases its source")
	assert_eq(_fixture.player, null, "Reload starts silent")


func test_preview_deadline_pauses_then_cleans_up_without_finished() -> void:
	_fixture = FIXTURE.instantiate()
	tree.root.add_child(_fixture)
	_fixture.play_clip(false, true, 0.25)
	_fixture.toggle_pause()
	await tree.create_timer(0.4).timeout
	assert_not_null(_fixture.player, "Paused deadline cannot expire")
	_fixture.toggle_pause()
	await tree.create_timer(0.45).timeout
	assert_eq(_fixture.player, null, "Explicit deadline stops a loop that never emits finished")
