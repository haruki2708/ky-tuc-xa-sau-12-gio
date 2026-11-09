"""T-239: finger shapes and hand placements for the grips that were wrong in the 09/11 playtest.

For each grip the thing held is placed in the hand (a short search) and every finger, the thumb too,
is posed by a search over its joints against the skinned Tripo hand (t239_hands.py): nothing may go
into the thing, the pads must touch it where a real hand does. The results are printed as GDScript
constants for game/scripts/player/hand_shapes.gd and drawn to build/t239/grip_*.png.
  python -B art_source/graphics_upgrade/protagonist/t239_grips.py [phone|read|pick|all]
Units: skeleton units in the hand bone's frame (world metres = SCALE x skeleton units).
"""
import math
import sys
from pathlib import Path

import numpy as np

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from t239_hands import FINGERS, SCALE, TIPS, Hand, as_matrix, axis_angle, box_distance, to_quaternion  # noqa: E402

OUT = Path(__file__).resolve().parents[3] / "build" / "t239"
INTO = 0.0004  # a vertex this far inside a surface counts as going through it
TAB, NL = chr(9), chr(10)
MM = 1000.0 * SCALE  # skeleton units to world millimetres


class Box:
    """A box in hand space: centre, axes (columns), half size (skeleton units)."""

    def __init__(self, centre, axes, half):
        self.centre = np.asarray(centre, float)
        self.axes = np.asarray(axes, float)
        self.half = np.asarray(half, float)

    def distance(self, points):
        return box_distance(points, self.centre, self.axes, self.half)

    def local(self, points):
        return (points - self.centre) @ self.axes

    def matrix(self):
        m = np.eye(4)
        m[:3, :3] = self.axes
        m[:3, 3] = self.centre
        return m


def finger_shape(finger, mcp, pip, dip, spread=0.0):
    return {finger + "Proximal": (mcp, 0.0, spread), finger + "Intermediate": (pip, 0.0, 0.0), finger + "Distal": (dip, 0.0, 0.0)}


def search_finger(hand, finger, boxes, score, ok=None, mcp=range(0, 61, 5), pip=range(0, 106, 5),
                  dip_ratio=(0.5, 0.7, 0.9), spread=(0.0,)):
    """Best (score) pose of one finger whose vertices stay out of every box (and pass `ok`)."""
    mask = hand.owner == finger
    best = None
    for a in mcp:
        for b in pip:
            for r in dip_ratio:
                for s in spread:
                    shape = finger_shape(finger, float(a), float(b), round(r * b, 1), s)
                    points = hand.skin(hand.pose(shape), mask)
                    if any(box.distance(points)[0].min() < -INTO for box in boxes):
                        continue
                    if ok is not None and not ok(points):
                        continue
                    value = score(points, shape)
                    if best is None or value > best[0]:
                        best = (value, shape)
    return best


def search_thumb(hand, boxes, score, ok=None, meta_x=range(-30, 31, 10), meta_y=range(-40, 41, 10),
                 meta_z=range(-60, 61, 10), flex=range(0, 61, 10)):
    """Best pose of the thumb: the metacarpal turned (x, y, z degrees), the two joints flexed."""
    mask = hand.owner == "Thumb"
    best = None
    sign = 1.0 if hand.side == "Left" else -1.0  # local z flexes the left thumb toward the palm with +, the right with -
    for x in meta_x:
        for y in meta_y:
            for z in meta_z:
                for f in flex:
                    shape = {"ThumbMetacarpal": (float(x), float(y), float(z)), "ThumbProximal": (0.0, 0.0, sign * f),
                             "ThumbDistal": (0.0, 0.0, sign * f * 0.8)}
                    points = hand.skin(hand.pose(shape), mask)
                    if any(box.distance(points)[0].min() < -INTO for box in boxes):
                        continue
                    if ok is not None and not ok(points):
                        continue
                    value = score(points, shape)
                    if best is None or value > best[0]:
                        best = (value, shape)
    return best


THUMB = ["ThumbMetacarpal", "ThumbProximal", "ThumbDistal"]


def _rotation_between(a, b):
    """4x4 rotation taking direction a to direction b (the shortest turn)."""
    a = a / np.linalg.norm(a)
    b = b / np.linalg.norm(b)
    axis = np.cross(a, b)
    s = np.linalg.norm(axis)
    if s < 1e-9:
        return np.eye(4)
    return axis_angle(axis, math.degrees(math.atan2(s, float(a @ b))))


