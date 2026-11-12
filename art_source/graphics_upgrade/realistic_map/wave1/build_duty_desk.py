"""T-250 (D-166) wave 1, A01: the floor-4 duty desk and what is on and above it, built here (no Tripo).
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>

Writes to game/assets/models/graphics_pilot/realistic_map/wave1/:
  duty_desk.glb        Carcass   an old single-pedestal office desk, 1.5 x 0.64 x 0.8 m (inside the PS1
                                 desk's collision box), three pedestal drawers, a shallow right drawer
                       KeyDrawer the centre drawer on steel runners, its own node (origin: the bottom of its
                                 front, closed); it slides along Godot +Z by up to DRAWER_TRAVEL. The fire key
                                 lies on its bottom at Godot y 0.650 (KeyStem in building_b.tscn).
  duty_key.glb         the fire-stair key: a brass key on a split ring with a red tag (origin: its underside)
  duty_desk_items.glb  open duty logbook and pen, closed logbook, ink pad and stamp, enamel mug, pen pot, forms
  desk_phone.glb       an old ivory push-button desk phone, coiled handset cord (origin: underside centre)
  wall_clock.glb       a round wall clock stopped at 4:00 (CH3 clue): Case, Dial and three hands, each hand
                       its own node pivoting on the clock's axis (origin: the back, on the wall)
  pa_speaker.glb       the wall PA horn on its bracket (origin: the wall plate)
  notice_board.glb     a cork notice board in an aluminium frame with pinned papers (origin: the back)
Desk frame (Blender): x along the desk, -Y towards the corridor, the floor at z 0, the desk's centre at x=y=0.
"""
import math
import sys
from pathlib import Path

from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w1kit as kit  # noqa: E402

FRONT = -0.325  # the top's front edge (Godot z 0.745, the PS1 collision box)
BACK = 0.315  # 5 mm off the corridor wall (Godot z 0.105)
TOP_Z = 0.80
TOP_T = 0.028
UNDER = TOP_Z - TOP_T
FACE = -0.310  # carcass front
DRAWER_TRAVEL = 0.34
KEY_FLOOR = 0.650  # the drawer bottom the key lies on (Godot y)


def mats():
	kit.material("W1Wood", (0.42, 0.24, 0.13), 0.5)
	kit.material("W1WoodPale", (0.62, 0.5, 0.36), 0.7)
	kit.material("W1Steel", (0.55, 0.55, 0.53), 0.35, 1.0)
	kit.material("W1Brass", (0.78, 0.62, 0.32), 0.32, 1.0)
	kit.material("W1Black", (0.03, 0.03, 0.03), 0.6)
	kit.material("W1RedPlastic", (0.6, 0.05, 0.04), 0.45)
	kit.material("W1Paper", (0.9, 0.89, 0.84), 0.85)
	kit.material("W1Pencil", (0.85, 0.62, 0.08), 0.5)


def bar_pull(part, x, y, z, width=0.096, reach=0.022, radius=0.0042):
	"""A U-shaped steel bar handle on a front at plane y (fronts face -Y)."""
	h = width / 2
	part.tube("W1Steel", [(x - h, y + 0.002, z), (x - h, y - reach * 0.7, z), (x - h * 0.85, y - reach, z),
		(x + h * 0.85, y - reach, z), (x + h, y - reach * 0.7, z), (x + h, y + 0.002, z)], radius, 8)


