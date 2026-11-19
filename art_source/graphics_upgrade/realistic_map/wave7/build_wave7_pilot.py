"""T-264 round 1: the pilot (card step 2) with the options the owner picks from (step 3). Blender 5.2.2, bmesh only, no
add-on, no Tripo. Every glb is in Godot world space with its origin at Godot (0, G, 0) (wave7_layout.py has the layout).
The facades are modular, so each pilot builds a building's whole outside from the same bay (the wide stills need it);
the options are separate meshes the capture shows or hides.

  bldga_wall.glb      building A, kiểu A2: the front as a plastered wall with a window per room (8 bays x 6 floors), the
                      glazed entrance at x 22 under a canopy, floor bands, pilasters, sills, iron grilles on the upper
                      floors, a few AC units and laundry; sides, back and roof plain. Window fill meshes (by option):
                      GlassClear*/GlassDark*/Curtains*/Fake*/Void, RealRooms + Lobby (option a), LobbyFake (b);
                      Silhouette: a figure behind floor 3's window at WindowSilhouette1 (x 18)
  bldga_gallery.glb   building A, kiểu A1: floors 2-6 as open corridors with balustrades like building B (rooms' doors and
                      windows on an inner wall 1.8 m back, fake rooms behind them); the ground floor as A2
  gym_r1.glb          the gym, roof R1: flat roof, parapet, vertical concrete louvres over the front; tall windows between
                      fins, the main door at x -30 under a canopy
  gym_r2.glb          the gym, roof R2: a corrugated barrel vault over the same walls, arched gable ends
  b_outside.glb       building B: floors 5-6 front as blocked corridors behind railings (rubble), the back of floors
                      1-3 with windows, AC units, downpipes
  road_asphalt.glb / road_slab.glb    the Avenue x 112..176: old asphalt with patches, worn lines / concrete slabs; kerbs
  verge_grass.glb / verge_pavers.glb  the verges: worn grass and dirt / grey "con sâu" block paving
  tree_bang.glb, tree_phuong.glb, tree_xacu.glb   three roadside species (trunk inside TreeTrunk's 0.5 m box below 3 m,
                      no leaf below 3 m); placed at the pilot's trunks by the capture
  lamp_steel.glb / lamp_concrete.glb  street lights at the pilot's three points: galvanised pole with an arm / spun
                      concrete pole with a bracket; the glass glows faintly as the PS1 heads did
  bench.glb, moped.glb                RoadBench2 as a precast concrete bench; FallenMoped1 as an underbone moped on its side
  fence_w1.glb / fence_b40.glb        Fence/W x -80, z 95..125: W1 as the south wall (D-180) / B40 chain-link on pipe posts
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave7/build_wave7_pilot.py [-- name ...]
"""
import json
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE.parent / "wave5"))
sys.path.insert(0, str(HERE.parent / "wave3"))
sys.path.insert(0, str(HERE))
import w1kit  # noqa: E402
import build_gate_pilot as GP  # noqa: E402  (GPart, B, build, export; its main is guarded)
import build_garden_pilot as TP  # noqa: E402  (tree buffers: Buf, tube, card)
import wave7_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave7"
G = L.G
B, GPart = GP.B, GP.GPart
PALETTE = json.loads((HERE / "palette7.json").read_text(encoding="utf-8"))
SIZES = {"W7WallYellow": 2.0, "W7WallPale": 2.0, "W7WallGrey": 2.0, "W7Trim": 2.0, "W7Concrete": 2.0, "W7Asphalt": 4.0,
	"W7RoadSlab": 2.0, "W7Kerb": 1.0, "W7Pavers": 0.9}
GP.PREVIEW.update({k: ((0.7, 0.62, 0.4), 0.8) for k in ("W7WallYellow", "W7WallPale", "W7WallGrey")})
TP.PREVIEW.update({"W7BarkBang": ((0.36, 0.32, 0.27), 0.8), "W7BarkPhuong": ((0.5, 0.49, 0.45), 0.8), "W7BarkXacu": ((0.42, 0.4, 0.36), 0.8),
	"W7LeafBang": ((0.17, 0.32, 0.1), 0.6), "W7LeafPhuong": ((0.2, 0.36, 0.1), 0.6), "W7LeafXacu": ((0.11, 0.24, 0.08), 0.6)})


def export(name, objs):
	GP.export(OUT / name, objs)


def build(part, extra=None):
	for f in getattr(part, "painted", []):
		if f.is_valid:
			f.tag = True
	sizes = dict(SIZES)
	sizes.update(extra or {})
	return GP.build(part, sizes)


def keep(part, faces):
	if not hasattr(part, "painted"):
		part.painted = []
	part.painted += list(faces)
	return faces


def pal(part, faces, key, rnd=None):
	cx, cy = PALETTE[key]
	rnd = rnd or random
	for f in faces:
		ju, jv = rnd.uniform(0.3, 0.7), rnd.uniform(0.3, 0.7)
		for loop in f.loops:
			loop[part.uv].uv = ((cx + ju) / 8.0, 1.0 - (cy + jv) / 8.0)
		f.tag = True
	return keep(part, faces)


# ------------------------------------------------------------------------------------------------ facade helpers

def wall_face(part, mat, axis, plane, s0, s1, y0, y1, holes, normal, row, s_origin, flip=False):
	"""A flat wall face on `plane` (z = plane for axis 'x', x = plane for axis 'z'), spanning s0..s1 along the axis and
	y0..y1, with rectangular holes [(sa, sb, ya, yb)]; UV2 in mask row `row` (metres from s_origin)."""
	ss, ys = {s0, s1}, {y0, y1}
	for h in holes:
		ss |= {min(max(h[0], s0), s1), min(max(h[1], s0), s1)}
		ys |= {min(max(h[2], y0), y1), min(max(h[3], y0), y1)}
	ss, ys = sorted(ss), sorted(ys)
	faces = []
	for i in range(len(ss) - 1):
		for j in range(len(ys) - 1):
			sm, ym = (ss[i] + ss[i + 1]) / 2, (ys[j] + ys[j + 1]) / 2
			if any(h[0] < sm < h[1] and h[2] < ym < h[3] for h in holes):
				continue
			if axis == "x":
				pts = [(ss[i], ys[j], plane), (ss[i + 1], ys[j], plane), (ss[i + 1], ys[j + 1], plane), (ss[i], ys[j + 1], plane)]
			else:
				pts = [(plane, ys[j], ss[i]), (plane, ys[j], ss[i + 1]), (plane, ys[j + 1], ss[i + 1]), (plane, ys[j + 1], ss[i])]
			faces.append(part.face(mat, pts, normal))
	part.map_uv2(faces, lambda q: L.facade_uv2(row, abs((q[0] if axis == "x" else q[2]) - s_origin), q[1]))
	return faces


def reveal(part, mat, axis, plane, depth, sa, sb, ya, yb, row, s_origin, out_sign):
	"""The four sides of an opening through a wall `depth` deep behind `plane` (out_sign: the side the viewer is on)."""
	p0, p1 = plane, plane - out_sign * depth
	faces = []
	if axis == "x":
		faces.append(part.face(mat, [(sa, ya, p0), (sb, ya, p0), (sb, ya, p1), (sa, ya, p1)], (0, 1, 0)))
		faces.append(part.face(mat, [(sa, yb, p0), (sb, yb, p0), (sb, yb, p1), (sa, yb, p1)], (0, -1, 0)))
		faces.append(part.face(mat, [(sa, ya, p0), (sa, yb, p0), (sa, yb, p1), (sa, ya, p1)], (1, 0, 0)))
		faces.append(part.face(mat, [(sb, ya, p0), (sb, yb, p0), (sb, yb, p1), (sb, ya, p1)], (-1, 0, 0)))
	else:
		faces.append(part.face(mat, [(p0, ya, sa), (p0, ya, sb), (p1, ya, sb), (p1, ya, sa)], (0, 1, 0)))
		faces.append(part.face(mat, [(p0, yb, sa), (p0, yb, sb), (p1, yb, sb), (p1, yb, sa)], (0, -1, 0)))
		faces.append(part.face(mat, [(p0, ya, sa), (p0, yb, sa), (p1, yb, sa), (p1, ya, sa)], (0, 0, 1)))
		faces.append(part.face(mat, [(p0, ya, sb), (p0, yb, sb), (p1, yb, sb), (p1, ya, sb)], (0, 0, -1)))
	part.map_uv2(faces, lambda q: L.facade_uv2(row, abs((q[0] if axis == "x" else q[2]) - s_origin), q[1]))
	return faces


