"""Pack the Tripo dorm manager into one game GLB (T-219, D-118).

    python -I pack_tripo_manager.py --staging <dir> --out <game glb>

Tripo Studio exports every animation as its own GLB with the full rigged body.
The plain "rigged" export has identity joint transforms (no usable rest), so an
animation export is the base: its nodes carry the skeleton rest.

1. Keep the base mesh, skin and materials; drop its animations.
2. Copy each clip in CLIPS from its source file, matching joints by node name,
   and rename it to the clip name manager.gd plays.
3. Strip horizontal root motion (Hips X/Z) from travelling clips: manager.gd
   moves the node itself.
4. Downscale textures above MAX_TEX (Tripo exports 4096 base colour).

Scale (Tripo characters stand about 0.98 m tall) and facing (+Z) are fixed in
the Godot import and the body scene, not here.
"""
import argparse
import io
import json
import struct
from pathlib import Path

from PIL import Image

BASE = "manager_idle.glb"
# (source file, source animation, game clip, strip horizontal root motion, (start, end) seconds or None)
CLIPS = [
    ("manager_idle.glb", "idle", "stand", False, None),
    ("manager_walk_v2.glb", "walk", "walk", True, None),
    ("manager_bow.glb", "bow", "ask", False, None),
    ("manager_wait.glb", "wait", "wait", False, None),
    # Tripo "slash" is 6.6 s: windup 1.3-1.8 s, chop to knee height by 2.2 s, back to the
    # windup start pose by 3.1 s. That window restarts cleanly for the director's 6 chops.
    ("manager_slash.glb", "slash", "slash", True, (1.15, 3.10)),
    ("manager_run.glb", "run", "lunge", True, None),
    # Tripo has no kill clip: one windup and chop, ending low (played over 0.65 s).
    ("manager_slash.glb", "slash", "kill", True, (1.15, 2.30)),
]
HIPS = "mixamorig:Hips"
MAX_TEX = 2048
# Scale keys that never leave 1.0 within this tolerance are dropped (Tripo bakes a scale
# channel for every joint); the file must stay under the 10 MiB limit.
SCALE_EPSILON = 1e-4
COMPONENTS = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}
COMPONENT_BYTES = {5120: 1, 5121: 1, 5122: 2, 5123: 2, 5125: 4, 5126: 4}


def read_glb(path):
    data = Path(path).read_bytes()
    magic, _, _ = struct.unpack_from("<III", data, 0)
    assert magic == 0x46546C67, f"{path} is not a GLB"
    offset, js, binary = 12, None, b""
    while offset < len(data):
        length, kind = struct.unpack_from("<II", data, offset)
        chunk = data[offset + 8:offset + 8 + length]
        if kind == 0x4E4F534A:
            js = json.loads(chunk)
        elif kind == 0x004E4942:
            binary = chunk
        offset += 8 + length
    return js, binary


def view_bytes(js, binary, index):
    view = js["bufferViews"][index]
    start = view.get("byteOffset", 0)
    return binary[start:start + view["byteLength"]]


def accessor_bytes(js, binary, index):
    acc = js["accessors"][index]
    size = COMPONENT_BYTES[acc["componentType"]] * COMPONENTS[acc["type"]]
    view = js["bufferViews"][acc["bufferView"]]
    stride = view.get("byteStride", size)
    raw = view_bytes(js, binary, acc["bufferView"])
    start = acc.get("byteOffset", 0)
    return b"".join(raw[start + i * stride:start + i * stride + size] for i in range(acc["count"]))


def sample(keys, t, width):
    """Linear sample of a (time, value) key list; quaternions are normalised after the lerp."""
    if t <= keys[0][0]:
        return list(keys[0][1])
    for (t0, v0), (t1, v1) in zip(keys, keys[1:]):
        if t0 <= t <= t1:
            f = 0.0 if t1 == t0 else (t - t0) / (t1 - t0)
            if width == 4 and sum(a * b for a, b in zip(v0, v1)) < 0.0:
                v1 = [-c for c in v1]
            v = [a + (b - a) * f for a, b in zip(v0, v1)]
            if width == 4:
                n = sum(c * c for c in v) ** 0.5
                v = [c / n for c in v]
            return v
    return list(keys[-1][1])


class Writer:
    def __init__(self):
        self.binary = bytearray()
        self.views = []

    def add(self, data):
        while len(self.binary) % 4:
            self.binary.append(0)
        self.views.append({"buffer": 0, "byteOffset": len(self.binary), "byteLength": len(data)})
        self.binary += data
        return len(self.views) - 1


def shrink_image(data):
    """Return JPEG bytes no larger than MAX_TEX. Tripo's maps are opaque (colour, normal,
    roughness/metal); the 2048 roughness/metal PNG alone is 4 MiB, the JPEG about 1 MiB."""
    image = Image.open(io.BytesIO(data))
    if max(image.size) > MAX_TEX:
        image = image.resize((MAX_TEX, MAX_TEX), Image.LANCZOS)
    out = io.BytesIO()
    image.convert("RGB").save(out, "JPEG", quality=92)
    return out.getvalue(), image.size


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--staging", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    staging = Path(args.staging)

    js, binary = read_glb(staging / BASE)
    writer = Writer()
    # Re-lay every base buffer view so images can shrink in place.
    image_views = {img["bufferView"] for img in js.get("images", [])}
    # Tripo names maps after the clip it exported ("manager_run_basecolor"); keep only the map kind
    # so Godot extracts manager_tripo_basecolor.jpg and friends.
    for img in js.get("images", []):
        img["name"] = img.get("name", "map").rsplit("_", 1)[-1]
        img["mimeType"] = "image/jpeg"
    for index, view in enumerate(js["bufferViews"]):
        data = view_bytes(js, binary, index)
        if index in image_views:
            data, size = shrink_image(data)
            print(f"image view {index}: {size[0]}x{size[1]} JPEG, {len(data) // 1024} KiB")
        new = writer.add(data)
        for key in ("byteStride", "target"):
            if key in view:
                writer.views[new][key] = view[key]

    nodes = {node.get("name"): i for i, node in enumerate(js["nodes"])}
    hips_rest = js["nodes"][nodes[HIPS]].get("translation", [0.0, 0.0, 0.0])
    animations = []
    for source, name, clip, strip, window in CLIPS:
        sjs, sbin = read_glb(staging / source)
        anim = next(a for a in sjs["animations"] if a["name"] == name)
        samplers, channels, times_cache = [], [], {}
        dropped = 0
        for channel in anim["channels"]:
            node_name = sjs["nodes"][channel["target"]["node"]].get("name")
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
            if path == "scale" and all(abs(c - 1.0) < SCALE_EPSILON for _, v in keys for c in v):
                dropped += 1
                continue
            if strip and node_name == HIPS and path == "translation":
                keys = [(t, [hips_rest[0], v[1], hips_rest[2]]) for t, v in keys]
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
        notes = [f"{dropped} constant scale channels dropped"]
        if strip:
            notes.append("root motion stripped")
        if window is not None:
            notes.append(f"trimmed {window[0]:.2f}-{window[1]:.2f} s")
        print(f"clip {clip} <- {source}:{name}, {len(channels)} channels, {length:.2f} s, " + ", ".join(notes))
        animations.append({"name": clip, "channels": channels, "samplers": samplers})

    js["animations"] = animations
    js["bufferViews"] = writer.views
    js["buffers"] = [{"byteLength": len(writer.binary)}]
    js["asset"]["generator"] = "Tripo Studio, packed by pack_tripo_manager.py (T-219)"
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
