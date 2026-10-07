extends Control
## Original low-poly silhouettes used only during the scripted body fade.


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var outline := PackedVector2Array([Vector2(0.13, 1.0), Vector2(0.19, 0.84),
		Vector2(0.20, 0.72), Vector2(0.22, 0.66), Vector2(0.24, 0.67), Vector2(0.23, 0.80),
		Vector2(0.26, 0.70), Vector2(0.28, 0.65), Vector2(0.30, 0.66), Vector2(0.27, 0.81),
		Vector2(0.31, 0.74), Vector2(0.33, 0.74), Vector2(0.31, 0.84),
		Vector2(0.34, 0.80), Vector2(0.36, 0.81), Vector2(0.32, 0.91), Vector2(0.24, 1.0)])
	for mirror in [false, true]:
		var points := PackedVector2Array()
		for point in outline:
			points.append(Vector2(1.0 - point.x if mirror else point.x, point.y) * size)
		draw_colored_polygon(points, Color("827b74"))
		draw_polyline(points, Color("bbb8ad"), 2.0, true)
