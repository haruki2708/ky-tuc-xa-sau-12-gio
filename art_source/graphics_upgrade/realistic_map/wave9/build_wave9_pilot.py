"""T-266 round 1: the wave-9 pilot (card section 2, step 2) for the options of step 3. Blender 5.2.2, bmesh only, no add-on,
no Tripo (the broken door is the game's own room door leaf, door_room.glb, cut and decimated here). Each glb has its origin
at the node the capture hangs it on (Godot coordinates in this file, B() turns them into Blender's):

  Room 407 (chapter 4's Room407 branch)
  slat_v1_bed2.glb      (Slat2/Hinge) V1: one plywood sheet 0.72 x 1.45 x 18 mm; its underside (W9SlatUnder) carries the scrap
  slat_v2_bed2.glb      (Slat2/Hinge) V2: nine pine slats 9 cm across the bed nailed on two battens; the scrap's words run over
                        the slats and the battens' undersides (one planar UV)
                        both lie on the Tripo bunk's deck under the mattress (top 2 cm under the hinge) and leave 8 cm of the
                        deck on the room side: lifted 62 degrees they stay under the upper bunk (bed 2's PS1 board, 0.86 m
                        at 70 degrees, goes through it)
  vent.glb / vent_open.glb   (Room407) a louvred sheet-steel grille 0.68 x 0.48 on the east wall at FakeVent, insect mesh and a
                        sooted back behind the blades; _open: the grille hanging askew from one screw (searched)
  hatch_h1.glb / hatch_h1_open.glb   (Room407) H1: a painted steel access hatch 0.6 x 0.6 in a frame, two cam locks; _open:
                        dropped on its hinge side, the dark void above
  hatch_h2.glb          (Room407) H2: a loose gypsum panel in a thin aluminium frame, one edge sagging, a dark gap
  Door 407 (glb origin = the room door leaf's own origin, door_room.glb: centre bottom, room face z -0.02)
  door_cracks.glb       Outer and Inner: the splits over the leaf's room face (W9Cracks), Inner only where the hole will be
  door_broken.glb       the leaf with the hole punched through from the corridor (W9DoorRoom, the game's textures), raw
                        splinters bent into the room (W9RawWood), decimated to ~2,000 triangles
  zombie_hand.glb       a forearm through the hole: torn grey sleeve, mottled skin, fingers clawing
  Ward (HospitalRoom; bed pieces at a Bed_* node)
  ward_shell.glb        floor, walls (green oil-paint dado 1.2 m, ivory over it, skirting), 60 x 60 ceiling panels, the
                        tube batten at CeilingLight, the window on the east wall, the monitor, three bedside cabinets
  footwall.glb / footwall_door.glb   the foot wall; _door: Y2's doorway (x 0.8..1.7) with its frame, the leaf ajar 25 degrees
                        into the room, a short dim corridor beyond
  ward_bed.glb          (Bed_*) stainless bed: head and foot frames with laminate panels, base, legs on castors, green vinyl
                        mattress (Mattress), sheet (Sheet), pillow, the card clip under the Card marker; ivbag stand iv.glb
  patient_t1.glb / patient_t2.glb   (Bed_Trung) T1: the blanket over Trung's body and legs, a bandaged forearm on it with the
                        drip line to the bag; T2: the blanket only
  patient_side.glb      (Bed_Nhat, Bed_Ngu, under Patient) a body under the blanket, the head turned to the wall, no face
  bed_empty.glb / bed_rolled.glb   (Bed_*) the lonely ending: a folded blanket on the flat sheet / the mattress rolled at the head
  curtain_y1.glb        Y1: a ceiling track round Trung's bed, the curtain drawn across its foot (z 1.5), and the shadow layer
                        (W9Shadow: the two nurses standing behind it, no light added)
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave9/build_wave9_pilot.py [-- name ...]
"""
import math
from pathlib import Path
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE.parent / "wave5"))
import w1kit  # noqa: E402
import build_gate_pilot as GP  # noqa: E402  (GPart, build, export; its main is guarded)

GP.G = 0.0      # every glb here is local: Godot (x, y, z) -> Blender (x, -z, y)
ROOT = HERE.parents[3]
GAME = ROOT / "game"
OUT = GAME / "assets/models/graphics_pilot/realistic_map/wave9"
DOOR_GLB = GAME / "assets/models/graphics_pilot/room407_shell/doors/door_room.glb"
GP.PREVIEW.update({"W9SlatUnder": ((0.6, 0.5, 0.35), 0.85), "W9DoorRoom": ((0.2, 0.4, 0.3), 0.6), "W9RawWood": ((0.7, 0.58, 0.4), 0.85),
	"W9Skin": ((0.5, 0.45, 0.38), 0.7), "W9Vinyl": ((0.2, 0.35, 0.3), 0.4), "W9Sheet": ((0.62, 0.63, 0.6), 0.9)})
SIZES = {"W8FloorCeramic": 1.6, "W8WallIvory": 2.0, "W8DadoGreen": 2.0, "W8Skirting": 1.6, "W8CeilingPanel": 2.4, "W9WardFloor": 1.6,
	"W9WardWall": 2.0, "W9WardDado": 2.0, "W9WardCeiling": 2.4}

# Bed 2 (lower bunk A): the PS1 board lies at the hinge's height (y 0.41 = Slat2); the Tripo deck's top is 0.385 and the upper
# bunk's underside 1.075 (survey_wave9.txt).
SLAT = {"x0": 0.02, "x1": 0.74, "z": 0.725, "top": -0.02, "board": 0.018, "slat_w": 0.09, "slats": 9, "batten_w": 0.04,
	"batten_h": 0.03, "battens": (0.06, 0.66)}
