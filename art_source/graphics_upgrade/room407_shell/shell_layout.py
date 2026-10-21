"""Room 407 shell surfaces (T-222) in room-local Godot metres, shared by build_shell.py (Blender)
and make_shell_masks.py (numpy). Plain Python: no bpy, no numpy.

A surface is a flat rectangle seen from the side of its normal (u x v). Its pieces become Blender
objects (an opening is the gap between pieces). Each group bakes one RGBA mask atlas; every surface
owns a rectangle of it at the group's texel density, so UV2 = atlas position and the mask can hold
stains, peeling paint and dirt that belong to that exact spot of the room.

Measurements: the corner shell (../room407_corner/build_corner.py): floor y=0, ceiling y=3,
west wall face x=0.1, east 7.9, back -6.925, door wall z=0 (the game moves it 0.105 into the
room, room407.gd DOOR_WALL_SHIFT), bathroom x 5.375..7.9 z -4.075..-6.925 behind a 0.15 m wall.
Openings: room door x 1.5..2.45 y 0..2.1, bathroom door x 5.35..6.35 y 0..2.2, balcony door
x 2.3..3.3 y 0..2.3. Balcony (ch1v2/extension.tscn collision): floor x 0..5.2 z -7..-8.5,
dividers 0.12 thick at x 0 and 5.2 up to y 2, parapet z -8.45..-8.55 up to y 1.1.
"""
from dataclasses import dataclass, field

ATLAS = 2048
PAD = 10  # pixels of bleed around every rectangle (linear filtering, no mipmaps)
NEUTRAL = (0, 0, 8, 8)  # atlas pixels kept at the group's neutral mask, for faces without a rectangle

X0, X1, Z_BACK, Z_FRONT, CEILING = 0.1, 7.9, -6.925, 0.0, 3.0
BATH = {"x0": 5.375, "x1": 7.9, "z0": -4.075, "z1": -6.925, "wall_room_x": 5.225, "wall_room_z": -3.925}
ROOM_DOOR = (1.5, 2.45, 2.1)
BATH_DOOR = (5.35, 6.35, 2.2)
BALCONY_DOOR = (2.3, 3.3, 2.3)
WALL_BACK_OUT = -7.075
BALCONY = {"x0": 0.06, "x1": 5.14, "z0": WALL_BACK_OUT, "z1": -8.45, "divider_top": 2.0, "parapet_top": 1.1}
SKIRTING = (0.1, 0.008)  # height, thickness
ARCHITRAVE = {"room": 0.07, "bath": 0.06}


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
    # (object name, u0, v0, u1, v1); default: one piece over the whole rectangle named after the surface
    pieces: list = field(default_factory=list)
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


def _wall(name, origin, u, w, h=CEILING, pieces=None, material="wall", group="walls"):
    return Surface(name, group, material, origin, u, PY, w, h, pieces or [])


def _skirting(name, origin, u, length):
    # A strip standing SKIRTING[1] proud of the wall face; the origin is on the wall face.
    out = (-u[2], 0, u[0])  # u x (0, 1, 0): the wall normal of an upright surface
    o = tuple(origin[i] + out[i] * SKIRTING[1] for i in range(3))
    return Surface(name, "floor", "skirting", o, u, PY, length, SKIRTING[0])


