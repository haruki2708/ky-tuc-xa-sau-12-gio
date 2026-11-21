"""T-267 (D-166) round 1 pilot: one CCTV room of cctv_set.tscn (Room306) and the corridor in front of it, in building
B's approved style of wave 2 (floors 1-3: two-tone plaster with the green-grey dado, terrazzo floor and skirting, green
door paint, the steel balustrade with its wooden rail). Every CCTV room has the same layout (Room<n> local metres, the
PS1 boxes: floor top y 0, walls' inner faces x 0.1 / 3.9 and z -4.9 / -0.1, ceiling 3.0; doorway x 2.0..2.9 under the
lintel at 2.2; Hall: floor z 0.1..2.35, x -0.85..4.85), so one set of glbs serves all five; the props stay where the
PS1 set has them. Visual only: no collider (the PS1 colliders stay, their meshes hide). Only wave 1-2 materials: no new
texture.
Run with Blender 5.2.2 from the repository root:
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave10/build_wave10.py
then python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_materials.py and godot --import.
  cctv_room.glb        Shell        floor, side and front walls (room side), ceiling, skirting
                       BackPlain    W1: the back wall as now (plaster and dado)
                       BackBalcony  W2: the back wall with a closed balcony door and a closed window (glass, grille),
                                    night behind them
                       DoorFrame    linings, stops, architraves both sides, the granite threshold, hinge knuckles, the green
                                    boards behind the room's Label3D numbers
                       NightLamp    the bulb on its cord where NightLight shines (1.5, 2.5, -2.6)
  cctv_hall.glb        Hall         the corridor: room-side wall, end walls, terrazzo floor and divider strips, ceiling,
                                    cross beams over the room partitions and the edge beam
                       Balustrade   floors 2-3 (209, 306, 310): curb, bars, rails, wooden handrail along the open side
                       Parapet      floor 1 (102, 106): the low plastered wall with a terrazzo coping
                       Batten       the tube batten over Hall/Tube (2.8, 2.8, 1.25)
                       Night        the dark beyond the open side
  cctv_light_set.glb   Bunks        option D1: two light steel bunks (decks under the mattresses at 0.36 and 1.13)
                       Lockers      option D1: four two-door steel lockers where Locker1..4 stand
"""
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave2"))
import w2kit as K  # noqa: E402
from w2kit import G, gbox, quad  # noqa: E402
import w1kit  # noqa: E402

OUT = w1kit.ROOT / "game/assets/models/graphics_pilot/realistic_map/wave10"
C = 0.003  # in front of the PS1 faces
X0, X1, ZB, ZF, CEIL = 0.1, 3.9, -4.9, -0.1, 3.0
DX0, DX1, DTOP = 2.0, 2.9, 2.1  # the doorway as drawn (the collider's opening is 2.2 high: the head lining is lower)
HX0, HX1, HZ0, HZ1 = -0.85, 4.85, 0.1, 2.35
DADO = 1.1
SKIRT = 0.12
SKIRT_OUT = 0.01
TOPH = CEIL - 0.002
BUNKS = (0.65, 3.35)
BUNK_Z = -3.0
DECKS = (0.355, 1.125)  # slat tops: the 407 mattress (bunk_mattress.glb) lies on them, its top at 0.43 / 1.2
LOCKERS_Z = ((-0.83, -0.07), (-1.63, -0.87))


