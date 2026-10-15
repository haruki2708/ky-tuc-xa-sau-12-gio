extends TestCase

const DOCUMENT = preload("res://ui/document/document_view.tscn")
const PAPER_SURFACE = preload("res://scripts/ui/paper_surface.gd")

var _host: Node
var _sub_viewport: SubViewport
var _document: CanvasLayer
var _locale: String
var _mouse_mode: Input.MouseMode
var _paused: bool


func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_mouse_mode = Input.mouse_mode
	_paused = tree.paused
	TranslationServer.set_locale("vi")
	assert_true(RuleSystem.load_rule_set(load("res://data/rules/demo.tres")).is_empty())
	_host = Node.new()
	tree.root.add_child(_host)
	_sub_viewport = SubViewport.new()
	_sub_viewport.size = Vector2i(1280, 720)
	_host.add_child(_sub_viewport)
	_document = DOCUMENT.instantiate()
	_sub_viewport.add_child(_document)
	await wait_frames(2)


func after_each() -> void:
	_host.queue_free()
	await wait_frames(2)
	RuleSystem.reset()
	TranslationServer.set_locale(_locale)
	Input.mouse_mode = _mouse_mode
	tree.paused = _paused


func test_photo_and_photo_family_looks_show_texture_and_handwritten_back() -> void:
	# 1. ch1_team_photo (look = photo)
	EventBus.document_opened.emit(&"ch1_team_photo")
	await wait_frames(2)
	assert_true(_document.is_open())
	assert_false(_document.get_node("Root/Paper").visible, "paper hidden for photo look")
	var photo_frame: Control = _document.get_node("Root/PhotoFrame")
	assert_true(photo_frame.visible, "photo frame visible for photo look")
	assert_false(_document.get_node("Root/CardFrame").visible, "card frame hidden for photo look")

	var photo_rect: TextureRect = _document.get_node("Root/PhotoFrame/PhotoCard/PhotoTexture")
	assert_not_null(photo_rect.texture)
	assert_eq(photo_rect.texture.resource_path, "res://assets/textures/papers/photo.png")

	var title: Label = _document.get_node("Root/PhotoFrame/BackPaper/BackContent/BackTitle")
	assert_true(title.visible)
	assert_eq(title.text, tr("DOC_CH1_TEAM_PHOTO_TITLE"))

	var back_lines: VBoxContainer = _document.get_node("Root/PhotoFrame/BackPaper/BackContent/BackScroll/BackLines")
	assert_eq(back_lines.get_child_count(), 2)
	assert_eq(back_lines.get_child(0).text, tr("DOC_CH1_TEAM_PHOTO_1"))
	assert_eq(back_lines.get_child(1).text, tr("DOC_CH1_TEAM_PHOTO_2"))

	var viewport_rect := Rect2(Vector2.ZERO, Vector2(1280, 720))
	var frame_rect := photo_frame.get_global_rect()
	assert_true(viewport_rect.encloses(frame_rect), "photo frame within 1280x720")
	_document.close_view()
	await wait_frames(2)

	# 2. ch1_viet_photo (look = photo_family)
	EventBus.document_opened.emit(&"ch1_viet_photo")
	await wait_frames(2)
	assert_true(_document.is_open())
	assert_false(_document.get_node("Root/Paper").visible)
	assert_true(photo_frame.visible)
	assert_eq(photo_rect.texture.resource_path, "res://assets/textures/papers/photo_family.png")
	assert_eq(title.text, tr("DOC_CH1_VIET_PHOTO_TITLE"))
	assert_eq(back_lines.get_child_count(), 1)
	assert_eq(back_lines.get_child(0).text, tr("DOC_CH1_VIET_PHOTO_1"))
	assert_true(viewport_rect.encloses(photo_frame.get_global_rect()), "family photo frame within 1280x720")
	_document.close_view()


func test_card_look_shows_student_card_proportions_and_details() -> void:
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(1280, 720))
	for card_id: StringName in [&"ch1_dat_card", &"ch1_phuc_card", &"ch1_viet_card"]:
		EventBus.document_opened.emit(card_id)
		await wait_frames(2)
		assert_true(_document.is_open())
		assert_false(_document.get_node("Root/Paper").visible, "paper hidden for card look")
		assert_false(_document.get_node("Root/PhotoFrame").visible, "photo frame hidden for card look")

		var card_frame: Control = _document.get_node("Root/CardFrame")
		assert_true(card_frame.visible, "card frame visible for card look")

		var data := DocumentData.load_by_id(card_id)
		var card_title: Label = _document.get_node("Root/CardFrame/CardContent/CardHeader/CardTitle")
		assert_eq(card_title.text, tr(data.title_key))

		var details: VBoxContainer = _document.get_node("Root/CardFrame/CardContent/CardBody/CardColumns/CardDetails")
		assert_eq(details.get_child_count(), data.text_keys.size())
		for index in data.text_keys.size():
			assert_eq(details.get_child(index).text, tr(data.text_keys[index]))

		var stamp: Label = _document.get_node("Root/CardFrame/CardContent/CardBody/CardStamp")
		assert_eq(stamp.visible, data.style == &"stamped")
		assert_eq(stamp.text, tr("UI_DOCUMENT_STAMP"))

		var card_rect := card_frame.get_global_rect()
		assert_true(viewport_rect.encloses(card_rect), "card frame fits in 1280x720")
		var ratio := card_rect.size.x / card_rect.size.y
		assert_true(ratio >= 1.5 and ratio <= 1.65, "card ratio ~ 85.6x54 (is %.3f)" % ratio)
		_document.close_view()
		await wait_frames(2)


