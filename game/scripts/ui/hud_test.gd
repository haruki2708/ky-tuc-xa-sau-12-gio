extends Control
## F6 playground; sample captions are typography fixtures, not story content.

const LocaleSettings = preload("res://scripts/ui/locale_settings.gd")
var _focused := false


func _ready() -> void:
	# This F6 scene also works before the Settings autoload is integrated.
	if get_node_or_null("/root/Settings") == null:
		var settings := preload("res://scripts/ui/settings.gd").new()
		add_child(settings)
	$Controls/Buttons/Focus.pressed.connect(_toggle_focus)
	$Controls/Buttons/Subtitles.pressed.connect(_queue_subtitles)
	$Controls/Buttons/Language.pressed.connect(_toggle_locale)
	if OS.get_cmdline_user_args().has("--capture-ui"):
		TranslationServer.set_locale("vi")
		_toggle_focus()
		EventBus.subtitle_requested.emit("SUB_TEST_1", 3600.0)


func _toggle_focus() -> void:
	_focused = not _focused
	EventBus.interaction_focus_changed.emit("PROMPT_INTERACT" if _focused else "")


func _queue_subtitles() -> void:
	EventBus.subtitle_requested.emit("SUB_TEST_1", 2.5)
	EventBus.subtitle_requested.emit("SUB_TEST_2", 2.5)


func _toggle_locale() -> void:
	var next_locale := "en" if TranslationServer.get_locale().begins_with("vi") else "vi"
	var error := LocaleSettings.set_locale(next_locale)
	$Controls/SaveError.visible = error != OK
	if error != OK:
		push_error("Could not save UI locale: %s" % error_string(error))