def thumb_reach(hand, shape, joint, effector, target, iterations=30, max_swing=85.0, flex=(-5.0, 80.0), use=(0, 1, 2)):
    """Cyclic coordinate descent on the thumb: bring the `effector` bone's origin (hand space) to
    `target` by turning the joints listed in `use` (0 metacarpal: any turn within max_swing of its rest
    direction; 1, 2: bend about their own z toward the palm, within flex degrees)."""
    side = hand.side
    sign = 1.0 if side == "Left" else -1.0
    shape = dict(shape)
    for name in THUMB:
        shape[name] = as_matrix(shape.get(name, (0.0, 0.0, 0.0)))
    rest = hand.pose({})
    rest_dir = rest[side + "ThumbProximal"][:3, 3] - rest[side + "ThumbMetacarpal"][:3, 3]
    for _ in range(iterations):
        for j in sorted(use, reverse=True):
            name = THUMB[j]
            posed = hand.pose(shape)
            g = posed[side + name]
            origin = g[:3, 3]
            a = posed[side + effector][:3, 3] - origin
            b = target - origin
            if j > 0:
                axis = g[:3, 2] / np.linalg.norm(g[:3, 2])
                a_p, b_p = a - axis * (a @ axis), b - axis * (b @ axis)
                if np.linalg.norm(a_p) < 1e-6 or np.linalg.norm(b_p) < 1e-6:
                    continue
                turn = math.degrees(math.atan2(float(axis @ np.cross(a_p, b_p)), float(a_p @ b_p)))
                current = math.degrees(math.atan2(shape[name][1, 0], shape[name][0, 0]))
                bent = sign * (current + turn)
                bent = min(max(bent, flex[0]), flex[1])
                shape[name] = axis_angle((0.0, 0.0, 1.0), sign * bent)
            else:
                q = _rotation_between(a, b)
                q[:3, :3] = np.eye(3) * 0.5 + q[:3, :3] * 0.5  # damped
                u, _, vt = np.linalg.svd(q[:3, :3])
                q[:3, :3] = u @ vt
                m = g[:3, :3] @ np.linalg.inv(shape[name][:3, :3])
                new = np.eye(4)
                new[:3, :3] = np.linalg.inv(m) @ q[:3, :3] @ g[:3, :3]
                trial = dict(shape)
                trial[name] = new
                moved = hand.pose(trial)
                direction = moved[side + "ThumbProximal"][:3, 3] - moved[side + "ThumbMetacarpal"][:3, 3]
                swing = math.degrees(math.acos(np.clip(direction @ rest_dir / np.linalg.norm(direction) / np.linalg.norm(rest_dir), -1, 1)))
                if swing <= max_swing:
                    shape[name] = new
    return shape


def thumb_twist(hand, shape, degrees):
    """The metacarpal turned about the thumb's own line (where its pad faces)."""
    side = hand.side
    shape = dict(shape)
    posed = hand.pose(shape)
    g = posed[side + "ThumbMetacarpal"]
    line = posed[side + "ThumbProximal"][:3, 3] - g[:3, 3]
    q = axis_angle(line, degrees)
    m = g[:3, :3] @ np.linalg.inv(as_matrix(shape.get("ThumbMetacarpal", (0.0, 0.0, 0.0)))[:3, :3])
    new = np.eye(4)
    new[:3, :3] = np.linalg.inv(m) @ q[:3, :3] @ g[:3, :3]
    shape["ThumbMetacarpal"] = new
    return shape


def place_thumb(hand, shape, joint_target, tip_target, boxes, twists=range(-90, 91, 15)):
    """The thumb with its IP joint (ThumbDistal) at joint_target and its tip at tip_target, turned so it
    stays out of the boxes and touches them most: tries twists of the metacarpal, keeps the best."""
    best = None
    mask = hand.owner == "Thumb"
    for twist in twists:
        trial = thumb_twist(hand, shape, float(twist))
        trial = thumb_reach(hand, trial, None, "ThumbDistal", joint_target, use=(0, 1))
        trial = thumb_reach(hand, trial, None, "HandThumb4", tip_target, use=(2,))
        points = hand.skin(hand.pose(trial), mask)
        d = min(b.distance(points)[0].min() for b in boxes)
        posed = hand.pose(trial)
        miss = np.linalg.norm(posed[hand.side + "HandThumb4"][:3, 3] - tip_target) + np.linalg.norm(posed[hand.side + "ThumbDistal"][:3, 3] - joint_target)
        near = sum(int((b.distance(points)[0] < 0.0015).sum()) for b in boxes)
        value = -max(0.0, -d - INTO) * 5000.0 - miss * 300.0 + near * 0.02
        if best is None or value > best[0]:
            best = (value, trial, d, miss)
    return best


def thumb_shape(hand, params):
    """Thumb joints from (ax, ay, az, f1, f2): the metacarpal turned by the rotation vector (ax, ay, az)
    degrees in its own frame, the two joints bent f1, f2 degrees toward the palm."""
    sign = 1.0 if hand.side == "Left" else -1.0
    ax, ay, az, f1, f2 = params
    vector = np.array([ax, ay, az], float)
    angle = float(np.linalg.norm(vector))
    meta = axis_angle(vector / angle, angle) if angle > 1e-6 else np.eye(4)
    return {"ThumbMetacarpal": meta, "ThumbProximal": axis_angle((0.0, 0.0, 1.0), sign * f1),
            "ThumbDistal": axis_angle((0.0, 0.0, 1.0), sign * f2)}


def fit_thumb(hand, shape, objective, seeds=((0, 0, 0, 10, 10),), limits=((-90, 90),) * 3 + ((-10, 80), (-10, 80))):
    """Coordinate descent on the thumb's five numbers, from each seed; the lowest objective(points,
    posed) wins. Returns (value, shape with the thumb, params)."""
    mask = hand.owner == "Thumb"

    def cost(params):
        trial = dict(shape)
        trial.update(thumb_shape(hand, params))
        posed = hand.pose(trial)
        return objective(hand.skin(posed, mask), posed)

    best = None
    for seed in seeds:
        params = list(map(float, seed))
        value = cost(params)
        step = 16.0
        while step >= 0.5:
            improved = False
            for i in range(5):
                for direction in (1.0, -1.0):
                    trial = list(params)
                    trial[i] = min(max(trial[i] + direction * step, limits[i][0]), limits[i][1])
                    v = cost(trial)
                    if v < value - 1e-9:
                        params, value, improved = trial, v, True
            if not improved:
                step *= 0.5
        if best is None or value < best[0]:
            best = (value, params)
    out = dict(shape)
    out.update(thumb_shape(hand, best[1]))
    return best[0], out, best[1]


