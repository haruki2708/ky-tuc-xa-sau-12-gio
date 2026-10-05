"""Chapter 2 word chain dictionary (D-049, D-051).

The player types any two-syllable word found in Wiktionary (Vietnamese and
English editions, as extracted by kaikki.org; CC BY-SA 3.0/4.0) or in the
game's own bank (word_bank.py). The dead roommates know a smaller part: the
words both Wiktionary editions agree on, plus the bank.

Output (game/data/ch2/):
  dictionary.txt   one word per line, "<word>\t<canon>\t<c>": canon as canon_word(),
                   c = 1 when the corpses know it.
                   CC BY-SA 4.0 (adapted from Wiktionary), see DICTIONARY_LICENSE.md.
  corpse_syllables.txt  every syllable a corpse may say, "<spelling>\t<canon>"
                   (for the voice bank, audio_source/ch2_syllable_voices.py).

Syllables are compared by canon(): tone marks set apart, so old and new
tone placement ("hoà" / "hòa") and "kỹ" / "kĩ" are the same syllable.
The game uses the same rule (scripts/core/viet_text.gd); test_viet_text
checks both against canon_samples.json.

Run from the repo root:  py -3 docs/design/ch2/build_dictionary.py
Downloads are cached in docs/design/ch2/.cache/ (gitignored).
"""
from datetime import date
import hashlib
import json
import sys
import unicodedata
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CACHE = HERE / ".cache"
OUT = ROOT / "game/data/ch2"
sys.path.insert(0, str(HERE))
sys.dont_write_bytecode = True
import word_bank  # noqa: E402

SOURCES = {
    "vi": "https://kaikki.org/viwiktionary/Ti%E1%BA%BFng%20Vi%E1%BB%87t/kaikki.org-dictionary-Ti%E1%BA%BFngVi%E1%BB%87t.jsonl",
    "en": "https://kaikki.org/dictionary/Vietnamese/kaikki.org-dictionary-Vietnamese.jsonl",
}
SKIP_POS = {"name", "proper noun", "character", "symbol", "romanization", "suffix", "prefix", "abbrev", "phrase", "proverb"}
LETTERS = set("abcdeghiklmnopqrstuvxyđ")
# The corpses say no slurs or obscenities (they would be voiced).
CORPSE_BLOCK = {"địt", "đụ", "đéo", "lồn", "buồi", "cặc", "đĩ", "cứt", "đái", "ỉa", "mọi", "khựa"}
# A corpse never leaves the player on a syllable with fewer continuations than this.
MIN_CONTINUATIONS = 5

TONE_MARKS = {"̀": 1, "́": 2, "̉": 3, "̃": 4, "̣": 5}
ONSETS = {"b", "c", "ch", "d", "đ", "g", "gh", "h", "k", "kh", "l", "m", "n", "ng", "ngh", "nh", "p", "ph",
          "r", "s", "t", "th", "tr", "v", "x"}


def canon_syllable(syllable: str) -> str:
    """Toneless syllable (keeps ă â ê ô ơ ư đ) + tone digit 0-5."""
    tone = 0
    kept = []
    for c in unicodedata.normalize("NFD", syllable.strip().lower()):
        if c in TONE_MARKS:
            tone = TONE_MARKS[c]
        else:
            kept.append(c)
    base = unicodedata.normalize("NFC", "".join(kept))
    # "kỹ" / "kĩ", "lý" / "lí": a lone y after a consonant is i.
    if base.endswith("y") and base[:-1] in ONSETS:
        base = base[:-1] + "i"
    return base + str(tone)


def canon_word(word: str) -> str:
    return " ".join(canon_syllable(s) for s in word.split())


def is_syllable(s: str) -> bool:
    base = canon_syllable(s)[:-1]
    letters = unicodedata.normalize("NFD", base)
    plain = "".join(c for c in letters if not unicodedata.combining(c))
    return 0 < len(plain) <= 7 and all(c in LETTERS for c in plain) and any(c in "aeiouy" for c in plain)


def fetch(edition: str) -> Path:
    CACHE.mkdir(exist_ok=True)
    path = CACHE / f"kaikki-{edition}.jsonl"
    if not path.exists():
        print("downloading", SOURCES[edition], flush=True)
        urllib.request.urlretrieve(SOURCES[edition], path)
    return path


