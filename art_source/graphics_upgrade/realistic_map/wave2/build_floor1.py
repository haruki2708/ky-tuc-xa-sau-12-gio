"""T-253 (D-167) wave 2, A10: building B's ground floor beyond the corridor kit of build_hall.py: the main door,
the manager's room (window, steps, knife, wall things), the lobby. Run with Blender 5.2.2 from the repository root:
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave2/build_floor1.py

  manager_window.glb   world metres: the window in floor 1's back wall (hole x 2..5.3, y G+1..G+2.44): plastered
                       reveals, a terrazzo sill, a green steel frame with two fixed lights (the left one broken), the
                       middle casements gone (one hangs open outside, one lies in the yard), glass on the sill and the
                       floors; the bridge over the sill (WindowBridge's box) and the steps up to it inside and down
                       outside, each tread's top at its centre on the WindowApproach / WindowExit collision ramps
  manager_room.glb     world metres: the key box and the calendar on the walls, papers on the desk
  knife.glb            local to BuildingB/Knife (1.4, G+0.82, -3.2): a kitchen knife driven point first into the
                       desk top (0.80), leaning 12 degrees like the PS1 one
  main_door_frame.glb  local to BuildingB/MainDoor (19.25, G, 4.1): steel frame, transom light, threshold, the
                       plastered piers and beam that make the gap in the lobby's low wall an entrance
  main_door_leaf.glb   local to MainDoor/Leaf (its hinge, x 17.75): steel-framed glass leaf, push bar inside, pull
                       handle outside; main_door_leaf_b.glb the other leaf for MainDoor/LeafB (hinge x 20.75; door.gd
                       swings a LeafB the other way when the door opens)
  main_door_chain.glb  local to MainDoor/Chains: a chain wrapped twice round the two outside pull handles, a padlock
"""
import math
import random
import sys
from pathlib import Path

import bmesh
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w2kit as K  # noqa: E402
from w2kit import G, L, gbox, quad  # noqa: E402

Y = L.G
COVER = L.COVER
W = L.WINDOW


# ---------------------------------------------------------------- steps on a collision ramp

def steps(part, x0, x1, z0, z1, y0, y1, base):
	"""Built steps over a collision ramp from (z0, y0) to (z1, y1): wave 1's rule, each tread's top at its centre on
	the ramp; solid down to `base` (plastered sides), terrazzo treads with a 2.5 cm nosing on their low edge and
	terrazzo risers."""
	n = max(4, math.ceil(abs(y1 - y0) / 0.15))
	dz = (z1 - z0) / n
	climbs = y1 > y0
	for i in range(n):
		za, zb = z0 + dz * i, z0 + dz * (i + 1)
		top = y0 + (y1 - y0) * (i + 0.5) / n
		low_z, high_z = (za, zb) if climbs else (zb, za)
		out = -math.copysign(1.0, high_z - low_z)  # from this tread towards the step below it
		zs = sorted((za, zb))
		gbox(part, "W1StairSide", (x0, base, zs[0]), (x1, top - 0.03, zs[1]))
		ts = sorted((low_z + out * 0.025, high_z))
		gbox(part, "W1Terrazzo", (x0, top - 0.03, ts[0]), (x1, top, ts[1]), bevel=0.004)
		lower = y0 + (y1 - y0) * ((i - 0.5) if climbs else (i + 1.5)) / n
		lower = min(max(lower, base), top - 0.03)
		rs = sorted((low_z, low_z + out * 0.012))
		if top - 0.03 - lower > 1e-3:
			gbox(part, "W1Terrazzo", (x0, lower, rs[0]), (x1, top - 0.03, rs[1]))


# ---------------------------------------------------------------- the manager's window