def desk():
	carcass = kit.Part("Carcass")
	W = "W1Wood"
	# Top, with a darker edge band.
	carcass.box(W, (-0.75, FRONT, UNDER), (0.75, BACK, TOP_Z), bevel=0.003)
	# Pedestal (left): two sides, back, bottom, recessed plinth.
	px0, px1 = -0.735, -0.355
	for x0, x1 in ((px0, px0 + 0.018), (px1 - 0.018, px1)):
		carcass.box(W, (x0, FACE, 0.06), (x1, 0.300, UNDER), bevel=0.0015)
	carcass.box(W, (px0 + 0.018, 0.288, 0.078), (px1 - 0.018, 0.300, UNDER))
	carcass.box(W, (px0 + 0.018, FACE + 0.01, 0.06), (px1 - 0.018, 0.288, 0.078))
	carcass.box("W1Black", (px0 + 0.012, FACE + 0.045, 0.0), (px1 - 0.012, 0.285, 0.06))
	# Pedestal drawer fronts, graduated, 3 mm gaps, set 4 mm into the carcass.
	fx0, fx1 = px0 + 0.0205, px1 - 0.0205
	for z0, z1, keyhole in ((0.081, 0.383, False), (0.386, 0.611, False), (0.614, 0.769, True)):
		carcass.box(W, (fx0, FACE + 0.004, z0), (fx1, FACE + 0.022, z1), bevel=0.002)
		zc = min(z1 - 0.045, (z0 + z1) / 2)
		bar_pull(carcass, (fx0 + fx1) / 2, FACE + 0.004, zc)
		if keyhole:
			carcass.cylinder("W1Brass", ((fx0 + fx1) / 2, FACE + 0.003, zc + 0.032), 0.009, 0.002, axis="Y", segments=12)
			carcass.box("W1Black", ((fx0 + fx1) / 2 - 0.0012, FACE + 0.0015, zc + 0.026), ((fx0 + fx1) / 2 + 0.0012, FACE + 0.0025, zc + 0.036))
	# Right end panel (the desk's leg) and its foot rail.
	carcass.box(W, (0.715, FACE, 0.0), (0.735, 0.300, UNDER), bevel=0.0015)
	carcass.box("W1Black", (0.712, FACE + 0.02, 0.0), (0.738, FACE + 0.06, 0.008))
	carcass.box("W1Black", (0.712, 0.24, 0.0), (0.738, 0.28, 0.008))
	# Modesty panel at the back of the knee hole.
	carcass.box(W, (px1, 0.282, 0.30), (0.715, 0.300, UNDER))
	# Drawer housing: a bottom panel under the two top drawers, the divider between them.
	carcass.box(W, (px1, FACE + 0.006, 0.620), (0.715, 0.282, 0.632), bevel=0.001)
	carcass.box(W, (0.335, FACE + 0.006, 0.632), (0.347, 0.282, UNDER))
	# Steel runners (channel rails) either side of the key drawer, screwed to the pedestal and the divider.
	for x0, x1 in ((px1, px1 + 0.012), (0.323, 0.335)):
		carcass.box("W1Steel", (x0, FACE + 0.02, 0.684), (x1, 0.27, 0.686))
		carcass.box("W1Steel", (x0, FACE + 0.02, 0.704), (x1, 0.27, 0.706))
		carcass.box("W1Steel", ((x0 if x0 < 0 else x1 - 0.001), FACE + 0.02, 0.684), ((x0 + 0.001 if x0 < 0 else x1), 0.27, 0.706))
	# The shallow right drawer (does not open).
	carcass.box(W, (0.349, FACE + 0.004, 0.636), (0.713, FACE + 0.022, 0.768), bevel=0.002)
	bar_pull(carcass, 0.531, FACE + 0.004, 0.702)

	drawer = kit.Part("KeyDrawer")
	# Box: 12 mm sides, a 5 mm bottom whose top is KEY_FLOOR, behind an 18 mm front.
	dx0, dx1 = -0.343, 0.323
	dy0, dy1 = FACE + 0.016, 0.236
	drawer.box("W1WoodPale", (dx0, dy0, KEY_FLOOR - 0.005), (dx0 + 0.012, dy1, 0.725))
	drawer.box("W1WoodPale", (dx1 - 0.012, dy0, KEY_FLOOR - 0.005), (dx1, dy1, 0.725))
	drawer.box("W1WoodPale", (dx0 + 0.012, dy1 - 0.012, KEY_FLOOR - 0.005), (dx1 - 0.012, dy1, 0.715))
	drawer.box("W1WoodPale", (dx0 + 0.012, dy0, KEY_FLOOR - 0.005), (dx1 - 0.012, dy1 - 0.012, KEY_FLOOR))
	# Runner strips on the drawer sides ride between the carcass channels.
	for x0, x1 in ((dx0 - 0.010, dx0), (dx1, dx1 + 0.010)):
		drawer.box("W1Steel", (x0, dy0 + 0.01, 0.688), (x1, dy1 - 0.01, 0.702))
	# Front, handle, a small keyhole.
	drawer.box("W1Wood", (-0.352, FACE - 0.002, 0.636), (0.332, FACE + 0.016, 0.768), bevel=0.002)
	bar_pull(drawer, -0.010, FACE - 0.002, 0.702)
	drawer.cylinder("W1Brass", (0.12, FACE - 0.003, 0.730), 0.008, 0.002, axis="Y", segments=12)
	drawer.box("W1Black", (0.1188, FACE - 0.0045, 0.725), (0.1212, FACE - 0.0035, 0.734))
	# What lives in the drawer, clear of the key (centre x -0.2, y 0): forms, a pencil, a rubber.
	drawer.box("W1Paper", (0.05, -0.22, KEY_FLOOR), (0.26, 0.08, KEY_FLOOR + 0.008),
		matrix=Matrix.Translation((0.155, -0.07, 0)) @ Matrix.Rotation(0.06, 4, "Z") @ Matrix.Translation((-0.155, 0.07, 0)))
	drawer.cylinder("W1Pencil", (-0.02, -0.05, KEY_FLOOR + 0.0035), 0.0035, 0.17, axis="Y", segments=6)
	drawer.box("W1RedPlastic", (-0.09, 0.10, KEY_FLOOR), (-0.05, 0.12, KEY_FLOOR + 0.008))
	objs = [carcass.build(), drawer.build(origin=(-0.010, FACE - 0.002, 0.636))]
	kit.export(kit.OUT / "duty_desk.glb", objs)
	return objs


