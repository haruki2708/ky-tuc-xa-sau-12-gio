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


def price_uv(i):
	"""UV rectangle (u0, v0, u1, v1; v down as in the image) of board i in price_*.png (2048 x 1024)."""
	col, row = divmod(i, 3)
	return (col * 1024 / 2048, row * 340 / 1024, (col + 1) * 1024 / 2048, (row * 340 + PRICE_PX[1]) / 1024)
