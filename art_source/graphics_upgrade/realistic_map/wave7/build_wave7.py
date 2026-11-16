"""T-264 round 2 (D-182): the buildings. Blender 5.2.2, bmesh only, no add-on, no Tripo. Uses build_wave7_pilot.py's
pieces with the owner's picks: fake rooms behind every window (b), building A as a windowed wall (A2), the canteen's
yellow, the lecture hall's flat roof with concrete louvres (R1), the gym's corrugated vault (R2). Every glb sits at
Godot (0, G, 0) in world space but figure.glb (see below).

Rules (card section 1, D-182; section 4): nothing of a front goes deeper than 0.45 m behind the wall's face (the core's
occluders fill each shell from 0.5 m in); under head height nothing stands more than 0.15 m out from the colliders
(plinths, sills, pilasters); canopies and louvres start above 2.4 m.

  bldga.glb           building A: the whole front (8 bays x 6 floors), the glazed entrance under a cantilevered canopy,
                      bands, pilasters, sills, grilles, AC units, laundry; fake dorm rooms (Fake) behind clear glass
                      (Glass) in every window but the three figures'; sides, back (small dark windows), roof
  figure.glb          a dark figure standing behind a window with a pale drawn curtain behind it, in the frame of its
                      WindowSilhouette node (origin = the node; its window's glass and fake room are left out)
  lecture.glb         the lecture hall: 16 bays x 5 floors of classrooms (fake), the entrance at x -10, vertical concrete
                      louvres from 2.4 m, sunshade hoods, flat roof behind a parapet
  gym.glb             the gym: tall windows between pilasters (fake hall), steel doors under a canopy at x -30, the
                      corrugated vault with arched gables
  b_outside.glb       building B: floors 5-6 front as blocked corridors behind railings (z 0.45..4), the back of floors
                      1-3 and 5-6 with flush windows (fake rooms), the main roof (floor 4 and the stair towers keep theirs)
  bldga_light.glb     chapters 1-2's light building A (D-182 item 9): the A2 shell with dark glass, no fake rooms, no
                      grilles, no figures (garden_backdrop.tscn)
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave7/build_wave7.py [-- name ...]
"""
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import build_wave7_pilot as P  # noqa: E402  (its main is guarded)
import wave7_layout as L  # noqa: E402

w1kit, GPart, B, G = P.w1kit, P.GPart, P.B, P.G
build, export, keep, pal, quad_x, fake_room = P.build, P.export, P.keep, P.pal, P.quad_x, P.fake_room
wall_face, reveal, window_frame, grille, ac_unit, laundry = P.wall_face, P.reveal, P.window_frame, P.grille, P.ac_unit, P.laundry
FH = L.FLOOR_H
# The three figures' windows of building A (floor 3): WindowSilhouette0 x 7, 1 x 18, 2 moved to x 32 (D-182 item 8).
FIGURE_WINDOWS = {(2, 7.5), (2, 17.5), (2, 32.5)}


