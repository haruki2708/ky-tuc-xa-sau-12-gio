"""T-212: deterministic original fire bell; no external recordings."""
from __future__ import annotations

import sys
sys.dont_write_bytecode = True
from array import array
import hashlib
import json
import math
from pathlib import Path
import shutil

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from process import RATE, ROOT, import_settings, loudness, run, write_wav

HERE = Path(__file__).resolve().parent
TARGET = -36
SECONDS = 4.0


def synthesize() -> list[float]:
    # Periodic strike ages include the previous cycle's decaying resonance.
    partials = ((840, 1.0), (1325, .43), (1870, .22), (2535, .09))
    values = []
    for index in range(round(SECONDS * RATE)):
        t = index / RATE
        value = 0.0
        for strike in range(16):
            age = (t - strike * .25) % SECONDS
            envelope = (1.0 - math.exp(-age / .003)) * math.exp(-age / .085)
            strength = 1.0 if strike % 2 == 0 else .85
            value += strength * envelope * sum(
                weight * math.sin(math.tau * frequency * age)
                for frequency, weight in partials
            )
        values.append(value * .3)
    return values


def main() -> None:
    candidates = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe"))
    ffmpeg = shutil.which("ffmpeg") or (str(candidates[0]) if candidates else None)
    if not ffmpeg:
        raise RuntimeError("Use the existing portable FFmpeg in D:/Tools/ffmpeg")
    raw = HERE / "raw/fire_bell_soft.wav"
    out = ROOT / "game/audio/graphics_upgrade/fire_bell_soft.ogg"
    raw.parent.mkdir(parents=True, exist_ok=True)
    out.parent.mkdir(parents=True, exist_ok=True)
    write_wav(raw, synthesize())
    gain = TARGET - float(loudness(ffmpeg, raw, TARGET)["input_i"])
    for _attempt in range(3):
        run(ffmpeg, ["-i", str(raw), "-af", f"volume={gain:.6f}dB",
                     "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1",
                     "-c:a", "libvorbis", "-q:a", "4", "-fflags", "+bitexact",
                     "-flags:a", "+bitexact", str(out)])
        measured = loudness(ffmpeg, out, TARGET)
        delta = TARGET - float(measured["input_i"])
        if abs(delta) <= .5:
            break
        gain += delta
    pcm = array("f", run(ffmpeg, ["-i", str(out), "-f", "f32le", "-ac", "1",
                                  "-ar", str(RATE), "-"]).stdout)
    if sys.byteorder != "little":
        pcm.byteswap()
    entry = dict(file=out.relative_to(ROOT).as_posix(), seconds=len(pcm) / RATE,
                 sample_rate=RATE, channels=1, loop=False, target_lufs=TARGET,
                 lufs=float(measured["input_i"]), true_peak_db=float(measured["input_tp"]),
                 boundary_delta=abs(pcm[0] - pcm[-1]), bytes=out.stat().st_size,
                 raw_bytes=raw.stat().st_size, sha256=hashlib.sha256(out.read_bytes()).hexdigest(),
                 raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest())
    if (abs(entry["lufs"] - TARGET) > 1 or entry["true_peak_db"] > -2
            or entry["boundary_delta"] > .01 or abs(entry["seconds"] - SECONDS) > .01
            or max(entry["bytes"], entry["raw_bytes"]) > 10_000_000):
        raise RuntimeError(entry)
    # Keep the production candidate finite: core currently awaits finished.
    import_settings(out, False)
    report = dict(ffmpeg=run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0],
                  assets=[entry], listening_status="pending_owner_listening")
    (HERE / "build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(entry, indent=2))
    print("RESULT: fire bell signal validation PASS; listening pending")


if __name__ == "__main__":
    main()
