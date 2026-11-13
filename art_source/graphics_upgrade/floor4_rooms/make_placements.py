"""T-255 (D-168): what stands in rooms 401-406 and 408, as room 407's placements.json (its Tripo and Blender props,
nothing new), each room a different group of students (Handoff, proposal 4):
  401 tidy, they study      402 messy, food and a laptop    403 football         404 music
  405 half empty: two have moved out (boxes, suitcases)      406 they cook         408 six students, washing everywhere
Writes game/data/floor4_rooms/rooms.json: per room its layout (rooms_layout.py: walls, bathroom, doors) and its rows
  name, model, position (Floor4 metres), yaw (degrees; the model's front is its -Z, its back +Z), optional rot_x,
  mount "wall" (the position is a point on the wall, floor4_rooms.gd pushes the model's back onto it), fabric (a
  colour of make_room_textures.py: the model's cloth takes <kind>_<colour>.jpg), scale, solid (a box inside the
  model's bounds on the world layer), outdoor (on the balcony: drawn with the facade, not the interior).
Rooms 401-406 are laid out in s (metres across the room from the side wall away from the bathroom) and z, then
placed by Room.s_to_x; the bath-west rooms are mirror images (a model's front keeps facing the same wall).
The zombies' box in front of each door (rooms_layout.SPAWN_CLEAR) stays free of anything solid (checked here).
Run: python -B art_source/graphics_upgrade/floor4_rooms/make_placements.py
"""
from pathlib import Path
import json
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rooms_layout as L  # noqa: E402

ROOT = HERE.parents[2]
OUT = ROOT / "game/data/floor4_rooms/rooms.json"
GP = "res://assets/models/graphics_pilot/"
B1, B2, B3, FU = GP + "room407_batch1/", GP + "room407_batch2/", GP + "room407_batch3/", GP + "room407_furnished/"
BACKPACK = GP + "room407_backpack_tripo_r2.glb"
DESK_TOP = 0.76
BUNK_Z = -2.5  # bunks from z -1.5 to -3.5, their heads (pillows) towards the door
LOWER, UPPER = 0.38, 1.15  # mattress heights (room 407)
LINE_Y = 2.6  # the room's clothesline (build_rooms.py CLOTHESLINE_Z); a hanging shirt's top is 0.78 above its foot
SHIRT_DROP = 0.78
BALCONY_LINE = (-7.85, 2.17)
# Half a locker's depth off its wall (+5 mm); the open locker stands where room 407's does (its door swings out).
LOCKER_HALF_DEPTH = {"closed": 0.306, "open": 0.3, "viet": 0.338}


class Plan:
	"""Rows of one room. add() takes s (across the room) or x (Floor4 metres, as given) and a yaw for a bath-east
	room; turn "front" keeps the model's front on the same wall when mirrored, "side" its +X (a bunk's open side)."""

	def __init__(self, room):
		self.room = room
		self.rows = []
		self.names = set()

	def add(self, name, model, s=None, y=0.0, z=0.0, yaw=0.0, x=None, turn="front", **extra):
		assert name not in self.names, name
		self.names.add(name)
		r = self.room
		if x is None:
			x = r.s_to_x(s)
			if r.bath_side == "west":
				yaw = -yaw if turn == "front" else 180.0 - yaw
		yaw = (yaw + 180.0) % 360.0 - 180.0
		row = {"name": name, "model": model, "position": [round(x, 4), round(y, 4), round(z, 4)], "yaw": round(yaw, 2)}
		row.update(extra)
		self.rows.append(row)
		return row

	def s_of(self, x):
		return x - self.room.x0 if self.room.bath_side == "east" else self.room.x1 - x


# ---------------------------------------------------------------- the parts every room has

def _jitter(key, size):
	"""A small fixed turn (degrees) for a name: things not quite square."""
	return round((sum(ord(c) * (k + 1) for k, c in enumerate(key)) % 101) / 100.0 * 2.0 * size - size, 1)


def bunk(p, tag, s, z, yaw, lower, upper, nets=("lower_closed", "upper_closed")):
	"""A bunk, its two mattresses, pillows, blankets and nets. lower / upper: (blanket kind, colour) or None (a bare
	mattress) or "none" (no mattress)."""
	p.add("Bunk" + tag, B2 + "bunk_frame.glb", s, 0.0, z, yaw, turn="side", solid=True)
	for level, y, spec, net in (("Lower", LOWER, lower, nets[0]), ("Upper", UPPER, upper, nets[1])):
		if spec == "none":
			continue
		p.add("Mattress" + tag + level, FU + "bunk_mattress.glb", s, y, z, 0.0)
		if spec is None:
			continue
		kind, colour = spec
		p.add("Pillow" + tag + level, B2 + "pillow.glb", s, y + 0.05, z + 0.67, _jitter(tag + level, 5.0), fabric=colour)
		if kind == "messy":
			p.add("Blanket" + tag + level, B2 + "blanket_messy.glb", s, y + 0.05, z - 0.25, 0.0 if level == "Lower" else 180.0, fabric=colour)
		else:
			p.add("Blanket" + tag + level, B2 + "blanket_folded.glb", s, y + 0.05, z - 0.68, _jitter(tag + level + "b", 4.0), fabric=colour)
		if net:
			p.add("Net" + tag + level, FU + "mosquito_net_%s.glb" % net if level == "Lower" else FU + "mosquito_net_upper_closed.glb",
				s, 0.0, z, yaw, turn="side")


