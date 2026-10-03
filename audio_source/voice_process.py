"""Render the approved CSV lines locally with eSpeak NG, then master old-PA OGGs."""
from __future__ import annotations

import argparse
from array import array
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import tempfile
import wave

sys.dont_write_bytecode = True
from process import ROOT, RATE, import_settings, loudness, run, write_wav

KEYS = ["RULE_HEADER_5", "RULE_1", "RULE_2", "RULE_3_GARBLED", "RULE_4", "RULE_5",
        "SPK_SIGN_LOG", "SPK_ROLLCALL_INTRO", "SPK_CHECK_TAPS", "SPK_NAME_PHUC",
        "SPK_NAME_VIET", "SPK_NAME_TRUNG", "SPK_NAME_DAT", "SPK_NAME_LAM",
        "SPK_NAME_TRUNG_AGAIN", "SPK_AND_ONE_MORE", "SPK_AND_TRUNG"]
SOURCE = ROOT / "audio_source/voice"
DEST = ROOT / "game/audio/voice"
DEFAULT_TTS = Path("D:/Tools/espeak-ng/1.52.0/portable/SourceDir/eSpeak NG/espeak-ng.exe")


def clean_text(text: str) -> str:
    text = re.sub(r"\([^)]*\)", "", text)
    text = re.sub(r"^\s*(?:Loa|Speaker)\s*:\s*", "", text)
    return re.sub(r"\s+", " ", text).strip()


def read_lines() -> dict:
    with (ROOT / "game/localization/strings.csv").open(encoding="utf-8-sig", newline="") as file:
        rows = list(csv.reader(file))
    header = rows[0]
    return {row[0]: {locale: row[header.index(locale)] for locale in ("vi", "en")}
            for row in rows[1:] if row and row[0]}


def parts_for(key: str, locale: str, lines: dict) -> list[tuple[str, str]]:
    if key.startswith("SPK_NAME_"):
        return [(clean_text(lines[key]["vi"]), "vi")]
    text = clean_text(lines["RULE_3" if key == "RULE_3_GARBLED" else key][locale])
    if key == "RULE_3_GARBLED":
        # Cut at the CSV punctuation separating the audible premise and hidden action.
        separator = ":" if locale == "vi" else ","
        premise, action = text.split(separator, 1)
        return [(premise + separator, locale), (action.strip(), locale)]
    if key == "SPK_AND_TRUNG" and locale == "en":
        name = clean_text(lines["SPK_NAME_TRUNG"]["vi"]).rstrip(".")
        before, after = text.split(name, 1)
        return [(before.strip(), "en"), (name, "vi"), (after.strip(), "en")]
    return [(text, locale)]


def synthesize(tts: Path, text: str, locale: str, slow: bool, temp: Path) -> tuple[array, int]:
    text_path, wav_path = temp / "input.txt", temp / "part.wav"
    text_path.write_text(text, encoding="utf-8")
    env = dict(os.environ, ESPEAK_DATA_PATH=str(tts.parent / "espeak-ng-data"))
    subprocess.run([str(tts), f"--path={tts.parent}", "-v", "vi" if locale == "vi" else "en-gb",
                    "-s", "95" if slow else "145", "-p", "42", "-a", "100", "-b", "1",
                    "-f", str(text_path), "-w", str(wav_path)], env=env, cwd=tts.parent,
                   capture_output=True, check=True)
    with wave.open(str(wav_path), "rb") as file:
        if file.getnchannels() != 1 or file.getsampwidth() != 2:
            raise RuntimeError("Expected mono PCM16 from eSpeak")
        rate = file.getframerate()
        pcm = array("h", file.readframes(file.getnframes()))
    if sys.byteorder != "little":
        pcm.byteswap()
    if not pcm or max(abs(v) for v in pcm) == 0:
        raise RuntimeError("TTS produced empty speech")
    return pcm, rate


