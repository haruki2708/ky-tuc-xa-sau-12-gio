extends Label


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - 4.0
	for inset in [0.0, 6.0]:
		draw_arc(center, radius - inset, 0, TAU, 96, Color("a63732"), 2.0, true)