def quad_x(part, mat, x0, x1, y0, y1, z, normal_z, uv=None):
	"""A quad in the plane z (window-sized fills), u from the viewer's left to right, v from the top (Godot)."""
	if normal_z < 0:   # seen from -z (looking +z): +x is on the viewer's left
		pts, uvs = [(x1, y0, z), (x0, y0, z), (x0, y1, z), (x1, y1, z)], [(0, 1), (1, 1), (1, 0), (0, 0)]
	else:
		pts, uvs = [(x0, y0, z), (x1, y0, z), (x1, y1, z), (x0, y1, z)], [(0, 1), (1, 1), (1, 0), (0, 0)]
	f = part.face(mat, pts, (0, 0, normal_z), uv if uv is not None else [(u, 1 - v) for u, v in uvs])
	return keep(part, [f])


def fake_room(part, mat, x0, x1, y0, y1, z, normal_z):
	"""A window-sized quad with the interior shader; UV2 = the window's width and height (metres)."""
	faces = quad_x(part, mat, x0, x1, y0, y1, z, normal_z)
	part.map_uv2(faces, lambda q, w=x1 - x0, h=y1 - y0: (w, h))
	return faces


def window_frame(part, x0, x1, y0, y1, z, mat="W1Alu", sashes=2, depth=0.05):
	t = 0.05
	for lo, hi in (((x0, y0, z - depth), (x1, y0 + t, z)), ((x0, y1 - t, z - depth), (x1, y1, z)), ((x0, y0, z - depth), (x0 + t, y1, z)),
			((x1 - t, y0, z - depth), (x1, y1, z))):
		part.gbox(mat, lo, hi)
	for k in range(1, sashes):
		xm = x0 + (x1 - x0) * k / sashes
		part.gbox(mat, (xm - 0.025, y0, z - depth), (xm + 0.025, y1, z))


def grille(part, x0, x1, y0, y1, z):
	"""Iron window bars on the outside face (VN dorms): a flat frame and round bars every 12 cm, a cross bar."""
	part.gbox("W1Iron", (x0 - 0.04, y0 - 0.04, z - 0.03), (x1 + 0.04, y0, z))
	part.gbox("W1Iron", (x0 - 0.04, y1, z - 0.03), (x1 + 0.04, y1 + 0.04, z))
	n = int((x1 - x0) / 0.12)
	for k in range(n + 1):
		x = x0 + (x1 - x0) * k / n
		part.pipe("W1Iron", [(x, y0, z - 0.015), (x, y1, z - 0.015)], 0.007, sides=4, cap=False)
	part.gbox("W1Iron", (x0, (y0 + y1) / 2 - 0.02, z - 0.03), (x1, (y0 + y1) / 2 + 0.02, z))


def ac_unit(part, x, y, z, nz, rnd):
	f = part.gbox("W7Palette", (x - 0.4, y, min(z, z + nz * 0.32)), (x + 0.4, y + 0.55, max(z, z + nz * 0.32)))
	pal(part, f, "ac_white", rnd)
	f = part.gbox("W7Palette", (x - 0.32, y + 0.06, z + nz * 0.321 - 0.001), (x + 0.1, y + 0.49, z + nz * 0.322))
	pal(part, f, "black", rnd)
	for dx in (-0.32, 0.32):
		part.gbox("W1Iron", (x + dx - 0.02, y - 0.04, min(z, z + nz * 0.36)), (x + dx + 0.02, y, max(z, z + nz * 0.36)))


def laundry(part, x0, x1, y, z, nz, rnd):
	part.pipe("W1Iron", [(x0, y, z + nz * 0.25), (x1, y, z + nz * 0.25)], 0.006, sides=4, cap=False)
	x = x0 + 0.15
	while x < x1 - 0.3:
		w = rnd.uniform(0.25, 0.45)
		f = quad_x(part, "W7Palette", x, x + w, y - rnd.uniform(0.4, 0.7), y - 0.02, z + nz * 0.25, nz)
		pal(part, f, rnd.choice(["towel_white", "clothes_blue", "clothes_red", "curtain_beige"]), rnd)
		x += w + rnd.uniform(0.1, 0.3)


def figure(part, x, y_floor, z, rnd):
	"""A person standing behind a window, facing out: dark (the room is unlit), only a shape."""
	m = Matrix.Translation(B((x, y_floor, z)))
	for lo, hi in (((-0.11, 0.0, -0.08), (-0.02, 0.85, 0.06)), ((0.02, 0.0, -0.08), (0.11, 0.85, 0.06)), ((-0.2, 0.85, -0.1), (0.2, 1.42, 0.09)),
			((-0.27, 0.95, -0.06), (-0.2, 1.4, 0.05)), ((0.2, 0.95, -0.06), (0.27, 1.4, 0.05)), ((-0.05, 1.42, -0.04), (0.05, 1.5, 0.04))):
		f = part.box("W7Palette", (lo[0], -hi[2], lo[1]), (hi[0], -lo[2], hi[1]), bevel=0.03, segments=1, matrix=m)
		pal(part, f, "silhouette", rnd)
	f = part.cylinder("W7Palette", (0.0, 0.0, 1.62), 0.105, 0.24, segments=10, matrix=m)
	pal(part, f, "silhouette", rnd)


# ------------------------------------------------------------------------------------------------ building A

class Fill:
	"""The option meshes of a facade's windows."""

	def __init__(self, tag):
		self.parts = {name: GPart(name + tag) for name in ("GlassClearGround", "GlassClearUpper", "GlassDarkGround", "GlassDarkUpper",
			"CurtainsGround", "CurtainsUpper", "FakeGround", "FakeUpper", "Void")}

	def window(self, x0, x1, y0, y1, z_face, nz, upper, room_mat, rnd, broken=False, figure=False):
		"""z_face: the wall's outer plane; the glass sits 0.15 m in, curtains 0.25, the fake room 0.3."""
		kind = "Upper" if upper else "Ground"
		zg = z_face - nz * 0.15
		if figure:
			pass
		elif not broken:
			quad_x(self.parts["GlassClear" + kind], "W2Glass", x0, x1, y0, y1, zg, nz)
			quad_x(self.parts["GlassDark" + kind], "W7GlassDark", x0, x1, y0, y1, zg, nz)
		else:
			quad_x(self.parts["Void"], "W7GlassDark", x0 - 0.1, x1 + 0.1, y0 - 0.1, y1 + 0.1, z_face - nz * 1.2, nz)
		if figure:
			# WindowSilhouette's window: no glass, curtain or fake room in front of the figure, a dark room behind it.
			return
		fake_room(self.parts["Fake" + kind], room_mat, x0, x1, y0, y1, z_face - nz * 0.3, nz)
		# Curtains: one or two panels drawn part way, the colour per room.
		col = rnd.choice(["curtain_blue", "curtain_green", "curtain_beige", "curtain_pink", "curtain_beige"])
		cover = rnd.uniform(0.35, 1.0)
		if rnd.random() < 0.5:
			f = quad_x(self.parts["Curtains" + kind], "W7Palette", x0, x0 + (x1 - x0) * cover, y0, y1, z_face - nz * 0.25, nz)
		else:
			f = quad_x(self.parts["Curtains" + kind], "W7Palette", x0, x0 + (x1 - x0) * cover * 0.5, y0, y1, z_face - nz * 0.25, nz)
			f += quad_x(self.parts["Curtains" + kind], "W7Palette", x1 - (x1 - x0) * cover * 0.5, x1, y0, y1, z_face - nz * 0.25, nz)
		pal(self.parts["Curtains" + kind], f, col, rnd)

	def objs(self):
		out = []
		for name, part in self.parts.items():
			if part.bm.faces:
				part.bm.normal_update()
				out.append(build(part, {"W7Palette": 1.0}))
		return out


