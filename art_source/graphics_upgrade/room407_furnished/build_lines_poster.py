"""Clotheslines and Phuc's football poster for room 407 (D-095: built in Blender, not Tripo).
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
Room-local Godot metres (room origin), exported to game/assets/models/graphics_pilot/room407_furnished/:
  clothesline_room.glb    west wall nail -> bathroom corner, hook points at y=2.58 (Details/HangingShirt_*)
  clothesline_balcony.glb balcony walls x=0.06..5.14, hook points at y=2.15 (Extension/BalconyShirt*)
  poster_football.glb     0.42 x 0.59 m paper on the west wall at Details/Phuc/FootballPoster, faces +X
The poster picture is rendered here from our own geometry (no text, no club marks): poster_football.png.
"""
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished"


def point(v):
    return Vector((v[0], -v[2], v[1]))


def clear():
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)


def plain(name, color, roughness=0.6, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def rope(name, knots, radius, mat):
    """Smooth cord through room-local knots (Catmull-Rom), as a mesh tube."""
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    curve.bevel_depth, curve.bevel_resolution = radius, 2
    curve.resolution_u = 6
    spline = curve.splines.new("NURBS")
    spline.points.add(len(knots) - 1)
    for p, k in zip(spline.points, knots):
        p.co = (*point(k), 1)
    spline.use_endpoint_u, spline.order_u = True, 3
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj = bpy.context.object
    obj.data.materials.append(mat)
    for face in obj.data.polygons:
        face.use_smooth = True
    return obj


def nail(name, at, toward, mat):
    start, end = point(at), point(toward)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.004, depth=(end - start).length, location=(start + end) / 2)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = (end - start).to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(mat)
    return obj


def export(name, objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    path = OUT / (name + ".glb")
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True,
                              export_yup=True, export_image_format="AUTO")
    tris = 0
    for obj in objects:
        evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
        m = evaluated.to_mesh()
        m.calc_loop_triangles()
        tris += len(m.loop_triangles)
        evaluated.to_mesh_clear()
    assert path.stat().st_size <= 10 * 1024 * 1024, path
    print("PROP", name, tris, "tris", path.stat().st_size, "bytes")


def clotheslines():
    cord = plain("Plastic clothesline | blue PVC", (0.18, 0.36, 0.55), 0.45)
    steel = plain("Wall nail | steel", (0.35, 0.34, 0.32), 0.4, 1.0)
    clear()
    # Room: hooks of the three shirts (x 1.2 / 1.98 / 2.76) and the spare hanger (2.4) sit at y=2.58.
    z = -3.9
    knots = [(0.1, 2.63, z), (0.6, 2.605, z), (1.2, 2.58, z), (1.6, 2.582, z), (1.98, 2.58, z), (2.4, 2.58, z),
             (2.76, 2.58, z), (3.5, 2.592, z), (4.4, 2.608, z), (5.27, 2.625, -3.92)]
    parts = [rope("ClotheslineRoom", knots, 0.0028, cord),
             nail("NailWest", (0.1, 2.635, z), (0.14, 2.625, z), steel),
             nail("NailBathCorner", (5.275, 2.63, -3.92), (5.235, 2.62, -3.92), steel)]
    export("clothesline_room", parts)
    clear()
    z = -7.85
    knots = [(0.06, 2.19, z), (0.5, 2.17, z), (1.0, 2.15, z), (1.6, 2.148, z), (2.2, 2.15, z), (2.8, 2.148, z),
             (3.4, 2.15, z), (4.4, 2.17, z), (5.14, 2.19, z)]
    parts = [rope("ClotheslineBalcony", knots, 0.0028, cord),
             nail("NailBalconyWest", (0.06, 2.195, z), (0.1, 2.185, z), steel),
             nail("NailBalconyEast", (5.14, 2.195, z), (5.1, 2.185, z), steel)]
    export("clothesline_balcony", parts)


