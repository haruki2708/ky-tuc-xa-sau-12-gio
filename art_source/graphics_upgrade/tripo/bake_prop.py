"""High-to-low prop pipeline for Tripo output (D-088).

Blender 5.2.2, background:
    blender -b --factory-startup -P bake_prop.py -- \
        --src high.glb --out game.glb --name stool \
        --min -0.18 0 -0.18 --size 0.36 0.30 0.36 \
        [--rotate 180] [--fit box|height|width] [--tris 5000] [--tex 1024] [--image-format JPEG] [--sharp 40]
        [--height-map 0:0 0.39:0.38 1.35:1.15 1.70:1.50] [--low prepared_low.glb]

1. Import the Tripo GLB (the detailed "high" model), join it into one mesh.
2. Rotate about the vertical axis so the agreed front faces glTF -Z.
3. Fit it to the measured envelope of the prop it replaces (glTF min/size):
   "box" scales each axis to the envelope; "height" / "width" keep proportions,
   match the height or the X width and centre the footprint on the envelope.
4. Duplicate and decimate the copy to the triangle budget, keeping its UVs (or, with --low, take a
   low model prepared elsewhere in the high model's space; it gets the same rotation and fit).
5. Bake the high model's shading normal (geometry + its normal map) onto the
   low model (Cycles, selected to active) and reuse the colour and
   roughness/metal maps, resized to --tex.
6. Export the low model alone as a static GLB, pivot at the floor origin.
"""
import argparse
import math
import sys

import bpy
import mathutils


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--name", required=True)
    parser.add_argument("--min", type=float, nargs=3, required=True)
    parser.add_argument("--size", type=float, nargs=3, required=True)
    parser.add_argument("--rotate", type=float, default=0.0)
    parser.add_argument("--fit", choices=("box", "height", "width"), default="height")
    parser.add_argument("--tris", type=int, default=5000)
    parser.add_argument("--tex", type=int, default=1024)
    # JPEG keeps large props (2048 maps) under the 10 MiB file limit.
    # Hard-surface props: split normals above this angle (degrees) so welded tubes and
    # panel edges stay crisp after decimation; 0 keeps fully smooth shading.
    parser.add_argument("--sharp", type=float, default=0.0)
    # Piecewise-linear vertical remap (glTF height after fitting, "from:to" knots in
    # metres) to land functional surfaces such as bunk decks on gameplay heights.
    parser.add_argument("--height-map", nargs="*", default=[])
    parser.add_argument("--image-format", choices=("AUTO", "JPEG"), default="AUTO")
    # A low model already decimated and edited like the high one (T-222 door leaves: the edited
    # high model no longer decimates cleanly).
    parser.add_argument("--low", default="")
    return parser.parse_args(sys.argv[sys.argv.index("--") + 1:])


def gltf_to_blender(v):
    return mathutils.Vector((v[0], -v[2], v[1]))


def bounds(obj):
    pts = [obj.matrix_world @ v.co for v in obj.data.vertices]
    lo = mathutils.Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = mathutils.Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    return lo, hi


def triangles(obj):
    return sum(len(p.vertices) - 2 for p in obj.data.polygons)


def select_only(*objs):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[-1]


def import_low(path, rotate, fit):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    added = [o for o in bpy.context.scene.objects if o not in before]
    meshes = [o for o in added if o.type == "MESH"]
    for o in meshes:
        w = o.matrix_world.copy()
        o.parent = None
        o.matrix_world = w
    for o in added:
        if o.type != "MESH":
            bpy.data.objects.remove(o, do_unlink=True)
    select_only(*meshes)
    if len(meshes) > 1:
        bpy.ops.object.join()
    low = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if rotate:
        low.data.transform(mathutils.Matrix.Rotation(math.radians(rotate), 4, "Z"))
    low.data.transform(fit)
    low.data.update()
    return low


