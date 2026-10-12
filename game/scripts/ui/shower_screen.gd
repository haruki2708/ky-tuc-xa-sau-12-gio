extends Node3D
## Mount at the room's ShowerScreen anchor. Gameplay buttons belong to lane A.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
var temperatures: Array[int] = []
var minutes_counted := 0
var _remaining := 0.0
var _duration := 8.0
var _choosing := false
var _selected := -1
var _fog := 0.0


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.albedo_texture = get_texture()
	$Display.material_override = material
	var content := Layout.card($Viewport/Root, Rect2(0.035, 0.035, 0.93, 0.93))
	content.add_theme_constant_override("separation", 6)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.54, 0.62, 0.43)
	paper.content_margin_left = 20
	paper.content_margin_right = 20
	paper.content_margin_top = 12
	paper.content_margin_bottom = 12
	$Viewport/Root/Card.add_theme_stylebox_override("panel", paper)
	for spec in [["Title", "UI_SHOWER_TITLE", 24], ["Rule", "UI_SHOWER_RULE", 24], ["Countdown", "", 26], ["Choice", "", 32], ["Temperature", "", 32]]:
		_lcd_label(content, spec[0], spec[1], spec[2])
	var timer := ProgressBar.new()
	timer.name = "Timer"
	timer.show_percentage = false
	timer.custom_minimum_size.y = 12
	content.add_child(timer)
	_lcd_label(content, "HistoryTitle", "UI_SHOWER_HISTORY", 24)
	var scroll := ScrollContainer.new()
	scroll.name = "HistoryScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var grid := GridContainer.new()
	grid.name = "History"
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 5)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	_lcd_label(content, "ProgressText", "", 24)
	var progress := ProgressBar.new()
	progress.name = "Progress"
	progress.max_value = 25.0
	progress.show_percentage = false
	progress.custom_minimum_size.y = 22
	content.add_child(progress)
	for bar: ProgressBar in [timer, progress]:
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.12, 0.19, 0.11)
		bar.add_theme_stylebox_override("fill", fill)
		var background := StyleBoxFlat.new()
		background.bg_color = Color(0.42, 0.49, 0.33)
		bar.add_theme_stylebox_override("background", background)
	var condensation := ColorRect.new()
	condensation.name = "Condensation"
	condensation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Viewport/Root.add_child(condensation)
	condensation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fog_material := ShaderMaterial.new()
	fog_material.shader = preload("res://ui/shower/steam.gdshader")
	fog_material.set_shader_parameter("screen_surface", true)
	condensation.material = fog_material
	EventBus.shower_choice_requested.connect(_request)
	EventBus.shower_choice_made.connect(_on_choice)
	EventBus.shower_slot_finished.connect(_on_slot)
	EventBus.shower_steam_changed.connect(_on_steam)
	EventBus.player_death_started.connect(func(_kind: StringName) -> void:
		_choosing = false
		_refresh())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: reset_display())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: reset_display())
	_refresh()


func _lcd_label(parent: Node, node_name: String, key: String, font_size: int) -> Label:
	var label := Layout.label(parent, node_name, key, font_size)
	label.add_theme_color_override("font_color", Color(0.09, 0.14, 0.07))
	label.add_theme_constant_override("outline_size", 0)
	return label


func get_texture() -> Texture2D:
	return $Viewport.get_texture()


func _request(seconds: float) -> void:
	if not is_finite(seconds) or seconds <= 0.0:
		return
	_duration = seconds
	_remaining = seconds
	_choosing = true
	_selected = -1
	_refresh()


func _on_choice(run_water: bool) -> void:
	if not _choosing:
		return
	_choosing = false
	_selected = 1 if run_water else 0
	_refresh()


func _on_slot(temperature: int, _ran: bool, counted: int) -> void:
	_choosing = false
	temperatures.append(temperature)
	minutes_counted = maxi(0, counted)
	var cell := _lcd_label($Viewport/Root/Card/Content/HistoryScroll/History, "Slot%d" % temperatures.size(), "", 24)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refresh()


func _on_steam(level: float) -> void:
	if not is_finite(level):
		return
	_fog = clampf(level, 0.0, 1.0)
	$Viewport/Root/Condensation.material.set_shader_parameter("level", _fog)


func wipe() -> void:
	# Clear the glass only; the next steam event can fog it again.
	_on_steam(0.0)


func reset_display() -> void:
	temperatures.clear()
	minutes_counted = 0
	_remaining = 0.0
	_choosing = false
	_selected = -1
	for child in $Viewport/Root/Card/Content/HistoryScroll/History.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	wipe()
	_refresh()


func _process(delta: float) -> void:
	if _choosing and not get_tree().paused:
		_remaining = maxf(0.0, _remaining - delta)
		if _remaining <= 0.0:
			_choosing = false # No timeout choice: core owns DEATH_NO_CHOICE.
		_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	var content := $Viewport/Root/Card/Content
	content.get_node("Countdown").text = tr("UI_SHOWER_COUNTDOWN") % ceili(_remaining) if _choosing else tr("UI_SHOWER_WAITING")
	content.get_node("Choice").text = tr("UI_SHOWER_OPTIONS") if _selected < 0 else tr("UI_SHOWER_SELECTED") % tr("UI_SHOWER_YES" if _selected == 1 else "UI_SHOWER_NO")
	content.get_node("Timer").max_value = _duration
	content.get_node("Timer").value = _remaining if _choosing else 0.0
	content.get_node("Temperature").text = tr("UI_SHOWER_TEMPERATURE") % temperatures.back() if not temperatures.is_empty() else tr("UI_SHOWER_TEMPERATURE_UNKNOWN")
	content.get_node("ProgressText").text = tr("UI_SHOWER_PROGRESS") % minutes_counted
	content.get_node("Progress").value = minf(minutes_counted, 25.0)
	var cells := content.get_node("HistoryScroll/History")
	for index in temperatures.size():
		cells.get_child(index).text = tr("UI_SHOWER_HISTORY_CELL") % [index + 1, temperatures[index]]


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()
