"""T-255: textures drawn here (numpy + Pillow), no downloaded image and no AI image.
  mask_rooms.png   the ageing masks of the seven room shells (room407_shell.gdshader on UV2; rooms_layout.py maps
                   each room to a 2048 x 1024 region): walls R paint loss, G grime, B water stain, A mould; floors
                   R grout dirt, G grime, B wet, A wear. Drawn from each room's plan: hand marks by its doors, heads
                   and shoulders on the walls by the bunks, the path from the door to the desks and the balcony,
                   damp round the bathroom; how worn depends on the room (405 half abandoned is the worst).
  recoloured copies of room 407's fabrics (its Tripo blankets and pillow, the curtain, the T-shirt), so each room's
                   students have their own colours: <name>_<colour>.jpg next to the originals' look.
Run: python -B art_source/graphics_upgrade/floor4_rooms/make_room_textures.py [masks] [fabrics]
"""
from pathlib import Path
import colorsys
import sys

import numpy as np
from PIL import Image

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rooms_layout as L  # noqa: E402

ROOT = HERE.parents[2]
OUT = ROOT / "game/assets/textures/graphics_pilot/floor4_rooms"
GAME = ROOT / "game"
# How aged each room is (grime, stains, mould, peel): the students and how long the room has been left.
AGE = {"401": 0.75, "402": 1.0, "403": 0.9, "404": 0.95, "405": 1.45, "406": 1.05, "408": 1.15}


def smooth_noise(rng, shape, scale):
	h, w = shape
	white = rng.normal(0.0, 1.0, (h, w))
	fy = np.fft.fftfreq(h)[:, None]
	fx = np.fft.rfftfreq(w)[None, :]
	out = np.fft.irfft2(np.fft.rfft2(white) * np.exp(-((fy * scale) ** 2 + (fx * scale) ** 2) * 18.0), s=(h, w))
	return out / max(out.std(), 1e-9)


def blob(a, b, ca, cb, ra, rb):
	return np.exp(-(((a - ca) / ra) ** 2 + ((b - cb) / rb) ** 2))


def band_grid(rect, scale):
	x, y, w, h = rect
	b, a = np.mgrid[0:h, 0:w].astype(np.float32)
	return (a + 0.5) / scale, (b + 0.5) / scale  # metres along, metres up/down the band


