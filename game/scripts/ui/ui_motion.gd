extends RefCounted
## Short presentation-only transitions; gameplay pause/navigation stay synchronous.

const DURATION := 0.18


static func reveal(control: Control) -> void:
	if control.has_meta("reveal_tween"):
		var previous: Tween = control.get_meta("reveal_tween")
		if previous != null and previous.is_valid():
			previous.kill()
	control.modulate.a = 0.0
	var tween := control.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	control.set_meta("reveal_tween", tween)
	tween.tween_property(control, "modulate:a", 1.0, DURATION).set_trans(Tween.TRANS_SINE)


static func closing_copy(control: Control, host: Node) -> void:
	if not control.is_visible_in_tree() or DisplayServer.get_name() == "headless":
		return
	# Capture pixels only: duplicating a tree with embedded Windows is unsafe.
	# The overlay never owns input, signals, scripts or gameplay state.
	var picture := control.get_viewport().get_texture().get_image()
	if picture == null or picture.is_empty():
		return
	var ghost := TextureRect.new()
	ghost.name = "ClosingVisual"
	ghost.texture = ImageTexture.create_from_image(picture)
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.focus_mode = Control.FOCUS_NONE
	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	host.add_child(ghost)
	ghost.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tween := host.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(ghost, "modulate:a", 0.0, DURATION)
	tween.tween_callback(ghost.queue_free)


static func scene_curtain(root: Window) -> void:
	# The root owns this brief overlay so App can change scenes immediately.
	var layer := CanvasLayer.new()
	layer.layer = 99
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_child(layer)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.015, 0.015, 1)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tween := layer.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(shade, "color:a", 0.0, 0.22)
	tween.tween_callback(layer.queue_free)
