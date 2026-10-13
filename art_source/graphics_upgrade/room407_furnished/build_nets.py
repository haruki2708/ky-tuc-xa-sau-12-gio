"""Mosquito nets for the room-407 bunks (D-095: built in Blender, not Tripo).
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
Bunk-local Godot metres: origin at the bunk centre on the floor, room side (ladder side of bunk A) is +X.
Exports three GLBs to game/assets/models/graphics_pilot/room407_furnished/:
  mosquito_net_lower_closed / mosquito_net_lower_open (hung under the upper deck, 1.15 m)
  mosquito_net_upper_closed (hung on four cords from ceiling hooks, upper mattress top 1.20 m)
The weave texture is generated here (no third-party asset). Cloth simulation gives the sag and folds.
"""
import math
import sys
from pathlib import Path

import bmesh
import bpy
import numpy as np
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished"
WIDTH, LENGTH = 0.80, 1.94          # matches the 0.8 x 1.9 mattress plus tuck allowance
DECKS = {"lower": 0.38, "upper": 1.15}  # Tripo bunk deck tops (D-096); mattress is 5 cm thick
CEILING = 3.0


def point(v):
    return Vector((v[0], -v[2], v[1]))


def weave_image():
    size, cells, thread = 256, 16, 2
    img = bpy.data.images.new("mosquito_net_weave", size, size, alpha=True)
    y, x = np.mgrid[0:size, 0:size]
    step = size // cells
    threads = ((x % step) < thread) | ((y % step) < thread)
    tone = 0.92 + 0.05 * np.random.default_rng(7).random((size, size))
    px = np.zeros((size, size, 4), dtype=np.float32)
    px[..., 0], px[..., 1], px[..., 2] = tone, tone * 0.985, tone * 0.95
    px[..., 3] = np.where(threads, 0.55, 0.02)  # mipmapped from afar this reads as a light veil
    img.pixels.foreach_set(px.ravel())
    img.file_format = "PNG"
    img.pack()
    return img


def materials():
    net = bpy.data.materials.new("Mosquito net | generated weave")
    net.use_nodes = True
    nodes, links = net.node_tree.nodes, net.node_tree.links
    bsdf = nodes["Principled BSDF"]
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = weave_image()
    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    bsdf.inputs["Roughness"].default_value = 0.9
    net.surface_render_method = "BLENDED"
    net.use_backface_culling = False
    hem = bpy.data.materials.new("Mosquito net hem | cotton")
    hem.use_nodes = True
    hem_bsdf = hem.node_tree.nodes["Principled BSDF"]
    hem_bsdf.inputs["Base Color"].default_value = (0.82, 0.81, 0.76, 1)
    hem_bsdf.inputs["Roughness"].default_value = 0.95
    hem.use_backface_culling = False
    return net, hem


def net_box(name, top, bottom, net_mat, hem_mat, open_front=False):
    """Bottomless box of ~4 cm quads; hems along the top edges and the tucked bottom rim."""
    bpy.ops.mesh.primitive_cube_add(size=1, location=point((0, (top + bottom) / 2, 0)))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = (WIDTH, LENGTH, top - bottom)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    remesh = obj.modifiers.new("cells", "REMESH")
    remesh.mode, remesh.voxel_size = "VOXEL", 0.042
    bpy.ops.object.modifier_apply(modifier=remesh.name)
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    z_lo = min(v.co.z for v in bm.verts)
    z_hi = max(v.co.z for v in bm.verts)
    doomed = [f for f in bm.faces if f.calc_center_median().z < z_lo + 0.02 and abs(f.normal.z) > 0.7]
    if open_front:
        # The room-side wall is lifted and rolled up onto the top edge.
        doomed += [f for f in bm.faces if f.calc_center_median().x > WIDTH / 2 - 0.02 and f.calc_center_median().z < z_hi - 0.03]
    bmesh.ops.delete(bm, geom=list(set(doomed)), context="FACES")
    bm.to_mesh(obj.data)
    bm.free()
    mesh = obj.data
    mesh.materials.append(net_mat)
    mesh.materials.append(hem_mat)
    for face in mesh.polygons:
        c = face.center
        on_top_edge = c.z > z_hi - 0.035 and (abs(c.x) > WIDTH / 2 - 0.03 or abs(c.y) > LENGTH / 2 - 0.03)
        face.material_index = 1 if on_top_edge or c.z < z_lo + 0.05 else 0
        face.use_smooth = True
    uv = mesh.uv_layers.new(name="UVMap")
    for face in mesh.polygons:
        axis = max(range(3), key=lambda i: abs(face.normal[i]))
        axes = [i for i in range(3) if i != axis]
        for li in face.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv = (co[axes[0]] / 0.05, co[axes[1]] / 0.05)
    # Pins: four top corners and tie loops along the long top edges, plus the tucked rim.
    pins = obj.vertex_groups.new(name="pin")
    ties = [(sx * WIDTH / 2, f * LENGTH / 2) for sx in (-1, 1) for f in (-1, -0.5, 0, 0.5, 1)]
    for v in mesh.vertices:
        tied = v.co.z > z_hi - 0.02 and any(math.hypot(v.co.x - tx, v.co.y - ty) < 0.05 for tx, ty in ties)
        rim = v.co.z < z_lo + 0.02
        if tied or rim:
            pins.add([v.index], 1.0, "REPLACE")
    return obj, z_hi


