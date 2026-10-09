"""Chapter 2 voices (T-170): speaker, Minh Nhật, Ngư and every word of the
word chain, rendered with eSpeak NG like chapter 1 (ch1_voice_process.py).

Word clips (WORD_CH2_*) are one flat, slow, low "corpse" read; lane E (T-175)
shapes them per corpse at runtime. Lines come from
docs/design/ch2/build_ch2_script.py, texts from game/localization/strings.csv.

Run from the repo root:  py -3 audio_source/ch2_voice_process.py
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import wave

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from process import ROOT, RATE, import_settings, loudness, run  # noqa: E402
from voice_process import DEFAULT_TTS, read_lines  # noqa: E402
import ch1_voice_process as ch1  # noqa: E402

SOURCE = ROOT / "audio_source/voice_ch2"
DEST = ROOT / "game/audio/voice/vi"
SCRIPT = ROOT / "docs/design/ch2/build_ch2_script.py"
VOICES = dict(ch1.VOICES)
# The dead: slow, flat, low; quiet (owner likes quiet audio); lane E distorts.
VOICES["corpse"] = ("vi+m3", 104, 18, "highpass=f=120,lowpass=f=4800", -30)
# D-051: the call is about 25% faster in chapter 2 (owner: round-4 chat too slow).
for _who in ("minh_nhat", "ngu"):
    _voice, _wpm, _pitch, _chain, _target = VOICES[_who]
    VOICES[_who] = (_voice, round(_wpm * 1.25), _pitch, _chain, _target)


def load_lines() -> list:
    spec = importlib.util.spec_from_file_location("ch2_script", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    lines = []
    for kind, ident, who, _clock, _vi, _en in module.SCRIPT:
        if kind in ("spk", "rule", "room", "chat"):
            lines.append((module.key_of(kind, ident), who))
    for key in sorted(module.word_keys().values()):
        lines.append((key, "corpse"))
    return lines


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tts", type=Path, default=DEFAULT_TTS)
    parser.add_argument("--keys", nargs="+", help="Render only these script keys and merge their report entries")
    parser.add_argument("--ffmpeg", default="D:/Tools/ffmpeg/ffmpeg-9.0.2-essentials_build/bin/ffmpeg.exe")
    args = parser.parse_args()
    if not Path(args.ffmpeg).is_file():
        found = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")) + sorted(Path("D:/Tools/FFmpeg").glob("**/ffmpeg.exe"))
        args.ffmpeg = str(found[0]) if found else args.ffmpeg
    if not args.tts.is_file():
        parser.error("Extract eSpeak NG 1.52.0 under D:/Tools first (see voice/README.md)")
    texts = read_lines()
    lines = load_lines()
    if args.keys:
        unknown = set(args.keys) - {key for key, _who in lines}
        if unknown:
            parser.error("Unknown voiced script keys: " + ", ".join(sorted(unknown)))
        lines = [(key, who) for key, who in lines if key in args.keys]
    (SOURCE / "raw").mkdir(parents=True, exist_ok=True)
    DEST.mkdir(parents=True, exist_ok=True)
    report = {"engine": "eSpeak NG 1.52.0", "voices": {k: list(v[:3]) + [v[4]] for k, v in VOICES.items()}, "assets": []}
    report_path = SOURCE / "build_report.json"
    if args.keys and report_path.is_file():
        report = json.loads(report_path.read_text(encoding="utf-8"))
        report["assets"] = [entry for entry in report["assets"] if entry["key"] not in args.keys]
    with tempfile.TemporaryDirectory(prefix="processing_", dir=SOURCE) as scratch:
        temp = Path(scratch)
        for key, who in lines:
            voice, wpm, pitch, chain, target = VOICES[who]
            # T-205 lines are verbatim CSV, including their broken ellipses.
            text = texts[key]["vi"] if args.keys else ch1.clean(texts[key]["vi"])
            if not text.strip():
                raise ValueError("Missing Vietnamese line: " + key)
            if key == "CHAT_CH2_N_CAUGHT":
                # A slight tremor keeps the established voice while conveying panic.
                chain += ",vibrato=f=7:d=0.08"
            raw_tts = ch1.synthesize(args.tts, text, voice, wpm, pitch, temp)
            raw = SOURCE / "raw" / f"{key}.wav"
            raw.write_bytes(raw_tts.read_bytes())
            shaped = temp / "shaped.wav"
            run(args.ffmpeg, ["-y", "-i", str(raw), "-af",
                              chain + ",afade=t=in:d=0.005,areverse,afade=t=in:d=0.05,areverse",
                              "-ar", str(RATE), "-ac", "1", "-c:a", "pcm_s16le", str(shaped)])
            measured = loudness(args.ffmpeg, shaped, target)
            norm = ("loudnorm=I=%d:TP=-2:LRA=7:linear=true:measured_I=%s:measured_TP=%s:measured_LRA=%s:"
                    "measured_thresh=%s:offset=%s" % (target, measured["input_i"], measured["input_tp"],
                                                     measured["input_lra"], measured["input_thresh"],
                                                     measured["target_offset"]))
            out = DEST / f"{key}.ogg"
            run(args.ffmpeg, ["-y", "-i", str(shaped), "-af", norm, "-ar", str(RATE), "-ac", "1",
                              "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", "4",
                              "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
            actual = loudness(args.ffmpeg, out, target)
            # Two-syllable words are too short for a strict integrated reading.
            tolerance = 3.0 if who == "corpse" else 1.5
            if abs(float(actual["input_i"]) - target) > tolerance or float(actual["input_tp"]) > -1:
                raise RuntimeError(f"Voice mastering failed: {key} {actual}")
            import_settings(out, False)
            with wave.open(str(raw), "rb") as file:
                seconds = file.getnframes() / file.getframerate()
            report["assets"].append({"key": key, "who": who, "text": text, "file": out.relative_to(ROOT).as_posix(),
                                     "seconds": round(seconds, 3), "lufs": float(actual["input_i"]),
                                     "true_peak_db": float(actual["input_tp"]),
                                     "target_lufs": target, "processing": chain,
                                     "raw_sha256": hashlib.sha256(raw.read_bytes()).hexdigest(),
                                     "sha256": hashlib.sha256(out.read_bytes()).hexdigest()})
            print(f"{key} [{who}]: {actual['input_i']} LUFS, {seconds:.2f} s", flush=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    # Lines and words the script no longer has (D-049: traps, the old Ngư call).
    made = {a["key"] for a in report["assets"]}
    for prefix in ("SPK_CH2_", "RULE_CH2_", "ROOM_CH2_", "CHAT_CH2_", "WORD_CH2_"):
        for old in list(DEST.glob(prefix + "*.ogg")) + list((SOURCE / "raw").glob(prefix + "*.wav")):
            if not args.keys and old.stem not in made:
                old.unlink()
                Path(str(old) + ".import").unlink(missing_ok=True)
                print("removed", old.name)
    total = sum((DEST / (a["key"] + ".ogg")).stat().st_size for a in report["assets"])
    print(f"VOICE CH2 RESULT: {len(lines)} rendered; {len(report['assets'])} reported; OGG = {total} bytes")


if __name__ == "__main__":
    main()
