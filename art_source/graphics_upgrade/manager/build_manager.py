"""Build the MPFB manager pilot. Run using run_blender.ps1; MPFB 2.0.18 required.

The source MakeHuman pack is CC0. No gameplay or production scene is changed.
"""
import importlib
import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector, Matrix

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SOURCE = HERE / "sources/makehuman"
OUT = ROOT / "game/assets/models/characters/manager"
HumanService = importlib.import_module("bl_ext.user_default.mpfb.services.humanservice").HumanService
TargetService = importlib.import_module("bl_ext.user_default.mpfb.services.targetservice").TargetService
LocationService = importlib.import_module("bl_ext.user_default.mpfb.services.locationservice").LocationService


def select_only(*objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[-1]


def freeze_shape(obj):
    if obj.data.shape_keys:
        key = obj.shape_key_add(name="Baked", from_mix=True)
        coords = [v.co.copy() for v in key.data]
        obj.shape_key_clear()
        for vertex, co in zip(obj.data.vertices, coords):
            vertex.co = co


def create_character():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    macro = TargetService.get_default_macro_info_dict()
    macro.update(gender=1.0, age=0.62, muscle=0.32, weight=0.28, height=0.48)
    macro["race"] = {"asian": 1.0, "caucasian": 0.0, "african": 0.0}
    body = HumanService.create_human(macro_detail_dict=macro)
    body.name = "ManagerSkin"
    targets = Path(LocationService.get_mpfb_data("targets"))
    for side in ("l", "r"):
        for part in ("height1", "height2", "height3"):
            TargetService.load_target(body, str(targets / f"eyes/{side}-eye-{part}-incr.target.gz"), weight=0.45)
    HumanService.set_character_skin(str(SOURCE / "skins/middleage_asian_male/middleage_asian_male.mhmat"), body, skin_type="GAMEENGINE")
    rig = HumanService.add_builtin_rig(body, "game_engine")
    rig.name = "Rig"
    objects = {"skin": body}
    for name, path, kind in [
        ("uniform", "clothes/male_casualsuit01/male_casualsuit01.mhclo", "Clothes"),
        ("shoes", "clothes/shoes01/shoes01.mhclo", "Clothes"),
        ("hair", "hair/short01/short01.mhclo", "Hair"),
        ("brows", "eyebrows/eyebrow001/eyebrow001.mhclo", "Eyebrows"),
        ("eyes", "eyes/low-poly/low-poly.mhclo", "Eyes"),
    ]:
        objects[name] = HumanService.add_mhclo_asset(str(SOURCE / path), body, asset_type=kind,
            subdiv_levels=0, material_type="GAMEENGINE")
        objects[name].name = "Manager_" + name
    for obj in objects.values():
        select_only(obj)
        freeze_shape(obj)
        for mod in list(obj.modifiers):
            if mod.type == "MASK":
                bpy.ops.object.modifier_apply(modifier=mod.name)
            elif mod.type == "SUBSURF":
                obj.modifiers.remove(mod)
        for face in obj.data.polygons:
            face.use_smooth = True
    return rig, objects


def triangles(obj):
    return sum(len(p.vertices) - 2 for p in obj.data.polygons)


def simplify(obj, target):
    select_only(obj)
    if triangles(obj) > target:
        mod = obj.modifiers.new("PilotBudget", "DECIMATE")
        mod.ratio = target / triangles(obj)
        bpy.ops.object.modifier_apply(modifier=mod.name)


def source_material(obj, kind):
    """Preserve source folds/pores and bake our own dust, blood and uniform colours."""
    # MPFB GAMEENGINE wraps textures inside node groups. Use the documented source
    # path explicitly rather than silently losing all detail when inspecting top nodes.
    images = {
        "skin": "skins/middleage_asian_male/middleage_lightskinned_male_diffuse2.png",
        "uniform": "clothes/male_casualsuit01/male_casualsuit01_diffuse.png",
        "shoes": "clothes/shoes01/shoes01_diffuse.png",
        "hair": "hair/short01/short01_diffuse.png",
        "brows": "eyebrows/eyebrow001/eyebrow001.png",
    }
    diffuse = bpy.data.images.load(str(SOURCE / images[kind]), check_existing=True)
    obj.data.uv_layers.active.name = "SourceUV"
    mat = bpy.data.materials.new(kind + "_source")
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    uv = nodes.new("ShaderNodeUVMap")
    uv.uv_map = "SourceUV"
    gray = nodes.new("ShaderNodeRGBToBW")
    if diffuse:
        tex = nodes.new("ShaderNodeTexImage")
        tex.image = diffuse
        links.new(uv.outputs["UV"], tex.inputs["Vector"])
        links.new(tex.outputs["Color"], gray.inputs["Color"])
    else:
        gray.inputs[0].default_value = (0.5, 0.5, 0.5, 1)
    attr = obj.data.color_attributes.new(name="Wear", type="FLOAT_COLOR", domain="CORNER")
    for face in obj.data.polygons:
        for li in face.loop_indices:
            x, y, z = obj.data.vertices[obj.data.loops[li].vertex_index].co
            color = (0.7, 0.72, 0.69)
            if kind == "skin":
                # A branching dried streak from the right hairline to the temple.
                centre = -0.053 + 0.012 * math.sin((z - 1.47) * 32)
                blood = y < -0.055 and 1.48 < z < 1.625 and abs(x-centre) < 0.007
                color = (0.085, 0.009, 0.006) if blood else (0.18, 0.20, 0.175)
            elif kind == "uniform":
                color = (0.34, 0.57, 0.76) if z > 0.895 else (0.21, 0.22, 0.23)
                if 0.885 < z < 0.925 and abs(x) < 0.20:
                    color = (0.07, 0.065, 0.05)
            elif kind == "shoes":
                color = (0.075, 0.078, 0.08)
            elif kind in ("hair", "brows"):
                temple = kind == "hair" and abs(x) > 0.057 and z < 1.54
                color = (0.45, 0.46, 0.44) if temple else (0.035, 0.032, 0.028)
            attr.data[li].color = (*color, 1)
    tint = nodes.new("ShaderNodeVertexColor")
    tint.layer_name = "Wear"
    # Keep source detail above a floor so aged skin and cotton remain readable.
    remap = nodes.new("ShaderNodeMapRange")
    remap.inputs["From Min"].default_value = 0
    remap.inputs["From Max"].default_value = 0.6
    remap.inputs["To Min"].default_value = 0.08 if kind == "skin" else 0.22
    remap.inputs["To Max"].default_value = 1.0
    links.new(gray.outputs[0], remap.inputs["Value"])
    multiply = nodes.new("ShaderNodeMixRGB")
    multiply.blend_type = "MULTIPLY"
    multiply.inputs[0].default_value = 1
    links.new(tint.outputs["Color"], multiply.inputs[1])
    links.new(remap.outputs[0], multiply.inputs[2])
    links.new(multiply.outputs[0], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.88
    if kind in ("hair", "brows") and diffuse:
        links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    return mat


def bake_atlas(objects, name, size=2048, alpha=False):
    """Bake colour (and cutout alpha) onto a new shared UV atlas, on the CPU."""
    select_only(*objects)
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    obj.data.uv_layers.new(name="AtlasUV")
    obj.data.uv_layers.active_index = len(obj.data.uv_layers)-1
    obj.data.uv_layers.active.active_render = True
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(70), island_margin=0.012)
    bpy.ops.object.mode_set(mode="OBJECT")
    image = bpy.data.images.new(name + "_color", width=size, height=size, alpha=alpha)
    image.generated_color = (0, 0, 0, 0 if alpha else 1)
    outputs = []
    for mat in obj.data.materials:
        nodes, links = mat.node_tree.nodes, mat.node_tree.links
        bsdf = nodes.get("Principled BSDF")
        emission = nodes.new("ShaderNodeEmission")
        links.new(bsdf.inputs["Base Color"].links[0].from_socket, emission.inputs["Color"])
        output = nodes.get("Material Output")
        links.new(emission.outputs[0], output.inputs[0])
        bake = nodes.new("ShaderNodeTexImage")
        bake.image = image
        nodes.active = bake
        outputs.append((mat, bsdf, emission, output, bake))
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 1
    scene.render.bake.margin = 12
    bpy.ops.object.bake(type="EMIT")
    if alpha:
        alpha_image = bpy.data.images.new(name + "_alpha", width=size, height=size)
        for mat, bsdf, emission, output, bake in outputs:
            for link in list(emission.inputs["Color"].links):
                mat.node_tree.links.remove(link)
            if bsdf.inputs["Alpha"].links:
                mat.node_tree.links.new(bsdf.inputs["Alpha"].links[0].from_socket, emission.inputs["Color"])
            else:
                emission.inputs["Color"].default_value = (1, 1, 1, 1)
            bake.image = alpha_image
        bpy.ops.object.bake(type="EMIT")
        import numpy as np
        rgba = np.empty(size*size*4, dtype=np.float32)
        mask = np.empty_like(rgba)
        image.pixels.foreach_get(rgba)
        alpha_image.pixels.foreach_get(mask)
        rgba[3::4] = mask[0::4]
        image.pixels.foreach_set(rgba)
        bpy.data.images.remove(alpha_image)
    texture_dir = HERE / "textures"
    texture_dir.mkdir(exist_ok=True)
    image.filepath_raw = str(texture_dir / (name + ".png"))
    image.file_format = "PNG"
    image.save()
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Roughness"].default_value = 0.82 if not alpha else 0.95
    tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = image
    mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    if alpha:
        mat.node_tree.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
        mat.surface_render_method = "DITHERED"
    # Keep only the new coordinates; no source-image dependencies in the export.
    for uv in list(obj.data.uv_layers):
        if uv.name != "AtlasUV":
            obj.data.uv_layers.remove(uv)
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    for p in obj.data.polygons:
        p.material_index = 0
    for attr in list(obj.data.color_attributes):
        obj.data.color_attributes.remove(attr)
    return obj


def detail_material():
    mat = bpy.data.materials.new("ManagerDetails")
    mat.use_nodes = True
    attr = mat.node_tree.nodes.new("ShaderNodeVertexColor")
    attr.layer_name = "Color"
    mat.node_tree.links.new(attr.outputs["Color"], mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"])
    mat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.38
    mat.node_tree.nodes["Principled BSDF"].inputs["Metallic"].default_value = 0.25
    return mat


def detail(obj, mat, color, rig=None, bone=None):
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    attr = obj.data.color_attributes.new(name="Color", type="FLOAT_COLOR", domain="CORNER")
    for value in attr.data:
        value.color = (*color, 1)
    if rig and bone:
        obj.parent = rig
        group = obj.vertex_groups.new(name=bone)
        group.add(list(range(len(obj.data.vertices))), 1, "REPLACE")
        mod = obj.modifiers.new("Skin", "ARMATURE")
        mod.object = rig
    return obj


def box(name, centre, size, mat, color, rig=None, bone=None, bevel=0.002):
    bpy.ops.mesh.primitive_cube_add(size=1, location=centre)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if bevel:
        mod = obj.modifiers.new("WornEdges", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return detail(obj, mat, color, rig, bone)


def accessories(rig, eyes, mat):
    # Temporary Blender props, clearly distinguished from pending Tripo assets.
    parts = [eyes]
    detail(eyes, mat, (0.40, 0.46, 0.40))
    for side in (-1, 1):
        eye_vertices = [v.co for v in eyes.data.vertices if v.co.x * side > 0]
        x = sum(v.x for v in eye_vertices) / len(eye_vertices)
        y = min(v.y for v in eye_vertices) - 0.0015
        z = (min(v.z for v in eye_vertices) + max(v.z for v in eye_vertices)) * 0.5
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=1, location=(x, y, z))
        pupil = bpy.context.object
        pupil.name = "TinyPupil"
        pupil.scale = (0.0018, 0.002, 0.0018)
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        parts.append(detail(pupil, mat, (0.015, 0.02, 0.018), rig, "head"))
    parts.append(box("TemporaryBlankID", (0.065, -0.129, 1.18), (0.055, 0.003, 0.084), mat, (0.63, 0.65, 0.60), rig, "spine_03"))
    for x in (0.047, 0.08):
        parts.append(box("TemporaryLanyard", (x, -0.121, 1.28), (0.007, 0.003, 0.16), mat, (0.018, 0.035, 0.055), rig, "spine_03", 0.001))
    for i in range(5):
        parts.append(box("TemporaryKey", (-0.18 + i*0.005, -0.087, 0.85-i*0.006), (0.005, 0.004, 0.05), mat, (0.40, 0.31, 0.13), rig, "pelvis", 0.001))
    parts.append(box("BeltBuckle", (0, -0.119, 0.91), (0.039, 0.005, 0.027), mat, (0.34, 0.34, 0.31), rig, "pelvis"))
    select_only(*parts)
    bpy.ops.object.join()
    props = bpy.context.object
    props.name = "ManagerDetails"
    return props


def export_knife(mat):
    # Bone-local handle lies along +Y. Final attachment is in the body scene.
    parts = [box("TemporaryCleaverBlade", (0.024, 0.235, 0), (0.125, 0.29, 0.005), mat, (0.38, 0.41, 0.43)),
        box("TemporaryCleaverEdge", (0.086, 0.235, 0), (0.008, 0.29, 0.0025), mat, (0.83, 0.85, 0.87), bevel=0.0005),
        box("TemporaryCleaverHandle", (0, 0.02, 0), (0.029, 0.14, 0.022), mat, (0.12, 0.048, 0.022))]
    for y in (-0.02, 0.055):
        parts.append(box("BrassRivet", (0, y, -0.0115), (0.009, 0.009, 0.002), mat, (0.49, 0.34, 0.13), bevel=0.001))
    select_only(*parts)
    bpy.ops.object.join()
    knife = bpy.context.object
    knife.name = "TemporaryCleaver"
    bpy.ops.export_scene.gltf(filepath=str(OUT / "temporary_cleaver.glb"), export_format="GLB", use_selection=True,
        export_animations=False, export_yup=True)
    return knife


def finish_character(rig, objects):
    for name in ("skin", "uniform", "shoes", "hair", "brows"):
        source_material(objects[name], name)
    skin = bake_atlas([objects["skin"]], "ManagerSkin")
    uniform = bake_atlas([objects["uniform"], objects["shoes"]], "ManagerUniform")
    hair = bake_atlas([objects["hair"], objects["brows"]], "ManagerHair", 1024, True)
    mat = detail_material()
    details = accessories(rig, objects["eyes"], mat)
    meshes = [skin, uniform, hair, details]
    for obj, budget in [(skin, 8500), (uniform, 11000), (hair, 2450)]:
        simplify(obj, budget)
    # Fit height including hair and shoe sole; preserve rig and mesh coordinates together.
    lowest = min(v.co.z for obj in meshes for v in obj.data.vertices)
    highest = max(v.co.z for obj in meshes for v in obj.data.vertices)
    scale = 1.70 / (highest - lowest)
    matrix = Matrix.Scale(scale, 4) @ Matrix.Translation((0, 0, -lowest))
    for obj in meshes:
        obj.data.transform(matrix)
    rig.data.transform(matrix)
    select_only(rig, *meshes)
    bpy.ops.export_scene.gltf(filepath=str(OUT / "manager_c.glb"), export_format="GLB", use_selection=True,
        export_animations=False, export_yup=True, export_apply=False, export_image_format="AUTO")
    knife = export_knife(mat)
    total = sum(triangles(obj) for obj in meshes) + triangles(knife)
    report = {"height_m": 1.70, "triangles": total, "materials": 4, "texture_max": 2048,
        "parts": {obj.name: triangles(obj) for obj in meshes + [knife]},
        "mpfb": "2.0.18", "temporary_props": ["cleaver", "keys", "blank ID", "lanyard"]}
    assert total <= 25000, report
    (OUT / "manager_c_budget.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
    # Keep the .blend compact and self-contained; source packages stay on D:.
    for image in bpy.data.images:
        if image.name.startswith("Manager") and image.filepath:
            image.pack()
    for _ in range(3):
        bpy.ops.outliner.orphans_purge(do_recursive=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(HERE / "manager_c.blend"), compress=True)
    assert (HERE / "manager_c.blend").stat().st_size <= 10*1024*1024
    print("T219_BUILD", json.dumps(report))


def main():
    rig, objects = create_character()
    report = {name: {"vertices": len(obj.data.vertices), "triangles": sum(len(p.vertices)-2 for p in obj.data.polygons),
        "min": [min(v.co[i] for v in obj.data.vertices) for i in range(3)],
        "max": [max(v.co[i] for v in obj.data.vertices) for i in range(3)]} for name, obj in objects.items()}
    report["bones"] = {b.name: {"head": list(b.head_local), "tail": list(b.tail_local)} for b in rig.data.bones}
    (ROOT / "build/t219/character_probe.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / "build/t219/manager_raw.blend"), compress=True)
    finish_character(rig, objects)


if __name__ == "__main__":
    main()
