"""T-264 round 3: what this wave replaces in props.tscn, instance by instance, in the rest of A16 (wave7_layout.region ==
'rest'). Pure Python (Blender's interpreter and patch_wave7.py import it). The PS1 street props (art_source/campus/
scatter.py) are composites: each object is found by its anchor piece (the car's body, the moped's body, the bicycle's
seat, the shelter's roof, ...), its other pieces by their size near the anchor. Anchors in the rest are replaced with
their pieces (pieces may lie just over a region's edge); loose things (rubble, rods, papers, glass, sandals, shoes) are
replaced where they lie in the rest. Never touched: drag marks and cracks (D_iron), blood (D_red), corpse pieces (none in
the rest: 0 heads, round 1), and the two phones (a screen quad paired with a D_iron quad).

An instance: (chunk name, index, basis columns (3 x 3), origin, rgba); see boxes.gd.
"""
import json
import math
from pathlib import Path

import wave7_layout as L

HERE = Path(__file__).resolve().parent
PS1 = HERE / "w7_ps1_props.json"
SKIN = (0.9, 0.7, 0.6)


def _close(s, t, tol=0.012):
	return all(abs(a - b) <= tol + 0.02 * b for a, b in zip(s, t))


def scale_of(basis):
	return tuple(math.sqrt(sum(v * v for v in col)) for col in basis)


# Anchor pieces: (kind, chunk prefix, scale, radius within which its pieces lie).
ANCHORS = [
	("car", "P_white_box", (4.2, 0.62, 1.8), 2.8),
	("moped", "P_white_box", (1.15, 0.3, 0.3), 1.3),
	("bicycle", "P_wood_box", (0.22, 0.05, 0.1), 1.0),
	("kiosk", "P_white_box", (3.0, 2.3, 2.0), 2.6),
	("planter", "P_concrete_box", (2.4, 0.6, 0.9), 1.7),
	("bin", "P_white_cylinder", (0.52, 0.84, 0.52), 0.5),
	("signpost", "P_iron_cylinder", (0.11, 2.8, 0.11), 1.7),
	("lamp_fallen", "P_iron_cylinder", (0.2, 6.4, 0.2), 4.0),
	("lamp_leaning", "P_iron_cylinder", (0.2, 6.8, 0.2), 4.0),
	("lit_lamp", "P_iron_cylinder", (0.14, 5.2, 0.14), 3.0),
	("bench", "P_concrete_box", (2.0, 0.1, 0.5), 1.3),
]
# Pieces of each kind (chunk prefix, scale).
PIECES = {
	"car": [("P_white_box", (2.3, 0.62, 1.62)), ("P_white_box", (2.34, 0.42, 1.66)), ("P_white_box", (2.4, 0.08, 1.7)),
		("P_white_box", (0.08, 0.14, 0.3)), ("P_iron_cylinder", (0.68, 0.24, 0.68)), ("P_iron_box", (0.18, 0.22, 1.7)),
		("P_paper_box", (0.08, 0.16, 0.3))],
	"moped": [("P_iron_cylinder", (0.56, 0.13, 0.56)), ("P_white_box", (0.6, 0.1, 0.32)), ("P_iron_box", (0.08, 0.06, 0.62)),
		("P_iron_box", (0.06, 0.62, 0.08)), ("P_paper_box", (0.1, 0.12, 0.16))],
	"bicycle": [("P_iron_cylinder", (0.66, 0.035, 0.66)), ("P_iron_box", (0.9, 0.035, 0.035)), ("P_iron_box", (0.035, 0.4, 0.035)),
		("P_iron_box", (0.035, 0.55, 0.035)), ("P_iron_box", (0.04, 0.04, 0.5))],
	"shelter": [("P_iron_box", (0.14, 2.5, 0.14)), ("P_concrete_box", None), ("P_iron_cylinder", (0.66, 0.035, 0.66)),
		("P_iron_box", (0.035, 0.035, 0.8)), ("P_iron_box", (0.5, 0.04, 0.04))],
	"kiosk": [("P_white_box", (2.6, 1.5, 0.06)), ("P_white_box", (2.2, 0.38, 0.05)), ("P_red_box", (3.6, 0.1, 1.5)),
		("P_concrete_box", (3.0, 0.12, 0.5))],
	"planter": [("P_grass_box", (2.2, 0.06, 0.7)), ("P_white_cone", (0.95, 0.85, 0.95))],
	"bin": [],
	"signpost": [("P_white_box", (1.4, 0.55, 0.05)), ("P_white_box", (0.7, 0.1, 0.02)), ("P_white_box", (0.28, 0.09, 0.02))],
	"lamp_fallen": [("P_iron_box", (1.0, 0.08, 0.08)), ("P_paper_box", (0.5, 0.1, 0.3))],
	"lamp_leaning": [("P_iron_box", (1.0, 0.08, 0.08)), ("P_paper_box", (0.5, 0.1, 0.3))],
	"lit_lamp": [("P_iron_box", (0.8, 0.07, 0.07)), ("P_paper_box", (0.45, 0.1, 0.28))],
	"bench": [("P_concrete_box", (2.0, 0.45, 0.08)), ("P_concrete_box", (0.1, 0.45, 0.45))],
}