def wall(part, plane, c, s0, s1, holes, facing, mats, uv2, top=TOPH, dado=DADO, skirting=True, skirt_mat="W1Terrazzo"):
	"""Wave 2's wall (build_hall.wall) at floor y 0: dado, plaster above, terrazzo skirting 1 cm proud. holes:
	[(s_a, s_b, h_top)] or [(s_a, s_b, h_top, h_bottom)]; uv2(s, h) -> (u, v)."""
	def P(s, h, off=0.0):
		if plane == "z":
			return (s, h, c + off * facing[2])
		return (c + off * facing[0], h, s)
	cuts = sorted({s0, s1} | {e for hole in holes for e in hole[:2] if s0 < e < s1})
	made = []
	for a, b in zip(cuts, cuts[1:]):
		mid = (a + b) / 2
		gap = [hole for hole in holes if hole[0] <= mid <= hole[1]]
		spans = [(0.0, top)]
		if gap:
			hole = gap[0]
			bottom = hole[3] if len(hole) > 3 else 0.0
			spans = [(hole[2], top)] + ([(0.0, bottom)] if bottom > 0.0 else [])
		for lo, hi in spans:
			for blo, bhi, mat in ((lo, min(hi, dado), mats[0]), (max(lo, dado), hi, mats[1])):
				if bhi - blo < 1e-4:
					continue
				f = quad(part, mat, P(a, blo), P(b, blo), P(b, bhi), P(a, bhi), facing)
				part.set_uv2([f], lambda co, plane=plane: uv2(co.x if plane == "z" else -co.y, co.z))
				made.append(f)
		if skirting and not (gap and (gap[0][3] if len(gap[0]) > 3 else 0.0) == 0.0):
			made += gbox(part, skirt_mat, P(a, 0.0), P(b, SKIRT, SKIRT_OUT))
	return made


def along(a, b):
	return lambda s, h: ((s - a) / (b - a), h / 3.3)


# ---------------------------------------------------------------- room

ROOM_MATS = ("W1StairDado", "W1StairWall")
WINDOW = (1.15, 2.45, 2.25, 1.05)  # x0, x1, head, sill: over the desk
BALCONY = (0.2, 0.95, 2.1)  # x0, x1, head: behind bunk A's foot


def shell():
	part = K.Part("Shell")
	fl = quad(part, "W1Terrazzo", (X0, 0.002, ZB), (X1, 0.002, ZB), (X1, 0.002, ZF), (X0, 0.002, ZF), (0, 1, 0))
	part.set_uv2([fl], lambda co: ((co.x - X0) / (X1 - X0), (-co.y - ZB) / (ZF - ZB)))
	wall(part, "x", X0 + C, ZB, ZF, [], (1, 0, 0), ROOM_MATS, along(ZB, ZF))
	wall(part, "x", X1 - C, ZB, ZF, [], (-1, 0, 0), ROOM_MATS, along(ZF, ZB))
	wall(part, "z", ZF - C, X0, X1, [(DX0, DX1, DTOP)], (0, 0, -1), ROOM_MATS, along(X1, X0))
	quad(part, "W1Soffit", (X0, CEIL - C, ZB), (X1, CEIL - C, ZB), (X1, CEIL - C, ZF), (X0, CEIL - C, ZF), (0, -1, 0))
	return K.build(part)


def back_plain():
	part = K.Part("BackPlain")
	wall(part, "z", ZB + C, X0, X1, [], (0, 0, 1), ROOM_MATS, along(X0, X1))
	return K.build(part)