def a_ground_and_shell(walls, trim, frames, fill, extras, lobby, rooms, rnd, wall_mat):
	"""Building A's ground floor, sides, back, roof and the bands/pilasters common to both kinds (front z 54)."""
	a = L.BUILDING_A
	x0, x1 = a["x"]
	z0, z1 = a["z"]
	zf = z0 - 0.004
	top = a["y"][1]
	g1 = G + L.FLOOR_H
	# Ground floor front: windows of bays 0..7 except the door bay (x 20.5..23.5 under the canopy, glazed doors).
	holes = [(x - 1.0, x + 1.0, G + 1.05, G + 2.55) for x in a["windows_x"] if abs(x - 22.5) > 0.1]
	holes.append((20.5, 23.5, G, G + 2.8))
	wall_face(walls, wall_mat, "x", zf, x0, x1, G - 0.05, g1, holes, (0, 0, -1), 0, x0)
	for h in holes:
		reveal(walls, wall_mat, "x", zf, 0.2, *h, 0, x0, -1)
	for x in a["windows_x"]:
		if abs(x - 22.5) < 0.1:
			continue
		window_frame(frames, x - 1.0, x + 1.0, G + 1.05, G + 2.55, zf + 0.15, sashes=2)
		in_segment = 15.0 < x < 30.0
		fill.window(x - 1.0, x + 1.0, G + 1.05, G + 2.55, zf, -1, False, "W7RoomDorm", rnd)
		trim.gbox("W7Concrete", (x - 1.08, G + 0.99, zf - 0.06), (x + 1.08, G + 1.05, zf + 0.2))
		if in_segment:
			# Option a: a real shallow room (3 m) behind the ground-floor windows of the pilot's segment.
			for lo, hi, key in (((x - 2.4, G, zf + 0.2), (x + 2.4, G + 0.02, zf + 3.2), "terrazzo"), ((x - 2.4, G + 3.0, zf + 0.2), (x + 2.4, G + 3.02, zf + 3.2), "concrete"),
					((x - 2.4, G, zf + 3.2), (x + 2.4, G + 3.0, zf + 3.22), "curtain_beige"), ((x - 2.42, G, zf + 0.2), (x - 2.4, G + 3.0, zf + 3.2), "curtain_beige"),
					((x + 2.4, G, zf + 0.2), (x + 2.42, G + 3.0, zf + 3.2), "curtain_beige"), ((x - 2.2, G, zf + 2.3), (x - 0.4, G + 1.75, zf + 3.1), "steel_grey"),
					((x + 0.6, G, zf + 2.6), (x + 1.8, G + 0.76, zf + 3.15), "door_green"), ((x - 2.1, G + 0.45, zf + 2.35), (x - 0.5, G + 0.55, zf + 3.05), "towel_white"),
					((x - 2.1, G + 1.3, zf + 2.35), (x - 0.5, G + 1.4, zf + 3.05), "clothes_blue")):
				f = rooms.gbox("W7Palette", lo, hi)
				pal(rooms, f, key, rnd)
	# The entrance: glazed aluminium doors (one leaf open), a fanlight, the lobby behind (option a/c real, b fake).
	window_frame(frames, 20.5, 23.5, G, G + 2.8, zf + 0.15, sashes=2, depth=0.08)
	frames.gbox("W1Alu", (20.5, G + 2.2, zf + 0.07), (23.5, G + 2.25, zf + 0.15))
	quad_x(fill.parts["GlassClearGround"], "W2Glass", 20.55, 21.95, G + 0.05, G + 2.2, zf + 0.12, -1)
	quad_x(fill.parts["GlassDarkGround"], "W7GlassDark", 20.55, 21.95, G + 0.05, G + 2.2, zf + 0.12, -1)
	frames.gbox("W1Alu", (22.0, G, zf + 0.15), (22.05, G + 2.2, zf + 1.5))
	fake_room(fill.parts["FakeGround"], "W7RoomLobby", 20.5, 23.5, G, G + 2.8, zf + 0.3, -1)
	for lo, hi, key in (((17.0, G, zf + 0.2), (28.0, G + 0.02, zf + 6.0), "terrazzo"), ((17.0, G + 3.0, zf + 0.2), (28.0, G + 3.02, zf + 6.0), "concrete"),
			((17.0, G, zf + 6.0), (28.0, G + 3.0, zf + 6.02), "curtain_beige"), ((20.0, G, zf + 0.2), (20.02, G + 3.0, zf + 6.0), "curtain_beige"),
			((24.0, G, zf + 0.2), (24.02, G + 3.0, zf + 6.0), "curtain_beige"), ((20.6, G + 1.2, zf + 5.9), (22.6, G + 2.3, zf + 5.98), "door_blue")):
		f = lobby.gbox("W7Palette", lo, hi)
		pal(lobby, f, key, rnd)
	for k in range(9):
		f = lobby.gbox("W7Palette", (22.6, G + k * 0.16, zf + 3.4 + k * 0.28), (23.9, G + (k + 1) * 0.16, zf + 6.0))
		pal(lobby, f, "terrazzo", rnd)
	# A cantilevered canopy (no posts: nothing new stands where the player walks).
	trim.gbox("W7Concrete", (19.6, G + 3.0, zf - 1.6), (24.4, G + 3.18, zf + 0.01))
	trim.gbox("W7Concrete", (19.6, G + 3.18, zf - 1.6), (24.4, G + 3.4, zf - 1.5))
	# Bands at each floor, pilasters between bays, the parapet; the plinth.
	for k in range(1, a["floors"]):
		faces = trim.gbox("W7Trim", (x0 - 0.15, G + L.FLOOR_H * k - 0.12, zf - 0.15), (x1 + 0.15, G + L.FLOOR_H * k + 0.02, zf + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, q[1]))
	for x in [x0 + 5.0 * k for k in range(9)]:
		faces = trim.gbox("W7Trim", (x - 0.2 if x > x0 else x, G - 0.05, zf - 0.12), (x + 0.2 if x < x1 else x, top, zf + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, q[1]))
	faces = trim.gbox("W7Trim", (x0 - 0.15, top, z0 - 0.15), (x1 + 0.15, top + 0.7, z1 + 0.15))
	trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, 9.8 + G))
	trim.gbox("W1Concrete", (x0 - 0.2, top + 0.7, z0 - 0.2), (x1 + 0.2, top + 0.76, z1 + 0.2))
	faces = trim.gbox("W7Concrete", (x0 - 0.05, G - 0.05, zf - 0.05), (x1 + 0.05, G + 0.35, zf + 0.01))
	trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, q[1]))
	# Sides, back (plain, a few small windows on the back), roof.
	wall_face(walls, wall_mat, "z", x0 - 0.004, z0, z1, G - 0.05, top, [], (-1, 0, 0), 0, z0)
	wall_face(walls, wall_mat, "z", x1 + 0.004, z0, z1, G - 0.05, top, [], (1, 0, 0), 0, z0)
	back_holes = [(x - 0.6, x + 0.6, G + 1.6 + L.FLOOR_H * k, G + 2.4 + L.FLOOR_H * k) for k in range(6) for x in a["windows_x"]]
	wall_face(walls, wall_mat, "x", z1 + 0.004, x0, x1, G - 0.05, top, back_holes, (0, 0, 1), 0, x0)
	for h in back_holes:
		quad_x(fill.parts["Void"], "W7GlassDark", h[0], h[1], h[2], h[3], z1 - 0.1, 1)
		reveal(walls, wall_mat, "x", z1 + 0.004, 0.1, *h, 0, x0, 1)
	walls.face("W1Concrete", [(x0, top, z0), (x1, top, z0), (x1, top, z1), (x0, top, z1)], (0, 1, 0))
	return zf