def football():
    """Classic 32-panel ball: truncated icosahedron hull, then rounded."""
    phi = (1 + 5 ** 0.5) / 2
    base = [(0, 1, 3 * phi), (1, 2 + phi, 2 * phi), (phi, 2, phi ** 3)]
    verts = set()
    for a, b, c in base:
        for p in [(a, b, c), (b, c, a), (c, a, b)]:  # even permutations
            for sx in (-1, 1):
                for sy in (-1, 1):
                    for sz in (-1, 1):
                        verts.add((round(sx * p[0], 6), round(sy * p[1], 6), round(sz * p[2], 6)))
    bm = bmesh.new()
    for v in verts:
        bm.verts.new(Vector(v) / 5.0)
    bmesh.ops.convex_hull(bm, input=list(bm.verts))
    bmesh.ops.dissolve_limit(bm, angle_limit=math.radians(1), verts=list(bm.verts), edges=list(bm.edges))
    mesh = bpy.data.meshes.new("Football")
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new("Football", mesh)
    bpy.context.collection.objects.link(obj)
    white = plain("Ball white", (0.85, 0.85, 0.82), 0.35)
    black = plain("Ball black", (0.02, 0.02, 0.02), 0.35)
    mesh.materials.append(white)
    mesh.materials.append(black)
    for face in mesh.polygons:
        face.material_index = 1 if len(face.vertices) == 5 else 0
        face.use_smooth = True
    sub = obj.modifiers.new("round", "SUBSURF")
    sub.levels = sub.render_levels = 3
    cast = obj.modifiers.new("sphere", "CAST")
    cast.factor = 1.0
    return obj


