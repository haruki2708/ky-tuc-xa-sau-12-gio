"""Chapter 2 corpse syllables (D-051, T-176, core): the dead roommates know
about 9 500 dictionary words, too many to voice one by one. Every syllable
they may say (game/data/ch2/corpse_syllables.txt, from
docs/design/ch2/build_dictionary.py) is rendered once with eSpeak NG in the
neutral corpse voice and packed, with silence between, into a few OGG
chunks; lane E's CorpseVoice plays two pieces back to back (T-178 audio).

Output:
  game/audio/voice/vi/ch2_syllables_<n>.ogg
  game/data/ch2/corpse_syllables.json  {"chunks": [...], "syllables": {canon: [chunk, start, length]}}

Run from the repo root:  py -3 audio_source/ch2_syllable_voices.py
"""
from __future__ import annotations

import argparse
from array import array
import json
from pathlib import Path
import sys
import tempfile
import wave

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from process import ROOT, import_settings, loudness, run  # noqa: E402
from voice_process import DEFAULT_TTS  # noqa: E402
import ch1_voice_process as ch1  # noqa: E402
import ch2_voice_process as ch2  # noqa: E402

LIST = ROOT / "game/data/ch2/corpse_syllables.txt"
MAP = ROOT / "game/data/ch2/corpse_syllables.json"
DEST = ROOT / "game/audio/voice/vi"
RATE = 22050
GAP = 0.25  # seconds of silence around every syllable
CHUNK_SYLLABLES = 650
THRESHOLD = 300  # 16-bit amplitude counted as sound when trimming


def trim(samples: array) -> array:
    first = next((i for i, v in enumerate(samples) if abs(v) > THRESHOLD), 0)
    last = next((i for i in range(len(samples) - 1, -1, -1) if abs(samples[i]) > THRESHOLD), len(samples) - 1)
    return samples[max(0, first - 40):last + 200]


def render(tts: Path, text: str, temp: Path) -> tuple[array, int]:
    voice, wpm, pitch, _chain, _target = ch2.VOICES["corpse"]
    path = ch1.synthesize(tts, text, voice, wpm, pitch, temp)
    with wave.open(str(path), "rb") as file:
        rate = file.getframerate()
        data = array("h", file.readframes(file.getnframes()))
    return trim(data), rate


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tts", type=Path, default=DEFAULT_TTS)
    parser.add_argument("--ffmpeg", default="")
    args = parser.parse_args()
    found = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")) + sorted(Path("D:/Tools/FFmpeg").glob("**/ffmpeg.exe"))
    ffmpeg = args.ffmpeg or (str(found[0]) if found else "ffmpeg")
    entries = [line.split("\t") for line in LIST.read_text(encoding="utf-8").splitlines() if line]
    _voice, _wpm, _pitch, chain, target = ch2.VOICES["corpse"]
    mapping = {"chunks": [], "syllables": {}}
    for old in DEST.glob("ch2_syllables_*.ogg*"):
        old.unlink()
    with tempfile.TemporaryDirectory(prefix="syllables_") as scratch:
        temp = Path(scratch)
        for chunk_index, begin in enumerate(range(0, len(entries), CHUNK_SYLLABLES)):
            samples, rate = array("h"), RATE
            for spelling, canon in entries[begin:begin + CHUNK_SYLLABLES]:
                piece, rate = render(args.tts, spelling, temp)
                gap = array("h", bytes(2 * int(GAP * rate)))
                samples.extend(gap)
                mapping["syllables"][canon] = [chunk_index, round(len(samples) / rate, 4), round(len(piece) / rate, 4)]
                samples.extend(piece)
            samples.extend(array("h", bytes(2 * int(GAP * rate))))
            raw = temp / "chunk.wav"
            with wave.open(str(raw), "wb") as file:
                file.setnchannels(1)
                file.setsampwidth(2)
                file.setframerate(rate)
                file.writeframes(samples.tobytes())
            shaped = temp / "shaped.wav"
            run(ffmpeg, ["-y", "-i", str(raw), "-af", chain, "-ar", str(RATE), "-ac", "1", "-c:a", "pcm_s16le", str(shaped)])
            measured = loudness(ffmpeg, shaped, target)
            norm = ("loudnorm=I=%d:TP=-2:LRA=7:linear=true:measured_I=%s:measured_TP=%s:measured_LRA=%s:"
                    "measured_thresh=%s:offset=%s" % (target, measured["input_i"], measured["input_tp"],
                                                     measured["input_lra"], measured["input_thresh"],
                                                     measured["target_offset"]))
            out = DEST / f"ch2_syllables_{chunk_index}.ogg"
            run(ffmpeg, ["-y", "-i", str(shaped), "-af", norm, "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1",
                         "-c:a", "libvorbis", "-q:a", "2", "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
            import_settings(out, False)
            mapping["chunks"].append("res://audio/voice/vi/" + out.name)
            # The rate eSpeak used may differ from RATE; offsets are in seconds.
            print(f"chunk {chunk_index}: {min(CHUNK_SYLLABLES, len(entries) - begin)} syllables, {out.stat().st_size} bytes", flush=True)
    MAP.write_text(json.dumps(mapping, ensure_ascii=False, indent=0) + "\n", encoding="utf-8")
    print(f"SYLLABLES RESULT: {len(mapping['syllables'])} syllables in {len(mapping['chunks'])} chunks")


if __name__ == "__main__":
    main()