def build_bldga(kind):
	w1kit.reset()
	rnd = random.Random(26401 if kind == "wall" else 26402)
	walls, trim, frames, bars, extras = GPart("Walls"), GPart("Trim"), GPart("Frames"), GPart("Bars"), GPart("Extras")
	lobby, rooms, sil = GPart("Lobby"), GPart("RealRooms"), GPart("Silhouette")
	fill = Fill("")
	a = L.BUILDING_A
	x0, x1 = a["x"]
	zf = a_ground_and_shell(walls, trim, frames, fill, extras, lobby, rooms, rnd, "W7WallYellow")
	g1, top = G + L.FLOOR_H, a["y"][1]
	broken = {(2, 1), (4, 6), (5, 3)}
	if kind == "wall":
		holes = [(x - 1.0, x + 1.0, G + 1.05 + L.FLOOR_H * k, G + 2.55 + L.FLOOR_H * k) for k in range(1, 6) for x in a["windows_x"]]
		wall_face(walls, "W7WallYellow", "x", zf, x0, x1, g1, top, holes, (0, 0, -1), 0, x0)
		for h in holes:
			reveal(walls, "W7WallYellow", "x", zf, 0.2, *h, 0, x0, -1)
		for k in range(1, 6):
			for i, x in enumerate(a["windows_x"]):
				ya, yb = G + 1.05 + L.FLOOR_H * k, G + 2.55 + L.FLOOR_H * k
				window_frame(frames, x - 1.0, x + 1.0, ya, yb, zf + 0.15, sashes=2)
				fill.window(x - 1.0, x + 1.0, ya, yb, zf, -1, True, "W7RoomDorm", rnd, broken=(k, i) in broken, figure=(k, i) == (2, 3))
				trim.gbox("W7Concrete", (x - 1.08, ya - 0.06, zf - 0.06), (x + 1.08, ya, zf + 0.2))
				grille(bars, x - 1.0, x + 1.0, ya, yb, zf - 0.02)
				if rnd.random() < 0.18:
					ac_unit(extras, x + 1.6, ya + 0.2, zf, -1, rnd)
				if rnd.random() < 0.15:
					laundry(extras, x - 1.0, x + 1.0, yb - 0.1, zf, -1, rnd)
	else:
		# A1: open corridors on floors 2-6 (slab edge, balustrade, columns), the rooms' wall 1.8 m back.
		zi = zf + 1.8
		for k in range(1, 6):
			yk = G + L.FLOOR_H * k
			faces = trim.gbox("W7Trim", (x0, yk - 0.25, zf - 0.02), (x1, yk + 0.02, zf + 0.01))
			trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, q[1]))
			walls.face("W1Terrazzo", [(x0, yk + 0.02, zf), (x1, yk + 0.02, zf), (x1, yk + 0.02, zi), (x0, yk + 0.02, zi)], (0, 1, 0))
			walls.face("W7Concrete", [(x0, yk - 0.25, zf), (x1, yk - 0.25, zf), (x1, yk - 0.25, zi), (x0, yk - 0.25, zi)], (0, -1, 0))
			# Balustrade: a low concrete parapet (0.6 m) with an iron rail above to 1.1 m.
			faces = trim.gbox("W7Trim", (x0, yk, zf - 0.02), (x1, yk + 0.6, zf + 0.1))
			trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, q[1]))
			bars.gbox("W1Iron", (x0, yk + 1.05, zf + 0.0), (x1, yk + 1.1, zf + 0.08))
			for xb in [x0 + 0.15 * j for j in range(int((x1 - x0) / 0.15) + 1)]:
				bars.gbox("W1Iron", (xb - 0.006, yk + 0.6, zf + 0.03), (xb + 0.006, yk + 1.05, zf + 0.05))
			holes = []
			for i, x in enumerate(a["windows_x"]):
				ya, yb = yk + 1.05, yk + 2.55
				holes.append((x - 1.4, x - 0.5, yk, yk + 2.2))      # the room's door
				holes.append((x + 0.0, x + 1.4, ya, yb - 0.3))       # its window
				fill.window(x + 0.0, x + 1.4, ya, yb - 0.3, zi, -1, True, "W7RoomDorm", rnd, broken=(k, i) in broken, figure=(k, i) == (2, 3))
				f = quad_x(extras, "W7Palette", x - 1.4, x - 0.5, yk, yk + 2.2, zi + 0.05, -1)
				pal(extras, f, rnd.choice(["door_green", "door_blue", "door_green"]), rnd)
				window_frame(frames, x + 0.0, x + 1.4, ya, yb - 0.3, zi + 0.15, sashes=2)
				grille(bars, x + 0.0, x + 1.4, ya, yb - 0.3, zi - 0.02)
				if rnd.random() < 0.3:
					laundry(extras, x - 2.0, x + 2.0, yk + 2.3, zf + 0.3, -1, rnd)
			wall_face(walls, "W7WallYellow", "x", zi, x0, x1, yk, yk + L.FLOOR_H - 0.25, holes, (0, 0, -1), 0, x0)
			for h in holes:
				reveal(walls, "W7WallYellow", "x", zi, 0.12, *h, 0, x0, -1)
		for x in [x0 + 5.0 * k for k in range(9)]:
			faces = trim.gbox("W7Trim", (x - 0.15 if x > x0 else x, g1, zf), (x + 0.15 if x < x1 else x, top, zf + 0.3))
			trim.map_uv2(faces, lambda q: L.facade_uv2(0, q[0] - x0, q[1]))
		wall_face(walls, "W7WallYellow", "x", zf, x0, x1, top - 0.25, top, [], (0, 0, -1), 0, x0)
	# WindowSilhouette1 (x 18, floor 3): a figure behind the glass, by the window at x 17.5.
	zfig = zf + 0.45 if kind == "wall" else zf + 2.25
	figure(sil, 18.0, G + 2 * L.FLOOR_H, zfig, rnd)
	# A pale drawn curtain a metre behind the figure, so its dark shape reads against it (the PS1 one was a black
	# plane on light glass); no light is added.
	ya = G + 2 * L.FLOOR_H + 1.05
	f = quad_x(sil, "W7Palette", 16.3, 18.7, ya - 0.3, ya + 1.8, zfig + 0.9, -1)
	pal(sil, f, "curtain_beige", rnd)
	objs = [build(walls, {"W1Concrete": 0.8, "W1Terrazzo": 1.0}), build(trim, {"W1Concrete": 0.8}), build(frames, {"W1Alu": 1.0}),
		build(bars, {"W1Iron": 1.0}), build(extras, {"W7Palette": 1.0, "W1Iron": 1.0}), build(lobby, {"W7Palette": 1.0}),
		build(rooms, {"W7Palette": 1.0}), build(sil, {"W7Palette": 1.0})] + fill.objs()
	export("bldga_%s.glb" % kind, objs)


# ------------------------------------------------------------------------------------------------ gym

