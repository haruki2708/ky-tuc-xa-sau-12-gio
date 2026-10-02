"""Props that replace floor 4 greybox boxes (T-138). Blender bundled Python, no addons.

Reuses the kit builder (art_source/kit/build_kit.py): same helpers, PS1 texture
style, front-is-Godot-minus-Z convention and GLB finalisation. Kit textures are
referenced, not copied; new textures go to game/assets/textures/props/.
"""
import hashlib
import json
import math
from pathlib import Path
import sys

import bpy
import bmesh

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "kit"))
import build_kit as kit  # noqa: E402

ROOT = kit.ROOT
MODELS = ROOT / "game/assets/models/props"
TEXTURES = ROOT / "game/assets/textures/props"
PREVIEWS = ROOT / "art_source/props/previews"
KIT_TEXTURES = ROOT / "game/assets/textures/kit"
SMALL = ("desk_lamp", "telephone", "desk_items", "tap", "slippers_pair", "shirt",
         "towel", "bucket", "pa_horn")
NEW_TEXTURES = [
    ("porcelain", (0.80, 0.82, 0.78), "speckle"),
    ("porcelain_dim", (0.50, 0.54, 0.52), "speckle"),
    ("inox", (0.56, 0.60, 0.60), "metal"),
    ("cork", (0.55, 0.40, 0.24), "speckle"),
    ("blue_paint", (0.13, 0.27, 0.36), "speckle"),
    ("foam", (0.86, 0.86, 0.84), "speckle"),
    ("white_cotton", (0.88, 0.88, 0.84), "cloth"),
    ("blue_plastic", (0.10, 0.30, 0.55), "speckle"),
    ("bakelite", (0.05, 0.05, 0.055), "speckle"),
    ("book_cloth", (0.36, 0.09, 0.07), "cloth"),
]
KIT_REUSED = ("old_wood", "iron", "cloth", "green_paint", "fan_paint")
REPORT = {}


def kit_material(name):
    """A material that points at the existing kit texture (no duplicate PNG)."""
    image = bpy.data.images.load(str(KIT_TEXTURES / f"{name}.png"), check_existing=True)
    image.name = name
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = 0.88
    tex = material.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.interpolation = "Closest"
    material.node_tree.links.new(tex.outputs["Color"], shader.inputs["Base Color"])
    kit.MATERIALS[name] = material


def finalize_gltf(path):
    """kit.finalize_gltf, but each image points at the props or the kit folder."""
    import struct
    data = path.read_bytes()
    json_size, chunk_type = struct.unpack_from("<II", data, 12)
    document = json.loads(data[20:20 + json_size])
    for sampler in document.get("samplers", []):
        sampler["magFilter"] = sampler["minFilter"] = 9728
    image_views = {image["bufferView"] for image in document["images"]}
    for image in document["images"]:
        name = image["name"]
        folder = "props" if (TEXTURES / f"{name}.png").is_file() else "kit"
        assert (ROOT / f"game/assets/textures/{folder}/{name}.png").is_file(), name
        image.pop("bufferView")
        image.pop("mimeType", None)
        image["uri"] = f"../../textures/{folder}/{name}.png"
    old_binary = data[28 + json_size:]
    binary, views, mapping = bytearray(), [], {}
    for old_index, view in enumerate(document["bufferViews"]):
        if old_index in image_views:
            continue
        binary.extend(b"\0" * (-len(binary) % 4))
        offset = view.get("byteOffset", 0)
        mapping[old_index] = len(views)
        views.append(dict(view, byteOffset=len(binary)))
        binary.extend(old_binary[offset:offset + view["byteLength"]])
    for accessor in document["accessors"]:
        if "bufferView" in accessor:
            accessor["bufferView"] = mapping[accessor["bufferView"]]
    document["bufferViews"] = views
    document["buffers"] = [{"byteLength": len(binary)}]
    binary.extend(b"\0" * (-len(binary) % 4))
    payload = json.dumps(document, separators=(",", ":")).encode("utf-8")
    payload += b" " * (-len(payload) % 4)
    tail = struct.pack("<II", len(binary), 0x004E4942) + binary
    path.write_bytes(struct.pack("<4sII", b"glTF", 2, 20 + len(payload) + len(tail)) +
                     struct.pack("<II", len(payload), chunk_type) + payload + tail)


# --- Small geometry helpers ---------------------------------------------------

box = kit.box
cylinder = kit.cylinder