def back_balcony():
	"""W2: the back wall with a glazed balcony door (closed) and a window (closed, grille outside), as the real rooms
	have them; behind them the night. The wall stays the PS1 box (z -5.1..-4.9): the openings are drawn only."""
	part = K.Part("BackBalcony")
	bx0, bx1, bhead = BALCONY
	wx0, wx1, whead, wsill = WINDOW
	wall(part, "z", ZB + C, X0, X1, [(bx0, bx1, bhead), (wx0, wx1, whead, wsill)], (0, 0, 1), ROOM_MATS, along(X0, X1))
	depth = 0.2
	back = ZB - depth
	# Reveals (plaster) through the wall's thickness.
	for x0, x1, top, bottom in ((bx0, bx1, bhead, 0.0), (wx0, wx1, whead, wsill)):
		for x, facing in ((x0, 1), (x1, -1)):
			quad(part, "W1StairWall", (x, bottom, ZB + C), (x, bottom, back), (x, top, back), (x, top, ZB + C), (facing, 0, 0))
		quad(part, "W1StairWall", (x0, top, ZB + C), (x1, top, ZB + C), (x1, top, back), (x0, top, back), (0, -1, 0))
		if bottom > 0.0:
			gbox(part, "W1Terrazzo", (x0 - 0.02, bottom - 0.02, ZB - 0.12), (x1 + 0.02, bottom + 0.012, ZB + 0.04), bevel=0.004)
	frame = 0.045
	mid = ZB - 0.11
	# The balcony door: green steel frame, a solid lower panel, glass above, a lever.
	for lo, hi in (((bx0, 0.0), (bx0 + frame, bhead)), ((bx1 - frame, 0.0), (bx1, bhead)), ((bx0, bhead - frame), (bx1, bhead)),
			((bx0, 0.0), (bx1, 0.05)), ((bx0, 0.95), (bx1, 0.95 + frame))):
		gbox(part, "W1DoorPaint", (lo[0], lo[1], mid - 0.025), (hi[0], hi[1], mid + 0.025), bevel=0.004)
	gbox(part, "W1DoorPaint", (bx0 + frame, 0.05, mid - 0.012), (bx1 - frame, 0.95, mid + 0.012))
	for k in range(3):
		y = 0.2 + k * 0.25
		gbox(part, "W1DoorPaint", (bx0 + frame + 0.04, y, mid + 0.012), (bx1 - frame - 0.04, y + 0.03, mid + 0.02))
	quad(part, "W2Glass", (bx0 + frame, 0.95 + frame, mid), (bx1 - frame, 0.95 + frame, mid), (bx1 - frame, bhead - frame, mid),
		(bx0 + frame, bhead - frame, mid), (0, 0, 1))
	gbox(part, "W1DoorPaint", ((bx0 + bx1) / 2 - 0.012, 0.95 + frame, mid - 0.015), ((bx0 + bx1) / 2 + 0.012, bhead - frame, mid + 0.015))
	gbox(part, "W1Steel", (bx1 - 0.11, 1.0, mid + 0.025), (bx1 - 0.09, 1.02, mid + 0.07), bevel=0.003)
	gbox(part, "W1Steel", (bx1 - 0.2, 1.0, mid + 0.06), (bx1 - 0.09, 1.02, mid + 0.075), bevel=0.003)
	# The window: two side-hung sashes, a fixed top light, glass, the security grille outside.
	for lo, hi in (((wx0, wsill), (wx0 + frame, whead)), ((wx1 - frame, wsill), (wx1, whead)), ((wx0, wsill), (wx1, wsill + frame)),
			((wx0, whead - frame), (wx1, whead)), (((wx0 + wx1) / 2 - 0.02, wsill), ((wx0 + wx1) / 2 + 0.02, whead)),
			((wx0, whead - 0.38), (wx1, whead - 0.38 + 0.035))):
		gbox(part, "W1DoorPaint", (lo[0], lo[1], mid - 0.025), (hi[0], hi[1], mid + 0.025), bevel=0.004)
	quad(part, "W2Glass", (wx0 + frame, wsill + frame, mid), (wx1 - frame, wsill + frame, mid), (wx1 - frame, whead - frame, mid),
		(wx0 + frame, whead - frame, mid), (0, 0, 1))
	grille = back - 0.03
	n = 9
	for k in range(1, n):
		gx = wx0 + k * (wx1 - wx0) / n
		gbox(part, "W1RailSteel", (gx - 0.007, wsill, grille - 0.007), (gx + 0.007, whead, grille + 0.007))
	for gy in (wsill + 0.35, whead - 0.35):
		gbox(part, "W1RailSteel", (wx0, gy - 0.012, grille - 0.01), (wx1, gy + 0.012, grille + 0.01))
	# The night behind both openings (nothing is built past the back wall).
	quad(part, "W1Black", (X0, -0.2, back - 0.45), (X1, -0.2, back - 0.45), (X1, CEIL, back - 0.45), (X0, CEIL, back - 0.45), (0, 0, 1))
	return K.build(part)


