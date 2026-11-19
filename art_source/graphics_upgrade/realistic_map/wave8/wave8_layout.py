"""T-265 wave 8: the library's measurements, taken from main's library.tscn (art_source/ch4_environment/build.py made it,
survey/library_nodes.tsv and plan_geometry.json confirm it). Godot world coordinates: the scene's root sits at
(45, -9.9, 195), so world = local + (45, -9.9, 195). Shared by the plan, the Blender pilot, the texture and capture
scripts. Pure Python (Blender's interpreter imports it).
"""
ORIGIN = (45.0, -9.9, 195.0)
G = -9.9
FLOOR_H = 3.3
LEVELS = [-9.9, -6.6, -3.3]          # floor tops (Floor<t>_Main/_South/_North tops; slabs 0.24 thick under them)
SLAB = 0.24
ROOF_UNDER = -0.05                   # Roof: 40 x 0.2 x 30 at y 0.05
ROOF_TOP = 0.15
CEILING = [y + FLOOR_H - SLAB for y in LEVELS[:2]] + [ROOF_UNDER]   # -6.84, -3.54, -0.05

# Walls (0.22 thick, centred on the scene's x 0 / 40, z 0 / 30): inner and outer faces.
WALL_T = 0.22
IN_W, IN_E, IN_S, IN_N = 45.11, 84.89, 195.11, 224.89
OUT_W, OUT_E, OUT_S, OUT_N = 44.89, 85.11, 194.89, 225.11
# The doorways through the ground floor's front (z 195) and back (z 225) walls: x 64..66, 2.4 m high (lintel above).
DOOR_X = (64.0, 66.0)
DOOR_H = 2.4
FRONT_DOOR = {"x": (64.025, 65.975), "z": (194.94, 195.06), "y": (G, G + 2.4)}      # FrontDoor: solid leaf, never opens
BACK_DOOR = {"at": (65.0, G, 225.0), "hinge_x": 64.03, "leaf": 1.94, "height": 2.4, "leaf_t": 0.1, "blocker_t": 0.16}
# Windows: 3 x 1.35 m dark panels (Window<t>_<x>_<z>) on the inside faces, x 50 / 58 / 72 / 80, both long walls; their foot
# 1.125 m and head 2.475 m over each floor; Sill<t>_* 3.15 x 0.07 x 0.25 at 1.1 m. The walls are solid behind them.
WINDOWS_X = [50.0, 58.0, 72.0, 80.0]
WINDOW = {"w": 3.0, "foot": 1.125, "head": 2.475, "sill": 1.1}
LIGHTS_X = [54.0, 70.0]               # Light<t>_9, _25: (x, floor + 2.8, 211), energy 0.65, range 16, kept as they are
LIGHT_Z = 211.0
LIGHT_H = 2.8
# Stairs on the east: two flights (Stairs0 floor 1 -> 2, Stairs1 floor 2 -> 3), x 79..84, rising north from z 199 to 209,
# 22 steps (0.15 rise, 10/22 tread); rails (RailCollision<t>_34 / _39) at x 79 and 84, 1.1 m over the slope. Upper
# floors are open over x 79..85, z 199..209 (the well). StairBase (floor 1) x 79..85, z 199..209.
STAIRS = {"x": (79.0, 84.0), "z": (199.0, 209.0), "steps": 22, "rise": 0.15}
RAILS_X = [79.0, 84.0]
WELL = (79.0, 85.0, 199.0, 209.0)
STAIR_FOOT = (81.0, 198.0)            # StairBottom<t> link (81, y, 198) -> (81, y, 199.1)
STAIR_TOP = (81.0, 210.0)             # StairTop<t> link (81, y + 3.3, 208.9) -> (81, y + 3.3, 210)
# Furniture (world), with the colliders kept.
SHELF_X = [51.0, 57.0, 73.0]          # Shelf<t>_6, _12, _28
SHELF_Z = {0: 218.0, 1: 202.0, 2: 218.0}
SHELF = {"w": 3.0, "d": 0.6, "h": 2.2, "back_z": 0.26, "boards_y": [0.1 + 0.56 * k for k in range(4)], "board_t": 0.07,
	"side_x": 1.48, "side_t": 0.08, "back_t": 0.08}      # open face toward -z (the front of the building)
TABLES_X = [53.0, 58.0, 72.0]         # ReadingTable8, 13, 27 on floor 2, z 216, 3 x 1.4, top 0.72..0.84 (only Top is solid)
TABLE_Z = 216.0
TABLE = {"w": 3.0, "d": 1.4, "top": 0.84, "top_t": 0.12}
CHAIR_DZ = 1.2                        # Chair<x>_-1 / _1 at z 216 -/+ 1.2 (no collider)
COUNTER = {"at": (57.0, G, 206.0), "w": 5.0, "d": 1.4, "top": 0.84, "top_t": 0.12, "panel_z": 0.6, "panel_t": 0.12, "panel_y": (0.05, 0.75)}
IRON_BAR = (58.0, -9.0, 206.0)        # Counter/IronBar: the pipe's middle line 0.9 over the floor, r 0.0135 -> its foot 0.886
LIBRARIAN_CHAIR = (57.0, G, 207.5)    # the anchor LibrarianSeat (57, -9.44, 207.5) is its seat
MAP_BOARD = {"at": (45.15, -8.1, 211.0), "w": 3.1, "h": 2.1, "paper": (2.9, 1.9)}   # on the west wall, facing +x
BARRICADE = {"at": (65.0, G, 196.0), "w": 2.6, "d": 1.3, "top": 0.84, "chairs_x": [64.2, 65.0, 65.8], "chairs_y": -9.05}
# Chapter 4's anchors (ch4_anchors.tscn, world; never moved).
ANCHORS = {"Start_library": (65.0, G, 223.0), "Counter": (58.0, -9.0, 206.0), "MapBoard": (45.25, -8.1, 211.0),
	"LibrarianSeat": (57.0, -9.44, 207.5), "ReadingDesk": (58.0, -5.71, 216.0), "ScareShelf3F": (57.0, -3.3, 218.0),
	"ThrownBook3F": (73.0, -1.1, 218.0)}
SPAWNS = [(62.0 + 3.0 * (i % 3), G, 228.0 + 3.0 * (i // 3)) for i in range(6)]
ZONE = (39.0, 91.0, 189.0, 231.0)     # wave 8's box: the library and 6 m round it
RUBBLE = [(58.0, 192.0, 25.91), (78.0, 192.0, 320.44)]   # Props/Solids/Body_p1_p4/S0, S1: 3.4 x 0.8 x 3.0 (kept)

# Fill options (card step 3), each piece {level, box (x0, x1, z0, z1), height, label, kind[, blocks_nav]}; filled in below.
FILL = {"m1": [], "m2": [], "m3": []}
