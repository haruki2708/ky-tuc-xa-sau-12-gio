extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var menu := get_node("/root/Autoplay/Chapter2QAMenu")
	menu.set_open(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://ch2-menu.png")
	menu.set_open(false)
	if not menu.available("r3") or not menu.available("r4"):
		print("RESULT: qa-menu SKIP chapter2 (T-170 scene/stage unavailable; menu rendered)")
		App.quit()
		return
	# Keep the observer across real scene changes.
	get_tree().current_scene = null
	for destination in ["r3", "r4"]:
		await menu.jump(destination)
		await get_tree().process_frame
		if str(GameState.segment) != str(menu.profile.jumps[destination]) or GameState.chapter != 2:
			print("RESULT: qa-menu FAIL chapter2 jump ", destination)
			App.quit(1)
			return
	print("RESULT: qa-menu PASS chapter2 (round 3/4 jumps)")
	App.quit()
