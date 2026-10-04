extends Control
## F6 evidence scene: existing approved data, no checkpoint writes or story director.

func _ready() -> void:
	var mode := "rulebook"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter-ui="):
			mode = arg.trim_prefix("--chapter-ui=")
	TranslationServer.set_locale("en" if mode.ends_with("_en") else "vi")
	mode = mode.trim_suffix("_en").trim_suffix("_vi")
	match mode:
		"rulebook":
			RuleSystem.load_rule_set(load("res://data/rules/ch1.tres"))
			for id: StringName in [&"ch1_general_2", &"ch1_general_3", &"ch1_r2"]:
				RuleSystem.mark_read(id)
			RuleSystem.set_suspected(&"ch1_r2", true)
			var book := _instance("res://ui/notebook/notebook.tscn")
			book.open_notebook()
		"survivors":
			_instance("res://ui/survivors/survivor_notice.tscn")
			EventBus.survivor_count_changed.emit(352)
		"death":
			_instance("res://ui/death/death_screen.tscn")
			GameState.set_flag(&"survivors", 352)
			EventBus.player_failed.emit(&"DEATH_OWN_BED")
		"puzzle", "hint":
			var panel := _instance("res://ui/puzzle/puzzle_panel.tscn")
			EventBus.puzzle_opened.emit(&"locker_combo_dat")
			panel._turn(0, 1)
			panel._turn(0, 1)
			for step in 5:
				panel._turn(1, 1)
			if mode == "hint":
				panel._show_hint()


func _instance(path: String) -> Node:
	var node: Node = load(path).instantiate()
	add_child(node)
	return node