def flat_ring(part, mat_name, cx, cy, r_out, r_in, z0, z1, segments=20, squash=1.0):
	verts = []
	for k in range(segments):
		a = k / segments * math.tau
		for r in (r_out, r_in):
			for z in (z0, z1):
				verts.append((cx + math.cos(a) * r, cy + math.sin(a) * r * squash, z))
	faces = []
	for k in range(segments):
		m = (k + 1) % segments
		o0b, o0t, i0b, i0t = k * 4, k * 4 + 1, k * 4 + 2, k * 4 + 3
		o1b, o1t, i1b, i1t = m * 4, m * 4 + 1, m * 4 + 2, m * 4 + 3
		faces += [(o0t, o1t, i1t, i0t), (o0b, i0b, i1b, o1b), (o0b, o1b, o1t, o0t), (i0b, i0t, i1t, i1b)]
	return part.poly(mat_name, verts, faces)


def key():
	part = kit.Part("FireKey")
	t = 0.0024
	flat_ring(part, "W1Brass", -0.030, 0.0, 0.0135, 0.0042, 0.0, t, 24, 0.92)
	part.box("W1Brass", (-0.0175, -0.0062, 0.0), (-0.0115, 0.0062, t), bevel=0.0005)
	part.box("W1Brass", (-0.0115, -0.0036, 0.0), (0.036, 0.0010, t * 0.95), bevel=0.0003)
	# Bitting: teeth of different heights on the upper edge, a pointed tip.
	for i, h in enumerate((0.0030, 0.0018, 0.0034, 0.0022, 0.0028)):
		x0 = -0.008 + i * 0.0085
		part.box("W1Brass", (x0, 0.0010, 0.0), (x0 + 0.0062, 0.0010 + h, t * 0.95))
	part.poly("W1Brass", [(0.036, -0.0036, 0), (0.036, 0.0010, 0), (0.042, -0.0010, 0),
		(0.036, -0.0036, t * 0.95), (0.036, 0.0010, t * 0.95), (0.042, -0.0010, t * 0.95)],
		[(0, 2, 1), (3, 4, 5), (0, 1, 4, 3), (1, 2, 5, 4), (2, 0, 3, 5)])
	# Split ring through the bow, lying flat over it, and a red plastic tag.
	ring = [(-0.046 + math.cos(a) * 0.0115, math.sin(a) * 0.0115, t + 0.0012 - 0.0012 * math.cos(a))
		for a in [k / 24 * math.tau for k in range(25)]]
	part.tube("W1Steel", ring, 0.0009, 6, cap=False)
	tag = part.box("W1RedPlastic", (-0.112, -0.012, 0.0), (-0.058, 0.012, 0.0028), bevel=0.0012)
	flat_ring(part, "W1Steel", -0.064, 0.0, 0.0035, 0.0022, 0.0028, 0.0031, 10)
	objs = [part.build()]
	kit.export(kit.OUT / "duty_key.glb", objs)
	return objs


