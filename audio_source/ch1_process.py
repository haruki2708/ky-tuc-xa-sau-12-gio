"""T-158 original procedural Foley, no recordings/models/dependencies beyond FFmpeg."""
from __future__ import annotations

from array import array
import hashlib
import json
import math
from pathlib import Path
import random
import sys
import tempfile

sys.dont_write_bytecode = True
from process import RATE, ROOT, SOURCE, import_settings, join_loop, loudness, run, write_wav

# name, raw seconds (loops lose 1 s), target LUFS, loop
ASSETS = [
    ("manager_step_01", .8, -42, False), ("manager_step_02", .8, -42, False),
    ("manager_drag", 7., -34, True), ("manager_knock", 1.8, -30, False),
    ("slash_mattress_01", 1.1, -28, False), ("slash_mattress_02", 1.2, -28, False),
    ("slash_wood_01", 1.2, -28, False), ("slash_wood_02", 1.3, -28, False),
    ("manager_kill", 2., -26, False), ("kill_soft", 1.4, -38, False),
    ("slash_soft", 1., -40, False),
    *[(f"scream_{i:02}", 2.5 + i * .25, -30, False) for i in range(1, 5)],
    ("call_ring", 4., -34, True), ("call_disconnect", 1.2, -34, False),
    ("call_drop", 1.8, -30, False), ("blood_drip", 9., -48, True),
    ("corpse_rustle", 1.3, -46, False), ("heartbeat", .65, -48, False),
    ("breath_gasp", 1.4, -38, False), ("bunk_climb", 2.1, -42, False),
    ("bunk_creak", 1.6, -44, False), ("wall_knock", 1.6, -38, False),
    ("locker_unlock", 1.4, -38, False), ("charger_plug", .7, -40, False),
    ("pa_on", .65, -32, False), ("pa_burst", .7, -36, False),
]


