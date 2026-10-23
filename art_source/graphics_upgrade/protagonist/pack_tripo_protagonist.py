"""Pack the Tripo protagonist Tran Trung into one game GLB (T-227, D-137, D-138).

    python -I pack_tripo_protagonist.py --staging <dir> --out <game glb>

Same Tripo Studio export as the manager (pack_tripo_manager.py): every animation is its own GLB
with the full rigged body, and an animation export is the base because its nodes carry the
skeleton rest.

1. Keep the base mesh, skin and materials; drop its animations.
2. Drop the "mixamorig:" prefix from joint names, so the Godot bone map (trung_bone_map.tres)
   reads plain Mixamo names.
3. Copy each clip in CLIPS from its source file, matching joints by name, and rename it to the
   key player_body.gd plays.
4. Strip horizontal root motion (Hips X/Z) from clips the player moves itself.
5. Drop channels that never leave the rest (Tripo bakes translation and scale for every joint).
6. Downscale textures above MAX_TEX (Tripo exports 4096 maps).

Clips Tripo has no preset for come from the CC0 Quaternius library, retargeted by Godot at run
time (player_body.gd). Scale (Tripo characters stand about 0.98 m tall) is set in the Godot import.
"""
import argparse
import io
import json
import struct
import sys
from pathlib import Path

from PIL import Image

# Shares the manager script's GLB helpers; no __pycache__ beside it.
sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "manager"))
from pack_tripo_manager import Writer, accessor_bytes, read_glb, sample, shrink_image, view_bytes  # noqa: E402

