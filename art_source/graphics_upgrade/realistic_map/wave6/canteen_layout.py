"""T-263 wave 6: the canteen's measured layout (main's canteen.tscn and its WestExit instance, as survey_canteen.gd dumped
them into survey/canteen_nodes.tsv; the canteen's root transform is 0, so these are world coordinates). Shared by the
texture, Blender and sheet scripts. Pure Python (Blender's interpreter imports it too).
"""
from pathlib import Path
import math
import re

HERE = Path(__file__).resolve().parent
SURVEY = HERE / "survey" / "canteen_nodes.tsv"

G = -9.9                 # hall, kitchen and store floor top (Floor, KitchenFloor, StoreFloor colliders)
CEIL = -5.9              # the PS1 ceiling's underside (Ceiling/Mesh -5.9..-5.8)
ROOF_UNDER = -5.45       # the roof slab's underside (Roof/Mesh, KitchenRoof/Mesh)
ROOF_TOP = -5.15
WALL_TOP = -5.3          # wall colliders reach y -5.3 (4.6 m from -9.9)
T = 0.125                # half the walls' thickness (0.25 m)
HALL = {"x": (170.0, 210.0), "z": (20.0, 44.0)}
KITCHEN = {"x": (186.0, 198.0), "z": (44.0, 52.0)}
STORE = {"x": (198.0, 210.0), "z": (44.0, 52.0)}
DOOR = (186.0, 194.0)            # main door: the gap between Front178 and Front202 (full height in PS1)
WEST_DOOR = (39.5, 41.5)         # WestExit: SouthWall z 20..39.5, NorthWall z 41.5..44, Lintel y -7.5..-5.3
WEST_DOOR_HEAD = -7.5
STORE_DOOR = (201.0, 203.0)      # store's opening to the hall (Back199.5 x 198..201, Back206.5 x 203..210)
BACK_DOOR = (200.0, 204.0)       # store's back door (StoreBack199 x 198..200, StoreBack207 x 204..210)
WINDOWS_X = [172.0, 175.0, 178.0, 181.0, 184.0, 196.0, 199.0, 202.0, 205.0, 208.0]
WINDOW = {"w": 2.4, "h": 1.6, "y": -7.7}   # glass 2.4 x 1.6 centred at y -7.7: sill -8.5, head -6.9
TUBES = [(x, z) for x in (175.0, 183.0, 191.0, 199.0, 207.0) for z in (24.0, 30.0, 36.0, 41.0)]
TUBE_Y = -5.92
FANS = [(179.0, 30.0, 59.0), (201.0, 30.0, 0.0), (190.0, 37.0, 0.0)]   # x, z, PS1 blade yaw (FanBlades_*)
LIGHTS = [(190.0, -6.3, 25.0), (190.0, -6.3, 33.0), (190.0, -6.3, 40.0)]  # CeilingLight25/33/40 (kept)
TV = {"case": (170.2, -7.5, 32.0), "case_size": (0.16, 0.8, 1.2), "screen": (170.29, -7.5, 32.0), "screen_size": (0.015, 0.66, 1.04)}
COUNTER = {"x": (170.5, 185.5), "z": (41.9, 42.9), "top": -9.0}     # Counter collider 15 x 0.9 x 1 at (178, -9.45, 42.4)
SERVE_X = [172.5, 175.5, 178.5, 181.5, 184.5]
PRICES = ["CƠM 5", "RAU 3", "THỊT 8", "CANH 2", "MÌ 6"]                # PriceText0..4, west to east (kept as they are)
SIGN_TEXT = "NHÀ ĂN SINH VIÊN"                                        # SignText
SLOGAN_TEXT = "TIẾT KIỆM LƯƠNG THỰC, KHÔNG BỎ PHÍ CƠM"                # SloganText
COOKTOP = {"x": (188.0, 196.0), "z": (50.65, 51.75), "top": -9.0}      # Cooktop collider
PREP = {"x": (188.4, 189.4), "z": (44.4, 48.8), "top": -9.0}           # PrepTable collider
SINK = {"x": (186.6, 187.8), "z": (48.85, 49.75), "top": -9.0}         # KitchenSink collider
CLOCK = (192.0, -7.4, 51.85)     # KitchenClock (meta stopped_hour = 4): dial faces -z, hands at 4:00
TABLE = {"top": 0.76, "len": 2.4, "depth": 0.75, "collider": (2.6, 0.9, 2.0)}  # local to each Table_* (x along the table)
STOOLS = [(sx * 0.8, sz * 0.75) for sz in (-1, 1) for sx in (-1, 0, 1)]
STOOL_COLOURS = ["red", "blue", "red", "red", "blue", "red"]            # Stool-1_0..Stool1_2 as the PS1 tints