def cone(name, location, r_bottom, r_top, depth, material, parent, vertices=10,
         rotation=(0, 0, 0), open_ends=False, inside=None):
    """Tapered tube along local Z. open_ends leaves both caps off; inside adds a
    flipped inner skin in another material so open shapes read from within."""
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=r_bottom, radius2=r_top,
                                    depth=depth, location=location,
                                    end_fill_type="NOTHING" if open_ends else "NGON")
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = rotation
    obj.parent = parent
    obj.data.materials.append(kit.MATERIALS[material])
    if inside:
        bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=r_bottom * 0.94,
                                        radius2=r_top * 0.94, depth=depth * 0.99,
                                        location=location, end_fill_type="NOTHING")
        inner = bpy.context.object
        inner.name = name + "_inside"
        inner.rotation_euler = rotation
        inner.parent = parent
        inner.data.materials.append(kit.MATERIALS[inside])
        bm = bmesh.new()
        bm.from_mesh(inner.data)
        bmesh.ops.reverse_faces(bm, faces=list(bm.faces))
        bm.to_mesh(inner.data)
        bm.free()
    return obj


def prism(name, outline, y0, y1, material, parent):
    """Extrudes an XZ outline (front at y0, back at y1)."""
    count = len(outline)
    vertices = [(x, y0, z) for x, z in outline] + [(x, y1, z) for x, z in outline]
    faces = [tuple(range(count)), tuple(reversed(range(count, 2 * count)))]
    faces += [(i, (i + 1) % count, (i + 1) % count + count, i + count) for i in range(count)]
    return kit.mesh_object(name, vertices, faces, material, parent)


def slab(name, outline, z0, z1, material, parent):
    """Extrudes an XY outline between heights z0 and z1."""
    count = len(outline)
    vertices = [(x, y, z0) for x, y in outline] + [(x, y, z1) for x, y in outline]
    faces = [tuple(reversed(range(count))), tuple(range(count, 2 * count))]
    faces += [(i, (i + 1) % count, (i + 1) % count + count, i + count) for i in range(count)]
    return kit.mesh_object(name, vertices, faces, material, parent)


# --- Props ---------------------------------------------------------------------
# Blender: metres, Z up, front faces -Y (Godot -Z after export).

def desk(root):
    # 1.5 x 0.65 x 0.8 m office desk; drawers on the front (-Y) left pedestal.
    box("top", (0, 0, 0.785), (1.5, 0.65, 0.03), "old_wood", root)
    box("pedestal", (-0.52, 0.02, 0.385), (0.42, 0.58, 0.77), "old_wood", root)
    for i, z in enumerate((0.64, 0.42, 0.17)):
        height = 0.17 if i == 0 else 0.2
        box("drawer", (-0.52, -0.275, z), (0.38, 0.025, height), "old_wood", root)
        box("pull", (-0.52, -0.293, z + 0.02), (0.1, 0.014, 0.018), "iron", root)
    box("side", (0.72, 0.02, 0.385), (0.03, 0.58, 0.77), "old_wood", root)
    box("modesty", (0.1, 0.27, 0.45), (1.2, 0.025, 0.5), "old_wood", root)
    box("rail", (0.1, -0.29, 0.745), (1.2, 0.02, 0.05), "old_wood", root)


def desk_lamp(root):
    # Origin at the bulb; base sits 0.26 m below (matches the old lamp boxes).
    cylinder("base", (0, 0.04, -0.25), 0.08, 0.025, "green_paint", root, 10)
    box("stem", (0, 0.06, -0.12), (0.022, 0.022, 0.25), "iron", root)
    arm = box("arm", (0, 0.03, 0.02), (0.02, 0.1, 0.02), "iron", root)
    arm.rotation_euler.x = 0.5
    cone("shade", (0, 0, 0.0), 0.11, 0.035, 0.11, "green_paint", root, 10,
         open_ends=True, inside="porcelain")
    cylinder("cap", (0, 0, 0.058), 0.04, 0.012, "green_paint", root, 8)


