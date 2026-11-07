extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var menu := get_node("/root/Autoplay/Chapter4QAMenu")
	menu.set_open(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://ch4-menu.png")
	menu.set_open(false)
	if not menu.available("split") or not menu.available("end4"):
		print("RESULT: qa-menu SKIP chapter4 (T-232 scene/stage unavailable; menu rendered)")
		App.quit()
		return
	# Keep the smoke driver across real scene changes.
	get_tree().current_scene = null
	for destination in ["split", "library", "return", "room407", "end4"]:
		await menu.jump(destination)
		await get_tree().process_frame
		if str(GameState.segment) != str(menu.profile.jumps[destination]) or GameState.chapter != 4:
			print("RESULT: qa-menu FAIL chapter4 jump ", destination)
			App.quit(1)
			return
		var key := InputEventKey.new()
		key.keycode = KEY_F9
		key.pressed = true
		menu._input(key)
		if not menu.panel.visible or not get_tree().paused:
			print("RESULT: qa-menu FAIL chapter4 F9")
			App.quit(1)
			return
		menu._input(key)
		if menu.panel.visible or get_tree().paused:
			print("RESULT: qa-menu FAIL chapter4 F9 close")
			App.quit(1)
			return
	print("RESULT: qa-menu PASS chapter4 (five stage jumps, F9)")
	App.quit()