def _vec(text):
	return tuple(float(t) for t in text.strip("()").split(","))


def rows():
	"""{path: (type, visible, position, rotation_deg, detail)} from the survey dump."""
	out = {}
	for line in SURVEY.read_text(encoding="utf-8").splitlines()[1:]:
		cells = line.split("\t")
		if len(cells) < 6:
			continue
		pos = _vec(cells[3]) if cells[3] != "-" else None
		rot = _vec(cells[4]) if cells[4] != "-" else None
		out[cells[0]] = (cells[1], cells[2], pos, rot, cells[5])
	return out


def tables():
	"""[(name, (x, z), yaw_deg)] of the 21 tables."""
	out = []
	for path, (kind, _vis, pos, rot, _d) in rows().items():
		if re.fullmatch(r"Table_\d+_\d+", path):
			out.append((path, (pos[0], pos[2]), rot[1]))
	return sorted(out)


def table_items(prefix):
	"""Per table: [(table, (x, y, z) world, yaw_deg)] of its Tray*/Bowl*/Chopsticks* children (prefix 'Tray' etc.)."""
	out = []
	for path, (kind, _vis, pos, rot, _d) in rows().items():
		m = re.fullmatch(r"(Table_\d+_\d+)/(%s\d+)" % prefix, path)
		if m:
			out.append((m.group(1), pos, rot[1]))
	return sorted(out)


def floor_items(prefix):
	"""[(name, (x, y, z), yaw)] of root nodes FloorTray*, Spill* ..."""
	out = []
	for path, (kind, _vis, pos, rot, _d) in rows().items():
		if re.fullmatch(r"%s\d+(\.\d+)?" % prefix, path):
			out.append((path, pos, rot[1]))
	return sorted(out)


def local_to_world(centre, yaw_deg, lx, lz):
	"""A table-local (x along the table, z across) point to world x, z (Godot yaw about +y)."""
	a = math.radians(yaw_deg)
	return (centre[0] + lx * math.cos(a) + lz * math.sin(a), centre[1] - lx * math.sin(a) + lz * math.cos(a))


# Interior wall faces of the hall, counter-clockwise from the south-west corner, as (start (x, z), end (x, z)) along
# the face; the mask atlas row 0 unrolls them in this order (u = metres along / HALL_PERIMETER).
HALL_FACES = [((170.0 + T, 20.0 + T), (210.0 - T, 20.0 + T)), ((210.0 - T, 20.0 + T), (210.0 - T, 44.0 - T)),
	((210.0 - T, 44.0 - T), (170.0 + T, 44.0 - T)), ((170.0 + T, 44.0 - T), (170.0 + T, 20.0 + T))]
HALL_PERIMETER = 128.0
KITCHEN_FACES = [((186.0 + T, 44.0), (186.0 + T, 52.0 - T)), ((186.0 + T, 52.0 - T), (198.0 - T, 52.0 - T)),
	((198.0 - T, 52.0 - T), (198.0 - T, 44.0))]
WALL_H = 4.6
MASK_ROWS = 4    # mask_walls.png: row 0 hall inside, row 1 kitchen and store inside, row 2 front facade, row 3 spare


