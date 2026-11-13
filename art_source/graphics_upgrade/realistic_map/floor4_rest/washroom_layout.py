"""T-256 (D-170) part A: the floor-4 shared washroom, plain Python numbers (no bpy), shared by the Blender builder,
the mask painter and the tests' notes. Washroom metres = Floor4 metres (Floor4/Washroom stands at the origin).

The gameplay contract (game/scenes/levels/floor4/washroom.tscn, kept as main has it):
  room x 0..6, z -5..0, walls 0.2 thick on those lines (inner faces x 0.1, 5.9, z -4.9, -0.1), ceiling at y 3.0,
  entrance x 2.4..3.6 up to y 2.3 (its corridor side and reveals are the G5 corridor shell's);
  StallDoor_i boxes at x 1, 3, 5 (1.94 wide), z -3.55 (0.08 thick), y 0..2.2; StallPartition_i at x 0, 2, 4
  (0.08 thick), z -3.5..-5.0, y 0..2.5; Sink_i boxes at x 0.36 (0.52), z -0.85, -1.85, -2.85 (0.62), y 0..0.86;
  Tap_i at (0.17, 0.86, z_i); TapWater falls from (0.282, 0.985, -2.85); Mirror at (0.145, 1.62, -1.85) facing +x;
  WashroomLight at (3, 2.8, -2); Anchors/WashroomNotice at (0.15, 1.55, -3.25) facing +x (a paper 0.21 x 0.3).
"""
CEILING = 3.0
WEST, EAST, BACK, FRONT = 0.1, 5.9, -4.9, -0.1  # inner faces
ENTRANCE = (2.4, 3.6, 2.3)
TILE_TOP = 1.8  # wall tiles up to here, plaster above
COVER = 0.003  # new faces stand this far in front of the old (collision) faces
TILE_T = 0.008  # tiles stand proud of the plaster by this much
# Stalls: fronts on the StallDoor plane, partitions on the StallPartition lines (masonry, 0.08 thick, tiled).
FRONT_Z = (-3.59, -3.51)  # the front's two faces (back, room side)
STALL_TOP = 2.2
STALL_XS = [(WEST, 1.96), (2.04, 3.96), (4.04, EAST)]  # each stall's inner width
PARTITIONS = [2.0, 4.0]
DOOR_W, DOOR_TOP = 0.75, 2.0  # the doorway in each front, centred on the stall
LEAF = (0.70, 0.15, 1.98)  # leaf width, its bottom and top (a gap under it, as stall doors have)
# How far each leaf stands open into its stall (degrees) and which jamb holds its hinges: a gap narrower than a
# man's shoulders (D-170), each a little different.
DOORS = [{"open": 24.0, "hinge": "west"}, {"open": 31.0, "hinge": "east"}, {"open": 19.0, "hinge": "west"}]
PLATFORM_H = 0.12  # the squat pan's step inside each stall
# The wash trough (D-170: a long tiled masonry trough, three taps) over the three Sink_i boxes.
TROUGH = {"x": (WEST, 0.645), "z": (-3.2, -0.5), "top": 0.86, "rim": 0.06, "bottom": 0.70}
TAP_ZS = [-0.85, -1.85, -2.85]
TAP_SPOUT = (0.282, 0.985)  # x, y of the spout's mouth (TapWater)
PIPE_Y = 1.075  # the exposed supply pipe along the west wall, under the mirror
MIRROR = {"centre": (0.145, 1.62, -1.85), "size": (2.5, 0.95)}  # narrowed from 2.8 to clear the notice board
NOTICE = {"centre": (0.15, 1.55, -3.25), "size": (0.28, 0.38)}
LIGHT = (3.0, 2.8, -2.0)
DRAIN = (3.0, -1.9)  # the floor drain the floor falls to
FALL = 0.012  # how much lower the floor is at the drain (visual only; collision stays flat)

# Mask atlas (UV2) for the shell shader: 1024 x 1024.
ATLAS = 1024
RECT_WALLS = (0, 0, 1024, 256)  # the room's walls, one run round the perimeter
RECT_FLOOR = (0, 256, 512, 420)
RECT_CEILING = (512, 256, 512, 420)
RECT_STALLS = (0, 680, 1024, 344)  # stall fronts (both faces), partitions (both faces), trough faces


def wall_runs():
    """The room's inner faces as runs of one perimeter coordinate p (metres), walking anticlockwise seen from above
    with the room on the left: front (east to west), west (front to back), back (west to east), east (back to front)."""
    runs, p = {}, 0.0
    for name, length in (("front", EAST - WEST), ("west", FRONT - BACK), ("back", EAST - WEST), ("east", FRONT - BACK)):
        runs[name] = (p, length)
        p += length + 0.1
    return runs, p


def stall_runs():
    """Stall pieces in RECT_STALLS: the fronts' room faces and back faces, the partitions' faces, the trough."""
    runs, p = {}, 0.0
    for name, length in (("front_room", EAST - WEST), ("front_back", EAST - WEST),
            ("part0_w", 1.39), ("part0_e", 1.39), ("part1_w", 1.39), ("part1_e", 1.39),
            ("trough_front", 2.7), ("trough_end", 0.55)):
        runs[name] = (p, length)
        p += length + 0.1
    return runs, p


def scales():
    _, walls = wall_runs()
    _, stalls = stall_runs()
    return {"walls": min(RECT_WALLS[2] / walls, RECT_WALLS[3] / CEILING),
            "floor": min(RECT_FLOOR[2] / (EAST - WEST), RECT_FLOOR[3] / (FRONT - BACK)),
            "ceiling": min(RECT_CEILING[2] / (EAST - WEST), RECT_CEILING[3] / (FRONT - BACK)),
            "stalls": min(RECT_STALLS[2] / stalls, RECT_STALLS[3] / 2.5)}


def to_uv(rect, a, b, scale):
    """Metres (a along, b up or back) inside rect -> UV2 (Blender convention, v up)."""
    px = rect[0] + min(max(a * scale, 1.0), rect[2] - 1.0)
    py = rect[1] + min(max(b * scale, 1.0), rect[3] - 1.0)
    return px / ATLAS, 1.0 - py / ATLAS
