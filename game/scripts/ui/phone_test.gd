extends Control
## F6/capture harness. No story lines, save writes or invented gameplay rules.


func _ready() -> void:
	var mode := "group"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--phone-capture="):
			mode = arg.trim_prefix("--phone-capture=")
	TranslationServer.set_locale("en" if mode.ends_with("_en") else "vi")
	var phone: CanvasLayer = load("res://ui/phone/phone_screen.tscn").instantiate()
	phone.set_script(load("res://scripts/ui/phone_preview.gd"))
	add_child(phone)
	EventBus.time_changed.emit(246)
	EventBus.phone_battery_changed.emit(64.0)
	EventBus.phone_call_incoming.emit(&"preview_call")
	if mode.begins_with("incoming"):
		return
	EventBus.phone_raised.emit(true)
	EventBus.phone_call_answered.emit(&"preview_call")
	EventBus.phone_message_received.emit(&"preview_a")
	EventBus.phone_message_received.emit(&"preview_b")
	EventBus.chat_member_changed.emit(&"preview_a", &"dead")
	EventBus.flashlight_toggled.emit(true)
	EventBus.chat_choice_requested.emit(&"preview_choice", PackedStringArray([
		"UI_PHONE_PREVIEW_OPTION_1", "UI_PHONE_PREVIEW_OPTION_2", "UI_PHONE_PREVIEW_OPTION_3", "UI_PHONE_PREVIEW_OPTION_4"]))
	if mode == "hidden":
		EventBus.player_hidden.emit(true, &"bunk")
		EventBus.breath_held.emit(true)
