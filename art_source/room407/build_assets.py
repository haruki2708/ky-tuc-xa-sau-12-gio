"""T-153 original dorm props and pixel textures. Blender background, no addons."""
import json
import math
import random
import struct
import sys
sys.dont_write_bytecode = True
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "art_source/kit"))
import build_kit as kit

OUT = ROOT / "game/assets/models/room407"
TEX = ROOT / "game/assets/textures/room407"


def texture(name, color, pattern="grain"):
    rng = random.Random(153 + sum(map(ord, name)))
    pixels = []
    for y in range(128):
        for x in range(128):
            noise = rng.uniform(-.035, .035)
            rgb = [max(.005, min(1, c + noise)) for c in color]
            alpha = 1
            if pattern == "tile":
                if x % 32 < 2 or y % 32 < 2:
                    rgb = [.12, .15, .145]
                elif (x // 32 + y // 32) % 2:
                    rgb = [v * .86 for v in rgb]
            if pattern == "wall":
                if y > 87:
                    rgb = [v * .62 for v in rgb]
                if (x * 13 + y * 7) % 131 < 3 and y > 65:
                    rgb = [.22, .24, .21]
            if pattern == "cloth":
                rgb = [v * (.85 if x % 13 < 3 else 1) for v in rgb]
            if pattern == "blood":
                dx, dy = (x - 64) / 58, (y - 64) / 50
                angle = math.atan2(dy, dx)
                edge = .82 + .10 * math.sin(angle * 7) + .07 * math.cos(angle * 11)
                alpha = 1 if dx * dx + dy * dy < edge else 0
                if (x - 38) ** 2 + (y - 46) ** 2 < 190:
                    rgb = [.19, .014, .024]
            pixels.extend((*rgb, alpha))
    image = bpy.data.images.new(name, width=128, height=128, alpha=True)
    image.pixels.foreach_set(pixels)
    image.filepath_raw = str(TEX / f"{name}.png")
    image.file_format = "PNG"
    image.save()
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Roughness"].default_value = .9
    tex = material.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.interpolation = "Closest"
    material.node_tree.links.new(tex.outputs["Color"], principled.inputs["Base Color"])
    kit.MATERIALS[name] = material


def box(root, name, at, size, mat="ink", angle=0):
    return kit.box(name, at, size, mat, root, angle)


def tube(root, name, points, radius=.006, mat="ink"):
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    curve.bevel_depth = radius
    curve.bevel_resolution = 0
    spline = curve.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for item, xyz in zip(spline.points, points):
        item.co = (*xyz, 1)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    obj.parent = root
    obj.data.materials.append(kit.MATERIALS[mat])
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj.select_set(False)


def disc(root, name, at, scale, mat="wood", vertices=12):
    obj = kit.cylinder(name, at, 1, 1, mat, root, vertices)
    obj.scale = scale
    return obj


def prop(root, name):
    if name == "books":
        for i in range(3):
            box(root, "pages", (0, 0, .025 + i * .037), (.23, .30, .025), "paper", i * .07)
            for z in (.009, .041):
                box(root, "cover", (0, 0, z + i * .037), (.24, .31, .005), "rust", i * .07)
    elif name == "headphones":
        tube(root, "band", [(.10 * math.cos(i * math.pi / 10), 0, .11 + .11 * math.sin(i * math.pi / 10)) for i in range(11)], .011)
        for x in (-.1, .1):
            box(root, "earcup", (x, 0, .08), (.035, .065, .095))
            box(root, "pad", (x * .80, 0, .08), (.012, .056, .075), "cloth")
    elif name == "noodles":
        for i in range(3):
            box(root, "packet", (0, 0, .03 + i * .049), (.15, .115, .045), "rust", i * .1)
            box(root, "label", (0, 0, .055 + i * .049), (.09, .055, .002), "paper", i * .1)
    elif name == "football_poster":
        box(root, "poster", (0, 0, 0), (.46, .018, .62), "moss")
        box(root, "pitch", (0, -.011, -.09), (.35, .003, .26), "paper")
        ball = disc(root, "ball", (0, -.022, .1), (.095, .095, .012), "paper", 10)
        ball.rotation_euler.x = math.pi / 2
        box(root, "ball_patch", (0, -.032, .1), (.062, .004, .062), "ink", .2)
    elif name == "laptop":
        box(root, "base", (0, 0, .015), (.33, .23, .03))
        for i in range(5):
            box(root, "keyboard_row", (0, .07 - i * .02, .032), (.27, .009, .002), "cloth")
        box(root, "trackpad", (0, -.075, .032), (.10, .052, .002), "moss")
        box(root, "lid", (0, .108, .13), (.33, .02, .23))
        box(root, "screen", (0, .096, .13), (.285, .002, .187), "screen")
        box(root, "tape", (.10, .082, .24), (.05, .032, .018), "paper")
    elif name == "guitar":
        disc(root, "lower_bout", (0, 0, .23), (.18, .22, .09))
        disc(root, "upper_bout", (0, .22, .23), (.13, .15, .085))
        box(root, "neck", (0, .53, .23), (.055, .49, .045))
        box(root, "headstock", (0, .81, .23), (.075, .12, .04), "wood")
        disc(root, "sound_hole", (0, .12, .279), (.057, .057, .003), "ink")
        for i in range(6):
            box(root, "string", ((i - 2.5) * .007, .39, .282), (.0015, .83, .002), "paper")
        box(root, "bridge", (0, -.055, .282), (.12, .03, .016))
    elif name == "family_photo":
        box(root, "frame", (0, 0, .12), (.21, .035, .24), "wood")
        box(root, "photo", (0, -.020, .12), (.173, .002, .20), "screen")
        for x, h in ((-.052, .1), (0, .075), (.052, .1)):
            box(root, "portrait", (x, -.023, .105), (.042, .003, h), "cloth")
            obj = disc(root, "head", (x, -.026, .105 + h / 2), (.022, .022, .003), "paper", 8)
            obj.rotation_euler.x = math.pi / 2
    elif name == "backpack":
        box(root, "bag", (0, 0, .21), (.29, .18, .40), "moss")
        box(root, "pocket", (0, -.105, .14), (.22, .055, .18), "cloth")
        tube(root, "handle", [(-.07, 0, .39), (-.07, 0, .46), (.07, 0, .46), (.07, 0, .39)], .009)
        for x in (-.09, .09):
            tube(root, "strap", [(x, .095, .37), (x, .16, .30), (x, .16, .13), (x, .09, .08)], .011)
    elif name == "power_strip":
        box(root, "case", (0, 0, .022), (.28, .062, .044), "paper")
        for x in (-.09, 0, .09):
            for dx in (-.016, .016):
                box(root, "socket", (x + dx, 0, .046), (.008, .019, .003))
        tube(root, "mains_lead", [(.14, 0, .02), (.23, .0, .01), (.27, .12, .01), (.31, .3, .01)], .005)
    elif name == "charging_cable":
        tube(root, "loose_cable", [(-.2 + i * .04, .1 * math.sin(i * .5), .01) for i in range(15)], .004, "paper")
        box(root, "usb_plug", (-.22, 0, .01), (.044, .018, .012), "paper")
        box(root, "usb_tip", (-.246, 0, .01), (.014, .013, .008), "ink")
        box(root, "phone_end", (.38, .066, .01), (.03, .012, .009), "paper")
    elif name == "notebook":
        box(root, "cover", (0, 0, .01), (.18, .25, .02), "moss")
        box(root, "blank_note", (0, 0, .025), (.16, .23, .01), "paper")
        for i in range(8):
            box(root, "binding", (-.08, -.10 + i * .028, .03), (.02, .004, .012))
    elif name == "trainers":
        for x in (-.085, .085):
            box(root, "sole", (x, 0, .025), (.125, .27, .05), "paper")
            box(root, "upper", (x, -.02, .08), (.12, .22, .095), "ink")
            for i in range(4):
                box(root, "lace", (x, -.045 + i * .026, .132), (.084, .006, .003), "paper")
    elif name == "router":
        box(root, "case", (0, 0, .027), (.20, .12, .055), "paper")
        for x in (-.077, .077):
            tube(root, "antenna", [(x, .044, .04), (x, .044, .23)], .006)
        for x in (-.06, -.025, .01, .045):
            box(root, "led", (x, -.062, .03), (.009, .003, .006), "moss")
    elif name == "bunk_trung":
        kit.bunk_bed(root)
        for obj in list(root.children):
            if obj.name.startswith(("thin_mat", "pillow")) and obj.location.z < .8:
                bpy.data.objects.remove(obj, do_unlink=True)


def finalize(path):
    data = path.read_bytes()
    size, kind = struct.unpack_from("<II", data, 12)
    doc = json.loads(data[20:20 + size])
    for sampler in doc.get("samplers", []):
        sampler["magFilter"] = sampler["minFilter"] = 9728
    image_views = {image["bufferView"] for image in doc["images"]}
    for image in doc["images"]:
        image.pop("bufferView")
        image.pop("mimeType", None)
        image["uri"] = f"../../textures/room407/{image['name']}.png"
    old = data[28 + size:]
    binary, views, mapping = bytearray(), [], {}
    for i, view in enumerate(doc["bufferViews"]):
        if i in image_views:
            continue
        binary.extend(b"\0" * (-len(binary) % 4))
        mapping[i] = len(views)
        views.append(dict(view, byteOffset=len(binary)))
        offset = view.get("byteOffset", 0)
        binary.extend(old[offset:offset + view["byteLength"]])
    for accessor in doc["accessors"]:
        if "bufferView" in accessor:
            accessor["bufferView"] = mapping[accessor["bufferView"]]
    doc["bufferViews"] = views
    doc["buffers"] = [{"byteLength": len(binary)}]
    binary.extend(b"\0" * (-len(binary) % 4))
    payload = json.dumps(doc, separators=(",", ":")).encode()
    payload += b" " * (-len(payload) % 4)
    path.write_bytes(struct.pack("<4sII", b"glTF", 2, 28 + len(payload) + len(binary)) + struct.pack("<II", len(payload), kind) + payload + struct.pack("<II", len(binary), 0x004E4942) + binary)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    TEX.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    kit.MODELS = OUT
    kit.finalize_gltf = finalize
    for name, color, pattern in [
        ("ink", (.045, .055, .058), "grain"), ("paper", (.73, .68, .53), "grain"),
        ("rust", (.43, .09, .045), "grain"), ("moss", (.16, .29, .22), "cloth"),
        ("wood", (.28, .14, .055), "cloth"), ("cloth", (.32, .39, .45), "cloth"),
        ("screen", (.11, .20, .24), "grain"), ("room_tile", (.41, .43, .37), "tile"),
        ("room_wall", (.57, .58, .46), "wall"), ("blood", (.27, .016, .025), "blood")]:
        texture(name, color, pattern)
    for alias, original in (("iron", "ink"), ("old_wood", "wood"), ("striped_mat", "cloth")):
        kit.MATERIALS[alias] = kit.MATERIALS[original]
    names = ["books", "headphones", "noodles", "football_poster", "laptop", "guitar", "family_photo", "backpack", "power_strip", "charging_cable", "notebook", "trainers", "router", "bunk_trung"]
    for name in names:
        root = kit.empty(name)
        prop(root, name)
        kit.consolidate(root)
        kit.export(root, name)
        limit = 1500 if name == "bunk_trung" else 500
        assert kit.REPORT[name]["triangles"] < limit
        kit.REPORT[name]["triangle_limit_exclusive"] = limit
        for obj in list(root.children_recursive) + [root]:
            bpy.data.objects.remove(obj, do_unlink=True)
    (ROOT / "art_source/room407/manifest.json").write_text(json.dumps(kit.REPORT, indent=2) + "\n", encoding="utf-8")
    print("ROOM407_ASSETS_RESULT: 14 models, 10 textures")


if __name__ == "__main__":
    main()
