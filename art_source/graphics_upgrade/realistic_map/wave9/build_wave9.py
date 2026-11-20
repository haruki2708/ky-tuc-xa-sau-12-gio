"""T-266 round 2 (D-187): the wave-9 models that go into the game. Blender 5.2.2, bmesh only, no add-on, no Tripo (the broken
door is the game's own room door leaf, door_room.glb, cut and decimated by build_wave9_pilot.py). Godot coordinates in this
file (GP.B turns them into Blender's); each glb has its origin at the node it hangs on:

  Room 407 (V2b slats, D-187 point 1-2; chapter 4's Room407 branch)
  slat_bed1.glb / slat_bed2.glb  (Slat1/Hinge, Slat2/Hinge) nine 14.5 cm planks with 1.6 cm gaps nailed on two battens,
                        0.72 m wide, from 2 cm off the hinge toward the room; the underside (W9SlatUnder1 / 2) carries
                        that bed's scrap in bled marker ink, read facing -x once lifted
  slat_bed4.glb         (Slat4/Hinge) the same panel mirrored (bed 4's hinge is on the east wall), W9SlatUnder4, read facing +x
  Room 407 fixtures (C2, D-187 point 5: room_407.tscn's Wave9Fixtures, Room407 space, so in all four chapters)
  vent.glb              VentBack (the sooted duct mouth, fixed) and VentGrille: a louvred painted-steel grille with insect
                        mesh, its origin at its top-north screw so the searched feedback (D-187 point 4) turns it to hang
                        askew from that one screw
  hatch.glb             HatchFrame (frame and the dark void) and HatchLeaf (H1: a painted steel access panel, two cam locks),
                        the leaf's origin on its west hinge so the feedback drops it ajar
  Door 407 (D-187 point 6; glb origin = the room door leaf's own origin)
  door_cracks.glb, door_broken.glb   as round 1 (build_wave9_pilot.py cracks door)
  zombie_hand.glb       a forearm through the hole: the torn grey hoodie sleeve comes through into the room and frays, the
                        wrist and a clawing hand in mottled grey skin (cylindrical UVs), the upper arm rising on the corridor
                        side toward a shoulder at 1.3 m (a body pressed to the door)
  Ward (D-187 points 7-10; HospitalRoom space, bed pieces at a Bed_* node)
  ward_shell.glb, footwall.glb, iv.glb   as the round-1 pilot (approved look)
  ward_bed.glb          the stainless bed, vinyl mattress, sheet, pillow, and the card holder (D-187 point 11): a thin steel
                        frame round lane D's card at the Card marker, hooked over the foot rail, open both sides
  patient_t1.glb        (Bed_Trung/Patient) T1: the blanket over Trung's body and legs, his left forearm bandaged on it, the
                        hand, a taped cannula and the drip line to IV_Trung's bag
  patient_side.glb      (Bed_Nhat/Patient, Bed_Ngu/Patient) a body under the blanket, the head turned away, no face
  bed_empty.glb         (Bed_Nhat/Empty, Bed_Ngu/Empty) the lonely ending: the blanket folded at the foot of the flat sheet
  curtain_y1.glb        Y1: the ceiling track round Trung's bed, the curtain drawn across its foot (z 1.5) and the shadow
                        layer (W9Shadow: the two nurses standing behind it at Nurse1 / Nurse2, x -+0.72; no light added)
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave9/build_wave9.py [-- name ...]
"""
import math
from pathlib import Path
import random
import sys

import bmesh
import bpy  # noqa: F401  (Blender's own module; the pilot's helpers use it)
from mathutils import Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import build_wave9_pilot as P  # noqa: E402  (its main is guarded)

GP = P.GP
w1kit = P.w1kit
OUT = P.OUT
SIZES = dict(P.SIZES, W9Skin=0.22, W9Hoodie=0.5, W9SkinPatient=0.25)
P.GP.PREVIEW.update({"W9Hoodie": ((0.36, 0.36, 0.37), 0.95), "W9VentPaint": ((0.5, 0.49, 0.45), 0.6),
	"W9SlatUnder1": ((0.6, 0.5, 0.35), 0.85), "W9SlatUnder2": ((0.6, 0.5, 0.35), 0.85), "W9SlatUnder4": ((0.6, 0.5, 0.35), 0.85)})