def paint_walls(room, rng, age):
	rect = L.RECT_WALLS
	sc = L.scales(room)["walls"]
	p, h = band_grid(rect, sc)
	runs, _ = L.wall_runs(room)
	shape = p.shape
	fine, mid, big = smooth_noise(rng, shape, 3), smooth_noise(rng, shape, 18), smooth_noise(rng, shape, 90)
	grime = np.clip(1 - h / 0.07, 0, 1) ** 1.4 * 0.8 + np.clip(1 - h / 0.2, 0, 1) * 0.3 + np.clip(big * 0.08 + 0.07, 0, 0.2)
	stain = np.zeros(shape, np.float32)
	mould = np.zeros(shape, np.float32)

	def along(run, metres):
		p0, length = runs[run]
		return p0 + metres

	# Front wall: hand marks either side of the door (run "front" goes from the east end westwards).
	f0, flen = runs["front"]
	door_c = room.x1 - room.door_x
	for side in (-1, 1):
		grime += blob(p, h, f0 + door_c + side * 0.62, 1.1, 0.09, 0.3) * 0.35 * age
	# Side walls by the bunks (z -0.85..-2.85): heads and shoulders at the lower and upper bunk, feet marks.
	for run in ("east", "west"):
		p0, length = runs[run]
		# "east" runs from the bathroom/back end to the front; "west" from the front to the back.
		for z in (1.0, 1.85, 2.7):
			d = (L.WALL_ROOM - (-z)) if False else z - 0.1
			pos = p0 + (length - d if run == "east" else d)
			for hh in (0.65, 1.45):
				grime += blob(p, h, pos, hh, 0.35, 0.12) * 0.22 * age * (0.6 + 0.4 * rng.random())
	# Balcony and bathroom doors: hand marks on their latch side.
	b0, blen = runs["back"]
	grime += blob(p, h, b0 + (room.balcony_door[1] - room.x0) + 0.1, 1.05, 0.08, 0.28) * 0.3 * age
	bf0, bflen = runs["bathfront"]
	grime += blob(p, h, bf0 + bflen * 0.5, 1.05, 0.5, 0.35) * 0.18 * age
	# Damp round the bathroom: its partition and front wall, stains from the top, mould at the floor and ceiling.
	for run in ("bathside", "bathfront"):
		q0, qlen = runs[run]
		inside = (p >= q0) & (p <= q0 + qlen)
		mould += inside * (np.clip(1 - h / 0.25, 0, 1) * 0.45 + np.clip((h - 2.75) / 0.25, 0, 1) * 0.4) * age
		stain += inside * np.clip((h - 1.6) / 1.4, 0, 1) * np.clip(mid * 0.35 + 0.35, 0, 1) * 0.6 * age
	# Leaks from the ceiling here and there; mould in the back corners.
	for _ in range(int(2 + 3 * age)):
		cp = rng.uniform(0.3, p.max() - 0.3)
		width = rng.uniform(0.12, 0.35)
		length = rng.uniform(0.4, 1.4)
		body = np.exp(-((p - cp - np.sin(h * 6.0) * 0.03) / width) ** 2 * 2) * np.clip((h - (3.0 - length)) / 0.25, 0, 1)
		stain = np.maximum(stain, body * 0.6)
	for run in ("back", "east", "west"):
		q0, qlen = runs[run]
		for end in (q0, q0 + qlen):
			mould = np.maximum(mould, blob(p, h, end, 2.9, 0.35, 0.3) * 0.5 * age)
			mould = np.maximum(mould, blob(p, h, end, 0.1, 0.3, 0.2) * 0.4 * age)
	peel = np.clip((mid * 0.6 + big * 0.55 + fine * 0.2 - 1.5 + 0.25 * (age - 1)) * 0.9, 0, 1) * np.clip((h - 0.9) / 1.0, 0, 1)
	peel = np.maximum(peel, np.clip(stain - 0.45, 0, 1) * 1.2)
	return rect, np.stack([peel, np.clip(grime + fine * 0.02, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2)


def paint_bath(room, rng, age):
	rect = L.RECT_BATH
	p, h = band_grid(rect, L.scales(room)["bath"])
	shape = p.shape
	mid = smooth_noise(rng, shape, 14)
	grime = np.clip(1 - h / 0.1, 0, 1) * 0.6 + 0.08
	stain = np.clip((h - 1.8) / 1.2, 0, 1) * np.clip(mid * 0.3 + 0.4, 0, 1) * 0.5 * age
	mould = (np.clip((h - 2.6) / 0.4, 0, 1) * 0.7 + np.clip(1 - h / 0.15, 0, 1) * 0.5) * np.clip(0.5 + mid * 0.4, 0, 1) * age
	peel = np.clip((mid - 1.2) * 0.8, 0, 1) * np.clip((h - 1.8) / 0.4, 0, 1) * age
	return rect, np.stack([np.clip(peel, 0, 1), np.clip(grime, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2)


def paint_ext(room, rng, age):
	rect = L.RECT_EXT
	a, h = band_grid(rect, L.scales(room)["ext"])
	shape = a.shape
	mid, big = smooth_noise(rng, shape, 16), smooth_noise(rng, shape, 70)
	# Rain streaks from the soffit, dirt at the floor, mould by the bathroom window and the drain.
	cols = smooth_noise(rng, (8, shape[1]), 2.5)[3][None, :] + smooth_noise(rng, shape, 30) * 0.4
	streaks = np.clip(cols - 1.1, 0, 1) * np.clip((h - 0.8) / 2.0, 0, 1) * 0.8
	grime = np.clip(1 - h / 0.2, 0, 1) * 0.6 + streaks * age + np.clip(big * 0.1 + 0.1, 0, 0.25)
	stain = streaks * 0.6 * age
	mould = np.clip(1 - h / 0.3, 0, 1) * np.clip(mid * 0.4 + 0.3, 0, 1) * 0.5 * age
	peel = np.clip((mid * 0.6 + big * 0.6 - 1.4) * 0.8, 0, 1) * age
	return rect, np.stack([np.clip(peel, 0, 1), np.clip(grime, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2)


def paint_floor(room, rng, age):
	rect = L.RECT_FLOOR
	sc = L.scales(room)["floor"]
	a, b = band_grid(rect, sc)  # a: metres east of x0 (bathroom floor at a + SECOND_SURFACE_AT), b: back from the front
	shape = a.shape
	mid, big = smooth_noise(rng, shape, 16), smooth_noise(rng, shape, 80)
	width = room.x1 - room.x0
	depth = L.WALL_ROOM - L.BACK_IN
	edge = np.minimum(np.minimum(a, width - a), np.minimum(b, depth - b))
	grime = np.clip(1 - edge / 0.25, 0, 1) ** 1.5 * 0.75 + np.clip(big * 0.1 + 0.08, 0, 0.22)
	door = room.door_x - room.x0
	balcony = (room.balcony_door[0] + room.balcony_door[1]) / 2 - room.x0
	bath = (room.bath_door[0] + room.bath_door[1]) / 2 - room.x0
	wear = np.zeros(shape, np.float32)
	for t in np.linspace(0, 1, 40):
		# The path from the door down the middle, then to the balcony door and to the bathroom door.
		wear = np.maximum(wear, blob(a, b, door, t * 3.4, 0.45, 0.4) * 0.7)
		wear = np.maximum(wear, blob(a, b, door + (balcony - door) * t, 3.4 + (depth - 3.6) * t, 0.4, 0.4) * 0.55)
		wear = np.maximum(wear, blob(a, b, door + (bath - door) * t, 3.4 + 0.4 * t, 0.4, 0.35) * 0.5)
	grime += blob(a, b, door, 0.3, 0.6, 0.35) * 0.4 * age
	wet = blob(a, b, bath, -L.BATH_FRONT_ROOM + 0.2, 0.5, 0.3) * 0.5 + blob(a, b, balcony, depth - 0.2, 0.5, 0.25) * 0.35
	bathfloor = a > L.SECOND_SURFACE_AT - 0.05
	wet = np.where(bathfloor, np.clip(0.35 + mid * 0.25, 0, 1), wet)
	grime = np.where(bathfloor, np.clip(0.35 + big * 0.15, 0, 1), grime)
	grout = np.clip(0.45 + big * 0.15, 0, 1) * age
	return rect, np.stack([np.clip(grout, 0, 1), np.clip(grime * age, 0, 1), np.clip((wet - 0.1) * 1.3, 0, 1), np.clip(wear, 0, 1)], axis=2)


def paint_ceiling(room, rng, age):
	rect = L.RECT_CEILING
	sc = L.scales(room)["ceiling"]
	a, b = band_grid(rect, sc)  # a east of x0 (the balcony floor at a + SECOND_SURFACE_AT), b forward from the back
	shape = a.shape
	mid, big = smooth_noise(rng, shape, 14), smooth_noise(rng, shape, 70)
	width = room.x1 - room.x0
	cx = room.door_x - room.x0
	grime = np.clip(big * 0.08 + 0.08, 0, 0.2) + blob(a, b, cx, 3.2, 0.9, 0.5) * 0.35 * age
	bath_c = (room.bath[0] + room.bath[1]) / 2 - room.x0
	stain = blob(a, b, bath_c, 1.4, 1.0, 1.5) * np.clip(mid * 0.3 + 0.5, 0, 1) * 0.55 * age
	for _ in range(int(1 + 2 * age)):
		la, lb, r = rng.uniform(0.3, width - 0.3), rng.uniform(0.5, 6.4), rng.uniform(0.2, 0.5)
		d = np.hypot(a - la, b - lb)
		stain = np.maximum(stain, np.clip(1 - d / r, 0, 1) ** 0.5 * 0.5 + np.exp(-((d - r) / 0.04) ** 2) * 0.45)
	mould = np.clip(1 - b / 0.25, 0, 1) * 0.5 * age
	peel = np.clip(stain - 0.5, 0, 1) * 1.2
	balcony = a > L.SECOND_SURFACE_AT - 0.05
	grime = np.where(balcony, np.clip(0.3 + big * 0.15, 0, 1), grime)
	return rect, np.stack([np.clip(peel, 0, 1), np.clip(grime, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2)


def masks():
	atlas = np.zeros((L.ATLAS, L.ATLAS, 4), np.float32)
	for room in L.ROOMS:
		rng = np.random.default_rng(255_000 + int(room.number))
		age = AGE[room.number]
		rx, ry = L.region_origin(room)
		for painter in (paint_walls, paint_bath, paint_ext, paint_floor, paint_ceiling):
			rect, img = painter(room, rng, age)
			x, y, w, h = rect
			atlas[ry + y:ry + y + h, rx + x:rx + x + w] = img
	atlas[:16, -16:] = 0.0  # faces without their own UV2 sample here
	OUT.mkdir(parents=True, exist_ok=True)
	Image.fromarray((np.clip(atlas, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA").save(OUT / "mask_rooms.png", optimize=True)


# Fabrics: room 407's own textures, hue-turned and toned for each room's students.
FABRICS = {
	"blanket_messy": "assets/models/graphics_pilot/room407_batch2/blanket_messy_blanket_messy_basecolor.jpg",
	"blanket_folded": "assets/models/graphics_pilot/room407_batch2/blanket_folded_blanket_folded_basecolor.png",
	"pillow": "assets/models/graphics_pilot/room407_batch2/pillow_pillow_basecolor.png",
	"shirt": "assets/models/graphics_pilot/room407_batch2/shirt_hanging_shirt_hanging_basecolor.png",
	"curtain": "assets/models/graphics_pilot/room407_furnished/curtain_balcony_curtain_green.jpg",
}
COLOURS = {  # name: (hue in turns, saturation factor, value factor): washed, faded student cloth like room 407's
	"blue": (0.6, 0.55, 0.78), "grey": (0.0, 0.08, 0.8), "green": (0.33, 0.42, 0.7), "brown": (0.07, 0.45, 0.62),
	"pink": (0.94, 0.38, 0.88), "navy": (0.64, 0.5, 0.52), "mustard": (0.12, 0.55, 0.82), "maroon": (0.98, 0.5, 0.55),
}


def recolour(src, hue, sat, val):
	rgb = np.asarray(Image.open(src).convert("RGB")).astype(np.float32) / 255.0
	r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
	mx, mn = rgb.max(axis=2), rgb.min(axis=2)
	v = mx
	s = np.where(mx > 1e-5, (mx - mn) / np.maximum(mx, 1e-5), 0)
	# Keep the weave's light and dark (value), give it the new hue and a saturation like the old one.
	s2 = np.clip(np.maximum(s, 0.45) * sat, 0, 1)
	v2 = np.clip(v * val, 0, 1)
	h2 = np.full_like(v2, hue)
	i = np.floor(h2 * 6).astype(int) % 6
	f = h2 * 6 - np.floor(h2 * 6)
	p = v2 * (1 - s2)
	q = v2 * (1 - f * s2)
	t = v2 * (1 - (1 - f) * s2)
	out = np.zeros_like(rgb)
	for k, (cr, cg, cb) in enumerate(((v2, t, p), (q, v2, p), (p, v2, t), (p, q, v2), (t, p, v2), (v2, p, q))):
		m = i == k
		out[..., 0][m], out[..., 1][m], out[..., 2][m] = cr[m], cg[m], cb[m]
	return out


def fabrics():
	OUT.mkdir(parents=True, exist_ok=True)
	for name, rel in FABRICS.items():
		src = GAME / rel
		for colour, (hue, sat, val) in COLOURS.items():
			img = recolour(src, hue, sat, val)
			Image.fromarray((img * 255 + 0.5).astype(np.uint8), "RGB").resize(
				(min(1024, Image.open(src).width), min(1024, Image.open(src).height))).save(OUT / f"{name}_{colour}.jpg", quality=90)


if __name__ == "__main__":
	jobs = {"masks": masks, "fabrics": fabrics}
	for job in sys.argv[1:] or list(jobs):
		jobs[job]()
		print("T255_TEX", job)