# The room door leaf (door_room.glb local): x -0.445 (latch) .. 0.445 (hinge), y 0 .. 2.1, z -0.02 (room face) .. 0.02.
LEAF = {"x0": -0.445, "x1": 0.445, "h": 2.1, "room": -0.02, "corr": 0.02}
# Hole centre 0.97 m up (Door407 space 0.96): under the rules sheet on the corridor face (Pivot (-0.44, 1.39), its foot ~1.25 m).
HOLE = {"c": (-0.071, 0.98), "rx": 0.2, "ry": 0.21}
# Room 407 (Room407 local = world - (30, 0, 0)).
VENT = {"wall": 7.9, "y": 2.35, "z": -1.0, "w": 0.68, "h": 0.48}
HATCH = {"x": 3.0, "z": -2.0, "ceil": 3.0, "size": 0.6}
# Ward.
WARD = {"x": 2.5, "z": 3.0, "h": 3.0, "inset": 0.004, "dado": 1.2}
BEDS = {"Bed_Trung": 0.0, "Bed_Nhat": -1.65, "Bed_Ngu": 1.65}


def part(name):
	return GP.GPart(name)


def build(p, sizes=None):
	GP.ensure_uv2(p)
	return GP.build(p, sizes or SIZES)


def export(name, parts):
	objs = [build(p) for p in parts if p.bm.faces]
	GP.export(OUT / name, objs)
	return objs


def B(p):
	return GP.B(p)


def planar(p, faces, fn):
	"""UV1 from fn(Godot point) -> image (u, v down)."""
	GP.set_uv(p, faces, fn)


def bevel_box(p, m, lo, hi, bevel=0.003):
	"""A box with bevelled edges (Godot lo..hi)."""
	a, b = B(lo), B(hi)
	return p.box(m, a, b, bevel=bevel, segments=1)


def rgrid(p, m, nx, nz, fn_pos, closed=False):
	"""A grid surface: fn_pos(i/nx, j/nz) -> Godot point. Returns faces."""
	verts = [[p.bm.verts.new(B(fn_pos(i / nx, j / nz))) for j in range(nz + 1)] for i in range(nx + 1)]
	faces = []
	idx = p.slot(m)
	for i in range(nx):
		for j in range(nz):
			f = p.bm.faces.new((verts[i][j], verts[i + 1][j], verts[i + 1][j + 1], verts[i][j + 1]))
			f.material_index = idx
			f.smooth = True
			faces.append(f)
	return faces, verts


def flip_up(p, faces):
	"""Make faces point Blender +Z (Godot +y) on average."""
	n = Vector()
	for f in faces:
		f.normal_update()
		n += f.normal
	if n.z < 0:
		for f in faces:
			f.normal_flip()


# ------------------------------------------------------------------------------------------------ slats

def under_uv(q):
	"""Bed 2's underside: u along the bed toward -z (the reader faces -x after the flip), v down from the far edge."""
	return ((SLAT["z"] - q[2]) / (2 * SLAT["z"]), (q[0] - SLAT["x0"]) / (SLAT["x1"] - SLAT["x0"]) * -1.0 + 1.0)


def build_slat_v1():
	w1kit.reset()
	p = part("SlatV1")
	s = SLAT
	faces = p.xbox("W1WoodPale", (s["x0"], s["top"] - s["board"], -s["z"]), (s["x1"], s["top"], s["z"]))
	under = faces["-y"]
	under.material_index = p.slot("W9SlatUnder")
	planar(p, [under], under_uv)
	# plywood edge: three plies seen as darker lines (a thin strip on each edge face)
	for side in ("-x", "+x", "-z", "+z"):
		faces[side].material_index = p.slot("W9RawWood")
	export("slat_v1_bed2.glb", [p])


def build_slat_v2(name="slat_v2_bed2.glb", slat_w=None):
	"""V2: nine slats on two battens; V2b (slat_w 0.145): the same nine as wide planks with 16 mm gaps (the words read)."""
	w1kit.reset()
	p = part("SlatV2")
	s = dict(SLAT)
	if slat_w:
		s["slat_w"] = slat_w
	pitch = 2 * s["z"] / s["slats"]
	unders = []
	for k in range(s["slats"]):
		z0 = -s["z"] + k * pitch + (pitch - s["slat_w"]) / 2
		rnd = random.Random(k)
		dy = rnd.uniform(-0.002, 0.002)
		f = p.xbox("W1WoodPale", (s["x0"], s["top"] - s["board"] + dy, z0), (s["x1"], s["top"] + dy, z0 + s["slat_w"]))
		f["-y"].material_index = p.slot("W9SlatUnder")
		unders.append(f["-y"])
		for side in ("-x", "+x"):
			f[side].material_index = p.slot("W9RawWood")
	for bx in s["battens"]:
		f = p.xbox("W1WoodPale", (bx, s["top"] - s["board"] - s["batten_h"], -s["z"] + 0.01),
			(bx + s["batten_w"], s["top"] - s["board"], s["z"] - 0.01))
		f["-y"].material_index = p.slot("W9SlatUnder")
		unders.append(f["-y"])
		# nail heads where the slats cross
		for k in range(s["slats"]):
			z = -s["z"] + k * pitch + pitch / 2
			p.xbox("W1Steel", (bx + 0.014, s["top"] - s["board"] - s["batten_h"] - 0.0015, z - 0.006),
				(bx + 0.026, s["top"] - s["board"] - s["batten_h"], z + 0.006))
	planar(p, unders, under_uv)
	export(name, [p])


# ------------------------------------------------------------------------------------------------ vent and hatch

