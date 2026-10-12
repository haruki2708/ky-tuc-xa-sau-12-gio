extends PanelContainer
## Photographed fibres with restrained print, fold and binding details.

const PAPER_TEXTURE = preload("res://ui/theme/textures/paper001_color.jpg")
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
	box.bg_color = _paper_tint
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
