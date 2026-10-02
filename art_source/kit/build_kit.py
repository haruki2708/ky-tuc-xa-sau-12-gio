"""Deterministic dormitory kit. Run with Blender's bundled Python, no addons."""
import hashlib
import json
import math
from pathlib import Path
import random
import struct

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
MODELS = ROOT / "game/assets/models/kit"
TEXTURES = ROOT / "game/assets/textures/kit"
PREVIEWS = ROOT / "art_source/kit/previews"
NAMES = ("wall_straight", "wall_door", "door", "bunk_bed", "locker",
         "ceiling_fan", "plastic_stool")
MATERIALS = {}
REPORT = {}


def texture_material(name, color, seed, pattern="speckle"):
    rng = random.Random(seed)
    image = bpy.data.images.new(name, width=128, height=128, alpha=False)
    pixels = []
    for y in range(128):
        for x in range(128):
            noise = rng.uniform(-0.045, 0.045)
            if pattern == "wood":
                noise += 0.05 * math.sin(x * 0.55 + math.sin(y * 0.07))
                if x % 32 < 2:
                    noise -= 0.13
            elif pattern == "cloth":
                noise += 0.07 if x % 16 < 3 else 0
                noise += 0.02 if y % 4 == 0 else 0
            elif pattern == "metal" and rng.random() < 0.035:
                noise -= 0.15
            pixels.extend([max(0, min(1, c + noise)) for c in color] + [1])
    image.pixels.foreach_set(pixels)
    image.filepath_raw = str(TEXTURES / f"{name}.png")
    image.file_format = "PNG"
    image.save()
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = 0.88
    tex = material.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.interpolation = "Closest"
    material.node_tree.links.new(tex.outputs["Color"], shader.inputs["Base Color"])
    MATERIALS[name] = material


def empty(name, parent=None, location=(0, 0, 0)):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    obj.location = location
    return obj


