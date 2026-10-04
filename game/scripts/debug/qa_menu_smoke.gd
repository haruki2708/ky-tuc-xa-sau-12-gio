extends Node
## Real scene jump/F9/isolation check. The observer survives scene replacement.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _run() -> void:
	if not preload("res://scripts/debug/qa_menu.gd").isolated():
		print("RESULT: qa-menu FAIL isolation")
		App.quit(1)
		return
	get_tree().current_scene = null
	var menu := get_node("/root/Autoplay/QAMenu")
	var passed := true
	for destination in ["prologue", "r1", "r2", "manager"]:
		await menu.jump(destination)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var scene := get_tree().current_scene
		passed = passed and scene != null and str(GameState.segment) == str(menu.jumps[destination])
		print("QA_MENU_CHECK: ", destination, " segment=", GameState.segment)
	var key := InputEventKey.new()
	key.keycode = KEY_F9
	key.pressed = true
	Input.parse_input_event(key.duplicate())
	Input.flush_buffered_events()
	await get_tree().process_frame
	print("QA_F9_OPEN: ", menu.panel.visible, " paused=", get_tree().paused)
	passed = passed and menu.panel.visible and get_tree().paused
	Input.parse_input_event(key.duplicate())
	Input.flush_buffered_events()
	await get_tree().process_frame
	print("QA_F9_CLOSE: ", menu.panel.visible, " paused=", get_tree().paused)
	passed = passed and not menu.panel.visible and not get_tree().paused
	menu.panel.get_child(0).get_node("QA_GOD").button_pressed = true
	var director := get_tree().current_scene.get_node("Chapter1Director")
	director._die(&"QA_TEST_DEATH")
	passed = passed and not director._dying and &"QA_TEST_DEATH" in director.suppressed
	menu.panel.get_child(0).get_node("QA_SPEED").button_pressed = true
	passed = passed and Engine.time_scale == 4.0
	menu.panel.get_child(0).get_node("QA_SPEED").button_pressed = false
	menu.panel.get_child(0).get_node("QA_ANSWERS").button_pressed = true
	passed = passed and menu.answers.visible
	menu.set_open(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://qa-menu.png")
	menu.set_open(false)
	print("RESULT: qa-menu ", "PASS" if passed else "FAIL", " (four real stage jumps, F9, invincibility, answers, x4, isolated saves)")
	App.quit(0 if passed else 1)