def report(hand, shape, boxes, label):
    verts = hand.skin(hand.pose(shape))
    lines = [label]
    for f in FINGERS + ["Palm"]:
        mask = hand.owner == f
        d = min(b.distance(verts[mask])[0].min() for b in boxes)
        lines.append("  %-6s nearest surface %+.1f mm" % (f, d * MM))
    return "\n".join(lines)


def gd_shape(name, shape):
    rows = ", ".join('"%s": Vector3(%.1f, %.1f, %.1f)' % (k, *v) for k, v in sorted(shape.items()))
    return "const %s := {%s}" % (name, rows)


def gd_transform(name, m):
    x, y, z, o = m[:3, 0], m[:3, 1], m[:3, 2], m[:3, 3]
    return ("const %s := Transform3D(Vector3(%.4f, %.4f, %.4f), Vector3(%.4f, %.4f, %.4f), "
            "Vector3(%.4f, %.4f, %.4f), Vector3(%.4f, %.4f, %.4f))") % (name, *x, *y, *z, *o)


def draw(hand, shape, boxes, path, title):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    colors = {"Palm": "gray", "Thumb": "red", "Index": "orange", "Middle": "green", "Ring": "blue", "Little": "purple"}
    verts = hand.skin(hand.pose(shape))
    fig, axs = plt.subplots(1, 3, figsize=(16, 5.5))
    views = [((0, 1), "hand x-y (look at the palm)"), ((1, 2), "hand y-z (side)"), ((0, 2), "hand x-z (along the fingers)")]
    edges = [(0, 1), (0, 2), (0, 4), (1, 3), (1, 5), (2, 3), (2, 6), (3, 7), (4, 5), (4, 6), (5, 7), (6, 7)]
    for ax, ((a, b), name) in zip(axs, views):
        for box in boxes:
            corners = np.array([box.centre + box.axes @ (box.half * np.array([sx, sy, sz]))
                                for sx in (-1, 1) for sy in (-1, 1) for sz in (-1, 1)])
            for i, j in edges:
                ax.plot([corners[i, a], corners[j, a]], [corners[i, b], corners[j, b]], "k-", lw=0.8)
        for owner, color in colors.items():
            mask = hand.owner == owner
            ax.scatter(verts[mask, a], verts[mask, b], s=3, c=color)
        ax.set_aspect("equal")
        ax.grid(True)
        ax.set_title(name)
    fig.suptitle(title)
    plt.tight_layout()
    plt.savefig(path, dpi=72)
    plt.close(fig)


# ---------------------------------------------------------------- phone (left hand)

PHONE_HALF = np.array([0.038, 0.0725, 0.0045]) / SCALE  # the Tripo phone (world metres) in skeleton units
SCREEN_HALF = np.array([0.032, 0.065]) / SCALE


def phone_box(phi_deg, centre):
    """The phone in left-hand space: its back on the palm, screen (+Z) along the palm normal; the
    fingers run across its back toward the far edge (+X of the phone), turned phi up its length."""
    phi = math.radians(phi_deg)
    xp = np.array([math.sin(phi), math.cos(phi), 0.0])
    yp = np.array([-math.cos(phi), math.sin(phi), 0.0])
    return Box(centre, np.stack([xp, yp, [0.0, 0.0, 1.0]], axis=1), PHONE_HALF)


def over_screen(box, points):
    local = box.local(points)
    return ((np.abs(local[:, 0]) < SCREEN_HALF[0]) & (np.abs(local[:, 1]) < SCREEN_HALF[1]) & (local[:, 2] > 0.0)).any()


def phone_fingers(hand, box, coarse=False):
    """The four fingers round the far edge: pads on its side face (within its thickness), the rest
    along its back, nothing over the screen."""
    shape = {}
    total = 0.0
    hx, hz = PHONE_HALF[0], PHONE_HALF[2]

    def score(points, s):
        local = box.local(points)
        d, _ = box.distance(points)
        beside = (local[:, 0] > hx - 0.0005) & (local[:, 0] < hx + 0.016) & (local[:, 2] > -hz - 0.002) & (local[:, 2] < hz + 0.004)
        wrap = 0.0
        side_gap = 0.02
        if beside.any():
            side_gap = d[beside].min()
            wrap = 3.0 if side_gap < 0.0008 else 1.0
        back = (local[:, 0] < hx - 0.004) & (local[:, 2] < 0.0)
        back_gap = d[back].min() if back.any() else 0.02
        bend = sum(v[0] for v in s.values())
        # Fingertips on the side face, not hooked forward in front of the screen's plane.
        forward = max(0.0, local[:, 2].max() - hz - 0.008)
        return wrap - side_gap * 500.0 - back_gap * 100.0 - bend * 0.003 - forward * 250.0

    mcp = range(0, 51, 10) if coarse else range(0, 56, 5)
    pip = range(30, 111, 10) if coarse else range(20, 116, 5)
    for finger in ["Index", "Middle", "Ring", "Little"]:
        best = search_finger(hand, finger, [box], score, ok=lambda p: not over_screen(box, p), mcp=mcp, pip=pip,
                             dip_ratio=(0.6,) if coarse else (0.4, 0.6, 0.8))
        if best is None:
            return None, -1e9
        total += best[0]
        shape.update(best[1])
    return shape, total