def shard(part, rng, centre, size, flat=True, normal=(0, 1, 0)):
	"""A glass splinter: an irregular triangle (lying flat, or standing in a frame's plane)."""
	cx, cy, cz = centre
	pts = []
	for k in range(3):
		a = k / 3 * math.tau + rng.uniform(-0.5, 0.5)
		r = size * rng.uniform(0.5, 1.0)
		if flat:
			pts.append((cx + math.cos(a) * r, cy, cz + math.sin(a) * r))
		else:
			pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r, cz))
	f = part.poly("W2Glass", [G(*p) for p in pts], [(0, 1, 2)], recalc=False)[0]
	f.normal_update()
	if f.normal.dot(G(*normal)) < 0:
		f.normal_flip()


def sash(part, rng, x0, x1, y0, y1, z, broken_from=None):
	"""A casement sash in the plane z (Godot), frame 4 cm, its glass gone but for teeth along the frame."""
	t = 0.04
	paint = "W1DoorPaint"
	gbox(part, paint, (x0, y0, z - 0.02), (x0 + t, y1, z + 0.02))
	gbox(part, paint, (x1 - t, y0, z - 0.02), (x1, y1, z + 0.02))
	gbox(part, paint, (x0 + t, y0, z - 0.02), (x1 - t, y0 + t, z + 0.02))
	gbox(part, paint, (x0 + t, y1 - t, z - 0.02), (x1 - t, y1, z + 0.02))
	# Teeth of glass left in the putty, along the inside of the frame.
	for edge in range(4):
		for k in range(rng.randint(2, 4)):
			if edge in (0, 1):
				x = x0 + t if edge == 0 else x1 - t
				yy = rng.uniform(y0 + 0.1, y1 - 0.1)
				tip = (x + (0.05 if edge == 0 else -0.05) * rng.uniform(0.6, 1.6), yy + rng.uniform(-0.04, 0.04))
				base = [(x, yy - rng.uniform(0.03, 0.07)), (x, yy + rng.uniform(0.03, 0.07))]
			else:
				yy = y0 + t if edge == 2 else y1 - t
				xx = rng.uniform(x0 + 0.1, x1 - 0.1)
				tip = (xx + rng.uniform(-0.04, 0.04), yy + (0.06 if edge == 2 else -0.06) * rng.uniform(0.6, 1.6))
				base = [(xx - rng.uniform(0.03, 0.07), yy), (xx + rng.uniform(0.03, 0.07), yy)]
			pts = [G(base[0][0], base[0][1], z), G(base[1][0], base[1][1], z), G(tip[0], tip[1], z)]
			part.poly("W2Glass", pts, [(0, 1, 2)], recalc=False)


