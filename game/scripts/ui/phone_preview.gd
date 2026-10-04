extends "res://scripts/ui/phone_screen.gd"
## Neutral fixtures only; production messages belong to core's data/messages.


func _load_message(id: StringName) -> MessageData:
	if id not in [&"preview_a", &"preview_b", &"preview_text"]:
		return null
	var message := MessageData.new()
	message.id = id
	message.sender = &"preview_a" if id == &"preview_a" else &"preview_b"
	message.sender_name_key = "UI_PHONE_PREVIEW_MEMBER_A" if id == &"preview_a" else "UI_PHONE_PREVIEW_MEMBER_B"
	message.text_key = "UI_PHONE_PREVIEW_LINE_A" if id == &"preview_a" else "UI_PHONE_PREVIEW_LINE_B"
	message.minutes = 245 if id == &"preview_a" else 246
	message.spoken = id != &"preview_text"
	message.outgoing = id == &"preview_text"
	return message
