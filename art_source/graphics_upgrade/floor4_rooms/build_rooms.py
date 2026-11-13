"""T-255 (D-168): the shells of rooms 401-406 and 408, as deep as room 407 and in room 407's style (its shell
shader, its plaster, floor tiles, bathroom tiles, the same green door frames), one glb per room in Floor4 metres:
  room_<n>.glb   Interior   walls, floor, ceiling, skirting, the bathroom (tiles to 1.8 m, anti-slip floor, drain,
                            a louvred window to the balcony), the room side of the door frame, the bathroom and
                            balcony door frames (the leaves are room 407's Tripo leaves, hung by the scene)
                 Exterior   the back facade (up to floor 5's slab), the balcony floor, parapet and coping, the
                            divider walls, the soffit and the slab edges
The scene draws Interior only while the room's door is open or the player is inside (floor4_rooms.gd); Exterior
always (it is the building's back face). Nothing here has collision: floor4_rooms.tscn carries the colliders.
Run with Blender 5.2.2 from the repository root:
  blender -b --factory-startup -P art_source/graphics_upgrade/floor4_rooms/build_rooms.py [-- 401 402 ...]
"""
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[0] / "realistic_map" / "wave2"))
sys.path.insert(0, str(HERE))
import w2kit as K  # noqa: E402
from w2kit import G, gbox  # noqa: E402
import rooms_layout as L  # noqa: E402

OUT = K.w1kit.ROOT / "game/assets/models/graphics_pilot/floor4_rooms"
K.SIZES.update({"F4Wall": 2.0, "F4Ceiling": 2.0, "F4Exterior": 2.0, "F4BalconyFloor": 1.5, "F4BathTiles": 1.27})
PERIOD = {"F4Wall": 2.0, "F4Ceiling": 2.0, "F4Floor": 1.9, "F4Skirting": 1.9, "F4BathFloor": 1.8, "F4Exterior": 2.0,
	"F4BalconyFloor": 1.5, "F4BathTiles": 1.27}
ROTATE = {"F4Floor": 45.0, "F4Skirting": 45.0}
PREVIEW = {"F4Wall": (0.72, 0.66, 0.52), "F4Ceiling": (0.8, 0.78, 0.7), "F4Floor": (0.75, 0.62, 0.5),
	"F4Skirting": (0.75, 0.62, 0.5), "F4BathFloor": (0.55, 0.42, 0.33), "F4Exterior": (0.78, 0.72, 0.55),
	"F4BalconyFloor": (0.6, 0.48, 0.38), "F4BathTiles": (0.86, 0.85, 0.8), "F4FrameGreen": (0.12, 0.3, 0.2),
	"F4Alu": (0.75, 0.75, 0.73), "F4Louvre": (0.6, 0.65, 0.62), "F4Drain": (0.5, 0.5, 0.5),
	"F4Enamel": (0.78, 0.75, 0.64), "F4TubeGlass": (0.92, 0.94, 0.9), "F4Wire": (0.2, 0.2, 0.19)}
SKIRT_H, SKIRT_T = 0.1, 0.008
TILE_TOP, TILE_T = 1.8, 0.008
ARCH_W, ARCH_T = 0.07, 0.018
COVER = 0.003
CLOTHESLINE_Z = -3.72  # the room's line (between the bunks' feet and the bathroom's front wall), at y 2.6
BALCONY_LINE = (-7.85, 2.17)  # the balcony's line (z, y), as room 407's


def materials():
	K.materials()
	for name, colour in PREVIEW.items():
		K.material(name, colour, 0.6, 0.6 if name in ("F4Alu", "F4Drain") else 0.0)


