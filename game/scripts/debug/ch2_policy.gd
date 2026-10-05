extends RefCounted
## Independent dictionary and temperature policy for D-049 through D-051.

const LOOP: Array[String] = ["học sinh", "sinh viên", "viên phấn", "phấn đấu", "đấu tranh", "tranh luận", "luận văn", "văn học"]


static func words(text: String) -> PackedStringArray:
	return VietText.canon_word(text).split(" ", false)


static func legal(previous: String, candidate: String, recent: Array) -> bool:
	var before := words(previous)
	var after := words(candidate)
	if after.size() != 2 or (not previous.is_empty() and (before.size() != 2 or before[1] != after[0])): return false
	for old: String in recent.slice(maxi(0, recent.size() - 3)):
		if " ".join(words(old)) == " ".join(after): return false
	return true


static func wrong_tone(previous: String, candidate: String) -> bool:
	var before := words(previous)
	var after := words(candidate)
	return before.size() == 2 and after.size() == 2 and before[1] != after[0] and before[1].left(-1) == after[0].left(-1)


## Only the previous revealed temperature is used; never look ahead into
## the scripted sequence. Unknown first slot is conservatively declined.
static func shower_yes(history: Array) -> bool:
	if history.is_empty(): return false
	var previous := int(history[-1])
	if previous < 0 or previous > 99: return false
	return ((previous / 10) + (previous % 10)) % 10 < 5


static var _distances: Dictionary = {}


static func dead_end(candidate: String) -> bool:
	return not Ch2Dictionary.shared().corpse_by_first.has(Ch2Dictionary.last_of(VietText.canon_word(candidate)))


## Reverse breadth-first distances from the loop, built once from dictionary.
static func _index_routes() -> void:
	if not _distances.is_empty(): return
	var incoming: Dictionary = {}
	for word: String in Ch2Dictionary.shared().spelling:
		var tail := Ch2Dictionary.last_of(word)
		if not incoming.has(tail): incoming[tail] = []
		incoming[tail].append(Ch2Dictionary.first_of(word))
	var queue: Array[String] = []
	for word: String in LOOP:
		var head := Ch2Dictionary.first_of(VietText.canon_word(word))
		_distances[head] = 0
		queue.append(head)
	var index := 0
	while index < queue.size():
		var tail := queue[index]
		index += 1
		for head: String in incoming.get(tail, []):
			if not _distances.has(head):
				_distances[head] = int(_distances[tail]) + 1
				queue.append(head)


static func choose_word(previous: String, recent: Array, mode: String = "legal") -> String:
	var dictionary := Ch2Dictionary.shared()
	var before := VietText.canon_word(previous)
	var head := Ch2Dictionary.last_of(before)
	if mode == "wrong_tone":
		for word: String in dictionary.spelling:
			if wrong_tone(previous, dictionary.spelling[word]): return dictionary.spelling[word]
		return ""
	var choices: Variant = dictionary.spelling.keys() if before.is_empty() else dictionary.by_first.get(head, PackedStringArray())
	if mode == "loop":
		for word: String in LOOP:
			if legal(previous, word, recent) and dictionary.has(VietText.canon_word(word)): return word
		_index_routes()
	var best := ""
	var distance := 99999
	for word: String in choices:
		if not legal(previous, dictionary.spelling[word], recent): continue
		if mode == "trap":
			if dead_end(dictionary.spelling[word]): return dictionary.spelling[word]
		elif mode == "loop":
			var steps := int(_distances.get(Ch2Dictionary.last_of(word), 99999))
			if steps < distance:
				distance = steps
				best = word
		else:
			if not dead_end(dictionary.spelling[word]): return dictionary.spelling[word]
			best = word
	return dictionary.spelling.get(best, "")


## Uses only the three temperatures received, never the scripted next value.
static func prediction(history: Array, wrong: bool = false, as_range: bool = false) -> String:
	if history.size() != 3: return ""
	for value: Variant in history:
		if not (value is int or value is float) or value != int(value) or value < 0 or value > 99: return ""
	var previous := int(history[-1])
	var tens := ((previous / 10) + (previous % 10)) % 10
	if as_range and not wrong: return "%dx" % tens
	var yes := tens < 5
	if wrong: yes = not yes
	return "có" if yes else "không"