def wall_uv2(row, s, y, length):
	"""UV2 of a wall point: metres along its unrolled row, height above the floor."""
	u = min(max(s / length, 0.0), 1.0)
	v = min(max((y - G) / WALL_H, 0.0), 1.0)
	return (u, (row + 1.0 - v) / MASK_ROWS)


FLOOR_MASK = {"x": (166.0, 214.0), "z": (14.0, 62.0)}   # mask_floor.png (and mask_ceiling.png) cover this square


def floor_uv2(x, z):
	return ((x - FLOOR_MASK["x"][0]) / (FLOOR_MASK["x"][1] - FLOOR_MASK["x"][0]),
		(z - FLOOR_MASK["z"][0]) / (FLOOR_MASK["z"][1] - FLOOR_MASK["z"][0]))


# A16 box this wave (card section 3, fixed in round 1 by walk_canteen.gd): the ground round the canteen from the gate
# strip's edge (z 13) to the back yard (z 60), x 166..218, less the west exit's apron and the way to the library
# north of z 37 west of the hall (x < 170: wave 8). The canteen's own footprint is wave 6's A15.
A16_BOX = {"x": (166.0, 218.0), "z": (13.0, 60.0)}
A16_WAVE8 = {"x": (166.0, 170.0), "z": (37.0, 60.0)}


def in_a16(x, z):
	inside = A16_BOX["x"][0] <= x <= A16_BOX["x"][1] and A16_BOX["z"][0] <= z <= A16_BOX["z"][1]
	wave8 = A16_WAVE8["x"][0] <= x < A16_WAVE8["x"][1] and A16_WAVE8["z"][0] < z <= A16_WAVE8["z"][1]
	return inside and not wave8


# Metres per repeat of each shell-shader scan (the shader has no uv1_scale: the builders divide UV1 by these).
SIZES = {"W6FloorCeramic": 1.6, "W6FloorTerrazzo": 1.0, "W6KitchenFloor": 0.6, "W6WallYellow": 2.0, "W6WallGreen": 2.0,
	"W6Wainscot": 1.24, "W6DadoGreen": 2.0, "W6CeilingPanel": 2.4, "W6StoveTile": 1.24, "W6FacadeYellow": 2.0,
	"W6FacadeWhite": 2.0, "W6CounterTile": 1.24}
PRICE_PX = (1024, 276)     # one price board in price_*.png (2.6 x 0.7 m); 2 columns x 3 rows, 340 px apart

# ------------------------------------------------------------------------------------ round 2 (D-181)
# The owner's picks (D-181): T1 tables, F1 floor and walls, Q1 counter with black wood price boards, C2 ceiling, K1
# kitchen, M2 mess, the TV keeps the wordless news frame. Round 2 adds the rest of A15 and the A16 strip; every number
# below is main's (survey/canteen_nodes.tsv).
SIZES.update({"W6Pavers": 0.9, "W6YardConcrete": 2.0})
# East side of the hall: the hand basins on SinkBlock (collider x 209.3..209.9, z 21.55..26.15, top -9.1), the tray
# return rack on TrayReturn (x 208.9..209.9, z 37.5..40.5, top -8.1) with ReturnShelf0..3 and the "TRẢ KHAY" sign
# (ReturnSign), two slop bins (no collider).
SINK_BLOCK = {"x": (209.3, 209.9), "z": (21.55, 26.15), "top": -9.1}
BASINS_Z = [22.2, 23.3, 24.4, 25.5]
TRAY_RETURN = {"x": (208.9, 209.9), "z": (37.5, 40.5), "top": -8.1}
RETURN_SHELVES = [-9.5, -9.05, -8.6, -8.15]
DIRTY_TRAYS = [(209.0, -9.45, 38.2), (209.0, -9.0, 38.7), (209.0, -8.55, 39.2), (209.0, -8.1, 39.7)]
RETURN_SIGN = "TRẢ KHAY"
SLOP_BINS = [(208.4, 41.2), (208.4, 41.9)]
# Posters on the west wall (PS1 Poster0..3 at z 24, 28, 36, 40). Poster3 hung in the west exit's opening (z 39.5..41.5,
# up to y -7.5): the thing PLAN section 9 saw in the doorway. Its new place is beside the exit, clear of the opening.
POSTERS_Z = [24.0, 28.0, 36.0, 42.85]
AC_Z = [24.0, 30.0, 36.0]        # ACUnit24/30/36 on the west wall's outside (169.43..169.78, y -7.6..-7.0)
# Store (x 198..210, z 44..52): racks Shelf199.2_* and Shelf209.2_* (0.7 x 5 m, boards at y -9.4, -8.5, -7.6), the
# boxes on the west rack, the oil cans on the east one, sacks by the back door; the kitchen's rice sacks.
RACKS_X = [199.2, 209.2]
RACK_Z = (45.5, 50.5)
RACK_LEVELS = [-9.4, -8.5, -7.6]
STORE_BOXES = [(199.2, -9.2, 46.0), (199.2, -8.3, 46.5), (199.2, -7.4, 47.0), (199.2, -9.2, 47.5), (199.2, -8.3, 48.0),
	(199.2, -7.4, 48.5), (199.2, -9.2, 49.0), (199.2, -8.3, 49.5)]
