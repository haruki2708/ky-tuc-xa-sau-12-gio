"""Read-only T-178 loudness comparison; never rebuilds core's syllable banks."""
from __future__ import annotations

from array import array
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import wave

sys.dont_write_bytecode = True
from process import ROOT, SOURCE, loudness, run

WORDS = [
    ("học sinh", "HOC_SINH"), ("sinh viên", "SINH_VIEN"),
    ("viên phấn", "VIEN_PHAN"), ("phấn đấu", "PHAN_DAU"),
    ("đấu tranh", "DAU_TRANH"), ("tranh luận", "TRANH_LUAN"),
    ("luận văn", "LUAN_VAN"), ("văn học", "VAN_HOC"),
]
RATE, PITCH = 44100, .72


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    mapping = json.loads((ROOT / "game/data/ch2/corpse_syllables.json").read_text(encoding="utf-8"))
    spelling = dict(line.split("\t") for line in (ROOT / "game/data/ch2/corpse_syllables.txt").read_text(encoding="utf-8").splitlines() if line)
    report = {"note": "Independent FFmpeg cut/fade comparison before shared runtime distortion; not a listening test.",
              "pitch": PITCH, "player_gain_db": -6, "gap_seconds": .08, "fade_seconds": .005,
              "source_sha256": {}, "words": []}
    for file in [ROOT / "game" / path.removeprefix("res://") for path in mapping["chunks"]]:
        report["source_sha256"][file.relative_to(ROOT).as_posix()] = hashlib.sha256(file.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory(prefix="syllable_audit_", dir=SOURCE) as scratch:
        temp = Path(scratch).resolve()
        assert temp.is_relative_to(SOURCE.resolve())
        for text, key in WORDS:
            joined = array("h")
            for i, syllable in enumerate(text.split()):
                chunk, start, length = mapping["syllables"][spelling[syllable]]
                source = ROOT / "game" / mapping["chunks"][chunk].removeprefix("res://")
                raw = run(ffmpeg, ["-i", str(source), "-af", f"atrim=start={start}:duration={length},asetpts=PTS-STARTPTS",
                                   "-ar", str(RATE), "-ac", "1", "-f", "s16le", "-"]).stdout
                samples = array("h", raw)
                if sys.byteorder != "little":
                    samples.byteswap()
                fade = round(.005 * PITCH * RATE)
                for frame in range(len(samples)):
                    samples[frame] = round(samples[frame] * min(1., frame / fade, (len(samples) - 1 - frame) / fade))
                joined.extend(samples)
                if i == 0:
                    joined.extend(array("h", [0]) * round(.08 * PITCH * RATE))
            wav = temp / "phrase.wav"
            with wave.open(str(wav), "wb") as output:
                output.setnchannels(1)
                output.setsampwidth(2)
                output.setframerate(RATE)
                if sys.byteorder != "little":
                    joined.byteswap()
                output.writeframes(joined.tobytes())
            # Same pitch and -6 dB source gain for both; private bus unchanged.
            filters = f"aresample={RATE},asetrate={RATE * PITCH},aresample={RATE},volume=-6dB,"
            assembled = loudness(ffmpeg, wav, -30, filters)
            whole = loudness(ffmpeg, ROOT / "game/audio/voice/vi" / f"WORD_CH2_{key}.ogg", -30, filters)
            entry = {"text": text, "whole_key": f"WORD_CH2_{key}", "syllable_lufs": float(assembled["input_i"]),
                     "whole_lufs": float(whole["input_i"]), "syllable_peak_db": float(assembled["input_tp"])}
            entry["delta_lu"] = round(entry["syllable_lufs"] - entry["whole_lufs"], 2)
            report["words"].append(entry)
            print(f"{text}: syllables {entry['syllable_lufs']} LUFS, whole {entry['whole_lufs']} LUFS, delta {entry['delta_lu']} LU", flush=True)
    report["mean_delta_lu"] = round(sum(x["delta_lu"] for x in report["words"]) / len(WORDS), 2)
    (SOURCE / "ch2/syllable_audit.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"SYLLABLE AUDIT: {len(WORDS)} comparisons; mean delta {report['mean_delta_lu']} LU")


if __name__ == "__main__":
    main()
