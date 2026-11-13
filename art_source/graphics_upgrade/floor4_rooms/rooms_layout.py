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
        if bath_side == "east":
            self.bath = (self.x1 - width, self.x1)
            self.balcony_door = (self.x0 + 0.55, self.x0 + 0.55 + BALCONY_DOOR_W)
        else:
            self.bath = (self.x0, self.x0 + width)
            self.balcony_door = (self.x1 - 0.55 - BALCONY_DOOR_W, self.x1 - 0.55)
        # The bathroom's partition (0.1 thick) faces the room at bath_wall; its door sits towards the room's middle.
        self.bath_wall = self.bath[0] - 0.1 if bath_side == "east" else self.bath[1] + 0.1
        mid = (self.bath[0] + self.bath[1]) / 2
        self.bath_door = (mid - BATH_DOOR_W / 2, mid + BATH_DOOR_W / 2)

    @property
    def width(self):
        return self.x1 - self.x0


# Neighbouring rooms mirror each other across their shared wall (plumbing back to back): 401|402, 403|404, 405|406.
ROOMS = [Room(str(401 + k), 6.0 + 4.0 * k, 10.0 + 4.0 * k, 8.0 + 4.0 * k, "east" if k % 2 == 0 else "west")
    for k in range(6)] + [Room("408", 38.0, 44.0, 42.0, "west")]
ROOM = {r.number: r for r in ROOMS}
