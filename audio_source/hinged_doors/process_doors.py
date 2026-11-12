"""T-244: four quiet, original synthesized door sounds, using stdlib and FFmpeg."""
from __future__ import annotations

import sys
sys.dont_write_bytecode = True
import hashlib
import json
import math
from pathlib import Path
import random
import shutil
from array import array

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from process import RATE, ROOT, import_settings, loudness, run, write_wav

HERE = Path(__file__).resolve().parent
ASSETS = ("wood_open", "wood_close", "aluminium_glass_open", "aluminium_glass_close")


def synthesize(name: str, seed: int) -> list[float]:
    rng = random.Random(seed)
    opening = name.endswith("open")
    wood = name.startswith("wood")
    seconds = 0.50 if opening else 0.65
    values: list[float] = []
    low_noise = 0.0
    phase = 0.0
    for index in range(round(seconds * RATE)):
        t = index / RATE
        noise = rng.uniform(-1, 1)
        low_noise += 0.08 * (noise - low_noise)
        if opening:
            envelope = math.sin(math.pi * t / seconds) ** 2
            frequency = (185 if wood else 620) + (35 if wood else 18) * math.sin(19 * t)
            phase += math.tau * frequency / RATE
            # Wood: low friction and an uneven hinge; aluminium: a short, dry rub.
            value = envelope * (0.22 * low_noise + (0.09 if wood else 0.025) * math.sin(phase)
                                + 0.015 * math.sin(phase * 2.07))
        else:
            value = 0.0
            # A padded frame contact followed by the small latch, without a slam.
            for start, strength in ((0.015, 1.0), (0.12, 0.32)):
                age = t - start
                if age < 0:
                    continue
                attack = 1.0 - math.exp(-age / 0.004)
                value += strength * attack * math.exp(-age / 0.035) * low_noise
                partials = ((145, 0.22), (310, 0.10), (490, 0.035)) if wood else (
                    (760, 0.08), (1287, 0.035), (2143, 0.015))
                for frequency, weight in partials:
                    value += strength * attack * math.exp(-age / (0.045 if wood else 0.075)) * weight * math.sin(math.tau * frequency * age)
        fade = min(1.0, t / 0.008, (seconds - t) / 0.06)
        values.append(value * fade)
    return values


def main() -> None:
    candidates = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe"))
    ffmpeg = shutil.which("ffmpeg") or (str(candidates[0]) if candidates else None)
    if not ffmpeg:
        raise RuntimeError("Use the existing portable FFmpeg in D:/Tools/ffmpeg")
    entries = []
    for index, name in enumerate(ASSETS):
        target = -36 if name.endswith("open") else -42
        raw = HERE / f"raw/{name}.wav"
        out = ROOT / f"game/audio/hinged_doors/{name}.ogg"
        raw.parent.mkdir(parents=True, exist_ok=True)
        out.parent.mkdir(parents=True, exist_ok=True)
        write_wav(raw, synthesize(name, 24400 + index))
        gain = target - float(loudness(ffmpeg, raw, target)["input_i"])
        for _attempt in range(3):
            run(ffmpeg, ["-i", str(raw), "-af", f"volume={gain:.6f}dB",
                         "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1",
                         "-c:a", "libvorbis", "-q:a", "4", "-fflags", "+bitexact",
                         "-flags:a", "+bitexact", str(out)])
            measured = loudness(ffmpeg, out, target)
            delta = target - float(measured["input_i"])
            if abs(delta) <= 0.5:
                break
            gain += delta
        pcm = array("f", run(ffmpeg, ["-i", str(out), "-f", "f32le", "-ac", "1", "-ar", str(RATE), "-"]).stdout)
        if sys.byteorder != "little":
            pcm.byteswap()
        entry = dict(file=out.relative_to(ROOT).as_posix(), seconds=len(pcm) / RATE,
                     sample_rate=RATE, channels=1, loop=False, target_lufs=target,
                     lufs=float(measured["input_i"]), true_peak_db=float(measured["input_tp"]),
                     bytes=out.stat().st_size, raw_bytes=raw.stat().st_size,
                     boundary_delta=abs(pcm[0] - pcm[-1]),
                     sha256=hashlib.sha256(out.read_bytes()).hexdigest(),
                     raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest())
        if (abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -20
                or entry["boundary_delta"] > 0.001 or max(entry["bytes"], entry["raw_bytes"]) > 10_000_000):
            raise RuntimeError(entry)
        import_settings(out, False)
        entries.append(entry)
        print(f"{name}: {entry['lufs']} LUFS, {entry['true_peak_db']} dBTP")
    report = dict(ffmpeg=run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0],
                  assets=entries, listening_status="pending_owner_listening")
    (HERE / "build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("RESULT: hinged door signal validation PASS; listening pending")


if __name__ == "__main__":
    main()