def vent_part(name, askew=0.0):
	v = VENT
	p = part(name)
	x = v["wall"]
	w, h = v["w"], v["h"]
	y0, y1 = v["y"] - h / 2, v["y"] + h / 2
	z0, z1 = v["z"] - w / 2, v["z"] + w / 2
	# the sooted back (on the wall face, inside the frame) stays put when the grille hangs askew
	back = p.face("W9Soot", [(x - 0.002, y0 + 0.02, z0 + 0.02), (x - 0.002, y1 - 0.02, z0 + 0.02), (x - 0.002, y1 - 0.02, z1 - 0.02),
		(x - 0.002, y0 + 0.02, z1 - 0.02)], (-1, 0, 0))
	g = part(name + "Grille")
	t = 0.012   # flange
	d = 0.035   # frame depth off the wall
	# frame: four bars
	for lo, hi in (((x - d, y0, z0), (x - 0.003, y0 + 0.04, z1)), ((x - d, y1 - 0.04, z0), (x - 0.003, y1, z1)),
			((x - d, y0, z0), (x - 0.003, y1, z0 + 0.04)), ((x - d, y0, z1 - 0.04), (x - 0.003, y1, z1))):
		g.gbox("WRVent", lo, hi)
	# flange lip against the wall
	g.gbox("WRVent", (x - 0.006, y0 - t, z0 - t), (x - 0.003, y1 + t, z1 + t))
	# louvres (tilted 40 degrees, the dust on their tops)
	n = 8
	for k in range(n):
		yc = y0 + 0.06 + k * (h - 0.12) / (n - 1)
		a = math.radians(40)
		dx, dy = math.cos(a) * 0.022, math.sin(a) * 0.022
		g.face("WRVent", [(x - 0.02 - dx, yc - dy, z0 + 0.04), (x - 0.02 + dx, yc + dy, z0 + 0.04), (x - 0.02 + dx, yc + dy, z1 - 0.04),
			(x - 0.02 - dx, yc - dy, z1 - 0.04)], (-math.sin(a), math.cos(a), 0))
		g.face("WRVent", [(x - 0.02 - dx, yc - dy - 0.002, z0 + 0.04), (x - 0.02 + dx, yc + dy - 0.002, z0 + 0.04),
			(x - 0.02 + dx, yc + dy - 0.002, z1 - 0.04), (x - 0.02 - dx, yc - dy - 0.002, z1 - 0.04)], (math.sin(a), -math.cos(a), 0))
	# insect mesh behind the blades
	mesh = g.face("W9Screen", [(x - 0.006, y0 + 0.04, z0 + 0.04), (x - 0.006, y1 - 0.04, z0 + 0.04), (x - 0.006, y1 - 0.04, z1 - 0.04),
		(x - 0.006, y0 + 0.04, z1 - 0.04)], (-1, 0, 0))
	planar(g, [mesh], lambda q: ((q[2] - z0) / 0.25, (y1 - q[1]) / 0.25))
	# four screws
	for yy in (y0 + 0.02, y1 - 0.02):
		for zz in (z0 + 0.02, z1 - 0.02):
			g.gbox("W1Steel", (x - d - 0.004, yy - 0.006, zz - 0.006), (x - d, yy + 0.006, zz + 0.006))
	if askew:
		# hanging from the top-north screw: turned about the wall normal, pulled 3 cm off the wall at the bottom
		pivot = B((x - d, y1 - 0.02, z0 + 0.02))
		rot = Matrix.Translation(pivot) @ Matrix.Rotation(math.radians(askew), 4, Vector((1, 0, 0))) @ Matrix.Translation(-pivot)
		bmesh.ops.transform(g.bm, matrix=rot, verts=g.bm.verts)
	return [p, g]


def build_vent():
	w1kit.reset()
	export("vent.glb", vent_part("Vent"))
	w1kit.reset()
	export("vent_open.glb", vent_part("VentOpen", askew=-24.0))


def hatch_part(name, kind, open_deg=0.0):
	h = HATCH
	p = part(name)
	c = h["ceil"]
	s = h["size"] / 2
	x, z = h["x"], h["z"]
	# the void above (a dark plate just under the ceiling, only seen through the gap)
	p.face("W9Void", [(x - s, c - 0.003, z - s), (x + s, c - 0.003, z - s), (x + s, c - 0.003, z + s), (x - s, c - 0.003, z + s)], (0, -1, 0))
	f = 0.03
	m = "W1Alu" if kind == "h2" else "W9HatchPaint"
	for lo, hi in (((x - s - f, c - 0.012, z - s - f), (x + s + f, c - 0.004, z - s)), ((x - s - f, c - 0.012, z + s), (x + s + f, c - 0.004, z + s + f)),
			((x - s - f, c - 0.012, z - s), (x - s, c - 0.004, z + s)), ((x + s, c - 0.012, z - s), (x + s + f, c - 0.004, z + s))):
		p.gbox(m, lo, hi)
	leaf = part(name + "Leaf")
	if kind == "h1":
		leaf.gbox("W9HatchPaint", (x - s + 0.004, c - 0.018, z - s + 0.004), (x + s - 0.004, c - 0.006, z + s - 0.004))
		for zz in (z - 0.17, z + 0.17):  # cam locks
			leaf.pipe("W1Steel", [(x + s - 0.05, c - 0.018, zz), (x + s - 0.05, c - 0.024, zz)], 0.012, sides=10)
		# a rust tear from a lock, the paint's grime (painted on via the material's vertex position, nothing more here)
		hinge = (x - s + 0.004, c - 0.012)
	else:
		leaf.gbox("W9Gypsum", (x - s + 0.004, c - 0.016, z - s + 0.004), (x + s - 0.004, c - 0.006, z + s - 0.004))
		hinge = (x - s + 0.004, c - 0.012)
		open_deg = open_deg or 7.0
	if open_deg:
		pivot = B((hinge[0], hinge[1], z))
		rot = Matrix.Translation(pivot) @ Matrix.Rotation(math.radians(open_deg), 4, Vector((0, 1, 0))) @ Matrix.Translation(-pivot)
		bmesh.ops.transform(leaf.bm, matrix=rot, verts=leaf.bm.verts)
	return [p, leaf]


def build_hatch():
	w1kit.reset()
	export("hatch_h1.glb", hatch_part("HatchH1", "h1"))
	w1kit.reset()
	export("hatch_h1_open.glb", hatch_part("HatchH1Open", "h1", 28.0))
	w1kit.reset()
	export("hatch_h2.glb", hatch_part("HatchH2", "h2"))


# ------------------------------------------------------------------------------------------------ door

def hole_outline(seed=3, n=22):
	r = random.Random(seed)
	cx, cy = HOLE["c"]
	pts = []
	for i in range(n):
		a = i / n * math.tau
		k = r.uniform(0.62, 1.12) if i % 2 else r.uniform(0.85, 1.25)
		pts.append((cx + math.cos(a) * HOLE["rx"] * k, cy + math.sin(a) * HOLE["ry"] * k))
	return pts


