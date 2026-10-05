class_name Ch2SyllableBank
extends RefCounted
## The corpses' voice for dictionary words outside the game's bank (D-051):
## every syllable they may say, cut from a few OGG chunks made by
## audio_source/ch2_syllable_voices.py. Lane E's CorpseVoice plays the pieces
## of a word back to back: play(from = start), stop after length.

const MAP_PATH := "res://data/ch2/corpse_syllables.json"

static var _map: Dictionary = {}
static var _streams: Array[AudioStream] = []


## Pieces of a word as typed or shown ("khuất bóng"): one {stream, start,
## length} per syllable, in order. Empty if any syllable has no recording.
static func clips_for(text: String) -> Array[Dictionary]:
	_load()
	var clips: Array[Dictionary] = []
	var syllables: Dictionary = _map.get("syllables", {})
	for syllable in VietText.syllables(text):
		var entry: Variant = syllables.get(VietText.canon_syllable(syllable))
		if entry == null or int(entry[0]) >= _streams.size() or _streams[int(entry[0])] == null:
			return [] as Array[Dictionary]
		clips.append({"stream": _streams[int(entry[0])], "start": float(entry[1]), "length": float(entry[2])})
	return clips


## Seconds the word lasts when played piece by piece with `gap` between.
static func seconds_for(text: String, gap: float = 0.08) -> float:
	var total := 0.0
	for clip in clips_for(text):
		total += float(clip.length) + gap
	return total


static func _load() -> void:
	if not _map.is_empty():
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAP_PATH))
	_map = data if data is Dictionary else {"syllables": {}}
	for path: String in _map.get("chunks", []):
		_streams.append(load(path) as AudioStream if ResourceLoader.exists(path) else null)
