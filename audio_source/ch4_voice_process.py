"""T-198: render only verbatim CH4_DESIGN lines; core keys remain external.

Output IDs are asset IDs, NOT invented localization keys. Both ending lines
have both nurse variants because the design does not assign their speaker.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import sys
import tempfile
sys.dont_write_bytecode = True
from process import ROOT, RATE, import_settings, loudness, run
from voice_process import DEFAULT_TTS, read_lines
import ch1_voice_process as ch1

SOURCE = ROOT / "audio_source/voice_ch4"
DEST = ROOT / "game/audio/ch4_voice"
VOICES = {
    "pa": (*ch1.VOICES["loa"][:4], -33),
    "nurse1": ("vi+f1", 145, 54, ch1.CLEAN, -34),
    "nurse2": ("vi+f3", 150, 62, ch1.CLEAN, -34),
}
LINES = [
    ("pa_signed", "pa", "Trần Trung đã đăng ký thành công. Bạn là người sống sót."),
    ("nurse1_wake", "nurse1", "Tỉnh rồi! Cậu nằm yên, đừng cử động."),
    ("nurse2_quake", "nurse2", "Động đất đó cậu. Trường cậu gần tâm chấn lắm. Lúc cứu ra cậu còn thở, coi như mạng lớn."),
    *[(f"{who}_{ending}", who, text) for ending, text in [
        ("all", "Hai bạn kia vẫn đang hôn mê. Nhưng ổn rồi."),
        ("alone", "Chỉ có cậu được cứu ra từ tòa đó."),
    ] for who in ("nurse1", "nurse2")],
]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tts", type=Path, default=DEFAULT_TTS)
    args = parser.parse_args()
    if not args.tts.is_file():
        parser.error("Existing eSpeak NG tool missing; no automatic installation")
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    design = (ROOT / "docs/design/CH4_DESIGN.md").read_text(encoding="utf-8")
    texts = read_lines()
    (SOURCE / "raw").mkdir(parents=True, exist_ok=True)
    DEST.mkdir(parents=True, exist_ok=True)
    report = {"engine": "eSpeak NG 1.52.0", "source": "docs/design/CH4_DESIGN.md", "voices": {k: list(v[:3]) + [v[4]] for k, v in VOICES.items()}, "assets": []}
    with tempfile.TemporaryDirectory(prefix="processing_", dir=SOURCE) as scratch:
        temp = Path(scratch)
        for ident, who, text in LINES:
            if text not in design:
                raise ValueError(f"Design text changed: {ident}; review before regenerating")
            voice, wpm, pitch, chain, target = VOICES[who]
            raw_tts = ch1.synthesize(args.tts, text, voice, wpm, pitch, temp)
            raw = SOURCE / "raw" / f"{ident}.wav"
            raw.write_bytes(raw_tts.read_bytes())
            shaped = temp / "shaped.wav"
            run(ffmpeg, ["-i", str(raw), "-af", chain + ",afade=t=in:d=0.005,areverse,afade=t=in:d=0.05,areverse", "-ar", str(RATE), "-ac", "1", str(shaped)])
            gain = target - float(loudness(ffmpeg, shaped, target)["input_i"])
            out = DEST / f"{ident}.ogg"
            for attempt in range(3):
                run(ffmpeg, ["-i", str(shaped), "-af", f"volume={gain:.6f}dB", "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", "4", "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
                actual = loudness(ffmpeg, out, target)
                delta = target - float(actual["input_i"])
                if abs(delta) <= .5:
                    break
                gain += delta
            if abs(float(actual["input_i"]) - target) > 1 or float(actual["input_tp"]) > -2:
                raise RuntimeError(f"Voice mastering failed: {ident}: {actual}")
            import_settings(out, False)
            prefix = "SPK_CH4_" if who == "pa" else "NEAR_CH4_NURSE_"
            keys = sorted(k for k, row in texts.items() if k.startswith(prefix) and ch1.clean(row["vi"]) == text)
            report["assets"].append(dict(id=ident, who=who, text=text, core_keys=keys, file=out.relative_to(ROOT).as_posix(),
                target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest()))
            print(f"{ident}: {actual['input_i']} LUFS; matching core keys: {keys}", flush=True)
    (SOURCE / "build_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"VOICE CH4 RESULT: {len(report['assets'])} clips validated")


if __name__ == "__main__":
    main()
