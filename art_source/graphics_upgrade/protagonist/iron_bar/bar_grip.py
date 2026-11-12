"""T-249: Tran Trung's right hand on chapter 3's iron bar (a 27 mm pipe), designed on the Tripo hand as
T-239's grips were (../t239_hands.py, ../t239_grips.py): no finger goes into the bar.
  python -B art_source/graphics_upgrade/protagonist/iron_bar/bar_grip.py [export]
- FIST: the bar across the palm, a little oblique (toward the fingers on the thumb's side, as a hammer
  is held), the four fingers wrapped round it, the thumb closed over the index.
- HOOK: how the hand takes a bar that lies on the ground: the fingers half curled, the bar against
  their pads; closing the hand (HOOK to FIST) rolls it into the palm.
Printed as GDScript for game/scripts/player/bar_hand.gd ("export" writes the file) and drawn to
build/t249/grip_bar_*.png. Units: skeleton units in the hand bone's frame (x across the palm toward
the thumb, y along the fingers, z out of the palm); world metres = SCALE x skeleton units.
The bar's frame in the hand: origin on its middle line at the middle of the fist, +Z toward its far
end (the thumb's side), +X out of the palm (square to the bar), +Y = Z x X.
"""
import math
import sys
from pathlib import Path

import numpy as np

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from t239_hands import FINGERS, SCALE, TIPS, Hand, as_matrix, axis_angle  # noqa: E402
from t239_grips import INTO, MM, NL, TAB, finger_shape, fit_thumb, quaternion_rows, search_finger, transform_line  # noqa: E402

OUT = HERE.parents[3] / "build" / "t249"
RADIUS = 0.0135 / SCALE
FOUR = ["Index", "Middle", "Ring", "Little"]
# Finger radii root to tip (skeleton units), as HandShapes.RADII.
RADII = {"Thumb": [0.016, 0.011, 0.010], "Index": [0.012, 0.010, 0.008], "Middle": [0.012, 0.010, 0.008],
         "Ring": [0.011, 0.010, 0.008], "Little": [0.010, 0.009, 0.007]}


class Bar:
    """A long round bar in hand space: a point on its middle line, the way it runs, its radius."""

    def __init__(self, point, along, radius=RADIUS):
        self.point = np.asarray(point, float)
        self.along = np.asarray(along, float) / np.linalg.norm(along)
        self.radius = radius

    def distance(self, points):
        """Signed distance of points (N, 3) to the bar's surface (< 0 inside), and how far each is along it."""
        rel = np.atleast_2d(points) - self.point
        t = rel @ self.along
        radial = np.linalg.norm(rel - t[:, None] * self.along, axis=1)
        return radial - self.radius, t

    def frame(self, origin_x=0.0):
        """The bar's frame (see the top) with its origin where the middle line crosses hand x = origin_x."""
        z = self.along
        out = np.array([0.0, 0.0, 1.0])
        x = out - z * (out @ z)
        x /= np.linalg.norm(x)
        y = np.cross(z, x)
        t = (origin_x - self.point[0]) / z[0] if abs(z[0]) > 1e-6 else 0.0
        m = np.eye(4)
        m[:3, 0], m[:3, 1], m[:3, 2], m[:3, 3] = x, y, z, self.point + z * t
        return m


def bar_at(y, z, oblique):
    phi = math.radians(oblique)
    return Bar([0.0, y, z], [math.cos(phi), math.sin(phi), 0.0])


def wrap_score(hand, finger, bar):
    """A finger wrapped round the bar: each joint beyond the knuckle and the tip a finger's radius off its surface."""
    radii = RADII[finger]
    side = hand.side

    def score(points, shape):
        posed = hand.pose(shape)
        names = [side + finger + "Intermediate", side + finger + "Distal", side + TIPS[finger]]
        gaps = [bar.distance(posed[name][:3, 3])[0][0] for name in names]
        # The middle joint may stand off (a thin bar leaves room inside the fist); the pad and tip close on it.
        miss = max(0.0, gaps[0] - radii[0] - 0.004) * 0.6 + abs(gaps[1] - radii[1]) + abs(gaps[2] - radii[2]) * 1.2
        d = bar.distance(points)[0]
        return -miss * 1000.0 + float((d < 0.0015).sum()) * 0.01

    return score


def fist_fingers(hand, bar, coarse=False):
    shape = {}
    total = 0.0
    step = 10 if coarse else 5
    for finger in FOUR:
        best = search_finger(hand, finger, [bar], wrap_score(hand, finger, bar), mcp=range(30, 96, step), pip=range(40, 116, step),
                             dip_ratio=(0.6,) if coarse else (0.45, 0.6, 0.75, 0.9))
        if best is None:
            return None, -1e9
        total += best[0]
        shape.update(best[1])
    return shape, total