def drape(obj, colliders, frames=70):
    for other in colliders:
        other.modifiers.new("Collision", "COLLISION")
        other.collision.thickness_outer = 0.005
    cloth = obj.modifiers.new("Cloth", "CLOTH")
    st, col = cloth.settings, cloth.collision_settings
    st.quality, st.mass, st.air_damping = 6, 0.05, 3
    st.tension_stiffness = st.compression_stiffness = 30
    st.shear_stiffness, st.bending_stiffness = 2, 0.02
    st.shrink_min = 0.0  # taut top: the player lies 0.43 m below it and must keep a clear view
    st.vertex_group_mass = "pin"
    col.distance_min, col.use_self_collision = 0.004, False
    scene = bpy.context.scene
    scene.frame_start, scene.frame_end = 1, frames
    cloth.point_cache.frame_start, cloth.point_cache.frame_end = 1, frames
    for frame in range(1, frames + 1):
        scene.frame_set(frame)
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=cloth.name)
    for other in colliders:
        other.modifiers.clear()
    scene.frame_set(1)


def cord(name, a, b, mat, radius=0.0025):
    start, end = point(a), point(b)
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=radius, depth=(end - start).length, location=(start + end) / 2)
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
    print("NET", name, tris, "tris", path.stat().st_size, "bytes")
    return tris


def build(variant, net_mat, hem_mat):
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    level, state = variant.split("_")
    deck = DECKS[level]
    mattress_top = deck + 0.05
    top = deck + 0.72 if level == "lower" else mattress_top + 0.86
    if level == "lower":
        top = DECKS["upper"] - 0.05  # tied under the upper deck
    bpy.ops.mesh.primitive_cube_add(size=1, location=point((0, deck + 0.025, 0)))
    mattress = bpy.context.object
    mattress.dimensions = (0.8, 1.9, 0.05)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    net, z_hi = net_box("MosquitoNet", top, mattress_top - 0.03, net_mat, hem_mat, open_front=(state == "open"))
    drape(net, [mattress])
    bpy.data.objects.remove(mattress, do_unlink=True)
    parts = [net]
    if state == "open":
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.035, depth=LENGTH - 0.06,
                                            location=point((WIDTH / 2 - 0.01, top - 0.04, 0)), rotation=(math.pi / 2, 0, 0))
        roll = bpy.context.object
        roll.name = "RolledWall"
        roll.data.materials.append(net_mat)
        roll.data.materials.append(hem_mat)
        uv = roll.data.uv_layers.active.data
        for face in roll.data.polygons:
            face.use_smooth = len(face.vertices) == 4
            for li in face.loop_indices:
                co = roll.data.vertices[roll.data.loops[li].vertex_index].co
                uv[li].uv = (math.atan2(co.y, co.x) * 0.035 / 0.05, co.z / 0.05)
        parts.append(roll)
    if level == "upper":
        for sx in (-1, 1):
            for sz in (-1, 1):
                corner = (sx * WIDTH / 2, top, sz * LENGTH / 2)
                parts.append(cord("HangingCord", corner, (sx * (WIDTH / 2 + 0.05), CEILING, sz * (LENGTH / 2 + 0.05)), hem_mat))
    return export("mosquito_net_" + variant, parts)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    net_mat, hem_mat = materials()
    total = sum(build(v, net_mat, hem_mat) for v in ("lower_closed", "lower_open", "upper_closed"))
    print("RESULT: mosquito nets export PASS", total, "tris")


main()
