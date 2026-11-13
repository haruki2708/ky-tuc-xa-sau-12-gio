"""T-253 wave 2: building B's floors 1-3 as built by art_source/campus/build_campus.py building() and
detail.building() (no Blender here, so tests and the texture script can import it). Godot world metres.

Floors 1/2/3 stand at Y = -9.9 / -6.6 / -3.3 (floor 4 at 0). On each floor (y = its Y):
  slab        x 0..44, z -7.6..4.0, top y           ceiling box underside y + 3.03 (x 0..44, z -7.6..4.0)
  corridor    z 0.08 (room-side wall face) .. 3.945 (rail collider); open to the stairwells at x 0 and x 44
  room wall   Facade<i>L/R boxes 0.16 thick at z 0 (faces z +/-0.08), 3 m high; Lintel<i> over each door, y 2.5..3.0
  doors       centres x = 2.75 + 5.5 i, opening x +/- 0.85, y 0..2.5
  partitions  x = 5.5 (i + 1), 0.16 thick, z -7.6..0; back wall z -7.6 (room face -7.5); end walls x 0 / 44 (+/-0.1)
  rail        Floor<N>/Rail box x 0..44, y 0..1.3, z 3.945..4.095 (floor 1: LobbyRailWest/East, main door between)
"""

FLOORS = {1: -9.9, 2: -6.6, 3: -3.3}
G = -9.9
X0, X1 = 0.0, 44.0
BAYS = 8
BAY = 5.5
DOOR_HALF = 0.85  # the facade boxes' opening (x +/- 0.85, y 0..2.5)
DOOR_TOP = 2.5
# The doorway one can walk through: the wall_door kit under KitDetail<N>/Frame<i> (x, y, 0) has its own collision
# (kit_import.gd: piers x +/- 0.45..1.0, lintel y 2.1..3.0, all z +/- 0.1), so every lower-floor doorway is
# 0.9 x 2.1 m, as on floor 4. The RoomDoor's Blocker (1.7 x 2.4) shuts it from behind.
KIT_HALF = 0.45
KIT_TOP = 2.1
KIT_DEPTH = 0.1
HINGE_X = 0.45  # RoomDoor Hinge: the visual pivot on the doorway's edge (main had 0.85, inside the kit's pier)
WALL_TOP = 3.0
CEILING = 3.03  # underside of the ceiling box over every floor
FACE = 0.08  # corridor face of the room wall boxes
COVER = 0.003  # the new plaster stands this far in front of a PS1 face it covers
RAIL_Z = 4.02
RAIL_FRONT = 3.945  # rail collider's corridor face
RAIL_TOP = 1.3
SLAB_EDGE = 4.0
BACK_FACE = -7.5
PARTITION_HALF = 0.08
END_HALF = 0.1
STAIR_WALL_W = 0.16  # MainStairs/Wall0.08's room-side face (x 0..0.16, z -6.2..-0.2, every floor)
STAIR_WALL_E = 43.84  # FireStairs/Wall43.92's room-side face
LIGHTS_X = (1.0, 10.0, 21.0, 32.0, 43.0)  # KitDetail<N>/Light<x>: y + 2.65, z 2.0
LIGHT_Z = 2.0
# Floor 1 (build_campus.py): which bays have what.
F1_OPEN = (0, 3)  # room 101 (the manager's room) and the lobby room: no door, no leaf
F1_ALCOVES = (1, 4, 6)  # spawn alcoves: their Door<i> boxes are hidden and have no collision
F1_SHUT = (2, 5, 7)  # plain StaticBody doors that never open
ROOM203_BAY = 2  # floor 2: no door at all (Room203Door anchor (13.75, -6.6, 0))
MAIN_DOOR_X = 19.25
MAIN_DOOR_HALF = 1.5
LOBBY_RAILS = ((0.0, 17.65), (20.65, 44.0))
# Manager's window in floor 1's back wall: hole x 2..5.3, y G+1 .. G+2.44 (WindowSill / WindowHeader boxes 0.22 deep).
WINDOW = {"x0": 2.0, "x1": 5.3, "sill": 1.0, "head": 2.44, "z": -7.6, "depth": 0.22}
# WindowApproach (inside) and WindowExit (outside) collision ramps, x 3.1..4.9, and the bridge over the sill.
WINDOW_RAMPS = {"approach": (3.1, 4.9, -4.5, -7.2, 0.0, 1.0), "exit": (3.1, 4.9, -8.0, -10.7, 1.0, 0.0)}
WINDOW_BRIDGE = (3.1, 4.9, -8.0, -7.2, 0.8, 1.0)
# Bodies that stand in rooms (floors 2 and 3, room_doors.interior): relative to the door centre x, at the floor y.
ROOM_BUNK = {"x": -1.8, "decks": (0.4, 1.45), "deck": (0.85, 0.16, 1.95), "z": -3.45, "posts": (-4.35, -2.55),
	"post": (0.08, 1.8, 0.08), "post_y": 0.9}
ROOM_LOCKER = {"x": 1.8, "y": 0.85, "z": -3.9, "size": (0.7, 1.7, 0.65)}


def door_x(i):
	return 2.75 + i * BAY


def partition_x(i):
	return BAY * (i + 1)


def bay_span(i):
	"""Inside faces of bay i's room: x from the west wall or partition to the next."""
	x0 = END_HALF if i == 0 else partition_x(i - 1) + PARTITION_HALF
	x1 = X1 - END_HALF if i == BAYS - 1 else partition_x(i) - PARTITION_HALF
	return x0, x1


def room_number(floor, i):
	return floor * 100 + i + 1


def has_room_door(floor, i):
	"""RoomDoor (Floor<N>/Door<i> with Hinge/Leaf) on floors 2 and 3, except room 203."""
	return floor in (2, 3) and not (floor == 2 and i == ROOM203_BAY)


def room_visible(floor, i):
	"""Rooms whose inside can be seen: every room behind a RoomDoor (they open), 203, and floor 1's open bays."""
	if floor in (2, 3):
		return True
	return i in F1_OPEN or i in F1_ALCOVES