def lockers(p, kinds, fronts=(-0.45, -1.13)):
	"""Four lockers on the side walls by the door (room 407's), kinds: four of closed / open / viet / None."""
	spots = [(0.0, fronts[0], -90.0), (0.0, fronts[1], -90.0), (3.8, fronts[0], 90.0), (3.8, fronts[1], 90.0)]
	for k, ((wall, z, yaw), kind) in enumerate(zip(spots, kinds)):
		if kind is None:
			continue
		half = LOCKER_HALF_DEPTH[kind]
		s = wall + half if wall == 0.0 else wall - half
		model = {"closed": B2 + "locker_closed.glb", "open": B2 + "locker_open.glb", "viet": FU + "locker_viet.glb"}[kind]
		p.add("Locker%d" % k, model, s, 0.0, z, yaw, solid=True)


def desk(p, tag, z, items):
	"""A desk against the wall away from the bathroom (s 0.36, along z), a stool half under it (the way to the
	balcony door stays a metre wide), what is on it: (model, dz, ds, yaw)."""
	p.add("Desk" + tag, B2 + "desk.glb", 0.36, 0.0, z, -90.0, solid=True)
	p.add("Stool" + tag, B1 + "stool.glb", 0.6, 0.0, z + 0.25, 0.0, solid=True)  # tucked half under the desk
	for k, (model, dz, ds, yaw) in enumerate(items):
		p.add("Desk%sItem%d" % (tag, k), model, 0.36 + ds, DESK_TOP, z + dz, yaw)


def bathroom(p, extra=()):
	"""Room 407's bathroom, set out in this one: toilet in the back corner under the window, the shower head on the
	back wall, the sink, mirror and towel rack on the side walls clear of the door's swing (it opens along the
	partition), the bucket, basins and bottles on the floor."""
	r = p.room
	w = r.bath[1] - r.bath[0]
	b0 = 1.9 + 0.1 if r.number != "408" else None
	s_far = 3.8 if r.number != "408" else None
	if r.number == "408":
		b0, s_far = p.s_of(r.bath[1]), p.s_of(r.bath[0])  # 408: bath west, s grows westwards
	z_back = L.BACK_IN
	p.add("Toilet", B2 + "toilet.glb", s_far - 0.27, 0.0, z_back + 0.375, 180.0, solid=True)
	p.add("ToiletBrush", B3 + "toilet_brush.glb", s_far - 0.62, 0.0, z_back + 0.17, 0.0)
	p.add("ToiletPaper", B3 + "toilet_paper.glb", s_far, 0.75, z_back + 0.85, 90.0, mount="wall")
	p.add("Shower", B2 + "shower.glb", b0 + 0.6, 0.8, z_back + 0.235, 180.0)
	p.add("ShowerBottles", B3 + "shower_bottles.glb", b0 + 0.95, 0.0, z_back + 0.08, 0.0)
	p.add("BathShelf", B3 + "bath_shelf.glb", b0 + 0.21, 0.0, z_back + 0.1, 0.0, solid=True)
	p.add("BathBucket", B1 + "bucket.glb", b0 + 0.35, 0.015, z_back + 0.65, 0.0)
	p.add("BathBasins", B3 + "bath_basins.glb", b0 + 0.85, 0.0, z_back + 0.75, 0.0)
	p.add("Sink", B2 + "sink.glb", s_far - 0.178, 0.36, -4.75, 90.0)
	p.add("MirrorSmall", B3 + "mirror_small.glb", s_far, 1.12, -4.75, 90.0, mount="wall")
	p.add("ToothbrushCup", B3 + "toothbrush_cup.glb", s_far - 0.06, 0.77, -4.6, 90.0)
	p.add("SinkToiletries", B3 + "sink_toiletries.glb", s_far - 0.06, 0.77, -4.92, 90.0)
	p.add("TowelRack", FU + "towel_rack_bare.glb", b0, 1.15, -5.75, -90.0, mount="wall")
	p.add("RackRag", FU + "rack_rag.glb", b0 + 0.059, 1.15, -5.75, -90.0)
	p.add("Mop", B3 + "mop.glb", s_far - 0.22, 0.0, -5.55, 0.0)
	p.add("LaundryDetergent", B3 + "laundry_detergent.glb", b0 + 0.15, 0.0, -5.45, -90.0)
	for k, (model, ds, dz, yaw) in enumerate(extra):
		p.add("BathExtra%d" % k, model, b0 + ds, 0.0, dz, yaw)