def open_book(part, cx, cy, yaw, width=0.42, depth=0.30, pages_mat="W1Pages"):
	"""Two page blocks bulging towards the spine; UVs across the two-page texture."""
	rot = Matrix.Translation((cx, cy, 0)) @ Matrix.Rotation(yaw, 4, "Z")
	n = 10
	verts = []
	faces = []
	half = width / 2
	for side in (-1, 1):
		base = len(verts)
		for i in range(n + 1):
			u = i / n  # 0 at the outer edge, 1 at the spine
			x = side * half * (1 - u)
			h = 0.006 + 0.014 * math.sin(u * math.pi * 0.5) ** 0.7 - 0.012 * u ** 6
			for y in (-depth / 2, depth / 2):
				verts.append((rot @ Vector((x, y, h))).to_tuple())
		for i in range(n):
			a = base + i * 2
			faces.append((a, a + 2, a + 3, a + 1) if side < 0 else (a, a + 1, a + 3, a + 2))
	made = part.poly(pages_mat, verts, faces, smooth=True, recalc=False)
	inv = rot.inverted()
	for f in made:
		for loop in f.loops:
			p = inv @ loop.vert.co
			loop[part.uv].uv = (0.5 + p.x / width, 0.5 + p.y / depth)
		f.tag = True
	# Page edges and the cover under them.
	part.box("W1PageEdge", (-half, -depth / 2, 0.003), (half, depth / 2, 0.006), matrix=rot)
	part.box("W1LedgerSpine", (-half - 0.006, -depth / 2 - 0.006, 0.0), (half + 0.006, depth / 2 + 0.006, 0.003), bevel=0.001, matrix=rot)


