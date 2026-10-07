extends Node
## Deterministic presentation fixture, never a chapter director or a verdict source.


func _ready() -> void:
	var mode := "compare_vi"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--ch4-ui="):
			mode = argument.trim_prefix("--ch4-ui=")
	TranslationServer.set_locale("en" if mode.ends_with("_en") else "vi")
	mode = mode.trim_suffix("_en").trim_suffix("_vi")
	GameState.reset()
	GameState.chapter = 4
	GameState.set_flag(&"ch4_compare_enabled", true)
	GameState.set_flag(&"ch4_phone_charges", 3)
	if mode.begins_with("hospital"):
		$Background.hide()
		var camera := Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 2.1
		camera.position = Vector3(0, 0, 2)
		add_child(camera)
		for index in 3:
			var card := preload("res://ui/ch4/bed_card.tscn").instantiate()
			card.character = ["nhat", "trung", "ngu"][index]
			card.position = Vector3((index - 1) * 0.65, 0, 0)
			add_child(card)
		EventBus.ch4_ending.emit(&"alone" if mode == "hospital_alone" else &"all")
		return
	if mode in ["end", "credits"]:
		var card := preload("res://ui/ch4/ch4_end_card.tscn").instantiate()
		add_child(card)
		card.set_process(false)
		EventBus.chapter_finished.emit(4)
		card._process(2.2 if mode == "end" else 5.2)
		return
	if mode == "fade":
		var phone := preload("res://ui/phone/phone_screen.tscn").instantiate()
		add_child(phone)
		phone.set_process(false)
		EventBus.fade_message_requested.emit(12.0)
		phone.ch4.advance(6.0)
		return
	if mode == "door":
		var blood := preload("res://ui/death/blood_overlay.tscn").instantiate()
		add_child(blood)
		EventBus.player_death_started.emit(&"door_burst")
		blood._process(0.6)
		blood.set_process(false)
		return
	var book := preload("res://ui/notebook/notebook.tscn").instantiate()
	add_child(book)
	book.open_notebook()
	var form: Node = book.ch4.forms
	form.set_process(false)
	if mode in ["compare", "marked"]:
		book.ch4.select_tab(1)
		if mode == "marked":
			book.ch4._select(&"ch3_r5_2")
			book.ch4.mark_selected()
			EventBus.ch4_compare_result.emit(&"ch3_r5_2", true)
			await get_tree().process_frame
			await get_tree().process_frame
			book.ch4.get_node("CompareScroll").scroll_vertical = 10000
		return
	for bed in [1, 2, 4]:
		EventBus.bed_slat_flipped.emit(bed)
	if mode == "scrap":
		form._show_paper(1)
		return
	EventBus.survivor_form_assembled.emit()
	if mode == "name":
		EventBus.door_damage_changed.emit(&"407", 0.6)
		form._bite()
		form.editor.entry.text = "Trần Trung"
	elif mode == "signed":
		form._bite()
		form.editor._submit("Trần Trung")
		EventBus.blood_name_closed.emit(&"accepted")
		form._process(1.3)