def door_frame():
	part = K.Part("DoorFrame")
	t, a, proud = 0.025, 0.065, 0.016
	# Linings on the jambs and under the head (inside the collider's opening: 0.85 m stays clear).
	gbox(part, "W1DoorPaint", (DX0, 0.0, ZF), (DX0 + t, DTOP, HZ0), bevel=0.003)
	gbox(part, "W1DoorPaint", (DX1 - t, 0.0, ZF), (DX1, DTOP, HZ0), bevel=0.003)
	gbox(part, "W1DoorPaint", (DX0, DTOP - t, ZF), (DX1, DTOP + 0.002, HZ0), bevel=0.003)
	# Stops: the leaf shuts against them from the room side.
	for x0, x1 in ((DX0 + t, DX0 + t + 0.014), (DX1 - t - 0.014, DX1 - t)):
		gbox(part, "W1DoorPaint", (x0, 0.0, -0.065), (x1, DTOP - t, -0.035))
	gbox(part, "W1DoorPaint", (DX0 + t, DTOP - t - 0.014, -0.065), (DX1 - t, DTOP - t, -0.035))
	# Architraves on both faces.
	for z0, z1 in ((ZF - C - proud, ZF - C), (HZ0 + C, HZ0 + C + proud)):
		gbox(part, "W1DoorPaint", (DX0 - a, 0.0, z0), (DX0, DTOP + a, z1), bevel=0.004, segments=2)
		gbox(part, "W1DoorPaint", (DX1, 0.0, z0), (DX1 + a, DTOP + a, z1), bevel=0.004, segments=2)
		gbox(part, "W1DoorPaint", (DX0, DTOP, z0), (DX1, DTOP + a, z1), bevel=0.004, segments=2)
	gbox(part, "W1Granite", (DX0, 0.0, ZF - 0.01), (DX1, 0.014, HZ0 + 0.01), bevel=0.003)
	# The number boards: building B's green backing behind NumberInside / NumberOutside (Label3D at y 2.42, z -/+0.11,
	# light digits ~0.19 m high), 5 mm proud so the digits stay in front of them.
	for z0, z1 in ((-0.108, ZF - C), (HZ0 + C, 0.108)):
		gbox(part, "W1DoorPaint", (2.45 - 0.23, 2.42 - 0.12, z0), (2.45 + 0.23, 2.42 + 0.12, z1), bevel=0.002)
	for y in (0.25, 1.05, 1.85):
		part.cylinder("W1Steel", tuple(G(DX1 - t - 0.004, y, ZF + 0.012)), 0.009, 0.11, axis="Z", segments=10)
	return K.build(part)


def night_lamp():
	"""A bare bulb on its cord from the ceiling: NightLight (1.5, 2.5, -2.6) shines from inside it."""
	part = K.Part("NightLamp")
	x, z = 1.5, -2.6
	part.cylinder("W1Enamel", tuple(G(x, CEIL - C - 0.012, z)), 0.045, 0.024, axis="Y", segments=16)
	part.tube("W1Black", [G(x, CEIL - 0.02, z), G(x, 2.6, z)], 0.0035, 6)
	part.cylinder("W1Enamel", tuple(G(x, 2.575, z)), 0.019, 0.055, axis="Y", segments=12)
	profile = [(0.0, 2.555), (0.014, 2.55), (0.03, 2.525), (0.034, 2.495), (0.028, 2.47), (0.0, 2.458)]
	for (r0, y0), (r1, y1) in zip(profile, profile[1:]):
		part.cylinder("W2Tube", tuple(G(x, (y0 + y1) / 2, z)), r0, abs(y0 - y1), axis="Y", segments=16, radius2=r1)
	return K.build(part)


# ---------------------------------------------------------------- hall

HALL_MATS = ("W2HallDado", "W2HallWall")


def hall_uv2(s, h):
	"""Inside the masks' floor-3 row (wave 2): u along the corridor, v up the wall."""
	return ((s - HX0) / 44.0 + 0.3, 2.0 / 3.0 + (0.002 + 0.996 * min(max(h / CEIL, 0.0), 1.0)) / 3.0)


