"""T-267 (D-188 point 8) A30: room 407's small things, new meshes for the mesh nodes the integrator listed (PLAN A30:
bevels and normals where they are needed, the prints, UV and words kept). Every node keeps its name, place and size
(within a few millimetres); only its mesh changes, and it keeps the material its scene gave the old box (the PS1 surface
shader on the same 128 px prints; the shower buttons, which had none, get a plain plastic one). Each mesh is built in
its own node's space (Godot metres) and written as an OBJ (one surface). The old tests' small-prop budgets hold: under
500 triangles for the notebook (and the songbook with it), the outlet and the bin. Visual only.
  dat_notebook.tscn   Cover      the back cover board, rounded corners, its sports print on top (sport.png)
                      Page       the block of pages over it, rounded corners, the first page on top (paper.png)
                      Binding0-6 the spiral's wire loops round the left edge, through the pages
  guitar_songbook     ChordString0-5, ChordFret0-3   the chord box printed on the page: flat ink lines, the nut thicker
  khoa_outlet.tscn    Recess, Top/Bottom/Left/RightTrim, Cover, ContactLeft/Right, ScrewTop   a wall socket: dark back,
                      the frame's rounded bars, the socket face, two rounded slots, a domed screw
  trash_bin.tscn      Waste0-2   three crumpled balls of paper (Base, Slat* are room 407's REPLACED_PS1: untouched)
  room407_anchors     ShowerYes/Button, ShowerNo/Button   a plate on the tiles and a push button on it
Run with Blender 5.2.2 from the repository root:
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10_a30.py
"""
import math
import random
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave1"))
import w1kit  # noqa: E402

OUT = w1kit.ROOT / "game/assets/models/graphics_pilot/realistic_map/wave10/a30"
made = {}


def G(x, y, z):
	return Vector((x, -z, y))


def slab(part, mat, axes, centre, half_a, half_b, c0, c1, r, segs=4, bevel=0.0, bevel_segs=2, only_high=False):
	"""A slab whose outline is a rounded rectangle in the (a, b) plane, from c0 to c1 along c; axes names the Godot axes
	of a, b, c ("x", "y" or "z"); centre is the Godot point the a, b offsets start from. The rims bevelled (only the c1
	one with only_high: the back lies on a desk or a wall)."""
	outline = []
	for cx, cy, start in ((half_a - r, half_b - r, 0), (-half_a + r, half_b - r, 90), (-half_a + r, -half_b + r, 180),
			(half_a - r, -half_b + r, 270)):
		for k in range(segs + 1):
			ang = math.radians(start + 90.0 * k / segs)
			outline.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))

	def P(a, b, c):
		v = {"x": centre[0], "y": centre[1], "z": centre[2]}
		v[axes[0]] += a
		v[axes[1]] += b
		v[axes[2]] += c
		return G(v["x"], v["y"], v["z"])

	bm = part.bm
	low = [bm.verts.new(P(a, b, c0)) for a, b in outline]
	high = [bm.verts.new(P(a, b, c1)) for a, b in outline]
	faces = [bm.faces.new(high), bm.faces.new(list(reversed(low)))]
	n = len(outline)
	for i in range(n):
		j = (i + 1) % n
		faces.append(bm.faces.new((low[i], low[j], high[j], high[i])))
	bmesh.ops.recalc_face_normals(bm, faces=faces)
	index = part.slot(mat)
	for f in faces:
		f.material_index = index
		f.smooth = len(f.verts) == 4
	caps = faces[:1] if only_high else faces[:2]
	if bevel > 0.0:
		rims = list({e for f in caps for e in f.edges})
		done = bmesh.ops.bevel(bm, geom=rims, offset=bevel, segments=bevel_segs, affect="EDGES", profile=0.5,
			clamp_overlap=True)
		for f in done["faces"]:
			f.material_index = index
			f.smooth = True
		faces = list({f for v in low + high if v.is_valid for f in v.link_faces} | set(done["faces"]))
	for f in faces:
		if len(f.verts) > 4:
			f.smooth = False
	return faces