def phone_thumb(hand, box, coarse=False):
    """The thumb up the near edge: its pad on the near side face, not over the screen."""
    hx, hz = PHONE_HALF[0], PHONE_HALF[2]

    def score(points, s):
        local = box.local(points)
        d, _ = box.distance(points)
        beside = (local[:, 0] < -hx + 0.0005) & (local[:, 0] > -hx - 0.018) & (local[:, 2] > -hz - 0.002) & (local[:, 2] < hz + 0.006)
        if not beside.any():
            return -10.0 - d.min() * 100.0
        gap = d[beside].min()
        # Lying along the edge (reaching up the phone), not standing out in front of the screen nor
        # past the phone's top.
        along = local[beside, 1].max() - local[beside, 1].min()
        front = max(0.0, local[:, 2].max() - hz - 0.008)
        past_top = max(0.0, local[:, 1].max() - PHONE_HALF[1] + 0.01)
        return (6.0 if gap < 0.0008 else 0.0) - gap * 800.0 + along * 80.0 - front * 300.0 - past_top * 300.0

    if coarse:
        return search_thumb(hand, [box], score, ok=lambda p: not over_screen(box, p), meta_x=range(-60, 61, 20),
                            meta_y=range(-40, 41, 20), meta_z=range(-30, 61, 15), flex=range(0, 41, 20))
    return search_thumb(hand, [box], score, ok=lambda p: not over_screen(box, p), meta_x=range(-70, 71, 10),
                        meta_y=range(-50, 51, 10), meta_z=range(-30, 71, 10), flex=range(0, 51, 10))


def straight_pips(hand, box):
    """Where the PIP joints of the straight fingers fall along the phone's width (local x)."""
    joints = hand.pose()
    return np.array([box.local(joints[hand.side + f + "Intermediate"][:3, 3][None, :])[0, 0] for f in ["Index", "Middle", "Ring", "Little"]])


def design_phone():
    hand = Hand("Left")
    rest = hand.skin(hand.pose())
    palm = hand.owner == "Palm"
    hx = PHONE_HALF[0]
    candidates = []
    for phi in (0.0, 10.0, 20.0, 30.0, 40.0, 50.0):
        for cx in np.arange(-0.06, 0.031, 0.006):
            for cy in np.arange(0.03, 0.131, 0.008):
                probe = phone_box(phi, np.array([cx, cy, 0.0]))
                local = probe.local(rest)
                under = (np.abs(local[:, 0]) < PHONE_HALF[0]) & (np.abs(local[:, 1]) < PHONE_HALF[1]) & palm
                if under.sum() < 5:
                    continue
                pips = straight_pips(hand, probe)
                near_edge = int(((pips > hx - 0.006) & (pips < hx + 0.022)).sum())
                if near_edge < 3:
                    continue
                # The thumb's root just outside the near edge, so the thumb can lie along it.
                root = probe.local(hand.pose()[hand.side + "ThumbMetacarpal"][:3, 3][None, :])[0]
                if not (-hx - 0.022 < root[0] < -hx + 0.004):
                    continue
                cz = rest[under, 2].max() + PHONE_HALF[2] + 0.0003
                candidates.append((near_edge, phi, cx, cy, cz))
    print("PHONE %d placements with three or four PIP joints at the far edge" % len(candidates), flush=True)
    scored = []
    for near_edge, phi, cx, cy, cz in candidates:
        box = phone_box(phi, np.array([cx, cy, cz]))
        shape, value = phone_fingers(hand, box, coarse=True)
        if shape is None:
            continue
        thumb = phone_thumb(hand, box, coarse=True)
        total = value + (thumb[0] if thumb else -20.0)
        scored.append((total, phi, cx, cy, cz))
    scored.sort(reverse=True)
    for row in scored[:8]:
        print("  coarse %.2f phi %.0f centre (%.3f %.3f %.4f)" % row, flush=True)
    best = None
    for total, phi, cx, cy, cz in scored[:4]:
        # The whole hand (the palm's edge moves with the fingers) must stay out: lift the phone off the
        # palm until it does, and pose the fingers again.
        for attempt in range(3):
            box = phone_box(phi, np.array([cx, cy, cz]))
            shape, value = phone_fingers(hand, box)
            thumb = phone_thumb(hand, box)
            if shape is None or thumb is None:
                break
            shape.update(thumb[1])
            value += thumb[0]
            into = -box.distance(hand.skin(hand.pose(shape)))[0].min()
            if into <= INTO:
                break
            cz += into + 0.0002
        if shape is None or thumb is None:
            continue
        print("  fine %.2f phi %.0f centre (%.3f %.3f %.4f) deepest %.1f mm" % (value, phi, cx, cy, cz, into * MM), flush=True)
        if into <= INTO and (best is None or value > best[0]):
            best = (value, box, shape)
    return hand, best[1], best[2]


