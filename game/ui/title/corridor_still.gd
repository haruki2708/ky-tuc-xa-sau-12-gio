extends Node3D
## One-off UI photograph fixture. Production title uses the resulting still.


func _ready() -> void:
	var output := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--t214-background="):
			output = argument.trim_prefix("--t214-background=")
	if output.is_empty():
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().borderless = true
	get_window().size = Vector2i(1920, 1080)
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	var error := picture.save_png(output)
	print("RESULT: T214 background ", "PASS" if error == OK else "FAIL", " ", picture.get_size())
	App.quit(0 if error == OK else 1)
