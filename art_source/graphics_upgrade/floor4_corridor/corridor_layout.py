"""T-235: the whole floor-4 corridor (x 0..44) in room 407's style, in Floor4 metres (Godot axes).
Grown from the T-233 pilot segment 406-407 (D-142 option A), approved by the owner with railing A1 and new
room plates (D-144). Shared by build_corridor.py (Blender) and make_corridor_masks.py (numpy). Plain Python.

Measured from the playable scene (a headless probe of floor4.tscn on 08/11/2026; PLAN.md section 1):
  corridor x 0..44, z 0..4; floor slab y -0.2..0, ceiling slab y 3..3.15; the room wall z -0.1..0.1
  (corridor face z 0.1) along the whole length.
  Doors 401..406 and 408 at x 8, 12, .., 28 and 42: kit piers x-1..x-0.45 and x+0.45..x+1, lintel from y 2.1;
  RoomDoor hinge (x+0.44, 0.01, 0), opening +90 degrees into the corridor (blocker x+-0.44, z -0.06..0.06).
  Door 407 as in T-233: Door407 pivot (32.44, 0.01, 0) opens into the room; room 407's frame lines the room
  half of the opening (z -0.123..-0.005).
  The old 408 doorway at x 36 (Former408Wall; Sealed408, a 0.85 x 1.7 panel at (36, 1.02, 0.13)): walled up
  when room 407 took that bay (T-190); room 408 moved to x 38..44.
  The washroom entrance x 2.4..3.6, up to y 2.3, no door (Washroom/EntranceWest, EntranceEast, EntranceLintel).
  RoomPlate_401..408 centred (x, 2.42) on the wall over each door, 408's at x 42.
  Corridor lights at y 2.8, z 2: CorridorLight_401..408 at x 8..36 every 4 m, CorridorLight_Desk at x 40.
  Railing at z 3.99: top rail y 1.04..1.10, low rail y 0.15..0.21, invisible barrier z 4.0..4.1, x 0..44.
  End caps WestEnd x -0.2..0 and EastEnd x 44..44.2, full width; Campus hides both to open the stairs.
  The duty desk stands against room 408's wall (x 39.25..40.75, z 0.095..0.745), its board and loudspeaker on it.
Nothing here has collision: the playable colliders stay as they are and every new face lies on or inside them.
"""
from dataclasses import dataclass
import zlib

PAD = 10  # bleed pixels round every atlas rectangle
NEUTRAL = (0, 0, 8, 8)  # the atlas corner kept at the group's plain value (unpainted faces sample it)
# Mask atlases (width, height) per group: 44 m of wall, floor and ceiling at a texel density close to the
# pilot's (about 250 px/m) where the eye is near, lower on the ceiling.
ATLAS = {"walls": (4096, 2048), "floor": (4096, 2048), "ceiling": (4096, 1024)}

X0, X1 = 0.0, 44.0
WALL_FACE, WALL_BACK = 0.1, -0.1
RAIL_Z = 3.99
EDGE_Z = 4.0  # outer edge of the corridor slabs (Floor and Roof collision z 0..4)
CEILING, ROOF_TOP, SLAB_BOTTOM = 3.0, 3.15, -0.2
END_DEPTH = 0.2  # WestEnd and EastEnd caps
LIN = 0.02  # door lining thickness
ARCH_W, ARCH_T = 0.07, 0.018  # architrave width and depth (room 407's door, build_shell.py)
SKIRTING = (0.1, 0.008)  # height, thickness (room 407)
SILL = 0.012
# Room 407's furnished shell draws the room side of its front wall (x 30..38): the corridor wall there
# stays a thin skin like the pilot's, clear of it. Elsewhere it fills the kit wall (room faces at z -0.1).
THIN_BACK = 0.06
SEAL_Z = 0.08  # the walled-up old 408 doorway: infill face 2 cm behind the corridor face