OIL_CANS = [(209.2, -9.2, 46.0), (209.2, -8.3, 46.5), (209.2, -7.4, 47.0), (209.2, -9.2, 47.5), (209.2, -8.3, 48.0),
	(209.2, -7.4, 48.5), (209.2, -9.2, 49.0), (209.2, -8.3, 49.5)]
STORE_SACKS = [(200.4, -9.6, 50.8), (200.4, -9.6, 50.0), (200.4, -9.6, 49.2)]
RICE_SACKS = [(196.9, -9.6, 45.0), (196.9, -9.6, 45.8), (196.9, -9.1, 45.0), (196.9, -9.1, 45.8)]
BACK_DOOR_HEAD = -7.4            # the back door's shutter box starts 2.5 m up (the opening x 200..204 is full height)
STORE_DOOR_HEAD = -7.5
# Outside: bikes (Bike0..5, frame along x, Bike0 and Bike3 leaning 12 degrees), bins, gas cylinders, the chimney.
BIKES = [(172.0, 17.2, 12.0), (173.6, 17.2, 0.0), (175.2, 17.2, 0.0), (176.8, 17.2, 12.0), (178.4, 17.2, 0.0), (180.0, 17.2, 0.0)]
BINS = [(205.0, 54.2, "blue_plastic"), (206.2, 54.2, "bin_grey")]
GAS_CYLINDERS = [(189.0, 53.0), (189.6, 53.0)]
CHIMNEY = (192.0, 51.0)
KITCHEN_ROOF = {"x": (185.875, 210.125), "z": (44.5, 52.3)}   # the kitchen and store's own slab (PS1 KitchenRoof)
ROOF = {"x": (169.5, 210.5), "z": (19.5, 44.5)}               # the hall's slab (PS1 Roof), parapets on all four sides
# Outside faces other than the front: mask row 3 unrolled anticlockwise seen from above, from the hall's north-west
# corner (s in metres): back wall west part, kitchen west, kitchen back, store back, store and hall east, hall west.
OUT_ROW = 3
OUT_RUNS = {"back_west": 0.0, "kitchen_west": 16.25, "kitchen_back": 24.5, "store_back": 36.75, "east": 49.0, "west": 81.5}
OUT_LENGTH = 128.0
# Store inside faces in mask row 1 after the kitchen's (s 28 on).
STORE_S = 40.0

