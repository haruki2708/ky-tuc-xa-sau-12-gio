"""T-239: Tran Trung's hands, rebuilt outside Godot to design finger poses against what they hold.

Reads the hand dump (bones at rest and the skinned vertices near each hand, skeleton space) written by
the T-239 probe (`t239_hands.json`, beside this file). Poses the fingers by forward kinematics with
local rotations on top of the rest pose (as game/scripts/player/finger_pose_modifier.gd does), skins
the vertices (linear blend), and measures them against boxes (a phone, a sheet, a lever bar, a door leaf).
Everything is in the hand bone's own frame ("hand space", skeleton units: world = SCALE x skeleton):
  x across the palm (right hand: toward the thumb; left hand: toward the little finger),
  y along the fingers, z out of the palm (the side the fingers curl to).
"""
import json
import math
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE / "t239_hands.json").read_text(encoding="utf-8"))
SCALE = DATA["skeleton_world_scale"]
FINGERS = ["Thumb", "Index", "Middle", "Ring", "Little"]
TIPS = {"Thumb": "HandThumb4", "Index": "HandIndex4", "Middle": "HandMiddle4", "Ring": "HandRing4", "Little": "HandPinky4"}


def parts(finger):
    return ["Metacarpal", "Proximal", "Distal"] if finger == "Thumb" else ["Proximal", "Intermediate", "Distal"]


def joints(side):
    """The 15 posable finger joints of a hand, root first per finger."""
    return [side + f + p for f in FINGERS for p in parts(f)]


def mat(values):
    m = np.eye(4)
    m[:3, 0] = values[0:3]
    m[:3, 1] = values[3:6]
    m[:3, 2] = values[6:9]
    m[:3, 3] = values[9:12]
    return m


def rot_euler(deg):
    """Godot Basis.from_euler (YXZ order) of degrees (x, y, z), as a 4x4."""
    x, y, z = (math.radians(a) for a in deg)
    cx, sx, cy, sy, cz, sz = math.cos(x), math.sin(x), math.cos(y), math.sin(y), math.cos(z), math.sin(z)
    rx = np.array([[1, 0, 0], [0, cx, -sx], [0, sx, cx]])
    ry = np.array([[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]])
    rz = np.array([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]])
    m = np.eye(4)
    m[:3, :3] = ry @ rx @ rz
    return m