@dataclass
class Door:
    room: str
    x0: float  # clear opening between the linings
    x1: float
    top: float
    z0: float  # where the linings start (the corridor face is WALL_FACE)
    swing: str  # "out" (RoomDoor, into the corridor), "in" (Door407, into the room) or "sealed"

    @property
    def name(self):
        return "Door" + self.room

    @property
    def hole(self):
        """The hole in the new wall: the opening plus the linings."""
        return self.x0 - LIN, self.x1 + LIN, self.top + LIN

    @property
    def centre(self):
        return (self.x0 + self.x1) / 2

    @property
    def hinge(self):
        return (self.x1 + 0.01, 0.01, 0.0)


def _room_door(room, x):
    return Door(room, x - 0.45, x + 0.43, 2.08, WALL_BACK, "out")


# Every doorway shares room 407's frame (D-142 option A: the 407 Tripo door on every room). Latch west,
# hinges east as on 407; the RoomDoor leaves swing out, so they need stops and show their hinges.
DOORS = [_room_door(str(401 + k), 8.0 + 4.0 * k) for k in range(6)] + [
    Door("407", 31.55, 32.43, 2.08, -0.005, "in"),  # room 407's frame lines z -0.123..-0.005
    Door("408Old", 35.55, 36.43, 2.08, SEAL_Z, "sealed"),
    _room_door("408", 42.0),
]
OUT_DOORS = [d for d in DOORS if d.swing == "out"]
WASHROOM = (2.4, 3.6, 2.3)  # the washroom entrance: x0, x1, top (the kit wall's own opening)
# Room 407's Tripo leaf (door_room.glb, 0.89 x 2.1 x 0.04, origin at its bottom centre) hangs on each RoomDoor
# hinge with its corridor face 5 mm behind the hinge line, so it swings out past the lining.
LEAF = {"offset": (-0.445, 0.0, -0.025), "lever_offset": -0.38, "lever_y": 1.05, "half": 0.02}

# Bays between the room partitions: shell, railing and atlas pieces are cut here (one mesh per bay).
BAYS = [(0.0, 6.0, "Washroom"), (6.0, 10.0, "401"), (10.0, 14.0, "402"), (14.0, 18.0, "403"),
        (18.0, 22.0, "404"), (22.0, 26.0, "405"), (26.0, 30.0, "406"), (30.0, 34.0, "407W"),
        (34.0, 38.0, "407E"), (38.0, 44.0, "408")]
THIN_BAYS = ("407W", "407E")

LIGHTS = [(f"CorridorLight_{401 + k}", 8.0 + 4.0 * k) for k in range(8)] + [("CorridorLight_Desk", 40.0)]
LIGHT_Z = 2.0
# Railing posts every 2 m; the end ones just inside the corridor so they stand clear of the end caps.
POSTS = [0.03] + [2.0 * k for k in range(1, 22)] + [43.97]
BAR_SPACING = 0.125  # A1 (D-144): balusters every 12.5 cm

# RoomPlate_* centres on the wall (T-190 layout): room number -> x.
PLATES = {str(401 + k): 8.0 + 4.0 * k for k in range(7)}
PLATES["408"] = 42.0
PLATE_Y = 2.42


def bay_of(x):
    for b0, b1, name in BAYS:
        if b0 <= x < b1:
            return name
    return BAYS[-1][2]


PX, NX, PY, NY, PZ, NZ = (1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)


@dataclass
class Face:
    """One rectangle of a logical surface: origin + u*a + v*b for a in a0..a1, b in b0..b1. Painted faces
    get their own atlas rectangle; the mask is painted from world positions, so pieces of one surface join."""
    obj: str  # Blender object the face is joined into
    part: str  # GLB file: "shell", "ends"
    group: str  # mask atlas: walls, floor, ceiling
    material: str  # wall, floor, skirting, ceiling
    surface: str  # logical surface (noise seed)
    origin: tuple
    u: tuple
    v: tuple
    a0: float
    b0: float
    a1: float
    b1: float
    painted: bool = True
    rect: tuple = None  # atlas pixels (x, y, w, h), set by pack()

    @property
    def w(self):
        return self.a1 - self.a0

    @property
    def h(self):
        return self.b1 - self.b0

    @property
    def normal(self):
        u, v = self.u, self.v
        return (u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0])

    @property
    def seed(self):
        return 2000 + zlib.crc32(self.surface.encode()) % 7919

    def point(self, a, b):
        return tuple(self.origin[i] + self.u[i] * a + self.v[i] * b for i in range(3))