# V2b (D-187 point 1): the pilot's V2 frame with nine 14.5 cm planks.
SLAT = dict(P.SLAT, slat_w=0.145)
# The vent grille hangs from its top-north screw (round 1 turned it the wrong way, against gravity).
VENT = P.VENT
VENT_DEPTH = 0.035
VENT_PIVOT = (VENT["wall"] - VENT_DEPTH, VENT["y"] + VENT["h"] / 2 - 0.02, VENT["z"] - VENT["w"] / 2 + 0.02)
HATCH = P.HATCH
HATCH_HINGE = (HATCH["x"] - HATCH["size"] / 2 + 0.004, HATCH["ceil"] - 0.012, HATCH["z"])
HOLE = P.HOLE
LEAF = P.LEAF
# The card marker on each Bed_* (hospital_room.tscn) and lane D's card size (bed_card.tscn).
CARD = {"c": (0.0, 0.88, 1.08), "w": 0.56, "h": 0.3}


def part(name):
	return GP.GPart(name)


def build_at(p, pivot=None):
	"""GP.build with the object's origin at `pivot` (Godot point), so a Godot node can turn it about that point."""
	GP.ensure_uv2(p)
	for name in p.slots:
		GP.mat(name)
	p.bm.normal_update()
	if pivot is None:
		return p.build(uv_size=SIZES)
	return p.build(origin=GP.B(pivot), uv_size=SIZES)


def export(name, objs):
	GP.export(OUT / name, objs)


# ------------------------------------------------------------------------------------------------ slats

def slat_uv(bed):
	"""The underside's UV: text up = away from the hinge (the edge that rises), read from the room. Beds 1 and 2 are read
	facing -x (their right is -z), bed 4 facing +x (its right is +z)."""
	s = SLAT
	if bed == 4:
		return lambda q: ((q[2] + s["z"]) / (2 * s["z"]), (q[0] + s["x1"]) / (s["x1"] - s["x0"]))
	return lambda q: ((s["z"] - q[2]) / (2 * s["z"]), 1.0 - (q[0] - s["x0"]) / (s["x1"] - s["x0"]))


def build_slat(bed):
	"""V2b for one bed: nine planks across the bed nailed on two battens, the hinge 2 cm off the panel's wall edge."""
	w1kit.reset()
	p = part("Slat%d" % bed)
	s = SLAT
	k = -1.0 if bed == 4 else 1.0
	under_mat = "W9SlatUnder%d" % bed

	def xs(a, b):
		return (min(a * k, b * k), max(a * k, b * k))

	pitch = 2 * s["z"] / s["slats"]
	unders = []
	for i in range(s["slats"]):
		z0 = -s["z"] + i * pitch + (pitch - s["slat_w"]) / 2
		dy = random.Random(i + 10 * bed).uniform(-0.002, 0.002)
		x0, x1 = xs(s["x0"], s["x1"])
		f = p.xbox("W1WoodPale", (x0, s["top"] - s["board"] + dy, z0), (x1, s["top"] + dy, z0 + s["slat_w"]))
		f["-y"].material_index = p.slot(under_mat)
		unders.append(f["-y"])
		for side in ("-x", "+x"):
			f[side].material_index = p.slot("W9RawWood")
	for bx in s["battens"]:
		x0, x1 = xs(bx, bx + s["batten_w"])
		f = p.xbox("W1WoodPale", (x0, s["top"] - s["board"] - s["batten_h"], -s["z"] + 0.01), (x1, s["top"] - s["board"], s["z"] - 0.01))
		f["-y"].material_index = p.slot(under_mat)
		unders.append(f["-y"])
		for i in range(s["slats"]):
			z = -s["z"] + i * pitch + pitch / 2
			n0, n1 = xs(bx + 0.014, bx + 0.026)
			p.xbox("W1Steel", (n0, s["top"] - s["board"] - s["batten_h"] - 0.0015, z - 0.006), (n1, s["top"] - s["board"] - s["batten_h"], z + 0.006))
	GP.set_uv(p, unders, slat_uv(bed))
	export("slat_bed%d.glb" % bed, [build_at(p)])