def plane(part, mat, origin, u, v, w, h, holes=(), uv2=None, period=None, rot=0.0, seed=0):
	"""A rectangle origin + a*u + b*v (a 0..w, b 0..h; Godot vectors, the face looks along u x v) with rectangular
	holes [(a0, b0, a1, b1)], UV1 in scan repeats (rotated by `rot` degrees), UV2 from uv2(a, b)."""
	cuts_a = sorted({0.0, w} | {c for hole in holes for c in (hole[0], hole[2]) if 0.0 < c < w})
	cuts_b = sorted({0.0, h} | {c for hole in holes for c in (hole[1], hole[3]) if 0.0 < c < h})
	faces = []
	period = period or PERIOD.get(mat, 1.0)
	r = math.radians(rot)
	off = ((seed * 0.37) % 1.0, (seed * 0.61) % 1.0)
	normal = (u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0])

	def at(a, b):
		return tuple(origin[i] + u[i] * a + v[i] * b for i in range(3))
	for a0, a1 in zip(cuts_a, cuts_a[1:]):
		for b0, b1 in zip(cuts_b, cuts_b[1:]):
			am, bm = (a0 + a1) / 2, (b0 + b1) / 2
			if any(h0 <= am <= h2 and h1 <= bm <= h3 for h0, h1, h2, h3 in holes):
				continue
			f = K.quad(part, mat, at(a0, b0), at(a1, b0), at(a1, b1), at(a0, b1), normal)
			for loop in f.loops:
				co = loop.vert.co
				# Back to (a, b) from the Blender point: Godot p = (co.x, co.z, -co.y).
				p = (co.x, co.z, -co.y)
				d = tuple(p[i] - origin[i] for i in range(3))
				a = sum(d[i] * u[i] for i in range(3))
				b = sum(d[i] * v[i] for i in range(3))
				ra, rb = a * math.cos(r) - b * math.sin(r), a * math.sin(r) + b * math.cos(r)
				loop[part.uv].uv = (ra / period + off[0], rb / period + off[1])
			K.keep_uv(part, [f])
			if uv2 is not None:
				part.set_uv2([f], lambda co, origin=origin, u=u, v=v: uv2(*_ab(co, origin, u, v)))
			faces.append(f)
	return faces


def _ab(co, origin, u, v):
	p = (co.x, co.z, -co.y)
	d = tuple(p[i] - origin[i] for i in range(3))
	return sum(d[i] * u[i] for i in range(3)), sum(d[i] * v[i] for i in range(3))


PX, NX, PY, NY, PZ, NZ = (1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)


# ---------------------------------------------------------------- interior

