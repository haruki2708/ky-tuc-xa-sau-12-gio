extends Control
## Isolated evidence: UI fixtures only, never a chapter director or live CCTV.

class PreviewFeed:
	extends Node
	var camera_id: StringName = &"102"
	var label_key := "UI_CCTV_PREVIEW_LABEL"
	func _ready() -> void:
		add_to_group("cctv_feed")
	func get_texture() -> Texture2D:
		return preload("res://ui/title/corridor.png")


func _ready() -> void:
	var mode := "lost_vi"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--missions-ui="):
			mode = arg.trim_prefix("--missions-ui=")
	TranslationServer.set_locale("en" if mode.ends_with("_en") else "vi")
	mode = mode.trim_suffix("_vi").trim_suffix("_en")
	GameState.set_time(328)
	var player := Node3D.new()
	player.name = "Player"
	add_child(player)
	if mode == "lock":
		var panel: CanvasLayer = load("res://ui/puzzle/puzzle_panel.tscn").instantiate()
		add_child(panel)
		var data := PuzzleData.new()
		data.id = &"preview_limited"
		data.title_key = "PUZZLE_LOCKER_DAT_TITLE"
		data.solution = "2109"
		data.max_attempts = 3
		data.lockout_seconds = 60.0
		panel.open_puzzle(data)
		for index in 4:
			panel._turn(index, 1)
		for attempt in 3:
			panel._submit()
		return
	if mode in ["blood", "blood_reduced"]:
		Settings.set_value("accessibility", "reduce_scares", mode == "blood_reduced")
		var blood: CanvasLayer = load("res://ui/death/blood_overlay.tscn").instantiate()
		add_child(blood)
		EventBus.player_death_started.emit(&"manager_kill")
		return
	var phone: CanvasLayer = load("res://ui/phone/phone_screen.tscn").instantiate()
	phone.set_script(preload("res://scripts/ui/phone_preview.gd"))
	add_child(phone)
	EventBus.phone_raised.emit(true)
	EventBus.phone_battery_changed.emit(64.0)
	EventBus.phone_call_incoming.emit(&"preview")
	EventBus.phone_call_answered.emit(&"preview")
	EventBus.phone_message_received.emit(&"preview_a")
	EventBus.phone_message_received.emit(&"preview_b")
	match mode:
		"lost": EventBus.phone_call_lost.emit(&"preview")
		"map":
			phone.tools_view.select_tab(1)
			phone.tools_view.toggle_room(102)
			phone.tools_view.toggle_room(306)
		"camera", "static":
			add_child(PreviewFeed.new())
			EventBus.cctv_unlocked.emit()
			EventBus.cctv_focus_requested.emit(&"102")
			if mode == "static":
				Settings.set_value("accessibility", "reduce_scares", true)
				EventBus.scare_triggered.emit(&"cctv_kill")