def build_slats():
	for bed in (1, 2, 4):
		build_slat(bed)


# ------------------------------------------------------------------------------------------------ vent and hatch (C2)

def build_vent():
	"""The pilot's grille in a darker, sooted paint, split from its back so the grille turns about its top-north screw."""
	w1kit.reset()
	back, grille = P.vent_part("Vent")
	back.name = "VentBack"
	grille.name = "VentGrille"
	for i, name in enumerate(grille.slots):
		if name == "WRVent":
			grille.slots[i] = "W9VentPaint"
	export("vent.glb", [build_at(back), build_at(grille, VENT_PIVOT)])


def build_hatch():
	w1kit.reset()
	frame, leaf = P.hatch_part("Hatch", "h1")
	frame.name = "HatchFrame"
	leaf.name = "HatchLeaf"
	export("hatch.glb", [build_at(frame), build_at(leaf, HATCH_HINGE)])


# ------------------------------------------------------------------------------------------------ the hand through the door

def ring_tube(p, m, path, radii, sides, u_wrap=1.0, v_scale=1.0, squash=(1.0, 1.0), jag=None, cap_end=True):
	"""A tube along `path` (Godot points) with cylindrical UVs (u round, v along, metres / v_scale). `jag(i, k)` adds a radial
	offset (torn edges); the start is open, the end capped when cap_end."""
	rings = []
	prev = None
	pts = [Vector(GP.B(q)) for q in path]
	for i, c in enumerate(pts):
		ahead = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
		side = ahead.cross(Vector((0, 0, 1)))
		if side.length < 1e-4:
			side = ahead.cross(Vector((1, 0, 0)))
		side.normalize()
		if prev is not None and side.dot(prev) < 0:
			side = -side
		prev = side
		up = side.cross(ahead).normalized()
		ring = []
		for k in range(sides):
			a = k / sides * math.tau
			r = radii[i] + (jag(i, k) if jag else 0.0)
			ring.append(p.bm.verts.new(c + side * math.cos(a) * r * squash[0] + up * math.sin(a) * r * squash[1]))
		rings.append(ring)
	idx = p.slot(m)
	faces = []
	run = 0.0
	vs = [0.0]
	for a, b in zip(pts, pts[1:]):
		run += (b - a).length
		vs.append(run)
	for i in range(len(rings) - 1):
		for k in range(sides):
			kk = (k + 1) % sides
			f = p.bm.faces.new((rings[i][k], rings[i][kk], rings[i + 1][kk], rings[i + 1][k]))
			f.material_index = idx
			f.smooth = True
			uvs = [(k / sides * u_wrap, vs[i] / v_scale), ((k + 1) / sides * u_wrap, vs[i] / v_scale),
				((k + 1) / sides * u_wrap, vs[i + 1] / v_scale), (k / sides * u_wrap, vs[i + 1] / v_scale)]
			for loop, t in zip(f.loops, uvs):
				loop[p.uv].uv = (t[0], 1.0 - t[1])
			f.tag = True
			faces.append(f)
	if cap_end:
		f = p.bm.faces.new(rings[-1])
		f.material_index = idx
		faces.append(f)
	return faces, rings