def interior(room):
	part = K.Part("Interior")
	sc = L.scales(room)
	runs, _ = L.wall_runs(room)
	bruns, _ = L.bath_runs(room)
	x0, x1 = room.x0 + COVER, room.x1 - COVER
	front, back = L.WALL_ROOM - COVER, L.BACK_IN + COVER
	bx0, bx1 = room.bath
	bfront_room = L.BATH_FRONT_ROOM + COVER  # room face of the bathroom's front wall
	bath_east = room.bath_side == "east"
	part_x = (bx0 - 0.1 - COVER) if bath_east else (bx1 + 0.1 + COVER)  # room face of the bathroom partition
	seed = int(room.number)

	def wall_uv(run, flip=False):
		p0, length = runs[run]
		return lambda a, b: L.to_uv(room, L.RECT_WALLS, p0 + (length - a if flip else a), b, sc["walls"])

	door = (room.door_x + L.DOOR[0] - 0.02, room.door_x + L.DOOR[1] + 0.02, L.DOOR[2] + 0.02)
	H = L.CEILING - COVER
	# Front wall (the corridor wall's room face), seen from the room (normal +z... the face looks -z into the room?)
	# Faces look into the room: the front wall's normal is -z, so u = -x, v = +y, origin at x1.
	plane(part, "F4Wall", (x1, 0, front), NX, PY, x1 - x0, H, [(x1 - door[1], 0, x1 - door[0], door[2])],
		wall_uv("front"), seed=seed)
	# Side walls: east (normal -x: u = +z... looking from the room at the east wall, u runs along -z from the front)
	east_end = bfront_room if bath_east else back
	west_end = back if bath_east else bfront_room
	plane(part, "F4Wall", (x1, 0, east_end), PZ, PY, front - east_end, H, (), wall_uv("east"), seed=seed + 1)
	plane(part, "F4Wall", (x0, 0, front), NZ, PY, front - west_end, H, (), wall_uv("west"), seed=seed + 2)
	# Back wall, room part only (the bathroom has its own), with the balcony door.
	bd = room.balcony_door
	if bath_east:
		bw0, bw1 = x0, part_x
	else:
		bw0, bw1 = part_x, x1
	plane(part, "F4Wall", (bw0, 0, back), PX, PY, bw1 - bw0, H, [(bd[0] - bw0, 0, bd[1] - bw0, L.BALCONY_DOOR_TOP)],
		wall_uv("back"), seed=seed + 3)
	# The bathroom's partition and front wall, room faces.
	if bath_east:
		plane(part, "F4Wall", (part_x, 0, back), PZ, PY, bfront_room - back, H, (), wall_uv("bathside"), seed=seed + 4)
		fx0, fx1 = part_x, x1
	else:
		plane(part, "F4Wall", (part_x, 0, bfront_room), NZ, PY, bfront_room - back, H, (), wall_uv("bathside"), seed=seed + 4)
		fx0, fx1 = x0, part_x
	bdoor = room.bath_door
	plane(part, "F4Wall", (fx0, 0, bfront_room), PX, PY, fx1 - fx0, H,
		[(bdoor[0] - fx0, 0, bdoor[1] - fx0, L.BATH_DOOR_TOP)], wall_uv("bathfront"), seed=seed + 5)
	# Floor (room part), its skirting, the ceiling over room and bathroom.
	floor_uv = lambda a, b: L.to_uv(room, L.RECT_FLOOR, a, b, sc["floor"])  # noqa: E731
	plane(part, "F4Floor", (x0, 0, front), PX, NZ, x1 - x0, front - bfront_room, (), floor_uv, rot=45.0, seed=seed)
	if bath_east:
		plane(part, "F4Floor", (x0, 0, bfront_room), PX, NZ, part_x - x0, bfront_room - back,
			(), lambda a, b: floor_uv(a, b + front - bfront_room), rot=45.0, seed=seed)
	else:
		plane(part, "F4Floor", (part_x, 0, bfront_room), PX, NZ, x1 - part_x, bfront_room - back,
			(), lambda a, b: floor_uv(a + part_x - x0, b + front - bfront_room), rot=45.0, seed=seed)
	ceil_uv = lambda a, b: L.to_uv(room, L.RECT_CEILING, a, b, sc["ceiling"])  # noqa: E731
	plane(part, "F4Ceiling", (x0, H, back), PX, PZ, x1 - x0, front - back, (), ceil_uv, seed=seed)
	skirting(part, room, x0, x1, front, back, part_x, bfront_room, door, bath_east)
	fittings(part, room)
	bathroom(part, room, bruns, sc, seed)
	frames(part, room, part_x, bfront_room, door)
	return K.build(part)


