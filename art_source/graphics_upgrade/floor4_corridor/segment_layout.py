"""T-233: the floor-4 corridor pilot segment around doors 406 and 407, in Floor4 metres (Godot axes).
Shared by build_segment.py (Blender) and make_segment_masks.py (numpy). Plain Python: no bpy, no numpy.

Measured from the playable scene (PLAN.md section 1, a headless probe of floor4.tscn on 07/11/2026):
  corridor floor top y 0, ceiling y 3, the room wall is 0.2 thick (z -0.1..0.1, corridor face z 0.1),
  the open side's railing at z 3.99 (top rail y 1.04..1.10, low rail y 0.15..0.21, invisible barrier z 4.0..4.1).
  Door 406: kit piers x 27.0..27.55 and 28.45..29.0, lintel from y 2.1; RoomDoor hinge (28.44, 0.01, 0),
  opens +90 degrees into the corridor. Door 407: piers x 31.0..31.55 and 32.45..33.0; Door407 pivot
  (32.44, 0.01, 0) opens -90 degrees into the room; room 407's own frame lines the room half of the
  opening (x 31.5..32.45, z -0.123..-0.005) and its Tripo leaf fills x 31.55..32.44.
  Corridor lights 406 and 407 at (28, 2.8, 2) and (32, 2.8, 2).
Nothing here has collision: the playable colliders stay as they are and every new face lies on or
inside them (the door linings fill the 2 cm of the kit piers next to the openings).
"""
from dataclasses import dataclass, field

ATLAS = (2048, 1024)  # width, height: an 8 m strip packs best in a wide atlas
PAD = 10  # bleed pixels round every atlas rectangle
NEUTRAL = (0, 0, 8, 8)

X0, X1 = 26.0, 34.0  # the segment: room 406 (x 26..30) and the first 4 m of room 407
WALL_FACE = 0.1  # corridor face of the room wall
WALL_BACK = -0.1
RAIL_Z = 3.99
EDGE_Z = 4.0  # end of the corridor slab (Floor collision z 0..4)
CEILING = 3.0
LIN = 0.02  # door lining thickness
ARCH_W, ARCH_T = 0.07, 0.018  # architrave width and depth (room 407's door, build_shell.py)
SKIRTING = (0.1, 0.008)  # height, thickness (room 407)
SILL = 0.012


@dataclass
class Door:
    name: str
    x0: float  # clear opening between the linings
    x1: float
    top: float
    z0: float  # lining depth (corridor face is WALL_FACE)
    hinge: tuple  # world hinge point of the playable door node
    swing: str  # "out" (into the corridor) or "in" (into the room)

    @property
    def hole(self):
        """The hole in the new wall: the opening plus the linings."""
        return self.x0 - LIN, self.x1 + LIN, self.top + LIN


# Both doors share room 407's frame (D-142, option A: the 407 Tripo door on every room). The latch side
# is west and the hinges east, as on 407; 406's leaf swings out, 407's in, so only 406 needs stops here.
DOORS = [
    Door("Door406", 27.55, 28.43, 2.08, WALL_BACK, (28.44, 0.01, 0.0), "out"),
    # Room 407's frame (room407.gd shifts it 0.105 m in) lines z -0.123..-0.005: this one starts there.
    Door("Door407", 31.55, 32.43, 2.08, -0.005, (32.44, 0.01, 0.0), "in"),
]
# 406's Tripo leaf (door_room.glb, 0.89 x 2.1 x 0.04, origin at its bottom centre) hangs on its hinge
# with its corridor face 5 mm behind the hinge line, so it can swing out past the lining.
LEAF_406 = {"centre": (28.44 - 0.445, 0.0, -0.025), "lever_offset": -0.38, "lever_y": 1.05, "half": 0.02}

