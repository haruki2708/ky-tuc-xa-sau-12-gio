extends Control

func _ready() -> void:
	get_window().mode = Window.MODE_WINDOWED
	get_window().borderless = true
	get_window().size = Vector2i(1920, 1080)
	var locale := "vi"
	var doc_id := &"ch1_team_photo"
	var out_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--locale="):
			locale = arg.trim_prefix("--locale=")
		elif arg.begins_with("--doc-id="):
			doc_id = StringName(arg.trim_prefix("--doc-id="))
		elif arg.begins_with("--save-png="):
			out_path = arg.trim_prefix("--save-png=")
	TranslationServer.set_locale(locale)
	var doc := DocumentData.load_by_id(doc_id)
	$DocumentView.show_document(doc)
	if not out_path.is_empty():
		_save_image.call_deferred(out_path)


func _save_image(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img != null:
		var err := img.save_png(path)
		print("SAVED PREVIEW (err %d): %s" % [err, path])
	get_tree().quit(0)