def _split(a0, a1, cuts):
    """a0..a1 cut at the bay boundaries inside it."""
    edges = [a0] + [c for c in cuts if a0 < c < a1] + [a1]
    return list(zip(edges, edges[1:]))


def wall_rects():
    """Corridor face of the room wall: full-height piers between the openings, lintels over them."""
    openings = [(WASHROOM[0], WASHROOM[1], WASHROOM[2], "washroom")] + [(*d.hole, d.room) for d in DOORS]
    openings.sort()
    rects, cursor = [], X0
    for hx0, hx1, htop, tag in openings:
        rects.append((cursor, 0.0, hx0, CEILING, "pier"))
        rects.append((hx0, htop, hx1, CEILING, "lintel_" + tag))
        cursor = hx1
    rects.append((cursor, 0.0, X1, CEILING, "pier"))
    cuts = [b[0] for b in BAYS[1:]]
    out = []
    for a0, b0, a1, b1, tag in rects:
        for s0, s1 in _split(a0, a1, cuts):
            out.append((s0, b0, s1, b1, tag))
    return out


def skirting_runs():
    """Tile skirting on the corridor face, stopped by the architraves and the washroom entrance."""
    stops = [(WASHROOM[0], WASHROOM[1])] + [(d.hole[0] - ARCH_W, d.hole[1] + ARCH_W) for d in DOORS]
    stops.sort()
    runs, cursor = [], X0
    for s0, s1 in stops:
        runs.append((cursor, s0))
        cursor = s1
    runs.append((cursor, X1))
    cuts = [b[0] for b in BAYS[1:]]
    return [piece for a0, a1 in runs for piece in _split(a0, a1, cuts)]


