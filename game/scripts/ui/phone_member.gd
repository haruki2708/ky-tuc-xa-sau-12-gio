extends HBoxContainer
## The avatar, status dot and strike remain legible without external art.

var member_id := ""
var state := "joined"


func configure(id: String, name_text: String, member_state: String) -> void:
	member_id = id
	state = member_state
	var avatar := ColorRect.new()
	avatar.custom_minimum_size = Vector2(24, 24)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.color = Color(0.12, 0.14, 0.16) if state == "dead" else Color(0.2, 0.52, 0.57)
	add_child(avatar)
	var label := Label.new()
	label.name = "Name"
	label.text = name_text
	label.add_theme_font_size_override("font_size", 21)
	label.modulate = Color(0.55, 0.55, 0.55) if state != "joined" else Color.WHITE
	add_child(label)
	var dot := Label.new()
	dot.text = "●"
	dot.modulate = Color(0.4, 0.42, 0.44) if state != "joined" else Color(0.35, 0.85, 0.58)
	add_child(dot)
	tooltip_text = tr("UI_PHONE_MEMBER_" + state.to_upper())
	if state == "dead":
		label.draw.connect(func() -> void:
			label.draw_line(Vector2(0, label.size.y * 0.52), Vector2(label.size.x, label.size.y * 0.52), Color.GRAY, 2.0))