def hall():
	part = K.Part("Hall")
	wall(part, "z", HZ0 + C, HX0, HX1, [(DX0, DX1, DTOP)], (0, 0, 1), HALL_MATS, hall_uv2)
	wall(part, "x", HX0 + C, HZ0, HZ1, [], (1, 0, 0), HALL_MATS, lambda s, h: hall_uv2(HX0 + (s - HZ0), h))
	wall(part, "x", HX1 - C, HZ0, HZ1, [], (-1, 0, 0), HALL_MATS, lambda s, h: hall_uv2(HX1 - (s - HZ0), h))
	fl = quad(part, "W2HallFloor", (HX0, 0.002, HZ0), (HX1, 0.002, HZ0), (HX1, 0.002, HZ1), (HX0, 0.002, HZ1), (0, 1, 0))
	part.set_uv2([fl], lambda co: ((co.x - HX0) / 44.0 + 0.3, 2.0 / 3.0 + (0.002 + 0.996 * min(max(-co.y / 4.0, 0.0), 1.0)) / 3.0))
	lift = 0.0026
	k = math.ceil(HX0 / 1.1)
	while k * 1.1 < HX1 - 0.05:
		xs = k * 1.1
		if xs > HX0 + 0.05:
			quad(part, "W2Divider", (xs - 0.003, lift, HZ0), (xs + 0.003, lift, HZ0), (xs + 0.003, lift, HZ1), (xs - 0.003, lift, HZ1), (0, 1, 0))
		k += 1
	for zs in (1.0, 2.0):
		quad(part, "W2Divider", (HX0, lift, zs - 0.003), (HX1, lift, zs - 0.003), (HX1, lift, zs + 0.003), (HX0, lift, zs + 0.003), (0, 1, 0))
	ceil = CEIL - C
	cuv = lambda co: ((co.x - HX0) / 44.0 + 0.3, 2.0 / 3.0 + (0.002 + 0.996 * min(max(-co.y / 4.0, 0.0), 1.0)) / 3.0)  # noqa: E731
	cf = quad(part, "W2HallCeiling", (HX0, ceil, HZ0), (HX1, ceil, HZ0), (HX1, ceil, HZ1 + 0.15), (HX0, ceil, HZ1 + 0.15), (0, -1, 0))
	part.set_uv2([cf], cuv)
	# Hall/Cam hangs at (-0.7, 2.65, 2.2): the edge beam stays over the balustrade (z 2.3..2.5) and 0.3 deep, clear of it.
	beams = []
	for bx in (0.0, 4.0):
		beams += gbox(part, "W2HallCeiling", (bx - 0.125, ceil - 0.3, HZ0), (bx + 0.125, ceil, 2.3))
	beams += gbox(part, "W2HallCeiling", (HX0, ceil - 0.3, 2.3), (HX1, ceil, HZ1 + 0.15))
	part.set_uv2(beams, cuv)
	return K.build(part)


RAIL_Z = 2.43


def balustrade():
	"""Floors 2-3 (wave 2's balustrade): concrete curb, square bars every 12.5 cm, flat rails, posts, wooden handrail."""
	part = K.Part("Balustrade")
	z = RAIL_Z
	x0, x1 = HX0, HX1
	gbox(part, "W1Concrete", (x0, 0.0, HZ1 + 0.005), (x1, 0.1, 2.5), bevel=0.006)
	gbox(part, "W1RailSteel", (x0, 0.16, z - 0.012), (x1, 0.19, z + 0.012))
	gbox(part, "W1RailSteel", (x0, 1.215, z - 0.02), (x1, 1.235, z + 0.02))
	gbox(part, "W1RailWood", (x0, 1.235, z - 0.032), (x1, 1.295, z + 0.032), bevel=0.012, segments=2)
	posts = [x0 + 0.03, x0 + 2.75, x0 + 5.5, x1 - 0.03]
	for px in posts:
		gbox(part, "W1RailSteel", (px - 0.025, 0.1, z - 0.025), (px + 0.025, 1.235, z + 0.025), bevel=0.003)
	count = int(round((x1 - x0) / 0.125))
	for k in range(count):
		bx = x0 + (k + 0.5) * (x1 - x0) / count
		if min(abs(bx - p) for p in posts) < 0.05:
			continue
		gbox(part, "W1RailSteel", (bx - 0.008, 0.19, z - 0.008), (bx + 0.008, 1.215, z + 0.008))
	return K.build(part)