def mask_and_hiss(samples: list[float], hidden_from: int | None, seed: int) -> list[float]:
    """Hidden speech gain is exactly zero BEFORE adding static, including reverb tails."""
    rng = random.Random(seed)
    low = high = 0.0
    result: list[float] = []
    for i, sample in enumerate(samples):
        noise = rng.uniform(-1, 1)
        low += (1 - math.exp(-math.tau * 300 / RATE)) * (noise - low)
        high += (1 - math.exp(-math.tau * 3400 / RATE)) * (noise - high)
        hiss = high - low
        mix = 0.0 if hidden_from is None else min(1.0, max(0.0, (i - hidden_from + 480) / 480))
        # No original sample contribution remains from hidden_from onward.
        value = sample * (1 - mix) + hiss * (.0007 + .19 * mix)
        edge = min(1.0, i / 240, (len(samples) - 1 - i) / 2400)
        result.append(value * max(0.0, edge))
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tts", type=Path, default=DEFAULT_TTS)
    parser.add_argument("--ffmpeg", default="D:/Tools/ffmpeg/ffmpeg-9.0.2-essentials_build/bin/ffmpeg.exe")
    args = parser.parse_args()
    if not args.tts.is_file():
        parser.error("Extract eSpeak NG 1.52.0 under D:/Tools first (see voice/README.md)")
    env = dict(os.environ, ESPEAK_DATA_PATH=str(args.tts.parent / "espeak-ng-data"))
    version = subprocess.run([str(args.tts), f"--path={args.tts.parent}", "--version"], env=env,
                             capture_output=True, check=True).stdout.decode().split("  Data at:")[0].strip()
    if "1.52.0" not in version:
        parser.error("Reproduction requires pinned eSpeak NG 1.52.0")
    lines = read_lines()
    SOURCE.mkdir(parents=True, exist_ok=True)
    report = {"engine": version, "engine_sha256": hashlib.sha256(args.tts.read_bytes()).hexdigest(),
              "ffmpeg": run(args.ffmpeg, ["-version"]).stdout.decode().splitlines()[0],
              "target_lufs": -26, "assets": []}
    with tempfile.TemporaryDirectory(prefix="processing_", dir=SOURCE) as scratch:
        temp = Path(scratch)
        for locale in ("vi", "en"):
            (SOURCE / "raw" / locale).mkdir(parents=True, exist_ok=True)
            (DEST / locale).mkdir(parents=True, exist_ok=True)
            for key in KEYS:
                parts = parts_for(key, locale, lines)
                combined = array("h")
                hidden_from = None
                rate = 22050
                for index, (text, language) in enumerate(parts):
                    pcm, rate = synthesize(args.tts, text, language, key == "SPK_NAME_TRUNG_AGAIN", temp)
                    if key == "RULE_3_GARBLED" and index == 1:
                        hidden_from = len(combined) / rate
                    combined.extend(pcm)
                raw = SOURCE / "raw" / locale / f"{key}.wav"
                if sys.byteorder != "little":
                    combined.byteswap()
                with wave.open(str(raw), "wb") as file:
                    file.setparams((1, 2, rate, 0, "NONE", "not compressed"))
                    file.writeframes(combined.tobytes())
                decoded = run(args.ffmpeg, ["-i", str(raw), "-af",
                    "highpass=f=300,lowpass=f=3400,asoftclip=type=tanh:threshold=0.65:output=0.85,"
                    "aecho=0.85:0.75:47|89|137:0.13|0.08|0.04",
                    "-f", "f32le", "-ac", "1", "-ar", str(RATE), "-"])
                pcm_float = array("f", decoded.stdout)
                if sys.byteorder != "little":
                    pcm_float.byteswap()
                seed = int.from_bytes(hashlib.sha256(f"{locale}/{key}".encode()).digest()[:4], "little")
                masked = mask_and_hiss(list(pcm_float), round(hidden_from * RATE) if hidden_from is not None else None, seed)
                prepared = temp / "prepared.wav"
                write_wav(prepared, masked)
                measured = loudness(args.ffmpeg, prepared, -26)
                norm = ("loudnorm=I=-26:TP=-2:LRA=7:linear=true:"
                        f"measured_I={measured['input_i']}:measured_TP={measured['input_tp']}:"
                        f"measured_LRA={measured['input_lra']}:measured_thresh={measured['input_thresh']}:"
                        f"offset={measured['target_offset']}")
                out = DEST / locale / f"{key}.ogg"
                correction = 0.0
                for attempt in range(3):
                    run(args.ffmpeg, ["-i", str(prepared), "-af", f"{norm},volume={correction:.4f}dB",
                        "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", "4",
                        "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
                    actual = loudness(args.ffmpeg, out, -26)
                    delta = -26 - float(actual["input_i"])
                    if abs(delta) <= .5:
                        break
                    correction += min(delta, -2 - float(actual["input_tp"]))
                if abs(float(actual["input_i"]) + 26) > 1 or float(actual["input_tp"]) > -1:
                    raise RuntimeError(f"Voice mastering failed: {key} {actual}")
                import_settings(out, False)
                entry = {"file": out.relative_to(ROOT).as_posix(), "locale": locale, "key": key,
                         "spoken_parts": [{"text": text, "voice": voice} for text, voice in parts],
                         "speed_wpm": 95 if key == "SPK_NAME_TRUNG_AGAIN" else 145,
                         "sha256": hashlib.sha256(out.read_bytes()).hexdigest(),
                         "raw_sha256": hashlib.sha256(raw.read_bytes()).hexdigest(),
                         "seconds": round(len(masked) / RATE, 4), "lufs": float(actual["input_i"]),
                         "true_peak_db": float(actual["input_tp"]), "loop": False,
                         "hidden_from_seconds": hidden_from, "hidden_speech_gain": 0 if hidden_from is not None else None}
                report["assets"].append(entry)
                print(f"{locale}/{key}: {entry['lufs']} LUFS, {entry['seconds']} s", flush=True)
    (SOURCE / "build_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for p in (SOURCE / "raw").rglob("*.wav")) + sum(p.stat().st_size for p in DEST.rglob("*.ogg"))
    if total >= 20_000_000:
        raise RuntimeError(f"Voice bank exceeds 20 MB: {total}")
    print(f"VOICE RESULT: {len(report['assets'])} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
