"""T-216: folded linen cleaning rag; Blender 5.2.2, no simulation or paid assets.
Run: blender -b --factory-startup -P <this file>. Metres, Godot +Y up.
Reuses the recorded CC0 Rough Linen scan; all three PBR maps embed in the GLB.
"""
import math
import sys
from pathlib import Path

import bpy

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bc.GROUP = "cleaning_rag"
    material = bc.material("Cleaning rag | CC0 Rough Linen", "rough_linen", strength=0.65)
    # Two loose folded layers: asymmetric edges, soft wrinkles, a lifted return fold.
    for layer in range(2):
        nx, nz = 20, 12
        vertices, faces, coords = [], [], []
        for j in range(nz + 1):
            v = j / nz
            for i in range(nx + 1):
                u = i / nx
                x = (u - .5) * (.28 - layer * .012) + layer * .004
                z = (v - .5) * (.12 - layer * .008) + .003 * math.sin(u * 5.0)
                y = .003 + layer * .007
                y += .002 * (1 + math.sin(u * 19 + v * 4)) * math.sin(v * math.pi)
                y += layer * .007 * math.exp(-((v - .12) / .13) ** 2)
                coords.append((x, y, z))
                vertices.append(bc.point((x, y, z)))
        for j in range(nz):
            for i in range(nx):
                k = j * (nx + 1) + i
                faces.append((k + nx + 1, k + nx + 2, k + 1, k))
        mesh = bpy.data.meshes.new("LinenFold")
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        obj = bpy.data.objects.new("LinenFold", mesh)
        bpy.context.collection.objects.link(obj)
        uv = mesh.uv_layers.new()
        for face in mesh.polygons:
            face.use_smooth = True
            for li in face.loop_indices:
                p = coords[mesh.loops[li].vertex_index]
                uv.data[li].uv = (p[0] / .27 + .5, p[2] / .27 + .5 + layer * .33)
        solid = obj.modifiers.new("Woven thickness", "SOLIDIFY")
        solid.thickness = .0012
        bc.finish(obj, "LinenFold", material)
        # Rolled hems follow the same folds; thin enough to read as cloth, not rope.
        border = list(range(nx + 1))
        border += [j * (nx + 1) + nx for j in range(1, nz + 1)]
        border += [nz * (nx + 1) + i for i in range(nx - 1, -1, -1)]
        border += [j * (nx + 1) for j in range(nz - 1, -1, -1)]
        border.append(0)
        bc.seam("RolledHem", [coords[k] for k in border], material, .0009)
    out = bc.ROOT / "game/assets/models/graphics_pilot/room407_furnished/cleaning_rag.glb"
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(out), export_format="GLB", use_selection=True,
                              export_apply=True, export_yup=True)
    bpy.ops.file.pack_all()
    bpy.ops.wm.save_as_mainfile(filepath=str(HERE / "cleaning_rag.blend"))
    assert out.stat().st_size <= 10 * 1024 * 1024
    print("RESULT: cleaning rag exported", out.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
