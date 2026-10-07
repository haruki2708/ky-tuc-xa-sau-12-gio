"""T-198 deterministic original Chapter 4 Foley and quiet music (CC0)."""
from __future__ import annotations
import sys
sys.dont_write_bytecode = True
import math
import random
from array import array
import hashlib
import json
from pathlib import Path
import tempfile
from process import RATE, ROOT, SOURCE, import_settings, join_loop, loudness, run, write_wav

ASSETS = [
    ("decoy_ring", 4., -42, True), ("phone_land", .8, -41, False),
    ("battery_empty", .6, -49, False), ("door_pound", .65, -39, False),
    ("wood_crack", .6, -43, False), ("wood_splinters", .65, -42, False),
    ("door_burst", 1.8, -33, False), ("door_burst_soft", 1.8, -44, False),
    ("library", 8., -54, True), ("drizzle", 8., -56, True),
    ("librarian_rise", 2., -40, False), ("books_fall", 1.8, -39, False),
    ("shelf_corpse", 1.7, -38, False), ("back_door_hit", 1.5, -38, False),
    ("knife_pull", 1., -42, False), ("stairs_turn", 2., -43, False),
    ("hall_lights", 2.4, -44, False), ("door_hand", 1.3, -42, False),
    ("neck_hand", 1.8, -44, False), ("pa_laugh", 1.8, -39, False),
    ("body_fade", 8., -49, False), ("heartbeat", .7, -47, False),
    ("monitor", .5, -49, False), ("nurse_step_01", .5, -46, False),
    ("nurse_step_02", .5, -46, False), ("hospital_door", 1.2, -46, False),
    ("music_sparse", 9., -53, True), ("music_hospital", 9., -56, True),
    ("music_end", 7., -51, False),
]