def build_door_cracks():
	w1kit.reset()
	outer, inner = part("CracksOuter"), part("CracksInner")
	L = LEAF
	z = L["room"] - 0.0015
	xs = (L["x0"] + 0.004, HOLE["c"][0] - HOLE["rx"] * 1.3, HOLE["c"][0] + HOLE["rx"] * 1.3, L["x1"] - 0.004)
	ys = (0.004, HOLE["c"][1] - HOLE["ry"] * 1.3, HOLE["c"][1] + HOLE["ry"] * 1.3, L["h"] - 0.004)
	uv = lambda q: ((q[0] - L["x0"]) / (L["x1"] - L["x0"]), (L["h"] - q[1]) / L["h"])  # noqa: E731
	for i in range(3):
		for j in range(3):
			target = inner if (i, j) == (1, 1) else outer
			f = target.face("W9Cracks", [(xs[i], ys[j], z), (xs[i + 1], ys[j], z), (xs[i + 1], ys[j + 1], z), (xs[i], ys[j + 1], z)], (0, 0, -1))
			planar(target, [f], uv)
	export("door_cracks.glb", [outer, inner])


def import_door():
	before = set(bpy.data.objects)
	bpy.ops.import_scene.gltf(filepath=str(DOOR_GLB))
	made = [o for o in bpy.data.objects if o not in before and o.type == "MESH"]
	bpy.ops.object.select_all(action="DESELECT")
	for o in made:
		o.select_set(True)
	bpy.context.view_layer.objects.active = made[0]
	if len(made) > 1:
		bpy.ops.object.join()
	door = bpy.context.view_layer.objects.active
	door.parent = None
	bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
	for o in [o for o in bpy.data.objects if o.type == "EMPTY"]:
		bpy.data.objects.remove(o)
	door.name = "BrokenLeaf"
	# The glb splits every vertex (7,157 open edges): weld them so the leaf is one closed shell for the boolean (loop UVs stay).
	bm = bmesh.new()
	bm.from_mesh(door.data)
	bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0004)
	bm.to_mesh(door.data)
	print("T266_DOOR welded: %d faces, %d open edges" % (len(bm.faces), len([e for e in bm.edges if e.is_boundary])))
	bm.free()
	door.data.materials.clear()
	door.data.materials.append(w1kit.material("W9DoorRoom", (0.2, 0.4, 0.3), 0.6))
	for img in list(bpy.data.images):
		bpy.data.images.remove(img)
	return door


def build_door_broken():
	w1kit.reset()
	door = import_door()
	dec = door.modifiers.new("Decimate", "DECIMATE")
	dec.ratio = 0.3
	bpy.context.view_layer.objects.active = door
	bpy.ops.object.modifier_apply(modifier=dec.name)
	# the cutter: the jagged outline pushed through the leaf
	cut = part("Cutter")
	pts = hole_outline()
	ring_a = [cut.bm.verts.new(B((x, y, -0.06))) for x, y in pts]
	ring_b = [cut.bm.verts.new(B((x, y, 0.06))) for x, y in pts]
	n = len(pts)
	for i in range(n):
		j = (i + 1) % n
		cut.bm.faces.new((ring_a[i], ring_a[j], ring_b[j], ring_b[i]))
	cut.bm.faces.new(ring_a)
	cut.bm.faces.new(list(reversed(ring_b)))
	bmesh.ops.recalc_face_normals(cut.bm, faces=cut.bm.faces)
	cutter = cut.build()
	boolean = door.modifiers.new("Hole", "BOOLEAN")
	boolean.operation = "DIFFERENCE"
	boolean.solver = "EXACT"
	boolean.object = cutter
	boolean.material_mode = "TRANSFER"
	bpy.context.view_layer.objects.active = door
	bpy.ops.object.modifier_apply(modifier=boolean.name)
	bpy.data.objects.remove(cutter)
	# The cut's walls take the cutter's material (raw wood): faces whose normal is mostly in the leaf's plane, inside the hole's box.
	if "W9RawWood" not in [m.name for m in door.data.materials]:
		door.data.materials.append(w1kit.material("W9RawWood", (0.7, 0.58, 0.4), 0.85))
	raw = [m.name for m in door.data.materials].index("W9RawWood")
	cx, cy = HOLE["c"]
	for poly in door.data.polygons:
		c = poly.center
		gx, gy = c.x, c.z
		if abs(gx - cx) < HOLE["rx"] * 1.35 and abs(gy - cy) < HOLE["ry"] * 1.35 and abs(poly.normal.y) < 0.5:
			poly.material_index = raw
	inside = [p for p in door.data.polygons if ((p.center.x - cx) / (HOLE["rx"] * 0.55)) ** 2 + ((p.center.z - cy) / (HOLE["ry"] * 0.55)) ** 2 < 1]
	print("T266_DOOR faces left inside the hole: %d (of %d)" % (len(inside), len(door.data.polygons)))
	# splinters bent into the room round the rim (the leaf was punched from the corridor)
	sp = part("Splinters")
	r = random.Random(9)
	for i, (x, y) in enumerate(pts):
		if r.random() < 0.25:
			continue
		dx, dy = x - cx, y - cy
		d = math.hypot(dx, dy)
		ux, uy = dx / d, dy / d
		length = r.uniform(0.04, 0.11)
		width = r.uniform(0.01, 0.025)
		base_a = (x - uy * width / 2, y + ux * width / 2, LEAF["room"] + 0.004)
		base_b = (x + uy * width / 2, y - ux * width / 2, LEAF["room"] + 0.004)
		tip = (x - ux * length * 0.35, y - uy * length * 0.35 + r.uniform(-0.01, 0.01), LEAF["room"] - length * r.uniform(0.5, 0.9))
		back_a = (base_a[0], base_a[1], LEAF["room"] + 0.02)
		back_b = (base_b[0], base_b[1], LEAF["room"] + 0.02)
		sp.face("W9RawWood", [base_a, base_b, tip], None)
		sp.face("W9RawWood", [back_b, back_a, tip], None)
		sp.face("W9RawWood", [base_a, back_a, tip], None)
		sp.face("W9RawWood", [back_b, base_b, tip], None)
	bmesh.ops.recalc_face_normals(sp.bm, faces=sp.bm.faces)
	objs = [door, build(sp)]
	GP.export(OUT / "door_broken.glb", objs)


