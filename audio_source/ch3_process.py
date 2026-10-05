"""T-186 original procedural sound design, deterministic; no speech samples."""
from __future__ import annotations
import sys
sys.dont_write_bytecode = True
from array import array
import hashlib
import json
import math
from pathlib import Path
import random
import tempfile
from process import RATE, ROOT, SOURCE, import_settings, join_loop, loudness, run, write_wav

ASSETS = [
    ("zombie_growl", 5., -43, True), ("zombie_hiss", 5., -44, True),
    ("zombie_drag_01", .8, -43, False), ("zombie_drag_02", .8, -43, False),
    ("horde", 8., -46, True), ("door_pound_01", 1., -37, False),
    ("door_pound_02", 1., -38, False),
    ("bar_swing", .55, -39, False), ("bar_hit", .8, -35, False),
    ("bar_miss", .6, -43, False), ("bar_bend", 1., -42, False),
    ("bar_break", 1.4, -36, False), ("pant", 1.3, -43, False),
    *[(f"run_{surface}_{i:02}", .55, -39, False) for surface in ("grass", "concrete") for i in range(1, 5)],
    ("wind", 8., -53, True), ("stadium", 8., -52, True),
    ("canteen", 8., -54, True), ("stairs", 8., -52, True),
    ("far_scream", 3., -48, False), ("rescue_siren", 9., -57, True),
    ("baton_buzz", 4., -42, True),
    ("death_zombie_grab", 3., -33, False), ("death_zombie_soft", 3., -44, False),
    ("death_guard_shock", 3., -33, False), ("death_guard_soft", 3., -44, False),
    ("music_run", 9., -51, True), ("music_wave", 9., -48, True),
    ("music_end", 7., -49, False),
]


