class_name Ch2Dictionary
extends RefCounted
## Word chain dictionary (D-049, D-051): data/ch2/dictionary.txt, built by
## docs/design/ch2/build_dictionary.py from Wiktionary (CC BY-SA, see
## data/ch2/DICTIONARY_LICENSE.md) plus the game's own bank. Words are keyed
## by VietText.canon_word(); the corpses know only the flagged part.

const PATH := "res://data/ch2/dictionary.txt"

## canon word -> spelling shown to the player.
var spelling: Dictionary[String, String] = {}
## canon first syllable -> canon words (all, and the ones the corpses know).
var by_first: Dictionary[String, PackedStringArray] = {}
var corpse_by_first: Dictionary[String, PackedStringArray] = {}
var corpse_count: int = 0

static var _shared: Ch2Dictionary


## Loaded once per run (about 31 000 words).
static func shared() -> Ch2Dictionary:
	if _shared == null:
		_shared = Ch2Dictionary.new()
		_shared.load_file(PATH)
	return _shared


func load_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Ch2Dictionary: missing " + path)
		return
	while not file.eof_reached():
		var parts := file.get_line().split("\t")
		if parts.size() < 3:
			continue
		spelling[parts[1]] = parts[0]
		var first := parts[1].get_slice(" ", 0)
		if not by_first.has(first):
			by_first[first] = PackedStringArray()
		by_first[first].append(parts[1])
		if parts[2] == "1":
			if not corpse_by_first.has(first):
				corpse_by_first[first] = PackedStringArray()
			corpse_by_first[first].append(parts[1])
			corpse_count += 1


func has(canon: String) -> bool:
	return spelling.has(canon)


func corpse_knows(canon: String) -> bool:
	return canon in corpse_by_first.get(first_of(canon), PackedStringArray())


static func first_of(canon: String) -> String:
	return canon.get_slice(" ", 0)


static func last_of(canon: String) -> String:
	return canon.get_slice(" ", 1)