def items():
	part = kit.Part("DeskItems")
	kit.material("W1Pages", (0.9, 0.88, 0.8), 0.85)
	kit.material("W1PageEdge", (0.86, 0.83, 0.74), 0.9)
	kit.material("W1Ledger", (0.1, 0.18, 0.28), 0.8)
	kit.material("W1LedgerSpine", (0.32, 0.07, 0.06), 0.75)
	kit.material("W1Enamel", (0.88, 0.88, 0.84), 0.25)
	kit.material("W1EnamelBlue", (0.08, 0.16, 0.42), 0.3)
	kit.material("W1PenBlue", (0.1, 0.2, 0.6), 0.4)
	kit.material("W1Plastic", (0.12, 0.3, 0.42), 0.5)
	kit.material("W1Rubber", (0.12, 0.1, 0.1), 0.8)
	# Open duty logbook in front of the chair space, its pen on the right page.
	open_book(part, -0.15, -0.04, math.radians(4))
	pen = Matrix.Translation((-0.03, -0.06, 0.023)) @ Matrix.Rotation(math.radians(70), 4, "Z")
	part.cylinder("W1Paper", (0, 0, 0), 0.0042, 0.13, axis="X", segments=8, matrix=pen)
	part.cylinder("W1PenBlue", (0.072, 0, 0), 0.0045, 0.045, axis="X", segments=8, matrix=pen)
	part.box("W1PenBlue", (0.06, 0.003, -0.001), (0.09, 0.006, 0.001), matrix=pen)
	# Closed logbook (older volume) at the right end, under the phone's cord side.
	closed = Matrix.Translation((0.63, 0.02, 0.0)) @ Matrix.Rotation(math.radians(-6), 4, "Z")
	part.box("W1PageEdge", (-0.094, -0.146, 0.0025), (0.096, 0.146, 0.0235), matrix=closed)
	cover = part.box("W1Ledger", (-0.100, -0.150, 0.0235), (0.100, 0.150, 0.0260), bevel=0.0008, matrix=closed)
	tops = [f for f in cover if f.normal.z > 0.9]
	part.planar_uv(tops, (closed @ Vector((-0.100, -0.150, 0.026))).to_tuple(), (closed.to_3x3() @ Vector((1, 0, 0))).to_tuple(),
		(closed.to_3x3() @ Vector((0, 1, 0))).to_tuple(), size=(0.200, 0.300))
	part.box("W1Ledger", (-0.100, -0.150, 0.0), (0.100, 0.150, 0.0025), bevel=0.0008, matrix=closed)
	part.box("W1LedgerSpine", (-0.106, -0.150, 0.0), (-0.094, 0.150, 0.026), bevel=0.004, matrix=closed)
	# Ink pad tin and a wooden stamp.
	pad = Matrix.Translation((0.06, -0.20, 0.0)) @ Matrix.Rotation(math.radians(12), 4, "Z")
	part.box("W1Steel", (-0.045, -0.032, 0.0), (0.045, 0.032, 0.012), bevel=0.003, matrix=pad)
	part.box("W1RedPlastic", (-0.043, -0.030, 0.012), (0.043, 0.030, 0.013), matrix=pad)
	stamp = Matrix.Translation((0.15, -0.17, 0.0))
	part.box("W1Rubber", (-0.022, -0.012, 0.0), (0.022, 0.012, 0.006), matrix=stamp)
	part.box("W1WoodPale", (-0.024, -0.014, 0.006), (0.024, 0.014, 0.016), bevel=0.002, matrix=stamp)
	part.lathe("W1WoodPale", [(0.006, 0.016), (0.008, 0.03), (0.006, 0.05), (0.013, 0.062), (0.012, 0.075), (0.004, 0.078)], 12, stamp)
	# White enamel mug with a blue rim and a few chips.
	mug = Matrix.Translation((0.20, 0.17, 0.0))
	part.lathe("W1Enamel", [(0.034, 0.0), (0.040, 0.004), (0.040, 0.080), (0.037, 0.082), (0.035, 0.010), (0.001, 0.010)], 24, mug)
	part.lathe("W1EnamelBlue", [(0.0405, 0.078), (0.0412, 0.083), (0.0395, 0.0865), (0.0368, 0.0832)], 24, mug, close_ends=False)
	part.tube("W1Enamel", [mug @ Vector(p) for p in ((0.038, 0, 0.068), (0.058, 0, 0.066), (0.064, 0, 0.045), (0.058, 0, 0.024), (0.038, 0, 0.020))], 0.0045, 8)
	for a, z in ((0.6, 0.03), (2.4, 0.055), (4.0, 0.012)):
		chip = mug @ Matrix.Rotation(a, 4, "Z") @ Matrix.Translation((0.0402, 0, z))
		part.cylinder("W1Black", (0, 0, 0), 0.003, 0.0012, axis="X", segments=6, matrix=chip)
	# Pen pot (a cut plastic bottle) with pens and a ruler, back left.
	pot = Matrix.Translation((-0.66, 0.20, 0.0))
	part.lathe("W1Plastic", [(0.030, 0.0), (0.033, 0.004), (0.033, 0.095), (0.031, 0.095), (0.031, 0.006), (0.001, 0.006)], 16, pot)
	for i, (dx, dy, tilt, length, m) in enumerate(((0.008, 0.004, 0.18, 0.14, "W1PenBlue"), (-0.01, 0.006, -0.12, 0.15, "W1Paper"),
			(0.0, -0.012, 0.08, 0.13, "W1RedPlastic"), (-0.006, -0.004, -0.2, 0.16, "W1Pencil"))):
		pen = pot @ Matrix.Translation((dx, dy, 0.006 + length / 2)) @ Matrix.Rotation(tilt, 4, "X" if i % 2 else "Y")
		part.cylinder(m, (0, 0, 0), 0.004, length, segments=6, matrix=pen)
	part.box("W1Steel", (-0.016, 0.008, 0.006), (0.016, 0.0095, 0.21), matrix=pot @ Matrix.Rotation(-0.15, 4, "Y"))
	# Loose forms at the back.
	forms = Matrix.Translation((0.02, 0.19, 0.0)) @ Matrix.Rotation(math.radians(9), 4, "Z")
	part.box("W1Paper", (-0.105, -0.075, 0.0), (0.105, 0.075, 0.003), matrix=forms)
	part.box("W1Paper", (-0.105, -0.075, 0.003), (0.105, 0.075, 0.004), matrix=forms @ Matrix.Rotation(math.radians(-7), 4, "Z"))
	objs = [part.build()]
	kit.export(kit.OUT / "duty_desk_items.glb", objs)
	return objs


