extends "res://scripts/ui/reading_overlay.gd"

const PHOTO_TEXTURE = preload("res://assets/textures/papers/photo.png")
const PHOTO_FAMILY_TEXTURE = preload("res://assets/textures/papers/photo_family.png")

var _document: DocumentData
var _close_on_release := false


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
	_close_on_release = false
	_render()
	if has_node("Root/Paper/Content/Scroll"):
		$Root/Paper/Content/Scroll.scroll_vertical = 0
	if has_node("Root/PhotoFrame/BackPaper/BackContent/BackScroll"):
		$Root/PhotoFrame/BackPaper/BackContent/BackScroll.scroll_vertical = 0


func _input(event: InputEvent) -> void:
	if not _open or event.is_echo():
		return
	# Ignore the release of the press that opened the paper in player physics.
	# A new press while reading arms closure; release resumes gameplay safely.
	if event.is_action_pressed("interact"):
		_close_on_release = true
		get_viewport().set_input_as_handled()
	elif event.is_action_released("interact"):
		get_viewport().set_input_as_handled()
		if _close_on_release:
			close_view()
	elif event.is_action_pressed("pause") or event.is_action_pressed("notebook"):
		get_viewport().set_input_as_handled()
		close_view()


func close_view() -> void:
	if not _open:
		return
	var id := _document.id if _document != null else &""
	_document = null
	super.close_view()
	if not id.is_empty():
		EventBus.document_closed.emit(id)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and _open:
		_render()


func _render() -> void:
	if _document == null:
		return
	var look := _document.look
	if look == &"photo" or look == &"photo_family":
		_render_photo(look)
	elif look == &"card":
		_render_card()
	else:
		_render_paper()


func _render_paper() -> void:
	$Root/Paper.visible = true
	if has_node("Root/PhotoFrame"):
		$Root/PhotoFrame.visible = false
	if has_node("Root/CardFrame"):
		$Root/CardFrame.visible = false
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


func _render_photo(look: StringName) -> void:
	$Root/Paper.visible = false
	if has_node("Root/CardFrame"):
		$Root/CardFrame.visible = false
	if not has_node("Root/PhotoFrame"):
		return
	var photo_frame: Control = $Root/PhotoFrame
	photo_frame.visible = true
	var texture: Texture2D = PHOTO_FAMILY_TEXTURE if look == &"photo_family" else PHOTO_TEXTURE
	var photo_rect: TextureRect = $Root/PhotoFrame/PhotoCard/PhotoTexture
	photo_rect.texture = texture

	var back_title: Label = $Root/PhotoFrame/BackPaper/BackContent/BackTitle
	back_title.text = tr(_document.title_key) if not _document.title_key.is_empty() else ""
	back_title.visible = not back_title.text.is_empty()
	back_title.add_theme_font_override("font", preload("res://assets/fonts/be_vietnam_pro_semibold.ttf"))

	var back_lines: VBoxContainer = $Root/PhotoFrame/BackPaper/BackContent/BackScroll/BackLines
	for child in back_lines.get_children():
		back_lines.remove_child(child)
		child.queue_free()
	for key in _document.text_keys:
		_add_handwritten_line(back_lines, tr(key))


func _render_card() -> void:
	$Root/Paper.visible = false
	if has_node("Root/PhotoFrame"):
		$Root/PhotoFrame.visible = false
	if not has_node("Root/CardFrame"):
		return
	var card_frame: Control = $Root/CardFrame
	card_frame.visible = true

	var card_title: Label = $Root/CardFrame/CardContent/CardHeader/CardTitle
	card_title.text = tr(_document.title_key) if not _document.title_key.is_empty() else ""
	card_title.add_theme_font_override("font", preload("res://assets/fonts/be_vietnam_pro_semibold.ttf"))

	var details: VBoxContainer = $Root/CardFrame/CardContent/CardBody/CardColumns/CardDetails
	for child in details.get_children():
		details.remove_child(child)
		child.queue_free()
	for key in _document.text_keys:
		_add_card_line(details, tr(key))

	var stamp: Label = $Root/CardFrame/CardContent/CardBody/CardStamp
	stamp.visible = _document.style == &"stamped"
	stamp.text = tr("UI_DOCUMENT_STAMP")


func _add_line(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color("24231f"))
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_font_size_override("font_size", 29)
	label.add_theme_font_override("font", preload("res://assets/fonts/ibm_plex_mono_regular.ttf"))
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


func _add_handwritten_line(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color("1a2334"))
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_font_size_override("font_size", 24)
	var italic := FontVariation.new()
	italic.base_font = preload("res://assets/fonts/be_vietnam_pro_regular.ttf")
	italic.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.18, 1), Vector2.ZERO)
	label.add_theme_font_override("font", italic)
	parent.add_child(label)


func _add_card_line(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color("16202c"))
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_font_override("font", preload("res://assets/fonts/ibm_plex_mono_regular.ttf"))
	parent.add_child(label)
