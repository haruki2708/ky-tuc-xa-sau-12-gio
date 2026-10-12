extends RefCounted
## Shared native controls for the chapter overlays.

static func label(parent: Node, node_name: String, key: String, size: int = 30) -> Label:
	var item := Label.new()
	item.name = node_name
	item.text = key
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item


static func button(parent: Node, node_name: String, key: String, callback: Callable) -> Button:
	var item := Button.new()
	item.name = node_name
	item.text = key
	item.pressed.connect(callback)
	parent.add_child(item)
	return item


static func card(root: Control, area: Rect2) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.name = "Card"
	root.add_child(panel)
	panel.anchor_left = area.position.x
	panel.anchor_top = area.position.y
	panel.anchor_right = area.end.x
	panel.anchor_bottom = area.end.y
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)
	return content


static func cinematic_style(panel: PanelContainer, warning: bool = false) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.02, 0.034, 0.03, 0.78)
	box.border_width_top = 2
	box.border_width_bottom = 1
	box.border_color = Color("8f5349") if warning else Color("788776")
	box.content_margin_left = 48
	box.content_margin_right = 48
	box.content_margin_top = 38
	box.content_margin_bottom = 38
	panel.add_theme_stylebox_override("panel", box)
