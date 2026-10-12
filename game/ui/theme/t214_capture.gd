extends Control
## Manual renderer fixture: isolated user data required; never plays a chapter.

const SCREENS := ["title", "warning", "credits", "chapters", "pause", "settings", "settings_bottom", "settings_reset", "phone", "phone_map", "phone_camera", "phone_choices", "phone_prediction", "phone_last_message", "paper", "handwritten", "notebook", "notebook_compare", "hud", "chain", "death", "chapter", "chapter4", "chapter4_credits"]
var _output := ""
var _errors := 0

class PreviewApp:
	extends Node
	func has_saved_game() -> bool:
		return true
	func start_game(_saved: bool) -> void:
		pass
	func start_chapter(_chapter: int) -> void:
		pass
	func quit() -> void:
		pass


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--t214-output="):
			_output = argument.trim_prefix("--t214-output=")
	if _output.is_empty() or DisplayServer.get_name() == "headless":
		push_error("T214 capture requires a real renderer and --t214-output=<directory>.")
		get_tree().quit(1)
		return
	_capture.call_deferred()


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(_output)
	get_window().mode = Window.MODE_WINDOWED
	get_window().borderless = true
	get_window().content_scale_size = Vector2i(1920, 1080)
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		get_window().size = resolution
		for locale: String in ["vi", "en"]:
			# The fixture is launched with isolated APPDATA; keep the locale picker honest.
			Settings.set_value("ui", "locale", locale)
			for screen: String in SCREENS:
				var host := Control.new()
				add_child(host)
				host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				_show_fixture(host, screen)
				await get_tree().process_frame
				await get_tree().process_frame
				if screen == "settings_bottom":
					host.get_node("PauseMenu/Root/SettingsCard/SettingsPanel/Scroll").scroll_vertical = 10000
				await get_tree().create_timer(0.45, true).timeout
				await RenderingServer.frame_post_draw
				var picture := get_viewport().get_texture().get_image()
				var filename := "%s/%s_%s_%dx%d.png" % [_output, screen, locale, resolution.x, resolution.y]
				if picture.get_size() != resolution or picture.save_png(filename) != OK:
					_errors += 1
					push_error("T214 capture failed: " + filename)
				else:
					print("CAPTURE: ", filename)
				var typography: Array = []
				_collect_typography(host, typography)
				var report := FileAccess.open(filename.trim_suffix(".png") + ".json", FileAccess.WRITE)
				report.store_string(JSON.stringify({"locale": locale, "resolution": [resolution.x, resolution.y],
					"logical_resolution": [1920, 1080], "text": typography}, "\t"))
				report.close()
				if screen in ["pause", "settings", "settings_bottom"]:
					var pause := host.get_node("PauseMenu")
					pause.close_menu()
					if get_tree().paused or pause.get_node("Root").visible:
						_errors += 1
						push_error("Closing the menu changed its synchronous gameplay contract.")
					await get_tree().create_timer(0.25, true).timeout
					if pause.has_node("ClosingVisual"):
						_errors += 1
						push_error("Closing transition did not dispose its overlay.")
				get_tree().paused = false
				host.queue_free()
				await get_tree().process_frame
				await get_tree().process_frame
	print("RESULT: T214 capture ", "PASS" if _errors == 0 else "FAIL", " (", SCREENS.size() * 4, " images)")
	App.quit(_errors)