LIGHTS = [(28.0, 2.0), (32.0, 2.0)]  # tube battens under the corridor lights (x, z); the lights stay at y 2.8
POSTS = [26.0, 28.0, 30.0, 32.0, 34.0]  # railing posts every 2 m
BAR_SPACING = {"dense": 0.125, "classic": 0.5}  # balusters; "classic" keeps the PS1 rhythm


@dataclass
class Surface:
    name: str
    group: str
    material: str
    origin: tuple
    u: tuple
    v: tuple
    w: float
    h: float
    pieces: list = field(default_factory=list)  # (object name, u0, v0, u1, v1)
    rect: tuple = None  # atlas pixels (x, y, w, h), set by pack()

    def __post_init__(self):
        if not self.pieces:
            self.pieces = [(self.name, 0.0, 0.0, self.w, self.h)]

    @property
    def normal(self):
        u, v = self.u, self.v
        return (u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0])

    def point(self, a, b):
        return tuple(self.origin[i] + self.u[i] * a + self.v[i] * b for i in range(3))


PX, NX, PY, NY, PZ, NZ = (1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)


def surfaces():
    h6, h7 = DOORS[0].hole, DOORS[1].hole
    wall_pieces = [
        ("WallWest", 0.0, 0.0, h6[0] - X0, CEILING),
        ("Lintel406", h6[0] - X0, h6[2], h6[1] - X0, CEILING),
        ("WallMiddle", h6[1] - X0, 0.0, h7[0] - X0, CEILING),
        ("Lintel407", h7[0] - X0, h7[2], h7[1] - X0, CEILING),
        ("WallEast", h7[1] - X0, 0.0, X1 - X0, CEILING),
    ]
    result = [
        Surface("HallWall", "walls", "wall", (X0, 0.0, WALL_FACE), PX, PY, X1 - X0, CEILING, wall_pieces),
        # Floor from the slab edge to the wall (normal up), ceiling from the wall to the edge (normal down).
        Surface("HallFloor", "floor", "floor", (X0, 0.0, EDGE_Z), PX, NZ, X1 - X0, EDGE_Z - WALL_FACE),
        Surface("HallCeiling", "ceiling", "ceiling", (X0, CEILING, WALL_FACE), PX, PZ, X1 - X0, EDGE_Z - WALL_FACE),
    ]
    # Tile skirting on the corridor face, stopped by the architraves.
    runs = [(X0, h6[0] - ARCH_W), (h6[1] + ARCH_W, h7[0] - ARCH_W), (h7[1] + ARCH_W, X1)]
    for k, (a, b) in enumerate(runs):
        result.append(Surface(f"Skirting{k}", "floor", "skirting", (a, 0.0, WALL_FACE + SKIRTING[1]), PX, PY,
                              b - a, SKIRTING[0]))
    return result


def pack(group_surfaces, size=ATLAS, pad=PAD):
    """Shelf-pack the rectangles at the highest uniform texel density that fits; returns px/m."""
    def attempt(scale):
        x = NEUTRAL[2] + pad
        y = shelf = 0
        placed = []
        for s in sorted(group_surfaces, key=lambda s: -s.h):
            w = int(s.w * scale + 0.999) + 2 * pad
            h = int(s.h * scale + 0.999) + 2 * pad
            if x + w > size[0]:
                x, y, shelf = 0, y + shelf, 0
            if y + h > size[1] or w > size[0]:
                return None
            placed.append((s, (x + pad, y + pad, w - 2 * pad, h - 2 * pad)))
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
    for s, rect in attempt(scale):
        s.rect = rect
    return scale


GROUPS = ("walls", "floor", "ceiling")


def layout():
    all_surfaces = surfaces()
    return all_surfaces, {g: pack([s for s in all_surfaces if s.group == g]) for g in GROUPS}


if __name__ == "__main__":
    shells, scales = layout()
    for s in shells:
        print(f"{s.group:8s} {s.name:12s} {s.w:6.3f} x {s.h:5.3f}  n={s.normal}  rect={s.rect}")
    print("px/m", scales)
