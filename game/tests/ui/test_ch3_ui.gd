extends TestCase

const STATUS = preload("res://ui/ch3/ch3_status.tscn")
const BLOOD = preload("res://ui/death/blood_overlay.tscn")
const END = preload("res://ui/ch3/ch3_end_card.tscn")
var host: Node
var _locale: String
var _mouse: Input.MouseMode
var _reduced: bool


func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_mouse = Input.mouse_mode
	_reduced = Settings.get_value("accessibility", "reduce_scares")
	Settings.set_value("accessibility", "reduce_scares", false)
	tree.paused = false
	host = Node.new()
	tree.root.add_child(host)


func after_each() -> void:
	host.queue_free()
	await wait_frames(2)
	tree.paused = false
	Settings.set_value("accessibility", "reduce_scares", _reduced)
	TranslationServer.set_locale(_locale)
	Input.mouse_mode = _mouse
	Input.action_release("move_forward")


func _mount(scene: PackedScene) -> Node:
	var node := scene.instantiate()
	host.add_child(node)
	node.set_process(false)
	return node


func _guard() -> Node3D:
	var node := Node3D.new()
	host.add_child(node)
	return node


func test_stamina_threshold_exhaustion_recovery_invalid_input_and_reduced() -> void:
	var status := _mount(STATUS)
	var rim := status.get_node("Root/Stamina")
	assert_false(rim.visible)
	EventBus.stamina_changed.emit(0.6, false)
	assert_false(rim.visible)
	EventBus.stamina_changed.emit(0.3, false)
	assert_true(rim.visible)
	assert_true(is_equal_approx(rim.material.get_shader_parameter("strength"), 0.5))
	EventBus.stamina_changed.emit(NAN, true)
	assert_false(status._exhausted)
	EventBus.stamina_changed.emit(0.0, true)
	assert_eq(rim.material.get_shader_parameter("strength"), 1.0)
	assert_true(rim.material.get_shader_parameter("exhausted"))
	Settings.set_value("accessibility", "reduce_scares", true)
	assert_true(rim.material.get_shader_parameter("reduced"))
	EventBus.stamina_changed.emit(1.0, false)
	assert_false(rim.visible)
	assert_eq(status.find_children("*", "Label", true, false).size(), 0, "no numeric stamina labels")


func test_bar_has_five_bends_authoritative_hits_and_single_break_animation() -> void:
	var status := _mount(STATUS)
	var icon := status.get_node("Root/BarIcon")
	assert_false(icon.visible)
	EventBus.bar_picked.emit(8)
	assert_true(icon.visible)
	var hits := [8, 6, 4, 2, 1]
	for index in hits.size():
		EventBus.bar_swung.emit(true, hits[index])
		assert_eq(icon.bend_stage, index)
	EventBus.bar_swung.emit(false, 1)
	assert_eq(icon.bend_stage, 4, "miss does not consume a hit")
	EventBus.bar_swung.emit(true, 0)
	icon.advance(0.2)
	EventBus.bar_broken.emit()
	assert_true(is_equal_approx(icon.break_elapsed, 0.2), "duplicate break must not restart animation")
	assert_true(icon.visible)
	assert_true(icon.breaking)
	icon.advance(0.5)
	assert_false(icon.visible)
	EventBus.bar_picked.emit(2)
	assert_eq(icon.bend_stage, 3, "picking a damaged bar uses supplied durability")
	EventBus.bar_broken.emit()
	EventBus.bar_picked.emit(8)
	assert_false(icon.breaking)
	assert_eq(icon.bend_stage, 0)


func test_guard_warnings_overlap_and_freed_guards_do_not_leave_static() -> void:
	var status := _mount(STATUS)
	var first := _guard()
	var second := _guard()
	EventBus.guard_warned.emit(first, true)
	EventBus.guard_warned.emit(second, true)
	EventBus.guard_warned.emit(first, false)
	assert_true(status.get_node("Root/GuardWarning").visible)
	second.free()
	status._process(0.1)
	assert_false(status.get_node("Root/GuardWarning").visible)
	EventBus.guard_warned.emit(first, true)
	Settings.set_value("accessibility", "reduce_scares", true)
	assert_true(status.get_node("Root/GuardWarning").material.get_shader_parameter("reduced"))
	EventBus.guard_warned.emit(first, false)
	assert_false(status.get_node("Root/GuardWarning").visible)


