extends Control
## Standalone integration harness; no project/autoload changes are needed for F6.

const SettingsStore = preload("res://scripts/ui/settings.gd")
const PauseMenu = preload("res://ui/pause/pause_menu.tscn")


func _ready() -> void:
	var settings := get_node_or_null("/root/Settings") as SettingsStore
	if settings == null:
		settings = SettingsStore.new()
		settings.name = "PreviewSettings"
		add_child(settings)
	var menu: CanvasLayer = PauseMenu.instantiate()
	menu.settings_path = settings.get_path()
	add_child(menu)
	var args := OS.get_cmdline_user_args()
	if args.has("--capture-pause") or args.has("--capture-settings"):
		TranslationServer.set_locale("vi")
		menu.open_menu()
		if args.has("--capture-settings"):
			menu.show_settings()