def phone():
	part = kit.Part("DeskPhone")
	kit.material("W1PhoneIvory", (0.78, 0.74, 0.62), 0.42)
	kit.material("W1PhoneKey", (0.86, 0.85, 0.80), 0.5)
	kit.material("W1Cord", (0.72, 0.68, 0.56), 0.55)
	# Body: a wedge 0.20 x 0.22, 0.045 high at the front rising to 0.075, rounded.
	sections = []
	for y, h in ((-0.11, 0.040), (-0.03, 0.052), (0.05, 0.070), (0.11, 0.072)):
		sections.append((y, h))
	verts = []
	faces = []
	ring_n = 12
	for y, h in sections:
		for k in range(ring_n):
			a = k / ring_n * math.tau
			# A rounded rectangle cross-section 0.20 wide x h high.
			x = 0.1 * max(-1, min(1, math.cos(a) * 1.25))
			z = h / 2 + (h / 2) * max(-1, min(1, math.sin(a) * 1.3))
			verts.append((x, y, z))
	for s in range(len(sections) - 1):
		for k in range(ring_n):
			m = (k + 1) % ring_n
			a, b = s * ring_n, (s + 1) * ring_n
			faces.append((a + k, b + k, b + m, a + m))
	faces.append(tuple(range(ring_n)))
	last = (len(sections) - 1) * ring_n
	faces.append(tuple(last + k for k in range(ring_n - 1, -1, -1)))
	part.poly("W1PhoneIvory", verts, faces, smooth=True)
	# Cradle: two raised forks at the back carrying the handset.
	for x in (-0.07, 0.07):
		part.box("W1PhoneIvory", (x - 0.022, 0.035, 0.068), (x + 0.022, 0.095, 0.085), bevel=0.006, segments=2)
	# Keypad: 4 x 3 keys on the sloped front.
	slope = math.atan2(0.052 - 0.040, 0.08)
	for r in range(4):
		for c in range(3):
			x = (c - 1) * 0.026
			y = -0.085 + r * 0.019
			z = 0.040 + (y + 0.11) * math.tan(slope) + 0.004
			part.box("W1PhoneKey", (x - 0.009, y - 0.0065, z - 0.002), (x + 0.009, y + 0.0065, z + 0.0035), bevel=0.0015,
				matrix=Matrix.Translation((x, y, z)) @ Matrix.Rotation(-slope, 4, "X") @ Matrix.Translation((-x, -y, -z)))
	# Handset across the cradle: grip with ear and mouth cups.
	hs = Matrix.Translation((0.0, 0.066, 0.098))
	part.box("W1PhoneIvory", (-0.075, -0.016, -0.011), (0.075, 0.016, 0.009), bevel=0.008, segments=2, matrix=hs)
	for x in (-0.088, 0.088):
		part.lathe("W1PhoneIvory", [(0.026, -0.016), (0.03, -0.006), (0.024, 0.006), (0.012, 0.008)], 16,
			hs @ Matrix.Translation((x, 0, -0.004)))
	# Coiled cord from the handset's left end down to the body's side.
	coil = []
	turns = 26
	for i in range(turns * 8 + 1):
		t = i / (turns * 8)
		a = t * turns * math.tau
		cx = -0.105 - 0.03 * math.sin(t * math.pi)
		cy = 0.066 - t * 0.12
		cz = 0.09 - t * 0.075 + 0.02 * math.sin(t * math.pi)
		coil.append((cx + math.cos(a) * 0.0055, cy, cz + math.sin(a) * 0.0055))
	part.tube("W1Cord", coil, 0.0015, 5)
	# Line cord out of the back towards the wall.
	part.tube("W1Black", [(0.06, 0.11, 0.02), (0.06, 0.15, 0.006), (0.09, 0.2, 0.002), (0.16, 0.235, 0.002)], 0.002, 5)
	objs = [part.build()]
	kit.export(kit.OUT / "desk_phone.glb", objs)
	return objs