def telephone(root):
    # Old rotary desk phone, 0.22 x 0.18 m footprint.
    box("body", (0, 0, 0.035), (0.21, 0.17, 0.07), "bakelite", root)
    top = box("slope", (0, -0.015, 0.085), (0.18, 0.12, 0.04), "bakelite", root)
    top.rotation_euler.x = -0.32
    dial = cylinder("dial", (0, -0.06, 0.088), 0.052, 0.012, "cloth", root, 12)
    dial.rotation_euler.x = -0.32
    cylinder("dial_hub", (0, -0.062, 0.096), 0.016, 0.012, "bakelite", root, 8).rotation_euler.x = -0.32
    for x in (-0.07, 0.07):
        box("cradle", (x, 0.03, 0.11), (0.03, 0.05, 0.03), "bakelite", root)
        box("cup", (x * 1.15, 0.03, 0.14), (0.055, 0.065, 0.04), "bakelite", root)
    box("handset", (0, 0.03, 0.15), (0.18, 0.04, 0.03), "bakelite", root)
    box("cord", (0.1, 0.07, 0.03), (0.02, 0.06, 0.02), "bakelite", root)


def desk_items(root):
    # Laid out in desk-top space (origin = desk top centre, front -Y), placed
    # with the duty desk. Avoids the open log, lamp and telephone spots.
    for i, (material, dy, angle) in enumerate((("book_cloth", 0.0, 0.05), ("blue_paint", 0.004, -0.08))):
        book = box("ledger", (0.6, 0.2 + dy, 0.015 + i * 0.03), (0.24, 0.32, 0.028), material, root)
        book.rotation_euler.z = angle
        box("pages", (0.6, 0.2 + dy, 0.015 + i * 0.03), (0.225, 0.31, 0.022), "cloth", root).rotation_euler.z = angle
    box("ink_pad", (0.16, -0.06, 0.008), (0.1, 0.07, 0.016), "bakelite", root)
    box("stamp_foot", (0.06, -0.08, 0.012), (0.05, 0.035, 0.024), "old_wood", root)
    cylinder("stamp_handle", (0.06, -0.08, 0.05), 0.012, 0.055, "old_wood", root, 8)
    cylinder("stamp_knob", (0.06, -0.08, 0.083), 0.02, 0.02, "old_wood", root, 8)
    cylinder("pen_cup", (-0.68, 0.17, 0.05), 0.035, 0.1, "blue_plastic", root, 8)
    for dx, angle in ((-0.01, 0.12), (0.012, -0.1)):
        pen = cylinder("pen", (-0.68 + dx, 0.17, 0.12), 0.005, 0.14, "bakelite", root, 4)
        pen.rotation_euler.y = angle


def hall_board(root):
    # 0.75 x 0.9 m board, 0.06 m deep, origin at its centre.
    for x in (-0.355, 0.355):
        box("frame_side", (x, 0, 0), (0.04, 0.06, 0.9), "old_wood", root)
    for z in (-0.43, 0.43):
        box("frame_rail", (0, 0, z), (0.67, 0.06, 0.04), "old_wood", root)
    box("cork", (0, 0.008, 0), (0.67, 0.035, 0.82), "cork", root)
    box("title_strip", (0, -0.026, 0.37), (0.4, 0.008, 0.05), "cloth", root)


def sink(root):
    # Pedestal basin against the wall (+Y is the wall side). Top at 0.86 m.
    cylinder("pedestal", (0, 0.06, 0.34), 0.085, 0.68, "porcelain", root, 10)
    basin = cylinder("basin", (0, -0.02, 0.76), 0.3, 0.2, "porcelain", root, 12)
    basin.scale = (1.0, 0.8, 1.0)
    bowl = cylinder("bowl", (0, -0.04, 0.862), 0.24, 0.004, "porcelain_dim", root, 12)
    bowl.scale = (1.0, 0.72, 1.0)
    cylinder("drain", (0, -0.04, 0.866), 0.025, 0.004, "inox", root, 8)
    box("splash", (0, 0.225, 0.92), (0.6, 0.03, 0.14), "porcelain", root)


def tap(root):
    # Deck faucet, origin at its foot; the spout points front (-Y).
    cylinder("foot", (0, 0, 0.01), 0.028, 0.02, "inox", root, 8)
    cylinder("body", (0, 0, 0.09), 0.016, 0.14, "inox", root, 8)
    spout = cylinder("spout", (0, -0.055, 0.155), 0.011, 0.12, "inox", root, 6)
    spout.rotation_euler.x = math.pi / 2
    cylinder("nozzle", (0, -0.112, 0.14), 0.012, 0.03, "inox", root, 6)
    box("handle_x", (0, 0, 0.175), (0.08, 0.014, 0.012), "inox", root)
    box("handle_y", (0, 0, 0.175), (0.014, 0.08, 0.012), "inox", root)
    cylinder("cap", (0, 0, 0.19), 0.01, 0.015, "blue_paint", root, 6)


