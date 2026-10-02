extends TestCase

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PlayerController = preload("res://scripts/player/player.gd")
const SETTINGS_PATH: String = "user://settings.cfg"

var player: PlayerController
var _had_settings: bool
var _settings_backup: PackedByteArray
var _previous_mouse_mode: Input.MouseMode
var _previous_paused: bool


func before_each() -> void:
	_previous_mouse_mode = Input.mouse_mode
	_previous_paused = tree.paused
	_had_settings = FileAccess.file_exists(SETTINGS_PATH)
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes(SETTINGS_PATH)
	assert_eq(ConfigFile.new().save(SETTINGS_PATH), OK, "isolate settings fixture")
	tree.paused = false
	_spawn_player()


func after_each() -> void:
	tree.paused = false
	player.free()
	if _had_settings:
		var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		assert_not_null(file, "restore user's exact settings bytes")
		if file != null:
			file.store_buffer(_settings_backup)
			file.close()
	else:
		if FileAccess.file_exists(SETTINGS_PATH):
			assert_eq(DirAccess.remove_absolute(SETTINGS_PATH), OK, "remove temporary settings")
	tree.paused = _previous_paused
	Input.mouse_mode = _previous_mouse_mode


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	tree.root.add_child(player)
	player.set_physics_process(false)


func _save(sensitivity: Variant, bob: Variant) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("input", "mouse_sensitivity", sensitivity)
	config.set_value("video", "head_bob", bob)
	config.set_value("ui", "locale", "en")
	assert_eq(config.save(SETTINGS_PATH), OK, "write temporary settings")


func _motion() -> InputEventMouseMotion:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.relative = Vector2(10, 5)
	return event


func test_pause_signal_disables_look_and_resume_restores_it() -> void:
	assert_true(player._mouse_captured, "capture requested at startup")
	for cycle: int in 2:
		tree.paused = true
		EventBus.game_paused.emit(true)
		assert_false(player._mouse_captured, "pause releases capture even in a paused tree")
		assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE, "pointer released")
		var yaw: float = player.rotation.y
		var pitch: float = player.head.rotation.x
		player._unhandled_input(_motion())
		assert_eq(player.rotation.y, yaw, "paused mouse does not rotate body")
		assert_eq(player.head.rotation.x, pitch, "paused mouse does not rotate head")
		tree.paused = false
		EventBus.game_paused.emit(false)
		assert_true(player._mouse_captured, "resume requests capture")
		if DisplayServer.get_name() != "headless":
			assert_eq(Input.mouse_mode, Input.MOUSE_MODE_CAPTURED, "OS capture restored")
		player._unhandled_input(_motion())
		assert_true(player.rotation.y < yaw, "look works again after resume")
		assert_true(player.head.rotation.x < pitch, "pitch works again after resume")


func test_pause_action_and_escape_do_not_change_capture() -> void:
	var action: InputEventAction = InputEventAction.new()
	action.action = &"pause"
	action.pressed = true
	var escape: InputEventKey = InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	for paused: bool in [false, true]:
		EventBus.game_paused.emit(paused)
		var mode: Input.MouseMode = Input.mouse_mode
		player._unhandled_input(action)
		player._unhandled_input(escape)
		assert_eq(player._mouse_captured, not paused, "Player leaves pause action to menu")
		assert_eq(Input.mouse_mode, mode, "Player does not toggle OS mouse mode for Esc")


func test_ready_loads_saved_values_without_writing_settings() -> void:
	_save(0.004, false)
	var original: PackedByteArray = FileAccess.get_file_as_bytes(SETTINGS_PATH)
	player.free()
	_spawn_player()
	assert_eq(player.mouse_sensitivity, 0.004, "saved sensitivity at ready")
	assert_false(player.head_bob_enabled, "saved bob at ready")
	assert_eq(FileAccess.get_file_as_bytes(SETTINGS_PATH), original, "Player only reads settings")