def build_gym(roof):
	w1kit.reset()
	rnd = random.Random(26403)
	walls, trim, frames, roofp = GPart("Walls"), GPart("Trim"), GPart("Frames"), GPart("Roof")
	fill = Fill("")
	g = L.GYM
	x0, x1 = g["x"]
	z0, z1 = g["z"]
	top = g["y"][1]
	zf = z0 - 0.004
	# Tall windows (1 m to 6.5 m) in every other bay between concrete fins, the main door at x -30 (3.6 x 3 m).
	wins = [x for x in g["windows_x"] if abs(x - (-27.5)) > 0.1 and abs(x - (-32.5)) > 0.1]
	holes = [(x - 1.0, x + 1.0, G + 1.0, G + 6.5) for x in wins] + [(-31.8, -28.2, G, G + 3.0)]
	wall_face(walls, "W7WallYellow", "x", zf, x0, x1, G - 0.05, top, holes, (0, 0, -1), 1, x0)
	for h in holes:
		reveal(walls, "W7WallYellow", "x", zf, 0.25, *h, 1, x0, -1)
	for x in wins:
		window_frame(frames, x - 1.0, x + 1.0, G + 1.0, G + 6.5, zf + 0.15, sashes=2)
		for yb in (G + 2.8, G + 4.6):
			frames.gbox("W1Alu", (x - 1.0, yb - 0.03, zf + 0.1), (x + 1.0, yb + 0.03, zf + 0.15))
		fill.window(x - 1.0, x + 1.0, G + 1.0, G + 6.5, zf, -1, False, "W7RoomGym", rnd, broken=rnd.random() < 0.15)
	# Steel double doors (one leaf ajar), a canopy over them.
	for xa, xb in ((-31.8, -30.02), (-29.98, -28.2)):
		f = quad_x(frames, "W7Palette", xa, xb, G, G + 3.0, zf + 0.2, -1)
		pal(frames, f, "door_green", rnd)
	trim.gbox("W7Concrete", (-33.5, G + 3.3, zf - 2.0), (-26.5, G + 3.5, zf + 0.01))
	# Fins every 5 m, a plinth; the east gable (x 0) plain with a high window band; back and west plain.
	for x in [x0 + 5.0 * k for k in range(13)]:
		if abs(x - (-30.0)) < 0.1:
			continue   # the main door's centre
		faces = trim.gbox("W7Trim", (x - 0.15, G - 0.05, zf - 0.45), (x + 0.15, top, zf + 0.01))
		trim.map_uv2(faces, lambda q: L.facade_uv2(1, q[0] - x0, q[1]))
	faces = trim.gbox("W7Concrete", (x0, G - 0.05, zf - 0.05), (x1, G + 0.4, zf + 0.01))
	trim.map_uv2(faces, lambda q: L.facade_uv2(1, q[0] - x0, q[1]))
	east_holes = [(z, z + 3.0, G + 6.0, G + 8.0) for z in (93.5, 101.5, 109.5, 117.5, 125.0)]
	wall_face(walls, "W7WallYellow", "z", x1 + 0.004, z0, z1, G - 0.05, top, east_holes, (1, 0, 0), 1, z0 - 60.0)
	for h in east_holes:
		walls.face("W7GlassDark", [(x1 - 0.1, h[2], h[0]), (x1 - 0.1, h[2], h[1]), (x1 - 0.1, h[3], h[1]), (x1 - 0.1, h[3], h[0])], (1, 0, 0))
		reveal(walls, "W7WallYellow", "z", x1 + 0.004, 0.1, *h, 1, z0 - 60.0, 1)
	wall_face(walls, "W7WallYellow", "z", x0 - 0.004, z0, z1, G - 0.05, top, [], (-1, 0, 0), 1, z0)
	wall_face(walls, "W7WallYellow", "x", z1 + 0.004, x0, x1, G - 0.05, top, [], (0, 0, 1), 1, x0)
	if roof == "r1":
		# Flat roof behind a parapet; a screen of vertical concrete louvres over the front's upper half.
		roofp.face("W1Concrete", [(x0, top, z0), (x1, top, z0), (x1, top, z1), (x0, top, z1)], (0, 1, 0))
		faces = trim.gbox("W7Trim", (x0 - 0.1, top, z0 - 0.1), (x1 + 0.1, top + 0.9, z1 + 0.1))
		trim.map_uv2(faces, lambda q: L.facade_uv2(1, q[0] - x0, 9.9 + G))
		x = x0 + 0.3
		while x < x1 - 0.2:
			if not (-34.0 < x < -26.0):
				trim.gbox("W7Concrete", (x - 0.06, G + 6.8, zf - 0.6), (x + 0.06, top + 0.9, zf - 0.05))
			x += 0.6
		trim.gbox("W7Concrete", (x0, G + 6.65, zf - 0.65), (x1, G + 6.8, zf - 0.02))
	else:
		# A corrugated barrel vault along x over the 40 m span, 5 m rise; arched gables; eaves gutters.
		segs = 16
		rise = 5.0
		zs = [z0 - 0.4 + (z1 - z0 + 0.8) * k / segs for k in range(segs + 1)]
		def vy(z):  # noqa: E306
			t = (z - (z0 + z1) / 2) / ((z1 - z0) / 2 + 0.4)
			return top + rise * (1 - t * t)
		faces = []
		for za, zb in zip(zs, zs[1:]):
			faces.append(roofp.face("W4RoofSheet", [(x0 - 0.3, vy(za), za), (x1 + 0.3, vy(za), za), (x1 + 0.3, vy(zb), zb), (x0 - 0.3, vy(zb), zb)], (0, 1, 0)))
			faces.append(roofp.face("W4RoofSheet", [(x0 - 0.3, vy(za) - 0.02, za), (x0 - 0.3, vy(zb) - 0.02, zb), (x1 + 0.3, vy(zb) - 0.02, zb), (x1 + 0.3, vy(za) - 0.02, za)], (0, -1, 0)))
		for xg, n in ((x0 - 0.004, -1), (x1 + 0.004, 1)):
			for za, zb in zip(zs, zs[1:]):
				if za < z0 or zb > z1:
					continue
				walls.face("W7WallYellow", [(xg, top, za), (xg, top, zb), (xg, vy(zb), zb), (xg, vy(za), za)], (n, 0, 0))
		for zz in (z0 - 0.4, z1 + 0.4):
			roofp.pipe("W4PoleSteel", [(x0 - 0.3, top + 0.02, zz), (x1 + 0.3, top + 0.02, zz)], 0.08, sides=6)
	for p in (walls, trim, frames, roofp):
		p.bm.normal_update()
	export("gym_%s.glb" % roof, [build(walls, {"W1Concrete": 0.8}), build(trim, {"W1Concrete": 0.8}), build(frames, {"W1Alu": 1.0, "W7Palette": 1.0}),
		build(roofp, {"W1Concrete": 0.8, "W4RoofSheet": 1.0, "W4PoleSteel": 1.0})] + fill.objs())


# ------------------------------------------------------------------------------------------------ building B

def build_b_outside():
	"""Floors 5-6 front: blocked corridors behind railings (rubble, boarded doors), as floors 1-4 read from the garden;
	the back of floors 1-3: windows (dark glass, curtains, a few broken), AC units, downpipes."""
	w1kit.reset()
	rnd = random.Random(26404)
	walls, trim, frames, bars, extras = GPart("Walls"), GPart("Trim"), GPart("Frames"), GPart("Bars"), GPart("Extras")
	fill = Fill("")
	b = L.BUILDING_B
	x0, x1 = b["x"]
	zr = b["front_z"]
	zi = 0.3
	for k in (4, 5):
		yk = G + L.FLOOR_H * k
		faces = trim.gbox("W7Trim", (x0, yk - 0.25, zi), (x1, yk + 0.02, zr + 0.02))
		trim.map_uv2(faces, lambda q: L.facade_uv2(3, q[0] - x0, q[1]))
		walls.face("W1Terrazzo", [(x0, yk + 0.02, zi), (x1, yk + 0.02, zi), (x1, yk + 0.02, zr), (x0, yk + 0.02, zr)], (0, 1, 0))
		for yu in (yk - 0.25, yk + L.FLOOR_H - 0.25):
			walls.face("W7Concrete", [(x0, yu, zi), (x1, yu, zi), (x1, yu, zr), (x0, yu, zr)], (0, -1, 0))
		bars.gbox("W1Iron", (x0, yk + 1.05, zr - 0.08), (x1, yk + 1.1, zr))
		bars.gbox("W1Iron", (x0, yk + 0.08, zr - 0.08), (x1, yk + 0.12, zr))
		for xb in [x0 + 0.12 * j for j in range(int((x1 - x0) / 0.12) + 1)]:
			bars.gbox("W1Iron", (xb - 0.006, yk + 0.12, zr - 0.05), (xb + 0.006, yk + 1.05, zr - 0.03))
		holes = []
		for x in b["upper_windows_x"]:
			holes.append((x - 1.6, x - 0.7, yk, yk + 2.2))
			holes.append((x - 0.4, x + 1.4, yk + 1.0, yk + 2.3))
			fill.window(x - 0.4, x + 1.4, yk + 1.0, yk + 2.3, zi, 1, True, "W7RoomDorm", rnd, broken=rnd.random() < 0.3)
			f = quad_x(extras, "W7Palette", x - 1.6, x - 0.7, yk, yk + 2.2, zi - 0.05, 1)
			pal(extras, f, "door_green", rnd)
			for j in range(rnd.randrange(2, 5)):
				m = Matrix.Translation(B((x + rnd.uniform(-1.8, 1.8), yk + 0.15, rnd.uniform(zi + 0.4, zr - 0.6)))) @ Matrix.Rotation(rnd.uniform(0, 3), 4, "Z")
				s = rnd.uniform(0.2, 0.5)
				f = extras.box("W7Palette", (-s, -s * 0.7, -0.13), (s, s * 0.7, s * 0.6), bevel=0.04, segments=1, matrix=m)
				pal(extras, f, "concrete", rnd)
		wall_face(walls, "W7WallPale", "x", zi, x0, x1, yk, yk + L.FLOOR_H - 0.25, holes, (0, 0, 1), 3, x0)
		for x in [x0 + 4.0 * j for j in range(12)]:
			faces = trim.gbox("W7Trim", (x - 0.15 if x > x0 else x, yk, zr - 0.3), (x + 0.15 if x < x1 else x, yk + L.FLOOR_H, zr))
			trim.map_uv2(faces, lambda q: L.facade_uv2(3, q[0] - x0, q[1]))
	trim.gbox("W7Trim", (x0 - 0.1, G + 6 * L.FLOOR_H - 0.3, b["back_z"] - 0.1), (x1 + 0.1, G + 6 * L.FLOOR_H + 0.5, zr + 0.1))
	# The back of floors 1-3 (z -7.7): a face 4 mm out with windows on its outside (the rooms' inside walls stay).
	zb = b["back_z"] - 0.004
	for k in range(3):
		yk = G + L.FLOOR_H * k
		for x in b["upper_windows_x"]:
			if k == 0 and x < 6.0:
				continue   # the manager's room window (WindowExit) stays as it is
			ya, yb = yk + 1.0, yk + 2.4
			# Flush windows: the rooms' real back walls stay behind (their inside faces are the PS1 boxes'), so the glass,
			# the fake room and the frame sit on the outside face (option b's shader gives the depth).
			fake_room(fill.parts["FakeUpper"], "W7RoomDorm", x - 0.9, x + 0.9, ya, yb, zb - 0.006, -1)
			quad_x(fill.parts["GlassDarkUpper"], "W7GlassDark", x - 0.9, x + 0.9, ya, yb, zb - 0.012, -1)
			quad_x(fill.parts["GlassClearUpper"], "W2Glass", x - 0.9, x + 0.9, ya, yb, zb - 0.012, -1)
			window_frame(frames, x - 0.9, x + 0.9, ya, yb, zb - 0.012, sashes=2, depth=-0.05)
			grille(bars, x - 0.9, x + 0.9, ya, yb, zb - 0.03)
			trim.gbox("W7Concrete", (x - 0.98, ya - 0.06, zb - 0.01), (x + 0.98, ya, zb + 0.08))
			if rnd.random() < 0.25:
				ac_unit(extras, x + 1.4, ya + 0.3, zb, -1, rnd)
		faces = trim.gbox("W7Trim", (x0, yk + L.FLOOR_H - 0.12, zb - 0.01), (x1, yk + L.FLOOR_H + 0.02, zb + 0.12))
		trim.map_uv2(faces, lambda q: L.facade_uv2(3, 44.0 + q[0] - x0, q[1]))
	# Floors 4-6 at the back and both ends of floors 5-6, the roof (the PS1 UpperFloor5/6 meshes are hidden with the
	# front, so their other faces come from here).
	wall_face(walls, "W7WallPale", "x", zb, x0, x1, G - 0.05, G + 6 * L.FLOOR_H, [], (0, 0, -1), 3, x0 - 44.0)
	for k in range(3, 6):
		yk = G + L.FLOOR_H * k
		for x in b["upper_windows_x"]:
			fake_room(fill.parts["FakeUpper"], "W7RoomDorm", x - 0.9, x + 0.9, yk + 1.0, yk + 2.4, zb - 0.006, -1)
			quad_x(fill.parts["GlassDarkUpper"], "W7GlassDark", x - 0.9, x + 0.9, yk + 1.0, yk + 2.4, zb - 0.012, -1)
			quad_x(fill.parts["GlassClearUpper"], "W2Glass", x - 0.9, x + 0.9, yk + 1.0, yk + 2.4, zb - 0.012, -1)
			window_frame(frames, x - 0.9, x + 0.9, yk + 1.0, yk + 2.4, zb - 0.012, sashes=2, depth=-0.05)
	for xe, n in ((x0 - 0.004, (-1, 0, 0)), (x1 + 0.004, (1, 0, 0))):
		wall_face(walls, "W7WallPale", "z", xe, b["back_z"], zr, G + 4 * L.FLOOR_H, G + 6 * L.FLOOR_H, [], n, 3, b["back_z"])
	walls.face("W1Concrete", [(x0, G + 6 * L.FLOOR_H, b["back_z"]), (x1, G + 6 * L.FLOOR_H, b["back_z"]), (x1, G + 6 * L.FLOOR_H, zr), (x0, G + 6 * L.FLOOR_H, zr)], (0, 1, 0))
	for x in (0.5, 22.0, 43.5):
		f = extras.pipe("W7Palette", [(x, G + 3 * L.FLOOR_H, zb - 0.08), (x, G + 0.2, zb - 0.08), (x, G + 0.05, zb - 0.25)], 0.045, sides=8)
		pal(extras, f, "pvc_grey", rnd)
	for p in (walls, trim, frames, bars, extras):
		p.bm.normal_update()
	export("b_outside.glb", [build(walls, {"W1Terrazzo": 1.0}), build(trim, {"W1Concrete": 0.8}), build(frames, {"W1Alu": 1.0}),
		build(bars, {"W1Iron": 1.0}), build(extras, {"W7Palette": 1.0, "W1Iron": 1.0})] + fill.objs())