def parapet():
	"""Floor 1 (wave 2's lobby parapet): a low plastered wall with a terrazzo coping."""
	part = K.Part("Parapet")
	top = 1.25
	wall(part, "z", HZ1 + C, HX0, HX1, [], (0, 0, -1), HALL_MATS, hall_uv2, top=top)
	gbox(part, "W1Terrazzo", (HX0, top, HZ1 - 0.02), (HX1, 1.3, 2.55), bevel=0.008)
	return K.build(part)


def batten():
	"""Wave 2's tube batten (build_hall.lamps) over Hall/Tube (2.8, 2.8, 1.25), along the corridor."""
	part = K.Part("Batten")
	lx, cz = 2.8, 1.25
	ceil = CEIL - C
	gbox(part, "W1Enamel", (lx - 0.62, ceil - 0.065, cz - 0.07), (lx + 0.62, ceil, cz + 0.07), bevel=0.01, segments=2)
	for side in (-1, 1):
		gbox(part, "W1Enamel", (lx - 0.61, ceil - 0.09, cz + side * 0.075 - 0.003), (lx + 0.61, ceil - 0.06, cz + side * 0.075 + 0.003))
		gbox(part, "W1Enamel", (lx + side * 0.6 - 0.018, ceil - 0.11, cz - 0.07), (lx + side * 0.6 + 0.018, ceil - 0.06, cz + 0.07), bevel=0.006)
	for tz in (cz - 0.035, cz + 0.035):
		part.tube("W2Tube", [G(lx - 0.575, ceil - 0.1, tz), G(lx + 0.575, ceil - 0.1, tz)], 0.0135, 12)
		for ex in (-1, 1):
			part.tube("W1Steel", [G(lx + ex * 0.575, ceil - 0.1, tz), G(lx + ex * 0.588, ceil - 0.1, tz)], 0.0145, 10)
	gbox(part, "W1Enamel", (lx - 0.012, ceil - 0.016, HZ0 + C), (lx + 0.012, ceil, cz - 0.07))
	return K.build(part)


def night():
	"""Past the open side: the dark (nothing is built out there, the set hangs 60 m under the campus)."""
	part = K.Part("Night")
	quad(part, "W1Black", (HX0 - 3.0, -2.0, 5.5), (HX1 + 3.0, -2.0, 5.5), (HX1 + 3.0, 6.0, 5.5), (HX0 - 3.0, 6.0, 5.5), (0, 0, -1))
	return K.build(part)


# ---------------------------------------------------------------- D1: light bunks and lockers (wave 2's)