def build_zombie_hand():
	"""D-187 point 6, 80 %: the arm of a body pressed against the corridor face, through the hole (Door407 / leaf space, the
	leaf's room face at z -0.02). Round 1's arm stopped at the leaf in a pale sleeve: now the torn hoodie sleeve comes 9 cm into
	the room and frays round the wrist, the skin is mapped (mottled grey, dried blood), and on the corridor side the arm bends
	up to a shoulder at 1.3 m, inside the body of the zombie at the door."""
	w1kit.reset()
	cx, cy = HOLE["c"]
	rnd = random.Random(31)
	# shoulder (corridor, inside the body) -> elbow -> through the hole -> wrist in the room
	arm_path = [(cx + 0.09, 1.31, 0.40), (cx + 0.06, 1.12, 0.34), (cx + 0.035, cy - 0.06, 0.24), (cx + 0.015, cy - 0.025, 0.08),
		(cx, cy, -0.04), (cx - 0.01, cy - 0.012, -0.16), (cx - 0.016, cy - 0.03, -0.25)]
	arm_r = [0.05, 0.047, 0.044, 0.041, 0.037, 0.032, 0.029]
	arm = part("Forearm")
	ring_tube(arm, "W9Skin", arm_path, arm_r, 12, u_wrap=1.0, v_scale=0.5, squash=(1.12, 0.9))
	# sleeve: grey hoodie from the shoulder to just inside the room, its end torn into strips
	sleeve = part("Sleeve")
	sl_path = arm_path[:5] + [(cx - 0.004, cy - 0.006, -0.09)]
	sl_r = [r + 0.016 for r in arm_r[:5]] + [arm_r[4] + 0.012]

	def torn(i, k):
		if i == len(sl_path) - 1:
			return rnd.uniform(-0.008, 0.01)
		return rnd.uniform(-0.002, 0.004)

	faces, rings = ring_tube(sleeve, "W9Hoodie", sl_path, sl_r, 14, u_wrap=2.0, v_scale=0.4, squash=(1.1, 0.95), jag=torn, cap_end=False)
	# ragged strips hanging from the torn cuff (into the room, toward the floor)
	last = rings[-1]
	for k in range(0, 14, 3):
		a, b = last[k].co.copy(), last[(k + 1) % 14].co.copy()
		drop = Vector((0, 0, -rnd.uniform(0.03, 0.07)))
		fwd = Vector((0, rnd.uniform(0.01, 0.035), 0))  # Blender +y = Godot -z (into the room)
		tip = (a + b) / 2 + drop + fwd
		va, vb, vt = sleeve.bm.verts.new(a), sleeve.bm.verts.new(b), sleeve.bm.verts.new(tip)
		f = sleeve.bm.faces.new((va, vb, vt))
		f.material_index = sleeve.slot("W9Hoodie")
	# the hand: a palm turned down, four fingers clawing toward the floor, the thumb
	hand = part("Hand")
	px, py, pz = cx - 0.018, cy - 0.04, -0.3
	palm = hand.box("W9Skin", GP.B((px - 0.043, py - 0.017, pz - 0.05)), GP.B((px + 0.043, py + 0.015, pz + 0.055)), bevel=0.013, segments=2)
	for f in palm:
		f.smooth = True
	for k in range(4):
		x0 = px - 0.032 + k * 0.0215
		pts = [(x0, py, pz - 0.048)]
		y, z = py, pz - 0.048
		for seg, ln in enumerate((0.044 - abs(k - 1.5) * 0.004, 0.028, 0.02)):
			ang = math.radians(28 + seg * 32 + rnd.uniform(-8, 8))
			z -= math.cos(ang) * ln
			y -= math.sin(ang) * ln
			pts.append((x0 + rnd.uniform(-0.003, 0.003), y, z))
		ring_tube(hand, "W9Skin", pts, [0.0092, 0.0088, 0.008, 0.0068], 7, u_wrap=0.25, v_scale=0.15)
	ring_tube(hand, "W9Skin", [(px + 0.042, py - 0.004, pz + 0.035), (px + 0.062, py - 0.016, pz + 0.0), (px + 0.066, py - 0.03, pz - 0.03)],
		[0.012, 0.0105, 0.009], 7, u_wrap=0.25, v_scale=0.15)
	export("zombie_hand.glb", [build_at(arm), build_at(sleeve), build_at(hand)])


# ------------------------------------------------------------------------------------------------ ward