def top_uv(part, faces, x0, x1, z0, z1):
	"""UV 0..1 over the rectangle seen from above (u along +x, v along +z), as BoxMesh's top face."""
	part.planar_uv(faces, G(x0, 0, z0), G(1, 0, 0), G(0, 0, 1), size=(x1 - x0, z1 - z0))


def keep(name, part):
	made[name] = part.build()


# ---------------------------------------------------------------- notebook (node origins: Cover (0, 0.008, 0),
# Page (0, 0.02, 0), Binding_i (-0.093, 0.026, z_i)); the book lies on y 0, its first page's top at 0.0245.

def notebook():
	part = w1kit.Part("A30NotebookCover")
	faces = slab(part, "A30Cover", ("x", "z", "y"), (0, -0.008, 0), 0.1, 0.14, 0.0, 0.0026, 0.006, segs=2)
	top_uv(part, faces, -0.1, 0.1, -0.14, 0.14)
	keep("notebook_cover", part)
	part = w1kit.Part("A30NotebookPages")
	faces = slab(part, "A30Paper", ("x", "z", "y"), (0, -0.02, 0), 0.09, 0.13, 0.0026, 0.0245, 0.004, segs=2, bevel=0.0012,
		bevel_segs=1, only_high=True)
	top_uv(part, faces, -0.09, 0.09, -0.13, 0.13)
	keep("notebook_pages", part)
	# One loop of the coil round the left edge (cover from x -0.1, pages from -0.09), through a hole 7 mm in (x -0.083).
	part = w1kit.Part("A30Ring")
	centre_x, centre_y, radius = -0.0025, -0.0125, 0.0122
	points = []
	steps = 8
	for k in range(steps + 1):
		a = k / steps * math.tau
		points.append(G(centre_x + math.cos(a) * radius, centre_y + math.sin(a) * radius, -0.0018 + 0.0036 * k / steps))
	part.tube("A30Ring", points, 0.0012, segments=3, cap=False)
	keep("notebook_ring", part)


# ---------------------------------------------------------------- the chord box printed on the songbook's page
# (ChordString_i at (x_i, 0.027, -0.04), ChordFret_j at (0, 0.027, z_j)); the page's top is at 0.0245.

def ink_line(name, half_x, half_z):
	part = w1kit.Part(name)
	y = -0.0013
	f = part.poly("A30Ink", [G(-half_x, y, -half_z), G(half_x, y, -half_z), G(half_x, y, half_z), G(-half_x, y, half_z)],
		[(0, 1, 2, 3)], recalc=False)[0]
	f.normal_update()
	if f.normal.dot(G(0, 1, 0)) < 0:
		f.normal_flip()
	top_uv(part, [f], -half_x, half_x, -half_z, half_z)
	keep(name.lower(), part)


# ---------------------------------------------------------------- Khoa's wall socket (faces +x, the wall at x 0.1)

def outlet():
	part = w1kit.Part("A30OutletBack")
	part.box("A30Dark", G(-0.0015, -0.073, -0.063), G(0.0015, 0.073, 0.063))
	keep("outlet_back", part)
	part = w1kit.Part("A30OutletRail")  # Top/BottomTrim: 0.024 deep, 0.022 high, 0.174 long
	part.box("A30Ivory", G(-0.012, -0.011, -0.087), G(0.012, 0.011, 0.087), bevel=0.003, segments=1)
	keep("outlet_rail", part)
	part = w1kit.Part("A30OutletStile")  # Left/RightTrim: 0.024 deep, 0.15 high, 0.022 wide
	part.box("A30Ivory", G(-0.012, -0.075, -0.011), G(0.012, 0.075, 0.011), bevel=0.003, segments=1)
	keep("outlet_stile", part)
	part = w1kit.Part("A30OutletFace")  # Cover: 0.018 deep, 0.12 square
	slab(part, "A30Ivory", ("z", "y", "x"), (0, 0, 0), 0.06, 0.06, -0.009, 0.009, 0.013, segs=3, bevel=0.004, bevel_segs=2,
		only_high=True)
	keep("outlet_face", part)
	part = w1kit.Part("A30OutletSlot")  # Contact*: a rounded slot just proud of the face (front at x 0.1305)
	slab(part, "A30Dark", ("z", "y", "x"), (0, 0, 0), 0.0045, 0.0135, -0.0012, 0.0015, 0.0042, segs=2)
	keep("outlet_slot", part)
	part = w1kit.Part("A30OutletScrew")  # ScrewTop: a domed head
	part.lathe("A30Steel", [(0.0042, 0.0), (0.0038, 0.0009), (0.0022, 0.0017), (0.0, 0.0019)],
		segments=8, matrix=_x_axis(Vector((-0.0012, 0, 0))))
	keep("outlet_screw", part)