# The A16 strip round the canteen (inside A16_BOX, less wave 8's corner and the building's footprint).
FOOTPRINT = {"x": (169.875, 210.125), "z": (19.875, 52.125)}
STRIP_UV = {"x": (166.0, 218.0), "z": (13.0, 60.0)}           # mask_strip6.png and mask_yard6.png (UV2)
GROUND_TOP = -9.93          # lawn 1 cm over the PS1 ground tiles (-9.94), as waves 3-5
PAVED_TOP = G               # pavers and the yard's concrete as T-262's walk (which ends at z 13, x 186..217)
FRONT_PAVED = {"x": (168.0, 217.0), "z": (13.0, 19.875)}      # the forecourt from the gate strip's walk to the facade
YARD = {"x": (184.0, 214.0), "z": (52.125, 58.5)}             # the service yard behind the kitchen and the store
APRON = 0.6                 # concrete apron along the back and side walls, a covered drain on its outer edge
DRAIN = 0.3


def strip_uv2(x, z):
	return ((x - STRIP_UV["x"][0]) / (STRIP_UV["x"][1] - STRIP_UV["x"][0]), (z - STRIP_UV["z"][0]) / (STRIP_UV["z"][1] - STRIP_UV["z"][0]))


# The building is an L: the hall, and the kitchen with the store behind its east part (the yard behind the hall's west
# part, x 170..185.875, z 44.125..52.125, is outside).
FOOTPRINT_PARTS = [{"x": (169.875, 210.125), "z": (19.875, 44.125)}, {"x": (185.875, 210.125), "z": (44.125, 52.125)}]


def in_footprint(x, z, grow=0.0):
	return any(p["x"][0] - grow < x < p["x"][1] + grow and p["z"][0] - grow < z < p["z"][1] + grow for p in FOOTPRINT_PARTS)


# props.tscn pieces this wave replaces in the A16 box (list_a16_box.py's kinds, round 1): papers, sandals, a backpack,
# trays. Kept: corpse heads (skin tint), drag marks, blood, and what stands round the kiosks, the drinks machine, the
# bicycle and the moped.
SKIN = (0.9, 0.7, 0.6)
REPLACED = ("paper", "dropped: sandal", "dropped: backpack", "dropped: tray")
KEEP_ROUND = [((214.0, 17.4), 2.6), ((219.5, 17.4), 2.6), ((182.2, 16.0), 0.8), ((208.4, 17.1), 0.9), ((207.6, 54.6), 1.3)]


def _close(a, b, tol=0.015):
	return all(abs(p - q) <= tol for p, q in zip(a, b))


def replaced_kind(name, c):
	"""c: one props.tscn instance (16 floats: basis columns, origin, colour). The kind this wave replaces, or None."""
	x, y, z = c[9:12]
	scale = tuple(math.sqrt(sum(t * t for t in c[k:k + 3])) for k in (0, 3, 6))
	if max(scale) == 0 or not in_a16(x, z) or tuple(round(t, 2) for t in c[12:15]) == SKIN:
		return None
	if name.startswith("D_iron") or name.startswith("D_red") or any(math.hypot(x - p[0], z - p[1]) <= r for p, r in KEEP_ROUND):
		return None
	if name.startswith("D_paper") and y < -9.7:
		return "paper"
	if name.startswith("D_white") and _close(scale, (0.11, 1.0, 0.27)):
		return "dropped: sandal"
	if name.startswith("P_white_box") and (_close(scale, (0.32, 0.42, 0.2)) or _close(scale, (0.26, 0.2, 0.06))):
		return "dropped: backpack"
	if (name.startswith("P_white_box") and _close(scale, (0.42, 0.03, 0.3))) or (name.startswith("P_paper_box") and _close(scale, (0.34, 0.012, 0.16))):
		return "dropped: tray"
	return None


def price_uv(i):
	"""UV rectangle (u0, v0, u1, v1; v down as in the image) of board i in price_*.png (2048 x 1024)."""
	col, row = divmod(i, 3)
	return (col * 1024 / 2048, row * 340 / 1024, (col + 1) * 1024 / 2048, (row * 340 + PRICE_PX[1]) / 1024)