def synthesize(name: str, seconds: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    values: list[float] = []
    low = 0.
    phase = 0.
    variant = seed % 4
    for i in range(round(seconds * RATE)):
        t = i / RATE
        n = rng.uniform(-1, 1)
        low += .035 * (n - low)
        value = 0.

        def hit(at: float, decay: float = 30.) -> float:
            u = t - at
            return min(1., max(0., u) / .003) * math.exp(-max(0., u) * decay) if u >= 0 else 0.

        if name == "manager_drag":
            scrape = .55 + .22 * math.sin(2 * math.pi * 1.17 * t) + .15 * math.sin(2 * math.pi * 3.7 * t)
            phase += 2 * math.pi * (1470 + 220 * math.sin(2 * math.pi * .63 * t)) / RATE
            value = scrape * (.17 * low + .022 * n + .05 * math.sin(phase) + .019 * math.sin(phase * 1.713))
        elif name.startswith("scream_"):
            # Glottal harmonics with vowel-formant weights, unstable pitch and breath.
            f0 = 190 + 51 * variant + 95 * math.sin(math.pi * t / seconds) + 8 * math.sin(2 * math.pi * (5 + variant) * t)
            phase += 2 * math.pi * f0 / RATE
            envelope = max(0., math.sin(math.pi * t / seconds)) ** .65
            voiced = sum(math.sin(phase * h) * (math.exp(-((h * f0 - 820) / 290) ** 2) + .6 * math.exp(-((h * f0 - 1850) / 440) ** 2)) / h for h in range(1, 13))
            value = envelope * (.34 * voiced + .06 * low + .015 * n) * (.75 + .25 * math.sin(2 * math.pi * 11 * t) ** 2)
        elif name.startswith("slash_") or name == "manager_kill":
            soft = name == "slash_soft"
            strikes = [.16, .62, 1.13] if name == "manager_kill" else [.14]
            for at in strikes:
                value += .25 * hit(at, 19) * (math.sin(2 * math.pi * (100 + variant * 12) * t) + low * 2)
                if not soft:
                    value += .12 * math.exp(-((t - at + .05) / .06) ** 2) * n
                    value += hit(at + .055, 38) * (.3 * n if "wood" in name else .6 * low)
                    if "wood" in name:
                        value += .13 * hit(at, 11) * math.sin(2 * math.pi * 470 * t)
        elif name == "kill_soft":
            value = .3 * hit(.05, 7) * (math.sin(2 * math.pi * 73 * t) + low)
        elif name in ("call_ring", "call_disconnect"):
            for at in ([1.08, 1.48] if name == "call_ring" else [.04, .31, .58]):
                u = t - at
                if 0 <= u < .17:
                    env = min(1., u / .008, (.17 - u) / .025)
                    value += env * .13 * (math.sin(2 * math.pi * 440 * t) + .45 * math.sin(2 * math.pi * 660 * t))
        elif name == "call_drop":
            value = hit(.15, 18) * (.25 * math.sin(2 * math.pi * 190 * t) + .25 * low)
            for j in range(13):
                at = .22 + j * .047
                value += hit(at, 65 + j * 4) * .08 * (n + math.sin(2 * math.pi * (1800 + j * 137) * t))
        elif name == "blood_drip":
            for at in [.3, 2.37, 3.91, 6.12, 8.31]:
                u = max(0., t - at)
                value += hit(at, 27) * (.23 * math.sin(2 * math.pi * (780 * u - 180 * u * u)) + .3 * low)
        elif name in ("corpse_rustle", "breath_gasp"):
            env = math.exp(-((t - (.3 if name == "breath_gasp" else .5)) / .25) ** 2)
            value = env * (1.1 * low + .012 * n) * (.65 + .35 * math.sin(2 * math.pi * 27 * t) ** 2)
        elif name == "heartbeat":
            value = (hit(.03, 28) + .65 * hit(.23, 34)) * .4 * math.sin(2 * math.pi * 68 * t)
        elif name.startswith("pa_"):
            env = math.exp(-t * 4) if name == "pa_on" else max(0., math.sin(math.pi * t / seconds))
            value = env * (.08 * n + .12 * low + .015 * math.sin(2 * math.pi * 870 * t))
            if name == "pa_on":
                value += .35 * hit(.02, 80) * low
        else:
            # Impacts, sole weight, bed iron and small mechanical Foley.
            onsets = [.05]
            if name in ("manager_knock", "wall_knock"):
                onsets = [.05, .47, .99]
            elif name == "bunk_climb":
                onsets = [.04, .61, 1.23]
            elif name == "locker_unlock":
                onsets = [.04, .23, .46, .8]
            metal = name.startswith("bunk_") or name in ("locker_unlock", "charger_plug")
            freq = 680 if metal else 125 + variant * 16
            for at in onsets:
                value += hit(at, 15 if metal else 24) * (.18 * math.sin(2 * math.pi * freq * t) + .38 * low)
                value += .025 * n * hit(at, 60)
            if name.startswith("bunk_"):
                phase += 2 * math.pi * (330 + 45 * math.sin(2 * math.pi * 1.3 * t)) / RATE
                value += .025 * math.sin(phase) * max(0., math.sin(math.pi * t / seconds))
        values.append(value)
    return values


def main() -> None:
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    raw_dir = SOURCE / "ch1/raw"
    out_dir = ROOT / "game/audio/ch1"
    raw_dir.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    report = {"ffmpeg": run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0], "assets": []}
    with tempfile.TemporaryDirectory(prefix="ch1_", dir=SOURCE) as scratch:
        for index, (name, seconds, target, loop) in enumerate(ASSETS):
            seed = 15801 + index
            raw = raw_dir / (name + ".wav")
            write_wav(raw, synthesize(name, seconds, seed))
            prepared = Path(scratch) / (name + ".wav")
            filters = "highpass=f=35,lowpass=f=8500"
            if name in ("slash_soft", "kill_soft"):
                filters += ",lowpass=f=700"
            if not loop:
                filters += f",afade=t=in:d=0.005,afade=t=out:st={seconds - .08}:d=0.08"
            run(ffmpeg, ["-i", str(raw), "-af", filters, "-ar", str(RATE), "-ac", "1", str(prepared)])
            if loop:
                join_loop(prepared, align_seam=True)
            measured = loudness(ffmpeg, prepared, target)
            # Linear measured gain supports quiet targets below loudnorm's -70 gate.
            gain = target - float(measured["input_i"])
            out = out_dir / (name + ".ogg")
            for attempt in range(3):
                run(ffmpeg, ["-i", str(prepared), "-af", f"volume={gain:.6f}dB", "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", "4", "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
                actual = loudness(ffmpeg, out, target)
                delta = target - float(actual["input_i"])
                if abs(delta) <= .5:
                    break
                gain += delta
            import_settings(out, loop)
            pcm = array("f", run(ffmpeg, ["-i", str(out), "-f", "f32le", "-ac", "1", "-ar", str(RATE), "-"]).stdout)
            if sys.byteorder != "little":
                pcm.byteswap()
            entry = dict(name=name, file=out.relative_to(ROOT).as_posix(), seed=seed, loop=loop,
                         target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                         seconds=round(len(pcm) / RATE, 4), bytes=out.stat().st_size,
                         sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),
                         boundary_delta=round(abs(pcm[0] - pcm[-1]), 7))
            if abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -2 or (loop and entry["boundary_delta"] > .01):
                raise RuntimeError(entry)
            report["assets"].append(entry)
            print(f"{name}: {entry['lufs']} LUFS", flush=True)
    (SOURCE / "ch1/build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for folder in (raw_dir, out_dir) for p in folder.iterdir() if p.suffix in (".wav", ".ogg"))
    if total >= 15_000_000:
        raise RuntimeError(f"Chapter bank exceeds 15 MB: {total}")
    print(f"CH1 RESULT: {len(ASSETS)} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