def design_fist():
    hand = Hand("Right")
    palm = hand.owner == "Palm"
    rest = hand.skin(hand.pose())
    scored = []
    for oblique in (10.0, 18.0, 26.0):
        for y in np.arange(0.085, 0.1251, 0.005):
            for z in np.arange(0.024, 0.0481, 0.004):
                bar = bar_at(y, z, oblique)
                # Pressed into the palm at most 2.5 mm (soft there), not floating off it.
                gap = bar.distance(rest[palm])[0].min()
                if gap < -0.0025 or gap > 0.004:
                    continue
                shape, value = fist_fingers(hand, bar, coarse=True)
                if shape is None:
                    continue
                scored.append((value - abs(gap) * 300.0, oblique, y, z))
    scored.sort(reverse=True)
    for row in scored[:6]:
        print("  FIST coarse %.2f oblique %.0f y %.3f z %.3f" % row, flush=True)
    best = None
    for value, oblique, y, z in scored[:4]:
        bar = bar_at(y, z, oblique)
        shape, value = fist_fingers(hand, bar)
        if shape is not None and (best is None or value > best[0]):
            best = (value, bar, shape, oblique, y, z)
    value, bar, shape, oblique, y, z = best
    print("FIST oblique %.0f y %.3f z %.3f value %.2f" % (oblique, y, z, value))
    return hand, bar, fist_thumb(hand, bar, shape)


def fist_thumb(hand, bar, shape):
    """The thumb closed over the index's middle bone (outside it, away from the bar), clear of the bar."""
    posed = hand.pose(shape)
    side = hand.side
    a = posed[side + "IndexIntermediate"][:3, 3]
    b = posed[side + "IndexDistal"][:3, 3]
    middle = (a + b) / 2.0
    rel = middle - bar.point
    out = rel - bar.along * (rel @ bar.along)
    out /= np.linalg.norm(out)
    target = middle + out * (RADII["Index"][1] + RADII["Thumb"][2])
    index_points = hand.skin(posed, hand.owner == "Index")

    def objective(points, posed_thumb):
        into_bar = np.maximum(0.0, -bar.distance(points)[0] - INTO).max()
        tip = posed_thumb[side + "HandThumb4"][:3, 3]
        # Not through the index: every thumb point clear of the index's skin by a millimetre.
        gaps = np.linalg.norm(points[:, None, :] - index_points[None, ::3, :], axis=2).min(axis=1)
        into_index = np.maximum(0.0, 0.003 - gaps).max()
        return float(np.linalg.norm(tip - target)) * 60.0 + into_bar * 3e3 + into_index * 2e3

    seeds = [(0, 0, 0, 20, 20), (0, 0, -40, 30, 30), (0, 0, 40, 30, 30), (-40, 0, 0, 30, 30), (40, 0, 0, 30, 30),
             (0, 40, 0, 30, 30), (0, -40, 0, 30, 30), (30, 30, -30, 40, 40), (-30, -30, 30, 40, 40)]
    value, fitted, params = fit_thumb(hand, shape, objective, seeds=seeds)
    print("FIST thumb value %.3f params %s" % (value, [round(p, 1) for p in params]))
    return fitted


def design_hook(oblique):
    """The fingers half curled, the bar against the pads of their end bones; the thumb out of the way."""
    hand = Hand("Right")
    shape = {}
    for finger, (mcp, pip, dip) in {"Index": (28.0, 42.0, 26.0), "Middle": (30.0, 45.0, 28.0), "Ring": (32.0, 46.0, 28.0),
                                    "Little": (34.0, 46.0, 28.0)}.items():
        shape.update(finger_shape(finger, mcp, pip, dip))
    shape.update({"ThumbMetacarpal": (0.0, 0.0, 0.0), "ThumbProximal": (0.0, 0.0, -10.0), "ThumbDistal": (0.0, 0.0, -8.0)})
    posed = hand.pose(shape)
    side = hand.side
    # Under the middle finger's end bone, on its palm side: out from the bone's middle, square to it,
    # toward the side the fingers curl to.
    a = posed[side + "MiddleDistal"][:3, 3]
    b = posed[side + TIPS["Middle"]][:3, 3]
    bone = (b - a) / np.linalg.norm(b - a)
    across = np.array([math.cos(math.radians(oblique)), math.sin(math.radians(oblique)), 0.0])
    pad = np.cross(across, bone)
    pad /= np.linalg.norm(pad)
    if pad[2] < 0.0:
        pad = -pad
    start = (a + b) / 2.0
    fingers = hand.skin(posed, np.isin(hand.owner, FOUR + ["Palm"]))
    best = None
    for off in np.arange(0.0, 0.0301, 0.0005):
        bar = Bar(start + pad * (RADIUS + off), across)
        if bar.distance(fingers)[0].min() >= -INTO:
            best = bar
            break
    print("HOOK bar %.1f mm off the middle finger's end bone" % ((np.linalg.norm(best.point - start) - RADIUS) * MM))
    return hand, best, shape