def faces():
    result = []
    cuts = [b[0] for b in BAYS[1:]]

    def add(obj, part, group, material, surface, origin, u, v, a0, b0, a1, b1, painted=True):
        result.append(Face(obj, part, group, material, surface, origin, u, v, a0, b0, a1, b1, painted))

    # Room wall: corridor face painted; room face plain (the furnished room draws its own in 407's bays).
    for a0, b0, a1, b1, tag in wall_rects():
        bay = bay_of((a0 + a1) / 2)
        obj = "Bay" + bay
        add(obj, "shell", "walls", "wall", "HallWall", (X0, 0.0, WALL_FACE), PX, PY, a0, b0, a1, b1)
        back = THIN_BACK if bay in THIN_BAYS else WALL_BACK
        add(obj, "shell", "walls", "wall", "HallWallBack", (X1, 0.0, back), NX, PY, X1 - a1, b0, X1 - a0, b1, False)
        if tag == "lintel_washroom":  # the head of the washroom entrance
            add(obj, "shell", "walls", "wall", "WashroomHead", (X0, WASHROOM[2], WALL_BACK), PX, PZ,
                a0, 0.0, a1, WALL_FACE - WALL_BACK)
    # The ends of the wall at x 0 and 44 (open to the stairwells when Campus lifts the end caps).
    add("BayWashroom", "shell", "walls", "wall", "WallEndWest", (X0, 0.0, WALL_BACK), PZ, PY, 0.0, 0.0, 0.2, CEILING, False)
    add("Bay408", "shell", "walls", "wall", "WallEndEast", (X1, 0.0, WALL_FACE), NZ, PY, 0.0, 0.0, 0.2, CEILING, False)
    # Washroom entrance jambs: plastered reveals through the wall.
    w0, w1, wtop = WASHROOM
    depth = WALL_FACE - WALL_BACK
    add("BayWashroom", "shell", "walls", "wall", "WashroomJambW", (w0, 0.0, WALL_FACE), NZ, PY, 0.0, 0.0, depth, wtop)
    add("BayWashroom", "shell", "walls", "wall", "WashroomJambE", (w1, 0.0, WALL_BACK), PZ, PY, 0.0, 0.0, depth, wtop)
    # The walled-up old 408 doorway: infill 2 cm behind the corridor face, inside the old linings.
    sealed = next(d for d in DOORS if d.swing == "sealed")
    add("Bay407E", "shell", "walls", "wall", "Infill408", (sealed.x0, 0.0, SEAL_Z), PX, PY, 0.0, SILL,
        sealed.x1 - sealed.x0, sealed.top)
    add("Bay407E", "shell", "walls", "wall", "Infill408Back", (sealed.x1, 0.0, THIN_BACK), NX, PY, 0.0, SILL,
        sealed.x1 - sealed.x0, sealed.top, False)
    # Floor slab: tiled top painted; its outer edge, ends and underside plain plaster like the ceiling's.
    span = EDGE_Z - WALL_FACE
    halves = ((0.0, span / 2), (span / 2, span))  # two floor strips per bay pack its atlas tighter
    for b0, b1, name in BAYS:
        obj = "Bay" + name
        for h0, h1 in halves:
            add(obj, "shell", "floor", "floor", "HallFloor", (X0, 0.0, EDGE_Z), PX, NZ, b0, h0, b1, h1)
        add(obj, "shell", "ceiling", "ceiling", "HallCeiling", (X0, CEILING, WALL_FACE), PX, PZ, b0, 0.0, b1, span)
        add(obj, "shell", "ceiling", "ceiling", "FloorEdge", (X0, SLAB_BOTTOM, EDGE_Z), PX, PY, b0, 0.0, b1, -SLAB_BOTTOM, False)
        add(obj, "shell", "ceiling", "ceiling", "FloorUnder", (X0, SLAB_BOTTOM, 0.0), PX, PZ, b0, 0.0, b1, EDGE_Z, False)
        add(obj, "shell", "ceiling", "ceiling", "RoofEdge", (X0, CEILING, EDGE_Z), PX, PY, b0, 0.0, b1, ROOF_TOP - CEILING, False)
        add(obj, "shell", "ceiling", "ceiling", "RoofTop", (X0, ROOF_TOP, EDGE_Z), PX, NZ, b0, 0.0, b1, EDGE_Z, False)
    for x, normal_u, obj in ((X0, PZ, "BayWashroom"), (X1, NZ, "Bay408")):
        z0 = 0.0 if normal_u == PZ else EDGE_Z
        add(obj, "shell", "ceiling", "ceiling", "SlabEnd", (x, SLAB_BOTTOM, z0), normal_u, PY, 0.0, 0.0, EDGE_Z, -SLAB_BOTTOM, False)
        add(obj, "shell", "ceiling", "ceiling", "RoofEnd", (x, CEILING, z0), normal_u, PY, 0.0, 0.0, EDGE_Z, ROOF_TOP - CEILING, False)
    # Skirting: front painted on the floor atlas, top and ends plain.
    sk_h, sk_t = SKIRTING
    face_z = WALL_FACE + sk_t
    for a0, a1 in skirting_runs():
        obj = "Bay" + bay_of((a0 + a1) / 2)
        add(obj, "shell", "floor", "skirting", "Skirting", (X0, 0.0, face_z), PX, PY, a0, 0.0, a1, sk_h)
        add(obj, "shell", "floor", "skirting", "SkirtingTop", (X0, sk_h, face_z), PX, NZ, a0, 0.0, a1, sk_t, False)
        for x, u in ((a0, PZ), (a1, NZ)):
            if x in cuts:
                continue
            z0 = WALL_FACE if u == PZ else face_z
            add(obj, "shell", "floor", "skirting", "SkirtingEnd", (x, 0.0, z0), u, PY, 0.0, 0.0, sk_t, sk_h, False)
    # End walls on the caps (standalone Floor4; Campus hides them with the caps): plaster and skirting.
    for name, x, u, sign in (("EndWest", X0, NZ, 1), ("EndEast", X1, PZ, -1)):
        z_start = EDGE_Z if u == NZ else WALL_FACE
        span = EDGE_Z - WALL_FACE
        add(name, "ends", "walls", "wall", name, (x, 0.0, z_start), u, PY, 0.0, 0.0, span, CEILING)
        back_u = PZ if u == NZ else NZ
        add(name, "ends", "walls", "wall", name + "Back", (x - sign * END_DEPTH, 0.0, EDGE_Z if back_u == NZ else WALL_FACE),
            back_u, PY, 0.0, 0.0, span, CEILING, False)
        # The cap's edge on the open side, seen from the yard.
        x_out = x - END_DEPTH if sign > 0 else x
        add(name, "ends", "walls", "wall", name + "Edge", (x_out, 0.0, EDGE_Z), PX, PY, 0.0, 0.0, END_DEPTH, CEILING, False)
        sx = x + sign * sk_t
        sk_z0, sk_z1 = face_z, RAIL_Z - 0.06
        if u == NZ:
            add(name, "ends", "floor", "skirting", name + "Skirting", (sx, 0.0, sk_z1), NZ, PY, 0.0, 0.0, sk_z1 - sk_z0, sk_h)
        else:
            add(name, "ends", "floor", "skirting", name + "Skirting", (sx, 0.0, sk_z0), PZ, PY, 0.0, 0.0, sk_z1 - sk_z0, sk_h)
        x_lo = min(x, sx)
        add(name, "ends", "floor", "skirting", name + "SkirtingTop", (x_lo, sk_h, sk_z1), PX, NZ, 0.0, 0.0, sk_t,
            sk_z1 - sk_z0, False)
        add(name, "ends", "floor", "skirting", name + "SkirtingEnd", (x_lo, 0.0, sk_z1), PX, PY, 0.0, 0.0, sk_t, sk_h, False)
    return result