def poster_picture(path):
    """Night match: a worn ball in the grass under blurred floodlights. Our own render, no text or marks."""
    clear()
    scene = bpy.context.scene
    ball = football()
    ball.scale = (0.11, 0.11, 0.11)
    ball.location = (0, 0, 0.1)
    ball.rotation_euler = (0.4, 0.2, 0.7)
    for mat in ball.data.materials:
        nodes, links = mat.node_tree.nodes, mat.node_tree.links
        scuff = nodes.new("ShaderNodeTexNoise")
        scuff.inputs["Scale"].default_value = 40
        ramp = nodes.new("ShaderNodeMapRange")
        ramp.inputs["To Min"].default_value, ramp.inputs["To Max"].default_value = 0.25, 0.75
        links.new(scuff.outputs["Fac"], ramp.inputs["Value"])
        links.new(ramp.outputs["Result"], nodes["Principled BSDF"].inputs["Roughness"])
    bpy.ops.mesh.primitive_plane_add(size=40)
    ground = bpy.context.object
    turf = bpy.data.materials.new("Pitch")
    turf.use_nodes = True
    nodes, links = turf.node_tree.nodes, turf.node_tree.links
    noise = nodes.new("ShaderNodeTexNoise")
    noise.inputs["Scale"].default_value = 300
    mix = nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.inputs["A"].default_value = (0.03, 0.13, 0.03, 1)
    mix.inputs["B"].default_value = (0.08, 0.28, 0.06, 1)
    links.new(noise.outputs["Fac"], mix.inputs["Factor"])
    bsdf = nodes["Principled BSDF"]
    links.new(mix.outputs["Result"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.7
    ground.data.materials.append(turf)
    # Real blades: hair particles on a patch around the ball.
    bpy.ops.mesh.primitive_plane_add(size=3, location=(0, 0, 0.001))
    patch = bpy.context.object
    patch.data.materials.append(turf)
    hair = patch.modifiers.new("Grass", "PARTICLE_SYSTEM").particle_system.settings
    hair.type, hair.count = "HAIR", 90000
    hair.use_advanced_hair = True  # in advanced mode the emit velocity sets the blade length
    hair.normal_factor, hair.factor_random, hair.brownian_factor = 0.045, 0.012, 0.002
    hair.length_random = 0.6
    hair.root_radius, hair.tip_radius, hair.radius_scale = 1.0, 0.0, 0.0025
    hair.material = 1
    hair.child_type = "NONE"
    # Floodlight banks far behind; depth of field turns them into soft discs.
    for bank, x in enumerate((-7, -2.6, 2.6, 7)):
        for i in range(3):
            for j in range(3):
                bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(x + i * 0.5, 30, 6 + bank % 2 + j * 0.45))
                glow = bpy.data.materials.get("Floodlight") or bpy.data.materials.new("Floodlight")
                if not glow.node_tree or "Emission" not in [n.type.title() for n in glow.node_tree.nodes]:
                    glow.use_nodes = True
                    emit = glow.node_tree.nodes.new("ShaderNodeEmission")
                    emit.inputs["Color"].default_value = (1.0, 0.95, 0.85, 1)
                    emit.inputs["Strength"].default_value = 400
                    glow.node_tree.links.new(emit.outputs["Emission"], glow.node_tree.nodes["Material Output"].inputs["Surface"])
                bpy.context.object.data.materials.append(glow)
    key = bpy.data.objects.new("Key", bpy.data.lights.new("Key", "SPOT"))
    key.data.energy, key.data.spot_size, key.data.shadow_soft_size = 2200, math.radians(30), 0.5
    key.location = (0.9, 3.2, 2.6)
    key.rotation_euler = (Vector((0, 0, 0.1)) - key.location).to_track_quat("-Z", "Y").to_euler()
    scene.collection.objects.link(key)
    fill = bpy.data.objects.new("Fill", bpy.data.lights.new("Fill", "AREA"))
    fill.data.energy, fill.data.size = 60, 2
    fill.location = (-1.0, -1.5, 1.2)
    fill.rotation_euler = (Vector((0, 0, 0.1)) - fill.location).to_track_quat("-Z", "Y").to_euler()
    scene.collection.objects.link(fill)
    world = bpy.data.worlds.new("Night stadium")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.006, 0.009, 0.02, 1)
    scene.world = world
    cam = bpy.data.objects.new("Camera", bpy.data.cameras.new("Camera"))
    scene.collection.objects.link(cam)
    scene.camera = cam
    cam.location = (0.04, -0.62, 0.17)
    cam.rotation_euler = (Vector((0.0, 0.6, 0.27)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 35
    cam.data.dof.use_dof = True
    cam.data.dof.focus_object = ball
    cam.data.dof.aperture_fstop = 1.4
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 96
    scene.cycles.use_denoising = True
    scene.render.resolution_x, scene.render.resolution_y = 768, 1080
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)


def poster(path):
    clear()
    # Glossy print paper: 0.42 x 0.59 m on the west wall (face toward +X), bottom-right corner curling off.
    w, h, cols, rows = 0.42, 0.59, 14, 20
    mesh = bpy.data.meshes.new("Poster")
    verts, faces, uvs = [], [], []
    for j in range(rows + 1):
        for i in range(cols + 1):
            u, v = i / cols, j / rows
            curl = max(0.0, (u - 0.72) / 0.28) * max(0.0, (0.22 - v) / 0.22)
            lift = 0.004 * math.sin(u * math.pi * 3 + v * 2) * (1 - abs(2 * v - 1)) + 0.05 * curl ** 2
            verts.append(point((0.104 + lift, 2.26 - h / 2 + v * h, -2.82 + w / 2 - u * w)))
            uvs.append((u, v))
    for j in range(rows):
        for i in range(cols):
            k = j * (cols + 1) + i
            faces.append((k, k + 1, k + cols + 2, k + cols + 1))
    mesh.from_pydata(verts, [], faces)
    layer = mesh.uv_layers.new(name="UVMap")
    for face in mesh.polygons:
        face.use_smooth = True
        for li in face.loop_indices:
            layer.data[li].uv = uvs[mesh.loops[li].vertex_index]
    obj = bpy.data.objects.new("Poster", mesh)
    bpy.context.collection.objects.link(obj)
    mat = bpy.data.materials.new("Poster print | own render")
    mat.use_nodes = True
    tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(str(path))
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.35
    mat.use_backface_culling = False
    mesh.materials.append(mat)
    tape_mat = plain("Clear tape | yellowed", (0.75, 0.68, 0.45), 0.3)
    parts = [obj]
    for u, v in ((0.0, 1.0), (1.0, 1.0), (0.0, 0.0)):
        bpy.ops.mesh.primitive_cube_add(size=1, location=point((0.106, 2.26 - h / 2 + v * h, -2.82 + w / 2 - u * w)))
        tape = bpy.context.object
        tape.dimensions = (0.002, 0.05, 0.022)
        tape.rotation_euler.x = math.radians(40 if u == v else -40)
        tape.data.materials.append(tape_mat)
        parts.append(tape)
    export("poster_football", parts)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    clotheslines()
    picture = HERE / "poster_football.png"
    poster_picture(picture)
    poster(picture)
    print("RESULT: clotheslines and poster export PASS")


main()