def balcony(p, colour, items=(), shirts=(), towels=()):
	"""The balcony: the curtain inside its door (room 407's, narrowed to the door), the washing on its line, what
	stands on its floor; shirts / towels: s along the line."""
	r = p.room
	c = (r.balcony_door[0] + r.balcony_door[1]) / 2
	# curtain_balcony.glb hangs in room 407's coordinates centred on x 2.7: scaled to 0.7 about the door's middle.
	p.add("CurtainBalcony", FU + "curtain_balcony.glb", x=c - 2.7 * 0.7, y=0.0, z=0.0, yaw=0.0, scale=[0.7, 1.0, 1.0], fabric=colour)
	for k, (s, colour_k) in enumerate(shirts):
		p.add("BalconyShirt%d" % k, B2 + "shirt_hanging.glb", s, BALCONY_LINE[1] - SHIRT_DROP, BALCONY_LINE[0], 0.0,
			fabric=colour_k, outdoor=True)
	for k, s in enumerate(towels):
		p.add("BalconyTowel%d" % k, B3 + "towel_draped.glb", s, BALCONY_LINE[1] - 0.73, BALCONY_LINE[0], 0.0, outdoor=True)
	for k, (model, s, z, yaw) in enumerate(items):
		p.add("Balcony%d" % k, model, s, -0.02, z, yaw, outdoor=True, solid=model.endswith(("drying_rack.glb", "storage_box.glb")))


def room_line(p, shirts):
	"""Shirts on the room's line in front of the bathroom: (s, colour) near the side walls, clear of the bathroom
	door and the way to the balcony."""
	for k, (s, colour) in enumerate(shirts):
		p.add("Shirt%d" % k, B2 + "shirt_hanging.glb", s, LINE_Y - SHIRT_DROP, -3.72, _jitter("shirt%d" % k, 8.0), fabric=colour)


def common_walls(p, socket_s=(1.1, 3.0)):
	"""Sockets low on the front wall either side of the door's box, one by the desks."""
	for k, s in enumerate(socket_s):
		p.add("SocketFront%d" % k, B3 + "wall_socket.glb", s, 0.3, L.WALL_ROOM, 0.0, mount="wall")
	p.add("SocketDesk", B3 + "wall_socket.glb", 0.0, 0.3, -4.9, -90.0, mount="wall")
	p.add("CeilingFan", FU + "ceiling_fan_split.glb", 1.9, L.CEILING, -2.2, 0.0)


def slippers(p, spots):
	for k, (s, z, yaw) in enumerate(spots):
		p.add("Slippers%d" % k, B1 + "slippers.glb", s, 0.005, z, yaw)


# ---------------------------------------------------------------- the rooms

def room_401():
	"""Tidy, they study: both desks, books, lamps, a timetable; blankets folded."""
	p = Plan(L.ROOM["401"])
	bunk(p, "A", 0.5, BUNK_Z, 0.0, ("folded", "blue"), ("folded", "navy"))
	bunk(p, "B", 3.3, BUNK_Z, 180.0, ("folded", "grey"), ("messy", "blue"), nets=("lower_open", "upper_closed"))
	lockers(p, ("closed", "closed", "closed", "viet"))
	desk(p, "Study", -4.27, [(B2 + "desk_lamp.glb", 0.4, -0.1, -90.0), (B2 + "notebook.glb", 0.0, 0.0, -100.0),
		(B2 + "books.glb", -0.45, -0.05, -80.0), (B3 + "pen_cup.glb", 0.2, -0.15, 0.0), (B2 + "power_strip.glb", 0.55, -0.2, 0.0)])
	desk(p, "Window", -5.77, [(B2 + "laptop.glb", 0.1, 0.0, -90.0), (B2 + "desk_lamp.glb", -0.5, -0.1, -90.0),
		(B2 + "books_row.glb", 0.55, -0.15, -90.0), (B3 + "pen_cup.glb", -0.25, -0.15, 30.0)])
	p.add("Bookshelf", B2 + "bookshelf.glb", 1.715, 0.0, -4.55, 90.0, solid=True)
	p.add("BookshelfTop", B2 + "books_row.glb", 1.73, 1.3, -4.4, 90.0)
	p.add("BookshelfTop2", B2 + "books_row.glb", 1.73, 1.3, -4.8, 90.0)
	p.add("Timetable", FU + "timetable.glb", 0.0, 1.45, -4.5, -90.0, mount="wall")
	p.add("Calendar", FU + "calendar.glb", 0.0, 1.4, -6.0, -90.0, mount="wall")
	p.add("ShelfA", B2 + "wall_shelf.glb", 0.0, 1.648, -1.95, -90.0, mount="wall")
	p.add("ShelfABooks", B2 + "books_row.glb", 0.16, 1.92, -1.8, -90.0)
	p.add("ShelfB", B2 + "wall_shelf.glb", 3.8, 1.648, -1.95, 90.0, mount="wall")
	p.add("ShelfBBooks", B2 + "books.glb", 3.64, 1.92, -2.0, 10.0)
	p.add("TrashBin", B2 + "trash_bin.glb", 1.4, 0.0, -6.6, 0.0)
	p.add("Backpack", BACKPACK, 1.1, 0.02, -4.6, 90.0)
	room_line(p, [(0.3, "blue"), (0.85, "grey"), (3.5, "navy")])
	slippers(p, [(1.1, -0.2, 180.0), (2.9, -0.25, 170.0), (0.7, -3.75, 90.0)])
	common_walls(p)
	bathroom(p)
	balcony(p, "blue", items=[(B3 + "basin_clothes.glb", 2.9, -7.6, 0.0), (B1 + "bucket.glb", 3.4, -7.5, 0.0)],
		shirts=[(0.6, "navy"), (1.2, "blue")], towels=[2.0, 2.6])
	return p