def clock():
	kit.material("W1ClockCase", (0.82, 0.8, 0.72), 0.4)
	kit.material("W1ClockDial", (0.92, 0.91, 0.85), 0.6)
	kit.material("W1ClockHand", (0.03, 0.03, 0.035), 0.4, 0.3)
	kit.material("W1ClockSecond", (0.6, 0.06, 0.04), 0.4)
	face = Matrix.Rotation(math.pi / 2, 4, "X")  # local +Z (the clock's axis) to Blender -Y
	case = kit.Part("Case")
	case.lathe("W1ClockCase", [(0.168, 0.0), (0.180, 0.004), (0.185, 0.020), (0.183, 0.038), (0.175, 0.047),
		(0.165, 0.047), (0.161, 0.040), (0.160, 0.030)], 48, face)
	dial = kit.Part("Dial")
	disc = dial.cylinder("W1ClockDial", (0, 0, 0.0305), 0.160, 0.001, segments=48, matrix=face)
	front = [f for f in disc if f.normal.y < -0.9]
	dial.planar_uv(front, (-0.160, -0.031, -0.160), (1, 0, 0), (0, 0, 1), size=(0.32, 0.32))
	# A thin glass ring catching light at the bezel (no glass sheet: it would hide the hands at night).
	hands = []
	for name, mat_name, length, width, tail, depth, angle in (("HourHand", "W1ClockHand", 0.088, 0.011, 0.022, 0.0335, 120.0),
			("MinuteHand", "W1ClockHand", 0.135, 0.008, 0.026, 0.0350, 0.0),
			("SecondHand", "W1ClockSecond", 0.142, 0.0024, 0.04, 0.0365, 222.0)):
		hand = kit.Part(name)
		t = 0.0012
		w = width / 2
		pts = [(-w * 0.8, -tail), (w * 0.8, -tail), (w, 0.0), (w * 0.55, length * 0.92), (0.0, length), (-w * 0.55, length * 0.92), (-w, 0.0)]
		verts = [(x, -depth, z) for x, z in pts] + [(x, -depth - t, z) for x, z in pts]
		n = len(pts)
		faces = [tuple(range(n)), tuple(range(2 * n - 1, n - 1, -1))]
		faces += [(k, (k + 1) % n, n + (k + 1) % n, n + k) for k in range(n)]
		hand.poly(mat_name, verts, faces)
		hand.cylinder(mat_name, (0, -depth - t / 2, 0), 0.007 if name != "SecondHand" else 0.0045, t * 1.5, axis="Y", segments=12)
		obj = hand.build()
		obj.rotation_euler = (0.0, math.radians(angle), 0.0)
		hands.append(obj)
	objs = [case.build(), dial.build()] + hands
	kit.export(kit.OUT / "wall_clock.glb", objs)
	return objs


def speaker():
	kit.material("W1SpeakerPaint", (0.72, 0.72, 0.68), 0.5)
	kit.material("W1Iron", (0.18, 0.18, 0.17), 0.55, 0.6)
	kit.material("W1SpeakerInner", (0.08, 0.08, 0.08), 0.8)
	part = kit.Part("Speaker")
	# Wall plate and arm.
	part.box("W1Iron", (-0.045, -0.006, -0.075), (0.045, 0.0, 0.075), bevel=0.002)
	for z in (-0.055, 0.055):
		part.cylinder("W1Steel", (0, -0.008, z), 0.006, 0.006, axis="Y", segments=8)
	part.box("W1Iron", (-0.012, -0.11, -0.012), (0.012, -0.006, 0.012), bevel=0.002)
	# Yoke around the driver, pivot bolts on both sides; the horn tips 16 degrees down.
	tilt = Matrix.Translation((0, -0.12, 0)) @ Matrix.Rotation(math.radians(16), 4, "X")
	part.box("W1Iron", (-0.072, -0.012, -0.010), (0.072, 0.0, 0.010), matrix=Matrix.Translation((0, -0.11, 0)))
	for x in (-0.068, 0.068):
		part.box("W1Iron", (x - 0.004, -0.06, -0.012), (x + 0.004, 0.0, 0.012), matrix=Matrix.Translation((0, -0.11, 0)))
		part.cylinder("W1Steel", (x * 1.06, 0, 0), 0.008, 0.01, axis="X", segments=10, matrix=tilt)
	axis = tilt @ Matrix.Rotation(math.pi / 2, 4, "X")  # local +Z of the lathe points out along the horn
	# Driver: a can behind the throat with a back cap.
	part.lathe("W1SpeakerPaint", [(0.045, -0.035), (0.055, -0.025), (0.058, 0.05), (0.03, 0.065)], 24, axis)
	# Horn: thin flared skin with a rolled lip, dark inside.
	outer = []
	inner = []
	length = 0.30
	for i in range(13):
		t = i / 12
		r = 0.03 + 0.11 * t ** 2.2
		z = 0.065 + t * length
		outer.append((r + 0.002, z))
		inner.append((r, z))
	part.lathe("W1SpeakerPaint", outer, 32, axis, close_ends=False)
	inner_faces = part.lathe("W1SpeakerInner", list(reversed(inner)), 32, axis, close_ends=False)
	part.lathe("W1SpeakerPaint", [(0.142, 0.065 + length), (0.147, 0.065 + length + 0.004), (0.145, 0.065 + length + 0.008),
		(0.140, 0.065 + length + 0.002)], 32, axis, close_ends=False)
	# Cable from the driver back to the wall and up to the ceiling (about 0.45 m over the plate).
	part.tube("W1Black", [(0.0, -0.10, 0.045), (0.0, -0.06, 0.09), (0.0, -0.012, 0.14), (0.0, -0.006, 0.2), (0.0, -0.006, 0.47)], 0.003, 6)
	objs = [part.build()]
	kit.export(kit.OUT / "pa_speaker.glb", objs)
	return objs