def window():
	rng = random.Random(253_10)
	part = K.Part("Window")
	x0, x1 = W["x0"], W["x1"]
	ys, yh = Y + W["sill"], Y + W["head"]
	zi, zo = W["z"] + W["depth"] / 2, W["z"] - W["depth"] / 2  # inner (room) and outer faces of the wall
	# Reveals: plaster on the jambs and the head (the WindowSill / WindowHeader boxes and the back wall's ends).
	quad(part, "W1StairWall", (x0 + COVER, ys, zo), (x0 + COVER, ys, zi), (x0 + COVER, yh, zi), (x0 + COVER, yh, zo), (1, 0, 0))
	quad(part, "W1StairWall", (x1 - COVER, ys, zo), (x1 - COVER, ys, zi), (x1 - COVER, yh, zi), (x1 - COVER, yh, zo), (-1, 0, 0))
	quad(part, "W1Soffit", (x0, yh - COVER, zo), (x1, yh - COVER, zo), (x1, yh - COVER, zi), (x0, yh - COVER, zi), (0, -1, 0))
	# The sill (terrazzo, proud of both faces) and the bridge it carries (WindowBridge x 3.1..4.9, y 0.8..1.0,
	# z -8.0..-7.2: concrete under a terrazzo top).
	gbox(part, "W1Terrazzo", (x0 - 0.05, ys - 0.03, zo - 0.04), (x1 + 0.05, ys, zi + 0.04), bevel=0.005)
	bx0, bx1, bz0, bz1, by0, by1 = L.WINDOW_BRIDGE
	for za, zb in ((bz0, zo - 0.04), (zi + 0.04, bz1)):
		body = gbox(part, "W1StairSide", (bx0, Y + by0, za), (bx1, Y + by1 - 0.03, zb))
		gbox(part, "W1Terrazzo", (bx0, Y + by1 - 0.03, za), (bx1, Y + by1, zb), bevel=0.004)
	# Steps up from the room (WindowApproach) and down to the yard (WindowExit).
	ax0, ax1, az0, az1, ay0, ay1 = L.WINDOW_RAMPS["approach"]
	steps(part, ax0, ax1, az0, az1, Y + ay0, Y + ay1, Y)
	ex0, ex1, ez0, ez1, ey0, ey1 = L.WINDOW_RAMPS["exit"]
	steps(part, ex0, ex1, ez0, ez1, Y + ey0, Y + ey1, Y - 0.02)
	# The steel frame near the outer face, mullions just outside the 1.8 m way through (x 3.1..4.9).
	fz0, fz1 = zo + 0.03, zo + 0.08
	paint = "W1DoorPaint"
	gbox(part, paint, (x0, ys, fz0), (x0 + 0.05, yh, fz1))
	gbox(part, paint, (x1 - 0.05, ys, fz0), (x1, yh, fz1))
	gbox(part, paint, (x0, yh - 0.05, fz0), (x1, yh, fz1))
	gbox(part, paint, (x0, ys, fz0), (x1, ys + 0.015, fz1))
	for mx in (3.0, 4.95):
		gbox(part, paint, (mx, ys, fz0), (mx + 0.05, yh, fz1))
	fz = (fz0 + fz1) / 2
	# Right fixed light: whole, dusty. Left fixed light: broken, splinters round a hole.
	quad(part, "W2Glass", (5.0, ys + 0.015, fz), (x1 - 0.05, ys + 0.015, fz), (x1 - 0.05, yh - 0.05, fz), (5.0, yh - 0.05, fz), (0, 0, 1))
	lx0, lx1, ly0, ly1 = x0 + 0.05, 3.0, ys + 0.015, yh - 0.05
	hole = Vector((2.62, ys + 0.62))
	corners = [(lx0, ly0), (lx1, ly0), (lx1, ly1), (lx0, ly1)]
	ring = []
	for k in range(14):
		a = k / 14 * math.tau
		r = rng.uniform(0.16, 0.34)
		ring.append((hole.x + math.cos(a) * r * 1.2, hole.y + math.sin(a) * r))
	ring = [(min(max(px, lx0 + 0.02), lx1 - 0.02), min(max(py, ly0 + 0.02), ly1 - 0.02)) for px, py in ring]
	for k in range(14):
		a, b = ring[k], ring[(k + 1) % 14]
		ang = math.atan2((a[1] + b[1]) / 2 - hole.y, (a[0] + b[0]) / 2 - hole.x)
		cx = min(max(hole.x + math.cos(ang) * 2.0, lx0), lx1)
		cy = min(max(hole.y + math.sin(ang) * 2.0, ly0), ly1)
		# Fan from each hole edge to the frame: the corner nearest that direction.
		far = min(corners, key=lambda c: (c[0] - cx) ** 2 + (c[1] - cy) ** 2)
		part.poly("W2Glass", [G(a[0], a[1], fz), G(b[0], b[1], fz), G(far[0], far[1], fz)], [(0, 1, 2)], recalc=False)
	for c0, c1 in zip(corners, corners[1:] + corners[:1]):
		near = min(ring, key=lambda p: (p[0] - (c0[0] + c1[0]) / 2) ** 2 + (p[1] - (c0[1] + c1[1]) / 2) ** 2)
		part.poly("W2Glass", [G(c0[0], c0[1], fz), G(c1[0], c1[1], fz), G(near[0], near[1], fz)], [(0, 1, 2)], recalc=False)
	# Beads round the fixed lights.
	for a, b in ((lx0, lx1), (5.0, x1 - 0.05)):
		for yy in (ys + 0.015, yh - 0.062):
			gbox(part, paint, (a, yy, fz - 0.014), (b, yy + 0.012, fz - 0.004))
	# The middle casements: the left one hangs open outside from its hinge on the mullion (x 3.05), the right one
	# lies in the yard east of the steps.
	hang = K.Part("Sash")
	sash(hang, rng, 0.0, 0.92, ys + 0.03, yh - 0.06, 0.0)
	sash_obj = K.build(hang)
	sash_obj.rotation_euler = (0, 0, math.radians(95))
	sash_obj.location = G(3.03, 0.0, fz1 + 0.005)
	fallen = K.Part("SashFallen")
	sash(fallen, rng, 0.0, 0.9, 0.0, 1.32, 0.0)
	fallen_obj = K.build(fallen)
	fallen_obj.rotation_euler = (math.radians(-90 + 4), 0, math.radians(18))
	fallen_obj.location = G(5.25, Y + 0.025, -8.35)
	# Glass on the sill ends, the floor inside and the yard outside, none on the way through.
	for k in range(26):
		inside = k < 12
		x = rng.choice([rng.uniform(2.15, 3.0), rng.uniform(5.0, 5.4)])
		if inside:
			z = rng.uniform(-7.4, -6.6)
			y = Y + 0.004
		else:
			z = rng.uniform(-9.6, -8.1)
			x = rng.choice([rng.uniform(2.3, 3.0), rng.uniform(5.0, 5.9)])
			y = Y + 0.004
		shard(part, rng, (x, y, z), rng.uniform(0.02, 0.06))
	for k in range(5):
		shard(part, rng, (rng.choice([rng.uniform(2.1, 3.0), rng.uniform(4.98, 5.25)]), ys + 0.002, rng.uniform(zo - 0.02, zi + 0.02)), rng.uniform(0.015, 0.04))
	return [K.build(part), sash_obj, fallen_obj]