def room_402():
	"""Messy, food and a laptop: noodles, takeaway boxes, cans, a pot on a mat, clothes on the floor."""
	p = Plan(L.ROOM["402"])
	bunk(p, "A", 0.5, BUNK_Z, 0.0, ("messy", "maroon"), ("messy", "mustard"), nets=("lower_open", "upper_closed"))
	bunk(p, "B", 3.3, BUNK_Z, 180.0, ("messy", "brown"), ("folded", "maroon"), nets=(None, None))
	lockers(p, ("open", "closed", "closed", "closed"))
	desk(p, "Laptop", -4.27, [(B2 + "laptop.glb", 0.15, 0.0, -80.0), (B2 + "noodles.glb", -0.4, -0.1, 20.0),
		(B3 + "takeaway_box.glb", 0.55, -0.1, 10.0), (B2 + "kettle.glb", -0.6, -0.15, -30.0), (B2 + "headphones.glb", 0.0, -0.2, 40.0)])
	p.add("Fridge", B1 + "fridge.glb", 0.3, 0.0, -5.4, -90.0, solid=True)
	p.add("RiceCooker", B1 + "rice_cooker.glb", 0.3, 0.84, -5.4, -90.0)
	p.add("WaterDispenser", B3 + "water_dispenser.glb", 0.22, 0.0, -6.05, -90.0, solid=True)
	p.add("TrashBag", B3 + "trash_bag.glb", 1.55, 0.0, -6.55, 20.0)
	p.add("TrashBag2", B3 + "trash_bag.glb", 1.6, 0.0, -6.05, -40.0)
	p.add("BottlesCans", B3 + "bottles_cans.glb", 1.4, 0.0, -5.1, 40.0)
	p.add("FloorMat", FU + "floor_mat.glb", 1.9, 0.0, -2.95, 90.0)
	p.add("FoldingTable", B3 + "folding_table.glb", 1.6, 0.008, -2.95, 90.0, solid=True)
	p.add("MealTray", B3 + "meal_tray.glb", 1.6, 0.308, -2.95, 20.0)
	p.add("Pot", B3 + "pot.glb", 2.3, 0.008, -3.3, 0.0)
	p.add("TakeawayFloor", B3 + "takeaway_box.glb", 1.5, 0.0, -3.25, -30.0)
	p.add("ClothesPile", B3 + "clothes_pile.glb", 2.55, 0.0, -0.4, 30.0)
	p.add("ClothesPileBunk", B3 + "clothes_pile.glb", 3.3, LOWER + 0.05, -2.2, -20.0)
	p.add("ShelfA", B2 + "wall_shelf.glb", 0.0, 1.648, -1.95, -90.0, mount="wall")
	p.add("ShelfANoodles", B2 + "noodles.glb", 0.16, 1.92, -2.15, -90.0)
	p.add("ShelfANoodles2", B2 + "noodles.glb", 0.16, 1.92, -1.8, -70.0)
	p.add("TrashBin", B2 + "trash_bin.glb", 1.05, 0.0, -3.7, 0.0)
	p.add("Backpack", BACKPACK, 3.0, 0.02, -3.8, 200.0)
	room_line(p, [(0.3, "maroon"), (0.8, "mustard"), (1.3, "brown"), (3.5, "grey")])
	slippers(p, [(1.3, -0.3, 200.0), (2.4, -1.4, 120.0), (3.0, -0.2, 160.0), (1.7, -3.6, 70.0)])
	common_walls(p)
	bathroom(p, extra=[(B3 + "clothes_pile.glb", 0.9, -5.0, 10.0)])
	balcony(p, "brown", items=[(B3 + "drying_rack.glb", 2.5, -7.75, 0.0), (B3 + "trash_bag.glb", 0.4, -7.4, 0.0)],
		shirts=[(0.5, "maroon"), (1.0, "mustard")], towels=[])
	return p