func _show_fixture(host: Control, screen: String) -> void:
	GameState.reset()
	GameState.chapter = 1
	var backdrop := TextureRect.new()
	backdrop.texture = load("res://ui/title/corridor.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.modulate = Color(0.45, 0.45, 0.45)
	host.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	match screen:
		"title", "warning", "credits", "chapters":
			var app := PreviewApp.new()
			host.add_child(app)
			var title: Control = load("res://ui/title/title_screen.tscn").instantiate()
			title.app_path = app.get_path()
			host.add_child(title)
			title.show_menu()
			if screen == "warning":
				title.show_warning()
			elif screen == "credits":
				title.show_credits()
			elif screen == "chapters":
				title.show_chapters()
			title.get_node("Hum").stop()
		"pause", "settings", "settings_bottom", "settings_reset":
			var pause: CanvasLayer = load("res://ui/pause/pause_menu.tscn").instantiate()
			host.add_child(pause)
			pause.open_menu()
			if screen.begins_with("settings"):
				pause.show_settings()
			if screen == "settings_reset":
				var panel := pause.get_node("Root/SettingsCard/SettingsPanel")
				if panel.has_method("_on_reset_video_pressed"):
					panel._on_reset_video_pressed()
		"phone", "phone_map", "phone_camera", "phone_choices", "phone_prediction", "phone_last_message":
			if screen == "phone_last_message":
				GameState.chapter = 4
				GameState.set_flag(&"ch4_phone_charges", 3)
			var phone: CanvasLayer = load("res://ui/phone/phone_screen.tscn").instantiate()
			phone.set_script(load("res://scripts/ui/phone_preview.gd"))
			host.add_child(phone)
			EventBus.time_changed.emit(246)
			EventBus.phone_battery_changed.emit(64.0)
			EventBus.phone_call_incoming.emit(&"preview_call")
			EventBus.phone_raised.emit(true)
			EventBus.phone_call_answered.emit(&"preview_call")
			EventBus.phone_message_received.emit(&"preview_a")
			EventBus.phone_message_received.emit(&"preview_b")
			if screen == "phone_map":
				phone.tools_view.select_tab(1)
			elif screen == "phone_camera":
				phone.state.camera_unlocked = true
				phone.tools_view.select_tab(2)
			elif screen == "phone_choices":
				EventBus.chat_choice_requested.emit(&"preview_choice", PackedStringArray(["UI_PHONE_PREVIEW_OPTION_1", "UI_PHONE_PREVIEW_OPTION_2", "UI_PHONE_PREVIEW_OPTION_3", "UI_PHONE_PREVIEW_OPTION_4"]))
			elif screen == "phone_prediction":
				EventBus.prediction_requested.emit(&"minh_nhat", PackedInt32Array([4, 7, 1]), 20.0)
			elif screen == "phone_last_message":
				EventBus.fade_message_requested.emit(12.0)
				phone.ch4.editor.entry.text = tr("UI_PHONE_PREVIEW_OPTION_1")
		"paper", "handwritten", "notebook", "notebook_compare":
			RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
			var document := DocumentData.load_by_id(&"hall_board_note" if screen == "handwritten" else &"room_paper_407")
			document.mark_rules_read()
			if screen.begins_with("notebook"):
				if screen == "notebook_compare":
					GameState.chapter = 4
					GameState.set_flag(&"ch4_compare_enabled", true)
				var notebook: CanvasLayer = load("res://ui/notebook/notebook.tscn").instantiate()
				host.add_child(notebook)
				notebook.open_notebook()
				if screen == "notebook_compare":
					notebook.ch4.select_tab(1)
			else:
				var paper: CanvasLayer = load("res://ui/document/document_view.tscn").instantiate()
				host.add_child(paper)
				paper.show_document(document)
		"hud":
			host.add_child(load("res://ui/hud/hud.tscn").instantiate())
			EventBus.interaction_focus_changed.emit("PROMPT_READ")
			EventBus.subtitle_requested.emit("SUB_NOTEBOOK_HINT", 20.0)
		"death":
			var death: CanvasLayer = load("res://ui/death/death_screen.tscn").instantiate()
			host.add_child(death)
			death._on_failed(&"")
		"chain":
			var chain: CanvasLayer = load("res://ui/chain/chain_panel.tscn").instantiate()
			host.add_child(chain)
			chain.tick_enabled = false
			EventBus.chain_turn_started.emit(&"trung", 15.0)
			EventBus.chain_word_spoken.emit(&"phuc", "WORD_CH2_DIEM_DANH")
			EventBus.chain_word_spoken.emit(&"viet", "WORD_CH2_DANH_SACH")
			EventBus.chain_input_requested.emit(15.0)
			chain.open_entry()
		"chapter":
			var card: CanvasLayer = load("res://ui/ch3/ch3_end_card.tscn").instantiate()
			host.add_child(card)
			card.show_card()
			card._process(2.0)
		"chapter4", "chapter4_credits":
			var card: CanvasLayer = load("res://ui/ch4/ch4_end_card.tscn").instantiate()
			host.add_child(card)
			card.set_process(false)
			EventBus.chapter_finished.emit(4)
			card._process(5.2 if screen == "chapter4_credits" else 2.2)


func _collect_typography(node: Node, output: Array) -> void:
	if node is Window and node.visible and not node.title.is_empty():
		var title_size: int = node.get_theme_font_size("title_font_size")
		var output_scale := float(get_window().size.y) / 1080.0
		output.append({"path": String(node.get_path()) + "/title", "text": node.title,
			"font_size": title_size, "screen_scale": output_scale, "output_px": title_size * output_scale})
	if node is Label or node is Button or node is RichTextLabel or node is LineEdit:
		var control := node as Control
		if control.is_visible_in_tree():
			var size_key := "normal_font_size" if node is RichTextLabel else "font_size"
			var text_value: String = (node as RichTextLabel).get_parsed_text() if node is RichTextLabel else node.tr(String(node.get("text")))
			var font_size := control.get_theme_font_size(size_key)
			output.append({"path": String(node.get_path()), "text": text_value, "font_size": font_size,
				"screen_scale": control.get_global_transform_with_canvas().get_scale().y * float(get_window().size.y) / 1080.0,
				"output_px": font_size * control.get_global_transform_with_canvas().get_scale().y * float(get_window().size.y) / 1080.0,
				"rect": [control.position.x, control.position.y, control.size.x, control.size.y]})
	for child in node.get_children(true):
		_collect_typography(child, output)