def surfaces():
    bx, bz = BATH["wall_room_x"], BATH["wall_room_z"]
    rd, bd, bal = ROOM_DOOR, BATH_DOOR, BALCONY_DOOR
    back_w = bx - X0
    front_w = X1 - X0
    result = [
        # Room walls, seen from inside the room.
        _wall("WestWall", (X0, 0, Z_FRONT), NZ, Z_FRONT - Z_BACK),
        _wall("BackWall", (X0, 0, Z_BACK), PX, back_w, pieces=[
            ("BackWest", 0, 0, bal[0] - X0, CEILING),
            ("BalconyLintel", bal[0] - X0, bal[2], bal[1] - X0, CEILING),
            ("BackEast", bal[1] - X0, 0, back_w, CEILING)]),
        _wall("BathroomSide", (bx, 0, Z_BACK), PZ, bz - Z_BACK),
        _wall("BathFront", (bx, 0, bz), PX, X1 - bx, pieces=[
            ("BathFrontW", 0, 0, bd[0] - bx, CEILING),
            ("BathLintel", bd[0] - bx, bd[2], bd[1] - bx, CEILING),
            ("BathFrontE", bd[1] - bx, 0, X1 - bx, CEILING)]),
        _wall("EastWall", (X1, 0, bz), PZ, Z_FRONT - bz),
        _wall("FrontWall", (X1, 0, Z_FRONT), NX, front_w, pieces=[
            ("FrontWallEast", 0, 0, X1 - rd[1], CEILING),
            ("DoorLintel", X1 - rd[1], rd[2], X1 - rd[0], CEILING),
            ("FrontWallWest", X1 - rd[0], 0, front_w, CEILING)]),
        # Bathroom walls (the tiles of bath_tiles.glb cover them up to 1.8 m).
        _wall("BathWallWest", (BATH["x0"], 0, BATH["z0"]), NZ, BATH["z0"] - BATH["z1"]),
        _wall("BathWallBack", (BATH["x0"], 0, BATH["z1"]), PX, BATH["x1"] - BATH["x0"]),
        _wall("BathWallEast", (BATH["x1"], 0, BATH["z1"]), PZ, BATH["z0"] - BATH["z1"]),
        _wall("BathWallFront", (BATH["x1"], 0, BATH["z0"]), NX, BATH["x1"] - BATH["x0"], pieces=[
            ("BathFrontInnerE", 0, 0, BATH["x1"] - bd[1], CEILING),
            ("BathLintelInner", BATH["x1"] - bd[1], bd[2], BATH["x1"] - BATH["x0"], CEILING)]),
        # Plastered reveals of the balcony opening (the aluminium frame sits in the middle).
        _wall("BalconyRevealW", (bal[0], 0, Z_BACK), NZ, Z_BACK - WALL_BACK_OUT, bal[2]),
        _wall("BalconyRevealE", (bal[1], 0, WALL_BACK_OUT), PZ, Z_BACK - WALL_BACK_OUT, bal[2]),
        Surface("BalconyRevealTop", "walls", "wall", (bal[0], bal[2], WALL_BACK_OUT), PX, PZ,
                bal[1] - bal[0], Z_BACK - WALL_BACK_OUT),
        # Floors.
        Surface("Floor", "floor", "floor", (X0, 0, Z_FRONT), PX, NZ, front_w, Z_FRONT - Z_BACK, pieces=[
            ("Floor", 0, 0, front_w, Z_FRONT - bz),
            ("FloorBack", 0, Z_FRONT - bz, back_w, Z_FRONT - Z_BACK)]),
        Surface("BathFloor", "floor", "bathfloor", (BATH["x0"], 0, BATH["z0"]), PX, NZ,
                BATH["x1"] - BATH["x0"], BATH["z0"] - BATH["z1"]),
        # Ceiling (one slab over room and bathroom).
        Surface("Ceiling", "ceiling", "ceiling", (X0, CEILING, Z_BACK), PX, PZ, front_w, Z_FRONT - Z_BACK),
        # Balcony: exterior face of the back wall, floor, divider faces, parapet, soffit.
        _wall("ExtBack", (BALCONY["x1"] + 0.06, 0, WALL_BACK_OUT), NX, BALCONY["x1"] + 0.12, group="balcony",
              material="exterior", pieces=[
                  ("ExtBackEast", 0, 0, BALCONY["x1"] + 0.06 - bal[1], CEILING),
                  ("ExtLintel", BALCONY["x1"] + 0.06 - bal[1], bal[2], BALCONY["x1"] + 0.06 - bal[0], CEILING),
                  ("ExtBackWest", BALCONY["x1"] + 0.06 - bal[0], 0, BALCONY["x1"] + 0.12, CEILING)]),
        Surface("BalconyFloor", "balcony", "balconyfloor", (BALCONY["x0"], 0, BALCONY["z0"]), PX, NZ,
                BALCONY["x1"] - BALCONY["x0"], BALCONY["z0"] - BALCONY["z1"]),
        _wall("DividerWest", (BALCONY["x0"], 0, BALCONY["z0"]), NZ, BALCONY["z0"] - BALCONY["z1"],
              BALCONY["divider_top"], group="balcony", material="exterior"),
        _wall("DividerEast", (BALCONY["x1"], 0, BALCONY["z1"]), PZ, BALCONY["z0"] - BALCONY["z1"],
              BALCONY["divider_top"], group="balcony", material="exterior"),
        _wall("ParapetInner", (BALCONY["x0"], 0, BALCONY["z1"]), PX, BALCONY["x1"] - BALCONY["x0"],
              BALCONY["parapet_top"] - 0.05, group="balcony", material="exterior"),
        Surface("BalconySoffit", "balcony", "exterior", (-0.06, CEILING, -8.6), PX, PZ, 5.32, WALL_BACK_OUT + 8.6),
    ]
    # Tile skirting on the room walls (not the bathroom: tiled to 1.8 m). It stops at the door
    # architraves; the balcony frame sits inside its opening.
    ar, ab = ARCHITRAVE["room"], ARCHITRAVE["bath"]
    result += [
        _skirting("SkirtingWest", (X0, 0, Z_FRONT), NZ, Z_FRONT - Z_BACK),
        _skirting("SkirtingBackWest", (X0, 0, Z_BACK), PX, bal[0] - X0),
        _skirting("SkirtingBackEast", (bal[1], 0, Z_BACK), PX, bx - bal[1]),
        _skirting("SkirtingBathSide", (bx, 0, Z_BACK), PZ, bz - Z_BACK),
        _skirting("SkirtingBathFront", (bd[1] + ab, 0, bz), PX, X1 - bd[1] - ab),
        _skirting("SkirtingEast", (X1, 0, bz), PZ, Z_FRONT - bz),
        _skirting("FrontSkirtingEast", (X1, 0, Z_FRONT), NX, X1 - rd[1] - ar),
        _skirting("FrontSkirtingWest", (rd[0] - ar, 0, Z_FRONT), NX, rd[0] - ar - X0),
    ]
    return result


def pack(group_surfaces, size=ATLAS, pad=PAD):
    """Shelf-pack the rectangles at the highest uniform texel density that fits; returns px/m."""
    def attempt(scale):
        x = y = shelf = 0
        x = NEUTRAL[2] + pad  # keep the neutral corner free
        placed = []
        for s in sorted(group_surfaces, key=lambda s: -s.h):
            w = int(s.w * scale + 0.999) + 2 * pad
            h = int(s.h * scale + 0.999) + 2 * pad
            if x + w > size:
                x, y, shelf = 0, y + shelf, 0
            if y + h > size or w > size:
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


def layout():
    """All surfaces with atlas rectangles; {group: px_per_metre}."""
    all_surfaces = surfaces()
    scales = {}
    for group in ("walls", "floor", "ceiling", "balcony"):
        scales[group] = pack([s for s in all_surfaces if s.group == group])
    return all_surfaces, scales


if __name__ == "__main__":
    shells, scales = layout()
    for s in shells:
        print(f"{s.group:8s} {s.name:18s} {s.w:6.3f} x {s.h:5.3f}  n={s.normal}  rect={s.rect}")
    print("px/m", scales)
