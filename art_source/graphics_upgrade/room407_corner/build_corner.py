"""Rebuild the measured room corner, export GLBs and an editable Blender scene.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
Coordinates in helpers are room-local Godot metres; Blender conversion is explicit.
"""
import json
import math
from pathlib import Path

import bpy
from mathutils import Vector

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "game/assets/models/graphics_pilot/room407_corner"
TEXTURES = HERE / "textures"
GROUPS = {}
GROUP = "architecture"


def point(v):
    return Vector((v[0], -v[2], v[1]))


def material(name, asset, color=(1, 1, 1, 1), color_asset=None, strength=0.45):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    for suffix in ("color", "normal", "arm"):
        tex = nodes.new("ShaderNodeTexImage")
        stem = color_asset if suffix == "color" and color_asset else asset
        tex.image = bpy.data.images.load(str(TEXTURES / f"{stem}_{suffix}.jpg"), check_existing=True)
        if suffix != "color":
            tex.image.colorspace_settings.name = "Non-Color"
        if suffix == "color":
            links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        elif suffix == "normal":
            normal = nodes.new("ShaderNodeNormalMap")
            normal.inputs["Strength"].default_value = strength
            links.new(tex.outputs["Color"], normal.inputs["Color"])
            links.new(normal.outputs["Normal"], bsdf.inputs["Normal"])
        else:
            split = nodes.new("ShaderNodeSeparateColor")
            links.new(tex.outputs["Color"], split.inputs["Color"])
            links.new(split.outputs["Green"], bsdf.inputs["Roughness"])
            links.new(split.outputs["Blue"], bsdf.inputs["Metallic"])
            # glTF exporter recognises this group for AO.
            group = bpy.data.node_groups.get("glTF Material Output")
            if not group:
                group = bpy.data.node_groups.new("glTF Material Output", "ShaderNodeTree")
                group.interface.new_socket(name="Occlusion", in_out="INPUT", socket_type="NodeSocketFloat")
            occlusion = nodes.new("ShaderNodeGroup")
            occlusion.node_tree = group
            links.new(split.outputs["Red"], occlusion.inputs["Occlusion"])
    mat.diffuse_color = color
    return mat


def finish(obj, name, mat):
    obj.name = name
    obj.data.materials.append(mat)
    GROUPS.setdefault(GROUP, []).append(obj)
    return obj


def box(name, pos, size, mat, bevel=0.006, period=1.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=point(pos))
    obj = bpy.context.object
    obj.dimensions = (size[0], size[2], size[1])
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Metric, non-stretched UVs on each face, before the bevel interpolates them.
    uv = obj.data.uv_layers.active.data
    for face in obj.data.polygons:
        axis = max(range(3), key=lambda i: abs(face.normal[i]))
        axes = [i for i in range(3) if i != axis]
        for li in face.loop_indices:
            v = obj.data.vertices[obj.data.loops[li].vertex_index].co + obj.location
            uv[li].uv = (v[axes[0]] / period, v[axes[1]] / period)
    if bevel:
        mod = obj.modifiers.new("Manufactured edge radius", "BEVEL")
        mod.width, mod.segments = bevel, 2
        bpy.ops.object.modifier_apply(modifier=mod.name)
        obj.modifiers.new("Weighted corner normals", "WEIGHTED_NORMAL")
    return finish(obj, name, mat)


def tube(name, a, b, radius, mat, sides=12, period=0.5):
    start, end = point(a), point(b)
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=(end-start).length,
                                      location=(start+end)/2)
    obj = bpy.context.object
    obj.rotation_euler = (end-start).to_track_quat("Z", "Y").to_euler()
    # Metric UVs (circumference x length) so paint chips are not squeezed 8x around thin tubes.
    uv = obj.data.uv_layers.active.data
    for face in obj.data.polygons:
        face.use_smooth = len(face.vertices) == 4
        angles = [math.atan2(obj.data.vertices[obj.data.loops[li].vertex_index].co.y,
                             obj.data.vertices[obj.data.loops[li].vertex_index].co.x) for li in face.loop_indices]
        wrap = max(angles) - min(angles) > math.pi
        for li, angle in zip(face.loop_indices, angles):
            co = obj.data.vertices[obj.data.loops[li].vertex_index].co
            if wrap and angle < 0:
                angle += 2 * math.pi
            uv[li].uv = (angle * radius / period, co.z / period) if face.use_smooth else (co.x / period, co.y / period)
    edge = obj.modifiers.new("Soft tube end", "BEVEL")
    edge.width, edge.segments = min(.001, radius*.12), 1
    edge.limit_method, edge.angle_limit = "ANGLE", .6
    bpy.ops.object.modifier_apply(modifier=edge.name)
    return finish(obj, name, mat)


