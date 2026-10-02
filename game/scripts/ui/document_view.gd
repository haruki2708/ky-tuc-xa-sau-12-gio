extends "res://scripts/ui/reading_overlay.gd"

var _document: DocumentData


func _ready() -> void:
	super._ready()
	EventBus.document_opened.connect(_on_document_opened)


func _on_document_opened(id: StringName) -> void:
	var document := DocumentData.load_by_id(id)
	if document != null:
		show_document(document)


func show_document(document: DocumentData) -> void:
	if document == null or not _begin_reading():
		return
	_document = document
	_render()
	$Root/Paper/Content/Scroll.scroll_vertical = 0


func _input(event: InputEvent) -> void:
	if not _open or event.is_echo():
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("pause") or event.is_action_pressed("notebook"):
		get_viewport().set_input_as_handled()
		close_view()


func close_view() -> void:
	if not _open:
		return
	var id := _document.id
	_document = null
	super.close_view()
	EventBus.document_closed.emit(id)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and _open:
		_render()


func _render() -> void:
	var paper: PanelContainer = $Root/Paper
	paper.set_paper_style(_document.style)
	var title: Label = $Root/Paper/Content/Title
	title.text = tr(_document.title_key) if not _document.title_key.is_empty() else ""
	title.visible = not title.text.is_empty()
	var lines: VBoxContainer = $Root/Paper/Content/Scroll/Lines
	for child in lines.get_children():
		lines.remove_child(child)
		child.queue_free()
	for index in _document.rule_ids.size():
		var rule := RuleSystem.get_rule(_document.rule_ids[index])
		if rule != null:
			_add_line(lines, "%d. %s" % [index + 1, tr(rule.text_key)])
	for key in _document.text_keys:
		_add_line(lines, tr(key))
	$Root/Paper/Content/Stamp.visible = _document.style == &"stamped"
	$Root/Paper/Content/Stamp.text = tr("UI_DOCUMENT_STAMP")


func _add_line(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color("24231f"))
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_font_size_override("font_size", 29)
	if _document.style == &"handwritten":
		var italic := FontVariation.new()
		italic.base_font = preload("res://assets/fonts/be_vietnam_pro_regular.ttf")
		italic.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.18, 1), Vector2.ZERO)
		label.add_theme_font_override("font", italic)
	elif _document.style == &"photocopy":
		label.add_theme_color_override("font_shadow_color", Color(0.15, 0.15, 0.13, 0.22))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
