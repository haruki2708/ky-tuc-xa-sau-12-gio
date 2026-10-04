"""T-164 procedural mission Foley. Rebuilds only the separate ch1v2 bank."""
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

# Basename, raw duration, LUFS, loop (crossfade removes one second).
ASSETS = [
    *[(f"wall_tap_{i:02}", .5, -42, False) for i in range(1, 4)],
    ("router_power_off", .65, -42, False), ("router_boot", 1.2, -40, False),
    ("router_online", .9, -40, False), ("power_switch", .6, -42, False),
    ("power_short", 1.5, -32, False), ("handle_rattle", 5., -40, True),
    ("handle_stop", 1., -42, False), ("lock_alarm", 1.5, -30, False),
    ("kiet_ring", 5., -36, True), ("call_reconnect", 1., -36, False),
    ("death_fall_back", 3., -32, False), ("death_bed_burst", 3., -34, False),
    ("death_flesh", 1.1, -34, False), ("death_fall_soft", 3., -42, False),
    ("death_bed_soft", 3., -44, False), ("cctv_static", 7., -54, True),
    ("cctv_switch", .7, -46, False),
]


def synthesize(name: str, seconds: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    result: list[float] = []
    low = 0.
    phase = 0.
    variant = seed % 3
    tau = math.tau
    for index in range(round(seconds * RATE)):
        t = index / RATE
        n = rng.uniform(-1., 1.)
        low += .06 * (n - low)

        def pulse(at: float, decay: float) -> float:
            u = t - at
            return min(1., u / .003) * math.exp(-u * decay) if u > 0 else 0.

        def tone(at: float, length: float, frequency: float) -> float:
            u = t - at
            if not 0 < u < length:
                return 0.
            return min(1., u / .01, (length - u) / .025) * math.sin(tau * frequency * u)

        if name.startswith("wall_tap"):
            # Knuckle transient and damped masonry body, without a resonant wood ring.
            value = pulse(.025, 38) * (.27 * math.sin(tau * (210 + 21 * variant) * t) + .33 * low)
            value += .07 * n * pulse(.025, 120)
        elif name in ("router_boot", "router_online", "call_reconnect", "kiet_ring"):
            notes = [(0.05, .18, 680), (.3, .17, 920)]
            if name == "router_boot":
                notes = [(.06, .24, 520), (.42, .24, 610), (.8, .2, 760)]
            elif name == "router_online":
                notes = [(.06, .16, 880), (.3, .32, 1175)]
            elif name == "kiet_ring":
                # Repeating triplet distinct from Trung's paired 440/660 Hz beeps.
                notes = [(at, .19, f) for at, f in [(1.04, 740), (1.31, 988), (1.58, 831), (3.04, 740), (3.31, 988), (3.58, 831)]]
            value = sum(.16 * tone(at, length, f) + .035 * tone(at, length, f * 2) for at, length, f in notes)
        elif name in ("router_power_off", "power_switch"):
            value = pulse(.03, 45) * (.15 * math.sin(tau * 330 * t) + .2 * low)
            value += .025 * n * pulse(.06, 95)
            if name == "router_power_off":
                value += .06 * math.exp(-t * 10) * math.sin(tau * (490 * t - 210 * t * t))
        elif name == "power_short":
            value = .0
            for at, decay in [(.04, 75), (.11, 53), (.29, 48), (.51, 38), (.78, 65)]:
                value += pulse(at, decay) * (.28 * n + .16 * math.sin(tau * 100 * t))
            value += .3 * low * pulse(1.02, 25)
        elif name in ("handle_rattle", "handle_stop"):
            value = 0.
            onsets = [j * .27 + .03 for j in range(20)] if name == "handle_rattle" else [.02, .17, .33]
            for at in onsets:
                value += pulse(at, 28) * (.08 * math.sin(tau * 780 * t) + .06 * math.sin(tau * 1370 * t) + .2 * low)
            phase += tau * (185 + 35 * math.sin(tau * 1.9 * t)) / RATE
            value += .02 * math.sin(phase) * (1. if name == "handle_rattle" else math.exp(-t * 7))
        elif name == "lock_alarm":
            phase += tau * (1680 + 260 * math.sin(tau * 7 * t)) / RATE
            value = .18 * math.sin(phase) * (.2 + .8 * max(0., math.sin(tau * 4 * t)))
        elif name.startswith("death_"):
            soft = name.endswith("soft")
            bed = "bed" in name
            if name == "death_flesh":
                value = pulse(.07, 16) * (.75 * low + .07 * n)
                value += pulse(.13, 23) * .16 * math.sin(tau * (140 * t - 45 * t * t))
            else:
                # Fall: gush/choked exhale first, body on tile at 1.6 s.
                # Bed: intermittent low impacts and iron shaking, no tile fall.
                value = 0.
                for at in ([.18, .64, 1.12, 1.7, 2.16] if bed else [1.6]):
                    value += pulse(at, 19) * (.19 * math.sin(tau * (110 if bed else 82) * t) + .3 * low)
                    if bed:
                        value += pulse(at, 12) * .035 * math.sin(tau * 620 * t)
                if not soft:
                    value += .75 * low * (pulse(.02, 5) + .5 * pulse(.48, 7))
                    value += .22 * low * math.exp(-((t - .95) / .34) ** 2) * (.55 + .45 * math.sin(tau * 23 * t) ** 2)
                    value += .045 * n * pulse(1.6 if not bed else .2, 40)
        else:
            # Quiet camera hiss and a short tuning interruption, no speech.
            value = .09 * n + .12 * low
            if name == "cctv_static":
                value *= .85 + .15 * math.sin(tau * .7 * t)
            else:
                value *= math.exp(-t * 7) * (.3 + .7 * math.sin(tau * 37 * t) ** 2)
        result.append(value)
    return result


def main() -> None:
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    raw_dir = SOURCE / "ch1v2/raw"
    out_dir = ROOT / "game/audio/ch1v2"
    raw_dir.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    report = {"ffmpeg": run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0], "assets": []}
    with tempfile.TemporaryDirectory(prefix="ch1v2_", dir=SOURCE) as scratch:
        for index, (name, seconds, target, loop) in enumerate(ASSETS):
            raw = raw_dir / (name + ".wav")
            write_wav(raw, synthesize(name, seconds, 16401 + index))
            prepared = Path(scratch) / (name + ".wav")
            filters = "highpass=f=35,lowpass=f=8500"
            if name.endswith("soft"):
                filters += ",lowpass=f=700"
            if name.startswith("cctv_"):
                filters += ",highpass=f=350,lowpass=f=4200"
            if not loop:
                filters += f",afade=t=in:d=0.005,afade=t=out:st={seconds - .08}:d=0.08"
            run(ffmpeg, ["-i", str(raw), "-af", filters, "-ar", str(RATE), "-ac", "1", str(prepared)])
            if loop:
                join_loop(prepared, align_seam=True)
            gain = target - float(loudness(ffmpeg, prepared, target)["input_i"])
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
            entry = dict(name=name, file=out.relative_to(ROOT).as_posix(), seed=16401 + index, loop=loop,
                         target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                         seconds=round(len(pcm) / RATE, 4), bytes=out.stat().st_size,
                         sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),
                         boundary_delta=round(abs(pcm[0] - pcm[-1]), 7))
            if abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -2 or (loop and entry["boundary_delta"] > .01):
                raise RuntimeError(entry)
            report["assets"].append(entry)
            print(f"{name}: {entry['lufs']} LUFS", flush=True)
    (SOURCE / "ch1v2/build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for folder in (raw_dir, out_dir) for p in folder.iterdir() if p.suffix in (".wav", ".ogg"))
    if total >= 10_000_000:
        raise RuntimeError(f"Bank exceeds 10 MB: {total}")
    print(f"CH1V2 RESULT: {len(ASSETS)} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
