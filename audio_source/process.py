"""Rebuild original synthetic WAVs and mono Vorbis assets using only stdlib + FFmpeg."""
from __future__ import annotations

import argparse
from array import array
import hashlib
import json
import math
import os
from pathlib import Path
import random
import re
import shutil
import subprocess
import sys
import tempfile
import wave

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "audio_source"
OUTPUT = ROOT / "game/audio"
RATE = 48000
TAU = math.tau
# name, category, raw duration, seed
ASSETS = [
    ("ceiling_fan", "ambience", 13.0, 10501),
    ("fluorescent_hum", "ambience", 13.0, 10502),
    ("fluorescent_flicker", "sfx", 1.5, 11401),
    ("night_insects_motorbike", "ambience", 21.0, 10503),
    *[(f"water_drip_{i:02}", "sfx", 1.0, 10510 + i) for i in range(1, 4)],
    *[(f"slipper_tile_{i:02}", "sfx", 0.6, 12300 + i) for i in range(1, 5)],
    *[(f"slipper_run_{i:02}", "sfx", 0.6, 12310 + i) for i in range(1, 5)],
    ("wood_door_open", "sfx", 2.4, 10531),
    ("wood_door_close", "sfx", 1.8, 10532),
    ("knock_01", "sfx", 1.5, 13001),
    ("knock_02", "sfx", 2.1, 13002),
    ("knock_03", "sfx", 2.9, 13003),
    ("speaker_chime", "sfx", 1.6, 13004),
    ("speaker_on", "sfx", 0.55, 13005),
    ("speaker_off", "sfx", 0.55, 13006),
    ("speaker_static", "ambience", 7.0, 13007),
    ("speaker_static_burst", "sfx", 1.5, 13008),
    ("phone_vibrate", "sfx", 3.4, 13009),
    ("light_switch", "sfx", 0.5, 13010),
    ("door_latch", "sfx", 0.65, 13011),
    ("sting_low", "sfx", 3.0, 13101),
    ("sting_hit", "sfx", 2.0, 13102),
    ("slipper_place", "sfx", 0.9, 13103),
    ("tube_cut", "sfx", 0.5, 13104),
    ("breath_close", "ambience", 9.0, 13105),
    *[(f"slipper_rush_{i:02}", "sfx", 0.6, 13105 + i) for i in range(1, 5)],
    ("whisper_co", "sfx", 1.5, 13110),
    ("net_billow", "sfx", 1.1, 13111),
    ("drone_base", "music", 33.0, 13301),
    ("drone_tension", "music", 17.0, 13302),
    ("chase_pulse", "music", 17.0, 13303),
    ("end_tone", "music", 10.0, 13304),
]

SEGMENT12_NAMES = {asset[0] for asset in ASSETS if 13000 <= asset[3] < 13100}
SCARE_NAMES = {asset[0] for asset in ASSETS if 13100 <= asset[3] < 13200}
LOOP_SFX = {"phone_vibrate"}
MUSIC_LOOPS = {"drone_base", "drone_tension", "chase_pulse"}


# Per-asset loudness chosen by ear with the owner (D-015…D-023); default: loops -24, SFX -18.
TARGET_OVERRIDES = {"slipper_tile": -56, "slipper_run": -53, "fluorescent_hum": -44, "ceiling_fan": -34}
TARGET_OVERRIDES.update({"knock_": -30, "speaker_": -32, "phone_vibrate": -36,
                         "light_switch": -36, "door_latch": -36})
TARGET_OVERRIDES.update({"sting_low": -32, "sting_hit": -20, "slipper_place": -32,
                         "tube_cut": -32, "breath_close": -36, "slipper_rush_": -34,
                         "whisper_co": -30, "net_billow": -32})
TARGET_OVERRIDES.update({"drone_base": -42, "drone_tension": -36,
                         "chase_pulse": -30, "end_tone": -32})


def target_lufs(name: str, loop: bool) -> int:
    for prefix, target in TARGET_OVERRIDES.items():
        if name.startswith(prefix):
            return target
    return -24 if loop else -18