# ---------------------------------------------------------------- the manager's room

def room_things():
	part = K.Part("ManagerRoom")
	wx = L.STAIR_WALL_W + COVER  # room 101's west wall face (the main stairs' wall)
	# A wooden key box on the west wall: its glazed door shut, hooks and tags inside.
	gbox(part, "W1Wood", (wx, Y + 1.3, -2.3), (wx + 0.07, Y + 1.85, -1.75), bevel=0.006)
	gbox(part, "W1Black", (wx + 0.07, Y + 1.34, -2.26), (wx + 0.071, Y + 1.81, -1.79))
	quad(part, "W2Glass", (wx + 0.072, Y + 1.34, -2.26), (wx + 0.072, Y + 1.34, -1.79), (wx + 0.072, Y + 1.81, -1.79),
		(wx + 0.072, Y + 1.81, -2.26), (1, 0, 0))
	for r in range(3):
		for c in range(5):
			hy = Y + 1.72 - r * 0.15
			hz = -2.2 + c * 0.09
			part.cylinder("W1Brass", tuple(G(wx + 0.045, hy, hz)), 0.003, 0.03, axis="X", segments=6)
			if (r * 5 + c) % 3 != 1:
				gbox(part, "W1RedPlastic" if (r + c) % 2 else "W1Paper", (wx + 0.035, hy - 0.07, hz - 0.012), (wx + 0.04, hy - 0.025, hz + 0.012))
	gbox(part, "W1Brass", (wx + 0.07, Y + 1.56, -1.8), (wx + 0.078, Y + 1.6, -1.79))
	# A calendar on the back wall by the window; papers left on the desk away from the knife.
	bz = L.BACK_FACE + COVER
	gbox(part, "W1Paper", (0.65, Y + 1.25, bz), (1.05, Y + 1.83, bz + 0.004))
	gbox(part, "W1RedPlastic", (0.65, Y + 1.75, bz + 0.004), (1.05, Y + 1.83, bz + 0.005))
	part.cylinder("W1Steel", tuple(G(0.85, Y + 1.86, bz + 0.004)), 0.004, 0.008, axis="Y", segments=6)
	top = Y + 0.8
	rng = random.Random(253_11)
	for k in range(5):
		cx, cz = rng.choice([(0.85, -3.3), (1.95, -3.05), (1.85, -3.4)])
		a = rng.uniform(-0.4, 0.4)
		w, d = 0.21, 0.297
		pts = [(cx + math.cos(a) * dx - math.sin(a) * dz, cz + math.sin(a) * dx + math.cos(a) * dz)
			for dx, dz in ((-w / 2, -d / 2), (w / 2, -d / 2), (w / 2, d / 2), (-w / 2, d / 2))]
		h = top + 0.001 + k * 0.0012
		quad(part, "W1Paper", (pts[0][0], h, pts[0][1]), (pts[1][0], h, pts[1][1]), (pts[2][0], h, pts[2][1]), (pts[3][0], h, pts[3][1]), (0, 1, 0))
	return [K.build(part)]


