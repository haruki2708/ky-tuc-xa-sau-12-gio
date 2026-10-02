class_name RuleData
extends Resource
## One printed line of the night rules, as it appears on one source (speaker,
## hall board, room paper...). A situation can be covered by the genuine line
## and by edited copies that tell the player to do something else.

## Unique id, e.g. &"knock_genuine", &"knock_room_paper".
@export var id: StringName
## Translation key of the printed text. Must start with RULE_.
@export var text_key: String
## Hidden truth. UI must never reveal it.
@export var is_fake: bool = false
## Where the line is printed or announced, e.g. &"speaker", &"hall_board".
@export var source: StringName
## Situation the line governs, e.g. &"knock_at_door".
@export var situation: StringName
## What the line tells the player to do, e.g. &"stay_silent".
@export var action: StringName
## Deviation added when the player gets the situation wrong through this line.
@export_range(0, 10) var penalty: int = 1
## World change performed by other systems when this line causes a mistake.
@export var consequence: StringName
## Breaking or following this line wrongly is a real loss (checkpoint reload).
@export var fatal: bool = false