def fittings(part, room):
	"""Room 407's fittings: a fluorescent batten across the ceiling over the bunks' feet (switched off), the light
	switch inside the door, the room's clothesline from wall to wall in front of the bathroom."""
	cx = (room.x0 + room.x1) / 2
	H = L.CEILING
	gbox(part, "F4Enamel", (cx - 0.62, H - 0.05, -3.24), (cx + 0.62, H, -3.16), bevel=0.006)
	gbox(part, "F4TubeGlass", (cx - 0.6, H - 0.075, -3.213), (cx + 0.6, H - 0.05, -3.187))
	for end in (-0.6, 0.6):
		gbox(part, "F4Alu", (cx + end - 0.02, H - 0.08, -3.22), (cx + end + 0.02, H - 0.05, -3.18))
	sx = room.door_x + (L.DOOR[1] + 0.2 if room.bath_side == "west" else L.DOOR[0] - 0.2)
	gbox(part, "F4Enamel", (sx - 0.04, 1.26, L.WALL_ROOM - 0.012), (sx + 0.04, 1.38, L.WALL_ROOM), bevel=0.003)
	gbox(part, "W1Black", (sx - 0.01, 1.3, L.WALL_ROOM - 0.016), (sx + 0.01, 1.34, L.WALL_ROOM - 0.012))
	gbox(part, "F4Wire", (room.x0, 2.597, CLOTHESLINE_Z - 0.003), (room.x1, 2.603, CLOTHESLINE_Z + 0.003))
	for x in (room.x0, room.x1):
		inward = 0.03 if x == room.x0 else -0.03
		gbox(part, "F4Wire", (min(x, x + inward), 2.59, CLOTHESLINE_Z - 0.006), (max(x, x + inward), 2.61, CLOTHESLINE_Z + 0.006))


def skirting(part, room, x0, x1, front, back, part_x, bfront, door, bath_east):
	"""Tile skirting 0.1 m high, 8 mm proud, round the room part (not across the doorways)."""
	runs = []
	bd, bdd = room.balcony_door, room.bath_door
	# (x0, z0) -> (x1, z1) along a wall face, the room side to the left of the run.
	runs.append(((x1, front), (door[1] + ARCH_W, front)))
	runs.append(((door[0] - ARCH_W, front), (x0, front)))
	if bath_east:
		runs.append(((x0, front), (x0, back)))
		runs.append(((x0, back), (bd[0], back)))
		runs.append(((bd[1], back), (part_x, back)))
		runs.append(((part_x, back), (part_x, bfront)))
		runs.append(((part_x, bfront), (bdd[0] - 0.06, bfront)))
		runs.append(((bdd[1] + 0.06, bfront), (x1, bfront)))
		runs.append(((x1, bfront), (x1, front)))
	else:
		runs.append(((x0, front), (x0, bfront)))
		runs.append(((x0, bfront), (bdd[0] - 0.06, bfront)))
		runs.append(((bdd[1] + 0.06, bfront), (part_x, bfront)))
		runs.append(((part_x, bfront), (part_x, back)))
		runs.append(((part_x, back), (bd[0], back)))
		runs.append(((bd[1], back), (x1, back)))
		runs.append(((x1, back), (x1, front)))
	for (ax, az), (bx, bz) in runs:
		length = math.hypot(bx - ax, bz - az)
		if length < 0.02:
			continue
		ux, uz = (bx - ax) / length, (bz - az) / length
		# Into the room: the run's left (the room is to the left walking the runs as listed).
		nx, nz = -uz, ux
		lo = (min(ax, bx) + (nx * SKIRT_T if nx < 0 else 0.0), 0.0, min(az, bz) + (nz * SKIRT_T if nz < 0 else 0.0))
		hi = (max(ax, bx) + (nx * SKIRT_T if nx > 0 else 0.0), SKIRT_H, max(az, bz) + (nz * SKIRT_T if nz > 0 else 0.0))
		faces = gbox(part, "F4Skirting", lo, hi)
		for f in faces:
			for loop in f.loops:
				co = loop.vert.co
				loop[part.uv].uv = ((co.x + co.y) / 1.9, co.z / 1.9 + 0.075)
		K.keep_uv(part, faces)