def draw_in_thing(hand, shape, box, path, title, screen=None):
    """The hand in the held thing's own frame: its front (x-y, as the eyes see a phone's screen) and
    from its side (x-z)."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    colors = {"Palm": "gray", "Thumb": "red", "Index": "orange", "Middle": "green", "Ring": "blue", "Little": "purple"}
    local = box.local(hand.skin(hand.pose(shape))) * MM
    half = box.half * MM
    fig, axs = plt.subplots(1, 3, figsize=(16, 6))
    for ax, (a, b), name in zip(axs, ((0, 1), (0, 2), (1, 2)), ("front (x-y): the face you look at", "x-z: along its length", "y-z: across")):
        ax.add_patch(plt.Rectangle((-half[a], -half[b]), 2 * half[a], 2 * half[b], fill=False, color="k"))
        if screen is not None and (a, b) == (0, 1):
            ax.add_patch(plt.Rectangle((-screen[0] * MM, -screen[1] * MM), 2 * screen[0] * MM, 2 * screen[1] * MM, fill=False, color="c", ls="--"))
        order = np.argsort(local[:, 3 - a - b]) if (a, b) == (0, 1) else np.arange(len(local))
        for owner, color in colors.items():
            mask = hand.owner[order] == owner
            pts = local[order][mask]
            ax.scatter(pts[:, a], pts[:, b], s=4, c=color)
        ax.set_aspect("equal")
        ax.grid(True)
        ax.set_title(name + " (mm)")
    fig.suptitle(title)
    plt.tight_layout()
    plt.savefig(path, dpi=72)
    plt.close(fig)


# ---------------------------------------------------------------- reading: a sheet's right edge (right hand)

SHEET_HALF_THICK = 0.0003 / SCALE  # paper, about 0.3 mm (the game draws it as a quad)
EDGE_INSET = 0.015 / SCALE  # the HandTarget sits 1.5 cm inside the right edge, half way up (readable.gd)


def sheet_box(origin, x, y, z, width=0.21 / SCALE, height=0.297 / SCALE):
    """A sheet as a thin box from its HandTarget frame: origin 1.5 cm inside the right edge, half way up;
    x toward the right edge, y up the sheet, z out of its face."""
    centre = origin - x * (width / 2.0 - EDGE_INSET)
    return Box(centre, np.stack([x, y, z], axis=1), np.array([width / 2.0, height / 2.0, SHEET_HALF_THICK]))


def read_fingers():
    """Relaxed fingers behind the sheet; the index curled a little more, its side the thumb's anvil."""
    return {"IndexProximal": (25.0, 0.0, 0.0), "IndexIntermediate": (45.0, 0.0, 0.0), "IndexDistal": (25.0, 0.0, 0.0),
            "MiddleProximal": (20.0, 0.0, 0.0), "MiddleIntermediate": (40.0, 0.0, 0.0), "MiddleDistal": (25.0, 0.0, 0.0),
            "RingProximal": (22.0, 0.0, 0.0), "RingIntermediate": (45.0, 0.0, 0.0), "RingDistal": (28.0, 0.0, 0.0),
            "LittleProximal": (25.0, 0.0, 0.0), "LittleIntermediate": (50.0, 0.0, 0.0), "LittleDistal": (30.0, 0.0, 0.0)}


def design_read(width=0.21 / SCALE, height=0.297 / SCALE):
    """Right hand at the sheet's right edge: the face toward the thumb (+X of the hand), fingers behind
    it, the thumb's pad on the face; the edge deep in the web between the thumb and the index."""
    hand = Hand("Right")
    shape = read_fingers()
    x_s = np.array([0.0, 0.0, -1.0])  # toward the right edge: the back of the hand's direction
    y_s = np.array([0.0, 1.0, 0.0])   # up the sheet: along the fingers
    z_s = np.array([1.0, 0.0, 0.0])   # the face: toward the thumb's side
    verts = hand.skin(hand.pose(shape))
    best = None
    for edge in np.arange(0.0, 0.081, 0.01):
        # The sheet's plane just in front of every finger (not the thumb) over the sheet (z > edge).
        others = (hand.owner != "Thumb") & (verts[:, 2] > edge - 0.004)
        plane = verts[others, 0].max() + SHEET_HALF_THICK + 0.0003
        for up in np.arange(0.04, 0.141, 0.02):
            origin = np.array([plane, up, edge + EDGE_INSET])
            box = sheet_box(origin, x_s, y_s, z_s, width, height)

            def objective(points, posed, box=box):
                local = box.local(points)
                over = (np.abs(local[:, 0]) <= box.half[0]) & (np.abs(local[:, 1]) <= box.half[1])
                behind = np.maximum(0.0, -(local[over, 2] - box.half[2])).max() if over.any() else 0.0
                # The pad of the distal phalanx on the face, inside the edge.
                tip = box.local(posed["RightHandThumb4"][:3, 3][None, :])[0]
                ip = box.local(posed["RightThumbDistal"][:3, 3][None, :])[0]
                pad_r = 0.011
                on_face = (tip[2] - pad_r - box.half[2]) ** 2 + (ip[2] - pad_r - box.half[2]) ** 2
                inside = max(0.0, tip[0] - (box.half[0] - 0.012)) + max(0.0, -tip[0] + box.half[0] - 0.05)
                level = (tip[1] - 0.0) ** 2
                touch = (np.abs(local[over, 2] - box.half[2]) < 0.0012).sum() if over.any() else 0
                return behind * 2e4 + on_face * 3e4 + inside * 200.0 + level * 50.0 - touch * 0.003

            seeds = [(0, 0, 0, 20, 20), (0, 0, -30, 20, 20), (0, 0, 30, 20, 20), (-30, 0, 0, 20, 20), (30, 0, 0, 20, 20)]
            value, fitted, params = fit_thumb(hand, shape, objective, seeds=seeds)
            if best is None or value < best[0]:
                best = (value, edge, up, plane, fitted, box)
    value, edge, up, plane, fitted, box = best
    print("READ edge %.3f up %.3f plane %.4f value %.3f" % (edge, up, plane, value))
    return hand, box, fitted


# ---------------------------------------------------------------- picking a sheet up off a desk (right hand)