def shell_front(walls, trim, frames, glass, fake, extras, bars, box, row, floors, windows_x, door_x, room_mat, rnd, light=False,
		figures=(), grilles=True):
	"""A shell's front on z = box z0: wall with windows on every floor, the entrance (3 m glazed doors, a fake lobby),
	bands, pilasters, plinth, parapet; sides, back (small dark windows) and the roof plain."""
	x0, x1 = box["x"]
	z0, z1 = box["z"]
	top = box["y"][1]
	zf = z0 - 0.004
	holes = []
	for k in range(floors):
		for x in windows_x:
			if k == 0 and abs(x - door_x) < 3.0:
				continue
			holes.append((x - 1.0, x + 1.0, G + 1.05 + FH * k, G + 2.55 + FH * k, k, x))
	door = (door_x - 1.5, door_x + 1.5, G, G + 2.8)
	wall_face(walls, "W7WallYellow", "x", zf, x0, x1, G - 0.05, top, [h[:4] for h in holes] + [door], (0, 0, -1), row, x0)
	for h in holes + [door]:
		reveal(walls, "W7WallYellow", "x", zf, 0.2, h[0], h[1], h[2], h[3], row, x0, -1)
	for xa, xb, ya, yb, k, x in holes:
		window_frame(frames, xa, xb, ya, yb, zf + 0.15, sashes=2)
		trim.gbox("W7Concrete", (xa - 0.08, ya - 0.06, zf - 0.06), (xb + 0.08, ya, zf + 0.2))
		if (k, x) in figures:
			quad_x(glass, "W2Glass", xa, xb, ya, yb, zf + 0.15, -1)   # the figure and its curtain are figure.glb
			continue
		if light:
			quad_x(glass, "W7GlassDark", xa, xb, ya, yb, zf + 0.15, -1)
			continue
		quad_x(glass, "W2Glass", xa, xb, ya, yb, zf + 0.15, -1)
		fake_room(fake, room_mat, xa, xb, ya, yb, zf + 0.3, -1)
		if k > 0 and grilles:
			grille(bars, xa, xb, ya, yb, zf - 0.02)
			if rnd.random() < 0.16:
				ac_unit(extras, xb + 0.6, ya + 0.2, zf, -1, rnd)
			if rnd.random() < 0.14:
				laundry(extras, xa, xb, yb - 0.1, zf, -1, rnd)
	# The entrance: closed glazed doors, a fanlight, the fake lobby behind; a cantilevered canopy from 3 m.
	window_frame(frames, door[0], door[1], G, G + 2.8, zf + 0.15, sashes=2, depth=0.08)
	frames.gbox("W1Alu", (door[0], G + 2.2, zf + 0.07), (door[1], G + 2.25, zf + 0.15))
	quad_x(glass, "W7GlassDark" if light else "W2Glass", door[0], door[1], G + 0.05, G + 2.75, zf + 0.12, -1)
	if not light:
		fake_room(fake, "W7RoomLobby", door[0], door[1], G, G + 2.8, zf + 0.3, -1)
	trim.gbox("W7Concrete", (door_x - 2.4, G + 3.0, zf - 1.6), (door_x + 2.4, G + 3.18, zf + 0.01))
	trim.gbox("W7Concrete", (door_x - 2.4, G + 3.18, zf - 1.6), (door_x + 2.4, G + 3.4, zf - 1.5))
	for k in range(1, floors):
		faces = trim.gbox("W7Trim", (x0 - 0.15, G + FH * k - 0.12, zf - 0.15), (x1 + 0.15, G + FH * k + 0.02, zf + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(row, q[0] - x0, q[1]))
	xs = [x0 + 5.0 * k for k in range(int((x1 - x0) / 5.0) + 1)]
	if xs[-1] < x1 - 0.01:
		xs.append(x1)
	for x in xs:
		faces = trim.gbox("W7Trim", (x - 0.2 if x > x0 else x, G - 0.05, zf - 0.12), (x + 0.2 if x < x1 else x, top, zf + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(row, q[0] - x0, q[1]))
	faces = trim.gbox("W7Trim", (x0 - 0.15, top, z0 - 0.15), (x1 + 0.15, top + 0.7, z1 + 0.15))
	trim.map_uv2(faces, lambda q: L.facade_uv2(row, q[0] - x0, top - 0.3))
	trim.gbox("W1Concrete", (x0 - 0.2, top + 0.7, z0 - 0.2), (x1 + 0.2, top + 0.76, z1 + 0.2))
	faces = trim.gbox("W7Concrete", (x0 - 0.05, G - 0.05, zf - 0.05), (x1 + 0.05, G + 0.35, zf + 0.01))
	trim.map_uv2(faces, lambda q: L.facade_uv2(row, q[0] - x0, q[1]))
	# Sides plain, the back with small dark windows (within 0.1 m of its face), the roof.
	wall_face(walls, "W7WallYellow", "z", x0 - 0.004, z0, z1, G - 0.05, top, [], (-1, 0, 0), row, z0)
	wall_face(walls, "W7WallYellow", "z", x1 + 0.004, z0, z1, G - 0.05, top, [], (1, 0, 0), row, z0)
	back = [(x - 0.6, x + 0.6, G + 1.6 + FH * k, G + 2.4 + FH * k) for k in range(floors) for x in windows_x]
	wall_face(walls, "W7WallYellow", "x", z1 + 0.004, x0, x1, G - 0.05, top, back, (0, 0, 1), row, x0)
	for h in back:
		quad_x(glass, "W7GlassDark", h[0], h[1], h[2], h[3], z1 - 0.1, 1)
		reveal(walls, "W7WallYellow", "x", z1 + 0.004, 0.1, *h, row, x0, 1)
	walls.face("W1Concrete", [(x0, top, z0), (x1, top, z0), (x1, top, z1), (x0, top, z1)], (0, 1, 0))
	return zf


def _parts():
	return [GPart(n) for n in ("Walls", "Trim", "Frames", "Glass", "Fake", "Extras", "Bars")]


def _export(name, parts):
	out = []
	for p in parts:
		if p.bm.faces:
			p.bm.normal_update()
			out.append(build(p, {"W1Concrete": 0.8, "W1Alu": 1.0, "W1Iron": 1.0, "W7Palette": 1.0}))
	export(name, out)


def build_bldga(light=False):
	w1kit.reset()
	rnd = random.Random(26421)
	walls, trim, frames, glass, fake, extras, bars = parts = _parts()
	a = L.BUILDING_A
	shell_front(walls, trim, frames, glass, fake, extras, bars, a, 0, a["floors"], a["windows_x"], a["door_x"], "W7RoomDorm", rnd,
		light=light, figures=() if light else FIGURE_WINDOWS, grilles=not light)
	if light:
		# The figures' windows get dark glass too (no figure in chapters 1-2).
		for k, x in FIGURE_WINDOWS:
			quad_x(glass, "W7GlassDark", x - 1.0, x + 1.0, G + 1.05 + FH * k, G + 2.55 + FH * k, a["z"][0] - 0.004 + 0.15, -1)
	_export("bldga_light.glb" if light else "bldga.glb", parts)


def build_figure():
	"""In a WindowSilhouette node's frame (origin at the node: x of the figure, y -1.9, z 53.8): the figure stands on
	floor 3 (y -3.3, so local -1.4) 0.25 m behind the wall's face (z 54), a pale curtain 0.42 m behind it (inside the
	0.45 m the occluders leave), 3.2 m wide so it fills the 2 m window with the figure up to 0.6 m off its middle."""
	w1kit.reset()
	rnd = random.Random(26422)
	part = GPart("Figure")
	ny, nz = -3.3 - (-1.9), 54.0 - 53.8
	m = Matrix.Translation(Vector((0.0, -(nz + 0.25), ny)))   # local Godot (x, y, z) -> Blender (x, -z, y)
	for lo, hi in (((-0.11, 0.0, -0.06), (-0.02, 0.85, 0.05)), ((0.02, 0.0, -0.06), (0.11, 0.85, 0.05)), ((-0.2, 0.85, -0.08), (0.2, 1.42, 0.07)),
			((-0.27, 0.95, -0.05), (-0.2, 1.4, 0.04)), ((0.2, 0.95, -0.05), (0.27, 1.4, 0.04)), ((-0.05, 1.42, -0.04), (0.05, 1.5, 0.04))):
		f = part.box("W7Palette", (lo[0], -hi[2], lo[1]), (hi[0], -lo[2], hi[1]), bevel=0.03, segments=1, matrix=m)
		pal(part, f, "silhouette", rnd)
	f = part.cylinder("W7Palette", (0.0, 0.0, 1.62), 0.105, 0.24, segments=10, matrix=m)
	pal(part, f, "silhouette", rnd)
	ya = ny + 1.05
	f = quad_x(part, "W7Palette", -1.6, 1.6, ya + G, ya + 1.5 + G, nz + 0.42, -1)   # quad_x goes through B() (y - G)
	pal(part, f, "curtain_beige", rnd)
	part.bm.normal_update()
	# Its root goes at the WindowSilhouette node itself (patch_wave7.py: position 0).
	export("figure.glb", [build(part, {"W7Palette": 1.0})])


def build_lecture():
	w1kit.reset()
	rnd = random.Random(26423)
	walls, trim, frames, glass, fake, extras, bars = parts = _parts()
	lec = L.LECTURE
	zf = shell_front(walls, trim, frames, glass, fake, extras, bars, lec, 2, lec["floors"], lec["windows_x"], lec["door_x"], "W7RoomClass",
		rnd, grilles=False)
	x0, x1 = lec["x"]
	top = lec["y"][1]
	# R1: vertical concrete louvres between windows (0.6 m out) from 2.4 m up, a sunshade hood over every window.
	for x in [x0 + 2.5 + 5.0 * k for k in range(16)]:
		for dx in (-1.35, 1.35):
			trim.gbox("W7Concrete", (x + dx - 0.06, G + 2.4, zf - 0.6), (x + dx + 0.06, top, zf - 0.01))
		for k in range(1, lec["floors"]):
			trim.gbox("W7Concrete", (x - 1.35, G + 2.6 + FH * k, zf - 0.6), (x + 1.35, G + 2.68 + FH * k, zf - 0.01))
	_export("lecture.glb", parts)


def build_gym():
	"""R2 (D-182): the pilot's vaulted gym with pilasters 0.12 m out at the foot (no deep fin in reach)."""
	w1kit.reset()
	rnd = random.Random(26424)
	walls, trim, frames, glass, fake, extras, bars = parts = _parts()
	g = L.GYM
	x0, x1 = g["x"]
	z0, z1 = g["z"]
	top = g["y"][1]
	zf = z0 - 0.004
	wins = [x for x in g["windows_x"] if abs(x - (-27.5)) > 0.1 and abs(x - (-32.5)) > 0.1]
	holes = [(x - 1.0, x + 1.0, G + 1.0, G + 6.5) for x in wins] + [(-31.8, -28.2, G, G + 3.0)]
	wall_face(walls, "W7WallYellow", "x", zf, x0, x1, G - 0.05, top, holes, (0, 0, -1), 1, x0)
	for h in holes:
		reveal(walls, "W7WallYellow", "x", zf, 0.25, *h, 1, x0, -1)
	for x in wins:
		window_frame(frames, x - 1.0, x + 1.0, G + 1.0, G + 6.5, zf + 0.15, sashes=2)
		for yb in (G + 2.8, G + 4.6):
			frames.gbox("W1Alu", (x - 1.0, yb - 0.03, zf + 0.1), (x + 1.0, yb + 0.03, zf + 0.15))
		quad_x(glass, "W2Glass", x - 1.0, x + 1.0, G + 1.0, G + 6.5, zf + 0.15, -1)
		fake_room(fake, "W7RoomGym", x - 1.0, x + 1.0, G + 1.0, G + 6.5, zf + 0.3, -1)
	for xa, xb in ((-31.8, -30.02), (-29.98, -28.2)):
		f = quad_x(frames, "W7Palette", xa, xb, G, G + 3.0, zf + 0.2, -1)
		pal(frames, f, "door_green", rnd)
	trim.gbox("W7Concrete", (-33.5, G + 3.3, zf - 2.0), (-26.5, G + 3.5, zf + 0.01))
	for x in [x0 + 5.0 * k for k in range(13)]:
		if abs(x - (-30.0)) < 0.1:
			continue
		xa, xb = max(x - 0.15, x0), min(x + 0.15, x1)   # the corners stay flush with the sides
		faces = trim.gbox("W7Trim", (xa, G - 0.05, zf - 0.12), (xb, top, zf + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(1, q[0] - x0, q[1]))
		trim.gbox("W7Trim", (xa, G + 2.4, zf - 0.45), (xb, top, zf - 0.12))
	faces = trim.gbox("W7Concrete", (x0, G - 0.05, zf - 0.05), (x1, G + 0.4, zf + 0.01))
	trim.map_uv2(faces, lambda q: L.facade_uv2(1, q[0] - x0, q[1]))
	east = [(z, z + 3.0, G + 6.0, G + 8.0) for z in (93.5, 101.5, 109.5, 117.5, 125.0)]
	wall_face(walls, "W7WallYellow", "z", x1 + 0.004, z0, z1, G - 0.05, top, east, (1, 0, 0), 1, z0 - 60.0)
	for h in east:
		walls.face("W7GlassDark", [(x1 - 0.1, h[2], h[0]), (x1 - 0.1, h[2], h[1]), (x1 - 0.1, h[3], h[1]), (x1 - 0.1, h[3], h[0])], (1, 0, 0))
		reveal(walls, "W7WallYellow", "z", x1 + 0.004, 0.1, *h, 1, z0 - 60.0, 1)
	wall_face(walls, "W7WallYellow", "z", x0 - 0.004, z0, z1, G - 0.05, top, [], (-1, 0, 0), 1, z0)
	wall_face(walls, "W7WallYellow", "x", z1 + 0.004, x0, x1, G - 0.05, top, [], (0, 0, 1), 1, x0)
	roof = GPart("Roof")
	segs, rise = 16, 5.0
	zs = [z0 - 0.4 + (z1 - z0 + 0.8) * k / segs for k in range(segs + 1)]

	def vy(z):
		t = (z - (z0 + z1) / 2) / ((z1 - z0) / 2 + 0.4)
		return top + rise * (1 - t * t)
	for za, zb in zip(zs, zs[1:]):
		roof.face("W4RoofSheet", [(x0 - 0.3, vy(za), za), (x1 + 0.3, vy(za), za), (x1 + 0.3, vy(zb), zb), (x0 - 0.3, vy(zb), zb)], (0, 1, 0))
		roof.face("W4RoofSheet", [(x0 - 0.3, vy(za) - 0.02, za), (x0 - 0.3, vy(zb) - 0.02, zb), (x1 + 0.3, vy(zb) - 0.02, zb), (x1 + 0.3, vy(za) - 0.02, za)], (0, -1, 0))
	for xg, nx in ((x0 - 0.004, -1), (x1 + 0.004, 1)):
		for za, zb in zip(zs, zs[1:]):
			if za < z0 or zb > z1:
				continue
			walls.face("W7WallYellow", [(xg, top, za), (xg, top, zb), (xg, vy(zb), zb), (xg, vy(za), za)], (nx, 0, 0))
	for zz in (z0 - 0.4, z1 + 0.4):
		roof.pipe("W4PoleSteel", [(x0 - 0.3, top + 0.02, zz), (x1 + 0.3, top + 0.02, zz)], 0.08, sides=6)
	_export("gym.glb", parts + [roof])


def build_b_outside():
	"""Building B's outside (D-182): floors 5-6 front corridors within z 0.45..4 (the occluders stop at z 0), the back's
	flush windows with fake rooms (not floor 4's), the main roof."""
	w1kit.reset()
	rnd = random.Random(26425)
	walls, trim, frames, glass, fake, extras, bars = parts = _parts()
	b = L.BUILDING_B
	x0, x1 = b["x"]
	zr, zb = b["front_z"], b["back_z"] - 0.004
	zi = 0.45
	for k in (4, 5):
		yk = G + FH * k
		faces = trim.gbox("W7Trim", (x0, yk - 0.25, zi), (x1, yk + 0.02, zr + 0.02))
		trim.map_uv2(faces, lambda q: L.facade_uv2(3, q[0] - x0, q[1]))
		walls.face("W1Terrazzo", [(x0, yk + 0.02, zi), (x1, yk + 0.02, zi), (x1, yk + 0.02, zr), (x0, yk + 0.02, zr)], (0, 1, 0))
		for yu in (yk - 0.25, yk + FH - 0.25):
			walls.face("W7Concrete", [(x0, yu, zi), (x1, yu, zi), (x1, yu, zr), (x0, yu, zr)], (0, -1, 0))
		bars.gbox("W1Iron", (x0, yk + 1.05, zr - 0.08), (x1, yk + 1.1, zr))
		bars.gbox("W1Iron", (x0, yk + 0.08, zr - 0.08), (x1, yk + 0.12, zr))
		for xb in [x0 + 0.12 * j for j in range(int((x1 - x0) / 0.12) + 1)]:
			bars.gbox("W1Iron", (xb - 0.006, yk + 0.12, zr - 0.05), (xb + 0.006, yk + 1.05, zr - 0.03))
		holes = []
		for x in b["upper_windows_x"]:
			holes.append((x - 1.6, x - 0.7, yk, yk + 2.2))
			holes.append((x - 0.4, x + 1.4, yk + 1.0, yk + 2.3))
			quad_x(glass, "W2Glass", x - 0.4, x + 1.4, yk + 1.0, yk + 2.3, zi - 0.15, 1)
			fake_room(fake, "W7RoomDorm", x - 0.4, x + 1.4, yk + 1.0, yk + 2.3, zi - 0.3, 1)
			f = quad_x(extras, "W7Palette", x - 1.6, x - 0.7, yk, yk + 2.2, zi - 0.05, 1)
			pal(extras, f, "door_green", rnd)
			for j in range(rnd.randrange(2, 5)):
				m = Matrix.Translation(B((x + rnd.uniform(-1.8, 1.8), yk + 0.15, rnd.uniform(zi + 0.4, zr - 0.6)))) @ Matrix.Rotation(rnd.uniform(0, 3), 4, "Z")
				s = rnd.uniform(0.2, 0.5)
				f = extras.box("W7Palette", (-s, -s * 0.7, -0.13), (s, s * 0.7, s * 0.6), bevel=0.04, segments=1, matrix=m)
				pal(extras, f, "concrete", rnd)
		wall_face(walls, "W7WallPale", "x", zi, x0, x1, yk, yk + FH - 0.25, holes, (0, 0, 1), 3, x0)
		for x in [x0 + 4.0 * j for j in range(12)]:
			faces = trim.gbox("W7Trim", (x - 0.15 if x > x0 else x, yk, zr - 0.3), (x + 0.15 if x < x1 else x, yk + FH, zr))
			trim.map_uv2(faces, lambda q: L.facade_uv2(3, q[0] - x0, q[1]))
	trim.gbox("W7Trim", (x0 - 0.1, G + 6 * FH - 0.3, b["back_z"] - 0.1), (x1 + 0.1, G + 6 * FH + 0.5, zr + 0.1))
	# The back (z -7.7): a face 4 mm out over floors 1-3 and 5-6, flush windows (frame, glass, fake room on the outside
	# face). Floor 4 keeps its own back (floor4_rooms.gd: facade, balconies, balcony doors; it is there in chapters 3-4).
	# The manager's room window (Floor1 WindowSill/WindowHeader, x 2..5.3; WindowExit) stays open.
	wall_face(walls, "W7WallPale", "x", zb, x0, x1, G - 0.05, G + 3 * FH, [(2.0, 5.3, -8.9, -7.46)], (0, 0, -1), 3, x0 - 44.0)
	wall_face(walls, "W7WallPale", "x", zb, x0, x1, G + 4 * FH, G + 6 * FH, [], (0, 0, -1), 3, x0 - 44.0)
	for k in (0, 1, 2, 4, 5):
		yk = G + FH * k
		for x in b["upper_windows_x"]:
			if k == 0 and x < 6.0:
				continue   # the manager's room window (WindowExit) stays as it is
			ya, yb = yk + 1.0, yk + 2.4
			fake_room(fake, "W7RoomDorm", x - 0.9, x + 0.9, ya, yb, zb - 0.006, -1)
			quad_x(glass, "W2Glass", x - 0.9, x + 0.9, ya, yb, zb - 0.012, -1)
			window_frame(frames, x - 0.9, x + 0.9, ya, yb, zb - 0.012, sashes=2, depth=-0.05)
			grille(bars, x - 0.9, x + 0.9, ya, yb, zb - 0.03)
			trim.gbox("W7Concrete", (x - 0.98, ya - 0.06, zb - 0.08), (x + 0.98, ya, zb + 0.01))
			if k > 0 and rnd.random() < 0.2:   # none on the ground floor: nothing in reach more than 0.15 m out
				ac_unit(extras, x + 1.4, ya + 0.3, zb, -1, rnd)
		faces = trim.gbox("W7Trim", (x0, yk + FH - 0.12, zb - 0.12), (x1, yk + FH + 0.02, zb + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(3, 44.0 + q[0] - x0, q[1]))
	for x in (0.5, 22.0, 43.5):
		for ya, yb in ((G + 0.12, G + 3 * FH), (G + 4 * FH, G + 6 * FH)):
			f = extras.pipe("W7Palette", [(x, yb, zb - 0.06), (x, ya, zb - 0.06)], 0.045, sides=8)
			pal(extras, f, "pvc_grey", rnd)
	# Floors 5-6 ends; the block's ends behind the towers (z -7.7..-6.4) on floors 1-3; the main roof. The stair towers
	# keep their own walls (waves 1 and 4).
	for xe, n in ((x0 - 0.004, (-1, 0, 0)), (x1 + 0.004, (1, 0, 0))):
		wall_face(walls, "W7WallPale", "z", xe, b["back_z"], zr, G + 4 * FH, G + 6 * FH, [], n, 3, b["back_z"])
		wall_face(walls, "W7WallPale", "z", xe, b["back_z"], -6.4, G - 0.05, G + 3 * FH, [], n, 3, b["back_z"])
	walls.face("W1Concrete", [(x0, G + 6 * FH, b["back_z"]), (x1, G + 6 * FH, b["back_z"]), (x1, G + 6 * FH, zr), (x0, G + 6 * FH, zr)], (0, 1, 0))
	_export("b_outside.glb", parts)


BUILDS = {"bldga": build_bldga, "figure": build_figure, "lecture": build_lecture, "gym": build_gym, "b_outside": build_b_outside,
	"bldga_light": lambda: build_bldga(True)}


if __name__ == "__main__":
	random.seed(2642)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
