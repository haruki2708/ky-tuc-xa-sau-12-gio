extends PanelContainer
## Shared confirmation with a safe initial focus and localized labels.

signal confirmed
signal cancelled


func _ready() -> void:
	$Content/Buttons/Confirm.pressed.connect(func() -> void: confirmed.emit())
	$Content/Buttons/Cancel.pressed.connect(func() -> void: cancelled.emit())


func open(message_key: String) -> void:
	$Content/Message.text = message_key
	show()
	$Content/Buttons/Cancel.grab_focus()