def _x_axis(at):
	"""Lathe axis (local Z) along Godot +x, at the Godot point `at`."""
	from mathutils import Matrix
	return Matrix.Translation(G(*at)) @ Matrix.Rotation(math.pi / 2, 4, "Y")


# ---------------------------------------------------------------- paper crumpled in the bin (Waste_i at (x, 0.08, 0))

def waste(index):
	part = w1kit.Part("A30Waste%d" % index)
	rng = random.Random(267_400 + index)
	bm = part.bm
	ico = bmesh.ops.create_icosphere(bm, subdivisions=2, radius=1.0)
	verts = ico["verts"]
	sx, sy, sz = 0.034 + 0.004 * rng.random(), 0.0145, 0.044 + 0.005 * rng.random()
	for v in verts:
		d = v.co.normalized()
		crumple = 1.0 + rng.uniform(-0.2, 0.16)
		g = Vector((d.x * sx, d.z * sy, -d.y * sz)) * crumple
		v.co = G(g.x, g.y, g.z)
	faces = list({f for v in verts for f in v.link_faces})
	index_slot = part.slot("A30Paper")
	for f in faces:
		f.material_index = index_slot
		f.smooth = False
	part.planar_uv(faces, G(-0.045, 0, -0.05), G(1, 0, 0), G(0, 0, 1), size=(0.09, 0.1))
	keep("waste%d" % index, part)


# ---------------------------------------------------------------- the shower's Có / Không buttons (Button under a
# marker turned 90 degrees: local -z is the tiled wall, the face looks along +z; was a 0.11 x 0.05 x 0.035 box)

def shower_button():
	part = w1kit.Part("A30ShowerButton")
	slab(part, "A30Plastic", ("x", "y", "z"), (0, 0, 0), 0.055, 0.025, -0.0175, -0.0095, 0.006, bevel=0.0015)
	slab(part, "A30Plastic", ("x", "y", "z"), (0, 0, 0), 0.044, 0.017, -0.0095, 0.0115, 0.005, bevel=0.003, bevel_segs=3)
	keep("shower_button", part)


def export_obj(name, obj):
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	path = OUT / (name + ".obj")
	bpy.ops.wm.obj_export(filepath=str(path), export_selected_objects=True, export_materials=False, export_uv=True,
		export_normals=True, export_triangulated_mesh=True, forward_axis="NEGATIVE_Z", up_axis="Y", apply_modifiers=True,
		export_object_groups=False, export_material_groups=False)
	tris = w1kit.triangles([obj])
	print("T267_A30 %s %d tris" % (path.name, tris))
	return tris


def main():
	w1kit.reset()
	OUT.mkdir(parents=True, exist_ok=True)
	notebook()
	ink_line("ChordString", 0.0006, 0.04)
	ink_line("ChordFret", 0.0475, 0.0007)
	ink_line("ChordNut", 0.0475, 0.0016)
	outlet()
	for k in range(3):
		waste(k)
	shower_button()
	total = sum(export_obj(name, obj) for name, obj in made.items())
	print("RESULT: T-267 A30 meshes", len(made), "files", total, "tris")


main()
