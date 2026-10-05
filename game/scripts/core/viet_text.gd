class_name VietText
extends RefCounted
## Vietnamese text as the player types it (system IME: Unikey, EVKey, the
## Windows keyboard; D-049). Syllables compare by canon(): the toneless
## syllable (keeps ă â ê ô ơ ư đ) plus a tone digit, so precomposed and
## combining input, old and new tone placement ("hoà" / "hòa") and "kỹ" /
## "kĩ" all match. Same rule as docs/design/ch2/build_dictionary.py.

## Tone digits: 0 ngang, 1 huyền, 2 sắc, 3 hỏi, 4 ngã, 5 nặng.
const TONED := {
	"a": "àáảãạ", "ă": "ằắẳẵặ", "â": "ầấẩẫậ", "e": "èéẻẽẹ", "ê": "ềếểễệ", "i": "ìíỉĩị",
	"o": "òóỏõọ", "ô": "ồốổỗộ", "ơ": "ờớởỡợ", "u": "ùúủũụ", "ư": "ừứửữự", "y": "ỳýỷỹỵ",
}
## Combining marks: tones, and the vowel marks of full decomposition (NFD).
const COMBINING_TONES := {0x0300: 1, 0x0301: 2, 0x0309: 3, 0x0303: 4, 0x0323: 5}
const COMBINING_SHAPES := {
	0x0302: {"a": "â", "e": "ê", "o": "ô"},
	0x0306: {"a": "ă"},
	0x031B: {"o": "ơ", "u": "ư"},
}
const ONSETS := ["b", "c", "ch", "d", "đ", "g", "gh", "h", "k", "kh", "l", "m", "n", "ng", "ngh", "nh", "p",
	"ph", "r", "s", "t", "th", "tr", "v", "x"]

static var _untone: Dictionary = {}


## "khuất" -> "khuât2". Empty for empty input.
static func canon_syllable(syllable: String) -> String:
	_build()
	var tone := 0
	var base := ""
	for c in syllable.strip_edges().to_lower():
		var code := c.unicode_at(0)
		if COMBINING_TONES.has(code):
			tone = COMBINING_TONES[code]
		elif COMBINING_SHAPES.has(code):
			if not base.is_empty():
				var last := base.right(1)
				base = base.left(-1) + String(COMBINING_SHAPES[code].get(last, last))
		elif _untone.has(c):
			base += String(_untone[c][0])
			tone = int(_untone[c][1])
		else:
			base += c
	if base.is_empty():
		return ""
	# A lone y after a consonant is i ("kỹ" = "kĩ", "lý" = "lí").
	if base.ends_with("y") and base.left(-1) in ONSETS:
		base = base.left(-1) + "i"
	return base + str(tone)


## A typed word -> its canonical syllables joined by one space ("" if empty).
static func canon_word(text: String) -> String:
	var parts := PackedStringArray()
	for syllable in syllables(text):
		parts.append(canon_syllable(syllable))
	return " ".join(parts)


## Syllables of typed text: lower case, split on any run of spaces.
static func syllables(text: String) -> PackedStringArray:
	return text.strip_edges().to_lower().split(" ", false)


## "có" / "co" / "khong" … without tone or case, for short typed answers.
static func plain(text: String) -> String:
	var out := ""
	for syllable in syllables(text):
		var c := canon_syllable(syllable)
		out += (" " if not out.is_empty() else "") + c.left(-1).replace("đ", "d").replace("ă", "a").replace("â", "a") \
			.replace("ê", "e").replace("ô", "o").replace("ơ", "o").replace("ư", "u")
	return out


static func _build() -> void:
	if not _untone.is_empty():
		return
	for base: String in TONED:
		var marks: String = TONED[base]
		for i in marks.length():
			_untone[marks[i]] = [base, i + 1]