def pick_fingers(index=(18.0, 22.0, 12.0), rest=1.0):
    """Picking up: the index nearly straight (its tip goes to the edge), the other three bent `rest`
    times a relaxed curl, so they stay off the desk."""
    return {"IndexProximal": (index[0], 0.0, 0.0), "IndexIntermediate": (index[1], 0.0, 0.0), "IndexDistal": (index[2], 0.0, 0.0),
            "MiddleProximal": (25.0 * rest, 0.0, 0.0), "MiddleIntermediate": (35.0 * rest, 0.0, 0.0), "MiddleDistal": (20.0 * rest, 0.0, 0.0),
            "RingProximal": (30.0 * rest, 0.0, 0.0), "RingIntermediate": (40.0 * rest, 0.0, 0.0), "RingDistal": (22.0 * rest, 0.0, 0.0),
            "LittleProximal": (35.0 * rest, 0.0, 0.0), "LittleIntermediate": (40.0 * rest, 0.0, 0.0), "LittleDistal": (22.0 * rest, 0.0, 0.0)}


def hand_frame(roll, pitch):
    """The hand's axes over a sheet lying face up (sheet frame: x toward its right edge, y up the sheet,
    z out of its face): palm down, fingers up the sheet, the thumb's side toward the sheet (-x); rolled
    `roll` degrees (thumb side up) and pitched `pitch` degrees (fingers down toward the desk)."""
    x_h = np.array([-1.0, 0.0, 0.0])
    y_h = np.array([0.0, 1.0, 0.0])
    z_h = np.array([0.0, 0.0, -1.0])
    r = axis_angle(y_h, -roll)[:3, :3]  # about the fingers: the thumb's side comes up
    x_h, z_h = r @ x_h, r @ z_h
    p = axis_angle(x_h, pitch)[:3, :3]  # about the hand's width: the fingers go down
    y_h, z_h = p @ y_h, p @ z_h
    return np.stack([x_h, y_h, z_h], axis=1)


def crosses(box, posed, side, fingers=("Index", "Middle", "Ring", "Little")):
    """A finger's bone line (knuckle, joints, tip) passing through the sheet's plane inside its outline:
    the skin's vertices can step over a sheet this thin, its bones cannot (T-239, found by the game's
    own test on the drawn fingers)."""
    for finger in fingers:
        names = [side + finger + part for part in ("Proximal", "Intermediate", "Distal")] + [side + TIPS[finger]]
        points = box.local(np.array([posed[name][:3, 3] for name in names]))
        for a, b in zip(points[:-1], points[1:]):
            if (a[2] > 0.0) == (b[2] > 0.0):
                continue
            c = a + (b - a) * (a[2] / (a[2] - b[2]))
            if abs(c[0]) <= box.half[0] and abs(c[1]) <= box.half[1]:
                return True
    return False