def stall_front(root):
    # 1.94 x 2.2 m stall front: two fixed panels and a door with a gap below.
    for x in (-0.71, 0.71):
        box("panel", (x, 0, 1.1), (0.52, 0.05, 2.2), "blue_paint", root)
    box("door", (0, 0.01, 1.075), (0.88, 0.04, 1.85), "blue_paint", root)
    box("transom", (0, 0, 2.1), (0.9, 0.05, 0.2), "blue_paint", root)
    box("handle", (0.35, -0.025, 1.0), (0.025, 0.03, 0.12), "inox", root)
    box("latch", (0.35, -0.022, 1.16), (0.06, 0.02, 0.03), "inox", root)
    for z in (0.35, 1.75):
        box("hinge", (-0.43, -0.02, z), (0.02, 0.02, 0.1), "inox", root)


def _sole_outline(side):
    points = []
    for i in range(14):
        theta = i / 14 * math.tau
        c, s = math.cos(theta), math.sin(theta)
        y = 0.13 * math.copysign(abs(s) ** 0.8, s)
        width = 0.047 * (1.0 + 0.16 * (y / 0.13))
        x = width * math.copysign(abs(c) ** 0.7, c) + side * 0.008 * (y / 0.13)
        points.append((x, -y))
    return points


def slippers_pair(root):
    # Vietnamese "dép lê": foam sole and one broad strap. Foam is tinted in
    # Godot (slippers_pair.gd), so the texture stays near white.
    for side, x, angle in ((-1, -0.065, 0.05), (1, 0.065, -0.05)):
        foot = kit.empty("slipper", root, (x, 0, 0))
        foot.rotation_euler.z = angle
        slab("sole", _sole_outline(side), 0.0, 0.022, "foam", foot)
        strap = prism("strap", [(-0.052, 0.022), (0.052, 0.022), (0.046, 0.055), (0.0, 0.066),
                                (-0.046, 0.055)], -0.075, -0.01, "foam", foot)
        strap.location.y = 0.0


def shirt(root):
    # Origin at the hook on the line. Flat T-shirt on a wire hanger.
    outline = [(-0.03, -0.1), (0.03, -0.1), (0.17, -0.13), (0.33, -0.25), (0.27, -0.33),
               (0.21, -0.29), (0.21, -0.78), (-0.21, -0.78), (-0.21, -0.29), (-0.27, -0.33),
               (-0.33, -0.25), (-0.17, -0.13)]
    prism("tee", outline, -0.012, 0.012, "white_cotton", root)
    box("collar", (0, -0.016, -0.11), (0.09, 0.008, 0.025), "white_cotton", root)
    for side in (-1, 1):
        wire = box("hanger_arm", (side * 0.1, 0, -0.09), (0.2, 0.006, 0.006), "iron", root)
        wire.rotation_euler.y = side * 0.32
    box("hanger_bar", (0, 0, -0.125), (0.38, 0.006, 0.006), "iron", root)
    box("hook_stem", (0, 0, -0.03), (0.006, 0.006, 0.06), "iron", root)
    box("hook_top", (0, 0.012, 0.0), (0.006, 0.03, 0.006), "iron", root)


def towel(root):
    # Origin on the line; folded over it, longer at the front.
    box("front", (0, -0.014, -0.33), (0.42, 0.012, 0.66), "cloth", root)
    box("back", (0, 0.014, -0.24), (0.42, 0.012, 0.48), "cloth", root)
    box("fold", (0, 0, 0.0), (0.42, 0.04, 0.014), "cloth", root)
    box("stripe", (0, -0.021, -0.6), (0.42, 0.004, 0.04), "blue_paint", root)


def bucket(root):
    # 0.3 m wide, 0.36 m tall plastic bucket; open top, handle up.
    cone("wall", (0, 0, 0.18), 0.12, 0.15, 0.36, "blue_plastic", root, 12, open_ends=True,
         inside="blue_plastic")
    cylinder("bottom", (0, 0, 0.006), 0.12, 0.012, "blue_plastic", root, 12)
    cylinder("inner_bottom", (0, 0, 0.03), 0.112, 0.004, "porcelain_dim", root, 12)
    bpy.ops.mesh.primitive_torus_add(major_radius=0.152, minor_radius=0.01,
                                     major_segments=12, minor_segments=4, location=(0, 0, 0.36))
    rim = bpy.context.object
    rim.name = "rim"
    rim.parent = root
    rim.data.materials.append(kit.MATERIALS["blue_plastic"])
    for i in range(7):
        theta = math.pi * i / 6
        seg = box("handle", (0.15 * math.cos(theta), 0, 0.36 + 0.13 * math.sin(theta)),
                  (0.07, 0.008, 0.008), "iron", root)
        seg.rotation_euler.y = -(theta - math.pi / 2)