def write_wav(path: Path, values: list[float]) -> None:
    samples = array("h", (round(max(-0.98, min(0.98, v)) * 32767) for v in values))
    if sys.byteorder != "little":
        samples.byteswap()
    with wave.open(str(path), "wb") as out:
        out.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        out.writeframes(samples.tobytes())


def synthesize(name: str, seconds: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    if name in MUSIC_LOOPS or name == "end_tone":
        return synthesize_music(name, seconds, seed)
    if name in SCARE_NAMES:
        return synthesize_scare(name, seconds, seed)
    if name in SEGMENT12_NAMES:
        return synthesize_segment12(name, seconds, seed)
    if name.startswith("slipper_"):
        return synthesize_slipper(seconds, seed, running=name.startswith("slipper_run"))
    result: list[float] = []
    low_noise = 0.0
    phase = 0.0
    variant = seed % 10
    for index in range(round(seconds * RATE)):
        t = index / RATE
        noise = rng.uniform(-1.0, 1.0)
        low_noise += 0.045 * (noise - low_noise)
        if name == "ceiling_fan":
            blade = 0.65 + 0.35 * math.sin(TAU * 7 * t)
            value = 0.32 * low_noise * blade + 0.045 * math.sin(TAU * 60 * t)
            value += 0.013 * math.sin(TAU * 120 * t) * blade
        elif name == "fluorescent_hum":
            # Keep mains hum, but put ballast energy where laptop speakers work.
            modulation = 1 + .07 * math.sin(TAU * .73 * t) + .035 * math.sin(TAU * 1.137 * t + .8)
            buzz = sum(a * math.sin(TAU * f * t) for f, a in
                       [(300, .033), (500, .030), (700, .022), (1100, .014), (1900, .008), (2900, .004)])
            value = .045 * math.sin(TAU * 100 * t) + buzz * modulation
            value += .008 * low_noise + .002 * math.sin(TAU * 6200 * t + .15 * math.sin(TAU * .91 * t))
        elif name == "fluorescent_flicker":
            # Irregular relay strikes followed by brief ballast ignition bursts.
            value = 0.0
            for onset, length in [(.025, .075), (.17, .12), (.39, .06), (.57, .23), (.93, .10), (1.12, .27)]:
                u = t - onset
                if 0 <= u < length:
                    envelope = min(1.0, u / .003) * min(1.0, (length - u) / .012)
                    value += envelope * (.035 * math.sin(TAU * 100 * t) + .055 * math.sin(TAU * 700 * t)
                                         + .028 * math.sin(TAU * 1700 * t) + .018 * noise)
                    value += .18 * noise * math.exp(-u * 200) * min(1.0, u / .0005)
        elif name == "night_insects_motorbike":
            chirp = max(0.0, math.sin(TAU * 2.3 * t)) ** 8
            pulse = max(0.0, math.sin(TAU * 31 * t)) ** 2
            insects = .065 * chirp * pulse * math.sin(TAU * 4200 * t)
            insects += .016 * max(0.0, math.sin(TAU * 1.7 * t + 1)) ** 6 * math.sin(TAU * 5100 * t)
            passing = math.exp(-((t - 10) / 3.2) ** 2)
            phase += TAU * (78 - 12 * math.tanh((t - 10) / 2)) / RATE
            motor = passing * (.065 * math.sin(phase) + .025 * math.sin(phase * 2) + .10 * low_noise)
            value = insects + motor + .016 * low_noise
        elif name.startswith("water_drip"):
            u = max(0.0, t - .04)
            freq = 1650 + variant * 155
            value = .34 * math.exp(-u * 19) * math.sin(TAU * (freq * u - 520 * u * u))
            value += .09 * noise * math.exp(-u * 65)
            value *= min(1.0, u / .003)
        elif name.startswith("slipper_tile"):
            u = max(0.0, t - .035)
            slap = math.exp(-u * (23 + variant)) * min(1.0, u / .005)
            drag = math.exp(-((u - .17 - variant * .008) / .085) ** 2)
            value = slap * (.24 * math.sin(TAU * (155 + variant * 12) * u) + .16 * noise)
            value += drag * (.20 * low_noise + .035 * noise)
            value += .035 * math.exp(-u * 17) * math.sin(TAU * 930 * u) * min(1.0, u / .006)
        else:
            closing = name.endswith("close")
            movement = max(0.0, math.sin(math.pi * min(t / (seconds - .15), 1))) ** 1.8
            phase += TAU * (195 + 65 * math.sin(TAU * .85 * t) + 9 * math.sin(TAU * 13 * t)) / RATE
            creak = (.065 * math.sin(phase) + .025 * math.sin(phase * 3)) * movement
            creak *= .6 + .4 * math.sin(TAU * 19 * t) ** 2
            impact_at = 1.22 if closing else .10
            u = max(0.0, t - impact_at)
            impact = math.exp(-u * 19) * min(1.0, u / .004)
            value = creak + .06 * low_noise * movement
            value += impact * (.30 * math.sin(TAU * 105 * u) + .12 * low_noise)
        result.append(value)
    return result


def synthesize_slipper(seconds: float, seed: int, running: bool) -> list[float]:
    """Flip-flop on glazed tile: a muffled heel "lep", then the sole flapping
    back against the heel ("xep"). Soft attacks, no low thump, no hard click."""
    rng = random.Random(seed)
    contact = .02 + rng.uniform(0, .012)
    gap = rng.uniform(.075, .105) if running else rng.uniform(.13, .19)
    heel_amp = rng.uniform(.8, 1.0) if running else rng.uniform(.55, .75)
    slap_amp = rng.uniform(.6, .75) if running else rng.uniform(.25, .4)
    flutter = rng.uniform(.008, .013)
    body_hz = rng.uniform(170, 230)
    heel_lp = 1 - math.exp(-TAU * (1900 if running else 1400) / RATE)
    slap_lp = 1 - math.exp(-TAU * 2500 / RATE)
    slap_hp = 1 - math.exp(-TAU * 1200 / RATE)
    scuff_lp = 1 - math.exp(-TAU * 900 / RATE)
    heel_state = slap_low = slap_band = scuff_state = 0.0

    def burst(u: float, attack: float, decay: float) -> float:
        if u < 0:
            return 0.0
        return min(1.0, u / attack) * math.exp(-u / decay)

    result: list[float] = []
    for index in range(round(seconds * RATE)):
        t = index / RATE
        noise = rng.uniform(-1.0, 1.0)
        heel_state += heel_lp * (noise - heel_state)
        slap_band += slap_lp * (noise - slap_band)
        slap_low += slap_hp * (slap_band - slap_low)
        scuff_state += scuff_lp * (noise - scuff_state)
        u = t - contact
        heel = burst(u, .007, .03) * (heel_state + .35 * math.sin(TAU * body_hz * u))
        slap_noise = slap_band - slap_low
        slap = burst(u - gap, .003, .014) + .3 * burst(u - gap - flutter, .003, .01)
        scuff = 0.0
        if 0 <= u < gap:
            scuff = math.sin(math.pi * u / gap) * scuff_state * (.06 if running else .04)
        result.append(.5 * (heel_amp * heel + slap_amp * slap * slap_noise + scuff))
    return result


def synthesize_segment12(name: str, seconds: float, seed: int) -> list[float]:
    """Original physical approximations; no sampled voices or third-party recordings."""
    rng = random.Random(seed)
    values: list[float] = []
    low = band = 0.0

    def envelope(u: float, attack: float, decay: float) -> float:
        return min(1.0, max(0.0, u) / attack) * math.exp(-max(0.0, u) / decay)

    for index in range(round(seconds * RATE)):
        t = index / RATE
        noise = rng.uniform(-1, 1)
        low += .035 * (noise - low)
        band += .42 * (noise - band)
        hiss = band - low
        value = 0.0
        if name.startswith("knock_"):
            variant = int(name[-2:]) - 1
            spacing = [.43, .73, 1.03][variant]
            for strike in range(3):
                u = t - (.025 + strike * spacing)
                body = sum(a * math.sin(TAU * f * u) for f, a in
                           [(210 - variant * 28, .24), (370 - variant * 35, .11), (790, .025)])
                value += envelope(u, .002, .045 + variant * .019) * body
                value += .12 * envelope(u, .001, .009) * hiss
        elif name == "speaker_chime":
            for onset, hz in [(.02, 880), (.65, 660)]:
                u = t - onset
                tone = math.sin(TAU * hz * u) + .19 * math.sin(TAU * hz * 2.01 * u)
                value += .16 * envelope(u, .006, .23) * math.tanh(1.6 * tone)
                value += .024 * envelope(u, .003, .28) * hiss
        elif name in ("speaker_on", "speaker_off"):
            u = t - .02
            hz = 105 if name.endswith("on") else 76
            value = .25 * envelope(u, .003, .032) * math.sin(TAU * hz * u)
            value += .11 * envelope(u, .001, .085) * hiss
        elif name.startswith("speaker_static"):
            drift = .8 + .13 * math.sin(TAU * .81 * t) + .07 * math.sin(TAU * 2.17 * t)
            value = .2 * hiss * drift + .008 * math.sin(TAU * 100 * t)
            if name.endswith("burst"):
                value *= .7 + .3 * math.sin(TAU * 27 * t) ** 2
                value += .035 * math.tanh(6 * hiss)
        elif name == "phone_vibrate":
            u = t % .8
            pulse = min(1.0, u / .035) * max(0.0, min(1.0, (.56 - u) / .04))
            motor = .10 * math.sin(TAU * 170 * t) + .055 * math.sin(TAU * 340 * t)
            rattle = max(0.0, math.sin(TAU * 42.5 * t)) ** 12
            metal = .11 * hiss + .06 * math.sin(TAU * 1850 * t) + .035 * math.sin(TAU * 2730 * t)
            value = pulse * (motor + rattle * metal)
        elif name == "light_switch":
            for onset, amplitude in [(.02, 1.0), (.048, .55)]:
                u = t - onset
                value += amplitude * envelope(u, .001, .012) * (.16 * hiss + .06 * math.sin(TAU * 1250 * u))
        elif name == "door_latch":
            u = t - .02
            scrape = math.exp(-((t - .14) / .075) ** 2)
            value = .08 * scrape * hiss
            for onset in [.025, .24]:
                u = t - onset
                value += envelope(u, .002, .023) * (.12 * hiss + .08 * math.sin(TAU * 940 * u) + .035 * math.sin(TAU * 2300 * u))
        values.append(value)
    return values


def synthesize_scare(name: str, seconds: float, seed: int) -> list[float]:
    """Seeded noise, resonances and envelopes; no speech recordings or TTS."""
    rng = random.Random(seed)
    values: list[float] = []
    low = mid = high = 0.0
    # Noise resonators approximate a whispered rounded vowel without voiced pitch.
    resonators = [(f, math.exp(-math.pi * width / RATE)) for f, width in
                  [(480, 150), (850, 220), (2400, 400)]]
    states = [[0.0, 0.0] for _ in resonators]
    variant = seed % 10

    def envelope(u: float, attack: float, decay: float) -> float:
        return min(1.0, max(0.0, u) / attack) * math.exp(-max(0.0, u) / decay)

    for index in range(round(seconds * RATE)):
        t = index / RATE
        noise = rng.uniform(-1, 1)
        low += .045 * (noise - low)
        mid += .22 * (noise - mid)
        high += .55 * (noise - high)
        air = high - mid
        soft = mid - low
        value = 0.0
        if name == "sting_low":
            # Slow onset and gently beating harmonics avoid a startling attack.
            swell = math.sin(math.pi * min(t / .5, 1) / 2) ** 2
            tail = math.exp(-t / .85) * min(1.0, (seconds - t) / .45)
            tone = (.3 * math.sin(TAU * 64 * t) + .13 * math.sin(TAU * 128.7 * t)
                    + .04 * math.sin(TAU * 192 * t))
            value = swell * tail * (.92 + .08 * math.sin(TAU * 4.2 * t)) * tone
        elif name == "sting_hit":
            u = t - .016
            metal = sum(a * math.sin(TAU * hz * u) for hz, a in
                        [(147, .19), (431, .16), (1037, .11), (2213, .06)])
            value = envelope(u, .001, .36) * math.tanh(3.0 * metal)
            value += .36 * envelope(u, .001, .038) * (soft + air)
        elif name == "slipper_place":
            for onset, strength in [(.025, 1.0), (.24, .83)]:
                u = t - onset
                value += strength * envelope(u, .009, .035) * (.55 * low + .07 * math.sin(TAU * 185 * u))
                value += strength * .12 * envelope(u - .014, .007, .022) * soft
        elif name == "tube_cut":
            u = t - .018
            value = envelope(u, .002, .018) * (.2 * math.sin(TAU * 110 * u) + .15 * low)
            value += .08 * envelope(u - .036, .001, .007) * air
        elif name == "breath_close":
            # Two unvoiced breaths per eight-second output loop; uneven rasp.
            cycle = t % 4.0
            inhale = math.sin(math.pi * min(cycle / 1.35, 1)) ** 2
            exhale = math.sin(math.pi * max(0.0, min((cycle - 1.65) / 1.8, 1))) ** 2
            rasp = .7 + .2 * math.sin(TAU * 31 * t) + .1 * math.sin(TAU * 47.3 * t)
            value = (.34 * inhale + .48 * exhale) * (soft + .24 * air) * rasp
        elif name.startswith("slipper_rush_"):
            u = t - (.022 + variant * .001)
            gap = .056 + variant * .003
            body = .16 * math.sin(TAU * (138 + variant * 7) * u)
            value = envelope(u, .005, .045) * (.65 * low + body)
            value += .65 * envelope(u - gap, .0025, .025) * soft
            value += .10 * envelope(u - .025, .014, .065) * low
        elif name == "whisper_co":
            vowel = 0.0
            for k, (hz, radius) in enumerate(resonators):
                prev, prev2 = states[k]
                current = (1 - radius) * noise + 2 * radius * math.cos(TAU * hz / RATE) * prev - radius * radius * prev2
                states[k] = [current, prev]
                vowel += current * [.24, .18, .08][k]
            # Brief breath consonant followed by a fading unvoiced "o" shape.
            value = .20 * envelope(t - .02, .01, .035) * air
            value += envelope(t - .10, .10, .38) * (vowel + .045 * soft)
        elif name == "net_billow":
            u = t - .02
            flutter = .75 + .25 * math.sin(TAU * (17 * t + 8 * t * t))
            value = .6 * envelope(u, .075, .14) * (soft + .12 * air) * flutter
        values.append(value)
    return values


def synthesize_music(name: str, seconds: float, seed: int) -> list[float]:
    """Unpitched air and slowly beating low partials, without a melodic sequence."""
    rng = random.Random(seed)
    values: list[float] = []
    low = air = 0.0
    for index in range(round(seconds * RATE)):
        t = index / RATE
        noise = rng.uniform(-1, 1)
        low += .012 * (noise - low)
        air += .13 * (noise - air)
        drift = .8 + .12 * math.sin(TAU * t / 16) + .08 * math.sin(TAU * t / 8)
        body = .15 * math.sin(TAU * 55 * t) + .065 * math.sin(TAU * 55.1875 * t)
        body += .035 * math.sin(TAU * 110 * t)
        metal = .016 * math.sin(TAU * 731.125 * t + .5 * math.sin(TAU * t / 8))
        if name == "drone_base":
            value = drift * (body + .09 * low + .15 * metal)
        elif name == "drone_tension":
            rub = .055 * math.sin(TAU * 58.25 * t) + .025 * math.sin(TAU * 116.75 * t)
            value = drift * (body + rub + metal + .12 * (air - low))
        elif name == "chase_pulse":
            # 112.5 BPM, 30 pulses per sixteen-second loop; rounded attacks.
            beat = (t * 1.875) % 1.0
            pulse = math.sin(math.pi * min(beat / .22, 1) / 2) ** 2 * math.exp(-beat * 5)
            value = (.2 + 1.8 * pulse) * body + pulse * (.16 * low + 1.4 * metal)
            value += .025 * (air - low) * drift
        else:
            envelope = math.sin(math.pi * min(t / 1.2, 1) / 2) ** 2
            envelope *= math.exp(-t / 2.7) * min(1.0, (seconds - t) / 1.5)
            value = envelope * (body + metal + .05 * low)
        values.append(value)
    return values


def run(ffmpeg: str, args: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run([ffmpeg, "-hide_banner", "-nostdin", "-y", *args],
                          check=True, capture_output=True)


def loudness(ffmpeg: str, path: Path, target: int, pre_filter: str = "") -> dict:
    proc = run(ffmpeg, ["-i", str(path), "-af", f"{pre_filter}loudnorm=I={target}:TP=-2:LRA=7:print_format=json", "-f", "null", "-"])
    match = re.search(r'\{\s*"input_i".*?\}', proc.stderr.decode(), re.S)
    if not match:
        raise RuntimeError(f"No loudness measurement for {path}")
    return json.loads(match.group())


def join_loop(path: Path, fade_seconds: float = 1.0, align_seam: bool = False) -> None:
    with wave.open(str(path), "rb") as src:
        samples = array("h", src.readframes(src.getnframes()))
    if sys.byteorder != "little":
        samples.byteswap()
    values = [s / 32767 for s in samples]
    count = round(fade_seconds * RATE)
    # Middle + tail/head crossfade: both ends retain adjacent source samples.
    blend = [values[-count + i] * (1 - i / (count - 1)) + values[i] * i / (count - 1) for i in range(count)]
    loop = values[count:-count] + blend
    if align_seam:
        # Rotate the already crossfaded loop to a low-slope, low-level sample.
        # This reduces codec-edge error for the new high-frequency ballast buzz.
        seam = min(range(1, RATE // 10), key=lambda i: abs(loop[i] - loop[i - 1]) + .01 * abs(loop[i]))
        loop = loop[seam:] + loop[:seam]
    write_wav(path, loop)


def import_settings(path: Path, loop: bool) -> None:
    sidecar = Path(str(path) + ".import")
    if sidecar.exists():
        contents = sidecar.read_text(encoding="utf-8")
        contents = re.sub(r"(?m)^loop=.*$", f"loop={str(loop).lower()}", contents)
    else:
        relative = path.relative_to(ROOT / "game").as_posix()
        contents = ('[remap]\n\nimporter="oggvorbisstr"\ntype="AudioStreamOggVorbis"\n\n'
                    f'[deps]\n\nsource_file="res://{relative}"\n\n[params]\n\n'
                    f'loop={str(loop).lower()}\nloop_offset=0.0\nbpm=0.0\nbeat_count=0\nbar_beats=4\n')
    sidecar.write_text(contents, encoding="utf-8", newline="\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg", default=os.environ.get("FFMPEG"))
    parser.add_argument("--regenerate-raw", action="store_true", help="Recreate original WAVs with fixed seeds")
    args = parser.parse_args()
    candidates = sorted(Path("D:/Tools/ffmpeg").glob("**/ffmpeg.exe"))
    ffmpeg = args.ffmpeg or shutil.which("ffmpeg") or (str(candidates[0]) if candidates else None)
    if not ffmpeg:
        parser.error("Install portable FFmpeg in D:/Tools/ffmpeg or pass --ffmpeg")
    raw_dir = SOURCE / "raw"
    raw_dir.mkdir(exist_ok=True)
    report = {"ffmpeg": run(ffmpeg, ["-version"]).stdout.decode().splitlines()[0], "assets": []}
    with tempfile.TemporaryDirectory(prefix="processing_", dir=SOURCE) as temp:
        for name, category, seconds, seed in ASSETS:
            raw = raw_dir / f"{name}.wav"
            if args.regenerate_raw or not raw.exists():
                write_wav(raw, synthesize(name, seconds, seed))
            loop = category == "ambience" or name in LOOP_SFX or name in MUSIC_LOOPS
            target = target_lufs(name, loop)
            prepared = Path(temp) / f"{name}.wav"
            filters = f"atrim=start=0:end={seconds},asetpts=PTS-STARTPTS,highpass=f=35,lowpass=f=11000"
            if not loop:
                # Footsteps skip the compressor: it flattens heel vs. sole-slap dynamics.
                if not name.startswith("slipper_"):
                    filters += ",acompressor=threshold=0.025:ratio=6:attack=0.1:release=80:makeup=1:knee=2"
                filters += f",afade=t=in:d=0.008,afade=t=out:st={seconds - .08}:d=0.08"
            run(ffmpeg, ["-i", str(raw), "-af", filters, "-ar", str(RATE), "-ac", "1", "-c:a", "pcm_s16le", str(prepared)])
            if loop:
                join_loop(prepared, align_seam=name == "fluorescent_hum")
            measured = loudness(ffmpeg, prepared, target)
            norm = (f"loudnorm=I={target}:TP=-2:LRA=7:linear=true:"
                    f"measured_I={measured['input_i']}:measured_TP={measured['input_tp']}:"
                    f"measured_LRA={measured['input_lra']}:measured_thresh={measured['input_thresh']}:"
                    f"offset={measured['target_offset']}")
            out = OUTPUT / category / f"{name}.ogg"
            out.parent.mkdir(parents=True, exist_ok=True)
            correction_db = 0.0
            # Short transients and Vorbis can shift the gated measurement.
            # Re-encode from PCM with a measured correction, never from lossy OGG.
            for attempt in range(3):
                run(ffmpeg, ["-i", str(prepared), "-af", f"{norm},volume={correction_db:.4f}dB", "-ar", str(RATE), "-ac", "1", "-map_metadata", "-1",
                             "-c:a", "libvorbis", "-q:a", "4", "-fflags", "+bitexact", "-flags:a", "+bitexact", str(out)])
                actual = loudness(ffmpeg, out, target)
                delta = target - float(actual["input_i"])
                if abs(delta) <= 0.5:
                    break
                correction_db += min(delta, -2.0 - float(actual["input_tp"]))
            import_settings(out, loop)
            decoded = run(ffmpeg, ["-i", str(out), "-f", "f32le", "-ac", "1", "-ar", str(RATE), "-"])
            pcm = array("f", decoded.stdout)
            if sys.byteorder != "little":
                pcm.byteswap()
            entry = {"file": out.relative_to(ROOT).as_posix(), "sha256": hashlib.sha256(out.read_bytes()).hexdigest(),
                     "raw_sha256": hashlib.sha256(raw.read_bytes()).hexdigest(), "bytes": out.stat().st_size,
                     "seconds": round(len(pcm) / RATE, 4), "channels": 1, "lufs": float(actual["input_i"]),
                     "true_peak_db": float(actual["input_tp"]), "loop": loop,
                     "boundary_delta": round(abs(pcm[0] - pcm[-1]), 7)}
            if abs(entry["lufs"] - target) > 1 or entry["true_peak_db"] > -1:
                raise RuntimeError(f"Loudness/peak validation failed: {entry}")
            if loop and entry["boundary_delta"] > .02:
                raise RuntimeError(f"Loop boundary validation failed: {entry}")
            if name == "fluorescent_hum":
                filtered = loudness(ffmpeg, out, target, "highpass=f=200:p=2,")
                entry["highpass_200hz_lufs"] = float(filtered["input_i"])
                entry["highpass_200hz_loss_lu"] = round(entry["lufs"] - entry["highpass_200hz_lufs"], 2)
                if not math.isfinite(entry["highpass_200hz_lufs"]) or entry["highpass_200hz_loss_lu"] > 10:
                    raise RuntimeError(f"Small-speaker validation failed: {entry}")
                print(f"HUM HP200: {entry['lufs']} -> {entry['highpass_200hz_lufs']} LUFS; loss {entry['highpass_200hz_loss_lu']} LU", flush=True)
            report["assets"].append(entry)
            print(f"{name}: {entry['lufs']} LUFS, {entry['true_peak_db']} dBTP, {entry['bytes']} bytes", flush=True)
    (SOURCE / "build_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    total = sum(p.stat().st_size for p in raw_dir.glob("*.wav")) + sum(p.stat().st_size for p in OUTPUT.rglob("*.ogg"))
    # T-133 adds long music loops; retain a bounded total and the per-file LFS limit.
    if total >= 20_000_000:
        raise RuntimeError(f"Audio exceeds 20 MB: {total}")
    print(f"AUDIO RESULT: {len(ASSETS)} assets validated; raw + OGG = {total} bytes")


if __name__ == "__main__":
    main()