def build_zombie_hand():
	w1kit.reset()
	cx, cy = HOLE["c"]
	arm = part("Forearm")
	# forearm from the corridor (elbow at z +0.28) through the hole to the wrist in the room (z -0.24), dipping a little
	path = [(cx + 0.02, cy - 0.06, 0.3), (cx + 0.01, cy - 0.03, 0.12), (cx, cy, -0.05), (cx - 0.01, cy - 0.01, -0.2), (cx - 0.015, cy - 0.03, -0.25)]
	radii = [0.046, 0.043, 0.038, 0.032, 0.03]
	rings = []
	for (x, y, z), rad in zip(path, radii):
		ring = []
		for k in range(10):
			a = k / 10 * math.tau
			ring.append(arm.bm.verts.new(B((x + math.cos(a) * rad * 1.15, y + math.sin(a) * rad * 0.9, z))))
		rings.append(ring)
	sk = arm.slot("W9Skin")
	for a, b in zip(rings, rings[1:]):
		for k in range(10):
			f = arm.bm.faces.new((a[k], a[(k + 1) % 10], b[(k + 1) % 10], b[k]))
			f.material_index = sk
			f.smooth = True
	# hand: a flattened palm and four clawing fingers, a thumb
	hand = part("Hand")
	px, py, pz = cx - 0.015, cy - 0.035, -0.31
	palm = hand.box("W9Skin", B((px - 0.045, py - 0.016, pz - 0.05)), B((px + 0.045, py + 0.016, pz + 0.06)), bevel=0.012, segments=2)
	for f in palm:
		f.smooth = True
	r = random.Random(4)
	for k in range(4):
		x0 = px - 0.033 + k * 0.022
		pts = [(x0, py, pz - 0.05)]
		y, z = py, pz - 0.05
		for seg, ln in enumerate((0.045, 0.03, 0.022)):
			ang = math.radians(25 + seg * 30 + r.uniform(-8, 8))   # curling down
			z -= math.cos(ang) * ln
			y -= math.sin(ang) * ln
			pts.append((x0 + r.uniform(-0.004, 0.004), y, z))
		hand.pipe("W9Skin", pts, 0.0085, sides=6)
	hand.pipe("W9Skin", [(px + 0.045, py - 0.005, pz + 0.03), (px + 0.065, py - 0.015, pz - 0.0), (px + 0.07, py - 0.03, pz - 0.03)], 0.01, sides=6)
	# torn sleeve over the corridor half, ragged end just inside the hole
	sleeve = part("Sleeve")
	srings = []
	spath = [(cx + 0.02, cy - 0.06, 0.32), (cx + 0.01, cy - 0.03, 0.12), (cx + 0.004, cy - 0.01, 0.0)]
	for n, (x, y, z) in enumerate(spath):
		ring = []
		for k in range(12):
			a = k / 12 * math.tau
			rad = 0.062 + (r.uniform(-0.006, 0.01) if n == 2 else 0.0)
			zz = z - (r.uniform(0.0, 0.05) if n == 2 else 0.0)
			ring.append(sleeve.bm.verts.new(B((x + math.cos(a) * rad * 1.1, y + math.sin(a) * rad * 0.95, zz))))
		srings.append(ring)
	cl = sleeve.slot("CCClothGrey")
	for a, b in zip(srings, srings[1:]):
		for k in range(12):
			f = sleeve.bm.faces.new((a[k], a[(k + 1) % 12], b[(k + 1) % 12], b[k]))
			f.material_index = cl
			f.smooth = True
	export("zombie_hand.glb", [arm, hand, sleeve])


# ------------------------------------------------------------------------------------------------ ward

