"""T-175 original procedural chapter-two audio; no speech or story generated."""
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

# Name, source duration, integrated LUFS, seamless loop (one second removed).
ASSETS = [
    ("corpse_mumble", 5., -40, True), ("corpse_fall", 1.4, -38, False),
    ("corpse_revive", 1.3, -38, False), ("corpse_gag", 1.2, -40, False),
    ("chain_tick", .5, -48, False), ("shower_beep", .5, -46, False),
    *[(f"door_push_{i:02}", .9, -44 + i * 2, False) for i in range(1, 4)],
    ("door_burst", 2., -34, False),
    ("water_cold", 7., -46, True), ("water_warm", 7., -44, True),
    ("water_boiling", 7., -40, True), ("steam_hiss", 6., -48, True),
    ("mirror_shiver", 1., -38, False),
    ("death_corpse_lunge", 3., -32, False), ("death_scald", 3., -32, False),
    ("death_corpse_soft", 3., -42, False), ("death_scald_soft", 3., -42, False),
    ("camera_room_loss", 3., -42, False),
    ("music_chain", 9., -48, True), ("music_shower", 9., -50, True),
    ("music_turn", 1.2, -48, False),
]


def synthesize(name: str, seconds: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    samples = []
    low = mid = phase = 0.
    tau = math.tau
    for i in range(round(seconds * RATE)):
        t = i / RATE
        noise = rng.uniform(-1., 1.)
        low += .025 * (noise - low)
        mid += .18 * (noise - mid)

        def impact(at: float, decay: float = 18.) -> float:
            u = t - at
            return min(1., u / .008) * math.exp(-decay * u) if u > 0 else 0.

        # Synthetic rough vowel, not words and not a recording of a person.
        phase += tau * (115 + 13 * math.sin(tau * 3.7 * t)) / RATE
        throat = (math.sin(phase) + .32 * math.sin(phase * 3) + .14 * math.sin(phase * 7))
        throat *= (.6 + .4 * math.sin(tau * 21 * t) ** 2)
        if name == "corpse_mumble":
            value = .07 * throat * (.15 + .85 * max(0., math.sin(tau * 1.2 * t))) + .2 * low
        elif name == "corpse_gag":
            value = (.15 * throat + .7 * low) * impact(.05, 5)
        elif name in ("corpse_fall", "corpse_revive"):
            onsets = [.06, .14, .35, .55] if name.endswith("revive") else [.05, .22, .52]
            value = sum(impact(at, 45) * (.2 * mid + .02 * noise) for at in onsets)
            value += impact(.5 if name.endswith("fall") else .1, 12) * (.1 * math.sin(tau * 85 * t) + .3 * low)
        elif name in ("chain_tick", "shower_beep"):
            value = impact(.02, 35) * (.12 * math.sin(tau * (680 if name == "chain_tick" else 960) * t) + .03 * mid)
        elif name.startswith("door_"):
            burst = name == "door_burst"
            level = 3 if burst else int(name[-2:])
            value = impact(.06, 12) * (.1 * math.sin(tau * (105 - level * 6) * t) + .8 * low)
            value += .09 * math.sin(tau * (290 * t + 12 * math.sin(tau * 2 * t))) * impact(.18, 6)
            if burst:
                value += .15 * mid * impact(.3, 1.8) + impact(.48, 15) * .4 * low
        elif name.startswith("water_") or name == "steam_hiss":
            value = .14 * mid + .025 * noise + .2 * low
            value *= .8 + .2 * math.sin(tau * 1.3 * t)
            if name == "water_cold":
                value += .07 * mid * max(0., math.sin(tau * 13 * t)) ** 8
            elif name == "water_boiling":
                value += .12 * math.sin(tau * (75 * t + .6 * math.sin(tau * 7 * t))) * max(0., math.sin(tau * 9 * t)) ** 4
            elif name == "steam_hiss":
                value = (.08 * noise + .04 * mid) * (.8 + .2 * math.sin(tau * .3 * t))
        elif name == "mirror_shiver":
            value = impact(.04, 7) * sum(.025 * math.sin(tau * f * t) for f in [743, 1117, 1679]) + .04 * mid * impact(.04, 12)
        elif name.startswith("death_") or name == "camera_room_loss":
            soft = name.endswith("soft")
            scald = "scald" in name
            value = .5 * low * impact(1.7, 10)
            if scald:
                value += (.18 * mid + .04 * noise) * (1 - t / seconds)
            else:
                # Three overlapping voices/pitches and discrete cloth/wet impacts.
                for at, frequency in [(.04, 170), (.14, 213), (.24, 265)]:
                    value += .08 * math.sin(tau * (frequency * t + 8 * math.sin(9 * t))) * impact(at, 1.5)
                if not soft:
                    value += sum(.3 * mid * impact(at, 25) for at in [.5, .83, 1.2, 1.52, 1.9])
            if not soft:
                value += .12 * throat * impact(.2, 1.3) + .3 * low * impact(.4, 3)
        else:
            # Non-melodic score: inharmonic low partials, damp-room filtered noise.
            humid = name == "music_shower"
            value = sum(.04 * math.sin(tau * f * t) for f in ([48, 72.4, 97] if humid else [55, 82.7, 111.2]))
            value *= .75 + .25 * math.sin(tau * .25 * t)
            value += (.4 if humid else .1) * low
            if name == "music_turn":
                value *= impact(.02, 4)
        samples.append(value)
    return samples


def main() -> None:
    ffmpeg = str(next(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe")))
    raw_dir, out_dir = SOURCE / "ch2/raw", ROOT / "game/audio/ch2"
    raw_dir.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    report = {"ffmpeg": run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0], "assets": []}
    with tempfile.TemporaryDirectory(prefix="ch2_", dir=SOURCE) as scratch:
        for index, (name, seconds, target, loop) in enumerate(ASSETS):
            raw, prepared, out = raw_dir / (name + ".wav"), Path(scratch) / (name + ".wav"), out_dir / (name + ".ogg")
            write_wav(raw, synthesize(name, seconds, 17501 + index))
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
            entry = dict(name=name, file=out.relative_to(ROOT).as_posix(), seed=17501 + index, loop=loop,
                         target_lufs=target, lufs=float(actual["input_i"]), true_peak_db=float(actual["input_tp"]),
                         seconds=round(len(pcm) / RATE, 4), bytes=out.stat().st_size,
                         sha256=hashlib.sha256(out.read_bytes()).hexdigest(), raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),
                         boundary_delta=round(abs(pcm[0] - pcm[-1]), 7))
            if abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -2 or (loop and entry["boundary_delta"] > .01):
                raise RuntimeError(entry)
            report["assets"].append(entry)
            print(f"{name}: {entry['lufs']} LUFS", flush=True)
    (SOURCE / "ch2/build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for folder in (raw_dir, out_dir) for p in folder.iterdir() if p.suffix in (".wav", ".ogg"))
    if total >= 10_000_000:
        raise RuntimeError(f"Bank exceeds 10 MB: {total}")
    print(f"CH2 RESULT: {len(ASSETS)} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
