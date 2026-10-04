class_name MessageData
extends Resource
## One text message on Trung's phone (D-027, T-150). The story director emits
## EventBus.phone_message_received(id); lane D's phone screen (T-155) loads it
## and shows it in the thread of its sender. Files live at
## res://data/messages/<id>.tres. Owner: integrator.

const DIRECTORY := "res://data/messages/"

@export var id: StringName
## Thread the message belongs to: &"mom", &"class_group", &"phuc", &"viet",
## &"dat", &"unknown"... The screen shows one thread per sender.
@export var sender: StringName
## Translation key of the sender's display name (contact name or number).
@export var sender_name_key: String
## Translation key of the message text.
@export var text_key: String
## In-game time it was sent, in GameState minutes (may be before midnight of
## the day screen: 600 = 10:00).
@export var minutes: int = 0
## True when Trung sent it (shown on the right).
@export var outgoing: bool = false
## True for a line spoken in the group call: lane E has a voice clip under
## text_key; the phone shows it as a transcript line.
@export var spoken: bool = false


static func load_by_id(message_id: StringName) -> MessageData:
	var path := DIRECTORY + String(message_id) + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as MessageData


## "10:00", "03:07"...
func clock_text() -> String:
	return "%02d:%02d" % [(minutes / 60) % 24, minutes % 60]
