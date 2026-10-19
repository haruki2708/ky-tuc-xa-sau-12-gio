"""Pack the Tripo dorm manager into one game GLB (T-219, D-118, D-120).

    python -I pack_tripo_manager.py --staging <dir> --out <game glb>

Tripo Studio exports every animation as its own GLB with the full rigged body.
The plain "rigged" export has identity joint transforms (no usable rest), so an
animation export is the base: its nodes carry the skeleton rest.

1. Keep the base mesh, skin and materials; drop its animations.
2. Copy each clip in CLIPS from its source file, matching joints by node name,
   and rename it to the clip name manager.gd plays.
3. Strip horizontal root motion (Hips X/Z) from travelling clips: manager.gd
   moves the node itself.
4. Paint milky eyes into the base colour (Tripo's texture lost the reference's white eyes)
   and make them wet in the roughness map.
5. Downscale textures above MAX_TEX (Tripo exports 4096 base colour).

Scale (Tripo characters stand about 0.98 m tall) and facing (+Z) are fixed in
the Godot import and the body scene, not here.
"""
import argparse
import io
import json
import struct
from pathlib import Path

import numpy as np
from PIL import Image

BASE = "manager_idle.glb"
# (source file, source animation, game clip, strip horizontal root motion, (start, end) seconds or None)
CLIPS = [
    ("manager_idle.glb", "idle", "stand", False, None),
    ("manager_walk_v2.glb", "walk", "walk", True, None),
    # D-120: the owner chose Tripo "wait" (hand on hip) for the question, not "bow".
    ("manager_wait.glb", "wait", "ask", False, None),
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
# Milky eyes (D-120): eye openings measured on a front render of the bind pose, in Tripo mesh
# metres (the model faces +Z): centre x, centre y, half width, half height.
EYES = [(-0.0176, 0.9009, 0.0083, 0.0026), (0.0174, 0.9007, 0.0078, 0.0027)]
IRIS_RADIUS = 0.0034
SCLERA = np.array([0.80, 0.80, 0.76])
GHOST_IRIS = np.array([0.62, 0.65, 0.66])
CLOUDY_PUPIL = np.array([0.86, 0.87, 0.85])
EYE_ROUGHNESS = 0.25
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


def shrink_image(image):
    """Return JPEG bytes no larger than MAX_TEX. Tripo's maps are opaque (colour, normal,
    roughness/metal); the 2048 roughness/metal PNG alone is 4 MiB, the JPEG about 1 MiB."""
    if max(image.size) > MAX_TEX:
        image = image.resize((MAX_TEX, MAX_TEX), Image.LANCZOS)
    out = io.BytesIO()
    image.convert("RGB").save(out, "JPEG", quality=92)
    return out.getvalue(), image.size


def smoothstep(edge0, edge1, x):
    t = np.clip((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def raster_uv(tri_uv, tri_pos, width, height, margin=0.0):
    """Texel centres inside a UV triangle grown by margin texels: (ys, xs, mesh positions, strictly inside)."""
    px = tri_uv[:, 0] * width
    py = tri_uv[:, 1] * height
    xmin, xmax = int(max(0, np.floor(px.min() - margin))), int(min(width - 1, np.ceil(px.max() + margin)))
    ymin, ymax = int(max(0, np.floor(py.min() - margin))), int(min(height - 1, np.ceil(py.max() + margin)))
    if xmax < xmin or ymax < ymin:
        return None
    gx, gy = np.meshgrid(np.arange(xmin, xmax + 1) + 0.5, np.arange(ymin, ymax + 1) + 0.5)
    d = (py[1] - py[2]) * (px[0] - px[2]) + (px[2] - px[1]) * (py[0] - py[2])
    if abs(d) < 1e-12:
        return None
    l0 = ((py[1] - py[2]) * (gx - px[2]) + (px[2] - px[1]) * (gy - py[2])) / d
    l1 = ((py[2] - py[0]) * (gx - px[2]) + (px[0] - px[2]) * (gy - py[2])) / d
    l2 = 1 - l0 - l1
    # Barycentric -> texels outside each edge: l_i times the triangle height over edge i.
    heights = [abs(d) / max(1e-9, np.hypot(px[j] - px[k], py[j] - py[k])) for j, k in ((1, 2), (2, 0), (0, 1))]
    dist = np.minimum(np.minimum(l0 * heights[0], l1 * heights[1]), l2 * heights[2])
    inside = dist >= -margin
    if not inside.any():
        return None
    ys, xs = np.nonzero(inside)
    bary = np.stack([l0[inside], l1[inside], l2[inside]], axis=1)
    return ys + ymin, xs + xmin, bary @ tri_pos, dist[inside] >= 0.0


def paint_milky_eyes(js, binary):
    """Return {image index: PIL image} with the base colour and roughness/metal maps repainted.

    Every texel of the eye triangles is mapped back to mesh space; texels inside an almond around
    each opening become a clouded eye (pale sclera, faint grey iris, cloudy pupil, lid shadow).
    A 1.5 texel skirt fills the UV gutter so filtering does not pull the old iris back in, but
    never over a texel another triangle owns."""
    primitive = js["meshes"][0]["primitives"][0]

    def array(index, width):
        dtype = {5126: np.float32, 5125: np.uint32, 5123: np.uint16}[js["accessors"][index]["componentType"]]
        values = np.frombuffer(accessor_bytes(js, binary, index), dtype=dtype)
        return values.reshape(-1, width) if width > 1 else values

    pos = array(primitive["attributes"]["POSITION"], 3)
    uv = array(primitive["attributes"]["TEXCOORD_0"], 2)
    tris = array(primitive["indices"], 1).reshape(-1, 3)
    pbr = js["materials"][primitive["material"]]["pbrMetallicRoughness"]
    colour_index = js["textures"][pbr["baseColorTexture"]["index"]]["source"]
    rm_index = js["textures"][pbr["metallicRoughnessTexture"]["index"]]["source"]

    def load(index):
        data = view_bytes(js, binary, js["images"][index]["bufferView"])
        return np.asarray(Image.open(io.BytesIO(data)).convert("RGB")).astype(np.float32)

    colour = load(colour_index)
    height, width = colour.shape[:2]
    weight = np.zeros((height, width), np.float32)
    painted = np.zeros((height, width, 3), np.float32)
    owned = np.zeros((height, width), bool)
    for tri in tris:
        hit = raster_uv(uv[tri], pos[tri], width, height)
        if hit is not None:
            owned[hit[0][hit[3]], hit[1][hit[3]]] = True
    low, high = pos[tris].min(axis=1), pos[tris].max(axis=1)
    near = np.zeros(len(tris), bool)
    for cx, cy, a, b in EYES:
        near |= ((low[:, 0] < cx + a * 1.2) & (high[:, 0] > cx - a * 1.2) & (low[:, 1] < cy + b * 1.5)
                 & (high[:, 1] > cy - b * 1.5) & (high[:, 2] > 0.04))
    for tri in tris[near]:
        hit = raster_uv(uv[tri], pos[tri], width, height, margin=1.5)
        if hit is None:
            continue
        ys, xs, p, strict = hit
        keep = strict | ~owned[ys, xs]
        ys, xs, p = ys[keep], xs[keep], p[keep]
        total = np.zeros(len(ys), np.float32)
        mixed = np.zeros((len(ys), 3), np.float32)
        for cx, cy, a, b in EYES:
            du = (p[:, 0] - cx) / a
            dv = (p[:, 1] - cy) / b
            lens = np.maximum(1e-4, 1.0 - np.minimum(np.abs(du), 1.0) ** 2.2) ** 0.6
            s = np.abs(dv) / lens
            mask = smoothstep(1.05, 0.8, s) * smoothstep(1.05, 0.85, np.abs(du))
            r = np.hypot(p[:, 0] - cx, p[:, 1] - cy) / IRIS_RADIUS
            c = np.tile(SCLERA, (len(ys), 1))
            iris = smoothstep(1.0, 0.8, r)[:, None] * 0.8
            c = c * (1 - iris) + GHOST_IRIS * iris
            pupil = smoothstep(0.45, 0.2, r)[:, None] * 0.7
            c = c * (1 - pupil) + CLOUDY_PUPIL * pupil
            shade = (1.0 - 0.30 * smoothstep(-0.2, 1.0, dv)) * (0.70 + 0.30 * (1.0 - np.clip(s, 0.0, 1.0)))
            mixed += c * shade[:, None] * mask[:, None]
            total += mask
        sel = total > 0
        weight[ys[sel], xs[sel]] = np.maximum(weight[ys[sel], xs[sel]], np.clip(total[sel], 0.0, 1.0))
        painted[ys[sel], xs[sel]] = mixed[sel] / total[sel, None]
    colour = colour * (1 - weight[..., None]) + painted * 255.0 * weight[..., None]
    print(f"milky eyes: {int((weight > 0).sum())} colour texels repainted")
    rm = load(rm_index)
    if rm.shape[:2] != weight.shape:
        weight = np.asarray(Image.fromarray(weight).resize(rm.shape[1::-1], Image.BILINEAR))
    # glTF metallicRoughness: G = roughness, B = metal. Wet, non-metal eyes.
    rm[..., 1] = rm[..., 1] * (1 - weight) + EYE_ROUGHNESS * 255.0 * weight
    rm[..., 2] = rm[..., 2] * (1 - weight)
    return {colour_index: Image.fromarray(np.clip(colour, 0, 255).astype(np.uint8)),
            rm_index: Image.fromarray(np.clip(rm, 0, 255).astype(np.uint8))}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--staging", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    staging = Path(args.staging)

    js, binary = read_glb(staging / BASE)
    writer = Writer()
    repainted = paint_milky_eyes(js, binary)
    # Re-lay every base buffer view so images can shrink in place.
    image_views = {img["bufferView"]: i for i, img in enumerate(js.get("images", []))}
    # Tripo names maps after the clip it exported ("manager_run_basecolor"); keep only the map kind
    # so Godot extracts manager_tripo_basecolor.jpg and friends.
    for img in js.get("images", []):
        img["name"] = img.get("name", "map").rsplit("_", 1)[-1]
        img["mimeType"] = "image/jpeg"
    for index, view in enumerate(js["bufferViews"]):
        data = view_bytes(js, binary, index)
        if index in image_views:
            image = repainted.get(image_views[index]) or Image.open(io.BytesIO(data))
            data, size = shrink_image(image)
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