def knife():
	"""Local to Knife (desk top at y -0.02): the point 2.5 cm into the wood, leaning 12 degrees about Z."""
	part = K.Part("Knife")
	tip = Vector((0.0, -0.045, 0.0))
	blade = 0.2
	w = 0.045
	# Blade: spine straight, edge curving to the point (flat faces to +/-Z), 2 mm thick.
	outline = []
	for k in range(9):
		t = k / 8
		y = tip.y + t * blade
		edge_x = -w * (1 - (1 - t) ** 2.2) if t < 1 else -w
		outline.append((edge_x, y))
	verts = [(0.0, tip.y + 0.012)] + [(0.0, tip.y + blade)] + list(reversed(outline))
	front = [G(x, y, 0.001) for x, y in verts]
	back = [G(x, y, -0.001) for x, y in verts]
	n = len(verts)
	faces = [list(range(n)), list(range(2 * n - 1, n - 1, -1))]
	faces += [(i, (i + 1) % n, n + (i + 1) % n, n + i) for i in range(n)]
	part.poly("W2Blade", front + back, faces)
	# Bolster and handle (black, three rivets).
	gbox(part, "W1Steel", (-w, tip.y + blade, -0.006), (0.004, tip.y + blade + 0.012, 0.006), bevel=0.002)
	gbox(part, "W2Grip", (-w + 0.008, tip.y + blade + 0.012, -0.009), (0.0, tip.y + blade + 0.125, 0.009), bevel=0.006, segments=2)
	for k in range(3):
		part.cylinder("W1Steel", tuple(G(-w / 2 + 0.004, tip.y + blade + 0.035 + k * 0.035, 0.0)), 0.0035, 0.0185, axis="Y", segments=8)
	obj = K.build(part)
	obj.data.transform(Matrix.Translation(-G(*tip)))
	obj.rotation_euler = (0, math.radians(12), 0)
	obj.location = G(*tip)
	return [obj]


# ---------------------------------------------------------------- the main door