def seam(name, coords, mat, radius=0.0018):
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 1
    curve.bevel_depth, curve.bevel_resolution = radius, 0
    spline = curve.splines.new("POLY")
    spline.points.add(len(coords)-1)
    for p, v in zip(spline.points, coords):
        p.co = (*point(v), 1)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    return finish(bpy.context.object, name, mat)


def quilt(name, level, mat):
    nx, nz = 14, 28
    verts, faces = [], []
    for j in range(nz+1):
        z = -3.92 + j/nz * 1.35
        for i in range(nx+1):
            x = 0.22 + i/nx * 0.86
            edge = max(0, abs(x-0.65)-0.365)
            wrinkle = 0.007*math.sin(i*1.35+j*.52) + .006*math.sin(j*.94+i*.35)
            y = level+.019+wrinkle-edge*1.8
            verts.append(point((x,y,z)))
    for j in range(nz):
        for i in range(nx):
            k = j*(nx+1)+i
            faces.append((k+nx+1,k+nx+2,k+1,k))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    uv = mesh.uv_layers.new()
    for face in mesh.polygons:
        face.use_smooth = True
        for li in face.loop_indices:
            v = verts[mesh.loops[li].vertex_index]
            uv.data[li].uv = (v.x/.35, v.y/.35)
    finish(obj, name, mat)
    for j in [0,nz]:
        coords = []
        for i in range(nx+1):
            v = verts[j*(nx+1)+i]
            coords.append((v.x,v.z+.001,-v.y))
        seam(name+"_hem", coords, mat)


def metric_uv(obj, period):
    """Box-project UVs in metres (object space) after deformation."""
    uv = obj.data.uv_layers.active or obj.data.uv_layers.new()
    for face in obj.data.polygons:
        axis = max(range(3), key=lambda i: abs(face.normal[i]))
        axes = [i for i in range(3) if i != axis]
        for li in face.loop_indices:
            v = obj.data.vertices[obj.data.loops[li].vertex_index].co
            uv.data[li].uv = (v[axes[0]] / period, v[axes[1]] / period)


def soft_block(name, centre, size, mat, cuts, shape, period):
    """Subdivided unit cube reshaped by shape(x, y, z) -> (x, y, z), in Godot axes."""
    bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 0))
    obj = bpy.context.object
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.subdivide(number_cuts=cuts)
    bpy.ops.object.mode_set(mode="OBJECT")
    for v in obj.data.vertices:
        gx, gy, gz = shape(v.co.x, v.co.z, -v.co.y)
        v.co = Vector((gx * size[0] / 2, -gz * size[2] / 2, gy * size[1] / 2))
    metric_uv(obj, period)
    obj.location = point(centre)
    for face in obj.data.polygons:
        face.use_smooth = True
    return finish(obj, name, mat)


def pillow_shape(x, y, z):
    # Puffy centre, pinched seams and corners, a little sag where the head rests.
    puff = ((1 - abs(x) ** 4) * (1 - abs(z) ** 4)) ** 0.42
    dent = 0.18 * math.exp(-((x + 0.15) ** 2 / 0.18 + z ** 2 / 0.25)) if y > 0 else 0.0
    wrinkle = 0.05 * math.sin(7 * x + 3 * z) * (1 - puff)
    if y > 0:
        return x * (1 + 0.03 * math.sin(9 * z)), y * max(puff - dent, 0.06) + wrinkle, z
    # Resting underside: nearly flat, seams sit ~2 cm above the mattress.
    return x * (1 + 0.03 * math.sin(9 * z)), y * min(max(puff, 0.06), 0.35), z