def pa_horn(root):
    # "Loa nén": horn speaker on a wall bracket. Origin at the bracket (wall
    # side); the horn mouth points front (-Y).
    box("plate", (0, 0.0, 0.0), (0.12, 0.02, 0.16), "iron", root)
    box("arm", (0, -0.07, 0.0), (0.03, 0.14, 0.03), "iron", root)
    cylinder("driver", (0, -0.17, 0.0), 0.075, 0.12, "fan_paint", root, 10).rotation_euler.x = math.pi / 2
    cylinder("driver_cap", (0, -0.1, 0.0), 0.05, 0.03, "fan_paint", root, 10).rotation_euler.x = math.pi / 2
    cone("horn", (0, -0.43, 0.0), 0.05, 0.2, 0.42, "fan_paint", root, 12,
         rotation=(math.pi / 2, 0, 0), open_ends=True, inside="bakelite")
    bpy.ops.mesh.primitive_torus_add(major_radius=0.2, minor_radius=0.01, major_segments=12,
                                     minor_segments=4, location=(0, -0.64, 0.0),
                                     rotation=(math.pi / 2, 0, 0))
    lip = bpy.context.object
    lip.name = "lip"
    lip.parent = root
    lip.data.materials.append(kit.MATERIALS["fan_paint"])


BUILDERS = {
    "desk": desk, "desk_lamp": desk_lamp, "telephone": telephone, "desk_items": desk_items,
    "hall_board": hall_board, "sink": sink, "tap": tap, "stall_front": stall_front,
    "slippers_pair": slippers_pair, "shirt": shirt, "towel": towel, "bucket": bucket,
    "pa_horn": pa_horn,
}


def main():
    for directory in (MODELS, TEXTURES, PREVIEWS):
        directory.mkdir(parents=True, exist_ok=True)
    kit.MODELS, kit.TEXTURES, kit.PREVIEWS = MODELS, TEXTURES, PREVIEWS
    kit.finalize_gltf = finalize_gltf
    kit.REPORT = REPORT
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 16
    scene.cycles.seed = 138
    scene.cycles.use_denoising = False
    scene.render.resolution_x = scene.render.resolution_y = 384
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.exposure = -1.2
    scene.world = bpy.data.worlds.new("studio")
    scene.world.use_nodes = True
    scene.world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.18, 0.21, 0.24, 1)
    scene.world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.45
    for seed, (name, color, pattern) in enumerate(NEW_TEXTURES):
        kit.texture_material(name, color, 138 + seed, pattern)
    for name in KIT_REUSED:
        kit_material(name)
    for name, builder in BUILDERS.items():
        root = kit.empty(name)
        builder(root)
        kit.consolidate(root)
        kit.export(root, name)
        limit = 500 if name in SMALL else 1500
        REPORT[name]["triangle_limit_exclusive"] = limit
        assert REPORT[name]["triangles"] < limit, (name, REPORT[name]["triangles"])
        # Hanging props have their origin on top; lift them above the
        # preview floor for the picture only (the GLB is already exported).
        lowest, _highest = kit.bounds(root)
        root.location.z = max(0.0, -lowest.z)
        kit.preview(root, name)
        root.location.z = 0.0
        kit.strip_render_metadata(PREVIEWS / f"{name}.png")
        for obj in list(root.children_recursive) + [root]:
            bpy.data.objects.remove(obj, do_unlink=True)
    report = {"blender": bpy.app.version_string, "seed": 138, "models": REPORT}
    (ROOT / "art_source/props/manifest.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    paths = sorted(list(MODELS.glob("*.glb")) + list(TEXTURES.glob("*.png")))
    hashes = {str(p.relative_to(ROOT)).replace("\\", "/"): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    (ROOT / "art_source/props/build_hashes.json").write_text(json.dumps(hashes, indent=2) + "\n", encoding="utf-8")
    print(f"PROPS_RESULT: {len(BUILDERS)} models, {len(NEW_TEXTURES)} textures")


if __name__ == "__main__":
    main()