def chunk_base(name):
	"""'P_concrete_box_m1_p2' -> 'P_concrete_box'."""
	parts = name.split("_")
	return "_".join(parts[:3])


def instances(data):
	"""Every non-zero instance of the dumped chunks: (chunk, index, basis, origin, rgba, scale)."""
	out = []
	for name, entry in data.items():
		v = entry["data"]
		for k in range(0, len(v), 16):
			c = v[k:k + 16]
			basis = (tuple(c[0:3]), tuple(c[3:6]), tuple(c[6:9]))
			s = scale_of(basis)
			if max(s) == 0:
				continue
			out.append((name, k // 16, basis, tuple(c[9:12]), tuple(c[12:16]), s))
	return out


def _shelter_anchor(base, s):
	return base == "P_white_box" and abs(s[1] - 0.12) < 0.02 and abs(s[2] - 2.8) < 0.05 and s[0] > 2.0


def classify(data):
	"""{(chunk, index): (kind, object id or None)} for every instance this wave replaces, and the objects
	[(object id, kind, anchor instance)] whose anchor lies in the rest."""
	inst = instances(data)
	anchors = []
	for it in inst:
		name, k, basis, o, rgba, s = it
		base = chunk_base(name)
		if _shelter_anchor(base, s):
			anchors.append(("shelter", it, s[0] / 2 + 1.6))
			continue
		for kind, prefix, scale, radius in ANCHORS:
			if base == prefix and _close(s, scale):
				anchors.append((kind, it, radius))
				break
	objects = []
	replaced = {}
	taken = set()
	for oid, (kind, it, radius) in enumerate(anchors):
		if L.region(it[3][0], it[3][2]) != "rest":
			continue
		objects.append((oid, kind, it))
		replaced[(it[0], it[1])] = (kind, oid)
		taken.add((it[0], it[1]))
	# Pieces: each to the nearest anchor of a kind that has it (anchors outside the rest claim theirs, so they stay).
	for it in inst:
		name, k, basis, o, rgba, s = it
		key = (name, k)
		if key in taken:
			continue
		base = chunk_base(name)
		best = None
		for oid, (kind, at, radius) in enumerate(anchors):
			if (at[0], at[1]) == key:
				best = None
				break
			fits = False
			for prefix, scale in PIECES[kind]:
				if base != prefix:
					continue
				if scale is None:   # the shelter's back wall: its length, 2 m tall, 0.1 m thick
					fits = abs(s[1] - 2.0) < 0.05 and abs(s[2] - 0.1) < 0.02 and s[0] > 2.0
				else:
					fits = _close(s, scale)
				if fits:
					break
			if not fits:
				continue
			d = math.dist(o, at[3])
			if d <= radius and (best is None or d < best[0]):
				best = (d, oid, kind)
		if best is not None:
			taken.add(key)
			if L.region(anchors[best[1]][1][3][0], anchors[best[1]][1][3][2]) == "rest":
				replaced[key] = (best[2], best[1])
	# Loose things in the rest.
	for it in inst:
		name, k, basis, o, rgba, s = it
		key = (name, k)
		if key in taken or L.region(o[0], o[2]) != "rest":
			continue
		base = chunk_base(name)
		tint = tuple(round(t, 2) for t in rgba[:3])
		kind = None
		if tint == SKIN or base.startswith("D_iron") or base.startswith("D_red"):
			kind = None
		elif base == "P_concrete_box":
			kind = "rubble"
		elif base == "P_iron_cylinder" and _close(s, (0.04, 1.1, 0.04)):
			kind = "rod"
		elif base == "D_paper_quad":
			kind = "paper"
		elif base == "D_white_quad" and tint == (0.55, 0.75, 0.85):
			kind = "glass"
		elif base == "D_white_quad" and _close(s, (0.11, 1.0, 0.27)):
			kind = "sandal"
		elif base == "P_white_box" and _close(s, (0.26, 0.1, 0.1)):
			kind = "shoe"
		if kind:
			replaced[key] = (kind, None)
	return replaced, objects


def load():
	return json.loads(PS1.read_text(encoding="utf-8"))


def surface_y(x, z):
	"""The new floor's top at (x, z): roads and forecourts, verge, or (outside this wave's ground) G."""
	kind = L.ground_kind(x, z)
	if kind in ("road", "paved"):
		return L.ROAD_Y
	if kind in ("verge", "edge", "kerb"):
		return L.VERGE_Y
	return L.G


if __name__ == "__main__":
	import collections
	rep, objs = classify(load())
	print(collections.Counter(k for k, _ in rep.values()))
	print(collections.Counter(k for _, k, _ in objs))