def grid(name, x_range, z_range, height, nx, nz, mat, period, lift):
    """Cloth sheet in Godot axes; lift(u, v) gives extra height so rest length exceeds footprint."""
    verts, faces, uvs = [], [], []
    for j in range(nz + 1):
        for i in range(nx + 1):
            u, v = i / nx, j / nz
            x = x_range[0] + u * (x_range[1] - x_range[0])
            z = z_range[0] + v * (z_range[1] - z_range[0])
            verts.append(point((x, height + lift(u, v), z)))
    for j in range(nz):
        for i in range(nx):
            k = j * (nx + 1) + i
            faces.append((k, k + nx + 1, k + nx + 2, k + 1))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    uv = mesh.uv_layers.new()
    # UVs follow the sheet's own arc length so the weave is not stretched by the folds.
    arc = [0.0]
    for j in range(1, nz + 1):
        arc.append(arc[-1] + (verts[j * (nx + 1)] - verts[(j - 1) * (nx + 1)]).length)
    for face in mesh.polygons:
        face.use_smooth = True
        for li in face.loop_indices:
            k = mesh.loops[li].vertex_index
            i, j = k % (nx + 1), k // (nx + 1)
            uv.data[li].uv = (i / nx * (x_range[1] - x_range[0]) / period, arc[j] / period)
    return finish(obj, name, mat)


def drape(obj, frames, colliders, grow=0.0, bending=0.6):
    """Run Blender cloth on obj against colliders, then bake the result into the mesh."""
    added = []
    for other in colliders:
        if not any(m.type == "COLLISION" for m in other.modifiers):
            other.modifiers.new("Collision", "COLLISION")
            other.collision.thickness_outer = 0.004
            other.collision.cloth_friction = 20
            added.append(other)
    cloth = obj.modifiers.new("Cloth", "CLOTH")
    st, col = cloth.settings, cloth.collision_settings
    st.quality, st.mass, st.air_damping = 8, 0.35, 2
    st.tension_stiffness = st.compression_stiffness = 40
    st.shear_stiffness, st.bending_stiffness = 10, bending
    st.shrink_min = -grow  # negative shrink: the sheet wants more area than it has, so it buckles into folds
    col.distance_min, col.use_self_collision, col.self_distance_min = 0.004, True, 0.004
    col.collision_quality = 3
    scene = bpy.context.scene
    scene.frame_start, scene.frame_end = 1, frames
    cloth.point_cache.frame_start, cloth.point_cache.frame_end = 1, frames
    for frame in range(1, frames + 1):
        scene.frame_set(frame)
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=cloth.name)
    for other in added:
        for m in [m for m in other.modifiers if m.type == "COLLISION"]:
            other.modifiers.remove(m)
    scene.frame_set(1)


