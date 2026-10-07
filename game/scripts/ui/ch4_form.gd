extends VBoxContainer
## Collected paper stays in the book. Character facts are supplied by core flags.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
const BEDS := [1, 2, 4]
@export var door_seconds := 90.0
var book_view: VBoxContainer
var scraps: Array[int] = []
var assembled := false
var door_fraction := 1.0
var shown_bed := 0
var signature := ""
var signed_elapsed := 0.0
var fields: VBoxContainer
var choices: HBoxContainer
var editor: VBoxContainer
var bite: Button
var name_label: Label


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	choices = HBoxContainer.new()
	choices.name = "Collected"
	add_child(choices)
	var scroll := ScrollContainer.new()
	scroll.name = "PaperScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var paper := PanelContainer.new()
	paper.name = "Paper"
	paper.set_script(preload("res://scripts/ui/paper_surface.gd"))
	paper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(paper)
	paper.set_paper_style(&"photocopy")
	fields = VBoxContainer.new()
	fields.name = "Fields"
	fields.add_theme_constant_override("separation", 18)
	paper.add_child(fields)
	bite = Layout.button(self, "Bite", "UI_CH4_BITE", _bite)
	editor = preload("res://scripts/ui/ch4_timed_entry.gd").new()
	editor.name = "BloodName"
	add_child(editor)
	editor.entry.add_theme_color_override("font_color", Color("b93232"))
	editor.submitted.connect(func(text: String) -> void: EventBus.blood_name_typed.emit(text))
	EventBus.bed_slat_flipped.connect(_scrap)
	EventBus.survivor_form_assembled.connect(_assemble)
	EventBus.blood_name_requested.connect(_request)
	EventBus.blood_name_closed.connect(_verdict)
	EventBus.door_damage_changed.connect(_door)
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: restore())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: restore())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: editor.close_request())
	EventBus.player_failed.connect(func(_reason: StringName) -> void: editor.close_request())
	EventBus.fade_message_requested.connect(func(_seconds: float) -> void:
		editor.close_request()
		book_view.book.close_view())
	restore()


func restore() -> void:
	editor.close_request()
	scraps.clear()
	for bed in BEDS:
		if bool(GameState.get_flag(StringName("ch4_ui_scrap_%d" % bed), false)):
			scraps.append(bed)
	assembled = bool(GameState.get_flag(&"ch4_form_ready", false))
	signature = str(GameState.get_flag(&"ch4_ui_signature", "")) if bool(GameState.get_flag(&"ch4_signed", false)) else ""
	signed_elapsed = 2.0
	door_fraction = clampf(float(GameState.get_flag(&"ch4_door_fraction", 1.0)), 0.0, 1.0)
	shown_bed = 0 if assembled or scraps.is_empty() else scraps[0]
	refresh()


func _scrap(bed: int) -> void:
	if GameState.chapter != 4 or bed not in BEDS:
		return
	if bed not in scraps:
		scraps.append(bed)
		GameState.set_flag(StringName("ch4_ui_scrap_%d" % bed), true)
	shown_bed = bed
	_open_paper()


func _assemble() -> void:
	if GameState.chapter != 4:
		return
	assembled = true
	shown_bed = 0
	_open_paper()


func _open_paper() -> void:
	book_view.book.open_notebook()
	book_view.select_tab(2)
	refresh()


func _show_paper(bed: int) -> void:
	shown_bed = bed
	refresh()


func refresh() -> void:
	if not is_node_ready():
		return
	for parent in [choices, fields]:
		for child in parent.get_children():
			parent.remove_child(child)
			child.queue_free()
	for bed in scraps:
		Layout.button(choices, "Scrap%d" % bed, tr("UI_CH4_FORM_SCRAP") % bed, _show_paper.bind(bed))
	if assembled:
		Layout.button(choices, "Form", "UI_CH4_FORM", _show_paper.bind(0))
	var has_paper := assembled or not scraps.is_empty()
	$PaperScroll.visible = has_paper
	name_label = null
	bite.visible = assembled and shown_bed == 0 and signature.is_empty() and not editor.active and door_fraction > 0.0
	if not has_paper:
		return
	_paper_line("Title", "UI_CH4_FORM_TITLE" if shown_bed == 0 else "UI_CH4_FORM_SCRAP_%d" % shown_bed, 32)
	var columns: Array[String] = ["SEX", "AGE", "DOB", "ROOM", "BUILDING"]
	if shown_bed == 1:
		columns = ["SEX", "AGE"]
	elif shown_bed == 2:
		columns = ["DOB", "ROOM"]
	elif shown_bed == 4:
		columns = ["BUILDING"]
	for column in columns:
		var key := StringName("ch4_form_" + column.to_lower())
		var value := str(GameState.get_flag(key, ""))
		if column == "ROOM":
			value = "407"
		elif column == "BUILDING":
			value = "B"
		_paper_line(column, tr("UI_CH4_FORM_" + column) + ":  " + tr(value), 27)
	if shown_bed in [0, 4]:
		_paper_line("NameHeading", "UI_CH4_FORM_NAME", 27)
		name_label = _paper_line("Signature", signature, 34)
		name_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		name_label.add_theme_color_override("font_color", Color("741e20"))
		name_label.custom_minimum_size.y = 52
		_update_signature()


func _paper_line(node_name: String, text: String, font_size: int) -> Label:
	var label := Layout.label(fields, node_name, text, font_size)
	label.add_theme_color_override("font_color", Color("38352e"))
	label.add_theme_color_override("font_shadow_color", Color(0.22, 0.15, 0.12, 0.23))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


func _bite() -> void:
	if not assembled or not signature.is_empty() or editor.active or door_fraction <= 0.0:
		return
	EventBus.blood_name_requested.emit(door_seconds * door_fraction)


func _request(seconds: float) -> void:
	if GameState.chapter != 4 or not assembled or not signature.is_empty() or not is_finite(seconds) or seconds <= 0.0:
		return
	_open_paper()
	shown_bed = 0
	editor.request(seconds)
	editor.duration = maxf(door_seconds, seconds)
	editor.refresh()
	refresh()


func _verdict(result: StringName) -> void:
	if not editor.active:
		return
	if result == &"wrong":
		editor.retry()
	elif result == &"accepted" and editor.waiting:
		signature = editor.last_text
		signed_elapsed = 0.0
		GameState.set_flag(&"ch4_ui_signature", signature)
		editor.close_request()
	elif result == &"timeout":
		editor.close_request()
	refresh()


func _door(id: StringName, fraction: float) -> void:
	if id != &"407" or not is_finite(fraction):
		return
	# Lane A reports accumulated damage, not remaining durability (T-195).
	door_fraction = 1.0 - clampf(fraction, 0.0, 1.0)
	if editor.active:
		editor.remaining = minf(editor.remaining, door_seconds * door_fraction)
		editor.refresh()
		if door_fraction <= 0.0:
			editor.close_request()
	refresh()


func _process(delta: float) -> void:
	editor.advance(delta)
	if not get_tree().paused:
		signed_elapsed += delta
	_update_signature()
	if not editor.active and assembled and signature.is_empty():
		bite.visible = shown_bed == 0 and door_fraction > 0.0


func _update_signature() -> void:
	if is_instance_valid(name_label):
		name_label.visible_ratio = clampf(signed_elapsed / 1.2, 0.0, 1.0)
