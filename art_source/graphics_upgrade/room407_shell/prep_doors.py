"""Make the Tripo door downloads into bare leaves before ../tripo/bake_prop.py (T-222, D-126).
Blender 5.2.2:  blender -b --factory-startup -P prep_doors.py -- <name> <src.glb> <out.glb> [low triangles]
With a triangle count the source is first welded and decimated to it, then edited the same way: the
low model for bake_prop.py --low (edited full-detail meshes no longer decimate cleanly).
Tripo gave each leaf extra parts the room cannot use (TRIPO_CUA_PHONG407.md section 2b):
  door_room_r2   a casing round the leaf, a lever and lock plate on its front, a plain back
  door_bathroom  a casing round the leaf, a lever on its front, a plain back
  door_balcony   its own frame round the leaf, a small knob on the front
Steps (Tripo's own units, Blender axes: x across, -y the front face, z up from the floor):
  crop   cut the casing off along planes (the leaf is what stays inside the box)
  clamp  push anything standing out of the front face back onto it (the lever, deep lips)
  paint  repaint the lever's texture islands with the paint round it, flatten its normal map
  mirror (bathroom) keep the front shell and mirror it to the back: the louvre goes through the door
  cap    close the four cut edges with flat strips coloured like the paint next to them
"""
import sys

import bmesh
import bpy
import numpy as np

DOORS = {
    # paint_face: Tripo also printed the lever into the leaf's own texture; repaint that patch too.
    "door_bathroom": {"crop": (-0.188, 0.185, 0.0, 0.925), "clamp_front": -0.032,
                      "lever": (-0.195, -0.135, 0.43, 0.53), "face_y": -0.024, "mirror": -0.016, "paint_face": True},
    # Round 2 of the room door (round 1 came out a double door): casing, lever and lock plate on the west.
    "door_room_r2": {"crop": (-0.193, 0.193, 0.0, 0.926), "clamp_front": -0.001,
                     "lever": (-0.2, -0.14, 0.4, 0.6), "face_y": 0.002, "mirror": 0.0185, "paint_face": True},
    "door_balcony": {"crop": (-0.224, 0.224, 0.0, 0.936), "clamp_front": -0.022,
                     "lever": (-0.218, -0.15, 0.41, 0.445), "face_y": -0.020, "mirror": None},
}


def load(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    obj = bpy.context.object
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return obj


def decimate(obj, target):
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.00005)
    bpy.ops.object.mode_set(mode="OBJECT")
    tris = sum(len(p.vertices) - 2 for p in obj.data.polygons)
    mod = obj.modifiers.new("decimate", "DECIMATE")
    mod.decimate_type, mod.ratio, mod.use_collapse_triangulate = "COLLAPSE", target / tris, True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    print("PREP decimated", tris, "->", sum(len(p.vertices) - 2 for p in obj.data.polygons), flush=True)


def crop(obj, x0, x1, z0, z1):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    for co, no in (((x0, 0, 0), (-1, 0, 0)), ((x1, 0, 0), (1, 0, 0)), ((0, 0, z1), (0, 0, 1)), ((0, 0, z0), (0, 0, -1))):
        geom = bm.verts[:] + bm.edges[:] + bm.faces[:]
        bmesh.ops.bisect_plane(bm, geom=geom, plane_co=co, plane_no=no, clear_outer=True)
    bm.to_mesh(obj.data)
    bm.free()


def material_images(obj):
    nodes = obj.data.materials[0].node_tree.nodes
    bsdf = next(n for n in nodes if n.type == "BSDF_PRINCIPLED")

    def source(socket):
        node = bsdf.inputs[socket].links[0].from_node if bsdf.inputs[socket].links else None
        while node is not None and node.type != "TEX_IMAGE":
            inputs = [i for i in node.inputs if i.links]
            node = inputs[0].links[0].from_node if inputs else None
        return node.image if node else None

    return {"base": source("Base Color"), "rm": source("Roughness"), "normal": source("Normal")}


def paint_lever(obj, box, face_y, paint_face=False):
    """Repaint the UV islands of the lever's faces with the leaf's paint around it."""
    x0, x1, z0, z1 = box
    mesh = obj.data
    uv = mesh.uv_layers.active.data
    lever, near = [], []
    for poly in mesh.polygons:
        c = poly.center
        ys = [mesh.vertices[v].co.y for v in poly.vertices]
        if x0 <= c.x <= x1 and z0 <= c.z <= z1 and (min(ys) < face_y - 0.004 or paint_face and c.y < face_y + 0.004):
            lever.append(poly)
        elif x0 - 0.04 <= c.x <= x1 + 0.04 and z0 - 0.04 <= c.z <= z1 + 0.04 and abs(c.y - face_y) < 0.003:
            near.append(poly)
    images = material_images(obj)
    print("PREP lever faces", len(lever), "paint samples", len(near), flush=True)
    for role, image in images.items():
        if image is None:
            continue
        w, h = image.size
        px = np.empty(w * h * 4, np.float32)
        image.pixels.foreach_get(px)
        px = px.reshape(h, w, 4)
        samples = []
        for poly in near:
            u, v = uv[poly.loop_indices[0]].uv
            samples.append(px[min(int(v * h), h - 1), min(int(u * w), w - 1)])
        colour = np.median(np.array(samples), axis=0) if role != "normal" else np.array([0.5, 0.5, 1.0, 1.0])
        mask = np.zeros((h, w), bool)
        for poly in lever:
            # Blender image rows start at the bottom, like UV v.
            pts = np.array([(uv[li].uv[0] * w, uv[li].uv[1] * h) for li in poly.loop_indices])
            fill_polygon(mask, pts, grow=2)
        px[mask] = colour
        image.pixels.foreach_set(px.ravel())
        image.update()
        print("PREP painted", role, int(mask.sum()), "texels", flush=True)