func test_empty_look_retains_legacy_paper_styles() -> void:
	for id: StringName in [&"hall_board", &"room_paper_407", &"hall_board_note", &"washroom_notice"]:
		var data := DocumentData.load_by_id(id)
		EventBus.document_opened.emit(id)
		await wait_frames(2)
		assert_true(_document.is_open())

		var paper: PanelContainer = _document.get_node("Root/Paper")
		assert_true(paper.visible, "paper visible for empty look")
		assert_false(_document.get_node("Root/PhotoFrame").visible, "photo hidden for empty look")
		assert_false(_document.get_node("Root/CardFrame").visible, "card hidden for empty look")
		assert_eq(paper.paper_style, data.style)

		var title: Label = _document.get_node("Root/Paper/Content/Title")
		assert_eq(title.visible, not data.title_key.is_empty())
		if title.visible:
			assert_eq(title.text, tr(data.title_key))

		var lines: VBoxContainer = _document.get_node("Root/Paper/Content/Scroll/Lines")
		assert_eq(lines.get_child_count(), data.rule_ids.size() + data.text_keys.size())
		_document.close_view()
		await wait_frames(2)


func test_all_looks_fit_in_720p_and_translate_cleanly() -> void:
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(1280, 720))
	for locale in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		# Photo look in locale
		EventBus.document_opened.emit(&"ch1_team_photo")
		await wait_frames(2)
		var photo_frame: Control = _document.get_node("Root/PhotoFrame")
		assert_true(viewport_rect.encloses(photo_frame.get_global_rect()))
		var photo_lines: VBoxContainer = _document.get_node("Root/PhotoFrame/BackPaper/BackContent/BackScroll/BackLines")
		for child in photo_lines.get_children():
			assert_true(child is Label)
			assert_false(child.text.is_empty())
		_document.close_view()
		await wait_frames(2)

		# Card look in locale
		EventBus.document_opened.emit(&"ch1_viet_card")
		await wait_frames(2)
		var card_frame: Control = _document.get_node("Root/CardFrame")
		assert_true(viewport_rect.encloses(card_frame.get_global_rect()))
		var card_lines: VBoxContainer = _document.get_node("Root/CardFrame/CardContent/CardBody/CardColumns/CardDetails")
		for child in card_lines.get_children():
			assert_true(child is Label)
			assert_false(child.text.is_empty())

		# Stamp text bounds check for vi and en
		var stamp: Label = _document.get_node("Root/CardFrame/CardContent/CardBody/CardStamp")
		assert_true(stamp.visible, "card stamp visible")
		var stamp_size := stamp.size
		assert_true(stamp_size.x >= 120.0 and stamp_size.y >= 120.0, "stamp size at least 120x120")
		assert_true(stamp.get_minimum_size().x <= stamp_size.x, "stamp minimum width fits inside stamp size")
		var font: Font = stamp.get_theme_font(&"font")
		var font_size: int = stamp.get_theme_font_size(&"font_size")
		var inner_radius: float = stamp.get_inner_radius() if stamp.has_method("get_inner_radius") else (minf(stamp_size.x, stamp_size.y) * 0.5 - 10.0)

		var style: StyleBox = stamp.get_theme_stylebox(&"normal")
		var text_width_limit: float = stamp.size.x
		if style != null:
			text_width_limit -= (style.content_margin_left + style.content_margin_right)
		var text_box := font.get_multiline_string_size(stamp.text, HORIZONTAL_ALIGNMENT_CENTER, text_width_limit, font_size)
		var half_w := text_box.x * 0.5
		var half_h := text_box.y * 0.5
		var corner_dist_sq := half_w * half_w + half_h * half_h
		var max_radius_sq := inner_radius * inner_radius
		assert_true(
			corner_dist_sq <= max_radius_sq,
			"Stamp text box (%.1f x %.1f) corner distance sq (%.1f) must be <= inner_radius^2 (%.1f) in locale %s" % [
				text_box.x, text_box.y, corner_dist_sq, max_radius_sq, locale
			]
		)

		_document.close_view()
		await wait_frames(2)


func test_card_silhouette_stays_inside_photo_rect() -> void:
	var photo_rect: Rect2 = PAPER_SURFACE.CARD_PHOTO_RECT
	var head_center: Vector2 = PAPER_SURFACE.CARD_HEAD_CENTER
	var head_radius: float = PAPER_SURFACE.CARD_HEAD_RADIUS
	var head_rect := Rect2(head_center - Vector2(head_radius, head_radius), Vector2(head_radius * 2.0, head_radius * 2.0))
	assert_true(photo_rect.encloses(head_rect), "Card silhouette head must be strictly inside CARD_PHOTO_RECT")
	assert_true(PAPER_SURFACE.CARD_BODY_POLYGON.size() >= 3, "Card body polygon must have at least 3 vertices")
	for pt: Vector2 in PAPER_SURFACE.CARD_BODY_POLYGON:
		assert_true(photo_rect.has_point(pt), "Card body point %s must be inside CARD_PHOTO_RECT" % str(pt))
