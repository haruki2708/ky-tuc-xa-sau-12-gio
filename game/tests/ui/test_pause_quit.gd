extends "res://tests/ui/settings_test_case.gd"

const PAUSE_SCENE = preload("res://ui/pause/pause_menu.tscn")


class FakeApp:
	extends Node
	var quit_calls := 0
	var paused_when_called := false


	func quit() -> void:
		quit_calls += 1
		paused_when_called = get_tree().paused


class QuitSpyMenu:
	extends "res://scripts/ui/pause_menu.gd"
	var direct_quit_calls := 0


	func _quit_tree() -> void:
		direct_quit_calls += 1


var _menu: QuitSpyMenu
var _real_app: Node
var _fake_app: FakeApp


func before_each() -> void:
	super.before_each()
	# Preserve the real autoload instance and its state; only replace the lookup.
	_real_app = tree.root.get_node_or_null("App")
	if _real_app != null:
		_real_app.name = "AppPreservedForQuitTest"
	var instance: CanvasLayer = PAUSE_SCENE.instantiate()
	instance.set_script(QuitSpyMenu)
	_menu = instance as QuitSpyMenu
	_menu.settings_path = settings.get_path()
	tree.root.add_child(_menu)


func after_each() -> void:
	_menu.close_menu()
	_menu.queue_free()
	await wait_frames(2)
	if is_instance_valid(_fake_app):
		_fake_app.free()
	if is_instance_valid(_real_app):
		_real_app.name = "App"
	super.after_each()


func test_quit_button_uses_app_while_paused() -> void:
	_fake_app = FakeApp.new()
	_fake_app.name = "App"
	tree.root.add_child(_fake_app)
	_menu.open_menu()
	_menu.get_node("Root/PauseCard/Buttons/Quit").pressed.emit()
	assert_eq(_fake_app.quit_calls, 1, "quit button delegates to /root/App;")
	assert_true(_fake_app.paused_when_called, "audio drain starts with the game still paused")
	assert_eq(_menu.direct_quit_calls, 0, "App must not be followed by an immediate exit;")


func test_quit_button_without_app_uses_direct_fallback() -> void:
	assert_eq(tree.root.get_node_or_null("App"), null, "standalone lookup has no App;")
	_menu.open_menu()
	_menu.get_node("Root/PauseCard/Buttons/Quit").pressed.emit()
	assert_eq(_menu.direct_quit_calls, 1, "standalone fallback remains available;")