def main():
    global GROUP
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.context.scene.unit_settings.system = "METRIC"
    plaster = material("Aged cream paint | scanned CC0", "painted_plaster_wall",
                       color_asset="painted_plaster_wall_cream", strength=0.8)
    ceramic = material("Small ceramic | CC0 1K", "plastered_wall_04_small")
    tile = material("Ceramic tile | scanned CC0", "interior_tiles")
    steel = material("Green painted steel | scanned CC0", "green_metal_rust", strength=0.7)
    fabric = material("Mattress cover | scanned CC0", "rough_linen_square", strength=0.8)
    wood = material("Worn desk veneer | scanned CC0", "wood_table_worn")
    mat_rush = material("Sleeping mat (chieu) | scanned CC0", "tatami_mat", strength=0.9)
    check = material("Checked pillowcase | scanned CC0", "fabric_pattern_05", strength=0.8)
    fleece = material("Fleece blanket | scanned CC0", "polar_fleece_square", strength=1.0)
    GROUP = "floor"
    box("Floor", (4,-.1,-3.5), (8,.2,7), tile, .003, 1.9)
    GROUP = "architecture"
    box("WestWall", (0,1.5,-3.5), (.2,3,7), plaster, .003, 2.0)
    box("BackWest", (1.15,1.5,-7), (2.3,3,.15), plaster, .003, 2.0)
    box("BackEast", (4.25,1.5,-7), (1.9,3,.15), plaster, .003, 2.0)
    box("BalconyLintel", (2.8,2.65,-7), (1,.7,.15), plaster, .003, 2.0)
    box("Ceiling", (4,3.075,-3.5), (8,.15,7), plaster, .003, 2.0)
    # Close the shell so wide views show walls, not the void (room_407 / extension / floor4 door 407).
    box("EastWall", (8,1.5,-3.5), (.2,3,7), plaster, .003, 2.0)
    box("FrontWallWest", (.75,1.5,.075), (1.5,3,.15), plaster, .003, 2.0)
    box("FrontWallEast", (5.225,1.5,.075), (5.55,3,.15), plaster, .003, 2.0)
    box("DoorLintel", (1.975,2.55,.075), (.95,.9,.15), plaster, .003, 2.0)
    box("BathroomBack", (6.65,1.5,-7), (2.7,3,.15), plaster, .003, 2.0)
    box("BathroomSide", (5.3,1.5,-5.5), (.15,3,3), plaster, .003, 2.0)
    box("BathFrontW", (5.3125,1.5,-4), (.075,3,.15), plaster, .003, 2.0)
    box("BathFrontE", (7.175,1.5,-4), (1.65,3,.15), plaster, .003, 2.0)
    box("BathLintel", (5.85,2.6,-4), (1,.8,.15), plaster, .003, 2.0)
    GROUP = "floor"
    box("WestSkirting", (.118,.06,-3.5), (.036,.12,7), tile, .005, 1.9)
    for x, width in [(1.2,2.2),(4.25,1.9)]:
        box("BackSkirting", (x,.06,-6.907), (width,.12,.035), tile,.005,1.9)
    GROUP = "fixtures"
    # Existing balcony aperture: x=2.3..3.3, y=0..2.3, NOT a new wall/window.
    for x in [2.315,3.285]:
        box("BalconyJamb", (x,1.15,-6.96), (.03,2.3,.14), steel,.004)
    box("BalconyHeader", (2.8,2.285,-6.96), (1,.03,.14), steel,.004)
    box("BalconyThreshold", (2.8,.012,-7), (1,.024,.19), ceramic,.004)
    for y in [.1,2.3]:
        box("WindowFixing", (2.31,y,-6.87), (.025,.03,.018), steel,.003)
    # Aged socket plate and recessed socket holes: no writing or narrative cue.
    box("SocketPlate", (.127,1.04,-4.42), (.05,.13,.095), ceramic,.009,.28)
    for z in [-4.445,-4.405]:
        box("SocketHole", (.154,1.04,z), (.003,.035,.008), steel,.002,.25)
    tube("WallConduit", (.126,1.11,-4.42), (.126,2.87,-4.42), .008, ceramic)
    # Closed doors (room door leaf hinges at x=2.44; bathroom door 5.35..6.35).
    box("RoomDoor", (1.995,1.05,.02), (.89,2.1,.04), steel, .006)
    box("BathroomDoor", (5.85,1.1,-4), (.98,2.2,.04), steel, .006)
    box("TubeHousing", (2,2.88,-1.2), (1.15,.065,.13), steel,.014)
    for z in [-1.235,-1.165]:
        tube("FluorescentTube", (1.46,2.84,z), (2.54,2.84,z), .016, ceramic,16)
    for x in [1.43,2.57]:
        box("TubeSocket", (x,2.855,-1.2), (.07,.06,.14), ceramic,.012,.3)
    GROUP = "bunk_a"
    for x in [.22,1.08]:
        for z in [-3.98,-2.02]:
            tube("RoundPost", (x,.025,z), (x,1.68,z), .02, steel)
            box("FootCap", (x,.017,z), (.042,.034,.042), steel,.009)
    for y in [.36,1.14]:
        for x in [.235,1.065]:
            tube("SideRail", (x,y,-3.97), (x,y,-2.03), .018, steel)
        for z in [-3.97,-2.03]:
            tube("EndRail", (.235,y,z), (1.065,y,z), .018, steel)
        box("MattressDeck", (.65,y,-3), (.83,.025,1.9), steel,.009)
        for x in [.22,1.08]:
            for z in [-3.98,-2.02]:
                tube("WeldCollar", (x,y-.025,z),(x,y+.025,z),.023,steel)
                tube("HexBolt", (x+.018,y,z),(x+.027,y,z),.007,steel,6)
    for z in [-3.98,-2.02]:
        tube("HeadRail", (.22,1.62,z),(1.08,1.62,z),.016,steel)
        for x in [.42,.65,.88]:
            tube("HeadSpindle",(x,1.18,z),(x,1.62,z),.009,steel,8)
    tube("SafetyRail",(.22,1.49,-3.98),(.22,1.49,-2.02),.015,steel)
    for z in [-3.8,-3.45]:
        tube("LadderStile",(1.078,.025,z),(1.078,1.4,z),.017,steel)
    for y in [.22,.49,.76,1.03,1.3]:
        tube("LadderRung",(1.078,y,-3.8),(1.078,y,-3.45),.013,steel)
    mattresses, rails = {}, [o for o in GROUPS["bunk_a"] if o.name.startswith(("SideRail", "EndRail"))]
    for tag, top in [("Lower",.43),("Upper",1.20)]:
        # Foam mattress in a linen cover; a 2 mm rush sleeping mat (chieu) lies on top.
        mattress = box(tag+"Mattress",(.65,top-.026,-3),(.8,.048,1.9),fabric,.016,.27)
        for vertex in mattress.data.vertices:
            if vertex.co.z > .005:
                vertex.co.z -= .003*math.exp(-((vertex.co.x/.26)**2+(vertex.co.y/.65)**2))
        seam(tag+"Piping",[(.255,top-.004,-3.94),(1.045,top-.004,-3.94),
                           (1.045,top-.004,-2.06),(.255,top-.004,-2.06),(.255,top-.004,-3.94)],fabric)
        mattresses[tag] = mattress
    GROUP = "bunk_a_bedding"
    for tag, top in [("Lower",.43),("Upper",1.20)]:
        # One woven panel between the mat's binding strips: 1.8 m repeat along the bed.
        sleeping_mat = grid(tag+"SleepingMat", (.27,1.03), (-3.93,-2.07), top-.001, 1, 1, mat_rush, 1.8, lambda u, v: 0)
        for li, loop in enumerate(sleeping_mat.data.loops):
            u, v = sleeping_mat.data.uv_layers.active.data[li].uv
            sleeping_mat.data.uv_layers.active.data[li].uv = (v, .03 + u * .42 / (.76/1.8))
        pillow = soft_block(tag+"Pillow", (.65, top+.024, -2.33), (.52, .17, .34), check, 7, pillow_shape, .5)
        pillow.rotation_euler.z = math.radians(4 if tag == "Lower" else -6)
    # Lower bed: blanket thrown back in folds (Blender cloth).
    blanket = grid("LowerBlanket", (.2,1.1), (-3.92,-2.62), .43+.07, 26, 36, fleece, .27,
                   lambda u, v: .04*math.sin(v*math.pi*3+.8*math.sin(u*4)) + .02*math.sin(u*math.pi*2.5+v*5))
    ladder = [o for o in GROUPS["bunk_a"] if o.name.startswith(("Ladder", "RoundPost"))]
    drape(blanket, 90, [mattresses["Lower"], *[o for o in GROUPS["bunk_a_bedding"] if o.name == "LowerPillow"], *rails, *ladder],
          grow=.16, bending=.3)
    # Upper bed: the same fleece pushed into a heap at the foot.
    heap = grid("UpperBlanket", (.36,.96), (-3.9,-3.3), 1.20+.15, 20, 18, fleece, .27,
                lambda u, v: .08*math.sin(v*math.pi*2.5+u*2) + .04*math.sin(u*math.pi*3))
    drape(heap, 60, [mattresses["Upper"], *rails, *ladder], grow=.18, bending=.3)
    for sheet in (blanket, heap):
        zs = [v.co.z for v in sheet.data.vertices]
        print("DRAPE", sheet.name, "blender z range", round(min(zs), 3), round(max(zs), 3))
    for sheet in (blanket, heap):
        # Keep the big folds, drop cell-sized buckles that shade as a sawtooth.
        calm = sheet.modifiers.new("Calm cell buckles", "SMOOTH")
        calm.factor, calm.iterations = .5, 4
        # Fleece is about a centimetre thick: give the sheet a body and a soft rim instead of a paper edge.
        thick = sheet.modifiers.new("Fleece thickness", "SOLIDIFY")
        thick.thickness, thick.offset, thick.use_rim = .012, 1.0, True
        bpy.context.view_layer.objects.active = sheet
        bpy.ops.object.modifier_apply(modifier=calm.name)
        bpy.ops.object.modifier_apply(modifier=thick.name)
        sheet.modifiers.new("Smooth folds", "WEIGHTED_NORMAL")
    GROUP = "study_desk"
    box("DeskTop",(1.8,.735,-4.55),(1.5,.05,.65),wood,.012,.55)
    for x in [1.13,2.47]:
        for z in [-4.8,-4.3]:
            tube("DeskLeg",(x,.015,z),(x,.71,z),.018,steel)
            box("DeskFoot",(x,.012,z),(.045,.024,.045),steel,.008)
    box("DeskApron",(1.8,.635,-4.79),(1.37,.15,.026),wood,.006,.55)
    for x in [1.13,2.47]:
        tube("DeskBrace",(x,.24,-4.8),(x,.24,-4.3),.01,steel)
    box("Drawer",(2.13,.646,-4.57),(.53,.11,.5),wood,.008,.55)
    tube("DrawerHandle",(2.01,.65,-4.304),(2.25,.65,-4.304),.007,steel)
    GROUP = "fixtures"
    # Rebuilt lamp placed on desk surface; fixture only, separate pilot light.
    box("LampBase",(1.8,.772,-4.6),(.18,.024,.15),steel,.012)
    tube("LampStem",(1.8,.784,-4.6),(1.77,1.0,-4.65),.009,steel)
    tube("LampArm",(1.77,1,-4.65),(1.85,1.10,-4.52),.008,steel)
    bpy.ops.mesh.primitive_cone_add(vertices=20, radius1=.085,radius2=.035,depth=.09,location=point((1.85,1.06,-4.52)))
    finish(bpy.context.object,"LampShade",steel)
    # Export only our visual geometry. No Tripo duplication in runtime exports.
    report = {"basis":"Godot room-local metres: x, y up, z; room world origin (30,0,0)","groups":{}}
    for name, objects in GROUPS.items():
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects: obj.select_set(True)
        bpy.context.view_layer.objects.active = objects[0]
        tris=0
        for obj in objects:
            evaluated=obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
            mesh=evaluated.to_mesh();mesh.calc_loop_triangles();tris+=len(mesh.loop_triangles);evaluated.to_mesh_clear()
        filepath=OUT/(name+".glb")
        bpy.ops.export_scene.gltf(filepath=str(filepath),export_format="GLB",use_selection=True,
                                  export_apply=True,export_image_format="JPEG",export_jpeg_quality=90,export_yup=True)
        report["groups"][name]={"triangles":tris,"mesh_count":len(objects),"file_bytes":filepath.stat().st_size}
        assert filepath.stat().st_size <= 10*1024*1024, filepath
    # Editable full corner includes approved Tripo props with external textures.
    placements=json.loads((HERE/"placements.json").read_text())
    imported=[]
    for row in placements:
        bpy.ops.object.select_all(action="DESELECT")
        before=set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=str(ROOT/"game"/row["model"].removeprefix("res://")))
        objects=set(bpy.data.objects)-before
        anchor=bpy.data.objects.new(row["name"],None);bpy.context.collection.objects.link(anchor)
        anchor.location=point(row["position"]);anchor.rotation_euler.z=math.radians(row["yaw"])
        for obj in objects:
            if obj.parent not in objects: obj.parent=anchor
        imported.extend(objects)
    unpack=HERE/"blender_textures";unpack.mkdir(exist_ok=True)
    for index,img in enumerate(bpy.data.images):
        if img.packed_file:
            path=unpack/f"tripo_{index:02d}.png"
            img.filepath_raw=str(path);img.file_format="PNG";img.save()
            img.unpack(method="REMOVE")
            img.filepath=str(path)
            assert path.stat().st_size<=10*1024*1024,path
        if img.filepath: img.filepath=bpy.path.relpath(img.filepath,start=str(HERE)).replace("\\", "/")
    report["generated_triangles"]=sum(g["triangles"] for g in report["groups"].values())
    report["tripo_triangles"]=sum(len(o.data.loop_triangles) if o.data.loop_triangles else sum(len(p.vertices)-2 for p in o.data.polygons) for o in imported if o.type=="MESH")
    # A usable Blender opening view and lights, never exported as gameplay lights.
    bpy.ops.object.camera_add(location=point((5.15,1.6,-.7)))
    cam=bpy.context.object;cam.rotation_euler=(point((1.7,.85,-3.8))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.lens=23
    bpy.context.scene.camera=cam
    for pos,power,size in [((2,2.78,-1.2),180,1.1),((2.6,2.6,-4.8),80,2)]:
        bpy.ops.object.light_add(type="AREA",location=point(pos));bpy.context.object.data.energy=power;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=size
    bpy.context.scene.world=bpy.data.worlds.new("Night interior preview")
    bpy.context.scene.world.color=(.06,.07,.09)
    bpy.context.scene.render.resolution_x=1280;bpy.context.scene.render.resolution_y=720
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type=='VIEW_3D': area.spaces.active.region_3d.view_perspective='CAMERA'
    bpy.ops.wm.save_as_mainfile(filepath=str(HERE/"room407_corner.blend"),compress=True)
    assert (HERE/"room407_corner.blend").stat().st_size<=10*1024*1024
    (HERE/"geometry_report.json").write_text(json.dumps(report,indent=2)+'\n')
    print("RESULT: corner Blender export PASS",json.dumps(report))


if __name__ == "__main__":
    main()