# ------------------------------------------------------------------------------------------------ the Avenue

ROAD_Y = -9.866   # pilot only: a hair over the PS1 Avenue mesh (-9.87); round 3 lays it 2 cm over the tiles' collider
KERB_TOP = -9.80


def build_road(kind):
	w1kit.reset()
	rnd = random.Random(26405)
	road, kerb, paint, gut = GPart("Road"), GPart("Kerbs"), GPart("Paint"), GPart("Joints")
	r = L.ROAD
	x0, x1 = r["x"]
	z0, z1 = r["z"]
	uv2 = lambda q: ((q[0] - L.ROAD_PILOT["x"][0]) / 64.0, (q[2] - L.ROAD_PILOT["z"][0]) / 26.0)  # noqa: E731
	if kind == "asphalt":
		faces = []
		for xa in range(int(x0), int(x1), 8):
			faces.append(road.face("W7Asphalt", [(xa, ROAD_Y, z0), (xa + 8, ROAD_Y, z0), (xa + 8, ROAD_Y, z1), (xa, ROAD_Y, z1)], (0, 1, 0)))
		road.map_uv2(faces, uv2)
		# Worn lines: a dashed centre line (3 m paint, 3 m gap), continuous edge lines.
		for xa in [x0 + 6.0 * k for k in range(int((x1 - x0) / 6.0))]:
			paint.face("W7Paint", [(xa, ROAD_Y + 0.004, -15.06), (xa + 3.0, ROAD_Y + 0.004, -15.06), (xa + 3.0, ROAD_Y + 0.004, -14.94), (xa, ROAD_Y + 0.004, -14.94)],
				(0, 1, 0), [(0, 1), (1.5, 1), (1.5, 0), (0, 0)])
		for ze in (z0 + 0.35, z1 - 0.35):
			paint.face("W7Paint", [(x0, ROAD_Y + 0.004, ze - 0.06), (x1, ROAD_Y + 0.004, ze - 0.06), (x1, ROAD_Y + 0.004, ze + 0.06), (x0, ROAD_Y + 0.004, ze + 0.06)],
				(0, 1, 0), [(0, 1), ((x1 - x0) / 2.0, 1), ((x1 - x0) / 2.0, 0), (0, 0)])
		keep(paint, list(paint.bm.faces))
	else:
		faces = []
		for xa in [x0 + 4.0 * k for k in range(int((x1 - x0) / 4.0))]:
			for za, zb in ((z0, -15.0), (-15.0, z1)):
				faces.append(road.face("W7RoadSlab", [(xa + 0.008, ROAD_Y, za + 0.008), (xa + 3.992, ROAD_Y, za + 0.008), (xa + 3.992, ROAD_Y, zb - 0.008),
					(xa + 0.008, ROAD_Y, zb - 0.008)], (0, 1, 0)))
		road.map_uv2(faces, uv2)
		gut.face("W3GutterDark", [(x0, ROAD_Y - 0.01, z0), (x1, ROAD_Y - 0.01, z0), (x1, ROAD_Y - 0.01, z1), (x0, ROAD_Y - 0.01, z1)], (0, 1, 0))
	for za, zb in ((z0 - 0.15, z0), (z1, z1 + 0.15)):
		xa = x0
		while xa < x1 - 0.01:
			xb = min(x1, xa + 1.0)
			faces = kerb.gbox("W7Kerb", (xa + 0.004, G - 0.08, za), (xb - 0.004, KERB_TOP, zb))
			kerb.map_uv2(faces, uv2)
			xa = xb
	objs = [build(road), build(kerb)]
	for p in (paint, gut):
		if p.bm.faces:
			objs.append(build(p))
	export("road_%s.glb" % kind, objs)


def build_verge(kind):
	w1kit.reset()
	part = GPart("Verge")
	uv2 = lambda q: ((q[0] - L.ROAD_PILOT["x"][0]) / 64.0, (q[2] - L.ROAD_PILOT["z"][0]) / 26.0)  # noqa: E731
	mat, y = ("W7Verge", L.GROUND + 0.01) if kind == "grass" else ("W7Pavers", G)
	faces = []
	for za, zb in ((L.ROAD_PILOT["z"][0], -19.15), (-10.85, L.ROAD_PILOT["z"][1])):
		for xa in range(112, 176, 8):
			faces.append(part.face(mat, [(xa, y, za), (xa + 8, y, za), (xa + 8, y, zb), (xa, y, zb)], (0, 1, 0)))
	part.map_uv2(faces, uv2)
	export("verge_%s.glb" % kind, [build(part, {"W7Verge": 1.0})])


