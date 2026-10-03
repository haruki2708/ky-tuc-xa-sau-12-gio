extends TestCase


class BotProbe extends "res://scripts/debug/playthrough_bot.gd":
	func _play() -> void:
		pass

	func _finish() -> void:
		finishing = true


func test_game_audio_stays_stopped_while_bot_runs_during_pause() -> void:
	var bot := BotProbe.new()
	tree.root.add_child(bot)
	await wait_frames(5)
	var hums: Array[LightHum] = []
	for node: Node in bot.main.find_children("*", "", true, false):
		if node is LightHum:
			hums.append(node)
	assert_false(hums.is_empty(), "main must contain real LightHum emitters")
	var playing_before := 0
	for hum in hums:
		if hum.playing:
			playing_before += 1
	assert_true(playing_before > 0, "test must exercise initially playing hums")
	tree.paused = true
	# Same stop sequence as App.quit, without terminating the test runner.
	for node: Node in bot.main.find_children("*", "", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
			node.stop()
	await wait_frames(5)
	assert_true(bot.can_process(), "bot must keep handling document close and timeouts")
	assert_false(bot.main.can_process(), "game must respect tree pause")
	for hum in hums:
		assert_false(hum.playing, "hum restarted during audio drain: " + str(hum.get_path()))
	bot.queue_free()
	await tree.create_timer(0.3, true, false, true).timeout
	tree.paused = false
	GameState.reset()