def two_syllable_words(path: Path) -> dict:
    """canon -> spelling, for lower-case two-syllable common words."""
    words = {}
    for line in path.open(encoding="utf-8"):
        entry = json.loads(line)
        if entry.get("pos", "") in SKIP_POS:
            continue
        word = unicodedata.normalize("NFC", entry["word"].strip())
        parts = word.split(" ")
        if len(parts) != 2 or word != word.lower() or not all(is_syllable(p) for p in parts):
            continue
        words.setdefault(canon_word(word), word)
    return words


def build():
    vi = two_syllable_words(fetch("vi"))
    en = two_syllable_words(fetch("en"))
    bank = {canon_word(w): w for w in word_bank.BANK}
    every = dict(en)
    every.update(vi)
    every.update(bank)  # the bank's spelling wins
    starts = {}
    for c in every:
        starts.setdefault(c.split(" ")[0], 0)
        starts[c.split(" ")[0]] += 1
    corpse = set()
    for c, word in every.items():
        common = c in bank and word not in word_bank.DEAD or (c in vi and c in en)
        if not common or any(s in CORPSE_BLOCK for s in word.split(" ")):
            continue
        if starts.get(c.split(" ")[1], 0) >= MIN_CONTINUATIONS:
            corpse.add(c)
    return every, corpse, starts


def main():
    every, corpse, starts = build()
    OUT.mkdir(parents=True, exist_ok=True)
    lines = [f"{every[c]}\t{c}\t{1 if c in corpse else 0}" for c in sorted(every, key=lambda k: every[k])]
    header = [
        "# Ky Tuc Xa Sau 12 Gio - chapter 2 word list. Adapted from Wiktionary (vi.wiktionary.org and",
        "# en.wiktionary.org, Wiktionary contributors; extracted by kaikki.org / wiktextract), plus the",
        "# game's own words. License: CC BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/",
        "# Changes: two-syllable entries only, names and affixes removed, canonical form and corpse flag added.",
    ]
    (OUT / "dictionary.txt").write_text("\n".join(header + lines) + "\n", encoding="utf-8", newline=chr(10))
    # One spelling per canonical syllable, for the corpse voice bank.
    spelled = {}
    for c in sorted(corpse):
        for spelling, key in zip(every[c].split(" "), c.split(" ")):
            spelled.setdefault(key, spelling)
    syllables = sorted(spelled)
    (OUT / "corpse_syllables.txt").write_text("\n".join(f"{spelled[k]}\t{k}" for k in syllables) + "\n", encoding="utf-8", newline=chr(10))
    report = {
        "words": len(every), "corpse_words": len(corpse), "corpse_syllables": len(syllables),
        "min_continuations": MIN_CONTINUATIONS,
        "sources": {k: {"url": v, "downloaded": date.fromtimestamp((CACHE / f"kaikki-{k}.jsonl").stat().st_mtime).isoformat(),
                        "sha256": hashlib.sha256((CACHE / f"kaikki-{k}.jsonl").read_bytes()).hexdigest()}
                    for k, v in SOURCES.items()},
    }
    (HERE / "dictionary_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline=chr(10))
    # Samples the game's canon (viet_text.gd) must agree with.
    samples = ["hoà bình", "hòa bình", "HÒA BÌNH", "thuỷ thủ", "kỹ thuật", "kĩ thuật", "lý do", "quý giá",
               "khuất phục", "vở kịch", "vỡ nát", "đường đi", "nghiêng ngả", "Ứng dụng", "giữ gìn", "quyết định"]
    samples += [unicodedata.normalize("NFD", "khuất phục"), unicodedata.normalize("NFD", "Ứng dụng")]
    (HERE.parents[2] / "game/tests/core/canon_samples.json").write_text(
        json.dumps({s: canon_word(s) for s in samples}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline=chr(10))
    print(json.dumps(report, ensure_ascii=False, indent=1))
    # Fairness: every corpse word leaves the player at least MIN_CONTINUATIONS answers.
    assert all(starts.get(c.split(" ")[1], 0) >= MIN_CONTINUATIONS for c in corpse)
    for w in word_bank.LOOP + word_bank.OPENING:
        assert canon_word(w) in every, w


if __name__ == "__main__":
    main()
