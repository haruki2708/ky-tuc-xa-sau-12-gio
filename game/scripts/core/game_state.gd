extends Node
## Autoload GameState: in-game clock, story segment, deviation level and story
## flags. Changes are announced on EventBus. Owner: integrator.

## 23:50, when the demo starts.
const START_MINUTES: int = 23 * 60 + 50
## Highest deviation level; each level changes the dorm a little more.
const MAX_DEVIATION: int = 5

## Minutes since 00:00 of the first day; keeps growing past midnight.
var minutes: int = START_MINUTES
var segment: StringName = &""
## Night being played, 1..Progress.CHAPTER_COUNT (D-029). reset() keeps it:
## a fresh start of the same night.
var chapter: int = 1
var deviation: int = 0
## In-game minutes per real second. 0 = the clock only moves on story beats.
var minutes_per_second: float = 0.0

var _flags: Dictionary[StringName, Variant] = {}
var _clock_accumulator: float = 0.0


func _process(delta: float) -> void:
	if minutes_per_second <= 0.0:
		return
	_clock_accumulator += delta * minutes_per_second
	if _clock_accumulator >= 1.0:
		var whole := int(_clock_accumulator)
		_clock_accumulator -= whole
		advance_minutes(whole)


## Back to a fresh night. Does not emit signals; callers rebuild their view.
func reset() -> void:
	minutes = START_MINUTES
	segment = &""
	deviation = 0
	minutes_per_second = 0.0
	_flags.clear()
	_clock_accumulator = 0.0


func set_time(value: int) -> void:
	value = maxi(0, value)
	if value == minutes:
		return
	minutes = value
	EventBus.time_changed.emit(minutes)


func advance_minutes(amount: int) -> void:
	set_time(minutes + maxi(0, amount))


## "23:50", "00:30"...
func clock_text() -> String:
	return "%02d:%02d" % [(minutes / 60) % 24, minutes % 60]


func set_segment(value: StringName) -> void:
	if value == segment:
		return
	segment = value
	EventBus.segment_changed.emit(segment)


## Negative amounts are allowed (a rare "calming" event). Clamped to 0..MAX.
func add_deviation(amount: int, reason: StringName = &"") -> void:
	var next := clampi(deviation + amount, 0, MAX_DEVIATION)
	if next == deviation:
		return
	deviation = next
	EventBus.deviation_changed.emit(deviation, reason)


## Flags hold simple story facts. Only bool/int/float/String survive a save.
func set_flag(flag: StringName, value: Variant) -> void:
	if not (value is bool or value is int or value is float or value is String):
		push_warning("GameState flag '%s' must be bool, int, float or String" % flag)
		return
	if _flags.has(flag) and typeof(_flags[flag]) == typeof(value) and _flags[flag] == value:
		return
	_flags[flag] = value
	EventBus.flag_changed.emit(flag, value)


func get_flag(flag: StringName, default: Variant = null) -> Variant:
	return _flags.get(flag, default)


func has_flag(flag: StringName) -> bool:
	return _flags.has(flag)


func to_dict() -> Dictionary:
	var flags := {}
	for flag in _flags:
		flags[String(flag)] = {"type": typeof(_flags[flag]), "value": _flags[flag]}
	return {
		"minutes": minutes,
		"segment": String(segment),
		"chapter": chapter,
		"deviation": deviation,
		"flags": flags,
	}


## Restores a snapshot and announces every value so views can rebuild.
func from_dict(data: Dictionary) -> void:
	reset()
	minutes = maxi(0, int(data.get("minutes", START_MINUTES)))
	segment = StringName(str(data.get("segment", "")))
	chapter = maxi(1, int(data.get("chapter", 1)))
	deviation = clampi(int(data.get("deviation", 0)), 0, MAX_DEVIATION)
	var flags: Dictionary = data.get("flags", {})
	for key: String in flags:
		var entry: Dictionary = flags[key]
		# JSON turns every number into float; restore the original type.
		_flags[StringName(key)] = type_convert(entry.get("value"), int(entry.get("type", TYPE_NIL)))
	EventBus.time_changed.emit(minutes)
	EventBus.segment_changed.emit(segment)
	EventBus.deviation_changed.emit(deviation, &"checkpoint")
	for flag in _flags:
		EventBus.flag_changed.emit(flag, _flags[flag])