def report(hand, shape, bar, label):
    verts = hand.skin(hand.pose(shape))
    lines = [label]
    for f in FINGERS + ["Palm"]:
        d = bar.distance(verts[hand.owner == f])[0].min()
        lines.append("  %-6s nearest surface %+.1f mm" % (f, d * MM))
    return NL.join(lines)


def draw(hand, shape, bar, path, title):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    colors = {"Palm": "gray", "Thumb": "red", "Index": "orange", "Middle": "green", "Ring": "blue", "Little": "purple"}
    verts = hand.skin(hand.pose(shape))
    frame = bar.frame()
    local = (verts - frame[:3, 3]) @ frame[:3, :3] * MM
    fig, axs = plt.subplots(1, 3, figsize=(17, 6))
    for ax, (a, b), name in zip(axs, ((0, 1), (2, 0), (2, 1)), ("along the bar: x out of the palm, y", "side: z along the bar, x out of the palm", "z along the bar, y")):
        for owner, color in colors.items():
            mask = hand.owner == owner
            ax.scatter(local[mask, a], local[mask, b], s=4, c=color)
        r = bar.radius * MM
        if (a, b) == (0, 1):
            ax.add_patch(plt.Circle((0.0, 0.0), r, fill=False, color="k"))
        else:
            ax.plot([-150, 150], [r, r], "k-", lw=0.8)
            ax.plot([-150, 150], [-r, -r], "k-", lw=0.8)
            ax.set_xlim(-90, 90)
        ax.set_aspect("equal")
        ax.grid(True)
        ax.set_title(name + " (mm)")
    fig.suptitle(title)
    plt.tight_layout()
    plt.savefig(path, dpi=72)
    plt.close(fig)


def export_gd(path, fist, bar_fist, hook, bar_hook):
    # Both frames' origins at the same place along the bar: where the fist's middle is.
    origin_x = -0.004
    lines = ["class_name BarHand",
             "extends RefCounted",
             "## T-249: Tran Trung's right hand on chapter 3's iron bar (a 27 mm pipe), generated by",
             "## art_source/graphics_upgrade/protagonist/iron_bar/bar_grip.py from the Tripo hand, as HandShapes was:",
             "## no finger goes into the bar. Do not edit by hand.",
             "## Joints: local rotations on top of the rest pose (FingerPoseModifier). Transforms: the bar's frame in",
             "## the hand bone's frame, skeleton units: its origin on the bar's middle line at the middle of the fist,",
             "## +Z toward the bar's far end (the thumb's side), +X out of the palm.",
             "",
             "## The fist round the bar: it lies across the palm a little obliquely (as a hammer is held), the four",
             "## fingers wrapped round it, the thumb closed over the index.",
             "const FIST := {", quaternion_rows(fist), "}",
             "const BAR_IN_FIST := " + transform_line(bar_fist.frame(origin_x)),
             "",
             "## Taking a bar that lies on the ground: the fingers half curled, the bar against the pads of their",
             "## end bones. Closing the hand (HOOK to FIST) rolls it into the palm.",
             "const HOOK := {", quaternion_rows(hook), "}",
             "const BAR_IN_HOOK := " + transform_line(bar_hook.frame(origin_x)),
             ""]
    Path(path).write_text(NL.join(lines), encoding="utf-8", newline=NL)
    print("WROTE", path)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    hand, bar_fist, fist = design_fist()
    print(report(hand, fist, bar_fist, "FIST nearest surfaces"))
    draw(hand, fist, bar_fist, OUT / "grip_bar_fist.png", "Right fist round the iron bar")
    oblique = math.degrees(math.atan2(bar_fist.along[1], bar_fist.along[0]))
    hand, bar_hook, hook = design_hook(oblique)
    print(report(hand, hook, bar_hook, "HOOK nearest surfaces"))
    draw(hand, hook, bar_hook, OUT / "grip_bar_hook.png", "Right hand hooking the iron bar off the ground")
    for name, bar in (("BAR_IN_FIST", bar_fist), ("BAR_IN_HOOK", bar_hook)):
        frame = bar.frame(-0.004)
        print("%s origin %s (wrist to bar %.1f mm)" % (name, np.round(frame[:3, 3], 4), np.linalg.norm(frame[:3, 3]) * MM))
    if len(sys.argv) > 1 and sys.argv[1] == "export":
        export_gd(HERE.parents[3] / "game" / "scripts" / "player" / "bar_hand.gd", fist, bar_fist, hook, bar_hook)