def build_ward_shell():
	w1kit.reset()
	W = WARD
	x, z, h, e = W["x"] - W["inset"], W["z"] - W["inset"], W["h"], W["dado"]
	floor = part("Floor")
	floor.face("W9WardFloor", [(-x, 0.0, -z), (x, 0.0, -z), (x, 0.0, z), (-x, 0.0, z)], (0, 1, 0))
	walls = part("Walls")
	# west, east, head (z -3): dado, wall above, skirting; the foot wall is its own glb (Y2's doorway)
	for (a, b, n) in (((-x, -z), (-x, z), (1, 0, 0)), ((x, z), (x, -z), (-1, 0, 0)), ((x, -z), (-x, -z), (0, 0, 1))):
		walls.face("W9WardDado", [(a[0], 0.0, a[1]), (b[0], 0.0, b[1]), (b[0], e, b[1]), (a[0], e, a[1])], n)
		walls.face("W9WardWall", [(a[0], e, a[1]), (b[0], e, b[1]), (b[0], h, b[1]), (a[0], h, a[1])], n)
		o = (n[0] * 0.012, 0, n[2] * 0.012)
		walls.face("W8Skirting", [(a[0] + o[0], 0.0, a[1] + o[2]), (b[0] + o[0], 0.0, b[1] + o[2]), (b[0] + o[0], 0.1, b[1] + o[2]),
			(a[0] + o[0], 0.1, a[1] + o[2])], n)
		walls.face("W8Skirting", [(a[0] + o[0], 0.1, a[1] + o[2]), (b[0] + o[0], 0.1, b[1] + o[2]), (b[0], 0.1, b[1]), (a[0], 0.1, a[1])], (0, 1, 0))
		walls.face("W9DadoLine", [(a[0] + o[0] * 0.3, e - 0.012, a[1] + o[2] * 0.3), (b[0] + o[0] * 0.3, e - 0.012, b[1] + o[2] * 0.3),
			(b[0] + o[0] * 0.3, e + 0.012, b[1] + o[2] * 0.3), (a[0] + o[0] * 0.3, e + 0.012, a[1] + o[2] * 0.3)], n)
	ceil = part("Ceiling")
	c = h - 0.005
	ceil.face("W9WardCeiling", [(-x, c, -z), (-x, c, z), (x, c, z), (x, c, -z)], (0, -1, 0))
	for k in range(-4, 5):
		ceil.gbox("W1Enamel", (k * 0.6 - 0.012, c - 0.012, -z), (k * 0.6 + 0.012, c - 0.001, z))
	for k in range(-5, 6):
		ceil.gbox("W1Enamel", (-x, c - 0.012, k * 0.6 - 0.012), (x, c - 0.001, k * 0.6 + 0.012))
	# the batten at CeilingLight (0, 2.8, 0) under the PS1 fixture's box (0, 2.88, 0)
	ceil.gbox("W1Enamel", (-0.6, 2.9, -0.07), (0.6, c - 0.012, 0.07))
	for dz in (-0.035, 0.035):
		ceil.pipe("W2Tube", [(-0.58, 2.885, dz), (0.58, 2.885, dz)], 0.013, sides=8)
	# window (east wall): aluminium frame, frosted glass lit by the day, bars
	win = part("Window")
	wx = x - 0.004
	z0, z1, y0, y1 = -1.55, 0.15, 1.05, 2.45
	win.face("W9WindowDay", [(wx, y0, z1), (wx, y0, z0), (wx, y1, z0), (wx, y1, z1)], (-1, 0, 0))
	for lo, hi in (((wx - 0.05, y0 - 0.05, z0 - 0.05), (wx, y0, z1 + 0.05)), ((wx - 0.05, y1, z0 - 0.05), (wx, y1 + 0.05, z1 + 0.05)),
			((wx - 0.05, y0, z0 - 0.05), (wx, y1, z0)), ((wx - 0.05, y0, z1), (wx, y1, z1 + 0.05)),
			((wx - 0.045, y0, (z0 + z1) / 2 - 0.02), (wx, y1, (z0 + z1) / 2 + 0.02))):
		win.gbox("W1Alu", lo, hi)
	win.gbox("W8Skirting", (wx - 0.16, y0 - 0.07, z0 - 0.08), (wx, y0 - 0.04, z1 + 0.08))
	for k in range(7):
		zz = z0 + 0.12 + k * (z1 - z0 - 0.24) / 6
		win.pipe("W1Iron", [(wx - 0.09, y0, zz), (wx - 0.09, y1, zz)], 0.008, sides=6)
	# monitor on its wall arm (out of the wake-up frame), cabinets behind the bed heads
	mon = part("Monitor")
	mon.gbox("W1Steel", (-0.04, 1.05, -2.996), (0.04, 1.11, -2.2))
	mon.gbox("W9Laminate", (-0.17, 1.06, -2.2), (0.17, 1.33, -2.08))
	scr = mon.face("W9MonitorScreen", [(-0.15, 1.08, -2.079), (0.15, 1.08, -2.079), (0.15, 1.31, -2.079), (-0.15, 1.31, -2.079)], (0, 0, 1))
	planar(mon, [scr], lambda q: ((q[0] + 0.15) / 0.3, (1.31 - q[1]) / 0.23))
	for bx in BEDS.values():
		mon.gbox("W9Cabinet", (bx - 0.25, 0.08, -2.4), (bx + 0.25, 0.84, -1.95))
		mon.gbox("W9Cabinet", (bx - 0.26, 0.84, -2.41), (bx + 0.26, 0.87, -1.94))
		mon.gbox("W1Iron", (bx - 0.24, 0.0, -2.38), (bx + 0.24, 0.08, -1.97))
		mon.gbox("W1Steel", (bx - 0.06, 0.6, -1.951), (bx + 0.06, 0.62, -1.94))
	export("ward_shell.glb", [floor, walls, ceil, win, mon])


def footwall_part(door):
	W = WARD
	x, z, h, e = W["x"] - W["inset"], W["z"] - W["inset"], W["h"], W["dado"]
	p = part("FootWall")
	spans = [(-x, x)] if not door else [(-x, 0.8), (1.7, x)]
	n = (0, 0, -1)
	for a, b in spans:
		p.face("W9WardDado", [(b, 0.0, z), (a, 0.0, z), (a, e, z), (b, e, z)], n)
		p.face("W9WardWall", [(b, e, z), (a, e, z), (a, h, z), (b, h, z)], n)
		p.face("W8Skirting", [(b, 0.0, z - 0.012), (a, 0.0, z - 0.012), (a, 0.1, z - 0.012), (b, 0.1, z - 0.012)], n)
		p.face("W9DadoLine", [(b, e - 0.012, z - 0.004), (a, e - 0.012, z - 0.004), (a, e + 0.012, z - 0.004), (b, e + 0.012, z - 0.004)], n)
	if not door:
		return [p]
	p.face("W9WardWall", [(1.7, 2.1, z), (0.8, 2.1, z), (0.8, h, z), (1.7, h, z)], n)
	# frame (painted steel), the leaf ajar 25 degrees into the room (hinge at x 1.7), a vision pane
	for lo, hi in (((0.75, 0.0, z - 0.03), (0.8, 2.15, z + 0.12)), ((1.7, 0.0, z - 0.03), (1.75, 2.15, z + 0.12)),
			((0.75, 2.1, z - 0.03), (1.75, 2.15, z + 0.12))):
		p.gbox("W1DoorPaint", lo, hi)
	leaf = part("Leaf")
	leaf.gbox("W1DoorPaint", (-0.88, 0.01, -0.02), (0.0, 2.08, 0.02))
	leaf.gbox("W2Glass", (-0.6, 1.3, -0.022), (-0.28, 1.75, 0.022))
	leaf.pipe("W6Stainless", [(-0.8, 1.0, -0.06), (-0.8, 1.0, -0.025)], 0.009)
	leaf.pipe("W6Stainless", [(-0.8, 1.0, -0.06), (-0.68, 1.0, -0.06)], 0.009)
	rot = Matrix.Translation(B((1.7, 0, z))) @ Matrix.Rotation(math.radians(-25), 4, Vector((0, 0, 1)))
	bmesh.ops.transform(leaf.bm, matrix=rot, verts=leaf.bm.verts)
	# the corridor beyond: a short box, its far wall faintly lit (no light: a dim emissive paint)
	cor = part("Corridor")
	cz0, cz1 = z + 0.12, z + 2.2
	cor.face("W9WardFloor", [(0.2, 0.0, cz0), (2.4, 0.0, cz0), (2.4, 0.0, cz1), (0.2, 0.0, cz1)], (0, 1, 0))
	cor.face("W9CorridorGlow", [(0.2, 0.0, cz1), (2.4, 0.0, cz1), (2.4, 2.8, cz1), (0.2, 2.8, cz1)], (0, 0, -1))
	cor.face("W9WardWall", [(0.2, 0.0, cz0), (0.2, 0.0, cz1), (0.2, 2.8, cz1), (0.2, 2.8, cz0)], (1, 0, 0))
	cor.face("W9WardWall", [(2.4, 0.0, cz1), (2.4, 0.0, cz0), (2.4, 2.8, cz0), (2.4, 2.8, cz1)], (-1, 0, 0))
	cor.face("W9WardCeiling", [(0.2, 2.8, cz0), (0.2, 2.8, cz1), (2.4, 2.8, cz1), (2.4, 2.8, cz0)], (0, -1, 0))
	return [p, leaf, cor]