def synthesize(name: str, seconds: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    samples = []
    low = mid = phase = 0.
    tau = math.tau
    for i in range(round(seconds * RATE)):
        t = i / RATE
        noise = rng.uniform(-1., 1.)
        low += .018 * (noise - low)
        mid += .15 * (noise - mid)
        phase += tau * (71 + 8 * math.sin(tau * 3.1 * t)) / RATE
        rough = (math.sin(phase) + .26 * math.sin(phase * 3.03) + .11 * math.sin(phase * 7.07))
        rough *= .65 + .35 * math.sin(tau * 23 * t) ** 2

        def hit(at: float, decay: float = 16.) -> float:
            u = t - at
            return min(1., u / .009) * math.exp(-decay * u) if u > 0 else 0.

        value = 0.
        if name in ("zombie_growl", "zombie_hiss", "horde"):
            breath = .15 + .85 * max(0., math.sin(tau * .47 * t))
            value = (.11 * rough + .35 * low) * breath
            if name == "zombie_hiss":
                value = (.25 * mid + .025 * noise + .015 * rough) * breath
            if name == "horde":
                value = sum(.025 * math.sin(tau * f * t + math.sin((j + 1) * t)) for j, f in enumerate([53, 69, 88, 109, 134])) + .4 * low
        elif "drag_" in name or name.startswith("run_"):
            grass = "grass" in name
            drag = "drag" in name
            value = (.7 * low + (.3 if grass or drag else .1) * mid) * hit(.03, 7 if drag else 24)
            value += .12 * math.sin(tau * (93 if grass else 135) * t) * hit(.04, 22)
            if not grass and not drag:
                value += .07 * noise * hit(.035, 80)
        elif name.startswith("door_") or name in ("bar_hit", "bar_break", "bar_bend"):
            value = (.6 * low + .14 * math.sin(tau * 83 * t)) * hit(.04, 12)
            if name.startswith("bar_"):
                metal = sum(.03 * math.sin(tau * (f * t + 2 * math.sin(8 * t))) for f in [317, 593, 991])
                value += metal * hit(.06, 4 if name == "bar_bend" else 10)
                if name == "bar_bend":
                    value *= .25
                if name == "bar_break":
                    value += .14 * noise * hit(.15, 45) + .3 * mid * hit(.4, 12)
            else:
                value += .2 * low * hit(.21, 14)
        elif name in ("bar_swing", "bar_miss", "pant"):
            envelope = math.sin(math.pi * min(t / seconds, 1)) ** (2 if name == "pant" else 4)
            value = (.12 * mid + .015 * noise) * envelope
            if name == "pant":
                value *= .45 + .55 * abs(math.sin(math.pi * 1.5 * t))
        elif name in ("wind", "stadium", "canteen", "stairs"):
            value = (.5 * low + .015 * mid) * (.75 + .25 * math.sin(tau * .17 * t))
            # Distinct resonances and delayed gusts, with no animal/insect synthesis.
            if name == "stadium":
                value += .025 * math.sin(tau * 62 * t) * (.5 + .5 * math.sin(tau * .3 * t))
            elif name == "canteen":
                value = .16 * low + .025 * math.sin(tau * 118 * t) + .009 * math.sin(tau * 237 * t)
            elif name == "stairs":
                value += sum(.018 * math.sin(tau * f * t) * (.6 + .4 * math.sin(tau * .7 * (t - delay))) for f, delay in [(137, 0), (181, .16), (223, .32)])
        elif name in ("far_scream", "rescue_siren"):
            freq = 430 + 145 * math.sin(tau * .25 * t)
            phase += tau * freq / RATE
            value = .12 * math.sin(phase) + .018 * math.sin(phase * 3)
            if name == "far_scream":
                value = (.08 * rough + .04 * math.sin(phase) + .12 * low) * math.sin(math.pi * t / seconds) ** 2
        elif name == "baton_buzz" or name.startswith("death_"):
            electric = .06 * math.sin(tau * 100 * t) + .025 * noise * max(0., math.sin(tau * 47 * t))
            value = electric
            if name.startswith("death_"):
                soft = name.endswith("soft")
                if "guard" in name:
                    value = electric * hit(.04, 1.7) + (.6 * low + .08 * math.sin(tau * 68 * t)) * hit(1.25, 10)
                else:
                    value = (.12 * rough + .5 * low) * hit(.04, 2)
                    if not soft:
                        value += sum(.22 * mid * hit(at, 24) for at in [.24, .57, .82, 1.13, 1.48])
                if soft:
                    value = .6 * low * hit(.2, 2) + .02 * math.sin(tau * 67 * t) * hit(.1, 1.5)
        elif name.startswith("music_"):
            value = sum(.045 * math.sin(tau * f * t) for f in ([49, 73.7, 98.4] if name == "music_wave" else [55, 82.7]))
            value *= .7 + .3 * math.sin(tau * (1.7 if name == "music_wave" else .75) * t) ** 4
            if name == "music_end":
                value = .12 * math.sin(tau * 55 * t) * math.sin(math.pi * t / seconds) ** 2
        else:
            raise ValueError(name)
        samples.append(value)
    return samples


def main() -> None:
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    raw_dir, out_dir = SOURCE / "ch3/raw", ROOT / "game/audio/ch3"
    raw_dir.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    report = {"ffmpeg": run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0], "assets": []}
    with tempfile.TemporaryDirectory(prefix="ch3_", dir=SOURCE) as scratch:
        for index, (name, seconds, target, loop) in enumerate(ASSETS):
            raw, prepared, out = raw_dir / (name + ".wav"), Path(scratch) / (name + ".wav"), out_dir / (name + ".ogg")
            write_wav(raw, synthesize(name, seconds, 18601 + index))
            filters = "highpass=f=35,lowpass=f=7500"
            if name.endswith("soft") or name == "corpse_mumble":
                filters += ",lowpass=f=700"
            if name == "camera_room_loss":
                filters += ",highpass=f=350,lowpass=f=3000"
            if not loop:
                filters += f",afade=t=in:d=0.005,afade=t=out:st={seconds - .08}:d=0.08"
            run(ffmpeg, ["-i", str(raw), "-af", filters, "-ar", str(RATE), "-ac", "1", str(prepared)])
            if loop:
                join_loop(prepared, align_seam=True)
            gain = target - float(loudness(ffmpeg, prepared, target)["input_i"])
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
            entry = dict(name=name, file=out.relative_to(ROOT).as_posix(), seed=18601 + index, loop=loop,
                         target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                         seconds=round(len(pcm) / RATE, 4), bytes=out.stat().st_size,
                         sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),
                         boundary_delta=round(abs(pcm[0] - pcm[-1]), 7))
            if abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -2 or (loop and entry["boundary_delta"] > .01):
                raise RuntimeError(entry)
            report["assets"].append(entry)
            print(f"{name}: {entry['lufs']} LUFS", flush=True)
    (SOURCE / "ch3/build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for folder in (raw_dir, out_dir) for p in folder.iterdir() if p.suffix in (".wav", ".ogg"))
    if total >= 20_000_000:
        raise RuntimeError(f"Bank exceeds 20 MB: {total}")
    print(f"CH3 RESULT: {len(ASSETS)} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
