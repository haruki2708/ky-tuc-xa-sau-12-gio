extends PanelContainer
## Photographed fibres with restrained print, fold and binding details.

const PAPER_TEXTURE = preload("res://ui/theme/textures/paper001_color.jpg")
const CARD_PHOTO_RECT := Rect2(36, 78, 130, 170)
const CARD_HEAD_CENTER := Vector2(101, 134)
const CARD_HEAD_RADIUS := 24.0
const CARD_BODY_POLYGON: Array[Vector2] = [
	Vector2(48, 246),
	Vector2(48, 226),
	Vector2(53, 208),
	Vector2(64, 192),
	Vector2(79, 178),
	Vector2(101, 172),
	Vector2(123, 178),
	Vector2(138, 192),
	Vector2(149, 208),
	Vector2(154, 226),
	Vector2(154, 246),
]
@export var paper_style: StringName = &"photocopy"
var _paper_tint := Color("e7e5d9")


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_paper_style(paper_style)


func set_paper_style(value: StringName) -> void:
	paper_style = value
	var box := StyleBoxFlat.new()
	_paper_tint = Color("f3e9ce")
	if value == &"photocopy":
		_paper_tint = Color("e7e5d9")
	elif value == &"handwritten":
		_paper_tint = Color("eee4c7")
	elif value == &"log":
		_paper_tint = Color("e9dfbf")
	elif value == &"notebook":
		_paper_tint = Color("e9dfc2")
	elif value == &"photo_back":
		_paper_tint = Color("fbf8f0")
	elif value == &"card":
		_paper_tint = Color("f6f8fa")
	box.bg_color = _paper_tint
	if value == &"card":
		box.corner_radius_top_left = 12
		box.corner_radius_top_right = 12
		box.corner_radius_bottom_left = 12
		box.corner_radius_bottom_right = 12
		box.shadow_color = Color(0, 0, 0, 0.65)
		box.shadow_size = 26
		box.shadow_offset = Vector2(0, 14)
		box.content_margin_left = 24
		box.content_margin_right = 24
		box.content_margin_top = 0
		box.content_margin_bottom = 20
	elif value == &"photo_back":
		box.corner_radius_top_left = 2
		box.corner_radius_top_right = 2
		box.corner_radius_bottom_left = 2
		box.corner_radius_bottom_right = 2
		box.shadow_color = Color(0, 0, 0, 0.6)
		box.shadow_size = 20
		box.shadow_offset = Vector2(0, 10)
		box.content_margin_left = 32
		box.content_margin_right = 32
		box.content_margin_top = 28
		box.content_margin_bottom = 28
	else:
		box.shadow_color = Color(0, 0, 0, 0.65)
		box.shadow_size = 22
		box.shadow_offset = Vector2(0, 12)
		box.content_margin_left = 56
		box.content_margin_right = 56
		box.content_margin_top = 38
		box.content_margin_bottom = 38
	add_theme_stylebox_override("panel", box)
	queue_redraw()


func _draw() -> void:
	draw_texture_rect(PAPER_TEXTURE, Rect2(Vector2.ZERO, size), false, _paper_tint)
	# The edge and crease stay subtle enough for small text on top of the paper.
	if paper_style != &"card" and paper_style != &"photo_back":
		draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color(0.29, 0.24, 0.16, 0.26), false, 2.0)
		draw_line(Vector2(size.x * 0.51, 0), Vector2(size.x * 0.5, size.y), Color(0.35, 0.3, 0.2, 0.05), 3.0)
	if paper_style == &"notebook":
		draw_rect(Rect2(0, 0, 16, size.y), Color("31413a"))
		draw_line(Vector2(25, 0), Vector2(25, size.y), Color(0.3, 0.24, 0.15, 0.18), 2.0)
		for y in range(30, int(size.y), 46):
			draw_line(Vector2(5, y), Vector2(20, y), Color("adb4a2"), 2.0, true)
	if paper_style == &"handwritten" or paper_style == &"log":
		for y in range(28, int(size.y), 28):
			draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.25, 0.4, 0.55, 0.18))
		if paper_style == &"handwritten":
			for x in range(28, int(size.x), 28):
				draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.25, 0.4, 0.55, 0.12))
		else:
			draw_line(Vector2(38, 0), Vector2(38, size.y), Color(0.65, 0.15, 0.12, 0.25), 2)
	elif paper_style == &"photocopy":
		for i in 38:
			var x := fmod(float(i * 137 + 11), maxf(size.x, 1.0))
			var y := fmod(float(i * 79 + 37), maxf(size.y, 1.0))
			draw_circle(Vector2(x, y), 1.5 + i % 3, Color(0.18, 0.16, 0.12, 0.07))
	elif paper_style == &"notice":
		for x in [size.x * 0.16, size.x * 0.76]:
			draw_rect(Rect2(x, 4, 100, 24), Color(0.67, 0.57, 0.31, 0.45))
	elif paper_style == &"photo_back":
		for y in range(40, int(size.y), 44):
			draw_line(Vector2(16, y), Vector2(size.x - 16, y), Color(0.35, 0.3, 0.25, 0.05))
	elif paper_style == &"card":
		draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color(0.18, 0.24, 0.35, 0.2), false, 1.5)
		draw_rect(Rect2(0, 0, size.x, 54), Color("1b324f"))
		draw_line(Vector2(0, 54), Vector2(size.x, 54), Color("d4af37"), 2.0)
		draw_rect(CARD_PHOTO_RECT, Color(0.88, 0.91, 0.94))
		draw_colored_polygon(PackedVector2Array(CARD_BODY_POLYGON), Color(0.74, 0.8, 0.86))
		draw_circle(CARD_HEAD_CENTER, CARD_HEAD_RADIUS, Color(0.74, 0.8, 0.86))
		draw_rect(CARD_PHOTO_RECT, Color(0.65, 0.72, 0.8), false, 1.5)