def build_footwall():
	w1kit.reset()
	export("footwall.glb", footwall_part(False))
	w1kit.reset()
	export("footwall_door.glb", footwall_part(True))


def bed_part():
	p = part("Frame")
	r = 0.016
	for zz, top in ((-1.03, 1.0), (1.03, 0.8)):
		for xx in (-0.48, 0.48):
			p.pipe("W6Stainless", [(xx, 0.1, zz), (xx, top, zz)], r, sides=10)
		p.pipe("W6Stainless", [(-0.48, top, zz), (0.48, top, zz)], r, sides=10)
		p.gbox("W9Laminate", (-0.46, 0.5 if zz < 0 else 0.48, zz - 0.008), (0.46, top - 0.04, zz + 0.008))
	for xx in (-0.47, 0.47):
		p.gbox("W6Stainless", (xx - 0.02, 0.4, -1.03), (xx + 0.02, 0.45, 1.03))
	p.gbox("W1Steel", (-0.46, 0.44, -1.0), (0.46, 0.46, 1.0))
	for xx in (-0.48, 0.48):
		for zz in (-1.03, 1.03):
			p.pipe("W1Iron", [(xx, 0.1, zz), (xx, 0.035, zz)], 0.01, sides=6)
			p.pipe("W1Iron", [(xx - 0.02, 0.04, zz), (xx + 0.02, 0.04, zz)], 0.035, sides=10)
	# card clip on the foot rail under the Card marker (0, 0.88, 1.08): a flat clip holding the card from below
	p.gbox("W6Stainless", (-0.07, 0.79, 1.06), (0.07, 0.815, 1.09))
	mat = part("Mattress")
	bevel_box(mat, "W9Vinyl", (-0.45, 0.46, -0.98), (0.45, 0.59, 0.98), 0.03)
	sheet = part("Sheet")
	sheet.gbox("W9Sheet", (-0.465, 0.59, -0.985), (0.465, 0.605, 0.985))
	for xx in (-0.465, 0.465):
		sheet.face("W9Sheet", [(xx, 0.49, -0.985), (xx, 0.49, 0.985), (xx, 0.6, 0.985), (xx, 0.6, -0.985)], (math.copysign(1, xx), 0, 0))
	pil = part("Pillow")
	bevel_box(pil, "W9Sheet", (-0.3, 0.605, -0.96), (0.3, 0.72, -0.62), 0.05)
	return [p, mat, sheet, pil]


def build_ward_bed():
	w1kit.reset()
	export("ward_bed.glb", bed_part())
	# IV stand (at an IV_* node: pole, base on five castors, hook, bag)
	w1kit.reset()
	iv = part("IV")
	iv.pipe("W6Stainless", [(0, 0.08, 0), (0, 2.05, 0)], 0.011, sides=8)
	for k in range(5):
		a = k / 5 * math.tau
		iv.pipe("W6Stainless", [(0, 0.09, 0), (math.cos(a) * 0.28, 0.06, math.sin(a) * 0.28)], 0.011, sides=6)
		iv.pipe("W1Iron", [(math.cos(a) * 0.28, 0.035, math.sin(a) * 0.28 - 0.02), (math.cos(a) * 0.28, 0.035, math.sin(a) * 0.28 + 0.02)], 0.026, sides=8)
	iv.pipe("W6Stainless", [(-0.15, 2.05, 0), (0.15, 2.05, 0)], 0.008, sides=6)
	bag = part("Bag")
	bevel_box(bag, "W9IVBag", (0.06, 1.72, -0.025), (0.2, 1.98, 0.025), 0.02)
	bag.pipe("W9IVBag", [(0.13, 1.72, 0), (0.13, 1.6, 0)], 0.006, sides=6)
	export("iv.glb", [iv, bag])


def body_height(x, z, top):
	"""Height of a body lying on its back (head at -z) at (x, z) in bed space; top = the sheet's top. Soft bumps (the blanket
	hides the shape: no sharp feet)."""
	def bump(cx, cz, rx, rz, hh):
		d = ((x - cx) / rx) ** 2 + ((z - cz) / rz) ** 2
		return hh * math.exp(-1.6 * d)
	h = max(bump(0, -0.42, 0.24, 0.32, 0.16), bump(0, -0.08, 0.22, 0.2, 0.13))   # chest, belly and hips
	for side in (-1, 1):
		h = max(h, bump(side * 0.1, 0.38, 0.1, 0.42, 0.085))                  # legs
		h = max(h, bump(side * 0.1, 0.8, 0.12, 0.17, 0.075))                  # feet
	return top + h


def blanket(p, m, z0, z1, top, body=True, width=0.6, drop=0.2, nx=26, nz=36):
	def pos(u, v):
		x = -width + 2 * width * u
		z = z0 + (z1 - z0) * v
		edge = 0.47
		if abs(x) <= edge:
			y = body_height(x, z, top) + 0.02 if body else top + 0.02
			y += 0.008 * math.sin(z * 23 + x * 9)
		else:
			t = (abs(x) - edge) / (width - edge)
			y = top + 0.02 - drop * math.sin(t * math.pi / 2) ** 0.8
			x = math.copysign(edge + 0.02 + 0.015 * t, x)
		return (x, y, z)
	faces, _ = rgrid(p, m, nx, nz, pos)
	flip_up(p, faces)
	planar(p, faces, lambda q: (q[0] / 0.5, q[2] / 0.5))
	return faces