def room_403():
	"""Football: the balls, trainers, a helmet on the shoe rack, the poster, kit drying on the line."""
	p = Plan(L.ROOM["403"])
	bunk(p, "A", 0.5, BUNK_Z, 0.0, ("messy", "green"), ("folded", "green"))
	bunk(p, "B", 3.3, BUNK_Z, 180.0, ("messy", "grey"), ("messy", "navy"))
	lockers(p, ("closed", "open", "closed", "closed"))
	desk(p, "Study", -4.27, [(B2 + "laptop.glb", 0.0, 0.0, -100.0), (B2 + "photo_frame.glb", 0.45, -0.15, -80.0),
		(B2 + "books.glb", -0.5, -0.05, -95.0), (B3 + "pen_cup.glb", 0.3, -0.18, 0.0)])
	desk(p, "Kit", -5.77, [(B3 + "helmet.glb", 0.3, -0.05, 160.0), (B2 + "books_row.glb", -0.45, -0.12, -90.0)])
	p.add("Football", B3 + "football.glb", 1.4, 0.0, -3.8, 0.0)
	p.add("FootballDesk", B3 + "football.glb", 1.2, 0.0, -6.5, 0.0)
	p.add("Trainers", B1 + "trainers.glb", 1.5, 0.015, -5.3, 15.0)
	p.add("Trainers2", B1 + "trainers.glb", 0.85, 0.015, -0.3, -160.0)
	p.add("ShoeRack", B2 + "shoe_rack.glb", 1.6, 0.0, -6.0, 90.0, solid=True)
	p.add("HelmetRack", B3 + "helmet.glb", 1.6, 0.5, -5.85, 70.0)
	# room 407's football poster (its glb sits on 407's west wall, x 0.1): on this room's wall above bunk A
	p.add("FootballPoster", FU + "poster_football.glb", x=p.room.x0 - 0.1, y=0.0, z=0.0, yaw=0.0)
	p.add("TowelBunkA", B3 + "towel_draped.glb", 0.5, UPPER - 0.065, -3.5, 0.0)
	p.add("TowelBunkB", B3 + "towel_draped.glb", 3.3, LOWER - 0.165, -3.5, 180.0)
	p.add("ShelfB", B2 + "wall_shelf.glb", 3.8, 1.648, -1.95, 90.0, mount="wall")
	p.add("TeamPhoto", B2 + "photo_frame.glb", 3.66, 1.92, -1.8, 90.0)
	p.add("TrashBin", B2 + "trash_bin.glb", 1.5, 0.0, -4.4, 0.0)
	p.add("Backpack", BACKPACK, 0.95, 0.02, -6.4, 60.0)
	room_line(p, [(0.3, "green"), (0.85, "green"), (3.5, "grey")])
	slippers(p, [(1.0, -0.2, 180.0), (2.8, -0.22, 190.0), (3.0, -3.65, 80.0)])
	common_walls(p)
	bathroom(p)
	balcony(p, "green", items=[(B3 + "basin_clothes.glb", 0.5, -7.6, 0.0), (B1 + "trainers.glb", 3.3, -7.3, 40.0)],
		shirts=[(0.9, "green"), (1.4, "green"), (1.9, "grey"), (2.4, "navy")], towels=[3.2])
	return p


def room_404():
	"""Music: guitars against the walls, headphones, a laptop, posters of nothing in particular (the timetable)."""
	p = Plan(L.ROOM["404"])
	bunk(p, "A", 0.5, BUNK_Z, 0.0, ("messy", "navy"), ("messy", "pink"), nets=("lower_closed", None))
	bunk(p, "B", 3.3, BUNK_Z, 180.0, ("folded", "grey"), ("folded", "navy"))
	lockers(p, ("closed", "closed", "viet", "closed"))
	desk(p, "Music", -4.27, [(B2 + "laptop.glb", 0.1, 0.0, -90.0), (B2 + "headphones.glb", -0.3, -0.1, -60.0),
		(B2 + "router.glb", 0.6, -0.2, -90.0), (B2 + "desk_lamp.glb", -0.55, -0.15, -90.0)])
	desk(p, "Window", -5.77, [(B2 + "books.glb", 0.2, -0.05, -85.0), (B2 + "notebook.glb", -0.2, 0.0, -110.0),
		(B2 + "headphones.glb", 0.5, -0.15, 30.0)])
	p.add("Guitar", B2 + "guitar.glb", 1.75, 0.0, -4.1, 90.0, rot_x=12.0)
	p.add("Guitar2", B2 + "guitar.glb", 3.55, 0.0, -3.75, 180.0, rot_x=10.0)
	p.add("GuitarBunk", B2 + "guitar.glb", 0.5, UPPER + 0.06, -3.0, 0.0, rot_x=-80.0)
	p.add("ShelfA", B2 + "wall_shelf.glb", 0.0, 1.648, -1.95, -90.0, mount="wall")
	p.add("ShelfAHeadphones", B2 + "headphones.glb", 0.15, 1.92, -1.85, -90.0)
	p.add("ShelfABooks", B2 + "books_row.glb", 0.16, 1.92, -2.15, -90.0)
	p.add("Timetable", FU + "timetable.glb", 0.0, 1.5, -4.6, -90.0, mount="wall")
	p.add("TrashBin", B2 + "trash_bin.glb", 1.55, 0.0, -5.6, 0.0)
	p.add("Backpack", BACKPACK, 1.0, 0.02, -3.95, 100.0)
	room_line(p, [(0.3, "navy"), (3.55, "pink")])
	slippers(p, [(1.2, -0.2, 180.0), (2.7, -0.3, 200.0)])
	common_walls(p)
	bathroom(p)
	balcony(p, "maroon", items=[(B1 + "bucket.glb", 3.4, -7.4, 0.0)], shirts=[(0.7, "pink"), (1.3, "navy")], towels=[2.3])
	return p


