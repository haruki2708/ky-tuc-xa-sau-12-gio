"""Chapter 1 voices (T-159, Claude làm thay): render every spoken line of the
chapter-1 script with eSpeak NG (offline, commercial use OK; D-006, as T-137),
one voice per character, then master OGGs into game/audio/voice/vi/.

Lines and speakers come from docs/design/ch1/build_ch1_script.py, texts from
game/localization/strings.csv. English builds reuse the Vietnamese voice with
English subtitles (D-006); the game falls back to vi/ for missing en/ clips.

Run from the repo root:  py -3 audio_source/ch1_voice_process.py
"""
from __future__ import annotations

import argparse
from array import array
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import wave

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from process import ROOT, RATE, import_settings, loudness, run  # noqa: E402
from voice_process import DEFAULT_TTS, read_lines  # noqa: E402

SOURCE = ROOT / "audio_source/voice_ch1"
DEST = ROOT / "game/audio/voice/vi"
SCRIPT = ROOT / "docs/design/ch1/build_ch1_script.py"

# who -> (eSpeak voice, words per minute, pitch 0-99, ffmpeg chain, target LUFS)
PA = ("highpass=f=300,lowpass=f=3400,asoftclip=type=tanh:threshold=0.6:output=0.85,"
      "aecho=0.85:0.75:47|89|137:0.13|0.08|0.04")
CLEAN = "highpass=f=90,lowpass=f=7000"
VOICES = {
    "loa": ("vi+m1", 132, 30, PA, -26),
    "mgr": ("vi+m3", 112, 20, "asetrate=22050*0.8,aresample=22050,lowpass=f=4200,"
            "asoftclip=type=tanh:threshold=0.7:output=0.9", -27),
    "minh_nhat": ("vi+m2", 150, 46, CLEAN, -26),
    "hung": ("vi+m4", 172, 56, CLEAN, -26),
    "dang": ("vi+m6", 178, 38, CLEAN, -25),
    "bao": ("vi+m5", 140, 66, CLEAN + ",vibrato=f=6:d=0.25", -27),
    "son": ("vi+m1", 128, 34, CLEAN, -27),
    "kiet": ("vi+m7", 162, 58, CLEAN, -26),
    "tung": ("vi+m8", 176, 50, CLEAN, -26),
    "vinh": ("vi+m2", 166, 40, CLEAN, -26),
    "ngu": ("vi+f2", 150, 58, CLEAN, -26),
    # Roommates grumbling in the dark room: quiet and soft (owner likes quiet audio).
    "phuc": ("vi+m4", 128, 44, "lowpass=f=5000", -32),
    "dat": ("vi+m5", 122, 40, "lowpass=f=5000", -32),
    "viet": ("vi+m3", 126, 48, "lowpass=f=5000", -32),
    # Việt's voice through the closed door.
    "viet_door": ("vi+m3", 120, 48, "lowpass=f=1100,aecho=0.8:0.6:28:0.25", -33),
}
# Non-verbal lines get a spoken stand-in (the subtitle keeps the stage text).
SPOKEN_OVERRIDES = {"MGR_CH1_LAUGH": "Khà… khà… khà."}


def load_script() -> list:
    spec = importlib.util.spec_from_file_location("ch1_script", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    lines = []
    for kind, ident, who, _clock, _vi, _en in module.SCRIPT:
        if kind in ("spk", "rule", "mgr", "room", "chat"):
            lines.append((module.key_of(kind, ident), who))
    return lines


def clean(text: str) -> str:
    text = re.sub(r"\([^)]*\)", "", text)
    return re.sub(r"\s+", " ", text).strip()


def synthesize(tts: Path, text: str, voice: str, wpm: int, pitch: int, temp: Path) -> Path:
    text_path, wav_path = temp / "input.txt", temp / "raw.wav"
    text_path.write_text(text, encoding="utf-8")
    env = dict(os.environ, ESPEAK_DATA_PATH=str(tts.parent / "espeak-ng-data"))
    subprocess.run([str(tts), f"--path={tts.parent}", "-v", voice, "-s", str(wpm), "-p", str(pitch),
                    "-a", "100", "-b", "1", "-f", str(text_path), "-w", str(wav_path)],
                   env=env, cwd=tts.parent, capture_output=True, check=True)
    with wave.open(str(wav_path), "rb") as file:
        if file.getnframes() == 0:
            raise RuntimeError("TTS produced empty speech: " + text)
    return wav_path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tts", type=Path, default=DEFAULT_TTS)
    parser.add_argument("--ffmpeg", default="D:/Tools/ffmpeg/ffmpeg-9.0.2-essentials_build/bin/ffmpeg.exe")
    args = parser.parse_args()
    if not Path(args.ffmpeg).is_file():
        found = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe"))
        args.ffmpeg = str(found[0]) if found else args.ffmpeg
    if not args.tts.is_file():
        parser.error("Extract eSpeak NG 1.52.0 under D:/Tools first (see voice/README.md)")
    texts = read_lines()
    (SOURCE / "raw").mkdir(parents=True, exist_ok=True)
    DEST.mkdir(parents=True, exist_ok=True)
    report = {"engine": "eSpeak NG 1.52.0", "voices": {k: list(v[:3]) + [v[4]] for k, v in VOICES.items()}, "assets": []}
    with tempfile.TemporaryDirectory(prefix="processing_", dir=SOURCE) as scratch:
        temp = Path(scratch)
        for key, who in load_script():
            voice, wpm, pitch, chain, target = VOICES[who]
            text = SPOKEN_OVERRIDES.get(key) or clean(texts[key]["vi"])
            raw_tts = synthesize(args.tts, text, voice, wpm, pitch, temp)
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
            if abs(float(actual["input_i"]) - target) > 1.5 or float(actual["input_tp"]) > -1:
                raise RuntimeError(f"Voice mastering failed: {key} {actual}")
            import_settings(out, False)
            with wave.open(str(raw), "rb") as file:
                seconds = file.getnframes() / file.getframerate()
            report["assets"].append({"key": key, "who": who, "text": text, "file": out.relative_to(ROOT).as_posix(),
                                     "seconds": round(seconds, 3), "lufs": float(actual["input_i"]),
                                     "true_peak_db": float(actual["input_tp"]),
                                     "sha256": hashlib.sha256(out.read_bytes()).hexdigest()})
            print(f"{key} [{who}]: {actual['input_i']} LUFS, {seconds:.2f} s", flush=True)
    (SOURCE / "build_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for p in (SOURCE / "raw").glob("*.wav")) + sum(
        (DEST / (a["key"] + ".ogg")).stat().st_size for a in report["assets"])
    if total >= 20_000_000:
        raise RuntimeError(f"Chapter 1 voice bank exceeds 20 MB: {total}")
    print(f"VOICE CH1 RESULT: {len(report['assets'])} lines; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