def board():
	kit.material("W1Cork", (0.55, 0.38, 0.22), 0.85)
	kit.material("W1Alu", (0.7, 0.7, 0.68), 0.35, 1.0)
	kit.material("W1Notices", (0.9, 0.9, 0.86), 0.85)
	kit.material("W1PinRed", (0.7, 0.08, 0.06), 0.35)
	kit.material("W1PinBlue", (0.1, 0.25, 0.65), 0.35)
	part = kit.Part("NoticeBoard")
	w, h = 0.90, 1.20
	depth = 0.022
	# Backing board and cork face.
	part.box("W1WoodPale", (-w / 2, -0.012, -h / 2), (w / 2, 0.0, h / 2))
	cork = part.box("W1Cork", (-w / 2 + 0.02, -depth + 0.004, -h / 2 + 0.02), (w / 2 - 0.02, -0.012, h / 2 - 0.02))
	# Aluminium frame: four mitred-looking bars with a rounded lip.
	for lo, hi in (((-w / 2, -depth, h / 2 - 0.024), (w / 2, 0.0, h / 2)), ((-w / 2, -depth, -h / 2), (w / 2, 0.0, -h / 2 + 0.024)),
			((-w / 2, -depth, -h / 2), (-w / 2 + 0.024, 0.0, h / 2)), ((w / 2 - 0.024, -depth, -h / 2), (w / 2, 0.0, h / 2))):
		part.box("W1Alu", lo, hi, bevel=0.004, segments=2)
	# Papers pinned on the cork (UV islands = the boxes in make_wave1_textures.notices; 2048 x 1024 atlas).
	sheets = [  # (atlas box px, centre x, centre z, width m, tilt deg)
		((0, 0, 680, 1000), -0.19, 0.18, 0.297, -2.0),
		((690, 0, 1370, 1000), 0.17, 0.12, 0.297, 1.5),
		((1380, 0, 1880, 700), -0.12, -0.33, 0.21, 3.0),
		((1380, 710, 1880, 1020), 0.24, -0.30, 0.16, -4.0),
	]
	yf = -depth + 0.0035
	for (x0, y0, x1, y1), cx, cz, sw, tilt in sheets:
		sh = sw * (y1 - y0) / (x1 - x0)
		m = Matrix.Translation((cx, 0, cz)) @ Matrix.Rotation(math.radians(tilt), 4, "Y")
		faces = part.box("W1Notices", (-sw / 2, yf - 0.0006, -sh / 2), (sw / 2, yf, sh / 2), matrix=m)
		front = [f for f in faces if f.normal.y < -0.9]
		corner = m @ Vector((-sw / 2, yf - 0.0006, -sh / 2))
		part.planar_uv(front, corner.to_tuple(), (m.to_3x3() @ Vector((1, 0, 0))).to_tuple(), (m.to_3x3() @ Vector((0, 0, 1))).to_tuple(),
			u_range=(x0 / 2048, x1 / 2048), v_range=(1 - y1 / 1024, 1 - y0 / 1024), size=(sw, sh))
		for i, (px, pz) in enumerate(((0, sh / 2 - 0.015), (-sw / 2 + 0.015, sh / 2 - 0.02), (sw / 2 - 0.015, sh / 2 - 0.02))[: 1 if sw < 0.2 else 3]):
			p = m @ Vector((px, yf - 0.0006, pz))
			pin = "W1PinRed" if (i + int(cx * 10)) % 2 else "W1PinBlue"
			part.cylinder(pin, (p.x, p.y - 0.004, p.z), 0.0055, 0.008, axis="Y", segments=10)
	objs = [part.build()]
	kit.export(kit.OUT / "notice_board.glb", objs)
	return objs


def main():
	kit.reset()
	mats()
	which = [a for a in sys.argv[sys.argv.index("--") + 1:]] if "--" in sys.argv else []
	jobs = {"desk": desk, "key": key, "items": items, "phone": phone, "clock": clock, "speaker": speaker, "board": board}
	for name in which or list(jobs):
		kit.reset()
		mats()
		jobs[name]()


main()