def door_frame():
	part = K.Part("MainDoorFrame")
	paint = "W1DoorPaint"
	h = L.MAIN_DOOR_HALF
	for s in (-1, 1):
		gbox(part, paint, (s * h, 0.0, -0.05), (s * (h + 0.06), 2.5, 0.05), bevel=0.003)
	gbox(part, paint, (-h - 0.06, 2.42, -0.05), (h + 0.06, 2.5, 0.05), bevel=0.003)
	# Transom light over the leaves, a bar in the middle.
	gbox(part, paint, (-h - 0.06, 2.84, -0.05), (h + 0.06, 2.9, 0.05), bevel=0.003)
	gbox(part, paint, (-0.025, 2.5, -0.04), (0.025, 2.84, 0.04))
	quad(part, "W2Glass", (-h, 2.5, 0.0), (h, 2.5, 0.0), (h, 2.84, 0.0), (-h, 2.84, 0.0), (0, 0, 1))
	gbox(part, "W1Granite", (-h, 0.0, -0.08), (h, 0.012, 0.08), bevel=0.003)
	# Plastered piers either side (over the low walls' ends) and the beam across, up to the hall ceiling.
	top = L.CEILING - COVER
	mats = ("W2HallDado", "W2HallWall")
	for s in (-1, 1):
		a, b = sorted((s * (h + 0.06), s * (h + 0.4)))
		for lo, hi, mat in ((0.0, 1.1, mats[0]), (1.1, top, mats[1])):
			gbox(part, mat, (a, lo, -0.17), (b, hi, 0.2))
		gbox(part, "W1Terrazzo", (a - 0.005, 0.0, -0.18), (b + 0.005, 0.12, 0.21))
	gbox(part, mats[1], (-h - 0.4, 2.9, -0.17), (h + 0.4, top, 0.2))
	# The piers' plaster samples floor 1's row of the hall wall mask (local x + the door's 19.25).
	part.set_uv2([f for f in part.bm.faces if f.material_index in (part.slot(mats[0]), part.slot(mats[1]))],
		lambda co: ((L.MAIN_DOOR_X + co.x) / 44.0, (0.002 + 0.996 * min(max(co.z / L.CEILING, 0.0), 1.0)) / 3.0))
	return [K.build(part)]


def leaf(side):
	"""side 'a' (MainDoor/Leaf: hinge at x 0, the leaf to +X) or 'b' (LeafB: to -X); y -1.2..1.2, z +/-0.025;
	glass in a green steel frame, a kick plate, a push bar inside (-Z), a pull handle outside (+Z) by the meeting
	edge (the chain goes round the two pull handles)."""
	s = 1 if side == "a" else -1
	part = K.Part("Leaf" + side.upper())
	paint = "W1DoorPaint"
	a, b = sorted((s * 0.005, s * 1.495))
	stile = 0.075
	gbox(part, paint, (a, -1.2, -0.025), (a + stile, 1.19, 0.025), bevel=0.003)
	gbox(part, paint, (b - stile, -1.2, -0.025), (b, 1.19, 0.025), bevel=0.003)
	for lo, hi in ((-1.2, -0.98), (-0.25, -0.15), (1.1, 1.19)):
		gbox(part, paint, (a + stile, lo, -0.025), (b - stile, hi, 0.025), bevel=0.003)
	for lo, hi in ((-0.98, -0.25), (-0.15, 1.1)):
		quad(part, "W2Glass", (a + stile, lo, 0.0), (b - stile, lo, 0.0), (b - stile, hi, 0.0), (a + stile, hi, 0.0), (0, 0, 1))
		for zz in (-0.012, 0.008):
			for yy in (lo, hi - 0.012):
				gbox(part, paint, (a + stile, yy, zz), (b - stile, yy + 0.012, zz + 0.004))
	for zz in (-0.027, 0.025):
		gbox(part, "W1Alu", (a + 0.02, -1.18, zz), (b - 0.02, -1.0, zz + 0.002))
	meet = s * 1.495
	# Push bar inside.
	pa, pb = sorted((s * 0.2, meet - s * 0.12))
	part.tube("W1Steel", [G(pa, -0.2, -0.085), G(pb, -0.2, -0.085)], 0.016, 12)
	for px in (pa + 0.03, pb - 0.03):
		part.tube("W1Steel", [G(px, -0.2, -0.025), G(px, -0.2, -0.085)], 0.012, 10)
	# Pull handle outside.
	hx = meet - s * 0.115
	part.tube("W1Steel", [G(hx, -0.45, 0.085), G(hx, 0.25, 0.085)], 0.014, 12)
	for py in (-0.4, 0.2):
		part.tube("W1Steel", [G(hx, py, 0.025), G(hx, py, 0.085)], 0.011, 10)
	# A floor bolt on the passive leaf.
	if side == "b":
		gbox(part, "W1Steel", (meet + 0.03, -1.19, -0.032), (meet + 0.05, -0.95, -0.025))
	return [K.build(part)]


