extends Control
## Capture harness: select a screen without changing settings or checkpoints.

class PreviewApp:
	extends Node
	func has_saved_game() -> bool:
		return true

	func start_game(_continue_saved: bool) -> void:
		pass

	func quit() -> void:
		App.quit()

	func start_chapter(_chapter: int) -> void:
		pass


func _ready() -> void:
	var app := PreviewApp.new()
	app.name = "PreviewApp"
	add_child(app)
	var title: Control = load("res://ui/title/title_screen.tscn").instantiate()
	title.app_path = app.get_path()
	add_child(title)
	var screen := "warning"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--title-capture="):
			screen = arg.trim_prefix("--title-capture=")
	TranslationServer.set_locale("en" if screen == "en" or screen.ends_with("_en") else "vi")
	match screen:
		"vi", "en": title.show_menu()
		"credits": title.show_credits()
		"credits_end", "credits_end_en":
			title.show_credits()
			await get_tree().process_frame
			await get_tree().process_frame
			title.get_node("Credits/Content/Scroll").scroll_vertical = 10000
		"settings": title.show_settings()
		"chapters", "chapters_en": title.show_chapters()
		_: title.show_warning()