def synthesize(name: str, seconds: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    samples = []
    low = mid = phase = 0.
    for i in range(round(seconds * RATE)):
        t = i / RATE
        noise = rng.uniform(-1., 1.)
        low += .025 * (noise - low)
        mid += .18 * (noise - mid)
        phase += math.tau * (78 + 12 * math.sin(17 * t)) / RATE
        throat = math.sin(phase) + .2 * math.sin(3.03 * phase)

        def hit(at: float, decay: float = 18.) -> float:
            u = t - at
            return min(1., u / .008) * math.exp(-decay * u) if u > 0 else 0.

        wood = (.5 * low + .12 * math.sin(math.tau * 87 * t))
        metal = sum(.035 * math.sin(math.tau * f * t) for f in [431, 797, 1291])
        breath = math.sin(math.pi * t / seconds) ** 2
        if name == "decoy_ring":
            gate = 1. if t % 2. < .7 else .02
            value = gate * (.08 * math.sin(math.tau * 440 * t) + .08 * math.sin(math.tau * 481 * t) + .035 * mid)
            value *= .7 + .3 * math.sin(95 * t) ** 2
        elif name in ("battery_empty", "monitor"):
            value = .15 * math.sin(math.tau * (510 if name == "battery_empty" else 880) * t) * hit(.03, 14)
        elif name == "phone_land":
            value = (wood + metal) * hit(.02, 26) + .2 * mid * hit(.22, 35)
        elif name.startswith("door_burst"):
            value = wood * hit(.03, 4) + .3 * mid * sum(hit(a, 30) for a in [.04, .12, .26, .41])
            if name.endswith("soft"):
                value = wood * hit(.03, 4)
        elif name in ("door_pound", "wood_crack", "wood_splinters"):
            value = wood * hit(.02, 17)
            if name == "wood_crack":
                value = .35 * mid * (hit(.02, 65) + hit(.12, 50))
            elif name == "wood_splinters":
                value = .22 * noise * sum(hit(a, 60) for a in [.02, .09, .17, .3]) + metal * hit(.04, 14)
        elif name in ("library", "drizzle"):
            value = .08 * low + .01 * mid
            if name == "library":
                value += .018 * math.sin(math.tau * 100 * t) + .09 * mid * hit(2.3, 1.8) + metal * hit(5.4, 6)
            else:
                value += .015 * noise * (.7 + .3 * math.sin(t))
        elif name == "librarian_rise":
            value = metal * hit(.04, 2.4) + .14 * mid * hit(.03, 1.8) + .12 * low * hit(.9, 2)
        elif name == "books_fall":
            value = sum((wood + .15 * mid) * hit(a, 23) for a in [.03, .23, .44, .62, .82, 1.03])
        elif name == "shelf_corpse":
            value = .3 * low * hit(.03, 2) + wood * hit(.6, 6) + metal * hit(.67, 13)
        elif name == "back_door_hit":
            value = wood * hit(.03, 7) + metal * hit(.08, 4) + .1 * noise * hit(.3, 15)
        elif name == "knife_pull":
            value = metal * breath + .15 * mid * hit(.15, 6)
        elif name == "stairs_turn":
            value = (.22 * mid + .07 * throat) * breath
        elif name == "hall_lights":
            value = sum(.1 * noise * hit(a, 65) for a in [.04, .5, 1., 1.6, 2.])
            value += .025 * math.sin(math.tau * 100 * t) * max(0, 1 - t / 2.)
        elif name == "door_hand":
            value = (.2 * low + .13 * mid) * hit(.06, 3) + wood * hit(.5, 18)
        elif name == "neck_hand":
            value = (.3 * low + .05 * mid) * breath
        elif name == "pa_laugh":
            value = .11 * throat * sum(hit(a, 8) for a in [.04, .45, .83]) + .035 * mid * breath
        elif name == "body_fade":
            value = (.12 * low + .025 * math.sin(math.tau * 58 * t)) * math.sin(math.pi * t / seconds) ** 2
        elif name == "heartbeat":
            value = .18 * math.sin(math.tau * 59 * t) * (hit(.03, 25) + .65 * hit(.24, 28))
        elif name.startswith("nurse_step"):
            value = (wood + .1 * mid) * hit(.02, 32)
        elif name == "hospital_door":
            value = metal * hit(.03, 4) + wood * hit(.7, 16)
        elif name.startswith("music_"):
            value = sum(.035 * math.sin(math.tau * f * t) for f in [55, 82.5, 110])
            value *= .4 + .6 * math.sin(math.pi * t / seconds) ** 4
            if name == "music_end":
                value *= math.sin(math.pi * t / seconds) ** 2
        else:
            raise ValueError(name)
        samples.append(value)
    return samples


def main() -> None:
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    raw_dir, out_dir = SOURCE / "ch4/raw", ROOT / "game/audio/ch4"
    raw_dir.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    report = {"ffmpeg": run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0], "assets": []}
    with tempfile.TemporaryDirectory(prefix="ch4_", dir=SOURCE) as scratch:
        for index, (name, seconds, target, loop) in enumerate(ASSETS):
            raw = raw_dir / (name + ".wav")
            prepared, out = Path(scratch) / (name + ".wav"), out_dir / (name + ".ogg")
            write_wav(raw, synthesize(name, seconds, 19801 + index))
            filters = "highpass=f=35,lowpass=f=7500"
            if name.endswith("soft"):
                filters += ",lowpass=f=700"
            if name == "pa_laugh":
                filters += ",highpass=f=300,lowpass=f=3400,aecho=0.8:0.7:47|89:0.13|0.08"
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
            entry = dict(name=name, file=out.relative_to(ROOT).as_posix(), seed=19801 + index, loop=loop,
                         target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                         seconds=round(len(pcm) / RATE, 4), bytes=out.stat().st_size,
                         sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),
                         boundary_delta=round(abs(pcm[0] - pcm[-1]), 7))
            if abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -2 or (loop and entry["boundary_delta"] > .01):
                raise RuntimeError(entry)
            report["assets"].append(entry)
            print(f"{name}: {entry['lufs']} LUFS", flush=True)
    (SOURCE / "ch4/build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for folder in (raw_dir, out_dir) for p in folder.iterdir() if p.suffix in (".wav", ".ogg"))
    if total >= 20_000_000:
        raise RuntimeError(f"Bank exceeds 20 MB: {total}")
    print(f"CH4 RESULT: {len(ASSETS)} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