def bathroom(part, room, bruns, sc, seed):
	"""Tiles to 1.8 m on its four walls (plaster above), the anti-slip floor, a drain, a louvred window high in the
	back wall onto the balcony."""
	bx0, bx1 = room.bath[0] + COVER, room.bath[1] - COVER
	bfront, back = L.BATH_FRONT_IN - COVER, L.BACK_IN + COVER
	H = L.CEILING - COVER
	bdoor = room.bath_door
	win = room.window

	def buv(run):
		p0, _ = bruns[run]
		return lambda a, b: L.to_uv(room, L.RECT_BATH, p0 + a, b, sc["bath"])
	walls = [  # (run, origin, u, length, holes)
		("front", (bx1, 0, bfront), NX, bx1 - bx0, [(bx1 - bdoor[1], 0, bx1 - bdoor[0], L.BATH_DOOR_TOP)]),
		("east", (bx1, 0, back), PZ, bfront - back, []),
		("back", (bx0, 0, back), PX, bx1 - bx0, [(win[0] - bx0, win[2], win[1] - bx0, win[3])]),
		("west", (bx0, 0, bfront), NZ, bfront - back, []),
	]
	for run, origin, u, length, holes in walls:
		# Plaster above the tiles, tiles 8 mm proud below (both cut round the openings).
		upper = [(a0, max(b0, TILE_TOP) - TILE_TOP, a1, b1 - TILE_TOP) for a0, b0, a1, b1 in holes if b1 > TILE_TOP]
		o_up = tuple(origin[i] + PY[i] * TILE_TOP for i in range(3))
		plane(part, "F4Wall", o_up, u, PY, length, H - TILE_TOP, upper,
			lambda a, b, f=buv(run): f(a, b + TILE_TOP), seed=seed + 7)
		n = (u[1] * 0 - u[2] * 1, u[2] * 0 - u[0] * 0, u[0] * 1 - u[1] * 0)  # u x +y
		o_tile = tuple(origin[i] + n[i] * TILE_T for i in range(3))
		lower = [(a0, b0, a1, min(b1, TILE_TOP)) for a0, b0, a1, b1 in holes if b0 < TILE_TOP]
		plane(part, "F4BathTiles", o_tile, u, PY, length, TILE_TOP, lower, None, period=1.27)
		# The tiles' top bullnose.
		a = tuple(o_tile[i] + PY[i] * TILE_TOP for i in range(3))
		b = tuple(a[i] + u[i] * length for i in range(3))
		lo = tuple(min(a[i], b[i]) - (0.006 if i != 1 and abs(n[i]) < 0.5 else 0.0) for i in range(3))
		hi = tuple(max(a[i], b[i]) + (0.012 if i == 1 else 0.0) for i in range(3))
		lo = tuple(lo[i] + (min(0.0, n[i] * 0.006) if abs(n[i]) > 0.5 else 0.0) for i in range(3))
		hi = tuple(hi[i] + (max(0.0, n[i] * 0.006) if abs(n[i]) > 0.5 else 0.0) for i in range(3))
		gbox(part, "F4BathTiles", lo, hi)
	plane(part, "F4BathFloor", (bx0, 0.0, bfront), PX, NZ, bx1 - bx0, bfront - back, (),
		lambda a, b: L.to_uv(room, L.RECT_FLOOR, a + L.SECOND_SURFACE_AT, b, sc["floor"]), seed=seed)
	cx, cz = (bx0 + bx1) / 2, back + 0.6
	gbox(part, "F4Drain", (cx - 0.07, 0.0, cz - 0.07), (cx + 0.07, 0.003, cz + 0.07))
	for k in range(5):
		gbox(part, "W1Black", (cx - 0.05, 0.0031, cz - 0.05 + k * 0.025), (cx + 0.05, 0.0034, cz - 0.04 + k * 0.025))
	# Louvred window onto the balcony: aluminium frame, five frosted blades, its plastered reveals.
	wz0, wz1 = L.BACK_OUT, L.BACK_IN
	for xa, xb in ((win[0], win[0] + 0.03), (win[1] - 0.03, win[1])):
		gbox(part, "F4Alu", (xa, win[2], (wz0 + wz1) / 2 - 0.03), (xb, win[3], (wz0 + wz1) / 2 + 0.03))
	for ya, yb in ((win[2], win[2] + 0.03), (win[3] - 0.03, win[3])):
		gbox(part, "F4Alu", (win[0], ya, (wz0 + wz1) / 2 - 0.03), (win[1], yb, (wz0 + wz1) / 2 + 0.03))
	# Blades tilted 40 degrees (out and down for the rain), each overlapping the next: no view through.
	zm = (wz0 + wz1) / 2
	for k in range(5):
		y = win[2] + 0.07 + k * 0.088
		xa, xb = win[0] + 0.03, win[1] - 0.03
		hi_in, lo_out = (y + 0.034, zm + 0.04), (y - 0.034, zm - 0.04)
		for facing, dy in (((0.0, 0.76, -0.65), 0.0), ((0.0, -0.76, 0.65), -0.004)):
			K.quad(part, "F4Louvre", (xa, hi_in[0] + dy, hi_in[1]), (xb, hi_in[0] + dy, hi_in[1]),
				(xb, lo_out[0] + dy, lo_out[1]), (xa, lo_out[0] + dy, lo_out[1]), facing)
	gbox(part, "F4Wall", (win[0] - 0.01, win[2] - 0.01, wz0), (win[1] + 0.01, win[2], wz1))
	gbox(part, "F4Wall", (win[0] - 0.01, win[3], wz0), (win[1] + 0.01, win[3] + 0.01, wz1))
	gbox(part, "F4Wall", (win[0] - 0.01, win[2], wz0), (win[0], win[3], wz1))
	gbox(part, "F4Wall", (win[1], win[2], wz0), (win[1] + 0.01, win[3], wz1))