def room_405():
	"""Half empty: two of them have moved out. Bunk B stripped, boxes, suitcases, empty lockers standing open."""
	p = Plan(L.ROOM["405"])
	bunk(p, "A", 0.5, BUNK_Z, 0.0, ("folded", "grey"), ("messy", "grey"), nets=("lower_closed", None))
	bunk(p, "B", 3.3, BUNK_Z, 180.0, None, "none", nets=(None, None))
	lockers(p, ("closed", "open", "open", "open"))
	desk(p, "Left", -4.27, [(B2 + "books.glb", 0.0, -0.05, -90.0), (B2 + "desk_lamp.glb", 0.45, -0.12, -90.0)])
	p.add("Suitcase", B3 + "suitcase.glb", 3.3, LOWER + 0.05, -2.3, 8.0)
	p.add("Suitcase2", B3 + "suitcase.glb", 0.36, 0.0, -6.55, 0.0, solid=True)
	p.add("Boxes", B3 + "cardboard_boxes.glb", 3.3, LOWER + 0.05, -3.05, 85.0)
	p.add("Boxes2", B3 + "cardboard_boxes.glb", 0.3, 0.0, -5.4, -90.0, solid=True)
	p.add("Boxes3", B3 + "cardboard_boxes.glb", 0.3, 0.45, -5.4, -84.0)
	p.add("Boxes4", B3 + "cardboard_boxes.glb", 0.3, 0.0, -5.9, -90.0, solid=True)
	p.add("TrashBag", B3 + "trash_bag.glb", 1.65, 0.0, -4.3, 0.0)
	p.add("TrashBag2", B3 + "trash_bag.glb", 0.3, 0.0, -6.0, 30.0)
	p.add("Calendar", FU + "calendar.glb", 0.0, 1.4, -6.3, -90.0, mount="wall")
	p.add("Backpack", BACKPACK, 0.9, 0.02, -3.85, 30.0)
	room_line(p, [(0.35, "grey")])
	slippers(p, [(1.0, -0.2, 180.0)])
	common_walls(p, socket_s=(1.1,))
	bathroom(p)
	balcony(p, "grey", items=[(B3 + "storage_box.glb", 0.5, -7.5, 90.0)], shirts=[(1.1, "grey")], towels=[])
	return p


def room_406():
	"""They cook: rice cooker, pot and kettle by the fridge, the meal tray on its mat, a water dispenser."""
	p = Plan(L.ROOM["406"])
	bunk(p, "A", 0.5, BUNK_Z, 0.0, ("messy", "brown"), ("folded", "mustard"))
	bunk(p, "B", 3.3, BUNK_Z, 180.0, ("folded", "mustard"), ("messy", "brown"), nets=("lower_open", "upper_closed"))
	lockers(p, ("closed", "closed", "open", "closed"))
	desk(p, "Kitchen", -4.27, [(B1 + "rice_cooker.glb", 0.4, -0.05, -90.0), (B2 + "kettle.glb", -0.1, -0.1, -30.0),
		(B3 + "pot.glb", -0.5, -0.05, 0.0), (B2 + "noodles.glb", 0.05, -0.25, 10.0)])
	p.add("Fridge", B1 + "fridge.glb", 0.3, 0.0, -5.35, -90.0, solid=True)
	p.add("WaterDispenser", B3 + "water_dispenser.glb", 0.22, 0.0, -6.0, -90.0, solid=True)
	p.add("BottlesCans", B3 + "bottles_cans.glb", 0.4, 0.0, -6.6, 10.0)
	p.add("FloorMat", FU + "floor_mat.glb", 1.9, 0.0, -2.95, 90.0)
	p.add("FoldingTable", B3 + "folding_table.glb", 1.6, 0.008, -2.95, 90.0, solid=True)
	p.add("MealTray", B3 + "meal_tray.glb", 1.55, 0.308, -2.95, -10.0)
	p.add("BasinMat", B3 + "basin_clothes.glb", 1.4, 0.0, -3.25, 0.0)
	p.add("Bookshelf", B2 + "bookshelf.glb", 1.715, 0.0, -4.55, 90.0, solid=True)
	p.add("BookshelfNoodles", B2 + "noodles.glb", 1.73, 1.3, -4.35, 90.0)
	p.add("BookshelfCooker", B3 + "takeaway_box.glb", 1.73, 1.3, -4.75, 80.0)
	p.add("ShelfB", B2 + "wall_shelf.glb", 3.8, 1.648, -1.95, 90.0, mount="wall")
	p.add("ShelfBNoodles", B2 + "noodles.glb", 3.64, 1.92, -2.0, 90.0)
	p.add("TrashBin", B2 + "trash_bin.glb", 1.4, 0.0, -6.6, 0.0)
	p.add("Backpack", BACKPACK, 1.05, 0.02, -4.7, 120.0)
	room_line(p, [(0.3, "brown"), (0.85, "mustard"), (3.5, "brown")])
	slippers(p, [(1.0, -0.2, 180.0), (2.9, -0.2, 175.0), (1.6, -3.7, 60.0)])
	common_walls(p)
	bathroom(p)
	balcony(p, "mustard", items=[(B3 + "basin_clothes.glb", 2.9, -7.6, 0.0), (B3 + "bottles_cans.glb", 0.4, -7.35, 0.0)],
		shirts=[(0.7, "brown"), (1.3, "mustard")], towels=[2.1])
	return p


