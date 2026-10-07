"""T-200: 16 approved Chapter 4 lines, read verbatim from strings.csv (D-068).

Render offline with existing eSpeak NG; never voice Trung or rewrite dialogue.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import wave
sys.dont_write_bytecode = True
from process import ROOT, RATE, import_settings, loudness, run
from voice_process import DEFAULT_TTS, read_lines
import ch1_voice_process as ch1
import ch3_voice_process as ch3

SOURCE = ROOT / "audio_source/voice_ch4"
DEST = ROOT / "game/audio/voice/vi"
VOICES = {
    "pa": (*ch1.VOICES["loa"][:4], -33),
    "nurse1": ("vi+f1", 145, 54, ch1.CLEAN, -34),
    "nurse2": ("vi+f3", 150, 62, ch1.CLEAN, -34),
    "minh_nhat": ch3.VOICES["minh_nhat"],
    "ngu": ch3.VOICES["ngu"],
}
LINES = [
    ("SPK_CH4_REGISTERED", "pa"),
    *[("CHAT_CH4_" + suffix, "ngu") for suffix in ("NGU_GO", "NGU_LECTURE", "NGU_NO_EXIT", "NGU_TRUNG")],
    *[("CHAT_CH4_" + suffix, "minh_nhat") for suffix in ("N_GO", "N_GYM", "N_LINE", "N_WHERE", "N_LOST", "N_GOT")],
    ("NEAR_CH4_NURSE1_AWAKE", "nurse1"),
    ("NEAR_CH4_NURSE1_LUCKY", "nurse1"),
    ("NEAR_CH4_NURSE2_QUAKE", "nurse2"),
    ("NEAR_CH4_NURSE2_ALL", "nurse2"),
    ("NEAR_CH4_NURSE2_ALONE", "nurse2"),
]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tts", type=Path, default=DEFAULT_TTS)
    args = parser.parse_args()
    if not args.tts.is_file():
        parser.error("Existing eSpeak NG tool missing; no automatic installation")
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    texts = read_lines()
    (SOURCE / "raw").mkdir(parents=True, exist_ok=True)
    DEST.mkdir(parents=True, exist_ok=True)
    report = {"engine": "eSpeak NG 1.52.0", "source": "game/localization/strings.csv", "approval": "D-068 / CH4_SCRIPT.md", "voices": {k: list(v[:3]) + [v[4]] for k, v in VOICES.items()}, "assets": []}
    with tempfile.TemporaryDirectory(prefix="processing_", dir=SOURCE) as scratch:
        temp = Path(scratch)
        for key, who in LINES:
            text = texts[key]["vi"]
            if not text.strip():
                raise ValueError(f"Missing Vietnamese line: {key}")
            voice, wpm, pitch, chain, target = VOICES[who]
            raw_tts = ch1.synthesize(args.tts, text, voice, wpm, pitch, temp)
            raw = SOURCE / "raw" / f"{key}.wav"
            raw.write_bytes(raw_tts.read_bytes())
            shaped = temp / "shaped.wav"
            run(ffmpeg, ["-i", str(raw), "-af", chain + ",afade=t=in:d=0.005,areverse,afade=t=in:d=0.05,areverse", "-ar", str(RATE), "-ac", "1", str(shaped)])
            gain = target - float(loudness(ffmpeg, shaped, target)["input_i"])
            out = DEST / f"{key}.ogg"
            for attempt in range(3):
                # Catch isolated TTS transients before encoding; remeasure the OGG.
                run(ffmpeg, ["-i", str(shaped), "-af", f"volume={gain:.6f}dB,alimiter=limit=0.63:level=false:latency=true", "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", "4", "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
                actual = loudness(ffmpeg, out, target)
                delta = target - float(actual["input_i"])
                if abs(delta) <= .5:
                    break
                gain += delta
            if abs(float(actual["input_i"]) - target) > 1 or float(actual["input_tp"]) > -2:
                raise RuntimeError(f"Voice mastering failed: {key}: {actual}")
            import_settings(out, False)
            with wave.open(str(raw), "rb") as file:
                seconds = file.getnframes() / file.getframerate()
            report["assets"].append(dict(key=key, who=who, text=text, seconds=round(seconds, 3), file=out.relative_to(ROOT).as_posix(),
                target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest()))
            print(f"{key} [{who}]: {actual['input_i']} LUFS; {seconds:.2f}s", flush=True)
    (SOURCE / "build_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"VOICE CH4 RESULT: {len(report['assets'])} clips validated")


if __name__ == "__main__":
    main()