func test_settings_signals_update_only_the_matching_key_while_paused() -> void:
	tree.paused = true
	EventBus.game_paused.emit(true)
	_save(0.004, false)
	var original: PackedByteArray = FileAccess.get_file_as_bytes(SETTINGS_PATH)
	EventBus.settings_changed.emit("audio", "master_db")
	EventBus.settings_changed.emit("video", "mouse_sensitivity")
	EventBus.settings_changed.emit("input", "head_bob")
	assert_eq(player.mouse_sensitivity, 0.002, "ignore unrelated section/key pairs")
	assert_true(player.head_bob_enabled, "ignore unrelated settings")
	EventBus.settings_changed.emit("input", "mouse_sensitivity")
	assert_eq(player.mouse_sensitivity, 0.004, "sensitivity changes immediately while paused")
	assert_true(player.head_bob_enabled, "only announced key is reloaded")
	player.camera.position.y = 0.018
	EventBus.settings_changed.emit("video", "head_bob")
	assert_false(player.head_bob_enabled, "bob disabled immediately while paused")
	assert_eq(player.camera.position.y, 0.0, "camera offset clears without a physics tick")
	assert_eq(FileAccess.get_file_as_bytes(SETTINGS_PATH), original, "live reload never writes settings")
	tree.paused = false
	EventBus.game_paused.emit(false)
	player._unhandled_input(_motion())
	assert_true(is_equal_approx(player.rotation.y, -0.04), "new sensitivity changes actual yaw")
	assert_true(is_equal_approx(player.head.rotation.x, -0.02), "new sensitivity changes actual pitch")
	_save(0.004, true)
	EventBus.settings_changed.emit("video", "head_bob")
	assert_true(player.head_bob_enabled, "bob can be enabled again")


func test_missing_file_and_missing_keys_use_contract_defaults() -> void:
	assert_eq(DirAccess.remove_absolute(SETTINGS_PATH), OK)
	player.free()
	_spawn_player()
	assert_eq(player.mouse_sensitivity, 0.002, "missing file sensitivity default")
	assert_true(player.head_bob_enabled, "missing file bob default")
	assert_false(FileAccess.file_exists(SETTINGS_PATH), "Player does not create missing file")
	_save(0.005, false)
	EventBus.settings_changed.emit("input", "mouse_sensitivity")
	EventBus.settings_changed.emit("video", "head_bob")
	assert_eq(ConfigFile.new().save(SETTINGS_PATH), OK)
	EventBus.settings_changed.emit("input", "mouse_sensitivity")
	EventBus.settings_changed.emit("video", "head_bob")
	assert_eq(player.mouse_sensitivity, 0.002, "missing key resets previous sensitivity")
	assert_true(player.head_bob_enabled, "missing key resets previous bob setting")
	assert_eq(DirAccess.remove_absolute(SETTINGS_PATH), OK)
	EventBus.settings_changed.emit("input", "mouse_sensitivity")
	EventBus.settings_changed.emit("video", "head_bob")
	assert_false(FileAccess.file_exists(SETTINGS_PATH), "reload does not create missing file")


func test_invalid_settings_fall_back_instead_of_clamping_or_coercing() -> void:
	for value: Variant in ["0.004", true, 1, 0.0004, 0.0061, -0.002, INF, -INF, NAN]:
		_save(0.004, false)
		EventBus.settings_changed.emit("input", "mouse_sensitivity")
		_save(value, false)
		EventBus.settings_changed.emit("input", "mouse_sensitivity")
		assert_eq(player.mouse_sensitivity, 0.002, "invalid sensitivity defaults: %s" % str(value))
	for value: Variant in ["false", 0, 1, 0.0, [], {}]:
		_save(0.004, false)
		EventBus.settings_changed.emit("video", "head_bob")
		_save(0.004, value)
		EventBus.settings_changed.emit("video", "head_bob")
		assert_true(player.head_bob_enabled, "invalid bob defaults: %s" % str(value))
	_save("invalid", "invalid")
	player.free()
	_spawn_player()
	assert_eq(player.mouse_sensitivity, 0.002, "startup uses same validation")
	assert_true(player.head_bob_enabled, "startup invalid bob defaults")


func test_sensitivity_accepts_both_inclusive_bounds() -> void:
	for sensitivity: float in [0.0005, 0.006]:
		_save(sensitivity, true)
		EventBus.settings_changed.emit("input", "mouse_sensitivity")
		assert_eq(player.mouse_sensitivity, sensitivity, "inclusive contract bound")


func test_freed_player_leaves_no_signal_connections() -> void:
	var pause_count: int = EventBus.game_paused.get_connections().size()
	var settings_count: int = EventBus.settings_changed.get_connections().size()
	player.free()
	assert_eq(EventBus.game_paused.get_connections().size(), pause_count - 1, "pause listener freed")
	assert_eq(EventBus.settings_changed.get_connections().size(), settings_count - 1, "settings listener freed")
	EventBus.game_paused.emit(true)
	EventBus.settings_changed.emit("input", "mouse_sensitivity")
	_spawn_player()