def chain():
	"""Local to MainDoor/Chains (the door's centre on the floor): two turns round the pull handles (x -0.12 and
	+0.12 world-local, z 0.085, y 0.75..1.45), the padlock through the end links, a slack tail."""
	part = K.Part("Chain")
	rng = random.Random(253_12)

	def link(p, d, k):
		"""One oval link 46 x 26 mm of 10 mm galvanised wire, centred at p along d, turned 90 degrees every other link."""
		d = d.normalized()
		side = d.cross(Vector((0, 0, 1)))
		if side.length < 1e-3:
			side = d.cross(Vector((1, 0, 0)))
		side.normalize()
		up = side.cross(d).normalized()
		if k % 2:
			side, up = up, side
		pts = []
		for j in range(9):
			a = j / 8 * math.tau
			pts.append(p + d * (math.cos(a) * 0.018) + side * (math.sin(a) * 0.008))
		part.tube("W1Steel", pts, 0.005, 5, cap=False)

	k = 0
	for turn, yc in enumerate((1.17, 1.03)):
		pts = []
		for j in range(64):
			t = j / 64 * math.tau
			pts.append(G(0.17 * math.cos(t), yc + 0.025 * math.sin(2 * t + turn), 0.085 + 0.052 * math.sin(t)))
		length = sum((pts[(j + 1) % 64] - pts[j]).length for j in range(64))
		count = int(length / 0.036)
		acc, j = 0.0, 0
		for c in range(count):
			target = c * length / count
			while acc + (pts[(j + 1) % 64] - pts[j]).length < target:
				acc += (pts[(j + 1) % 64] - pts[j]).length
				j += 1
			seg = pts[(j + 1) % 64] - pts[j]
			p = pts[j] + seg * ((target - acc) / max(seg.length, 1e-6))
			link(p, seg, k)
			k += 1
	# Padlock at the front where the turns meet, its shackle through both end links; a tail of slack links.
	lock = G(0.0, 1.0, 0.152)
	gbox(part, "W1Brass", (-0.032, 0.92, 0.14), (0.032, 0.995, 0.166), bevel=0.005)
	part.tube("W1Steel", [lock + Vector((-0.016, 0, 0)), lock + Vector((-0.016, 0, 0.03)), lock + Vector((0, 0, 0.042)),
		lock + Vector((0.016, 0, 0.03)), lock + Vector((0.016, 0, 0))], 0.004, 8, cap=False)
	part.cylinder("W1Black", tuple(G(0.0, 0.95, 0.1625)), 0.004, 0.002, axis="Y", segments=8)
	p = G(0.02, 0.98, 0.15)
	for t in range(7):
		nxt = p + Vector((rng.uniform(-0.008, 0.008), rng.uniform(-0.004, 0.004), -0.034))
		link((p + nxt) / 2, nxt - p, k)
		k += 1
		p = nxt
	return [K.build(part)]


def main():
	K.materials()
	K.material("W1RedPlastic", (0.52, 0.05, 0.04), 0.45)
	jobs = (("manager_window.glb", window), ("manager_room.glb", room_things), ("knife.glb", knife),
		("main_door_frame.glb", door_frame), ("main_door_leaf.glb", lambda: leaf("a")),
		("main_door_leaf_b.glb", lambda: leaf("b")), ("main_door_chain.glb", chain))
	for name, fn in jobs:
		K.export(name, fn())
		K.reset()
		K.materials()
		K.material("W1RedPlastic", (0.52, 0.05, 0.04), 0.45)


main()