func test_status_pause_lifecycle_and_chapter_one_two_do_not_keep_effects() -> void:
	var status := _mount(STATUS)
	EventBus.stamina_changed.emit(0.0, true)
	EventBus.bar_picked.emit(8)
	tree.paused = true
	status._process(4.0)
	assert_eq(status._elapsed, 0.0)
	assert_false(status.get_node("Root").visible)
	tree.paused = false
	status._process(0.1)
	assert_true(status.get_node("Root").visible)
	EventBus.player_death_started.emit(&"zombie_grab")
	EventBus.stamina_changed.emit(0.0, true)
	EventBus.bar_picked.emit(8)
	assert_false(status.get_node("Root").visible)
	EventBus.checkpoint_loaded.emit(&"ch3_b")
	assert_false(status.get_node("Root/Stamina").visible)
	assert_false(status.get_node("Root/BarIcon").visible)
	for chapter in [1, 2]:
		EventBus.chapter_started.emit(chapter)
		EventBus.stamina_changed.emit(0.0, true)
		assert_false(status.get_node("Root").visible)
	EventBus.chapter_started.emit(3)
	EventBus.stamina_changed.emit(0.0, true)
	assert_true(status.get_node("Root/Stamina").visible)
	EventBus.chapter_finished.emit(3)
	assert_false(status.get_node("Root").visible)


func test_death_modes_live_reduction_pause_and_checkpoint_cleanup() -> void:
	var blood := _mount(BLOOD)
	var root := blood.get_node("Root")
	EventBus.player_death_started.emit(&"zombie_grab")
	assert_true(root.visible)
	assert_true(root.material.get_shader_parameter("splash"))
	assert_true(root.material.get_shader_parameter("handprints"))
	blood._process(0.5)
	EventBus.player_death_started.emit(&"guard_shock")
	assert_eq(blood._elapsed, 0.0)
	assert_false(root.material.get_shader_parameter("handprints"))
	assert_true(root.material.get_shader_parameter("guard_shock"))
	Settings.set_value("accessibility", "reduce_scares", true)
	assert_true(root.material.get_shader_parameter("reduced"))
	assert_eq(root.position, Vector2.ZERO)
	tree.paused = true
	blood._process(2.0)
	assert_eq(blood._elapsed, 0.0)
	tree.paused = false
	blood._process(1.5)
	assert_true(blood._elapsed >= 1.2, "shock reaches its dark phase")
	EventBus.checkpoint_loaded.emit(&"ch3_gate")
	assert_false(root.visible)
	EventBus.player_death_started.emit(&"manager_kill")
	assert_false(root.material.get_shader_parameter("guard_shock"))
	assert_false(root.material.get_shader_parameter("handprints"))


func test_end_card_only_chapter_three_translates_and_does_not_unlock_progress() -> void:
	var card := _mount(END)
	var unlocked := Progress.unlocked_chapter()
	EventBus.chapter_finished.emit(2)
	assert_false(card.get_node("Root").visible)
	EventBus.chapter_finished.emit(3)
	assert_true(card.get_node("Root").visible)
	assert_false(card.get_node("Root/Center").visible)
	card._process(1.0)
	EventBus.chapter_finished.emit(3)
	assert_eq(card._elapsed, 1.0, "duplicate completion does not restart fade")
	card._process(1.0)
	assert_true(card.get_node("Root/Center").visible)
	var title := card.get_node("Root/Center/Lines/Title")
	TranslationServer.set_locale("vi")
	assert_eq(title.tr(title.text), "Hết chương 3")
	TranslationServer.set_locale("en")
	assert_eq(title.tr(title.text), "End of chapter 3")
	assert_eq(Progress.unlocked_chapter(), unlocked)
	assert_false(tree.paused)
	assert_eq(Input.mouse_mode, _mouse)
	EventBus.chapter_started.emit(3)
	assert_false(card.get_node("Root").visible)


func test_ch3_death_reasons_use_core_translation_keys_without_local_story() -> void:
	# Core's script (T-181) supplies the text; the death screen shows tr(key).
	TranslationServer.set_locale("vi")
	var death := _mount(load("res://ui/death/death_screen.tscn"))
	for key: StringName in [&"DEATH_CH3_GRABBED", &"DEATH_CH3_GUARD"]:
		assert_true(tr(key) != String(key), "core text for " + key)
		EventBus.player_failed.emit(key)
		assert_eq(death.get_node("Root/Card/Content/Reason").text, tr(key))
		EventBus.checkpoint_loaded.emit(&"ch3_b")


func test_status_is_passive_and_all_controls_ignore_mouse() -> void:
	var status := _mount(STATUS)
	EventBus.stamina_changed.emit(0.2, false)
	Input.action_press("move_forward")
	status._process(0.1)
	for control: Control in status.find_children("*", "Control", true, false):
		assert_eq(control.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_true(Input.is_action_pressed("move_forward"))
	assert_eq(Input.mouse_mode, _mouse)
	assert_false(tree.paused)
