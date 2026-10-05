extends Node
## Test double only: not a replacement chapter and never a benchmark fixture.
var auto_start: bool = false
var enabled: bool = true
var hits: int = 0
var stamina: float = 0.0

func run_from(stage: StringName) -> void:
	GameState.set_segment(stage)

func set_zombies(value: bool) -> void:
	enabled = value

func give_bar(value: int) -> void:
	hits = value

func refill() -> void:
	stamina = 1.0
