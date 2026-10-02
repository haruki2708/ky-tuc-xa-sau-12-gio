extends PanelContainer
## Procedural paper cues stay at full UI resolution; no external textures.

var paper_style: StringName = &"photocopy"


func set_paper_style(value: StringName) -> void:
	paper_style = value
	var box := StyleBoxFlat.new()
	box.bg_color = Color("f4f0e5")
	if value == &"photocopy":
		box.bg_color = Color("d5d3c9")
	elif value == &"handwritten":
		box.bg_color = Color("eee8ce")
	elif value == &"log":
		box.bg_color = Color("e9e2c9")
	box.content_margin_left = 56
	box.content_margin_right = 56
	box.content_margin_top = 38
	box.content_margin_bottom = 38
	add_theme_stylebox_override("panel", box)
	queue_redraw()


func _draw() -> void:
	if paper_style == &"handwritten" or paper_style == &"log":
		for y in range(28, int(size.y), 28):
			draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.25, 0.4, 0.55, 0.18))
		if paper_style == &"handwritten":
			for x in range(28, int(size.x), 28):
				draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.25, 0.4, 0.55, 0.12))
		else:
			draw_line(Vector2(38, 0), Vector2(38, size.y), Color(0.65, 0.15, 0.12, 0.35), 2)
	elif paper_style == &"photocopy":
		for i in 38:
			var x := fmod(float(i * 137 + 11), maxf(size.x, 1.0))
			var y := fmod(float(i * 79 + 37), maxf(size.y, 1.0))
			draw_circle(Vector2(x, y), 1.5 + i % 3, Color(0.18, 0.16, 0.12, 0.07))
	elif paper_style == &"notice":
		for x in [size.x * 0.16, size.x * 0.76]:
			draw_rect(Rect2(x, 4, 100, 24), Color(0.67, 0.57, 0.31, 0.45))