def main():
    args = parse_args()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=args.src)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    for o in meshes:
        w = o.matrix_world.copy()
        o.parent = None
        o.matrix_world = w
    for o in list(bpy.context.scene.objects):
        if o.type != "MESH":
            bpy.data.objects.remove(o, do_unlink=True)
    select_only(*meshes)
    if len(meshes) > 1:
        bpy.ops.object.join()
    high = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    high.name = args.name + "_high"

    # 2. Orientation about the vertical axis (Blender Z == glTF Y).
    if args.rotate:
        high.data.transform(mathutils.Matrix.Rotation(math.radians(args.rotate), 4, "Z"))

    # 3. Fit to the envelope.
    lo, hi = bounds(high)
    size = hi - lo
    t_a = gltf_to_blender(args.min)
    t_b = gltf_to_blender([args.min[i] + args.size[i] for i in range(3)])
    t_lo = mathutils.Vector(map(min, t_a, t_b))
    t_hi = mathutils.Vector(map(max, t_a, t_b))
    t_size = t_hi - t_lo
    if args.fit == "box":
        scale = mathutils.Vector((t_size.x / size.x, t_size.y / size.y, t_size.z / size.z))
        offset = t_lo
    else:
        # "height" matches the height, "width" the glTF X width; both keep proportions.
        s = t_size.z / size.z if args.fit == "height" else t_size.x / size.x
        scale = mathutils.Vector((s, s, s))
        centre = (t_lo + t_hi) / 2
        offset = mathutils.Vector((centre.x - size.x * s / 2, centre.y - size.y * s / 2, t_lo.z))
    fit = mathutils.Matrix.Translation(offset) @ mathutils.Matrix.Diagonal((*scale, 1.0)) @ mathutils.Matrix.Translation(-lo)
    high.data.transform(fit)
    high.data.update()
    if args.height_map and not args.low:
        knots = sorted(tuple(float(v) for v in k.split(":")) for k in args.height_map)

        def remap(z):
            if z <= knots[0][0]:
                return z - knots[0][0] + knots[0][1]
            for (a, a2), (b, b2) in zip(knots, knots[1:]):
                if z <= b:
                    return a2 + (z - a) * (b2 - a2) / (b - a)
            return z - knots[-1][0] + knots[-1][1]

        for v in high.data.vertices:
            v.co.z = remap(v.co.z)
        print("BAKE height map", knots)
    lo, hi = bounds(high)
    print("BAKE high tris", triangles(high), "bounds", tuple(round(v, 4) for v in lo), tuple(round(v, 4) for v in hi))

    # 4. Low model: decimated copy that keeps the UV layout.
    if args.low:
        low = import_low(args.low, args.rotate, fit)
        low.name = args.name
    else:
        low = high.copy()
        low.data = high.data.copy()
        low.name = args.name
        bpy.context.scene.collection.objects.link(low)
    # glTF import splits vertices along UV seams; weld them so the decimator
    # sees one surface (UVs live on face corners and survive), then use plain
    # smooth normals that the tangent-space bake and the export both follow.
    select_only(low)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=0.0001 * max(t_size))
    bpy.ops.object.mode_set(mode="OBJECT")
    if low.data.has_custom_normals:
        bpy.ops.mesh.customdata_custom_splitnormals_clear()
    bpy.ops.object.shade_smooth()
    if triangles(low) > args.tris:
        mod = low.modifiers.new("decimate", "DECIMATE")
        mod.decimate_type = "COLLAPSE"
        mod.ratio = args.tris / triangles(low) * 0.98
        mod.use_collapse_triangulate = True
        select_only(low)
        bpy.ops.object.modifier_apply(modifier=mod.name)
    select_only(low)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.quads_convert_to_tris()
    bpy.ops.object.mode_set(mode="OBJECT")
    if args.sharp:
        select_only(low)
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(args.sharp))
    print("BAKE low tris", triangles(low))

    # 5. Bake the high shading normal into the low UVs.
    src_mat = high.data.materials[0]
    mat = src_mat.copy()
    mat.name = args.name + "_mat"
    low.data.materials.clear()
    low.data.materials.append(mat)
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    baked = bpy.data.images.new(args.name + "_normal", args.tex, args.tex, alpha=False, float_buffer=False)
    baked.colorspace_settings.name = "Non-Color"
    bake_node = nodes.new("ShaderNodeTexImage")
    bake_node.image = baked
    nodes.active = bake_node
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 4
    scene.render.bake.use_selected_to_active = True
    scene.render.bake.cage_extrusion = 0.01 * max(t_size)
    scene.render.bake.max_ray_distance = 0.03 * max(t_size)
    scene.render.bake.margin = 8
    scene.render.bake.normal_space = "TANGENT"
    select_only(high, low)
    bpy.ops.object.bake(type="NORMAL")
    print("BAKE normal baked", baked.size[:])

    # Rewire the low material: baked normal replaces the original normal map,
    # colour and roughness/metal maps are reused at --tex resolution.
    principled = next(n for n in nodes if n.type == "BSDF_PRINCIPLED")
    normal_map = next((n for n in nodes if n.type == "NORMAL_MAP"), None)
    if normal_map is None:
        normal_map = nodes.new("ShaderNodeNormalMap")
        links.new(normal_map.outputs["Normal"], principled.inputs["Normal"])
    for link in list(normal_map.inputs["Color"].links):
        old = link.from_node
        links.remove(link)
        if old.type == "TEX_IMAGE":
            nodes.remove(old)
    links.new(bake_node.outputs["Color"], normal_map.inputs["Color"])
    # bpy wrappers are not identity-stable: compare nodes by name.
    base_inputs = {link.from_node.name for link in principled.inputs["Base Color"].links}
    for node in list(nodes):
        if node.type == "TEX_IMAGE" and node.name != bake_node.name and node.image is not None:
            role = "basecolor" if node.name in base_inputs else "rm"
            image = node.image.copy()
            image.name = args.name + "_" + role
            if image.size[0] > args.tex or image.size[1] > args.tex:
                image.scale(args.tex, args.tex)
            node.image = image
    for image in bpy.data.images:
        if image.users and image.has_data:
            image.pack()

    # 6. Export only the low model.
    bpy.data.objects.remove(high, do_unlink=True)
    low.data.name = args.name + "_mesh"
    select_only(low)
    bpy.ops.export_scene.gltf(filepath=args.out, export_format="GLB", use_selection=True,
        export_image_format=args.image_format, export_jpeg_quality=92, export_yup=True, export_apply=True,
        export_animations=False)
    print("BAKE wrote", args.out, "tris", triangles(low), "materials", len(low.data.materials))


main()
