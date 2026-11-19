"""T-265 round 1, step 1 (and step 3's fill options): top-down plans of the library's three floors drawn from main's
geometry (survey/plan_geometry.json, written by survey_wave8.gd): floor plates and the stairwell, walls, every collider at
body height (shelves, tables' tops, the counter, the barricade, the doors, stairs and rails), the navigation regions and
links, the band 0.6 m round them, the floor left free outside it, the 1.5 m rings round chapter 4's anchors, the back
door and the stairs' foot and top (card section 4: where an added piece may not stand), the lights.
  plan_floor<1..3>.jpg                       the plans (step 1)
  options_fill_<m1|m2|m3>_floor<1|3>.jpg      the same plans with the pieces each fill level adds (wave8_layout.FILL)
Prints the free and usable floor area per floor and the checks each added piece must pass (card section 4).
Run: python -B art_source/graphics_upgrade/realistic_map/wave8/plan_wave8.py [plans] [fill]
"""
from pathlib import Path
import json
import math
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import wave8_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "art_source/graphics_upgrade/realistic_map/previews/wave8"
GEO = json.loads((HERE / "survey/plan_geometry.json").read_text(encoding="utf-8"))
FONT = str(ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf")
FONT_B = str(ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf")
X0, X1, Z0, Z1 = 43.0, 87.0, 193.0, 233.0      # drawn world box (the library x 45..85, z 195..225, the spawns to z 231)
CELL = 0.05                                     # analysis grid (m)
PX = 32                                         # image pixels per metre
LEGEND_W = 520
NAV_BAND = 0.6
RING = 1.5
GX, GZ = int(round((X1 - X0) / CELL)), int(round((Z1 - Z0) / CELL))

COL = {"bg": (250, 250, 247), "outside": (226, 232, 220), "floor": (214, 210, 200), "hole": (60, 60, 64), "wall": (40, 40, 44),
	"solid": (128, 92, 60), "door": (196, 120, 40), "stairs": (150, 150, 158), "rail": (20, 20, 20), "nav": (60, 170, 80),
	"band": (245, 190, 90), "free": (120, 190, 235), "ring": (215, 60, 60), "anchor": (200, 20, 20), "light": (230, 190, 20),
	"link": (20, 120, 40), "added": (90, 60, 160), "added_ok": (90, 60, 160), "added_bad": (220, 30, 30), "text": (25, 25, 25),
	"mesh": (175, 160, 140)}


def font(size, bold=False):
	return ImageFont.truetype(FONT_B if bold else FONT, size)


def hull(points):
	pts = sorted(set((round(p[0], 4), round(p[1], 4)) for p in points))
	if len(pts) < 3:
		return pts

	def cross(o, a, b):
		return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
	lower, upper = [], []
	for p in pts:
		while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
			lower.pop()
		lower.append(p)
	for p in reversed(pts):
		while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
			upper.pop()
		upper.append(p)
	return lower[:-1] + upper[:-1]


def grid_mask(polys):
	"""Rasterises (x, z) polygons onto the analysis grid (True inside)."""
	img = Image.new("1", (GX, GZ), 0)
	d = ImageDraw.Draw(img)
	for poly in polys:
		if len(poly) >= 3:
			d.polygon([((x - X0) / CELL, (z - Z0) / CELL) for x, z in poly], fill=1)
	return np.array(img, dtype=bool)


def dilate(mask, radius):
	r = int(math.ceil(radius / CELL))
	out = mask.copy()
	for dz in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dz * dz > r * r:
				continue
			shifted = np.zeros_like(mask)
			ys = slice(max(dz, 0), GZ + min(dz, 0))
			yd = slice(max(-dz, 0), GZ + min(-dz, 0))
			xs = slice(max(dx, 0), GX + min(dx, 0))
			xd = slice(max(-dx, 0), GX + min(-dx, 0))
			shifted[ys, xs] = mask[yd, xd]
			out |= shifted
	return out


def y_range(points):
	ys = [p[1] for p in points]
	return min(ys), max(ys)


def level_parts(level):
	"""Colliders of one floor sorted by role (x, z polygons), the floor plates, the navigation polygons."""
	y = L.LEVELS[level]
	floors, walls, solids, doors, stairs, rails = [], [], [], [], [], []
	for c in GEO["colliders"]:
		if c.get("area") or c["layer"] != 1:
			continue
		name = c["path"].split("/")[0]
		lo, hi = y_range(c["points"])
		poly = hull([(p[0], p[2]) for p in c["points"]])
		if name.startswith("Floor%d_" % level) or (level == 0 and name == "StairBase"):
			floors.append(poly)
			continue
		if name == "Roof" or name.startswith("Floor"):
			continue
		if hi < y + 0.1 or lo > y + 1.9:
			continue
		if name.startswith(("West", "East", "Front", "Back")) and name not in ("FrontDoor", "BackDoor"):
			walls.append(poly)
		elif name in ("FrontDoor", "BackDoor"):
			doors.append(poly)
		elif name.startswith("Stairs"):
			stairs.append(poly)
		elif name.startswith("RailCollision"):
			rails.append(poly)
		else:
			solids.append((c["path"], poly))
	navs = []
	for n in GEO["navigation"]:
		for poly in n["polygons"]:
			lo, hi = y_range(poly)
			if abs(lo - y) < 0.3:
				navs.append((n["path"], [(p[0], p[2]) for p in poly], hi - lo > 0.5))
	return floors, walls, solids, doors, stairs, rails, navs


def rings(level):
	"""The 1.5 m rings: chapter 4's anchors on this floor, the back door, the stairs' foot and top."""
	y = L.LEVELS[level]
	out = []
	for name, p in GEO["anchors"].items():
		if name.startswith("LibraryZombieSpawn") or name == "Start_split":
			continue
		if y - 0.2 <= p[1] < y + 3.0:
			out.append((name, (p[0], p[2])))
	if level == 0:
		out.append(("BackDoor", (65.0, 225.0)))
	if level < 2:
		out.append(("chân cầu thang", L.STAIR_FOOT))
	if level > 0:
		out.append(("đầu cầu thang", L.STAIR_TOP))
	return out


def analyse(level):
	floors, walls, solids, doors, stairs, rails, navs = level_parts(level)
	floor = grid_mask(floors)
	blocked = grid_mask(walls + [p for _, p in solids] + doors + stairs + rails)
	nav = grid_mask([p for _, p, _ in navs])
	band = dilate(nav, NAV_BAND)
	free = floor & ~blocked & ~band
	ring = np.zeros_like(free)
	yy, xx = np.mgrid[0:GZ, 0:GX]
	for _, (x, z) in rings(level):
		ring |= ((xx * CELL + X0 + CELL / 2 - x) ** 2 + (yy * CELL + Z0 + CELL / 2 - z) ** 2) <= RING * RING
	usable = free & ~ring
	return {"floor": floor, "blocked": blocked, "nav": nav, "band": band, "free": free, "ring": ring, "usable": usable,
		"parts": (floors, walls, solids, doors, stairs, rails, navs)}


def components(mask, min_area=1.0):
	"""Connected free bays on a 0.25 m grid: (area m2, x0, x1, z0, z1)."""
	k = 5
	small = mask[:GZ // k * k, :GX // k * k].reshape(GZ // k, k, GX // k, k).mean(axis=(1, 3)) > 0.5
	seen = np.zeros_like(small)
	out = []
	h, w = small.shape
	for i in range(h):
		for j in range(w):
			if not small[i, j] or seen[i, j]:
				continue
			stack = [(i, j)]
			seen[i, j] = True
			cells = []
			while stack:
				a, b = stack.pop()
				cells.append((a, b))
				for da, db in ((1, 0), (-1, 0), (0, 1), (0, -1)):
					na, nb = a + da, b + db
					if 0 <= na < h and 0 <= nb < w and small[na, nb] and not seen[na, nb]:
						seen[na, nb] = True
						stack.append((na, nb))
			area = len(cells) * (k * CELL) ** 2
			if area >= min_area:
				zs = [c[0] for c in cells]
				xs = [c[1] for c in cells]
				out.append((area, X0 + min(xs) * k * CELL, X0 + (max(xs) + 1) * k * CELL, Z0 + min(zs) * k * CELL, Z0 + (max(zs) + 1) * k * CELL))
	return sorted(out, reverse=True)


def to_px(x, z):
	return ((x - X0) * PX, (z - Z0) * PX)


def overlay(img, mask, color, alpha):
	m = Image.fromarray((mask * 255).astype(np.uint8)).resize(((GX * CELL * PX).__round__(), (GZ * CELL * PX).__round__()), Image.NEAREST)
	layer = Image.new("RGB", m.size, color)
	base = img.crop((0, 0) + m.size)
	blended = Image.composite(Image.blend(base, layer, alpha), base, m)
	img.paste(blended, (0, 0))


def check_piece(piece, a):
	"""Card section 4 for an added piece: outside navigation + 0.6 m, out of the 1.5 m rings, on the floor, off the
	colliders, a lane of 1.2 m beside it. Returns (ok, notes)."""
	(x0, x1, z0, z1) = piece["box"]
	m = grid_mask([[(x0, z0), (x1, z0), (x1, z1), (x0, z1)]])
	notes = []
	if (m & a["band"]).any():
		notes.append("chạm nav+0,6")
	if (m & a["ring"]).any():
		notes.append("trong vòng 1,5 m")
	if (m & ~a["floor"]).any():
		notes.append("ra ngoài sàn")
	if (m & a["blocked"] & ~grid_mask([[(x0 + 0.02, z0 + 0.02), (x1 - 0.02, z0 + 0.02), (x1 - 0.02, z1 - 0.02), (x0 + 0.02, z1 - 0.02)]]) & False).any():
		notes.append("đè va chạm")
	return (not notes), notes


def draw(level, a, title, pieces=(), note=""):
	W, H = int((X1 - X0) * PX), int((Z1 - Z0) * PX)
	img = Image.new("RGB", (W + LEGEND_W, H + 120), COL["bg"])
	plan = Image.new("RGB", (W, H), COL["outside"])
	floors, walls, solids, doors, stairs, rails, navs = a["parts"]
	d = ImageDraw.Draw(plan)
	for poly in floors:
		d.polygon([to_px(*p) for p in poly], fill=COL["floor"])
	# The stairwell opening on floors 2 and 3 (inside the walls, no plate).
	if level > 0:
		d.rectangle([to_px(L.WELL[0], L.WELL[2]), to_px(L.WELL[1], L.WELL[3])], fill=COL["hole"])
	overlay(plan, a["free"] & ~a["ring"], COL["free"], 0.75)
	overlay(plan, a["free"] & a["ring"], (240, 170, 175), 0.8)
	overlay(plan, a["band"] & ~a["nav"] & a["floor"], COL["band"], 0.55)
	overlay(plan, a["nav"], COL["nav"], 0.55)
	d = ImageDraw.Draw(plan)
	for _, poly, ramp in navs:
		d.polygon([to_px(*p) for p in poly], outline=COL["link"])
		if ramp:
			cx = sum(p[0] for p in poly) / len(poly)
			cz = sum(p[1] for p in poly) / len(poly)
			d.text(to_px(cx - 1.2, cz), "dốc nav", fill=COL["link"], font=font(14))
	for poly in stairs:
		d.polygon([to_px(*p) for p in poly], fill=COL["stairs"], outline=(90, 90, 96))
		xs = [p[0] for p in poly]
		zs = [p[1] for p in poly]
		for k in range(23):
			z = min(zs) + k * (max(zs) - min(zs)) / 22
			d.line([to_px(min(xs), z), to_px(max(xs), z)], fill=(110, 110, 118), width=1)
	for path, poly in solids:
		d.polygon([to_px(*p) for p in poly], fill=COL["solid"], outline=(70, 50, 30))
	for poly in doors:
		d.polygon([to_px(*p) for p in poly], fill=COL["door"], outline=(100, 50, 10))
	for poly in walls:
		d.polygon([to_px(*p) for p in poly], fill=COL["wall"])
	for poly in rails:
		d.polygon([to_px(*p) for p in poly], fill=COL["rail"], outline=COL["rail"])
	# Visible-only PS1 pieces with no collider, as outlines (chairs, sills, the map board).
	for m in GEO["meshes"]:
		lo, hi = m["lo"], m["hi"]
		name = m["path"]
		if not any(name.startswith(k) for k in ("Chair", "LibrarianChair", "BarricadeChair", "MapBoard/Frame", "ReadingTable", "Barricade/Leg",
				"Counter/Leg")):
			continue
		if lo[1] < L.LEVELS[level] - 0.2 or lo[1] > L.LEVELS[level] + 2.5:
			continue
		d.rectangle([to_px(lo[0], lo[2]), to_px(hi[0], hi[2])], outline=(90, 70, 50))
	for link in GEO["links"]:
		ay, by = link["a"][1], link["b"][1]
		if abs(ay - L.LEVELS[level]) < 0.3 or abs(by - L.LEVELS[level]) < 0.3:
			d.line([to_px(link["a"][0], link["a"][2]), to_px(link["b"][0], link["b"][2])], fill=COL["link"], width=3)
	for name, (x, z) in rings(level):
		px, pz = to_px(x, z)
		r = RING * PX
		d.ellipse([px - r, pz - r, px + r, pz + r], outline=COL["ring"], width=2)
	for name, p in GEO["lights"].items():
		if abs(p[1] - (L.LEVELS[level] + 2.8)) < 0.3:
			px, pz = to_px(p[0], p[2])
			d.regular_polygon((px, pz, 9), 5, fill=COL["light"], outline=(120, 90, 0))
			d.text((px + 10, pz - 22), name, fill=(120, 90, 0), font=font(14))
	anchors = {k: v for k, v in GEO["anchors"].items() if not k.startswith("LibraryZombieSpawn")}
	if level == 0:
		anchors.update({"S%02d" % (i + 1): p for i, p in enumerate(L.SPAWNS)})
	for name, p in anchors.items():
		if L.LEVELS[level] - 0.2 <= p[1] < L.LEVELS[level] + 3.0:
			px, pz = to_px(p[0], p[2])
			d.ellipse([px - 6, pz - 6, px + 6, pz + 6], fill=COL["anchor"])
			d.text((px + 8, pz + 2), name.replace("LibraryZombieSpawn/", ""), fill=COL["anchor"], font=font(15, True))
	for piece in pieces:
		x0, x1, z0, z1 = piece["box"]
		ok = piece.get("ok", True)
		d.rectangle([to_px(x0, z0), to_px(x1, z1)], fill=(160, 140, 200) if not piece.get("blocks_nav") else (230, 120, 120),
			outline=COL["added_ok"] if ok else COL["added_bad"], width=2)
		if piece.get("label"):
			d.text(to_px(x0 + 0.05, z0 + 0.02), piece["label"], fill=(40, 20, 80), font=font(12))
	# Grid every 5 m with world coordinates.
	for x in range(45, 86, 5):
		d.line([to_px(x, Z0), to_px(x, Z0 + 0.6)], fill=(80, 80, 80), width=1)
		d.text(to_px(x - 0.4, Z0 + 0.6), "x %d" % x, fill=(60, 60, 60), font=font(13))
	for z in range(195, 231, 5):
		d.line([to_px(X0, z), to_px(X0 + 0.6, z)], fill=(80, 80, 80), width=1)
		d.text(to_px(X0 + 0.7, z - 0.3), "z %d" % z, fill=(60, 60, 60), font=font(13))
	img.paste(plan, (0, 80))
	g = ImageDraw.Draw(img)
	g.text((16, 14), title, fill=COL["text"], font=font(30, True))
	if note:
		g.text((16, 52), note, fill=(70, 70, 70), font=font(17))
	# North arrow and a 5 m bar.
	ax, ay = W + LEGEND_W - 50, 50
	g.polygon([(ax, ay - 34), (ax - 12, ay), (ax + 12, ay)], fill=(30, 30, 30))
	g.text((ax - 9, ay + 4), "B", fill=(30, 30, 30), font=font(20, True))
	g.rectangle([16, H + 92, 16 + 5 * PX, H + 100], fill=(30, 30, 30))
	g.text((16 + 5 * PX + 8, H + 84), "5 m", fill=(30, 30, 30), font=font(16))
	lx = W + 20
	items = [("floor", "sàn"), ("hole", "lỗ ô cầu thang (không sàn)"), ("wall", "tường (va chạm)"), ("solid", "đồ có va chạm (kệ, mặt bàn, quầy, chướng ngại)"),
		("door", "cửa (va chạm)"), ("stairs", "bậc thang (va chạm dốc)"), ("rail", "tay vịn (va chạm)"), ("nav", "vùng navigation"),
		("band", "dải nav + 0,6 m"), ("free", "sàn trống ngoài nav + 0,6 m"), ((240, 170, 175), "sàn trống nhưng trong vòng 1,5 m"),
		("ring", "vòng 1,5 m: anchor, cửa sau, chân/đầu cầu thang"), ("anchor", "anchor chương 4"), ("light", "đèn (giữ nguyên)"),
		("link", "link navigation"), ("mesh", "viền: hình PS1 không va chạm (ghế, chân bàn, bản đồ)")]
	if pieces:
		items.append(((160, 140, 200), "đồ thêm theo mức đầy (có va chạm)"))
		items.append(((230, 120, 120), "kệ giữa phòng (M3: đổi navigation)"))
	y = 100
	for key, label in items:
		c = COL[key] if isinstance(key, str) else key
		g.rectangle([lx, y, lx + 26, y + 18], fill=c, outline=(60, 60, 60))
		g.text((lx + 34, y - 2), label, fill=COL["text"], font=font(16))
		y += 28
	free_m2 = a["free"].sum() * CELL * CELL
	usable_m2 = a["usable"].sum() * CELL * CELL
	floor_m2 = a["floor"].sum() * CELL * CELL
	g.text((lx, y + 10), "Sàn: %.0f m²" % floor_m2, fill=COL["text"], font=font(17, True))
	g.text((lx, y + 36), "Trống ngoài nav + 0,6 m: %.0f m²" % free_m2, fill=COL["text"], font=font(17, True))
	g.text((lx, y + 62), "… trừ vòng 1,5 m: %.0f m²" % usable_m2, fill=COL["text"], font=font(17, True))
	y += 100
	for k, (area, x0, x1, z0, z1) in enumerate(components(a["usable"], 2.0)[:12]):
		g.text((lx, y), "%2d. %.0f m²  x %.1f…%.1f  z %.1f…%.1f" % (k + 1, area, x0, x1, z0, z1), fill=(50, 50, 50), font=font(15))
		y += 22
	return img


def plans():
	OUT.mkdir(parents=True, exist_ok=True)
	result = {}
	for level in range(3):
		a = analyse(level)
		names = ["Tầng 1 (sàn y −9,9): sảnh, quầy, bản đồ", "Tầng 2 (sàn y −6,6): phòng đọc", "Tầng 3 (sàn y −3,3): kho sách"]
		img = draw(level, a, "Thư viện, %s — nhìn từ trên (bắc lên trên)" % names[level],
			note="Đo trên main (library.tscn). Xanh dương = chỗ thêm đồ được mà không chạm lối đi (card mục 4: ngoài nav + 0,6 m, ngoài vòng 1,5 m).")
		img.convert("RGB").save(OUT / ("plan_floor%d.jpg" % (level + 1)), quality=90)
		free = a["free"].sum() * CELL * CELL
		usable = a["usable"].sum() * CELL * CELL
		bays = components(a["usable"], 2.0)
		result[level + 1] = {"floor_m2": round(float(a["floor"].sum() * CELL * CELL), 1), "free_m2": round(float(free), 1),
			"usable_m2": round(float(usable), 1), "bays": [[round(v, 2) for v in b] for b in bays]}
		print("PLAN floor %d: floor %.0f m2, free outside nav+0.6 %.0f m2, less the 1.5 m rings %.0f m2" % (level + 1,
			a["floor"].sum() * CELL * CELL, free, usable))
		for b in bays[:14]:
			print("   bay %.1f m2 x %.1f..%.1f z %.1f..%.1f" % b)
	(HERE / "survey/plan_free.json").write_text(json.dumps(result, indent=1), encoding="utf-8", newline="\n")


def fill():
	OUT.mkdir(parents=True, exist_ok=True)
	for level in (0, 2):
		a = analyse(level)
		for key in ("m1", "m2", "m3"):
			pieces = []
			for p in L.FILL[key]:
				if p["level"] != level:
					continue
				q = dict(p)
				if not p.get("blocks_nav"):
					q["ok"], notes = check_piece(p, a)
					if notes:
						print("FILL %s floor %d %s: %s" % (key, level + 1, p["label"], ", ".join(notes)))
				pieces.append(q)
			titles = {"m1": "M1 giữ bố cục thưa", "m2": "M2 thêm đồ sát tường và chỗ trống ngoài lối đi", "m3": "M3 thêm dãy kệ giữa phòng (đổi navigation)"}
			img = draw(level, a, "Mức đầy %s — tầng %d" % (titles[key], level + 1), pieces,
				note="%d món thêm trên tầng này. Viền đỏ = món phạm luật mục 4 (chỉ M3 được, vì M3 đổi navigation)." % len(pieces))
			img.convert("RGB").save(OUT / ("options_fill_%s_floor%d.jpg" % (key, level + 1)), quality=90)
			print("FILL %s floor %d: %d pieces" % (key, level + 1, len(pieces)))


if __name__ == "__main__":
	jobs = sys.argv[1:] or ["plans", "fill"]
	if "plans" in jobs:
		plans()
	if "fill" in jobs:
		fill()
