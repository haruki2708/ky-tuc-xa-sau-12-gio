extends Control
## Isolated UI evidence using only examples approved in CH2_DESIGN.md.

const TEMPERATURES := [67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42]
const OPTIONS := ["UI_CH2_PREVIEW_WORD_2", "UI_CH2_PREVIEW_WORD_3", "UI_CH2_PREVIEW_WORD_4", "UI_CH2_PREVIEW_WORD_5"]


func _ready() -> void:
	var mode := "chain_player_vi"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ch2-ui="):
			mode = arg.trim_prefix("--ch2-ui=")
	TranslationServer.set_locale("en" if mode.ends_with("_en") else "vi")
	mode = mode.trim_suffix("_vi").trim_suffix("_en")
	Settings.set_value("accessibility", "reduce_scares", mode.ends_with("_reduced"))
	if mode.begins_with("chain_"):
		var chain: CanvasLayer = load("res://ui/chain/chain_panel.tscn").instantiate()
		add_child(chain)
		EventBus.chain_turn_started.emit(&"dat", 4.0)
		EventBus.chain_word_spoken.emit(&"dat", "UI_CH2_PREVIEW_WORD_1")
		if mode != "chain_corpse":
			EventBus.chain_turn_started.emit(&"trung", 15.0)
			EventBus.chain_input_requested.emit(15.0)
			chain.open_entry()
			chain.get_node("Root/Card/Content/Entry").text = "khuất bóng"
			if mode == "chain_blocked":
				EventBus.chain_choice_blocked.emit(true)
			if mode == "chain_timeout":
				chain._process(15.0)
		return
	if mode.begins_with("shower_"):
		var screen: Node3D = load("res://ui/shower/shower_screen.tscn").instantiate()
		add_child(screen)
		var display := TextureRect.new()
		display.texture = screen.get_texture()
		display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(display)
		display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		display.offset_left = 400
		display.offset_right = -400
		display.offset_top = 60
		display.offset_bottom = -60
		if mode != "shower_countdown":
			for temperature: int in TEMPERATURES:
				EventBus.shower_slot_finished.emit(temperature, false, 24)
		EventBus.shower_choice_requested.emit(8.0)
		if mode in ["shower_steam", "shower_wiped"]:
			EventBus.shower_steam_changed.emit(1.0)
		if mode == "shower_wiped":
			screen.wipe()
		return
	if mode.begins_with("prediction_"):
		var phone: CanvasLayer = load("res://ui/phone/phone_screen.tscn").instantiate()
		add_child(phone)
		var member: StringName = &"ngu" if mode == "prediction_ngu" else &"minh_nhat"
		EventBus.prediction_requested.emit(member, PackedInt32Array([74, 15, 62] if member == &"ngu" else [38, 16, 75]), 20.0)
		return
	if mode == "phone":
		var phone: CanvasLayer = load("res://ui/phone/phone_screen.tscn").instantiate()
		phone.set_script(preload("res://scripts/ui/ch2_phone_preview.gd"))
		add_child(phone)
		EventBus.phone_raised.emit(true)
		EventBus.phone_message_received.emit(&"ch2_preview_loop")
		return
	var blood: CanvasLayer = load("res://ui/death/blood_overlay.tscn").instantiate()
	add_child(blood)
	if mode == "camera_steam":
		blood.set_shower_inside(true)
		EventBus.shower_steam_changed.emit(1.0)
	else:
		EventBus.player_death_started.emit(StringName(mode.trim_suffix("_reduced")))