def build_patients():
	top = 0.605
	# T1: Trung's blanket over him, his bandaged left forearm (world +x) on it, the drip line to IV_Trung's bag
	w1kit.reset()
	t1 = part("BlanketT1")
	blanket(t1, "W9Blanket", -0.55, 0.98, top)
	arm = part("ArmT1")
	ax0 = (0.2, body_height(0.2, -0.2, top) + 0.05, -0.28)
	ax1 = (0.17, body_height(0.17, 0.05, top) + 0.045, 0.06)
	arm.pipe("W9Bandage", [ax0, ((ax0[0] + ax1[0]) / 2, (ax0[1] + ax1[1]) / 2 + 0.01, (ax0[2] + ax1[2]) / 2), ax1], 0.034, sides=10)
	bevel_box(arm, "W9SkinPatient", (ax1[0] - 0.035, ax1[1] - 0.02, ax1[2]), (ax1[0] + 0.035, ax1[1] + 0.01, ax1[2] + 0.1), 0.012)
	arm.gbox("W9IVBag", (ax0[0] - 0.02, ax0[1] + 0.03, ax0[2] + 0.12), (ax0[0] + 0.02, ax0[1] + 0.045, ax0[2] + 0.16))
	line = [(ax0[0], ax0[1] + 0.04, ax0[2] + 0.14), (0.32, 0.72, -0.3), (0.5, 0.95, -0.55), (0.63, 1.4, -0.6), (0.7, 1.6, -0.6)]
	arm.pipe("W9IVBag", line, 0.003, sides=5)
	export("patient_t1.glb", [t1, arm])
	w1kit.reset()
	t2 = part("BlanketT2")
	blanket(t2, "W9Blanket", -0.55, 0.98, top)
	export("patient_t2.glb", [t2])
	# a companion: blanket to the shoulders, the head on the pillow turned to the wall (no face), dark hair
	w1kit.reset()
	sb = part("BlanketSide")
	blanket(sb, "W9Blanket", -0.6, 0.98, top)
	head = part("Head")
	hd = head.box("W9Hair", B((-0.085, 0.68, -0.88)), B((0.085, 0.84, -0.66)), bevel=0.07, segments=3)
	for f in hd:
		f.smooth = True
	nk = head.box("W9SkinPatient", B((-0.06, 0.66, -0.7)), B((0.06, 0.76, -0.6)), bevel=0.04, segments=2)
	for f in nk:
		f.smooth = True
	export("patient_side.glb", [sb, head])
	# the lonely ending: a folded blanket on the flat sheet; or the mattress rolled at the head end (Mattress, Sheet hidden)
	w1kit.reset()
	fold = part("Folded")
	for k in range(3):
		bevel_box(fold, "W9Blanket", (-0.3, top + k * 0.025, 0.55), (0.3, top + 0.025 + k * 0.025, 0.9), 0.012)
	export("bed_empty.glb", [fold])
	w1kit.reset()
	roll = part("Rolled")
	roll.cylinder("W9Vinyl", B((0, 0.62, -0.75)), 0.16, 0.9, axis="X", segments=16)
	roll.cylinder("W9Sheet", B((0, 0.62, -0.75)), 0.165, 0.86, axis="X", segments=16)
	bevel_box(roll, "W9Blanket", (-0.3, 0.46, 0.55), (0.3, 0.52, 0.9), 0.012)
	export("bed_rolled.glb", [roll])


def build_curtain():
	w1kit.reset()
	track = part("Track")
	ty = 2.94
	pts = [(-1.12, ty, -1.25), (-1.12, ty, 1.5), (1.12, ty, 1.5), (1.12, ty, -1.25)]
	for a, b in zip(pts, pts[1:]):
		track.gbox("W1Alu", (min(a[0], b[0]) - 0.012, ty - 0.03, min(a[2], b[2]) - 0.012), (max(a[0], b[0]) + 0.012, ty, max(a[2], b[2]) + 0.012))
	for xx in (-1.12, 1.12):
		track.pipe("W1Alu", [(xx, ty, 1.5), (xx, 2.995, 1.5)], 0.006, sides=6)
	cur = part("Curtain")
	z = 1.5
	folds = 26
	def pos(u, v):
		x = 1.1 - 2.2 * u
		y = 0.38 + (2.9 - 0.38) * (1 - v)
		return (x, y, z + 0.04 * math.sin(u * folds * math.pi))
	faces, _ = rgrid(cur, "W9Curtain", 52, 6, pos)
	planar(cur, faces, lambda q: ((1.1 - q[0]) / 0.6, (2.9 - q[1]) / 0.6))
	# the mesh band at the top
	for f in faces:
		c = f.calc_center_median()
		if c.z > 2.45:
			f.material_index = cur.slot("W9CurtainNet")
	# the shadow layer: the same pleats 6 mm toward Trung, the two figures standing behind (x about +-0.62)
	sh = part("Shadow")
	def pos2(u, v):
		x = 1.1 - 2.2 * u
		y = 0.38 + (2.4 - 0.38) * (1 - v)
		return (x, y, z - 0.006 + 0.04 * math.sin(u * folds * math.pi))
	sfaces, _ = rgrid(sh, "W9Shadow", 52, 6, pos2)
	planar(sh, sfaces, lambda q: ((1.1 - q[0]) / 2.2, (2.4 - q[1]) / 2.02))
	for p in (cur, sh):
		for f in p.bm.faces:
			f.normal_update()
	export("curtain_y1.glb", [track, cur, sh])


BUILDS = {"slats": lambda: (build_slat_v1(), build_slat_v2(), build_slat_v2("slat_v2b_bed2.glb", 0.145)), "vent": build_vent, "hatch": build_hatch,
	"cracks": build_door_cracks, "door": build_door_broken, "hand": build_zombie_hand, "shell": build_ward_shell,
	"footwall": build_footwall, "bed": build_ward_bed, "patients": build_patients, "curtain": build_curtain}

if __name__ == "__main__":
	random.seed(266)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
