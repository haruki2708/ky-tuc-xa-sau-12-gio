extends Control
## F6 harness. Only the log sample is synthetic, explicitly labeled as UI preview.

const DOCUMENTS := ["hall_board", "room_paper_407", "hall_board_note", "washroom_notice"]
const LABELS := ["SOURCE_HALL_BOARD", "SOURCE_ROOM_PAPER", "SOURCE_HANDWRITTEN_NOTE", "SOURCE_WASHROOM_NOTICE"]


func _ready() -> void:
	RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
	for index in DOCUMENTS.size():
		_add_button(LABELS[index], _open_document.bind(DOCUMENTS[index]))
	_add_button("UI_LOG_PREVIEW_TITLE", _open_log_preview)
	_add_button("UI_NOTEBOOK_TEST_SPEAKER", _read_speaker)
	_add_button("UI_NOTEBOOK_TITLE", $Notebook.open_notebook)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--reading-capture="):
			TranslationServer.set_locale("vi")
			_capture(arg.trim_prefix("--reading-capture="))


func _add_button(key: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = key
	button.pressed.connect(callback)
	$Controls.add_child(button)


func _open_document(id: StringName) -> void:
	DocumentData.load_by_id(id).mark_rules_read()
	EventBus.document_opened.emit(id)


func _open_log_preview() -> void:
	var document := DocumentData.new()
	document.id = &"ui_log_preview"
	document.title_key = "UI_LOG_PREVIEW_TITLE"
	document.style = &"log"
	document.text_keys = ["UI_LOG_PREVIEW_TEXT"]
	$DocumentView.show_document(document)


func _read_speaker() -> void:
	for id: StringName in [&"lights_genuine", &"knock_genuine", &"slippers_genuine", &"rollcall_self_genuine", &"tap_genuine"]:
		RuleSystem.mark_read(id, &"speaker", "RULE_3_GARBLED" if id == &"slippers_genuine" else "")


func _capture(kind: String) -> void:
	if kind == "log":
		_open_log_preview()
	elif kind == "notebook":
		DocumentData.load_by_id(&"room_paper_407").mark_rules_read()
		RuleSystem.mark_read(&"slippers_genuine", &"speaker", "RULE_3_GARBLED")
		RuleSystem.set_suspected(&"slippers_paper", true)
		$Notebook.open_notebook()
	else:
		var ids := {"stamped": "hall_board", "photocopy": "room_paper_407", "handwritten": "hall_board_note", "notice": "washroom_notice"}
		if ids.has(kind):
			_open_document(ids[kind])


func _exit_tree() -> void:
	RuleSystem.reset()