def room_408():
	"""Six of them, washing everywhere: three bunks, six lockers, two drying racks, clothes on every line."""
	r = L.ROOM["408"]
	p = Plan(r)
	# s from the east wall (x 43.84) westwards. Bunks: two along the east wall behind the zombies' box (its east edge
	# x 42.95 is within a bunk's width of the wall), one on the west wall at the front (x 38.55). Lockers: the east
	# and west walls by the door, two on the front wall west of the door's box. The fridge in the east corner.
	bunk(p, "A", 0.452, -3.63, 0.0, ("messy", "pink"), ("folded", "blue"))
	bunk(p, "B", 0.452, -5.75, 0.0, ("folded", "green"), ("messy", "navy"), nets=("lower_open", "upper_closed"))
	bunk(p, "C", p.s_of(38.55), BUNK_Z, 180.0, ("messy", "grey"), ("messy", "maroon"))
	for k, (s, z, yaw, kind) in enumerate([(0.306, -0.45, -90.0, "closed"), (0.3, -1.13, -90.0, "open"),
			(p.s_of(38.406), -0.45, 90.0, "closed"), (p.s_of(38.438), -1.13, 90.0, "viet"),
			(p.s_of(39.75), -0.42, 0.0, "closed"), (p.s_of(40.45), -0.42, 0.0, "closed")]):
		model = {"closed": B2 + "locker_closed.glb", "open": B2 + "locker_open.glb", "viet": FU + "locker_viet.glb"}[kind]
		p.add("Locker%d" % k, model, s, 0.0, z, yaw, solid=True)
	# Desks against the bathroom's partition (x 40.74, from its corner z -3.925 back), facing east.
	for tag, z, items in (("A", -4.68, [(B2 + "laptop.glb", 0.0, 0.0, 90.0), (B2 + "kettle.glb", 0.5, 0.15, 30.0)]),
			("B", -6.175, [(B2 + "books.glb", 0.1, 0.05, 80.0), (B2 + "desk_lamp.glb", -0.5, 0.1, 90.0)])):
		p.add("Desk" + tag, B2 + "desk.glb", x=40.74 + 0.36, y=0.0, z=z, yaw=-90.0, solid=True)
		p.add("Stool" + tag, B1 + "stool.glb", x=40.74 + 0.6, y=0.0, z=z + 0.25, yaw=0.0, solid=True)
		for k, (model, dz, dx, yaw) in enumerate(items):
			p.add("Desk%sItem%d" % (tag, k), model, x=40.74 + 0.36 + dx, y=DESK_TOP, z=z + dz, yaw=yaw)
	p.add("DryingRack", B3 + "drying_rack.glb", x=40.1, y=0.0, z=-1.9, yaw=90.0, solid=True)
	p.add("ClothesPile", B3 + "clothes_pile.glb", x=38.6, y=0.0, z=-3.75, yaw=20.0)
	p.add("ClothesPile2", B3 + "clothes_pile.glb", x=43.35, y=LOWER + 0.05, z=-6.1, yaw=-30.0)
	p.add("Fridge", B1 + "fridge.glb", x=43.56, y=0.0, z=-2.0, yaw=90.0, solid=True)
	p.add("RiceCooker", B1 + "rice_cooker.glb", x=43.56, y=0.84, z=-2.0, yaw=90.0)
	p.add("TrashBin", B2 + "trash_bin.glb", x=42.7, y=0.0, z=-2.85, yaw=0.0)
	p.add("Backpack", BACKPACK, x=42.7, y=0.02, z=-4.75, yaw=-60.0)
	p.add("ShelfA", B2 + "wall_shelf.glb", 0.0, 1.648, -3.1, -90.0, mount="wall")
	p.add("ShelfABooks", B2 + "books_row.glb", 0.16, 1.92, -2.95, -90.0)
	p.add("Calendar", FU + "calendar.glb", x=40.74, y=1.45, z=-5.0, yaw=-90.0, mount="wall")
	p.add("CeilingFan", FU + "ceiling_fan_split.glb", x=41.4, y=L.CEILING, z=-2.2, yaw=0.0)
	p.add("CeilingFanBack", FU + "ceiling_fan_split.glb", x=42.3, y=L.CEILING, z=-5.0, yaw=30.0)
	for k, x in enumerate((40.9, 43.0)):
		p.add("SocketFront%d" % k, B3 + "wall_socket.glb", x=x, y=0.3, z=L.WALL_ROOM, yaw=0.0, mount="wall")
	# Washing: the room's line (x 38.1..43.84), shirts clear of the bathroom door (x 39.52..40.52) and the way in.
	for k, (x, colour) in enumerate(((38.35, "pink"), (38.8, "blue"), (39.25, "green"), (43.55, "navy"))):
		p.add("Shirt%d" % k, B2 + "shirt_hanging.glb", x=x, y=LINE_Y - SHIRT_DROP, z=-3.72, yaw=90.0, fabric=colour)
	slippers(p, [(1.2, -0.2, 180.0), (2.9, -0.25, 170.0), (p.s_of(39.3), -0.95, 150.0), (p.s_of(41.6), -3.8, 90.0)])
	bathroom(p, extra=[])
	balcony(p, "navy", items=[(B3 + "drying_rack.glb", p.s_of(39.4), -7.75, 0.0), (B3 + "basin_clothes.glb", 0.7, -7.5, 0.0),
		(B1 + "bucket.glb", 0.25, -8.1, 0.0)],
		shirts=[(1.1, "grey"), (1.7, "pink"), (2.3, "blue"), (2.9, "green"), (3.5, "maroon")], towels=[4.2, 4.8])
	return p


