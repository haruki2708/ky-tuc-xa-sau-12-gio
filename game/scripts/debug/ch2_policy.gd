extends RefCounted
## QA oracle from CH2_DESIGN.md. Word validity/dead ends come from the
## published core lexicon; never infer a Vietnamese word from its spelling.

const LOOP: Array[String] = ["học sinh", "sinh viên", "viên phấn", "phấn đấu", "đấu tranh", "tranh luận", "luận văn", "văn học"]


static func words(text: String) -> PackedStringArray:
	return text.strip_edges().to_lower().split(" ", false)


static func legal(previous: String, candidate: String, recent: Array) -> bool:
	var before := words(previous)
	var after := words(candidate)
	if before.size() != 2 or after.size() != 2 or before[1] != after[0]: return false
	for old: String in recent.slice(maxi(0, recent.size() - 3)):
		if " ".join(words(old)) == " ".join(after): return false
	return true


static func without_tone(text: String) -> String:
	var groups := ["aàáảãạ", "ăằắẳẵặ", "âầấẩẫậ", "eèéẻẽẹ", "êềếểễệ", "iìíỉĩị", "oòóỏõọ", "ôồốổỗộ", "ơờớởỡợ", "uùúủũụ", "ưừứửữự", "yỳýỷỹỵ"]
	var out := text.to_lower()
	for group: String in groups:
		for letter: String in group:
			out = out.replace(letter, group[0])
	return out


static func wrong_tone(previous: String, candidate: String) -> bool:
	var before := words(previous)
	var after := words(candidate)
	return before.size() == 2 and after.size() == 2 and before[1] != after[0] and without_tone(before[1]) == without_tone(after[0])


## Returns an option index; -1 means the requested kind was not offered.
## A loop route must reach one of the eight words within three bridge words.
static func choose(previous: String, options: Array, recent: Array, lexicon: Dictionary, mode: String = "legal") -> int:
	var best := -1
	var distance := 99
	for i in options.size():
		var entry: Dictionary = lexicon.get(options[i], {})
		var text: String = entry.get("text", "")
		if mode == "wrong_tone":
			if wrong_tone(previous, text): return i
			continue
		if entry.get("valid", false) != true or not legal(previous, text, recent): continue
		if mode == "trap":
			if entry.get("dead_end", false) == true: return i
		elif mode == "loop":
			var depth := _loop_distance(text, recent, lexicon, 3)
			if depth < distance:
				distance = depth
				best = i
		else: return i
	return best if distance < 99 else -1


static func _loop_distance(word: String, recent: Array, lexicon: Dictionary, remaining: int) -> int:
	if word in LOOP: return 0
	if remaining <= 0: return 99
	var best := 99
	var history := recent.duplicate()
	history.append(word)
	for entry: Dictionary in lexicon.values():
		var next: String = entry.get("text", "")
		if entry.get("valid", false) == true and legal(word, next, history):
			best = mini(best, 1 + _loop_distance(next, history, lexicon, remaining - 1))
	return best


## Only the previous revealed temperature is used; never look ahead into
## the scripted sequence. Unknown first slot is conservatively declined.
static func shower_yes(history: Array) -> bool:
	if history.is_empty(): return false
	var previous := int(history[-1])
	if previous < 0 or previous > 99: return false
	return ((previous / 10) + (previous % 10)) % 10 < 5