def build_ward_bed():
	"""The pilot's stainless bed with the card holder of D-187 point 11 (open both sides; lane D's card sits in it)."""
	w1kit.reset()
	frame, mattress, sheet, pillow = P.bed_part()
	holder = part("CardHolder")
	cx, cy, cz = CARD["c"]
	hw, hh = CARD["w"] / 2 + 0.012, CARD["h"] / 2 + 0.012
	t = 0.006
	bars = [((cx - hw, cy - hh, cz - t), (cx + hw, cy - hh + 0.014, cz + t)), ((cx - hw, cy + hh - 0.014, cz - t), (cx + hw, cy + hh, cz + t)),
		((cx - hw, cy - hh, cz - t), (cx - hw + 0.014, cy + hh, cz + t)), ((cx + hw - 0.014, cy - hh, cz - t), (cx + hw, cy + hh, cz + t))]
	for lo, hi in bars:
		holder.gbox("W6Stainless", lo, hi)
	# two J hooks from the frame's back over the foot rail (pipe at y 0.8, z 1.03, r 0.016)
	for hx in (-0.18, 0.18):
		holder.pipe("W6Stainless", [(hx, cy - hh + 0.02, cz - t), (hx, 0.84, cz - 0.02), (hx, 0.836, 1.03), (hx, 0.8, 1.005), (hx, 0.775, 1.007)], 0.004, sides=6)
	# small corner tabs that keep the card in (both faces)
	for sx in (-1, 1):
		for sy in (-1, 1):
			holder.gbox("W6Stainless", (cx + sx * (hw - 0.03) - 0.016, cy + sy * (hh - 0.02) - 0.01, cz - t - 0.002),
				(cx + sx * (hw - 0.03) + 0.016, cy + sy * (hh - 0.02) + 0.01, cz - t))
			holder.gbox("W6Stainless", (cx + sx * (hw - 0.03) - 0.016, cy + sy * (hh - 0.02) - 0.01, cz + t),
				(cx + sx * (hw - 0.03) + 0.016, cy + sy * (hh - 0.02) + 0.01, cz + t + 0.002))
	export("ward_bed.glb", [build_at(frame), build_at(mattress), build_at(sheet), build_at(pillow), build_at(holder)])