def frames(part, room, part_x, bfront_room, door):
	"""Green door frames as room 407's: the room side of the room door (the corridor builds the rest), the
	bathroom door (linings and architraves both faces) and the balcony door (aluminium frame in the wall)."""
	g = "F4FrameGreen"
	z = L.WALL_ROOM
	d0, d1, top = room.door_x + L.DOOR[0], room.door_x + L.DOOR[1], L.DOOR[2]
	for xa, xb in ((d0 - 0.02 - ARCH_W, d0 - 0.02), (d1 + 0.02, d1 + 0.02 + ARCH_W)):
		gbox(part, g, (xa, 0.0, z - ARCH_T), (xb, top + 0.02 + ARCH_W, z), bevel=0.003)
	gbox(part, g, (d0 - 0.02, top + 0.02, z - ARCH_T), (d1 + 0.02, top + 0.02 + ARCH_W, z), bevel=0.003)
	# Bathroom door: linings through the 0.15 m wall, architraves on the room face and the bathroom face.
	b0, b1, bt = room.bath_door[0], room.bath_door[1], L.BATH_DOOR_TOP
	zr, zi = L.BATH_FRONT_ROOM, L.BATH_FRONT_IN
	for xa, xb in ((b0, b0 + 0.02), (b1 - 0.02, b1)):
		gbox(part, g, (xa, 0.0, zi), (xb, bt, zr))
	gbox(part, g, (b0, bt - 0.02, zi), (b1, bt, zr))
	for zf, out in ((zr, 1), (zi, -1)):
		for xa, xb in ((b0 - ARCH_W, b0), (b1, b1 + ARCH_W)):
			gbox(part, g, (xa, 0.0, min(zf, zf + out * ARCH_T)), (xb, bt + ARCH_W, max(zf, zf + out * ARCH_T)), bevel=0.003)
		gbox(part, g, (b0, bt, min(zf, zf + out * ARCH_T)), (b1, bt + ARCH_W, max(zf, zf + out * ARCH_T)), bevel=0.003)
	# Balcony door: an aluminium frame in the middle of the wall, plastered reveals either side.
	a0, a1, at = room.balcony_door[0], room.balcony_door[1], L.BALCONY_DOOR_TOP
	zo, zb = L.BACK_OUT, L.BACK_IN
	zm = (zo + zb) / 2
	for xa, xb in ((a0, a0 + 0.045), (a1 - 0.045, a1)):
		gbox(part, "F4Alu", (xa, 0.0, zm - 0.03), (xb, at, zm + 0.03))
	gbox(part, "F4Alu", (a0, at - 0.045, zm - 0.03), (a1, at, zm + 0.03))
	gbox(part, "F4Alu", (a0, 0.0, zo + 0.01), (a1, 0.02, zb - 0.01))
	for xa in (a0, a1):
		gbox(part, "F4Wall", (xa - (0.004 if xa == a0 else 0.0), 0.02, zo), (xa + (0.004 if xa == a1 else 0.0), at, zb))
	gbox(part, "F4Wall", (a0, at, zo), (a1, at + 0.004, zb))


