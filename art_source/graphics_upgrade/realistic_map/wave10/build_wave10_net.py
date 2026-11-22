"""T-267 (D-188 point 3): the one mosquito net room 407's set lacks. Every CCTV room (not 310) has bunk A's upper deck
net open, where the victim lies, as its PS1 net (kit/mosquito_net_open.glb) was; room 407 hangs only closed upper nets.
This runs room 407's own builder (art_source/graphics_upgrade/room407_furnished/build_nets.py, D-095: Blender, cloth
simulation, its generated weave) for the variant it already knows how to make, "upper_open" (the room-side wall,
+X, rolled up onto the top edge; four cords to the ceiling hooks), with a higher canopy (below), and writes it here
instead of into room 407's folder.
The weave image is not packed into the glb: make_wave10_materials.py maps the two placeholders onto CWNetWeave /
CWNetHem, which reuse room 407's weave texture (no new texture).
Run with Blender 5.2.2 from the repository root:
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10_net.py
"""
import sys
from pathlib import Path

import bpy

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
SOURCE = HERE.parents[1] / "room407_furnished/build_nets.py"
OUT = HERE.parents[3] / "game/assets/models/graphics_pilot/realistic_map/wave10"

# The builder's own code, without its call to main() (it would rebuild room 407's three nets).
code = SOURCE.read_text(encoding="utf-8")
assert code.rstrip().endswith("main()"), "build_nets.py changed: check this wrapper"
code = code.rstrip()[: -len("main()")]
# One change: the canopy 1.0 m over the mattress instead of room 407's 0.86. The CCTV victims sit up on this deck
# (106 sit_up, 209 cower, 102 answer) and their heads came through the lower top; the cords still reach the ceiling.
CANOPY = "top = deck + 0.72 if level == \"lower\" else mattress_top + 0.86"
assert CANOPY in code, "build_nets.py changed: check the canopy height"
code = code.replace(CANOPY, CANOPY.replace("0.86", "1.0"))
# And 5 cm cloth cells instead of 4.2 cm: a wave-10 glb stays under 5,000 triangles (D-188 point 7). The weave's UV is
# metric (5 cm a repeat), so the net looks the same.
CELLS = "remesh.mode, remesh.voxel_size = \"VOXEL\", 0.042"
assert CELLS in code, "build_nets.py changed: check the cell size"
code = code.replace(CELLS, CELLS.replace("0.042", "0.05"))
space = {"__name__": "build_nets", "__file__": str(SOURCE)}
exec(compile(code, str(SOURCE), "exec"), space)
space["OUT"] = OUT

bpy.ops.wm.read_factory_settings(use_empty=True)
OUT.mkdir(parents=True, exist_ok=True)
net_mat, hem_mat = space["materials"]()
# Placeholder names for the .import mapping; the weave image stays out of the glb.
net_mat.name = "CWNetWeave"
hem_mat.name = "CWNetHem"
for node in net_mat.node_tree.nodes:
	if node.type == "TEX_IMAGE":
		image = node.image
		net_mat.node_tree.nodes.remove(node)
		bpy.data.images.remove(image)
tris = space["build"]("upper_open", net_mat, hem_mat)
built = OUT / "mosquito_net_upper_open.glb"
target = OUT / "cctv_net_upper_open.glb"
target.unlink(missing_ok=True)
built.rename(target)
print("RESULT: T-267 net upper_open", tris, "tris ->", target.name)