def bunk(part, cx, room_side):
	t = 0.018
	hx, hz = 0.45 - t, 1.0 - t
	za, zb = BUNK_Z - hz, BUNK_Z + hz
	for px in (cx - hx, cx + hx):
		for pz in (za, zb):
			gbox(part, "W2BunkPaint", (px - t, 0.0, pz - t), (px + t, 1.62, pz + t), bevel=0.004)
			gbox(part, "W1Black", (px - t - 0.004, 0.0, pz - t - 0.004), (px + t + 0.004, 0.025, pz + t + 0.004), bevel=0.003)
	for top in DECKS:
		for side in (-1, 1):
			gbox(part, "W2BunkPaint", (cx + side * hx - t, top - 0.07, za + t), (cx + side * hx + t, top - 0.015, zb - t))
		for pz in (za, zb):
			gbox(part, "W2BunkPaint", (cx - hx + t, top - 0.07, pz - t), (cx + hx - t, top - 0.015, pz + t))
		for k in range(7):
			pz = za + 0.09 + k * (zb - za - 0.18) / 6
			gbox(part, "W1WoodPale", (cx - hx + t, top - 0.03, pz - 0.045), (cx + hx - t, top - 0.012, pz + 0.045), bevel=0.003)
	# Head and foot: two rails each between the posts (the top one low enough for Room310's Cam to see the head).
	for pz in (za, zb):
		for h in (0.62, 1.45):
			gbox(part, "W2BunkPaint", (cx - hx + t, h - 0.013, pz - 0.013), (cx + hx - t, h + 0.013, pz + 0.013))
	# The upper deck's guard rail on the room side, over the head half, on two drops.
	rx = cx + room_side * hx
	ga, gb = za + 0.06, BUNK_Z + 0.15
	gbox(part, "W2BunkPaint", (rx - 0.013, 1.40, ga), (rx + 0.013, 1.426, gb), bevel=0.004)
	for gz in (ga + 0.02, gb - 0.02):
		gbox(part, "W2BunkPaint", (rx - 0.011, DECKS[1] - 0.015, gz - 0.011), (rx + 0.011, 1.40, gz + 0.011))
	# The ladder at the foot end, on the room side.
	lx = rx + room_side * 0.03
	for lz in (zb - 0.36, zb - 0.06):
		gbox(part, "W2BunkPaint", (lx - 0.012, 0.0, lz - 0.012), (lx + 0.012, 1.44, lz + 0.012), bevel=0.003)
	for k in range(4):
		y = 0.3 + k * 0.28
		gbox(part, "W2BunkPaint", (lx - 0.01, y - 0.01, zb - 0.36), (lx + 0.01, y + 0.01, zb - 0.06))


def bunks():
	part = K.Part("Bunks")
	bunk(part, BUNKS[0], 1)
	bunk(part, BUNKS[1], -1)
	return K.build(part)


def locker(part, x0, x1, z0, z1, door_x, facing):
	"""Wave 2's two-door steel locker (build_hall.locker) inside the PS1 locker's footprint, doors towards the room."""
	gbox(part, "W2LockerPaint", (x0, 0.06, z0), (x1, 1.74, z1), bevel=0.006)
	gbox(part, "W1Black", (x0 + 0.03, 0.0, z0 + 0.03), (x1 - 0.03, 0.06, z1 - 0.03))
	zc = (z0 + z1) / 2
	f0, f1 = (door_x, door_x + 0.008) if facing > 0 else (door_x - 0.008, door_x)
	for k, (a, b) in enumerate(((z0 + 0.01, zc - 0.004), (zc + 0.004, z1 - 0.01))):
		gbox(part, "W2LockerPaint", (f0, 0.09, a), (f1, 1.71, b), bevel=0.003)
		for v in range(5):
			h = 1.46 + v * 0.035
			l0, l1 = (f1 - 0.002, f1 + 0.0015) if facing > 0 else (f0 - 0.0015, f0 + 0.002)
			gbox(part, "W1Black", (l0, h, a + 0.05), (l1, h + 0.012, b - 0.05))
		hz = b - 0.035 if k == 0 else a + 0.035
		h0, h1 = (f1, f1 + 0.017) if facing > 0 else (f0 - 0.017, f0)
		gbox(part, "W1Steel", (h0, 0.92, hz - 0.008), (h1, 1.07, hz + 0.008))


def lockers():
	part = K.Part("Lockers")
	for z0, z1 in LOCKERS_Z:
		locker(part, 0.06, 0.58, z0, z1, 0.58, 1)
		locker(part, 3.42, 3.94, z0, z1, 3.42, -1)
	return K.build(part)


def export(name, objs):
	w1kit.export(OUT / name, objs)


def main():
	K.materials()
	export("cctv_room.glb", [shell(), back_plain(), back_balcony(), door_frame(), night_lamp()])
	K.reset()
	K.materials()
	export("cctv_hall.glb", [hall(), balustrade(), parapet(), batten(), night()])
	K.reset()
	K.materials()
	export("cctv_light_set.glb", [bunks(), lockers()])


main()