def box(name, location, size, material, parent, angle=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.rotation_euler.z = angle
    obj.parent = parent
    obj.data.materials.append(MATERIALS[material])
    return obj


def cylinder(name, location, radius, depth, material, parent, vertices=8):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius,
                                       depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.data.materials.append(MATERIALS[material])
    return obj


def wall(root, doorway=False):
    # Split paint at 1.05 m with actual geometry, no extra surface decals.
    if doorway:
        for x in (-0.725, 0.725):
            box("lower_pier", (x, 0, 0.525), (0.55, 0.2, 1.05), "green_paint", root)
            box("upper_pier", (x, 0, 1.575), (0.55, 0.2, 1.05), "plaster", root)
        box("lintel", (0, 0, 2.55), (2, 0.2, 0.9), "plaster", root)
    else:
        box("lower_wall", (0, 0, 0.525), (2, 0.2, 1.05), "green_paint", root)
        box("upper_wall", (0, 0, 2.025), (2, 0.2, 1.95), "plaster", root)


def door(root):
    # Hinge foot at origin; 0.88 x 2.08 leaf leaves fitting clearance.
    box("wood_leaf", (0.44, 0, 1.04), (0.88, 0.04, 2.08), "old_wood", root)
    for x in (0.065, 0.815):
        box("stile", (x, -0.025, 1.04), (0.10, 0.02, 2.08), "old_wood", root)
    for z in (0.08, 0.88, 2.0):
        box("rail", (0.44, -0.026, z), (0.68, 0.018, 0.11), "old_wood", root)
    for z in (0.3, 1.8):
        box("hinge", (0.015, -0.03, z), (0.03, 0.025, 0.10), "iron", root)
    box("lock_plate", (0.75, -0.035, 1.01), (0.06, 0.015, 0.17), "iron", root)
    box("handle", (0.708, -0.064, 1.055), (0.13, 0.032, 0.025), "iron", root)


def bunk_bed(root):
    # Overall envelope includes mosquito-net frame and ladder: .9 x 2 x 1.7 m.
    for x in (-0.43, 0.43):
        for y in (-0.98, 0.98):
            box("post", (x, y, 0.85), (0.04, 0.04, 1.7), "iron", root)
    for z in (0.34, 1.11):
        for x in (-0.43, 0.43):
            box("bed_side", (x, 0, z), (0.04, 1.96, 0.07), "iron", root)
        for y in (-0.96, 0.96):
            box("bed_end", (0, y, z), (0.84, 0.04, 0.07), "iron", root)
        box("sleeping_board", (0, 0, z + 0.028), (0.82, 1.90, 0.025), "old_wood", root)
        box("thin_mat", (0, 0, z + 0.065), (0.80, 1.88, 0.05), "striped_mat", root)
        box("pillow", (0, 0.70, z + 0.115), (0.54, 0.30, 0.05), "cloth", root)
    for y in (-0.98, 0.98):
        box("net_end", (0, y, 1.685), (0.86, 0.025, 0.03), "iron", root)
    for x in (-0.43, 0.43):
        box("net_side", (x, 0, 1.685), (0.025, 1.96, 0.03), "iron", root)
        box("upper_guard", (x, 0.20, 1.36), (0.025, 1.50, 0.035), "iron", root)
    for x in (-0.30, 0.02):
        box("ladder_rail", (x, -0.975, 0.66), (0.025, 0.035, 1.32), "iron", root)
    for z in (0.22, 0.44, 0.66, 0.88, 1.10):
        box("ladder_rung", (-0.14, -0.975, z), (0.32, 0.035, 0.025), "iron", root)


def locker(root):
    for x in (-0.33, 0.33):
        for y in (-0.22, 0.22):
            box("foot", (x, y, 0.055), (0.07, 0.07, 0.11), "iron", root)
    box("cabinet", (0, 0.015, 0.935), (0.76, 0.49, 1.67), "locker_paint", root)
    # Two stacked compartments, each with vents, pull and label holder.
    for z in (0.525, 1.355):
        box("compartment_door", (0, -0.245, z), (0.72, 0.03, 0.80), "locker_paint", root)
        box("label_holder", (0, -0.265, z + 0.18), (0.16, 0.008, 0.065), "iron", root)
        box("blank_label", (0, -0.270, z + 0.18), (0.13, 0.005, 0.041), "cloth", root)
        box("pull", (0.245, -0.28, z), (0.025, 0.04, 0.13), "iron", root)
        for offset in (-0.23, -0.18, -0.13):
            box("vent", (0, -0.263, z + offset), (0.40, 0.006, 0.015), "iron", root)


def ceiling_fan(root):
    cylinder("mount", (0, 0, 0.59), 0.085, 0.06, "fan_paint", root)
    cylinder("downrod", (0, 0, 0.37), 0.018, 0.40, "iron", root)
    cylinder("motor", (0, 0, 0.12), 0.12, 0.12, "fan_paint", root, 12)
    rotor = empty("fan_rotor", root, (0, 0, 0.055))
    cylinder("hub", (0, 0, 0), 0.08, 0.11, "fan_paint", rotor, 12)
    for i in range(3):
        angle = i * math.tau / 3
        box("blade", (0.37 * math.cos(angle), 0.37 * math.sin(angle), 0),
            (0.55, 0.13, 0.018), "fan_paint", rotor, angle)


def plastic_stool(root):
    box("seat", (0, 0, 0.435), (0.32, 0.32, 0.03), "red_plastic", root)
    for x in (-0.13, 0.13):
        for y in (-0.13, 0.13):
            box("leg", (x, y, 0.21), (0.038, 0.038, 0.42), "red_plastic", root)
    for x in (-0.13, 0.13):
        box("brace", (x, 0, 0.14), (0.025, 0.26, 0.03), "red_plastic", root)
    for y in (-0.13, 0.13):
        box("brace", (0, y, 0.14), (0.26, 0.025, 0.03), "red_plastic", root)


def consolidate(parent):
    for child in list(parent.children):
        if child.type == "EMPTY":
            consolidate(child)
    meshes = [child for child in parent.children if child.type == "MESH"]
    if not meshes:
        return
    bpy.ops.object.select_all(action="DESELECT")
    for mesh in meshes:
        mesh.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = parent.name + "_mesh"
    # Bake actual triangles so reported counts are the exported counts.
    modifier = obj.modifiers.new("triangles", "TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=modifier.name)


def bounds(root):
    bpy.context.view_layer.update()
    points = [obj.matrix_world @ Vector(corner)
              for obj in root.children_recursive if obj.type == "MESH"
              for corner in obj.bound_box]
    return (Vector(tuple(min(p[i] for p in points) for i in range(3))),
            Vector(tuple(max(p[i] for p in points) for i in range(3))))


def aim(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()


def preview(root, name):
    scene = bpy.context.scene
    lo, hi = bounds(root)
    center = (lo + hi) / 2
    span = max(hi - lo)
    bpy.ops.object.camera_add(location=center + Vector((1.15, -1.9, 1.0)) * span)
    camera = bpy.context.object
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = span * 1.55
    aim(camera, center)
    scene.camera = camera
    extras = [camera]
    for location, energy, size in (((-3, -4, 6), 700, 5), ((4, 1, 4), 450, 4)):
        bpy.ops.object.light_add(type="AREA", location=location)
        light = bpy.context.object
        light.data.energy = energy
        light.data.shape = "DISK"
        light.data.size = size
        aim(light, center)
        extras.append(light)
    bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, -0.008))
    floor = bpy.context.object
    mat = bpy.data.materials.get("studio_floor") or bpy.data.materials.new("studio_floor")
    mat.diffuse_color = (0.12, 0.15, 0.16, 1)
    floor.data.materials.append(mat)
    extras.append(floor)
    scene.render.filepath = str(PREVIEWS / f"{name}.png")
    bpy.ops.render.render(write_still=True)
    for obj in extras:
        bpy.data.objects.remove(obj, do_unlink=True)


def export(root, name):
    meshes = [obj for obj in root.children_recursive if obj.type == "MESH"]
    triangles = sum(len(obj.data.polygons) for obj in meshes)
    limit = 500 if name in ("ceiling_fan", "plastic_stool") else 1500
    assert triangles < limit, (name, triangles, limit)
    lo, hi = bounds(root)
    REPORT[name] = {"triangles": triangles, "triangle_limit_exclusive": limit,
                    "blender_dimensions_m": [round(v, 5) for v in hi - lo],
                    "godot_dimensions_m": [round((hi - lo)[i], 5) for i in (0, 2, 1)]}
    # glTF's normal +Y-up conversion maps Blender -Y to Godot +Z.
    # Bake a half turn into children so the required visual front is Godot -Z,
    # while the exported root and hinge origin remain identity transforms.
    original = [(obj, obj.matrix_world.copy()) for obj in root.children]
    root.rotation_euler.z = math.pi
    bpy.context.view_layer.update()
    corrected = [(obj, obj.matrix_world.copy()) for obj in root.children]
    root.rotation_euler.z = 0
    bpy.context.view_layer.update()
    for obj, matrix in corrected:
        obj.matrix_world = matrix
    bpy.ops.object.select_all(action="DESELECT")
    for obj in [root] + list(root.children_recursive):
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(filepath=str(MODELS / f"{name}.glb"),
                              export_format="GLB", use_selection=True,
                              export_yup=True, export_animations=False,
                              export_cameras=False, export_lights=False,
                              export_extras=False, export_image_format="AUTO")
    force_nearest_sampler(MODELS / f"{name}.glb")
    for obj, matrix in original:
        obj.matrix_world = matrix
    bpy.context.view_layer.update()


def force_nearest_sampler(path):
    # Blender Closest exports NEAREST_MIPMAP_LINEAR for minification.
    # Pin both glTF sampler filters to NEAREST without changing project settings.
    data = path.read_bytes()
    json_size, chunk_type = struct.unpack_from("<II", data, 12)
    assert chunk_type == 0x4E4F534A
    document = json.loads(data[20:20 + json_size])
    for sampler in document.get("samplers", []):
        sampler["magFilter"] = sampler["minFilter"] = 9728
    payload = json.dumps(document, separators=(",", ":")).encode("utf-8")
    payload += b" " * (-len(payload) % 4)
    tail = data[20 + json_size:]
    path.write_bytes(struct.pack("<4sII", b"glTF", 2, 20 + len(payload) + len(tail)) +
                     struct.pack("<II", len(payload), chunk_type) + payload + tail)


def contact_sheet():
    # 4 x 2 tiles, 256 px each. Bottom-right tile is intentionally empty.
    width, height = 1024, 512
    pixels = [0.12, 0.15, 0.16, 1.0] * (width * height)
    for index, name in enumerate(NAMES):
        source = bpy.data.images.load(str(PREVIEWS / f"{name}.png"), check_existing=False)
        source.scale(256, 256)
        data = list(source.pixels)
        ox, oy = (index % 4) * 256, (1 - index // 4) * 256
        for y in range(256):
            start = ((oy + y) * width + ox) * 4
            pixels[start:start + 1024] = data[y * 1024:(y + 1) * 1024]
        bpy.data.images.remove(source)
    sheet = bpy.data.images.new("contact_sheet", width=width, height=height, alpha=False)
    sheet.pixels.foreach_set(pixels)
    sheet.filepath_raw = str(PREVIEWS / "contact_sheet.png")
    sheet.file_format = "PNG"
    sheet.save()


def strip_render_metadata(path):
    # Render time/date are PNG metadata, not pixels; omit them for stable hashes.
    data = path.read_bytes()
    output = bytearray(data[:8])
    offset = 8
    while offset < len(data):
        size = struct.unpack_from(">I", data, offset)[0]
        kind = data[offset + 4:offset + 8]
        end = offset + 12 + size
        if kind not in (b"tEXt", b"zTXt", b"iTXt", b"tIME"):
            output.extend(data[offset:end])
        offset = end
    path.write_bytes(output)


def main():
    for directory in (MODELS, TEXTURES, PREVIEWS):
        directory.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 24
    scene.cycles.seed = 102
    scene.cycles.use_denoising = False
    scene.render.threads_mode = "FIXED"
    scene.render.threads = 8
    scene.render.resolution_x = scene.render.resolution_y = 512
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.render.image_settings.color_depth = "8"
    scene.view_settings.view_transform = "Standard"
    scene.world = bpy.data.worlds.new("studio")
    scene.world.use_nodes = True
    scene.world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.18, 0.21, 0.24, 1)
    scene.world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.45
    definitions = [
        ("plaster", (0.67, 0.64, 0.49), "speckle"),
        ("green_paint", (0.22, 0.34, 0.28), "speckle"),
        ("old_wood", (0.29, 0.17, 0.085), "wood"),
        ("iron", (0.09, 0.14, 0.15), "metal"),
        ("striped_mat", (0.30, 0.38, 0.30), "cloth"),
        ("cloth", (0.62, 0.62, 0.49), "cloth"),
        ("locker_paint", (0.28, 0.40, 0.37), "metal"),
        ("fan_paint", (0.57, 0.58, 0.46), "metal"),
        ("red_plastic", (0.59, 0.055, 0.035), "speckle"),
    ]
    for seed, (name, color, pattern) in enumerate(definitions):
        texture_material(name, color, 102 + seed, pattern)
    builders = (lambda r: wall(r), lambda r: wall(r, True), door, bunk_bed,
                locker, ceiling_fan, plastic_stool)
    for name, builder in zip(NAMES, builders):
        root = empty(name)
        builder(root)
        consolidate(root)
        export(root, name)
        preview(root, name)
        strip_render_metadata(PREVIEWS / f"{name}.png")
        for obj in list(root.children_recursive) + [root]:
            bpy.data.objects.remove(obj, do_unlink=True)
    contact_sheet()
    report = {"blender": bpy.app.version_string, "seed": 102, "models": REPORT}
    (ROOT / "art_source/kit/manifest.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8")
    paths = sorted(list(MODELS.glob("*.glb")) + list(TEXTURES.glob("*.png")) +
                   [PREVIEWS / f"{name}.png" for name in NAMES] + [PREVIEWS / "contact_sheet.png"])
    hashes = {str(path.relative_to(ROOT)).replace("\\", "/"):
              hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    (ROOT / "art_source/kit/build_hashes.json").write_text(
        json.dumps(hashes, indent=2) + "\n", encoding="utf-8")
    print("KIT_RESULT: 7 models, 9 textures, 8 previews generated")


if __name__ == "__main__":
    main()
