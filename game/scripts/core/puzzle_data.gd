class_name PuzzleData
extends Resource
## A puzzle close-up (T-150). Lane A's puzzle station emits
## EventBus.puzzle_opened(id); lane D's panel (T-156) loads this data, checks
## the player's answer and emits EventBus.puzzle_solved(id). Files live at
## res://data/puzzles/<id>.tres. Owner: integrator.

const DIRECTORY := "res://data/puzzles/"

@export var id: StringName
## Which panel to show: &"combination" (number dials), &"fuse_box" (switches).
@export var kind: StringName = &"combination"
## Translation key of the heading shown on the panel.
@export var title_key: String
## combination: the digits, e.g. "304". fuse_box: one character per switch,
## "1" = on, "0" = off, left to right, e.g. "1001".
@export var solution: String
## fuse_box: translation key of each switch label, left to right (the wiring
## diagram taped inside the lid). Unused by combination.
@export var label_keys: Array[String] = []
## Optional document shown next to the panel as the hint (diagram, calendar).
@export var hint_document: StringName


static func load_by_id(puzzle_id: StringName) -> PuzzleData:
	var path := DIRECTORY + String(puzzle_id) + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as PuzzleData


## True when the answer matches (digits or switch states, as a string).
func check(answer: String) -> bool:
	return answer == solution
