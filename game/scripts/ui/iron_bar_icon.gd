extends Control
## Five silhouettes; gameplay supplies remaining hits, never decremented here.

@export_range(1, 64) var max_hits := 8
var held := false
var bend_stage := 0
var breaking := false
var break_elapsed := 0.0
const BREAK_SECONDS := 0.65


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clear_icon()


func pick(hits_left: int) -> void:
	clear_icon()
	if hits_left > 0:
		held = true
		_set_hits(hits_left)
		show()


func swing(_hit: bool, hits_left: int) -> void:
	if not held:
		return
	if hits_left <= 0:
		break_bar()
	else:
		_set_hits(hits_left)


func _set_hits(hits_left: int) -> void:
	var wear := 1.0 - clampf(float(hits_left) / max_hits, 0.0, 1.0)
	bend_stage = mini(4, int(floor(wear * 5.0)))
	queue_redraw()


func break_bar() -> void:
	if not held or breaking:
		return
	held = false
	breaking = true
	break_elapsed = 0.0
	queue_redraw()


func advance(delta: float) -> void:
	if not breaking:
		return
	break_elapsed += delta
	if break_elapsed >= BREAK_SECONDS:
		clear_icon()
	queue_redraw()


func clear_icon() -> void:
	held = false
	breaking = false
	bend_stage = 0
	break_elapsed = 0.0
	hide()
	queue_redraw()


func _draw() -> void:
	if not held and not breaking:
		return
	var bend := float(bend_stage) * 6.0
	var alpha := 1.0 - clampf(break_elapsed / BREAK_SECONDS, 0.0, 1.0) if breaking else 1.0
	var points := PackedVector2Array([Vector2(12, 38), Vector2(45, 35), Vector2(70, 33 + bend * 0.4), Vector2(112, 30 + bend)])
	var pieces: Array[PackedVector2Array] = [points]
	if breaking:
		pieces = [PackedVector2Array([points[0], points[1], Vector2(58, 38)]),
			PackedVector2Array([Vector2(70, 49), points[2] + Vector2(9, 14), points[3] + Vector2(9, 14)])]
	for piece in pieces:
		draw_polyline(piece, Color(0.015, 0.018, 0.02, alpha * 0.9), 9.0, true)
		draw_polyline(piece, Color(0.58, 0.61, 0.61, alpha * 0.9), 5.0, true)
		draw_polyline(piece, Color(0.85, 0.86, 0.81, alpha * 0.7), 1.0, true)