BASE = "trung_idle.glb"
PREFIX = "mixamorig:"
# (source file, source animation, game clip, strip horizontal root motion, (start, end) seconds or None)
CLIPS = [
    # The first 5.6 s only: past 6 s Tripo's idle shifts his weight onto one hip, and the head
    # drifts 10 cm off the camera. player_body.gd plays this window back and forth.
    ("trung_idle.glb", "idle", "idle", False, (0.0, 5.6)),
    ("trung_walk.glb", "walk", "walk", True, None),
    ("trung_run.glb", "run", "run", True, None),
    ("trung_look_around.glb", "look_around", "look_around", False, None),
    ("trung_scared.glb", "scared_01", "scared", True, None),
    ("trung_hit_to_body.glb", "hit_to_body_02", "hit", True, None),
    ("trung_jump.glb", "jump", "jump", True, None),
    # Climbs onto a ledge about 1.7 m up and forward: the motion stays in for the bunk later.
    ("trung_climb.glb", "climb", "climb", False, None),
    # Seated the whole clip (hips at seat height).
    ("trung_sit.glb", "sit", "sit", False, None),
]
HIPS = "Hips"
MAX_TEX = 2048
EPSILON = 1e-4


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--staging", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    staging = Path(args.staging)

    js, binary = read_glb(staging / BASE)
    for node in js["nodes"]:
        node["name"] = node.get("name", "").removeprefix(PREFIX)
    writer = Writer()
    image_views = {img["bufferView"]: i for i, img in enumerate(js.get("images", []))}
    # Tripo names maps after the clip it exported ("trung_idle_basecolor"); keep only the map kind
    # so Godot extracts trung_tripo_basecolor.jpg and friends.
    for img in js.get("images", []):
        img["name"] = img.get("name", "map").rsplit("_", 1)[-1]
        img["mimeType"] = "image/jpeg"
    for index, view in enumerate(js["bufferViews"]):
        data = view_bytes(js, binary, index)
        if index in image_views:
            data, size = shrink_image(Image.open(io.BytesIO(data)))
            print(f"image view {index}: {size[0]}x{size[1]} JPEG, {len(data) // 1024} KiB")
        new = writer.add(data)
        for key in ("byteStride", "target"):
            if key in view:
                writer.views[new][key] = view[key]

    nodes = {node["name"]: i for i, node in enumerate(js["nodes"])}
    rest = {name: js["nodes"][i].get("translation", [0.0, 0.0, 0.0]) for name, i in nodes.items()}
    animations = []
    for source, name, clip, strip, window in CLIPS:
        sjs, sbin = read_glb(staging / source)
        anim = next(a for a in sjs["animations"] if a["name"] == name)
        samplers, channels, times_cache = [], [], {}
        dropped = 0
        for channel in anim["channels"]:
            node_name = sjs["nodes"][channel["target"]["node"]].get("name", "").removeprefix(PREFIX)
            path = channel["target"]["path"]
            if node_name not in nodes:
                continue
            sampler = anim["samplers"][channel["sampler"]]
            width = 4 if path == "rotation" else 3
            times = list(struct.unpack(f"<{sjs['accessors'][sampler['input']]['count']}f", accessor_bytes(sjs, sbin, sampler["input"])))
            values = list(struct.unpack(f"<{len(times) * width}f", accessor_bytes(sjs, sbin, sampler["output"])))
            keys = [(t, values[i * width:(i + 1) * width]) for i, t in enumerate(times)]
            if window is not None:
                inside = [(t, v) for t, v in keys if window[0] + 1e-4 < t < window[1] - 1e-4]
                keys = [(window[0], sample(keys, window[0], width))] + inside + [(window[1], sample(keys, window[1], width))]
                keys = [(t - window[0], v) for t, v in keys]
            if path == "scale" and all(abs(c - 1.0) < EPSILON for _, v in keys for c in v):
                dropped += 1
                continue
            if path == "translation" and node_name != HIPS and all(
                    abs(c - r) < EPSILON for _, v in keys for c, r in zip(v, rest[node_name])):
                dropped += 1
                continue
            if strip and node_name == HIPS and path == "translation":
                keys = [(t, [rest[HIPS][0], v[1], rest[HIPS][2]]) for t, v in keys]
            key_times = tuple(round(t, 6) for t, _ in keys)
            if key_times not in times_cache:
                data = struct.pack(f"<{len(key_times)}f", *key_times)
                js["accessors"].append({"bufferView": writer.add(data), "componentType": 5126, "count": len(key_times),
                                        "type": "SCALAR", "min": [min(key_times)], "max": [max(key_times)]})
                times_cache[key_times] = len(js["accessors"]) - 1
            flat = [c for _, v in keys for c in v]
            js["accessors"].append({"bufferView": writer.add(struct.pack(f"<{len(flat)}f", *flat)), "componentType": 5126,
                                    "count": len(keys), "type": "VEC4" if width == 4 else "VEC3"})
            samplers.append({"input": times_cache[key_times], "output": len(js["accessors"]) - 1,
                             "interpolation": sampler.get("interpolation", "LINEAR")})
            channels.append({"sampler": len(samplers) - 1, "target": {"node": nodes[node_name], "path": path}})
        length = max(js["accessors"][s["input"]]["max"][0] for s in samplers)
        notes = [f"{dropped} constant channels dropped"]
        if strip:
            notes.append("root motion stripped")
        if window is not None:
            notes.append(f"trimmed {window[0]:.2f}-{window[1]:.2f} s")
        print(f"clip {clip} <- {source}:{name}, {len(channels)} channels, {length:.2f} s, " + ", ".join(notes))
        animations.append({"name": clip, "channels": channels, "samplers": samplers})

    js["animations"] = animations
    js["bufferViews"] = writer.views
    js["buffers"] = [{"byteLength": len(writer.binary)}]
    js["asset"]["generator"] = "Tripo Studio, packed by pack_tripo_protagonist.py (T-227)"
    payload = json.dumps(js, separators=(",", ":")).encode()
    payload += b" " * (-len(payload) % 4)
    blob = bytes(writer.binary) + b"\0" * (-len(writer.binary) % 4)
    total = 12 + 8 + len(payload) + 8 + len(blob)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(struct.pack("<III", 0x46546C67, 2, total)
                    + struct.pack("<II", len(payload), 0x4E4F534A) + payload
                    + struct.pack("<II", len(blob), 0x004E4942) + blob)
    print(f"wrote {out} ({total / 1048576:.2f} MiB)")


if __name__ == "__main__":
    main()