def build_patients():
	"""T1 (Trung), the companions under their blankets, and the lonely ending's folded blanket."""
	top = 0.605
	w1kit.reset()
	t1 = part("BlanketT1")
	P.blanket(t1, "W9Blanket", -0.55, 0.98, top)
	arm = part("ArmT1")
	# Trung's left forearm (world +x) lies on the blanket over his belly, bandaged from the elbow to the wrist
	ax0 = (0.21, P.body_height(0.21, -0.22, top) + 0.045, -0.24)
	ax1 = (0.17, P.body_height(0.17, 0.06, top) + 0.04, 0.07)
	mid = ((ax0[0] + ax1[0]) / 2, (ax0[1] + ax1[1]) / 2 + 0.012, (ax0[2] + ax1[2]) / 2)
	ring_tube(arm, "W9Bandage", [ax0, mid, ax1], [0.036, 0.035, 0.03], 12, u_wrap=1.0, v_scale=0.12, squash=(1.1, 0.85))
	hand = part("HandT1")
	wx, wy, wz = ax1
	palm = hand.box("W9SkinPatient", GP.B((wx - 0.038, wy - 0.022, wz + 0.005)), GP.B((wx + 0.036, wy + 0.008, wz + 0.1)), bevel=0.012, segments=2)
	for f in palm:
		f.smooth = True
	for k in range(4):
		x0 = wx - 0.027 + k * 0.018
		pts = [(x0, wy - 0.006, wz + 0.098), (x0 + 0.002, wy - 0.012, wz + 0.135), (x0 + 0.002, wy - 0.02, wz + 0.16)]
		ring_tube(hand, "W9SkinPatient", pts, [0.0085, 0.008, 0.007], 6, u_wrap=0.2, v_scale=0.1)
	ring_tube(hand, "W9SkinPatient", [(wx - 0.036, wy - 0.008, wz + 0.03), (wx - 0.052, wy - 0.016, wz + 0.065), (wx - 0.055, wy - 0.022, wz + 0.09)],
		[0.01, 0.009, 0.008], 6, u_wrap=0.2, v_scale=0.1)
	# the cannula on the back of the hand under a strip of tape, the line running off the bed to IV_Trung's bag (0.7, 1.6, -0.6)
	hand.gbox("W9Bandage", (wx - 0.022, wy + 0.008, wz + 0.035), (wx + 0.022, wy + 0.012, wz + 0.07))
	hand.pipe("W9IVBag", [(wx + 0.004, wy + 0.012, wz + 0.05), (wx + 0.03, wy + 0.016, wz + 0.02)], 0.0045, sides=6)
	line = [(wx + 0.03, wy + 0.016, wz + 0.02), (0.3, top + 0.16, -0.05), (0.42, top + 0.05, -0.32), (0.5, 0.8, -0.56),
		(0.62, 1.25, -0.62), (0.7, 1.6, -0.6)]
	hand.pipe("W9IVBag", line, 0.0028, sides=5)
	export("patient_t1.glb", [build_at(t1), build_at(arm), build_at(hand)])
	w1kit.reset()
	sb = part("BlanketSide")
	P.blanket(sb, "W9Blanket", -0.6, 0.98, top)
	head = part("Head")
	hd = head.box("W9Hair", GP.B((-0.085, 0.68, -0.88)), GP.B((0.085, 0.84, -0.66)), bevel=0.07, segments=3)
	for f in hd:
		f.smooth = True
	nk = head.box("W9SkinPatient", GP.B((-0.06, 0.66, -0.7)), GP.B((0.06, 0.76, -0.6)), bevel=0.04, segments=2)
	for f in nk:
		f.smooth = True
	export("patient_side.glb", [build_at(sb), build_at(head)])
	w1kit.reset()
	fold = part("Folded")
	for k in range(3):
		P.bevel_box(fold, "W9Blanket", (-0.3, top + k * 0.025, 0.55), (0.3, top + 0.025 + k * 0.025, 0.9), 0.012)
	export("bed_empty.glb", [build_at(fold)])


def build_iv():
	"""The pilot's drip stand (at an IV_* node): pole, five castors, the hook bar, the bag and its line."""
	w1kit.reset()
	iv = part("IV")
	iv.pipe("W6Stainless", [(0, 0.08, 0), (0, 2.05, 0)], 0.011, sides=8)
	for k in range(5):
		a = k / 5 * math.tau
		iv.pipe("W6Stainless", [(0, 0.09, 0), (math.cos(a) * 0.28, 0.06, math.sin(a) * 0.28)], 0.011, sides=6)
		iv.pipe("W1Iron", [(math.cos(a) * 0.28, 0.035, math.sin(a) * 0.28 - 0.02), (math.cos(a) * 0.28, 0.035, math.sin(a) * 0.28 + 0.02)], 0.026, sides=8)
	iv.pipe("W6Stainless", [(-0.15, 2.05, 0), (0.15, 2.05, 0)], 0.008, sides=6)
	bag = part("Bag")
	P.bevel_box(bag, "W9IVBag", (0.06, 1.72, -0.025), (0.2, 1.98, 0.025), 0.02)
	bag.pipe("W9IVBag", [(0.13, 1.72, 0), (0.13, 1.6, 0)], 0.006, sides=6)
	export("iv.glb", [build_at(iv), build_at(bag)])


def build_footwall():
	w1kit.reset()
	export("footwall.glb", [build_at(p) for p in P.footwall_part(False)])


BUILDS = {"slats": build_slats, "vent": build_vent, "hatch": build_hatch, "cracks": P.build_door_cracks, "door": P.build_door_broken,
	"hand": build_zombie_hand, "shell": P.build_ward_shell, "footwall": build_footwall, "bed": build_ward_bed, "iv": build_iv,
	"patients": build_patients, "curtain": P.build_curtain}

if __name__ == "__main__":
	random.seed(266)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
