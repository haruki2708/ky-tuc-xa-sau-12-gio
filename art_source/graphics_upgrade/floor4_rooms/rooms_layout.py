"""T-255 (D-168): rooms 401-406 and 408 on floor 4, as deep as room 407, each with a bathroom and a balcony.
Plain Python (no bpy): shared by the Blender builders, the plan drawing and the placement tables.

Floor4 metres (Godot axes). The corridor wall stands at z -0.1..0.1; room 407 (x 30..38, room-local x 0.1..7.9 at
x + 30) goes back to its inner back face z -6.925, its back wall -6.925..-7.075, its balcony -7.075..-8.45 behind a
parapet -8.45..-8.55 (art_source/graphics_upgrade/room407_shell/shell_layout.py). Every new room takes the same
depths so the floor-4 back facade is one line. Partitions stay where they are (x 6, 10, .., 30 and 38, 0.2 thick),
doors stay where they are (401..406 at x 8, 12, .., 28; 408 at 42; opening x - 0.45 .. x + 0.43, y 0..2.08).
Chapter 3-4: room 408's east side is the fire stairwell's west wall (Campus FireStairs/Wall43.92, face x 43.84).
"""
CEILING = 3.0
WALL_ROOM = -0.1  # room face of the corridor wall
BACK_IN, BACK_OUT = -6.925, -7.075
BALCONY_OUT, PARAPET_OUT = -8.45, -8.55
BATH_FRONT_ROOM, BATH_FRONT_IN = -3.925, -4.075  # the bathroom's front wall, 0.15 thick (as 407)
PARTITION_HALF = 0.1
DOOR = (-0.45, 0.43, 2.08)  # opening relative to the door's x, and its top
BATH_DOOR_W, BATH_DOOR_TOP = 1.0, 2.2  # room 407's bathroom door (hinged.gd, its Tripo leaf)
BALCONY_DOOR_W, BALCONY_DOOR_TOP = 1.0, 2.3  # room 407's balcony door
BATH_DOOR_IN = 0.12  # the bathroom door's jamb from the bathroom's partition
EAST_408 = 43.84  # chapter 3-4: the fire stairwell's wall; chapter 1-2: Room408EastWall's face is 43.9
# Zombies (chapter 3, D-061): RoomSpawns B4/R<room> at (door x, 0, -1.5), a second one 0.6 m east; the nav strip of
# each room is x +/- 0.65 of the door, z -2.5..-0.5 (campus Navigation). Furniture keeps out of this box:
SPAWN_CLEAR = (-0.7, 0.95, -2.6, -0.1)  # x0, x1 relative to the door, z0, z1


class Room:
    def __init__(self, number, west, east, door_x, bath_side):
        self.number = number
        self.west, self.east = west, east  # partition centre lines (408: east is its wall face)
        self.x0 = west + PARTITION_HALF  # inner faces
        self.x1 = east - PARTITION_HALF if number != "408" else EAST_408
        self.door_x = door_x
        self.bath_side = bath_side  # "east" or "west": which back corner holds the bathroom
        width = 2.54 if number == "408" else 1.8  # bathroom inner width (407: 2.525)
        # The balcony door stands BALCONY_DOOR_IN from the side wall away from the bathroom (408: in the room's
        # middle, clear of its back bunk); the bathroom door hard by its partition, on the room's middle side, so
        # the way in passes the bath-side bunk's foot (placements.py).
        balcony_in = 1.24 if number == "408" else 0.75
        if bath_side == "east":
            self.bath = (self.x1 - width, self.x1)
            self.balcony_door = (self.x0 + balcony_in, self.x0 + balcony_in + BALCONY_DOOR_W)
            self.bath_door = (self.bath[0] + BATH_DOOR_IN, self.bath[0] + BATH_DOOR_IN + BATH_DOOR_W)
        else:
            self.bath = (self.x0, self.x0 + width)
            self.balcony_door = (self.x1 - balcony_in - BALCONY_DOOR_W, self.x1 - balcony_in)
            self.bath_door = (self.bath[1] - BATH_DOOR_IN - BATH_DOOR_W, self.bath[1] - BATH_DOOR_IN)
        # The bathroom's partition (0.1 thick) faces the room at bath_wall.
        self.bath_wall = self.bath[0] - 0.1 if bath_side == "east" else self.bath[1] + 0.1

    def s_to_x(self, s):
        """Across the room from the side wall away from the bathroom (s 0) towards the bathroom's side."""
        return self.x0 + s if self.bath_side == "east" else self.x1 - s

    def yaw(self, yaw):
        """A yaw given for a bath-east room (s along +x), as it stands in this room."""
        return yaw if self.bath_side == "east" else -yaw

    @property
    def window(self):
        """The bathroom's louvred window in the back wall (x0, x1, y0, y1): off the bathroom's middle away from the
        balcony door, whose leaf opens flat against the facade on the bathroom's side."""
        c = (self.bath[0] + self.bath[1]) / 2 + (0.2 if self.bath_side == "east" else -0.2)
        return (c - 0.3, c + 0.3, 1.85, 2.35)

    @property
    def width(self):
        return self.x1 - self.x0


