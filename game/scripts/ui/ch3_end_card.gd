extends CanvasLayer
## Presentation only: core stops gameplay, unlocks chapter four and owns navigation.

@export_range(0.0, 10.0) var fade_seconds := 2.0
var _active := false
var _elapsed := 0.0


func _ready() -> void:
	EventBus.chapter_finished.connect(func(chapter: int) -> void:
		if chapter == 3:
			show_card())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: close_card())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: close_card())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: close_card())
	close_card()


func show_card() -> void:
	if _active:
		return
	_active = true
	_elapsed = 0.0
	_refresh()


func close_card() -> void:
	_active = false
	_elapsed = 0.0
	_refresh()


func _process(delta: float) -> void:
	if _active and not get_tree().paused:
		_elapsed += delta
		_refresh()


func _refresh() -> void:
	$Root.visible = _active
	$Root/Shade.color.a = clampf(_elapsed / maxf(fade_seconds, 0.001), 0.0, 1.0)
	$Root/Center.visible = _active and _elapsed >= fade_seconds
