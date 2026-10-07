extends VBoxContainer
## Chapter-four views share the existing book; verdicts and saved flags belong to core.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
const R5: Array[StringName] = [&"ch3_r5_1", &"ch3_r5_2", &"ch3_r5_3"]
var book: CanvasLayer
var tab := 0
var selected: StringName = &""
var matched: StringName = &""
var pending: StringName = &""
var feedback := ""
var compare: VBoxContainer
var forms: VBoxContainer
var tabs: HBoxContainer


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs = HBoxContainer.new()
	tabs.name = "Tabs"
	add_child(tabs)
	Layout.button(tabs, "Rules", "UI_RULEBOOK_TITLE", select_tab.bind(0))
	Layout.button(tabs, "Compare", "UI_CH4_COMPARE", select_tab.bind(1))
	Layout.button(tabs, "Documents", "UI_CH4_DOCUMENTS", select_tab.bind(2))
	var scroll := ScrollContainer.new()
	scroll.name = "CompareScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	compare = VBoxContainer.new()
	compare.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compare.add_theme_constant_override("separation", 22)
	scroll.add_child(compare)
	forms = preload("res://scripts/ui/ch4_form.gd").new()
	forms.name = "Forms"
	forms.book_view = self
	add_child(forms)
	EventBus.ch4_compare_result.connect(_result)
	EventBus.flag_changed.connect(func(_key: StringName, _value: Variant) -> void: refresh())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: reset_view())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: reset_view())
	reset_view()


func reset_view() -> void:
	tab = 0
	selected = &""
	pending = &""
	matched = StringName(str(GameState.get_flag(&"ch4_ui_marked_rule", "")))
	if matched not in R5:
		matched = &""
	feedback = "UI_CH4_NOTE_REDUNDANT" if not matched.is_empty() else ""
	refresh()


func compare_enabled() -> bool:
	return GameState.chapter == 4 and bool(GameState.get_flag(&"ch4_compare_enabled", false))


func select_tab(index: int) -> void:
	if index == 1 and not compare_enabled():
		return
	if GameState.chapter != 4:
		return
	tab = index
	refresh()
	announce_open()


func announce_open() -> void:
	if tab == 1 and compare_enabled() and book.is_open():
		EventBus.ch4_compare_opened.emit()


func refresh() -> void:
	if not is_node_ready():
		return
	visible = GameState.chapter == 4
	if not compare_enabled() and tab == 1:
		tab = 0
	tabs.get_node("Compare").visible = compare_enabled()
	book.get_node("Root/Book/Content/Scroll").visible = tab == 0 or not visible
	book.get_node("Root/Book/Content/Empty").visible = (tab == 0 or not visible) and RuleSystem.read_entries().is_empty()
	size_flags_vertical = Control.SIZE_EXPAND_FILL if tab != 0 else Control.SIZE_FILL
	$CompareScroll.visible = visible and tab == 1
	forms.visible = visible and tab == 2
	if tab == 1:
		_render_compare()
	forms.refresh()


func _render_compare() -> void:
	for child in compare.get_children():
		compare.remove_child(child)
		child.queue_free()
	for round_number in range(1, 6):
		var row := HBoxContainer.new()
		row.name = "Round%d" % round_number
		row.add_theme_constant_override("separation", 30)
		compare.add_child(row)
		var lines := VBoxContainer.new()
		lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lines.size_flags_stretch_ratio = 3.0
		row.add_child(lines)
		Layout.label(lines, "Heading", tr("UI_RULEBOOK_ROUND") % round_number, 28)
		for rule in comparison_rules():
			var rule_id: StringName = rule.id
			var rule_round: int = 1 if rule_id == &"ch1_general_3" else book._round_for({"text_key": rule.text_key, "source": rule.source})
			if rule_round != round_number:
				continue
			if round_number == 5 and rule_id in R5:
				var button := Layout.button(lines, String(rule_id), "", _select.bind(rule_id))
				button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				var label := RichTextLabel.new()
				label.fit_content = true
				label.mouse_filter = Control.MOUSE_FILTER_IGNORE
				label.add_theme_font_size_override("normal_font_size", 25)
				label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				label.offset_left = 16
				label.offset_top = 8
				label.offset_right = -16
				label.offset_bottom = -8
				button.add_child(label)
				if rule_id == matched or rule_id == pending:
					label.push_underline()
				label.add_text(tr(rule.text_key))
				if rule_id == matched or rule_id == pending:
					label.pop()
				# Native button text supplies sizing; child draws the underline.
				button.text = tr(rule.text_key)
				for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
					button.add_theme_color_override(color_name, Color.TRANSPARENT)
				button.modulate = Color("f4c6ad") if rule_id == selected else Color.WHITE
			else:
				Layout.label(lines, String(rule_id), rule.text_key, 25)
		if round_number in [2, 3, 4]:
			var key := str(GameState.get_flag(StringName("ch4_solved_r%d" % round_number), ""))
			var note := Layout.label(row, "Solved", tr(key) if not key.is_empty() else "", 24)
			note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if round_number == 5:
			var underline := Layout.button(lines, "Underline", "UI_CH4_UNDERLINE", mark_selected)
			underline.disabled = selected.is_empty() or not pending.is_empty() or not matched.is_empty()
			Layout.label(lines, "Feedback", feedback, 25)


func _select(rule_id: StringName) -> void:
	if not matched.is_empty() or not pending.is_empty():
		return
	selected = rule_id
	feedback = ""
	refresh()


func comparison_rules() -> Array[RuleData]:
	# A new chapter replaces RuleSystem; keep canonical prior-round wording available.
	var rules: Dictionary = {}
	for data: RuleSet in [preload("res://data/rules/ch1.tres"), preload("res://data/rules/ch2.tres"), preload("res://data/rules/ch3.tres")]:
		for rule in data.rules:
			rules[rule.id] = rule
	for id in RuleSystem.all_rule_ids():
		rules[id] = RuleSystem.get_rule(id)
	var result: Array[RuleData] = []
	for rule: RuleData in rules.values():
		result.append(rule)
	return result


func mark_selected() -> void:
	if not compare_enabled() or selected not in R5 or not pending.is_empty() or not matched.is_empty():
		return
	pending = selected
	refresh()
	EventBus.ch4_sentence_marked.emit(pending)


func _result(rule_id: StringName, correct: bool) -> void:
	if pending != rule_id or pending.is_empty():
		return
	pending = &""
	if correct:
		matched = rule_id
		GameState.set_flag(&"ch4_ui_marked_rule", String(rule_id))
	feedback = "UI_CH4_NOTE_REDUNDANT" if correct else "UI_CH4_NOT_YET"
	refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh()
