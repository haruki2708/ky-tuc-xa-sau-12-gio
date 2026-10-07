extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var menu := get_node("/root/Autoplay/Chapter3QAMenu")
	menu.set_open(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://ch3-menu.png")
	menu.set_open(false)
	if not menu.available("b") or not menu.available("gate"):
		print("RESULT: qa-menu SKIP chapter3 (T-181 scene/stage unavailable; menu rendered)")
		App.quit()
		return
	# Keep the observer across real scene changes.
	get_tree().current_scene = null
	for destination in ["b", "garden", "stadium", "gate"]:
		await menu.jump(destination)
		await get_tree().process_frame
		if str(GameState.segment) != str(menu.profile.jumps[destination]) or GameState.chapter != 3:
			print("RESULT: qa-menu FAIL chapter3 jump ", destination)
			App.quit(1)
			return
		# Exercise the same signal handlers as the four visible debug buttons.
		var player := get_tree().current_scene.get_node("Player")
		player.call("_set_stamina", 0.2)
		for action in ["zombies_off", "zombies_on", "give_bar", "refill"]:
			var outcome: Dictionary = await menu.apply_action(action)
			if outcome.status != "PASS":
				print("RESULT: qa-menu FAIL chapter3 ", destination, " ", action)
				App.quit(1)
				return
		var key := InputEventKey.new()
		key.keycode = KEY_F9
		key.pressed = true
		menu._input(key)
		if not menu.panel.visible or not get_tree().paused:
			print("RESULT: qa-menu FAIL chapter3 F9")
			App.quit(1)
			return
		menu._input(key)
	print("RESULT: qa-menu PASS chapter3 (four area jumps, four debug actions per area, F9)")
	App.quit()