# ---------------------------------------------------------------- exterior

def exterior(room):
	part = K.Part("Exterior")
	sc = L.scales(room)
	west, east = room.west, (room.east if room.number != "408" else 44.0)
	ext_uv = lambda a, b: L.to_uv(room, L.RECT_EXT, a, b, sc["ext"])  # noqa: E731
	zo = L.BACK_OUT - COVER
	bd = room.balcony_door
	bx0, bx1 = room.bath
	win = room.window
	# The back facade seen from the balcony (normal -z): u = -x from the east end; up to floor 5's slab.
	holes = [(east - bd[1], 0.0, east - bd[0], L.BALCONY_DOOR_TOP), (east - win[1], win[2], east - win[0], win[3])]
	plane(part, "F4Exterior", (east, 0.0, zo), NX, PY, east - west, L.EXT_H, holes, ext_uv, seed=int(room.number))
	# Balcony: floor (a step down of 2 cm for the rain), parapet faces and coping, dividers, soffit, slab edges.
	bw0, bw1 = west + 0.06, east - 0.06
	floor_y = -0.02
	plane(part, "F4BalconyFloor", (bw0, floor_y, L.BACK_OUT), PX, NZ, bw1 - bw0, L.BACK_OUT - L.BALCONY_OUT, (),
		lambda a, b: L.to_uv(room, L.RECT_CEILING, a + L.SECOND_SURFACE_AT, b, sc["ceiling"]))
	gbox(part, "F4Exterior", (west - 0.06, -0.2, L.BACK_OUT), (east + 0.06, floor_y, L.PARAPET_OUT))
	gbox(part, "F4Exterior", (bw0, floor_y, L.BALCONY_OUT), (bw1, 1.1, L.PARAPET_OUT))
	gbox(part, "F4BalconyFloor", (west - 0.06, 1.1, L.BALCONY_OUT + 0.03), (east + 0.06, 1.15, L.PARAPET_OUT - 0.03), bevel=0.01)
	# Dividers between balconies (each room its west one; 408 also its east end; 406's east one is room 407's).
	divs = [west]
	if room.number == "408":
		divs.append(east)
	for dx in divs:
		gbox(part, "F4Exterior", (dx - 0.06, floor_y, L.BACK_OUT), (dx + 0.06, 2.0, L.PARAPET_OUT))
	# The soffit over the balcony (floor 5's slab) and its edge band.
	gbox(part, "F4Exterior", (west - 0.06, L.CEILING, L.BACK_OUT), (east + 0.06, L.EXT_H, L.PARAPET_OUT - 0.05))
	# The balcony's clothesline from divider to divider.
	gbox(part, "F4Wire", (bw0, BALCONY_LINE[1] - 0.003, BALCONY_LINE[0] - 0.003), (bw1, BALCONY_LINE[1] + 0.003, BALCONY_LINE[0] + 0.003))
	# A drain spout through the parapet foot.
	gbox(part, "W1Iron", ((bw0 + bw1) / 2 - 0.03, -0.01, L.BALCONY_OUT - 0.02), ((bw0 + bw1) / 2 + 0.03, 0.02, L.PARAPET_OUT - 0.1))
	return K.build(part)


def main():
	materials()
	which = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [r.number for r in L.ROOMS]
	for number in which:
		room = L.ROOM[number]
		K.w1kit.export(OUT / ("room_%s.glb" % number), [interior(room), exterior(room)])
		K.reset()
		materials()


main()