def fill_polygon(mask, pts, grow=0):
    """Set the texels of a convex UV polygon (pixel units), grown by `grow` texels."""
    h, w = mask.shape
    lo = np.floor(pts.min(axis=0)).astype(int) - grow
    hi = np.ceil(pts.max(axis=0)).astype(int) + grow + 1
    lo, hi = np.maximum(lo, 0), np.minimum(hi, (w, h))
    if (hi <= lo).any():
        return
    yy, xx = np.mgrid[lo[1]:hi[1], lo[0]:hi[0]] + 0.5
    inside = np.ones(xx.shape, bool)
    centre = pts.mean(axis=0)
    for a, b in zip(pts, np.roll(pts, -1, axis=0)):
        edge = b - a
        normal = np.array([edge[1], -edge[0]])
        length = np.hypot(*normal) or 1.0
        sign = 1.0 if np.dot(centre - a, normal) >= 0 else -1.0
        inside &= ((xx - a[0]) * normal[0] + (yy - a[1]) * normal[1]) * sign / length >= -grow
    mask[lo[1]:hi[1], lo[0]:hi[0]] |= inside


def clamp_front(obj, y_min, lever, face_y):
    """Nothing stands out further than y_min; inside the lever's box nothing stands out of the face."""
    x0, x1, z0, z1 = lever
    for v in obj.data.vertices:
        if x0 - 0.01 <= v.co.x <= x1 + 0.01 and z0 - 0.01 <= v.co.z <= z1 + 0.01:
            v.co.y = max(v.co.y, face_y)
        elif v.co.y < y_min:
            v.co.y = y_min


def mirror_back(obj, plane_y):
    """Keep the front shell (y < plane_y) and add its mirror image behind the plane."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    geom = bm.verts[:] + bm.edges[:] + bm.faces[:]
    bmesh.ops.bisect_plane(bm, geom=geom, plane_co=(0, plane_y, 0), plane_no=(0, 1, 0), clear_outer=True)
    front = bm.faces[:]
    copy = bmesh.ops.duplicate(bm, geom=bm.verts[:] + bm.edges[:] + front)
    new_verts = [e for e in copy["geom"] if isinstance(e, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y = 2 * plane_y - v.co.y
    new_faces = [e for e in copy["geom"] if isinstance(e, bmesh.types.BMFace)]
    bmesh.ops.reverse_faces(bm, faces=new_faces)
    bm.to_mesh(obj.data)
    bm.free()


def cap(obj, x0, x1, z0, z1):
    """Close the cut edges with flat strips; their UVs point at the paint just inside each edge."""
    mesh = obj.data
    ys = np.empty(len(mesh.vertices) * 3, np.float32)
    mesh.vertices.foreach_get("co", ys)
    ys = ys.reshape(-1, 3)[:, 1]
    yf, yb = float(ys.min()), float(ys.max())
    uv = mesh.uv_layers.active.data
    centres = np.empty(len(mesh.polygons) * 3, np.float32)
    mesh.polygons.foreach_get("center", centres)
    centres = centres.reshape(-1, 3)
    starts = np.empty(len(mesh.polygons), np.int32)
    mesh.polygons.foreach_get("loop_start", starts)

    # One paint UV per side: the front face nearest the middle of that edge.
    def paint_uv(px, pz):
        d = (centres[:, 0] - px) ** 2 + (centres[:, 2] - pz) ** 2 + 4 * (centres[:, 1] - yf) ** 2
        return tuple(uv[int(starts[int(np.argmin(d))])].uv)
    sides = {
        "left": ([(x0, yf, z0), (x0, yb, z0), (x0, yb, z1), (x0, yf, z1)], paint_uv(x0 + 0.01, (z0 + z1) / 2)),
        "right": ([(x1, yf, z0), (x1, yf, z1), (x1, yb, z1), (x1, yb, z0)], paint_uv(x1 - 0.01, (z0 + z1) / 2)),
        "top": ([(x0, yf, z1), (x0, yb, z1), (x1, yb, z1), (x1, yf, z1)], paint_uv(0, z1 - 0.01)),
        "bottom": ([(x0, yf, z0), (x1, yf, z0), (x1, yb, z0), (x0, yb, z0)], paint_uv(0, z0 + 0.01)),
    }
    bm = bmesh.new()
    bm.from_mesh(mesh)
    layer = bm.loops.layers.uv.active
    for corners, paint in sides.values():
        face = bm.faces.new([bm.verts.new(c) for c in corners])
        for loop in face.loops:
            loop[layer].uv = paint
    bm.to_mesh(mesh)
    bm.free()
    print("PREP capped, leaf depth", round(yb - yf, 4), flush=True)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:]
    name, src, out = argv[:3]
    spec = DOORS[name]
    obj = load(src)
    paint_lever(obj, spec["lever"], spec["face_y"], spec.get("paint_face", False))
    if len(argv) > 3:
        decimate(obj, int(argv[3]))
    crop(obj, *spec["crop"])
    clamp_front(obj, spec["clamp_front"], spec["lever"], spec["face_y"])
    if spec["mirror"] is not None:
        mirror_back(obj, spec["mirror"])
    cap(obj, *spec["crop"])
    for image in bpy.data.images:
        if image.has_data:
            image.pack()
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=True, export_image_format="JPEG",
                              export_jpeg_quality=95, export_yup=True)
    print("PREP wrote", out, len(obj.data.polygons), "faces", flush=True)


main()