def quat_to_mat(q):
    x, y, z, w = q
    m = np.eye(4)
    m[:3, :3] = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                 [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                 [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]
    return m


class Hand:
    def __init__(self, side):
        self.side = side
        hand = DATA["hands"][side]
        self.bones = {b["name"]: b for b in hand["bones"]}
        self.rest_global = {n: mat(b["rest_global"]) for n, b in self.bones.items()}
        self.rest_local = {n: mat(b["rest_local"]) for n, b in self.bones.items()}
        self.parent = {n: b["parent"] for n, b in self.bones.items()}
        self.hand_rest = self.rest_global[side + "Hand"]
        self.to_hand = np.linalg.inv(self.hand_rest)
        verts = hand["vertices"]
        self.rest_points = np.array([v["p"] + [1.0] for v in verts])
        names = sorted({w[0] for v in verts for w in v["w"]})
        self.weight_bones = names
        self.weights = np.zeros((len(verts), len(names)))
        index = {n: i for i, n in enumerate(names)}
        for i, v in enumerate(verts):
            for name, w in v["w"]:
                self.weights[i, index[name]] += w
        self.weights /= self.weights.sum(axis=1, keepdims=True)
        # Which finger (or palm) each vertex belongs to: its strongest finger bone, else the palm.
        self.owner = []
        for v in verts:
            best = max(v["w"], key=lambda e: e[1])[0]
            owner = "Palm"
            for f in FINGERS:
                if f in best or (f == "Little" and "Pinky" in best):
                    owner = f
            self.owner.append(owner)
        self.owner = np.array(self.owner)
        self.idle = {n: quat_to_mat(b["idle_local_rotation"]) for n, b in self.bones.items()}

    def pose(self, shape=None, idle=False):
        """Global transforms (hand space) of every hand bone for `shape` {joint suffix: euler degrees},
        local rotations on top of the rest pose (or the idle clip's rotations when idle=True)."""
        shape = shape or {}
        out = {}

        def solve(name):
            if name in out:
                return out[name]
            parent = self.parent[name]
            local = self.rest_local[name].copy()
            if idle and name in self.idle and not name.endswith("Hand"):
                local[:3, :3] = self.idle[name][:3, :3]
            key = name[len(self.side):]
            if key in shape:
                value = shape[key]
                local = local @ (value if isinstance(value, np.ndarray) else rot_euler(value))
            if name == self.side + "Hand":
                g = np.eye(4)
            elif parent in self.bones:
                g = solve(parent) @ local
            else:
                g = self.to_hand @ self.rest_global[parent] @ local if parent in self.rest_global else local
            out[name] = g
            return g

        for name in self.bones:
            if name.endswith("LowerArm"):
                out[name] = self.to_hand @ self.rest_global[name]
        for name in self.bones:
            solve(name)
        return out

    def skin(self, posed, mask=None):
        """Vertices (hand space) for posed bone transforms (linear blend skinning), all or `mask`."""
        if not hasattr(self, "_hand_rest_points"):
            self._hand_rest_points = (self.to_hand @ self.rest_points.T).T
            self._inv_rest = {n: np.linalg.inv(self.to_hand @ self.rest_global[n]) for n in self.weight_bones}
        rest_points = self._hand_rest_points if mask is None else self._hand_rest_points[mask]
        weights = self.weights if mask is None else self.weights[mask]
        out = np.zeros((len(rest_points), 3))
        for j, name in enumerate(self.weight_bones):
            w = weights[:, j]
            if not w.any():
                continue
            m = posed[name] @ self._inv_rest[name]
            out += (rest_points @ m.T)[:, :3] * w[:, None]
        return out

    def joint_points(self, posed):
        """Joint origins per finger, root to tip, hand space."""
        chains = {}
        for f in FINGERS:
            chain = [posed[self.side + f + p][:3, 3] for p in parts(f)]
            chain.append(posed[self.side + TIPS[f]][:3, 3])
            chains[f] = np.array(chain)
        return chains


def axis_angle(axis, degrees):
    axis = np.asarray(axis, float) / np.linalg.norm(axis)
    x, y, z = axis
    c, s = math.cos(math.radians(degrees)), math.sin(math.radians(degrees))
    t = 1.0 - c
    m = np.eye(4)
    m[:3, :3] = [[t * x * x + c, t * x * y - s * z, t * x * z + s * y],
                 [t * x * y + s * z, t * y * y + c, t * y * z - s * x],
                 [t * x * z - s * y, t * y * z + s * x, t * z * z + c]]
    return m


def as_matrix(value):
    return value if isinstance(value, np.ndarray) else rot_euler(value)


def to_quaternion(m):
    """Rotation part of a 4x4 as (x, y, z, w)."""
    r = m[:3, :3]
    w = math.sqrt(max(0.0, 1.0 + r[0, 0] + r[1, 1] + r[2, 2])) / 2.0
    x = math.sqrt(max(0.0, 1.0 + r[0, 0] - r[1, 1] - r[2, 2])) / 2.0
    y = math.sqrt(max(0.0, 1.0 - r[0, 0] + r[1, 1] - r[2, 2])) / 2.0
    z = math.sqrt(max(0.0, 1.0 - r[0, 0] - r[1, 1] + r[2, 2])) / 2.0
    x = math.copysign(x, r[2, 1] - r[1, 2])
    y = math.copysign(y, r[0, 2] - r[2, 0])
    z = math.copysign(z, r[1, 0] - r[0, 1])
    return (x, y, z, w)


def box_distance(points, centre, axes, half):
    """Signed distance of points (N,3) to a box (centre, 3x3 axes as columns, half size): < 0 inside."""
    local = (points - centre) @ axes
    q = np.abs(local) - half
    outside = np.linalg.norm(np.maximum(q, 0.0), axis=1)
    inside = np.minimum(np.max(q, axis=1), 0.0)
    return outside + inside, local


def frame(origin, x, y, z):
    m = np.eye(4)
    m[:3, 0], m[:3, 1], m[:3, 2], m[:3, 3] = x, y, z, origin
    return m


if __name__ == "__main__":
    for side in ("Right", "Left"):
        h = Hand(side)
        posed = h.pose()
        verts = h.skin(posed)
        print(side, "vertices", len(verts), "owners", {o: int((h.owner == o).sum()) for o in set(h.owner)})
        print("  rest extents x %.3f..%.3f y %.3f..%.3f z %.3f..%.3f" % (verts[:, 0].min(), verts[:, 0].max(),
              verts[:, 1].min(), verts[:, 1].max(), verts[:, 2].min(), verts[:, 2].max()))
        palm = verts[(h.owner == "Palm") & (np.abs(verts[:, 0]) < 0.025) & (verts[:, 1] > 0.03) & (verts[:, 1] < 0.08)]
        print("  palm patch z: max %.4f (palm face), min %.4f (back of the hand)" % (palm[:, 2].max(), palm[:, 2].min()))
        for f, chain in h.joint_points(posed).items():
            print("  %-6s %s" % (f, " ".join("(%.3f %.3f %.3f)" % tuple(p) for p in chain)))