def design_pick(width=0.15 / SCALE, height=0.21 / SCALE, lift=0.018 / SCALE):
    """At the pinch: with lift > 0 the sheet's right edge is lifted (turned about its left edge) onto the
    index fingertip, which lies on the desk under it ("nhac mep"); with lift 0 the fingertip stops at the
    edge on the desk ("kep thang"). The thumb's pad lies on the face just inside the edge; everything
    stays above the desk. Returns the hand, the sheet (hand space, as pinched), the shape and the hand in
    the flat sheet's frame."""
    hand = Hand("Right")
    tilt = math.asin(min(1.0, lift / width))
    edge_x = EDGE_INSET
    best = None
    rejected = {"below": 0, "high": 0, "cut": 0, "crosses": 0}
    for roll in (15.0, 30.0, 45.0):
        for pitch in (25.0, 40.0, 55.0):
            for index in ((20.0, 25.0, 15.0), (35.0, 40.0, 20.0), (45.0, 50.0, 25.0)):
                # The other three relaxed (the owner, 09/11: no fist, the arm not bent).
                for rest in (0.3, 0.5, 0.8):
                    shape = pick_fingers(index, rest)
                    frame = hand_frame(roll, pitch)
                    posed = hand.pose(shape)
                    verts = hand.skin(posed)
                    to_sheet = np.eye(4)
                    to_sheet[:3, :3] = frame
                    tip = posed["RightHandIndex4"][:3, 3]
                    # The index tip at the lifted edge's lip, its pad under it (the bone stays outside the
                    # edge: a finger along the edge but inside it would have to pass through the sheet), or
                    # just past the edge on the desk.
                    along = edge_x + 0.002 / SCALE if lift > 0.0 else edge_x + 0.009 / SCALE
                    to_sheet[:3, 3] = np.array([along, 0.0, 0.0]) - frame @ tip
                    in_sheet = (to_sheet @ np.c_[verts, np.ones(len(verts))].T).T[:, :3]
                    is_index = hand.owner == "Index"
                    # Rest the index's lowest point on the desk (the plane under the sheet).
                    to_sheet[2, 3] += (-SHEET_HALF_THICK + 0.0004) - in_sheet[is_index, 2].min()
                    in_sheet = (to_sheet @ np.c_[verts, np.ones(len(verts))].T).T[:, :3]
                    others = hand.owner != "Thumb"
                    below = max(0.0, (-SHEET_HALF_THICK - in_sheet[others, 2]).max())
                    if below > 0.0008:
                        rejected["below"] += 1
                        continue
                    # Lifted, the edge rests on the index: the sheet turns up about its left edge, from
                    # `lift` in 2 mm steps up to 4 cm at the edge, until no finger is in it or through it.
                    to_hand = np.linalg.inv(to_sheet)
                    left = np.array([edge_x - width, 0.0, 0.0])
                    box = None
                    used = 0.0
                    for rise in (np.arange(lift, 0.0401 / SCALE, 0.002 / SCALE) if lift > 0.0 else [0.0]):
                        turn = axis_angle((0.0, -1.0, 0.0), math.degrees(math.asin(min(1.0, rise / width))))
                        lifted = np.eye(4)
                        lifted[:3, :3] = turn[:3, :3]
                        lifted[:3, 3] = left - turn[:3, :3] @ left
                        marker_in_hand = to_hand @ lifted
                        trial = sheet_box(marker_in_hand[:3, 3], marker_in_hand[:3, 0], marker_in_hand[:3, 1], marker_in_hand[:3, 2], width, height)
                        if -trial.distance(verts[others])[0].min() <= INTO and not crosses(trial, posed, "Right"):
                            box = trial
                            used = float(rise)
                            break
                    if box is None:
                        rejected["crosses"] += 1
                        continue
                    desk_h = to_hand @ np.array([0.0, 0.0, -SHEET_HALF_THICK, 1.0])
                    desk_n = to_hand[:3, :3] @ np.array([0.0, 0.0, 1.0])

                    def objective(points, posed, box=box, desk_h=desk_h, desk_n=desk_n):
                        local = box.local(points)
                        over = (np.abs(local[:, 0]) <= box.half[0]) & (np.abs(local[:, 1]) <= box.half[1])
                        behind = np.maximum(0.0, -(local[over, 2] - box.half[2])).max() if over.any() else 0.0
                        under = np.maximum(0.0, -((points - desk_h[:3]) @ desk_n)).max()
                        tip_t = box.local(posed["RightHandThumb4"][:3, 3][None, :])[0]
                        ip_t = box.local(posed["RightThumbDistal"][:3, 3][None, :])[0]
                        pad = (tip_t[2] - 0.011 - box.half[2]) ** 2 + 0.5 * (ip_t[2] - 0.013 - box.half[2]) ** 2
                        inside = max(0.0, tip_t[0] - (box.half[0] - 0.008)) + max(0.0, box.half[0] - 0.035 - tip_t[0])
                        level = tip_t[1] ** 2
                        return behind * 2e4 + under * 2e4 + pad * 3e4 + inside * 300.0 + level * 30.0

                    seeds = [(0, 0, 0, 20, 20), (0, 0, -30, 25, 25), (0, 0, 30, 25, 25), (-30, 0, 0, 25, 25), (30, 0, 0, 25, 25)]
                    value, fitted, params = fit_thumb(hand, shape, objective, seeds=seeds)
                    # A lower lift looks more like a hand's (1 point per cm over the asked one).
                    value += (roll - 30.0) ** 2 * 0.0002 + rest * 0.004 + max(0.0, used - lift) * SCALE
                    if best is None or value < best[0]:
                        best = (value, roll, pitch, index, rest, fitted, box, to_sheet, used)
    if best is None:
        raise RuntimeError("no pick pose for lift %.0f mm: rejected %s" % (lift * MM, rejected))
    value, roll, pitch, index, rest, fitted, box, to_sheet, used = best
    print("PICK lift %.0f mm (asked %.0f): roll %.0f pitch %.0f index %s rest %.1f value %.3f" % (used * MM, lift * MM, roll, pitch, index, rest, value))
    return hand, box, fitted, to_sheet, used


def finish_phone(hand, box, shape):
    """The phone's thumb up its near edge (fit_thumb), then the whole hand checked against it."""
    hx, hy, hz = PHONE_HALF

    def objective(points, posed):
        local = box.local(points)
        d, _ = box.distance(points)
        into = np.maximum(0.0, -d - INTO).max()
        ip = box.local(posed[hand.side + "ThumbDistal"][:3, 3][None, :])[0]
        tip = box.local(posed[hand.side + "HandThumb4"][:3, 3][None, :])[0]
        radius = 0.011
        line = (ip[0] + hx + radius) ** 2 + ip[2] ** 2 + (tip[0] + hx + radius * 0.8) ** 2 + tip[2] ** 2
        past = max(0.0, local[:, 1].max() - hy)
        front = np.maximum(0.0, local[:, 2] - hz - 0.006).max()
        over = ((np.abs(local[:, 0]) < SCREEN_HALF[0]) & (np.abs(local[:, 1]) < SCREEN_HALF[1]) & (local[:, 2] > 0)).sum()
        touch = (d < 0.0012).sum()
        return line * 1e4 + into * 3e3 + past * 300 + front * 300 + over * 0.5 - touch * 0.002

    seeds = [(0, 0, 0, 10, 10), (0, 0, 30, 20, 20), (0, 0, -30, 20, 20), (30, 0, 0, 20, 20), (-30, 0, 0, 20, 20),
             (0, 30, 0, 20, 20), (0, -30, 0, 20, 20)]
    fingers = {k: v for k, v in shape.items() if not k.startswith("Thumb")}
    value, fitted, params = fit_thumb(hand, fingers, objective, seeds=seeds)
    return fitted


def quaternion_rows(shape):
    rows = []
    for name in sorted(shape):
        x, y, z, w = to_quaternion(as_matrix(shape[name]))
        rows.append(TAB + '"%s": Quaternion(%.7f, %.7f, %.7f, %.7f),' % (name, x, y, z, w))
    return NL.join(rows)


def transform_line(m):
    x, y, z, o = m[:3, 0], m[:3, 1], m[:3, 2], m[:3, 3]
    return "Transform3D(Vector3(%.7f, %.7f, %.7f), Vector3(%.7f, %.7f, %.7f), Vector3(%.7f, %.7f, %.7f), Vector3(%.7f, %.7f, %.7f))" % (
        *x, *y, *z, *o)