def pack(group_faces, size, pad=PAD):
    """Shelf-pack the painted rectangles at the highest uniform texel density that fits; returns px/m."""
    def attempt(scale):
        x = NEUTRAL[2] + pad
        y = shelf = 0
        placed = []
        for f in sorted(group_faces, key=lambda f: (-f.h, -f.w)):
            w = int(f.w * scale + 0.999) + 2 * pad
            h = int(f.h * scale + 0.999) + 2 * pad
            if x + w > size[0]:
                x, y, shelf = 0, y + shelf, 0
            if y + h > size[1] or w > size[0]:
                return None
            placed.append((f, (x + pad, y + pad, w - 2 * pad, h - 2 * pad)))
            x += w
            shelf = max(shelf, h)
        return placed

    lo, hi = 10.0, 2000.0
    for _ in range(40):
        mid = (lo + hi) / 2
        if attempt(mid):
            lo = mid
        else:
            hi = mid
    scale = int(lo)
    for f, rect in attempt(scale):
        f.rect = rect
    return scale


GROUPS = ("walls", "floor", "ceiling")


def layout():
    all_faces = faces()
    scales = {g: pack([f for f in all_faces if f.group == g and f.painted], ATLAS[g]) for g in GROUPS}
    return all_faces, scales


if __name__ == "__main__":
    shells, scales = layout()
    for g in GROUPS:
        painted = [f for f in shells if f.group == g and f.painted]
        area = sum(f.w * f.h for f in painted)
        print(f"{g:8s} {len(painted):3d} painted faces, {area:7.1f} m2, {scales[g]} px/m in {ATLAS[g]}")
    print("faces", len(shells), "objects", len({f.obj for f in shells}))
    for f in shells:
        n = f.normal
        if abs(sum(c * c for c in n) - 1) > 1e-6:
            print("BAD NORMAL", f)