# ------------------------------------------------------------------------------------------------ trees

CELLS = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]   # UV (v up) of the 4 cells


def _limb(bark, mat, start, direction, length, r0, r1, rnd, droop=0.0, segs=4):
	pts, radii = [Vector(start)], [r0]
	d = Vector(direction).normalized()
	for k in range(1, segs + 1):
		t = k / segs
		d = (d + Vector((rnd.uniform(-0.12, 0.12), rnd.uniform(-0.12, 0.12), -droop * t))).normalized()
		pts.append(pts[-1] + d * length / segs)
		radii.append(r0 + (r1 - r0) * t)
	TP.tube(bark, mat, pts, radii, 6)
	return pts


def build_tree(species):
	"""One tree at the origin (glb origin = the trunk's foot on the ground): below 3 m only the trunk, radius <= 0.22 m
	(TreeTrunk: 0.5 x 3 x 0.5); limbs from 3 m; leaf cards from 3.2 m up, none below 3 m."""
	w1kit.reset()
	rnd = random.Random({"bang": 1, "phuong": 2, "xacu": 3}[species] + 26410)
	bark, leaves = TP.Buf("Bark"), TP.Buf("Leaves")
	bm, lm = {"bang": ("W7BarkBang", "W7LeafBang"), "phuong": ("W7BarkPhuong", "W7LeafPhuong"), "xacu": ("W7BarkXacu", "W7LeafXacu")}[species]
	up = Vector((0, 0, 1))
	if species == "bang":
		# Tall straight trunk, tiered whorls of horizontal limbs (pagoda), rosettes of big leaves on the limbs' ends.
		trunk = [Vector((0, 0, h)) for h in (0.0, 3.0, 6.0, 9.0, 11.5)]
		TP.tube(bark, bm, trunk, [0.21, 0.18, 0.14, 0.09, 0.04], 9)
		for tier, (h, reach) in enumerate(((4.1, 4.4), (5.7, 3.8), (7.3, 3.0), (8.9, 2.2), (10.4, 1.4))):
			for k in range(6):
				a = k / 6 * math.tau + tier * 0.6 + rnd.uniform(-0.2, 0.2)
				d = Vector((math.cos(a), math.sin(a), 0.08))
				pts = _limb(bark, bm, (0, 0, h), d, reach, 0.07 - tier * 0.01, 0.02, rnd, droop=0.05)
				for t in (0.3, 0.45, 0.6, 0.75, 0.88, 1.0):
					at = pts[int(t * (len(pts) - 1))]
					size = rnd.uniform(1.3, 1.9) * (1.1 - tier * 0.1)
					TP.card(leaves, lm, at + Vector((0, 0, 0.08)), Vector((math.cos(a + 1.3), math.sin(a + 1.3), 0.0)), up, size, size,
						CELLS[rnd.randrange(2)], base=0.5, radial_from=(0, 0, h + 0.5), normal_mix=0.3)
					TP.card(leaves, lm, at, d + Vector((0, 0, 0.6)), Vector((math.cos(a + 1.57), math.sin(a + 1.57), 0)), size * 0.9, size * 0.7,
						CELLS[2 + rnd.randrange(2)], base=0.4, radial_from=(0, 0, h), normal_mix=0.4)
					# Round 3: a third, flatter rosette card turned at random fills the tier (the pilot's crowns read thin).
					b = a + rnd.uniform(-1.2, 1.2)
					TP.card(leaves, lm, at + Vector((0, 0, 0.15)), Vector((math.cos(b), math.sin(b), 0.25)), up, size * 1.05, size * 1.05,
						CELLS[rnd.randrange(2)], base=0.45, radial_from=(0, 0, h + 0.5), normal_mix=0.35)
	elif species == "phuong":
		# Short trunk forking at 3.2 m into 4 spreading limbs, a wide flat umbrella crown of feathery fronds, red flowers.
		TP.tube(bark, bm, [Vector((0, 0, 0)), Vector((0.02, 0, 1.5)), Vector((0.03, 0.01, 3.4))], [0.21, 0.19, 0.17], 9)
		for k in range(5):
			a = k / 5 * math.tau + rnd.uniform(-0.3, 0.3)
			d = Vector((math.cos(a) * 0.8, math.sin(a) * 0.8, 0.7))
			pts = _limb(bark, bm, (0.03, 0.01, 3.4), d, 4.2, 0.12, 0.05, rnd, droop=0.1)
			for j in range(4):
				b = a + rnd.uniform(-0.7, 0.7)
				d2 = Vector((math.cos(b), math.sin(b), 0.15))
				sub = _limb(bark, bm, pts[-2], d2, 2.6, 0.05, 0.015, rnd, droop=0.2, segs=3)
				for at in sub[1:]:
					for n in range(6):
						c = b + rnd.uniform(-1.2, 1.2)
						size = rnd.uniform(1.6, 2.4)
						TP.card(leaves, lm, at + Vector((rnd.uniform(-0.4, 0.4), rnd.uniform(-0.4, 0.4), 0.3)), Vector((math.cos(c), math.sin(c), 0.25)),
							up, size, size, CELLS[rnd.randrange(3)], base=0.3, radial_from=(0, 0, 4.0), normal_mix=0.5)
					if rnd.random() < 0.5:
						TP.card(leaves, lm, at + Vector((0, 0, 0.5)), Vector((1, 0, 0.3)), up, 1.2, 1.2, CELLS[3], base=0.3, radial_from=(0, 0, 4.0))
	else:
		# Xà cừ: tall clean trunk to 5 m, a dense rounded crown of many sprays.
		trunk = [Vector((0, 0, h)) for h in (0.0, 3.0, 5.0, 8.0, 11.0, 13.0)]
		TP.tube(bark, bm, trunk, [0.22, 0.2, 0.17, 0.12, 0.07, 0.03], 9)
		for k in range(16):
			h = 5.0 + k * 0.5
			a = k * 2.4 + rnd.uniform(-0.3, 0.3)
			d = Vector((math.cos(a), math.sin(a), 0.55))
			pts = _limb(bark, bm, (0, 0, h), d, 3.4 - k * 0.1, 0.08, 0.02, rnd)
			for at in pts[1:]:
				for n in range(6):
					c = a + rnd.uniform(-1.4, 1.4)
					size = rnd.uniform(1.4, 2.0)
					TP.card(leaves, lm, at, Vector((math.cos(c), math.sin(c), 0.6)), Vector((math.cos(c + 1.5), math.sin(c + 1.5), 0.2)), size, size,
						CELLS[rnd.randrange(4)], base=0.4, radial_from=(0, 0, 8.5), normal_mix=0.55)
	low = [v for v in leaves.v if v.z < 3.0]
	trunk_out = [v for v in bark.v if v.z < 3.0 and math.hypot(v.x, v.y) > 0.24]
	print("T264_TREE %s: bark %d tris, leaves %d tris, %d leaf verts under 3 m, %d bark verts outside the trunk box" % (species, bark.tris(),
		leaves.tris(), len(low), len(trunk_out)))
	objs = [bark.build(), leaves.build()]
	export("tree_%s.glb" % species, objs)


# ------------------------------------------------------------------------------------------------ lamps, bench, moped, fence