def export_gd(path):
    hand_l, phone, phone_shape = design_phone()
    phone_shape = finish_phone(hand_l, phone, phone_shape)
    print(report(hand_l, phone_shape, [phone], "PHONE final"))
    draw_in_thing(hand_l, phone_shape, phone, OUT / "grip_phone_front.png", "Phone frame: screen +z", SCREEN_HALF)
    hand_r, sheet, read_shape = design_read()
    print(report(hand_r, read_shape, [sheet], "READ final"))
    read_marker = np.eye(4)
    read_marker[:3, :3] = sheet.axes
    read_marker[:3, 3] = sheet.centre + sheet.axes[:, 0] * (sheet.half[0] - EDGE_INSET)
    picks = {}
    for lift, tag in ((0.018 / SCALE, "LIFT"), (0.0, "STRAIGHT")):
        hand_r, box, shape, to_sheet, used = design_pick(lift=lift)
        print(report(hand_r, shape, [box], "PICK %s final" % tag))
        draw_in_thing(hand_r, shape, box, OUT / ("grip_pick_%s_front.png" % tag.lower()), "Sheet frame as pinched (%s)" % tag)
        picks[tag] = (shape, to_sheet, used)
    lines = ["class_name HandShapes",
             "extends RefCounted",
             "## T-239: Tran Trung's finger poses and where a held thing sits in the hand, generated by",
             "## art_source/graphics_upgrade/protagonist/t239_grips.py from the Tripo hand (t239_hands.json): every",
             "## finger (the thumb too) posed against the thing so no part of the hand goes into it. Do not edit by hand.",
             "## Joints: local rotations on top of the rest pose (FingerPoseModifier). Transforms: in the hand bone's",
             "## frame, skeleton units (x across the palm, y along the fingers, z out of the palm).",
             "",
             "## The left hand on the phone (its Model frame: screen +Z): the back on the palm, the four fingers",
             "## round the far edge, the thumb up the near edge, nothing over the screen.",
             "const PHONE := {", quaternion_rows(phone_shape), "}",
             "const PHONE_IN_HAND := " + transform_line(phone.matrix()),
             "",
             "## Reading: the right hand at the sheet's right edge, the edge deep between the thumb and the index:",
             "## the thumb's pad on the face (toward the eyes), the fingers behind. The HandTarget's frame (1.5 cm",
             "## inside the edge, half way up; +Z the face) in the hand.",
             "const READ := {", quaternion_rows(read_shape), "}",
             "const SHEET_IN_HAND_READ := " + transform_line(read_marker),
             "",
             "## Picking a sheet up off a desk: the thumb's pad on the face just inside the right edge, the index",
             "## fingertip on the desk under it, the edge lifted onto it (LIFT, \"nhac mep\") or not (STRAIGHT, \"kep",
             "## thang\"). The hand in the flat sheet's HandTarget frame at the pinch, and how far the edge rises.",
    ]
    for tag in ("LIFT", "STRAIGHT"):
        shape, to_sheet, lift = picks[tag]
        lines.append("const PICK_%s := {" % tag)
        lines.append(quaternion_rows(shape))
        lines.append("}")
        lines.append("const HAND_IN_SHEET_PICK_%s := %s" % (tag, transform_line(to_sheet)))
        lines.append("const PICK_%s_RISE: float = %.5f" % (tag, lift * SCALE))
    lines += ["",
              "## Finger radii on the Tripo mesh (skeleton units; medians from the T-239 probe), root to tip: the",
              "## tests' finger capsules.",
              "const RADII := {\"Thumb\": [0.016, 0.011, 0.010], \"Index\": [0.012, 0.010, 0.008], \"Middle\": [0.012, 0.010, 0.008],",
              TAB + "\"Ring\": [0.011, 0.010, 0.008], \"Little\": [0.010, 0.009, 0.007]}", ""]
    Path(path).write_text(NL.join(lines), encoding="utf-8", newline=NL)
    print("WROTE", path)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    if which == "export":
        export_gd(Path(__file__).resolve().parents[3] / "game" / "scripts" / "player" / "hand_shapes.gd")
        sys.exit(0)
    if which in ("phone", "all"):
        hand, box, shape = design_phone()
        print(report(hand, shape, [box], "PHONE nearest surfaces"))
        print(gd_shape("PHONE", shape))
        print(gd_transform("PHONE_IN_HAND", box.matrix()))
        draw(hand, shape, [box], OUT / "grip_phone.png", "Left hand on the phone")
        draw_in_thing(hand, shape, box, OUT / "grip_phone_front.png", "Phone frame: screen +z", SCREEN_HALF)
    if which in ("read", "all"):
        hand, box, shape = design_read()
        print(report(hand, shape, [box], "READ nearest surfaces"))
        draw(hand, shape, [box], OUT / "grip_read.png", "Right hand holding a sheet's right edge")
        draw_in_thing(hand, shape, box, OUT / "grip_read_front.png", "Sheet frame: face +z (the eyes)")
    if which in ("pick", "all"):
        for lift, tag in ((0.018 / SCALE, "lift"), (0.0, "straight")):
            hand, box, shape, to_sheet = design_pick(lift=lift)
            print(report(hand, shape, [box], "PICK %s nearest surfaces" % tag))
            draw(hand, shape, [box], OUT / ("grip_pick_%s.png" % tag), "Right hand picking a sheet's edge off the desk (%s)" % tag)
            draw_in_thing(hand, shape, box, OUT / ("grip_pick_%s_front.png" % tag), "Sheet frame as pinched: face +z (up)")