# ---------------------------------------------------------------- checks and output

def footprint(row):
	"""Rough floor box (x0, x1, z0, z1) of a solid row, from the sizes measured off the glbs."""
	# The open locker by its body: its swung door is not a footprint (room 407 stands it the same way).
	sizes = {"bunk_frame": (0.9, 2.0), "locker_closed": (0.675, 0.6), "locker_open": (0.675, 0.6), "locker_viet": (0.7, 0.666),
		"desk": (1.5, 0.65), "stool": (0.295, 0.295), "bookshelf": (1.0, 0.35), "fridge": (0.54, 0.56), "water_dispenser": (0.36, 0.37),
		"toilet": (0.41, 0.7), "bath_shelf": (0.38, 0.2), "folding_table": (0.7, 0.5), "drying_rack": (1.2, 0.86), "shoe_rack": (0.6, 0.26),
		"standing_fan_split": (0.62, 0.51), "storage_box": (0.55, 0.68), "suitcase": (0.58, 0.61), "cardboard_boxes": (0.47, 0.32)}
	key = row["model"].rsplit("/", 1)[1][:-4]
	w, d = sizes[key]
	if abs(abs(row["yaw"]) - 90.0) < 45.0:
		w, d = d, w
	x, _, z = row["position"]
	return x - w / 2, x + w / 2, z - d / 2, z + d / 2


def check(plan):
	r = plan.room
	sx0, sx1, sz0, sz1 = L.SPAWN_CLEAR
	box = (r.door_x + sx0, r.door_x + sx1, sz0, sz1)
	for row in plan.rows:
		if not row.get("solid"):
			continue
		x0, x1, z0, z1 = footprint(row)
		assert x1 <= box[0] or x0 >= box[1] or z1 <= box[2] or z0 >= box[3], (r.number, row["name"], "in the zombies' box")
		assert x0 >= r.x0 - 0.01 and x1 <= r.x1 + 0.01, (r.number, row["name"], "through a side wall", x0, x1)
		assert z0 >= L.PARAPET_OUT and z1 <= L.WALL_ROOM + 0.01, (r.number, row["name"], "through the front wall")


def layout(room):
	def r(v):
		return [round(x, 4) for x in v] if isinstance(v, (list, tuple)) else round(v, 4)
	return {"x0": r(room.x0), "x1": r(room.x1), "west": room.west, "east": room.east if room.number != "408" else 44.0,
		"door_x": room.door_x, "bath_side": room.bath_side, "bath": r(room.bath), "bath_wall": r(room.bath_wall),
		"bath_door": r(room.bath_door), "balcony_door": r(room.balcony_door), "window": r(room.window)}


def main():
	plans = [room_401(), room_402(), room_403(), room_404(), room_405(), room_406(), room_408()]
	data = {"note": "T-255 (D-168): written by art_source/graphics_upgrade/floor4_rooms/make_placements.py",
		"depths": {"wall_room": L.WALL_ROOM, "back_in": L.BACK_IN, "back_out": L.BACK_OUT, "balcony_out": L.BALCONY_OUT,
			"parapet_out": L.PARAPET_OUT, "bath_front_room": L.BATH_FRONT_ROOM, "bath_front_in": L.BATH_FRONT_IN,
			"ceiling": L.CEILING, "ext_h": L.EXT_H, "bath_door_top": L.BATH_DOOR_TOP, "balcony_door_top": L.BALCONY_DOOR_TOP},
		"rooms": {}}
	for plan in plans:
		check(plan)
		data["rooms"][plan.room.number] = {"layout": layout(plan.room), "props": plan.rows}
		print("T255_PLACEMENTS", plan.room.number, len(plan.rows), "rows")
	OUT.parent.mkdir(parents=True, exist_ok=True)
	with open(OUT, "w", encoding="utf-8", newline="\n") as out:
		out.write(json.dumps(data, indent="\t", ensure_ascii=False) + "\n")


if __name__ == "__main__":
	main()
