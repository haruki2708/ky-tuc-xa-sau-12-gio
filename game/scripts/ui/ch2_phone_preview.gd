extends "res://scripts/ui/phone_screen.gd"
## Approved word-loop text as a MessageData fixture. Production data belongs to core.

func _load_message(id: StringName) -> MessageData:
	if id != &"ch2_preview_loop":
		return super._load_message(id)
	var message := MessageData.new()
	message.id = id
	message.sender = &"minh_nhat"
	message.sender_name_key = "NAME_CH1_MINH_NHAT"
	message.text_key = "UI_CH2_PREVIEW_LOOP"
	message.minutes = 390
	message.spoken = false
	return message
