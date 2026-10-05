extends Control
## Isolated presentation fixtures; no chapter-three gameplay or guessed story text.

class PreviewApp:
	extends Node
	func has_saved_game() -> bool:
		return false


func _ready() -> void:
	var mode := "stamina_low_vi"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ch3-ui="):
			mode = arg.trim_prefix("--ch3-ui=")
	TranslationServer.set_locale("en" if mode.ends_with("_en") else "vi")
	mode = mode.trim_suffix("_vi").trim_suffix("_en")
	Settings.set_value("accessibility", "reduce_scares", mode.ends_with("_reduced"))
	mode = mode.trim_suffix("_reduced")
	if mode == "chapters":
		var app := PreviewApp.new()
		add_child(app)
		var title: Control = load("res://ui/title/title_screen.tscn").instantiate()
		title.app_path = app.get_path()
		title.progress_path = "user://ch3_ui_preview_progress.json"
		Progress.unlock(3, title.progress_path)
		add_child(title)
		title.show_chapters()
		return
	if mode == "end_card":
		var ending: CanvasLayer = load("res://ui/ch3/ch3_end_card.tscn").instantiate()
		add_child(ending)
		EventBus.chapter_finished.emit(3)
		ending._process(2.0)
		ending.set_process(false)
		return
	if mode in ["zombie_grab", "guard_shock", "guard_flash", "guard_dark"]:
		var blood: CanvasLayer = load("res://ui/death/blood_overlay.tscn").instantiate()
		add_child(blood)
		EventBus.player_death_started.emit(&"zombie_grab" if mode == "zombie_grab" else &"guard_shock")
		var elapsed := 0.0 if mode == "guard_flash" else 1.5 if mode == "guard_dark" else 0.35 if mode == "guard_shock" else 1.0
		blood._process(elapsed)
		blood.set_process(false)
		return
	var status: CanvasLayer = load("res://ui/ch3/ch3_status.tscn").instantiate()
	add_child(status)
	# Existing HUD subtitle placement demonstrates that edge effects spare readable text.
	add_child(load("res://ui/hud/hud.tscn").instantiate())
	EventBus.subtitle_requested.emit("CH_3_TITLE", 60.0)
	match mode:
		"stamina_full": EventBus.stamina_changed.emit(1.0, false)
		"stamina_low": EventBus.stamina_changed.emit(0.25, false)
		"stamina_exhausted": EventBus.stamina_changed.emit(0.0, true)
		"bar_new": EventBus.bar_picked.emit(8)
		"bar_bent": EventBus.bar_picked.emit(1)
		"bar_broken":
			EventBus.bar_picked.emit(1)
			EventBus.bar_broken.emit()
		"guard_warning":
			var guard := Node3D.new()
			add_child(guard)
			EventBus.guard_warned.emit(guard, true)
	status._process(0.15)
	status.set_process(false)