def build_lamp(kind):
	"""At each pilot point (x, z), the pole's foot; the arm reaches over the road (+z)."""
	w1kit.reset()
	pole, head, glass = GPart("Pole"), GPart("Head"), GPart("LampGlass")
	for x, z in L.PILOT_LAMPS:
		if kind == "steel":
			pole.cylinder("W4PoleSteel", tuple(B((x, G + 4.0, z))), 0.09, 8.0, segments=8, radius2=0.05)
			pole.cylinder("W4PoleSteel", tuple(B((x, G + 0.3, z))), 0.16, 0.6, segments=8)
			pts = [(x, G + 7.6, z), (x, G + 8.1, z + 0.4), (x, G + 8.3, z + 1.2), (x, G + 8.3, z + 2.0)]
			pole.pipe("W4PoleSteel", pts, 0.04, sides=6)
			head.gbox("W4FloodBody", (x - 0.16, G + 8.18, z + 1.8), (x + 0.16, G + 8.34, z + 2.5))
			glass.face("W7LampGlass", [(x - 0.13, G + 8.17, z + 1.85), (x + 0.13, G + 8.17, z + 1.85), (x + 0.13, G + 8.17, z + 2.45), (x - 0.13, G + 8.17, z + 2.45)], (0, -1, 0))
		else:
			pole.cylinder("W7Concrete", tuple(B((x, G + 4.25, z))), 0.13, 8.5, segments=10, radius2=0.08)
			pole.gbox("W1Iron", (x - 0.05, G + 7.4, z - 0.05), (x + 0.05, G + 7.6, z + 0.12))
			pole.pipe("W1Iron", [(x, G + 7.5, z + 0.1), (x, G + 7.9, z + 1.0), (x, G + 8.0, z + 1.6)], 0.03, sides=6)
			head.cylinder("W4FloodBody", tuple(B((x, G + 7.95, z + 1.85))), 0.16, 0.6, axis="Y", segments=8, radius2=0.1)
			glass.face("W7LampGlass", [(x - 0.12, G + 7.86, z + 1.62), (x + 0.12, G + 7.86, z + 1.62), (x + 0.12, G + 7.86, z + 2.1), (x - 0.12, G + 7.86, z + 2.1)], (0, -1, 0))
	export("lamp_%s.glb" % kind, [build(pole, {"W4PoleSteel": 1.0, "W1Iron": 1.0}), build(head, {"W4FloodBody": 1.0}), build(glass)])


def build_bench():
	"""RoadBench2: a precast concrete bench with a terrazzo seat and back, inside BenchBody2 (2.4 x 0.8 x 0.6 at -9.5)."""
	w1kit.reset()
	part = GPart("Bench")
	x, z = L.BENCH
	for dx in (-0.85, 0.85):
		part.gbox("W1Concrete", (x + dx - 0.08, G, z - 0.25), (x + dx + 0.08, G + 0.42, z + 0.25))
		part.gbox("W1Concrete", (x + dx - 0.08, G + 0.42, z + 0.18), (x + dx + 0.08, G + 0.8, z + 0.28))
	part.gbox("W1Terrazzo", (x - 1.18, G + 0.42, z - 0.28), (x + 1.18, G + 0.5, z + 0.18))
	part.gbox("W1Terrazzo", (x - 1.18, G + 0.55, z + 0.18), (x + 1.18, G + 0.79, z + 0.26))
	export("bench.glb", [build(part, {"W1Concrete": 0.8, "W1Terrazzo": 1.0})])


def build_moped():
	"""FallenMoped1: an underbone moped (red panels) on its side inside MopedBody1 (1.8 x 0.6 x 1.1 at -9.6)."""
	w1kit.reset()
	rnd = random.Random(26406)
	part = GPart("Moped")
	x, z = L.MOPED
	# Built standing in its own frame (x along, y up, z across), then laid on its left side (rotated about x) and turned.
	lie = Matrix.Translation(B((x, G + 0.3, z + 0.07))) @ Matrix.Rotation(math.radians(8), 4, "Z") @ Matrix.Rotation(math.radians(88), 4, "X") @ Matrix.Translation((0, 0, -0.55))
	for cx in (-0.62, 0.62):
		f = part.cylinder("W7Palette", (cx, 0.0, 0.3), 0.29, 0.09, axis="Y", segments=14, matrix=lie)
		pal(part, f, "rubber", rnd)
		f = part.cylinder("W7Palette", (cx, -0.002, 0.3), 0.17, 0.095, axis="Y", segments=10, matrix=lie)
		pal(part, f, "chrome", rnd)
	for lo, hi, key in (((-0.45, -0.17, 0.35), (0.35, 0.17, 0.62), "moped_red"), ((-0.5, -0.14, 0.62), (0.15, 0.14, 0.75), "seat"),
			((0.3, -0.12, 0.45), (0.55, 0.12, 0.95), "moped_red"), ((0.45, -0.32, 0.95), (0.52, 0.32, 0.99), "black"),
			((0.52, -0.08, 0.85), (0.6, 0.08, 0.95), "lamp_white"), ((-0.75, -0.08, 0.55), (-0.6, 0.08, 0.62), "lamp_red"),
			((-0.6, 0.14, 0.18), (0.05, 0.2, 0.26), "chrome")):
		f = part.box("W7Palette", (lo[0], lo[1], lo[2]), (hi[0], hi[1], hi[2]), matrix=lie)
		pal(part, f, key, rnd)
	f = part.box("W7Palette", (0.5, -0.03, 0.3), (0.58, 0.03, 0.9), matrix=lie)
	pal(part, f, "black", rnd)
	export("moped.glb", [build(part, {"W7Palette": 1.0})])


def build_fence(kind):
	"""Fence/W from z 95 to 125 inside its collider (x -80.15..-79.85, 3 m)."""
	w1kit.reset()
	solid, near = GPart("Solid"), GPart("Bars")
	xw = L.FENCE_W_PILOT["x"]
	za, zb = L.FENCE_W_PILOT["z"]
	if kind == "w1":
		posts = [za + 3.0 * k for k in range(int((zb - za) / 3.0) + 1)]
		for p in posts:
			solid.gbox("W5Plaster", (xw - 0.15, G - 0.06, p - 0.15), (xw + 0.15, G + 2.92, p + 0.15))
			solid.gbox("W5Plaster", (xw - 0.15, G + 2.92, p - 0.17), (xw + 0.15, G + 3.0, p + 0.17))
		for pa, pb in zip(posts, posts[1:]):
			solid.gbox("W5Plaster", (xw - 0.1, G - 0.06, pa + 0.15), (xw + 0.1, G + 1.8, pb - 0.15), skip=("-z", "+z"))
			solid.gbox("W5Plaster", (xw - 0.13, G + 1.8, pa + 0.15), (xw + 0.13, G + 1.86, pb - 0.15), skip=("-z", "+z"))
			n = max(1, int((pb - pa - 0.3) / 0.12))
			for i in range(1, n):
				zb2 = pa + 0.15 + (pb - pa - 0.3) * i / n
				near.beam("W5GateGreen", (xw, G + 1.86, zb2), (xw, G + 2.93, zb2), 0.02, 0.02, caps=False)
			near.beam("W5GateGreen", (xw, G + 2.93, pa + 0.15), (xw, G + 2.93, pb - 0.15), 0.04, 0.04, caps=False)
		GP.ensure_uv2(solid)
		export("fence_w1.glb", [build(solid), build(near, {"W5GateGreen": 1.0})])
	else:
		posts = [za + 2.5 * k for k in range(int((zb - za) / 2.5) + 1)]
		solid.gbox("W1Concrete", (xw - 0.12, G - 0.06, za), (xw + 0.12, G + 0.25, zb))
		for p in posts:
			solid.cylinder("W4PoleSteel", tuple(B((xw, G + 1.35, p))), 0.03, 2.4, segments=8)
		solid.pipe("W4PoleSteel", [(xw, G + 2.5, za), (xw, G + 2.5, zb)], 0.022, sides=6)
		near.face("W4Chainlink", [(xw, G + 0.25, za), (xw, G + 0.25, zb), (xw, G + 2.48, zb), (xw, G + 2.48, za)], (1, 0, 0),
			[(0.0, 0.0), ((zb - za) / 0.5, 0.0), ((zb - za) / 0.5, 2.23 / 0.5), (0.0, 2.23 / 0.5)])
		keep(near, list(near.bm.faces))
		export("fence_b40.glb", [build(solid, {"W1Concrete": 0.8, "W4PoleSteel": 1.0}), build(near)])


BUILDS = {"bldga_wall": lambda: build_bldga("wall"), "bldga_gallery": lambda: build_bldga("gallery"), "gym_r1": lambda: build_gym("r1"),
	"gym_r2": lambda: build_gym("r2"), "b_outside": build_b_outside, "road_asphalt": lambda: build_road("asphalt"),
	"road_slab": lambda: build_road("slab"), "verge_grass": lambda: build_verge("grass"), "verge_pavers": lambda: build_verge("pavers"),
	"tree_bang": lambda: build_tree("bang"), "tree_phuong": lambda: build_tree("phuong"), "tree_xacu": lambda: build_tree("xacu"),
	"lamp_steel": lambda: build_lamp("steel"), "lamp_concrete": lambda: build_lamp("concrete"), "bench": build_bench, "moped": build_moped,
	"fence_w1": lambda: build_fence("w1"), "fence_b40": lambda: build_fence("b40")}


if __name__ == "__main__":
	random.seed(264)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