# Neighbouring rooms mirror each other across their shared wall (plumbing back to back): 401|402, 403|404, 405|406.
ROOMS = [Room(str(401 + k), 6.0 + 4.0 * k, 10.0 + 4.0 * k, 8.0 + 4.0 * k, "east" if k % 2 == 0 else "west")
    for k in range(6)] + [Room("408", 38.0, 44.0, 42.0, "west")]
ROOM = {r.number: r for r in ROOMS}


# ---------------------------------------------------------------- mask atlas (UV2), shared with the mask painter
ATLAS = 4096
REGION = (2048, 1024)  # one per room: 2 across, 4 down
WALL_H = 3.0
EXT_H = 3.3  # the back facade is carried up to floor 5's slab (chapter 3-4: Campus BuildingB/UpperFloor5 at y 3.3)


def region_origin(room):
    k = [r.number for r in ROOMS].index(room.number)
    return (k % 2) * REGION[0], (k // 2) * REGION[1]


def wall_runs(room):
    """The room's inside faces as runs along one perimeter coordinate p (metres): name -> (p0, length)."""
    x0, x1 = room.x0, room.x1
    depth = WALL_ROOM - BACK_IN
    runs, p = {}, 0.0
    for name, length in (("front", x1 - x0), ("east", depth), ("back", x1 - x0), ("west", depth),
            ("bathside", BATH_FRONT_ROOM - BACK_IN), ("bathfront", room.bath[1] - room.bath[0] + 0.1)):
        runs[name] = (p, length)
        p += length + 0.05
    return runs, p


def bath_runs(room):
    width = room.bath[1] - room.bath[0]
    depth = BATH_FRONT_IN - BACK_IN
    runs, p = {}, 0.0
    for name, length in (("front", width), ("east", depth), ("back", width), ("west", depth)):
        runs[name] = (p, length)
        p += length + 0.05
    return runs, p


# Rectangles inside a room's region (x, y, w, h in pixels).
RECT_WALLS = (0, 0, 2048, 300)
RECT_BATH = (0, 300, 1024, 300)
RECT_EXT = (1024, 300, 1024, 300)
RECT_FLOOR = (0, 600, 1024, 424)
RECT_CEILING = (1024, 600, 1024, 424)
# The floor and ceiling rects are 20 m wide at their scale: the bathroom floor (in RECT_FLOOR) and the balcony floor
# (in RECT_CEILING) are drawn this far along, past the widest room (408, 5.74 m).
SECOND_SURFACE_AT = 6.0


def to_uv(room, rect, a, b, scale):
    """Pixel (a * scale, b * scale) inside `rect` of the room's region -> UV2 (Blender convention: v up)."""
    rx, ry = region_origin(room)
    px = rx + rect[0] + min(max(a * scale, 1.0), rect[2] - 1.0)
    py = ry + rect[1] + min(max(b * scale, 1.0), rect[3] - 1.0)
    return px / ATLAS, 1.0 - py / ATLAS


def scales(room):
    """px per metre of each band (walls, bath, exterior, floor and ceiling)."""
    _, wall_len = wall_runs(room)
    _, bath_len = bath_runs(room)
    width = room.x1 - room.x0 + 0.2
    depth = WALL_ROOM - BALCONY_OUT
    return {"walls": min(RECT_WALLS[2] / wall_len, RECT_WALLS[3] / WALL_H),
            "bath": min(RECT_BATH[2] / bath_len, RECT_BATH[3] / WALL_H),
            "ext": min(RECT_EXT[2] / width, RECT_EXT[3] / EXT_H),
            "floor": min(RECT_FLOOR[2] / width, RECT_FLOOR[3] / depth),
            "ceiling": min(RECT_CEILING[2] / width, RECT_CEILING[3] / depth)}
